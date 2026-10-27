@echo off
rem 生产构建（与 GitHub Actions 参数一致），产物在 public\
setlocal
set "ROOT=%~dp0"
set "PATH=%ROOT%.tools\node;%ROOT%.tools\hugo;%PATH%"
set "HUGO=%ROOT%.tools\hugo\hugo.exe"
if not exist "%HUGO%" set "HUGO=hugo"
"%HUGO%" --gc --minify %*