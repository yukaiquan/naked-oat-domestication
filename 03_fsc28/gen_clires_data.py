import pandas as pd
import numpy as np

# 1. Read 100 best results
# sep='\s+' automatically handles spaces and tabs
try:
    df = pd.read_csv('bootstrap_best_100.txt', sep='\s+')
except Exception as e:
    print(f"Error reading file: {e}")
    exit()

# 2. Calculate hidden key parameter T2 (T1 + TDELTA)
# This is key data for showing wild ancestor divergence time in the paper
if 'T1' in df.columns and 'TDELTA' in df.columns:
    df['T2'] = df['T1'] + df['TDELTA']

# 3. Filter out likelihood value columns
cols_to_drop = ['MaxEstLhood', 'MaxObsLhood']
params_df = df.drop(columns=[c for c in cols_to_drop if c in df.columns])

# 4. Calculate 2.5%, 50%(median), 97.5% quantiles
ci_lower = params_df.quantile(0.025)
median_val = params_df.median()
ci_upper = params_df.quantile(0.975)

# 5. Integrate results
result_ci = pd.DataFrame({
    '95_CI_Lower': ci_lower,
    'Median_Bootstrap': median_val,
    '95_CI_Upper': ci_upper
})

# 6. Save to CSV for easy import into Excel
result_ci.to_csv('Parameters_95CI_Final.csv')

print("\n" + "="*50)
print("   95% CONFIDENCE INTERVALS (FINAL RESULTS)")
print("="*50)
print(result_ci)
print("="*50)
print("\nResults saved to 'Parameters_95CI_Final.csv'")