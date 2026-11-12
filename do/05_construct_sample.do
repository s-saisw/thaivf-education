use "$datadir/main.dta", clear

keep if hc3==7 | hc3==11
local linenum = 3
include $subprogramdir\sub_expobs.do //keep only if child/grandchild of the head

foreach x in borrow_vf hhmem age_head eduyr_head{
	drop if missing(`x')
}
local linenum = 4
include $subprogramdir\sub_expobs.do //Drop if head is missing age or education data

* relationship to head ------
gen child = cond(hc3 == 7, 1, 0)
gen grandchild = cond(hc3 == 11, 1, 0)

* age group -----
recode age (3/5 = 0) (6/11 = 1) (12/14 = 2) (15/17 = 3) (18/21 = 4) (else = .), generate(age_group)
recode age (4/6 = 0) (7/12 = 1) (13/18 = 3) (19/22 = 4) (else = .), generate(age_group_2)
recode age (4/6 = 0) (7/12 = 1) (13/15 = 2) (16/18 = 3) (19/22 = 4) (else = .), generate(age_group_3)

* employment -----
replace oc1b = . if oc1b == -88
replace oc1b = . if oc1b == -8
replace oc1b = . if age <= 10

replace oc1a = . if oc1a == -99
replace oc1a = . if oc1a == -8
replace oc1a = . if age <= 10

gen working_any = cond(oc1a>5 | (hc_inschool==1 & oc2a>5),1,0) if !missing(oc1a) & !missing(oc2a)
gen working_primary = cond(oc1a>5,1,0) if !missing(oc1a) & !missing(oc2a) // primary
gen working_parttime = cond(hc_inschool==1 & oc2a>5,1,0) if !missing(oc1a) & !missing(oc2a) // inschool but working (secondary)

* GPP ------
gen lgpp = log(gpp)

* observed in 2009 sample ------

sort newid year
bysort newid: egen temp_obslast=max(year)
bysort newid: egen obslast=mean(temp_obslast)
gen obs2009 = (temp_obslast==2009)
drop temp_obslast

* label -----------------------------------------------------------------------

label variable borrow_vf "Borrow from VF"
label variable hc_inschool "In school"
label variable lex_edu "\$\log\$(Edu exp)"
label variable working_any "Emp (any)"
label variable working_primary "Emp (primary)"
label variable working_parttime "Emp (secondary)"
label variable eduyr_head "Head's educ"
label variable age_head "Head's age"
label variable lincome_gross "HH income"
label variable hhmem "No. of HH members"

label define age_groupl 0 "Age 3--5" 1 "Age 6--11" 2 "Age 12--14" 3 "Age 15--17" 4 "Age 18--21"
label values age_group age_groupl

label define femalel 0 "Male" 1 "Female"
label values female femalel

label define malel 0 "Female" 1 "Male"
label values male malel

assert _N == 20542
save "$datadir/sample.dta", replace
