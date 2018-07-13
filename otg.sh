#!/bin/bash
minicom=$(ps cax | grep minicom)
launchShell=0
reboot=0

while [ ${#minicom} -ne 0 ]
do
    sudo pkill minicom
    sleep 2
    minicom=$(ps cax | grep minicom)
done

    # Check if User wants to launch adb shell or bootloader #
if [ "$#" -ge 1 ]; then
    arg1=$1
    if [ "$arg1" = "-s" ]; then
        launchShell=1
    elif [ "$arg1" = "-r" ]; then
        reboot=1
    fi
fi

{
    echo "echo 1 > sys/class/gpio/gpio258/value"
    echo "mount -o remount, rw /system"
        # Key sequence to quit Minicom #
} | sudo minicom -w -D /dev/ttyUSB0
sleep 3

    # Launch an adb shell #
if [ $launchShell -ne 0 ]; then
    adb shell

    # Reboot device into bootloader, launch fastboot #
elif [ $reboot -ne 0 ]; then
    adb devices
    conn=$(adb devices)
    if [ ${#conn} -ge 25 ]; then
        adb reboot-bootloader
        sleep 3
        {
            echo "stop autoboot"
            echo "fastboot q"
        } | sudo minicom -w -D /dev/ttyUSB0
    fi
    sleep 1
fi

sudo pkill minicom