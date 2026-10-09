# KUME · 酷米输入法

本项目基于 AIME 改名开发。英文产品名为 **KUME**，中文名为 **酷米输入法**，命令名为 `kume`。默认强调色为 `rgb(1, 91, 215)` / `#015BD7`，应用于设置控件、默认候选高亮和品牌图标；深色背景上的文字强调色使用更浅的蓝色以保持可读性。Git 仓库仍为 `wangsizhu0504/kime`，仓库地址与本地检出目录不随产品改名自动变化。

## 独立安装与数据

| 项目 | KUME |
|---|---|
| 输入法 | `KUME.app` |
| 设置 | `KUME Settings.app` |
| Swift 包 | `Packages/KUMEKit` |
| 模块 | `KUMECore`、`KUMEPanel`、`KUMEAI`；引擎模块仍为 `RimeKit` |
| 输入法标识 | `app.kriszu.inputmethod.kume` |
| 设置标识 | `app.kriszu.kume.settings` |
| RIME 用户目录 | `~/Library/KUME/Rime` |
| 统计与凭据 | `~/Library/Application Support/KUME` |
| 日志 | `~/Library/Logs/KUME` |
| 配置层 | `kume/imported`、`kume/generated` |
| 环境变量前缀 | `KUME_` |
| 主题链接及格式 | `kume-ime://theme`、`kume-theme` |
| 备份格式 | `kume-backup` |

KUME 不自动迁移、覆盖或删除 AIME 的配置、统计、凭据、应用和输入源。旧 AIME 主题链接与备份不冒充 KUME 格式；如需迁移，应另行设计显式导入流程。应用、安装包、通知与日志统一使用 `app.kriszu` 标识前缀，与 AIME 分离。

## 外部资源与发布

词库、语言模型和依赖继续使用真实的上游下载地址；AIME、词库作者和第三方许可的来源署名保留。旧发布记录、宣传图和截图是历史资料，不代表 KUME 当前界面或发布状态。应用内字标和输入源图标已重新生成。

KUME 暂无已配置的独立更新服务。自动检查默认关闭，应用中的手动检查只显示说明，不请求 AIME 发布服务。校验代码还会拒绝 `product` 不是 `kume` 的清单与下载请求。启用更新前必须配置并核验 KUME 自己的下载地址、发布签名、清单公钥，然后启用 `AppUpdateChecker.serviceConfigured`。仓库继承的签名与发布脚本不代表本项目已拥有相应证书、服务或发布权限。

原作者版权和第三方许可证保持不变。

## AI 配置

AI 助手与输入法动作统一读取 `kume/features.json` 的 `aiBaseURL` 和 `aiModel`；API Key 单独保存在 `~/Library/Application Support/KUME/credentials.json`。不再使用 Apple 智能或 `ai.provider` / `ai.baseURL` / `ai.model` 的 UserDefaults 副本。未配置时提示补全设置，不回退到其他服务。支持基础地址和完整 `/chat/completions` 地址，协议为 OpenAI Chat Completions。输入法动作仍需开启发送授权，修改地址后会撤销旧授权。
