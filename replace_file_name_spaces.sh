#!/bin/bash

count=0
for file in *; do
  if [[ -d "$file" ]]; then
    continue # skip directories
  fi
  mv -- "$file" "${file// /-}"
done

echo "Processed $count files. Space replacement complete."

# Run this command in target directory prior to running script:
# chmod +x replace_file_name_spaces.sh
