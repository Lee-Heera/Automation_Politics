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
use "$interim/COE_empl_control.dta"  // COE 데이터에서 나온 고용비율 보고 -> 제조업 비율 산출하기 

keep year regioncode newindcode emp_ijt firm  sido_nm sigungu_nm newind emp_it 

isid year regioncode newindcode // unique 

keep if year>=1997 
/*
// 지역필터링
drop if sido_nm=="제주특별자치도" 
drop if sido_nm=="세종특별자치시"
*/

tab year 

* 제조업 더미
gen is_mfg = (newindcode >= 107 & newindcode <= 119) // 제조업 newindcode: 107~119

* 지역-연도별 제조업 고용 합산 → 제조업 비중
bysort year regioncode: egen mfg_emp = total(emp_ijt * is_mfg)
gen manu_share = mfg_emp / emp_it
drop mfg_emp
assert manu_share >= 0 & manu_share <= 1 & manu_share!=. 

* 지역-연도별 제조업 사업체 합산 -> 제조업 비중 
bys year regioncode: egen mfg_firm = total(firm * is_mfg)
bys year regioncode: egen firm_it = total(firm) // 
gen manu_share2 = mfg_firm / firm_it
assert manu_share2 >= 0 & manu_share2 <= 1 & manu_share2!=. 
drop mfg_firm

keep year regioncode sido_nm sigungu_nm manu_share manu_share2

duplicates drop year sido_nm regioncode, force
isid year regioncode
tab year

sort regioncode year 

save "$data/manu_control.dta",replace 
