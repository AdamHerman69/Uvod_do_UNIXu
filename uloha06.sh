#!/bin/bash

awk '
BEGIN {
        RS="<"
        FS=">"
}


/^a/ {
        print $1
}
' "$1" | awk '
BEGIN {
        RS="[[:space:]]"
        FS="="
}

/^href=/ {
        gsub(/\"/,"",$2)
        gsub(/&quot/,"\"",$2)
        gsub(/&amp/,"\\&",$2)
        gsub(/&lt/,"<",$2)
        gsub(/&gt/,">",$2)
        print $2
}
' -
