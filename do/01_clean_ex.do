forvalues y = 1997/1999 {
	
	if `y' == 1997 {
		local filepath = "1997_rural\data\Updated - master.dta"
	}
	else if `y' == 1998 {
		local filepath = "1998_rural\data\Updated - master.dta"
	}
	else if `y' == 1999 {
		local filepath = "1999_rural\data\Updated - master.dta"
	}
	
	use "$rawdatadir\\`filepath'", replace
	keep newid ex5-ex9
	
	gen year = `y'

	save $datadir\15ex_`y'.dta, replace
}

local filecode 15ex
local output $datadir\15ex.dta
include $subprogramdir\sub_merge_townsend_file.do

forvalues y = 1997/1999 {
	append using $datadir\15ex_`y'.dta
	erase $datadir\15ex_`y'.dta
}

drop ex10 rural

forvalues i = 5/9 {
	replace ex`i' = 0 if ex`i' < 0
	replace ex`i' = 0 if missing(ex`i')
}

rename ex5 ex_house
rename ex6 ex_vehicle
rename ex7 ex_edu
rename ex8 ex_cloth
rename ex9 ex_eatout

destring newid, replace

gcollapse (sum) ex_*, by(newid year)

save `output', replace
