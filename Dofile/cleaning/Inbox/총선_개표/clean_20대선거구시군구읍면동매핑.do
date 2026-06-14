**********************************************************************  
* Robot and automation
* Singapore Employment Statistics clean do-file
**********************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global data "${main}/Data cleaned"
	global interim "${main}/Data interim"
	global final "${main}/Data final"
	global prof_raw "${main}/Data raw/professor_raw"	
	/*
	global ifr "${main}/Data raw/IFR"
	global kepco  "${main}/Data raw/KEPCO"
	global oarlr "${main}/Data raw/OARLR"
	global singapore "${main}/Data raw/Singapore"
	*/
*******************************************************************************
import excel "$main/Data raw/센서스 공간정보 지역 코드.xlsx",sheet("2016년") clear 
drop in 1 
rename (A B C D E F) (시도코드 시도명칭 시군구코드 시군구명칭 읍면동코드 읍면동명칭)
drop if missing(읍면동명칭)
keep 시도명칭 시군구명칭 읍면동명칭

* 정규화 읍면동명칭_norm: 코드 테이블은 원본 그대로 보존 (norm은 선거 데이터에만 적용)
save "$interim/선거구시군구매핑/code_tbl_2016.dta", replace

* ── 2. 선거 데이터 로드 및 전처리 ─────────────────────────────────────────────
import excel "$main/Data raw/총선_개표/제20대 국회의원선거 개표결과.xlsx", sheet("지역구") clear 
	
//cellrange(A1:F30000) clear

rename (A B C D E F) (시도_raw 선거구 읍면동 투표구 선거인수_str 투표수_str)
ren (G H I J K L M N O P Q R S) (새누리당 더불어민주당 국민의당 정의당 노동당 녹색당 진리대한당 한나라당 무소속김대한 무소속이원옥 유효투표수 무효투표 기권)
* 시도 forward fill
replace 시도_raw = "" if 시도_raw == "시도"  // 헤더행 제거
gen 시도 = 시도_raw
replace 시도 = 시도[_n-1] if 시도 == ""

* 소계 행만 유지
keep if 투표구 == "소계"

* 숫자 변환
gen 선거인수_clean = subinstr(선거인수_str, ",", "", .)
gen 투표수_clean   = subinstr(투표수_str,   ",", "", .)
destring 선거인수_clean 투표수_clean, replace
rename (선거인수_clean 투표수_clean) (선거인수 투표수)
//destring 새누리당 더불어민주당 국민의당 정의당 노동당 녹색당 진리대한당 한나라당 무소속김대한 무소속이원옥 유효투표수 무효투표 기권, replace ignore(",")

* 수동 매핑 4개
gen 시군구 = ""
replace 시군구 = "거제시" if 읍면동 == "마전동"
replace 시군구 = "사천시" if 읍면동 == "벌용동"
replace 시군구 = "영월군" if 읍면동 == "수주면"
replace 시군구 = "평택시" if 읍면동 == "청북면"

* 정규화: 선거 데이터 읍면동의 제N동 → N동 (코드 테이블과 맞추기)
gen 읍면동_norm = ustrregexra(읍면동, "제([0-9])", "$1")

gen _id = _n
* 정당별 득표수 포함 전체 컬럼 저장 (xlsx → dta 변환 보존 목적)
save "$interim/선거구시군구매핑/20대총선_읍면동별_총선개표.dta", replace

* ── 3. Pass 1: 원본 읍면동명으로 merge ────────────────────────────────────────
use "$interim/선거구시군구매핑/20대총선_읍면동별_총선개표.dta", clear

* joinby는 양쪽 변수명이 동일해야 함 → rename 후 join
rename 시도 시도명칭
rename 읍면동 읍면동명칭
joinby 시도명칭 읍면동명칭 using "$interim/선거구시군구매핑/code_tbl_2016.dta", unmatched(master) _merge(_m1)
rename 읍면동명칭 읍면동
rename 시도명칭 시도

* 매칭된 것 저장
preserve
    keep if _m1 == 3 & 시군구 == ""
    replace 시군구 = 시군구명칭
    drop 시군구명칭 _m1
    save "$interim/선거구시군구매핑/20대_matched1.dta", replace
restore

* 미매칭 (코드테이블에 없는 읍면동) → Pass 2로
keep if _m1 == 1
drop 시군구명칭 _m1

* ── 4. Pass 2: 정규화 읍면동명으로 merge ──────────────────────────────────────
rename 시도 시도명칭
rename 읍면동_norm 읍면동명칭
joinby 시도명칭 읍면동명칭 using "$interim/선거구시군구매핑/code_tbl_2016.dta", unmatched(master) _merge(_m2)
rename 읍면동명칭 읍면동_norm
rename 시도명칭 시도

* 시군구 확정
replace 시군구 = 시군구명칭 if 시군구 == "" & _m2 == 3
drop 시군구명칭 _m2

save "$interim/선거구시군구매핑/20대_matched2.dta", replace

* ── 5. 합치기 + 중복 해소 ──────────────────────────────────────────────────────
* Pass 1에서 중복 매칭된 경우 (같은 _id에 여러 시군구) → 선거구명으로 필터
use "$interim/선거구시군구매핑/20대_matched1.dta", clear
append using "$interim/선거구시군구매핑/20대_matched2.dta"

* 중복: (시도, 선거구, 읍면동)당 여러 행 발생 시 선거구명에 시군구명이 포함된 것 선택
* 선거구명 정규화: 갑을병정무 제거, 공백 제거
gen 선거구_norm = ustrregexra(선거구, "[갑을병정무]$", "")
replace 선거구_norm = subinstr(선거구_norm, " ", "", .)
gen 시군구_norm = subinstr(시군구, " ", "", .)

bysort _id: gen _n_matches = _N

* 선거구_norm ↔ 시군구_norm 포함 여부 플래그
gen _match_ok = ustrregexm(선거구_norm, 시군구_norm) | ustrregexm(시군구_norm, 선거구_norm)
bysort _id: egen _any_ok = max(_match_ok)

* 좋은 후보가 있는 _id: 매칭 안 되는 후보 제거
* 좋은 후보가 없는 _id: 전부 남겨두고 아래에서 첫 번째만 선택 (행 전체 손실 방지)
drop if _n_matches > 1 & _any_ok == 1 & _match_ok == 0

drop _match_ok _any_ok

* 그래도 중복이면 첫 번째만
bysort _id: keep if _n == 1

drop _id _n_matches 선거구_norm 시군구_norm
capture drop 읍면동_norm

* ── 6. 통영시고성군 보충 ────────────────────────────────────────────────────────
* 메인 개표결과.xlsx에 없어 별도 선거인수현황 파일에서 추가 (투표수는 미제공)

* foreach 전에 메인 데이터를 임시 저장 (import excel clear 가 메모리를 덮어씀)
save "$interim/선거구시군구매핑/20대_main_temp.dta", replace

foreach 시군구이름 in 고성군 통영시 {
    * firstrow 사용: 1행이 변수명이 됨
    * A열 헤더 = "중앙선거관리위원회선거통계시스템" → 읍면동으로 rename
    * G열 헤더 = 빈칸 → Stata가 "G"로 자동명명 → 선거인수로 rename
    * F열 값 중 "확정선거인수" 행 = 전체합계행 → 제거
    import excel "$main/Data raw/총선_개표/선거인수현황[제20대][국회의원선거][경상남도][`시군구이름'].xlsx", ///
        sheet(Sheet1) firstrow clear
    drop B C D E H I J K L M N O P Q
    drop in 1/3
    rename G 선거인수
    rename 중앙선거관리위원회선거통계시스템 읍면동
    drop if F == "확정선거인수"
    drop F
    replace 읍면동 = ustrtrim(읍면동)
    drop if 읍면동 == "읍면동명" | 읍면동 == "합계" | missing(읍면동) | 읍면동 == ""
    keep 읍면동 선거인수
    destring 선거인수, replace ignore(",")
    gen 시도    = "경상남도"
    gen 시군구  = "`시군구이름'"
    gen 선거구  = "통영시고성군"
    gen 투표수  = .
    order 시도 시군구 선거구 읍면동 선거인수 투표수
    save "$interim/선거구시군구매핑/통영고성_`시군구이름'.dta", replace
}

* 메인 데이터 복원 후 append
use "$interim/선거구시군구매핑/20대_main_temp.dta", clear
erase "$interim/선거구시군구매핑/20대_main_temp.dta"
append using "$interim/선거구시군구매핑/통영고성_고성군.dta"
append using "$interim/선거구시군구매핑/통영고성_통영시.dta"

erase "$interim/선거구시군구매핑/통영고성_고성군.dta"
erase "$interim/선거구시군구매핑/통영고성_통영시.dta"

* ── 7. 최종 정리 및 저장 ───────────────────────────────────────────────────────
//order 시도 시군구 선거구 읍면동 선거인수 투표수 새누리당 더불어민주당 국민의당 정의당 노동당 녹색당 진리대한당 한나라당 무소속김대한 무소속이원옥 유효투표수 무효투표 기권
sort 시도 시군구 선거구 읍면동

count
count if missing(시군구)

save "$data/2016congress_clean.dta", replace

* ── 7. Robustness Check ─────────────────────────────────────────────────────

* (1) 읍면동 행 수: 최종 데이터 vs 원본 소계 행 수
quietly count
local N_final = r(N)

preserve
    import excel "$main/Data raw/총선_개표/제20대 국회의원선거 개표결과.xlsx", ///
        sheet("지역구") clear
    rename D 투표구
    quietly count if 투표구 == "소계"
    local N_소계원본 = r(N)
restore

di ""
di "══════════════════════════════════════════"
di "  Robustness Check: 20대 선거구-시군구 매핑"
di "══════════════════════════════════════════"
di ""
di "[ 1 ] 읍면동 행 수"
di "      원본 소계 행 수  : `N_소계원본'  (통영시고성군 별도처리 제외)"
di "      최종 데이터 행 수: `N_final'  (통영시고성군 읍면동 포함)"
* 통영시고성군 읍면동 수 계산
quietly count if 선거구 == "통영시고성군"
local N_통영 = r(N)
di "      (통영시고성군 읍면동 `N_통영'개 포함)"
local N_기대 = `N_소계원본' + `N_통영'
if `N_final' == `N_기대' {
    di "      → 일치 ✔  (`N_소계원본' + `N_통영' = `N_기대')"
}
else {
    di "      → 불일치 ✘  기대: `N_기대', 실제: `N_final'"
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

* (3) 고유 시군구 개수: 시군구 이름만으로 세면 중구·동구 등 중복이름 때문에 과소집계됨
*     → (시도, 시군구) 쌍 기준으로 카운트
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

* (4) 선거인수 총합: 통영시고성군 포함 전체 비교
quietly sum 선거인수
local sum_final = r(sum)

* 통영시고성군은 원본 xlsx에 없으므로 최종 데이터에서 그 합산을 따로 구해 원본에 더함
quietly sum 선거인수 if 선거구 == "통영시고성군"
local sum_통영 = r(sum)

preserve
    import excel "$main/Data raw/총선_개표/제20대 국회의원선거 개표결과.xlsx", ///
        sheet("지역구") clear
    rename (A B C D E F) (시도_raw 선거구 읍면동 투표구 선거인수_str 투표수_str)
    keep if 투표구 == "소계"
    gen 선거인수_clean = subinstr(선거인수_str, ",", "", .)
    destring 선거인수_clean, replace
    quietly sum 선거인수_clean
    local sum_원본 = r(sum) + `sum_통영'
restore

di ""
di "[ 4 ] 선거인수 총합 (통영시고성군 포함)"
di "      원본+통영고성 합산: " %15.0fc `sum_원본'
di "      최종 데이터       : " %15.0fc `sum_final'
local diff = abs(`sum_final' - `sum_원본')
if `diff' == 0 {
    di "      → 일치 ✔"
}
else {
    di "      → 불일치 ✘  차이: " %15.0fc `diff'
}

* (5) 시군구별 읍면동 수 분포 (상·하위 5개)
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

* (6) 선거구 수: (시도, 선거구) 쌍 기준 — 이름만 세면 남구갑/북구을 등 중복으로 과소집계
*     PDF 공식 기준 20대 253개, 통영시고성군이 별도파일이므로 데이터에서는 252개 정상
tempvar sel_tag
bysort 시도 선거구: gen `sel_tag' = (_n == 1)
quietly count if `sel_tag'
local N_선거구 = r(N)
drop `sel_tag'

di ""
di "[ 6 ] 선거구 수 (시도+선거구 쌍 기준)"
di "      데이터 선거구 수: `N_선거구'  (PDF 공식 253, 통영시고성군 포함 → 253 정상)"
if `N_선거구' == 253 {
    di "      → 정상 ✔"
}
else {
    di "      → 확인 필요 ✘"
}
/*
* (7) 유효투표수 총합
quietly sum 유효투표수
local sum_유효_final = r(sum)

* 통영시고성군 읍면동은 투표수=missing → 유효투표수도 missing (원본에 없으므로 비교 제외)
preserve
    import excel "$main/Data raw/총선_개표/제20대 국회의원선거 개표결과.xlsx", ///
        sheet("지역구") clear
    rename D 투표구
    keep if 투표구 == "소계"
    gen 유효투표수_raw = subinstr(Q, ",", "", .)
    destring 유효투표수_raw, replace
    quietly sum 유효투표수_raw
    local sum_유효_원본 = r(sum)
restore

di ""
di "[ 7 ] 유효투표수 총합 (통영시고성군 제외 비교)"
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

/*
* 시군구 집계도 저장
preserve
    collapse (sum) 선거인수 투표수, by(시도 시군구)
    save "$data/2016congress_clean.dta", replace
restore
*/
* 임시파일 정리
erase "$interim/선거구시군구매핑/code_tbl_2016.dta"
//erase "$interim/선거구시군구매핑/20대_지역구_읍면동별_시군구매핑.dta"
erase "$interim/선거구시군구매핑/20대_matched1.dta"
erase "$interim/선거구시군구매핑/20대_matched2.dta"
