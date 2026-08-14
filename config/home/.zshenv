#!/bin/zsh
# ~/.zshenv — 所有 zsh 会话都会读取（含脚本），放环境变量
# 注意：本文件必须位于 ~/.zshenv，不能在 ZDOTDIR 里

# XDG 目录
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}

# 把 zsh 配置重定位到 ~/.config/zsh（其余启动文件都从这里读）
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

# path/fpath 数组去重
typeset -gU path fpath

# 命令搜索路径
path=(
  $HOME/.local/bin      # pi / hermes / specify 等
  /opt/homebrew/bin     # macOS Homebrew (Apple Silicon)
  /usr/local/bin        # macOS Homebrew (Intel) 兼容
  ${ZDOTDIR}/bin        # zsh 自带脚本目录（fzf-preview.sh 等）
  $path
)

export EDITOR=vim
