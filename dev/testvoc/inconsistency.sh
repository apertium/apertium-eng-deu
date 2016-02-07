TMPDIR=/tmp
DIR=$1
SRCENG=`cat ../../config.status | grep AP_SRC1 | cut -f2 -d'=' | tr -d '"'`
SRCDEU=`cat ../../config.status | grep AP_SRC2 | cut -f2 -d'=' | tr -d '"'`

if [[ $DIR == "deu-eng" ]]; then

    lt-expand $SRCDEU/apertium-deu.deu.dix | grep -v '<lower>' | grep -v '<cmp>'| grep -v '<cmp-split>'| grep -v 'NON_ANALYSIS'| grep -v 'REGEX' | grep -v ':<:' | sed 's/:>:/%/g' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
    apertium-pretransfer|\
    lt-proc -b ../../deu-eng.autobil.bin | tee $TMPDIR/tmp_testvoc2.txt |\
    lrx-proc -m ../../deu-eng.autolex.bin |\
    apertium-transfer -b ../../apertium-eng-deu.deu-eng.t1x  ../../deu-eng.t1x.bin | tee $TMPDIR/tmp_testvoc3.txt |\
    apertium-interchunk ../../apertium-eng-deu.deu-eng.t2x  ../../deu-eng.t2x.bin | tee $TMPDIR/tmp_testvoc4.txt |\
    apertium-postchunk ../../apertium-eng-deu.deu-eng.t3x  ../../deu-eng.t3x.bin | tee $TMPDIR/tmp_testvoc5.txt |\
    lt-proc -d ../../deu-eng.autogen.bin  | sed 's/ \.//g' > $TMPDIR/tmp_testvoc6.txt

    lt-proc -d ../../eng-deu.autogen.bin $TMPDIR/tmp_testvoc1.txt | sed 's/ \.//g'  > $TMPDIR/tmp_testvoc0.txt

    paste -d _ $TMPDIR/tmp_testvoc0.txt $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc5.txt $TMPDIR/tmp_testvoc6.txt | sed 's/\^.<sent>\$//g' | sed 's/_/ ------>  /g'

elif [[ $DIR == "eng-deu" ]]; then

    lt-expand $SRCENG/apertium-eng.eng.dix | grep -v '<lower>' | grep -v '<cmp>'| grep -v '<cmp-split>'| grep -v 'NON_ANALYSIS'| grep -v 'REGEX' | grep -v ':<:' | sed 's/:>:/%/g' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
    apertium-pretransfer|\
    lt-proc -b ../../eng-deu.autobil.bin | tee $TMPDIR/tmp_testvoc2.txt |\
    lrx-proc -m ../../eng-deu.autolex.bin |\
    apertium-transfer -b ../../apertium-eng-deu.eng-deu.t1x  ../../eng-deu.t1x.bin | tee $TMPDIR/tmp_testvoc3.txt |\
    apertium-interchunk ../../apertium-eng-deu.eng-deu.t2x  ../../eng-deu.t2x.bin | tee $TMPDIR/tmp_testvoc4.txt |\
    apertium-postchunk ../../apertium-eng-deu.eng-deu.t3x  ../../eng-deu.t3x.bin | tee $TMPDIR/tmp_testvoc5.txt |\
    lt-proc -d ../../eng-deu.autogen.bin  | sed 's/ \.//g' > $TMPDIR/tmp_testvoc6.txt

    lt-proc -d ../../deu-eng.autogen.bin $TMPDIR/tmp_testvoc1.txt | sed 's/ \.//g'  > $TMPDIR/tmp_testvoc0.txt

    paste -d _ $TMPDIR/tmp_testvoc0.txt $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc5.txt $TMPDIR/tmp_testvoc6.txt | sed 's/\^.<sent>\$//g' | sed 's/_/ ------>  /g' 

else
	echo "Unsupported mode.";
fi
