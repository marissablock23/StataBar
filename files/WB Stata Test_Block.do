
clear
cd "/desktop/Stata test"
set more off, perm

log using "Log_Block.smcl"

* Household Analysis

use "kor10_household.dta", clear

	* Make sure all households are in same province as listed in assignment
	tab b1r1

	* Rename variables to ease analysis
	rename b7r25 avg_con
	label var avg_con "Average monthly household consumption, Sec. 7 Q25"

	rename b2r1 hhsize
	label var hhsize "Household size, Sec. 2 Q1"
	
	save "kor10_household.dta", replace

	* Generate Unique Household ID
	local id b1r1 b1r2 b1r3 b1r4 b1r5 b1r6 b1r8 b1r9
	foreach i in `id' {
		tostring `i', gen(`i'_2)
	}
	gen id = b1r1_2 + b1r2_2 + b1r3_2 + b1r4_2 + b1r5_2 + b1r6_2 + b1r8_2 + b1r9_2
	label var id "Unique household id"
	
	drop b1r1_2 b1r2_2 b1r3_2 b1r4_2 b1r5_2 b1r6_2 b1r8_2 b1r9_2
	
	* Average Monthly Consumption
	sum avg_con
	tabstat avg_con, stat(mean count) by(hhsize)
	gen hhsize2 = hhsize
	* Collapse data to get average consumption per size of household
	collapse avg_con (count) hhsize, by(hhsize2)
	label var hhsize "# of households per size"
	gen x = avg_con*hhsize
	* Calculate numerator 
	tabstat x, stat(sum)
	* Calculate denomintator
	tabstat hhsize, stat(sum)
	* Divide by hand to get 2539813.3
	
	* Average Monthly Consumption per Capita
	use "kor10_household.dta", clear
	gen avg_con_pc = avg_con/hhsize
	label var avg_con_pc "Average monthly consumption per capita"
	sum avg_con_pc
	
	* Consumption Quintiles
	xtile quint [aw = wert10r] = avg_con, nq(5)
	bysort quint: sum avg_con
	
	* Median Monthly Consumption
	sum avg_con, det
	* The median of the average monthly consumption at the household level is 2149762.

	

*Individual Analysis

use "kor10_individual.dta", clear

	* Rename variables to ease analysis
	rename b5r16 education
	label var education "Highest level of education studied/passed, Sec. 5 Q16"
	* Note: Primary school = 1,2, or 3
	
	rename b5r15 school
	label var school "=2 if still in school, Sec. 5Q15"
	
	* Primary Gross Enrollment Rate
		*1. # of children still in school at primary level, regardless of age
		tabstat school if school==2 & education==1|education==2|education==3, stat(count)
		
		*2. # of school-age population (7-12) in Riau province
		tabstat umur if umur>=7 & umur<=12, stat(count)
		
		* Divide 1 by 2 to get 4678/4013 = 116.6% Primary Gross Enrollment Rate
		
	* Primary Net Enrollment Rate
		*1. # of children ages 7-12 in school at primary level
		tabstat school if school==2 & education==1|education==2|education==3 & umur>=7 & umur<=12, stat(count)
	
		*2. # of school-age population (7-12) in Riau province
		tabstat umur if umur>=7 & umur<=12, stat(count)
		
		* Divide 1 by 2 to get 4669/4013 = 116.3% Primary Net Enrollment Rate

**********************************************************************************
* Assignment 2
* Download latest Barro & Lee data

use "/Users/marissablock/Downloads/BL2013_MF1599_v2.1.dta", clear

	* Filter data to listed countries
	keep if region_code=="East Asia and the Pacific"
	list country BLcode
	drop if BLcode==132 | BLcode==134 | BLcode==136 | BLcode==144 | BLcode==314 | BLcode==342
	tab country

	
	* Low Income and Lower Middle Income
	graph twoway line yr_sch year if country=="Cambodia" & year>1955|| line yr_sch year if country=="Myanmar" & year>1955 || line yr_sch year if country=="Indonesia" & year>1955 || line yr_sch year if country=="Mongolia" & year>1955 || line yr_sch year if country=="Philippines" & year>1955 || line yr_sch year if country=="Viet Nam" & year>1955, legend(label(1 "Cambodia") label(2 "Myanmar") label(3 "Indonesia") label(4 "Mongolia") labe(5 "Philippines") label(6 "Vietnam")) title("Education Attainment, 1960-2010" "Low Income and Lower Middle Income") note("Countries were categorized by the World Bank's 2010 income classification") ylabel(2(2)12)
	graph save Graph "LI_LMI Countries.gph", replace

	* Upper Middle Income and High Income
	graph twoway line yr_sch year if country=="China" & year>1955|| line yr_sch year if country=="Thailand" & year>1955 || line yr_sch year if country=="China, Hong Kong Special Administrative Region" & year>1955 || line yr_sch year if country=="Taiwan" & year>1955 || line yr_sch year if country=="Republic of Korea" & year>1955 || line yr_sch year if country=="Singapore" & year>1955, legend(label(1 "China") label(2 "Thailand") label(3 "Hong Kong") label(4 "Taiwan") labe(5 "Korea") label(6 "Singapore")) title("Education Attainment, 1960-2010" "Upper Middle Income and High Income") note("Countries were categorized by the World Bank's 2010 income classification")	
	graph save Graph "UMI_HI Countries.gph", replace
		
log close


