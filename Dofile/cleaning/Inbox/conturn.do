********************************************************************************
* 읍면동별 개표결과 - 여러 연도 통합
********************************************************************************
clear
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과"

* 연도별 파일명과 드롭할 컬럼 정의
local files `" "제19대 국회의원선거 개표결과.xlsx" "제20대 국회의원선거 개표결과.xlsx" "제21대 국회의원선거 개표결과.xlsx" "제22대 국회의원선거 개표결과.xlsx" "'
local years "2012 2016 2020 2024"
local drops `" "H I J K L M N O" "H I J K L M N O P" "H I J K L M N O P Q" "H I J K L M" "'

* 파일 개수 확인
local n_files : word count `files'

* 임시 데이터 저장용
tempfile temp_data

* 첫 번째 파일 처리
local file1 : word 1 of `files'
local year1 : word 1 of `years'
local drop1 `" `: word 1 of `drops'' "'

import excel "`file1'", sheet("지역구") firstrow clear
drop 후보자별득표수 `drop1'
compress

rename 후보자별득표수계 유효투표수
rename 시도 sido_nm 

* 문자열 변수 공백 제거
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

order sido_nm 선거구
rename 선거구 sggName 
rename 읍면동 emd_nm 
destring 선거인수 투표수 유효투표수 무효투표수 기권수, replace ignore(",")

keep if 투표구 == "소계"
gen year = `year1'
drop 투표구

save `temp_data', replace

* 나머지 파일 처리 및 append
forval i = 2/`n_files' {
    local file`i' : word `i' of `files'
    local year`i' : word `i' of `years'
    local drop`i' : word `i' of `drops'
    
    import excel "`file`i''", sheet("지역구") firstrow clear
    drop 후보자별득표수 `drop`i''
    compress
    
    rename 후보자별득표수계 유효투표수
    rename 시도 sido_nm 
    
    * 문자열 변수 공백 제거
    ds, has(type string)
    foreach var of varlist `r(varlist)' {
        replace `var' = ustrtrim(`var') if !missing(`var')
    }
    
    order sido_nm 선거구
    rename 선거구 sggName 
    rename 읍면동 emd_nm 
    
    * ★ 2024년만 기권자수 → 기권수로 변경
    if `year`i'' == 2024 {
        capture rename 기권자수 기권수
    }
    
    destring 선거인수 투표수 유효투표수 무효투표수 기권수, replace ignore(",")
    
    keep if 투표구 == "소계"
    gen year = `year`i''
    drop 투표구
    
    append using `temp_data'
    save `temp_data', replace
}

* 최종 데이터
use `temp_data', clear

* 연도 확인
tab year

cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
save "congturnmerge_읍면동.dta", replace
**************************************************여기부터 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
use "congturnmerge_읍면동.dta", clear 

tab year 

/*
gen emd_nm_new = emd_nm

* 1) "제"+숫자+"동"으로 끝나는 경우 "제" 삭제
replace emd_nm_new = ustrregexra(emd_nm_new, "제([0-9]+동)$", "$1") ///
    if regexm(emd_nm, "제[0-9]+동$") ///
    & !regexm(emd_nm, "[0-9]+가제[0-9]+동")

* 2) "제"+숫자+"·"+숫자+"동" 패턴에서 "제" 삭제 (예: 면목제3·8동 → 면목3·8동)
replace emd_nm_new = ustrregexra(emd_nm_new, "제([0-9]+·[0-9]+동)", "$1") ///
    if regexm(emd_nm, "제[0-9]+·[0-9]+동") 

* 3) "제"+숫자+"·"+한글+"동" 패턴에서 "제" 삭제 (예: 봉명제2·송정동 → 봉명2·송정동)
replace emd_nm_new = ustrregexra(emd_nm_new, "제([0-9]+·[가-힣]+동)", "$1") ///
    if regexm(emd_nm, "제[0-9]+·[가-힣]+동") 

* 4) 숫자+문자+"제"+숫자+"동" 패턴에서 "제" 삭제 (예: 성수1가제1동 → 성수1가1동)
replace emd_nm_new = ustrregexra(emd_nm_new, "([0-9]+[가-힣]+)제([0-9]+동)", "$1$2") ///
    if regexm(emd_nm, "[0-9]+[가-힣]+제[0-9]+동")
	
drop emd_nm 
ren emd_nm_new emd_nm 

merge m:n year sido_nm emd_nm using "/Users/ihuila/Desktop/data/master thesis/after/2012_2024시군구읍면동_clean.dta"

br if _merge!=3 
order year sido_nm sggName sigungu_nm emd_nm 

// 여기부턴 수동으로 넣기 (자료보고)
replace sigungu_nm = "파주시" if sggName=="파주시을" & _merge!=3 & emd_nm=="진동면"
replace sigungu_nm = "사천시" if sggName == "사천시남해군하동군" & _merge!=3 & emd_nm=="벌용동"
replace sigungu_nm = "창원시의창구" if sggName == "창원시의창구" & _merge!=3 & emd_nm=="팔용동"

replace sigungu_nm = "세종특별자치시" if sido_nm=="세종특별자치시" & _merge!=3 
replace sigungu_nm = "종로구" if sggName == "종로구" & _merge!=3 

replace sigungu_nm = sggName if sggName =="공주시" &_merge!=3 
replace sigungu_nm = sggName if sggName =="청원군" &_merge!=3 
replace sigungu_nm = sggName if sggName =="거제시" &_merge!=3 

replace sigungu_nm = "평택시" if sggName =="평택시을" &_merge!=3 
replace sigungu_nm = "영월군" if sggName == "태백시횡성군영월군평창군정선군" &_merge!=3 & emd_nm=="수주면"
replace sigungu_nm = "서구" if sido_nm=="인천광역시" & _merge!=3 & emd_nm=="청라동"

drop if _merge==2 
drop _merge

br // obs = 13,983  - 2012: 3,480 / 2016: 3,467 / 2020: 3,485 / 2024: 3,551 
*****************************************************************************8
sort year sido_nm sggName sigungu_nm 

bysort year sido_nm sigungu_nm: egen 선거인수_시군구 = total(선거인수)
bysort year sido_nm sigungu_nm: egen 투표수_시군구 = total(투표수)
bysort year sido_nm sigungu_nm: egen 유효투표수_시군구 = total(유효투표수)
bysort year sido_nm sigungu_nm: egen 무효투표수_시군구 = total(무효투표수)

// 잘못분류된 것 찾기 
br if sigungu_nm != sggName 
*/

/*
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
rename 선거구 sggName 
ren 읍면동 emd_nm 
destring 선거인수 투표수 유효투표수 무효투표수 기권수, replace ignore(",")

// 읍면동 단위까지 (현재는 투표구까지 되어있음) 
keep if 투표구 == "소계"

gen year = 2012 
drop 투표구




gen sigungu_nm=""
**************************************************
***** 서울: 시군구=선거구인경우 
replace sigungu_nm=sggName if sggName =="종로구"&sido_nm=="서울특별시"  
replace sigungu_nm=sggName if sggName =="중구"&sido_nm=="서울특별시" 
replace sigungu_nm=sggName if sggName =="용산구"&sido_nm=="서울특별시" 
replace sigungu_nm=sggName if sggName =="금천구"&sido_nm=="서울특별시" 

***** 부산: 시군구=선거구인경우 
replace sigungu_nm=sggName if sggName=="서구"&sido_nm=="부산광역시"  
replace sigungu_nm=sggName if sggName=="영도구"&sido_nm=="부산광역시"  
replace sigungu_nm=sggName if sggName=="동래구"&sido_nm=="부산광역시"  
replace sigungu_nm=sggName if sggName=="금정구"&sido_nm=="부산광역시" 
replace sigungu_nm=sggName if sggName=="연제구"&sido_nm=="부산광역시" 
replace sigungu_nm=sggName if sggName=="수영구"&sido_nm=="부산광역시" 
replace sigungu_nm=sggName if sggName=="사상구"&sido_nm=="부산광역시" 

***** 대구: 시군구=선거구인경우 
replace sigungu_nm=sggName if sggName=="서구"&sido_nm=="대구광역시"  
replace sigungu_nm=sggName if sggName=="달성군"&sido_nm=="대구광역시"  

***** 인천: 시군구=선거구인경우 
replace sigungu_nm=sggName if sggName=="연수구"&sido_nm=="인천광역시"  

***** 광주: 시군구=선거구인경우 
replace sigungu_nm=sggName if sggName=="동구"&sido_nm=="광주광역시"
replace sigungu_nm=sggName if sggName=="남구"&sido_nm=="광주광역시" 

***** 대전: 시군구=선거구인경우 
replace sigungu_nm=sggName if sggName=="동구"&sido_nm=="대전광역시"
replace sigungu_nm=sggName if sggName=="중구"&sido_nm=="대전광역시" 
replace sigungu_nm=sggName if sggName=="유성구"&sido_nm=="대전광역시" 
replace sigungu_nm=sggName if sggName=="대덕구"&sido_nm=="대전광역시" 

***** 울산: 시군구=선거구인경우 
replace sigungu_nm=sggName if sggName=="중구"&sido_nm=="울산광역시"
replace sigungu_nm=sggName if sggName=="동구"&sido_nm=="울산광역시" 
replace sigungu_nm=sggName if sggName=="북구"&sido_nm=="울산광역시" 
replace sigungu_nm=sggName if sggName=="울주군"&sido_nm=="울산광역시" 



***** 세종: 전체 -> 세종특별자치시 
replace sigungu_nm = sggName if sido_nm=="세종특별자치시" 
*/
