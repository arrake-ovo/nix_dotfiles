# fzf-tab：fzf 风格的补全菜单

zstyle ':fzf-tab:*' fzf-flags \
  --bind='ctrl-t:top,change:top' \
  --bind='alt-e:down,alt-u:up' \
  --bind='alt-n:preview-up,alt-i:preview-down' \
  --layout=reverse \
  --height=80% \
  --color='bg:#282A36,fg:#F8F8F2,hl:#BD93F9,fg+:#F8F8F2,bg+:#44475A,info:#FFB86C,border:#6272A4,spinner:#50FA7B,header:#BD93F9,pointer:#8BE9FD,marker:#FF79C6,prompt:#50FA7B,hl+:#BD93F9'

zstyle ':fzf-tab:complete:*:*' fzf-preview 'bash fzf-preview.sh ${(Q)realpath}'
