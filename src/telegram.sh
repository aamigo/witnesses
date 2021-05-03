#!/bin/bash

# Do some prep work
command -v /usr/local/bin/telegram-send >/dev/null 2>&1 || {
  echo >&2 "We require telegram-send for this script to run, but it's not installed.  Aborting."
  exit 1
}
command -v curl >/dev/null 2>&1 || {
  echo >&2 "We require curl for this script to run, but it's not installed.  Aborting."
  exit 1
}

# global config options
DRYRUN=0
BOT_CONF=''
MESSAGE_URL=''
FORMAT='markdown'

# check if we have options
while :; do
  case $1 in
  --dry)
    DRYRUN=1
    ;;
  --format) # Takes an option argument; ensure it has been specified.
    if [ "$2" ]; then
      FORMAT=$2
      shift
    else
      echo 'ERROR: "--format" requires a non-empty option argument.'
      exit 1
    fi
    ;;
  --format=?*)
    FORMAT=${1#*=} # Delete everything up to "=" and assign the remainder.
    ;;
  --format=) # Handle the case of an empty --format=
    echo 'ERROR: "--format" requires a non-empty option argument.'
    exit 1
    ;;
  --message-url) # Takes an option argument; ensure it has been specified.
    if [ "$2" ]; then
      MESSAGE_URL=$2
      shift
    else
      echo 'ERROR: "--message-url" requires a non-empty option argument.'
      exit 1
    fi
    ;;
  --message-url=?*)
    MESSAGE_URL=${1#*=} # Delete everything up to "=" and assign the remainder.
    ;;
  --message-url=) # Handle the case of an empty --message-url=
    echo 'ERROR: "--message-url" requires a non-empty option argument.'
    exit 1
    ;;
  --bot-conf) # Takes an option argument; ensure it has been specified.
    if [ "$2" ]; then
      BOT_CONF=$2
      shift
    else
      echo 'ERROR: "--bot" requires a non-empty option argument.'
      exit 1
    fi
    ;;
  --bot-conf=?*)
    BOT_CONF=${1#*=} # Delete everything up to "=" and assign the remainder.
    ;;
  --bot-conf=) # Handle the case of an empty --bot=
    echo 'ERROR: "--bot" requires a non-empty option argument.'
    exit 1
    ;;
  *) # Default case: No more options, so break out of the loop.
    break ;;
  esac
  shift
done

# We must have the bot config details
if [ -z "${BOT_CONF}" ]; then
  echo >&2 "The BOT config is not set. Aborting."
  exit 1
fi

# We must have the message URL
if [ -z "${MESSAGE_URL}" ]; then
  echo >&2 "The message URL is not set. Aborting."
  exit 1
fi

# place the bot config on drive
echo "${BOT_CONF}" >bot.conf

# Get the message
MESSAGE=$(curl -s "${MESSAGE_URL}")

# check test behaviour
if (("$DRYRUN" == 1)); then
  echo "Message:\n${MESSAGE}"
  echo "Format: ${FORMAT}"
else
  /usr/local/bin/telegram-send "${MESSAGE}" --config bot.conf  --format "$FORMAT" --disable-web-page-preview
fi

exit 0
