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
	
********************************************************************** 
use "$data/kor_empl.dta" 

merge m:1 newindcode using "$data/sgp_empl.dta" , nogen assert(3)

merge m:1 newindcode year using "$data/IFR_long.dta"
tab year if _merge!=3 
drop _merge 
**********************************************************************
* X, IV 만들기 
**********************************************************************

foreach base_emp in 2005 2006 2007 {

    * X (Korean shock)
    gen _term_X = share`base_emp' * drobot_kr / emp_j`base_emp'
    bysort year regioncode: egen X_annual`base_emp' = total(_term_X)
    drop _term_X

    * IV (Singapore shock)
    gen _term_IV = share95 * drobot_sg / sgp_empj`base_emp'
    bysort year regioncode: egen IV_annual`base_emp' = total(_term_IV)
    drop _term_IV

    label variable X_annual`base_emp'  "Bartik X annual (base=`base_emp')"
    label variable IV_annual`base_emp' "Bartik IV SG annual (base=`base_emp')"
}


duplicates drop year regioncode, force
keep if year>=2006 

keep year regioncode newindcode sido_nm sigungu_nm rb_kr rb_sg drobot_kr drobot_sg X_annual2005 IV_annual2005 X_annual2006 IV_annual2006 X_annual2007 IV_annual2007

duplicates drop year regioncode, force
tab year // 지역 229개씩 

isid year regioncode

save "$data/X_final_klips.dta", replace
