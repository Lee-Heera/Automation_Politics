**************** 재정 CSV 데이터 - 필요한 변수만 남기고 저장 ******************
clear
set more off
cd "/Users/ihuila/Desktop/data/master thesis/raw/spending"

// 1단계: CSV -> DTA 변환 + 연도 변수 추가
forvalues year = 2010/2022 {
    capture confirm file "`year'.csv"
    if _rc != 0 {
        di "File `year'.csv not found, skipping..."
        continue
    }

    import delimited "`year'.csv", clear  // CSV 불러오기
    gen year = `year'  // 연도 변수 추가

    // 필요한 변수만 남기기 (v1, v2, v10~v33, v54, year)

    save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending/`year'.dta", replace
}

di "Step 1 완료: 모든 연도별 dta 파일 생성 완료 (필요한 변수만 유지)"


// 2단계: append로 합치기
clear
local first = 1

forvalues year = 2010/2022 {
    capture confirm file "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending/`year'.dta"
	
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
save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending/spendingmerge.dta", replace
******************************************************************
****** 재정 데이터 - 클리닝 *************************************
use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending/spendingmerge.dta", clear 

** trans, unemp, pubsafe, indus, envir, region, admin, agri, sharetax, develop, sani

** 변수명 설정 
ren v2 spend_all 

ren v3 admin011 
ren v4 admin013
ren v5 admin014
ren v6 admin016

ren v7 pubsafe023
ren v8 pubsafe025
ren v9 pubsafe026

ren v10 edu051 
ren v11 edu052
ren v12 edu053

ren v13 art061 
ren v14 art062 
ren v15 art063
ren v16 art064
ren v17 art065

ren v18 envir071 
ren v19 envir072
ren v20 envir073
ren v21 envir074
ren v22 envir075
ren v23 envir076

ren v24 welfare081 
ren v25 welfare082 
ren v26 welfare084 
ren v27 welfare085 
ren v28 welfare086 
ren v29 welfare087 
ren v30 welfare088 
ren v31 welfare089 

ren v32 health091
ren v33 health093

ren v34 agri101 // 농수산 
ren v35 agri102 
ren v36 agri103 

ren v37 indus111
ren v38 indus112
ren v39 indus113 
ren v40 indus114
ren v41 indus115
ren v42 indus116

ren v43 trans121 // 수송, 교통 
ren v44 trans123
ren v45 trans124
ren v46 trans125
ren v47 trans126

ren v48 region141 // 지역개발 
ren v49 region142
ren v50 region143

ren v51 tech151  // 과학기술개발 
ren v52 tech152
ren v53 tech153

ren v54 prespend // 예비비 
ren v55 etc // 기타 

ren v1 시군구명 

drop in 1/2

** 조건에 맞는 행 삭제 
** 1) ~계, 2) ~본청, 3) 자치단체+그다음행 
drop if strpos(시군구명, "본청") > 0  // varname을 실제 변수명으로 수정
drop if strpos(시군구명, "자치단체") > 0  // 자치단체가 포함된 행 표시
drop if strpos(시군구명, "계") > 0 & 시군구명 !="충남계룡시" & 시군구명 != "인천계양구" & 시군구명 != "세종계"
drop if 시군구명==""

** 시도명 정리 
gen sido_nm = ""
replace sido_nm=substr(시군구명, 1, 6)

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
replace sido_nm = "제주특별자치도" if regexm(sido_nm, "제주")

** 시군구명 정리
gen sigungu_nm = substr(시군구명, 7, .)  // 아마 인코딩 이슈로 - 7로 설정해야 글자 안깨지고 잘나옴 
replace sigungu_nm="세종특별자치시" if sido_nm=="세종특별자치시"
order 시군구명 sido_nm sigungu_nm 

drop 시군구명 

** 지역명 변경된 곳은 수동으로 바꿔주기 
replace sigungu_nm="여주시" if sigungu_nm=="여주군"
replace sigungu_nm="미추홀구" if sigungu_nm=="남구" & sido_nm=="인천광역시"
replace sigungu_nm="당진시" if sigungu_nm=="당진군"


** 숫자형태 변수로 변환 
* sigungu_nm과 sido_nm을 제외한 변수 목록 만들기
ds sigungu_nm sido_nm, not

* 해당 변수들 numeric 형으로 변환하기
foreach var of varlist `r(varlist)' {
    * 문자형 변수를 숫자로 변환 (쉼표 등 제거)
    destring `var', replace ignore(",")

    * 숫자를 일반 형식으로 표시하도록 format 지정
    format `var' %12.0g
}

// 2010년도 마산,진해데이터는 어차피 없고 -> 창원시(통합)에 포함되어 있음 
br if sigungu_nm=="창원시"  |  sigungu_nm=="창원시(통합)"
drop if sigungu_nm=="창원시" & year==2010 
drop if sigungu_nm=="마산시" & year==2010 
drop if sigungu_nm=="진해시" & year==2010 

replace sigungu_nm="창원시" if sigungu_nm=="창원시(통합)"
br if sigungu_nm=="창원시" 

drop if sigungu_nm=="연기군" | sigungu_nm=="청원군" // 연기군, 청원군은 어차피 나중에 없어짐 

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending/spendingcleaning.dta", replace 
********************** robot 데이터랑 합치기(merge 1번째) **************************
use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending/spendingcleaning.dta", clear 

merge m:n sido_nm sigungu_nm year using "/Users/ihuila/Desktop/data/master thesis/Robot1.dta"

order sido_nm sigungu_nm year 

br if _merge==2 // 1. 세종특별자치시(2010-2012년도 재정데이터에 없음), 2. 제주도 (재정데이터에 제주도가 없음)
drop if _merge==2 

drop _merge
save "spendingrobot.dta", replace 
*********************** 통제변수 데이터랑 합치기(merge 2번째) ********************
use "/Users/ihuila/Desktop/data/master thesis/pop_variables_clean.dta",clear 
merge m:n sido_nm sigungu_nm year using "spendingrobot.dta"

br if _merge==1 // 통제변수 데이터에만 있는 관측치 
// 1. 2000~2009년도 자료(통제변수 데이터에만 있는) (drop)  2. 제주도 자료 (drop) 3. 세종특별시 2010~2012 (drop)
drop if _merge==1 

drop _merge

save "/Users/ihuila/Desktop/data/master thesis/spendingrobot.dta", replace
*********************통제변수 더추가 ****************** 
use "/Users/ihuila/Desktop/data/master thesis/spendingrobot.dta", clear

merge m:n year sido_nm sigungu_nm using "/Users/ihuila/Desktop/data/master thesis/control/spend_var.dta"

br if _merge==2 
tab year if _merge==2 // 2023년도 데이터 
drop if _merge!=3 

drop _merge 
drop region
*************************************************************
*** 단위 조정: per capita, 1,000 KRW 기준으로 통일할 것 ***

*** 1. 원 단위 변수 처리 (예: 예산규모, 자체수입 등)
*** 단위가 "원" → 인구수로 나누고 1,000으로 나눠야 함 (나눈수에 1000곱하기)
*** 공식: ( 변수 / 인구수) * 1000

* 원 단위 변수들을 수동으로 지정 (필요에 따라 수정하세요)
foreach var in 자치단체예산규모 교부액 세출결산액  {
    gen per`var' = (`var' / 인구수)*1000
    label variable per`var' "`var' per capita (1,000 KRW)"
}

*** 2. 이미 천 원 단위인 지방세액+부문별 세출결산액 변수들을 처리 (per capita = var / 인구수) ***
* 와일드카드를 사용하기 위해 ds 명령을 사용하여 변수 목록 생성
ds admin* pubsafe* edu* art* envir* welfare* health* agri* indus* region* trans* tech* 지방세액
local cheon `r(varlist)'

foreach var in `cheon' {
    gen per`var' = `var' / 인구수
    label variable per`var' "`var' per capita (1,000 KRW)"
}

***********************************************************
**** 1. 부문별 총합 (절대금액)
**** 2. 부문별 총합 (log 절대금액)
**** 3. 각 부문 (log 절대금액)

foreach cat in admin pubsafe edu art envir welfare health agri indus region1 trans tech {

    * 1-1. 해당 대분류의 소분류 절대금액 변수 모두 불러오기
    ds `cat'*
    local subvars `r(varlist)'

    * 1-2. 대분류 총합 변수 생성: t[cat]
    egen t`cat' = rowtotal(`subvars')
    label variable t`cat' "Total `cat' spending (KRW)"

    * 1-3. 대분류 총합 로그 변수 생성: log[cat]
    gen log`cat' = log(t`cat')
    label variable log`cat' "Log of total `cat' spending (KRW)"

    * 1-4. 소분류 개별 로그 변수 생성: log[소분류명]
    foreach var of local subvars {
        gen log`var' = log(`var')
        label variable log`var' "Log of `var' (KRW)"
	  }
}


**** 4. 부문별 총합 (per capita)
**** 5. 부문별 총합 (log - percapita)
**** 6. 각 부문 (log - percapita)
* 1. 대분류 loop
foreach cat in admin pubsafe edu art envir welfare health agri indus region1 trans tech {

    * 1-1. 해당 대분류의 소분류 per capita 변수 모두 불러오기
    ds per`cat'*
    local subvars `r(varlist)'

    * 1-2. 대분류 총합 변수 생성: tper[cat]
    egen tper`cat' = rowtotal(`subvars')
    label variable tper`cat' "Total `cat' spending per capita (1,000 KRW)"

    * 1-3. 대분류 총합 로그 변수 생성: logper[cat]
    gen logper`cat' = log(tper`cat')
    label variable logper`cat' "Log of total `cat' spending per capita (1,000 KRW)"

    * 1-4. 소분류 개별 로그 변수 생성: log_per[소분류명]
    foreach var of local subvars {
        gen log`var' = log(`var')
        label variable log`var' "Log of `var' (per capita, 1,000 KRW)"
    }
}

/*
// 변수 라벨링 
label variable log_welfa "사회복지"
label variable log_envir "환경보호"
label variable log_edu "교육"
label variable log_health "보건"
label variable log_art "문화 및 관광"
label variable log_admin "일반공공행정"
label variable log_pubsafe "공공질서"
label variable log_indus "산업중소기업"
label variable log_trans "수송및교통"
label variable log_agri "농림해양수산"
label variable log_tech "과학기술"
label variable log_region "국토및지역개발"

label variable log_wel081 "기초생활보장"
label variable log_wel082 "취약계층지원"
label variable log_wel084 "보육 가족및여성"
label variable log_wel085 "노인 청소년"
label variable log_wel086 "노동"
label variable log_wel087 "보훈"
label variable log_wel088 "주택"
label variable log_wel089 "사회복지일반"
*/

tabstat tperwelfare, stat(mean sd N)

// 평균 출력 (한 번에 요약)
summarize tper* // 
// 높은순서대로: 사회복지, 농업, 환경, 지역개발, 일반행정, 문화관광, 수송및교통, 공공질서, 산업, 건강, 교육, 기술 
// N수가 똑같으면서, 높은순서대로: 사회복지, 환경, 지역개발, 일반행정, 문화관광 

save "/Users/ihuila/Desktop/data/master thesis/spendingrobot2.dta", replace 
