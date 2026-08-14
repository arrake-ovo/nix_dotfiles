# 别名与函数

# —— 常用别名 ——
alias ..='cd ..'
alias ...='cd ../..'
alias l='ls -la'
alias ll='ls -lh'
alias g='git'

# mkcd：建目录并进入
mkcd() { mkdir -p "$1" && cd "$1"; }

# yazi：退出后 cd 到 yazi 所在目录
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
