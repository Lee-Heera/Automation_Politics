clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin"

use "총선 개표 결과_2008" // 시군구 단위로 되어있음, -> 일단 지역구 의원만 

order num sgId sgTypecode sdName wiwName sggName 
rename sdName sido_nm 
rename wiwName sigungu_nm 

drop hbj* 

replace sigungu_nm = strtrim(sigungu_nm)
replace sido_nm = strtrim(sido_nm)
replace sggName = strtrim(sggName)
********************* 행정구역 - 시군구에 맞춰서 drop,keep 
* 1) sido_nm이 "합계"인 행만 삭제
drop if sido_nm == "합계"

* 2) sido_nm과 sigungu_nm이 둘 다 "합계"인 행 삭제
drop if sido_nm == "합계" & sigungu_nm == "합계"

* 3) 일단 지역구 의원만 
drop if sggName == "비례대표"

* 4) 연도변수 추가 
gen year = substr(sgId, 1, 4)
destring year, replace

tab year // 선거아닌 연도 -> 재보궐 
keep if year ==2008 | year == 2012 | year ==2016 | year == 2020 | year == 2024
********************** 지역 명칭변경 
****** 1) 인천광역시 남구 -> 미추홀구로 명칭변경  (명칭변경)
replace sigungu_nm = "미추홀구" if sido_nm=="인천광역시" & sigungu_nm == "남구"

****** 2) 연기군 -> 세종으로 통합되면서 연기군 폐지 (연기군 삭제, 세종특별자치시 삭제)
drop if sigungu_nm == "연기군"

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

******************************** 여기부터 
* 총선의 경우 선거구별로 정당 통합이 안되어있음 
* 1) 거대양당 둘다 존재하는 선거구 
* 2) 거대 보수당 + 다른 군소정당 or 무소속
* 3) 거대 진보당 + 다른 군소정당 or 무소속

* 1) 
* 정당번호 순서대로 
* 2008년: 통합민주당 / 한나라당 
* 2012년: 새누리당 / 민주통합당 
* 2016년: 새누리당 / 더불어민주당 
* 2020년 더불어민주당 / 미래통합당 
* 2024년: 더불어민주당 / 국민의힘

* 2008년 현황 
tab year if jd01 != "통합민주당" & year==2008 // 거대 진보정당 후보 없는 지역 
tab year if jd02 != "한나라당" & year == 2008  // 거대 보수정당 후보 없는 지역 

br if jd01 != "통합민주당" & & jd02 != "한나라당" & year==2008 // 경상도, 부산, 울산, 대구, 소수 경기도+ 충청도  

br if year == 2008 & sido_nm=="광주광역시"  // 전라북도, 전라남도, 광주광역시 모두 양당 후보자체는 다 나옴 

* 2012년 현황 
tab year if jd01 != "새누리당" & year==2012 // 거대 진보정당 후보 없는 지역 
tab year if jd02 != "민주통합당" & year == 2012  // 거대 보수정당 후보 없는 지역 

br if jd01 != "새누리당" & year == 2012 
br if jd02 != "민주통합당" & year == 2012 

* 2016년 현황 
tab year if jd01 != "새누리당" & year==2016 // 거대 진보정당 후보 없는 지역 
tab year if jd02 != "더불어민주당" & year == 2016  // 거대 보수정당 후보 없는 지역 

br if jd01 != "새누리당" & year == 2016
br if jd02 != "더불어민주당" & year == 2016 

* 2012년 현황 
tab year if jd01 != "새누리당" & year==2012 // 거대 진보정당 후보 없는 지역 
tab year if jd02 != "민주통합당" & year == 2012  // 거대 보수정당 후보 없는 지역 

br if jd01 != "새누리당" & year == 2012 
br if jd02 != "민주통합당" & year == 2012 

********************* 1) 특별시/ 광역시 
* 특별시/광역시 중에서 sigungu_nm이 "합계"인 행 삭제
drop if (strpos(sido_nm, "특별시") > 0 | ///
         strpos(sido_nm, "광역시") > 0 | ///
         strpos(sido_nm, "특별자치시") > 0) & ///
        sigungu_nm == "합계"

* 특별시/광역시 중에서 선거구 분구되어있는 구는 합친 행 만들어야 하고 관측치 확인 
*********************************************
*** 특별시/광역시 케이스
*********************************************
** case 1) 시군구 그대로 -> 선거구 
** case 2) 시군구에서 -> 갑/을 분구 

* 선거구가 분구된 구 (갑/을/병 등) 통합
* 예: 성동구갑, 성동구을 → 성동구

local varlist sunsu tusu yutusu mutusu gigwonsu dugsu*

* 1) 선거구 표시 제거한 구 이름 변수 생성
gen gu_base = sigungu_nm

* 갑/을/병/정/무 제거
foreach suffix in "갑" "을" "병" "정" "무" {
    replace gu_base = subinstr(gu_base, "`suffix'", "", .) if ///
        (strpos(sido_nm, "특별시") > 0 | ///
         strpos(sido_nm, "광역시") > 0 )
}

* 2) 특별시/광역시에서 구 단위로 collapse
preserve
keep if strpos(sido_nm, "특별시") > 0 | ///
        strpos(sido_nm, "광역시") > 0 

collapse (sum) `varlist' (first) jd* sgId sgTypecode, by(sido_nm gu_base year)
rename gu_base sigungu_nm

tempfile metro_cities
save `metro_cities'
restore

* 3) 원본에서 특별시/광역시 삭제
drop if strpos(sido_nm, "특별시") > 0 | ///
        strpos(sido_nm, "광역시") > 0 

* 4) 통합된 특별시/광역시 데이터 append
append using `metro_cities'

* 5) gu_base 변수 삭제
drop gu_base

* 6) 특별시/광역시 연도별 관측치 확인
* 방법 1: 각 특별시/광역시별로 연도별 관측치
tab sido_nm year if strpos(sido_nm, "특별시") > 0 | ///
                    strpos(sido_nm, "광역시") > 0 

// 서울 25, 인천10, 광주5, 대전5, 대구8, 부산16, 울산5 이어야함 
******************************************
*** 일반 시/도 (세종 제외) 케이스 
******************************************
drop if strpos(sido_nm, "도") > 0 & sigungu_nm == "합계"

** case 1) 시군구는 ~시, 선거구는 ~시 갑/을 => 갑+을 숫자 합치기 
** case 2) 시군구는 ~시~구, 선거구는 ~시~구 갑/을 => 시 단위까지 모두 합치기 
** case 3) 시군구는 ~시~구, 선거구는 ~시~구 => 시 단위까지 모두합치기 
** case 4) 시군구는 ~시, 선거구는 ~시 => 이건 그대로 따로 수정x
** case 5) 시군구는 ~시/~군, 선거구는 통합된 지역(ex: 태백시정월군영월군) => 이건 그대로 따로 수정x

drop if strpos(sido_nm, "도") > 0 & sigungu_nm == "합계"

local sum_vars sunsu tusu yutusu mutusu gigwonsu
unab dugsu_vars : dugsu*
local varlist `sum_vars' `dugsu_vars'

* 확인
di "`varlist'"

* =================================================================
* Case 1) sigungu_nm은 ~시 (구가 없음), sggName은 ~시갑/을
*         => 갑+을 합치기
* 예: 의정부시 - 의정부시갑, 의정부시 - 의정부시을 → 의정부시
* =================================================================

preserve
keep if strpos(sido_nm, "도") > 0 & ///
        strpos(sigungu_nm, "구") == 0 & ///
        sigungu_nm != "" & ///
        (strpos(sggName, "갑") > 0 | ///
         strpos(sggName, "을") > 0 | ///
         strpos(sggName, "병") > 0 | ///
         strpos(sggName, "정") > 0 | ///
         strpos(sggName, "무") > 0)

* 확인
count
di "Case 1 대상: " r(N) "개 관측치"
list sido_nm sigungu_nm sggName in 1/10

collapse (sum) `varlist' (first) jd* sgId sgTypecode, by(sido_nm sigungu_nm year)

tempfile case1
save `case1'
restore

* 원본에서 case1 해당 행 삭제
drop if strpos(sido_nm, "도") > 0 & ///
        strpos(sigungu_nm, "구") == 0 & ///
        sigungu_nm != "" & ///
        (strpos(sggName, "갑") > 0 | ///
         strpos(sggName, "을") > 0 | ///
         strpos(sggName, "병") > 0 | ///
         strpos(sggName, "정") > 0 | ///
         strpos(sggName, "무") > 0)

append using `case1'

* ================================================================
* Case 2 & 3) sigungu_nm은 ~시~구 
*             => 시 단위로 모두 합치기
* 예: 수원시장안구, 수원시권선구 → 수원시
* =================================================================

* Step 1: ~시~구에서 시 이름만 추출
gen city_name = ""

* ~시~구 패턴 찾기 (예: 수원시장안구 → 수원시)
replace city_name = substr(sigungu_nm, 1, strpos(sigungu_nm, "시")) ///
    if strpos(sido_nm, "도") > 0 & ///
       strpos(sigungu_nm, "시") > 0 & ///
       strpos(sigungu_nm, "구") > 0

* Step 2: 합산값 계산 (검증용)
foreach var of local varlist {
    gen `var'_check23 = .
}


levelsof sido_nm if strpos(sido_nm, "도") > 0, local(sido_list)
foreach sido of local sido_list {
    levelsof city_name if city_name != "" & sido_nm == "`sido'", local(city_list)
    
    foreach city of local city_list {
        foreach yr in 2008 2012 2016 2020 2024 {
            foreach var of local varlist {
                quietly summarize `var' if sido_nm == "`sido'" & ///
                                            city_name == "`city'" & ///
                                            year == `yr'
                local expected_`var' = r(sum)
            }
        }
    }
}

* Step 3: ~시~구 형태만 collapse
preserve
keep if city_name != ""

collapse (sum) `varlist' (first) jd* hbj* sgId sgTypecode, by(sido_nm city_name year)
rename city_name sigungu_nm

* 검증값 표시
foreach var of local varlist {
    gen `var'_check23 = `var'
}

tempfile case23
save `case23'
restore

* Step 4: 원본에서 case2,3 해당 행 삭제
drop if city_name != ""

* Step 5: case2,3 데이터 append
append using `case23'

* Step 6: Case 2&3 검증
di "==============================="
di "Case 2&3 검증"
di "==============================="
local case23_ok 1
foreach var of local varlist {
    count if `var'_check23 != . & abs(`var' - `var'_check23) > 0.01
    if r(N) > 0 {
        di "  ❌ `var' 불일치 발견"
        local case23_ok 0
    }
    drop `var'_check23
}
if `case23_ok' == 1 di "  ✅ Case 2&3 모든 변수 일치"

* Step 7: 임시 변수 삭제
drop city_base city_name

* 최종 확인
di "==============================="
di "경기도 2008년 확인"
di "==============================="
tab sigungu_nm if sido_nm == "경기도" & year == 2008

di "==============================="
di "전체 통합 결과"
di "==============================="
if `case1_ok' == 1 & `case23_ok' == 1 {
    di "  ✅ 모든 케이스 검증 통과"
}
else {
    di "  ⚠️ 일부 케이스 검증 실패 - 확인 필요"
}

				
* 디버깅: 어떤 데이터가 있는지 확인
br sido_nm sigungu_nm sggName city_base if strpos(sido_nm, "도") > 0 & year == 2008

* Case 1 조건 확인
* 1) ~도 지역
count if strpos(sido_nm, "도") > 0
di "~도 지역: " r(N)

* 2) sigungu_nm이 ~시로 끝나는 경우
count if strpos(sido_nm, "도") > 0 & substr(sigungu_nm, -1, 1) == "시"
di "~시로 끝나는 경우: " r(N)

* 3) sggName에 갑/을이 있는 경우
count if strpos(sido_nm, "도") > 0 & ///
         (strpos(sggName, "갑") > 0 | ///
          strpos(sggName, "을") > 0 | ///
          strpos(sggName, "병") > 0 | ///
          strpos(sggName, "정") > 0 | ///
          strpos(sggName, "무") > 0)
di "sggName에 갑/을 있는 경우: " r(N)

* 4) 두 조건 모두 만족
count if strpos(sido_nm, "도") > 0 & ///
         substr(sigungu_nm, -1, 1) == "시" & ///
         (strpos(sggName, "갑") > 0 | ///
          strpos(sggName, "을") > 0 | ///
          strpos(sggName, "병") > 0 | ///
          strpos(sggName, "정") > 0 | ///
          strpos(sggName, "무") > 0)
di "두 조건 모두: " r(N)

* 실제 예시 확인
list sido_nm sigungu_nm sggName city_base if strpos(sido_nm, "경기도") > 0 & ///
                                             year == 2008 in 1/20
