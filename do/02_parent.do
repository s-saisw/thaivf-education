* children living inside the household ---------------------------------------

use $datadir\04hc_tab1.dta, replace
merge 1:1 newid number year using $datadir\05oc_tab1.dta
drop if _merge == 2

replace oc_inschool_main = hc_inschool if _merge == 1 & age <= 10
replace oc_inschool_any = hc_inschool if _merge == 1 & age <= 10
drop _merge

* oc_school_and_work is missing for 10 yo and under since occupation data is not observed

assert _N == 150092
save $datadir\hcoc.dta, replace


use "$datadir/hcoc", clear

gen temp = hc3 if hc3==1
bysort newid year: egen N = total(temp)
drop if N>1 // drop hhs with multiple heads
drop temp N

replace age = floor(age) //get rid of .5 in age variables
gen yob = year - age

include $subprogramdir/sub_gen_eduyr.do

assert _N == 149961

save "$datadir/hcoc_educ", replace


use "$datadir/hcoc_educ", clear
keep newid year hc* oc* yob eduyr
bysort newid year hc3: gen n=_n
keep if n==1
drop n // Assume: for merging, only one "son"/"daughter-in-law" in the household (cuz cannot identify father v.s. uncle, etc.)
foreach y in father mother head{
	foreach x in hc3 hc4 hc7 oc1b yob eduyr{
		gen `x'_`y' = `x'
	}
}

keep newid year *father *mother *head
save "$datadir/hc_parent.dta", replace



use "$datadir/hcoc_educ", clear

gen temp = hc4 if hc3==1
bysort newid year: egen sex_head = mean(temp)
drop temp

gen hc3_father = .
gen hc3_mother = .
replace hc3_father = 13 if hc3==1 | hc3==5
replace hc3_mother = 13 if hc3==1 | hc3==5
replace hc3_father = 1 if hc3==7 & sex_head==1
replace hc3_father = 3 if hc3==7 & sex_head==3
replace hc3_mother = 1 if hc3==7 & sex_head==3
replace hc3_mother = 3 if hc3==7 & sex_head==1
replace hc3_father = 7 if hc3==11
replace hc3_mother = 9 if hc3==11 // Assume: fathers are "son"; mothers are "daughter-in-law"
gen hc3_head=1

gen hc4_father=1
gen hc4_mother=3

merge m:1 newid hc3_head year using "$datadir/hc_parent.dta", keepus(*_head)
drop if _merge==2
drop _merge

gen age_3_21 = cond(age>2 & age<22, 1, 0)
bysort newid year: egen numchild_3_21 = total(age_3_21)

bysort newid year: egen numchild_inschool = total(hc_inschool)

assert _N == 149961

save "$datadir/merge_parent.dta", replace

* children living outside the household ---------------------------------------

local filecode 07kh_tab1
local output $datadir/07kh_tab1.dta
include $subprogramdir/sub_merge_townsend_file.do

drop if missing(kh4)

local x "child"
rename kh4a `x'_sex
rename kh4 `x'_age
rename kh5 `x'_edu

save "$datadir/childout.dta", replace
