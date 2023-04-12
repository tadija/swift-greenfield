#!/bin/sh

FILE="Config/Env/BuildSettings.xcconfig"
CMD="$1"
KEY="$2"
VALUE="$3"

function printUsage {
    echo "ℹ️  USAGE:\n- get \$KEY\n- set \$KEY \$VALUE"
}

function getValueForKey {
    RESULT=$(cat $FILE | grep "$KEY " | cut -d "=" -f2 | xargs)
    if [ -z $RESULT ]
        then echo "⚠️  key not found: $KEY"
        else echo $RESULT
    fi
}

function setValueForKey {
    sed -i '' "s/\($KEY *= *\).*/\1$VALUE/" $FILE
    getValueForKey $KEY
}

function main {
    case $CMD in
    "get")
        if [ -z $KEY ]
            then printUsage
            else getValueForKey $KEY
        fi
        ;;
    "set")
        if [ -z $VALUE ]
            then printUsage
            else setValueForKey $KEY $VALUE
        fi
        ;;
    *)
        printUsage
        ;;
    esac
}

main
