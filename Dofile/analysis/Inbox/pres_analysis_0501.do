**********************************************************************  
* Robot and automation
* Singapore Employment Statistics clean do-file
**********************************************************************
clear all

	global main "/Users/ihuila/Desktop/data/master thesis"
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
*************************************************************************
use "$final/Robot_pres_merge.dta"

sort regioncode year 
xtset regioncode year 

sort regioncode year
bysort regioncode (year): gen lag_college = college_final[_n-1]
bysort regioncode (year): gen lag_pop65   = pop65[_n-1]

global fixed i.year 
global demo lag_college lag_pop65 

ren immi_total tot_immi 
***************** 이질성 분석용 변수 만들기 ***************** 
* ============================================
* 1. 이민자 비율 변수 생성 -> 이질성분석용 (2007년도 기준)
* ============================================
gen he_p_immi0 = immi0 / pop
gen he_p_immi  = immi  / pop
gen he_p_immi2 = immi2 / pop
gen he_p_immi3 = immi3 / pop

* ============================================
* 2. 2007년 기준 중위수 더미 생성
* ============================================
foreach v in he_p_immi0 he_p_immi he_p_immi2 he_p_immi3 {
    bysort regioncode (year): gen `v'_base = `v' if year == 2012
    bysort regioncode: egen `v'_2012 = max(`v'_base)
    drop `v'_base
    
    qui sum `v'_2012, detail
    local med = r(p50)
    gen dum_`v' = (`v'_2012 >= `med') if !missing(`v'_2012)  // dum_he_p_immi0 등으로 생성
    di "중위수 (`v'): `med'"
}

rename dum_he_p_immi0 dum_high_p_immi0
rename dum_he_p_immi  dum_high_p_immi
rename dum_he_p_immi2 dum_high_p_immi2
rename dum_he_p_immi3 dum_high_p_immi3
****************************** pilot study ****************************** 
ivreg2 d_turnout $fixed $demo (X_robot_FD=IV_robot_FD), cluster(regioncode) robust first // -> first stage coeff : negative 나옴 
est store m1 

ivreg2 d_conserv1_p $fixed $demo (X_robot_FD=IV_robot_FD), cluster(regioncode) robust first // -> first stage coeff : negative 나옴 
est store m2 

xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD),fe cluster(regioncode) robust first // -> long difference 로 하기 
****************************** pilot study ******************************
est clear 

ivreg2 ld_turnout (X_robot_LD=IV_robot_LD) if year==2022,  cluster(regioncode) robust first 
est store m1 

ivreg2 ld_conserv1_p (X_robot_LD=IV_robot_LD) if year==2022,  cluster(regioncode) robust first 
est store m2 

esttab m*, nogap stats(N cdf arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 


xi: xtivreg2 ld_turnout (X_robot_LD=IV_robot_LD), fe cluster(regioncode) robust first  // -> long difference 로 하기 
est store m1 

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD),fe cluster(regioncode) robust first   // -> long difference 로 하기 
est store m2 // conserv 증가 

xi: xtivreg2 ld_conserv2_p $fixed $demo (X_robot_LD=IV_robot_LD),fe cluster(regioncode) robust first ffirst  // -> long difference 로 하기 
est store m3 // conserv 증가 

esttab m*, nogap stats(N cdf arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)  
****************************** heterogeneity ******************************
******** 수도권 Vs. 비수도권 
est clear 
 
xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD) if sido_nm=="서울특별시" | sido_nm=="인천광역시" | sido_nm=="경기도", fe cluster(regioncode) robust first  
est store m1 

xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD) if sido_nm!="서울특별시" & sido_nm!="인천광역시" & sido_nm!="경기도", fe cluster(regioncode) robust first  
est store m2 
// 투표율은 모두감소  (다만 계수 크기+significance 비수도권이 강함)

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD) if sido_nm=="서울특별시" | sido_nm=="인천광역시" | sido_nm=="경기도",fe cluster(regioncode) robust first  
est store m3 

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD) if sido_nm!="서울특별시" & sido_nm!="인천광역시" & sido_nm!="경기도",fe cluster(regioncode) robust first   // 비수도권에서 자동화 -> conservative 
est store m4 

xi: xtivreg2 ld_conserv2_p $fixed $demo (X_robot_LD=IV_robot_LD) if sido_nm=="서울특별시" | sido_nm=="인천광역시" | sido_nm=="경기도", fe cluster(regioncode) robust first ffirst 
est store m5 

xi: xtivreg2 ld_conserv2_p $fixed $demo (X_robot_LD=IV_robot_LD) if sido_nm=="서울특별시" | sido_nm=="인천광역시" | sido_nm=="경기도", fe cluster(regioncode) robust first ffirst 
est store m6 

esttab m*, nogap stats(N cdf arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

********* Solid conservative / Solid democrat / Competitive 지역 
est clear 
 
xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD) if dum_solid_con1==1 , fe cluster(regioncode) robust first  
est store m1 

xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD) if dum_solid_lib1==1 , fe cluster(regioncode) robust first  
est store m2 

xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD) if dum_competitive1==1, fe cluster(regioncode) robust first  
est store m3 
// 투표율은 모두 감소 

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD) if dum_solid_con1==1,fe cluster(regioncode) robust first  
est store m4 

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD) if dum_solid_lib1==1,fe cluster(regioncode) robust first   
est store m5 

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD) if dum_competitive1==1, fe cluster(regioncode) robust first   
est store m6

// solid democrat, solid competitive 모두-> conservative 쪽으로 
// 경합지역은 유의미하지 않았음 
esttab m*, nogap stats(N cdf arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

********* immigration 밀집도 높은지역 vs. 낮은
est clear 
 
xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD) if dum_high_p_immi0==1  , fe cluster(regioncode) robust first  
est store m1 

xi: xtivreg2 ld_turnout $fixed $demo (X_robot_LD=IV_robot_LD) if dum_high_p_immi0==0, fe cluster(regioncode) robust first  
est store m2 

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD) if dum_high_p_immi0==1,fe cluster(regioncode) robust first  
est store m4 

xi: xtivreg2 ld_conserv1_p $fixed $demo (X_robot_LD=IV_robot_LD) if dum_high_p_immi0==0, fe cluster(regioncode) robust first   
est store m5 

esttab m*, nogap stats(N cdf arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

// 투표율은 모두 감소 
// 이민자 밀집이 높은 지역에서 conservative, 낮은 지역은 유의미하지 X 

