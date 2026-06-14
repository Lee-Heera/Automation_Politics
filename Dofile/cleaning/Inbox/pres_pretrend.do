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

keep year regioncode sido_nm sigungu_nm X_SD Z_SD D_conserv1_p_0207 D_conserv2_p_0207 D_turnout_0207 aged_share_SD college_share_SD immi_share_SD mfg_share_SD

keep if year==2007 

global SD aged_share_SD college_share_SD 

*****************************************************************************
**** pretrend check 
est clear 

reg D_turnout_0207 X_SD $SD, ///
    cluster(regioncode)
est store pre1

reg D_conserv1_p_0207 X_SD $SD , cluster(regioncode)
est store pre2

reg D_conserv2_p_0207 X_SD $SD, ///
    cluster(regioncode)
est store pre3
	
esttab pre* , nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

***** Singapore exposure 
est clear 

reg D_turnout_0207 Z_SD  
est store pre1
reg D_conserv1_p_0207 Z_SD 
est store pre2
reg D_conserv2_p_0207 Z_SD
est store pre3

reg D_turnout_0207 Z_SD , cluster(regioncode)
est store pre4
reg D_conserv1_p_0207 Z_SD , cluster(regioncode)
est store pre5
reg D_conserv2_p_0207 Z_SD , cluster(regioncode)
est store pre6

reg D_turnout_0207 Z_SD $SD , cluster(regioncode)
est store pre7
reg D_conserv1_p_0207 Z_SD $SD, cluster(regioncode)
est store pre8
reg D_conserv2_p_0207 Z_SD $SD, cluster(regioncode)
est store pre9
	

esttab pre* , nogap stats(N r2 widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 
*****************************************************************************
******************** Figure ******************** 
reg D_conserv1_p_0207 X_SD $SD , cluster(regioncode)

graph twoway (lfit  D_conserv1_p_0207 X_SD) (scatter D_conserv1_p_0207 X_SD)

binscatter D_conserv1_p_0207 X_SD, ///
    nquantiles(20) ///
    title("Pre-trend Check: Robot Exposure and Past Voting Change") ///
    xtitle("Robot Exposure (residual, 2007-2012)") ///
    ytitle("Δ Conservative Vote Share (residual, 2002-2007)") ///
    note("Slope: " %5.3f beta " (SE: " %5.3f se ")" ///
         "Covariates partialed out: aged share, college share." ///
         "Standard errors clustered at region level." ///
         "Following Acemoglu and Restrepo (2020).")
		 
******************** Figure ******************** 
reg D_turnout_0207 X_SD $SD , cluster(regioncode)
binscatter D_conserv1_p_0207 X_SD, ///
    nquantiles(20) ///
    title("Pre-trend Check: Robot Exposure and Past Voting Change") ///
    xtitle("Robot Exposure (residual, 2007-2012)") ///
    ytitle("Δ Conservative Vote Share (residual, 2002-2007)") ///
    note("Slope: " %5.3f beta " (SE: " %5.3f se ")" ///
         "Covariates partialed out: aged share, college share." ///
         "Standard errors clustered at region level." ///
         "Following Acemoglu and Restrepo (2020).")
    
graph export "$final/pretrend_binscatter.png", replace
