# 1) Sliju vsechny seznamy do jednoho, vypisu duplikaty s poctem opakovani, vyfiltruji ty, ktere se nachazi 3x 
# a odeberu z vystupu pocet vyskytu

sort social.txt beverly_hills.txt actor.txt | uniq -cd | grep 3 | sed 's/.*3 //'

# 2) Grepem vytáhnu z .csv souborů názvy zemí, odeberu uvozovky, setřídim a nechám vyjet duplikáty.

grep -oh "\".*\"" countrycodes_en.csv kodyzemi_cz.csv | tr -d '"' | sort | uniq -d

# 3) Vytáhneme ze souboru relevantní řádky, spočítáme slova každého řádku (počet členů skupiny + 1) a napíšeme počet na začátek řádky. Výstup seřadíme (numericky) a uložíme
# do pomocného souboru. Přečteme první charakter souboru a grepem vybereme všechny řádky které začínají na toto číslo 
# (skupiny se stejným počtem lidí) a z těch vypíšeme pouze jméno skupiny

#!/bin/sh

cut -d: -f 1,4 /etc/group | {
while read line
do
        echo $line | sed 's/[,:]/ /g' |
        wc -w |
        tr -d '\n'
        echo " $line"
done
} | sort -nr >/tmp/pomocneiSoubor

pocetSlov=$(head -c1 /tmp/pomocneiSoubor)
pocetRadku=$(grep -c $pocetSlov /tmp/pomocneiSoubor)
grep $pocetRadku /tmp/pomocneiSoubor |
grep -o ' .*:' |
tr -d ':' | tr -d ' '

rm /tmp/pomocneiSoubor
