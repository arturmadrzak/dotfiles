#!/usr/bin/env sh

GNOME_KB_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
GNOME_KB_KEY="custom-keybindings"
GNOME_KB_PATH_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

gnome_kb_get_list() {
    # Print the raw gsettings list value, e.g.
    # "['/org/.../custom0/','/org/.../custom1/']" or "@as []"
    gsettings get "$GNOME_KB_SCHEMA" "$GNOME_KB_KEY"
}

gnome_kb_each_path() {
    # Echo each custom-keybinding path (one per line), e.g.:
    # /org/.../custom0/
    # /org/.../custom1/
    list=$(gnome_kb_get_list) || return 1

    case $list in
        "@as []")
            return 0
            ;;
    esac

    # Safely parse the GNOME array into separate paths (POSIX-safe)
    # Example input:
    #   "['/path/one/','/path/two/']"
    printf '%s\n' "$list" |
        sed "
            s/^\[//;       # remove leading [
            s/\]$//;       # remove trailing ]
            s/,/\'$'\n/g;  # split comma-separated entries into lines
            s/^ *'//;      # trim leading spaces and opening quote
            s/' *$//;      # trim closing quote and trailing spaces
        " |
        sed '/^$/d'        # drop empty lines
}

gnome_kb_find_binding_path() {
    # Input:  $1 = binding string, e.g. "<Super>c"
    # Output: path on stdout if found; exit 0 if found, 1 otherwise.
    binding=$1

    while IFS= read -r path
    do
        [ -z "$path" ] && continue
        schema_path="$GNOME_KB_SCHEMA.custom-keybinding:$path"
        current=$(gsettings get "$schema_path" binding 2>/dev/null) || continue
        # remove surrounding single quotes
        current=$(echo "$current" | sed "s/^'//;s/'$//")
        if [ "$current" = "$binding" ]; then
            printf '%s\n' "$path"
            return 0
        fi
    done <<EOF
$(gnome_kb_each_path)
EOF

    return 0
}

gnome_kb_append_path_list() {
    # Input:  $1 = new path
    # Output: new list literal suitable for gsettings set
    new_path=$1
    list=$(gnome_kb_get_list)

    if [ "$list" = "@as []" ]; then
        printf "['%s']\n" "$new_path"
    else
        list=${list%]}
        printf "%s, '%s']\n" "$list" "$new_path"
    fi
}

gnome_kb_find_free_path() {
    # Output: first unused /org/.../customN/ path
    idx=0
    while :
    do
        candidate="$GNOME_KB_PATH_BASE/custom$idx/"
        used=false

        while IFS= read -r path
        do
            [ -z "$path" ] && continue
            if [ "$path" = "$candidate" ]; then
                used=true
                break
            fi
        done <<EOF
$(gnome_kb_each_path)
EOF

        if [ "$used" = false ]; then
            printf '%s\n' "$candidate"
            return 0
        fi

        idx=$((idx + 1))
    done
}

gnome_set_binding() {
    # Usage: gnome_set_binding "<Super>c" "/path/to/command.sh"
    BINDING=$1
    COMMAND=$2

    if [ -z "$BINDING" ] || [ -z "$COMMAND" ]; then
        echo "Usage: gnome_set_binding '<Super>c' '/path/to/command.sh'" >&2
        return 1
    fi

    # Check if this binding already exists
    existing_path=$(gnome_kb_find_binding_path "$BINDING")

    if [ -n "$existing_path" ]; then
        schema_path="$GNOME_KB_SCHEMA.custom-keybinding:$existing_path"
        existing_cmd=$(gsettings get "$schema_path" command 2>/dev/null | sed "s/^'//;s/'$//")
        existing_name=$(gsettings get "$schema_path" name 2>/dev/null | sed "s/^'//;s/'$//")

        # If command is the same, don't ask – just say it's already configured
        if [ "$existing_cmd" = "$COMMAND" ]; then
            echo "[KEY-BIND] '$BINDING' already set to '$COMMAND'. Nothing to do."
            return 0
        fi

        echo "[KEY-BIND] '$BINDING' is already used:"
        echo "  Name   : $existing_name"
        echo "  Command: $existing_cmd"
        echo
        printf 'Overwrite? [yes/no/abort]: '
        read -r ans || return 1

        case $ans in
            yes|y|Y)
                gsettings set "$schema_path" command "$COMMAND"
                gsettings set "$schema_path" name "Custom: $COMMAND"
                echo "Updated existing binding '$BINDING' -> '$COMMAND'"
                return 0
                ;;
            no|n|N)
                echo "Leaving existing binding unchanged."
                return 0
                ;;
            abort|a|A)
                echo "Aborted."
                return 1
                ;;
            *)
                echo "Unknown answer, aborted." >&2
                return 1
                ;;
        esac
    fi

    # Binding not used yet → create a new customN entry
    new_path=$(gnome_kb_find_free_path) || return 1
    new_list=$(gnome_kb_append_path_list "$new_path")

    gsettings set "$GNOME_KB_SCHEMA" "$GNOME_KB_KEY" "$new_list"

    new_schema_path="$GNOME_KB_SCHEMA.custom-keybinding:$new_path"
    gsettings set "$new_schema_path" name "Custom: $COMMAND"
    gsettings set "$new_schema_path" command "$COMMAND"
    gsettings set "$new_schema_path" binding "$BINDING"

    echo "[KEY-BIND] $BINDING -> $COMMAND"
}
