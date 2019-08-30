#!/bin/bash

# User defines RS_PATH to be ":"-separated list of directories to search, in order.
# If RS_PATH is empty, it is assumed to be "."

declare -a RS_PATH_ARRAY

# input: command to execute, with optional parameters
# output: nothing on stdout, and command output on stderr
to_stderr() {
    (>&2 "$@")
}

# input: name of script (without extension) to locate
# output: first directory in RS_PATH that contains the script
# without an extension or with any of the supported extensions
# (.sh, .pl, .py, ...)
rs_locate_in_path() {
    local file=$1
    local pathentry
    for pathentry in "${RS_PATH_ARRAY[@]}"
    do
        pathentry=$(trim "$pathentry")
        if [ -f "$pathentry/$file" ]; then
            echo "$pathentry/$file"
            return 0
        fi
        if [ -f "$pathentry/${file}.sh" ]; then
            echo "$pathentry/${file}.sh"
            return 0
        fi
        if [ -f "$pathentry/${file}.pl" ]; then
            echo "$pathentry/${file}.pl"
            return 0
        fi
        if [ -f "$pathentry/${file}.py" ]; then
            echo "$pathentry/${file}.py"
            return 0
        fi
    done
    to_stderr echo "error: script not found: $file"
    return 1
}


# split RS_PATH on ":" and populate the global RS_PATH_ARRAY
rspath_to_array() {
    local rspath="$RS_PATH"
    if [ -z "$rspath" ]; then
        rspath=.
    fi
    mapfile -d : -t RS_PATH_ARRAY <<< "$rspath"
}

# input: variable name 
# output: content of variable edited to remove leading and trailing whitespace
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}


print_help() {
    echo "usage: rs <script> [options...]"
    echo "usage: rs --locate|-l <script>"
    echo "usage: rs --connect|-c <connection> <script>"
    echo "usage: RS_CONNECT=<connection> rs --connect-env|-C <script>"
}

# Main

if [ $# -eq 0 ]; then
    to_stderr print_help
    exit 1
fi

rspath_to_array

case "$1" in
    --locate|-l)
        shift
        script_name=$1
        rs_locate_in_path "$script_name"
        exit $?
        ;;
    --connect|-c)
        shift
        connect="$1"
        shift
        script_name=$1
        script_path=$(rs_locate_in_path "$script_name")
        if [ -z "$script_path" ]; then
            exit 1
        fi
        cat $script_path | $connect bash "<( cat - )" "$@"
        exit $?
        ;;
    --connect-env|-C)
        shift
        connect="$RS_CONNECT"
        if [ -z "$RS_CONNECT" ]; then
            to_stderr echo "error: undefined environment variable RS_CONNECT"
            to_stderr echo "usage: RS_CONNECT=<connection> rs --connect-env|-C <script>"
            exit 1
        fi
        script_name=$1
        script_path=$(rs_locate_in_path "$script_name")
        if [ -z "$script_path" ]; then
            exit 1
        fi
        cat $script_path | $connect bash "<( cat - )" "$@"
        exit $?
        ;;
esac

script_name=$1
shift
script_path=$(rs_locate_in_path "$script_name")

if [ -z "$script_path" ]; then
    exit 1
fi

if [ -x "$script_path" ]; then
    # using shell here because on cygwin a perl script may not
    # execute correctly if we just do $script_path $@ , it will not show
    # any output unless there's a syntax error
    ${SHELL:-sh} "$script_path" "$@"
else
    head -n 1 "$script_path" | grep '^#!' >/dev/null
    if [ $? -eq 0 ]; then
        # using shell here because on cygwin a perl script may not
        # execute correctly if we just do $script_path $@ , it will not show
        # any output unless there's a syntax error
        ${SHELL:-sh} "$script_path" "$@"
    else
        echo "error: not executable: $script_path" >&2
        exit 1
    fi
fi
