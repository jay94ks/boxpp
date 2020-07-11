#!/bin/bash

BOX_DIR_PATH="$BOX_DIR/pcre"
BOX_DIR_CHECK="$BOX_DIR_PATH/bin/pcre-config"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"pcre

BOX_SOURCE="$BOX_BUILD/pcre"
BOX_SOURCE_URL="https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz"
BOX_SOURCE_EXT="$BOX_BUILD/pcre-8.42"

export LIB_PCRE="$BOX_DIR_PATH"
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

    ../pcre/configure --enable-utf8 \
        --prefix="$BOX_DIR_PATH" --disable-static

    make -j 16 && make install
    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"