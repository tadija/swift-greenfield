#!/bin/sh

# get current xcode project name
XCODE_PROJECT=$(find . -maxdepth 1 -name "*.xcodeproj" | head -1)
OLD_PROJECT_NAME=$(basename "${XCODE_PROJECT%.*}")

# get new project name as optional parameter
NEW_PROJECT_NAME="$1"

function renameProject {
    # if not provided, input new project name
    if [ -z $NEW_PROJECT_NAME ]
        then echo "enter new project name:"
        read NEW_PROJECT_NAME
    fi

    # download rename script and make it executable
    URL="https://raw.githubusercontent.com/tadija/xcode-project-renamer/master/Sources/main.swift"
    curl $URL -o rename.swift && chmod +x rename.swift

    # rename project from old name to new name
    rename.swift "$OLD_PROJECT_NAME" "$NEW_PROJECT_NAME"

    # remove rename script
    rm rename.swift
}

function main {
    if [ -z $OLD_PROJECT_NAME ]
        then echo "xcodeproj file not found"
        else renameProject
    fi
}

main
