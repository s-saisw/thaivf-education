* ------------------------------------------------------------------------------
**# Table 6 : Heterogeneity by various things
* ------------------------------------------------------------------------------

use "$datadir/sample_fixed.dta", clear

merge m:1 vilid using "$datadir/bank_access_1997"
drop if _merge==2
drop _merge

merge m:1 newid year using "$datadir/05oc_tab1_hhlvl"
drop if _merge==2
drop _merge

keep if samp_chil == 1

preserve

keep if year == last_before02_obs

gen numchild_cat_pre = 1 if numchild_3_21 <= 2
replace numchild_cat_pre = 2 if numchild_3_21 >= 3

keep newid numchild_cat_pre

gcollapse numchild_cat_pre, by(newid)

save "$datadir/numchild_pre.dta", replace

restore

* effect by bank access --------------------------------------------------------

foreach i in 1 0 {
	
	local gr1 "Bank in 1997"
	local gr0 "No bank in 1997"
	
	reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if bank_in_village == `i', absorb(newid) cluster(vilid)
	eststo
	sum hc_inschool if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local gr "`gr`i''"
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
	
}

* Effects by number of children in households ----------------------------------

merge m:1 newid using $datadir/numchild_pre.dta
replace numchild_cat_pre = 1 if _merge == 1 //no children means little constraint

foreach i in 1 2 {
	
	local gr1 "\$\leq\$ 2 children"
	local gr2 "\$\geq\$ 3 children"
	
	reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if numchild_cat_pre == `i', absorb(newid) cluster(vilid)
	eststo
	sum hc_inschool if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local gr "`gr`i''"
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
	
}

* Effects by income level in the village ---------------------------------------

bysort vilid year: egen vil_incmed = median(income_net) if year <= 2001 //compared to the median household income in the village
gen temp = 1 if year <= 2001 & income_net <= vil_incmed
replace temp = 0 if year <= 2001 & income_net > vil_incmed
bysort newid: egen lowinc = mean(temp)
drop temp 

egen lowinc_cat = cut(lowinc), group(2)
tab lowinc_cat

forvalues i = 1/2{
	
	local samp1 lowinc_cat == 0
	local samp2 lowinc_cat == 1
	
	local gr1 "High HH income"
	local gr2 "Low HH income"
	
	reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if `samp`i'', absorb(newid) cluster(vilid)
	eststo
	sum hc_inschool if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local gr "`gr`i''"
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
	
}

local keepvar c.vilsize*#c.post 
local statlist N level gr samp sampage depvarmean 
local statlab `"Observations "Analysis level" Group Sample Age "Dep. var. mean if post = 0" "'
local statfmt %15.0fc 3 %15.2fc
local filename $outdir\inschool_did_bybankaccess.tex
include $subprogramdir\sub_create_table.do
