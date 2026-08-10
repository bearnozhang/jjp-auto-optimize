#!/bin/bash
# JJP监控脚本 - 实时监控节点状态

set -e

# 配置
WORKER_API="${WORKER_API:-https://jjp.bearno1.dpdns.org/test/api/preferred-ips}"
LOG_FILE="./logs/monitor_$(date +%Y%m%d).log"
ALERT_THRESHOLD=50  # 节点数量低于此值告警
LATENCY_THRESHOLD=200  # 延迟高于此值告警

# 创建日志目录
mkdir -p ./logs

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查节点数量
check_node_count() {
    log "=== 检查节点数量 ==="
    
    RESPONSE=$(curl -sk "$WORKER_API" 2>/dev/null)
    NODE_COUNT=$(echo "$RESPONSE" | jq '.count // 0' 2>/dev/null || echo 0)
    
    log "当前节点数量: $NODE_COUNT"
    
    if [ "$NODE_COUNT" -lt "$ALERT_THRESHOLD" ]; then
        log "⚠️ 警告: 节点数量低于阈值 ($ALERT_THRESHOLD)"
        return 1
    fi
    
    log "✅ 节点数量正常"
    return 0
}

# 检查节点延迟
check_latency() {
    log "=== 检查节点延迟 ==="
    
    RESPONSE=$(curl -sk "$WORKER_API" 2>/dev/null)
    
    echo "$RESPONSE" | jq -c '.data[]' 2>/dev/null | while read -r node; do
        ip=$(echo "$node" | jq -r '.ip')
        port=$(echo "$node" | jq -r '.port')
        name=$(echo "$node" | jq -r '.name')
        
        # 测试延迟
        START=$(date +%s%N)
        timeout 3 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null
        END=$(date +%s%N)
        
        if [ $? -eq 0 ]; then
            LATENCY=$(( (END - START) / 1000000 ))
            log "$ip:$port ($name) - ${LATENCY}ms"
            
            if [ "$LATENCY" -gt "$LATENCY_THRESHOLD" ]; then
                log "⚠️ 延迟过高: $ip:$port"
            fi
        else
            log "❌ 连接失败: $ip:$port"
        fi
    done
}

# 检查订阅可用性
check_subscription() {
    log "=== 检查订阅可用性 ==="
    
    SUB_URL="https://jjp.bearno1.dpdns.org/test/sub"
    RESPONSE=$(curl -sk -w "%{http_code}" -o /tmp/sub_check.txt "$SUB_URL" 2>/dev/null)
    STATUS=$(echo "$RESPONSE" | tail -1)
    SIZE=$(wc -c < /tmp/sub_check.txt 2>/dev/null || echo 0)
    
    if [ "$STATUS" = "200" ] && [ "$SIZE" -gt 1000 ]; then
        log "✅ 订阅可用 (HTTP $STATUS, ${SIZE} bytes)"
        return 0
    else
        log "❌ 订阅异常 (HTTP $STATUS, ${SIZE} bytes)"
        return 1
    fi
}

# 生成健康报告
generate_report() {
    log "=== 生成健康报告 ==="
    
    REPORT_FILE="./reports/health_$(date +%Y%m%d_%H%M%S).md"
    mkdir -p ./reports
    
    cat > "$REPORT_FILE" << EOF
# JJP健康检查报告

**检查时间**: $(date)
**检查结果**: $1

## 详细信息

### 节点状态
$(check_node_count 2>&1)

### 延迟测试
$(check_latency 2>&1)

### 订阅状态
$(check_subscription 2>&1)

## 建议
$(if [ "$1" = "PASS" ]; then echo "- ✅ 系统运行正常"; else echo "- ⚠️ 需要检查问题"; fi)
EOF
    
    log "报告已生成: $REPORT_FILE"
}

# 主函数
main() {
    log "=========================="
    log "JJP监控开始"
    log "=========================="
    
    # 执行检查
    NODE_OK=false
    SUB_OK=false
    
    check_node_count && NODE_OK=true
    check_subscription && SUB_OK=true
    
    # 计算总体状态
    if $NODE_OK && $SUB_OK; then
        STATUS="PASS"
        log "✅ 总体状态: 正常"
    else
        STATUS="FAIL"
        log "⚠️ 总体状态: 异常"
    fi
    
    # 生成报告
    generate_report "$STATUS"
    
    log "=========================="
    log "JJP监控完成"
    log "=========================="
    
    # 返回状态
    if [ "$STATUS" = "PASS" ]; then
        return 0
    else
        return 1
    fi
}

# 执行主函数
main
