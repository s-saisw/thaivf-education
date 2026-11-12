* borrowing behavior ----------------------------------------------------------

forvalues y = 1997/1999 {
	
	if `y' == 1997 {
		local filepath = "1997_rural\data\Updated - j27tb1.dta"
	}
	else if `y' == 1998 {
		local filepath = "1998_rural\data\bl_t.dta"
	}
	else if `y' == 1999 {
		local filepath = "1999_rural\data\bl3a.dta"
	}
	
	use "$rawdatadir\\`filepath'", replace
	
	gen year = `y'
	include $subprogramdir\sub_cleanrawvar_borrowing.do

	gcollapse (sum) borrow_amount borrow_vf_amount borrow_bank_amount borrow_infml_amount borrow_oth_amount (max) borrow_vf borrow_bank borrow_infml borrow_oth, by(newid year borrow_year)

	save $datadir\17bl_tab1_`y'.dta, replace
}


* 2000 onwards data -----

local filecode 17bl_tab1
local output $datadir\17bl_tab1.dta
include $subprogramdir\sub_merge_townsend_file.do
include $subprogramdir\sub_gen_province.do

include $subprogramdir\sub_cleanrawvar_borrowing.do
gcollapse (sum) borrow_amount borrow_vf_amount borrow_bank_amount borrow_infml_amount borrow_oth_amount (max) borrow_vf borrow_bank borrow_infml borrow_oth, by(newid year borrow_year)

forvalues y = 1997/1999 {
	append using $datadir\17bl_tab1_`y'.dta
	erase $datadir\17bl_tab1_`y'.dta
}

save $datadir\17bl_tab1.dta, replace
