/* ---------------------------------------------------------------------------- *
* Plotting South Korean EPU data
* Author: Jessica Yu Kyung Koh
* Edited: 2016/09/16
* Note: This do file plots (Raw Monthly EPU Count/Total Monthly Article Count) 
		on left vertical scale, and ln(Total Monthly Article Count) on the right 
		vertical scale. Calendar time in months on the horizontal axis. If there
		are two archive sources for the same newspaper, then both are plotted
		on the same chart. 
* ---------------------------------------------------------------------------- */

clear all

* ----------- *
* Preparation *
* ----------- *
* Locals for directory and newspapers
local dir : pwd

* Include macros
include "`dir'/../macros.do"

* Locals for plotting
local region				graphregion(color(white))

local xtitle				xtitle(Month)
local ylabel				ylabel(3(1)9)
local xlabel				xlabel(, labsize(small))
local ytitle1				ytitle(Log Total Count, height(5) color(navy))
local ytitle2				ytitle((EPU Counts)/(Total Counts), axis(2) height(5) color(maroon))

* Bring in data
use "`dir'\..\..\data\epu-new.dta", clear


* -------- *
* 1. Donga *
* -------- *
* locals of start and end dates for plotting.
local sdate1	01jan1930
local edate1	01dec1975
local sdate2	01jan1976
local edate2	`enddate'
local legend1	legend(off)
local legend2	legend(label(1 "Log Total (Donga Archive)") label(2 "Log Total (Naver)") ///
				   label(3 "EPU-Total Ratio (Donga Archive)") label(4 "EPU-Total Ratio (Naver)") size(small))

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

	twoway (line log_total_Donga_own date, yaxis(1) `region' `xtitle' `ytitle1' `ytitle2' `xlabel' color(navy) `legend`i'' name(plot_donga`i') xlabel(`s_sdate`i''(2000)`s_edate`i'')) ///
			(line log_total_Donga_naver date, yaxis(1) `region' color(emidblue) ) ///
			(line ratio_Donga_own date, yaxis(2) color(maroon)) ///
			(line ratio_Donga_naver date, yaxis(2) color(erose) ) 
	restore
}

graph combine plot_donga1 plot_donga2, col(1) graphregion(color(white))
graph export "`dir'\..\..\output\plots\plot_donga_combined.eps", replace

* ------------- *
* 2. Kyunghyang *
* ------------- *
* locals of start and end dates for plotting.
local sdate1	01jan1946
local edate1	01dec1980
local sdate2	01jan1981
local edate2	`enddate'
local legend1	legend(off)
local legend2	legend(label(1 "Log Total (Naver)") label(2 "Log Total (Big Kinds)") ///
						label(3 "EPU-Total Ratio (Naver)") label(4 "EPU-Total Ratio (Big Kinds)") size(small))

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

	twoway (line log_total_Kyunghyang_naver date, yaxis(1) `region' `xtitle' `ytitle1' `ytitle2' `xlabel' color(navy) `legend`i'' name(plot_kyunghyang`i') xlabel(`s_sdate`i''(1800)`s_edate`i'')) ///
			(line log_total_Kyunghyang_bigkinds date, yaxis(1) `region' color(emidblue)) ///
			(line ratio_Kyunghyang_naver date, yaxis(2) color(maroon)) ///
			(line ratio_Kyunghyang_bigkinds date, yaxis(2) color(erose)) 

	restore
}

graph combine plot_kyunghyang1 plot_kyunghyang2, col(1) graphregion(color(white))
graph export "`dir'\..\..\output\plots\plot_kyunghyang_combined.eps", replace

* -------- *
* 3. Maeil *
* -------- *
* locals of start and end dates for plotting.
local sdate1	01mar1966
local edate1	01dec1990
local sdate2	01jan1991
local edate2	`enddate'
local legend1	legend(off)
local legend2 	legend(label(1 "Log Total (Naver)") label(2 "Log Total (Big Kinds)") label(3 "EPU-Total Ratio (Naver)") label(4 "EPU-Total Ratio (Big Kinds)") size(small))

* Define scalars for the start and end dates (for xlabel)				   
scalar s_sdate1 = td(`sdate1')
scalar s_edate1 = td(`edate1')
scalar s_sdate2 = td(`sdate2')
scalar s_edate2 = td(`edate2')						
						
local s_sdate1 = s_sdate1
local s_edate1 = s_edate1
local s_sdate2 = s_sdate2
local s_edate2 = s_edate2

replace log_total_Maeil_bigkinds = . if date < td(01jan1995)

foreach i in 1 2 {
	preserve
	keep if date >= td(`sdate`i'') & date <= td(`edate`i'')

	twoway (line log_total_Maeil_naver date, yaxis(1) `region' `xtitle' `ytitle1' `ytitle2' `xlabel' color(navy) `legend`i'' name(plot_maeil`i') xlabel(`s_sdate`i''(1550)`s_edate`i'')) ///
			(line log_total_Maeil_bigkinds date, yaxis(1) `region' color(emidblue) ) ///
			(line ratio_Maeil_naver date, yaxis(2) color(maroon)) ///
			(line ratio_Maeil_bigkinds date, yaxis(2) color(erose)) 
	restore
}

graph combine plot_maeil1 plot_maeil2, col(1) graphregion(color(white))
graph export "`dir'\..\..\output\plots\plot_maeil_combined.eps", replace 

* ------------------ *
* 4. Hankyoreh Naver *
* ------------------ *
preserve

keep if date >= td(01may1988) 

twoway (line log_total_Hankyoreh_naver date, yaxis(1) `region' `xtitle' `ytitle1' `ytitle2' `xlabel' color(navy)  ///
										legend(label(1 "Log Total (Naver)") label(2 "Log Total (Big Kinds)") ///
											   label(3 "EPU-Total Ratio (Naver)") label(4 "EPU-Total Ratio (Big Kinds)") size(small)) ) ///
		(line log_total_Hankyoreh_bigkinds date, yaxis(1) `region' color(emidblue)) ///
		(line ratio_Hankyoreh_naver date, yaxis(2) color(maroon) ) ///
		(line ratio_Hankyoreh_bigkinds date, yaxis(2) color(erose) ) 

graph export "`dir'\..\..\output\plots\plot_hankyoreh.eps", replace

restore


* -------------- *
* 5. HankookIlbo *
* -------------- *
preserve

keep if date >= td(01jan1990)

twoway (line log_total_Hankook_bigkinds date, yaxis(1) `region' `xtitle' `ytitle1' `ytitle2' `xlabel' color(navy) ///
										legend(label(1 "Log Total (Big Kinds)") label(2 "EPU-Total Ratio (Big Kinds)") size(small)) ) ///
		(line ratio_Hankook_bigkinds date, yaxis(2) color(maroon)) 
graph export "`dir'\..\..\output\plots\plot_hankook.eps", replace

restore


* -------------------------- *
* 6. Korea Economic Bigkinds *
* -------------------------- *
preserve

keep if date >= td(01jan1995)

twoway (line log_total_KoreaEcon_bigkinds date, yaxis(1) `region' `xtitle' `ytitle1' `ytitle2' `xlabel' color(navy) ///
										legend(label(1 "Log Total (Big Kinds)") label(2 "EPU-Total Ratio (Big Kinds)") size(small)) ) ///
		(line ratio_KoreaEcon_bigkinds date, yaxis(2) color(maroon)) 
graph export "`dir'\..\..\output\plots\plot_koreaecon.eps", replace


restore
