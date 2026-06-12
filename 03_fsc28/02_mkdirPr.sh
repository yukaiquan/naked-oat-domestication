mkdir G2_G3_G4_3pop
cd G2_G3_G4_3pop
# 1D SFS
cp ../output_1D_G2/fastsimcoal2/*_MAFpop0.obs ./ThreePop_MAFpop0.obs
cp ../output_1D_G3/fastsimcoal2/*_MAFpop0.obs ./ThreePop_MAFpop1.obs
cp ../output_1D_G4/fastsimcoal2/*_MAFpop0.obs ./ThreePop_MAFpop2.obs

# 2D SFS
# G3(1) vs G2(0)
cp ../output_2D_G2_G3/fastsimcoal2/*_jointMAFpop1_0.obs ./ThreePop_jointMAFpop1_0.obs
# G4(2) vs G2(0)
cp ../output_2D_G2_G4/fastsimcoal2/*_jointMAFpop1_0.obs ./ThreePop_jointMAFpop2_0.obs
# G4(2) vs G3(1)
cp ../output_2D_G3_G4/fastsimcoal2/*_jointMAFpop1_0.obs ./ThreePop_jointMAFpop2_1.obs
