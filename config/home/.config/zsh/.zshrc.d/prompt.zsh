# 自写 prompt：复刻 zim 的 sorin 主题，去掉 zim 依赖
# 左 PS1 = 目录 + vi 模式指示；右 RPS1 = git 状态 + 退出码 + venv

# —— 路径缩写（fish 风格：~/n/nix_dotfiles）——
prompt_pwd() {
  local -a dirs
  local pwd=${PWD/#$HOME/'~'}
  if [[ $pwd == '~' ]]; then print -n '~'; return; fi
  dirs=("${(@s:/:)pwd}")
  if (( ${#dirs} > 2 )); then
    local i
    for (( i = 2; i <= ${#dirs} - 1; i++ )); do
      dirs[$i]=${dirs[$i][1]}
    done
  fi
  print -n "${(j:/:)dirs}"
}

# —— vi 模式指示（normal: ❮❮❮ / insert: ❯❯❯）——
_prompt_vimode() {
  case ${KEYMAP} in
    vicmd) print -n ' %F{2}❮%F{3}❮%F{1}❮' ;;
    *)     print -n ' %F{1}❯%F{3}❯%F{2}❯' ;;
  esac
}
# vi 模式切换时重绘 prompt
_prompt_keymap_select() { zle reset-prompt; zle -R }
zle -N zle-keymap-select _prompt_keymap_select

# —— git 状态（zsh 内置 vcs_info，替代 zim 的 git-info）——
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats ' %F{2}%b%f%c%u'
zstyle ':vcs_info:git*' actionformats ' %F{2}%b%f:%F{1}%a%f%c%u'
add-zsh-hook precmd vcs_info

setopt promptsubst

PS1='${SSH_TTY:+"%B%F{1}%n%f@%b%F{3}%m "}%B%F{4}$(prompt_pwd)%(!. %F{1}#.)$(_prompt_vimode)%f%b '
RPS1='${VIRTUAL_ENV:+"%F{3}(${VIRTUAL_ENV:t})"}%(?:: %F{1}✘ %?)%B${VIM:+" %F{6}V"}${vcs_info_msg_0_}%f%b'
