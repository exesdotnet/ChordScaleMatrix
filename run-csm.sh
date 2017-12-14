#!/bin/bash

if [ $# -ge 2 ]; then
	echo ""
	echo "Usage: $0 [Options]"
	echo "--app : Run as standalone application"
	echo ""
	exit 1
fi

if [ "$1" = "--app" ]; then
	echo "TODO: Create standalone application starter script"
else
	cd ~

	(/usr/bin/qjackctl &> /dev/null &)

	if [[ -n `pidof scide` ]]; then echo "Hello scide!"; else (scide &> /dev/null &); fi
fi

