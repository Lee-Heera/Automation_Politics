clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin"

use "총선 투표 결과_2008" // 시군구 단위로 되어있음 
**********************************
*** 둘다 합계인 행 
drop if sdName=="합계" & wiwName == "합계"

*** xx시 / 합계인 행 
drop if wiwName == "합계"

*** 연도 변수 생성 
gen year = substr(sgId, 1, 4)
destring year, replace

tab year  // 선거아닌 연도 -> 재보궐 
keep if year ==2008 | year == 2012 | year ==2016 | year == 2020 | year == 2024 

*** 쓸모 없는 변수 삭제
drop turnout vrOrder num 

rename sdName sido_nm 
rename wiwName sigungu_nm 

destring totSunsu psSunsu psEtcSunsu totTusu psTusu psEtcTusu, replace 

*********************************** 명칭변경 혹은 삭제 
****** 1) 인천광역시 남구 -> 미추홀구로 명칭변경  (명칭변경)
replace sigungu_nm = "미추홀구" if sido_nm=="인천광역시" & sigungu_nm == "남구"

****** 2) 연기군 -> 세종으로 통합되면서 연기군 폐지 (연기군 삭제, 세종특별자치시 삭제)
drop if sigungu_nm == "연기군" & year == 2008 
replace sigungu_nm = "세종특별자치시" if sido_nm=="세종특별자치시" & sigungu_nm=="연기군" & year == 2012 

// 2012년에는 원자료가 세종특별자치시-연기군으로 저장되어있음 

***** 3)여주군 -> 여주시로 이름 변경 
replace sigungu_nm = "여주시" if sido_nm=="경기도" & sigungu_nm=="여주군" 
 
***** 4) 당진군 -> 당진시로 승격 
replace sigungu_nm="당진시" if sigungu_nm=="당진군"

***** 5) 대구광역시 군위군 (2023 or 2024) 
replace sido_nm = "경상북도" if sido_nm=="대구광역시" & sigungu_nm=="군위군" 

***** 6) 강원특별자치도 -> 강원도 
replace sido_nm = "강원도" if sido_nm == "강원특별자치도"

***** 7) 전북특별자치도 -> 전라북도 
replace sido_nm = "전라북도" if sido_nm == "전북특별자치도"
************************************ 통합해야 하는 경우 - 데이터 탐색  
* Case 1) 창원시 
br if sido_nm == "경상남도"

// 2008년: 마산시, 진해시, 창원시 (시 단위) -> 창원시 (시단위)
// 2012년: 창원시의창구, 창원시성산구, 창원시마산합포구, 창원시마산회원구, 창원시진해구(시/구 단위) -> 창원시(시로 통합)
// 2016년: 2012년과 동일 
// 2020년: 2012년과 동일 
// 2024년: 2012년과 동일 

* Case 2) 청주시 
br if sido_nm== "충청북도"
// 2008년: 청주시상당구, 청주시흥덕구, 청원군 (시/구 + 시) -> 청주시 (시 단위)
// 2012년: 청주시상당구, 청주시흥덕구, 청원군 (시/구 + 시) -> 청주시 (시 단위)
// 2016년: 청주시상당구, 청주시흥덕구, 청주시서원구, 청주시청원구(시/구) -> 청주시 (시로 통합)
// 2020년: 청주시상당구, 청주시흥덕구, 청주시서원구, 청주시청원구(시/구) -> 청주시 (시로 통합)
// 2024년: 청주시상당구, 청주시흥덕구, 청주시서원구, 청주시청원구(시/구) -> 청주시 (시로 통합)

* Case 3) 부천시 
br if sido_nm=="경기도" 

// 2008년: 부천시원미구, 부천시소사구, 부천시오정구 (시/구) -> 부천시 (시로 통합)
// 2012년: 부천시원미구, 부천시소사구, 부천시오정구 (시/구) -> 부천시 (시로 통합)
// 2016년: 부천시원미구, 부천시소사구, 부천시오정구 (시/구) -> 부천시 (시로 통합)
// 2020년: 부천시 (그대로 두면됨)
// 2024년: 부천시원미구, 부천시소사구, 부천시오정구 (시/구) -> 부천시 (시로 통합)

* Case 4) 천안시 
// 2008년 천안시 (이건 그대로두기)
// 2012, 2016, 2020, 2024년: 천안시서북구, 천안시동남구 (시/구) -> 천안시(시로 통합)
 
* Case 5) 나머지 시/구들 (행정구역 변경없이 그냥 합치는 것) - across year (모든 대수에 걸쳐)
// 수원시, 성남시, 안양시, 안산시, 고양시, 용인시, 전주시, 포항시 (시/구로 나누어진것 -> 시로 통합)

********************************************************************************
* Case 1) 창원시 통합
********************************************************************************
local varlist totSunsu psSunsu psEtcSunsu totTusu psTusu psEtcTusu

* ========== 2008년 처리 ==========
local target_2008   "창원시"
local src_list_2008 "마산시 진해시"

* src 조건 생성 (2008)
local src_cond_2008 ""
foreach src of local src_list_2008 {
    if "`src_cond_2008'" == "" local src_cond_2008 `"sigungu_nm == "`src'""'
    else                        local src_cond_2008 `"`src_cond_2008' | sigungu_nm == "`src'""'
}

* Step 1: 합산값 계산 (2008)
foreach var of local varlist {
    quietly summarize `var' if sigungu_nm == "`target_2008'" & year == 2008
    local base_`var'_2008 = r(sum)
    foreach src of local src_list_2008 {
        quietly summarize `var' if sigungu_nm == "`src'" & year == 2008
        local base_`var'_2008 = `base_`var'_2008' + r(sum)
    }
}

* Step 2: _new 변수 생성 (2008)
foreach var of local varlist {
    gen `var'_new = `var'
    replace `var'_new = `base_`var'_2008' if sigungu_nm == "`target_2008'" & year == 2008
}

* Step 3: 검증 (2008)
local all_ok_2008 1
foreach var of local varlist {
    quietly summarize `var'_new if sigungu_nm == "`target_2008'" & year == 2008
    local diff = abs(r(mean) - `base_`var'_2008')
    if `diff' > 0.01 {
        di "  ❌ [2008] `var' 불일치: 예상=`base_`var'_2008', _new=`r(mean)'"
        local all_ok_2008 0
    }
}
if `all_ok_2008' == 1 di "  ✅ 창원시(2008) 모든 변수 일치"

* Step 4: 처리 (2008)
if `all_ok_2008' == 1 {
    drop if (`src_cond_2008') & year == 2008
    di "  ✅ 창원시(2008) 마산시, 진해시 삭제 완료"
}
else {
    foreach var of local varlist {
        drop `var'_new
    }
    gen `var'_new = `var'
    di "  ⚠️ [2008] 검증 실패 — 통합 중단"
}

* ========== 2012년 이후 처리 ==========
local target_2012   "창원시"
local src_list_2012 "창원시의창구 창원시성산구 창원시마산합포구 창원시마산회원구 창원시진해구"

* src 조건 생성 (2012~)
local src_cond_2012 ""
foreach src of local src_list_2012 {
    if "`src_cond_2012'" == "" local src_cond_2012 `"sigungu_nm == "`src'""'
    else                        local src_cond_2012 `"`src_cond_2012' | sigungu_nm == "`src'""'
}

* Step 1: 합산값 계산 (2012~)
foreach var of local varlist {
    foreach yr in 2012 2016 2020 2024 {
        local base_`var'_`yr' = 0
        foreach src of local src_list_2012 {
            quietly summarize `var'_new if sigungu_nm == "`src'" & year == `yr'
            local base_`var'_`yr' = `base_`var'_`yr'' + r(sum)
        }
    }
}

* Step 2: 새 행 추가 및 값 입력 (2012~)
foreach yr in 2012 2016 2020 2024 {
    * 창원시 행이 이미 있는지 확인
    count if sigungu_nm == "`target_2012'" & year == `yr'
    if r(N) == 0 {
        * 없으면 새 행 추가 (첫 번째 구에서 복사)
        local first_gu : word 1 of `src_list_2012'
        expand 2 if sigungu_nm == "`first_gu'" & year == `yr', gen(new_row)
        replace sigungu_nm = "`target_2012'" if new_row == 1
        drop new_row
    }
    
    * 합산값 입력
    foreach var of local varlist {
        replace `var'_new = `base_`var'_`yr'' if sigungu_nm == "`target_2012'" & year == `yr'
    }
}

* Step 3: 검증 (2012~)
local all_ok_2012 1
foreach yr in 2012 2016 2020 2024 {
    foreach var of local varlist {
        quietly summarize `var'_new if sigungu_nm == "`target_2012'" & year == `yr'
        local diff = abs(r(mean) - `base_`var'_`yr'')
        if `diff' > 0.01 {
            di "  ❌ [`yr'] `var' 불일치: 예상=`base_`var'_`yr'', _new=`r(mean)'"
            local all_ok_2012 0
        }
    }
}
if `all_ok_2012' == 1 di "  ✅ 창원시(2012~2024) 모든 변수 일치"

* Step 4: 처리 (2012~)
if `all_ok_2012' == 1 {
    drop if (`src_cond_2012') & inlist(year, 2012, 2016, 2020, 2024)
    di "  ✅ 창원시(2012~2024) 구 단위 삭제 완료"
}
* 최종: 변수 교체
if `all_ok_2008' == 1 & `all_ok_2012' == 1 {
    foreach var of local varlist {
        drop `var'
        rename `var'_new `var'
    }
    di "  ✅ 창원시 통합 완료 (전체 연도)"
}
else {
    foreach var of local varlist {
        capture drop `var'_new
    }
    di "  ⚠️ 검증 실패 — 창원시 통합 중단"
}
********************************************************************************
* Case 2) 청주시 통합
* 2008~2012: 청주시상당구 + 청주시흥덕구 + 청원군 → 청주시
* 2016~2024: 청주시상당구 + 청주시흥덕구 + 청주시서원구 + 청주시청원구 → 청주시
********************************************************************************
local varlist totSunsu psSunsu psEtcSunsu totTusu psTusu psEtcTusu

* ========== 2008~2012년 처리 ==========
local target_0812   "청주시"
local src_list_0812 "청주시상당구 청주시흥덕구 청원군"

* src 조건 생성 (2008~2012)
local src_cond_0812 ""
foreach src of local src_list_0812 {
    if "`src_cond_0812'" == "" local src_cond_0812 `"sigungu_nm == "`src'""'
    else                        local src_cond_0812 `"`src_cond_0812' | sigungu_nm == "`src'""'
}

* Step 1: 합산값 계산 (2008~2012)
foreach var of local varlist {
    gen `var'_new = `var'
    foreach yr in 2008 2012 {
        local base_`var'_`yr' = 0
        foreach src of local src_list_0812 {
            quietly summarize `var' if sigungu_nm == "`src'" & year == `yr'
            local base_`var'_`yr' = `base_`var'_`yr'' + r(sum)
        }
    }
}

* Step 2: 새 행 추가 및 값 입력 (2008~2012)
foreach yr in 2008 2012 {
    * 청주시 행이 이미 있는지 확인
    count if sigungu_nm == "`target_0812'" & year == `yr'
    if r(N) == 0 {
        * 없으면 새 행 추가 (청주시상당구에서 복사)
        expand 2 if sigungu_nm == "청주시상당구" & year == `yr', gen(new_row)
        replace sigungu_nm = "`target_0812'" if new_row == 1
        drop new_row
    }
    
    * 합산값 입력
    foreach var of local varlist {
        replace `var'_new = `base_`var'_`yr'' if sigungu_nm == "`target_0812'" & year == `yr'
    }
}

* Step 3: 검증 (2008~2012)
local all_ok_0812 1
foreach yr in 2008 2012 {
    foreach var of local varlist {
        quietly summarize `var'_new if sigungu_nm == "`target_0812'" & year == `yr'
        local diff = abs(r(mean) - `base_`var'_`yr'')
        if `diff' > 0.01 {
            di "  ❌ [`yr'] `var' 불일치: 예상=`base_`var'_`yr'', _new=`r(mean)'"
            local all_ok_0812 0
        }
    }
}
if `all_ok_0812' == 1 di "  ✅ 청주시(2008~2012) 모든 변수 일치"

* Step 4: 처리 (2008~2012)
if `all_ok_0812' == 1 {
    drop if (`src_cond_0812') & inlist(year, 2008, 2012)
    di "  ✅ 청주시(2008~2012) 구/군 단위 삭제 완료"
}

* ========== 2016~2024년 처리 ==========
local target_1624   "청주시"
local src_list_1624 "청주시상당구 청주시흥덕구 청주시서원구 청주시청원구"

* src 조건 생성 (2016~2024)
local src_cond_1624 ""
foreach src of local src_list_1624 {
    if "`src_cond_1624'" == "" local src_cond_1624 `"sigungu_nm == "`src'""'
    else                        local src_cond_1624 `"`src_cond_1624' | sigungu_nm == "`src'""'
}

* Step 1: 합산값 계산 (2016~2024)
foreach var of local varlist {
    foreach yr in 2016 2020 2024 {
        local base_`var'_`yr' = 0
        foreach src of local src_list_1624 {
            quietly summarize `var'_new if sigungu_nm == "`src'" & year == `yr'
            local base_`var'_`yr' = `base_`var'_`yr'' + r(sum)
        }
    }
}

* Step 2: 새 행 추가 및 값 입력 (2016~2024)
foreach yr in 2016 2020 2024 {
    * 청주시 행이 이미 있는지 확인
    count if sigungu_nm == "`target_1624'" & year == `yr'
    if r(N) == 0 {
        * 없으면 새 행 추가 (청주시상당구에서 복사)
        expand 2 if sigungu_nm == "청주시상당구" & year == `yr', gen(new_row)
        replace sigungu_nm = "`target_1624'" if new_row == 1
        drop new_row
    }
    
    * 합산값 입력
    foreach var of local varlist {
        replace `var'_new = `base_`var'_`yr'' if sigungu_nm == "`target_1624'" & year == `yr'
    }
}

* Step 3: 검증 (2016~2024)
local all_ok_1624 1
foreach yr in 2016 2020 2024 {
    foreach var of local varlist {
        quietly summarize `var'_new if sigungu_nm == "`target_1624'" & year == `yr'
        local diff = abs(r(mean) - `base_`var'_`yr'')
        if `diff' > 0.01 {
            di "  ❌ [`yr'] `var' 불일치: 예상=`base_`var'_`yr'', _new=`r(mean)'"
            local all_ok_1624 0
        }
    }
}
if `all_ok_1624' == 1 di "  ✅ 청주시(2016~2024) 모든 변수 일치"

* Step 4: 처리 (2016~2024)
if `all_ok_1624' == 1 {
    drop if (`src_cond_1624') & inlist(year, 2016, 2020, 2024)
    di "  ✅ 청주시(2016~2024) 구 단위 삭제 완료"
}

* 최종: 변수 교체
if `all_ok_0812' == 1 & `all_ok_1624' == 1 {
    foreach var of local varlist {
        drop `var'
        rename `var'_new `var'
    }
    di "  ✅ 청주시 통합 완료 (전체 연도)"
}
else {
    foreach var of local varlist {
        capture drop `var'_new
    }
    di "  ⚠️ 검증 실패 — 청주시 통합 중단"
}
********************************************************************************
* Case 3) 부천시 통합
* 2008, 2012, 2016, 2024: 부천시원미구 + 부천시소사구 + 부천시오정구 → 부천시
* 2020: 부천시 (이미 통합되어 있음, 그대로 유지)
********************************************************************************

local varlist totSunsu psSunsu psEtcSunsu totTusu psTusu psEtcTusu

local target   "부천시"
local src_list "부천시원미구 부천시소사구 부천시오정구"

* src 조건 생성
local src_cond ""
foreach src of local src_list {
    if "`src_cond'" == "" local src_cond `"sigungu_nm == "`src'""'
    else                   local src_cond `"`src_cond' | sigungu_nm == "`src'""'
}

* Step 1: 합산값 계산 (2008, 2012, 2016, 2024)
foreach var of local varlist {
    gen `var'_new = `var'
    foreach yr in 2008 2012 2016 2024 {
        local base_`var'_`yr' = 0
        foreach src of local src_list {
            quietly summarize `var' if sigungu_nm == "`src'" & year == `yr'
            local base_`var'_`yr' = `base_`var'_`yr'' + r(sum)
        }
    }
}

* Step 2: 새 행 추가 및 값 입력
foreach yr in 2008 2012 2016 2024 {
    * 부천시 행이 이미 있는지 확인
    count if sigungu_nm == "`target'" & year == `yr'
    if r(N) == 0 {
        * 없으면 새 행 추가 (부천시원미구에서 복사)
        expand 2 if sigungu_nm == "부천시원미구" & year == `yr', gen(new_row)
        replace sigungu_nm = "`target'" if new_row == 1
        drop new_row
    }
    
    * 합산값 입력
    foreach var of local varlist {
        replace `var'_new = `base_`var'_`yr'' if sigungu_nm == "`target'" & year == `yr'
    }
}

* Step 3: 검증
local all_ok 1
foreach yr in 2008 2012 2016 2024 {
    foreach var of local varlist {
        quietly summarize `var'_new if sigungu_nm == "`target'" & year == `yr'
        local diff = abs(r(mean) - `base_`var'_`yr'')
        if `diff' > 0.01 {
            di "  ❌ [`yr'] `var' 불일치: 예상=`base_`var'_`yr'', _new=`r(mean)'"
            local all_ok 0
        }
    }
}
if `all_ok' == 1 di "  ✅ 부천시(2008, 2012, 2016, 2024) 모든 변수 일치"

* Step 4: 처리
if `all_ok' == 1 {
    drop if (`src_cond') & inlist(year, 2008, 2012, 2016, 2024)
    foreach var of local varlist {
        drop `var'
        rename `var'_new `var'
    }
    di "  ✅ 부천시 통합 완료"
}
else {
    foreach var of local varlist {
        drop `var'_new
    }
    di "  ⚠️ 검증 실패 — 부천시 통합 중단"
}

********************************************************************************
* Case 4) 천안시 통합
* 2008: 천안시 (그대로 유지)
* 2012, 2016, 2020, 2024: 천안시서북구 + 천안시동남구 → 천안시
********************************************************************************
local varlist totSunsu psSunsu psEtcSunsu totTusu psTusu psEtcTusu

local target   "천안시"
local src_list "천안시서북구 천안시동남구"

* src 조건 생성
local src_cond ""
foreach src of local src_list {
    if "`src_cond'" == "" local src_cond `"sigungu_nm == "`src'""'
    else                   local src_cond `"`src_cond' | sigungu_nm == "`src'""'
}

* Step 1: 합산값 계산 (2012, 2016, 2020, 2024)
foreach var of local varlist {
    gen `var'_new = `var'
    foreach yr in 2012 2016 2020 2024 {
        local base_`var'_`yr' = 0
        foreach src of local src_list {
            quietly summarize `var' if sigungu_nm == "`src'" & year == `yr'
            local base_`var'_`yr' = `base_`var'_`yr'' + r(sum)
        }
    }
}

* Step 2: 새 행 추가 및 값 입력
foreach yr in 2012 2016 2020 2024 {
    * 천안시 행이 이미 있는지 확인
    count if sigungu_nm == "`target'" & year == `yr'
    if r(N) == 0 {
        * 없으면 새 행 추가 (천안시서북구에서 복사)
        expand 2 if sigungu_nm == "천안시서북구" & year == `yr', gen(new_row)
        replace sigungu_nm = "`target'" if new_row == 1
        drop new_row
    }
    
    * 합산값 입력
    foreach var of local varlist {
        replace `var'_new = `base_`var'_`yr'' if sigungu_nm == "`target'" & year == `yr'
    }
}

* Step 3: 검증
local all_ok 1
foreach yr in 2012 2016 2020 2024 {
    foreach var of local varlist {
        quietly summarize `var'_new if sigungu_nm == "`target'" & year == `yr'
        local diff = abs(r(mean) - `base_`var'_`yr'')
        if `diff' > 0.01 {
            di "  ❌ [`yr'] `var' 불일치: 예상=`base_`var'_`yr'', _new=`r(mean)'"
            local all_ok 0
        }
    }
}
if `all_ok' == 1 di "  ✅ 천안시(2012~2024) 모든 변수 일치"

* Step 4: 처리
if `all_ok' == 1 {
    drop if (`src_cond') & inlist(year, 2012, 2016, 2020, 2024)
    foreach var of local varlist {
        drop `var'
        rename `var'_new `var'
    }
    di "  ✅ 천안시 통합 완료"
}
else {
    foreach var of local varlist {
        drop `var'_new
    }
    di "  ⚠️ 검증 실패 — 천안시 통합 중단"
}
********************************************************************************
* Case 5) 나머지 구로 쪼개진 시들 → 시로 통합
********************************************************************************
local varlist totSunsu psSunsu psEtcSunsu totTusu psTusu psEtcTusu
local cities  "수원시 성남시 안양시 안산시 고양시 용인시 전주시 포항시"

local 수원시_gu "수원시장안구 수원시권선구 수원시팔달구 수원시영통구"
local 성남시_gu "성남시수정구 성남시중원구 성남시분당구"
local 안양시_gu "안양시만안구 안양시동안구"
local 안산시_gu "안산시상록구 안산시단원구"
local 고양시_gu "고양시덕양구 고양시일산동구 고양시일산서구"
local 용인시_gu "용인시처인구 용인시기흥구 용인시수지구"
local 전주시_gu "전주시완산구 전주시덕진구"
local 포항시_gu "포항시북구 포항시남구"

foreach city of local cities {

    local gu_list "``city'_gu'"

    * 구 조건 생성
    local gu_cond ""
    foreach gu of local gu_list {
        if "`gu_cond'" == "" local gu_cond `"sigungu_nm == "`gu'""'
        else                  local gu_cond `"`gu_cond' | sigungu_nm == "`gu'""'
    }

    di "==============================="
    di "통합: `city'"
    di "==============================="

    * Step 1: 연도별 합산값 계산
    foreach var of local varlist {
        foreach yr in 2008 2012 2016 2020 2024 {
            local base_`var'_`yr' = 0
            foreach gu of local gu_list {
                quietly summarize `var' if sigungu_nm == "`gu'" & year == `yr'
                local base_`var'_`yr' = `base_`var'_`yr'' + r(sum)
            }
        }
    }

    * Step 2: 연도별 통합행 생성 후 append
    preserve
    keep if `gu_cond'
    collapse (sum) `varlist' (first) sgId sgTypecode, by(sido_nm year)
    gen sigungu_nm = "`city'"
    tempfile merged_`city'
    save `merged_`city''
    restore

    drop if `gu_cond'
    append using `merged_`city''

    * Step 3: 연도별 검증
    local all_ok 1
    foreach yr in 2008 2012 2016 2020 2024 {
        foreach var of local varlist {
            quietly summarize `var' if sigungu_nm == "`city'" & year == `yr'
            local diff = abs(r(mean) - `base_`var'_`yr'')
            if `diff' > 0.01 {
                di "  ❌ [`yr'] `var' 불일치: 예상=`base_`var'_`yr'', 실제=`r(mean)'"
                local all_ok 0
            }
        }
    }
    if `all_ok' == 1 di "  ✅ 모든 변수 일치 — `city' 통합 완료"
    else             di "  ⚠️ 검증 실패 — `city' 확인 필요"
}
********************************************************************* 
****** 추가: 화성시 2024년의 경우에 화성시갑, 화성시을로 쪼개져있음 (다른 데이터는 선거구 아님)
local varlist totSunsu psSunsu psEtcSunsu totTusu psTusu psEtcTusu

local target   "화성시"
local src_list "화성시갑 화성시을"

* src 조건 생성
local src_cond ""
foreach src of local src_list {
    if "`src_cond'" == "" local src_cond `"sigungu_nm == "`src'""'
    else                   local src_cond `"`src_cond' | sigungu_nm == "`src'""'
}

* Step 1: 합산값 계산 (2024)
foreach var of local varlist {
    gen `var'_new = `var'
    local base_`var'_2024 = 0
    foreach src of local src_list {
        quietly summarize `var' if sigungu_nm == "`src'" & year == 2024
        local base_`var'_2024 = `base_`var'_2024' + r(sum)
    }
}

* Step 2: 새 행 추가 및 값 입력 (2024)
count if sigungu_nm == "`target'" & year == 2024
if r(N) == 0 {
    * 없으면 새 행 추가 (화성시갑에서 복사)
    expand 2 if sigungu_nm == "화성시갑" & year == 2024, gen(new_row)
    replace sigungu_nm = "`target'" if new_row == 1
    drop new_row
}

* 합산값 입력
foreach var of local varlist {
    replace `var'_new = `base_`var'_2024' if sigungu_nm == "`target'" & year == 2024
}

* Step 3: 검증
local all_ok 1
foreach var of local varlist {
    quietly summarize `var'_new if sigungu_nm == "`target'" & year == 2024
    local diff = abs(r(mean) - `base_`var'_2024')
    if `diff' > 0.01 {
        di "  ❌ [2024] `var' 불일치: 예상=`base_`var'_2024', _new=`r(mean)'"
        local all_ok 0
    }
}
if `all_ok' == 1 di "  ✅ 화성시(2024) 모든 변수 일치"

* Step 4: 처리
if `all_ok' == 1 {
    drop if (`src_cond') & year == 2024
    foreach var of local varlist {
        drop `var'
        rename `var'_new `var'
    }
    di "  ✅ 화성시 통합 완료"
}
else {
    foreach var of local varlist {
        drop `var'_new
    }
    di "  ⚠️ 검증 실패 — 화성시 통합 중단"
}
**************************************************************
sort year sido_nm sigungu_nm 
drop sgTypecode 

tab year 
// 2008: 228개 (세종특별시 제외)
// 2012, 2016, 2020, 2024: 229개 (세종, 제주포함)

cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin"
save congturn_시군구.dta, replace 
