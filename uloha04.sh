# 1) Sliju vsechny seznamy do jednoho, vypisu duplikaty s poctem opakovani, vyfiltruji ty, ktere se nachazi 3x 
# a odeberu z vystupu pocet vyskytu

sort social.txt beverly_hills.txt actor.txt | uniq -cd | grep 3 | sed 's/.*3 //'

# 2) Grepem vytáhnu z .csv souborů názvy zemí, odeberu uvozovky, setřídim a nechám vyjet duplikáty.

grep -oh "\".*\"" countrycodes_en.csv kodyzemi_cz.csv | tr -d '"' | sort | uniq -d

