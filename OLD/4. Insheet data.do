clear all
set mem 200m
set more off
cap cd "C:\Users\Scott\Dropbox\BakerBloom\Political Uncertainty\Data\Korea EPU"
cap cd "C:\Users\srb834\Dropbox\BakerBloom\Political Uncertainty\Data\Korea EPU"

******************************************************
import excel using "South Korea EPU_Regressed.xls", sheet("Original Data") firstrow

gen month = month(Month)
gen year = year(Month)
gen period = year + (month-1)/12

keep year month period *Adj
order year month period


local papers "DongaAdj MaeilAdj HankyorehAdj HankookAdj KoreaAdj KyunghyangAdj"

foreach paper of local papers {
	sum `paper' if year>=1995 & year<=2014
	replace `paper' = `paper'/r(sd)
}

egen korea_index = rowmean(DongaAdj MaeilAdj HankyorehAdj HankookAdj KoreaAdj KyunghyangAdj)

sum korea_index if year>=1995 & year<=2014,de
replace korea_index = korea_index/r(mean)*100

twoway (line korea_index period), xlabel(1990(5)2015)


compress
export excel using korea_epu_data.xlsx, firstrow(variables) replace

save korea_epu_data, replace


/*
OK, then please use the following process to construct the South Korean EPU Index. 
(A) Multiplicatively standardize each paper’s raw EPU rate so that it has unit standard deviation from 1995-2014.  
(B) Using the results of step (A), average across papers by month to obtain an overall South Korean EPU index from January 1990 to December 2014.  
(C) Using the result in step (B), multiplicatively standardize the overall South Korean EPU index to have a mean of 100 from 1995 to 2014.
This procedure mimics how we handle other countries while providing a reasonable splice.  
