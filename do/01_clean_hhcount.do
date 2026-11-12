* construct hh count in each village

* 1997 data ----
use $rawdatadir_keyinf\dataverse_files_1997\iii.dta, replace
rename newid vilid
rename sp3 hh_count
rename sp4 pop

gen year = 1997

keep vilid year hh_count pop

save $datadir\keyinf_hhcount_1997.dta, replace

* 1998 data ----

use $rawdatadir_keyinf\dataverse_files_1998\k98_vh2.dta, replace
rename newid vilid
rename vh2a hh_count
rename vh2b pop

gen year = 1998

keep vilid year hh_count pop

save $datadir\keyinf_hhcount_1998.dta, replace

* 1999 data ----

use $rawdatadir_keyinf\dataverse_files_1999\k99_vh2.dta, replace
rename newid vilid
rename vh2a hh_count
rename vh2b pop

gen year = 1999

keep vilid year hh_count pop

save $datadir\keyinf_hhcount_1999.dta, replace

* 2000 onwards data ----

local filecode 03vh2
local output $datadir\keyinf_03vh2.dta
include $subprogramdir\sub_merge_townsend_keyinf_file.do

rename newid vilid
rename vh2a hh_count
rename vh2b pop

keep vilid year hh_count pop

forvalues y = 1997/1999 {
	append using $datadir\keyinf_hhcount_`y'.dta
	erase $datadir\keyinf_hhcount_`y'.dta
}

sort vilid (year)
duplicates drop

save `output', replace