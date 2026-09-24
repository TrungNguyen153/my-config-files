# External-command completions from carapace (scoop install extras/carapace-bin).
# carapace only runs when Tab is pressed, so startup doesn't pay for it.

# Call the real carapace.exe rather than scoop's shim, which would add a second
# process to every Tab press (~60 ms here). Falls back to whatever is on PATH.
let carapace_exe = $nu.home-dir | path join scoop apps carapace-bin current carapace.exe
let carapace_exe = if ($carapace_exe | path exists) { $carapace_exe } else { 'carapace' }

# Returning null, not an empty list, is what hands the word back to Nushell's
# own completion: an empty list means "no completions". So null whenever
# carapace has nothing useful -- missing, no spec for the command ("-ERR"),
# non-JSON output, or no candidates, which is its answer for any path written
# with backslashes.
$env.config.completions.external.completer = {|spans: list<string>|
    try {
        let candidates = CARAPACE_LENIENT=1 ^$carapace_exe $spans.0 nushell ...$spans | from json | default []
        if ($candidates | is-empty) or ($candidates | where value =~ '^-.*ERR$' | is-not-empty) {
            null
        } else {
            $candidates
        }
    } catch {
        null
    }
}
