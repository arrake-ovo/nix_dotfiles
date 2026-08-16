# 输入法自动切换：进入 TUI 程序时切英文，退出恢复原输入法
# 依赖 macism（nixpkgs-unstable，见 modules/home/programs/terminal/tools/ime-switch）

# 英文输入源 ID（ABC 键盘布局）。可用 `macism` 查看当前、`macism <id>` 切换。
_IME_ENGLISH_ID="${IME_ENGLISH_ID:-com.apple.keylayout.ABC}"

# 用法：ime-e <命令> [参数...]
# 例：ime-e yazi；ime-e lazygit
# 注意：只适合「纯导航、不输入中文」的 TUI。编辑器（nvim）不要用它，
#       会挡住插入模式的中文输入，nvim 请用 Squirrel 的 vim_mode 或 im-select.nvim。
ime-e() {
  # macism 未安装时直接运行原命令，不报错
  if ! command -v macism >/dev/null 2>&1; then
    "$@"
    return $?
  fi

  local prev ret
  prev="$(macism 2>/dev/null)"
  macism "$_IME_ENGLISH_ID" 2>/dev/null
  "$@"
  ret=$?
  [[ -n "$prev" ]] && macism "$prev" 2>/dev/null
  return $ret
}
