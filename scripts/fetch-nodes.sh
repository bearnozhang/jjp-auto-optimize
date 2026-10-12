#!/bin/bash
# 从免费订阅源抓取节点，验证并添加地区信息

echo "=== 抓取免费节点 ==="

# 免费订阅源
SOURCES=(
    "https://raw.githubusercontent.com/awesome-vpn/awesome-vpn/master/all"
    # 2026-10-13：FreeFolksOn 的 v2ray.txt / config.txt 已 404，已移除
)

# 下载所有订阅
> temp_nodes.txt
for SOURCE in "${SOURCES[@]}"; do
    echo "抓取: $SOURCE"
    curl -skL "$SOURCE" >> temp_nodes.txt 2>/dev/null || true
    sleep 1
done

# 解码base64内容
echo ""
echo "=== 解码base64 ==="
base64 -d temp_nodes.txt > decoded_nodes.txt 2>/dev/null || true

# 提取节点URL（去重）
echo ""
echo "=== 提取节点 ==="
cat temp_nodes.txt decoded_nodes.txt | \
    grep -oE "(vless|vmess|trojan|ss)://[a-zA-Z0-9+/=?.%&@#-]+" | \
    sort -u > all_nodes.txt

echo "提取到 $(wc -l < all_nodes.txt) 个节点"

# 验证节点并添加地区信息
echo ""
echo "=== 验证节点并添加地区信息 ==="
> verified_nodes.txt

while IFS= read -r node; do
    # 提取IP/域名
    ip=$(echo "$node" | grep -oP '@\K[^:]+' | head -1)
    
    # 跳过私有IP
    if echo "$ip" | grep -qE "^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)"; then
        continue
    fi
    
    # 测试连接
    if timeout 3 bash -c "echo >/dev/tcp/$ip/443" 2>/dev/null; then
        # 获取地区信息
        region=$(curl -sk "http://ip-api.com/json/$ip?fields=country,regionName,city" 2>/dev/null | grep -oP '"country":"[^"]*"' | cut -d'"' -f4)
        city=$(curl -sk "http://ip-api.com/json/$ip?fields=country,regionName,city" 2>/dev/null | grep -oP '"city":"[^"]*"' | cut -d'"' -f4)
        
        # 获取延迟
        latency=$(curl -sk --connect-timeout 3 -o /dev/null -w "%{time_connect}" "https://$ip:443" 2>/dev/null | cut -d'.' -f1)
        
        # 构建节点名称
        name="${region}/${city} (${latency}ms)"
        
        echo "$node" >> verified_nodes.txt
        echo "✅ $ip - $name"
    else
        echo "❌ $ip - 连接失败"
    fi
done < all_nodes.txt

echo ""
echo "验证后节点数: $(wc -l < verified_nodes.txt)"

# 清理
rm -f temp_nodes.txt decoded_nodes.txt all_nodes.txt

echo ""
# 只有抓到节点时才覆盖 free_nodes.txt，避免源挂掉时清空列表
if [ -s verified_nodes.txt ]; then
    mv verified_nodes.txt free_nodes.txt
    echo "节点文件已保存: free_nodes.txt"
else
    rm -f verified_nodes.txt
    echo "没有抓到可用节点，保留原有 free_nodes.txt"
fi
