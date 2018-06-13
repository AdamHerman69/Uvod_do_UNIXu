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
}

/^href=/ {
        gsub(/^href=/,"")
        gsub(/\"/,"")
        gsub(/&quot/,"\"")
        gsub(/&amp/,"\\&")
        gsub(/&lt/,"<")
        gsub(/&gt/,">")
        print
}
' -
