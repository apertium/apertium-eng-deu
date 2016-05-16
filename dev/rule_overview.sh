#!/bin/bash
#(created by wolfgangth)

# you can use this script to generate an overview
# of all rules with its rule numbers shown in debug mode

#(if you commented out a rule in any t?x-file, add a  _  (like <_rule)
# to avoid that this was counted by this script)

# output to same dir as rule files
TO_DIR="."      ## start as:  dev/rule_overview.sh  (from apertium-eng-deu)
#TO_DIR=".."     ## start as:  ./rule_overview.sh    (from dev)

cat $TO_DIR/apertium-eng-deu.deu-eng.t1x | grep '<rule' | cat -n > $TO_DIR/xt1x.deu-eng.txt
cat $TO_DIR/apertium-eng-deu.deu-eng.t2x | grep '<rule' | cat -n > $TO_DIR/xt2x.deu-eng.txt

cat $TO_DIR/apertium-eng-deu.eng-deu.t1x | grep '<rule' | cat -n > $TO_DIR/xt1x.eng-deu.txt
cat $TO_DIR/apertium-eng-deu.eng-deu.t2x | grep '<rule' | cat -n > $TO_DIR/xt2x.eng-deu.txt
