use "$datadir/sample_fixed.dta", clear

keep if samp_child == 1 | samp_grandchild == 1
assert _N == 13480

merge m:1 newid year using "$datadir/05oc_tab1_hhlvl"
drop if _merge==2
drop _merge

tab age_group, gen(age_group_cat)

collapse (sum) age_group_cat* child grandchild (mean) ex_* numchild_3_21 lex_edu_hhmem lex_edu_3_21 lincome_gross income_gross inc_agribiz vilsize_inv vilsize post borrow_rate_pre female lgpp samp_child oc_vilpos borrow_vf borrow_vf_year_first income_net eduyr_head (max) hh_agri obs2009, by(newid vilid year ampid province)

forvalues i=1/5{
	gen age_share_cat`i' = age_group_cat`i'/numchild_3_21
}

* educational expenditures ------------------

gen ex_edu_potential = age_group_cat1*3523 + age_group_cat2*2367 + age_group_cat3*3432 + age_group_cat4*5183 + age_group_cat5*10781

gen ex_edu_comparable = (ex_edu-ex_edu_potential)/ex_edu_potential

* other consumption expenditures ------------
foreach x in house vehicle cloth eatout rice dairy meat alcohol gas ceremony {
	replace ex_`x' = 0 if missing(ex_`x')
}

gen ex_maint = ex_house + ex_vehicle
gen ex_basic = ex_eatout + (ex_rice + ex_dairy + ex_meat + ex_gas)*12 + ex_cloth
gen ex_disc = (ex_alcohol + ex_ceremony)*12

foreach x in maint basic disc {
	gen lex_`x' = log(ex_`x' + 1)
}

label variable lex_maint "log(1 + maintenance)"
label variable lex_basic "log(1 + basic needs)"
label variable lex_disc "log(1 + discretionary)"


* household business activities -------------

merge m:1 newid year using "$datadir/13ba_tab1.dta", keepus(ba4 ba9 ba10 ba12)

gen hhbiz = 1 if _merge == 3
replace hhbiz = 0 if _merge == 1
drop if _merge==2
drop _merge

replace hh_agri = 0 if missing(hh_agri)

gen numworker = ba9 if ba9>0
gen numworker_hh = ba10 if ba10>=0 & numworker!=.
replace numworker_hh = numworker if numworker_hh>numworker & !missing(numworker_hh)
replace numworker = numworker_hh if missing(numworker)
assert numworker >= numworker_hh if !missing(numworker)

merge m:1 newid year using "$datadir/13ba_tab2.dta"
drop if _merge == 2
drop _merge
gen capital = ba18
replace capital = 0 if capital < 0

gen ex_edu_3_21_k = ex_edu_3_21/1000

label variable vilsize_inv "1/village size"
label variable post "post"
label variable ex_edu_3_21_k "\shortstack{Edu expense/child\\(1000 Baht)}"
label variable lex_edu_3_21 "log(Edu expense/child)"
label variable ex_edu_comparable "EEG"

save $datadir/sample_fixed_hh.dta, replace

* ------------------------------------------------------------------------------
**# Table 7: Effect of access to the Village Fund on household's educational expenditure
* ------------------------------------------------------------------------------

keep if samp_child == 1
gen lvilsize = log(vilsize)

reghdfe ex_edu_comparable c.vilsize_inv##c.post i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos, absorb(newid) cluster(vilid)
eststo
sum ex_edu_comparable  if e(sample) & post == 0
estadd scalar depvarmean = r(mean)
estadd local samp "Child"
estadd local level "Household"

sum ex_edu_potential if e(sample) & post == 0 //10620.89
di _b[c.vilsize_inv#c.post]*r(mean)/100

reghdfe ex_edu_3_21_k c.vilsize_inv##c.post i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos, absorb(newid) cluster(vilid)
eststo
sum ex_edu_3_21_k  if e(sample) & post == 0
estadd scalar depvarmean = r(mean)
estadd local samp "Child"
estadd local level "Household"

local keepvar c.vilsize*#c.post 
local statlist N level samp  depvarmean
local statlab `"Observations "Analysis level" Sample  "Dep. var. mean if post=0" "'
local statfmt %15.0fc 3 3 %15.2fc
local filename $outdir/eduexp_comparable.tex
include $subprogramdir\sub_create_table.do

* ------------------------------------------------------------------------------
**# Table B4: robustness checks
* ------------------------------------------------------------------------------

reghdfe ex_edu_comparable c.lvilsize##c.post i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos, absorb(newid) cluster(vilid)
estimates save $outdir\exedugap_rc0, replace
sum ex_edu_comparable if e(sample)
preserve
clear
set obs 1
generate exedugap_depvarmean = r(mean)
save $outdir\exedugap_depvarmean_rc0.dta, replace
restore

reghdfe ex_edu_comparable c.vilsize_inv##c.post i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos if obs2009 == 1, absorb(newid) cluster(vilid)
estimates save $outdir\exedugap_rc2, replace
sum ex_edu_comparable if e(sample)
preserve
clear
set obs 1
generate exedugap_depvarmean = r(mean)
save $outdir\exedugap_depvarmean_rc2.dta, replace
restore


