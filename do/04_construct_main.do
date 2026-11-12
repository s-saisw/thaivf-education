use "$datadir/merge_parent.dta", clear

gen borrow_year = year

gen province = substr(newid, 1, 2)
destring province, replace
replace province = 24 if province == 7
replace province = 31 if province == 27
replace province = 33 if province == 53
replace province = 16 if province == 49

gen district = substr(newid, 1, 4)
gen subdistrict = substr(newid, 1, 6)

gen ampid = substr(newid, 1, 4)
gen tamid = substr(newid, 1, 6)
destring ampid, replace
destring tamid, replace
destring newid, replace

merge m:1 newid borrow_year using "$datadir/borrow_behavior.dta"

foreach x in vf bank infml oth {
	replace borrow_`x' = 0 if _merge == 1
}
drop if _merge==2
drop _merge

destring vilid, replace
merge m:1 vilid borrow_year using "$datadir/village_vf.dta"
keep if _merge==3
drop _merge

merge m:1 newid year using "$datadir/15ex.dta"
drop if _merge==2
drop _merge

merge m:1 newid year using "$datadir/15ex_tab1.dta"
drop if _merge==2
drop _merge

merge m:1 newid year using "$datadir/16in.dta"
drop if _merge==2
drop _merge

merge m:1 newid year using "$datadir/16in_tab1_hhlvl.dta"
drop if _merge==2
drop _merge

merge m:1 newid year using "$datadir/04hc.dta", keepus(hhmem)
drop if _merge==2
drop _merge

merge m:1 province year using "$datadir/99external_GPP_long.dta"
drop if _merge == 2
drop _merge

merge m:1 newid year using "$datadir/04hc.dta"
drop if _merge==2
drop _merge

merge m:1 newid year using "$datadir/12fa.dta"
drop if _merge==2
drop _merge

keep if year<=2009 //Round 2 policy was implemented from Feb 2010 - Dec 2012

local linenum = 1
include $subprogramdir\sub_expobs.do //original sample

sort newid year
bysort newid: egen firstobs = min(year)
drop if firstobs>2001

local linenum = 2
include $subprogramdir\sub_expobs.do //Drop if never observed before 2001

gen temp = year if year<=2001
bysort newid: egen last_before02_obs = max(temp)
drop temp

foreach x in ex_edu income_gross income_net{
	qui su `x' if `x'>0
	replace `x' = `r(min)' if `x'<=0
	gen l`x' = ln(`x')
}

gen ex_edu_3_21= ex_edu/numchild_3_21
gen lex_edu_3_21 = log(ex_edu_3_21)
gen lex_edu_hhmem = log(ex_edu/hhmem)

su income_gross if year==last_before02_obs,d
gen income_high_lastbefore02 = cond(income_gross>`r(p50)',1,0) if year==firstobs
bysort newid: egen temp = mean(income_high_lastbefore02)
replace income_high_lastbefore02 = temp 
drop temp

g age_head = year - yob_head

replace rural = 1 if year<2000

gen male = 1 - female

bysort newid: egen lastobs=max(year)

assert _N== 40895

save "$datadir/main.dta", replace
