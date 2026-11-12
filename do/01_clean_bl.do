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
	
	use "$rawdatadir/`filepath'", replace
	
	gen year = `y'

	save $datadir\17bl_tab1_loanlvl_`y'.dta, replace
}

local filecode 17bl_tab1
local output $datadir\17bl_loanlvl_tab1.dta
include $subprogramdir\sub_merge_townsend_file.do
include $subprogramdir\sub_gen_province.do

forvalues y = 1997/1999 {
	append using $datadir\17bl_tab1_loanlvl_`y'.dta
	erase $datadir\17bl_tab1_loanlvl_`y'.dta
}

gen ampid = substr(newid, 1, 4) //amphoe = district
gen tamid = substr(newid, 1, 6) //tambon = sub-district
gen vilid = substr(newid, 1, 8) //village
destring newid, replace

gen vf = cond(bl3b == 13, 1, 0)
gen bank = cond(inlist(bl3b, 5, 7, 9), 1, 0)
gen informal = cond(inlist(bl3b, 1, 3, 17, 19, 21, 23, 25), 1, 0)

gen source = 1 if vf == 1
replace source = 2 if bank == 1
replace source = 3 if informal == 1

gen borrow_month = substr(bl3c, 1, 2)
replace borrow_month = "" if borrow_month == "DK"
replace borrow_month = "3" if borrow_month == "3/"
replace borrow_month = "" if borrow_month == "IV"
replace borrow_month = "" if borrow_month == "RF"
destring borrow_month, replace
replace borrow_month = . if borrow_month > 12 | borrow_month == 0

gen borrow_year = substr(bl3c, -2, 2)
replace borrow_year = "" if borrow_year == "DK"
replace borrow_year = "" if borrow_year == "w)"
replace borrow_year = "" if borrow_year == "e)"
replace borrow_year = "" if borrow_year == "RF"
destring borrow_year, replace
replace borrow_year = 2500 + borrow_year - 543
drop if borrow_year > year

save $datadir\17bl_loanlvl_tab1.dta, replace