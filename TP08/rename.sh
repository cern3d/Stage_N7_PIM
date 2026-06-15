#!/bin/bash

# Loop through all files that have at least two dots
for file in *.*.*; do
    # Check if the file actually exists
    [ -e "$file" ] || continue

    # Ensure it matches the pattern: name.number.extension
    # [0-9]+ matches one or more digits in the middle section
    if [[ "$file" =~ ^([^.]+)\.([0-9]+)\.(.+)$ ]]; then
        
        # Construct the new name using the captured groups
        # BASH_REMATCH[1] is the name, [2] is the number, [3] is the extension
        new_name="${BASH_REMATCH[1]}_${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
        
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed: $file -> $new_name"
    fi
done