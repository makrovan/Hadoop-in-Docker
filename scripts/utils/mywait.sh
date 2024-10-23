#!/bin/bash
# set -x

sleep 10

if [ $# -gt 0 ]; then
	for param in "$@"; do
		if [[ $param =~ ^[0-9]*$ ]]; then
			pid0=$param
		else
			pid0="$(pidof $param)"
		fi
		if (ps $pid0 >> /dev/null); then 
			if [ -z "$pid" ]; then
				pid="${pid0}"
			else
				pid="${pid} ${pid0}"
			fi
		fi
	done
else
	pid="$(pidof java)"
fi

# Exit if pid variable is unset or set to the empty string
[ -z "$pid" ] && exit

echo "waiting for process $pid...."
myloop=true;
while $myloop; do
	for i in $pid; do
		if (ps $i >> /dev/null); then
			sleep 10
		else
			myloop=false
			echo "Process $i finished"
			#kill $(pidof -s java)
			break
		fi
	done
done
