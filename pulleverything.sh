#!/bin/bash

# make this script executable
# $ chmod +x pulleverything.sh
# call it like this
# $ ./pulleverything.sh

# store the current dir
CUR_DIR=$(pwd)

#hey user
echo "Pulling in latest changes for all repositories..."

# Find all git repositories and update it to the latest revision on current branch
for i in $(find . -name ".git" | cut -c 3-); do
    #ignore li3 submodules
    if [[ "$i" != *libraries* ]]
  then
        #ignore deployment submodules
    if [[ "$i" != *deployment* ]]
    then

      echo "";
          echo $i;

          #We have to go to the .git parent directory to call the pull command
          cd "$i";
          cd ..;
                #preload index - for nfs
                git config core.preloadindex true
          #pull
          git pull;
          #update submodules
          git submodule update;
          #lets get back to the CUR_DIR
          cd $CUR_DIR
      fi
  fi

done

echo "Complete!"
