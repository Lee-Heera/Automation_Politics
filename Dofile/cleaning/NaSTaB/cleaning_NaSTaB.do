**********************************************************************  
* Robot and automation
* Singapore Employment Statistics clean do-file
**********************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global raw "${main}/Data raw"
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
	
********************************************************************** 
**** STEP1: 각 차수별 데이터 불러와서 가구+가구원 merge 
local year "09 10 11 12 13 14 15 16 17" 
local real_year 2016 

foreach y of local year{
	* 가구에 지역정보 포함된 데이터 (가구 레벨)
	use "$raw/NaSTaB/region/NaSTaB`y'H_region.dta", clear
	
	tempfile hdata 
	
	save `hdata'
	
	* 가구원 데이터 
	use "$raw/NaSTaB/Person/NaSTaB`y'P.dta", clear
	tempfile pdata 
	
	save `pdata'
	
	* 가구데이터 + 가구원데이터 머지 
	use `hdata', clear
	merge 1:m hid`y' using `pdata'
	
	keep if _merge==3 
	
	save "$interim/NaSTaB/NaSTaB_`y'.dta", replace 
	
	local real_year = `real_year' + 1 
}
**********************************************************************
***** STEP2: 각 데이터 Append -> Long type data (panel) 
clear 
set more off 

cd "$interim/NaSTaB"

capture erase "NaSTaB_long.dta"   // 이전 실행 결과가 남아있으면 깨끗이 지우고 시작

forvalues y = 9/17 {
    local wave = string(`y', "%02.0f")       // 09, 10, ..., 17
    local surveyyear = `y' + 2007            // 09->2016, 17->2024

    use "NaSTaB_`wave'.dta", clear

    * prefix + wave 형태의 변수명을 prefix로 통일
    foreach prefix in w h p hid pid hs ps pw p_ {
        capture unab vars : `prefix'`wave'*
        if !_rc {
            foreach var of local vars {
                local newname = subinstr("`var'", "`prefix'`wave'", "`prefix'", .)
                rename `var' `newname'
            }
        }
    }

    * hdf038이 존재하고 numeric이면 string으로 변환
    capture confirm variable hdf038
    if !_rc {
        capture confirm numeric variable hdf038
        if !_rc {
            tostring hdf038, replace force
        }
    }

    gen year = `surveyyear'
    order year hid pid

    if `y' == 9 {
        save "NaSTaB_long.dta", replace       // 첫 wave는 새로 저장
    }
    else {
        append using "NaSTaB_long.dta"        // 이후 wave는 누적
        save "NaSTaB_long.dta", replace
    }
}
// obs = 106,113 (09차~17차)
**********************************************************************
***** STEP3: variable cleaning 

* outcome variable 
local vars pga001 pga003 pga004 pga005 pga006 pga007 pga008 pga009 pga010 pga011 ///
			pga020 pga030 pga040 ///
			pgb001 pgb020 pgb030 ///
			pgb050 pgb060 pgb070 pgb080 ///
			pgb090 pgb100 pgb110 pgb120

misstable summarize `vars'


* control variable 
* 1) gender - female =1 , male =0 
tab pwgen, m  // 1: 남, 2: 여, (결측없음)
gen female = pwgen-1
tab pwgen 

* 2) age - continuous variable 
tab pwbyr, m  // 출생연도 (결측없음)
gen age = year - pwbyr 
tab age

* 3) education level - 4년제 대졸이상 / 대졸미만 
tab pwedu, m // 모름/무응답 -> 결측처리 
// -9: 모름무응답 
// 1 미취학, 무학 ~ 5: 대학교 (4년제미만)
// 6: 4년제 대학 ~ 8: 박사 

gen edu =.  if pwedu == -9 
replace edu = 0 if pwedu >=1 & pwedu <=5 
replace edu = 1 if pwedu >=6 & pwedu <=8 // 4년제대졸자 이상 

tab pwedu, m 
tab edu, m 
