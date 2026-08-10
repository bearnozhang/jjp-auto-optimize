# JJP Auto Optimize - 设置指南

## 🔐 必需的密钥配置

### 1. WORKER_API (可选)
- **说明**: JJP Worker API地址
- **默认值**: `https://jjp.bearno1.dpdns.org/test/api/preferred-ips`
- **设置位置**: 仓库 Settings → Secrets and variables → Actions

### 2. 通知Webhook (可选)
- **SLACK_WEBHOOK**: Slack通知地址
- **FEISHU_WEBHOOK**: 飞书通知地址

## 📋 配置步骤

### 步骤1: 访问仓库设置
```
https://github.com/bearnozhang/jjp-auto-optimize/settings/secrets/actions
```

### 步骤2: 添加密钥
点击 "New repository secret"，添加以下密钥：

| 名称 | 值 | 说明 |
|------|-----|------|
| WORKER_API | `https://jjp.bearno1.dpdns.org/test/api/preferred-ips` | JJP Worker API地址 |

### 步骤3: 启用Actions
```
https://github.com/bearnozhang/jjp-auto-optimize/actions
```
点击 "I understand my workflows, go ahead and enable them"

## ⚙️ 自定义配置

### 修改运行时间
编辑 `.github/workflows/jjp-optimize.yml`：
```yaml
on:
  schedule:
    - cron: '0 3 * * *'  # UTC时间，北京时间需要+8小时
```

常用cron表达式：
- `0 3 * * *` - 每天凌晨3点 UTC (北京时间11点)
- `0 15 * * *` - 每天下午3点 UTC (北京时间23点)
- `0 */6 * * *` - 每6小时运行一次
- `0 3 * * 1` - 每周一凌晨3点

### 修改最大延迟阈值
```yaml
env:
  MAX_LATENCY: 200  # 最大延迟(ms)
```

### 修改最大上传数量
在手动触发时设置 `max_ips` 参数。

## 🧪 测试运行

### 手动触发
1. 访问 Actions 页面
2. 选择 "JJP Auto Optimize"
3. 点击 "Run workflow"
4. 设置参数（可选）
5. 点击 "Run workflow"

### 查看结果
1. 在 Actions 页面点击运行记录
2. 查看每个步骤的日志
3. 下载 artifacts 查看详细结果

## 📊 监控和通知

### 查看运行历史
```
https://github.com/bearnozhang/jjp-auto-optimize/actions
```

### 查看API调用
```
https://api.github.com/repos/bearnozhang/jjp-auto-optimize/actions/runs
```

## 🔧 故障排除

### 问题1: Actions未触发
- 检查是否启用了Actions
- 检查cron表达式是否正确
- 检查仓库是否为private（免费账户限制）

### 问题2: 测试失败
- 检查yx-tools是否下载成功
- 检查候选IP源是否可访问
- 查看详细日志

### 问题3: 上传失败
- 检查WORKER_API密钥是否正确
- 检查Worker是否可访问
- 查看API响应错误信息

## 📈 性能优化

### 提高测试速度
- 增加 `-t` 参数（线程数）
- 减少 `-n` 参数（每个IP测试次数）

### 提高成功率
- 增加候选IP源
- 降低 `MAX_LATENCY` 阈值
- 增加超时时间
