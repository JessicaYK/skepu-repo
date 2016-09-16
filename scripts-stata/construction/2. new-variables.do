/* ---------------------------------------------------------------------------- *
* Generating new variables
* Author: Jessica Yu Kyung Koh
* Edited: 2016/09/15
* ---------------------------------------------------------------------------- */
* Bring in data
use "${dir}\..\data\epu-original.dta", clear

* Create log_total
foreach var in `totallist' {
	gen log_total_`var' = log(total_ori_`var')
	replace log_total_`var' = 0 if total_ori_`var' == 0 
}

* Create (raw EPU count/total count)
foreach var in `totallist' {
	gen ratio_`var' = (epu_ori_`var')/(total_ori_`var')
}

* Create log_EPU
foreach var in `totallist' {
	gen log_epu_`var' = log(epu_ori_`var')
	
	* Rename total_ori and epu_ori
	rename total_ori_`var' total_count_`var'
	rename epu_ori_`var' epu_count_`var'
}
					
save "${dir}\..\data\epu-new.dta", replace
