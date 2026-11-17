#!/system/bin/sh

MODDIR=${0%/*}

until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 5
done

sleep 30

while true; do
  sh $MODDIR/opt.sh >/dev/null 2>&1
  sleep 120
done