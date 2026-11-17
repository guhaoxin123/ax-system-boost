#!/system/bin/sh

ui_print "- AXManager 性能优化模块"
ui_print "- 联发科 / 高通 平台适配"
ui_print "- 正在安装"

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/action.sh 0 0 0755
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/opt.sh 0 0 0755
[ -f $MODPATH/post-fs-data.sh ] && set_perm $MODPATH/post-fs-data.sh 0 0 0755

ui_print "- 安装完成 重启生效"