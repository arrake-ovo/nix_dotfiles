# 历史

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history

setopt EXTENDED_HISTORY      # 带时间戳
setopt HIST_IGNORE_ALL_DUPS  # 全部去重
setopt HIST_IGNORE_SPACE     # 空格开头的命令不记
setopt HIST_REDUCE_BLANKS    # 压缩连续空白
setopt HIST_VERIFY           # 历史展开先确认再执行
