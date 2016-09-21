/* ---------------------------------------------------------------------------- *
* Standardizing EPU and Constructing an overall SK EPU index
* Author: Jessica Yu Kyung Koh
* Edited: 2016/09/16
* ---------------------------------------------------------------------------- */

* ----------- *
* Preparation *
* ----------- *
* Bring in data
use "${dir}\..\data\epu-new.dta", clear

* Declare date as a date variable in order to use date commands later on.
tsset date 	

* Drop if date is before the start date of the South Korea EPU
drop if date < td(`startdate')

* Only keep necessary variables and rename them
capture drop mean* 

foreach news in `epulist' {
	rename ratio_`news' rawepu_`news'
	label var rawepu_`news' "Raw EPU rate: `news'"
	label var adjepu_`news' "Adjusted EPU rate: `news'"
}


* ----------------------------------------------------------------------- *
* Standardize each newspaper's EPU rate to have a unit standard deviation *
* ----------------------------------------------------------------------- *
* Note: unit standard deviation from 1995 onward
foreach news in `epulist' {
	summ adjepu_`news' if date >= td(`startdate_std')	& date <= td(`enddate_std')	// to capture r(sd)
	generate stdepu_`news' = adjepu_`news'/r(sd)
	label var stdepu_`news' "Standardized adjusted epu: `news'"
	
	summ stdepu_`news'
}


* ------------------------- *
* Average across newspapers *
* ------------------------- *
egen meanSKepu = rowmean(stdepu_Donga_own stdepu_Kyunghyang_bigkinds stdepu_Hankyoreh_bigkinds stdepu_Hankook_bigkinds stdepu_Maeil_bigkinds stdepu_KoreaEcon_bigkinds)
label var meanSKepu "Mean of standardized adj. epu of all newspapers from 1990"


* -------------------------------------------------- *
* Standardize the overall SK EPU to have mean of 100 *
* -------------------------------------------------- *
summ meanSKepu if date <= td(`enddate_std')
generate finalSKepu = (meanSKepu*100)/r(mean)
label var finalSKepu "Final South Korean EPU (Standardized with a mean of 100)"


save "${dir}\..\data\epu-final.dta", replace


* --------------------- *
* Merge in the old data *
* --------------------- *
* Drop variables that are to be generated
capture drop finalSKepu2015
import excel "${dir}\..\output\final-epu\Korea_Policy_Uncertainty_Data_2015.xlsx", sheet("Korea EPU Index") firstrow clear							

* Generate the date variable that are consistent with our main data
generate day = 1
destring year, replace
generate date = mdy(month, day, year)
format date %d
drop month day year

* Rename 2015 EPU variable
rename Korea finalSKepu2015

* Merge with the final data
merge 1:1 date using "${dir}\..\data\epu-final.dta"
drop _merge

save "${dir}\..\data\epu-final.dta", replace

* Generate the string version of the date in order to export to excel
generate year = year(date)
tostring year, replace
generate month = month(date)
tostring month, replace
gen Date = month + "/" + year

* Export to excel
export excel Date finalSKepu finalSKepu2015 using "${dir}\..\output\final-epu\skepu-final-excel.xls", sheet("Final SK EPU") firstrow(variables) sheetreplace 
export excel Date meanSKepu stdepu_Donga_own stdepu_Kyunghyang_bigkinds stdepu_Hankyoreh_bigkinds stdepu_Hankook_bigkinds  ///
				stdepu_Maeil_bigkinds stdepu_KoreaEcon_bigkinds using "${dir}\..\output\final-epu\skepu-final-excel.xls", sheet("Std EPU each news") firstrow(variables) sheetreplace
export excel Date rawepu_Donga_own rawepu_Kyunghyang_bigkinds rawepu_Hankyoreh_bigkinds rawepu_Hankook_bigkinds  ///
				rawepu_Maeil_bigkinds rawepu_KoreaEcon_bigkinds using "${dir}\..\output\final-epu\skepu-final-excel.xls", sheet("Raw EPU each news") firstrow(variables) sheetreplace
export excel Date total_count_Donga_own total_count_Kyunghyang_bigkinds total_count_Hankyoreh_bigkinds ///
					total_count_Hankook_bigkinds total_count_KoreaEcon_bigkinds total_count_Maeil_bigkinds using "${dir}\..\output\final-epu\skepu-final-excel.xls", sheet("Raw Total counts") firstrow(variables) sheetreplace
export excel Date epu_count_Donga_own epu_count_Kyunghyang_bigkinds epu_count_Hankyoreh_bigkinds ///
					epu_count_Hankook_bigkinds epu_count_KoreaEcon_bigkinds epu_count_Maeil_bigkinds using "${dir}\..\output\final-epu\skepu-final-excel.xls", sheet("Raw EPU counts") firstrow(variables) sheetreplace					

