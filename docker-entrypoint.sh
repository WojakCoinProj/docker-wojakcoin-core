#!/bin/bash
set -e

# If the first argument looks like a flag, assume it is for wojakcoind.
if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  echo "$0: assuming arguments for wojakcoind"
  set -- wojakcoind "$@"
fi

# For wojakcoind, make sure the data directory exists and is used explicitly.
if [ "$1" = "wojakcoind" ] || [ "$(echo "$1" | cut -c1)" = "-" ]; then
  mkdir -p "$WOJAKCOIN_DATA"
  echo "$0: setting data directory to $WOJAKCOIN_DATA"
  set -- "$@" -datadir="$WOJAKCOIN_DATA"
fi

if [ "$1" = "wojakcoind" ] || [ "$1" = "wojakcoin-cli" ] || [ "$1" = "wojakcoin-tx" ]; then
  echo
  exec "$@"
fi

echo
exec "$@"
