#!/bin/bash

# # #
# --help
#

ALL_POS="abbr adj adv cm cnjadv cnjcoo cnjsub det guio ij n np num pr preadv prn rel vaux vbhaver vblex vbser vbmod OVERALL"

show_help() {
    cat <<EOF

  Summarize results of running testvoc/inconsistency.sh script on per part-of-speech
basis, computing for each PoS the number and percentage of translated, untranslated and
partially translated items.
USAGE: `basename $0` [OPTIONS] file_generated_by_inconsistency.sh
OPTIONS:
  -h|--help    display this message and exit

EOF
}

while [ $# -ne 0 ]; do
    case $1 in
	-h|--help)
	    show_help
	    exit
	    ;;
	*)
	    break
	    ;;
    esac
    shift
done

if [ $# -ne 1 ]; then
    echo "ERROR: The script accepts exactly one command line argument." >&2
    exit 1
fi

INFILE=$1

# for macs / computers without 'apcalc'
which calc >/dev/null
if [ $? -eq 0 ]; then
    CALC="calc -p | sed 's/~//g'"
else
    CALC="bc -l 2>/dev/null | sed 's/^\./0./g'"
fi

subsetfile=`mktemp --tmpdir $(basename $0).XXXXXX`
trap "rm -f $subsetfile" EXIT

echo -n ""
date
echo -e "==============================================="
echo -e "POS\tTotal\tClean\tWith @\tWith #\tClean %"
for pos in $ALL_POS; do
    case $pos in
	det)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<n>' -e '<np>' | grep -v REGEX >$subsetfile
	    ;;

	preadv)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<adj>' -e '<adv>' | grep -v REGEX >$subsetfile
	    ;;

	adv)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<adj>' -e '<v' | grep -v REGEX >$subsetfile
	    ;;

	cnjsub)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<v' | grep -v REGEX >$subsetfile
	    ;;

	prn)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<v' | grep -v REGEX >$subsetfile
	    ;;

	vbser)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<pp' -e '<vbm' | grep -v REGEX >$subsetfile
	    ;;

	vbhaver)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<pp' -e '<vbm' | grep -v REGEX >$subsetfile
	    ;;

	pr)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<prn' -e '<ger' | grep -v REGEX >$subsetfile
	    ;;

	rel)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<pr' | grep -v REGEX >$subsetfile
	    ;;

	adj)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<np' | grep -v REGEX >$subsetfile
	    ;;

	vbmod)
	    cat $INFILE | grep "<$pos>" | grep -v -e '<vbl' | grep -v REGEX >$subsetfile
	    ;;

	OVERALL)
	    cat $INFILE | grep -v REGEX >$subsetfile
	    ;;

	*)
	    cat $INFILE | grep "<$pos>" | grep -v REGEX >$subsetfile
	    ;;
    esac

    TOTAL=`cat $subsetfile |                wc -l`
    AT=`cat $subsetfile    | grep '@'     | wc -l`
    HASH=`cat $subsetfile  | grep '>  *#' | wc -l`

    UNCLEAN=`echo $AT+$HASH | sh -c "$CALC"`
    CLEAN=`echo $TOTAL-$UNCLEAN | sh -c "$CALC"`
    PERCLEAN=`echo $UNCLEAN/$TOTAL*100 | sh -c "$CALC" | head -c 5`

    echo $PERCLEAN | grep "Err" >/dev/null
    if [ $? -eq 0 ]; then
	TOTPERCLEAN="100"
    elif [ -z "$PERCLEAN" ]; then
	TOTPERCLEAN="100"
    else
	TOTPERCLEAN=`echo 100-$PERCLEAN | sh -c "$CALC" | head -c 5`
    fi

    echo -e "$TOTAL;$pos;$CLEAN;$AT;$HASH;$TOTPERCLEAN"
done | sort -gr | awk 'BEGIN {FS=";"; OFS="\t"} {print $2, $1, $3, $4, $5, $6}'

echo -e "==============================================="
