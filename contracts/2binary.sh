#!/usr/bin/bash

FILE=$1
# file
OUT_FILE="$FILE.tact"
#remove out file if exists
if [ -f "$OUT_FILE" ]; then
    rm $OUT_FILE
fi

# export only name without extension
OUT_NAME=$(basename $FILE | cut -d. -f1)
data=$(xxd -u -p -c 1000000 < $FILE | sed 's/../\\x&/g')
echo "const $OUT_NAME: String = \"$data\";" >> $OUT_FILE

echo "Successfully binary $FILE to \"$OUT_FILE\"";

