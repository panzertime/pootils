#!/binbash
#
# This breaks files in a directory out into new subdirectories based on size

if [ -n "$1" ]; then
        echo "Usage: ./size_breakdown.sh INDIR [OUTDIR] [bucket count] [bucket size]"
        exit 1
fi 

out_dir="output"
if [ -z "$2" ]; then
        out_dir=$2
fi

count=50
if [ -z "$3" ]; then
        count=$3
fi

bucket_size=1024
if [ -z "$4" ]; then
        bucket_size=$4
fi

for i in {1..$count}; 
do 
        name=$out_dir'/'$i'k'
        mkdir -p $name
done

for i in {1..$count};
do
        max_size=$(( 1024*i + 1))
        to_dir=$out_dir'/'$i'k'
        for f in $1/*;
        do
                size=`stat -c %s $f`
                if [ $size -lt $max_size ]; then
                        mv $f $to_dir/
                fi
        done
done
