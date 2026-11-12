replace hc7o = lower(hc7o)

gen eduyr = 0 if hc7 <= 9
replace eduyr = 1 if hc7 == 11
replace eduyr = 2 if hc7 == 13
replace eduyr = 3 if hc7 == 15
replace eduyr = 4 if hc7 == 17
replace eduyr = 5 if hc7 == 19
replace eduyr = 6 if hc7 == 21
replace eduyr = 7 if hc7 == 23

replace eduyr = 8 if hc7 == 25 & yob <= 1964
replace eduyr = 9 if hc7 == 27 & yob <= 1964
replace eduyr = 10 if hc7 == 29 & yob <= 1964
replace eduyr = 11 if hc7 == 31 & yob <= 1964
replace eduyr = 12 if hc7 == 33 & yob <= 1964
replace eduyr = 12 if hc7 == 35 & yob <= 1964
replace eduyr = 12 if hc7 == 37 & yob <= 1964
replace eduyr = 12 if hc7 == 39 & yob <= 1964

replace eduyr = 7 if hc7 == 25 & yob > 1964
replace eduyr = 8 if hc7 == 27 & yob > 1964
replace eduyr = 9 if hc7 == 29 & yob > 1964
replace eduyr = 10 if hc7 == 31 & yob > 1964
replace eduyr = 11 if hc7 == 33 & yob > 1964
replace eduyr = 12 if hc7 == 35 & yob > 1964
replace eduyr = 12 if hc7 == 37 & yob > 1964
replace eduyr = 12 if hc7 == 39 & yob > 1964

replace eduyr = 11 if hc7 == 41 & yob <= 1964
replace eduyr = 12 if hc7 == 43 & yob <= 1964
replace eduyr = 13 if hc7 == 45 & yob <= 1964
replace eduyr = 13 if hc7 == 47 & yob <= 1964
replace eduyr = 14 if hc7 == 49 & yob <= 1964
replace eduyr = 15 if hc7 == 51 & yob <= 1964
replace eduyr = 16 if hc7 == 53 & yob <= 1964

replace eduyr = 10 if hc7 == 41 & yob > 1964
replace eduyr = 11 if hc7 == 43 & yob > 1964
replace eduyr = 12 if hc7 == 45 & yob > 1964
replace eduyr = 13 if hc7 == 47 & yob > 1964
replace eduyr = 14 if hc7 == 49 & yob > 1964
replace eduyr = 15 if hc7 == 51 & yob > 1964
replace eduyr = 16 if hc7 == 53 & yob > 1964

replace eduyr = 13 if hc7 == 55
replace eduyr = 14 if hc7 == 57
replace eduyr = 15 if hc7 == 59
replace eduyr = 16 if hc7 == 61

replace eduyr = 0 if hc7 == 63

replace eduyr = 16 if hc7 == 63 & hc7o == "bachelor degree"
replace eduyr = 16 if hc7 == 63 & hc7o == "5th year of undergraduate student"
replace eduyr = 16 if hc7 == 63 & hc7o == "5th yr of university"
replace eduyr = 16 if hc7 == 63 & hc7o == "6th year student of medical science faculty"
replace eduyr = 16 if hc7 == 63 & hc7o == "finished equivalent to ba"
replace eduyr = 16 if hc7 == 63 & hc7o == "6th year student of medical science faculty"
replace eduyr = 16 if hc7 == 63 & hc7o == "in the 5th yr of medical science faculty"

replace eduyr = 16 if hc7 == 63 & hc7o == "teacher"
replace eduyr = 16 if hc7 == 63 & hc7o == "teaching subject"

replace eduyr = 16 if hc7 == 63 & hc7o == "finished  police school"
replace eduyr = 16 if hc7 == 63 & hc7o == "finishing police private school"

replace eduyr = 14 if hc7 == 63 & hc7o == "certificate of second year of teacher"

*replace eduyr = 18 if hc7 == 63 //other = master degree
replace eduyr = 18 if hc7 == 63 & hc7o == "master degree" //other = master degree
replace eduyr = 18 if hc7 == 63 & hc7o == "master's degree"
replace eduyr = 18 if hc7 == 63 & hc7o == "studying in first year of master degree"
replace eduyr = 18 if hc7 == 63 & hc7o == "finish m.a."
replace eduyr = 18 if hc7 == 63 & hc7o == "master course"
replace eduyr = 18 if hc7 == 63 & hc7o == "master course."

replace eduyr = 21 if hc7 == 63 & hc7o == "doctor degree"

replace eduyr = age - 6 if !missing(eduyr) & eduyr >= age
