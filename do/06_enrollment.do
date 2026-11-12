use "$datadir/sample.dta", clear

gen vilsize = hh_count_last_before02
gen vilsize_inv = 1/vilsize

gen post = (year >= 2002)
label variable post "Post"

// gen yearsq = year^2

gcollapse borrow_vf vilsize_inv vilsize, by(vilid year)

drop if year >= 2002
gcollapse borrow_vf vilsize, by(vilid)

sum vilsize, detail
keep vilid borrow_vf

rename borrow_vf borrow_rate_pre

save $datadir/VFborrow_pretreatment.dta, replace

**# clean sample ----------------------------------------------------------------

use "$datadir/sample.dta", clear

gen vilsize = hh_count_last_before02
gen vilsize_inv = 1/vilsize
label variable vilsize_inv "1/village size"

gen vilsize_100 = vilsize/100 
label variable vilsize_100 "village size"

gen post = (year >= 2002)

merge m:1 vilid using $datadir/VFborrow_pretreatment.dta
drop _merge

merge m:1 newid year using "$datadir/05oc_tab1_hhlvl"
drop if _merge==2
drop _merge
replace oc_vilpos = 0 if missing(oc_vilpos)

replace working_any = 0 if missing(working_any) & age >= 11
egen enrollemp = group(hc_inschool working_any) 
qui tab enrollemp, generate(enrollemp)
label variable enrollemp1 "\shortstack{Not in school\\non-employed}"
label variable enrollemp2 "\shortstack{Not in school\\employed}"
label variable enrollemp3 "\shortstack{In school\\non-employed}"
label variable enrollemp4 "\shortstack{In school\\employed}"

gen family_worker = cond(oc1b==3|oc2b==3,1,0)
label variable family_worker "Family worker"

keep if age >= 3 & age <= 21
local linenum = 5
include $subprogramdir\sub_expobs.do

*-------------------------------------------------------------------------------
**# Table 4: overall effects
*-------------------------------------------------------------------------------

local agesamp age >= 3 & age <= 21
local samp_child `agesamp' & child == 1
local samp_grandchild `agesamp' & child == 0

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if `samp_child', absorb(newid) cluster(vilid) 
eststo enroll_c
sum hc_inschool if e(sample) & post == 0
estadd scalar depvarmean = r(mean)
estadd local samp "Child"
estadd local level "Individual"
gen samp_child = 1 if e(sample)

foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if  `samp_grandchild', absorb(newid) cluster(vilid)
eststo enroll_gc
sum hc_inschool if e(sample) & post == 0
estadd scalar depvarmean = r(mean)
estadd local samp "Grandchild"
estadd local level "Individual"
gen samp_grandchild = 1 if e(sample)
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if (samp_child == 1|samp_grandchild == 1), absorb(newid) cluster(vilid)
eststo enroll_full
sum hc_inschool if e(sample) & post == 0
estadd scalar depvarmean = r(mean)
estadd local samp "Full"
estadd local level "Individual"
gen samp_full = 1 if e(sample)
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}
reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_child == 1 & age >= 3 & age <= 10, absorb(newid) cluster(vilid) keepsingletons
eststo enroll_c1
sum hc_inschool if e(sample) & post == 0
estadd scalar depvarmean = r(mean)
estadd local samp "Child"
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_child == 1 & age >= 11 & age <= 21, absorb(newid) cluster(vilid) keepsingletons
eststo enroll_c2
sum hc_inschool if e(sample) & post == 0
estadd scalar depvarmean = r(mean)
estadd local samp "Child"
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

local estorder enroll_full enroll_c enroll_gc enroll_c1 enroll_c2
local keepvar c.vilsize*#c.post 
local statlist N level samp sampage sampyear depvarmean
local statlab `"Observations "Analysis level" Sample Age "Sample years" "Dep. var. mean if post = 0" "'
local statfmt %15.0fc 3 3 3 %15.2fc


local filename $outdir\inschool_did.tex
local prehead = "\begin{center} \begin{threeparttable} \begin{tabular}{l*{@M}{r}} \hline \hline "
local posthead = "\hline"
local postfoot = "\hline \end{tabular} \end{threeparttable} \end{center}"

	#delim ;
	estout `estorder'
	using `filename', replace
	cells(b(nostar fmt(3)) se(par) ) 
	keep(`keepvar')
	order(`keepvar')
	stats(`statlist', 
	labels(`statlab') 
	fmt(`statfmt')) 
	label 
	mlabels(,depvar) 
	collabels(,none) 
	varlabels(_cons "Constant")
	numbers 
	interaction(" $\times$ ")
	style(tex) 
	prehead(`prehead')
	posthead(`posthead')
	prefoot(\hline) 
	postfoot(`postfoot');
	#delim cr
	
	eststo clear

save $datadir/sample_fixed.dta, replace

keep if (samp_child == 1|samp_grandchild == 1)
local linenum = 6
include $subprogramdir\sub_expobs.do //Drop households with only one observation
	
*-------------------------------------------------------------------------------
**# Figure 2: estimation: graph
*-------------------------------------------------------------------------------

use $datadir/sample_fixed.dta, replace

reghdfe hc_inschool c.vilsize_inv##ib(2001).year i.year ///
lgpp c.age##c.age female c.borrow_rate_pre##i.year oc_vilpos if samp_child == 1, absorb(newid) cluster(vilid)

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
	ytitle("In school") ;
	#delim cr

graph export $outdir/enrollment.pdf, replace

*-------------------------------------------------------------------------------
**# Table 6: enrollment x employment
*-------------------------------------------------------------------------------

use $datadir/sample_fixed.dta, replace

keep if samp_child == 1

forvalues i= 1/4{
	
	reghdfe enrollemp`i' c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if age >= 11 & age <= 21 & samp_child == 1, absorb(newid) cluster(vilid) keepsingletons
	
	eststo 
	sum enrollemp`i' if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
}

local estorder 
local keepvar c.vilsize*#c.post 
local statlist N level samp sampage depvarmean 
local statlab `"Observations "Analysis level" Sample Age "Dep. var. mean if post = 0" "'
local statfmt %15.0fc 3 3 3 %15.2fc
local filename $outdir\enrollemp_did.tex
include $subprogramdir\sub_create_table.do

reghdfe family_worker c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if age >= 11 & age <= 21 & samp_child == 1, absorb(newid) cluster(vilid) keepsingletons
estimates save $outdir\famworker, replace
sum family_worker if e(sample) & post == 0

clear
set obs 1
generate famworker_depvarmean = r(mean)
save $outdir\famworker_depvarmean.dta, replace

*-------------------------------------------------------------------------------
**# Table B4: Impact heterogeneity by 2nd gen
*-------------------------------------------------------------------------------

use $datadir\04hc_tab1.dta, replace

gen parent_of_head = 0
replace parent_of_head = 1 if hc3 == 13

gen child_of_head = 0
replace child_of_head = 1 if hc3 == 7 | hc3 == 9

gcollapse (sum) child_of_head (max) parent_of_head, by(newid year)
destring newid, replace

save $datadir\parent_of_head.dta, replace

use "$datadir/sample.dta", clear

gen vilsize = hh_count_last_before02
gen vilsize_inv = 1/vilsize
label variable vilsize_inv "1/village size"

gen vilsize_100 = vilsize/100 
label variable vilsize_100 "village size"

gen post = (year >= 2002)

merge m:1 vilid using $datadir/VFborrow_pretreatment.dta
drop _merge

merge m:1 newid year using "$datadir/05oc_tab1_hhlvl"
drop if _merge==2
drop _merge
replace oc_vilpos = 0 if missing(oc_vilpos)

merge m:1 newid year using $datadir\parent_of_head.dta
drop if _merge == 2
drop _merge
erase $datadir\parent_of_head.dta

bysort newid year: egen parent_gen=count(child)
gen parent_gen_high = (parent_gen>3)

* Re-estimate main effect ------------------------------------------------------

local agesamp age >= 3 & age <= 21
local samp_child `agesamp' & child == 1 
local samp_grandchild `agesamp' & child == 0 

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if `samp_child', absorb(newid) cluster(vilid)
gen samp_child = 1 if e(sample)

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if  `samp_grandchild', absorb(newid) cluster(vilid)
gen samp_grandchild = 1 if e(sample)

* estimation -------------------------------------------------------------------

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_child == 1 & parent_of_head == 1, absorb(newid) cluster(vilid)
eststo
estadd local samp "Child"
estadd local subsamp "With grandparents"
sum hc_inschool if e(sample)
estadd scalar depvarmean = r(mean)
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_child == 1 & parent_of_head == 0, absorb(newid) cluster(vilid)
eststo
estadd local samp "Grandchild"
estadd local subsamp "No grandparents"
sum hc_inschool if e(sample)
estadd scalar depvarmean = r(mean)
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_grandchild == 1 & child_of_head >= 1, absorb(newid) cluster(vilid)
eststo
estadd local samp "Grandchild"
estadd local subsamp "With parents"
sum hc_inschool if e(sample)
estadd scalar depvarmean = r(mean)
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_grandchild == 1 & child_of_head == 0, absorb(newid) cluster(vilid)
eststo
estadd local samp "Grandchild"
estadd local subsamp "No parents"
sum hc_inschool if e(sample)
estadd scalar depvarmean = r(mean)
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_grandchild == 1 & parent_gen_high == 1, absorb(newid) cluster(vilid)
eststo
estadd local samp "Grandchild"
estadd local subsamp "Parent gen. \$>\$ 3"
sum hc_inschool if e(sample)
estadd scalar depvarmean = r(mean)
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if samp_grandchild == 1 & parent_gen_high == 0, absorb(newid) cluster(vilid)
eststo
estadd local samp "Grandchild"
estadd local subsamp "Parent gen. \$\leq\$ 3"
sum hc_inschool if e(sample)
estadd scalar depvarmean = r(mean)
estadd local level "Individual"
foreach x in age year {
	sum `x' if e(sample)
	local min = r(min)
	local max = r(max)
	estadd local samp`x' "`min'--`max'"
}

local keepvar c.vilsize*#c.post 
local statlist N level samp subsamp sampage sampyear depvarmean
local statlab `"Observations "Analysis level" Sample Group Age "Sample years" "Dep. var. mean if post = 0 " "'
local statfmt %15.0fc 3 3 %15.2fc
local filename $outdir\inschool_did_byhhstruc.tex
include $subprogramdir\sub_create_table.do