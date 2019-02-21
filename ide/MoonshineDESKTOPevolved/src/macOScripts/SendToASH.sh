#!/bin/bash
# checks if bundle-id exists
if ! [ -x "$(mdfind 'net.prominic.MoonshineAppStoreHelper')" ]; then
  open -b "net.prominic.MoonshineAppStoreHelper"
  exit 1
else
  open http://moonshine-ide.com/moonshine-app-store-helper-utility/
fi