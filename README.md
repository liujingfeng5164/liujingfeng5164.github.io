# 静好

Hugo + Tailwind CSS v4 + Sveltia CMS + GitHub Pages 的静态博客。
无数据库、无 OAuth 代理、无常驻后端；写作后台用 GitHub PAT 认证。

## 目录结构

```
.
├── archetypes/default.md          # hugo new 的模板
├── assets/css/main.css            # Tailwind 入口（@source hugo_stats.json）
├── content/
│   ├── about.md                   # /about/
│   └── posts/                     # Sveltia CMS 写入这里
├── layouts/
│   ├── _partials/{css,header,footer}.html
│   ├── _default/{baseof,list,single}.html
│   └── index.html
├── static/admin/{index.html,config.yml}   # 写作后台
├── .github/workflows/deploy.yml           # 构建 + 部署
├── hugo.yaml
└── package.json                   # Tailwind v4 依赖
```

## 上线前必改：把 yourname 换成你的 GitHub 用户名

| 文件 | 需要替换的内容 |
| --- | --- |
| `hugo.yaml` | `baseURL: "https://yourname.github.io/"` |
| `static/admin/config.yml` | `repo: yourname/yourname.github.io`、`site_url`、`display_url` |

如果仓库名不是 `你的用户名.github.io`（即项目站点），把 `hugo.yaml` 的 baseURL 改成
`https://你的用户名.github.io/仓库名/`，并把 `config.yml` 的 `repo` 改成 `你的用户名/仓库名`。
部署工作流已经用 `configure-pages` 输出的 `base_url` 覆盖 baseURL，所以路径不会错。

## 本地开发

本项目把 Hugo 与 Node 都装在了 `.tools/`（已 gitignore），不污染系统环境和其他项目：

```powershell
# 把便携版工具链加入当前会话的 PATH
$env:Path = "G:\blog\.tools\node;" + $env:Path
$hugo = "G:\blog\.tools\hugo\hugo.exe"

# 本地预览（含草稿）
& $hugo server --disableFastRender --buildDrafts --buildFuture

# 生产构建（与 CI 一致）
& $hugo --gc --minify
```

打开 http://localhost:1313/ 预览，http://localhost:1313/admin/ 是本地后台入口
（本地后台同样会真实提交到仓库，建议只在正式域名下写文章）。

## 首次上线

1. 在 GitHub 新建仓库 `你的用户名.github.io`。
2. `git init` → 提交 → 推送到 `main`。
3. 仓库 **Settings → Pages → Source** 选择 **GitHub Actions**（不要选 Deploy from a branch）。
4. 等 Actions 跑完，访问 `https://你的用户名.github.io`。

## 写作后台登录（PAT）

1. GitHub → Settings → Developer settings → **Fine-grained personal access tokens** → Generate new token。
2. Repository access 只勾选这个博客仓库。
3. Permissions → Contents 设为 **Read and write**（Metadata 会自动只读勾上）。
4. 生成后复制 token，访问 `https://你的用户名.github.io/admin/`，点 **Sign in with Token**，粘贴即可。
   Token 存在浏览器 localStorage，换设备/清缓存需重新粘贴。

## 日常写作流程

```
打开 /admin/ → Token 登录
→ 左侧「文章」→ 新建 / 编辑
→ Markdown 正文 + 标题、日期、标签、摘要
→ Publish（Sveltia 通过 GitHub API 提交 commit）
→ GitHub Actions 自动构建 Hugo + Tailwind
→ 前端更新
```

## 实现要点

- Tailwind v4 走 Hugo 内置的 `css.TailwindCSS`，不需要 PostCSS、不需要 `tailwind.config.js`（v4 是 CSS-first 配置）。
- `build.buildStats.enable: true` 生成 `hugo_stats.json`，并由 `module.mounts` 挂到 `assets/notwatching/`，
  再在 `main.css` 里 `@source "hugo_stats.json"` —— 因为该文件在 `.gitignore` 里，Tailwind 默认不会扫它。
- CSS partial 用 `templates.Defer` 延迟到所有页面渲染完再编译，保证 class 统计完整。
- `security.exec.allow` 放行了 `node` 与 `tailwindcss`，否则 Hugo 会拒绝执行 CLI。
- 生产构建输出带 fingerprint + SRI 的样式表；开发模式输出未压缩、可直接热更新的样式。