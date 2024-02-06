#!/bin/bash
#Format
# Escape character
export esc='\e' # \e, \033 ou \x1b

# Return to the default setting
export reset=$esc'[0m'

# Different emphasis
export bold=$esc'[1m'
export dim=$esc'[2m'
export underline=$esc'[4m'
export blink=$esc'[5m'

# Font colors
export default=$esc'[39m'
export black=$esc'[30m'
export red=$esc'[31m'
export green=$esc'[32m'
export yellow=$esc'[33m'
export blue=$esc'[34m'
export magenta=$esc'[35m'
export cyan=$esc'[36m'
export lightgrey=$esc'[37m'
export darkgrey=$esc'[90m'
export lightred=$esc'[91m'
export lightgreen=$esc'[92m'
export lightyellow=$esc'[93m'
export lightblue=$esc'[94m'
export lightmagenta=$esc'[95m'
export lightcyan=$esc'[96m'
export white=$esc'[97m'

# Background colors
export bdefault=$esc'[49m'
export bblack=$esc'[40m'
export bred=$esc'[41m'
export bgreen=$esc'[42m'
export byellow=$esc'[43m'
export bblue=$esc'[44m'
export bmagenta=$esc'[45m'
export bcyan=$esc'[46m'
export blightgrey=$esc'[47m'
export bdarkgrey=$esc'[100m'
export blightred=$esc'[101m'
export blightgreen=$esc'[102m'
export blightyellow=$esc'[103m'
export blightblue=$esc'[104m'
export blightmagenta=$esc'[105m'
export blightcyan=$esc'[106m'
export bwhite=$esc'[107m'
