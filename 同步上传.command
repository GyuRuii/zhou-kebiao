#!/bin/sh
# 双击运行:把 Mac 版小栗周表的最新数据上传,手机上点「同步数据」即可拉取
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 本文件放在哪都能找到 sync.sh:先在自身目录找,再找旁边的 Claude/zhou-kebiao
if [ -f "$SCRIPT_DIR/sync.sh" ]; then
  cd "$SCRIPT_DIR"
elif [ -d "$SCRIPT_DIR/Claude/zhou-kebiao" ]; then
  cd "$SCRIPT_DIR/Claude/zhou-kebiao"
else
  echo "找不到 sync.sh:请把本文件放到 zhou-kebiao 文件夹里(或桌面上,旁边有 Claude 文件夹即可)"
  echo ""
  echo "按回车键关闭窗口"
  read dummy
  exit 1
fi
./sync.sh
echo ""
echo "按回车键关闭窗口"
read dummy
