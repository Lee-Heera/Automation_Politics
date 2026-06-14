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
use "$final/Final_president.dta"

tab year // 2007, 2012, 2017, 2022 

sort regioncode year 
xtset regioncode year  // 
*******************************************************************************
* construct the migration share 
gen migra_share = pop_migra/pop

bysort regioncode (year): gen SD_migra = migra_share[_n+1] - migra_share
// 2012년 share - 2007년 share

order year regioncode sido_nm sigungu_nm 
global fixed i.year 
global control aged_share college_share 
global additional immi_share manu_share 

encode sido_nm, generate(sido_id)

gen sample = 1 if year>=2007 & year<=2017 
*******************************************************************************
* 이질성 더미 
* the share of immigrant 
qui summarize immi_share if year == 2007, detail
scalar median_2007 = r(p50)

gen high_temp = (immi_share >= median_2007) if year == 2007

bysort regioncode: egen high_immi = max(high_temp)
drop high_temp

* the share of manufacturing 
qui summarize manu_share if year == 2007, detail
scalar median_2007 = r(p50)

gen high_temp = (manu_share >= median_2007) if year == 2007

bysort regioncode: egen high_manu = max(high_temp)
drop high_temp

* the share of migration 
qui summarize migra_share if year==2007, detail 
scalar median_2007 = r(p50)

gen high_temp = (migra_share >= median_2007) if year == 2007

bysort regioncode: egen high_migra = max(high_temp)
drop high_temp

*************************Summary statistics **********************************
cd "$main/Output/table/0607"

local outvars  SD_turnout SD_conserv1_p
local xvars    X_SD2005 IV_SD2005 
local xvars_mfg X_SD2005_mfg IV_SD2005_mfg 
local controls aged_share college_share

estpost summarize `outvars' `xvars' `controls' if sample == 1

esttab using "summary.csv", ///
    title("Summary Statistics") ///
    cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3)) count(fmt(0))") ///
    collabels("Mean" "SD" "Min" "Max" "N") replace 

*******************************************************************************
********************** Panel A: OLS ********************** no fixed effect 
est clear

xi:reg SD_turnout X_SD2005 if sample==1, ///
 vce(cluster regioncode)
est store ols1 

xi:reg SD_conserv1_p X_SD2005 if sample==1, ///
vce(cluster regioncode)
est store ols2 

esttab ols* using "main1.csv", replace ///
    mtitles("Turnout" "Conservatism") ///
    mgroups("Panel A: OLS", pattern(1 0)) ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
********************** Panel B: FE ********************** regionFE, yearFE
xi: xtivreg2  SD_turnout $fixed X_SD2005  if sample==1, ///
cluster(regioncode) robust first fe 
est store fixed1

xi: xtivreg2  SD_conserv1_p $fixed X_SD2005 if sample==1, ///
cluster(regioncode) robust first fe 
est store fixed2

esttab fixed1 fixed2 using "main1.csv", ///
    append mgroups("Panel B: Fixed Effects", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
	
********************** Panel C: FEIV **********************region FE, year FE 
xi: xtivreg2 SD_turnout  $fixed (X_SD2005=IV_SD2005)  if sample==1, ///
cluster(regioncode) robust first fe
est store m1

xi: xtivreg2 SD_conserv1_p $fixed (X_SD2005=IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe 
est store m2

esttab m* using "main1.csv", ///
	append /// 
	mgroups("Panel C: FE-IV", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
	
// esttab ols*, nogap stats(N cdf widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)
**************************** Main Table 2) **************************************
est clear 
// add controls 
xi: xtivreg2 SD_turnout  $fixed $control (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe 
est store m1

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe
est store m2
// only competitive region 
xi: xtivreg2 SD_turnout  $fixed $control (X_SD2005  = IV_SD2005) if sample==1&dum_competitive1==1, ///
cluster(regioncode) robust first fe
est store m4

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005  = IV_SD2005) if sample==1&dum_competitive1==1 , ///
cluster(regioncode) robust first fe 
est store m5 

esttab m* using "main2.csv", ///
	replace /// 
	mgroups("Main2", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
*****************************************************************************
***************************** 이질성 분석 ****************************
* immigration 
est clear 
 
xi: xtivreg2 SD_turnout $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_immi==1 , cluster(regioncode) robust first fe
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_immi==1, cluster(regioncode) robust first fe 
est store m2 

xi: xtivreg2 SD_turnout $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_immi==0, cluster(regioncode) robust first fe  
est store m3 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_immi==0, cluster(regioncode) robust first fe 
est store m4 

esttab m* using "hetero.csv", ///
	replace /// 
	mgroups("Heterogeneity", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
	
// esttab m*, nogap stats(N cdf widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 


* manufacturing
est clear 
 
xi: xtivreg2 SD_turnout $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_manu==1, cluster(regioncode) robust first fe 
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_manu==1, cluster(regioncode) robust first fe
est store m2 

xi: xtivreg2 SD_turnout $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_manu==0,cluster(regioncode) robust first fe  
est store m4 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005  = IV_SD2005) if sample==1&high_manu==0, cluster(regioncode) robust first fe
est store m5 

esttab m*, nogap stats(N cdf widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

esttab m* using "hetero.csv", ///
	append /// 
	mgroups("Heterogeneity", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 

***************************** 군소정당 포함 *******************************
est clear 
xi: xtivreg2 SD_turnout  $fixed (X_SD2005=IV_SD2005)  if sample==1, ///
cluster(regioncode) robust first fe
est store m1

xi: xtivreg2 SD_conserv2_p $fixed (X_SD2005=IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe 
est store m2

xi: xtivreg2 SD_conserv2_p $fixed $control (X_SD2005=IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe 
est store m3 

xi: xtivreg2 SD_conserv2_p $fixed (X_SD2005=IV_SD2005) if sample==1&dum_competitive2==1, ///
cluster(regioncode) robust first fe 
est store m4  // 군소정당 포함 + competitive region만 하면 안나옴 

xi: xtivreg2 SD_conserv2_p $fixed $control (X_SD2005=IV_SD2005) if sample==1&dum_competitive2==1, ///
cluster(regioncode) robust first fe 
est store m5  // 군소정당 포함 + competitive region만 하면 안나옴 

esttab m*, stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
*************************************************************************
* Manufacturing X, IV 
**************************************************************************
*************************Summary statistics **********************************
cd "$main/Output/table/0607"

local outvars  SD_turnout SD_conserv1_p
local xvars    X_SD2005 IV_SD2005 
local xvars_mfg X_SD2005_mfg IV_SD2005_mfg 
local controls aged_share college_share

estpost summarize `outvars' `xvars' `xvars_mfg' `controls' if sample == 1

esttab using "summary_mfg.csv", ///
    title("Summary Statistics") ///
    cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3)) count(fmt(0))") ///
    collabels("Mean" "SD" "Min" "Max" "N") replace 

*******************************************************************************
********************** Panel A: OLS ********************** no fixed effect 
est clear

xi:reg SD_turnout X_SD2005_mfg if sample==1, ///
 vce(cluster regioncode)
est store ols1 

xi:reg SD_conserv1_p X_SD2005_mfg if sample==1, ///
vce(cluster regioncode)
est store ols2 

esttab ols* using "main1_mfg.csv", replace ///
    mtitles("Turnout" "Conservatism") ///
    mgroups("Panel A: OLS", pattern(1 0)) ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
********************** Panel B: FE ********************** regionFE, yearFE
xi: xtivreg2  SD_turnout $fixed X_SD2005_mfg  if sample==1, ///
cluster(regioncode) robust first fe 
est store fixed1

xi: xtivreg2  SD_conserv1_p $fixed X_SD2005_mfg if sample==1, ///
cluster(regioncode) robust first fe 
est store fixed2

esttab fixed1 fixed2 using "main1_mfg.csv", ///
    append mgroups("Panel B: Fixed Effects", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
	
********************** Panel C: FEIV **********************region FE, year FE 
xi: xtivreg2 SD_turnout  $fixed (X_SD2005_mfg=IV_SD2005_mfg)  if sample==1, ///
cluster(regioncode) robust first fe
est store m1

xi: xtivreg2 SD_conserv1_p $fixed (X_SD2005_mfg=IV_SD2005_mfg) if sample==1, ///
cluster(regioncode) robust first fe 
est store m2

esttab m* using "main1_mfg.csv", ///
	append /// 
	mgroups("Panel C: FE-IV", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
	
// esttab ols*, nogap stats(N cdf widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)
**************************** Main Table 2) **************************************
est clear 
// add controls 
xi: xtivreg2 SD_turnout  $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1, ///
cluster(regioncode) robust first fe 
est store m1

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1, ///
cluster(regioncode) robust first fe
est store m2
// only competitive region 
xi: xtivreg2 SD_turnout  $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&dum_competitive1==1, ///
cluster(regioncode) robust first fe
est store m4

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&dum_competitive1==1 , ///
cluster(regioncode) robust first fe 
est store m5 

esttab m* using "main2_mfg.csv", ///
	replace /// 
	mgroups("Main2", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
*****************************************************************************
***************************** 이질성 분석 ****************************
* immigration 
est clear 
 
xi: xtivreg2 SD_turnout $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&high_immi==1 , cluster(regioncode) robust first fe
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&high_immi==1, cluster(regioncode) robust first fe 
est store m2 

xi: xtivreg2 SD_turnout $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&high_immi==0, cluster(regioncode) robust first fe  
est store m3 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&high_immi==0, cluster(regioncode) robust first fe 
est store m4 

esttab m* using "hetero_mfg.csv", ///
	replace /// 
	mgroups("Heterogeneity", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
	
// esttab m*, nogap stats(N cdf widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 


* manufacturing
est clear 
 
xi: xtivreg2 SD_turnout $fixed $control (X_SD2005_mfg = IV_SD2005_mfg) if sample==1&high_manu==1, cluster(regioncode) robust first fe 
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&high_manu==1, cluster(regioncode) robust first fe
est store m2 

xi: xtivreg2 SD_turnout $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&high_manu==0,cluster(regioncode) robust first fe  
est store m4 

xi: xtivreg2 SD_conserv1_p $fixed $control (X_SD2005_mfg  = IV_SD2005_mfg) if sample==1&high_manu==0, cluster(regioncode) robust first fe
est store m5 

esttab m*, nogap stats(N cdf widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

esttab m* using "hetero_mfg.csv", ///
	append /// 
	mgroups("Heterogeneity", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 

***************************** 군소정당 포함 *******************************
est clear 
xi: xtivreg2 SD_turnout  $fixed (X_SD2005_mfg=IV_SD2005_mfg)  if sample==1, ///
cluster(regioncode) robust first fe
est store m1

xi: xtivreg2 SD_conserv2_p $fixed (X_SD2005_mfg=IV_SD2005_mfg) if sample==1, ///
cluster(regioncode) robust first fe 
est store m2

xi: xtivreg2 SD_conserv2_p $fixed $control (X_SD2005_mfg=IV_SD2005_mfg) if sample==1, ///
cluster(regioncode) robust first fe 
est store m3 

xi: xtivreg2 SD_conserv2_p $fixed (X_SD2005_mfg=IV_SD2005_mfg) if sample==1&dum_competitive2==1, ///
cluster(regioncode) robust first fe 
est store m4  // 군소정당 포함 + competitive region만 하면 안나옴 

xi: xtivreg2 SD_conserv2_p $fixed $control (X_SD2005_mfg=IV_SD2005_mfg) if sample==1&dum_competitive2==1, ///
cluster(regioncode) robust first fe 
est store m5  // 군소정당 포함 + competitive region만 하면 안나옴 

esttab m*, stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 

