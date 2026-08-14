# 行为开关（setopt）

# —— 目录 ——
setopt AUTO_CD              # 目录名直接 cd
setopt AUTO_PUSHD           # cd 自动压栈
setopt PUSHD_IGNORE_DUPS    # 不重复压栈
setopt PUSHD_MINUS          # 栈号与 cd - 语义一致

# —— 补全 ——
setopt AUTO_LIST            # 歧义补全自动列出
setopt AUTO_PARAM_SLASH     # 补全目录自动加 /
setopt ALWAYS_TO_END        # 补全后光标移到词尾
setopt COMPLETE_IN_WORD     # 从光标处补全

# —— 通配 ——
setopt EXTENDED_GLOB        # 增强通配符
setopt GLOB_DOTS            # 通配含隐藏文件（fzf-tab 需要）

# —— 其他 ——
setopt INTERACTIVE_COMMENTS # 交互式允许 # 注释
setopt NO_BEEP              # 不响铃
setopt NO_FLOW_CONTROL      # 释放 Ctrl-S/Ctrl-Q
setopt NOTIFY               # 后台任务结束立即报告
setopt PROMPT_SUBST         # prompt 允许命令替换
setopt SHARE_HISTORY        # 会话间共享历史

# WORDCHARS 去掉 /，补全时按 / 分段
WORDCHARS=${WORDCHARS//[\/]}
