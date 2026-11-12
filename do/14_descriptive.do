* ------------------------------------------------------------------------------
**# Fig B2: enrollment across age groups in 2001 
* ------------------------------------------------------------------------------
use "$datadir/sample_fixed.dta", clear
keep if year == 2001

label define age_groupl2 0 "Age 3-5" 1 "Age 6-11" 2 "Age 12-14" 3 "Age 15-17" 4 "Age 18-21"
label values age_group age_groupl2

drop if missing(age_group)

replace working_any = 0 if age <= 10
tab hc_inschool working_any, cell

gen type = 1 if working_any == 0 & hc_inschool == 1
replace type = 2 if working_any == 1 & hc_inschool == 1
replace type = 3 if working_any == 0 & hc_inschool == 0
replace type = 4 if working_any == 1 & hc_inschool == 0

tab type, gen(type_cat)

#delim ;
gcollapse type_cat*, by(age_group);
#delim cr

forvalues i = 1/4 {
	replace type_cat`i' = 100 * type_cat`i'
}

#delim ;
	graph hbar type_cat*, over(age_group) stack 
	bar(1, color(stc1))
	bar(2, color(stc1%30))
	bar(3, color(white) lcolor(stc1))
	bar(4, color(white) lcolor(stc1) lpattern(dash))
	ytitle("Percent")
	blabel(bar, format(%4.1f) pos(center) size(small))
	legend(order(
	1 "In school; non-employed"
	2 "In school; employed"
	3 "Not in school; non-employed"
	4 "Not in school; employed"
	) pos(6) row(4));
	#delim cr
	
foreach i in 14 15 16 18 20 {
	
	gr_edit .plotregion1.barlabels[`i'].Delete barlabels[`i'] edits
	
}

graph export $outdir/empenroll_byage.pdf, replace

clear all

* ------------------------------------------------------------------------------
**# Table 1: characteristics of loan
* ------------------------------------------------------------------------------

use "$datadir/sample_fixed.dta", replace

gcollapse (max) samp_full, by(newid year)

save $datadir/hhsample.dta, replace

* merge with HH data -------

use $datadir\17bl_loanlvl_tab1.dta, replace

merge m:1 newid year using $datadir/hhsample.dta
keep if _merge == 3
erase $datadir/hhsample.dta

keep if samp_full == 1

gen coll_none = cond(bl3i == 1, 1, 0) //no collateral
gen coll_guarantor = cond(inlist(bl3i, 13, 15), 1, 0)
gen coll_asset = cond(inlist(bl3i, 3, 5, 7, 9, 11, 17), 1, 0)

gen collval = bl3j
replace collval = 0 if inlist(bl3i, 1, 13, 15)
replace collval = 0 if bl3j == 0
replace collval = collval/10^4

gen loan_amt = bl3f
replace loan_amt = . if loan_amt <= 0
replace loan_amt = loan_amt/10^4

gen loan_len = bl3g
replace loan_len = . if bl3g < 0

gen intrate = bl3f1

label variable loan_amt "Amount of loan (10K Baht)"
label variable loan_len "Loan duration (months)"
label variable intrate "Interest rate (\%)"

label variable coll_asset "\hspace{5pt} Collateral required (Yes = 1, No = 0)"
label variable coll_guarantor "\hspace{5pt} Guarantor required (Yes = 1, No = 0)"
label variable coll_none "\hspace{5pt} No guarantor/collateral required (Yes = 1, No = 0)"
label variable collval "\hspace{5pt} Value of collateral (10K Baht)"

local nocol 7
local nostat = `nocol' - 1
local filename $outdir\loan_sumstat.tex

local var loan_amt loan_len intrate coll_asset coll_guarantor coll_none collval 

local obs : di %15.0fc _N

#delim ;
bysort source: eststo: estpost
summarize `var';
#delim cr

#delim ;
estout using `filename', replace
label
cells("mean(fmt(%5.2fc)) sd(fmt(%5.2f))")
mlabels(,none) 
collabels("Mean" "SD" "Mean" "SD" )
refcat(coll_asset "Loan security", nolabel) 
style(tex)
nonumbers
prehead(\begin{center} \begin{threeparttable}
\begin{tabular}{l*{`nostat'}{r}} \hline \hline
&\multicolumn{2}{c}{(1)} 
&\multicolumn{2}{c}{(2)}
&\multicolumn{2}{c}{(3)}\\ 
&\multicolumn{2}{c}{VF loan} 
&\multicolumn{2}{c}{Bank loan}
&\multicolumn{2}{c}{Informal loan} \\ 
\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}) 
posthead(\midrule)
prefoot()
postfoot(
\hline \end{tabular} \end{threeparttable} \end{center});
#delim cr

eststo clear