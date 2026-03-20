#!/bin/bash
# trim-dead-air.sh
# Usage: ./trim-dead-air.sh <input_file> [--min-duration 3] [--headroom 15]
# Measures voice loudness baseline via ebur128, then flags silence that far below it.
# Requires: ffmpeg, gawk (brew install gawk)

set -e

INPUT=""
MIN_DURATION=3
HEADROOM=15  # dB below baseline that counts as silence

while [[ $# -gt 0 ]]; do
  case "$1" in
    --min-duration) MIN_DURATION="$2"; shift 2 ;;
    --headroom)     HEADROOM="$2";     shift 2 ;;
    -*) echo "Unknown option: $1"; exit 1 ;;
    *)  INPUT="$1"; shift ;;
  esac
done

if [ -z "$INPUT" ]; then
  echo "Usage: $0 <input_file> [--min-duration 3] [--headroom 15]"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "Error: file '$INPUT' not found."
  exit 1
fi

GAWK=$(command -v gawk || command -v awk)

fmt_time() {
  echo "$1" | "$GAWK" '{
    total = $1
    h = int(total / 3600)
    m = int((total % 3600) / 60)
    s = total - (h * 3600) - (m * 60)
    printf "%02d:%02d:%06.3f", h, m, s
  }'
}

DURATION=$(ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 "$INPUT" 2>/dev/null)
DURATION_FMT=$(fmt_time "$DURATION")

echo ""
echo "File:     $INPUT"
echo "Duration: $DURATION_FMT"
echo ""

# Step 1: measure loudness via ebur128 — use LRA high (loudest sustained parts = voice)
echo "Measuring voice loudness baseline..."
EBUR_LOG=$(ffmpeg -i "$INPUT" -af "ebur128=peak=true" -f null - 2>&1)

# LRA high = top of the loudness range, best proxy for voice level
# Avoids drag-down from silent sections that skew integrated loudness
LRA_HIGH=$(echo "$EBUR_LOG" | grep "LRA high:" | tail -1 | awk '{print $3}')

# Fall back to integrated loudness if LRA high is unavailable
if [ -z "$LRA_HIGH" ] || [ "$LRA_HIGH" = "-inf" ]; then
  LRA_HIGH=$(echo "$EBUR_LOG" | grep "I:" | grep "LUFS" | tail -1 | awk '{print $2}')
fi

if [ -z "$LRA_HIGH" ]; then
  echo "Error: could not measure loudness. Is this file valid?"
  exit 1
fi

# Silence threshold = baseline - headroom
THRESHOLD=$(echo "$LRA_HIGH $HEADROOM" | "$GAWK" '{printf "%.1f", $1 - $2}')

echo "Voice baseline:    ${LRA_HIGH} LUFS (LRA high)"
echo "Silence threshold: ${THRESHOLD} dB  (${HEADROOM}dB below baseline)"
echo "Min duration:      ${MIN_DURATION}s"
echo ""
echo "Detecting dead air..."
echo ""

# Step 2: run silencedetect using the computed threshold
SILENCE_LOG=$(ffmpeg -i "$INPUT" \
  -af "silencedetect=noise=${THRESHOLD}dB:d=${MIN_DURATION}" \
  -f null - 2>&1)

STARTS=()
ENDS=()

while IFS= read -r line; do
  if echo "$line" | grep -q "silence_start:"; then
    val=$(echo "$line" | awk -F'silence_start: ' '{print $2}' | awk '{print $1}')
    STARTS+=("$val")
  elif echo "$line" | grep -q "silence_end:"; then
    val=$(echo "$line" | awk -F'silence_end: ' '{print $2}' | awk '{print $1}')
    ENDS+=("$val")
  fi
done <<< "$SILENCE_LOG"

if [ ${#STARTS[@]} -eq 0 ]; then
  echo "No dead air detected with current settings."
  echo "Try --headroom 10 to be less aggressive, or --min-duration 1 for shorter gaps."
  exit 0
fi

echo "Detected ${#STARTS[@]} dead air section(s):"
echo ""

TO_CUT_STARTS=()
TO_CUT_ENDS=()

for (( i=0; i<${#STARTS[@]}; i++ )); do
  START="${STARTS[$i]}"
  END="${ENDS[$i]:-$DURATION}"

  LEN=$(echo "$END $START" | "$GAWK" '{printf "%.1f", $1 - $2}')
  START_FMT=$(fmt_time "$START")
  END_FMT=$(fmt_time "$END")

  printf "  [%d] %s --> %s  (%ss)\n" "$((i+1))" "$START_FMT" "$END_FMT" "$LEN"
  read -p "      Cut this section? [y/N] " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    TO_CUT_STARTS+=("$START")
    TO_CUT_ENDS+=("$END")
  fi
done

if [ ${#TO_CUT_STARTS[@]} -eq 0 ]; then
  echo ""
  echo "Nothing to cut. Exiting."
  exit 0
fi

echo ""
echo "Cutting ${#TO_CUT_STARTS[@]} section(s)..."

BASENAME="${INPUT%.*}"
EXT="${INPUT##*.}"
OUTPUT="${BASENAME}-cut.mp4"

PARTS=()
LIST=$(mktemp /tmp/trim_list_XXXXXX.txt)

cleanup() {
  for f in "${PARTS[@]}"; do rm -f "$f"; done
  rm -f "$LIST"
}
trap cleanup EXIT

SEG_STARTS=()
SEG_ENDS=()
PREV_END=0

for (( i=0; i<${#TO_CUT_STARTS[@]}; i++ )); do
  SEG_STARTS+=("$PREV_END")
  SEG_ENDS+=("${TO_CUT_STARTS[$i]}")
  PREV_END="${TO_CUT_ENDS[$i]}"
done
SEG_STARTS+=("$PREV_END")
SEG_ENDS+=("$DURATION")

> "$LIST"
SEG_NUM=0

for (( i=0; i<${#SEG_STARTS[@]}; i++ )); do
  S="${SEG_STARTS[$i]}"
  E="${SEG_ENDS[$i]}"
  IS_POS=$(echo "$E $S" | "$GAWK" '{print ($1 - $2 > 0) ? "yes" : "no"}')
  if [ "$IS_POS" != "yes" ]; then continue; fi

  SEG_NUM=$((SEG_NUM+1))
  PART=$(mktemp /tmp/trim_part_XXXXXX)
  mv "$PART" "${PART}.${EXT}"
  PART="${PART}.${EXT}"
  PARTS+=("$PART")
  echo "  Segment $SEG_NUM: $(fmt_time $S) --> $(fmt_time $E)"
  ffmpeg -y -loglevel error -stats \
    -i "$INPUT" -ss "$S" -to "$E" \
    -c:v libx264 -c:a aac "$PART"
  printf "file '%s'\n" "$PART" >> "$LIST"
done

echo ""
echo "Joining $SEG_NUM segments..."
ffmpeg -y -loglevel error -stats \
  -f concat -safe 0 -i "$LIST" -c copy "$OUTPUT"

echo ""
echo "Done. Output: $OUTPUT"
