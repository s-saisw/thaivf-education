* child, grandchild sample ----------------------------------------------------
use $datadir/sample_fixed.dta, replace

keep if samp_full == 1

replace family_worker = . if age < 11

label variable child "\hspace{5pt} Child (\$=1\$) or grandchild (\$=0\$)"
label variable female "\hspace{5pt} Female"
label variable age "\hspace{5pt} Age"
label variable hc_inschool "\hspace{5pt} In school"
label variable working_any "\hspace{5pt} In employment"
label variable eduyr_head "\hspace{5pt} Head's year of education"

label variable enrollemp1 "\hspace{5pt} Not in school \& non-employed"
label variable enrollemp2 "\hspace{5pt}  Not in school \& employed"
label variable enrollemp3 "\hspace{5pt}  In school \& non-employed"
label variable enrollemp4 "\hspace{5pt}  In school \& employed"
label variable family_worker "\hspace{5pt} Family worker"

keep if age >= 3 & age <= 21

	#delim ;
	eststo: estpost
	summarize child female age eduyr_head hc_inschool enrollemp3 enrollemp4 enrollemp1 enrollemp2 family_worker  ;
	#delim cr

	local numcol = 3


	local prehead = "\begin{center} \begin{threeparttable} \begin{tabular}{l*{`numcol'}{r}} \hline \hline "
	local posthead = "\hline \multicolumn{4}{l}{\textbf{Panel A: Child-level statistics}}\\"
	local postfoot = ""

	#delim ;
	estout using $outdir\summarystat.tex, replace
	label
	cells("count(fmt(%6.0fc)) mean(fmt(%5.2fc)) sd(fmt(%5.2f))" )
	mlabels(,none) 
	collabels("N" "Mean" "SD" ) 
	refcat(child "Children aged 3--21" enrollemp3 "Children aged 11--21", nolabel) 
	style(tex)
	nonumbers
	prehead(`prehead') 
	posthead(`posthead')
	prefoot()
	postfoot( `postfoot');
	#delim cr

	eststo clear
	
* household sample ------------------------------------------------------------

use $datadir/sample_fixed_hh.dta, replace

gen hh_type = 1 if child >= 1 & grandchild == 0
replace hh_type = 2 if child == 0 & grandchild >= 1
replace hh_type = 3 if child >= 1 & grandchild >= 1
tab hh_type, gen(hh_type)

replace capital = capital/10000
replace capital = . if numworker == 0 | missing(numworker)
replace capital = . if hhbiz == 0 & hh_agri == 0

replace inc_agribiz = inc_agribiz/10000
replace inc_agribiz = 0 if missing(inc_agribiz)
replace inc_agribiz = . if numworker == 0 | missing(numworker)
replace inc_agribiz = . if hhbiz == 0 & hh_agri == 0

label variable hh_type1 "\hspace{5pt} Child-only household"
label variable hh_type2 "\hspace{5pt} Grandchild-only household"
label variable hh_type3 "\hspace{5pt} Child-grandchild household"

label variable ex_edu "\hspace{5pt} Annual educational expense (Baht)"
label variable ex_edu_comparable "\hspace{5pt} Educational expense gap (EEG)"
label variable ex_basic "\hspace{5pt} Annual basic needs expense (Baht)"
label variable ex_disc "\hspace{5pt} Annual discretionary expense (Baht)"
label variable ex_maint "\hspace{5pt} Annual maintenance expense (Baht)"

label variable income_net "\hspace{5pt} Annual household income (Baht)"
label variable hh_agri "\hspace{5pt} In farming"
label variable hhbiz "\hspace{5pt} In business"
label variable numworker "\hspace{5pt} Number of workers"
label variable numworker_hh "\hspace{5pt} Number of household members in business"
label variable capital "\hspace{5pt} Capital (10K Baht)"
label variable inc_agribiz "\hspace{5pt} Farm \& business income (10K Baht)"

	#delim ;
	eststo: estpost
	summarize hh_type1 hh_type2 hh_type3 ex_edu ex_edu_comparable ex_basic ex_disc ex_maint income_net hh_agri hhbiz numworker capital inc_agribiz;
	#delim cr

	local numcol = 3
	
	local prehead = ""
	local posthead = "\hline \multicolumn{4}{l}{\textbf{Panel B: Household-level statistics}}\\"
	local postfoot = "\hline \end{tabular} \end{threeparttable} \end{center}"

	#delim ;
	estout using $outdir\summarystat.tex, append
	label
	cells("count(fmt(%6.0fc)) mean(fmt(%14.2fc)) sd(fmt(%14.2fc))" )
	mlabels(,none) 
	collabels(,none) 
	refcat(hh_type1 "All households" numworker "Households in business", nolabel) 
	style(tex)
	nonumbers
	prehead(`prehead') 
	posthead(`posthead')
	prefoot()
	postfoot( `postfoot');
	#delim cr

	eststo clear