#!/usr/bin/env bash
killall -q polybar
polybar top | tee -a /tmp/polybar1.log & disown