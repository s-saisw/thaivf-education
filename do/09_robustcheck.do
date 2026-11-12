*-------------------------------------------------------------------------------
**# Table B4: Robustness checks
*-------------------------------------------------------------------------------

use $datadir/sample_fixed.dta, replace

gen ex_edu_comparable = .
label variable ex_edu_comparable "EEG"

gen lvilsize = log(vilsize)
label variable lvilsize "\$\log\$(village size)"

keep if samp_child == 1

* use log village size --------------------------

forvalues s = 1/2 {
	
	local samp1 age >= 3 & age <= 21
	local samp2 age >= 3 & age <= 10
	
	reghdfe hc_inschool c.lvilsize##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if `samp`s'' & samp_child == 1, absorb(newid) cluster(vilid) keepsingletons

	eststo 
	sum hc_inschool if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
	
}

foreach y in hc_inschool enrollemp1 enrollemp2 enrollemp3 enrollemp4 {
	
	reghdfe `y' c.lvilsize##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if age >= 11 & age <= 21 & samp_child == 1, absorb(newid) cluster(vilid) keepsingletons
	
	eststo 
	sum `y' if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
}

estimates use $outdir\exedugap_rc0
eststo 
estadd local samp "Child"
estadd local level "Household"
estadd local sampage "3--21"
preserve
use $outdir\exedugap_depvarmean_rc0.dta, replace
sum exedugap_depvarmean
restore

estadd scalar depvarmean = r(mean)

local keepvar c.lvilsize*#c.post 
local statlist N level samp sampage depvarmean 
local statlab `"Observations "Analysis level" Sample Age "Dep. var. mean if post = 0" "'
local statfmt %15.0fc 3 3 3 %15.2fc

local prehead = "\begin{center} \begin{threeparttable} \begin{tabular}{l*{@M}{r}} \hline \hline "
local posthead = "\hline \multicolumn{@span}{l}{\textbf{Panel A:} log of village size as explanatory variable} \\"
local prefoot = ""
local postfoot = ""

	#delim ;
	estout
	using $outdir\main_rc.tex, replace
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
	
* subsample: observed in 2009 ---------------------------------
	
forvalues s = 1/2 {
	
	local samp1 age >= 3 & age <= 21
	local samp2 age >= 3 & age <= 10
	
	reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if `samp`s'' & samp_child == 1 & obs2009 == 1, absorb(newid) cluster(vilid) keepsingletons

	eststo 
	sum hc_inschool if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
	
}

foreach y in hc_inschool enrollemp1 enrollemp2 enrollemp3 enrollemp4 {
	
	reghdfe `y' c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if age >= 11 & age <= 21 & samp_child == 1 & obs2009 == 1, absorb(newid) cluster(vilid) keepsingletons
	
	eststo 
	sum `y' if e(sample) & post == 0
	estadd scalar depvarmean = r(mean)
	estadd local samp "Child"
	estadd local level "Individual"
	
	sum age if e(sample)
	local agemin = r(min)
	local agemax = r(max)
	estadd local sampage "`agemin'--`agemax'"
}

estimates use $outdir\exedugap_rc2
eststo 
estadd local samp "Child"
estadd local level "Household"
estadd local sampage "3--21"
preserve
use $outdir\exedugap_depvarmean_rc2.dta, replace
sum exedugap_depvarmean
restore

estadd scalar depvarmean = r(mean)

local keepvar c.vilsize*#c.post 
local statlist N level samp sampage depvarmean 
local statlab `"Observations "Analysis level" Sample Age "Dep. var. mean if post = 0" "'
local statfmt %15.0fc 3 3 3 %15.2fc

local prehead = ""
local posthead = "\hline \multicolumn{@span}{l}{\textbf{Panel B:} Using sample of households observed in 2009} \\"
local prefoot = ""
local postfoot = ""

	#delim ;
	estout
	using $outdir\main_rc.tex, append
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
	
* specifications with region-time controls -------------------------------------

*-------------------------------------------------------------------------------
**# Table B4: Robustness checks + revise to add region time FE and village time trend
*-------------------------------------------------------------------------------

foreach p in 4 6 {
	
	local prehead1 "\begin{center} \begin{threeparttable} \begin{tabular}{l*{@M}{r}} \hline \hline "
	local prehead2 ""
	local prehead3 ""
	
	local posthead4 "\hline \multicolumn{9}{l}{\textbf{Panel C:} Include district \$\times\$ year FE} \\"
	local posthead6 "\hline \multicolumn{9}{l}{\textbf{Panel D:} Include village\$\times\$ time trend} \\"

	local postfoot4 ""
	local postfoot6 "\hline \end{tabular} \end{threeparttable} \end{center}"
	
	local fileopt4 append nonumbers mlabels(,none) 
	local fileopt6 append nonumbers mlabels(,none) 
	
	local filename $outdir\main_rc.tex

	* household level analysis ----------

	use $datadir/sample_fixed_hh.dta, replace
	keep if samp_child == 1
	
	gen yearsq = year*year
	
	local regiontimeopt4 i.ampid#i.year
	local regiontimeopt6 i.vilid#c.year
	
	local clusteropt4 cluster(vilid)
	local clusteropt6 cluster(vilid)
	
	quietly: reghdfe ex_edu_comparable c.vilsize_inv##c.post i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos `regiontimeopt`p'', absorb(newid) `clusteropt`p''
	estimates save $outdir\exedugap_tfe`p', replace

	sum ex_edu_comparable if e(sample)

	clear
	set obs 1
	generate exedugap_depvarmean = r(mean)
	save $outdir\exedugap_depvarmean_tfe`p'.dta, replace

	* individual level analysis -----------

	use $datadir/sample_fixed.dta, replace
	gen ex_edu_comparable = .
	label variable ex_edu_comparable "EEG"
	
	forvalues s = 1/2 {
		
		local samp1 age >= 3 & age <= 21
		local samp2 age >= 3 & age <= 10
		
		quietly: reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos `regiontimeopt`p'' if `samp`s'' & samp_child == 1, absorb(newid) `clusteropt`p'' keepsingletons

		eststo 
		sum hc_inschool if e(sample) & post == 0
		estadd scalar depvarmean = r(mean)
		estadd local samp "Child"
		estadd local level "Individual"
		
		sum age if e(sample)
		local agemin = r(min)
		local agemax = r(max)
		estadd local sampage "`agemin'--`agemax'"
		
	}

	foreach y in hc_inschool enrollemp1 enrollemp2 enrollemp3 enrollemp4 {
		
		quietly: reghdfe `y' c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos `regiontimeopt`p'' if age >= 11 & age <= 21 & samp_child == 1, absorb(newid) `clusteropt`p'' keepsingletons
		
		eststo 
		sum `y' if e(sample) & post == 0
		estadd scalar depvarmean = r(mean)
		estadd local samp "Child"
		estadd local level "Individual"
		
		sum age if e(sample)
		local agemin = r(min)
		local agemax = r(max)
		estadd local sampage "`agemin'--`agemax'"
	}

	* create table

	estimates use $outdir\exedugap_tfe`p'
	eststo 
	estadd local samp "Child"
	estadd local level "Household"
	estadd local sampage "3--21"
	preserve
	use $outdir\exedugap_depvarmean_tfe`p'.dta, replace
	sum exedugap_depvarmean
	restore
	
	estadd scalar depvarmean = r(mean)

	local keepvar c.vilsize_inv*#c.post 
	local statlist N level samp sampage depvarmean 
	local statlab `"Observations "Analysis level" Sample Age "Dep. var. mean if post = 0" "'
	local statfmt %15.0fc 3 3 3 %15.2fc


	#delim ;
	estout `estorder'
	using `filename', `fileopt`p''
	cells(b(nostar fmt(3)) se(par) ) 
	keep(`keepvar')
	order(`keepvar')
	stats(`statlist', 
	labels(`statlab') 
	fmt(`statfmt')) 
	label 
	collabels(,none) 
	varlabels(_cons "Constant")
	interaction(" $\times$ ")
	style(tex) 
	prehead(`prehead`p'')
	posthead(`posthead`p'')
	prefoot("") 
	postfoot(`postfoot`p'');
	#delim cr

	eststo clear
}


