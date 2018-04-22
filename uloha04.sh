# 1) Sliju vsechny seznamy do jednoho, vypisu duplikaty s poctem opakovani, vyfiltruji ty, ktere se nachazi 3x 
# a odeberu z vystupu pocet vyskytu

sort social.txt beverly_hills.txt actor.txt | uniq -cd | grep 3 | sed 's/.*3 //'

# 2) Grepem vytáhnu z .csv souborů názvy zemí, odeberu uvozovky, setřídim a nechám vyjet duplikáty.

grep -oh "\".*\"" countrycodes_en.csv kodyzemi_cz.csv | tr -d '"' | sort | uniq -d

# 3)

cut -d: -f 1,4 /etc/group | { 
while read line; 
do 
echo $line | sed 's/[,:]/ /g' | wc -w | tr -d '\n'; 
echo " $line"; 
done; 
} | sort -nr | { 
pocetSlov=$(head -c1);
pocetRadku=`expr $(grep -c $pocetSlov) + 1` ;
echo $pocetRadku ; }

pocetSlov=$(head -c1 seznam); pocetRadku=`expr $(grep -c $pocetSlov seznam )` ; grep $pocetRadku seznam | grep -o ' .*:' | tr -d ':' | tr -d ' '
