#!/bin/bash

source $RECEIPTS_DIR/lib.openssl.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

BOX_DIR_PATH="$BOX_DIR/curl"
BOX_DIR_CHECK="$BOX_DIR_PATH/bin/curl"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"curl

BOX_SOURCE="$BOX_BUILD/curl"
BOX_SOURCE_URL="https://curl.haxx.se/download/curl-7.71.1.tar.xz"
BOX_SOURCE_EXT="$BOX_BUILD/curl-7.71.1"

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

    ../curl/configure --prefix="$BOX_DIR_PATH" \
        --with-ssl="$LIB_OPENSSL" --with-ca-path="$BOX_VAR/openssl/certs" \
        --disable-static

    make -j 16 && make install
    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"

export LIB_CURL="$BOX_DIR_PATH"
export CFLAGS_CURL="-I$BOX_DIR_PATH/include"
export LIBS_CURL="-L$BOX_DIR_PATH/lib -lcurl"