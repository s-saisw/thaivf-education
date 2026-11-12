import delimited "$sesdir\Microdata SES 2543 REC01.csv", clear
save $datadir\ses_hhchar.dta, replace

import delimited "$sesdir\Microdata SES 2543 REC02.csv", clear
save $datadir\ses_rec2.dta, replace

import delimited "$sesdir\Microdata SES 2543 REC06.csv", clear
save $datadir\ses_rec6.dta, replace

import delimited "$sesdir\Microdata SES 2543 REC09.csv", clear
save $datadir\ses_rec9.dta, replace

* household structure ---------------------------------------------------------

use $datadir\ses_rec2.dta, replace

gen age = b04

gen age_group = 1 if age <= 2
replace age_group = 2 if age >= 3 & age <= 5
replace age_group = 3 if age >= 6 & age <= 11
replace age_group = 4 if age >= 12 & age <= 14
replace age_group = 5 if age >= 15 & age <= 17
replace age_group = 6 if age >= 18 & age <= 21
replace age_group = 7 if age >= 22 & !missing(age)

tab age_group, gen(age_group_d)

gcollapse (sum) age_group_d* ,by(new_hh_n)

save $datadir\ses_rec2_hhlevel.dta, replace

* merge data ------------------------------------------------------------------

log using $logdir\ses_expense.log, replace

use $datadir\ses_hhchar.dta, replace
merge 1:1 new_hh_n using $datadir\ses_rec2_hhlevel.dta
drop _merge 
merge 1:1 new_hh_n using $datadir\ses_rec9.dta
drop _merge 

gen exp_edu = j171

forvalues g = 1/6 {

	preserve
	quietly: keep if age_group_d`g' != 0
	
	forvalues i = 1/`=`g'-1' {
		quietly: drop if age_group_d`i' != 0
	}
	
	forvalues i = `=`g'+1'/6 {
		quietly: drop if age_group_d`i' != 0
	}
	
	di "--------------group `g'---------------"
	gen exp_edu_pchild = (exp_edu/age_group_d`g')*12
	sum exp_edu_pchild, detail
	
	gen exp_edu_pchild_zero = (exp_edu_pchild == 0)
	sum exp_edu_pchild_zero
	
	sum exp_edu_pchild if exp_edu_pchild > 0, detail 
	
	gen agegr = `g'
	save $datadir\ses_agegr`g'.dta, replace
	
	restore
}

save $datadir\ses_hhchar.dta, replace

log close