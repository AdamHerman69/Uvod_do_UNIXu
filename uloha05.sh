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
 
 
