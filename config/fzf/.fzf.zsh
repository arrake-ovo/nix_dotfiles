# Setup fzf
# ---------
# 将 fzf 二进制路径添加到 PATH
# if [[ ! "$PATH" == */root/.fzf/bin* ]]; then
#   PATH="${PATH:+${PATH}:}/root/.fzf/bin"
# fi

# fzf 配置
# ---------

# 默认查找命令使用 fd，排除常见忽略目录
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 
--exclude node_modules 
--exclude .cache
--exclude .local
--exclude target'

# 补全触发符，设置为反斜杠
export FZF_COMPLETION_TRIGGER='\'

# 默认选项：Dracula 主题、自定义键绑定、预览等
export FZF_DEFAULT_OPTS="
  --multi
  --bind 'ctrl-t:top,change:top'          # Ctrl-t 返回顶部
  --bind 'alt-e:down,alt-u:up'            # Alt-e 向下，Alt-u 向上
  --bind 'alt-n:preview-up,alt-i:preview-down'  # Alt-n/i 预览上下滚动
  --bind 'ctrl-/:toggle-preview'          # Ctrl-/ 切换预览
  --style full                            # 全屏样式
  --layout reverse                        # 反转布局（列表从顶部开始）
  --height 80%                            # 窗口高度占 80%
  --preview 'fzf-preview.sh {}'           # 使用 fzf-preview.sh 预览
  --bind 'result:transform-list-label:if [[ -z \$FZF_QUERY ]]; then echo \" \$FZF_MATCH_COUNT items \"; else echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \"; fi'
  --bind 'focus:transform-preview-label:[[ -n {} ]] && printf \" Previewing [%s] \" {}'
  --input-label '' --header-label ' File Type '
  --bind 'focus:+transform-header:file --brief {}'
  --color='bg:#282A36,fg:#F8F8F2,hl:#BD93F9,fg+:#F8F8F2,bg+:#44475A'
  --color='info:#FFB86C,border:#6272A4,spinner:#50FA7B,header:#BD93F9'
  --color='pointer:#8BE9FD,marker:#FF79C6,prompt:#50FA7B,hl+:#BD93F9'
"

# Ctrl-t：文件查找，带预览
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers {} 2>/dev/null || fzf-preview.sh {}'
  --preview-window right:50%:wrap
"

# Alt-c：目录切换
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude target"
export FZF_ALT_C_OPTS="
  --preview 'tree -C {} | head -100'
  --preview-window right:50%:wrap
  --bind 'focus:transform-header:'''
"

# Ctrl-r：历史搜索
export FZF_CTRL_R_OPTS="
  --no-preview
  --bind 'focus:transform-header:'''
"

# 绑定 Ctrl-n 到 fzf 的历史搜索 widget
bindkey '^n' fzf-history-widget

# 启用 fzf 的 zsh 补全和键绑定
source <(fzf --zsh)

# 自定义函数：使用 ripgrep 进行内容搜索
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf \
    --preview "rg --ignore-case --pretty --context 10 '$1' {}"
}
