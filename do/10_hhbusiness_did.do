use "$datadir/sample_fixed_hh.dta", replace

label variable numworker "Labor"
label variable numworker_hh "Family labor"
label variable vilsize_inv "1/village size"
label variable post "post"
label variable hhbiz "In business"
label variable hh_agri "In farming"

keep if samp_child == 1

gen hh_bizagri = 1 if hh_agri == 1
replace hh_bizagri = 1 if hhbiz == 1
replace hh_bizagri = 0 if hh_agri == 0 & hhbiz == 0
label variable hh_bizagri "\shortstack{In business \\farming}"

gen inc_agribiz_10k = inc_agribiz/10000
winsor2 inc_agribiz_10k, cut(1 99)

replace capital = . if missing(numworker_hh)
gen capital_10k = capital/10000
winsor2 capital_10k, cut(1 99)

label variable inc_agribiz_10k_w "\shortstack{Farm/business \\ income}"
label variable capital_10k_w "Capital"

save "$datadir/sample_fixed_hhbiz.dta", replace

* ------------------------------------------------------------------------------
**# Table 8
* ------------------------------------------------------------------------------

use "$datadir/sample_fixed_hhbiz.dta", replace

foreach y in hh_agri hhbiz hh_bizagr {
	
	local regoption absorb(newid) cluster(vilid)
	
	reghdfe `y' c.vilsize_inv##c.post i.year lgpp age_group_cat* female c.borrow_rate_pre#i.year oc_vilpos, `regoption'
	eststo est`y'
	estadd local samp "Child"
	sum `y' if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local level "Household"
}


foreach y in numworker capital_10k_w inc_agribiz_10k_w {
	
	local regoption absorb(newid) cluster(vilid)
	
	quietly: reghdfe `y' c.vilsize_inv##c.post i.year ///
	lgpp age_group_cat* female c.borrow_rate_pre#i.year oc_vilpos if !missing(numworker), `regoption'
	eststo est`y'
	
	estadd local samp "Child"
	estadd local level "Household"
	
	sum `y' if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	
}

estimates use "$outdir\famworker"
eststo estfamworker
estadd local samp "Child"
estadd local level "Individual"
estadd local sampage "11--21"

preserve
use "$outdir\famworker_depvarmean.dta", replace
sum famworker_depvarmean
restore

gen family_worker = . //fake var for labelling
label variable family_worker "Family worker"

estadd scalar depvarmean = r(mean)

local estorder esthh_agri esthhbiz esthh_bizagr estnumworker estcapital_10k_w estinc_agribiz_10k_w estfamworker 
local keepvar c.vilsize_inv#c.post 
local statlist N level samp sampage depvarmean
local statlab `" Observations "Analysis level" Sample Age "Dep. var. mean if post = 0"  "'
local statfmt %15.0fc 3 3 %15.2fc 
local filename "$outdir\hhactivity_all.tex"
include "$subprogramdir\sub_create_table"