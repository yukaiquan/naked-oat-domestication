PREFIX="ThreePop"
FSC_PATH="/publicssd/share/h13713/soft/fsc28_linux64/fsc28"
PAR_FILE="${PREFIX}.par"

# 1. Ensure original configuration files exist
if [ ! -f "$PAR_FILE" ] || [ ! -f "${PREFIX}.tpl" ] || [ ! -f "${PREFIX}.est" ]; then
    echo "Error: Cannot find ${PREFIX}.par, .tpl or .est files!"
    exit 1
fi

echo "Starting to clean old folders and regenerate 100 Bootstrap datasets..."

for i in {1..100}
do
    echo "Processing dataset $i..."
    
    # Clean and create a clean directory
    rm -rf ${PREFIX}_$i
    mkdir -p ${PREFIX}_$i
    
    # Generate a set of simulated data (-i specifies par, -n 1 generates one set, -m multi-population, -q quiet)
    $FSC_PATH -i $PAR_FILE -n 1 -m -s 0 -q
    
    # fsc generated files are in ${PREFIX}/ directory by default, move them to our working directory ${PREFIX}_$i/
    # Note: moving .txt files here
    mv ${PREFIX}/*.txt ${PREFIX}_$i/
    rm -rf ${PREFIX}/  # Remove temporary empty directory created by fsc
    
    # Copy configuration files needed for re-estimation
    cp ${PREFIX}.tpl ${PREFIX}.est ${PREFIX}_$i/
done

echo "All folders are ready. Running format conversion script (txt -> obs)..."

# 2. Run your previous Python conversion script (ensure it's in current directory)
# This script converts .txt to integer .obs files with '1 observations' header
python rename_txt2obs.py

echo "--- Preparation complete! ---"
PREFIX="ThreePop"
FSC_BIN="/publicssd/share/h13713/soft/fsc28_linux64/fsc28"

# Clear old task file
> boot_sbatch.tsv

for i in {1..100}
do
    # Core fix:
    # 1. Use ( ... ) & inside the loop to put each run in background for parallel execution
    # 2. Use wait command after loop to ensure all 10 background processes complete before task is done
    CMD="cd ${PREFIX}_$i && "
    CMD+="for r in {1..30}; do "
    CMD+="(mkdir -p run_\$r && cp ${PREFIX}.tpl ${PREFIX}.est *.obs run_\$r/ && cd run_\$r && $FSC_BIN -t ${PREFIX}.tpl -e ${PREFIX}.est -m -M -n 100000 -L 40 -s 0 -q -0) & "
    CMD+="done && wait"
    
    echo -e "bt$i\t$CMD" >> boot_sbatch.tsv
done

echo "Generated boot_sbatch.tsv with 100 parallelized tasks."

python /publicssd/share/h13713/soft/sbatch_script.py -i boot_sbatch.tsv -p com300 -m 164G -N 1 -n 30 -e bwa


PREFIX="ThreePop"

# 1. Extract header (Header)
# Path modified to match your current deep structure
head -n 1 ${PREFIX}_1/run_1/${PREFIX}/${PREFIX}.bestlhoods > bootstrap_best_100.txt

# 2. Loop to extract the best value from 10 runs for each dataset
for i in {1..100}
do
    # Check if this Bootstrap folder exists
    if [ -d "${PREFIX}_$i" ]; then
        # Core logic:
        # Use wildcard to find all bestlhoods in run_1~10 under this folder
        # Path: ThreePop_i/run_*/ThreePop/ThreePop.bestlhoods
        # grep -v excludes header -> sort -k18nr sorts by column 18 (MaxEstLhood) in descending order -> head -n 1 takes the maximum
        best_line=$(grep -v "MaxEstLhood" ${PREFIX}_$i/run_*/${PREFIX}/${PREFIX}.bestlhoods | sort -k18nr | head -n 1 | cut -d: -f2-)
        
        if [ -n "$best_line" ]; then
            echo "$best_line" >> bootstrap_best_100.txt
        else
            echo "Warning: Dataset $i has no results at the expected path."
        fi
    fi
done

echo "Done! Total valid bootstrap results: $(grep -v "MaxEstLhood" bootstrap_best_100.txt | wc -l)"

python gen_clires_data.py
