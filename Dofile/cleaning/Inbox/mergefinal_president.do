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
*******************************************************************************
****** Control variable (merge)
use "$data/demoshare_control.dta"

merge m:1 regioncode year using "$data/immi_control.dta"
drop _merge 

merge m:1 regioncode year using "$data/manu_control.dta"
tab year if _merge!=3 
keep if _merge==3 
drop _merge 
tab year

merge m:1 regioncode year using "$data/migration_control.dta"
tab year if _merge==2 // 2000~2006년도 + 2007년 이후 (제주도 관측치 2개씩)
keep if _merge==3 
drop _merge 

tab year 

save "$data/control_clean.dta", replace 
*******************************************************************************
use "$data/X_final.dta", clear 

merge m:1 regioncode year using "$data/Y_final.dta"
drop _merge // _merge==1, _merge==2 일단 살리기 

merge m:1 regioncode year using "$data/X_final_mfg.dta"
tab year if _merge==1 
drop _merge 

merge m:1 regioncode year using "$data/control_clean.dta"
tab year if _merge ==2 
tab year if _merge ==1

keep if _merge==3 | _merge==1 
drop _merge
tab year // 불균형패널 

drop if sido_nm== "제주특별자치도"
tab year 

// Final 
// 제주도 제외 227개 지역 * 1997, 2002, 2007, 2012, 2017, 2022 

save "$final/Final_president.dta", replace 
