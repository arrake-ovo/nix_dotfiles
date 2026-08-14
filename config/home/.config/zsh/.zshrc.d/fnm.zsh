# fnm node 版本管理（fnm 二进制由 nix 提供）
# 按目录 .nvmrc / .node-version 自动切换 node 版本；无项目配置时回落到 Nix 的 node
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
