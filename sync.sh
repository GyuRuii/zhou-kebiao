#!/bin/sh
# 同步课表到手机版:直接读取 Mac 版 app 的本地存储(课表+备忘录),上传到 GitHub Pages
# 用法: 双击运行或 ./sync.sh —— 无需手动导出
set -e
cd "$(dirname "$0")"

# 1. 从 Mac 版 app 的 WebKit 存储里读最新数据
DB_DIR="$HOME/Library/WebKit/com.chestnut.weeklytimetable/WebsiteData/Default"
DB=$(find "$DB_DIR" -name "localstorage.sqlite3" -path "*LocalStorage*" 2>/dev/null | head -1)
[ -n "$DB" ] || { echo "找不到 Mac 版小栗周表的本地存储,请先打开过一次 Mac 版 app"; exit 1; }

TMP=$(mktemp -d)
cp "$DB" "$TMP/"
cp "$DB-wal" "$TMP/" 2>/dev/null || true
cp "$DB-shm" "$TMP/" 2>/dev/null || true
python3 - "$TMP/localstorage.sqlite3" "$TMP/payload.json" <<'PYEOF'
import sqlite3, json, sys
con = sqlite3.connect(sys.argv[1])
vals = {}
for k, v in con.execute("SELECT key, value FROM ItemTable"):
    vals[k] = v.decode('utf-16')
con.close()
payload = {
    "events": json.loads(vals.get('weekly-timetable-v1', '[]')),
    "memo": vals.get('weekly-timetable-memo-v1', ''),
}
open(sys.argv[2], 'w', encoding='utf-8').write(json.dumps(payload, ensure_ascii=False, indent=2))
print(f"读取到 {len(payload['events'])} 条日程 + 备忘录 {len(payload['memo'])} 字")
PYEOF
cp "$TMP/payload.json" "课表.json"
rm -rf "$TMP"

# 2. 提交并推送到 GitHub(直连失败自动走本地代理)
git add 课表.json
git -c user.name="GyuRuii" -c user.email="326579602+GyuRuii@users.noreply.github.com" \
    commit -m "同步课表+备忘录 $(date '+%m-%d %H:%M')" >/dev/null 2>&1 || true

TOKEN_FILE="$HOME/.zhou-kebiao-token"
if [ -f "$TOKEN_FILE" ]; then
  REMOTE="https://GyuRuii:$(cat "$TOKEN_FILE")@github.com/GyuRuii/zhou-kebiao.git"
else
  REMOTE="origin"
fi
push_direct()  { git -c http.version=HTTP/1.1 push "$REMOTE" main; }
push_proxy()   { git -c http.version=HTTP/1.1 -c http.proxy=http://127.0.0.1:7897 push "$REMOTE" main; }
# 本地代理端口开着就先走代理,否则直连;失败再换另一条路
if nc -z -w 1 127.0.0.1 7897 2>/dev/null; then
  push_proxy >/dev/null 2>&1 || push_direct
else
  push_direct >/dev/null 2>&1 || push_proxy
fi
echo "✅ 已上传。手机上打开 app 点「同步数据」即可。"
