#!/bin/bash

BOX_DIR_PATH="$BOX_DIR/icu4c"
BOX_DIR_CHECK="$BOX_DIR_PATH/bin/icu-config"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"icu4c

BOX_SOURCE="$BOX_BUILD/icu4c"
BOX_SOURCE_URL="http://github.com/unicode-org/icu/releases/download/release-67-1/icu4c-67_1-src.tgz"
BOX_SOURCE_EXT="$BOX_BUILD/icu"

export LIB_ICU4C="$BOX_DIR_PATH"
PREVIOUS_PWD=`pwd`

if [ ! -f "$BOX_DIR_CHECK" ]; then
    if [ ! -d "$BOX_SOURCE" ]; then
        TAR_NAME=$(basename "$BOX_SOURCE_URL")

        if [ ! -f "$TAR_NAME" ]; then
            if [ ! -f "$DOWNLOAD_CACHE/$TAR_NAME" ]; then
                CURRENT_PWD=`pwd`
                cd "$DOWNLOAD_CACHE"

                $DOWNLOADER $BOX_SOURCE_URL

                if [ "$?" != "0" ]; then
                    cd "$PREVIOUS_PWD"
                    export BOX_ERROR="1"
                    exit 1
                fi

                cd "$CURRENT_PWD"
            fi

            cp -v "$DOWNLOAD_CACHE/$TAR_NAME" "$TAR_NAME"
            if [ "$?" != "0" ]; then
                cd "$PREVIOUS_PWD"
                export BOX_ERROR="1"
                exit 1
            fi
        fi

        echo "Extracting $TAR_NAME..."
        tar xf "$TAR_NAME"

        if [ "$?" != "0" ]; then
            cd "$PREVIOUS_PWD"
            export BOX_ERROR="1"
            exit 1
        fi

        mv -v "$BOX_SOURCE_EXT" "$BOX_SOURCE"
    fi

    rm -rf "$BOX_BUILD_PATH"
    mkdir -pv "$BOX_BUILD_PATH"
    cd "$BOX_BUILD_PATH"

    ../icu4c/source/configure --prefix="$BOX_DIR_PATH" --disable-static

    make -j 16 && make install
    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"