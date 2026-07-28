**********************************************************************
* Robot and automation
* Singapore Employment Statistics clean do-file
* 목적: Bartik X / IV 변수를 대선 연도(2007, 2012, 2017, 2022) 기준으로 생성
* 최종 산출물: X_final.dta (지역×연도 패널, 229개 시군구)
**********************************************************************
clear all

	* 경로 설정
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
* 데이터 로드 및 병합
* kor_empl: 한국 산업별 지역 고용 데이터
* sgp_empl: 싱가포르 산업별 고용 데이터 (IV용)
* IFR_robot: 국제로봇연맹(IFR) 산업별 로봇 밀도 데이터
**********************************************************************
use "$data/kor_empl.dta"

* 싱가포르 고용 데이터 병합 (IV 구성에 사용할 외국 로봇 충격)
merge m:1 newindcode using "$data/sgp_empl.dta" , nogen assert(3)

* IFR 로봇 스톡 병합 (산업코드 기준 m:1)
merge m:1 newindcode using "$data/IFR_robot.dta", nogen assert(3)
// IFR_robot1.dta

**********************************************************************
* 대선 연도와 구간에 맞춰서 만들기 
**********************************************************************
* STEP 1: ΔRobot 변수 생성
**********************************************************************
foreach ctr in kr sg {
    * LD
    gen drobot_`ctr'_0717 = rb_`ctr'2017 - rb_`ctr'2007
    gen drobot_`ctr'_0722 = rb_`ctr'2022 - rb_`ctr'2007
    
	* SD
    gen drobot_`ctr'_0712 = rb_`ctr'2012 - rb_`ctr'2007
    gen drobot_`ctr'_1217 = rb_`ctr'2017 - rb_`ctr'2012
    gen drobot_`ctr'_1722 = rb_`ctr'2022 - rb_`ctr'2017
}
**********************************************************************
* STEP 1-2: drobot만 따로 stacked SD 변수 생성 (Bartik 집계 X/IV 이전)
*  - X_SD2005/IV_SD2005와 동일한 cohort-year 매칭 방식
*    (2007행 <- 0712, 2012행 <- 1217, 2017행 <- 1722)
**********************************************************************
local sd_specs 0712 1217 1722
local sd_bases 2007 2012 2017
local n : word count `sd_specs'

foreach ctr in kr sg {
    gen drobot_`ctr'_SD = .
    forvalues i = 1/`n' {
        local sp : word `i' of `sd_specs'
        local by : word `i' of `sd_bases'
        replace drobot_`ctr'_SD = drobot_`ctr'_`sp' if year == `by'
    }
    label variable drobot_`ctr'_SD "Delta robot stock (`ctr', SD stacked: cohort 2007/2012/2017)"
}

* 음수 로봇 증감이 있는 산업 확인 (데이터 이상치 점검용)
br if drobot_kr_0712 < 0
//save "$data/X_final_beforeduplicates.dta" ,replace

**********************************************************************
* STEP 2: Bartik X / IV 계산
* X  = Σ_j share07_ij  × ΔRobot_kr_j / emp_j2007
* IV = Σ_j share95_ij  × ΔRobot_sg_j / sgp_empj2007
**********************************************************************
local specs  0717   0722   0712   1217   1722
local bases  2007   2007   2007   2012   2017

local n : word count `specs'

foreach base_emp in 2005{
    forvalues i = 1/`n' {
        local sp : word `i' of `specs'
        local by : word `i' of `bases'

        * X (Korean shock, share & emp base = base_emp)
        gen _term = share`base_emp' * drobot_kr_`sp' / emp_j`base_emp'
        bysort year regioncode: egen _X = total(_term)
		
        drop _term
        gen X`base_emp'_`sp' = _X if year == `by'
        drop _X

        * IV (Singapore shock, share95 고정 / sgp_emp base = base_emp)
        gen _term = share95 * drobot_sg_`sp' / sgp_empj`base_emp'
        bysort year regioncode: egen _IV = total(_term)
        drop _term
        gen IV`base_emp'_`sp' = _IV if year == `by'
        drop _IV

        label variable X`base_emp'_`sp'  "Bartik X (base=`base_emp', `sp')"
        label variable IV`base_emp'_`sp' "Bartik IV SG (base=`base_emp', `sp')"
    }
}

* 산업×지역×연도 → 지역×연도로 집계된 후 중복 제거
duplicates drop year regioncode, force
* 대선 직전 연도만 유지 (2007·2012·2017·2022)
keep if year==2007 | year==2012 | year==2017 | year==2022

* SD(Short Difference) stacked 방식: 각 cohort 첫 해 행에 해당 기간 충격을 할당
foreach base_emp in 2005 {
    * X: 세 cohort 중 해당 행에 값 있는 것 하나로 합치기
    gen X_SD`base_emp' = .
    replace X_SD`base_emp' = X`base_emp'_0712 if !missing(X`base_emp'_0712)
    replace X_SD`base_emp' = X`base_emp'_1217 if !missing(X`base_emp'_1217)
    replace X_SD`base_emp' = X`base_emp'_1722 if !missing(X`base_emp'_1722)

    * IV: 동일
    gen IV_SD`base_emp' = .
    replace IV_SD`base_emp' = IV`base_emp'_0712 if !missing(IV`base_emp'_0712)
    replace IV_SD`base_emp' = IV`base_emp'_1217 if !missing(IV`base_emp'_1217)
    replace IV_SD`base_emp' = IV`base_emp'_1722 if !missing(IV`base_emp'_1722)

    label variable X_SD`base_emp'  "Bartik X SD (empbase=`base_emp')"
    label variable IV_SD`base_emp' "Bartik IV SD (empbase=`base_emp', SG)"
}

* Long difference 이름 변경 
foreach base_emp in 2005{
    * rename: X2005_0717 → X_LD2005_0717
    rename X`base_emp'_0717  X_LD`base_emp'_0717
    rename X`base_emp'_0722  X_LD`base_emp'_0722
    rename IV`base_emp'_0717 IV_LD`base_emp'_0717
    rename IV`base_emp'_0722 IV_LD`base_emp'_0722

    label variable X_LD`base_emp'_0717  "Bartik X LD (2007→2017, empbase=`base_emp')"
    label variable X_LD`base_emp'_0722  "Bartik X LD (2007→2022, empbase=`base_emp')"
    label variable IV_LD`base_emp'_0717 "Bartik IV LD (2007→2017, empbase=`base_emp', SG)"
    label variable IV_LD`base_emp'_0722 "Bartik IV LD (2007→2022, empbase=`base_emp', SG)"
}

* 최종 저장 전 고유성 확인 (산업코드·연도·지역 조합이 유일해야 함)
isid newindcode year regioncode

* 회귀분석에 필요한 변수만 남기기 (LD: 장기차분, SD: 단기차분 stacked)
keep year regioncode sido_nm sigungu_nm X_LD2005_0717 IV_LD2005_0717 X_LD2005_0722 IV_LD2005_0722 X2005_0712 IV2005_0712 X2005_1217 IV2005_1217 X2005_1722 IV2005_1722 X_SD2005 IV_SD2005

duplicates drop year regioncode, force
tab year // 지역 229개씩

isid year regioncode

save "$data/X_final.dta", replace
