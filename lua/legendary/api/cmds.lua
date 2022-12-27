local Command = require('legendary.data.command')

local M = {}

M.cmds = vim.tbl_map(function(cmd)
  return Command:parse(cmd)
end, {
  {
    ':Legendary',
    function(opts)
      local l = require('legendary')
      local filters = require('legendary.filters')
      if not opts or not opts.args then
        l.find()
        return
      end

      if vim.trim((opts.args):lower()) == 'keymaps' then
        l.find({ filters = { filters.keymaps() } })
        return
      end

      if vim.trim((opts.args):lower()) == 'commands' then
        l.find({ filters = { filters.commands() } })
        return
      end

      if vim.trim((opts.args):lower()) == 'autocmds' then
        l.find({ filters = { filters.autocmds() } })
        return
      end

      if vim.trim((opts.args):lower()) == 'functions' then
        l.find({ filters = { filters.funcs() } })
        return
      end

      l.find()
    end,
    description = 'Find keymaps and commands with vim.ui.select()',
    opts = {
      nargs = '*',
      complete = function(arg_lead)
        if arg_lead and vim.trim(arg_lead):sub(1, 1):lower() == 'k' then
          return { 'keymaps' }
        end

        if arg_lead and vim.trim(arg_lead):sub(1, 1):lower() == 'c' then
          return { 'commands' }
        end

        if arg_lead and vim.trim(arg_lead):sub(1, 1):lower() == 'a' then
          return { 'autocmds' }
        end

        if arg_lead and vim.trim(arg_lead):sub(1, 1):lower() == 'f' then
          return { 'functions' }
        end

        return { 'keymaps', 'commands', 'autocmds', 'functions' }
      end,
    },
  },
  {
    ':LegendaryScratch',
    function(args)
      local method = vim.tbl_get(args, 'fargs', 1)
      if method ~= 'current' and method ~= 'split' and method ~= 'vsplit' and method ~= 'float' then
        method = nil
      end
      require('legendary.ui.scratchpad').open(method)
    end,
    description = 'Create a Lua scratchpad buffer to help develop commands and keymaps',
    opts = { nargs = '?' },
  },
  {
    ':LegendaryScratchToggle',
    function(args)
      local method = vim.tbl_get(args, 'fargs', 1)
      if method ~= 'current' and method ~= 'split' and method ~= 'vsplit' and method ~= 'float' then
        method = nil
      end
      require('legendary.ui.scratchpad').toggle(method)
    end,
    description = 'Toggle the legendary.nvim Lua scratchpad buffer',
    opts = { nargs = '?' },
  },
  {
    ':LegendaryEvalLine',
    function()
      if vim.bo.ft ~= 'lua' then
        vim.api.nvim_err_write("Filetype must be 'lua' to eval lua code")
        return
      end
      require('legendary.ui.scratchpad').lua_eval_current_line()
    end,
    description = 'Eval the current line as Lua',
  },
  {
    ':LegendaryEvalLines',
    function(range)
      if vim.bo.ft ~= 'lua' then
        vim.api.nvim_err_write("Filetype must be 'lua' to eval lua code")
        return
      end

      require('legendary.ui.scratchpad').lua_eval_range(range.line1, range.line2)
    end,
    description = 'Eval lines selected in visual mode as Lua',
    opts = {
      range = true,
    },
  },
  {
    ':LegendaryEvalBuf',
    require('legendary.ui.scratchpad').lua_eval_buf,
    description = 'Eval the whole buffer as Lua',
  },
  {
    ':LegendaryApi',
    function()
      vim.cmd(string.format('e %s/%s', vim.g.legendary_root_dir, 'doc/legendary-api.txt'))
      local buf_id = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_option(buf_id, 'filetype', 'help')
      vim.api.nvim_buf_set_option(buf_id, 'buftype', 'help')
      vim.api.nvim_buf_set_name(buf_id, string.format('Legendary API Docs [%s]', buf_id))
      vim.api.nvim_win_set_buf(0, buf_id)
      vim.api.nvim_buf_set_option(buf_id, 'modifiable', false)
    end,
    description = "Show Legendary's full API documentation",
  },
  {
    ':LegendaryDeprecated',
    function()
      require('legendary.deprecate').flush()
    end,
    description = 'Show legendary.nvim deprecation warning messages, if any',
  },
  {
    ':LegendaryLog',
    function()
      require('legendary.log').open_log_file()
    end,
    description = 'Open the log file for legendary.nvim',
  },
  {
    ':LegendaryFrecencyReset',
    function()
      require('legendary.api.db.wrapper').delete_db()
    end,
    description = 'Reset the frecency database',
  },
  {
    ':LegendaryLogLevel',
    function(args)
      local log_level = vim.tbl_get(args, 'fargs', 1)
      if not vim.tbl_contains(require('legendary.log').levels, log_level) then
        error(string.format('Invalid log level %s', log_level))
        return
      end
      require('legendary.config').log_level = log_level
    end,
    description = 'Convenience command to set log level',
    opts = { nargs = 1 },
  },
  {
    ':LegendaryMatrix',
    function()
      local url = 'https://matrix.to/#/%23legendary.nvim:matrix.org'
      local cmd
      if vim.fn.has('mac') == 1 then
        cmd = 'open'
      elseif vim.fn.has('unix') == 1 then
        cmd = 'xdg-open'
      elseif vim.fn.has('win32') == 1 then
        cmd = 'start'
      end

      if cmd then
        vim.fn.jobstart(string.format('%s %s', cmd, url))
      else
        vim.notify(string.format('Join the legendary.nvim Matrix channel: %s', url))
      end
    end,
    description = 'Join the legendary.nvim Matrix channel',
  },
})

M.bind = function()
  vim.tbl_map(function(command)
    command:apply()
  end, M.cmds)
end

return M
