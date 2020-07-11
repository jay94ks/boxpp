#!/bin/bash

CHECK_AXEL=`which axel 2>&1 1>/dev/null; echo $?`
CHECK_WGET=`which wget 2>&1 1>/dev/null; echo $?`
CHECK_CXX=`which g++ 2>&1 1>/dev/null; echo $?`
CHECK_CC=`which gcc 2>&1 1>/dev/null; echo $?`
CHECK_MAKE=`which make 2>&1 1>/dev/null; echo $?`
CHECK_AWK=`which awk 2>&1 1>/dev/null; echo $?`
CHECK_SED=`which sed 2>&1 1>/dev/null; echo $?`
CHECK_GREP=`which grep 2>&1 1>/dev/null; echo $?`
CHECK_FIND=`which find 2>&1 1>/dev/null; echo $?`
CHECK_CMAKE=`which cmake 2>&1 1>/dev/null; echo $?`
CHECK_PKGCFG=`which pkg-config 2>&1 1>/dev/null; echo $?`
CHECK_BISON=`which bison 2>&1 1>/dev/null; echo $?`
CHECK_AUTOCONF=`which autoconf 2>&1 1>/dev/null; echo $?`

export MEET_PREREQUISITES="1"
if [ "$CHECK_AXEL" == "0" ]; then
    export DOWNLOADER="axel -n 10"
elif [ "$CHECK_WGET" == "0" ]; then
    export DOWNLOADER="wget"
else
    echo "error: no downloader found: requires wget or axel." >&2
    exit 1;
fi

if [ "$CHECK_CXX" != "0" ]; then
    echo "error: no g++ compiler found: requires build-essential package." >&2
    exit 1;
fi

if [ "$CHECK_CC" != "0" ]; then
    echo "error: no gcc compiler found: requires build-essential package." >&2
    exit 1;
fi

if [ "$CHECK_MAKE" != "0" ]; then
    echo "error: no make util found: requires make package." >&2
    exit 1;
fi

if [ "$CHECK_CMAKE" != "0" ]; then
    echo "error: no cmake util found: requires cmake package." >&2
    exit 1;
fi

if [ "$CHECK_AWK" != "0" ]; then
    echo "error: no awk util found: requires awk package." >&2
    exit 1;
fi

if [ "$CHECK_SED" != "0" ]; then
    echo "error: no sed util found: requires sed package." >&2
    exit 1;
fi

if [ "$CHECK_GREP" != "0" ]; then
    echo "error: no grep util found: requires grep package." >&2
    exit 1;
fi

if [ "$CHECK_FIND" != "0" ]; then
    echo "error: no find util found: requires find package." >&2
    exit 1;
fi

if [ "$CHECK_PKGCFG" != "0" ]; then
    echo "error: no pkg-config found: requires pkg-config package." >&2
    exit 1;
fi

if [ "$CHECK_AUTOCONF" != "0" ]; then
    echo "error: no autoconf found: requires autoconf package." >&2
    exit 1;
fi

CHECK_NCURSES=`pkg-config ncurses 2>&1 1>/dev/null; echo $?`
CHECK_LIBPYTHON=`pkg-config python 2>&1 1>/dev/null; echo $?`

if [ "$CHECK_BISON" != "0" ]; then
    echo "error: no bison found: requires bison package." >&2
    exit 1;
fi

if [ "$CHECK_NCURSES" != "0" ]; then
    echo "error: no ncurses found: requires libncurses5-dev package." >&2
    exit 1;
fi

if [ "$CHECK_LIBPYTHON" != "0" ]; then
    echo "error: no libpython found: requires libpython-dev package." >&2
    exit 1;
fi

export MEET_PREREQUISITES="0"