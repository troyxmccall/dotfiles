#!/usr/bin/env bash

for key in MakeLarger MakeSmaller MoveToBottomDisplay MoveToBottomHalf MoveToCenter MoveToFullscreen MoveToLeftDisplay MoveToLeftHalf MoveToLowerLeft MoveToLowerRight MoveToNextDisplay MoveToNextThird MoveToPreviousDisplay MoveToPreviousThird MoveToRightDisplay MoveToRightHalf MoveToTopDisplay MoveToTopHalf MoveToUpperLeft MoveToUpperRight RedoLastMove UndoLastMove; do
  printf "defaults write com.divisiblebyzero.Spectacle ${key} -data ";
  defaults read com.divisiblebyzero.Spectacle MoveToCenter | sed 's/[^0-9a-f]//g';
done