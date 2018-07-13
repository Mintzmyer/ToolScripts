minicom=$(ps cax | grep minicom)
while [ ${#minicom} -ne 0 ]
do
    sudo pkill minicom
    sleep 2
    minicom=$(ps cax | grep minicom)
done

echo "echo 1 > sys/class/gpio/gpio258/value" | sudo minicom -w -D /dev/ttyUSB0
echo "mount -o remount, rw /system" | sudo minicom -w -D /dev/ttyUSB0
echo $(xdotool keydown Ctrl key a keyup Ctrl key q) | sudo minicom -w -D /dev/ttyUSB0
sleep 3

sudo pkill minicom
adb shell
