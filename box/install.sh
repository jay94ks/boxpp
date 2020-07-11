#!/bin/bash
THIS_DIR=`pwd`
INST_DIR="/box"
WHOAMI=`whoami`

INSTALLING_VERSION="1"

if [ "$WHOAMI" == "root" ]; then
    echo "DO NOT TRY TO INSTALL USING ROOT!"
    exit 1
fi

if [ "$1" != "" ]; then
    INST_DIR="$1"
fi

mkdir -pv "$INST_DIR"

if [ ! -d "$INST_DIR" ]; then
    echo "$INST_DIR isn't exists."
    echo "To change, enter target directory like below."
    echo "./install.sh /path/to/install"
    exit 1
fi

PHP_FOUND=`which php 2>&1 1>/dev/null; echo $?`

if [ "$PHP_FOUND" == "0" ]; then
	PHP_VER_CHECK=`php -r "echo version_compare(phpversion(), '7.2', '<') ? 1 : 0;"`
	
	if [ "$PHP_VER_CHECK" == "0" ]; then
		echo "Will you use system's PHP installation for box++? (yes/no)"
		echo "Causion: You may modify the system's PHP CLI configurations and It will affect box's working.";
		
		IFS= read -r ANS
	else
		echo "System's PHP isn't compatible with box++ required."
		echo "Box++ will compile PHP from source code."
		echo "Press enter to continue. (Ctrl + C for cancel)"
		IFS= read -r
		ANS="N"
	fi
else
	echo "No PHP distro found."
	echo "Box++ will compile PHP from source code."
	echo "Press enter to continue. (Ctrl + C for cancel)"
	IFS= read -r
	ANS="N"
fi

if [ "$ANS" == "yes" ] || [ "$ANS" == "y" ]; then
	# Bootstrap runtimes.
	if [ ! -d "$INST_DIR/base" ]; then
		chmod +x "$THIS_DIR/bootstrap/bootstrap.sh"
		"$THIS_DIR/bootstrap/bootstrap.sh" "$INST_DIR/base"
	fi

	if [ ! -f "$INST_DIR/base/box/php/bin/php" ]; then
		echo "No php built."
		exit 1
	fi
	rm -rf "$INST_DIR/boxpp"

	if [ ! -f "$INST_DIR/boxpp" ]; then
		g++ "$THIS_DIR/bootstrap/boxpp.cpp" \
			-I"$INST_DIR/base/box/php/include/php" \
			-L"$INST_DIR/base/box/php/lib" -lphp7 \
			-o "$INST_DIR/boxpp" -Wl,-rpath="$INST_DIR/base/box/php/lib"
	fi
fi

cd "$THIS_DIR"

INSTALLED_VERSION="0"
if [ -f "$INST_DIR/.box.version" ]; then
    INSTALLED_VERSION=`cat "$INST_DIR/.box.version"`
fi

echo "$INSTALLING_VERSION" > "$INST_DIR/.box.version"


rm -rf "$INST_DIR/core"
cp -rv "$THIS_DIR/core" "$INST_DIR/core"

echo "#!/bin/bash" > "$INST_DIR/core/.env"
echo "DB_CONNECTION=sqlite" >> "$INST_DIR/core/.env"
echo "DB_DATABASE=$INST_DIR/datas/boxpp.sqlite" >> "$INST_DIR/core/.env"
source "$INST_DIR/core/.env"

# Create only if not exists.
if [ ! -f "$DB_DATABASE" ]; then
    DB_DIRECTORY=`dirname "$DB_DATABASE"`
    mkdir -pv "$DB_DIRECTORY"
    touch $DB_DATABASE
fi

if [ ! -f "$INST_DIR/core/.box-env.php" ]; then
    touch "$INST_DIR/core/.box-env.php"
fi

echo "install: done."