**# enrollemp 1-4 --------------

use $datadir/sample_fixed.dta, replace
keep if samp_child == 1

forvalues i = 1/4 {
	
	local xtitle1 "Not in school & non-employed"
	local xtitle2 "Not in school & employed"
	local xtitle3 "In school & non-employed"
	local xtitle4 "In school & employed"
	
	reghdfe enrollemp`i' c.vilsize_inv##ib(2001).year i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if age >= 11 & age <= 21 & samp_child == 1, absorb(newid) cluster(vilid) keepsingletons

	#delim ;
	coefplot, 
	keep(*#c.vilsize_inv) 
	coeflabels(1997.year#c.vilsize_inv = "1997" 
	1998.year#c.vilsize_inv = "1998" 
	1999.year#c.vilsize_inv = "1999" 
	2000.year#c.vilsize_inv = "2000" 
	2001.year#c.vilsize_inv = "2001" 
	2002.year#c.vilsize_inv = "2002" 
	2003.year#c.vilsize_inv = "2003" 
	2004.year#c.vilsize_inv = "2004" 
	2005.year#c.vilsize_inv = "2005" 
	2006.year#c.vilsize_inv = "2006" 
	2007.year#c.vilsize_inv = "2007" 
	2008.year#c.vilsize_inv = "2008"
	2009.year#c.vilsize_inv = "2009") 
	omitted baselevels
	ci(95 myci) ciopts(recast(rcap) lcolor(gray%30))
	vertical yline(0) 
	recast(connected)
	xline(5.5) ylab(-20(10)20)
	ytitle(`xtitle`i'') ;
	#delim cr
	
	graph export $outdir/enrollemp`i'.pdf, replace
}


**# EEG ------------------------------------------------------------------------

use $datadir/sample_fixed_hh.dta, replace

keep if samp_child == 1

reghdfe ex_edu_comparable c.vilsize_inv##ib(2001).year i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos, absorb(newid) cluster(vilid)

	#delim ;
	coefplot, 
	keep(*#c.vilsize_inv) 
	coeflabels(1997.year#c.vilsize_inv = "1997" 
	1998.year#c.vilsize_inv = "1998" 
	1999.year#c.vilsize_inv = "1999" 
	2000.year#c.vilsize_inv = "2000" 
	2001.year#c.vilsize_inv = "2001" 
	2002.year#c.vilsize_inv = "2002" 
	2003.year#c.vilsize_inv = "2003" 
	2004.year#c.vilsize_inv = "2004" 
	2005.year#c.vilsize_inv = "2005" 
	2006.year#c.vilsize_inv = "2006" 
	2007.year#c.vilsize_inv = "2007" 
	2008.year#c.vilsize_inv = "2008"
	2009.year#c.vilsize_inv = "2009") 
	omitted baselevels
	ci(95 myci) ciopts(recast(rcap) lcolor(gray%30))
	vertical yline(0) 
	recast(connected)
	xline(5.5)
	ytitle("EEG") ;
	#delim cr

graph export $outdir/eeg.pdf, replace

