[ $# -lt 2 ] && echo 'usage: pjava-analyse.sh sample_frequence record_period [output.svg]' && exit

sample_frequency=$1
record_period=$2

timestamp=$(date +"%y%m%d_%H%M%S")
[ $# -ge 3 ] && output=$3 || output=${timestamp}.svg
echo "output filename: $output"

script_home=$(dirname $(readlink -f "$0"))
source $script_home/pjava-setting.sh

sudo perf record -F $sample_frequency -a -g -- sleep $record_period
sudo $SCRIPT_PATH/jmaps.sh
sudo perf script | stackcollapse-perf.pl | flamegraph.pl --color=java --hash > $output
