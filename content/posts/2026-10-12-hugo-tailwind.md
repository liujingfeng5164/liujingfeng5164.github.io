---
title: "把样式收进一次构建：Hugo 与 Tailwind v4"
date: 2026-10-12T10:30:00+08:00
draft: false
tags: ["代码", "工具"]
summary: "Hugo 现在可以直接调用 Tailwind CLI，不再需要 PostCSS，也不再需要在 CI 里手写额外的构建步骤。"
---

Hugo 从 v0.128.0 起内置了 `css.TailwindCSS`。Tailwind 升到 v4 之后，这条链路变得更短：没有 PostCSS，没有 `tailwind.config.js`，样式配置回到 CSS 本身。

## 链路长这样

```
模板里的 class
   ↓  Hugo 构建时统计
hugo_stats.json
   ↓  Tailwind CLI 只读这一份清单
public/css/main.<hash>.css
```

## 两个容易踩的点

`build.buildStats.enable` 必须是 `true`，否则 `hugo_stats.json` 是空的，最后生成的样式表会小得可疑。

`hugo_stats.json` 通常写进 `.gitignore`，而 Tailwind 会尊重 `.gitignore`。所以 CSS 里要用 `@source "hugo_stats.json"` 显式点名，否则它不会被扫描。

## 为什么值得

构建产物只有真正用到的类，几 KB 的样式表，配上 CDN 就是秒开。前端不再需要任何运行时框架，这也是这套组合能长期不腐坏的原因。