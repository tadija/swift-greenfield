#!/bin/sh

CMD="$1"

MREMOTE=".package(url: \"https://github.com/tadija/swift-minions.git\", branch: \"main\")"
MLOCAL=".package(path: \"../Minions\")"

MREMOTED=".product(name: \"Minions\", package: \"swift-minions\")"
MLOCALD="\"Minions\""

# r2l (remote to local) will clone remote Minions and make them a local package.
function r2l {
    git clone https://github.com/tadija/swift-minions.git Packages/Minions
    rm -rf Packages/Minions/.git
    sed -i '' "s|${MREMOTE}|${MLOCAL}|g" Packages/Shared/Package.swift
    sed -i '' "s|${MREMOTED}|${MLOCALD}|g" Packages/Shared/Package.swift
}

# l2r (local to remote) will remove local Minions and make them a remote dependency.
function l2r {
    rm -rf Packages/Minions
    sed -i '' "s|${MLOCAL}|${MREMOTE}|g" Packages/Shared/Package.swift
    sed -i '' "s|${MLOCALD}|${MREMOTED}|g" Packages/Shared/Package.swift
}

function printUsage {
    echo "ℹ️  USAGE:\n- r2l | remote to local \n- l2r | local to remote"
}

function main {
    case $CMD in
    "r2l")
        r2l
        ;;
    "l2r")
        l2r
        ;;
    *)
        printUsage
        ;;
    esac
}

main
