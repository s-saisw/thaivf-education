
/*use "$rawdatadir\1997_rural\data\Updated - j27tb1.dta", replace
local y = 1997

	
gen year = `y'
*/

replace bl3b = . if bl3b == -88
drop if missing(bl3b)

gen borrow_vf = (bl3b == 13) //village fund
gen borrow_bank = inlist(bl3b, 5, 9)
gen borrow_infml = inlist(bl3b, 1, 3, 17, 19, 21, 23, 25)
gen borrow_oth = inlist(bl3b, 7, 11, 15, 17)

replace bl3e = . if bl3e < 0
drop if missing(bl3e)
drop if bl3e == 0

replace bl3c = "" if bl3c == "DK(don't know)"
replace bl3c = "" if bl3c == "DK"

gen borrow_month = substr(bl3c, 1, 2)
replace borrow_month = "" if borrow_month == "DK"
replace borrow_month = "3" if borrow_month == "3/"
destring borrow_month, replace
replace borrow_month = 3 if borrow_month == 0 | borrow_month > 12

gen borrow_year = substr(bl3c, -2, 2)
replace borrow_year = "" if borrow_year == "DK"
destring borrow_year, replace
replace borrow_year = 2500 + borrow_year - 543
drop if borrow_year > year

replace borrow_year = borrow_year + 1 if borrow_month >= 5

gen borrow_amount = bl3e
drop if bl3e <= 0

foreach x in vf bank infml oth {
	gen borrow_`x'_amount = borrow_`x'*borrow_amount
}
