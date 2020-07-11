#!/bin/bash

source $RECEIPTS_DIR/lib.openssl.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.libxml2.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.sqlite3.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.bzip2.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.zlib.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.curl.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.gmp.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.pcre.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/lib.readline.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

source $RECEIPTS_DIR/mod.xclie.sh
if [ "$BOX_ERROR" != "0" ]; then
    cd "$PREVIOUS_PWD"
    export BOX_ERROR="1"
    exit 1
fi

BOX_DIR_PATH="$BOX_DIR/php"
BOX_DIR_CHECK="$BOX_DIR_PATH/bin/php"
BOX_BUILD_PATH="$BOX_BUILD/$BUILD_PREFIX"php

BOX_SOURCE="$BOX_BUILD/php"
BOX_SOURCE_URL="http://www.php.net/distributions/php-7.4.7.tar.xz"
BOX_SOURCE_EXT="$BOX_BUILD/php-7.4.7"

export LIB_PHP="$BOX_DIR_PATH"
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

    PHP_OPT_APXS=""

    if [ -d "$BOX_DIR/httpd" ]; then
        PHP_OPT_APXS="--with-apxs2=$BOX_DIR/httpd/bin/apxs"
    fi

    if [ ! -d "$BOX_SOURCE/sapi/xclie" ]; then
        cp -rvf "$MOD_PHP_XCLIE" "$BOX_SOURCE/sapi/xclie"
    fi

    sed -i "s/direct\.h/dirent\.h/g" "$BOX_SOURCE/sapi/xclie/php_xclie.c"
    sed -i "s/MAX_PATH/4096/g" "$BOX_SOURCE/sapi/xclie/php_xclie.c"

    cd "$BOX_SOURCE"

    ./buildconf -f

    cd "$BOX_BUILD_PATH"
    ../php/configure \
            OPENSSL_CFLAGS="$CFLAGS_OPENSSL" OPENSSL_LIBS="$LIBS_OPENSSL" \
            LIBXML_CFLAGS="$CFLAGS_LIBXML2" LIBXML_LIBS="$LIBS_LIBXML2" \
            SQLITE_CFLAGS="$CFLAGS_SQLITE3" SQLITE_LIBS="$LIBS_SQLITE3" \
            ZLIB_CFLAGS="$CFLAGS_ZLIB" ZLIB_LIBS="$LIBS_ZLIB" \
            CURL_CFLAGS="$CFLAGS_CURL" CURL_LIBS="$LIBS_CURL" \
            --prefix="$BOX_DIR_PATH" $PHP_OPT_APXS \
            --with-iconv --with-openssl-dir="$LIB_OPENSSL" \
            --with-openssl --with-libxml="$LIB_LIBXML2" \
            --with-gmp="$LIB_GMP" --with-zlib --with-pdo-mysql \
            --without-pdo-sqlite --with-readline="$LIB_READLINE" \
            --with-gettext --with-bz2="$LIB_BZIP2" \
            --with-curl --with-pcre="$LIB_PCRE" \
            --with-mysqli --with-pdo-mysqli \
            --with-config-file-path="$BOX_VAR" \
            --disable-cgi --disable-fastcgi \
            --enable-xclie=shared \
            --enable-cli \
            --disable-static --enable-shared
    
    make -j 16 && make install
    if [ "$?" != "0" ]; then
        cd "$PREVIOUS_PWD"
        export BOX_ERROR="1"
        echo $PHP_OPT_APXS
        exit 1
    fi
fi

cd "$PREVIOUS_PWD"
export BOX_ERROR="0"