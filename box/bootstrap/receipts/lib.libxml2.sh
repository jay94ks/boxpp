#!/bin/bash

PREVIOUS_PWD=`pwd`
source $RECEIPTS_DIR/lib.icu4c.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

BOX_DIR_PATH="$BOX_DIR/libxml2"
BOX_DIR_CHECK="$BOX_DIR_PATH/bin/xml2-config"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"libxml2

BOX_SOURCE="$BOX_BUILD/libxml2"
BOX_SOURCE_URL="http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz"
BOX_SOURCE_EXT="$BOX_BUILD/libxml2-2.9.10"

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

    ../libxml2/configure --prefix="$BOX_DIR_PATH" \
            --with-history --with-icu="$LIB_ICU4C" --with-threads \
            --without-python --disable-static

    make -j 16 && make install
    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"

export LIB_LIBXML2="$BOX_DIR_PATH"

export CFLAGS_LIBXML2="-I$BOX_DIR_PATH/include/libxml2"
export LIBS_LIBXML2="-L$BOX_DIR_PATH/lib -lxml2"