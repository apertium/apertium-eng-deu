#!/bin/bash

# # #
# TODO
# 1. use mktemp for generating tmp file names and clean up on exit
#

TMPDIR=/tmp
SCRIPTDIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
OPT_DATADIR=

show_help() {
    local myname=`basename $0`
    cat <<EOF

  Check consistency between the monolingual dictionary on the source side
and the biligual dictionary in the given language pair.
USAGE: $myname [OPTIONS] translation-direction(s)
for example:
USAGE: $myname eng-deu
USAGE: $myname -d path/to/apertium-eng-deu eng-deu deu-eng
OPTIONS:
  --help   display this message and exit
  -d|--datadir[=]PATH
           this option is passed down to inconsistency.sh script. Read more
           in --help for the latter script.

EOF
}

process() {
    local langpair=$1
    local tmpfile=$TMPDIR/$langpair.testvoc

    bash $SCRIPTDIR/inconsistency.sh $OPT_DATADIR "$langpair" > "$tmpfile"
    kode=$?
    if [ $kode -ne 0 ]; then
	echo "ERROR: An error (exit code ${kode}) occurred at the first stage of analysis." >&2
	return 1
    fi

    bash $SCRIPTDIR/inconsistency-summary.sh "$tmpfile"
}

if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

while [ $# -ne 0 ]; do
    case $1 in
	-h|--help)
	    show_help
	    exit 0
	    ;;
	-d|--datadir|--data-dir)
	    OPT_DATADIR="$1 $2"
	    shift
	    ;;
	-d*|--datadir=*|--data-dir=*)
	    OPT_DATADIR="$1"
	    ;;
	-*)
	    echo "ERROR: Unrecognized option '$1'" >&2
	    exit 2
	    ;;
	eng-deu)
	    echo "==English->German=============================="
	    process $1
	    echo ""
	    ;;
	deu-eng)
	    echo "==German->English=============================="
	    process $1
	    echo ""
	    ;;
	*)
	    echo "ERROR: Unknown language pair: '$1'" >&2
	    exit 3
	    ;;
    esac
    shift
done
