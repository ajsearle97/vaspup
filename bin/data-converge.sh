#! /bin/bash

rm -f data # delete data file if exists

n=0
for i in */CONTCAR; do

  folder=${i/CONTCAR/}
  name=${folder//[\/]/} # folder name without slashes

  n_atoms=$(sed '7q;d' $i | awk '{sum=0; for (i=1; i<=NF; i++) { sum+= $i } print sum}') # sum over row 7 of the CONTCAR
  energy_total=$(grep TOTEN $folder/OUTCAR | awk '{print $5}' | tail -1 | tr -d '\n') # tr is to remove the trailing newline
  energy_per_atom=$(echo "scale = 7; $energy_total / $n_atoms" | bc)

  echo -n -e "$name\t$energy_total\t$energy_per_atom" >> data

  if [ "$n" -ne "0" ]; then # the first line will not have a difference therefore ignore it
    energy_prev=$(sed "${n}q;d" data | awk '{print $3}')
    energy_diff=$(echo "scale = 7; ($energy_prev - $energy_per_atom) * 1000" | bc)

    echo -n -e "\t$energy_diff" >> data
  fi

  echo -n -e "\n" >> data
  let n=n+1
done
