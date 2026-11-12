* ------------------------------------------------------------------------------
**# Table B3
* ------------------------------------------------------------------------------ 

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

*-------------------------------------------------------------------------------
**# Re-estimate main effect
*-------------------------------------------------------------------------------

local agesamp age >= 3 & age <= 21
local samp_child `agesamp' & child == 1 
local samp_grandchild `agesamp' & child == 0 

reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if `samp_child', absorb(newid) cluster(vilid)
gen samp_child = 1 if e(sample)


reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if  `samp_grandchild', absorb(newid) cluster(vilid)
gen samp_grandchild = 1 if e(sample)

*-------------------------------------------------------------------------------
**# Effect on borrowing
*-------------------------------------------------------------------------------

tab age_group, gen(age_group_cat)

gcollapse borrow_vf borrow_bank borrow_infml borrow_oth vilsize_inv vilsize_100 post borrow_rate_pre oc_vilpos female age_group_cat* lgpp samp_child samp_grandchild, by(newid vilid year)

label variable borrow_vf "Village fund"
label variable borrow_bank "Bank"
label variable borrow_infml "Informal"
label variable borrow_oth "Others"
label variable post "post"
label variable vilsize_inv "1/village size"

foreach x in vf bank infml oth {
	
	reghdfe borrow_`x' c.vilsize_inv##c.post i.year lgpp age_group_cat* female c.borrow_rate_pre#i.year oc_vilpos if (samp_child == 1 | samp_grandchild == 1) & (year == 2000 | year == 2002), absorb(newid) cluster(vilid) 

	eststo 
	sum borrow_`x' if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Full"
	estadd local level "Household"
	
}

local keepvar c.vilsize*#c.post 
local statlist N level samp depvarmean
local statlab `" Observations "Analysis level" Sample "Dep. var. mean if post = 0"  "'
local statfmt %15.0fc 3 3 %15.2fc 

local prehead = "\begin{center} \begin{threeparttable} \begin{tabular}{l*{@M}{r}} \hline \hline "
local posthead = "\hline \multicolumn{@span}{l}{\textbf{Panel A:} Sample: 2000 \& 2002} \\"
local prefoot = ""
local postfoot = ""

	#delim ;
	estout
	using $outdir\borrow_did.tex, replace
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
	prefoot(`prefoot') 
	postfoot(`postfoot');
	#delim cr

	eststo clear

foreach x in vf bank infml oth {
	
	reghdfe borrow_`x' c.vilsize_inv##c.post i.year lgpp age_group_cat* female c.borrow_rate_pre#i.year oc_vilpos if (samp_child == 1 | samp_grandchild == 1), absorb(newid) cluster(vilid) 

	eststo 
	sum borrow_`x' if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Full"
	estadd local level "Household"
	
}

local prehead = ""
local posthead = "\hline \multicolumn{@span}{l}{\textbf{Panel B:} Sample: 1997--2009} \\"
local prefoot = ""
local postfoot = "\hline \end{tabular} \end{threeparttable} \end{center}"

	#delim ;
	estout
	using $outdir\borrow_did.tex, append
	cells(b(nostar fmt(3)) se(par) ) 
	keep(`keepvar')
	order(`keepvar')
	stats(`statlist', 
	labels(`statlab') 
	fmt(`statfmt')) 
	label 
	mlabels(,none) 
	collabels(,none) 
	varlabels(_cons "Constant")
	nonumbers 
	interaction(" $\times$ ")
	style(tex) 
	prehead(`prehead')
	posthead(`posthead')
	prefoot(`prefoot') 
	postfoot(`postfoot');
	#delim cr

	eststo clear