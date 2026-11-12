
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

		local path $rawdatadir\\`yr'_`area'\data\

		local file = "`path'" + "hh" + "`yr2'" + "_" + "`filecode'" + ".dta"
		use `file', replace

		gen year = `yr'
		gen rural = .
		replace rural = 1 if "`area'" == "rural"
		replace rural = 0 if "`area'" == "urban"

		if (`yr' == `yrstart' & "`area'" == "rural") {
			save `output', replace
		}
		else {
			append using `output'
			save `output', replace
		}
	}
}
}
