#!/system/bin/sh

MODDIR=${0%/*}

echo  "ghxnb666"
echo "【更新 联发科/高通 性能优化"
sleep 0.5
echo "【更新】全平台 CPU/GPU 频率释放"
sleep 0.4
echo "【新增】云控与无用进程后台清理"
sleep 0.3
echo "【新增】后台常驻守护服务"
sleep 0.3
echo "【作者】GHX"
sleep 0.3
echo "这款模块免费，不许倒卖"
sleep 0.3
echo ""
echo "性能服务状态:运行中"
echo ""
echo "[+]自动识别SOC"
echo "全局优化CPU/GPU/温控/云控..."
sleep 0.3
SOC=$(getprop ro.board.platform)
BRAND=$(getprop ro.product.brand | tr '[A-Z]' '[a-z]')
sleep 0.3
echo "[√]${BRAND} | ${SOC} 检测设备"
echo "- Android 版本 : $(getprop ro.build.version.release)"
sleep 0.3
echo "- 内核版本: $(uname -r)"
sleep 0.3
echo "- 处理器 : $(getprop ro.product.board)"
sleep 0.3
echo "- CPU 信息: $(getprop ro.hardware)"
sleep 0.3
echo "- 内存大小: $(free | grep Mem | awk '{print $2}')"
sleep 1.0
echo ">> 开始CPU优化"
sh $MODDIR/opt.sh cpu
echo "【OK】CPU优化完成"
sleep 0.5
echo ">> 开始GPU优化"
sh $MODDIR/opt.sh gpu
echo "【OK】GPU优化完成"
sleep 0.5
echo ">> 开始温控封堵优化"
sh $MODDIR/opt.sh thermal
echo "【OK】温控封堵完成"
sleep 0.5
echo ">> 开始内存IO优化"
sh $MODDIR/opt.sh mem
echo "【OK】内存IO优化完成"
sleep 0.5
echo "=====云控与无用进程拦截启动====="
sleep 0.3
sh $MODDIR/opt.sh junk
echo "【OK】无用进程清理完成"
sleep 0.3
echo "QQ群：1058272764，持续更新"
sleep 0.3
echo "这款模块免费，不许倒卖
ghxnn666"