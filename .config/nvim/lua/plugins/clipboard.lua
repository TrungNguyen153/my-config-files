return   {
    'bkoropoff/clipipe',
    opts = {
      -- Optional configuration, defaults shown here:
      path = nil, -- clipipe binary
      keep_line_endings = false, -- Set to true to disable \r\n conversion on Windows
      enable = true, -- Automatically set g:clipboard to enable clipipe
      start_timeout = 5000, -- Timeout for starting background process (ms)
      timeout = 500, -- Timeout for responses from background process (ms)
      interval = 50, -- Polling interval for responses (ms)
      download = true, -- Download pre-built binary if needed
      build = true, -- Build from source if needed
    }
}