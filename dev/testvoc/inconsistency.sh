#!/bin/bash

# # #
# TODO
# 1. use mktemp for generating tmp file names and clean up on exit
#

TMPDIR=/tmp
# canonical language pair name, it is always the same for both eng-deu and deu-eng directions
CNNPAIR=eng-deu

################################################################################
# FUNCTIONS

show_help() {
    myname=`basename $0`
    cat <<EOF

  Preprocess sources files.
USAGE: $myname [OPTIONS] translation-direction
for example
USAGE: $myname eng-deu
USAGE: $myname -d ../apertium-eng-deu deu-eng
OPTIONS:
  -h|--help     display this message and exit
  -d|--datadir[=]PATH
                path to language pair directory, typically named apertium-LANG1-LANG2.
                If not given, the script attempts to guess it by checking the current
                and all ancestor directories of the current directory until it finds
                config.status file.

EOF
}

has_apertium_config_file() {
    local config_file="$1/config.status"
    if [ -f "$config_file" ] && \
	   `cat "$config_file" | grep PACKAGE | grep -w apertium-${CNNPAIR} >/dev/null`;
    then
	return 0
    fi
    return 1
}

# Determine the top level directory of apertium language pair based on the value
# set through the option if available or on the value of the current directory
# if the option was not used
#
# Algorithm:
# Try to find the file config.status in the current directory or in any other
# ancestor directories.
path_to_lang_pair_dir() {

    if [ -n "$DATADIR" ]; then
	if $(has_apertium_config_file $DATADIR) ; then
	    path=$DATADIR
	else
	    echo "ERROR: The directory $DATADIR does not look like apertium language pair directory" >&2
	    return 1
	fi
    else
	cwd=`pwd`
	while true; do
	    if $(has_apertium_config_file $cwd) ; then
		path=$cwd
		break
	    fi

	    prev_cwd=$cwd
	    cwd=`dirname $cwd`
	    if [ -z "$cwd" -o $prev_cwd == $cwd ]; then
		break
	    fi
	done
    fi

    if [ ! -d "$path" ]; then
	echo "ERROR: Could not determine language pair directory for '${CNNPAIR}'" >&2
	return 2
    fi

    echo $path
}

# Compute path to apertium-eng or apertium-deu directory
# Arguments:
#   $1 -- numeric code of the language, where:
#          1 means English (lang1 in terms of autogen.sh, --with-lang1 option)
#          2 means German  (lang2 in terms of autogen.sh, --with-lang2 option)
path_to_lang_dir() {
    local ap_var=AP_SRC$1  # ex: AP_SRC1 or AP_SRC2
    local path=$(cat "${LPDIR}/config.status" | grep -w $ap_var | cut -f2 -d= | tr -d '"')

    if [ -z "$path" ]; then
	return 1
    fi

    if [[ $path != /* ]]; then
	# If the path found in cofig.status if relative, it is relative to language pair
	# directory (apertium-eng-deu) rather than to the current directory.
	# Hence fixing the path.
	path=$LPDIR/$path
    fi

    if [ ! -d "$path" ]; then
	return 2
    fi

    echo $path
}

filter_dix() {
    grep -v '<lower>' | grep -v '<cmp>' | grep -v '<cmp-split>' | grep -v 'NON_ANALYSIS' | grep -v 'REGEX' | grep -v ':<:' |
	sed 's/:>:/%/g' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g'
}

# Arguments
#  $1 -- language direction: eng-deu or deu-eng
#  $2 -- path to top directory of source language: path/to/apertium-eng or path/to/apertium-deu
# Examples:
#  > process deu-eng path/to/apertium-deu
#  > process eng-deu path/to/apertium-eng
process() {
    local sl=$(echo $1 | cut -d- -f1) # source language code
    local tl=$(echo $1 | cut -d- -f2) # target language code
    local sl_dir=$2

    local tmpfile=$TMPDIR/tmp_testvoc_$1

    lt-expand            $sl_dir/apertium-$sl.$sl.dix | filter_dix | tee ${tmpfile}_1.txt |
    apertium-pretransfer |
    lt-proc -b           $LPDIR/$sl-$tl.autobil.bin | tee ${tmpfile}_2.txt |
    lrx-proc -m          $LPDIR/$sl-$tl.autolex.bin |
    apertium-transfer -b $LPDIR/apertium-$CNNPAIR.$sl-$tl.t1x $LPDIR/$sl-$tl.t1x.bin | tee ${tmpfile}_3.txt |
    apertium-interchunk  $LPDIR/apertium-$CNNPAIR.$sl-$tl.t2x $LPDIR/$sl-$tl.t2x.bin | tee ${tmpfile}_4.txt |
    apertium-postchunk   $LPDIR/apertium-$CNNPAIR.$sl-$tl.t3x $LPDIR/$sl-$tl.t3x.bin | tee ${tmpfile}_5.txt |
    lt-proc -d           $LPDIR/$sl-$tl.autogen.bin | sed 's/ \.//g' > ${tmpfile}_6.txt

    lt-proc -d           $LPDIR/$tl-$sl.autogen.bin ${tmpfile}_1.txt | sed 's/ \.//g' > ${tmpfile}_0.txt

    # merge results of individual stages
    paste -d _ ${tmpfile}_{0,1,2,5,6}.txt | sed 's/\^.<sent>\$//g' | sed 's/_/ ------>  /g'
}

################################################################################
# MAIN

while [ $# -ne 0 ]; do
    case $1 in
	-h|--help)
	    show_help
	    exit 0
	    ;;
	-d|--datadir|--data-dir)
	    shift
	    DATADIR=$1
	    ;;
	--datadir=*|--data-dir=*)
	    DATADIR=$(echo $1 | cut -d= -f2)
	    ;;
	-d*)
	    DATADIR=$(echo $1 | cut -c3-)
	    ;;
	-*)
	    echo "ERROR: Unrecognized option '$1'" >&2
	    exit 1
	    ;;
	*)
	    break
	    ;;
    esac
    shift
done

if [ $# -ne 1 ]; then
    echo "ERROR: Invalid number of cmd parameters. Strictly one param is allowed. Try --help" >&2
    exit 2
fi

LPDIR=$(path_to_lang_pair_dir) || exit 11
L1DIR=$(path_to_lang_dir 1)    || exit 12
L2DIR=$(path_to_lang_dir 2)    || exit 13

#echo "Language pair directory=$LPDIR" >&2
#echo "Language 1    directory=$L1DIR" >&2
#echo "Language 2    directory=$L2DIR" >&2
#exit 100

if [[ $1 == "deu-eng" ]]; then
    process "$1" "$L2DIR"

elif [[ $1 == "eng-deu" ]]; then
    process "$1" "$L1DIR"

else
    echo "ERROR: Unknown language pair: $1" >&2
    exit 2
fi
