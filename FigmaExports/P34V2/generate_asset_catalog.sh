#!/bin/zsh
set -euo pipefail

catalog="/Users/memo/Roolio/Roolio/Assets.xcassets"

for directory in "$catalog" "$catalog/P34V2"; do
  cat > "$directory/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
done

for imageset in "$catalog/P34V2"/*.imageset; do
  asset_file=$(find "$imageset" -maxdepth 1 -type f ! -name Contents.json -print -quit)
  filename=$(basename "$asset_file")
  extension="${filename##*.}"
  vector_line=""
  if [[ "$extension" == "svg" ]]; then
    vector_line=',
  "properties" : {
    "preserves-vector-representation" : true
  }'
  fi
  cat > "$imageset/Contents.json" <<JSON
{
  "images" : [
    {
      "filename" : "$filename",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }$vector_line
}
JSON
done
