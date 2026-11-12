forvalues y = 1997/1999 {
	
	if `y' == 1997 {
		local filepath = "1997_rural\data\Updated - j07tab.dta"
		local idvar oc_id
	}
	else if `y' == 1998 {
		local filepath = "1998_rural\data\Updated - oc_t.dta"
		local idvar oc_id
	}
	else if `y' == 1999 {
		local filepath = "1999_rural\data\Updated - oc1.dta"
		local idvar hc_id
	}
	
	use "$rawdatadir\\`filepath'", replace
	rename `idvar' number
	
	gen year = `y'

	save $datadir\05oc_tab1_`y'.dta, replace
}

* 2000 onwards data -----

local filecode 05oc_tab1
local output $datadir\05oc_tab1.dta
include $subprogramdir\sub_merge_townsend_file.do

forvalues y = 1997/1999 {
	append using $datadir\05oc_tab1_`y'.dta
	erase $datadir\05oc_tab1_`y'.dta
}

gen oc_inschool_main = 0
replace oc_inschool_main = 1 if oc1a == 3

gen oc_inschool_any = 0
replace oc_inschool_any = 1 if oc1a == 3
replace oc_inschool_any = 1 if oc2a == 3

gen oc_school_and_work = 0
replace oc_school_and_work = 1 if oc1a == 3 & (oc2a != 3 & oc2a != 1 & oc2a != 0 & oc2a != 5) 

gen oc_vilpos = 1 if !missing(oc3)
replace oc_vilpos = 0 if oc3 == "A"
replace oc_vilpos = 0 if oc3 == "IV(invalid value)"
replace oc_vilpos = 0 if oc3 == "NA(not applicable)"
replace oc_vilpos = 0 if oc3 == "MI(missing value)"
replace oc_vilpos = 0 if strpos(oc3, "DK")

save $datadir\05oc_tab1.dta, replace

* Village position at HH level -------------------------------------------------

use $datadir\05oc_tab1.dta, replace

gcollapse (max) oc_vilpos, by(newid year)
destring newid, replace

save $datadir/05oc_tab1_hhlvl.dta, replace