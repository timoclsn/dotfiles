local home = os.getenv("HOME")
local shell = "com.superlogical.terminal.shell"
local terminal_block = "com.superlogical.terminal"
-- The Rex server runs with a minimal PATH, without Homebrew or ~/.local/bin.
local path = home .. "/.local/bin:/opt/homebrew/bin:" .. os.getenv("PATH")

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
  return rex.layout.block({ flavor = shell, options = { cwd = cwd, command = command } })
end

-- A floating layer running a command, closed when the command exits.
local function popup(label, command, bounds)
  in_session("new_layer", {
    bounds = bounds,
    focus = true,
    layout = rex.layout.block({
      flavor = shell,
      label = label,
      options = { command = command, exit = { on_completion = true, quick_exit_threshold_ms = 0 } },
    }),
  })
end

-- The program in the foreground of the focused pane, if Rex can tell.
local function foreground(ctx)
  local process = rex.block.call(terminal_block, "process", { block_id = ctx.block_id })
  return process and process.foreground
end

local function pane_dir(ctx)
  local program = foreground(ctx)
  if not (program and program.cwd) then
    error("Can't tell this pane's directory", 0)
  end
  return program.cwd
end

-- Runs cc through an interactive zsh (cc is an alias) and keeps a fish shell
-- open once it exits. The prompt is passed as an argument, so quotes,
-- newlines and '!' reach cc without any shell quoting.
local function agent_command(prompt)
  return { "zsh", "-ic", 'cc "$@"; exec fish', "zsh", prompt }
end

local function find_session(label)
  for _, session in ipairs(call("session.list", {}).sessions or {}) do
    if session.label == label then
      return session.session_id
    end
  end
end

-- Sorts the sessions in the sidebar alphabetically by moving each one to the
-- end in order. Moving a session needs the connection attached to it.
local function sort_sessions()
  local sessions = call("session.list", {}).sessions
  table.sort(sessions, function(a, b)
    return a.label:lower() < b.label:lower()
  end)
  for _, session in ipairs(sessions) do
    call("session.attach", { session_id = session.session_id })
    call("session.move", { session_id = session.session_id })
  end
end

-- A new session has one window running cc.
local function create_session(label, dir, prompt)
  local session_id = call("session.create", {
    label = label,
    initial_windows = {
      { layout = terminal(dir, agent_command(prompt)) },
    },
  }).session_id
  sort_sessions()
  return session_id
end

local function open_project(args)
  local dir = args.dir:gsub("^~/", home .. "/"):gsub("/$", "")
  local label = dir:match("[^/]+$")
  local session_id = find_session(label) or create_session(label, dir, args.prompt)

  if args.detach then
    return { session = label }
  end
  rex.client.queue("session.select", { session_id = session_id })
end

-- Without a dir it opens the fzf project picker in a floating layer, which
-- runs this action again with the picked dir.
rex.action({
  name = "sessionizer",
  title = "Open Project…",
  category = "Projects",
  keywords = "project session sessionizer switch",
  args = { dir = "string?", detach = "boolean?", prompt = "string?" },
  run = function(_, args)
    if args.dir then
      return open_project(args)
    end
    popup("Projects", { home .. "/.local/bin/rex-sessionizer" }, { 0.2, 0.15, 0.6, 0.7 })
  end,
})

-- Rex's own tab actions count tabs across all sessions, tmux counts them per
-- session, so these work on the windows of the current session only. The
-- current window is the one holding the pane the key was pressed in.
local function session_windows(ctx)
  local windows = in_session("view", {}).windows
  for index, window in ipairs(windows) do
    if window.focused_block_id == ctx.block_id then
      return windows, index
    end
  end
  return windows, 1
end

-- The app tracks which tab it shows itself, so ask it to switch.
local function focus_window(ctx, window)
  if window then
    rex.client.queue("session.select", { session_id = ctx.session_id, window_id = window.window_id })
  end
end

rex.action({
  name = "tab_goto",
  title = "Go to Tab in Session",
  category = "Tabs",
  args = { index = "integer" },
  run = function(ctx, args)
    local windows = session_windows(ctx)
    focus_window(ctx, windows[args.index])
  end,
})

rex.action({
  name = "tab_step",
  title = "Step Through Tabs in Session",
  category = "Tabs",
  args = { step = "integer" },
  run = function(ctx, args)
    local windows, active = session_windows(ctx)
    focus_window(ctx, windows[(active - 1 + args.step) % #windows + 1])
  end,
})

rex.action({
  name = "sort_sessions",
  title = "Sort Sessions",
  category = "Sessions",
  run = sort_sessions,
})

-- Session IDs start with their creation time, so the highest one is the newest.
rex.action({
  name = "newest_session",
  title = "Go to Newest Session",
  category = "Sessions",
  run = function(ctx)
    local newest
    for _, session in ipairs(call("session.list", {}).sessions) do
      if not newest or session.session_id > newest.session_id then
        newest = session
      end
    end
    if newest.session_id == ctx.session_id then
      error("Already in newest session: " .. newest.label, 0)
    end
    rex.client.queue("session.select", { session_id = newest.session_id })
  end,
})

-- Splits the pane into a 2x2 grid and focuses the top-left one.
rex.action({
  name = "grid",
  title = "Split Pane into Grid",
  category = "Panes",
  run = function()
    for _, action in ipairs({ "pane.split.right", "pane.split.down", "pane.focus.left", "pane.split.down", "pane.focus.up" }) do
      rex.client.queue(action)
    end
  end,
})

-- The splits from the layout's root down to a block, each with the side
-- the block is on.
local function path_to(node, block_id)
  if node.block_id then
    return node.block_id == block_id and {} or nil
  end
  for _, side in ipairs({ "before", "after" }) do
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
rex.action({
  name = "cycle_width",
  title = "Cycle Pane Width",
  category = "Panes",
  run = function(ctx)
    local windows, active = session_windows(ctx)
    local splits = path_to(windows[active].layers[1].layout, ctx.block_id) or {}
    local last = splits[#splits]
    for index = #splits, 1, -1 do
      local node, side = splits[index].node, splits[index].side
      if node.split.direction == "horizontal" then
        local share = last.node.split[last.side].rect[3]
        local target = share < 0.4 and 0.5 or share < 0.6 and 0.67 or 0.33
        local side_width = target / node.rect[3]
        in_session("resize_pane", {
          direction = "horizontal",
          before_block_id = first_block(node.split.before),
          after_block_id = first_block(node.split.after),
          ratio = math.min(0.95, math.max(0.05, side == "before" and side_width or 1 - side_width)),
        })
        return
      end
    end
  end,
})

-- Opens the current branch's PR in the browser, or else the repository.
rex.action({
  name = "open_repo",
  title = "Open Repository in Browser",
  category = "Git",
  run = function(ctx)
    local dir = pane_dir(ctx)
    if not run({ "git", "rev-parse", "--is-inside-work-tree" }, { cwd = dir }).ok then
      error("Not in a git repository", 0)
    end
    if run({ "gh", "pr", "view", "--web" }, { cwd = dir }).ok then
      return
    end
    if not run({ "gh", "browse" }, { cwd = dir }).ok then
      error("No remote origin found", 0)
    end
  end,
})

rex.action({
  name = "copy_path",
  title = "Copy Pane Directory",
  category = "Panes",
  run = function(ctx)
    local dir = pane_dir(ctx)
    if dir:sub(1, #home) == home then
      dir = "~" .. dir:sub(#home + 1)
    end
    run({ "pbcopy" }, { stdin = dir })
  end,
})

rex.action({
  name = "diff",
  title = "Open Git Diff",
  category = "Git",
  run = function(ctx)
    in_session("new_window", {
      window_label = "diff",
      layout = terminal(pane_dir(ctx), { "zsh", "-ic", "git diff | comview" }),
    })
  end,
})

rex.action({
  name = "agents_dashboard",
  title = "Agents Dashboard",
  category = "Agents",
  run = function()
    popup("Agents Dashboard", { home .. "/.local/bin/agents-dashboard" }, { 0.1, 0.1, 0.8, 0.8 })
  end,
})

-- Same prefix and keys as tmux. Keys are written as pressed on a German
-- layout, e.g. "|" is alt+7 and "(" is shift+8. Keys Rex has no name for
-- use their physical key code: [Backquote] is "<", [Backslash] is "#".
local prefix = "ctrl+space>"
local function bind(key, action, args)
  rex.bind(prefix .. key, action, args)
end

-- Tabs (tmux windows)
bind("c", "client.tab.new")
bind("n", "tab_step", { step = 1 })
bind("p", "tab_step", { step = -1 })
for index = 1, 9 do
  bind(tostring(index), "tab_goto", { index = index })
end
bind(",", "client.tab.rename")
bind("shift+6", "client.tab.close") -- &
bind("[Backquote]", "client.tab.move.backward") -- <
bind("shift+[Backquote]", "client.tab.move.forward") -- >
bind("shift+d", "diff")

-- Sessions
bind("f", "sessionizer")
bind("shift+[Backslash]", "sessionizer", { dir = "~/Developer/personal/dotfiles" }) -- '
bind("shift+n", "sessionizer", { dir = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes" })
bind("s", "session.switch")
bind("w", "session.switch")
bind("shift+8", "session.previous") -- (
bind("shift+9", "session.next") -- )
bind("shift+4", "session.rename") -- $
bind("shift+a", "newest_session")
bind("shift+s", "sort_sessions")

-- Panes
bind("alt+7", "pane.split.right") -- |
bind("-", "pane.split.down")
bind("+", "grid")
bind("left", "pane.focus.left")
bind("right", "pane.focus.right")
bind("up", "pane.focus.up")
bind("down", "pane.focus.down")
bind("o", "pane.focus_next")
bind("z", "pane.zoom")
bind("shift+z", "cycle_width")
bind("x", "pane.close")
bind("alt+8", "pane.move.left") -- {
bind("alt+9", "pane.move.right") -- }
bind("shift+1", "pane.move_to_new_tab") -- !
for _, direction in ipairs({ "left", "right", "up", "down" }) do
  bind("ctrl+" .. direction, "pane.resize", { direction = direction })
end
bind("ctrl+y", "pane.copy_id")
bind("shift+y", "copy_path")

-- Other
bind("shift+o", "open_repo")
bind("a", "agents_dashboard")
bind("r", "client.config.reload")
bind("e", "client.sidebar.toggle")

-- ctrl+h/j/k/l move between panes, except in programs that use them
-- themselves: vim moves between its own splits, fzf moves its selection.
-- Same list as vim-tmux-navigator.
local keeps_ctrl_hjkl = { nvim = true, vim = true, view = true, fzf = true }
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    local program = foreground(ctx)
    if program and keeps_ctrl_hjkl[program.name] then
      return false
    end
    rex.session.focus_direction({ direction = direction })
    return true
  end)
end
