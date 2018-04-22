# 1) Sliju vsechny seznamy do jednoho, vypisu duplikaty s poctem opakovani, vyfiltruji ty, ktere se nachazi 3x 
# a odeberu z vystupu pocet vyskytu

sort social.txt beverly_hills.txt actor.txt | uniq -cd | grep 3 | sed 's/.*3 //'
