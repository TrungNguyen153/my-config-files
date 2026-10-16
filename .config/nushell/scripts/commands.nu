alias ll = ls -l

# Make a directory and cd into it.
def --env mkcd [dir: path] {
    mkdir $dir
    cd $dir
}

# yazi, then cd into the directory it was quit in. The official snippet from
# yazi-rs.github.io; note `rm -p`, since rm goes to the Recycle Bin here.
def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    ^yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

# herdr on a workspace for this directory. A bare `herdr` attaches to the saved
# session and ignores the cwd, so focus the workspace that has a pane here, or
# create one. The API does not start the server, so start it headless first.
def hd [--session (-s): string] {
    let s = if $session == null { [] } else { [--session $session] }
    let norm = {|p| $p | str lowercase | str trim --right --char '\' }

    if (^herdr ...$s pane list | complete).exit_code != 0 {
        let args = ($s | append server | each {|a| $"'($a)'" } | str join ',')
        ^pwsh -NoProfile -Command $"Start-Process herdr -ArgumentList ($args) -WindowStyle Hidden"
        mut up = false
        for _ in 1..40 {
            sleep 250ms
            if (^herdr ...$s pane list | complete).exit_code == 0 { $up = true; break }
        }
        if not $up { error make {msg: "herdr server did not start"} }
    }

    let here = (do $norm $env.PWD)
    let hit = (^herdr ...$s pane list | from json | get result.panes
        | where {|p| (do $norm $p.cwd) == $here } | get -o 0)
    if $hit == null {
        ^herdr ...$s workspace create --cwd $env.PWD --focus | ignore
    } else {
        ^herdr ...$s workspace focus $hit.workspace_id | ignore
    }

    # Inside a herdr pane the focus change is enough; nesting is refused.
    if $env.HERDR_ENV? != "1" { ^herdr ...$s }
}
