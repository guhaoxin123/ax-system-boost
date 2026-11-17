# 全机型系统优化

<img src="banner.jpg" width="100%">

自动识别芯片与品牌，按平台加载对应策略：释放 CPU/GPU 频率、压温控、调内存与 IO、清理云控与无用进程。免 ROOT。

## 功能
- 自适应平台：MTK / 高通，按品牌（小米、OPPO、vivo、荣耀、努比亚…）加载不同策略
- CPU：切换 performance 调速器、锁最高频、全核在线；MTK 关 PPM 限制，高通关 touchboost
- GPU：解除功率 / 温控 / 低电量限制，`devfreq` 锁最高频
- 温控：关闭 `thermal_zone` mode 与 `msm_thermal` / `mtk_thermal` 等模块，减少降频
- 内存与 IO：调 `swappiness`、`vfs_cache_pressure`、`dirty_ratio`，提高 `read_ahead_kb`
- 云控清理：按品牌禁用广告 / 统计 / 云控 / 温控远控组件并强制停止进程
- 常驻：`service.sh` 开机延迟 30 秒进入循环，每 120 秒跑一次 `opt.sh`

## 安装
1. 到 [Releases](../../releases) 下载 `ax-system-boost-v2.4.zip`
2. AxManager / 模块管理器从本地导入
3. 重启后自动生效；点操作按钮可立即执行一次完整优化

## 文件
| 文件 | 说明 |
|---|---|
| `module.prop` | 模块信息 |
| `opt.sh` | 核心优化脚本（平台自适应） |
| `customize.sh` | 安装期检测 |
| `post-fs-data.sh` / `service.sh` | 开机与常驻循环 |
| `action.sh` | 操作按钮 |
| `banner.jpg` | 模块头图 |

## 说明
作者 ghx；本仓库由 DSH 整理、重命名并统一打包。修改系统参数有风险，出问题先在管理器里禁用模块重启。
