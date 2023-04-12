#!/bin/sh

PROJECT_NAME="$1"

function bootstrap {
    echo ""
    echo "GreenField bootstrap running 🚧"
    echo ""

    git clone git@github.com:tadija/greenfield.git $PROJECT_NAME

    cd $PROJECT_NAME
    Scripts/rename-xcodeproj.sh $PROJECT_NAME

    rm -rf .git
    git init

    git add .
    git commit -m "Init project: \"$PROJECT_NAME\""

    echo ""
    echo "GreenField bootstrap done ✅"
    echo ""
}

if [ -z $PROJECT_NAME ]
    then echo "missing argument: PROJECT_NAME"
    else bootstrap
fi
