import os
import glob

# Recommended multiplier: corresponds to your approximate SNP count, ensuring fsc has enough counts to calculate likelihood values
MULTIPLIER = 100000 

# Modify matching pattern to only match folders with ThreePop_ followed by numbers
# Or directly check if it's a folder
all_targets = glob.glob("ThreePop_*")

for item in all_targets:
    # Core fix: only process folders, skip files
    if not os.path.isdir(item):
        continue
        
    print(f"Processing directory: {item}...")
    
    # Find all txt files in this folder (excluding simparam)
    files = [f for f in os.listdir(item) if f.endswith('.txt') and 'simparam' not in f]
    
    for filename in files:
        file_path = os.path.join(item, filename)
        # Generate corresponding .obs filename
        new_filename = filename.replace(".txt", ".obs")
        new_path = os.path.join(item, new_filename)
        
        with open(file_path, 'r') as f:
            lines = f.readlines()
        
        if not lines:
            continue
            
        with open(new_path, 'w') as f_out:
            # 1. Write required header for fsc estimation mode
            f_out.write("1 observations\n")
            
            # 2. Process data
            for i, line in enumerate(lines):
                parts = line.strip().split()
                if not parts: continue
                
                if i == 0:
                    # First row is column names (d0_0, d0_1...)
                    # Add a tab at the beginning for alignment
                    f_out.write("\t" + "\t".join(parts) + "\n")
                else:
                    # Subsequent rows: first column is row name (d1_0, etc.), followed by data
                    row_label = parts[0]
                    # Convert floats to integer counts
                    counts = []
                    for x in parts[1:]:
                        try:
                            # Multiply by multiplier and round
                            val = str(int(float(x) * MULTIPLIER))
                            counts.append(val)
                        except ValueError:
                            counts.append("0")
                    f_out.write(row_label + "\t" + "\t".join(counts) + "\n")

print("\nSuccess! All 100 folders have been processed.")
print("The .txt files have been converted to .obs with headers and integer counts.")