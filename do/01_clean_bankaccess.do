use $rawdatadir_keyinf\dataverse_files_1997\iv.dta, replace
rename newid vilid

gen bank_access = 0
foreach x in d f g {
	replace bank_access = 1 if iob1`x' == 1
}

gen bank_in_village = 0
foreach x in d f g {
	replace bank_in_village = 1 if iob3`x' == 1
}

gen bank_in_tambon = 0
replace bank_in_tambon = 1 if bank_in_village == 1
foreach x in d f g {
	replace bank_in_tambon = 1 if iob3`x' == 3
}

keep vilid bank_access bank_in_village bank_in_tambon
destring vilid, replace

save $datadir\bank_access_1997.dta, replace
