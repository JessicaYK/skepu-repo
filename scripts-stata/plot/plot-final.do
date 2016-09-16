/* ---------------------------------------------------------------------------- *
* Plotting the final EPU data
* Author: Jessica Yu Kyung Koh
* Edited: 2016/08/17
* ---------------------------------------------------------------------------- */

clear all

* ----------- *
* Preparation *
* ----------- *
* Locals for directory and newspapers
local dir : pwd

* Bring in macros
include "`dir'\..\macros.do"

* Bring in data
use "`dir'\..\..\data\epu-final.dta", clear


* ------------------------------ *
* Individual Newspaper EPU Plots * 
* ------------------------------ *
* Locals
local region	graphregion(color(white)) lwidth(vvthin)
local xtitle	xtitle(Month)
local ytitle 	ytitle(Standardized EPU Rate)
local sdate1	`startdate'
local edate1	01dec2005
local sdate2	01jan2006
local edate2	`enddate'
local legend1	legend(off)
local legend2	legend(label(1 "Dong Ilbo") label(2 "Kyunghyang News") ///
							label(3 "Maeil Economic") label(4 "Hankyoreh")  ///
							label(5 "Hankook Ilbo") label(6 "Korea Econ") size(small))

* Define scalars for the start and end dates (for xlabel)				   
scalar s_sdate1 = td(`sdate1')
scalar s_edate1 = td(`edate1')
scalar s_sdate2 = td(`sdate2')
scalar s_edate2 = td(`edate2')				   

local s_sdate1 = s_sdate1
local s_edate1 = s_edate1
local s_sdate2 = s_sdate2
local s_edate2 = s_edate2							
							
foreach i in 1 2 {
	preserve
	keep if date >= td(`sdate`i'') & date <= td(`edate`i'')

	twoway (line stdepu_Donga_own date, `region' `xtitle' `ytitle' `legend`i''  name(plot_final`i') xlabel(`s_sdate`i''(950)`s_edate`i'')) ///
		(line stdepu_Kyunghyang_bigkinds date) ///
		(line stdepu_Maeil_bigkinds date) ///
		(line stdepu_Hankyoreh_bigkinds date) ///
		(line stdepu_Hankook_bigkinds date) ///
		(line stdepu_KoreaEcon_bigkinds date) 
	restore
}


graph combine plot_final1 plot_final2, col(1) graphregion(color(white))
graph export "`dir'\..\..\output\plots\plot_final_combined.eps", replace
			

* ----------------------------- *
* Overall South Korea EPU Plots *
* ----------------------------- *			
* Locals
local region	graphregion(color(white)) 
local xtitle	xtitle(Month)
local ytitle 	ytitle(South Korea EPU)
local legend 	legend(label(1 "New") label(2 "Old"))

* One that plots the new South Korean EPU index form 1990 onwards
twoway (line finalSKepu date, `region' `xtitle' `ytitle')
graph export "`dir'\..\..\output\plots\plot_final_skepu.pdf", replace

* One that plots the new and old South Korean EPU index from 1990 to 2014.
twoway (line finalSKepu date, `region' `xtitle' `ytitle' `legend') ///
		(line finalSKepu2015 date)
graph export "`dir'\..\..\output\plots\plot_final_skepu_w2015.pdf", replace


* --------------- *
* For Power point *
* --------------- *
* Locals
local region	graphregion(color(white)) 
local xtitle	xtitle("")
local ytitle 	ytitle("")
local yearlist  1990 1995 2000 2005 2010 2015

local xlabellist

foreach year in `yearlist' {
	local s`year' = td(01jan`year')
	di `s`year''
	local xlabellist `xlabellist' `s`year'' "`year'"
}

local xlabel	xlabel(`xlabellist')

twoway (line finalSKepu date, `region' `xtitle' `ytitle' `xlabel')
graph export "`dir'\..\..\output\plots\plot_final_skepu_pp.png", replace
