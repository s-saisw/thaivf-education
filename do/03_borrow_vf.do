use "$datadir/17bl_tab1.dta", clear

collapse (max) borrow_vf borrow_bank borrow_infml borrow_oth (sum) borrow_amount borrow_vf_amount borrow_bank_amount borrow_infml_amount borrow_oth_amount, by(newid borrow_year)

gen vilid = substr(newid, 1, 8)
destring vilid, replace
destring newid, replace
xtset newid borrow_year
gen borrow_vf_l1 = l1.borrow_vf
gen borrow_vf_l2 = l2.borrow_vf
gen borrow_vf_year = borrow_year if borrow_vf==1
bysort newid: egen borrow_vf_year_first = min(borrow_vf_year)

save "$datadir/borrow_behavior.dta", replace

use "$datadir/keyinf_03vh2.dta", clear
duplicates drop
g borrow_year = year
destring vilid, replace
g vfperhh = 10^6/hh_count
drop if missing(vfperhh)
g vfperc = 10^6/pop
drop if missing(vfperc)
g postprogram = cond(borrow_year>2001,1,0)

gen temp = year if year<=2001
bysort vilid: egen vil_last_before02 = max(temp)
drop temp

gen hh_count_last_before02 = hh_count if year == vil_last_before02
bysort vilid: egen temp = mean(hh_count_last_before02)
replace hh_count_last_before02 = temp
drop temp

qui tab borrow_year if borrow_year>2001, generate(borrow_year)

forvalues i=1/`r(r)'{
	replace borrow_year`i'=0 if missing(borrow_year`i')
}

xtset vilid borrow_year

assert _N == 2124

save "$datadir/village_vf.dta", replace
