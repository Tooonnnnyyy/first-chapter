# First Chapter

[English](../../README.md) · [Français](../fr/README.md) · [简体中文](README.md)

面向渥太华大学一年级学生的开源图书馆服务指南：查找研究支持、学习空间和借用设备，访问官方服务页面，并保存个人计划。

**P0：让学生更容易找到重要信息，保证已宣传的功能正常工作。** 项目始于 2026 年图书馆 AI Buildathon，现作为独立开源项目维护，采用 [MIT 许可证](../../LICENSE)。

[使用网页版](https://first-chapter-nine.vercel.app) · [报告问题](https://github.com/Tooonnnnyyy/first-chapter/issues) · [Wiki](https://github.com/Tooonnnnyyy/first-chapter/wiki)

## 当前状态

- iOS：引导、服务搜索、设备链接、可选助手，以及保存在设备上的个人计划。
- Web：搜索、发现、设备链接，以及浏览器本地计划。在 Vercel 上可启用服务器端 DeepSeek 代理。
- 实验性 Node/SQLite API：服务目录、匿名会话、计划、可解释的推荐排序和初版任务/经验值接口。**当前客户端尚未连接此 API。**

OAuth 账号、新的竖屏信息流和社区功能仍在规划中。已有法语目录数据，但尚未接入界面语言切换。文档翻译不代表应用界面已完成翻译。“Import Your Files”是待实现占位功能。节省点击次数是估算，并非用户研究结果。

## 使用与运行

### iOS

需要 macOS、Xcode 26+ 和 iOS 26+ 模拟器。打开 `FirstChapter.xcodeproj`，选择 FirstChapter scheme 和可用的 iPhone 模拟器，然后点击 Run。无需 API key；助手最终会回退到本地搜索，并标明来源。

```sh
xcodebuild -project FirstChapter.xcodeproj -scheme FirstChapter \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

已启动 iPhone 模拟器时，可用 `./scripts/run.sh` 构建、安装并启动。脚本不再请求或保存密钥。原有原生端直接使用供应商密钥的路径仅适用于私人开发，分发应用不得包含密钥。DeepSeek 在线调用、完整无障碍和端到端验证仍未完成。

### Web 与产品介绍页

在仓库根目录运行，需要 Python 3：

```sh
npm run serve:web
```

打开 <http://127.0.0.1:8080>。此命令仅提供静态文件，不能运行 `/api/ask`，助手会使用已标注的本地回退。要启用可选代理，将 `web/` 部署到 Vercel，并在服务器环境配置 `DEEPSEEK_API_KEY`，不要放入浏览器代码。GitHub Actions 不会自动部署到 Vercel。

直接打开 `landing/index.html` 即可查看独立产品页。真实产品截图已嵌入 HTML，不依赖单独图片文件夹。截图来自 2026 年 11 月原型，可能与后续版本不同。

### 实验性 API 与检查

使用 Node 24（见 `.node-version`）。根目录命令和服务器无需安装 npm 依赖。

```sh
npm run start:server
# 在另一个终端：
curl http://127.0.0.1:8787/health
npm run check
npm test
```

SQLite 文件自动生成于 `server/data/`，不会提交到 Git。可配置 `HOST`、`PORT`、`FC_DATA_DIR`；默认仅监听本机。API 尚缺完整账号生命周期、限流和输入验证，请保持本地开发用途。上述检查不等于浏览器和原生界面的完整验证。

早期 React 原型保存在 `archive/geeguide-web/`。如需运行，在该目录依次执行 `npm ci`、`npm test`、`npm run build`、`npm start`，预览端口为 4173。

## 目录用途

| 路径 | 用途 |
| --- | --- |
| `FirstChapter/`、`FirstChapter.xcodeproj/` | SwiftUI 应用与 Xcode 配置 |
| `web/` | 当前 Web 应用及可选 Vercel 代理 |
| `server/` | 实验性 API、测试及容器配置 |
| `landing/` | 内嵌截图的独立产品页 |
| `docs/en/`、`docs/fr/`、`docs/zh-CN/` | 按语言组织的文档 |
| `docs/architecture/`、`docs/reference/` | 架构决策、官方来源和设计参考 |
| `docs/planning/`、`docs/reviews/`、`docs/history/` | 规划、评审及历史记录 |
| `scripts/`、`.github/` | 构建、检查与 GitHub 自动化 |
| `archive/geeguide-web/` | 早期原型源码，不是当前部署 |

[贡献与自动化说明](maintenance.md) · [架构参考（英文）](../architecture/overview.md) · [路线图（英文）](../planning/v2-roadmap.md) · [图书馆来源（英文）](../reference/library-services.md)

借用资格、开放时间、预约和库存以官方系统为准。本项目与渥太华大学无隶属关系，也未获得其背书。MIT 适用于项目代码；大学名称、商标及外部内容仍受其原有权利约束。
