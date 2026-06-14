**********************************************************************
* Robot and automation
* 19대 국회의원선거 개표결과 → 읍면동별 선거인수/투표수 + 시군구 매핑
**********************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global data "${main}/Data cleaned"
	global interim "${main}/Data interim"
	global final "${main}/Data final"

*******************************************************************************
* ── 1. 코드 테이블 (2012년 기준) ─────────────────────────────────────────────
import excel "$main/Data raw/센서스 공간정보 지역 코드.xlsx", sheet("2012년") clear
drop in 1
rename (A B C D E F) (시도코드 시도명칭 시군구코드 시군구명칭 읍면동코드 읍면동명칭)
drop if missing(읍면동명칭)
keep 시도명칭 시군구명칭 읍면동명칭

save "$interim/선거구시군구매핑/code_tbl_2012.dta", replace

* ── 2. 선거 데이터 로드 및 전처리 ─────────────────────────────────────────────
import excel "$main/Data raw/총선_개표/제19대 국회의원선거 개표결과.xlsx", sheet("지역구") clear

rename (A B C D E F) (시도_raw 선거구 읍면동 투표구 선거인수_str 투표수_str)
drop O
//ren (G H I J K L M N P Q R) (새누리당 민주통합당 국민의힘 국민행복당 불교연합당 진보신당 무소속류승구 무소속서맹종 유효투표수 무효투표 기권)

* 헤더행 제거 (시도_raw == "시도")
replace 시도_raw = "" if 시도_raw == "시도"
gen 시도 = 시도_raw
replace 시도 = 시도[_n-1] if 시도 == ""

* 소계 행만 유지
keep if 투표구 == "소계"

* 숫자 변환
gen 선거인수_clean = subinstr(선거인수_str, ",", "", .)
gen 투표수_clean   = subinstr(투표수_str,   ",", "", .)
destring 선거인수_clean 투표수_clean, replace
rename (선거인수_clean 투표수_clean) (선거인수 투표수)
//destring 새누리당 민주통합당 국민의힘 국민행복당 불교연합당 진보신당 무소속류승구 무소속서맹종 유효투표수 무효투표 기권, replace ignore(",")

* 수동 매핑: 실행 후 robustness check [2]에서 누락 읍면동 확인하여 추가
gen 시군구 = ""

* 정규화: 제N동 → N동
gen 읍면동_norm = ustrregexra(읍면동, "제([0-9])", "$1")

gen _id = _n
* 정당별 득표수 포함 전체 컬럼 저장 (xlsx → dta 변환 보존 목적)
save "$interim/선거구시군구매핑/19대총선_읍면동별_총선개표.dta", replace

* ── 3. Pass 1: 원본 읍면동명으로 merge ────────────────────────────────────────
use "$interim/선거구시군구매핑/19대총선_읍면동별_총선개표.dta", clear

rename 시도 시도명칭
rename 읍면동 읍면동명칭
joinby 시도명칭 읍면동명칭 using "$interim/선거구시군구매핑/code_tbl_2012.dta", unmatched(master) _merge(_m1)
rename 읍면동명칭 읍면동
rename 시도명칭 시도

preserve
    keep if _m1 == 3 & 시군구 == ""
    replace 시군구 = 시군구명칭
    drop 시군구명칭 _m1
    save "$interim/선거구시군구매핑/19대_matched1.dta", replace
restore

keep if _m1 == 1
drop 시군구명칭 _m1

* ── 4. Pass 2: 정규화 읍면동명으로 merge ──────────────────────────────────────
rename 시도 시도명칭
rename 읍면동_norm 읍면동명칭
joinby 시도명칭 읍면동명칭 using "$interim/선거구시군구매핑/code_tbl_2012.dta", unmatched(master) _merge(_m2)
rename 읍면동명칭 읍면동_norm
rename 시도명칭 시도

replace 시군구 = 시군구명칭 if 시군구 == "" & _m2 == 3
drop 시군구명칭 _m2

save "$interim/선거구시군구매핑/19대_matched2.dta", replace

* ── 5. 합치기 + 중복 해소 ──────────────────────────────────────────────────────
use "$interim/선거구시군구매핑/19대_matched1.dta", clear
append using "$interim/선거구시군구매핑/19대_matched2.dta"

gen 선거구_norm = ustrregexra(선거구, "[갑을병정무]$", "")
replace 선거구_norm = subinstr(선거구_norm, " ", "", .)
gen 시군구_norm = subinstr(시군구, " ", "", .)

bysort _id: gen _n_matches = _N

gen _match_ok = ustrregexm(선거구_norm, 시군구_norm) | ustrregexm(시군구_norm, 선거구_norm)
bysort _id: egen _any_ok = max(_match_ok)
drop if _n_matches > 1 & _any_ok == 1 & _match_ok == 0
drop _match_ok _any_ok

bysort _id: keep if _n == 1

drop _id _n_matches 선거구_norm 시군구_norm
capture drop 읍면동_norm

* ── 6. 최종 정리 및 저장 ───────────────────────────────────────────────────────
//order 시도 시군구 선거구 읍면동 선거인수 투표수 새누리당 민주통합당 국민의힘 국민행복당 불교연합당 진보신당 무소속류승구 무소속서맹종 유효투표수 무효투표 기권
sort 시도 시군구 선거구 읍면동

count
count if missing(시군구)

save "$data/2012congress_clean.dta", replace

* ── 7. Robustness Check ─────────────────────────────────────────────────────

* (1) 읍면동 행 수
quietly count
local N_final = r(N)

preserve
    import excel "$main/Data raw/총선_개표/제19대 국회의원선거 개표결과.xlsx", ///
        sheet("지역구") clear
    rename D 투표구
    quietly count if 투표구 == "소계"
    local N_소계원본 = r(N)
restore

di ""
di "══════════════════════════════════════════"
di "  Robustness Check: 19대 선거구-시군구 매핑"
di "══════════════════════════════════════════"
di ""
di "[ 1 ] 읍면동 행 수"
di "      원본 소계 행 수  : `N_소계원본'"
di "      최종 데이터 행 수: `N_final'"
if `N_final' == `N_소계원본' {
    di "      → 일치 ✔"
}
else {
    di "      → 불일치 ✘  차이: " `N_final' - `N_소계원본'
}

* (2) 시군구 누락 여부
quietly count if missing(시군구) | 시군구 == ""
local N_missing = r(N)
di ""
di "[ 2 ] 시군구 누락"
di "      missing 행 수: `N_missing'"
if `N_missing' == 0 {
    di "      → 누락 없음 ✔"
}
else {
    di "      → 누락 있음 ✘"
    list 시도 선거구 읍면동 if missing(시군구) | 시군구 == ""
}

* (3) 고유 시군구 수 (시도+시군구 쌍 기준)
tempvar sgg_tag
bysort 시도 시군구: gen `sgg_tag' = (_n == 1)
quietly count if `sgg_tag'
local N_sgg = r(N)
drop `sgg_tag'

quietly levelsof 시도, local(sido_list)
local N_sido = r(r)

di ""
di "[ 3 ] 고유 시군구 수 (시도+시군구 쌍 기준)"
di "      최종 데이터 시군구 수: `N_sgg'"
di "      고유 시도 수         : `N_sido'"

* (4) 선거인수 총합
quietly sum 선거인수
local sum_final = r(sum)

preserve
    import excel "$main/Data raw/총선_개표/제19대 국회의원선거 개표결과.xlsx", ///
        sheet("지역구") clear
    rename (A B C D E F) (시도_raw 선거구 읍면동 투표구 선거인수_str 투표수_str)
    keep if 투표구 == "소계"
    gen 선거인수_clean = subinstr(선거인수_str, ",", "", .)
    destring 선거인수_clean, replace
    quietly sum 선거인수_clean
    local sum_원본 = r(sum)
restore

di ""
di "[ 4 ] 선거인수 총합 (소계 행 기준)"
di "      원본 소계 합산: " %15.0fc `sum_원본'
di "      최종 데이터   : " %15.0fc `sum_final'
local diff = abs(`sum_final' - `sum_원본')
if `diff' == 0 {
    di "      → 일치 ✔"
}
else {
    di "      → 불일치 ✘  차이: " %15.0fc `diff'
}

* (5) 시군구별 읍면동 수 분포
di ""
di "[ 5 ] 시군구별 읍면동 수 (상위 5개)"
preserve
    bysort 시도 시군구: gen n_emd = _N
    bysort 시도 시군구: keep if _n == 1
    gsort -n_emd
    list 시도 시군구 n_emd in 1/5, noobs
    di "      하위 5개 (읍면동 가장 적은 시군구)"
    gsort n_emd
    list 시도 시군구 n_emd in 1/5, noobs
restore

* (6) 선거구 수: PDF 공식 기준 19대 246개
tempvar sel_tag
bysort 시도 선거구: gen `sel_tag' = (_n == 1)
quietly count if `sel_tag'
local N_선거구 = r(N)
drop `sel_tag'

di ""
di "[ 6 ] 선거구 수 (시도+선거구 쌍 기준)"
di "      데이터 선거구 수: `N_선거구'  (PDF 공식 246 → 246 정상)"
if `N_선거구' == 246 {
    di "      → 정상 ✔"
}
else {
    di "      → 확인 필요 ✘"
}
/*
* (7) 유효투표수 총합
quietly sum 유효투표수
local sum_유효_final = r(sum)

preserve
    import excel "$main/Data raw/총선_개표/제19대 국회의원선거 개표결과.xlsx", ///
        sheet("지역구") clear
    rename D 투표구
    keep if 투표구 == "소계"
    gen 유효투표수_raw = subinstr(P, ",", "", .)
    destring 유효투표수_raw, replace
    quietly sum 유효투표수_raw
    local sum_유효_원본 = r(sum)
restore

di ""
di "[ 7 ] 유효투표수 총합"
di "      원본 소계 합산: " %15.0fc `sum_유효_원본'
di "      최종 데이터   : " %15.0fc `sum_유효_final'
local diff7 = abs(`sum_유효_final' - `sum_유효_원본')
if `diff7' == 0 {
    di "      → 일치 ✔"
}
else {
    di "      → 불일치 ✘  차이: " %15.0fc `diff7'
}
*/
di ""
di "══════════════════════════════════════════"

* 임시파일 정리
erase "$interim/선거구시군구매핑/code_tbl_2012.dta"
// erase "$interim/선거구시군구매핑/19대총선_읍면동별_총선개표.dta"
erase "$interim/선거구시군구매핑/19대_matched1.dta"
erase "$interim/선거구시군구매핑/19대_matched2.dta"
