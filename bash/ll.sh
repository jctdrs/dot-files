#!/usr/bin/bash

# Argument
if [ -z "$*" ]; then 
  dirarg=.
else
  dirarg=$1
fi

# Keyword
KW="-loh"

# MODIFIED LS
( du -sh --apparent-size $dirarg/*; ls $KW --color=always $dirarg )\
  | awk '{ if ($1 == "total")
             {LS = 1} 
           else if (!LS) 
             { COUNT+=1
               SIZES[COUNT] = $1
               if (length($1) > maxlen1) {maxlen1 = length($1)} }
           else 
              { COUNTLS+=1
                sub($2,"",$0)
                sub($3,sprintf(SIZES[COUNTLS]),$3)
                printf("%2s  %6s  %4s  %2s  %-3s  %-5s   %s\n", 
                       $1, $2, $3, $5, $4, $6, $7) } }' 
