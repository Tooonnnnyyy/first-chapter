# First Chapter 贡献与维护

[使用说明](README.md) · [English](../en/maintenance.md) · [Français](../fr/maintenance.md)

## 贡献流程

先选择或创建 Issue，写明学生需求和可观察的验收条件。P0 表示核心发现功能失效，或阻碍发布的数据/隐私问题；P1 为下一项有价值的改进；P2 为后续工作。同时参考 v2 路线图的优先级及任务认领记录。从最新 `main` 建立分支，禁止直接修改或推送 `main`。

每次提交聚焦一个问题，更新官方信息来源及相关翻译，运行 README 中的检查。Swift 修改需要模拟器构建；界面修改需要实际交互和无障碍验证。创建关联 Issue 的 PR，说明学生能感受到的变化和验证范围，处理评审讨论并等待必要检查通过。没有独立评审时，不得声称已经获得他人批准。

欢迎英文、法文和中文贡献。保持代码标识符稳定，翻译用户可见文本和文档。明确标注未翻译内容，不要把多语言文档当作完整界面本地化。遵守[行为准则](../../CODE_OF_CONDUCT.md)。

## GitHub 自动化如何工作

| 工作流 | 何时触发 | 作用 |
| --- | --- | --- |
| CI | PR、main 推送、手动 | 检查链接与源码、测试 API 和旧原型、无签名 iOS 构建、容器健康检查 |
| Security | PR、main、每周 | PR 依赖风险检查，以及 JavaScript/TypeScript CodeQL 分析 |
| Source release | 推送 `v*` 标签 | 验证版本和 main 祖先关系、运行检查、生成含源码和 SHA-256 校验值的**草稿发布** |
| Publish experimental API container | 仅 main 上手动运行 | 将按提交标记的镜像上传 GHCR，不部署服务器 |
| Wiki navigation | main 文档变更或手动 | 生成三语导航附件；只有配置 `WIKI_TOKEN` 才自动同步 |
| Dependabot | Actions 每周、归档 npm 每月 | 自动提出依赖更新 PR，不自动合并 |

在 **Actions** 页面打开某次运行，再选择 job 查看日志。绿色仅表示列出的检查通过，不代表所有界面、数据准确性、安全性和线上部署均已验证。失败时修复第一个出错步骤，在同一分支推送即可重跑。没有配置付费云服务凭证。

## 标签、发布与软件包

Git tag 为指定提交命名；GitHub Release 在标签上附加说明及文件。先验证 main 中的目标提交并更新 CHANGELOG，再创建如 `v0.1.0-alpha.1` 的 annotated tag 并推送该标签。工作流生成草稿，维护者检查后发布。在完整验证完成前使用预发布标记。源码发布不等于已签名 iOS 应用、TestFlight 或服务器部署。不要覆盖已发布标签；新建补丁版本，或通过 PR 回退代码。

根目录 `package.json` 是私有开发命令集合。服务器没有第三方 npm 依赖；两者均不发布到 npm。归档 React 应用有独立 lockfile，使用 `npm ci`。

服务器 Dockerfile 以非 root 用户运行；CI 会构建并测试 `/health`。本机安装 Docker 后可以运行：

```sh
docker build -t first-chapter-api:local server
docker run --rm -p 127.0.0.1:8787:8787 -v first-chapter-data:/data first-chapter-api:local
```

命名 volume 保存数据库，容器退出后仍保留；删除 volume 会删除数据。手动发布工作流生成 `ghcr.io/tooonnnnyyy/first-chapter/api:sha-<完整提交>`，不创建可变的 `latest` 标签。软件包可见性与仓库可见性分别设置，需要确认后才能期待匿名下载。发布镜像不代表 API 已可用于生产。原生应用和静态网页不需要这个包。

## Wiki、隐私及维护

仓库内版本化 Markdown 是文档来源，Wiki 负责导航。GitHub 要求先在网页创建第一篇 Wiki，之后才存在独立 `.wiki.git` 仓库。工作流总会生成可下载附件；自动同步需要专用、最小权限且可以写入此 Wiki 的 token，保存在 Actions secret `WIKI_TOKEN`。不要将 token 写入文件或 Issue。未配置时可将生成页面手动复制到已初始化 Wiki。

当前计划保存在设备/浏览器。可选助手可能将问题发送给供应商，请勿输入敏感信息。不要在 Issue 中附上学生记录、token、数据库或私人截图。托管前请阅读 [SECURITY](../../SECURITY.md) 及 [API 限制](../architecture/overview.md)。

其他功能分支开发期间保持应用目录稳定。[架构](../architecture/overview.md)、[路线图](../planning/v2-roadmap.md)、官方参考和历史记录以英文为准；本维护指南和 README 提供中文概述，欢迎继续补充翻译。
