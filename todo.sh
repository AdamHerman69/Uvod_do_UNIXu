#!/bin/bash

# implementace jednoduche todo list aplikace

# vytvoreni pracovnich adresaru

if ! cd $HOME/todo 2> /dev/null ; then
        mkdir $HOME/todo
        cd $HOME/todo
        mkdir archive lists tmp
        touch ./tmp/main_menu
fi

# pracuji v adresari ./todo/

function zobraz_menu {                          #vykresluje menu a zpracovavaprikazy

        function get_list {                     # z prikazu zjiska podle cisla jmeno listu ktero vraci
                command="$1"
                cislo_listu="$(printf "$command" | sed 's/[^0-9]//g')"

                list=$(echo $cislo_listu | awk -F";" '
                        FILENAME == "-" {cislo_listu = $1}
                        FILENAME != "-" && cislo_listu == $1 {print $2}
                        ' -  ./tmp/main_menu)
                printf "$list"
        }

        slozka="lists"                          # program zacina v menu s listy
        while : ; do                            # nekonecny loop vykresluje menu a reaguje na prikazy


                # vykresleni nadpisu

                clear
                if [ "$slozka" = "lists" ]; then
                        echo "        ______"
                        echo "       | MENU |"
                        echo "        ¯¯¯¯¯¯"
                else
                        echo "        ________"
                        echo "       | ARCHIV |"
                        echo "        ¯¯¯¯¯¯¯¯"
                fi

                # vypsani vytvorenych to-do listu

                touch ./tmp/main_menu
                ls ./"$slozka" | awk 'BEGIN {print "cislo;to-do list"} {print NR";" $0}' - > ./tmp/main_menu
                cat ./tmp/main_menu | column -t -s";"

                printf "\n\n$zprava\n\n"                # info o minulem prikazu

                # prikazy

                printf "[cislo listu] - zobrazit list
                a[cislo listu] - archivovat/znovuobnovit list
                d[cislo listu] - vymazat list
                q - ukoncit todo list
                c[jmeno noveho listu] - vytvorit novy list
                archiv - prepnout do archivu
                listy - prepnout na todo listy\n" | column -t -s"-"


                # nacteni a vyhodnoceni prikazu

                printf "\n\nNapiste prikaz: "
                read command < /dev/tty

                # pokud je cislo zobrazime list

                if [ -z "$(printf "$command" | grep -o '[^0-9]')" ]; then
                        list="$(get_list $command)"
                        zobraz_list "$list" "$slozka"
                        zprava="$list opusten"

                # archivace/obnoveni

                elif printf "$command" | grep -q '^a[0-9]\{1,\}$' ; then
                        list="$(get_list $command)"
                        if [ "$slozka" = "lists" ]; then
                                if mv ./lists/"$list" ./archive/"$list"  ; then
                                        zprava="$list uspesne archivovan"
                                else zprava="archivace neuspesna"
                                fi
                        elif [ "$slozka" = "archive" ]; then
                                if mv ./archive/"$list" ./lists/"$list"  ; then
                                        zprava="$list uspesne obnoven"
                                else zprava="obnoveni neuspesne"
                                fi
                        fi

                # smazani listu

                elif printf "$command" | grep -q '^d[0-9]\{1,\}$' ; then
                        list="$(get_list $command)"
                        if rm ./"$slozka"/"$list" ; then
                                zprava="$list uspesne smazan"
                        else zprava="smazani se nepodarilo"
                        fi

                # vytvoreni noveho listu

                elif [[ "$command" == c* ]]; then
                        jmeno=$(printf "$command" | sed 's/c//')
                        if touch ./"$slozka"/"$jmeno" ; then
                                zprava="list $jmeno uspesne vytvoren"
                        else zprava="vytvoreni se nepodarilo"
                        fi

                # ukonceni programu

                elif [ "$command" = "q" ]; then
                        clear
                        printf "Neplecha ukoncena\n"
                        exit

                # prepnuti do archivu

                elif [ "$command" = "archiv" ]; then
                        slozka="archive"

                # prepnuti z5 na seznam listu

                elif [ "$command" = "listy" ]; then
                        slozka="lists"

                else
                        zprava="Spatny format prikazu\n"
                fi
        done
}

# funkce na zobrazeni a manipulaci s jednotlivimy to-do listy

function zobraz_list {
        skryt_hotove="false"
        list="$1"
        slozka="$2"

        # ridici while loop bezi do ukonceni prikazem q

        while : ; do
                clear

                # nadpis

                echo "$list"
                echo "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"

                # vypsani listu

                if [ "$skryt_hotove" = "false" ]; then
                        cat ./"$slozka"/"$list" | awk -F";" 'BEGIN {print "cislo;hotovo?;priorita;deadline;ukol"} {print NR ";" $0}' | column -t -s";"
                else cat ./"$slozka"/"$list" | awk -F";" 'BEGIN {print "cislo;hotovo?;priorita;deadline;ukol"} $1 == "false" {print NR ";" $0}' | column -t -s";"
                fi

                # vypsani prikazu

                printf "\n\n\n"
                printf "q - opustit list
                c - pridat novy ukol
                d[cislo ukolu] - smazat ukol
                h[cislo ukolu] - oznacit ukol za hotovy
                h - zobrazit/skryt hotove ukoly
                dh - vymazat hotove ukoly
                s{p/d} - seradit podle priority/deadline
                rs{p/d} - seradit obracene\n" | column -t -s"-"

                # nacteni a vyhodnoceni prikazu

                printf "\n\nZadejte prikaz: "
                read command < /dev/tty

                # ukonceni prace s listem

                if [ "$command" = "q" ]; then
                        break

                # vytvoreni nove polozky a serazeni podle priority

                elif [ "$command" = "c" ]; then
                        printf "Ukol: "
                        read ukol < /dev/tty
                        printf "Deadline (YYYY/MM/DD hh:mm:ss): "               # uzivatel si muze zvolit jak podrobny datum/cas chce, ale musi dodrzet poradi a format
                        read deadline < /dev/tty
                        printf "Priorita (prirozene cislo): "
                        read priorita < /dev/tty
                        hotovo="false"

                        printf "${hotovo};${priorita};${deadline};${ukol}\n" >> ./"$slozka"/"$list"
                        sort -t";" -k1,1 -k2,2nr -k3 ./"$slozka"/"$list" > ./tmp/serazeny_list
                        mv ./tmp/serazeny_list ./"$slozka"/"$list"

                # smazani ukolu

                elif printf "$command" | grep -q '^d[0-9]\{1,\}$' ; then
                        cislo_ukolu="$(printf "$command" | sed 's/[^0-9]//g')"
                        sed -i "${cislo_ukolu}d" ./"$slozka"/"$list"

                # oznaceni za hotove

                elif printf "$command" | grep -q '^h[0-9]\{1,\}$' ; then
                        cislo_ukolu="$(printf "$command" | sed 's/[^0-9]//g')"
                        sed -i "${cislo_ukolu}s/false/true/" ./"$slozka"/"$list"

                # toggle na skryti/odkryti hotovych ukolu

                elif [ "$command" = "h" ]; then
                        if [ "$skryt_hotove" = "false" ]; then
                                skryt_hotove="true"
                        else skryt_hotove="false"
                        fi

                # smazani hotovych ukolu

                elif [ "$command" = "dh" ]; then
                        sed -i '/^true;.*$/d' ./"$slozka"/"$list"

                # ruzna razeni podle priority/data

                elif [ "$command" = "sp" ]; then
                        sort -t";" -k2,2n -k3 ./"$slozka"/"$list" > ./tmp/serazeny_list
                        mv ./tmp/serazeny_list ./"$slozka"/"$list"

                elif [ "$command" = "sd" ]; then
                        sort -t";" -k3,3 -k2,2 ./"$slozka"/"$list" > ./tmp/serazeny_list
                        mv ./tmp/serazeny_list ./"$slozka"/"$list"


                elif [ "$command" = "rsp" ]; then
                        sort -t";" -k2,2nr ./"$slozka"/"$list" > ./tmp/serazeny_list
                        mv ./tmp/serazeny_list ./"$slozka"/"$list"


                elif [ "$command" = "rsd" ]; then
                        sort -rt";" -k3,3 ./"$slozka"/"$list" > ./tmp/serazeny_list
                        mv ./tmp/serazeny_list ./"$slozka"/"$list"

                else printf "Neznamy prikaz\n"

                fi
        done
}

zobraz_menu
