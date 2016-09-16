# =========================================== #
# Description of the folder structure
# Author: Jessica Yu Kyung Koh
# Modified: 2016/09/16
# =========================================== #

This README file describes how the folders are structured in the "South Korea EPU."

# data:
	This folder contains merged and cleaned data from original output csv's.
	The data is generated from the STATA codes. 

# documentation:
	This folder includes all the documentations for the construction of the South Korea EPU index,
	including memo.
	
# output:
	This folder includes outputs from the codes, mainly,
	(1) csv files that contain counts of news articles (scraped with Perl codes)
	(2) plots for South Korea EPU analysis (generated from STATA codes)
	(3) Final South Korea EPU index data in an excel file. 
	
# scripts-perl:
	This folder contains Perl scripts used for web-scraping. 
	(1) Subfolder named "old" contains old scripts that are no longer used.
	(2) Subfolder named "futurework" contains scripts that can be used once the website issues are fixed.
	(3) Scripts that are not contained in the subfolders above are the ones that we currently use 
		to scrape article numbers
		
# scripts-stata
	This folder contains STATA scripts used for merging and cleaning, plotting, regressions, and construction
	of indices. In order to replicate all the results, please read the "README" file inside the "scripts-stata"
	folder. 
	