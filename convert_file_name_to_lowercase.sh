#!/bin/bash

count=0
for file in *; do
  if [[ -d "$file" ]]; then
    continue # skip directories
  fi

  lowercase=$(echo "$file" | tr '[:upper:]' '[:lower:]')
  if [ "$file" != "$lowercase" ]; then
    mv -- "$file" "$lowercase" && count=$((count + 1))
  fi
done

echo "Processed $count files. Conversion complete."

# Run this command in target directory prior to running script:
# chmod +x convert_file_name_to_lowercase.sh

## version for bash > 4.0
##!/bin/bash
#
#count=0
#for file in *; do
#  if [[ -d "$file" ]]; then
#    continue
#  fi
#  mv -- "$file" "${file,,}" 2>/dev/null && count=$((count + 1))
#done
#
#echo "Processed $count files. Conversion complete."
