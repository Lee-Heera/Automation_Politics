***** 2025년 대선 - 전국 합치기 
clear

local in "/Users/ihuila/Desktop/data/master thesis/raw/PresiE/2025"
local out "/Users/ihuila/Desktop/data/master thesis/afterpresi/2025"

local files `" "강원특별자치도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전북특별자치도" "제주특별자치도" "충청남도" "충청북도" "세종특별자치시" "'

foreach region of local files {
    
    local fname "[제21대_대통령선거]_개표진행상황[대통령선거][`region'].xlsx"
    
    import excel "`in'/`fname'", firstrow clear
    
    gen sido_nm = "`region'"
    
    drop in 1/3
    drop in L
    
    save "`out'/`region'.dta", replace
    
    di "완료: `region'"
}

cd "/Users/ihuila/Desktop/data/master thesis/afterpresi/2025"

* 각 지역별 데이터 행, 열 수 확인 (각 후보가 몇명인지)
foreach region of local files {
    use "`region'.dta", clear
    di "====== `region' ======"
    di "행 수: `=_N'"
    di "열 수: `=c(k)'"
    describe
}

**********************************STEP 2 각 지역별 데이터 열 개수가 다르므로, 열 개수/ 변수명 통일 
local files `" "강원특별자치도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전북특별자치도" "제주특별자치도" "충청남도" "충청북도" "세종특별자치시" "'
local alpha "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"

use "강원특별자치도.dta",clear 

foreach region of local files {
    use "`region'.dta", clear
    
	drop M 
	
    ren (B C D E F G H I J K L) (선거인수 투표수 더불어민주당 국민의힘 개혁신당 민주노동당 무소속 유효투표수 무효투표 기권 개표율)
	ren 중앙선거관리위원회선거통계시스템  A 
		
    save "`region'.dta", replace
    di "완료: `region'"
}

**********************STEP 3 append 해서 2025년 전국 데이터로 만들것 
use "강원특별자치도.dta", replace 

local files `" "강원특별자치도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "울산광역시" "인천광역시" "전라남도" "전북특별자치도" "제주특별자치도" "충청남도" "충청북도" "세종특별자치시" "'

foreach region of local files {
    if "`region'" != "강원특별자치도" {
        append using "`region'.dta", force
    }
}

save 2025premerge.dta, replace 
*************************** cleaning ***************************************
use 2025premerge.dta, clear 

* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

//득표율 말고, 투표수 기준으로 다시 계산(추후 패널데이터 통합, 시군구 구획 변경때문에)
drop if A == "" // 짝수행 제거 
drop if A == "합계" | A == "구시군명"
drop if A == "시도명"

tab A 

* 1. 깨진 문자 패턴 설정 (한글, 영문, 숫자 외 문자 제거)
gen A_clean = ustrregexra(A, "[^\uAC00-\uD7A3a-zA-Z0-9]", "")

* 2. 원래 값과 비교해서 '깨짐이 있었던 경우'만 처리
replace A_clean = A_clean + "시" if A != A_clean

* 3. A 변수 덮어쓰기 (선택사항)
replace A = A_clean if A != A_clean

* 4. 정리
drop A_clean
ren A sigungu_nm 

destring 선거인수 투표수 더불어민주당 국민의힘 개혁신당 민주노동당 무소속 유효투표수 무효투표 기권 개표율, replace ignore(",")

order sido_nm sigungu_nm 
compress 
************ 명칭변경, 통합, 폐지된 시군구 정리 ********* 기준: 로봇데이터 
/*
****** 1) 인천광역시 남구 -> 미추홀구로 명칭변경  (명칭변경)
replace sigungu_nm = "미추홀구" if sido_nm=="인천광역시" & sigungu_nm == "남구"

****** 2) 연기군 -> 세종으로 통합되면서 연기군 폐지 (연기군 삭제, 세종특별자치시 삭제)
drop if sigungu_nm == "연기군"

***** 3)여주군 -> 여주시로 이름 변경 
replace sigungu_nm = "여주시" if sido_nm=="경기도" & sigungu_nm=="여주군" 
 */
 
count if 개표율 == 100  // 전체 obs와 동일 
drop 개표율 

**** 경북 군위군이 대구광역시로 통합되었으나 (2025년 기준) 로봇데이터 기준으로 다시 경상북도 군위군으로 변경 
replace sido_nm = "경상북도" if sido_nm=="대구광역시" & sigungu_nm=="군위군"

********************************************************************************
* 4) 나머지 구로 쪼개진 시들 → 시로 통합
********************************************************************************
local varlist 선거인수 투표수 더불어민주당 국민의힘 개혁신당 민주노동당 무소속 유효투표수 무효투표 기권
local cities  "부천시 수원시 성남시 안양시 안산시 고양시 용인시 전주시 포항시 천안시 창원시 청주시 화성시"

local 부천시_gu "부천시오정구 부천시원미구 부천시소사구"
local 수원시_gu "수원시장안구 수원시권선구 수원시팔달구 수원시영통구"
local 성남시_gu "성남시수정구 성남시중원구 성남시분당구"
local 안양시_gu "안양시만안구 안양시동안구"
local 안산시_gu "안산시상록구 안산시단원구"
local 고양시_gu "고양시덕양구 고양시일산동구 고양시일산서구"
local 용인시_gu "용인시처인구 용인시기흥구 용인시수지구"
local 전주시_gu "전주시완산구 전주시덕진구"
local 포항시_gu "포항시북구 포항시남구"
local 천안시_gu "천안시서북구 천안시동남구"
local 창원시_gu "창원시의창구 창원시성산구 창원시마산합포구 창원시마산회원구 창원시진해구"
local 청주시_gu "청주시상당구 청주시서원구 청주시흥덕구 청주시청원구"
local 화성시_gu "화성시갑 화성시을"

foreach city of local cities {

    local gu_list "``city'_gu'"

    * keep 조건 생성
    local keep_cond ""
    foreach gu of local gu_list {
        if "`keep_cond'" == "" local keep_cond `"sigungu_nm == "`gu'""'
        else                    local keep_cond `"`keep_cond' | sigungu_nm == "`gu'""'
    }

    di "==============================="
    di "통합: `city'"
    di "==============================="

    * Step 1: 합산값 스칼라로 저장
    foreach var of local varlist {
        local base_`var' = 0
        foreach gu of local gu_list {
            quietly summarize `var' if sigungu_nm == "`gu'"
            local base_`var' = `base_`var'' + r(sum)
        }
    }

    * Step 2: 통합행 생성 후 append
    preserve
    keep if `keep_cond'
    collapse (sum) `varlist', by(sido_nm)
    gen sigungu_nm = "`city'"
    tempfile merged_`city'
    save `merged_`city''
    restore

    drop if `keep_cond'
    append using `merged_`city''

    * Step 3: 검증
    local all_ok 1
    foreach var of local varlist {
        quietly summarize `var' if sigungu_nm == "`city'"
        local diff = abs(r(mean) - `base_`var'')
        if `diff' > 0.01 {
            di "  ❌ `var' 불일치: 예상=`base_`var'', 실제=`r(mean)'"
            local all_ok 0
        }
    }
    if `all_ok' == 1 di " ✅ 모든 변수 일치 — `city' 통합 완료"
    else             di "  ⚠️ 검증 실패 — `city' 확인 필요"
}

********************************************
********** 강원특별자치도, 전북특별자치도 -> 강원도, 전라북도로 변경 
replace sido_nm="강원도" if sido_nm == "강원특별자치도"
replace sido_nm="전라북도" if sido_nm=="전북특별자치도" 

*********************************
sort sido_nm sigungu_nm 
gen year=2025

tab sigungu_nm 

// 제주2, 세종1, 나머지 226 -> 총 obs 229

save 2025premerge.dta, replace 
