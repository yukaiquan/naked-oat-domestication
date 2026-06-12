#!/bin/bash

# Define prefix, must match .tpl and .est file names
PREFIX="ThreePop"

for i in {1..50}
do
    # Run fsc28
    # -m: MAF folded data, -M: maximum likelihood estimation, -n: number of simulations, -L: number of iterations, -c: number of threads, -0: ignore monomorphic sites
    echo -e "dxl$i\tmkdir run_$i && cp ${PREFIX}.tpl ${PREFIX}.est *.obs run_$i/ && cd run_$i && /publicssd/share/h13713/soft/fsc28_linux64/fsc28 -t ${PREFIX}.tpl -e ${PREFIX}.est -m -M -n 200000 -L 50 -c 1 -s 0 -q -0"
done  > fsc_sbatch.tsv

python /public/share/h13713/soft/sbatch_script.py -i fsc_sbatch.tsv -p com300 -m 4G -N 1 -n 1 -e bwa

# Extract and summarize likelihood values from all results, sort in descending order
sh /publicssd/share/h13713/soft/fsc28_linux64/fsc-selectbestrun.sh 