* food and alcohol consumption -----------------------

forvalues y = 1997/1999 {

	if `y' == 1997 {
		local filepath = "1997_rural\data\Updated - j23tb1.dta"
	}
	else if `y' == 1998 {
		local filepath = "1998_rural\data\Updated - ex_t.dta"
	}
	else if `y' == 1999 {
		local filepath = "1999_rural\data\Updated - ex_t.dta"
	}
	
	use "$rawdatadir\\`filepath'", replace
	
	
	if `y' == 1997 {
		rename line_id number
		drop if ex4 < 0
	}
	else if `y' == 1998 {
		rename line_id number
		drop if ex4 < 0
	}
	else if `y' == 1999 {
		rename line_id number
		drop if ex4 < 0
	}
	
	keep newid number ex*
	
	gen year = `y'

	save $datadir\15ex_tab1_`y'.dta, replace
}

local filecode 15ex_tab1
local output $datadir\15ex_tab1.dta
include $subprogramdir\sub_merge_townsend_file.do

forvalues y = 1997/1999 {
	append using $datadir\15ex_tab1_`y'.dta
	erase $datadir\15ex_tab1_`y'.dta
}

drop if ex4 == 0
drop if missing(ex4)

gen type = 1 if inlist(number, 1, 2, 3) //rice+grains
replace type = 2 if inlist(number, 4) //dairy
replace type = 3 if inlist(number, 5) //meat
replace type = 4 if inlist(number, 6, 7, 8) //alcohol + tobacco
replace type = 5 if inlist(number, 9) //gasoline
replace type = 6 if inlist(number, 10) //ceremonies

gcollapse (sum) ex4, by(newid year type)
rename ex4 ex
reshape wide ex, i(newid year) j(type)

forvalues i = 1/6 {
	replace ex`i' = 0 if missing(ex`i')
}

rename ex1 ex_rice
rename ex2 ex_dairy
rename ex3 ex_meat
rename ex4 ex_alcohol
rename ex5 ex_gas
rename ex6 ex_ceremony

destring newid, replace
gcollapse (sum) ex_*, by(newid year)

save $datadir\15ex_tab1.dta, replace