********************************************************************************
* 센서스 공간정보 지역 코드 - 여러 연도 통합
********************************************************************************

clear
cd "/Users/ihuila/Desktop/data/master thesis/after"

* 연도별 시트명 정의
local sheets `" "2012년" "2016년" "2020년6월" "2024년 6월" "'
local years "2012 2016 2020 2024"

* 파일 개수
local n_years : word count `years'

* 임시 파일
tempfile temp_data

* 첫 번째 연도 처리
local sheet1 : word 1 of `sheets'
local year1 : word 1 of `years'

import excel "/Users/ihuila/Desktop/data/master thesis/raw/센서스 공간정보 지역 코드.xlsx", ///
    sheet("`sheet1'") clear
ren (A B C D E F) (sidocode sido_nm regioncode sigungu_nm emdcode emd_nm)
drop in 1/2
gen year = `year1'

save `temp_data', replace

* 나머지 연도 처리 및 append
forval i = 2/`n_years' {
    local sheet`i' : word `i' of `sheets'
    local year`i' : word `i' of `years'
    
    import excel "/Users/ihuila/Desktop/data/master thesis/raw/센서스 공간정보 지역 코드.xlsx", ///
        sheet("`sheet`i''") clear
    ren (A B C D E F) (sidocode sido_nm regioncode sigungu_nm emdcode emd_nm)
    drop in 1/2
    gen year = `year`i''
    
    append using `temp_data'
    save `temp_data', replace
}

* 최종 데이터
use `temp_data', clear

* 연도별 관측치 확인
tab year

* 저장
cd "/Users/ihuila/Desktop/data/master thesis/after"
save 2012_2024시군구읍면동.dta, replace

/*
* 연도별 파일도 저장 (필요시)
foreach yr in 2012 2016 2020 2024 {
    preserve
    keep if year == `yr'
    save `yr'시군구읍면동.dta, replace
    restore
}
*/
***************************************************************
cd "/Users/ihuila/Desktop/data/master thesis/after"
use 2012_2024시군구읍면동.dta, clear 

******** 세종특별자치시 이름 변경 
replace sigungu_nm = "세종특별자치시" if sigungu_nm=="세종시" 

******** 읍면동 이름패턴 통일 
* 1) 숫자+기호+숫자+동 → 숫자·숫자+동 (가운뎃점으로 통일)
gen emd_nm_new = emd_nm

* 숫자,숫자동 → 숫자·숫자동
replace emd_nm_new = ustrregexra(emd_nm_new, "([0-9]+),([0-9]+동)", "$1·$2")

* * 2) "제"+숫자+"동"으로 끝나는 경우에만 "제" 삭제
* 단, 거제/홍제 포함 OR 숫자+"가"+"제"+숫자+"동" 패턴은 제외
replace emd_nm_new = subinstr(emd_nm, "제", "", 1) ///
    if regexm(emd_nm, "제[0-9]+동$") ///
    & !regexm(emd_nm, "[0-9]+가제[0-9]+동") ///
	& !regexm(emd_nm, "홍제|거제")

drop emd_nm 
ren emd_nm_new emd_nm 

save 2012_2024시군구읍면동_clean.dta, replace
