# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#


# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
#if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
#  if (( ${+commands[curl]} )); then
#    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
#        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
#  else
#    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
#        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
#  fi
#fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
#if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
#  source ${ZIM_HOME}/zimfw.zsh init
#fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install


# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v
bindkey '^v' edit-command-line
bindkey -v
bindkey -M vicmd "k" vi-insert
bindkey -M vicmd "K" vi-insert-bol
bindkey -M vicmd "n" vi-backward-char
bindkey -M vicmd "i" vi-forward-char
bindkey -M vicmd "N" vi-beginning-of-line
bindkey -M vicmd "I" vi-end-of-line
bindkey -M vicmd "e" down-line-or-history
bindkey -M vicmd "u" up-line-or-history
bindkey -M vicmd "l" undo
#bindkey -M vicmd "-" vi-rev-repeat-search
bindkey -M vicmd "=" vi-repeat-search
bindkey -M vicmd "h" vi-forward-word-end

# fzf-tab
# 
setopt GLOB_DOTS

zstyle ':fzf-tab:*' fzf-flags \
  --bind='ctrl-t:top,change:top' \
  --bind='alt-e:down,alt-u:up' \
  --bind='alt-n:preview-up,alt-i:preview-down' \
  --layout=reverse \
  --height=80% \
  --color='bg:#282A36,fg:#F8F8F2,hl:#BD93F9,fg+:#F8F8F2,bg+:#44475A,info:#FFB86C,border:#6272A4,spinner:#50FA7B,header:#BD93F9,pointer:#8BE9FD,marker:#FF79C6,prompt:#50FA7B,hl+:#BD93F9'
#zstyle ':fzf-tab:*' node_modules

zstyle ':fzf-tab:complete:*:*'  fzf-preview 'bash fzf-preview.sh ${(Q)realpath}'


[ -f ~/.config/fzf/.fzf.zsh ] && source ~/.config/fzf/.fzf.zsh

# yazi 别名
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

export PATH="$HOME/.local/bin:$PATH"
