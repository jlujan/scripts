#!/bin/sh

if [ $# -lt 1 ]
then
  echo "If the .app and .dSYM are not in the current directory, specify their paths as additional arguments"
  echo "`basename $0` crash_file.crash [path_containing_app] [path_containing_dsym]"
  exit 1
fi

CRASH=$1
TARGET_PATH=$2
DSYM_PATH=$3

APP=`grep "^Process:" ${CRASH} | sed -n -E "s/^Process:[^a-zA-Z0-9]*([a-zA-Z0-9]+).*$/\1/p"`
echo "App Name: \"${APP}\""

if [ -z "$TARGET_PATH" ]
then
  TARGET_PATH=".${TARGET_PATH%/}/${APP}.app/${APP}"
else
  TARGET_PATH="${TARGET_PATH%/}/${APP}.app/${APP}"
fi

echo "App path: ${TARGET_PATH}"

if [ -z "$DSYM_PATH" ]
then
  DSYM_PATH="./${APP}.app.dSYM"
else
  DSYM_PATH="${DSYM_PATH%/}/${APP}.app.dSYM"
fi

echo "dSYM path: ${DSYM_PATH}"

DEVELOPER_DIR=`xcode-select --print-path`
export DEVELOPER_DIR
SYMBOLICATE_PATH=${DEVELOPER_DIR}/Platforms/iPhoneOS.platform/Developer/Library//PrivateFrameworks/DTDeviceKit.framework/Versions/A/Resources/symbolicatecrash

set -e

CRASH_UUID=`grep --after-context=2 "Binary Images:" "${CRASH}" | grep "${APP}" | grep -o "<.*>" | sed -E "s/<(.*)>/\1/"`
echo "Found crash UUID: \"${CRASH_UUID}\""

APP_UUID=`dwarfdump --uuid ${TARGET_PATH} | cut -d ' ' -f 2`
echo "Found app UUID: \"${APP_UUID}\""

DYSYM_UUID=`dwarfdump --uuid ${DSYM_PATH}  | cut -d ' ' -f 2`
echo "Found dsym UUID: \"${DYSYM_UUID}\""

echo "-----------------------------------"
echo "UUID's must match ${CRASH_UUID} ${APP_UUID} ${DYSYM_UUID}"
echo "-----------------------------------"

#mdfind "com_apple_xcode_dsym_uuids = *"
"${SYMBOLICATE_PATH}" "${CRASH}"
