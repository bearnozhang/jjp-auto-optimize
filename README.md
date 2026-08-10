# JJP Auto Optimize

JJP节点自动优选系统 - GitHub Actions定时任务

## 功能

- 每天凌晨3点自动运行
- 从多个免费源获取候选IP
- 使用yx-tools测试延迟
- 自动上传优选IP到JJP Worker
- 自动清理失效节点

## 使用的工具

- [yx-tools](https://github.com/byJoey/yx-tools) - Cloudflare优选IP工具
- GitHub Actions - CI/CD自动化

## 配置

在仓库的 Settings > Secrets 中添加：

- `WORKER_API` - JJP Worker API地址（可选，默认使用公共地址）

## 手动触发

在 Actions 页面点击 "JJP Auto Optimize" > "Run workflow" 即可手动触发。

