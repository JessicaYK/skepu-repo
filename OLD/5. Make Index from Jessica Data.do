clear all
set mem 200m
set more off
cap cd "C:\Users\scottb131\Dropbox\BakerBloom\Political Uncertainty\Data\Korea EPU"

import excel using "Jessica_Data.xlsx", firstrow

local papers "donga kyunghyang maeil hankyoreh hankook koreaecon"

rename Mon date
gen month = month(date)
gen year = year(date)

foreach paper of local papers {
	gen `paper'_index = epu_`paper'/total_`paper'
}

foreach paper of local papers {
	sum `paper'_index if year<2011
	replace `paper'_index = `paper'_index/r(sd)
}

egen korea_epu = rowmean(*_index)
sum korea_epu if year<2011
replace korea_epu = korea_epu/r(mean)*100


gen period = year + (month-1)/12

twoway (line *index period, xlabel(1990(5)2015) xtitle(""))


twoway (line korea_epu period, xlabel(1990(5)2015) xtitle(""))


stop

keep year month korea_epu

cap cd "C:\Users\scottb131\Dropbox\Policy Uncertainty Website\media"

tostring year, replace
global num_obs = _N+1
set obs $num_obs
replace year = "Source: “Measuring Economic Policy Uncertainty” by Scott Baker, Nicholas Bloom and Steven J. Davis at www.PolicyUncertainty.com.  These data can be used freely with attribution to the authors, the paper, and the website." in $num_obs

preserve
rename korea Korea
keep year month Korea
export excel using Korea_Policy_Uncertainty_Data.xlsx, firstrow(varlabels) replace sheet("Korea EPU Index")
restore
