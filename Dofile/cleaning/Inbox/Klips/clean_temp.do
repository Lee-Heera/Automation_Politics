
/*==========================================================
 * PART B: 1998년도 KLIPS 데이터 클리닝 + 지역 병합
 *==========================================================*/
use "${raw}/Klips27/Klips_long_260522.dta", clear

*--- B1: 기본 필터 ---
keep if year == 1998
keep if p_age >= 15 & p_age <= 64
keep if !missing(p_age) & !missing(p_sex) & !missing(p_edu) ///
      & !missing(p_region) & !missing(h0142)               ///
      & !missing(p_jobfam2000)

di "[B1] 1998 기본 필터 후 관측치: " _N // 6196 

*--- B2: 변수 클리닝 ---
* 성별 (0=남자, 1=여자)
replace p_sex = p_sex - 1
label define sex_lb 0 "남자" 1 "여자", replace
label values p_sex sex_lb

* 교육 수준 (3단계)
* p_edu: 1=무학, 2=고졸미만, 3=고졸, 4=대재/중퇴, 5=전문대졸, 6=4년제 대졸이상
gen byte edu_cat = 1 if p_edu <= 2
replace  edu_cat = 2 if inrange(p_edu, 3, 5)
replace  edu_cat = 3 if p_edu == 6
label define edu_lb 1 "고졸미만" 2 "고졸~전문대졸" 3 "4년제대졸이상", replace
label values edu_cat edu_lb
label var edu_cat "교육수준 3단계"

*--- B3: 지역 크로스워크 병합 (1998 = 1차 = 구코드) ---
merge m:1 p_region h0142 using "${interim}/crosswalk_region_old.dta", ///
    keep(1 3) nogen keepusing(sidonm sigungu_nm)

count if missing(sigungu_nm)
local n_nomatch = r(N)
if `n_nomatch' > 0 {
    di as error "[B3] 경고: `n_nomatch' 관측치 지역 미매핑 (crosswalk 미포함 코드)"
    di as error "      → 해당 관측치는 region_id = . 로 처리됨"
    tab p_region h0142 if missing(sigungu_nm), m
}
else {
    di "[B3] 지역 크로스워크 병합 완료 (미매핑 없음)"
}

*--- B4: 지역 ID 생성 (시도 × 시군구) ---
* 광역시/특별시: sido × 구(자치구) = 지역 단위
* 일반도: sido × 시/군 (일반구 집계 후)
egen region_id = group(p_region sigungu_nm)
label var region_id "지역 ID (시도×시군구, 시군구 표준화 후)"

quietly levelsof region_id, local(reg_list)
di "[B4] 고유 지역 수: " `: word count `reg_list''

sort pid
save "${interim}/Klips_1998_clean.dta", replace
di "[B] 1998 정리 데이터 저장: " _N " 관측치"

/*==========================================================
 * PART C: Multinomial Logit 추정 (직업선택 확률)
 *   모형: p_jobfam2000 ~ p_age + p_sex + i.edu_cat + i.region_id
 *   직업 카테고리: KSCO5 소분류 ~150개
 *==========================================================*/
use "${interim}/Klips_1998_clean.dta", clear

di "[C] 직업 카테고리 수:"
tab p_jobfam2000

* 가장 빈도 높은 직업코드를 기준 카테고리로 설정
tempvar _cnt
bysort p_jobfam2000: gen `_cnt' = _N
gsort -`_cnt' p_jobfam2000
quietly levelsof p_jobfam2000 if `_cnt' == `_cnt'[1], local(base_occ)
local base_occ = `: word 1 of `base_occ''
drop `_cnt'
di "[C] mlogit 기준 카테고리 (최빈 직업): " `base_occ'

* Multinomial logit 추정
* 지역변수: i.region_id (시군구 수준)
* 수렴 보조: technique(bfgs), iterate(300)
mlogit p_jobfam2000 p_age p_sex i.edu_cat i.region_id, ///
    baseoutcome(`base_occ') iterate(300) technique(bfgs)

* 예측확률 저장: pr_1, pr_2, ..., pr_K (K = 카테고리 수)
* 변수 순서는 e(out) 매트릭스에 저장됨
matrix E_out = e(out)
local K = colsof(E_out)
di "[C] 예측확률 생성: " `K' " 직업 카테고리"

predict double pr_*, pr

save "${interim}/Klips_predicprob.dta", replace
di "[C] 예측확률 저장: " _N " 관측치"

/*==========================================================
 * PART D: Individual Vulnerability 계산
 *   IV_i = Σ_{j=1}^{K} Pr̂(o_i=j | age, sex, edu, region) × θ_j
 *   θ_j: Frey-Osborne (2013) 자동화 확률 (KSCO5 소분류 수준)
 *==========================================================*/
use "${interim}/Klips_predicprob.dta", clear

*--- D1: θ_j 로컬 매크로로 사전 로드 ---
* auto_prob_ksco5.dta: crosswalk_SOC_ISCO_KSCO.do 에서 생성
preserve
    use "${interim}/auto_prob_ksco5.dta", clear
    local n_theta = _N
    forvalues i = 1/`n_theta' {
        local theta_`=p_jobfam2000[`i']' = auto_prob[`i']
    }
    di "[D1] θ_j 로드: `n_theta' 직업 카테고리"
restore

*--- D2: IV 계산 ---
* E_out 행렬은 PART C에서 mlogit 직후 저장됨 (현재 e() 사라짐)
* → PART C에서 matrix E_out = e(out) 으로 저장했으나
*   use 이후 e() 초기화됨. matrix는 유지됨.
* (주의: matrix E_out이 현재 메모리에 있어야 함 - do파일 순서 실행 필수)

gen double IV = 0
local n_mapped  = 0
local n_nomatch = 0

forvalues k = 1/`K' {
    local occ_k = round(E_out[1, `k'])
    local th_k  ``theta_`occ_k'''       // 해당 직업의 θ; 미정의 시 ""
    if "`th_k'" != "" {
        replace IV = IV + pr_`k' * `th_k'
        local ++n_mapped
    }
    else {
        local ++n_nomatch
    }
}

di "[D2] IV 계산 완료"
di "      θ 매핑 성공 직업 수: `n_mapped'"
di "      θ 미매핑 직업 수:    `n_nomatch' (crosswalk 미포함, 0으로 처리)"

* 자신의 현재 직업 자동화 확률 (참고용)
merge m:1 p_jobfam2000 using "${interim}/auto_prob_ksco5.dta", ///
    keep(1 3) nogen keepusing(auto_prob)
rename auto_prob theta_own
label var theta_own "자신 직업 자동화 확률 (θ_j, 참고용)"
label var IV        "개인 자동화 취약도 (Anelli et al. 2019)"

summarize IV theta_own, detail

*--- D3: 최종 저장 ---
keep pid year p_age p_sex edu_cat p_region sidonm sigungu_nm region_id ///
     p_jobfam2000 theta_own IV

sort pid
save "${interim}/Klips_IV.dta", replace
di "[D] 개인 자동화 취약도 저장: " _N " 관측치 → ${interim}/Klips_IV.dta"
