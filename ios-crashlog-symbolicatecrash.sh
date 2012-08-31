#!/bin/sh

if [ $# -ne 2 ]
then
  echo "Usage: Copy 'app_name'.app and 'app_name'.app.dSYM into `dirname $0` and run"
  echo "`basename $0` app_name crash_file.crash"
  exit $E_BADARGS
fi

CRASH=$2
APP=$1
DEVELOPER_DIR=`xcode-select --print-path`
export DEVELOPER_DIR
SYMBOLICATE_PATH=${DEVELOPER_DIR}/Platforms/iPhoneOS.platform/Developer/Library//PrivateFrameworks/DTDeviceKit.framework/Versions/A/Resources/symbolicatecrash

set -e

CRASH_UUID=`grep --after-context=2 "Binary Images:" "${CRASH}" | grep "${APP}" | grep -o "<.*>" | sed -E "s/<(.*)>/\1/"`
echo "Found crash UUID: ${CRASH_UUID}"

APP_UUID=`dwarfdump --uuid ${APP}.app.dSYM`
echo "Found app UUID: ${APP_UUID}"

DYSYM_UUID=`dwarfdump --uuid ${APP}.app/${APP}`
echo "Found dsym UUID: ${DYSYM_UUID}"

echo "-----------------------------------"
echo "UUID's must match ${CRASH_UUID} ${APP_UUID} ${DYSYM_UUID}"
echo "-----------------------------------"

mdfind "com_apple_xcode_dsym_uuids == ${UUID}"
"${SYMBOLICATE_PATH}" "${CRASH}"