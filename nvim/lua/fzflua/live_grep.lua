return function(opts)
  opts = opts or {}
  require('fzf-lua').live_grep { search = opts.default_text or '', cwd = opts.cwd }
end
