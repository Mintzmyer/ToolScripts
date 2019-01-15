#!/bin/bash
#
# A way to streamline fastboot when flashing images to an
# embedded linux/Android device. Mostly obsolete, but useful
# at the time. Should either be updated or removed. 
#

defaultDir=~/
altDir1=~/
altDir2=~/
altDir3=~/
buildDir=$defaultDir
flash=1
make=1

# Prints the help message for the shell script
sendHelp(){
    echo "Fast Fastboot: "
    echo "Usage: ff.sh [1..3] [OPTION2]"
    echo "Make and flash images from default build directory"
    echo "    [1..3]          Build from an alternative build directory"
    echo "    -m, onlymake    Skip flashing boot/sys image, only clean+make"
    echo "    -f, onlyflash   Skip clean+make, just flash existing images"
    echo "    -h, help        Display this help message"
    exit 0
}

if [ "$#" -ge 1 ]; then
    arg1=$1
    arg2=$2
    if [ "$arg1" = "-h" ] || [ "$arg1" = "help" ] || [ "$arg2" = "-h" ] || [ "$arg2" = "help" ]; then
        sendHelp
    fi
    if [ "$arg1" = "-m" ] || [ "$arg1" = "onlymake" ] || [ "$arg2" = "-m" ] || [ "$arg2" = "onlymake" ]; then
        flash=0
    fi
    if [ "$arg1" = "-f" ] || [ "$arg1" = "onlyflash" ] || [ "$arg2" = "-f" ] || [ "$arg2" = "onlyflash" ]; then
        make=0
    elif [ $arg1 -eq 1 ] || [ $arg2 -eq 1 ]; then
        buildDir=$altDir1
    elif [ $arg1 -eq 2 ] || [ $arg2 -eq 2 ]; then
        buildDir=$altDir2
    elif [ $arg1 -eq 3 ] || [ $arg2 -eq 3 ]; then
        buildDir=$altDir3
    fi
fi

sudo date

    # Build fresh boot and system images #
echo "Using build at $buildDir"
if [ $make -eq 1 ]; then
    build=$(make -C $buildDir installclean | grep "TARGET_PRODUCT=" | cut -d"=" -f 2)
    make -C $buildDir -j7 || exit 1
else
    build=$(make -C $buildDir --question | grep "TARGET_PRODUCT=" | cut -d"=" -f 2)
    echo "Skipping make"    
fi

    # Flash fresh boot and system images #
if [ $flash -eq 1 ]; then
    /bin/bash ~/otg.sh -r
    sleep .5
    fastboot flash boot $buildDir/out/target/product/$build/boot.img
    sleep .5
    fastboot flash system $buildDir/out/target/product/$build/system.img
    sleep .5
    fastboot reboot
else
    echo "Skipping flash"    
fi
