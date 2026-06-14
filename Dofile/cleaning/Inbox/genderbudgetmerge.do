**************** 재정 CSV 데이터 - 필요한 변수만 남기고 저장 ******************
clear
set more off
cd "/Users/ihuila/Desktop/data/master thesis/raw/genderbudget"

// 1단계: CSV -> DTA 변환 + 연도 변수 추가
forvalues year = 2015/2022 {
    capture confirm file "genderbudget`year'.csv"
    if _rc != 0 {
        di "File `year'.csv not found, skipping..."
        continue
    }

    import delimited "genderbudget`year'.csv", clear  // CSV 불러오기
    gen year = `year'  // 연도 변수 추가

    // 필요한 변수만 남기기 (v1, v2, v10~v33, v54, year)

    save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftergender/genderbudget/`year'.dta", replace
}

di "Step 1 완료: 모든 연도별 dta 파일 생성 완료 (필요한 변수만 유지)"


// 2단계: append로 합치기
clear
local first = 1
cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftergender/genderbudget"

forvalues year = 2015/2022 {
    capture confirm file "`year'.dta"
    if _rc != 0 {
        di "File `year'.dta not found, skipping..."
        continue
    }

    if `first' {
        use "`year'.dta", clear
        local first = 0
    }
    else {
        append using "`year'.dta"
    }
}

// 최종 결과 저장
save "genderbudgetmerge.dta", replace
******************************************************************
****** 재정 데이터 - 클리닝 *************************************
use "genderbudgetmerge.dta", clear 

drop in 1/2

** 조건에 맞는 행 삭제 
drop if 회계연도==.
tab 회계연도
tab 자치단체명
drop if strpos(자치단체명, "본청") > 0  & 자치단체명!="세종본청"
// varname을 실제 변수명으로 수정

****변수명 정리 
ren 지역명 sido_nm 
ren 자치단체명 시군구명
ren v8 genratio 
ren v7 taxrev

** 시도명 정리 
replace sido_nm = "서울특별시" if regexm(sido_nm, "서울")
replace sido_nm = "부산광역시" if regexm(sido_nm, "부산")
replace sido_nm = "대구광역시" if regexm(sido_nm, "대구")
replace sido_nm = "인천광역시" if regexm(sido_nm, "인천")
replace sido_nm = "광주광역시" if regexm(sido_nm, "광주")
replace sido_nm = "대전광역시" if regexm(sido_nm, "대전")
replace sido_nm = "울산광역시" if regexm(sido_nm, "울산")
replace sido_nm = "세종특별자치시" if regexm(sido_nm, "세종")
replace sido_nm = "경기도" if regexm(sido_nm, "경기")
replace sido_nm = "강원도" if regexm(sido_nm, "강원")
replace sido_nm = "충청북도" if regexm(sido_nm, "충북")
replace sido_nm = "충청남도" if regexm(sido_nm, "충남")
replace sido_nm = "전라북도" if regexm(sido_nm, "전북")
replace sido_nm = "전라남도" if regexm(sido_nm, "전남")
replace sido_nm = "경상북도" if regexm(sido_nm, "경북")
replace sido_nm = "경상남도" if regexm(sido_nm, "경남")

** 시군구명 정리
gen sigungu_nm = substr(시군구명, 7, .)  // 아마 인코딩 이슈로 - 7로 설정해야 글자 안깨지고 잘나옴 
replace sigungu_nm="세종특별자치시" if sido_nm=="세종특별자치시"
order 시군구명 sido_nm sigungu_nm 

tab sigungu_nm 

drop 시군구명 

** 지역명 변경된 곳은 수동으로 바꿔주기 
replace sigungu_nm="여주시" if sigungu_nm=="여주군"
replace sigungu_nm="미추홀구" if sigungu_nm=="남구" & sido_nm=="인천광역시"
replace sigungu_nm="당진시" if sigungu_nm=="당진군"

drop no
drop 회계연도

count if sigungu_nm == "청원군"

save "genderbudgetmerge.dta", replace 
********************* 통제변수 + 로봇데이터 머지하기 *******************************
use "genderbudgetmerge.dta", clear 

// 1. 로봇데이터 머지하기 
merge m:n year sido_nm sigungu_nm using "/Users/ihuila/Desktop/data/master thesis/raw/Robot1.dta"

tab year if _merge!=3 
// 1. 2010~2014년도 자료 (로봇에만 있음)
// 2. 2015-2022년도 - 제주시 서귀포시 자료 
br if _merge!=3 & year==2015 

drop if _merge!=3
drop _merge

// 2. 통제변수 머지하기 
merge m:n regioncode year using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftercontrol/sigungucontrol.dta"

order sido_nm sigungu_nm regioncode year 

br if _merge==2 // 통제변수데이터 (2007-2009년도자료)
// 1. 2007-2014년도 
// 2. 제주 (전년도)
tab year if _merge==2 
drop if _merge==2 & year>=2007&year<=2013 // 2014년도는 lagged control var 때문에 삭제 안함 
drop if sido_nm=="제주특별자치도" 

br if _merge==2 & year!=2014 

br if sigungu_nm=="미추홀구" // 2017년도는 성인지예산 원자료에서부터 미추홀구 없음 

br if _merge!=3

drop _merge

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftergender/genderbudgetrobot.dta",replace 
*******************************************************************************

hist 성인지예산액 if sido_nm=="서울특별시" 
