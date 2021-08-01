#!/usr/bin/env bash

# Copyright 2020-2021 Mike Carlton
#
# Released under terms of the MIT License:
#   http://carlton.mit-license.org/

echo2()
{
    echo "$@" >&2
}

RCFILE="/usr/local/etc/bluekvm.rc"

. "$RCFILE"

if [[ -z "$keyboard" ]] || [[ -z "$display1" ]] ; then
  echo2 "You must define keyboard and display1 (and optionally display2) in $RCFILE"
  exit 1
fi

while true ; do
  connected=$(blueutil --is-connected "$keyboard")
  if [[ "$connected" == 1 ]] ; then
    [[ "$VERBOSE" == 1 ]] && echo2 "waiting on disconnect"
    blueutil --wait-disconnect $keyboard
  else
    [[ "$VERBOSE" == 1 ]] && echo2 "waiting on connect"
    blueutil --wait-connect $keyboard
    if [[ $(uname -m) == "arm64" ]] ; then
        m1ddc display 1 set input $display1
        [[ $display2 ]] && m1ddc display 2 set input $display2
    else
        ddcctl -d 1 -i $display1 >/dev/null
        [[ $display2 ]] && ddcctl -d 2 -i $display2 >/dev/null
    fi
  fi
done
