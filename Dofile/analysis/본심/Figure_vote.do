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
	global output "${main}/Output"
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

gen sample = (year>=2007 & year<=2017)
*******************************************************************************
* controlling for pretrend 용 변수 
* SD pretrend: 각 코호트의 직전 SD값 (bysort로 lag)
foreach v in SD_conserv1_p SD_conserv2_p SD_turnout {
    cap drop pre_`v'
    bysort regioncode (year): gen pre_`v' = `v'[_n-1]
    label variable pre_`v' "Pretrend `v' for SD (prev cohort SD)"
}


cd "$output/figure/0607"
************************** Pretrend check ******************************************
reg pre_SD_turnout IV_SD2005 if year==2007, cluster(regioncode)
local b1 : display %6.3f _b[IV_SD2005]
local p1 : display %5.3f 2*(1-normal(abs(_b[IV_SD2005]/_se[IV_SD2005])))
est store pre1

reg pre_SD_conserv1_p IV_SD2005 if year==2007, cluster(regioncode)
local b2 : display %6.3f _b[IV_SD2005]
local p2 : display %5.3f 2*(1-normal(abs(_b[IV_SD2005]/_se[IV_SD2005])))
est store pre2

quietly sum pre_SD_turnout if year==2007
local ylo1=r(min)+(r(max)-r(min))*0.05
quietly sum pre_SD_conserv1_p if year==2007
local ylo2=r(min)+(r(max)-r(min))*0.05
quietly sum IV_SD2005 if year==2007
local xhi=r(max)

twoway (scatter pre_SD_turnout IV_SD2005 if year==2007, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    pre_SD_turnout IV_SD2005 if year==2007, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Change in robot exposure") ytitle("{&Delta} Turnout") ///
         graphregion(color(white)) bgcolor(white)
graph export "scatter_pre_turnout.pdf", replace //width(2400)

twoway (scatter pre_SD_conserv1_p IV_SD2005 if year==2007, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    pre_SD_conserv1_p IV_SD2005 if year==2007, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Change in robot exposure") ytitle("{&Delta} Conservative two-party share") ///
         graphregion(color(white)) bgcolor(white)
graph export "scatter_pre_conserv.pdf", replace //width(2400)

/*
twoway (scatter pre_SD_turnout IV_SD2005 if year==2007, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    pre_SD_turnout IV_SD2005 if year==2007, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Change in robot exposure") ytitle("{&Delta} Turnout, 02{&rarr}07") ///
         text(`ylo1' `xhi' "coeff=`b1'" "p-value=`p1'", size(small) place(nw)) ///
         graphregion(color(white)) bgcolor(white)
graph export "scatter_pre_turnout.pdf", replace width(2400)

twoway (scatter pre_SD_conserv1_p IV_SD2005 if year==2007, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    pre_SD_conserv1_p IV_SD2005 if year==2007, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Change in robot exposure") ytitle("{&Delta} Conserv. Vote, 02{&rarr}07") ///
         text(`ylo2' `xhi' "coeff=`b2'" "p-value=`p2'", size(small) place(nw)) ///
         graphregion(color(white)) bgcolor(white)
graph export "scatter_pre_conserv.pdf", replace width(2400)
*/
************************** Pretrend check ******************************************
xtreg X_SD2005 IV_SD2005 $fixed $control if sample==1 , cluster(regioncode) fe
local b1 : display %6.3f _b[IV_SD2005]
local p1 : display %5.3f 2*(1-normal(abs(_b[IV_SD2005]/_se[IV_SD2005])))
est store fir1

************************** First-stage relationship ******************************************
twoway (scatter X_SD2005 IV_SD2005 if sample==1, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    X_SD2005 IV_SD2005 if sample==1, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Bartik IV exposure") ytitle("{&Delta} Robot exposure") ///
         graphregion(color(white)) bgcolor(white)
graph export "scatter_firststage.pdf", replace

************************** Results (reduced form) ******************************************
twoway (scatter SD_turnout IV_SD2005 if sample==1, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    SD_turnout IV_SD2005 if sample==1, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Bartik IV exposure") ytitle("{&Delta} Turnout") ///
         graphregion(color(white)) bgcolor(white)
graph export "scatter_result_turnout.pdf", replace

twoway (scatter SD_conserv1_p IV_SD2005 if sample==1, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    SD_conserv1_p IV_SD2005 if sample==1, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Bartik IV exposure") ytitle("{&Delta} Conservative two-party share") ///
         graphregion(color(white)) bgcolor(white)
graph export "scatter_result_conserv.pdf", replace

************************** First-stage / Results, FE & controls partialled out (binscatter) ******************************************
binscatter X_SD2005 IV_SD2005 if sample==1, absorb(regioncode) controls($fixed $control) ///
    xtitle("Bartik IV exposure (residual)") ytitle("{&Delta} Robot exposure (residual)") ///
    graphregion(color(white)) bgcolor(white)
graph export "binscatter_firststage.pdf", replace

binscatter SD_turnout IV_SD2005 if sample==1, absorb(regioncode) controls($fixed $control) ///
    xtitle("Bartik IV exposure (residual)") ytitle("{&Delta} Turnout (residual)") ///
    graphregion(color(white)) bgcolor(white)
graph export "binscatter_result_turnout.pdf", replace

binscatter SD_conserv1_p IV_SD2005 if sample==1, absorb(regioncode) controls($fixed $control) ///
    xtitle("Bartik IV exposure (residual)") ytitle("{&Delta} Conservative two-party share (residual)") ///
    graphregion(color(white)) bgcolor(white)
graph export "binscatter_result_conserv.pdf", replace

/*
*********************Main results*************************************
xi: xtivreg2 SD_turnout $fixed (X_SD2005=IV_SD2005) if sample==1, ///
    cluster(regioncode) robust first fe
local b1 : display %6.3f _b[X_SD2005]
local p1 : display %5.3f 2*(1-normal(abs(_b[X_SD2005]/_se[X_SD2005])))
est store m1

xi: xtivreg2 SD_conserv1_p $fixed (X_SD2005=IV_SD2005) if sample==1, ///
    cluster(regioncode) robust first fe
local b2 : display %6.3f _b[X_SD2005]
local p2 : display %5.3f 2*(1-normal(abs(_b[X_SD2005]/_se[X_SD2005])))
est store m2

quietly sum SD_turnout   if sample==1
local ylo1=r(min)+(r(max)-r(min))*0.05
quietly sum SD_conserv1_p if sample==1
local ylo2=r(min)+(r(max)-r(min))*0.05
quietly sum X_SD2005      if sample==1
local xhi=r(max)

twoway (scatter SD_turnout X_SD2005 if sample==1, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    SD_turnout X_SD2005 if sample==1, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Change in robot exposure") ytitle("{&Delta} Turnout") ///
         text(`ylo1' `xhi' "coeff=`b1'" "p-value=`p1'", size(small) place(nw)) ///
         graphregion(color(white)) bgcolor(white)
graph export "$main/Output/figure/scatter_iv_turnout.png", replace width(2400)

twoway (scatter SD_conserv1_p X_SD2005 if sample==1, msymbol(Oh) mcolor(navy%60) mlwidth(vthin)) ///
       (lfit    SD_conserv1_p X_SD2005 if sample==1, lcolor(black) lwidth(medthin)) ///
       , yline(0,lcolor(gs13)) xline(0,lcolor(gs13)) legend(off) ///
         xtitle("Change in robot exposure") ytitle("{&Delta} Conserv. Vote") ///
         text(`ylo2' `xhi' "coeff=`b2'" "p-value=`p2'", size(small) place(nw)) ///
         graphregion(color(white)) bgcolor(white)
graph export "$main/Output/figure/scatter_iv_conserv.png", replace width(2400)
*/	  
	  