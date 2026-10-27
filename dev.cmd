@echo off
rem 本地预览（含草稿/未来文档）。优先使用项目内隔离的 .tools 工具链。
setlocal
set "ROOT=%~dp0"
set "PATH=%ROOT%.tools\node;%ROOT%.tools\hugo;%PATH%"
set "HUGO=%ROOT%.tools\hugo\hugo.exe"
if not exist "%HUGO%" set "HUGO=hugo"
"%HUGO%" server --disableFastRender --buildDrafts --buildFuture --port 1313 %*