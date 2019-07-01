# setting this before run all of those perf-java-* script!

# path to your jdk8+
export JAVA_HOME=/usr/lib/jvm/default-java

export SCRIPT_HOME=$(dirname $(readlink -f "$0"))

export PATH=$PATH:$SCRIPT_HOME:$SCRIPT_HOME/FlameGraph
