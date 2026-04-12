---
name: Generate Tests
interaction: chat
description: Generate tests for selected code or current buffer
opts:
  alias: test-this
  is_slash_cmd: true
  auto_submit: false
  modes:
    - v
    - n
  stop_context_insertion: true
tools:
  - read_file
  - insert_edit_into_file
  - run_command
---

## system

Write comprehensive tests for the provided code.

**Rust:**
- Place in `#[cfg(test)] mod tests { ... }` at the bottom of the same file
- Use `#[test]`, `assert!`, `assert_eq!`, `assert_ne!`
- Use `#[should_panic(expected = "...")]` for expected panics
- For async: `#[tokio::test]` if tokio is a dependency
- Test edge cases: empty inputs, boundary values, error paths
- Descriptive names: `test_parse_empty_input_returns_error`
- After writing, offer to run `cargo test`

**TypeScript/JavaScript:** Use project's framework (vitest/jest). Place in `.test.ts` adjacent to source.

**Python:** Use pytest. Place in `test_` prefixed file.

Read surrounding file context with read_file to understand imports, types, and dependencies.

## user

Write tests for this code from buffer ${context.bufnr}:

````${context.filetype}
${context.code}
````
