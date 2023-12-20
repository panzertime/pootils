#!/bin/bash
#
# This file sorts all the files in some directory into some other directory, by:
#     File Type (extension)
#     File Creation Date (month and year)
#     Size Bucket (seven buckets from below 50k to bigger than 10M)

if [ -n "$1" ]; then
        bucket="50k"
        echo "Usage: ./general_file_bucketer.sh INDIR [OUTDIR]"
        exit 1
fi 

prefix="./output/"
if [ -z "$2" ]; then
        prefix=$2
fi

mkdir -p $prefix

find $1 -type "f" -exec echo {} >> $prefix/tmp_filenames \;

while IFS="" read -r p || [ -n "$p" ]
do
        extension=`echo $p | awk -F"." '{print $NF}'`
        date=`stat -c '%w' "$p"`
        month="${date:0:7}"
        size=`stat -c '%s' "$p"`

        bucket="50k"
        if [ $size -gt 10485760 ]; then
                bucket="10M"
        elif [ $size -gt 5242880 ]; then
                bucket="5M"
        elif [ $size -gt 1048576 ]; then
                bucket="1M"
        elif [ $size -gt 524288 ]; then
                bucket="512k"
        elif [ $size -gt 102400 ]; then
                bucket="100k"
        elif [ $size -gt 51200 ]; then
                bucket="50k"
        else
                bucket="Small"
        fi

        destination=$extension"/"$month"/"$bucket"/"
        filename=`uuidgen`"."$extension

        echo "$p:$prefix$destination$filename" >> $prefix/tmp_mapping
  done < $prefix/tmp_filenames

awk -F":" '{print $2}' $prefix/tmp_mapping | awk -F"/" '{print $1"/"$2"/"$3"/"$4"/"$5}' >> $prefix/tmp_directories
sort $prefix/tmp_directories | uniq > $prefix/tmp_newdirs && mv $prefix/tmp_newdirs $prefix/tmp_directories

while IFS="" read -r d || [ -n "$d" ]
do
        mkdir -p $d
done < $prefix/tmp_directories

while IFS="" read -r fn || [ -n "$fn" ]
do
        from=${fn%:*}
        to=${fn#*:}
        mv $from $to
done < $prefix/tmp_mapping


rm -rf $prefix/tmp_mapping $prefix/tmp_filenames $prefix/tmp_directories
