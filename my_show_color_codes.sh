#!/bin/bash

#
# my_show_color_codes.sh:
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.#
#
# Exit status:
#  · 0 -> Success

# The text used to test color configuration
TEXT_TEST='Test'

#Foreground/Background
for fgbg in 38 48 ; do
    for color in {0..256} ; do

        echo -en "\e[${fgbg};5;${color}m ${TEXT_TEST}\t\e[0m"

        #Display 10 colors per lines
        if [ $((($color + 1) % 10)) == 0 ] ; then
            echo
        fi
    done
    echo
done

exit 0
