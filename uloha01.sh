touch -d, --date="7 days ago" reference.txt
find -newer reference.txt -name "*.txt"
rm reference.txt
