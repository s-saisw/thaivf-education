forvalues y = 1997/1999 {

	if `y' == 1997 {
		local filepath = "1997_rural\data\j24tb1.dta"
	}
	else if `y' == 1998 {
		local filepath = "1998_rural\data\Updated - in_t1.dta"
	}
	else if `y' == 1999 {
		local filepath = "1999_rural\data\Updated - in1_t.dta"
	}
	
	use "$rawdatadir\\`filepath'", replace
	
	if `y' == 1997 {
		gen dot_pos = strpos(initem, ".") 
		gen number = substr(initem, 1, dot_pos-1) if dot_pos != 0
		gen specify = substr(initem, dot_pos+1, .) if dot_pos != 0
		replace number = subinstr(number, " ", "", .)
	}
	else if `y' == 1998 {
		gen dot_pos = strpos(in_item, ".") 
		gen number = substr(in_item, 1, dot_pos-1) if dot_pos != 0
		gen specify = substr(in_item, dot_pos+1, .) if dot_pos != 0
		
		gen codelen = strlen(number)
		replace number = "" if codelen > 3
		replace number = subinstr(number, " ", "", .)
	}
	else if `y' == 1999 {
		gen number = in3
		
		replace number = subinstr(number, " ", "", .)
		replace number = "II1" if number == "II#1"
		replace number = "S1" if number == "S#1"
		replace number = "II1" if number == "MI(missing value)"
		
		gen codelen = strlen(in3)
		gen number_pos1 = substr(in3, 1, 1) if codelen >= 2
		gen number_pos2 = substr(in3, 2, 1) if codelen >= 2
		
		replace number = number_pos1 if number_pos1 != number_pos2 & codelen == 2 //assume first one is main
		decode in2_id, gen(specify) 
	}
	
	keep newid number in2 in4 specify
	rename number in3
	
	gen year = `y'

	save $datadir\16in_tab1_`y'.dta, replace
}

local filecode 16in_tab1
local output $datadir\16in_tab1.dta
include $subprogramdir\sub_merge_townsend_file.do

keep newid number in2 in3 in4 specify year

forvalues y = 1997/1999 {
	append using $datadir\16in_tab1_`y'.dta
	erase $datadir\16in_tab1_`y'.dta
}

keep if in2 == 1
drop if missing(in4)
drop if in4 < 0
drop if in4 == 0

gen inc_agribiz_d = .
foreach x in "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "M" "N" "O" "P" "Q" "R" "S" {
	replace inc_agribiz_d = 1 if (strpos(in3, "`x'") > 0)
}
replace inc_agribiz_d = 0 if in3 == "BB"
replace inc_agribiz_d = 0 if in3 == "CC"
replace inc_agribiz_d = 0 if in3 == "DD"
replace inc_agribiz_d = 0 if in3 == "EE"
replace inc_agribiz_d = 0 if in3 == "FF"
replace inc_agribiz_d = 0 if in3 == "GG"
replace inc_agribiz_d = 0 if in3 == "HH"
replace inc_agribiz_d = 0 if strpos(in3, "II")
tab in3 if inc_agribiz_d == .

gen inc_agribiz = inc_agribiz_d * in4
keep if !missing(inc_agribiz)
drop if inc_agribiz == 0

gcollapse (sum) inc_agribiz, by(newid year)
destring newid, replace

save $datadir\16in_tab1_hhlvl.dta, replace
