#/bin/bash
for file in *; do
  if [ -f "$file" ]; then
    du -h "$file"
  fi
done
