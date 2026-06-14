**********************************************************************  
* Robot and automation
* Singapore Employment Statistics clean do-file
**********************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global data "${main}/Data cleaned"
	global interim "${main}/Data interim"
	global final "${main}/Data final"
	global prof_raw "${main}/Data raw/professor_raw"	
	/*
	global ifr "${main}/Data raw/IFR"
	global kepco  "${main}/Data raw/KEPCO"
	global oarlr "${main}/Data raw/OARLR"
	global singapore "${main}/Data raw/Singapore"
	*/
	
********************************************************************************
* new indcode 머지전 정리 
********************************************************************************
 
use "$prof_raw/RobotInd.dta"
keep if newindcode !=.

save "$interim/newindcode.dta", replace 
********************************************************************************
* append singapore employment 
********************************************************************************
use "$interim/DOS/sgp_empl2_clean.dta"  // 2000~2007 
append using "$interim/DOS/sgp_empl3_clean.dta" // 2008~2025
append using "$interim/UNIDO/sgp_empl.dta" //. 2005~

* merge with industry code 
merge m:1 newindcode using "$interim/newindcode.dta"

br if _merge!=3 // All industries, Metal unspecified 
keep if _merge==3 
drop _merge 

* filtering 
keep if year>=2005 & year <=2023 // 2005~2023년도가 공통으로 존재 (제조업, 비제조업)
keep newindcode year sgp_empl newind
label var sgp_empl "emp_sg j,t"

* long -> wide 
reshape wide sgp_empl, i(newindcode newind) j(year)


foreach year in 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 { 
	ren sgp_empl`year' sgp_empj`year'
	
	label var sgp_empj`year' "Singapore employment in industry j, year `year'"
}

isid newindcode
sort newindcode

* save 
save "$data/sgp_empl.dta", replace // industry-level data 

* only manufacturing 
keep if newindcode >=107 & newindcode <= 119 
save "$data/sgp_empl_mfg.dta", replace 


/*
********************************************************************** 
* wood & furniture 통합
********************************************************************** 
replace newindcode = 118 if newindcode == 119
replace newind = "other manufacturing" if newindcode == 118

collapse (sum) sgp_empl , by(year newindcode newind)
*/

