# config.nu
#
# Installed by:
# version = "0.116.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# OneDark Darker : palette partagee avec les terminaux et Neovim.
let theme_path = ($nu.home-dir | path join '.config' 'theme' 'onedark.json')
let onedark = open $theme_path
$env.config.color_config = ($env.config.color_config | merge {
    separator: $onedark.grey1
    leading_trailing_space_bg: { attr: r }
    header: { fg: $onedark.blue attr: b }
    empty: $onedark.blue
    bool: $onedark.orange
    int: $onedark.orange
    filesize: $onedark.aqua
    duration: $onedark.aqua
    date: $onedark.purple
    range: $onedark.aqua
    float: $onedark.orange
    string: $onedark.green
    nothing: $onedark.grey1
    binary: $onedark.aqua
    cell-path: $onedark.aqua
    row_index: $onedark.grey1
    record: $onedark.fg
    list: $onedark.fg
    block: $onedark.blue
    hints: $onedark.grey0
    search_result: { fg: $onedark.bg0 bg: $onedark.yellow }
    shape_binary: $onedark.aqua
    shape_block: $onedark.blue
    shape_bool: $onedark.orange
    shape_custom: $onedark.aqua
    shape_external: $onedark.aqua
    shape_externalarg: $onedark.green
    shape_external_resolved: $onedark.aqua
    shape_filepath: $onedark.yellow
    shape_flag: $onedark.purple
    shape_float: $onedark.orange
    shape_garbage: { fg: $onedark.fg bg: $onedark.red }
    shape_glob_interpolation: $onedark.green
    shape_globpattern: $onedark.yellow
    shape_int: $onedark.orange
    shape_internalcall: $onedark.blue
    shape_keyword: $onedark.purple
    shape_list: $onedark.blue
    shape_literal: $onedark.green
    shape_match_pattern: $onedark.aqua
    shape_nothing: $onedark.grey1
    shape_operator: $onedark.aqua
    shape_pipe: $onedark.aqua
    shape_range: $onedark.aqua
    shape_record: $onedark.blue
    shape_redirection: $onedark.aqua
    shape_signature: $onedark.purple
    shape_string: $onedark.green
    shape_string_interpolation: $onedark.green
    shape_table: $onedark.blue
    shape_variable: $onedark.fg
    shape_vardecl: $onedark.fg
})

# Invite simple pour le developpement : dossier courant et branche Git.
$env.config.show_banner = false
$env.PROMPT_COMMAND = {||
    let current_path = $env.PWD | str replace $nu.home-dir '~'
    let branch = (do -i { git branch --show-current } | complete).stdout | str trim
    if ($branch | is-empty) {
        $"(ansi '#82a6a5')($current_path)(ansi reset)"
    } else {
        $"(ansi '#82a6a5')($current_path)(ansi reset) (ansi '#9aa889')[($branch)](ansi reset)"
    }
}
$env.PROMPT_COMMAND_RIGHT = ''

# Let tmux start the same Nushell executable in every pane.
if $nu.os-info.name == "windows" {
    if "SHELL" in ($env | columns) { hide-env SHELL }
} else {
    $env.SHELL = $nu.current-exe
    $env.PATH = ($env.PATH
        | prepend ($nu.home-dir | path join ".local" "bin")
        | prepend ($nu.home-dir | path join "go" "bin")
        | prepend ($nu.home-dir | path join ".atuin" "bin"))
}

# Atuin keeps searchable command history; init.nu is generated once per OS.
let atuin_init = ($nu.home-dir | path join ".atuin" "init.nu")
if ($atuin_init | path exists) {
    source ~/.atuin/init.nu
}


# Terminal shortcuts shared across Windows, macOS, and Linux.
alias c = clear
alias v = nvim

def ensure-tmux-session [name: string, working_dir: string] {
    let existing = (do { ^tmux has-session -t $name } | complete)
    if $existing.exit_code != 0 {
        ^tmux new-session -d -s $name -n editor -c $working_dir
        ^tmux new-window -d -t $name -n shell -c $working_dir
    }
}

def s [] {
    ensure-tmux-session dev $env.PWD
    ensure-tmux-session global $nu.home-dir
    ^tmux attach-session -t dev
}
# WinGet installs the native Windows tmux build outside the default PATH.
if $nu.os-info.name == "windows" {
    let tmux_dir = ($env.LOCALAPPDATA | path join "Microsoft" "WinGet" "Packages" "arndawg.tmux-windows_Microsoft.Winget.Source_8wekyb3d8bbwe")
    if (($tmux_dir | path join "tmux.exe") | path exists) {
        $env.PATH = ($env.PATH | prepend $tmux_dir)
    }
}
