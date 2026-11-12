local sampobs = _N
preserve 
clear
set obs 1
gen sampobs = `sampobs'
save $outdir\sampconst_obs`linenum'.dta, replace
restore