* ------------------------------------------------------------------------------
**# Figure 1a, 1b: First-stage
* ------------------------------------------------------------------------------

use $datadir/sample_fixed.dta, clear

keep if samp_full == 1
tab vilsize

gen borrow_bio = 0
replace borrow_bio = 1 if borrow_bank == 1
replace borrow_bio = 1 if borrow_infml == 1
replace borrow_bio = 1 if borrow_oth == 1

local i = 2002
	
	preserve
	
	keep if (year == 2000| year == `i')

	gcollapse vilsize_inv vilsize (max) borrow_vf borrow_bio, by(newid vilid year) //collapse at household level
	gcollapse borrow_vf borrow_bio vilsize_inv vilsize, by(vilid year) //collapse at village level

	reshape wide borrow_vf borrow_bio , i(vilid) j(year) 

	gen borrow_delta = (borrow_vf`i' - borrow_vf2000)*100
	gen borrow_delta_bio = (borrow_bio`i' - borrow_bio2000)*100

	local endash = ustrunescape("\u2013")
	
	
	reg borrow_delta vilsize_inv, robust
	local b = _b[vilsize_inv]
	local stde = string(_se[vilsize_inv], "%15.3f")
		
	if (`b' < 0){
		local b = abs(`b')
		local minus = ustrunescape("\u2212")
	}
	else {
		local minus ""
	}
	local b = string(`b', "%15.3f")

	#delim ;
	binscatterhist borrow_delta vilsize_inv,
	text(30 0.02 "Slope: `minus'`b' (`stde')", size(*1.1) place(e))
	yscale(range(20 100)) ylabel(20(20)100, labsize(*1.5)) xlabel(,labsize(*1.5))
	vce(robust) nquantiles(30) 
	ytitle("% borrowed from VF" "`i' `endash' 2000 (pp)", size(*1.5))
	xtitle("Inverse of village size before VF", size(*1.5))
	mcolors(stc1) lcolors(stc2);
	#delim cr
	
	graph export $outdir/borrowVF_change_`i'.pdf, replace
	
		
		reg borrow_delta_bio vilsize_inv, robust
		local b = _b[vilsize_inv]
		local stde = string(_se[vilsize_inv], "%15.3f")
		
		if (`b' < 0){
			local b = abs(`b')
			local minus = ustrunescape("\u2212")
		}
		else {
			local minus ""
		}
		local b = string(`b', "%15.3f")
		
		#delim ;
		binscatterhist borrow_delta_bio vilsize_inv,
		text(0 0.025 "Slope: `minus'`b' (`stde')", size(*1.1))
		yscale(range(-60 20)) ylabel(-60(20)20, labsize(*1.5)) xlabel(,labsize(*1.5)) 
		vce(robust)
		nquantiles(30)
		ytitle("% borrowed from non`endash'VF sources" "2002 `endash' 2000 (pp)", size(*1.5))
		xtitle("Inverse of village size before VF", size(*1.5))
		mcolors(stc1) lcolors(stc2);
		#delim cr
		
		graph export $outdir/borrowbio_change_2002.pdf, replace
		
	
	restore


* ------------------------------------------------------------------------------
**# Figure 1c: First-stage with Times borrowing
* ------------------------------------------------------------------------------

use $datadir/sample_fixed.dta, clear

keep if samp_full == 1

gcollapse vilsize vilsize_inv (max) borrow_vf, by(newid year)

keep if year >= 2002
xtset newid year
bysort newid (year): gen borrow_vfcum = sum(borrow_vf)

gen borrowyear = year*borrow_vf
replace borrowyear = . if borrowyear == 0
bysort newid: egen firstborrow = min(borrowyear)

gcollapse vilsize vilsize_inv firstborrow (max) borrow_vfcum, by(newid)

sum vilsize, detail
local medsize = r(p50)
gen smallvil = cond(vilsize <= r(p50), 1 , 0)

#delim ;
twoway 
(hist borrow_vfcum if smallvil == 1, discrete lcolor(gs12) fcolor(gs12))
(hist borrow_vfcum if smallvil == 0, discrete lcolor(stc1) fcolor(none)) ,
legend(pos(6) order(1 "Village with {&le} `medsize' households" 2 "Village with {&ge} `=`medsize'+1' households ") size(*1.5))
xtitle("Number of years borrowing from VF (2002-2009)", size(*1.5)) ytitle("Fraction",size(*1.5))
xlabel(0(1)8, labsize(*1.5)) ylab(,labsize(*1.5));
#delim cr

graph export $outdir/timesborrow_hist.pdf, replace

* ------------------------------------------------------------------------------
**# Figure 1d: First-stage with Times borrowing
* ------------------------------------------------------------------------------

#delim ;
twoway 
(hist firstborrow if smallvil == 1, discrete lcolor(gs12) fcolor(gs12))
(hist firstborrow if smallvil == 0, discrete lcolor(stc1) fcolor(none)) ,
legend(pos(6) order(1 "Village with {&le} `medsize' households" 2 "Village with {&ge} `=`medsize'+1' households ") size(*1.5))
xtitle("Year of first loan from VF", size(*1.5))  ytitle("Fraction",size(*1.5))
xlabel(2002(1)2009, labsize(*1.5)) ylab(,labsize(*1.5));
#delim cr

graph export $outdir/yearfirstborrow_hist.pdf, replace

* ------------------------------------------------------------------------------
**# Figure B1 a: distribution of borrowing amount
* ------------------------------------------------------------------------------

use $datadir/sample_fixed.dta, replace
gcollapse (max) samp_full vilsize, by(newid)

save $outdir/sampid.dta, replace

use $datadir\17bl_loanlvl_tab1.dta, replace
destring newid, replace

keep if source == 1
keep if borrow_year >= 2002

gen vfamt = bl3e
replace vfamt = 50000 if bl3e >= 50000

merge m:1 newid using $outdir/sampid.dta
keep if _merge == 3

#delim ;
hist vfamt, bin(50) fraction
xlabel(0(10000)40000 50000 "{&ge}50000")
xtitle("Loan size (Baht)");
#delim cr

graph export $outdir\loansize.pdf, replace

gen under20k = (vfamt <= 20000)
sum under20k

* ------------------------------------------------------------------------------
**# Figure B1 b: First-stage with loan size
* ------------------------------------------------------------------------------

use $datadir/sample_fixed.dta, clear

gen smallvil = cond(vilsize <= 105, 1 , 0)
local medsize = 105

replace borrow_vf_amount = 80000 if borrow_vf_amount >= 80000

gen borrow_vf_amount_10k = borrow_vf_amount/10^4

#delim ;
twoway 
(hist borrow_vf_amount_10k if smallvil == 1, lcolor(gs12) fcolor(gs12) start(0) width(0.25) fraction)
(hist borrow_vf_amount_10k if smallvil == 0, lcolor(stc1) fcolor(none) start(0) width(0.25) fraction) ,
legend(pos(6) order(1 "Village with {&le} `medsize' households" 2 "Village with {&ge} `=`medsize'+1' households ") size(*1.5))
xtitle("Total household borrowing from VF in a year (10K Baht)", size(*1.5)) ytitle(,size(*1.5))
xlabel(0(1)7 8 "{&ge}8" , labsize(*1.5)) ylab(,labsize(*1.5));
#delim cr

graph export $outdir/amtborrow.pdf, replace