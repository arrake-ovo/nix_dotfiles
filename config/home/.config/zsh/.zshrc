#!/bin/zsh
# ~/.config/zsh/.zshrc — 交互式 shell 的入口（编排器，不写具体配置）
# 加载顺序：antidote 插件 → 拆分配置 → （prompt 在 .zshrc.d/prompt.zsh 里）

# 1. antidote 插件管理器（由 nix 提供）
ANTIDOTE_ZSH=${HOME}/.nix-profile/share/antidote/antidote.zsh
if [[ -f ${ANTIDOTE_ZSH} ]]; then
  source ${ANTIDOTE_ZSH}
  # 静态 bundle 写到可写的 cache 目录（ZDOTDIR 是只读软链，无法写 .zsh_plugins.zsh）
  zstyle ':antidote:static' file ${XDG_CACHE_HOME:-$HOME/.cache}/antidote/zsh_plugins.zsh
  antidote load
else
  print -u2 "antidote 未找到：${ANTIDOTE_ZSH}（请确认 nix 包 antidote 已安装）"
fi

# 2. 循环加载拆分配置（按文件名排序）
for _rc in ${ZDOTDIR:-$HOME}/.zshrc.d/*.zsh(N); do
  source "$_rc"
done
unset _rc
