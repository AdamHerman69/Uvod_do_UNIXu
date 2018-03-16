# 1.
grep -w -i "raven" raven.txt

# 2.
grep -c ^$ raven.txt

#3.
grep -i -w "rep\|word\|more" raven.txt

#4.
grep "p.*p.*ore" raven.txt

#5.
grep "^[^A-Z]" raven.txt

#6.
grep -c "\-$" raven.txt

#7.
grep -o -w "[a-zA-Z]*ore" raven.txt

#8.
grep -w -o "[fF][a-zA-Z]*" raven.txt

#9.
bash uloha9.sh

uloha9.sh:
#!/bin/bash

for i in {a..z}
do
        grep "[^a-zA-Z]\{1,\}[$i${i^^}][a-zA-Z]*[^a-zA-Z]\{1,\}[$i${i^^}][a-zA-Z]*" raven.txt
done


exit 0
