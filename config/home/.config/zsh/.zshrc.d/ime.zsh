# 输入法自动切换：进入「纯导航 TUI」时切英文，退出后恢复原输入法。
# 依赖 macism（见 modules/darwin/programs/inputmethods/ime-switch）。
# 本文件由 ime-switch 模块按需软链到 ~/.config/zsh/.zshrc.d/，未启用该模块时不存在。

# 英文输入源 ID（ABC 键盘布局）。可用 `macism` 查看当前、`macism <id>` 切换。
_IME_ENGLISH_ID="${IME_ENGLISH_ID:-com.apple.keylayout.ABC}"

# 需要「全程英文」的纯导航 TUI 命令（按命令行第一个词精确匹配）。
# 只放导航/浏览类程序；不要放 nvim/vim——它们要按模式切中英文，放进来会挡住插入模式中文。
_IME_TUI_APPS=(
  yazi
  y          # y() 是 yazi 的包装（退出后 cd 到所在目录）
  # lazygit  # 需要时取消注释
)

# 切英文前记录的原输入源；空 = 未处于切英文状态
_IME_PREV_SOURCE=

_ime_is_tui() {
  local cmd="$1" app
  for app in $_IME_TUI_APPS; do
    [[ "$cmd" == "$app" ]] && return 0
  done
  return 1
}

_ime_preexec() {
  command -v macism >/dev/null 2>&1 || return
  local cmd="${1%% *}"
  _ime_is_tui "$cmd" || return
  _IME_PREV_SOURCE="$(macism 2>/dev/null)"
  [[ -n "$_IME_PREV_SOURCE" ]] && macism "$_IME_ENGLISH_ID" 2>/dev/null
}

_ime_precmd() {
  [[ -n "$_IME_PREV_SOURCE" ]] || return
  macism "$_IME_PREV_SOURCE" 2>/dev/null
  _IME_PREV_SOURCE=
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _ime_preexec
add-zsh-hook precmd _ime_precmd
