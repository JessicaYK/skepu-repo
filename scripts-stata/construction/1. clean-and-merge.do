* ---------------------------------------------------------------------------- *
* Cleaning and merging raw web-scraped data
* Author: Jessica Yu Kyung Koh
* Edited: 2016/09/15
* ---------------------------------------------------------------------------- *

* ---------------------------------------------------------------------------- *
* Importing and Cleaning Bigkinds EPU Count Data
* ---------------------------------------------------------------------------- *
foreach paper in `newspaperid' {
	* Import
	import delimited "${dir}\..\output\counts\bigkinds.csv", clear
	drop v4
	keep if v1 == `paper'
	drop v1
	
	* Generate date variable
	di "newspaper `paper'"
	rename v2 month
	rename v3 year
	generate day = 1
	generate date = mdy(month, day, year)
	format date %d
	label var date "Month of the articles"
	
	drop month year day
	
	* Rename EPU count
	rename v5	epu_ori_`lab`paper''
	label var epu_ori_`lab`paper''		"Original monthly counts of EPU articles: `lab`paper''"
	
	* Save and merge data
	if `paper' == 01101001 {
		save "${dir}\..\data\epu-original.dta", replace
	}	
	else {
		tempfile temp_`lab`paper''
		save "`temp_`lab`paper'''"
		
		use "${dir}\..\data\epu-original.dta", clear
		merge 1:1 date using `temp_`lab`paper'''
		
		drop _merge
		save "${dir}\..\data\epu-original.dta", replace
	}
}


* ---------------------------------------------------------------------------- *
* Importing and Cleaning Bigkinds Total Count Data
* ---------------------------------------------------------------------------- *
foreach paper in `newspaperid' {
	* Import
	import delimited "${dir}\..\output\counts\bigkindstotal.csv", clear
	drop v4
	keep if v1 == `paper'
	drop v1
	
	* Generate date variable
	rename v2 month
	rename v3 year
	generate day = 1
	generate date = mdy(month, day, year)
	format date %d
	label var date "Month of the articles"
	
	drop month year day
	
	* Rename EPU count
	rename v5	total_ori_`lab`paper''
	label var total_ori_`lab`paper''		"Original monthly counts of total articles: `lab`paper''"
	
	* Save and merge data
	tempfile total_`lab`paper''
	save "`total_`lab`paper'''"
	
	use "${dir}\..\data\epu-original.dta", clear
	merge 1:1 date using `total_`lab`paper'''
	
	drop _merge
	save "${dir}\..\data\epu-original.dta", replace
}

* ---------------------------------------------------------------------------- *
* Importing and Cleaning Donga Count Data
* ---------------------------------------------------------------------------- *
* Append Pre and Post Datasets
foreach type in epu total {
	* Bring in Pre Dataset
	import delimited "${dir}\..\output\counts\dongapre2010`type'.csv", clear
	drop v1 v4

	* Generate date variable
	rename v2 month
	rename v3 year
	generate day = 1
	generate date = mdy(month, day, year)
	format date %d
	label var date "Month of the articles"
	drop month year day
	
	* Rename count
	rename v5	`vardongapre2010`type''	
	label var 	`vardongapre2010`type''		"Origial monthly counts of `type' articles: Donga"

	* Save and data
	tempfile temp_dongapre`type'
	save "`temp_dongapre`type''"
	
	* Bring in Post Dataset
	import delimited "${dir}\..\output\counts\dongapost2010`type'.csv", clear
	drop v3

	* Generate date variable
	rename v1 month
	rename v2 year
	generate day = 1
	generate date = mdy(month, day, year)
	format date %d
	label var date "Month of the articles"
	drop month year day
	
	* Rename count
	rename v4	`vardongapre2010`type''	
	label var 	`vardongapre2010`type''		"Origial monthly counts of `type' articles: Donga"

	* Save and data
	tempfile temp_dongapost`type'
	save "`temp_dongapost`type''"
	
	append using `temp_dongapre`type''
	sort date
	tempfile temp_append`type'
	save "`temp_append`type''"


	use "${dir}\..\data\epu-original.dta", clear
	merge 1:1 date using `temp_append`type''

	drop _merge
	sort date
	save "${dir}\..\data\epu-original.dta", replace	
}

* ---------------------------------------------------------------------------- *
* Importing and Cleaning Naver News Library Data
* ---------------------------------------------------------------------------- *
import delimited "${dir}\..\output\counts\newslibrary.csv", clear

generate day = 1
generate date = mdy(month, day, year)
format date %d
label var date "Month of the articles"
drop month year day

* Rename variables to make them consistent with other variables
rename epu_ori_donga_naver			epu_ori_Donga_naver
rename epu_ori_kyunghyang_naver		epu_ori_Kyunghyang_naver
rename epu_ori_maeil_naver			epu_ori_Maeil_naver
rename epu_ori_hankyoreh_naver		epu_ori_Hankyoreh_naver
rename total_ori_kyunghyang_naver	total_ori_Kyunghyang_naver
rename total_ori_donga_naver		total_ori_Donga_naver
rename total_ori_maeil_naver		total_ori_Maeil_naver
rename total_ori_hankyoreh_naver	total_ori_Hankyoreh_naver


tempfile temp_naverlibrary
save "`temp_naverlibrary'"

use "${dir}\..\data\epu-original.dta", clear
merge 1:1 date using `temp_naverlibrary'

drop _merge
sort date
save "${dir}\..\data\epu-original.dta", replace
