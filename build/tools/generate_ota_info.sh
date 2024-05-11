#!/bin/bash
if [ "$1" ]
then
  file_path=$1
  file_name=$(basename "$file_path")
  if [[ $file_name == *"VANILLA"* ]]; then
  variant="vanilla"
  else
  variant="gapps"
  fi
  DEVICE=$(echo $TARGET_PRODUCT | sed 's/infinity_//g')
  if [ -f $file_path ]; then
    file_size=$(stat -c%s $file_path)
    version=$(echo "$file_name" | cut -d '-' -f 3)
    aversion="14"
    md5=$(md5sum $file_path | awk '{ print $1 }');
    datetime=$(grep ro\.build\.date\.utc ./out/target/product/$DEVICE/system/build.prop | cut -d= -f2);
    download="https://sourceforge.net/projects/infinity-x/files/${DEVICE}/${aversion}/${variant}/${file_name}";
    echo -e "{\n\t\"response\": [\n\t\t{\n\t\t\t\"filename\": \"$file_name\",\n\t\t\t\"download\": \"$download\",\n\t\t\t\"timestamp\": $datetime,\n\t\t\t\"md5\": \"$md5\",\n\t\t\t\"size\": $file_size,\n\t\t\t\"version\": \"$version\"\n\t\t}\n\t]\n}" > $file_path.json
  fi
fi
