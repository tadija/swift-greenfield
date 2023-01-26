#!/bin/sh

XCODE_PROJECT=$(find . -maxdepth 1 -name "*.xcodeproj" | head -1)

DD_PATH=$(
    xcodebuild \
    -project $XCODE_PROJECT \
    -showBuildSettings \
    | grep -m 1 "CONFIGURATION_BUILD_DIR" \
    | grep -oEi "\/.*" \
    | rev | cut -d '/' -f4- | rev \
)

echo "ℹ️  derived data path: $DD_PATH"

read -p "⚠️  clear derived data? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm -rf "$DD_PATH"
    echo "✅ done!"
fi
