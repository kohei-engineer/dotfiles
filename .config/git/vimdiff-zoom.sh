#!/bin/sh
# Usage: vimdiff-zoom.sh LOCAL REMOTE
# Zooms the WezTerm pane on the first file and restores it after the last.
# Outside WezTerm, this runs as a normal vimdiff.
local_file=$1 remote_file=$2
path_counter=${GIT_DIFF_PATH_COUNTER:-0}
path_total=${GIT_DIFF_PATH_TOTAL:-0}

w=$(command -v wezterm || command -v wezterm.exe)
pane=${WEZTERM_PANE:-}

# WSL doesn't pass WEZTERM_PANE through, so ask WezTerm for the focused pane.
# Only needed on the first file (zoom) and the last one (unzoom).
if [ -z "$pane" ] && [ -n "$w" ] &&
   { [ "$path_counter" -eq 1 ] || [ "$path_counter" -eq "$path_total" ]; }; then
    pane=$("$w" cli list-clients --format json |
        sed -n 's/.*"focused_pane_id": *\([0-9]*\).*/\1/p' | head -n 1)
fi

if [ "$TERM_PROGRAM" = WezTerm ] && [ -n "$w" ] && [ -n "$pane" ]; then
    if [ "$path_counter" -eq 1 ]; then
        "$w" cli zoom-pane --pane-id "$pane" --zoom
    fi
fi

# Except on the last file, stay on vim's alternate screen at exit so the
# shell doesn't flash between files (git-difftool--helper sets these vars).
if [ "$path_counter" -lt "$path_total" ]; then
    exec vim -c 'set t_te=' -d "$local_file" "$remote_file"
fi

vim -d "$local_file" "$remote_file"
status=$?

if [ "$TERM_PROGRAM" = WezTerm ] && [ -n "$w" ] && [ -n "$pane" ] &&
   [ "$path_counter" -eq "$path_total" ]; then
    "$w" cli zoom-pane --pane-id "$pane" --unzoom
fi

exit "$status"
