*************************************************************************
* 21대 국회의원선거 개표결과 2차 클린
* 2020congress_clean.dta → 시군구2 정규화 및 시군구 단위 집계
*************************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global data "${main}/Data cleaned"
	global interim "${main}/Data interim"
	global final "${main}/Data final"

************************************************************************
use "$data/2012congress_clean2.dta" 

append using "$data/2016congress_clean2.dta" 
append using "$data/2020congress_clean2.dta" 

replace sigungu_nm="미추홀구" if sido_nm=="인천광역시" & sigungu_nm=="남구" 
replace sigungu_nm="여주시" if sigungu_nm=="여주군" 

****************************** 지역코드 매치*************************	
merge m:1 sido_nm sigungu_nm year using "$data/sigungu_code.dta"

tab year if _merge==2 // 총선없는 연도 
keep if _merge==3 
drop _merge

tab year 

save "$interim/총선_개표/congress_append.dta", replace 
************************************************************************
* 각 시군구별로 양당 후보 모두존재 (선거구 -> 시군구로 변환하는 과정에서)
gen uncontested = 0

replace uncontested = 1 if year==2012 & (missing(새누리당) + missing(민주통합당)) == 1
replace uncontested = 1 if year==2016 & (missing(새누리당) + missing(더불어민주당)) == 1
replace uncontested = 1 if year==2020 & (missing(미래통합당) + missing(더불어민주당)) == 1

* 한 번이라도 해당된 지역 목록
bysort regioncode: egen ever_uncontested = max(uncontested)
list sido_nm sigungu_nm year if uncontested == 1, sepby(regioncode)

* 지역별 요약 (몇 번 선거에서 해당됐는지)
bysort regioncode: egen n_uncontested = total(uncontested)
tab n_uncontested  // 중복 없이 지역 단위로 보려면 한 연도로 필터
************************************************************************
* 정당매핑 (2012-2020)
************************************************************************
// 정당구분 시 주의: 2016년 국민의힘은 현재의 국민의힘 정당이 아님 

// 19대: 새누리당 민주통합당 국민의힘 국민행복당 불교연합당 진보신당 무소속류승구 무소속서맹종
// 20대: 새누리당 더불어민주당 국민의당 정의당 노동당 녹색당 진리대한당 한나라당 무소속김대한 무소속이원옥
// 21대: 더불어민주당 미래통합당 우리공화당 민중당 가자평화인권당 공화당 국민혁명배당금당 국민새정당 민중민주당 한나라당 무소속김용덕
************************************************************************


