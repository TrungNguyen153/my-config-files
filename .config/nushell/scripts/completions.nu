# External-command completions from carapace (scoop install extras/carapace-bin).
# carapace only runs when Tab is pressed, so startup doesn't pay for it.

# Call the real carapace.exe rather than scoop's shim, which would add a second
# process to every Tab press (~60 ms here). Falls back to whatever is on PATH.
let carapace_exe = $nu.home-dir | path join scoop apps carapace-bin current carapace.exe
let carapace_exe = if ($carapace_exe | path exists) { $carapace_exe } else { 'carapace' }

# Commands carapace has a spec for, cached so startup only reads a file. The
# cache is rebuilt when carapace.exe is newer than it; delete it after adding
# your own specs. null (list unavailable) means "always ask carapace".
let carapace_names_cache = $nu.cache-dir | path join carapace-names.txt
let carapace_names = try {
    if not ($carapace_names_cache | path exists) or (ls $carapace_names_cache).0.modified < (ls $carapace_exe).0.modified {
        mkdir $nu.cache-dir
        ^$carapace_exe --list --names | save --force $carapace_names_cache
    }
    open $carapace_names_cache | lines
} catch {
    null
}

# Returning null, not an empty list, is what hands the word back to Nushell's
# own completion: an empty list means "no completions". So null whenever
# carapace has nothing useful -- missing, no spec for the command ("-ERR"),
# non-JSON output, or no candidates, which is its answer for any path written
# with backslashes.
#
# Nushell hands the completer a record and binds its fields by parameter name;
# `place.command` is the token list of the command being completed.
#
# Starting carapace.exe costs ~280 ms per Tab press here (Windows loading an
# 86 MB binary; carapace itself runs for ~10 ms), so it is skipped where
# Nushell's own file completion gives the same answer: commands carapace has
# no spec for, and words whose directory part exists on disk (`src/ma`, `.\`,
# `C:\Us`). `origin/ma` still reaches carapace unless ./origin/ exists.
$env.config.completions.external.completer = {|place|
    let spans = $place.command
    let dir = $spans | last | str replace -r "^[\"'`]" '' | str replace -r '[^\\/]*$' ''
    let is_path = $dir != '' and ($dir | path expand | path exists)
    if $is_path or ($carapace_names != null and $spans.0 not-in $carapace_names) {
        null
    } else {
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
}
