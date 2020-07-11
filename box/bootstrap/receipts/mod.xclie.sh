#!/bin/bash

BOX_DIR_PATH="$BOX_DIR/php"
BOX_DIR_CHECK="$BOX_DIR/php/include/sapi/xclie/php_xclie.h"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"xclie

BOX_SOURCE="$BOX_BUILD/php-xclie"
BOX_SOURCE_URL="https://github.com/jay94ks/php-xclie/archive/v0.1.1.tar.gz"
BOX_SOURCE_EXT="$BOX_BUILD/php-xclie-0.1.1"

export MOD_PHP_XCLIE="$BOX_SOURCE/xclie"
PREVIOUS_PWD=`pwd`

if [ ! -f "$BOX_DIR_CHECK" ]; then
    if [ ! -d "$BOX_SOURCE" ]; then
        #TAR_NAME=$(basename "$BOX_SOURCE_URL")
        TAR_NAME="php-xclie-0.1.1.tar.gz"

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
        tar xzf "$TAR_NAME"

        if [ "$?" != "0" ]; then
            cd "$PREVIOUS_PWD"
            export BOX_ERROR="1"
            exit 1
        fi

        mv -v "$BOX_SOURCE_EXT" "$BOX_SOURCE"
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"
