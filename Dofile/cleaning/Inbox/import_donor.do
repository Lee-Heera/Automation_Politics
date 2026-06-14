cd "/Users/ihuila/Desktop/data/master thesis/raw/Donor/KA-money"

foreach f in ///
    "2012_KAPF" "2013_KAPF" "2014_KAPF" "2015_KAPF" ///
    "2016_KAPF-19" "2016_KAPF-20" "2017_KAPF" "2018_KAPF" ///
    "2019_KAPF" "2020_KAPF-20" "2020_KAPF-21" "2021_KAPF" ///
    "2022_KAPF" "2023_KAPF" "2023_KAPF_수입지출" ///
    "2024_KAPF-21" "2024_KAPF-21_수입지출" ///
    "2024_KAPF-22" "2024_KAPF-22_수입지출" {

    capture import excel "`f'.xlsx", firstrow clear
    if _rc != 0 {
        display "오류: `f'"
        continue
    }
	
    save "`f'.dta", replace
    display "완료: `f'"
}
 
pwd 
cd "/Users/ihuila/Desktop/data/master thesis/raw/Donor/KA-money"

* 각 파일 변수명 확인
foreach yr in 2012 2013 2014 2015 2017 2018 2019 2021 2022 2023 {
    use "`yr'_KAPF.dta", clear
    display "=== `yr' ==="
    describe
}

foreach yr_age in "2016 19" "2016 20" "2020 20" "2020 21" "2024 21" "2024 22" {
    local yr  : word 1 of `yr_age'
    local age : word 2 of `yr_age'
    use "`yr'_KAPF-`age'.dta", clear
    display "=== `yr'_KAPF-`age' ==="
    describe
}

* 각 파일 관측치 수 먼저 기록
local total_obs 0

foreach yr in 2012 2013 2014 2015 2017 2018 2019 2021 2022 2023 {
    use "`yr'_KAPF.dta", clear
    local n = _N
    local total_obs = `total_obs' + `n'
    display "`yr'_KAPF: `n'행"
}

foreach yr_age in "2016 19" "2016 20" "2020 20" "2020 21" "2024 21" "2024 22" {
    local yr  : word 1 of `yr_age'
    local age : word 2 of `yr_age'
    use "`yr'_KAPF-`age'.dta", clear
    local n = _N
    local total_obs = `total_obs' + `n'
    display "`yr'_KAPF-`age': `n'행"
}

display "=============================="
display "개별 파일 합계: `total_obs'행" // 1896608행
display "=============================="

use "2012_KAPF.dta", clear
gen year = 2012
gen Congera = 19

capture program drop clean_kapf
program define clean_kapf
    * 불필요한 변수 삭제
    capture drop L
    capture drop M

    * 총연번 통일
    capture rename 연번 총연번

    * 지출액 통일 (I가 지출액인 경우 - 2017)
    capture rename I 지출액
    capture rename 지출금회 지출액
    capture rename 지출 지출액

    * 사용처 통일
    capture rename 성명법인단체명 사용처
    capture rename 성명 사용처

    * 필요한 변수만 유지
    keep 총연번 의원번호 의원명 당 당ID 지역명 연월일 내역 지출액 사용처 분류 year Congera
end


clean_kapf

foreach yr in 2013 2014 2015 2017 2018 2019 2021 2022 2023 {
    preserve
        use "`yr'_KAPF.dta", clear
        if `yr' <= 2015 local age 19
        else if `yr' <= 2019 local age 20
        else local age 21
        gen year = `yr'
        gen Congera = `age'
        clean_kapf
        tempfile tmp
        save `tmp'
    restore
    append using `tmp'
    display "완료: `yr'_KAPF | Congera=`age'"
}

foreach yr_age in "2016 19" "2016 20" "2020 20" "2020 21" "2024 21" "2024 22" {
    local yr  : word 1 of `yr_age'
    local age : word 2 of `yr_age'
    preserve
        use "`yr'_KAPF-`age'.dta", clear
        gen year = `yr'
        gen Congera = `age'
        clean_kapf
        tempfile tmp
        save `tmp'
    restore
    append using `tmp'
    display "완료: `yr'_KAPF-`age' | Congera=`age'"
}

cd "/Users/ihuila/Desktop/data/master thesis/afterdonor"
save "politicianexpen_long.dta", replace
display "완료! 총 관측치: `=_N'" // 완료! 총 관측치: 1896608
***************************************************************
use "politicianexpen_long.dta", clear 

/*
cd "/Users/ihuila/Desktop/data/master thesis/raw/Donor/KA-money"
use "2016_KAPF-19.dta", clear 

br if 총연번 == ""
*/

compress 
br if 총연번 == ""

drop if 총연번 == ""
// 2016년 19대 국회에서 총연번이랑 다른 변수들 모두 비어있는 관측치 있음 -> 이거 삭제 

count if 총연번 == ""

save "politicianexpen_longclean.dta", replace 
***************************************************************
use  "politicianexpen_longclean.dta", clear 
keep if Congera == 20 
save "politicianexpen_longclean20.dta", replace  // 20대 국회 


use "politicianexpen_longclean.dta", clear 
keep if Congera == 21 
save "politicianexpen_longclean21.dta", replace  // 21대 국회 

use "politicianexpen_longclean.dta", clear 
keep if Congera == 22 
save "politicianexpen_longclean22.dta",replace // 22대 국회 
***************************************************************

