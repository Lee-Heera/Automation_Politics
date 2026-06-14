**********************************************************************
clear all

set more off

global main    "/Users/ihuila/Research/MASTER_thesis"
global data "${main}/Data cleaned"
global raw     "${main}/Data raw"
global interim "${main}/Data interim"
global prof_raw "${main}/Data raw/professor_raw"
global final "${main}/Data final"
**********************************************************************
use "$interim/Klips/klips_auto_merge.dta"

drop if p_jobfam2000==. &  p_jobfam2007==. &  p_jobfam2017==. 

/*
br if soc_code==""

foreach var in soc_code isco08 ksco8 ksco7 ksco6 ksco5 {
    tab year if !missing(`var') & trim(`var') != "", mi
    di "========== `var' =========="
}
*/

* aim: 1998년도 기준 vulnerability 계산 
keep if year==1998 

* variable 
* gender 
replace p_sex = p_sex - 1

* p_edu: 1=무학, 2=고졸미만, 3=고졸, 4=대재/중퇴, 5=전문대졸, 6=4년제 대졸이상
gen byte edu_cat = 1 if p_edu <= 2
replace  edu_cat = 2 if inrange(p_edu, 3, 5)
replace  edu_cat = 3 if p_edu == 6

*********** 
foreach v in ksco8 ksco7 ksco6 ksco5 {
    gen `v'_2d = substr(`v', 1, 2)
}

bysort ksco5_2d: egen auto_prob_ksco5_2d = mean(auto_prob)


order ksco8 ksco8_2d ksco7 ksco7_2d ksco6 ksco6_2d ksco5 ksco5_2d ///
      auto_prob_ksco5_2d auto_prob

codebook ksco5_2d

tab ksco5_2d, mi

br ksco5 ksco5_2d auto_prob auto_prob_ksco5_2d in 1/50

mlogit ksco5_2d p_age p_sex i.edu_cat i.regioncode 



keep p_edu p_sex p_age pid year wave p_region h0142 sido_nm sigungu_nm p_jobfam2000 p_jobfam2007 p_jobfam2017 auto_prob regioncode 


