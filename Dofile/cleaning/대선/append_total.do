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
use "$data/2007president_clean.dta" 

append using "$data/1992president_clean.dta"
append using "$data/1997president_clean.dta"
append using "$data/2002president_clean.dta"
append using "$data/2012president_clean.dta" 
append using "$data/2017president_clean.dta" 
append using "$data/2022president_clean.dta" 

tab year  


****************************** 지역코드 매치*************************	
merge m:1 sido_nm sigungu_nm year  using "$data/sigungu_code.dta"

/*
tab year if _merge==2 // 대선없는연도 
tab year if _merge==3 
*/

keep if _merge==3 
drop _merge 
tab year // 229 

isid regioncode year 

save "$interim/대선_개표/president_append.dta", replace 
**********************************************************************
* Turnout in share of registered votes 
**********************************************************************
gen turnout = 투표수 / 선거인수 // 1-turnout = 기권율 

**********************************************************************
* 정당 매핑 (1997~2022)
**********************************************************************
// 1992 민주자유당, 민주당, 통일국민당, 신정당, 대한정의당, 무소속김옥선, 무소속백기완 
// 1997 한나라당 새정치국민회의, 국민신당, 건설국민승리 
// 2002 한나라당 새천년민주당, 민주노동당 
// 2007 한나라당, 대통합민주신당, 무소속이회창, 민주노동당, 창조한국당 
// 2012 새누리당, 민주통합당 
// 2017 더불어민주당, 자유한국당, 국민의당, 바른정당, 정의당 
// 2022 더불어민주당, 국민의힘, 정의당

order sido_nm sigungu_nm year 선거인수 투표수 유효투표수 무효투표 기권 
*---------------------------------------------------------------------
* Version 1: 거대양당만
*---------------------------------------------------------------------
* 진보
gen liberal1_st = 0
replace liberal1_st = cond(missing(민주당), 0, 민주당) if year == 1992
replace liberal1_st = cond(missing(새정치국민회의), 0, 새정치국민회의) if year == 1997
replace liberal1_st = cond(missing(새천년민주당), 0, 새천년민주당) if year == 2002
replace liberal1_st = cond(missing(대통합민주신당), 0, 대통합민주신당) if year == 2007
replace liberal1_st = cond(missing(민주통합당), 0, 민주통합당) if year == 2012
replace liberal1_st = cond(missing(더불어민주당), 0, 더불어민주당) if inlist(year, 2017, 2022)

* 보수
gen conserv1_st = 0
replace conserv1_st = cond(missing(민주자유당), 0, 민주자유당) if year == 1992
replace conserv1_st = cond(missing(한나라당), 0, 한나라당) if inlist(year, 1997, 2002, 2007)
replace conserv1_st = cond(missing(새누리당), 0, 새누리당) if year == 2012
replace conserv1_st = cond(missing(자유한국당), 0, 자유한국당) if year == 2017
replace conserv1_st = cond(missing(국민의힘), 0, 국민의힘) if year == 2022
*---------------------------------------------------------------------
* 연도별 군소 정당 매핑
*---------------------------------------------------------------------
* 투표율 1% 이상인 군소정당과 무소속후보 남길것 
* 1992: 통일국민당 (보수), 신정당(보수) / 무소속백기완(진보)
* 1997: 국민신당(보수), 건설국민승리(진보) 
* 2002: 민주노동당(진보) 
* 2007: 무소속이회창(보수), 민주노동당, 창조한국당(진보)
* 2012: X 
* 2017: 바른정당, 국민의당(보수) // 정의당(진보) 
* 2022: 정의당(진보)
*---------------------------------------------------------------------
* Version 2: 군소정당/무소속 포함
*---------------------------------------------------------------------
// 군소정당 포함 (정의당/바른정당, 이회창)
gen liberal2_st = liberal1_st
gen conserv2_st = conserv1_st

* 진보 군소정당 추가
replace liberal2_st = liberal2_st + cond(missing(무소속백기완), 0, 무소속백기완) ///
if year == 1992 
replace liberal2_st = liberal2_st + cond(missing(건설국민승리), 0, 건설국민승리) ///
if year == 1997
replace liberal2_st = liberal2_st + cond(missing(민주노동당), 0, 민주노동당) ///
if year == 2002 
replace liberal2_st = liberal2_st + cond(missing(민주노동당), 0, 민주노동당) ///
                                  + cond(missing(창조한국당), 0, 창조한국당) ///
                                  if year == 2007

replace liberal2_st = liberal2_st + cond(missing(정의당), 0, 정의당) ///
if year == 2017 | year==2022 

* 보수 군소정당 추가
replace conserv2_st = conserv2_st + cond(missing(통일국민당), 0, 통일국민당) ///
								  +  cond(missing(신정당), 0, 신정당) ///
						          if year == 1992
replace conserv2_st = conserv2_st + cond(missing(국민신당), 0, 국민신당) /// 
if year == 1997
replace conserv2_st = conserv2_st + cond(missing(무소속이회창), 0, 무소속이회창) ///
if year == 2007
replace conserv2_st = conserv2_st + cond(missing(바른정당), 0, 바른정당) ///
								  +  cond(missing(국민의당), 0, 국민의당) ///
						          if year == 2017
								  
drop 대통합민주신당 한나라당 민주노동당 민주당 창조한국당 참주인연합 경제공화당 새시대참사람연합 한국사회당 무소속이회창 민주자유당 통일국민당 신정당 대한정의당 무소속김옥선 무소속백기완 새정치국민회의 국민신당 건설국민승리 공화당 바른정치연합 통일한국당 새천년민주당 하나로국민연합 사회당 호국당 새누리당 민주통합당 무소속박종선 무소속김소연 무소속강지원 무소속김순자 더불어민주당 자유한국당 국민의당 바른정당 정의당 경제애국당 국민대통합당 늘푸른한국당 민중연합당 한국국민당 홍익당 무소속김민찬 국민의힘 기본소득당 국가혁명당 노동당 신자유민주연합 우리공화당 진보당 한류연합당
*---------------------------------------------------------------------
* Vote Shares 계산
*-------------------------------------------------------------------
gen conserv1_p = conserv1_st / (conserv1_st + liberal1_st) 
gen conserv2_p = conserv2_st / (conserv2_st + liberal2_st) 
gen liberal1_p = liberal1_st / (conserv1_st + liberal1_st)
gen liberal2_p = liberal2_st / (conserv2_st + liberal2_st)

* Check
gen check = liberal1_p + conserv1_p
tab check 
assert abs(check - 1) < 0.0001 if !missing(check)

gen check2 = liberal2_p + conserv2_p
tab check2
assert abs(check2 - 1) < 0.0001 if !missing(check2)

drop check check2
************************************************************************
foreach yr in 1992 1997 2002 2007 2012 2017 2022 {
    preserve
    keep if year == `yr'
    keep regioncode conserv1_p conserv2_p turnout
    foreach var in conserv1_p conserv2_p  turnout {
        rename `var' `var'_`yr'
    }
    tempfile base`yr'
    save `base`yr''
    restore
    merge m:1 regioncode using `base`yr'', nogen
}	

*---------------------------------------------------------------------
* LD / SD 차분 변수 생성
*---------------------------------------------------------------------
local specs   0722   0717   9297  9702   0207   0712   1217   1722
local bases   2007   2007   1992  1997   2002   2007   2012   2017
local ends    2022   2017   1997  2002   2007   2012   2017   2022
local types   LD     LD     SD 	  SD     SD     SD     SD     SD

local n : word count `specs'
forvalues i = 1/`n' {
    local sp : word `i' of `specs'
    local by : word `i' of `bases'
    local en : word `i' of `ends'
    local tp : word `i' of `types'

    foreach v in conserv1_p conserv2_p turnout {
        gen `tp'_`v'_`sp' = `v'_`en' - `v'_`by' if year == `by'
        label variable `tp'_`v'_`sp' "`tp' `v' (`by'→`en')"
    }
}

*---------------------------------------------------------------------
* SD 합친 변수 (5개 구간 전부)
*---------------------------------------------------------------------
foreach v in conserv1_p conserv2_p turnout {
    gen SD_`v' = .
    foreach sp in 9297 9702 0207 0712 1217 1722 {
        replace SD_`v' = SD_`v'_`sp' if !missing(SD_`v'_`sp')
    }
    label variable SD_`v' "SD `v' (전구간: 9297/9702/0207/0712/1217/1722)"
}

********************************************************************
* Solid/Competitive 지역 더미
* 분석기간 2012-2022 기준, v1=거대양당, v2=군소정당포함
********************************************************************
foreach v in 1 2 {
    gen lib`v'_over55 = (liberal`v'_p > 0.55) ///
        if !missing(liberal`v'_p) & inlist(year, 2007, 2012, 2017, 2022)
    gen con`v'_over55 = (conserv`v'_p > 0.55) ///
        if !missing(conserv`v'_p) & inlist(year, 2007, 2012, 2017, 2022)

    bysort regioncode: egen solid_lib`v' = min(lib`v'_over55)
    bysort regioncode: egen solid_con`v' = min(con`v'_over55)

    gen dum_solid_lib`v'   = (solid_lib`v' == 1)
    gen dum_solid_con`v'   = (solid_con`v' == 1)
    gen dum_competitive`v' = (dum_solid_lib`v' == 0 & dum_solid_con`v' == 0)

    count if dum_solid_lib`v'==1 & dum_solid_con`v'==1  // 0이어야 함

    drop lib`v'_over55 con`v'_over55 solid_lib`v' solid_con`v'
}

**********************************************************************
* 변수 정리
drop 선거인수 투표수 유효투표수 무효투표 기권  liberal1_st conserv1_st liberal2_st conserv2_st  liberal1_p liberal2_p turnout_1992 conserv1_p_1992 conserv2_p_1992 turnout_1997 conserv1_p_1997 conserv2_p_1997 turnout_2002 conserv1_p_2002 conserv2_p_2002 turnout_2007 conserv1_p_2007 conserv2_p_2007 turnout_2012 conserv1_p_2012 conserv2_p_2012 turnout_2017 conserv1_p_2017 conserv2_p_2017 turnout_2022 conserv1_p_2022 conserv2_p_2022

compress
sort year regioncode

tab year // 229 
save "$data/Y_final.dta", replace 


/*
*---------------------------------------------------------------------
* Pre-trend differences
* Version 1: Stacked (시작연도 행에만 저장)
*---------------------------------------------------------------------
local pt_specs  9702   0207
local pt_bases  1997   2002
local pt_ends   2002   2007

local n : word count `pt_specs'
forvalues i = 1/`n' {
    local sp : word `i' of `pt_specs'
    local by : word `i' of `pt_bases'
    local en : word `i' of `pt_ends'

    foreach v in conserv1_p conserv2_p turnout {
        gen D_`v'_`sp' = `v'_`en' - `v'_`by' if year == `by'
        label variable D_`v'_`sp' "Pretrend `v' (`by'→`en'), stacked"
    }
}

* Stacked 합친 변수 (1997행/2002행)
foreach v in conserv1_p conserv2_p turnout {
    gen D_`v' = .
    replace D_`v' = D_`v'_9702 if !missing(D_`v'_9702)
    replace D_`v' = D_`v'_0207 if !missing(D_`v'_0207)
    label variable D_`v' "Pretrend `v' stacked (9702@1997, 0207@2002)"
}
*/
/*
*---------------------------------------------------------------------
* Version 2: Broadcast (모든 연도에 동일값 채움 → control 변수용)
* regioncode별 고정값, 회귀분석 control로 직접 투입
*---------------------------------------------------------------------
foreach v in conserv1_p conserv2_p turnout {
    * 9702: 1997→2002 차분값을 모든 연도에 broadcast
    bysort regioncode: egen bc_`v'_9702 = max(D_`v'_9702)
    label variable bc_`v'_9702 "Pretrend `v' (1997→2002), broadcast all years"

    * 0207: 2002→2007 차분값을 모든 연도에 broadcast
    bysort regioncode: egen bc_`v'_0207 = max(D_`v'_0207)
    label variable bc_`v'_0207 "Pretrend `v' (2002→2007), broadcast all years"
}
*/
/*
*---------------------------------------------------------------------
* Version 3: Matched pretrend (SD 코호트별 직전 구간 → robustness용)
* "controlling for pretrend" 회귀분석에서 SD_`v' 와 같은 행에 있어야 함
*
* cohort 1 base_year=2007: pretrend = 2002→2007 (D_`v'_0207)
* cohort 2 base_year=2012: pretrend = 2007→2012 (SD_`v'_0712)
* cohort 3 base_year=2017: pretrend = 2012→2017 (SD_`v'_1217)
*---------------------------------------------------------------------
foreach v in conserv1_p conserv2_p turnout {
    gen pre_SD_`v' = .
    replace pre_SD_`v' = D_`v'_0207    if year == 2007  // cohort1 직전: 2002→2007
    replace pre_SD_`v' = SD_`v'_0712   if year == 2012  // cohort2 직전: 2007→2012
    replace pre_SD_`v' = SD_`v'_1217   if year == 2017  // cohort3 직전: 2012→2017
    label variable pre_SD_`v' "Matched pretrend `v' (SD 코호트별 직전구간)"
}

* LD용 matched pretrend (base_year=2007, pretrend=2002→2007)
foreach v in conserv1_p conserv2_p turnout {
    gen pre_LD_`v' = D_`v'_0207 if year == 2007
    label variable pre_LD_`v' "Matched pretrend `v' for LD (2002→2007 @2007)"
}

sort year regioncode
*/
