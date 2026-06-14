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
cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending"

forvalues year = 2010/2022 {
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
save "spendingmerge.dta", replace
******************************************************************
****** 재정 데이터 - 클리닝 *************************************
use "spendingmerge.dta", clear 

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

// 1. 2010년도 창원시(통합)데이터 어차피 제공해서, 마산/진해 그냥 drop 
tab year if sigungu_nm=="마산시" 
tab year if sigungu_nm=="진해시" 
drop if sigungu_nm=="창원시" & year==2010 
drop if sigungu_nm=="마산시" & year==2010 
drop if sigungu_nm=="진해시" & year==2010 

replace sigungu_nm="창원시" if sigungu_nm=="창원시(통합)"
br if sigungu_nm=="창원시" 

drop if sigungu_nm=="연기군" 

// 2. 당진 - 중복데이터 삭제 
br if sigungu_nm=="당진시"
drop if sigungu_nm=="당진시" & year==2012 & spend_all==0


// 3. 청원군 + 청주시 
tab sigungu_nm if sido_nm=="충청북도" & year>=2010 & year<=2014 
tab sigungu_nm if sido_nm=="충청북도" & year>=2015
br if sigungu_nm=="청원군" | sigungu_nm=="청주시" // 2014년도 원자료부터 청원군,청주시 모두. 으로 설정되어있음 (데이터값 결측) 

// 청원군 2015년도부터 청주시에 통합, 2010-2014년도 청원군 -> 청주시에 통합해야됨 

tab year if sigungu_nm=="청원군" // 2010-2014년도까지 데이터가 있음 

preserve
keep if inlist(sigungu_nm, "청주시", "청원군")&year>=2010&year<=2014

gen region_merge = "청주시(통합)"

local fiscalvars spend* admin* pubsafe* edu* health* region1* indus* tech* agri* trans* prespend etc envir* art* wel* // 여기에 더 추가 가능

collapse (sum) `fiscalvars', by(year region_merge)

rename region_merge sigungu_nm

tempfile chungju_merged
save `chungju_merged'

restore

drop if inlist(sigungu_nm, "청원군")

append using `chungju_merged'

// 확인 작업 
sort sido_nm sigungu_nm year 

br if sigungu_nm=="청원군" | sigungu_nm=="청주시" | sigungu_nm=="청주시(통합)"
drop if sigungu_nm=="청주시" & year>=2010 & year<=2014

replace sido_nm="충청북도" if sigungu_nm=="청주시(통합)"
replace sigungu_nm="청주시" if sigungu_nm=="청주시(통합)"

tab year sido_nm  // 226(2010-2012), 2014-2022(227) - 세종시때문임 

save "spendingclean.dta", replace 
********************* 통제변수 + 로봇데이터 머지하기 *******************************
use "spendingclean.dta", clear 

// 1. 로봇데이터 머지하기 
merge m:n year sido_nm sigungu_nm using "/Users/ihuila/Desktop/data/master thesis/raw/Robot1.dta"

br if _merge!=3 // 제주도(전년도), 세종(3개년)
drop if _merge!=3 

drop _merge

// 2. 통제변수 머지하기 
merge m:n regioncode year using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftercontrol/sigungucontrol.dta"

order sido_nm sigungu_nm regioncode year 

br if _merge==2 // 통제변수데이터 (2007-2009년도자료)
// 1. 2007-2009 년도 
// 2. 세종시 (2010-2012년)
// 3. 제주 (전년도)
tab year if _merge==2 
drop if _merge==2 & year>=2007&year<=2008 // 2009년도는 lagged control var 때문에 삭제 안함 
drop if _merge==2 & year==2009 & sigungu_nm=="세종특별시" 

drop if sido_nm=="제주특별자치도" 

br if _merge==1 // 없음 

drop _merge

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterdata/spendingrobot.dta",replace 
*******************************************************************************
****** 변수만들기 ******** 
local big welfare envir edu health art admin pubsafe indus trans agri tech region

foreach var of local big {
    
	// 1. 각 소분류 합친 대분류 금액 변수 만들기 
	egen `var' = rowtotal(`var'*)
	
	// 2. 대분류 금액에 로그씌운 변수 만들기 
    gen log`var' = log(`var')
}

gen logall=log(spend_all)

// 3. 각 소분류 재정데이터에 로그씌우기 -> 일단 사회복지예산 소분류들만 만들기 (필요하면 나중에 만들기)
local welcats 081 082 084 085 086 087 088 089

foreach code of local welcats {
    gen logwel`code' = log(welfare`code')
}

br 

summ log*
// 관측치 안맞는것: edu, tech, agri, (region은 2개가 더많음)

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterdata/spendingrobot.dta",replace 

tab year 

/*
tabstat tperwelfare, stat(mean sd N)

// 평균 출력 (한 번에 요약)
summarize tper* // 
// 높은순서대로: 사회복지, 농업, 환경, 지역개발, 일반행정, 문화관광, 수송및교통, 공공질서, 산업, 건강, 교육, 기술 
// N수가 똑같으면서, 높은순서대로: 사회복지, 환경, 지역개발, 일반행정, 문화관광 
*/
