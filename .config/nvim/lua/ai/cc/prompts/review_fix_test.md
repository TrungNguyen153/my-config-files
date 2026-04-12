---
name: Review Fix Test
interaction: chat
description: "Three-step workflow: review code, apply fixes, run tests"
opts:
  alias: review-fix-test
  is_slash_cmd: false
  is_workflow: true
  auto_submit: false
tools:
  - read_file
  - grep_search
  - insert_edit_into_file
  - run_command
  - file_search
---

## system

You are executing a three-step code improvement workflow. Follow each step in order.

## user

Review the current buffer for bugs, security issues, performance problems, and idiomatic violations. Present findings as a numbered list with severity (critical/warning/suggestion).

## user

```yaml opts
auto_submit: true
```

Now apply fixes for all critical and warning items using insert_edit_into_file. For suggestions, only fix if straightforward.

## user

```yaml opts
auto_submit: true
```

Run the project's test suite to verify nothing is broken:
- Rust: `cargo test`
- TypeScript: `npm test`
- Python: `pytest`

Report results. If tests fail due to your changes, fix and re-run.
