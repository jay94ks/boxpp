#!/bin/bash

BOX_DIR_PATH="$BOX_DIR/bzip2"
BOX_DIR_CHECK="$BOX_DIR_PATH/bin/bzip2"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"bzip2

BOX_SOURCE="$BOX_BUILD/bzip2"
BOX_SOURCE_URL="https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
BOX_SOURCE_EXT="$BOX_BUILD/bzip2-1.0.8"

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
    cp -rv "$BOX_SOURCE" "$BOX_BUILD_PATH"
    cd "$BOX_BUILD_PATH"

    make -f Makefile-libbz2_so
    make install PREFIX="$BOX_DIR_PATH"
    mkdir -pv "$BOX_DIR_PATH"/{bin,include,lib}

    #cp -rv "$BOX_SOURCE/bzdiff" "$BOX_DIR_PATH/bin/bzdiff"
    #cp -rv "$BOX_SOURCE/bzgrep" "$BOX_DIR_PATH/bin/bzgrep"
    #cp -rv "$BOX_SOURCE/bzip2recover" "$BOX_DIR_PATH/bin/bzip2recover"
    #cp -rv "$BOX_SOURCE/bzip2" "$BOX_DIR_PATH/bin/bzip2"

    cp -rv "$BOX_SOURCE"/*.h "$BOX_DIR_PATH/include"
    #cp -rv "$BOX_SOURCE"/*.a "$BOX_DIR_PATH/lib"

    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"

export LIB_BZIP2="$BOX_DIR_PATH"

export CFLAGS_BZIP2="-I$BOX_DIR_PATH/include"
export LIBS_BZIP2="-L$BOX_DIR_PATH/lib -lz"