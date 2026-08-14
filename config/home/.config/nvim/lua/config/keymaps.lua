local map = vim.keymap.set

require("config.colemak").setup()

map("n", "tn", "<C-o>", { desc = "Jump Back" })
map("n", "ti", "<C-i>", { desc = "Jump Forward" })

map("n", "tu", "<Cmd>BufferLineCyclePrev<CR>", { desc = "buffer prev" })
map("n", "te", "<Cmd>BufferLineCycleNext<CR>", { desc = "buffer next" })
map("n", "th", "<Cmd>BufferLinePick<CR>", { desc = "pick buffer" })
map("n", "tc", "<cmd>bd<CR>", { desc = "Close Buffer" })

map("n", "sv", "<C-w>t<C-w>H", { desc = "Vertical Split Layout" })
map("n", "sh", "<C-w>t<C-w>K", { desc = "Horizontal Split Layout" })

map("n", "<leader><CR>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })
map("n", "=", "nzz", { desc = "Next Search Result" })
map("n", "-", "Nzz", { desc = "Prev Search Result" })

map({ "n", "i", "v" }, "qw", "<cmd>w<cr>", { desc = "Save File" })

map("n", "k", "i", { desc = "Insert Mode" })
map("n", "K", "I", { desc = "Insert at Line Start" })
map("n", "l", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-u>", { desc = "Undo in Insert Mode" })

map("n", "Q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "qq", "<cmd>q<CR>", { desc = "Quit Window" })
map("n", "qf", "<cmd>q!<CR>", { desc = "Force Quit Window" })
map("n", "qw", "<cmd>wq<CR>", { desc = "Save and Quit" })
map("n", "qa", "<cmd>qa<CR>", { desc = "Quit All" })
map("n", "qA", "<cmd>qa!<CR>", { desc = "Force Quit All" })
map("n", "qo", "<cmd>only<CR>", { desc = "Only Current Window" })
map("n", ";", ":", { desc = "Command Mode" })
map("n", "q;", "q:", { desc = "Command History" })
