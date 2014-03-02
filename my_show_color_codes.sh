#!/bin/bash

#
# my_show_color_codes.sh:
#
# Echoes a bunch of color codes to the terminal to demonstrate what's
# available. Each line is the color code of one foreground color, out of 17
# (default + 16 escapes), followed by a test use of that color on all nine
# background colors (default + 8 escapes).
#
# Exit status:
#  · 0 -> Success

# The text used to test color configuration
TEXT_TEST='Test'

echo -e "\n                   40m      41m      42m      43m\
      44m      45m      46m      47m";

for set_foregrounds in  '    m' '   1m' '   2m' '  30m' '1;30m' '2;30m' \
                        '  31m' '1;31m' '2;31m' '  32m' '1;32m' '2;33m' \
                        '  33m' '1;33m' '2;33m' '  34m' '1;34m' '2;34m' \
                        '  35m' '1;35m' '2;35m' '  36m' '1;36m' '2;36m' \
                        '  37m' '1;37m' '2;37m' ;
do 
    foreground=${set_foregrounds// /}
    echo -en " $set_foregrounds \033[$foreground  $TEXT_TEST  "

    for background in 40m 41m 42m 43m 44m 45m 46m 47m ;
    do
        echo -en "$EINS \033[$foreground\033[$background  $TEXT_TEST  \033[0m"
    done
    echo
done
echo

exit 0
