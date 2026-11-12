forvalues y = 1997/1999 {
	
	if `y' == 1997 {
		local filepath = "1997_rural/data/j17.dta"
	}
	else if `y' == 1998 {
		local filepath = "1998_rural/fa.dta"
	}
	else if `y' == 1999 {
		local filepath = "1999_rural/data/fa.dta"
	}
	
	use "$rawdatadir/`filepath'", replace
	
	gen year = `y'
	
	if (`y' == 1998 | `y' == 1999) {
		
		forvalues i = 1/5 {
			rename fa140`i' fa14_`i'
		}
	
	}
	

	save "$datadir/12fa_`y'.dta", replace
}

local filecode 12fa
local output $datadir\12fa.dta
include $subprogramdir\sub_merge_townsend_file.do

forvalues y = 1997/1999 {
	append using $datadir\12fa_`y'.dta
	erase $datadir\12fa_`y'.dta
}

gen hh_agri = 1 if fa1 == 1
replace hh_agri = 0 if fa1 == 3

keep hh_agri newid year
gcollapse (max) hh_agri, by(newid year)

destring newid, replace

save `output', replace
