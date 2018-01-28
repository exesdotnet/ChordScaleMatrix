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

elif [ "$1" = "--crash" ]; then
	killall scsynth
	killall scide
	killall sclang
	killall jackd
	killall qjackctl

else
	cd ~

	if [ "`which qjackctl`" = "" ]; then
		echo "qjackctl is not installed."
		echo "You can install JACK Adudio Connection Kit Control by running 'sudo apt install qjackctl'."
	else
		(/usr/bin/qjackctl &> /dev/null &)
	fi

	if [[ -n `pidof scide` ]]; then echo "Hello SuperCollider IDE!"; else (scide &> /dev/null &); fi
fi

