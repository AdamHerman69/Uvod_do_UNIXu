# Skript 1

pocet=0;
cat /etc/passwd | while read x
do
   pocet=`expr $pocet + 1`
done
echo $pocet

# Nefunguje, protože inkrementujeme proměnou pocet ve while cyklu, který kvůli pipě běží v jiném procesu než náš shell (má tedy jiné proměné)
# a tedy při provedení příkazu echo $pocet vypíše shell hodotu, kterou jsme přiřadili do proměné v 1. řádku.

# Skript 2

cat /etc/passwd | {
   pocet=0
   while read x
   do
      pocet=`expr $pocet + 1`
   done
   echo $pocet
}

# Funguje, protože díky složeným závorkám proměnou vypisuje stejný proces, který jí inkrementoval, je to tedy ta samá proměná

# Skript 3

pocet=0
while read x
do
   pocet=`expr $pocet + 1`
done </etc/passwd
echo $pocet

# Funguje, protože nikde v programu nevytváříme jiný proces (v předchozích 2 příkladech se vytvářel kvůli programu cat) a tedy
# inkrementujeme i vypisujeme stejnou proměnou.

# Skript 4

pocet=0
while read x </etc/passwd
do
   pocet=`expr $pocet + 1`
done
echo $pocet

#Nefunguje, zde je špatně syntax, při read-while loopu dáváme soubor na vstup až na konec loopu tedy za slovo "done"
# jako v předchozím případě
