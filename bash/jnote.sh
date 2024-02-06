#!/usr/bin/bash

jnote(){
if [[ -z "${1}" ]]; then
    eval displayNotes

elif [[ "${1}" == "add" ]]; then
    if [[ -n "${2}" ]]; then
        eval addToNotes "${*}"
    else
        echo -e "bash: $HOME/jnote.sh: Note to add not stated" >&2
        return
    fi
elif [[ "${1}" == "remove" ]]; then
    if [[ -n "${2}" ]]; then
        eval validateArguments "$*"
        VALIDATE_ARGUMENTS=$?
        if [[ "$VALIDATE_ARGUMENTS" == 1 ]]; then
            return
        else
            eval removeNotes "${*}"
        fi
    else
        echo -e "bash: $HOME/jnote.sh: Note(s) to remove not stated" >&2
        return
    fi
else
    echo -e "bash: $HOME/jnote.sh: Wrong command" "'${1}'" >&2
    return
fi
}
export -f jnote

displayNotes(){
    NUM_LINES=$(wc -l "${HOME}/.jnote" | awk '{printf $1 }')
    if [[ $NUM_LINES == 0 ]]; then
         echo -e "bash: $HOME/jnote.sh: No notes to display" >&2
    else
        # shellcheck disable=SC2154
        echo -e "${underline}Notes:${reset}"
        cat "${HOME}/.jnote"
    fi
}

addToNotes(){
    NOTE_NUMBER="$(wc -l "${HOME}/.jnote" | awk '{printf $1+1}')"
    echo "$NOTE_NUMBER""." "${@:2}" >> "${HOME}/.jnote"
}

validateArguments(){
    if [[ "${2}" == "all" && -z "${3}" ]]; then
        return 0
    else
        re='^[0-9]+$'
        for NOTE_NUMBER in "${@:2}"
        do    
        if ! [[ $NOTE_NUMBER =~ $re ]] ; then
            echo -e "bash: $HOME/jnote.sh: Note(s) to remove not stated" >&2
            return 1
        fi
        done
        return 0
    fi
}

removeNotes(){
    if [[ "${2}" == "all" ]]; then
        sed -i --follow-symlinks d "${HOME}/.jnote"
    else
        for NOTE_NUMBER in "${@:2}"
        do    
            sed -i --follow-symlinks "/\b${NOTE_NUMBER}. \b/d" "${HOME}/.jnote"
        done
        eval restructureNotes
    fi
}

restructureNotes(){
    LINE_COUNT="$(wc -l "${HOME}/.jnote" | awk '{printf $1}')"
    for NUM in $(seq 1 "$LINE_COUNT")
    do
        sed -Ei --follow-symlinks "$NUM s/[0-9]+./$NUM./g" "${HOME}/.jnote"
    done
}
