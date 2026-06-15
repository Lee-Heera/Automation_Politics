**********************************************************************
* 대선 정치
* 1992 대통령선거 (14대) 개표결과 정리
**********************************************************************
clear all

global main   "/Users/ihuila/Research/MASTER_thesis"
global data   "${main}/Data cleaned"
global interim "${main}/Data interim"

local yr   1992 
local elec 14
local in   "$main/Data raw/대선_개표/`yr'"
local out  "$interim/대선_개표/`yr'"

**********************************************************************
* STEP 1: 시도별 Excel → dta 저장
**********************************************************************
local files    `" "강원" "경기" "경남" "경북" "광주" "대구" "대전" "부산" "서울" "인천" "전남" "전북" "제주" "충남" "충북" "'
local sidonames `" "강원도" "경기도" "경상남도" "경상북도" "광주광역시" "대구광역시" "대전광역시" "부산광역시" "서울특별시" "인천광역시" "전라남도" "전라북도" "제주특별자치도" "충청남도" "충청북도" "'

local n = wordcount(`"`files'"')
forvalues i = 1/`n' {
    local region : word `i' of `files'
    local sidonm : word `i' of `sidonames'
    import excel "`in'/개표현황[제`elec'대][대통령선거][`region'].xlsx", firstrow clear
    gen sido_nm = "`sidonm'"
    drop in 1/3
    drop in L
    save "`out'/`region'.dta", replace
}

**********************************************************************
* STEP 2: append
**********************************************************************
use "`out'/강원.dta", clear
foreach region of local files {
    if "`region'" != "강원" append using "`out'/`region'.dta", force
}
save "`out'/preappend.dta", replace

**********************************************************************
* STEP 3: 열 정리 및 변수명 부여
**********************************************************************
use "`out'/preappend.dta", clear

ren 중앙선거관리위원회선거통계시스템 sigungu_nm
ren B 선거인수
ren C 투표수
ren D 민주자유당 
ren E 민주당 
ren F 통일국민당 
ren G 신정당 
ren H 대한정의당 
ren I 무소속김옥선 
ren J 무소속백기완 
ren K 유효투표수
ren L 무효투표
ren M 기권
drop N

order sido_nm sigungu_nm

* 문자열 앞뒤 공백 제거
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

* 헤더/푸터 행 제거
drop if sigungu_nm == "" | inlist(sigungu_nm, "합계", "구시군명", "시도명")

* 깨진 문자 처리
gen _clean = ustrregexra(sigungu_nm, "[^가-힣a-zA-Z0-9]", "")
replace sigungu_nm = _clean + "시" if sigungu_nm != _clean
drop _clean

* 갑/을/병/정 제거 (선거구 분할 표기)
replace sigungu_nm = ustrregexra(sigungu_nm, "[갑을병정]$", "") ///
    if regexm(sigungu_nm, "[갑을병정]$")

local varlist 선거인수 투표수 민주자유당 민주당 통일국민당 신정당 대한정의당 무소속김옥선 무소속백기완 유효투표수 무효투표 기권
destring `varlist', replace ignore(",")

**********************************************************************
* STEP 4: 시군구명 정규화
**********************************************************************
* 울산시 -> 울산광역시  
replace sido_nm = "울산광역시" if sido_nm=="경상남도" & sigungu_nm=="울산시중구"
replace sido_nm = "울산광역시" if sido_nm=="경상남도" & sigungu_nm=="울산시남구"
replace sido_nm = "울산광역시" if sido_nm=="경상남도" & sigungu_nm=="울산시동구"

gen is_metro = regexm(sido_nm, "광역시|특별시|특별자치시")

* 일반도 시+구 → 시 (예: 부천시원미구 → 부천시)
replace sigungu_nm = ustrregexra(sigungu_nm, "([가-힣]+시)[가-힣]+구$", "$1") ///
    if !is_metro & regexm(sigungu_nm, "[가-힣]+시[가-힣]+구$")

* 광역시 구+시 → 구
replace sigungu_nm = ustrregexra(sigungu_nm, "([가-힣]+구)[가-힣]+시$", "$1") ///
    if is_metro & regexm(sigungu_nm, "[가-힣]+구[가-힣]+시$")

* 군+시 → 군
replace sigungu_nm = ustrregexra(sigungu_nm, "([가-힣]+군)[가-힣]+시$", "$1") ///
    if regexm(sigungu_nm, "[가-힣]+군[가-힣]+시$")

drop is_metro

* 수동 보정
// replace sigungu_nm = "중구" if sido_nm=="서울특별시" & sigungu_nm=="중구서울시"

**********************************************************************
* STEP 5: 1차 collapse → 시군구 단위
**********************************************************************
collapse (sum) `varlist', by(sido_nm sigungu_nm)

**********************************************************************
* STEP 6: 행정구역 변경 처리
**********************************************************************
* ── 공통 ─────────────────────────────────────────────────────────────
replace sigungu_nm = "미추홀구" if sido_nm=="인천광역시" & sigungu_nm=="남구"

replace sigungu_nm = "세종특별자치시" if sigungu_nm == "연기군"
replace sido_nm = "세종특별자치시" if sigungu_nm=="세종특별자치시" 

replace sigungu_nm = "여주시"   if sido_nm=="경기도" & sigungu_nm=="여주군"

* ── 창원시 통합: 마산시 + 진해시 → 창원시
replace sigungu_nm = "창원시" if inlist(sigungu_nm, "마산시", "진해시")

* ── 청주시 통합: 청원군 → 청주시
replace sigungu_nm = "청주시" if sigungu_nm == "청원군"

* ── 여수시 통합: 여천군 + 여천시 → 여수시
replace sigungu_nm = "여수시" if inlist(sigungu_nm, "여천군", "여천시")

* ── 제주: 남제주군 → 서귀포시, 북제주군 → 제주시
replace sigungu_nm = "서귀포시" if sigungu_nm == "남제주군"
replace sigungu_nm = "제주시"   if sigungu_nm == "북제주군"

* 동광양시, 광양군 -> 광양시 
replace sigungu_nm="광양시" if sigungu_nm=="동광양시"  
replace sigungu_nm="광양시" if sigungu_nm=="광양군" 

* ── 군 → 시 명칭 변경
foreach pair in "당진군:당진시" "김포군:김포시" "화성군:화성시" "안성군:안성시" ///
                "광주군:광주시" "양주군:양주시" "포천군:포천시" {
    local old = substr("`pair'", 1, strpos("`pair'", ":")-1)
    local new = substr("`pair'", strpos("`pair'", ":")+1, .)
    replace sigungu_nm = "`new'" if sigungu_nm == "`old'"
}


**********************************************************************
* STEP 7: 2차 collapse (통합 후)
**********************************************************************
collapse (sum) `varlist', by(sido_nm sigungu_nm)

**********************************************************************
* STEP 8: 시군구 분리 (2003년 이전 데이터 처리)
**********************************************************************
* 증평군 생성: 괴산군 1/2 분리
foreach var of local varlist {
    replace `var' = `var' / 2 if sigungu_nm=="괴산군" & sido_nm=="충청북도"
}
expand 2 if sigungu_nm=="괴산군" & sido_nm=="충청북도"
bysort sido_nm sigungu_nm: gen _seq = _n if sigungu_nm=="괴산군"
replace sigungu_nm = "증평군" if _seq == 2
drop _seq

* 계룡시 생성: 논산시 1/2 분리 (균등 1/2 가정)
foreach var of local varlist {
    replace `var' = `var' / 2 if sigungu_nm=="논산시" & sido_nm=="충청남도"
}
expand 2 if sigungu_nm=="논산시" & sido_nm=="충청남도"
bysort sido_nm sigungu_nm: gen _seq = _n if sigungu_nm=="논산시"
replace sigungu_nm = "계룡시" if _seq == 2
drop _seq

**********************************************************************
* STEP 9: 저장
**********************************************************************
gen year = `yr'
tab year  

keep year sido_nm sigungu_nm `varlist'

isid sido_nm sigungu_nm
sort sido_nm sigungu_nm
save "$data/`yr'president_clean.dta", replace
