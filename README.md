<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/brand/kume/base-v1/lockup-white.png">
    <img src="assets/brand/kume/base-v1/lockup-color.png" width="300" alt="KUME · 酷米输入法">
  </picture>
</p>

<p align="center"><b>中文常新，自在表达。</b></p>

<p align="center">基于 RIME 的开源 macOS 中文输入法 · 本地优先 · 可选 AI</p>

<p align="center">
  <a href="https://aime.zool.app">上游官网</a> ·
  <a href="https://github.com/wangsizhu0504/kime/releases">下载</a> ·
  <a href="https://aime.zool.app/docs/">上游使用文档</a> ·
  <a href="docs/privacy.md">隐私说明</a> ·
  <a href="README.en.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/wangsizhu0504/kime/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/wangsizhu0504/kime/ci.yml?branch=main&style=flat-square&label=CI" alt="CI"></a>
  <a href="https://github.com/wangsizhu0504/kime/releases"><img src="https://img.shields.io/github/v/release/wangsizhu0504/kime?include_prereleases&style=flat-square&label=release" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-2f855a?style=flat-square" alt="MIT"></a>
  <img src="https://img.shields.io/badge/macOS-26%2B-111111?style=flat-square&logo=apple" alt="macOS 26+">
  <img src="https://img.shields.io/badge/Swift-6-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 6">
  <img src="https://img.shields.io/badge/librime-1.17-B64032?style=flat-square" alt="librime 1.17">
</p>

> [!IMPORTANT]
> **KUME · 酷米输入法** 基于 [AIME](https://github.com/zoolapp/aime) 改名开发，保留上游版权与许可。KUME 使用独立的应用标识及 `~/Library/KUME/Rime` 配置目录，不迁移或修改 AIME 数据。目前请从源码构建；KUME 的安装包签名、公证、Homebrew 分发与自动更新服务尚未配置。详见[改名说明](docs/renaming.md)。

## 有些话，适合静静打出来

语音输入很方便。但不想说话的时候、在共享空间里不便开口的时候，或想边写边想、慢慢斟酌一句话的时候，键盘依然有它的位置。

KUME 为这些时刻而做：保留 RIME 的开放与自由，用原生界面管理输入习惯，在需要时加入 AI 辅助。无内置广告，日常输入在本机处理，方案、外观与词库由你选择。

如果你希望保留全拼／双拼和自己的词库，又想少写一些配置文件；如果你重视安静写作、工具透明和表达的掌控感，可以试试 KUME。

## 为什么是 KUME

| | |
|---|---|
| **开源，站在 RIME 肩上** | 以 [librime](https://github.com/rime/librime) 为引擎、[雾凇拼音](https://github.com/iDvel/rime-ice) 为默认方案。可从鼠须管只读导入已有配置，不改动原目录。KUME 原创代码以 MIT 许可开源。 |
| **日常输入在本机处理** | 组字、候选与个人词频都在本机，不写输入日志，不内置广告、遥测或崩溃上报。常用语与可选输入统计只存于本机。 |
| **AI 由你主动调用** | 翻译、润色与自定义动作，长按 ⌥ 再按空格即可在光标处完成；只有你主动执行时才处理那一段文字。统一从设置读取自定义 OpenAI 兼容接口的地址、模型和 API Key。简繁转换在本机完成。 |
| **输入习惯，由你调整** | 用可视化设置管理方案、配色与快捷键；原生候选窗、常用语分类、短语编码、符号板字母直选，让日常输入少些切换。 |
| **词库常新，生态开放** | 官方词库可按每天／每周自动检查，也可仅手动更新；版本与 SHA-256 校验后使用。可订阅 RIME 兼容词表、安装社区方案，从鼠须管只读导入。感谢上游维护者与贡献者。 |

## 功能

- **快捷菜单**：打字时长按 ⌥，空格进入 AI 处理，1–4 进入常用语、符号、高频词、表情，0 打开设置，全程不离开键盘。
- **表情板**：1906 个离线 emoji，分为表情、人物、自然、美食、旅行、活动、物品、符号、旗帜 9 类。数字切分类、字母直选；Shift+字母或空格连续插入，回车插入并关闭，Esc 返回。
- **AI 处理**：对选中文字、刚打的字或正在选的候选执行翻译、润色，或你自己写提示词的动作（如「粤语」）；简繁转换也在这里，但在本机完成。结果以候选列表呈现，回车替换。
- **输入图层（可选）**：打出的字先停在光标处，回车上屏，便于整段润色后再发送。
- **可视化设置**：候选数量、中英切换、模糊音、简拼纠错、快捷键、简繁输出、按应用默认中英文等 80 余项，覆盖常用 RIME 配置（[调研文档](docs/rime-config-reference.md)）。
- **外观**：配色画廊与实时预览、字体字号、横排 / 竖排、圆角与间距；可基于任一配色自定义，并提示对比度不足。
- **词库**：官方在线词库目录（版本与 SHA-256 校验，每天 / 每周自动更新），任意 RIME 兼容词表订阅；雾凇、万象、白霜等方案一键安装，冲突先提示。
- **词库容量与扩展**：雾凇基础包约 187 万条原始记录（未去重）；官方当前版本每表 160 条是额外专题词，可随版本扩充。可以添加自己的 RIME 词表，单表上限 20 MiB、最多 32 个订阅；更新比较实际内容，等量换词或改权重也会生效。
- **整句选词（可选）**：词库页可下载约 405 MB 的万象离线语言模型，再在输入习惯中启用；默认关闭，评分在本机完成。
- **常用语与短语**：分类管理手机号、邮箱、地址等常用内容；表格编辑自定义短语。
- **输入统计（可选，仅本机）**：每日字数、时段与应用分布、高频词，一键置顶为首选。
- **同步与备份**：基于 RIME 同步目录在多台 Mac 间合并词频（KUME 不运营同步服务器）；一键导出 / 恢复本地备份文件。
- **自动更新**：保留更新校验代码；在配置 KUME 自身的发布服务前关闭，不会安装 AIME 更新。
- **首次引导**：从启用输入法、选择全拼 / 双拼到试打示例短语，一步步带你完成。
- **命令行**：`kume deploy / bench / doctor / import-squirrel / package / get / set / sync`，便于脚本化与 CI。

## 安装

### 从源码构建

App 支持 Apple 芯片与 Intel 的 Mac；命令行工具 `kume` 目前仅支持 Apple 芯片。

从源码构建需要 macOS 26+、Xcode 26+ 与 [XcodeGen](https://github.com/yonaskolb/XcodeGen)（`brew install xcodegen`）。

```bash
git clone https://github.com/wangsizhu0504/kime.git kume && cd kume
bash scripts/install-dev.sh
```

脚本会下载并校验固定版本的 librime 与雾凇拼音，构建输入法、设置 App 与命令行工具，安装到 `~/Library/Input Methods/KUME.app` 并注册。

## 从鼠须管迁移

1. 在鼠须管菜单中执行一次「同步用户数据」，使词频快照为最新。
2. 打开酷米输入法设置，在概览页点击「导入」；或使用命令行：

   ```bash
   ~/Library/Input\ Methods/KUME.app/Contents/Helpers/kume import-squirrel --dry-run   # 预览计划
   ~/Library/Input\ Methods/KUME.app/Contents/Helpers/kume import-squirrel
   ```

导入只读，不修改 `~/Library/Rime`。你的 `*.custom.yaml` 原样放入 `~/Library/KUME/Rime/kume/imported/`，界面中的修改写在独立一层并优先生效，可随时恢复。

## 架构

```mermaid
flowchart LR
  subgraph IME["KUME.app · 输入法进程"]
    C[IMKit 控制器] --> R[librime 1.17<br/>+ lua / octagram / predict]
    C --> P[候选窗 · AppKit]
  end
  S["KUME Settings.app · SwiftUI"] -- 写配置层 --> U[(~/Library/KUME/Rime)]
  S -- 部署请求 --> IME
  R --> U
  Sq[(~/Library/Rime · 只读)] -. 导入 .-> U
```

设置 App 不链接 librime，只读写文件，通过分布式通知请求输入法重新部署。每项配置由三层合成：KUME 默认值 → 手写补丁 → 界面修改。详见 [架构说明](docs/architecture.md) 与 [架构决策记录](docs/decisions/)。

## 开发

```bash
bash scripts/fetch-librime.sh && bash scripts/fetch-dicts.sh
swift build --package-path Packages/KUMEKit && bash scripts/stage-plugins.sh
swift test --package-path Packages/KUMEKit
xcodegen generate && open KUME.xcodeproj
```

性能门禁：`kume bench --schema rime_ice --keys nihaoshijie --iterations 2000 --assert-p99-ms 5`。
贡献流程见 [CONTRIBUTING.zh.md](CONTRIBUTING.zh.md)，发布流程见 [docs/releasing.md](docs/releasing.md)，安全问题请按 [SECURITY.md](SECURITY.md) 私下报告。

## 文档与参与

[文档导航](docs/README.md) 汇总使用、配置、开发与分发说明。遇到问题可提交 [Issue](https://github.com/wangsizhu0504/kime/issues)；贡献代码请读 [贡献指南](CONTRIBUTING.zh.md)，公共词表贡献请到 [aime-dicts](https://github.com/zoolapp/aime-dicts)。欢迎分享输入习惯、方案与主题，反馈示例请使用虚构文字，不附带个人词频或完整配置目录。

## 隐私

日常输入在本机处理，不写输入日志，不上传拼音串、候选列表或用户词频，不包含任何统计或崩溃上报 SDK。订阅在线词库时，输入法按你设定的频率请求公开词表；KUME 的版本检查暂未启用。
只有你主动执行 AI 动作时，目标文字才交给设置中的自定义 Provider。请先配置接口地址、模型和 API Key，并单独允许发送输入法动作中的文字；服务方可能计费。详见 [隐私说明](docs/privacy.md)。

## 路线图

- [x] librime 前端、候选窗、命令行、开发安装与 CI
- [x] 可视化设置、外观预览、应用选项、常用语与自定义短语
- [x] 官方在线词库目录、方案包管理（固定版本与 SHA-256）
- [x] 快捷菜单、AI 处理（自定义 Provider）、输入图层
- [x] 输入统计、首次引导、本地备份与恢复
- [ ] 配置 KUME 的 Developer ID 签名、公证与自动更新
- [ ] 竖排文字方向、候选窗翻页指示
- [ ] librime 源码可复现构建

## 贡献者

感谢每一位参与共建的朋友：提交过 PR 或 Issue 的人都会列在这里。

**代码**

<p>
<a href="https://github.com/foru17" title="@foru17"><img src="https://avatars.githubusercontent.com/u/1920586?v=4&s=96" width="48" height="48" alt="@foru17"></a>
<a href="https://github.com/miantiao-me" title="@miantiao-me"><img src="https://avatars.githubusercontent.com/u/2959393?v=4&s=96" width="48" height="48" alt="@miantiao-me"></a>
</p>

**反馈与建议**

<p>
<a href="https://github.com/BlackCCCat" title="@BlackCCCat"><img src="https://avatars.githubusercontent.com/u/44139461?v=4&s=96" width="48" height="48" alt="@BlackCCCat"></a>
<a href="https://github.com/liustar2011-afk" title="@liustar2011-afk"><img src="https://avatars.githubusercontent.com/u/275464398?v=4&s=96" width="48" height="48" alt="@liustar2011-afk"></a>
<a href="https://github.com/ShingmoYeung" title="@ShingmoYeung"><img src="https://avatars.githubusercontent.com/u/14231553?v=4&s=96" width="48" height="48" alt="@ShingmoYeung"></a>
<a href="https://github.com/uu-myheart" title="@uu-myheart"><img src="https://avatars.githubusercontent.com/u/18180275?v=4&s=96" width="48" height="48" alt="@uu-myheart"></a>
<a href="https://github.com/gaoyuanzong" title="@gaoyuanzong"><img src="https://avatars.githubusercontent.com/u/3156656?v=4&s=96" width="48" height="48" alt="@gaoyuanzong"></a>
<a href="https://github.com/sunpm" title="@sunpm"><img src="https://avatars.githubusercontent.com/u/35005831?v=4&s=96" width="48" height="48" alt="@sunpm"></a>
<a href="https://github.com/liuhao320" title="@liuhao320"><img src="https://avatars.githubusercontent.com/u/38712559?v=4&s=96" width="48" height="48" alt="@liuhao320"></a>
<a href="https://github.com/txchen" title="@txchen"><img src="https://avatars.githubusercontent.com/u/713074?v=4&s=96" width="48" height="48" alt="@txchen"></a>
<a href="https://github.com/morigith" title="@morigith"><img src="https://avatars.githubusercontent.com/u/73282352?v=4&s=96" width="48" height="48" alt="@morigith"></a>
</p>

## 致谢

[RIME / librime](https://github.com/rime/librime) · [鼠须管](https://github.com/rime/squirrel) · [雾凇拼音](https://github.com/iDvel/rime-ice) · [万象拼音](https://github.com/amzxyz/rime_wanxiang) · [白霜拼音](https://github.com/gaboolic/rime-frost) · [rime-essay](https://github.com/rime/rime-essay) · [OpenCC](https://github.com/BYVoid/OpenCC) · [Yams](https://github.com/jpsim/Yams)

## 许可

KUME 原创代码采用 [MIT](LICENSE) 许可。安装包还包含 GPL-3.0 组件：原生插件 `librime-octagram`，以及雾凇拼音方案、词表与 Lua 脚本。
因此**安装包作为整体按 GPL-3.0 条款分发**，原创源码本身仍是 MIT（MIT 与 GPL-3.0 兼容）；每个 Release 都附带对应源码包。
上游 AIME 在线词表采用 CC BY 4.0。其余第三方组件见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)，原生插件许可核对见 [插件许可审计](docs/native-plugin-license-audit.md)。

<p align="center"><sub>基于 ZOOL LLC / Luo Lei 的 AIME 开发，保留原作者版权与许可；KUME / 酷米输入法为本项目名称</sub></p>

排障与诊断导出见[排障指南](docs/troubleshooting.md)。
