#!/bin/bash
# Fan full speed or auto, default auto
full () {
echo 255 > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon[[:print:]]*/pwm1 
}
auto () {
 echo 2 > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon[[[:print:]]*/pwm1_enable
}




$1;

