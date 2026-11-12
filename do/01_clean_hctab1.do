forvalues y = 1997/1999 {
	
	if `y' == 1997 {
		local filepath = "1997_rural\data\Updated - j05.dta"
		local idvar hc_id
	}
	else if `y' == 1998 {
		local filepath = "1998_rural\data\Updated - hc_t.dta"
		local idvar hc_id
	}
	else if `y' == 1999 {
		local filepath = "1999_rural\data\Updated - hc2_t.dta"
		local idvar hc_id
	}
	
	use "$rawdatadir\\`filepath'", replace
	rename `idvar' number
	
	gen year = `y'

	save $datadir\04hc_tab1_`y'.dta, replace
}

* 2000 onwards data -----

local filecode 04hc_tab1
local output $datadir\04hc_tab1.dta
include $subprogramdir\sub_merge_townsend_file.do

forvalues y = 1997/1999 {
	append using $datadir\04hc_tab1_`y'.dta
	erase $datadir\04hc_tab1_`y'.dta
}

gen age = hc5
replace age = floor(hc5)
replace age = . if hc5 < 0

gen hc_inschool = 0
replace hc_inschool = 1 if hc6 == 1

gen female = (hc4 == 3)

save $datadir\04hc_tab1.dta, replace

