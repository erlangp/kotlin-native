#!/usr/bin/env bash

DIR=$(dirname "$0")
PATH=../../dist/bin:../../bin:$PATH
DEPS=$(dirname `type -p konanc`)/../dependencies

CFLAGS_macbook=-I$HOME/Library/Frameworks/SDL2.framework/Headers
LINKER_ARGS_macbook="-F $HOME/Library/Frameworks -framework SDL2"
COMPILER_ARGS_macbook=
# Uncomment this if your path to SDL differs from the one above.
#CFLAGS_macbook=-I/opt/local/include/SDL2
#LINKER_ARGS_macbook="-L/opt/local/lib -lSDL2"
#CFLAGS_macbook=-I/usr/local/include/SDL2
#LINKER_ARGS_macbook="-L/usr/local/lib -lSDL2"

CFLAGS_linux=-I/usr/include/SDL2
LINKER_ARGS_linux="-L/usr/lib/x86_64-linux-gnu -lSDL2"
COMPILER_ARGS_linux=

CFLAGS_iphone=-I$DEPS/target-sysroot-2-darwin-ios/System/Library/Frameworks/SDL2.framework/Headers
LINKER_ARGS_iphone="-framework SDL2 \
-framework AVFoundation -framework CoreGraphics -framework CoreMotion -framework Foundation -framework GameController \
-framework AudioToolbox -framework OpenGLES -framework QuartzCore -framework UIKit"
COMPILER_ARGS_iphone=-nomain

CFLAGS_raspberrypi=-I$DEPS/target-sysroot-1-raspberrypi/usr/include/SDL2
LINKER_ARGS_raspberrypi="-lSDL2"
COMPILER_ARGS_raspberrypi=

if [ x$TARGET == x ]; then
case "$OSTYPE" in
  darwin*)  TARGET=macbook ;;
  linux*)   TARGET=linux ;;
  *)        echo "unknown: $OSTYPE" && exit 1;;
esac
fi

var=CFLAGS_${TARGET}
CFLAGS=${!var}
var=LINKER_ARGS_${TARGET}
LINKER_ARGS=${!var}
var=COMPILER_ARGS_${TARGET}
COMPILER_ARGS=${!var} # add -opt for an optimized build.

rm -rf $DIR/build/
mkdir $DIR/build/
mkdir $DIR/build/c_interop/
mkdir $DIR/build/bin/

cinterop -def $DIR/src/c_interop/sdl.def -copt "$CFLAGS" -target $TARGET -o $DIR/build/c_interop/sdl.kt.bc || exit 1

konanc $COMPILER_ARGS -target $TARGET $DIR/src/kotlin-native/Tetris.kt \
       -library $DIR/build/c_interop/sdl.kt.bc -linkerArgs "$LINKER_ARGS" \
       -o $DIR/build/bin/Tetris.kexe || exit 1

cp -R $DIR/src/resources $DIR/build/bin

echo "Artifact path is ./build/bin/Tetris.kexe"
