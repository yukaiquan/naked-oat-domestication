#!/bin/bash

# --- Parameter settings ---
VCF="dxl_gbs_maf005_ID.5_ld_50_10_0.5.vcf.gz"              # Your VCF filename
STRAT="samples_groups.txt"       # Your sample-population correspondence file
EASYSFS="python /publicssd/share/h13713/soft/easySFS/easySFS.py"

# --- 1. Define population names and corresponding projection values (order must match exactly) ---
pops=(
  "G4" "G3" "G2"
)

projs=(56 80 80)

num_pops=${#pops[@]}

# Create main output directory
mkdir -p fsc_obs_files

echo "Starting to process $num_pops populations..."

# --- 2. Loop to generate SFS ---
for (( i=0; i<$num_pops; i++ )); do
    pop1=${pops[$i]}
    proj1=${projs[$i]}

    # A. Generate 1D SFS (for estimating Ne of this population)
    echo "Processing 1D: $pop1 (proj: $proj1)"
    grep -w "$pop1" $STRAT > tmp_indiv.txt
    $EASYSFS -i $VCF -p tmp_indiv.txt --proj $proj1 -a -f -o "output_1D_${pop1}" > /dev/null
    
    # Copy 1D results to main directory
    cp output_1D_${pop1}/fastsimcoal2/*MAF*.obs fsc_obs_files/ 2>/dev/null

    # B. Generate 2D SFS (pairwise combinations, for estimating divergence time)
    for (( j=i+1; j<$num_pops; j++ )); do
        pop2=${pops[$j]}
        proj2=${projs[$j]}
        
        echo "  Processing 2D: ${pop1} & ${pop2} (projs: $proj1,$proj2)"
        
        # Extract samples from these two populations
        grep -E -w "$pop1|$pop2" $STRAT > tmp_pair.txt
        
        # Run easySFS
        $EASYSFS -i $VCF -p tmp_pair.txt --proj $proj1,$proj2 -a -f -o "output_2D_${pop1}_${pop2}" > /dev/null
        
        # Copy 2D results to main directory
        cp output_2D_${pop1}_${pop2}/fastsimcoal2/*jointMAF*.obs fsc_obs_files/ 2>/dev/null
    done
done

rm tmp_indiv.txt tmp_pair.txt
echo "All tasks completed! All .obs files have been placed in the fsc_obs_files folder."
