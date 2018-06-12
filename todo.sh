#!/bin/bash

if ! cd $HOME/todo 2> /dev/null ; then
        mkdir $HOME/todo
        cd $HOME/todo
        mkdir archive lists tmp
        touch ./tmp/main_menu ./tmp/archive_menu
fi

#pracuji v adresari ./todo/

function zobraz_menu {

        function get_list {
                command="$1"
                cislo_listu="$(printf "$command" | sed 's/[^0-9]//g')"

                list=$(echo $cislo_listu | awk -F";" '
                        FILENAME == "-" {cislo_listu = $1}
                        FILENAME != "-" && cislo_listu == $1 {print $2}
                        ' -  ./tmp/main_menu)
                printf "$list"
        }

        slozka="lists"
        while : ; do

                clear
                echo "        ______"
                echo "       | MENU |"
                echo "        ¯¯¯¯¯¯"

                touch ./tmp/main_menu
                ls ./"$slozka" | awk 'BEGIN {print "cislo;to-do list"} {print NR";" $0}' - > ./tmp/main_menu
                cat ./tmp/main_menu | column -t -s";"

                printf "\n"
                printf "$zprava\n"
                printf "\n"

                #prikazy

                printf "[cislo listu] - zobrazit list
                a[cislo listu] - archivovat/znovuobnovit list
                d[cislo listu] - vymazat list
                q - ukoncit todo list
                tc[jmeno noveho listu] - vytvorit novy list
                archiv - prepnout do archivu
                listy - prepnout na todo listy\n" | column -t -s"-"
                printf "\n\nNapiste prikaz: "
                read command < /dev/tty

                if [ -z "$(printf "$command" | grep -o '[^0-9]')" ]; then               # pokud je cislo
                        list="$(get_list $command)"
                        zobraz_list "$list" "$slozka"
                        zprava="$list opusten"

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

                elif printf "$command" | grep -q '^d[0-9]\{1,\}$' ; then
                        list="$(get_list $command)"
                        if rm ./"$slozka"/"$list" ; then
                                zprava="$list uspesne smazan"
                        else zprava="smazani se nepodarilo"
                        fi
                elif [[ "$command" == c* ]]; then
                        jmeno=$(printf "$command" | sed 's/c//')
                        if touch ./"slozka"/"$jmeno" ; then
                                zprava="list $jmeno uspesne vytvoren"
                        else zprava="vytvoreni se nepodarilo"
                        fi
                elif [ "$command" = "q" ]; then
                        clear
                        printf "Neplecha ukoncena\n"
                        exit

                elif [ "$command" = "archiv" ]; then
                        slozka="archive"
                elif [ "$command" = "listy" ]; then
                        slozka="lists"

                else
                        zprava="Spatny format prikazu\n"
                fi
        done
}

function zobraz_list {
        skryt_hotove="false"
        while : ; do
                list="$1"
                slozka="$2"
                clear
                echo "$list"
                echo "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
                if [ "$skryt_hotove" = "false" ]; then
                        cat ./"$slozka"/"$list" | awk -F";" 'BEGIN {print "cislo;hotovo?;priorita;deadline;ukol"} {print NR ";" $0}' | column -t -s";"
                else cat ./"$slozka"/"$list" | awk -F";" 'BEGIN {print "cislo;hotovo?;priorita;deadline;ukol"} $1 == "false" {print NR ";" $0}' | column -t -s";"
                fi

                printf "\n\n\n"
                printf "q - opustit list
                c - pridat novy ukol
                d[cislo ukolu]] - smazat ukol
                h[cislo ukolu] - oznacit ukol za hotovy
                h - zobrazit/skryt hotove ukoly
                dh - vymazat hotove ukoly
                s{p/d} - seradit podle priority/deadline
                rs{p/d} - seradit obracene\n" | column -t -s"-"

                printf "\n\nZadejte prikaz: "
                read command < /dev/tty

                if [ "$command" = "q" ]; then
                        break
                elif [ "$command" = "c" ]; then
                        printf "Ukol: "
                        read ukol < /dev/tty
                        printf "Deadline (YYYY/MM/DD hh:mm:ss): "
                        read deadline < /dev/tty
                        printf "Priorita (prirozene cislo): "
                        read priorita < /dev/tty
                        hotovo="false"

                        printf "${hotovo};${priorita};${deadline};${ukol}\n" >> ./"$slozka"/"$list"
                        sort -t";" -k1,1 -k2,2n -k3 ./"$slozka"/"$list" > ./tmp/serazeny_list
                        mv ./tmp/serazeny_list ./"$slozka"/"$list"

                elif printf "$command" | grep -q '^d[0-9]\{1,\}$' ; then
                        cislo_ukolu="$(printf "$command" | sed 's/[^0-9]//g')"
                        sed -i "${cislo_ukolu}d" ./"$slozka"/"$list"

                elif printf "$command" | grep -q '^h[0-9]\{1,\}$' ; then
                        cislo_ukolu="$(printf "$command" | sed 's/[^0-9]//g')"
                        sed -i "${cislo_ukolu}s/false/true/" ./"$slozka"/"$list"

                elif [ "$command" = "h" ]; then
                        if [ "$skryt_hotove" = "false" ]; then
                                skryt_hotove="true"
                        else skryt_hotove="false"
                        fi
                elif [ "$command" = "dh" ]; then
                        sed -i '/^true;.*$/d' ./"$slozka"/"$list"

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
