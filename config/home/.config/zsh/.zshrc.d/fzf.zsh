# fzf 配置
# 注意：--color 等注释不能写在双引号内，否则会作为字面量传给 fzf

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache --exclude .local --exclude target'
export FZF_COMPLETION_TRIGGER='\'

# Dracula 主题 + 键位 + 预览
export FZF_DEFAULT_OPTS="
  --multi
  --bind 'ctrl-t:top,change:top'
  --bind 'alt-e:down,alt-u:up'
  --bind 'alt-n:preview-up,alt-i:preview-down'
  --bind 'ctrl-/:toggle-preview'
  --style full
  --layout reverse
  --height 80%
  --preview 'fzf-preview.sh {}'
  --color='bg:#282A36,fg:#F8F8F2,hl:#BD93F9,fg+:#F8F8F2,bg+:#44475A'
  --color='info:#FFB86C,border:#6272A4,spinner:#50FA7B,header:#BD93F9'
  --color='pointer:#8BE9FD,marker:#FF79C6,prompt:#50FA7B,hl+:#BD93F9'
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers {} 2>/dev/null || fzf-preview.sh {}'
  --preview-window right:50%:wrap
"

export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude target"
export FZF_ALT_C_OPTS="
  --preview 'tree -C {} | head -100'
  --preview-window right:50%:wrap
"

export FZF_CTRL_R_OPTS="--no-preview"

# fzf 的 zsh 集成（Ctrl-T / Ctrl-R / Alt-C 键位 + 补全）
source <(fzf --zsh)

# 内容搜索：fif <关键字>
fif() {
  if [ "$#" -lt 1 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf \
    --preview "rg --ignore-case --pretty --context 10 '$1' {}"
}
