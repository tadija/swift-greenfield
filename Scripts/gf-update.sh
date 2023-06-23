#!/bin/sh

GF_DIR="_GF"

function update {
    echo ""
    echo "swift-greenfield | update running 🚧"
    echo ""

    # clone original repo and prepare for sync
    git clone "https://github.com/tadija/swift-greenfield.git" $GF_DIR
    rm -rf $GF_DIR/.git
    rm -rf $GF_DIR/GreenField.xcodeproj
    rm $GF_DIR/CHANGELOG.md
    rm $GF_DIR/README.md
    echo ""

    # perform sync with the current directory
    rsync -avh $GF_DIR/ .

    # cleanup
    rm -rf $GF_DIR

    echo ""
    echo "swift-greenfield | update done ✅"
    echo ""
}

update
