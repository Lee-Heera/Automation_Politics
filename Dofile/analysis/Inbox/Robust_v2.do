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

global fixed i.year 
global control aged_share college_share 
global additional immi_share manu_share 

*******************************************************************************
* controlling for pretrend 용 변수 
* SD pretrend: 각 코호트의 직전 SD값 (bysort로 lag)
foreach v in SD_conserv1_p SD_conserv2_p SD_turnout {
    bysort regioncode (year): gen pre_`v' = `v'[_n-1]
    label variable pre_`v' "Pretrend `v' for SD (prev cohort SD)"
}


cd "$main/Output/table/0517"
*******************************************************************************
* IV validity 
*******************************************************************************
* First-stage relationship 
gen sample= (year>=2007 & year<=2017)
est clear 
xtreg X_SD2005  IV_SD2005 if sample==1, cluster(regioncode) fe // region FE 
est store fir1 

xtreg X_SD2005  IV_SD2005  $fixed if sample==1 , cluster(regioncode) fe // year FE 
est store fir2 

xtreg X_SD2005 IV_SD2005 $fixed $control if sample==1 , cluster(regioncode) fe // control 추가 
est store fir3 

esttab fir* using "valid_first.csv", replace ///
    mtitles("(1)" "(2)" "(3)") ///
    mgroups("First-stage", pattern(1 0)) ///
    stats(N F r2, fmt(0 3) labels("Observations" "F-statistics" "R-squared")) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap
	
* Pretrend check 
est clear 

reg pre_SD_turnout IV_SD2005  if year==2007, cluster(regioncode) 
est store pre1
reg pre_SD_conserv1_p IV_SD2005 if year==2007, cluster(regioncode) 
est store pre2

// control 추가 
reg pre_SD_turnout IV_SD2005 $control  if year==2007 , cluster(regioncode) 
est store pre7
reg pre_SD_conserv1_p IV_SD2005 $control  if year==2007, cluster(regioncode)
est store pre8
	
esttab pre* using "valid_pretrend.csv", replace ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    mgroups("Pretrend check", pattern(1 0)) ///
    stats(N F r2, fmt(0 3) labels("Observations" "F-statistics" "R-squared")) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 
	
* balance test 
reg IV_SD2005 aged_share college_share immi_share manu_share2 if year==2007, cluster(regioncode)


*******************************************************************************
* Robustness check 
*******************************************************************************
* Additional controls 
est clear 
// add controls 
xi: xtivreg2 SD_turnout  $fixed $control $additional (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe 
est store m1

xi: xtivreg2 SD_conserv1_p $fixed $control $additional (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe
est store m2

xi: xtivreg2 SD_turnout  $fixed $control $additional pre_SD_turnout (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe 
est store m3

xi: xtivreg2 SD_conserv1_p $fixed $control $additional pre_SD_conserv1_p (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe
est store m4

esttab m* using "robust_addtional.csv", replace ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    mgroups("Robustness_additional", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 

/*
ivreg2 SD_conserv1_p_1217 (X_SD2005  = IV_SD2005) if year==2012, ///
cluster(regioncode) robust first

ivreg2 SD_conserv1_p_1722 (X_SD2005  = IV_SD2005) if year==2017, ///
cluster(regioncode) robust first
*/

	/*
* alternative two-party vote share 
est clear 

xi: xtivreg2 SD_conserv2_p $fixed $control (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe
est store m1

xi: xtivreg2 SD_conserv2_p $fixed $control $additional (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe
est store m2

xi: xtivreg2 SD_conserv2_p $fixed $control $additional pre_SD_conserv2_p (X_SD2005  = IV_SD2005) if sample==1, ///
cluster(regioncode) robust first fe
est store m3

esttab m*,  stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) 
	


esttab m* using "main2.csv", ///
	replace /// 
	mgroups("Main2", pattern(1 0)) ///
    stats(N r2 cdf widstat arf arfp, fmt(0 3)) ///
    b(%8.3f) se(%8.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nogap 

*/
