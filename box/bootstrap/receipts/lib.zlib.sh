#!/bin/bash

BOX_DIR_PATH="$BOX_DIR/zlib"
BOX_DIR_CHECK="$BOX_DIR_PATH/lib/libz.so"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"zlib

BOX_SOURCE="$BOX_BUILD/zlib"
BOX_SOURCE_URL="https://zlib.net/zlib-1.2.11.tar.gz"
BOX_SOURCE_EXT="$BOX_BUILD/zlib-1.2.11"

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

    ../zlib/configure --prefix="$BOX_DIR_PATH"

    make -j 16 && make install
    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"

export LIB_ZLIB="$BOX_DIR_PATH"

export CFLAGS_ZLIB="-I$BOX_DIR_PATH/include"
export LIBS_ZLIB="-L$BOX_DIR_PATH/lib -lz"