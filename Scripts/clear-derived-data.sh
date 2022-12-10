#!/bin/sh

DD_PATH=$(
    xcodebuild \
    -project Greenfield.xcodeproj \
    -showBuildSettings \
    | grep -m 1 "CONFIGURATION_BUILD_DIR" \
    | grep -oEi "\/.*" \
    | rev | cut -d'/' -f4- | rev
)

rm -rf "$DD_PATH"
