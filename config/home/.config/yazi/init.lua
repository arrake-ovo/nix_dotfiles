require("yaziline"):setup {
	separator_style = "curvy",
	select_symbol = "",
	yank_symbol = "󰆐",
	filename_max_length = 24, -- trim when filename > 24
	filename_trim_length = 6 -- trim 6 chars from both ends
}

require("starship"):setup {
	config_file = "~/.config/yazi/starship.toml",
}

-- 配置说明用户的用户名和组名
Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ui.Line {}
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		ui.Span(":"),
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		ui.Span(" "),
	}
end, 500, Status.RIGHT)

-- You can configure your bookmarks by lua language
local bookmarks = {}

local path_sep = package.config:sub(1, 1)
local home_path = ya.target_family() == "windows" and os.getenv("USERPROFILE") or os.getenv("HOME")
if ya.target_family() == "windows" then
  table.insert(bookmarks, {
    tag = "Scoop Local",

    path = (os.getenv("SCOOP") or home_path .. "\\scoop") .. "\\",
    key = "p"
  })
  table.insert(bookmarks, {
    tag = "Scoop Global",
    path = (os.getenv("SCOOP_GLOBAL") or "C:\\ProgramData\\scoop") .. "\\",
    key = "P"
  })
end
table.insert(bookmarks, {
  tag = "Desktop",
  path = home_path .. path_sep .. "Desktop" .. path_sep,
  key = "d"
})

require("yamb"):setup {
  -- Optional, the path ending with path seperator represents folder.
  bookmarks = bookmarks,
  -- Optional, recieve notification everytime you jump.
  jump_notify = true,
  -- Optional, the cli of fzf.
  cli = "fzf",
  -- Optional, a string used for randomly generating keys, where the preceding characters have higher priority.
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  -- Optional, the path of bookmarks
  path = (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark") or
        (os.getenv("HOME") .. "/.config/yazi/bookmark"),
}


-- 自定义 keyjump的内置快捷键

require("keyjump"):setup({
	icon_fg = "#fda1a1",
	first_key_fg = "#df6249",
    go_table = { -- `g` to open go menu(global mode)
		{ on = { "h" },       run = "cd ~",             desc = "Go to home" },
		{ on = { "c" },       run = "cd ~/.config",     desc = "Go to config" },
		-- { on = { "u" },       run = "cd /media/UUI/",     desc = "Go to Mobile disk" },
	}
})



-- 确保 th.git 表存在
th.git = th.git or {}

-- 自定义 Git 状态符号的样式（基于 Dracula 主题）
th.git.modified = ui.Style():fg("#BD93F9") -- 紫色 (Modified)
th.git.added = ui.Style():fg("#50FA7B") -- 绿色 (Added)
th.git.untracked = ui.Style():fg("#FF79C6") -- 粉色 (Untracked)
th.git.ignored = ui.Style():fg("#6272A4") -- 灰蓝色 (Ignored)
th.git.deleted = ui.Style():fg("#FF5555") -- 红色 (Deleted)
th.git.updated = ui.Style():fg("#8BE9FD") -- 青色 (Updated)

-- 自定义 Git 状态符号的文本（使用纯字母）
th.git.modified_sign = "M" -- Modified
th.git.added_sign = "A" -- Added
th.git.untracked_sign = "U" -- Untracked
th.git.ignored_sign = "I" -- Ignored
th.git.deleted_sign = "D" -- Deleted
th.git.updated_sign = "R" -- Updated (R for Refreshed/Updated)

require("git"):setup {}

require("githead"):setup {
}

