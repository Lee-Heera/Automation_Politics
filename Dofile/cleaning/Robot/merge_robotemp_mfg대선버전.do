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
	
********************************************************************** 
use "$data/kor_empl_mfg.dta" 

merge m:1 newindcode using "$data/sgp_empl_mfg.dta" , nogen assert(3)

merge m:1 newindcode using "$data/IFR_robot_mfg.dta", nogen assert(3)

**********************************************************************
* 대선 연도와 구간에 맞춰서 만들기 
**********************************************************************
* STEP 1: ΔRobot 변수 생성
**********************************************************************
foreach ctr in kr sg {
    * LD
    gen drobot_`ctr'_0717_mfg = rb_`ctr'_manu2017 - rb_`ctr'_manu2007
    gen drobot_`ctr'_0722_mfg = rb_`ctr'_manu2022 - rb_`ctr'_manu2007

	* SD
    gen drobot_`ctr'_0712_mfg = rb_`ctr'_manu2012 - rb_`ctr'_manu2007
    gen drobot_`ctr'_1217_mfg = rb_`ctr'_manu2017 - rb_`ctr'_manu2012
    gen drobot_`ctr'_1722_mfg = rb_`ctr'_manu2022 - rb_`ctr'_manu2017
}

/*
count if drobot_kr_0712 < 0
tab newindcode if drobot_kr_0712 < 0 // 102, 108, 119 
di r(N)/121828 * 100 "%"

count if drobot_kr_1217 < 0
tab newindcode if drobot_kr_1217 < 0 // 102, 105, 108 
di r(N)/121828 * 100 "%"

count if drobot_kr_1722 < 0
tab newindcode if drobot_kr_1722 < 0 // 103, 110, 113 
di r(N)/121828 * 100 "%"

sum drobot_kr_*, detail 
*/
// 102: mining 
// 103: utility 
// 105: education, research, development 
// 108: textiles 
// 110: plastics and chemicals 
// 113: metal products 
// 119: wood and furniture 
**********************************************************************
* STEP 2: Bartik X / IV 계산
* X  = Σ_j share07_ij  × ΔRobot_kr_j / emp_j2007
* IV = Σ_j share95_ij  × ΔRobot_sg_j / sgp_empj2007
**********************************************************************
local specs  0717   0722   0712   1217   1722
local bases  2007   2007   2007   2012   2017

local n : word count `specs'

foreach base_emp in 2005 {
    forvalues i = 1/`n' {
        local sp : word `i' of `specs'
        local by : word `i' of `bases'

        * X (Korean shock, share & emp base = base_emp)
        gen _term = share`base_emp'_manu * drobot_kr_`sp'_mfg / emp_j`base_emp'_manu
        bysort year regioncode: egen _X = total(_term)
        drop _term
        gen X`base_emp'_`sp'_mfg = _X if year == `by'
        drop _X

        * IV (Singapore shock, share95 고정 / sgp_emp base = base_emp)
        gen _term = share95_manu * drobot_sg_`sp'_mfg / sgp_empj`base_emp'
        bysort year regioncode: egen _IV = total(_term)
        drop _term
        gen IV`base_emp'_`sp'_mfg = _IV if year == `by'
        drop _IV

        label variable X`base_emp'_`sp'_mfg  "Bartik X (manufacturing, base=`base_emp', `sp')"
        label variable IV`base_emp'_`sp'_mfg "Bartik IV SG (manufacturing, base=`base_emp', `sp')"
    }
}

duplicates drop year regioncode, force
keep if year==2007 | year==2012 | year==2017 | year==2022

* First difference -> stacked
foreach base_emp in 2005 {
    * X: 세 cohort 중 해당 행에 값 있는 것 하나로 합치기
    gen X_SD`base_emp'_mfg = .
    replace X_SD`base_emp'_mfg = X`base_emp'_0712_mfg if !missing(X`base_emp'_0712_mfg)
    replace X_SD`base_emp'_mfg = X`base_emp'_1217_mfg if !missing(X`base_emp'_1217_mfg)
    replace X_SD`base_emp'_mfg = X`base_emp'_1722_mfg if !missing(X`base_emp'_1722_mfg)

    * IV: 동일
    gen IV_SD`base_emp'_mfg = .
    replace IV_SD`base_emp'_mfg = IV`base_emp'_0712_mfg if !missing(IV`base_emp'_0712_mfg)
    replace IV_SD`base_emp'_mfg = IV`base_emp'_1217_mfg if !missing(IV`base_emp'_1217_mfg)
    replace IV_SD`base_emp'_mfg = IV`base_emp'_1722_mfg if !missing(IV`base_emp'_1722_mfg)

    label variable X_SD`base_emp'_mfg  "Bartik X SD (manufacturing, empbase=`base_emp')"
    label variable IV_SD`base_emp'_mfg "Bartik IV SD (manufacturing, empbase=`base_emp', SG)"
}

* Long difference 이름 변경
foreach base_emp in 2005 {
    * rename: X2005_0717_mfg → X_LD2005_0717_mfg
    rename X`base_emp'_0717_mfg  X_LD`base_emp'_0717_mfg
    rename X`base_emp'_0722_mfg  X_LD`base_emp'_0722_mfg
    rename IV`base_emp'_0717_mfg IV_LD`base_emp'_0717_mfg
    rename IV`base_emp'_0722_mfg IV_LD`base_emp'_0722_mfg

    label variable X_LD`base_emp'_0717_mfg  "Bartik X LD (manufacturing, 2007→2017, empbase=`base_emp')"
    label variable X_LD`base_emp'_0722_mfg  "Bartik X LD (manufacturing, 2007→2022, empbase=`base_emp')"
    label variable IV_LD`base_emp'_0717_mfg "Bartik IV LD (manufacturing, 2007→2017, empbase=`base_emp', SG)"
    label variable IV_LD`base_emp'_0722_mfg "Bartik IV LD (manufacturing, 2007→2022, empbase=`base_emp', SG)"
}

isid newindcode year regioncode 

keep year regioncode sido_nm sigungu_nm X_LD2005_0717_mfg IV_LD2005_0717_mfg X_LD2005_0722_mfg IV_LD2005_0722_mfg X2005_0712_mfg IV2005_0712_mfg X2005_1217_mfg IV2005_1217_mfg X2005_1722_mfg IV2005_1722_mfg X_SD2005_mfg IV_SD2005_mfg

duplicates drop year regioncode, force
tab year // 지역 229개씩 

isid year regioncode

save "$data/X_final_mfg.dta", replace
