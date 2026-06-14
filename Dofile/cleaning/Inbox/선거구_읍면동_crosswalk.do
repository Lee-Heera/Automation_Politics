****************************읍면동별 데이터 **********************************
clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin"

use "총선 읍면동별 선거인수_2008.dta" 

** 변수명 변경 
rename (tpgCount ppltCnt cfmtnElcnt cfmtnManElcnt cfmtnFmlElcnt) (tpgCount_emd ppltCnt_emd  cfmtnElcnt_emd cfmtnManElcnt_emd cfmtnFmlElcnt_emd)
rename sdName sido_nm 
rename wiwName sigungu_nm 

** 연도 변수 생성 
gen year = substr(sgId, 1, 4)
destring year, replace
keep if year ==2008 | year == 2012 | year ==2016 | year == 2020 | year == 2024  // 선거연도만 남기기 

***** 
br if year==2016 & sido_nm=="경상남도" 

drop if emdName == "합계"

tab year 






collapse (sum) ppltCnt, by(year sigungu_nm)

// 읍면동별 단위 데이터랑 머지 
merge 1:m sgId sido_nm sigungu_nm year using "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congwin_crosswalk_시군구선거구.dta"

drop _merge 
drop tpgCount 

order year sido_nm sigungu_nm sggName emdName 

collapse (sum) ppltCnt_emd cfmtnElcnt_emd,  by(year sido_nm sigungu_nm sggName)


// 여기부터 

/*
**************************** 2008년 ****************************************
* 로봇데이터 기준의 시군구로 맞추기 
// sigungu_nm2 생성 (기본값은 sigungu_nm 그대로)
gen sigungu_nm2 = sigungu_nm

// 통일
// replace sigungu_nm2 = "창원시"  if inlist(sigungu_nm, "마산시", "진해시", ///
                                  "창원시의창구", "창원시성산구", ///
                                  "창원시마산합포구", "창원시마산회원구", "창원시진해구")
// replace sigungu_nm2 = "청주시"  if inlist(sigungu_nm, "청주시상당구", ///
                                  "청주시흥덕구", "청원군", ///
                                  "청주시서원구", "청주시청원구")
// replace sigungu_nm2 = "부천시"  if inlist(sigungu_nm, "부천시원미구", ///
                                  "부천시소사구", "부천시오정구")
replace sigungu_nm2 = "천안시"  if inlist(sigungu_nm, "천안시서북구", "천안시동남구")
replace sigungu_nm2 = "수원시"  if regexm(sigungu_nm, "^수원시")
replace sigungu_nm2 = "성남시"  if regexm(sigungu_nm, "^성남시")
replace sigungu_nm2 = "안양시"  if regexm(sigungu_nm, "^안양시")
replace sigungu_nm2 = "안산시"  if regexm(sigungu_nm, "^안산시")
replace sigungu_nm2 = "고양시"  if regexm(sigungu_nm, "^고양시")
replace sigungu_nm2 = "용인시"  if regexm(sigungu_nm, "^용인시")
replace sigungu_nm2 = "전주시"  if regexm(sigungu_nm, "^전주시")
replace sigungu_nm2 = "포항시"  if regexm(sigungu_nm, "^포항시")
replace sigungu_nm2 = "화성시"  if inlist(sigungu_nm, "화성시갑", "화성시을")

// 확인
br if sigungu_nm != sigungu_nm2

order year sido_nm sigungu_nm sigungu_nm2 sggName emdName 

collapse (sum) ppltCnt_emd  cfmtnElcnt_emd,  by(year sido_nm sigungu_nm2)

tab year 

// 확인 
br if year == 2008

drop if sigungu_nm=="연기군" & year == 2008 
replace sigungu_nm="세종특별자치시" if sido_nm=="세종특별자치시" & sigungu_nm=="연기군" & year==2012

tab year 

sido_nm	sigungu_nm2

// 2016년 경상남도 고성군, 창원시 
****************************************************************
**** 시군구-선거구 관계 
**** Case1) 시군구=선거구 => crosswalk 필요 없음 
**** Case2) 시군구>선거구 => crosswalk 필요 (해당 데이터로 만들기)
**** Case3) 시군구<선거구 (ex: 농어촌 지역) -> crosswalk 필요 없음 
**** Case4) 복합형 (ex: 해운대구기장군갑, 해운대구기장군을) => crosswalk 필요 (이건 읍면동 데이터로 해야함)
****************************************************************
**** Case1) 
gen case1_sgg = ( sigungu_nm == sggName ) 

**** Case2) 
gen case2_sgg = (sggName == sigungu_nm + "갑") | ///
              (sggName == sigungu_nm + "을") | ///
              (sggName == sigungu_nm + "병") | ///
              (sggName == sigungu_nm + "정") | ///
              (sggName == sigungu_nm + "무")
********* 중간점검 
br if case1_sgg == 0 & case2_sgg == 0 

********* Case3) 
gen case3_sgg = (case1_sgg==0 & case2_sgg==0) & ///
                (regexm(sggName, "시$") | ///
				regexm(sggName, "구$") | ///
                regexm(sggName, "군$"))
				 
br if case3_sgg == 1 // 포항시남구울릉군 

********* 중간점검 
br if case1_sgg == 0 & case2_sgg == 0 & case3_sgg == 0 
sort sido_nm sigungu_nm sggName 

// 강원도: 춘천시철원군화천군양구군갑, 춘천시철원군화천군양구군을 -> 여기서 춘천시만 갑을로 쪼개져있을뿐, 나머지 군(철원군, 화천군, 양구군을 -> case 3에 해당)
// 춘천시는 -> case 2에 해당 
replace case3_sgg = 1 if case1_sgg==0 & case2_sgg==0 & case3_sgg==0 & ///
                         regexm(sigungu_nm, "군$") & ///
                         regexm(sggName, "군$")==0
						 
replace case2_sgg = 1 if (sigungu_nm=="춘천시" & sggName== "춘천시철원군화천군양구군갑" )
replace case2_sgg = 1 if (sigungu_nm=="춘천시" & sggName== "춘천시철원군화천군양구군을" )

// 지역별로 확인 

* 2024년 부천시 (부천시오정구 = 부천시갑, 부천시원미구=부천시을, 부천시소사구=부천시병 -> 사실상 일대일 대응임)
br if case1_sgg == 0 & case2_sgg == 0 & case3_sgg == 0 & regexm(sigungu_nm, "부천시")
replace case1_sgg = 1 if year == 2024 & regexm(sigungu_nm, "부천시")

*  
br if case1_sgg == 0 & case2_sgg == 0 & case3_sgg == 0 

**** 수동으로 케이스 조절
*/
	
