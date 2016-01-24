if [[ $1 = "eng-deu" ]]; then

  echo "==English->German===========================";
  bash inconsistency.sh eng-deu > /tmp/eng-deu.testvoc;
  bash inconsistency-summary.sh /tmp/eng-deu.testvoc eng-deu
  echo ""

elif [[ $1 = "deu-eng" ]]; then

  echo "==German->English===========================";
  bash inconsistency.sh deu-eng > /tmp/deu-eng.testvoc;
  bash inconsistency-summary.sh /tmp/deu-eng.testvoc deu-eng
  echo ""

else
  echo ""
  echo "==unknown language pair=====================";
fi

