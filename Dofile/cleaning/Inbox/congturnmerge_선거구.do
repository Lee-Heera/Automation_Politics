clear
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과"

import excel "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과/제19대 국회의원선거 개표결과.xlsx", sheet("지역구") firstrow 

drop 후보자별득표수 H I J K L M N O

compress

// 선거인수 = 유효투표 + 무효투표 + 기권
// 선거인수 = 투표수 + 기권
// 투표수 = 유효투표 + 무효투표

rename 후보자별득표수계 유효투표수
rename 시도 sido_nm 

* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

order sido_nm 선거구
// 시군구 단위 데이터로 
keep if  읍면동=="합계" 
gen year = 2012 

drop 투표구 읍면동 
destring 선거인수 투표수 유효투표수 무효투표수 기권수, replace ignore(",")

rename 선거구 sggName 

// obs= 246 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
save "2012congturn_선거구.dta",replace 
*****************************2016년**************************************
clear
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과"

import excel "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과/제20대 국회의원선거 개표결과.xlsx", sheet("지역구") firstrow 

drop 후보자별득표수 H I J K L M N O P

compress

// 선거인수 = 유효투표 + 무효투표 + 기권
// 선거인수 = 투표수 + 기권
// 투표수 = 유효투표 + 무효투표

rename 후보자별득표수계 유효투표수
rename 시도 sido_nm 

* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

order sido_nm 선거구

tab 선거구 if sido_nm=="경상남도" 

// 시군구 단위 데이터로 
keep if  읍면동=="합계" 
gen year = 2016 

drop 투표구 읍면동 
destring 선거인수 투표수 유효투표수 무효투표수 기권수, replace ignore(",")

rename 선거구 sggName

// obs= 252 (원래는 253개여야 함)
// 2016년 경상남도 통영시고성군 무투표당선으로 인해, 개표정보 공개 안함 (선거구단위)

// 통영시고성군 데이터 append 

append using "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn/2016_통영시고성군_선거구.dta"

cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
save "2016congturn_선거구.dta",replace 
**************************** 2020년 ************************************
clear
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과"

import excel "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과/제21대 국회의원선거 개표결과.xlsx", sheet("지역구") firstrow 

drop 후보자별득표수 H I J K L M N O P Q

compress

// 선거인수 = 유효투표 + 무효투표 + 기권
// 선거인수 = 투표수 + 기권
// 투표수 = 유효투표 + 무효투표

rename 후보자별득표수계 유효투표수
rename 시도 sido_nm 

* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

order sido_nm 선거구
// 시군구 단위 데이터로 
keep if  읍면동=="합계" 
gen year = 2020 

drop 투표구 읍면동 
destring 선거인수 투표수 유효투표수 무효투표수 기권수, replace ignore(",")

rename 선거구 sggName 

// obs= 253 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
save "2020congturn_선거구.dta",replace 
**************************** 2024년 ************************************
clear
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과"

import excel "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과/제22대 국회의원선거 개표결과.xlsx", sheet("지역구") firstrow 

drop 후보자별득표수 H I J K L M

compress

// 선거인수 = 유효투표 + 무효투표 + 기권
// 선거인수 = 투표수 + 기권
// 투표수 = 유효투표 + 무효투표

rename 후보자별득표수계 유효투표수
rename 시도 sido_nm 

* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

order sido_nm 선거구
// 시군구 단위 데이터로 
keep if  읍면동=="합계" 
gen year = 2024 

drop 투표구 읍면동 
rename 기권자수 기권수 
destring 선거인수 투표수 유효투표수 무효투표수 기권수, replace ignore(",")

rename 선거구 sggName 

// obs= 254 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
save "2024congturn_선거구.dta",replace 
********************************************************************
********* 19~21대 국회의원 선거(2012~2024) 데이터 append *********** 
clear 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"

use 2012congturn_선거구

append using 2016congturn_선거구
append using 2020congturn_선거구
append using 2024congturn_선거구

save "congturnmerge_선거구.dta", replace 
