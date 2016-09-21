/* --------------------------------------------------------------------------- *
* Macros for the South Korea EPU Construction
* Author: Jessica Yu Kyung Koh
* Edited: 2016/09/15
* Note: This do file contains global and local variables that are going to be
        used in all do files for the construction of the South Korea EPU index.
* --------------------------------------------------------------------------- */

* ---------------------------------------------------------------------------- *
* Locals
* ---------------------------------------------------------------------------- *
* Newspapers
local newspaperid			01101001 01101101 01100101 02100101 02100601
local totallist 			Hankyoreh_bigkinds Hankook_bigkinds Kyunghyang_bigkinds ///
							Maeil_bigkinds KoreaEcon_bigkinds Donga_own Donga_naver ///
							Kyunghyang_naver Maeil_naver Hankyoreh_naver		// This is the list of parts of all newspaper variable names.
							
local epulist 				Hankook_bigkinds Maeil_bigkinds KoreaEcon_bigkinds ///
							Donga_own Hankyoreh_bigkinds Kyunghyang_bigkinds // This is the newspapers used in the construction of SK EPU 

* Start and end dates for the current range of South Korea EPU
local startdate				01jan1990
local enddate				01jul2016

* Start and end date for standardization
local startdate_std			01jan1995
local enddate_std			01dec2014							
							
* Labels for newspapers
local lab01101001 			Hankyoreh_bigkinds
local lab01101101 			Hankook_bigkinds
local lab01100101 			Kyunghyang_bigkinds
local lab02100101 			Maeil_bigkinds
local lab02100601 			KoreaEcon_bigkinds

* For variable names
local vardongapre2010epu	epu_ori_Donga_own
local vardongapre2010total	total_ori_Donga_own
local vardongapost2010epu	epu_ori_Donga_own
local vardongapost2010total	total_ori_Donga_own

		
