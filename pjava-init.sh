#! /bin/bash
# require command: perf
# apt install linux-tools-common cmake
# for aws: apt install linux-tools-aws
# apt update && apt upgrade && reboot

source pjava-setting.sh

echo 'this script must run in its dir.'
echo 'source this file to rewrite "java" command!'

# build perf-map-agent
cd perf-map-agent && cmake . && make && cd ..
cp perf-map-agent/out/*.jar perf-map-agent/out/*.so ./

cmd="alias java=$JAVA_HOME/bin/java -XX:+PreserveFramePointer"
echo $cmd && $cmd
