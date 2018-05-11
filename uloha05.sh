1)

ls -lSh /etc | head -n 2 | tail -n 1

// vypíše řádku i s inforacemi o souboru, pokud bychom chtěli jen jméno souboru museli bychom to z ní ještě vytáhnout

2)

find /var -type f -printf "%s\t%p\n" |sort -n | tail -n 1

// vyhledá (rekurzivně) všechny regulární soubory, a vypíše každý na řádek společně s jeho velikostí | numericky je seřadí a vybere poslední

3)

find /etc -type f -printf "%T@\t%p\n" | sort -n | tail -n 1

// vyhledá (rekurzivně) všechny regulární soubory, a vypíše každý na řádek společně s časem jeho poslední modifikace (v sekundách od počátku času) | numericky je seřadí a vybere poslední

find /etc -maxdepth 1 -type f -printf "%T@\t%p\n" | sort -n | tail -n 1

// to samé akorát nastavíme maximální hloubku rekurze 1

 4) 
# Pravděpodobně existuje na tuto úlohu elegantnější řešení, ale toto funguje.

upperlower.sh :
 
#!/bin/bash
reverse="false"
adresa=""

if [ "$#" -eq 0 ];
then
        read -p "Zadne argumetny, zadejte adresar: " adresa
elif [ "$#" -eq 1 ] && [ "$1" != "-r" ];
then
        adresa="$1"
elif [ "$#" -eq 1 ] && [ "$1" = "-r" ]
then
        read -p "Zadejte adresar: " adresa
elif [ "$#" -eq 2 ] && [ "$2" = "-r" ];
then
        adresa="$1"
        reverse="true"
elif [ "$#" -eq 2 ] && [ "$1" = "-r" ];
then
        adresa="$2"
        reverse="true"
else
        printf "chybny vstup\\n"
fi

printf "Adresa: $adresa\\n"
printf "Reverse: $reverse\\n"

prejmenuj(){    # dostane jako argument adresar
        for filename in $1/*
        do
                if [[ -d $filename ]]
                then
                        prejmenuj $filename
                elif [[ -f $filename ]]
                then
                        basename=`basename $filename`
                        dirname=`dirname $filename`

                        if [[ $reverse = "false" ]]
                        then
                                if [[ $(echo $basename | grep [a-z]) = "" ]]
                                then
                                        if [[ $(ls $dirname | grep "^$(tr '[:upper:]' '[:lower:]' <<< "$basename" )$") = "" ]]
                                        then
                                                mv -n "$filename" ""$dirname"/$(tr '[:upper:]' '[:lower:]' <<< "$basename")"
                                        else
                                                printf "Chyba: kolize soubor $filename\nn"
                                        fi
                                fi
                        elif [[ $reverse = "true" ]]
                        then
                                if [[ $(echo $basename | grep [A-Z]) = "" ]]
                                then
                                        if [[ $(ls $dirname | grep "^$(tr '[:lower:]' '[:upper:]' <<< "$basename")$") = "" ]]
                                        then
                                                mv -n "$filename" ""$dirname"/$(tr '[:lower:]' '[:upper:]' <<< "$basename")"
                                        else
                                                printf "Chyba: kolize soubor $filename\\n"
                                        fi
                                fi
                        fi
                fi
        done
}

if [ "$adresa" != "" ]
then
        prejmenuj $adresa
fi
