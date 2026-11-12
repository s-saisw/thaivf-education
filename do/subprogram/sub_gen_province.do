gen province = substr(newid, 1, 2)
destring province, replace
replace province = 24 if province == 7
replace province = 31 if province == 27
replace province = 33 if province == 53
replace province = 16 if province == 49

/*
local provtag16 "Lopburi"
local provtag24 "Chachoengsao"
local provtag31 "Buriram"
local provtag33 "Sisaket"
local provtag54 "Phrae"
local provtag67 "Petchabun"
local provtag91 "Satun"

foreach p in 16 24 31 33 49 54 67 91 {
	gen province`p' = (province == `p')
	label variable province`p' `provtag`p''
}
*/
