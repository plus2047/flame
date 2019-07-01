#!/bin/bash

usage='usage: analyse.sh java_pid record_count sample_period [output.svg]'
[ $# -lt 3 ] && echo $usage && exit 1

PROFILED_PID=$1
RECORD_COUNT=$2
SAMPLE_PERIOD=$3

TS=$(date +"%y%m%d_%H%M%S")
[ $# -ge 4 ] && OUTPUT=$4 || OUTPUT=${TS}.svg
echo "output filename: $OUTPUT"

T_STACK="_temp_stack.txt"
T_COLLAPSED="_temp_collapsed.txt"
T_PALETTE="_temp_palette.map"
FLAME=./FlameGraph

echo "Getting stacktraces from process $PROFILED_PID..."
rm -f $T_STACK
echo "begin sampling at $(date)."
for (( i=0; i<$RECORD_COUNT; i++ )); do
    jstack "$PROFILED_PID" >> $T_STACK && sleep $SAMPLE_PERIOD
done
echo "end   sampling at $(date)."

$FLAME/stackcollapse-jstack.pl $T_STACK > $T_COLLAPSED

# 1st run - hot: default
$FLAME/flamegraph.pl --cp $T_COLLAPSED > $OUTPUT

# 2nd run - blue: I/O
cp palette.map $T_PALETTE
cat $T_PALETTE |\
    grep -v '\.read' |\
    grep -v '\.write' |\
    grep -v 'socketRead' |\
    grep -v 'socketWrite' |\
    grep -v 'socketAccept' > palette.map
$FLAME/flamegraph.pl --cp --colors=io $T_COLLAPSED > $OUTPUT

mv palette.map $T_PALETTE

echo "done"
