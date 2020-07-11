#!/bin/bash

BOX_DIR_PATH="$BOX_DIR/sqlite3"
BOX_DIR_CHECK="$BOX_DIR_PATH/bin/sqlite3"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"sqlite3

BOX_SOURCE="$BOX_BUILD/sqlite3"
BOX_SOURCE_URL="https://www.sqlite.org/2020/sqlite-autoconf-3320300.tar.gz"
BOX_SOURCE_EXT="$BOX_BUILD/sqlite-autoconf-3320300"

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

    ../sqlite3/configure --prefix="$BOX_DIR_PATH" --disable-static

    make -j 16 && make install
    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"
export LIB_SQLITE3="$BOX_DIR_PATH"

export CFLAGS_SQLITE3="-I$BOX_DIR_PATH/include"
export LIBS_SQLITE3="-L$BOX_DIR_PATH/lib -lsqlite3"