
if missing(`"`statlist'"') {
    local statlist N samp 
	local statlab `" Observations Sample "'
	local statfmt %15.0fc 3
} 
else {
	local statlist `statlist'
	local statlab `statlab'
	local statfmt `statfmt'
}

if missing(`"`estorder'"') {
    local estorder ""
} 
else {
	local estorder `estorder'
}

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

if missing(`"`noclear'"') {
	eststo clear
}
else if (`noclear' == 1) {
	di "keep stored est"
}


	
