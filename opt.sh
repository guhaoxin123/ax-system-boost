#!/system/bin/sh

SOC=$(getprop ro.board.platform)
HW=$(getprop ro.hardware)
BRAND=$(getprop ro.product.brand | tr '[A-Z]' '[a-z]')

CHIP=common
[ -d /sys/class/kgsl/kgsl-3d0 ] && CHIP=qcom
[ -d /proc/gpufreq ] && CHIP=mtk
[ -d /sys/kernel/ged ] && CHIP=mtk
[ -d /sys/module/mtk_thermal ] && CHIP=mtk
case "$SOC" in
  mt*|MT*) CHIP=mtk ;;
  sm*|SM*|msm*|MSM*|kona*|kalama*|waipio*|taro*|lahaina*) CHIP=qcom ;;
esac
case "$HW" in
  mt*|MT*) CHIP=mtk ;;
  qcom*|QCOM*) CHIP=qcom ;;
esac

PKGS=""

dis() {
  case "$PKGS" in
    *"package:$1"*) pm disable-user --user 0 "$1" >/dev/null 2>&1 ;;
  esac
}

stop_app() {
  am force-stop "$1" >/dev/null 2>&1
}

do_cpu() {
  for p in /sys/devices/system/cpu/cpufreq/policy* /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
    [ -d "$p" ] || continue
    echo performance > "$p/scaling_governor" 2>/dev/null
    mx=$(cat "$p/cpuinfo_max_freq" 2>/dev/null)
    if [ -n "$mx" ]; then
      echo "$mx" > "$p/scaling_max_freq" 2>/dev/null
      echo "$mx" > "$p/scaling_min_freq" 2>/dev/null
    fi
  done
  for c in /sys/devices/system/cpu/cpu[0-9]*/online; do
    echo 1 > "$c" 2>/dev/null
  done
  echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/boost 2>/dev/null
  echo 1 > /sys/module/cpu_boost/parameters/input_boost_enabled 2>/dev/null
  echo 0 > /sys/module/cpu_boost/parameters/boost_ms 2>/dev/null
  if [ "$CHIP" = "mtk" ]; then
    echo 0 > /proc/ppm/enabled 2>/dev/null
    echo 0 > /proc/ppm/policy/ut_fix_freq_idx 2>/dev/null
    echo 100 > /proc/ppm/policy/hard_userlimit_cpu_freq 2>/dev/null
  fi
  if [ "$CHIP" = "qcom" ]; then
    echo 0 > /sys/module/msm_performance/parameters/touchboost 2>/dev/null
    echo 1 > /sys/module/msm_performance/parameters/cpu_boost 2>/dev/null
  fi
}

do_gpu() {
  if [ "$CHIP" = "mtk" ]; then
    [ -f /proc/gpufreq/gpufreq_power_limited ] && echo 0 > /proc/gpufreq/gpufreq_power_limited 2>/dev/null
    [ -f /proc/gpufreq/gpufreq_limited_thermal_ignore ] && echo 1 > /proc/gpufreq/gpufreq_limited_thermal_ignore 2>/dev/null
    [ -f /proc/gpufreq/gpufreq_limited_low_batt_volt_ignore ] && echo 1 > /proc/gpufreq/gpufreq_limited_low_batt_volt_ignore 2>/dev/null
    [ -f /proc/gpufreq/gpufreq_limited_low_batt_volume_ignore ] && echo 1 > /proc/gpufreq/gpufreq_limited_low_batt_volume_ignore 2>/dev/null
    [ -f /proc/gpufreq/gpufreq_limited_oc_ignore ] && echo 1 > /proc/gpufreq/gpufreq_limited_oc_ignore 2>/dev/null
    [ -f /sys/kernel/ged/hal/custom_boost_gpu_freq ] && echo 1 > /sys/kernel/ged/hal/custom_boost_gpu_freq 2>/dev/null
    [ -f /sys/kernel/ged/hal/custom_upbound_gpu_freq ] && echo 1 > /sys/kernel/ged/hal/custom_upbound_gpu_freq 2>/dev/null
  fi
  if [ "$CHIP" = "qcom" ]; then
    b=/sys/class/kgsl/kgsl-3d0
    if [ -d "$b" ]; then
      echo performance > $b/devfreq/governor 2>/dev/null
      echo 0 > $b/throttling 2>/dev/null
      echo 1 > $b/force_clk_on 2>/dev/null
      echo 1 > $b/force_no_nap 2>/dev/null
      echo 0 > $b/force_bus_on 2>/dev/null
      echo 0 > $b/force_rail_on 2>/dev/null
      echo 0 > $b/disable_ebuf 2>/dev/null
      mx=$(cat $b/devfreq/max_freq 2>/dev/null)
      [ -n "$mx" ] && echo "$mx" > $b/devfreq/min_freq 2>/dev/null
      cat $b/max_gpuclk > $b/gpuclk 2>/dev/null
    fi
  fi
  for d in /sys/class/devfreq/*mali* /sys/class/devfreq/*kgsl* /sys/class/devfreq/*gpufreq* /sys/class/devfreq/*ged*; do
    [ -d "$d" ] || continue
    echo performance > "$d/governor" 2>/dev/null
    mx=$(cat "$d/max_freq" 2>/dev/null)
    [ -n "$mx" ] && echo "$mx" > "$d/min_freq" 2>/dev/null
  done
}

do_thermal() {
  for t in /sys/class/thermal/thermal_zone*; do
    [ -d "$t" ] || continue
    echo disabled > "$t/mode" 2>/dev/null
  done
  [ -f /sys/module/msm_thermal/parameters/enabled ] && echo N > /sys/module/msm_thermal/parameters/enabled 2>/dev/null
  [ -f /sys/module/msm_thermal/core_control/parameters/enabled ] && echo N > /sys/module/msm_thermal/core_control/parameters/enabled 2>/dev/null
  [ -f /sys/module/mtk_thermal/parameters/enable ] && echo 0 > /sys/module/mtk_thermal/parameters/enable 2>/dev/null
  [ -f /sys/module/mtk_thermal/parameters/enable_all ] && echo 0 > /sys/module/mtk_thermal/parameters/enable_all 2>/dev/null
  [ -f /sys/module/thermal/parameters/enabled ] && echo N > /sys/module/thermal/parameters/enabled 2>/dev/null
  [ -f /proc/driver/thermal/tm_zone ] && echo 0 > /proc/driver/thermal/tm_zone 2>/dev/null
  [ -f /sys/class/thermal/thermal_message/sconfig ] && echo 10 > /sys/class/thermal/thermal_message/sconfig 2>/dev/null
}

do_mem() {
  echo 0 > /proc/sys/vm/swappiness 2>/dev/null
  echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
  echo 10 > /proc/sys/vm/dirty_ratio 2>/dev/null
  echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null
  echo 0 > /proc/sys/kernel/sched_boost 2>/dev/null
  echo 1 > /proc/sys/kernel/sched_schedstats 2>/dev/null
  for q in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/ufs*/queue /sys/block/dm-*/queue; do
    [ -d "$q" ] || continue
    echo 2048 > "$q/read_ahead_kb" 2>/dev/null
    echo 0 > "$q/iostats" 2>/dev/null
  done
}

do_junk() {
  PKGS=$(pm list packages 2>/dev/null)
  case "$BRAND" in
    xiaomi|redmi|poco)
      dis com.miui.msa.global
      dis com.miui.analytics
      dis com.miui.systemAdSolution
      dis com.xiaomi.ab
      dis com.miui.hybrid
      dis com.xiaomi.mircs
      dis com.miui.daemon
      stop_app com.miui.analytics
      stop_app com.miui.msa.global
      stop_app com.miui.systemAdSolution
      ;;
    oppo|realme|oneplus)
      dis com.oplus.statistics
      dis com.coloros.adservice
      dis com.oplus.cosa
      dis com.oplus.battery.cloud
      dis com.oplus.thermalcontrol
      dis com.coloros.sceneservice
      dis com.oplus.quicksearch
      stop_app com.oplus.cosa
      stop_app com.coloros.adservice
      stop_app com.oplus.statistics
      ;;
    vivo|iqoo)
      dis com.vivo.analytics
      dis com.android.bbklog
      dis com.vivo.pushservice
      dis com.vivo.batterysaver.cloud
      dis com.vivo.scenectrl
      dis com.bbk.iqoo.logsystem
      stop_app com.vivo.analytics
      stop_app com.android.bbklog
      ;;
    honor)
      dis com.honor.analytics
      dis com.honor.advertise
      dis com.honor.cloudcontrol
      dis com.honor.thermal.cloud
      dis com.honor.thermal.remote
      dis com.honor.userstat
      dis com.honor.datacollect
      stop_app com.honor.analytics
      stop_app com.honor.cloudcontrol
      ;;
    nubia|redmagic)
      dis com.nubia.analytics
      dis com.nubia.advertise
      dis com.nubia.cloudcontrol
      dis com.nubia.thermal.remote
      dis com.nubia.userstat
      dis com.nubia.config.sync
      stop_app com.nubia.analytics
      stop_app com.nubia.cloudcontrol
      ;;
  esac
  stop_app com.android.tracedbox
  stop_app com.android.dumpstate
}

case "$1" in
  cpu) do_cpu ;;
  gpu) do_gpu ;;
  thermal) do_thermal ;;
  mem) do_mem ;;
  junk) do_junk ;;
  *) do_cpu; do_gpu; do_thermal; do_mem; do_junk ;;
esac