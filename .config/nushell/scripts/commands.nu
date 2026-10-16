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
