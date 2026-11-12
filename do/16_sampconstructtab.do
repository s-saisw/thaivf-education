
local text1 "Original sample"
local text2 "Drop if never observed before 2001"
local text3 "Keep only child/grandchild of the head"
local text4 "Drop if head is missing age or education data"
local text5 "Keep only individuals age 3--21"
local text6 "Drop households with only one observation"

forvalues i = 1/6 {
	
	use "$outdir\sampconst_obs`i'.dta", replace
	sum sampobs
	local obs`i': di %6.0fc r(mean)
	
	local line`i' `text`i'' & `obs`i''
	
}



texdoc init "$outdir/sampconst_obs.tex", replace force
tex \begin{center} \begin{threeparttable} \begin{tabular}{l*{1}{r}} \hline \hline 
tex                    &         (1)   \\
tex                    & Sample size   \\
tex \hline
tex `line1' \\
tex `line2' \\
tex `line3' \\
tex `line4' \\
tex `line5' \\
tex `line6' \\
tex \hline
tex \hline \end{tabular} \end{threeparttable} \end{center}
texdoc close