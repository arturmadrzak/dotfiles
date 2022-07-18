#!/bin/sh

set -eu

LOG_TAG=$(basename "${0}")

DEF_OPTION="value1"

e_err()
{
    echo "${LOG_TAG}: ERROR: ${*}" >&2
}

usage()
{
    echo "Usage: ${0} [OPTIONS] [--] [ARGS]"
    echo "<description>"
    echo "    -f|--flag    <description>"
    echo "    -o|--option  <description> (default:'${DEF_OPTION}')"
    echo
}

main()
{
    if ! _temp=$(getopt \
        --options 'hfo:' \
        --longoptions 'help,flag,option:' \
        --name "${0}" -- "$@");
        then
            usage
            exit 1
    fi

    # Note the quotes around "$TEMP": they are essential!
    eval set -- "${_temp}"
    unset _temp

    while true; do
        case "$1" in
            '-h'|'--help')
                usage
                exit 0
                ;;
            '-f'|'--flag')
                echo 'Flag is set'
                shift
                continue
                ;;
            '-o'|'--option')
                echo "Option, argument '$2'"
                shift 2
                continue
                ;;
            '--')
                shift
                break
                ;;
            *)
                echo 'Internal error!' >&2
                exit 1
                ;;
        esac
    done

    echo 'Arguments:'
    for arg; do
        echo "--> '$arg'"
    done

}

main "${@}"

exit 0
