#!/bin/bash
filename=$1
echo "Parsing video file ${filename}..."
file_dir=$(dirname $1)
file_basename=$(basename $1)
file_basename_name=${file_basename%.*}
file_basename_extension=${filename##*.}

# Counting elapsed time
start_time=$SECONDS

# Converting the codec format
if [ "${filename##*.}" != "mp4" ]
then
    echo "Converting input file into mp4 format..."
    ffmpeg -i $filename -codec copy "$file_dir/$file_basename_name.mp4"
    filename="$file_dir/$file_basename_name.mp4"
    file_basename="$file_basename_name.mp4"
    file_basename_extension="mp4"
fi

# Trimming the converted video into 10min segments
duration=$(ffmpeg -i $filename 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,//)
IFS=":"     # : is set as delimiter
read -ra ADDR <<< "$duration"   # str is read into an array as tokens separated by IFS
for i in "${ADDR[@]}"; do   # access each element of array
    echo "$i"
done
hour=${ADDR[0]}
minute=${ADDR[1]}
second=${ADDR[2]%.*}
IFS=" "
second_total=$(($hour*3600+$minute*60+$second))
echo "The video duration is ${hour} hours, ${minute} minutes and ${second} seconds, namely ${second_total} seconds in total"
trimming_elapsed=$(($SECONDS - $start_time))

segments=$(($second_total/600+1))
echo "The video will be trimmed into ${segments} segments."
for ((i=1;i<=segments;i++));
do
    ffmpeg -ss 00:$(($i*10-10)):00 -i $filename -to 00:$(($i*10)):00 -c copy $file_dir/${file_basename%.*}_$i.mp4
    # Run object detection, tracking, and 2D pitch mapping codes
    python main.py --input $file_dir/${file_basename%.*}_$i.mp4 --output ${file_basename%.*}_$i
done
total_elapsed=$(($SECONDS - $start_time))
mean_detection_elapsed=$((($total_elapsed-$trimming_elapsed) / $segments))
eval "echo Total elapsed time: $(date -ud "@$total_elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"
eval "echo Converting and trimming time: $(date -ud "@$trimming_elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"
eval "echo Mean detection, tracking, and mapping time: $(date -ud "@$mean_detection_elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"