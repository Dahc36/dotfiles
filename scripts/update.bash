#!/usr/bin/env bash

files=$(ls -A src)

for file in $files; do
  echo "Updating $file..."
  cp ~/$file src/$file
done
