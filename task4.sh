#!/bin/sh

if [[ -n $1 ]]; then
	cd $1
fi

git fetch origin

if [[ -n $(git diff origin/master) ]]; then
	git merge origin/master
	# re-deploy flask
	instance=$(ps aux | grep "/usr/bin/python3 $(pwd)" | head -1 | awk '{print $NF}')
	pid=$(ps aux | grep "/usr/bin/python3 $instance" | head -1 | awk '{print $2}')
	kill -9 $pid
	/usr/bin/python3 $instance
fi
