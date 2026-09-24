# External-command completions from carapace (scoop install extras/carapace-bin).
# carapace only runs when Tab is pressed, so startup doesn't pay for it. Any
# failure -- carapace missing, no spec for the command ("-ERR"), non-JSON
# output -- returns null, and Nushell falls back to completing file paths.

# Call the real carapace.exe rather than scoop's shim, which would add a second
# process to every Tab press (~60 ms here). Falls back to whatever is on PATH.
let carapace_exe = $nu.home-dir | path join scoop apps carapace-bin current carapace.exe
let carapace_exe = if ($carapace_exe | path exists) { $carapace_exe } else { 'carapace' }

$env.config.completions.external.completer = {|spans: list<string>|
    try {
        CARAPACE_LENIENT=1 ^$carapace_exe $spans.0 nushell ...$spans
        | from json
        | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
    } catch {
        null
    }
}
