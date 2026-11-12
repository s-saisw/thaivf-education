forvalues y = 1997/1999 {
	
	if `y' == 1997 {
		local filepath = "1997_rural/data/jbatab.dta"
	}
	else if `y' == 1998 {
		local filepath = "1998_rural/data/Updated - ba_t1.dta"
	}
	else if `y' == 1999 {
		local filepath = "1999_rural/data/ba16.dta"
	}
	
	use "$rawdatadir/`filepath'", replace
	
	gen year = `y'
	
	keep newid year ba*

	save "$datadir/13ba_tab2_`y'.dta", replace
}

local filecode 13ba_tab2
local output "$datadir/13ba_tab2.dta"


quietly {
local yrstart = 2000

forvalues yr = `yrstart'/2017 {
	local yr2 = `yr' - 2000
	local yr2 = string(`yr2', "%02.0f")
	
	if (`yr' == 2000) {
		local yr2 = "00"
	}
	
	if (`yr' < 2008) | (`yr' >= 2016 & `yr' <= 2017) {
		local arealist rural 
	}
	else if `yr' >= 2008 & `yr' <= 2015{
		local arealist rural urban
	}
	
	foreach area in `arealist' {

		local path "$rawdatadir/`yr'_`area'/data/"

		local file = "`path'" + "hh" + "`yr2'" + "_" + "`filecode'" + ".dta"
		use "`file'", replace

		gen year = `yr'
		gen rural = .
		replace rural = 1 if "`area'" == "rural"
		replace rural = 0 if "`area'" == "urban"

		if (`yr' == `yrstart' & "`area'" == "rural") {
			save "`output'", replace
		}
		else {
			append using "`output'"
			save "`output'", replace
		}
	}
}
}

forvalues y = 1997/1999 {
	append using "$datadir/13ba_tab2_`y'.dta"
	erase "$datadir/13ba_tab2_`y'.dta"
}


destring newid, replace

replace bnumber=1 if year<2000
keep if bnumber==1


collapse (sum) ba18, by(newid year) //total asset cost


save "`output'", replace
