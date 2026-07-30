#!/usr/bin/env bash

files=$(ls -A ./src)

for file in $files; do
  read -p "Overwrite ~/$file? (y/N) " prompt
  if [[ $prompt == "y" ]]; then
    cp ./src/$file ~/$file
  fi
done
