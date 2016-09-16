/* --------------------------------------------------------------------------- *
* Driver file for South Korea EPU Construction
* Author: Jessica Yu Kyung Koh
* Modified: 09/15/2016
* Note: This is a driver file that runs all the necessary do files for constructing
        the South Korea EPU index. Those who need to replicate constructing South
		Korea EPU index should simply run this driver file, and it will generate 
		the overall SK EPU index as well as individual newspaper EPU index. 
		Note that this driver file does not deal with plotting. 
* --------------------------------------------------------------------------- */		
clear all

* Set directory
global dir : pwd

* Include the macros
include "${dir}/macros.do"

* Include do files
include "${dir}/construction/1. clean-and-merge.do"
include "${dir}/construction/2. new-variables.do"
include "${dir}/construction/3. imputation.do"
include "${dir}/construction/4. standardization.do"
