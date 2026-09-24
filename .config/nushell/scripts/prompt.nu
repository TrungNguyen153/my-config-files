# Two-line prompt: path, git branch and slow-command time, then a caret
# coloured by the last exit code. Nothing external runs per prompt -- the
# branch is read straight from .git/HEAD.

# Untyped on purpose: an `[]: nothing -> string` signature around `loop`
# fails to parse.
def _prompt_git_branch [] {
    mut dir = $env.PWD
    loop {
        let dotgit = $dir | path join '.git'
        let kind = $dotgit | path type
        if $kind in ['dir' 'file'] {
            # In worktrees and submodules .git is a file: "gitdir: <path>".
            let gitdir = if $kind == 'dir' { $dotgit } else {
                let line = try { open --raw $dotgit | decode utf-8 | lines | first } catch { return '' }
                $dir | path join ($line | str replace --regex '^gitdir:\s*' '' | str trim)
            }
            let head = try { open --raw ($gitdir | path join 'HEAD') | decode utf-8 | str trim } catch { return '' }
            if ($head | str starts-with 'ref: ') {
                return ($head | str substring 5.. | str replace --regex '^refs/heads/' '')
            }
            return ($head | str substring 0..<7) # detached HEAD
        }
        let parent = $dir | path dirname
        if $parent == $dir { return '' }
        $dir = $parent
    }
}

# 2.3s, 1m1s, 2h5m
def _prompt_took [ms: int] {
    let s = $ms // 1000
    if $s < 60 {
        $'($ms / 1000 | math round --precision 1)s'
    } else if $s < 3600 {
        $'($s // 60)m($s mod 60)s'
    } else {
        $'($s // 3600)h($s mod 3600 // 60)m'
    }
}

$env.PROMPT_COMMAND = {||
    # relative-to ignores case and won't treat C:\Users\OSX as home.
    let rel = try { $env.PWD | path relative-to $nu.home-dir } catch { null }
    let path = if $rel == null { $env.PWD } else if $rel == '' { '~' } else { '~' | path join $rel }
    let branch = _prompt_git_branch
    let took = $env.CMD_DURATION_MS | into int
    [
        $'(ansi blue_bold)($path)(ansi reset)'
        (if $branch != '' { $'  (ansi magenta)(char --unicode 'e0a0') ($branch)(ansi reset)' })
        (if $took >= 2000 { $'  (ansi yellow)took (_prompt_took $took)(ansi reset)' })
        (char newline)
    ] | compact | str join
}

$env.PROMPT_INDICATOR = {||
    let color = if $env.LAST_EXIT_CODE == 0 { ansi green_bold } else { ansi red_bold }
    $'($color)(char --unicode '276f')(ansi reset) '
}

# The clock lives in WezTerm's tab bar.
$env.PROMPT_COMMAND_RIGHT = ''
