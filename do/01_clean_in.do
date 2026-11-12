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
	keep newid in1 in6 
	
	gen year = `y'

	save $datadir\16in_`y'.dta, replace
}

local filecode 16in
local output $datadir\16in.dta
include $subprogramdir\sub_merge_townsend_file.do

keep newid year in1 in6

forvalues y = 1997/1999 {
	append using $datadir\16in_`y'.dta
	erase $datadir\16in_`y'.dta
}

replace in1 = . if in1 == -8888888
replace in6 = . if in6 == -8888888

gen income_net = in1 - in6
rename in1 income_gross
rename in6 expense

gen vilid = substr(newid, 1, 8)
destring vilid, replace
destring newid, replace

gcollapse (sum) income_net income_gross expense, by(newid vilid year)

save $datadir\16in.dta, replace

