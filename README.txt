##==========================================================================##
##                              GRIERA SCRIPTS                              ##
##==========================================================================##

All my scripts follows these rules:
  · Their names start with 'my_' pattern
  · Delimiter used between words is underscore '_'
    (e.g., my_cut_string, my_add_date, etc.).
  · Their bodies start with a detailed description explaining how to use them.
  · Include an usage() function that outputs a brief description explainning 
    how to run them. This function will be called when the script is run
    without any argument. This rule is not apply to scripts which no need
    arguments in order to execute them.

Also, all of them have a debugging mode in order to detect posible crashes.
This mode prints the output of commands used inside the functions to
standard output. To enable it, just type '-d' flag as the first parameter
when yo run a script. The rule for implementing it is to define a variable
inside the script called 'DBG', that will be set up to 1 if first argument
is equal to '-d'.

