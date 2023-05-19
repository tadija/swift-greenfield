#!/bin/sh

PROJECT_NAME="$1"

function bootstrap {
    echo ""
    echo "swift-greenfield | bootstrap running 🚧"
    echo ""

    git clone https://github.com/tadija/swift-greenfield.git $PROJECT_NAME
    cd $PROJECT_NAME

    Scripts/rename-xcodeproj.sh $PROJECT_NAME

    echo "# $PROJECT_NAME" > README.md
    echo "# Release Notes" > CHANGELOG.md

    rm -rf .git
    git init
    git add .
    git commit -m "Init project: \"$PROJECT_NAME\""

    echo ""
    echo "swift-greenfield | bootstrap done ✅"
    echo ""

    echo "opening $PROJECT_NAME in Xcode..."
    xed .
}

if [ -z $PROJECT_NAME ]
    then echo "missing argument: PROJECT_NAME"
    else bootstrap
fi
