#!/bin/sh
# 双击运行:把 Mac 版小栗周表的最新数据上传,手机上点「同步数据」即可拉取
cd "$(dirname "$0")/Claude/zhou-kebiao"
./sync.sh
echo ""
echo "按回车键关闭窗口"
read dummy
