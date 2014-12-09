#!/bin/sh

# Usage: ./profile.sh pid output.txt

PROFILED_PID=$1
OUTPUT_FILE=$2

echo "Getting stacktraces from process $PROFILED_PID... Will stop on ^C or when the process exits."

rm -f "$OUTPUT_FILE"

while true; do
    jstack "$PROFILED_PID" >> "$OUTPUT_FILE" && sleep 0.01 || break
done

echo
echo "Done! Stacks saved to $OUTPUT_FILE"
