local home = os.getenv 'HOME'
local shell = 'com.superlogical.terminal.shell'
local terminal_block = 'com.superlogical.terminal'
-- The Rex server runs with a minimal PATH, without Homebrew or ~/.local/bin.
local path = home .. '/.local/bin:/opt/homebrew/bin:' .. os.getenv 'PATH'
-- It does not have its own rex command on that PATH either.
local rex_command = home .. '/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex'

-- Rex API calls return a result or nil and an error message.
local function unwrap(result, err)
  if err ~= nil then
    error(err, 0)
  end
  return result
end

local function call(method, args)
  return unwrap(rex.call(method, args))
end

-- Calls a session method on the action's own session.
local function in_session(method, args)
  return unwrap(rex.session[method](args))
end

local function run(argv, opts)
  opts = opts or {}
  opts.env = { PATH = path }
  return unwrap(rex.exec(argv, opts))
end

local function terminal(cwd, command)
  return rex.layout.block { flavor = shell, options = { cwd = cwd, command = command } }
end

-- A floating layer running a command, closed when the command exits. Focus
-- goes back to the pane the key was pressed in, which Rex doesn't do itself.
-- Returns the id of the new layer.
local function popup(options)
  local layer = in_session('new_layer', {
    bounds = options.bounds,
    focus = true,
    layout = rex.layout.block {
      flavor = shell,
      label = options.label,
      options = {
        cwd = options.cwd,
        command = options.command,
        exit = { on_completion = true, quick_exit_threshold_ms = 0 },
      },
    },
  })
  if options.ctx.block_id then
    unwrap(rex.exec.start({
      rex_command,
      'do',
      '-s',
      options.ctx.session_id,
      home .. '/.config/rex/restore-focus.lua',
      'popup=' .. layer.block_ids[1],
      'origin=' .. options.ctx.block_id,
    }, { detach = true }))
  end
  return layer.layer_id
end

-- The program in the foreground of the focused pane, if Rex can tell.
local function foreground(ctx)
  local process = rex.block.call(terminal_block, 'process', { block_id = ctx.block_id })
  return process and process.foreground
end

local function pane_dir(ctx)
  local program = foreground(ctx)
  if not (program and program.cwd) then
    error("Can't tell this pane's directory", 0)
  end
  return program.cwd
end

local function repo_dir(ctx)
  local dir = pane_dir(ctx)
  if not run({ 'git', 'rev-parse', '--is-inside-work-tree' }, { cwd = dir }).ok then
    error('Not in a git repository', 0)
  end
  return dir
end

-- Runs cc and keeps a fish shell open once it exits. The prompt is passed as
-- an argument, so quotes, newlines and '!' reach cc without any shell quoting.
-- fish -c has no job control, which would keep cc in fish's own process group.
-- Rex would then see fish as the foreground program and not recognise the agent.
local function agent_command(prompt)
  return { 'fish', '-ic', 'status job-control full; cc $argv; exec fish', '--', prompt }
end

-- Rex has no focus history, so remember what these actions switch between: the
-- sessions, and the tabs of each session. A switch made another way, like
-- clicking, is noticed the next time one of these actions runs.
local history_file = home .. '/.local/state/rex-history'

-- Read from disk once and then kept in memory, since the config keeps running
-- between key presses. The file lets the history outlive a server restart.
local history

local function read_history()
  local entries = {}
  local file = io.open(history_file)
  if not file then
    return entries
  end
  for line in file:lines() do
    local scope, current, previous = line:match '^(%S+) (%S+) ?(%S*)$'
    if scope then
      entries[scope] = { current = current, previous = previous ~= '' and previous or nil }
    end
  end
  file:close()
  return entries
end

-- Keeping the history on disk is optional, so a failed write never stops a switch.
local function write_history()
  local file = io.open(history_file, 'w')
  if not file then
    return
  end
  for scope, entry in pairs(history) do
    file:write(scope, ' ', entry.current, ' ', entry.previous or '', '\n')
  end
  file:close()
end

-- Visits the items in order, each one becoming the scope's current item and the
-- one before it the previous. Returns the scope's current and previous item.
local function remember(scope, ...)
  history = history or read_history()
  local entry = history[scope] or {}
  local changed = false
  for index = 1, select('#', ...) do
    local item = select(index, ...)
    if entry.current ~= item then
      entry = { current = item, previous = entry.current }
      changed = true
    end
  end
  if changed then
    history[scope] = entry
    write_history()
  end
  return entry
end

local function select_session(ctx, session_id)
  rex.client.queue('session.select', { session_id = session_id })
  remember('sessions', ctx.session_id, session_id)
end

local function find_session(label)
  for _, session in ipairs(call('session.list', {}).sessions or {}) do
    if session.label == label then
      return session.session_id
    end
  end
end

-- Sorts the sessions in the sidebar alphabetically by moving each one to the
-- end in order. Moving a session needs the connection attached to it.
local function sort_sessions()
  local sessions = call('session.list', {}).sessions
  table.sort(sessions, function(a, b)
    return a.label:lower() < b.label:lower()
  end)
  for _, session in ipairs(sessions) do
    call('session.attach', { session_id = session.session_id })
    call('session.move', { session_id = session.session_id })
  end
end

-- A new session has one window running cc.
local function create_session(label, dir, prompt)
  local session_id = call('session.create', {
    label = label,
    initial_windows = {
      { layout = terminal(dir, agent_command(prompt)) },
    },
  }).session_id
  sort_sessions()
  return session_id
end

-- Whether an app triggered the action. Otherwise it came from elsewhere, such
-- as the CLI, whose connection is gone by the time the picker needs it.
local function from_app(ctx)
  if not ctx.client_id then
    return false
  end
  for _, client in ipairs(call('client.list', { kinds = { 'app' } }).clients) do
    if client.client_id == ctx.client_id then
      return true
    end
  end
  return false
end

-- Worktrees made by the `session` skill are named <repo>-w-<name>. They show
-- up as "<repo> <branch icon> <name>". The `session_label` action exposes this
-- mapping, so scripts like worktree-remove.ts never duplicate it.
local branch_icon = '\243\176\152\172' -- nf-md-source_branch, U+F062C

local function expand_dir(dir)
  return (dir:gsub('^~/', home .. '/'):gsub('/$', ''))
end

local function session_label(dir)
  local folder = expand_dir(dir):match '[^/]+$'
  local repo, name = folder:match '^(.-)%-w%-(.+)$'
  if not repo then
    return folder
  end
  -- "[" sorts before letters, so a repo's review sessions group together.
  local label = name:gsub('^review%-', '[review] ')
  return repo .. ' ' .. branch_icon .. ' ' .. label
end

rex.action {
  name = 'session_label',
  title = 'Show Session Label for Project',
  category = 'Projects',
  args = { dir = 'string' },
  run = function(_, args)
    return { label = session_label(args.dir) }
  end,
}

local function open_project(ctx, args)
  local dir = expand_dir(args.dir)
  local label = session_label(dir)
  local session_id = find_session(label) or create_session(label, dir, args.prompt)

  if args.detach then
    return { session = label }
  end
  select_session(ctx, session_id)
end

-- Without a dir it opens the fzf project picker in a floating layer, which
-- runs this action again with the picked dir.
rex.action {
  name = 'sessionizer',
  title = 'Open Project…',
  category = 'Projects',
  keywords = 'project session sessionizer switch',
  args = { dir = 'string?', detach = 'boolean?', prompt = 'string?' },
  run = function(ctx, args)
    if args.dir then
      return open_project(ctx, args)
    end
    -- The picker runs this action again through the CLI, which only finds the
    -- app on its own when exactly one is connected, so name the app that asked.
    local script = home .. '/.local/bin/rex-sessionizer'
    local command = from_app(ctx) and { '/usr/bin/env', 'REX_CLIENT=' .. ctx.client_id, script } or { script }
    popup { label = 'Projects', command = command, bounds = { 0, 0, 1, 1 }, ctx = ctx }
  end,
}

-- Rex's own tab actions count tabs across all sessions, tmux counts them per
-- session, so these work on the windows of the current session only. The
-- current window is the one holding the pane the key was pressed in.
local function session_windows(ctx)
  local windows = in_session('view', {}).windows
  for index, window in ipairs(windows) do
    if window.focused_block_id == ctx.block_id then
      return windows, index
    end
  end
  return windows, 1
end

-- The app tracks which tab it shows itself, so ask it to switch.
local function focus_window(ctx, current, window)
  if window then
    rex.client.queue('session.select', { session_id = ctx.session_id, window_id = window.window_id })
    remember(ctx.session_id, current.window_id, window.window_id)
  end
end

rex.action {
  name = 'tab_goto',
  title = 'Go to Tab in Session',
  category = 'Tabs',
  args = { index = 'integer' },
  run = function(ctx, args)
    local windows, active = session_windows(ctx)
    focus_window(ctx, windows[active], windows[args.index])
  end,
}

rex.action {
  name = 'last_tab',
  title = 'Go to Last Tab in Session',
  category = 'Tabs',
  run = function(ctx)
    local windows, active = session_windows(ctx)
    local current = windows[active]
    local previous = remember(ctx.session_id, current.window_id).previous
    for _, window in ipairs(windows) do
      if window.window_id == previous then
        return focus_window(ctx, current, window)
      end
    end
  end,
}

rex.action {
  name = 'sort_sessions',
  title = 'Sort Sessions',
  category = 'Sessions',
  run = sort_sessions,
}

rex.action {
  name = 'expand_sessions',
  title = 'Expand All Sessions',
  category = 'Sessions',
  run = function()
    for _, session in ipairs(call('session.list', {}).sessions) do
      rex.client.queue('session.expand', { session_id = session.session_id })
    end
  end,
}

-- Session IDs start with their creation time, so the highest one is the newest.
rex.action {
  name = 'newest_session',
  title = 'Go to Newest Session',
  category = 'Sessions',
  run = function(ctx)
    local newest
    for _, session in ipairs(call('session.list', {}).sessions) do
      if not newest or session.session_id > newest.session_id then
        newest = session
      end
    end
    if newest.session_id ~= ctx.session_id then
      select_session(ctx, newest.session_id)
    end
  end,
}

-- For built-in actions that switch somewhere unknown: note where you are first.
-- Looking up the current tab costs a call to the server, so it is only done for
-- actions that change tabs.
rex.action {
  name = 'track_switch',
  title = 'Run Action and Remember Where You Were',
  category = 'Sessions',
  args = { action = 'string', tabs = 'boolean?' },
  run = function(ctx, args)
    local scope, current = 'sessions', ctx.session_id
    if args.tabs then
      local windows, active = session_windows(ctx)
      scope, current = ctx.session_id, windows[active].window_id
    end
    rex.client.queue(args.action)
    remember(scope, current)
  end,
}

rex.action {
  name = 'last_session',
  title = 'Go to Last Session',
  category = 'Sessions',
  run = function(ctx)
    local previous = remember('sessions', ctx.session_id).previous
    if previous then
      select_session(ctx, previous)
    end
  end,
}

-- Splits the pane into a 2x2 grid and focuses the top-left one.
rex.action {
  name = 'grid',
  title = 'Split Pane into Grid',
  category = 'Panes',
  run = function()
    for _, action in ipairs { 'pane.split.right', 'pane.split.down', 'pane.focus.left', 'pane.split.down', 'pane.focus.up' } do
      rex.client.queue(action)
    end
  end,
}

-- Like tmux's kill-pane: closing the only pane of a tab closes the tab.
rex.action {
  name = 'close_pane',
  title = 'Close Pane or Tab',
  category = 'Panes',
  run = function(ctx)
    local windows, active = session_windows(ctx)
    local layers = windows[active].layers
    local only_pane = #layers == 1 and layers[1].layout.block_id
    rex.client.queue(only_pane and 'client.tab.close' or 'pane.close')
  end,
}

-- The splits from the layout's root down to a block, each with the side
-- the block is on.
local function path_to(node, block_id)
  if node.block_id then
    return node.block_id == block_id and {} or nil
  end
  for _, side in ipairs { 'before', 'after' } do
    local path = path_to(node.split[side], block_id)
    if path then
      table.insert(path, 1, { node = node, side = side })
      return path
    end
  end
end

local function first_block(node)
  return node.block_id or first_block(node.split.before)
end

-- Cycles the pane's width through 1/3, 1/2 and 2/3 of the window by moving
-- the closest left/right border around it.
rex.action {
  name = 'cycle_width',
  title = 'Cycle Pane Width',
  category = 'Panes',
  run = function(ctx)
    local windows, active = session_windows(ctx)
    local splits = path_to(windows[active].layers[1].layout, ctx.block_id) or {}
    local last = splits[#splits]
    for index = #splits, 1, -1 do
      local node, side = splits[index].node, splits[index].side
      if node.split.direction == 'horizontal' then
        local share = last.node.split[last.side].rect[3]
        local target = share < 0.4 and 0.5 or share < 0.6 and 0.67 or 0.33
        local side_width = target / node.rect[3]
        in_session('resize_pane', {
          direction = 'horizontal',
          before_block_id = first_block(node.split.before),
          after_block_id = first_block(node.split.after),
          ratio = math.min(0.95, math.max(0.05, side == 'before' and side_width or 1 - side_width)),
        })
        return
      end
    end
  end,
}

-- How many panes sit side by side (or stacked, for "vertical") in a node.
-- A split across the other direction counts as its widest side.
local function panes_along(node, direction)
  if node.block_id then
    return 1
  end
  local before, after = panes_along(node.split.before, direction), panes_along(node.split.after, direction)
  return node.split.direction == direction and before + after or math.max(before, after)
end

-- Gives every pane in the window the same width and height, like tmux's
-- select-layout tiled: each split gets space in proportion to the panes on its sides.
rex.action {
  name = 'equalize',
  title = 'Equalize Pane Sizes',
  category = 'Panes',
  run = function(ctx)
    local windows, active = session_windows(ctx)
    local function equalize(node)
      if node.block_id then
        return
      end
      local direction = node.split.direction
      local before, after = panes_along(node.split.before, direction), panes_along(node.split.after, direction)
      in_session('resize_pane', {
        direction = direction,
        before_block_id = first_block(node.split.before),
        after_block_id = first_block(node.split.after),
        ratio = before / (before + after),
      })
      equalize(node.split.before)
      equalize(node.split.after)
    end
    equalize(windows[active].layers[1].layout)
  end,
}

-- Opens the current branch's PR in the browser, or else the repository.
rex.action {
  name = 'open_repo',
  title = 'Open Repository in Browser',
  category = 'Git',
  run = function(ctx)
    local dir = repo_dir(ctx)
    if run({ 'gh', 'pr', 'view', '--web' }, { cwd = dir }).ok then
      return
    end
    if not run({ 'gh', 'browse' }, { cwd = dir }).ok then
      error('No remote origin found', 0)
    end
  end,
}

rex.action {
  name = 'copy_path',
  title = 'Copy Pane Directory',
  category = 'Panes',
  run = function(ctx)
    local dir = pane_dir(ctx)
    if dir:sub(1, #home) == home then
      dir = '~' .. dir:sub(#home + 1)
    end
    run({ 'pbcopy' }, { stdin = dir })
  end,
}

rex.action {
  name = 'copy_session_id',
  title = 'Copy Session ID',
  category = 'Sessions',
  run = function(ctx)
    run({ 'pbcopy' }, { stdin = ctx.session_id })
  end,
}

rex.action {
  name = 'reveal_in_finder',
  title = 'Open Pane Directory in Finder',
  category = 'Panes',
  run = function(ctx)
    run { 'open', pane_dir(ctx) }
  end,
}

-- The layers this config opened for lazygit. A popup is recognised by its id,
-- so the block keeps the name Rex gives it.
local lazygit_layers = {}

-- The lazygit popup of this window, if one is open.
local function lazygit_layer(ctx)
  local windows, active = session_windows(ctx)
  for _, layer in ipairs(windows[active].layers) do
    if lazygit_layers[layer.layer_id] then
      return layer
    end
  end
end

-- Opens lazygit in a popup. Pressing the key again minimizes the popup and
-- keeps lazygit running, pressing it once more brings it back. Quitting
-- lazygit closes the popup.
rex.action {
  name = 'lazygit',
  title = 'Lazygit',
  category = 'Git',
  keywords = 'git lazygit',
  run = function(ctx)
    local layer = lazygit_layer(ctx)
    if not layer then
      local layer_id = popup {
        command = { '/opt/homebrew/bin/fish', '-c', 'status job-control full; lazygit' },
        bounds = { 0.05, 0.05, 0.9, 0.9 },
        cwd = pane_dir(ctx),
        ctx = ctx,
      }
      lazygit_layers[layer_id] = true
      return
    end
    local restoring = layer.state == 'minimized'
    in_session('set_layer_state', {
      layer_id = layer.layer_id,
      state = restoring and 'normal' or 'minimized',
      focus = restoring,
    })
  end,
}

-- Opens a tab running a fish command and keeps a fish shell open once it
-- exits. Job control is on so Rex sees the command as the foreground program.
local function open_tab_running(ctx, dir, fish_command)
  local windows, active = session_windows(ctx)
  local window = in_session('new_window', {
    layout = terminal(dir, { 'fish', '-ic', 'status job-control full; ' .. fish_command .. '; exec fish' }),
  })
  focus_window(ctx, windows[active], window)
end

rex.action {
  name = 'neovim',
  title = 'Open Neovim in New Tab',
  category = 'Tabs',
  keywords = 'nvim vim editor',
  run = function(ctx)
    open_tab_running(ctx, pane_dir(ctx), 'nvim')
  end,
}

rex.action {
  name = 'update_tools',
  title = 'Run update-tools in New Tab',
  category = 'Tabs',
  keywords = 'update tools brew drift',
  run = function(ctx)
    open_tab_running(ctx, pane_dir(ctx), 'update-tools')
  end,
}

-- Install only acts on an update Rex already knows about, so wait for the
-- check to finish before asking for the install.
rex.action {
  name = 'update_rex',
  title = 'Check for Rex Update, Install and Relaunch',
  category = 'App',
  keywords = 'update rex app check download install relaunch upgrade',
  run = function(ctx)
    if not from_app(ctx) then
      error('Run this from the Rex app, which is the one that updates', 0)
    end
    local check = call('client.perform', { client_id = ctx.client_id, action = 'client.update.check', timeout_ms = 30000 })
    if check.result.result == 'up_to_date' then
      return
    end
    rex.client.queue 'client.update.install'
  end,
}

local function trim(text)
  return (text:gsub('%s+$', ''))
end

-- Shows the changes live next to an agent working in the pane. Only the CLI
-- can split with a command, the built-in split action can't.
local function watch_diff_in_split(ctx, dir, target)
  local argv = { rex_command, 'split', '-s', ctx.session_id, '-b', ctx.block_id, '--split=right', '-c', dir, '--', 'hunk', 'diff', '--watch' }
  table.insert(argv, target)
  if not run(argv).ok then
    error("Couldn't open the diff split", 0)
  end
end

rex.action {
  name = 'diff',
  title = 'Watch Diff in Split',
  category = 'Git',
  keywords = 'git diff hunk watch',
  run = function(ctx)
    watch_diff_in_split(ctx, repo_dir(ctx))
  end,
}

-- Diffs the working tree against where the branch left the PR's base branch,
-- so it shows everything the PR changes, committed or not.
rex.action {
  name = 'pr_diff',
  title = 'Watch Diff of Pull Request in Split',
  category = 'Git',
  keywords = 'git diff hunk watch pr pull request',
  run = function(ctx)
    local dir = repo_dir(ctx)
    local base = run({ 'gh', 'pr', 'view', '--json', 'baseRefName', '--jq', '.baseRefName' }, { cwd = dir })
    if not base.ok then
      error('No pull request for this branch', 0)
    end
    local fork_point = run({ 'git', 'merge-base', 'HEAD', 'origin/' .. trim(base.stdout) }, { cwd = dir })
    if not fork_point.ok then
      error("Can't find where the branch left the base branch", 0)
    end
    watch_diff_in_split(ctx, dir, trim(fork_point.stdout))
  end,
}

-- Same prefix and keys as tmux. Keys are written as pressed on a German
-- layout, e.g. "|" is alt+7 and "(" is shift+8. Keys Rex has no name for
-- use their physical key code: [Backquote] is "<", [Backslash] is "#".
local prefix = 'ctrl+space>'
local function bind(key, action, args)
  rex.bind(prefix .. key, action, args)
end

-- Tabs (tmux windows)
bind('c', 'track_switch', { action = 'client.tab.new', tabs = true })
bind('l', 'last_tab')
bind('v', 'neovim')
for index = 1, 9 do
  bind(tostring(index), 'tab_goto', { index = index })
end

-- Sessions
bind('f', 'sessionizer')
bind(',', 'sessionizer', { dir = '~/Developer/personal/dotfiles' })
bind('s', 'track_switch', { action = 'session.switch' })
bind('shift+l', 'last_session') -- L
bind('n', 'newest_session')
bind('shift+s', 'sort_sessions')
bind('e', 'session.collapse_others')
bind('shift+e', 'expand_sessions')

-- Panes
bind('alt+7', 'pane.split.right') -- |
bind('-', 'pane.split.down')
bind('+', 'grid')
bind('z', 'pane.zoom')
bind('shift+z', 'cycle_width')
bind('shift+0', 'equalize') -- =
bind('x', 'close_pane')

-- Copy
bind('y', 'pane.copy_id')
bind('shift+y', 'copy_session_id')
bind('ctrl+y', 'copy_path')

-- Open
bind('g', 'lazygit')
bind('d', 'diff')
bind('shift+d', 'pr_diff')
bind('o', 'open_repo')
bind('shift+f', 'reveal_in_finder')

-- Config
bind('r', 'client.config.reload')
bind('u', 'update_tools')
bind('shift+u', 'update_rex')

-- ctrl+h/j/k/l move between panes, except in programs that use them
-- themselves: vim moves between its own splits, fzf moves its selection.
-- Same list as vim-tmux-navigator.
local keeps_ctrl_hjkl = { nvim = true, vim = true, view = true, fzf = true }
for key, direction in pairs { h = 'left', j = 'down', k = 'up', l = 'right' } do
  rex.bind('ctrl+' .. key, function(ctx)
    local program = foreground(ctx)
    if program and keeps_ctrl_hjkl[program.name] then
      return false
    end
    rex.session.focus_direction { direction = direction }
    return true
  end)
end
