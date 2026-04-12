---
name: Generate Documentation
interaction: chat
description: Generate documentation comments for selected code
opts:
  alias: doc
  is_slash_cmd: true
  auto_submit: true
  modes:
    - v
  stop_context_insertion: true
tools:
  - insert_edit_into_file
---

## system

Generate documentation comments following language conventions:

- **Rust**: `///` doc comments with markdown. Include `# Examples`, `# Errors`, `# Panics`, `# Safety` sections where relevant.
- **TypeScript/JavaScript**: JSDoc (`/** */`) with `@param`, `@returns`, `@throws`, `@example`.
- **Python**: Google-style docstrings with Args, Returns, Raises.
- **Lua**: EmmyLua annotations (`---@param`, `---@return`).
- **Go**: godoc conventions (comment starts with function name).

Write concise documentation that explains *why*, not just *what*. Insert directly above the code using insert_edit_into_file.

## user

Generate documentation for this code in buffer ${context.bufnr} (${context.filetype}):

````${context.filetype}
${context.code}
````
