clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin"
use "총선 선거구별 선거인수 정보_2008.dta"

***************************** 변수명 변경 / 정리 
destring emdCount tpgCount ppltCnt ntabPpltCnt frgnrPpltCnt cfmtnElcnt cfmtnRacnt cfmtnFrgnrCnt cfmtnManElcnt cfmtnManRacnt cfmtnManFrgnrCnt cfmtnFmlElcnt cfmtnFmlRacnt cfmtnFmlFrgnrCnt cfmtnRdvtDccnt cfmtnNtabRdvtDccnt cfmtnRdvtManDccnt cfmtnNtabRdvtManDccnt cfmtnRdvtFmlDccnt cfmtnNtabRdvtFmlDccnt, replace 

rename sdName sido_nm 
rename wiwName sigungu_nm 

** 연도 변수 생성 
gen year = substr(sgId, 1, 4)
destring year, replace

tab year 

keep if year ==2008 | year == 2012 | year ==2016 | year == 2020 | year == 2024  // 선거연도만 남기기 

keep year sgId sido_nm sggName sigungu_nm emdCount ppltCnt cfmtnElcnt

tab sigungu_nm sggName if year==2016 & sido_nm=="경상남도"  
// 통영시고성군 선거구가 없음(무투표 당선)
// 또한, 당선인 통계에는 존재하나, 선거구별 선거인수 정보 제공하지 않음 
// 읍면동 데이터에서 보고 직접입력 

// ppltCnt 인구수
// cfmtnElcnt 확정선거인수

************************
drop if sggName == "합계"

* 2016년 통영시 직접입력 (통영시고성군)
set obs `=_N+1'
replace sido_nm = "경상남도" in L
replace sggName = "통영시고성군" in L 
replace sigungu_nm = "통영시" in L
replace year = 2016 in L
replace sgId = "20160413" in L
replace ppltCnt = 138934 in L
replace cfmtnElcnt  = 112206  in L

* 2016년 고성군 직접입력 (통영시고성군)
set obs `=_N+1'
replace sido_nm = "경상남도" in L
replace sggName = "통영시고성군" in L 
replace sigungu_nm = "고성군" in L
replace year = 2016 in L
replace sgId = "20160413" in L
replace ppltCnt = 55067 in L
replace cfmtnElcnt  = 47604  in L
************************* 
drop if sigungu_nm == "합계"
**************************
collapse (sum) ppltCnt cfmtnElcnt, by(year sido_nm sggName)

tab year // 2016년확인 2016년 경남 

// obs = 1251 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin"
save "cong선거인수_선거구.dta",replace 
*******************************************************************************
clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin"
use "총선 선거구별 선거인수 정보_2008.dta"

***************************** 변수명 변경 / 정리 
destring emdCount tpgCount ppltCnt ntabPpltCnt frgnrPpltCnt cfmtnElcnt cfmtnRacnt cfmtnFrgnrCnt cfmtnManElcnt cfmtnManRacnt cfmtnManFrgnrCnt cfmtnFmlElcnt cfmtnFmlRacnt cfmtnFmlFrgnrCnt cfmtnRdvtDccnt cfmtnNtabRdvtDccnt cfmtnRdvtManDccnt cfmtnNtabRdvtManDccnt cfmtnRdvtFmlDccnt cfmtnNtabRdvtFmlDccnt, replace 

rename sdName sido_nm 
rename wiwName sigungu_nm 

** 연도 변수 생성 
gen year = substr(sgId, 1, 4)
destring year, replace

tab year 

keep if year ==2008 | year == 2012 | year ==2016 | year == 2020 | year == 2024  // 선거연도만 남기기 

keep year sgId sido_nm sggName sigungu_nm emdCount ppltCnt cfmtnElcnt

tab sigungu_nm sggName if year==2016 & sido_nm=="경상남도"  
// 통영시고성군 선거구가 없음(무투표 당선)
// 또한, 당선인 통계에는 존재하나, 선거구별 선거인수 정보 제공하지 않음 
// 읍면동 데이터에서 보고 직접입력 

// ppltCnt 인구수
// cfmtnElcnt 확정선거인수
*********************************
* 2016년 통영시 직접입력 (통영시고성군)
set obs `=_N+1'
replace sido_nm = "경상남도" in L
replace sggName = "통영시고성군" in L 
replace sigungu_nm = "통영시" in L
replace year = 2016 in L
replace sgId = "20160413" in L
replace ppltCnt = 138934 in L
replace cfmtnElcnt  = 112206  in L

* 2016년 고성군 직접입력 (통영시고성군)
set obs `=_N+1'
replace sido_nm = "경상남도" in L
replace sggName = "통영시고성군" in L 
replace sigungu_nm = "고성군" in L
replace year = 2016 in L
replace sgId = "20160413" in L
replace ppltCnt = 55067 in L
replace cfmtnElcnt  = 47604  in L
*********** 
collapse (sum) ppltCnt cfmtnElcnt, by(year sido_nm sigungu_nm sggName)

drop if sido_nm=="합계" & sigungu_nm=="합계" & sggName == "합계"
drop if sigungu_nm=="합계"  & sigungu_nm=="합계" 
