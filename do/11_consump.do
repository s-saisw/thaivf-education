* ------------------------------------------------------------------------------
**# Table 9
* ------------------------------------------------------------------------------

use $datadir/sample_fixed_hh.dta, replace

keep if samp_child == 1

label variable vilsize_inv "1/village size"
label variable post "post"

gen ex_total = ex_basic + ex_disc + ex_maint

foreach y in total basic disc maint {
	gen ex_`y'_x1000 = ex_`y'/1000
}

label variable ex_total_x1000 "\shortstack{Total\\(excl edu)\\(1000 Baht)}"
label variable ex_basic_x1000 "\shortstack{Basic needs\\(1000 Baht)}"
label variable ex_disc_x1000 "\shortstack{Discretionary\\(1000 Baht)}"
label variable ex_maint_x1000 "\shortstack{Maintenance\\(1000 Baht)}"

foreach x in total basic disc maint {
	
	reghdfe ex_`x'_x1000 c.vilsize_inv##c.post i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos if samp_child == 1, absorb(newid) cluster(vilid) 
	eststo
	
	sum ex_`x'_x1000  if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Child"
	estadd local level "Household"
}

local keepvar c.vilsize*#c.post 
local statlist N level samp depvarmean
local statlab `"Observations "Analysis level" Sample "Dep. var. mean if post=0" "'
local statfmt %15.0fc 3 3 %15.2fc
local filename $outdir/consump.tex
include $subprogramdir\sub_create_table.do