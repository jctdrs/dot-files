#!/usr/bin/bash
jcal(){
    CURRENT_YEAR="$(date +%-Y)"
    CURRENT_MONTH="$(date +%-m)"
    CURRENT_DAY=$(date +%-d)
    
    if [[ -z "${1}" ]]; then
        START_MONTH="${CURRENT_MONTH}"
        START_YEAR="${CURRENT_YEAR}"
    else
        eval validateMonth "$*"
        VALIDATE_MONTH=$?
        if [[ "$VALIDATE_MONTH" == 1 ]]; then
            return 1
        fi
        START_MONTH="${1}"
        
        if [[ -n "${2}" ]]; then
            START_YEAR="${2}"
        else
            START_YEAR="${CURRENT_YEAR}"
        fi
    fi
    
    eval sort_dates

    for (( MONTH=START_MONTH; MONTH<(START_MONTH+4); MONTH++ ))
    do
    if [[ $MONTH -gt 12 ]]; then
        true
    else
        R=$(sed -n "s/\/$MONTH\b//p" "${HOME}/.dates-${START_YEAR}" | awk '
            {a[++n]=$1; b[++n]=$2}
            END{var= "\\b";
            for (i=1; i<=n; i++)
            if (b[i]=="") var=var a[i-1] "\\b|";
            print var}')
        
        G=$(sed -n "s/\/$MONTH\b//p" "${HOME}/.dates-${START_YEAR}" | awk '
            {a[++n]=$1; b[++n]=$2}
            END{var= "\\b";
            for (i=1; i<=n; i++)
            if (b[i]!="") var= var a[i-1] "\\b[^;]|\\b";
            print var}')
        

        if [[ "${MONTH}" == "${START_MONTH}" ]]; then
            if [[ "${MONTH}" == "${CURRENT_MONTH}" ]]; then
                ncal "${START_YEAR}" -m "${MONTH}" -M > "${HOME}/.${MONTH}"
                eval today
                GREP_COLORS='ms=2;91' grep -E -w --color=always "${R}" "${HOME}/.${MONTH}" > "${HOME}/.tmp"
                GREP_COLORS='ms=2;92' grep -E --color=always "${G}" "${HOME}/.tmp" > "${HOME}/.tmp.tmp"
                mv "${HOME}/.tmp.tmp" "${HOME}/.${MONTH}"
            else
                ncal "${START_YEAR}" -m "${MONTH}" -M | GREP_COLORS='ms=2;91' grep -E -w --color=always "${R}" \
                > "${HOME}/.tmp"
                GREP_COLORS='ms=2;92' grep -E  --color=always "${G}" "${HOME}/.tmp" > "${HOME}/.tmp.tmp"
                mv "${HOME}/.tmp.tmp" "${HOME}/.${MONTH}"
            fi
        else
            if [[ "${MONTH}" == "${CURRENT_MONTH}" ]]; then
                ncal "${START_YEAR}" -m "${MONTH}" -M | cut -d" " -f3- | sed '1 s/^[  \t]*//' > "${HOME}/.${MONTH}"
                eval today
                GREP_COLORS='ms=2;91' grep -E -w --color=always "${R}" "${HOME}/.${MONTH}" > "${HOME}/.tmp.tmp"
                GREP_COLORS='ms=2;92' grep -E --color=always "${G}" "${HOME}/.tmp.tmp" > "${HOME}/.tmp"
                mv "${HOME}/.tmp.tmp" "${HOME}/.${MONTH}"
            else
                ncal "${START_YEAR}" -m "${MONTH}" -M | cut -d" " -f3- | sed '1 s/^[  \t]*//' | \
                GREP_COLORS='ms=2;91' grep -E -w --color=always "${R}" > "${HOME}/.tmp"
                GREP_COLORS='ms=2;92' grep -E --color=always "${G}" "${HOME}/.tmp" > "${HOME}/.tmp.tmp"
                mv "${HOME}/.tmp.tmp" "${HOME}/.${MONTH}"
            fi
        fi
    fi
    done
    
    eval join
    eval weekend

    cat "${HOME}/.jcal"
    rm  "${HOME}/.jcal"
    rm "${HOME}/.tmp"
    
    eval agenda
}
export -f jcal

sort_dates(){
    sort -t '/' -k2,2n -k 1,1n -o "${HOME}/.dates-${START_YEAR}" "${HOME}/.dates-${START_YEAR}"
}

join(){
    mv "${HOME}/.${START_MONTH}" "${HOME}/.jcal"
    for (( MONTH=START_MONTH+1; MONTH<(START_MONTH+4); MONTH++ ))
    do
    if [[ $MONTH -gt 12 ]]; then
        true
    else
        NUM=1
        while IFS= read -r line; do
            if [[ "${NUM}" == 1 ]]; then
                sed -i "${NUM} s/$/${line}/" "${HOME}/.jcal"
            else
                sed -i "${NUM} s/$/  ${line}/" "${HOME}/.jcal"
            fi
            NUM=$((NUM +1))
        done < "${HOME}/.${MONTH}"
        rm "${HOME}/.$MONTH"
    fi
    done
}

weekend(){
    sed -i '7,8s/\S\+/&\x1b[2m\x1b[94m/' "${HOME}/.jcal"
    sed -i '7,8s/$/\x1b[0m/' "${HOME}/.jcal"
}

today(){
    if [[ $(date +%-u) -gt 5 ]]; then
        sed -i "s,\b$CURRENT_DAY\b,\x1b[47m&\x1b[49m\x1b[2m\x1b[94m," "${HOME}/.${CURRENT_MONTH}"
    else
        if echo "$R" | grep -q "${CURRENT_DAY}"; then
            sed -i "s,\b$CURRENT_DAY\b,\x1b[47m\x1b[2m\x1b[31m&\x1b[0m," "${HOME}/.${CURRENT_MONTH}"
        elif echo "$G" | grep -q "${CURRENT_DAY}"; then
            sed -i "s,\b$CURRENT_DAY\b,\x1b[47m\x1b[2m\x1b[32m&\x1b[0m," "${HOME}/.${CURRENT_MONTH}"
        else
            sed -i "s,\b$CURRENT_DAY\b,\x1b[47m&\x1b[0m," "${HOME}/.${CURRENT_MONTH}"
        fi
    fi
}

validateMonth(){
    re='^([1-9]|1[012])$'
    MONTH_NUMBER="${1}"
    if ! [[ $MONTH_NUMBER =~ $re ]] ; then
        echo -e "bash: $HOME/jcal.sh: Month not valid" >&2
        return 1

    #elif [[ -n "${2}" ]]; then
    #    echo -e "bash: $HOME/jcal.sh: Command not valid" >&2
    #    return 1
    fi
    return 0
}

agenda(){
    echo
    # shellcheck disable=SC2154
    echo -e "${underline}"Agenda:"${reset}" 
    first="${CURRENT_DAY:0:1}"
    second="${CURRENT_DAY:1:1}"
    
    if grep -Eq "^${CURRENT_DAY}\/${CURRENT_MONTH} ." "${HOME}/.dates-${START_YEAR}" --color=no; then
        echo "Today": 
        grep -E "^${CURRENT_DAY}\/${CURRENT_MONTH} ." "${HOME}/.dates-${START_YEAR}" --color=no
        echo ""
    fi

    for (( MONTH=START_MONTH; MONTH<(START_MONTH+2); MONTH++ ));
    do
        if [[ "${MONTH}" == "${CURRENT_MONTH}" ]]; then
            if [[ "${CURRENT_DAY}" -lt 9 ]]; then
                grep -E "[$((first+1))-9]\/${MONTH} .|1[0-9]\/${MONTH} .|2[0-9]\/${MONTH} .|3[0-1]\/${MONTH} ." \
                "${HOME}/.dates-${START_YEAR}" --color=no
            elif [[ "${CURRENT_DAY}" -lt 19 ]]; then
                grep -E "1[$((second+1))-9]\/${MONTH} .|2[0-9]\/${MONTH} .|3[0-1]\/${MONTH} ." \
                "${HOME}/.dates-${START_YEAR}" --color=no
            elif [[ "${CURRENT_DAY}" -lt 29 ]]; then
                grep -E "2[$((second+1))-9]\/${MONTH} .|3[0-1]\/${MONTH} ." \
                "${HOME}/.dates-${START_YEAR}" --color=no
            elif [[ "${CURRENT_DAY}" -lt 32 ]]; then
                grep -E "3[$((second+1))]\/${MONTH} ." "${HOME}/.dates-${START_YEAR}" --color=no
            fi
        else
            grep -E "[1-9]\/${MONTH} .|1[0-9]\/${MONTH} .|2[0-9]\/${MONTH} .|3[0-1]\/${MONTH} ." \
            "${HOME}/.dates-${START_YEAR}" --color=no
        fi
    done
    echo
}
