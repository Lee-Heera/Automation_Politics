**********************************************************************
* crosswalk_SOC_ISCO_KSCO.do
* ─────────────────────────────────────────────────────────────────
* ksco5,6,7,8 
* 참고: KLIPS p_jobfam2000은 KSCO 5차 소분류 코드(정수, 앞자리 0 없음)
*       예) KSCO5 "011" → KLIPS 11,  "111" → KLIPS 111
**********************************************************************
clear all
set more off

global main    "/Users/ihuila/Research/MASTER_thesis"
global raw     "${main}/Data raw"
global interim "${main}/Data interim"

* ── 파일명 전역 변수 ──────────────────────────────────────────────
global f_auto  "${raw}/automation_prob.csv"
global f_si    "${raw}/isco_soc_crosswalk.xls"
global f_ki    "${raw}/한국표준직업분류(KSCO 8차)-국제표준직업분류(ISCO-08) 연계표_20251103085955.xlsx"
global f_ver   "${raw}/한국표준직업분류 연계표(8-7 7-6 6-5 5-4 4-3)_250604_20250604045215.xls"

* ──────────────────────────────────────────────────────────────────
* A1. 자동화 확률 (SOC 2010 기준)
* ──────────────────────────────────────────────────────────────────
import delimited "${f_auto}", encoding(latin1) varnames(1) clear
keep soc probability
rename soc        soc_code
rename probability auto_prob

* SOC 코드 하이픈 제거: "11-1011" → "111011"
replace soc_code = subinstr(soc_code, "-", "", .)
replace soc_code = strtrim(soc_code)
drop if missing(soc_code) | missing(auto_prob)

di "[A1] 자동화 확률 로드: " _N " SOC 코드"
tempfile f1_auto
save `f1_auto'

* ──────────────────────────────────────────────────────────────────
* A2. SOC 2010 → ISCO-08 연계표 
* ──────────────────────────────────────────────────────────────────
import excel "${f_si}", sheet(2010 SOC to ISCO-08) ///
    cellrange(A8:D1132) allstring clear

rename A soc_code
rename D isco08
drop C

drop if soc_code == "" | isco08 == ""

* SOC 코드 정리
replace soc_code = strtrim(subinstr(soc_code, "-", "", .))

di "[A2] SOC→ISCO 연계: " _N " 매핑 쌍"
tempfile f2_si
save `f2_si'

merge m:1 soc_code using `f1_auto'
br if _merge==2 

keep if _merge==3 // automation probability 에 있는 직업군만 남기기 
drop _merge 

tempfile soc_isco_auto 
save `soc_isco_auto'

* ── A2a. KSCO 8차 → 7차 ─────────────────────────────────────────
import excel "${f_ver}", sheet("8차-7차 연계") ///
    allstring clear
drop in 1/2 

rename A ksco8
rename C ksco7

ren B kor_ksco8 
ren D kor_ksco7 

replace ksco8 = strtrim(subinstr(ksco8, "*", "", .))
replace ksco7 = strtrim(subinstr(ksco7, "*", "", .))

* Forward fill 신부호 (1:N 매핑 처리)
gen long _obs = _n
gen long _grp = sum(ksco8 != "")
bysort _grp (_obs): replace ksco8 = ksco8[1]
drop _grp _obs

drop if ksco8 == "" | ksco7 == ""

* ── ksco8, ksco7 3자리 코드 생성 ────────────────────────────────
foreach v in ksco8 ksco7 {
    gen `v'_3d = substr(`v', 1, 3)
    * 숫자 코드: 1자리→"X00", 2자리→"XY0"
    replace `v'_3d = `v'_3d + "00" if length(`v'_3d) == 1 & regexm(`v'_3d, "^[0-9]$")
    replace `v'_3d = `v'_3d + "0"  if length(`v'_3d) == 2 & regexm(`v'_3d, "^[0-9]{2}$")
    * 군인 A 코드 → 98x 숫자 코드 변환 (7차-6차 연계 빨간셀 기준)
    * A (군인대분류)→980, A01(장교)→981, A02/A03(준사관/부사관)→982
    replace `v'_3d = "980" if `v'_3d == "A"
    replace `v'_3d = "981" if `v'_3d == "A01"
    replace `v'_3d = "982" if inlist(`v'_3d, "A02", "A03")
}

keep ksco8 ksco7 kor_ksco8 ksco8_3d ksco7_3d

di "[A4a] KSCO8→KSCO7: " _N " 매핑 쌍"
tempfile f4_v87
save `f4_v87'

* ──────────────────────────────────────────────────────────────────
* A3. ISCO-08 → KSCO 8차 연계표
* ──────────────────────────────────────────────────────────────────
import excel "${f_ki}", ///
    sheet("3-2. (연계표) ISCO(08)-KSCO(8차)") ///
    allstring clear

drop in 1/6 

rename A isco08
rename D ksco8
drop B 
compress 

replace isco08 = strtrim(subinstr(isco08, "*", "", .))
replace ksco8  = strtrim(subinstr(ksco8,  "*", "", .))

* ISCO 코드 Forward Fill (Excel 병합 셀 → 빈 셀)
gen long _obs = _n
gen long _grp = sum(isco08 != "")
bysort _grp (_obs): replace isco08 = isco08[1]
drop _grp _obs

drop if isco08 == "" | ksco8 == ""
ren E kor_ksco8 
ren C en_isco08

keep isco08 ksco8 en_isco08 kor_ksco8 

di "[A3] ISCO→KSCO8 연계: " _N " 매핑 쌍"
tempfile f3_ki
save `f3_ki'

* ── A4b. KSCO 7차 → 6차 ─────────────────────────────────────────
import excel "${f_ver}", sheet("7차-6차 연계") ///
     allstring clear
	 
drop in 1/2 

rename A ksco7
rename C ksco6
ren B kor_ksco7 
ren D kor_ksco6 

replace ksco7 = strtrim(subinstr(ksco7, "*", "", .))
replace ksco6 = strtrim(subinstr(ksco6, "*", "", .))

gen long _obs = _n
gen long _grp = sum(ksco7 != "")
bysort _grp (_obs): replace ksco7 = ksco7[1]
drop _grp _obs

* ── ksco6 3자리 코드 생성 (ksco7_3d는 f4_v87에서 이미 생성) ────
gen ksco6_3d = substr(ksco6, 1, 3)
replace ksco6_3d = ksco6_3d + "00" if length(ksco6_3d) == 1 & regexm(ksco6_3d, "^[0-9]$")
replace ksco6_3d = ksco6_3d + "0"  if length(ksco6_3d) == 2 & regexm(ksco6_3d, "^[0-9]{2}$")
* 군인 A 코드 → 98x 숫자 코드 변환 (6차 빨간셀 기준)
* A (군인대분류)→980, A11x(장교)→981, A12x(부사관/병)→982
replace ksco6_3d = "980" if ksco6_3d == "A"
replace ksco6_3d = "981" if ksco6_3d == "A11"
replace ksco6_3d = "982" if ksco6_3d == "A12"

keep ksco7 ksco6 kor_ksco7 kor_ksco6 ksco6_3d

di "[A4b] KSCO7→KSCO6: " _N " 매핑 쌍"
tempfile f5_v76
save `f5_v76'

* ── A4c. KSCO 6차 → 5차 (소분류 3자리 추출) ─────────────────────
*     행 4부터 데이터: Col A=KSCO6, B=항목명, C=KSCO5
import excel "${f_ver}", sheet("6차-5차 연계") ///
     allstring clear

drop in 1/3 

rename A ksco6
rename C ksco5
ren B kor_ksco6
ren D kor_ksco5 

replace ksco6 = strtrim(subinstr(ksco6, "*", "", .))
replace ksco5 = strtrim(subinstr(ksco5, "*", "", .))

gen long _obs = _n
gen long _grp = sum(ksco6 != "")
bysort _grp (_obs): replace ksco6 = ksco6[1]
drop _grp _obs

drop if ksco6 == "" | ksco5 == ""

* ── ksco5 3자리 코드 생성 (ksco6_3d는 f5_v76에서 이미 생성) ────
gen ksco5_3d = substr(ksco5, 1, 3)
replace ksco5_3d = ksco5_3d + "00" if length(ksco5_3d) == 1 & regexm(ksco5_3d, "^[0-9]$")
replace ksco5_3d = ksco5_3d + "0"  if length(ksco5_3d) == 2 & regexm(ksco5_3d, "^[0-9]{2}$")
* 군인 A 코드 → 98x 숫자 코드 변환 (5차 빨간셀 기준)
* A (군인대분류)→980, A11x(장교)→981, A12x(부사관/병)→982
replace ksco5_3d = "980" if ksco5_3d == "A"
replace ksco5_3d = "981" if ksco5_3d == "A11"
replace ksco5_3d = "982" if ksco5_3d == "A12"

keep ksco6 ksco5 kor_ksco6 kor_ksco5 ksco5_3d

di "[A4c] KSCO6→KSCO5: " _N " 매핑 쌍"
tempfile f6_v65
save `f6_v65'
******************************************************************************
* KSCO 
use  `f4_v87'   // KSCO 8차 → 7차

joinby ksco7    using `f5_v76'   // KSCO 7차 → 6차
joinby ksco6    using `f6_v65'   // KSCO 6차 → 5차 소분류
joinby ksco8 	using `f3_ki'
joinby isco08 using `soc_isco_auto'

codebook soc_code // 645 (frey and osborne 데이터 702개의 직업)

compress

tempfile occu_cross
save `occu_cross'
******************************************************************************
* KSCO + ISCO + SOC 
use `occu_cross', clear              

compress
di "[A6] 전체 체인 병합: " _N " 행"
save "${interim}/Klips/occu_crosswalk.dta", replace

* ── A7. KSCO5 소분류 수준 집계 (KLIPS merge용) ──────────────────
gen p_jobfam2000 = real(ksco5_3d)

* SOC×ISCO×KSCO 경로 deduplicate
bysort soc_code isco08 ksco8 ksco7 ksco6 ksco5_3d: keep if _n == 1

* KSCO5 수준 평균 자동화 확률
bysort ksco5_3d: egen auto_prob_mean = mean(auto_prob)

* 대표 행 1개 유지 → 차수별 코드/명칭, ISCO, SOC 보존
bysort ksco5_3d (soc_code isco08 ksco8): keep if _n == 1
replace auto_prob = auto_prob_mean
drop auto_prob_mean

order soc_code isco08 ///
      ksco8 ksco8_3d kor_ksco8 ///
      ksco7 ksco7_3d kor_ksco7 ///
      ksco6 ksco6_3d kor_ksco6 ///
      ksco5 ksco5_3d kor_ksco5 ///
      p_jobfam2000 auto_prob
sort p_jobfam2000

save "${interim}/Klips/auto_ksco.dta", replace
******************************************************************************
use "$data/klips_robot.dta", clear

qui tab p_jobfam2000 if !missing(p_jobfam2000)
local n_occ_raw = r(r)
di "[B0] 원자료 고유 직업 코드(p_jobfam2000) 수: " `n_occ_raw'

* ── B2. 소분류 수준 자동화 확률 병합 ─────────────────────────────
*   ✓ 143/151/272: SOC→ISCO→KSCO 체인으로 자동 커버
*   ✓ 150/310/817: 3자리 체인 없음 → B2a 2자리 평균 fallback
*   ✗ 300/800/900/980: 2자리도 커버 불가 → 결측 처리
merge m:1 p_jobfam2000 using "${interim}/Klips/auto_ksco.dta"
// keep(1 3)

order ksco5_3d p_jobfam2000 p_jobfam2007 p_jobfam2017 auto_prob 
br if _merge==1
tab p_jobfam2000 if _merge==1

* ── B2a. 2자리 fallback: 150(→15), 310(→31), 817(→81) ──────────
gen ksco5_2d = floor(p_jobfam2000 / 10)
bysort ksco5_2d: egen auto_prob_2d = mean(auto_prob)

replace auto_prob = auto_prob_2d ///
    if missing(auto_prob) & inlist(p_jobfam2000, 143, 150, 151, 272, 310, 817)
replace ksco5_3d = string(p_jobfam2000) ///
    if inlist(p_jobfam2000, 143, 150, 151, 272, 310, 817) & ksco5_3d == ""

drop ksco5_2d auto_prob_2d

br if _merge ==1 

order soc_code isco08 ksco8 ksco8_3d kor_ksco8 ksco7 ksco7_3d kor_ksco7 ksco6 ksco6_3d kor_ksco6 ksco5 kor_ksco5 B en_isco08 ksco5_3d p_jobfam2000 p_jobfam2007 p_jobfam2017 auto_prob 

drop _merge

save "$interim/Klips/klips_auto_merge.dta", replace 
