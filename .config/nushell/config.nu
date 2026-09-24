# Nushell config. Overrides only: Nushell applies its built-in defaults first.
# `config nu --doc` lists every option.

$env.config.show_banner = false

$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'
$env.config.buffer_editor = 'nvim'

# SQLite history also records each command's directory, exit status and
# duration. The old plaintext history.txt was brought over with `history import`.
$env.config.history.file_format = 'sqlite'

$env.config.completions.algorithm = 'fuzzy'
# rm moves to the Recycle Bin; `rm -p` deletes permanently.
$env.config.rm.always_trash = true
# Repeat the header under tables taller than the screen.
$env.config.footer_mode = 'auto'

# WezTerm reads the working directory from OSC 7 (tab labels, new tabs and
# splits) and ignores OSC 9;9, which Nushell sends by default on Windows.
if $env.TERM_PROGRAM? == 'WezTerm' {
    $env.config.shell_integration.osc7 = true
    $env.config.shell_integration.osc9_9 = false
}

# Tab opens the IDE-style menu, which shows each candidate's description
# (carapace supplies them for flags and subcommands).
$env.config.keybindings ++= [{
    name: ide_completion_menu_on_tab
    modifier: none
    keycode: tab
    mode: [emacs]
    event: {
        until: [
            { send: menu name: ide_completion_menu }
            { send: menunext }
            { edit: complete }
        ]
    }
}]

# yazi detects file types with `file`; on Windows use the one bundled with Git.
let git_file = $env.USERPROFILE | path join scoop apps git current usr bin file.exe
if ($git_file | path exists) {
    $env.YAZI_FILE_ONE = $git_file
}

source scripts/prompt.nu
source scripts/completions.nu
source scripts/commands.nu
