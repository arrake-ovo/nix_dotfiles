local settings = {
  -- Flip this to false when you want Lazy.nvim to skip loading Copilot entirely.
  enabled = true,
}

local function copy_to_clipboard(value)
  pcall(vim.fn.setreg, "+", value)
  pcall(vim.fn.setreg, "*", value)
end

local function open_signin_popup(code, url)
  local lines = {
    " [Copilot] ",
    "",
    " First copy your one-time code: ",
    "   " .. code .. " ",
    " In your browser, visit: ",
    "   " .. url .. " ",
    "",
    " The URL has also been sent to vim.notify(). ",
    " This popup will close automatically once auth finishes. ",
  }

  local height = #lines
  local width = math.max(unpack(vim.tbl_map(function(line)
    return #line
  end, lines)))

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    style = "minimal",
    border = "single",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    height = height,
    width = width,
  })

  vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = winid })

  return function()
    pcall(vim.api.nvim_win_close, winid, true)
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end
end

local function with_copilot_client(callback)
  local client = require("copilot.client")
  local client_config = require("copilot.client.config")

  local lsp_client = client.get()
  if lsp_client and client.initialized then
    callback(lsp_client)
    return
  end

  client.ensure_client_started()

  lsp_client = client.get()
  if lsp_client and client.initialized then
    callback(lsp_client)
    return
  end

  vim.notify("[Copilot] Starting Copilot client...", vim.log.levels.INFO)

  local fired = false
  client_config.add_callback(function(initialized_client)
    if fired then return end
    fired = true
    vim.schedule(function()
      callback(initialized_client)
    end)
  end)
end

local function patch_copilot_auth()
  local api = require("copilot.api")
  local auth = require("copilot.auth")

  if auth._arrake_patched_signin == true then return end

  auth.signin = function()
    with_copilot_client(function(lsp_client)
      coroutine.wrap(function()
        local status_err, status = api.check_status(lsp_client)
        if status_err then
          vim.notify("[Copilot] " .. tostring(status_err), vim.log.levels.ERROR)
          return
        end

        if status and status.user then
          vim.notify("[Copilot] Authenticated as GitHub user: " .. status.user, vim.log.levels.INFO)
          return
        end

        local sign_in_err, sign_in = api.sign_in_initiate(lsp_client)
        if sign_in_err then
          vim.notify("[Copilot] " .. tostring(sign_in_err), vim.log.levels.ERROR)
          return
        end

        if not sign_in or not sign_in.verificationUri or not sign_in.userCode then
          vim.notify("[Copilot] Failed to get Copilot verification URL.", vim.log.levels.ERROR)
          return
        end

        copy_to_clipboard(sign_in.userCode)

        vim.notify(
          string.format(
            "Copilot code copied: %s\nOpen this URL if the browser does not launch:\n%s",
            sign_in.userCode,
            sign_in.verificationUri
          ),
          vim.log.levels.INFO,
          { title = "Copilot Auth", timeout = 15000 }
        )

        if vim.ui and vim.ui.open then
          local ok, open_err = pcall(vim.ui.open, sign_in.verificationUri)
          if not ok then
            vim.notify(
              "[Copilot] Failed to open browser automatically: " .. tostring(open_err),
              vim.log.levels.WARN
            )
          end
        end

        local close_popup = open_signin_popup(sign_in.userCode, sign_in.verificationUri)
        local confirm_err, confirm = api.sign_in_confirm(lsp_client, { userCode = sign_in.userCode })
        close_popup()

        if confirm_err then
          vim.notify("[Copilot] " .. tostring(confirm_err), vim.log.levels.ERROR)
          return
        end

        if not confirm or string.lower(confirm.status or "") ~= "ok" then
          local reason = confirm and confirm.error and confirm.error.message or "authentication failed"
          vim.notify("[Copilot] Authentication failure: " .. reason, vim.log.levels.ERROR)
          return
        end

        vim.notify("[Copilot] Authenticated as GitHub user: " .. confirm.user, vim.log.levels.INFO)
      end)()
    end)
  end

  auth._arrake_patched_signin = true
end

return {
  {
    "zbirenbaum/copilot.lua",
    optional = true,
    enabled = settings.enabled,
    opts = function(_, opts)
      opts = opts or {}
      opts.panel = opts.panel or {}
      opts.suggestion = opts.suggestion or {}
      return opts
    end,
    config = function(_, opts)
      require("copilot").setup(opts)
      patch_copilot_auth()

      vim.schedule(function()
        local ok, client = pcall(require, "copilot.client")
        if not ok then return end
        client.buf_attach(false, vim.api.nvim_get_current_buf())
      end)

      vim.api.nvim_create_user_command("CopilotAuthBrowser", function()
        require("copilot.auth").signin()
      end, {
        desc = "Start GitHub Copilot auth and open the verification URL in a browser",
      })
    end,
  },
}
