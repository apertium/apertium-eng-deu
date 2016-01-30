TMPDIR=/tmp

if [[ $1 = "eng-deu" ]]; then

  echo "==English->German===========================";
  bash inconsistency.sh eng-deu > $TMPDIR/eng-deu.testvoc;
  bash inconsistency-summary.sh $TMPDIR/eng-deu.testvoc eng-deu
  echo ""

elif [[ $1 = "deu-eng" ]]; then

  echo "==German->English===========================";
  bash inconsistency.sh deu-eng > $TMPDIR/deu-eng.testvoc;
  bash inconsistency-summary.sh $TMPDIR/deu-eng.testvoc deu-eng
  echo ""

else
  echo ""
  echo "==unknown language pair=====================";
fi
