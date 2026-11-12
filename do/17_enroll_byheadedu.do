*-------------------------------------------------------------------------------
**# Table B4: Robustness checks + revise to add region time FE and village time trend
*-------------------------------------------------------------------------------

forvalues p = 1/3 {
	
	local prehead1 "\begin{center} \begin{threeparttable} \begin{tabular}{l*{@M}{r}} \hline \hline "
	local prehead2 ""
	local prehead3 ""
	
	local posthead1 "\hline \multicolumn{5}{l}{\textbf{Panel A:} Household head has less than 4 years of education} \\"
	local posthead2 "\hline \multicolumn{5}{l}{\textbf{Panel B:} Household head has 4 years of education} \\"
	local posthead3 "\hline \multicolumn{5}{l}{\textbf{Panel C:} Household head has more than 4 years of education} \\"
	
	local postfoot1 ""
	local postfoot2 ""
	local postfoot3 "\hline \end{tabular} \end{threeparttable} \end{center}"
	
	local fileopt1 replace numbers mlabels(,depvar) 
	local fileopt2 append nonumbers mlabels(,none) 
	local fileopt3 append nonumbers mlabels(,none) 
	
	local sampopt1 eduyr_head < 4
	local sampopt2 eduyr_head == 4
	local sampopt3 eduyr_head > 4 & !missing(eduyr_head)
	
	local filename $outdir\byheadeduc.tex

	* household level analysis ----------

	use "$datadir/sample_fixed_hhbiz.dta", replace
	keep if samp_child == 1
	
	gen yearsq = year*year
	egen provyr = group(province year)
	egen distyr = group(ampid year)
	
	foreach depvar in ex_edu_comparable numworker capital_10k_w {
		
		preserve
		
		quietly: reghdfe `depvar' c.vilsize_inv##c.post i.year lgpp female c.borrow_rate_pre#i.year oc_vilpos if `sampopt`p'', absorb(newid) cluster(vilid)
		estimates save "$outdir/`depvar'_byheadeduc`p'", replace
		
		sum `depvar' if e(sample)

		clear
		set obs 1
		generate depvarmean = r(mean)
		save "$outdir/`depvar'_depvarmean_byheadeduc`p'.dta", replace
		
		restore
		
	}

	* individual level analysis -----------

	use $datadir/sample_fixed.dta, replace
	
	foreach depvar in ex_edu_comparable numworker capital_10k_w {
		gen `depvar' = .
	}
	label variable ex_edu_comparable "EEG"
	label variable numworker "Labor"
	label variable capital_10k_w "Capital"
	
	egen provyr = group(province year)
	egen distyr = group(ampid year)
		
	quietly: reghdfe hc_inschool c.vilsize_inv##c.post i.year lgpp c.age##c.age female c.borrow_rate_pre#i.year oc_vilpos if age >= 3 & age <= 21 & samp_child == 1 & `sampopt`p'', absorb(newid) cluster(vilid) keepsingletons

		eststo 
		sum hc_inschool if e(sample) & post == 0
		estadd scalar depvarmean = r(mean)
		estadd local samp "Child"
		estadd local level "Individual"
		
		sum age if e(sample)
		local agemin = r(min)
		local agemax = r(max)
		estadd local sampage "`agemin'--`agemax'"
		

	* create table
	
	foreach depvar in ex_edu_comparable numworker capital_10k_w {

		estimates use $outdir/`depvar'_byheadeduc`p'
		eststo 
		estadd local samp "Child"
		estadd local level "Household"
		estadd local sampage "3--21"
		preserve
		use $outdir/`depvar'_depvarmean_byheadeduc`p'.dta, replace
		sum depvarmean
		restore
		
		estadd scalar depvarmean = r(mean)
	
	}

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
	prefoot(\hline) 
	postfoot(`postfoot`p'');
	#delim cr

	eststo clear
}


