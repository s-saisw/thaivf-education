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
	
	gen year = `y'
	rename hc1 hhmem
	keep newid year hhmem

	save $datadir\04hc_`y'.dta, replace
}

local filecode 04hc
local output $datadir\04hc.dta
include $subprogramdir\sub_merge_townsend_file.do
rename hc1 hhmem
keep newid year hhmem

forvalues y = 1997/1999 {
	append using $datadir\04hc_`y'.dta
	erase $datadir\04hc_`y'.dta
}

replace hhmem = . if hhmem == -88

destring newid, replace
gcollapse (sum) hhmem, by(newid year)

save `output', replace
