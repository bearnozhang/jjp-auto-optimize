#!/bin/bash
# 从免费订阅源抓取节点，去重后保存到GitHub

echo "=== 抓取免费节点 ==="

# 免费订阅源
SOURCES=(
    "https://raw.githubusercontent.com/awesome-vpn/awesome-vpn/master/all"
    "https://raw.githubusercontent.com/littlebais/free-proxy-nodes/main/v2ray"
    "https://raw.githubusercontent.com/FreeFolksOn/abc-configs-free-vpn-proxy-list/main/README.md"
    "https://cdn.jsdelivr.net/gh/xiaoji235/airport-free/v2ray.txt"
)

# 下载所有订阅
> temp_nodes.txt
for SOURCE in "${SOURCES[@]}"; do
    echo "抓取: $SOURCE"
    curl -skL "$SOURCE" >> temp_nodes.txt 2>/dev/null || true
    sleep 1
done

# 提取节点URL（去重）
grep -oE "(vless|vmess|trojan|ss)://[a-zA-Z0-9+/=?.%&@#-]+" temp_nodes.txt | \
    sort -u | \
    head -200 > free_nodes.txt

echo "去重后节点数: $(wc -l < free_nodes.txt)"

# 按地区分类
echo ""
echo "=== 按地区分类 ==="
echo "日本节点: $(grep -i "japan\|日本" free_nodes.txt | wc -l)"
echo "韩国节点: $(grep -i "korea\|韩国" free_nodes.txt | wc -l)"
echo "美国节点: $(grep -i "united states\|美国" free_nodes.txt | wc -l)"
echo "香港节点: $(grep -i "hong kong\|香港" free_nodes.txt | wc -l)"
echo "新加坡节点: $(grep -i "singapore\|新加坡" free_nodes.txt | wc -l)"

# 清理
rm -f temp_nodes.txt

echo ""
echo "节点文件已保存: free_nodes.txt"
