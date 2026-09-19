local M = {}

-- Text matching: what wezterm turns into clickable links, and what QuickSelect
-- (LEADER+SPACE) offers as a labelled target.

function M.apply(config, wezterm, _platform)
  -- Start from the built-ins rather than replacing them. The defaults already
  -- cover bare URLs, URLs wrapped in ()[]{}<>, and email addresses.
  --
  -- Deliberately NOT added: the widely-copied GitHub issue and commit-SHA
  -- rules. Both hardcode a single owner/repo into the URL template, which
  -- would point every 7-hex-char string at the wrong project across the 21
  -- repos under Desktop/Workspace.
  config.hyperlink_rules = wezterm.default_hyperlink_rules()

  -- Added to the default QuickSelect patterns, not replacing them --
  -- disable_default_quick_select_patterns stays unset, so URLs, paths, git
  -- hashes, IPs and numbers still match.
  config.quick_select_patterns = {
    -- Compiler and linter locations: src/main.rs:42:17, lua/keys.lua:26.
    -- The default path patterns stop at the colon, so the line and column
    -- would otherwise need selecting by hand.
    [[[\w./\\-]+:\d+(?::\d+)?]],

    -- Windows absolute paths, which the default path patterns handle poorly.
    [[[A-Za-z]:\\[^\s"'<>|]+]],
  }
end

return M
