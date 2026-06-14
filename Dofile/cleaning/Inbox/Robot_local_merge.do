******************************************************
* 연도별 지선 데이터 append (2006,2010,2014,2018,2022)
******************************************************
clear 
cd "/Users/ihuila/Desktop/data/master thesis/" 

************************
// 1. 로봇데이터 (수정전)
use raw/Prof_raw/Robot1.dta 

*************************
// 2. 로봇데이터 (싱가포르로 수정 후)
merge m:1 countyid year using raw/Prof_raw/SG_IVs_v101.dta 

tab year if _merge==2 // 2004~2009년도까지 229개씩 
br if _merge==2 

keep if _merge==3 
drop _merge 

tab year // 2010~2022, 229개씩 
 
*************************
// 3. 종속변수 
merge m:1 regioncode year using afterlocal/local_panel.dta 

tab year if _merge==2 // 지선 데이터에만 있는 2006년도 값 때문에 

tab year if _merge==1 // 대선 데이터에 없는 연도 때문에 + 2010년도 세종 
br if _merge==1 & year == 2010

keep if _merge==3 
drop _merge 

tab year // 2010, 2014, 2018, 2022 (2010년도만 obs 228, 나머지연도 229)
*************************
// 4. 통제변수 
merge m:1 sido_nm sigungu_nm year using after/sigungucontrol.dta

br if _merge==1  // 통제변수 데이터에는 제주도 없음 
drop if _merge==1 

br if _merge==2 
tab year if _merge==2  // 227개씩 

// lagged control variable 쓸거라서 2007년도 데이터 남겨두기 
// 원래 지선에서 2010년도 전기는 2006년도이지만, 편의상 2007년도 사용 

keep if _merge==3 | year==2007 

tab year // 2007, 2010, 2014, 2018, 2022 

sort sido_nm sigungu_nm

drop _merge 

*************************
//5. immigrant 데이터 추가머지하기 
merge m:1 sido_nm sigungu_nm year using after/KOREA_immigration_clean.dta

br if _merge==2 
tab year if _merge==2 // 머지 안된 데이터는 2007~2010년도 데이터 

drop if _merge==2 
drop _merge

drop if sido_nm == "세종특별자치시"
drop if sido_nm == "제주특별자치도"

tab year // obs = 226 

save "after/Robot_local_merge.dta", replace 
