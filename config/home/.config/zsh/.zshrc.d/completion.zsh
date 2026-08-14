# 补全样式（compinit 初始化在 .zshrc 里手动完成）

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
# fzf-tab 要求关闭原生菜单，否则会抢走 Tab 补全（fzf-tab 无法接管）
zstyle ':completion:*' menu no
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' rehash true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' cache-path ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache
zstyle ':completion:*' use-cache on
