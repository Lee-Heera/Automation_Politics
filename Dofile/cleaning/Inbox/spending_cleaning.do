clear 
set more off 
use "/Users/ihuila/Desktop/data/master thesis/sigungu_spending.dta"

tab region
tab year // 2008, 2014-2020 (재정데이터)

// 지역명 정리 (시/도 - 총 16개)
// 1. 서울 -> 서울특별시, 
// 2. 대구, 울산, 광주, 부산, 인천, 대전
// 3. 경기, 강원 
// 4. 충남, 충북, 경남, 경북, 전북, 전남 -> 충청남도, 충청북도,  경상남도, 경상북도, 전라북도, 전라남도 
// 5. 세종 -> 세종특별자치시 

replace region="서울특별시" if region == "서울"

replace region=region+"광역시" if region=="대구" | region=="광주"|region=="부산"|region=="인천"|region=="대전"|region=="울산"

replace region=region+"도" if region=="경기" | region=="강원" 

replace region = "충청북도" if region=="충북" 
replace region = "충청남도" if region=="충남" 
replace region = "경상북도" if region=="경북" 
replace region = "경상남도" if region=="경남" 
replace region = "전라북도" if region=="전북" 
replace region = "전라남도" if region=="전남" 

replace region=region+"특별자치시" if region=="세종" 

/// 1. 서울특별시 
tab jurisdiction if region=="서울특별시" 
replace jurisdiction="중구" if jurisdiction=="서울중구"
replace jurisdiction="강서구" if jurisdiction=="서울강서구"

/// 2. 대구광역시 
tab jurisdiction if region=="대구광역시" 
replace jurisdiction = subinstr(jurisdiction, "대구", "", .) if regexm(jurisdiction, "^대구")
replace jurisdiction="달성군" if jurisdiction=="달성" 

/// 3. 울산광역시 
tab jurisdiction if region=="울산광역시"
replace jurisdiction = subinstr(jurisdiction, "울산", "", .) if regexm(jurisdiction, "^울산")
replace jurisdiction="울주군" if jurisdiction=="울주"

tab jurisdiction if region=="울산광역시"

/// 4. 광주광역시 
tab jurisdiction if region=="광주광역시"
replace jurisdiction = subinstr(jurisdiction, "광주", "", .) if regexm(jurisdiction, "^광주")&region=="광주광역시"

tab jurisdiction if region=="광주광역시"

/// 5. 부산광역시 
tab jurisdiction if region=="부산광역시"
replace jurisdiction = subinstr(jurisdiction, "부산", "", .) if regexm(jurisdiction, "^부산")
replace jurisdiction="기장군" if jurisdiction=="기장"
replace jurisdiction="부산진구" if region=="부산광역시" & jurisdiction=="진구" 
tab jurisdiction if region=="부산광역시"

/// 6. 인천광역시 
tab jurisdiction if region=="인천광역시"
replace jurisdiction = subinstr(jurisdiction, "인천", "", .) if regexm(jurisdiction, "^인천")
replace jurisdiction="강화군" if jurisdiction=="강화"
replace jurisdiction="옹진군" if jurisdiction=="옹진"

replace jurisdiction = "미추홀구" if region=="인천광역시"&jurisdiction=="남구"

tab jurisdiction if region=="인천광역시"

/// 7. 대전광역시 
tab jurisdiction if region=="대전광역시"
replace jurisdiction = subinstr(jurisdiction, "대전", "", .) if regexm(jurisdiction, "^대전")

tab jurisdiction if region=="대전광역시" 
///////////////////////////////////////////////////
/// 8. 경기 
tab jurisdiction if region=="경기도" 

replace jurisdiction = jurisdiction+"시" if region=="경기도" 

replace jurisdiction = "연천군" if region=="경기도"&jurisdiction=="연천시"
replace jurisdiction = "가평군" if region=="경기도"&jurisdiction=="가평시"
replace jurisdiction = "양평군" if region=="경기도"&jurisdiction=="양평시"

tab jurisdiction if region=="경기도" 

// 연천, 가평, 양평만 "군"
/////////////////////////////////////////////////////
/// 9. 강원도
tab jurisdiction if region=="강원도" 

//강릉시, 고성군, 동해시, 삼척시, 속초시, 양구군, 양양군, 영월군, 원주시, 인제군, 정선군, 철원군, 춘천시, 태백시, 평창군, 홍천군, 화천군, 횡성군 
replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction, "강릉", "동해", "삼척", "속초", "춘천", "태백", "원주")

replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "고성", "양구", "영월", "인제", "정선")
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "철원", "평창", "홍천", "화천", "횡성", "양양") // 양양군(로봇데이터에 맞추기)
replace jurisdiction = "고성군" if jurisdiction=="강원고성" 

tab jurisdiction if region=="강원도" 

///////////////////////////////////////////////////////
/// 10. 경상북도 
tab jurisdiction if region=="경상북도" 

//포항시, 경주시, 김천시, 안동시, 구미시, 영주시, 영천시, 상주시, 문경시, 경산시, 의성군, 청송군, 영양군, 영덕군, 청도군, 고령군, 성주군, 칠곡군, 예천군, 봉화군, 울진군, 울릉군, 군위?? 
replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction, "포항", "경주", "김천", "안동", "구미")
replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction,"영주", "영천", "상주", "문경", "경산")

replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "의성", "청송", "영양", "영덕", "청도", "고령") 
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "성주", "칠곡", "예천", "봉화", "울진", "울릉", "군위")

tab jurisdiction if region=="경상북도" 

/////////////////////////////////////////////////////
/// 11. 경상남도 
tab jurisdiction if region=="경상남도" 

// 창원시, 진주시, 통영시, 사천시, 김해시, 밀양시, 거제시, 양산시, 의령군, 함안군, 창녕군, 고성군, 남해군, 하동군, 산청군, 함양군, 거창군, 합천군 

replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction, "창원", "진주", "통영", "사천", "김해", "밀양", "거제", "양산")
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "의령", "함안", "창녕", "고성", "남해", "하동", "산청", "함양") 
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "거창", "합천")
replace jurisdiction = "창원시" if jurisdiction == "통합창원"
replace jurisdiction = "고성군" if jurisdiction == "경남고성"

tab jurisdiction if region=="경상남도" 

///////////////////////////////////////////////////////////
/// 12. 충청북도 
tab jurisdiction if region=="충청북도" 

//청주시, 충주시, 제천시, 보은군, 옥천군, 영동군, 증평군, 진천군, 괴산군, 음성군, 단양군
replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction, "청주", "충주", "제천")
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "보은", "옥천", "영동", "증평", "진천", "괴산", "음성", "단양")

tab jurisdiction if region=="충청북도" 

///////////////////////////////////////////////////////////////
/// 13. 충청남도
tab jurisdiction if region=="충청남도" 
// 천안시, 공주시, 보령시, 아산시, 서산시, 논산시, 계룡시, 당진시, 금산군, 부여군, 서천군, 청양군, 홍성군, 예산군, 태안군, 연기군 

replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction, "천안", "공주", "보령", "아산", "서산", "논산", "계룡", "당진")
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "금산", "부여", "서천", "청양", "홍성", "예산", "태안", "연기")

tab jurisdiction if region=="충청남도" 
////////////////////////////////////////////////////////////////
/// 14. 전라북도 
tab jurisdiction if region=="전라북도" 

// 전주시, 익산시, 군산시, 정읍시, 남원시, 김제시, 완주군, 진안군, 무주군, 장수군, 임실군, 순창군, 고창군, 부안군
replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction, "전주", "익산", "군산", "정읍", "남원", "김제")
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "완주", "진안", "무주", "장수", "임실", "순창", "고창", "부안")

tab jurisdiction if region=="전라북도" 

/////////////////////////////////////////////////////////////////
/// 15. 전라남도
tab jurisdiction if region=="전라남도" 

// 목포시, 여수시, 순천시, 나주시, 광양시, 담양군, 곡성군, 구례군, 고흥군, 보성군, 화순군, 강진군, 해남군, 영암군, 무안군, 함평군, 영광군, 장성군, 완도군, 진도군, 신안군 
replace jurisdiction = jurisdiction + "시" if inlist(jurisdiction, "목포", "여수", "순천", "나주", "광양")
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "담양", "곡성", "구례", "고흥", "보성", "화순", "강진", "해남")
replace jurisdiction = jurisdiction + "군" if inlist(jurisdiction, "영암", "무안", "함평", "영광", "장성", "완도", "진도", "신안", "장흥")

tab jurisdiction if region=="전라남도" 
///////////////////////////////////////////////////////////////////
/// 16. 세종특별자치시 
tab jurisdiction if region=="세종특별자치시"

replace jurisdiction="세종특별자치시" if jurisdiction=="세종"
/////////////////////////////////////////////////////////////////////

ren region sido_nm 
ren jurisdiction sigungu_nm 

save "/Users/ihuila/Desktop/data/master thesis/sigungu_spending_new.dta", replace
***********************************************************************************************************************
// 1차merge: 시군구코드 + 재정데이터 머지 
use "/Users/ihuila/Desktop/data/master thesis/sigungu_spending_new.dta", clear 

merge m:n sido_nm sigungu_nm year using "/Users/ihuila/Desktop/data/master thesis/sigungu_code.dta"

br if _merge==2 // 
tab year if _merge==2 // 2010-2013, 2021-2022년도 데이터 (로봇데이터에만 있는 연도) + 2014~2020년도의 2개씩 있는 관측치는 제주도 
br if _merge==2 & year>=2014 & year<=2020 

br if _merge==1 // 
tab year if _merge==1 // 2008년도 데이터 (재정데이터에만 있는 연도)

keep if _merge==3 

drop sigungu_id _merge // 재정데이터에 있는 sigungu_id 버리고, 로봇데이터에 있는 regioncode, countyid 사용해야 함 

save "/Users/ihuila/Desktop/data/master thesis/spending_new.dta", replace // 여기서 관측치는 1589개 (이건 spending + robot으로 버전)
************************************************************************************************
// 2차merge: spending_new + robot 데이터 머지 
use "/Users/ihuila/Desktop/data/master thesis/spending_new.dta", clear 
merge m:1 regioncode year using "/Users/ihuila/Desktop/data/master thesis/Robot1.dta"

// 로봇데이터는 2010~2022년도까지 
// 재정데이터는 2008, 2014-2020년도까지. 

br if _merge==1 // 없음 

br if _merge==2 // 2010-2013년도, 2021-2022년도 데이터(로봇데이터에만 있는) + 2014~2020년도까지는 2개씩 뭐가 있음(제주도 관측치) 
tab year if _merge==2 
br if _merge==2&year==2014 

// _merge==1, _merge==2 인 경우 모두 분석을 위해 삭제해도 됨 

keep if _merge==3 

drop _merge 

save "/Users/ihuila/Desktop/data/master thesis/spendingrobot.dta", replace // 분석을 위해 필요한 것, 여기서 관측치 1589개 
*********************************************************************************************
**************************** 여기부터 분석 (spending + robot) ******************
use "/Users/ihuila/Desktop/data/master thesis/spendingrobot.dta", clear 

xtset regioncode year 
gen log_pub = log(pubsafe)
gen log_welfa = log(welfare)
gen log_envi = log(envir)

xi: xtivreg2 log_pub (DRobot_exp_all1997=Z_DRobot_exp_all1997) i.year , fe robust  first
xi: xtivreg2 log_welfa (DRobot_exp_all1997=Z_DRobot_exp_all1997) i.year , fe robust  first
xi: xtivreg2 log_envi (DRobot_exp_all1997=Z_DRobot_exp_all1997) i.year , fe robust  first


