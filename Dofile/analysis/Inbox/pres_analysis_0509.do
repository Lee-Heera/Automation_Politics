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
xtset regioncode year // balanced panel 

order year regioncode sido_nm sigungu_nm 
global fixed i.year 
global LD2007 aged_share_2007 college_share_2007
global LD2012 aged_share_2012 college_share_2012
global SD aged_share_SD college_share_SD 

*******************************************************************************
********************** (LONG DIFFERENCE 2007-2022) ****************************
est clear  
ivreg2  LD_turnout_0722  $LD2007 (X_LD0722=Z_LD0722),cluster(regioncode) robust first
est store m1 

ivreg2  LD_conserv1_p_0722 $LD2007 (X_LD0722=Z_LD0722),cluster(regioncode) robust first
est store m2 

ivreg2  LD_conserv2_p_0722 $LD2007 (X_LD0722=Z_LD0722),cluster(regioncode) robust first
est store m3 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 
********************** (LONG DIFFERENCE 2012-2022) ****************************
est clear  
ivreg2  LD_turnout_1222  $LD2012 (X_LD1222=Z_LD1222),cluster(regioncode) robust first
est store m1 

ivreg2  LD_conserv1_p_1222 $LD2012 (X_LD1222=Z_LD1222),cluster(regioncode) robust first
est store m2 

ivreg2  LD_conserv2_p_1222 $LD2012 (X_LD1222=Z_LD1222),cluster(regioncode) robust first
est store m3 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 
********************** (Stacked difference 2007-2022) ************************
est clear 
xi: xtivreg2 SD_turnout $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD),fe cluster(regioncode) robust first
est store m1

xi: xtivreg2 SD_conserv1_p $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD),fe cluster(regioncode) robust first
est store m2

xi: xtivreg2 SD_conserv2_p $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD),fe cluster(regioncode) robust first
est store m3 

xi: xtivreg2 SD_turnout  (X_SD = Z_SD),fe cluster(regioncode) robust first
est store m4

xi: xtivreg2 SD_conserv1_p  (X_SD = Z_SD),fe cluster(regioncode) robust first
est store m5

xi: xtivreg2 SD_conserv2_p  (X_SD = Z_SD),fe cluster(regioncode) robust first
est store m6 

ivreg2  SD_turnout $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD), cluster(regioncode) robust first
est store m7

ivreg2  SD_conserv1_p $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD), cluster(regioncode) robust first
est store m8

ivreg2 SD_conserv2_p $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD), cluster(regioncode) robust first
est store m9 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 
********************** (Stacked difference 2012-2022) ************************
est clear 
xi: xtivreg2 SD_turnout $fixed $SD (X_SD = Z_SD) if year>=2012 & year<=2022,fe cluster(regioncode) robust first
est store m1

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD)  if year>=2012 & year<=2022 ,fe cluster(regioncode) robust first
est store m2

xi: xtivreg2 SD_conserv2_p $fixed $SD  (X_SD = Z_SD)  if year>=2012 & year<=2022 ,fe cluster(regioncode) robust first
est store m3 
esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

xi: xtivreg2 SD_turnout   (X_SD = Z_SD)  if year>=2012 & year<=2022 ,fe cluster(regioncode) robust first
est store m4

xi: xtivreg2 SD_conserv1_p  (X_SD = Z_SD)  if year>=2012 & year<=2022 ,fe cluster(regioncode) robust first
est store m5

xi: xtivreg2 SD_conserv2_p  (X_SD = Z_SD)  if year>=2012 & year<=2022 ,fe cluster(regioncode) robust first
est store m6 

ivreg2  SD_turnout $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD)  if year>=2012 & year<=2022, cluster(regioncode) robust first
est store m7

ivreg2  SD_conserv1_p $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD)  if year>=2012 & year<=2022, cluster(regioncode) robust first
est store m8

ivreg2 SD_conserv2_p $fixed $SD immi_share_SD mfg_share_SD (X_SD = Z_SD)  if year>=2012 & year<=2022, cluster(regioncode) robust first
est store m9 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

***************************** 이질성 분석 ****************************
* 수도권 vs. 비수도권 
est clear 
 
xi: xtivreg2 SD_turnout $fixed $SD (X_SD = Z_SD) if sido_nm=="서울특별시" | sido_nm=="인천광역시" | sido_nm=="경기도", fe cluster(regioncode) robust first  
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if sido_nm=="서울특별시" | sido_nm=="인천광역시" | sido_nm=="경기도", fe cluster(regioncode) robust first  
est store m2 

xi: xtivreg2 SD_conserv2_p $fixed $SD (X_SD = Z_SD) if sido_nm=="서울특별시" | sido_nm=="인천광역시" | sido_nm=="경기도", fe cluster(regioncode) robust first  
est store m3 

xi: xtivreg2 SD_turnout $fixed $SD (X_SD = Z_SD) if sido_nm!="서울특별시" & sido_nm!="인천광역시" & sido_nm!="경기도",fe cluster(regioncode) robust first   
est store m4 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if sido_nm!="서울특별시" &sido_nm!="인천광역시" & sido_nm!="경기도", fe cluster(regioncode) robust first ffirst 
est store m5 

xi: xtivreg2 SD_conserv2_p $fixed $SD (X_SD = Z_SD) if sido_nm!="서울특별시" & sido_nm!="인천광역시" & sido_nm!="경기도", fe cluster(regioncode) robust first ffirst 
est store m6 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

* immigration 
est clear 
 
xi: xtivreg2 SD_turnout $fixed $SD (X_SD = Z_SD) if high_immi_2007==1, fe cluster(regioncode) robust first  
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if high_immi_2007==1, fe cluster(regioncode) robust first  
est store m2 

xi: xtivreg2 SD_conserv2_p $fixed $SD (X_SD = Z_SD) if high_immi_2007==1, fe cluster(regioncode) robust first  
est store m3 

xi: xtivreg2 SD_turnout $fixed $SD (X_SD = Z_SD) if high_immi_2007==0,fe cluster(regioncode) robust first   
est store m4 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if high_immi_2007==0, fe cluster(regioncode) robust first ffirst 
est store m5 

xi: xtivreg2 SD_conserv2_p $fixed $SD (X_SD = Z_SD) if high_immi_2007==0, fe cluster(regioncode) robust first ffirst 
est store m6 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

* manufacturing share 
est clear 
 
xi: xtivreg2 SD_turnout $fixed $SD (X_SD = Z_SD) if high_mfg_2007==1, fe cluster(regioncode) robust first  
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if high_mfg_2007==1, fe cluster(regioncode) robust first  
est store m2 

xi: xtivreg2 SD_conserv2_p $fixed $SD (X_SD = Z_SD) if high_mfg_2007==1, fe cluster(regioncode) robust first  
est store m3 

xi: xtivreg2 SD_turnout $fixed $SD (X_SD = Z_SD) if high_mfg_2007==0,fe cluster(regioncode) robust first   
est store m4 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if high_mfg_2007==0, fe cluster(regioncode) robust first ffirst 
est store m5 

xi: xtivreg2 SD_conserv2_p $fixed $SD (X_SD = Z_SD) if high_mfg_2007==0, fe cluster(regioncode) robust first ffirst 
est store m6 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

* solid democra vs. solid repub vs. competitive  
est clear 
 
xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if dum_solid_lib1==1, fe cluster(regioncode) robust first 
est store m1 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if dum_solid_con1==1, fe cluster(regioncode) robust first  
est store m2 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if dum_competitive1==1, fe cluster(regioncode) robust first  
est store m3 

xi: xtivreg2 SD_turnout  $fixed $SD (X_SD = Z_SD) if dum_solid_lib1==1, fe cluster(regioncode) robust first 
est store m4 

xi: xtivreg2 SD_conserv1_p $fixed $SD (X_SD = Z_SD) if dum_solid_con1==1, fe cluster(regioncode) robust first  
est store m5 

xi: xtivreg2 SD_conserv2_p $fixed $SD (X_SD = Z_SD) if dum_competitive1==1, fe cluster(regioncode) robust first  
est store m6 

esttab m*, nogap stats(N widstat arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 
