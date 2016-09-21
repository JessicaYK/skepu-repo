/* ---------------------------------------------------------------------------- *
* Identifying Abnormal Months and Imputing EPU for Those Months
* Author: Jessica Yu Kyung Koh
* Edited: 2016/09/15
* ---------------------------------------------------------------------------- */
	
* ----------- *
* Preparation *
* ----------- *	
* Bring in data
use "${dir}\..\data\epu-new.dta", clear

* Declare date as a date variable in order to use date commands later on.
tsset date 	

* Capture drop variables that are to be generated
capture drop meanlag_*	 adjepu*

   

* --------------------------- *
* Identifying abnormal months *
* --------------------------- * 
* Generate lag variables
foreach var in `totallist' {
	generate meanlag_`var' = (total_count_`var'[_n-4] + total_count_`var'[_n-5]  ///
								+ total_count_`var'[_n-6] + total_count_`var'[_n-7] + total_count_`var'[_n-8] + total_count_`var'[_n-9] ///
								+ total_count_`var'[_n-10] + total_count_`var'[_n-11] + total_count_`var'[_n-12] + total_count_`var'[_n-13] ///
								+ total_count_`var'[_n-14] + total_count_`var'[_n-15])/12
								
	label var meanlag_`var' "Mean lag from t-15 to t-4 for `var'"						
}  

* Store dates and newspapers if N(t)/Nbar < 0.3 
local impute_list 					// this is to store newspapers subject to imputation later on
local regressor_list				// this is to store newspapers that are used as regressors
local regressor_list_to_rename		// this is to rename the regressor variables later on

foreach var in `epulist' {
	* Identify abnormal months and store them into the local
	levelsof date if (total_count_`var'/meanlag_`var' < 0.3) & (date >= td(`startdate')) & (date <= td(`enddate')), local(abnormal`var')
	
	* Store if a newspaper is subject to imputation (at least 1 abnormal month detected)
	local mcount`var' : word count `abnormal`var''
	if `mcount`var'' != 0 {
		local impute_list `impute_list' `var'
	}
	
	* Store if a newspaper is going to be used as regressor (no abnormal month detected)
	if `mcount`var'' == 0 {
		local regressor_list `regressor_list' ratio_`var'
		local regressor_list_to_rename `regressor_list_to_rename' `var'
	}
}


* ---------- *
* Imputation *
* ---------- *
* If we need to impute for some months, run the imputation code
local icount : word count `impute_list'

if `icount' != 0 {
	* Capture the number of regressors
	local regressor_count : word count `regressor_list'

	foreach y in `impute_list' {	
		* Regress
		regress ratio_`y' `regressor_list'
		mat coef = e(b)
		
		* Store results to scalars
		foreach num of numlist 1/`regressor_count' {
			scalar regressor`num'_coef = coef[1,`num']
		}
		local cons_num = `regressor_count' + 1
		scalar constant = coef[1,`cons_num']
		
		* Form a local for the equation for our imputation (This is because we are not sure what will be the regressor variables)
				// Equation will be in the following format => constant + regressor1_coef * regressor1 + regressor2_coef * regressor2 .. so on for abnormal months!
		local equation 
		foreach num of numlist 1/`regressor_count' {
			local regressor`num' : word `num' of `regressor_list'
			local equation `equation' + regressor`num'_coef * `regressor`num''
		}
		local equation 		constant `equation'

		* Impute 
		generate adjepu_`y' = ratio_`y'

		foreach month in `abnormal`y'' {
			replace adjepu_`y' = `equation' if date == `month'
		}
	}
}



* For consistency, name no-abnormal epu rates "adj_`var'"
foreach var in `regressor_list_to_rename' {
	generate adjepu_`var'	= ratio_`var'
}

* Save the data
save "${dir}\..\data\epu-new.dta", replace
