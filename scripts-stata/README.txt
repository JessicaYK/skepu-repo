# ============================================================== #
# How to use STATA codes to construct the South Korean EPU index
# Author: Jessica Yu Kyung Koh
# Modified: 2016/09/16
# ============================================================== #

This README file describes how to use the STATA codes to generate the South Korean EPU index and plots. 

1. "macros.do" contains global and local variables that are used throughout all the codes.
   This "macros.do" file should be included in the beginning of a driver file or files that are
   to be run in a stand-alone manner. 
   
2. If the date range for the index changes in the future, you only need to modify "macros.do".
   For example, if the end date of the EPU index changes to July 2017, change the local variable
   "enddate" to 01jul2017. Same applies to the standardization dates. 

3. Once "macros.do" is modified for the right range of dates and newspaper lists,
   simply run "driver.do" to construct the South Korean EPU index. The output will be saved in the 
   "output" folder in the skepu-repo.

   "driver.do" runs all the do files in the "construction" subfolder. The do files in the construction
   subfolder are general enough that if a user changes macro variables in "macro.do", all the other
   do files will automatically account for the changes made in the macros.
   
4. Once the "driver.do" is fully run, a user can plot using the plotting do files in the "plot" subfolder.
   The plotting do files are meant to be run in a stand-alone manner without using the driver file.
   "plot-raw.do" plots the log total counts and EPU rate to check abnormal months, and "plot-final.do"
   generates the final plots of the South Korean EPU index. 

   Note that you might have to fix the x-label intervals manually in the plotting to files to make 
   the plots look nicer.    


# data:

#