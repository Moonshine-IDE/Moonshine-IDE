#!/bin/bash
# checks if bundle-id exists
HELPER_PATH=$(mdfind kMDItemCFBundleIdentifier = 'net.prominic.MoonshineAppStoreHelper' | head -n 1) 
#echo "Helper path:  '$HELPER_PATH'"

if [ -x "${HELPER_PATH}" ]; then
  open -b "net.prominic.MoonshineAppStoreHelper"
  exit 1
else
  open https://moonshine-ide.com/moonshine-app-store-helper-2/
fi