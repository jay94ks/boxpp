#!/bin/bash
SELF_PATH=`dirname $(realpath $0)`

WORK_DIR="$1"
WORK_USR=`whoami`

RECEIPTS_DIR="$SELF_PATH/receipts"
if [ "$WORK_DIR" == "" ]; then
    echo "specify bootstrap directory: e.g. /my-box"
    while [ "$WORK_DIR" == "" ];
    do
        IFS= read -r TMP

        if [ "$TMP" == "" ]; then
            echo "installation directory can not be empty."
        elif [ "$WORK_DIR" == "" ]; then
            if [ -d "$TMP" ]; then
                echo "$TMP is already exists."
                echo "are you sure to proceed, enter 'yes':"

                IFS= read -r TMP2
            else
                TMP2="yes"
            fi

            if [ "$TMP2" == "yes" ]; then
                export WORK_DIR="$TMP"
            else
                echo "specify installation directory: e.g. /my-box"
            fi
        fi
    done
fi

if [ ! -d "$WORK_DIR" ]; then
    CREATED=`mkdir -pv $WORK_DIR 2>&1 1>/dev/null; echo $?`

    if [ "$CREATED" != "0" ]; then
        echo "can't create directory: $WORK_DIR"
        exit 1
    fi
fi

CURRENT_DIR=`pwd`
cd $WORK_DIR
export WORK_DIR=`pwd`
cd $CURRENT_DIR

echo "Checking writable or not..."

echo "IS WRITTABLE????" > "$WORK_DIR/read-write.test"
if [ ! -f "$WORK_DIR/read-write.test" ]; then
    echo "Impossible to write anything for $WORK_DIR"
    echo "Check your permission for $WORK_DIR"
    exit 1
fi

rm -rf "$WORK_DIR/read-write.test"

echo "----"
echo "WORK_DIR: $WORK_DIR"
echo "WORK_USR: $WORK_USR"
echo "Type 'yes' if correct above."

IFS="" read -r TMP
if [ "$TMP" != "yes" ]; then
    echo "Canceled."
    exit 1
fi

chmod +x "$RECEIPTS_DIR"/*.sh
. $RECEIPTS_DIR/prerequisites.sh

if [ "$MEET_PREREQUISITES" != "0" ]; then
    echo "Prerequisites are unmet. canceled."
    exit 1
fi

export DOWNLOADER="$DOWNLOADER"
export BUILD_PREFIX="build-"
export DOWNLOAD_CACHE="$SELF_PATH/caches"

export USR="$WORK_USR"
export BOX="$WORK_DIR"
export BOX_DIR="$WORK_DIR/box"
export BOX_RUN="$WORK_DIR/run"
export BOX_VAR="$WORK_DIR/var"
export BOX_BUILD="$WORK_DIR/builds"

mkdir -pv "$WORK_DIR"/{box,run,var,builds}

if [ ! -d "$DOWNLOAD_CACHE" ]; then
    mkdir -pv "$DOWNLOAD_CACHE"
fi

if [ "$INSTALL_WHAT" == "" ]; then
    while IFS= read -r RECEIPTS
    do
        if [ "$RECEIPTS" != "" ]; then
            export RECEIPTS=`realpath "$RECEIPTS"`
            export RECEIPTS_DIR=`dirname "$RECEIPTS"`
            cd $BOX_BUILD

            . $RECEIPTS

            if [ "$BOX_ERROR" != "0" ]; then
                echo "Error during executing $RECEIPTS."
                exit 1
            fi

            cd $CURRENT_DIR
        fi

        echo bootstrap: `basename "$RECEIPTS"`: done
    done <<< "$(find "$RECEIPTS_DIR" -type f | grep '\.sh$' | grep 'receipts/box\.')"
elif [ -f "$RECEIPTS_DIR/box.$INSTALL_WHAT.sh" ]; then
    export RECEIPTS="$RECEIPTS_DIR/box.$INSTALL_WHAT.sh"
    export RECEIPTS=`realpath "$RECEIPTS"`
    export RECEIPTS_DIR=`dirname "$RECEIPTS"`

    cd $BOX_BUILD

    . $RECEIPTS

    if [ "$BOX_ERROR" != "0" ]; then
        echo "Error during executing $RECEIPTS."
        exit 1
    fi

    cd $CURRENT_DIR
    echo bootstrap: `basename "$RECEIPTS"`: done.
else
    echo "error: $INSTALL_WHAT: unknown script."
fi