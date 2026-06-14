************************ 2008년 당선인 데이터 불러오기 -> dta 파일로 저장 
clear 

local in  "/Users/ihuila/Desktop/data/master thesis/raw/Congwin/2008"
local out  "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2008"

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    
    local fname "당선인통계[제18대][국회의원선거][국회의원선거][`region'].xlsx"
    
    import excel "`in'/`fname'", firstrow clear
    
    gen sido_nm = "`region'"
     drop in 1/3
	 
    save "`out'/`region'.dta", replace
    
    di "완료: `region'"
}
*****************************
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2008"

use "강원도.dta", clear 

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    if "`region'" != "강원도" {
        append using "`region'.dta", force
    }
}

save 2008congwinmerge.dta, replace 
*************************** cleaning ***************************************
use 2008congwinmerge.dta, clear 

rename 중앙선거관리위원회선거통계시스템 sigungu_nm  
gen year = 2008 
order sido_nm sigungu_nm year 

********************클리닝 
* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

drop if sigungu_nm == "합계"
drop B J 
compress 
** 정당멸 모두 같은 칼럼에 있는지 확인 (0, 1, 정당 1개 이런구조여야 함)
tab C 
tab D 
tab E 
tab F 
tab G 
tab H 
tab I 

ren C 통합민주당
ren D 한나라당
ren E 자유선진당
ren F 민주노동당
ren G 창조한국당
ren H 친박연대
ren I 무소속

*** 
drop if sigungu_nm == "선거구명"
drop if sigungu_nm == ""

 // 2008년 선거구 245개, 관측치 245개 
*** 
destring 통합민주당 한나라당 자유선진당 민주노동당 창조한국당 친박연대 무소속, replace 

save 2008congwinmerge_선거구.dta, replace 
************************************************************************************
************************ 2012년 당선인 데이터 불러오기 -> dta 파일로 저장 
clear 

local in  "/Users/ihuila/Desktop/data/master thesis/raw/Congwin/2012"
local out  "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2012"

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    
    local fname "당선인통계[제19대][국회의원선거][국회의원선거][`region'].xlsx"
    
    import excel "`in'/`fname'", firstrow clear
    
    gen sido_nm = "`region'"
    
	drop in 1/3
	 
    save "`out'/`region'.dta", replace
    
    di "완료: `region'"
}
*****************************
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2012"

use "강원도.dta", clear 

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    if "`region'" != "강원도" {
        append using "`region'.dta", force
    }
}

save 2012congwinmerge.dta, replace 
*************************** cleaning ***************************************
use 2012congwinmerge.dta, clear 

rename 중앙선거관리위원회선거통계시스템 sigungu_nm  
gen year = 2012 
order sido_nm sigungu_nm year 

********************클리닝 
* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

drop if sigungu_nm == "합계"
drop B H
 
compress 
** 정당멸 모두 같은 칼럼에 있는지 확인 (0, 1, 정당 1개 이런구조여야 함)
tab C // 새누리당 
tab D // 민주통합당
tab E // 자유선진당
tab F  // 통합진보당 
tab G // 무소속 

ren C 새누리당 
ren D 민주통합당
ren E 자유선진당
ren F 통합진보당
ren G 무소속

*** 
drop if sigungu_nm == "선거구명"
drop if sigungu_nm == ""

*** 
destring 새누리당 민주통합당 자유선진당 통합진보당 무소속, replace 

// 원래는 지역구 246개 
// 현 데이터 지역구 246개 
save 2012congwinmerge_선거구.dta, replace 
************************************************************************************
************************ 2016년 당선인 데이터 불러오기 -> dta 파일로 저장 
clear 

local in  "/Users/ihuila/Desktop/data/master thesis/raw/Congwin/2016"
local out  "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2016"

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    
    local fname "당선인통계[제20대][국회의원선거][국회의원선거][`region'].xlsx"
    
    import excel "`in'/`fname'", firstrow clear
    
    gen sido_nm = "`region'"
    
	drop in 1/3
	 
    save "`out'/`region'.dta", replace
    
    di "완료: `region'"
}
*****************************
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2016"

use "강원도.dta", clear 

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    if "`region'" != "강원도" {
        append using "`region'.dta", force
    }
}

save 2016congwinmerge.dta, replace 
*************************** cleaning ***************************************
use 2016congwinmerge.dta, clear 

rename 중앙선거관리위원회선거통계시스템 sigungu_nm  
gen year = 2016 
order sido_nm sigungu_nm year 

********************클리닝 
* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

drop if sigungu_nm == "합계"
drop B H
 
compress 
** 정당멸 모두 같은 칼럼에 있는지 확인 (0, 1, 정당 1개 이런구조여야 함)
tab C // 새누리당 
tab D // 더불어민주당
tab E // 국민의당
tab F  // 정의당
tab G // 무소속 

ren C 새누리당 
ren D 더불어민주당
ren E 국민의당
ren F 정의당
ren G 무소속

*** 
drop if sigungu_nm == "선거구명"
drop if sigungu_nm == ""

*** 
destring 새누리당 더불어민주당 국민의당 정의당 무소속, replace 

// 원래는 지역구 253개 현 데이터 253개 

save 2016congwinmerge_선거구.dta, replace 
************************************************************************************
************************ 2020년 당선인 데이터 불러오기 -> dta 파일로 저장 
clear 

local in  "/Users/ihuila/Desktop/data/master thesis/raw/Congwin/2020"
local out  "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2020"

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    
    local fname "당선인통계[제21대][국회의원선거][국회의원선거][`region'].xlsx"
    
    import excel "`in'/`fname'", firstrow clear
    
    gen sido_nm = "`region'"
    
	drop in 1/3
	 
    save "`out'/`region'.dta", replace
    
    di "완료: `region'"
}
*****************************
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2020"

use "강원도.dta", clear 

local files `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전라북도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    if "`region'" != "강원도" {
        append using "`region'.dta", force
    }
}

save 2020congwinmerge.dta, replace 
*************************** cleaning ***************************************
use 2020congwinmerge.dta, clear 

rename 중앙선거관리위원회선거통계시스템 sigungu_nm  
gen year = 2020
order sido_nm sigungu_nm year 

********************클리닝 
* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

drop if sigungu_nm == "합계"
drop B G
 
compress 
** 정당멸 모두 같은 칼럼에 있는지 확인 (0, 1, 정당 1개 이런구조여야 함)
tab C // 더불어민주당
tab D // 미래통합당
tab E // 정의당
tab F  // 무소속 

ren C 더불어민주당
ren D 미래통합당
ren E 정의당
ren F 무소속 

*** 
drop if sigungu_nm == "선거구명"
drop if sigungu_nm == ""

*** 
destring 더불어민주당 미래통합당 정의당 무소속, replace 

// 원래는 지역구 253개 
// 현 데이터 253개 

save 2020congwinmerge_선거구.dta, replace 
************************************************************************************
************************ 2024년 당선인 데이터 불러오기 -> dta 파일로 저장 
clear 

local in  "/Users/ihuila/Desktop/data/master thesis/raw/Congwin/2024"
local out  "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2024"

local files `" "강원특별자치도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전북특별자치도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    
    local fname "당선인통계[제22대][국회의원선거][국회의원선거][`region'].xlsx"
    
    import excel "`in'/`fname'", firstrow clear
    
    gen sido_nm = "`region'"
    
	drop in 1/3
	 
    save "`out'/`region'.dta", replace
    
    di "완료: `region'"
}
*****************************
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/2024"

use "강원특별자치도.dta", clear 

local files `" "강원특별자치도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전북특별자치도" "세종특별자치시" "제주특별자치도" "충청남도" "충청북도" "'

foreach region of local files {
    if "`region'" != "강원특별자치도" {
        append using "`region'.dta", force
    }
}

save 2024congwinmerge.dta, replace 
*************************** cleaning ***************************************
use 2024congwinmerge.dta, clear 

rename 중앙선거관리위원회선거통계시스템 sigungu_nm  
gen year = 2024
order sido_nm sigungu_nm year 

********************클리닝 
* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

drop if sigungu_nm == "합계"
drop B H
compress 
** 정당멸 모두 같은 칼럼에 있는지 확인 (0, 1, 정당 1개 이런구조여야 함)
tab C // 더불어민주당
tab D // 국민의힘
tab E // 새로운미래
tab F  // 개혁신당
tab G // 진보당

ren C 더불어민주당
ren D 국민의힘
ren E 새로운미래
ren F 개혁신당 
ren G 진보당

*** 
drop if sigungu_nm == "선거구명"
drop if sigungu_nm == ""

*** 
destring 더불어민주당 국민의힘 새로운미래 개혁신당 진보당, replace 

// 원래는 지역구 254개 
// 현 데이터 254개  

save 2024congwinmerge_선거구.dta, replace
******************************* 선거구 단위 **********************************************
clear 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin"

use 2008/2008congwinmerge_선거구.dta

append using 2012/2012congwinmerge_선거구.dta, force 
append using 2016/2016congwinmerge_선거구.dta, force 
append using 2020/2020congwinmerge_선거구.dta, force 
append using 2024/2024congwinmerge_선거구.dta, force

rename sigungu_nm sggName 

br if year==2016 & sido_nm=="경상남도" 

save congwinmerge_선거구.dta, replace 

keep sido_nm sggName year 

// 선거구 개수 
// 2008 - 245 
// 2012 - 246 (이때부터 세종특별자치시 포함)
// 2016 - 253 
// 2020 - 253 
// 2024 - 254 

br if year==2016 & sido_nm=="경상남도" 

save pivot_sggName.dta, replace  // 기준이 되는 선거구 데이터 
