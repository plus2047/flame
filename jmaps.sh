#!/bin/bash
#
# jmaps - creates java /tmp/perf-PID.map symbol maps for all java processes.
#
# This is a helper script that finds all running "java" processes, then executes
# perf-map-agent on them all, creating symbol map files in /tmp. These map files
# are read by perf_events (aka "perf") when doing system profiles (specifically,
# the "report" and "script" subcommands).
#
# USAGE: jmaps [-u]
#		-u	# unfoldall: include inlined symbols
#
# My typical workflow is this:
#
# perf record -F 99 -a -g -- sleep 30; jmaps
# perf script > out.stacks
# ./stackcollapse-perf.pl out.stacks | ./flamegraph.pl --color=java --hash > out.stacks.svg
#
# The stackcollapse-perf.pl and flamegraph.pl programs come from:
# https://github.com/brendangregg/FlameGraph
#
# REQUIREMENTS:
# Tune two environment settings below.
#
# 13-Feb-2015	Brendan Gregg	Created this.
# 20-Feb-2017      "      "     Added -u for unfoldall.

SCRIPT_PATH=$(dirname $(readlink -f "$0"))
source $SCRIPT_PATH/pjava-setting.sh

AGENT_HOME=$SCRIPT_PATH/perf-map-agent
debug=0

if [[ "$USER" != root ]]; then
	echo "ERROR: not root user? exiting..."
	exit
fi

if [[ ! -x $JAVA_HOME ]]; then
	echo "ERROR: JAVA_HOME not set correctly; edit $0 and fix"
	exit
fi

if [[ ! -x $AGENT_HOME ]]; then
	echo "ERROR: AGENT_HOME not set correctly; edit $0 and fix"
	exit
fi

if [[ "$1" == "-u" ]]; then
	opts=unfoldall
fi

# figure out where the agent files are:
AGENT_OUT=""
AGENT_JAR=""
if [[ -e $AGENT_HOME/out/attach-main.jar ]]; then
	AGENT_JAR=$AGENT_HOME/out/attach-main.jar
elif [[ -e $AGENT_HOME/attach-main.jar ]]; then
	AGENT_JAR=$AGENT_HOME/attach-main.jar
fi
if [[ -e $AGENT_HOME/out/libperfmap.so ]]; then
	AGENT_OUT=$AGENT_HOME/out
elif [[ -e $AGENT_HOME/libperfmap.so ]]; then
	AGENT_OUT=$AGENT_HOME
fi
if [[ "$AGENT_OUT" == "" || "$AGENT_JAR" == "" ]]; then
	echo "ERROR: Missing perf-map-agent files in $AGENT_HOME. Check installation."
	exit
fi

# Fetch map for all "java" processes
echo "Fetching maps for all java processes..."
for pid in $(pgrep -x java); do
	mapfile=/tmp/perf-$pid.map
	[[ -e $mapfile ]] && rm $mapfile

	cmd="cd $AGENT_OUT; $JAVA_HOME/bin/java -Xms32m -Xmx128m -cp $AGENT_JAR:$JAVA_HOME/lib/tools.jar net.virtualvoid.perf.AttachOnce $pid $opts"
	(( debug )) && echo $cmd

	user=$(ps ho user -p $pid)
	if [[ "$user" != root ]]; then
		# make $user the username if it is a UID:
		if [[ "$user" == [0-9]* ]]; then user=$(awk -F: '$3 == '$user' { print $1 }' /etc/passwd); fi
		cmd="sudo -u $user sh -c '$cmd'"
	fi

	echo "Mapping PID $pid (user $user):"
	if (( debug )); then
		time eval $cmd
	else
		eval $cmd
	fi
	if [[ -e "$mapfile" ]]; then
		chown root $mapfile
		chmod 666 $mapfile
	else
		echo "ERROR: $mapfile not created."
	fi

	echo "wc(1): $(wc $mapfile)"
	echo
done
