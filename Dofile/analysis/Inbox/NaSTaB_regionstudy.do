use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_longregion_final.dta", clear 

br

sort regioncode year 
xtset regioncode year 

global fixed i.year 
global demo L.college_final L.pop65 
global demo2 L.college_final L.pop65 L.p_immi0
global demo3 L.college_final L.pop65 L.p_malab 
global demo4 L.college_final L.pop65 L.p_immi0 L.p_malab 
**************************HETEROGENOUS - dummy variable 
// 로봇노출 - 중윗값 더미변수 만듦 
xi:reg median_pga020 $fixed DRobot_exp_all1995, vce(cluster regioncode)

gen sample=e(sample)

summarize DRobot_exp_all1995 if year == 2012 & sample==1, detail
local med = r(p50)

gen highro = .
replace highro = 1 if DRobot_exp_all1995 >= `med' & sample==1
replace highro = 0 if DRobot_exp_all1995 < `med' & sample==1 

// 이민자 비율 - 더미 만들기 
** 이민자 밀집지역 dummy variable 
** 5%가 넘으면 이민자 밀집지역, 5%미만일 경우 아님 
summarize p_immi0 if year == 2012 & sample==1, detail
local med = r(p50)

gen highimmi = .
replace highimmi = 1 if p_immi0 >= `med' & sample==1
replace highimmi = 0 if p_immi0 < `med' & sample==1 

// 대졸자비율 - 중윗값 더미 만들기 
summarize college_final if year==2012 & sample==1, detail 
local med =r(p50)

gen highedu= . 
replace highedu = 1 if college_final >= `med' & sample==1
replace highedu = 0 if college_final < `med' & sample==1 

// 고령인구 더미 
summarize pop65 if year==2012 & sample==1, detail 
local med =r(p50)

gen highage= . 
replace highage = 1 if pop65  >= `med' & sample==1
replace highage = 0 if pop65  < `med' & sample==1 

// 제조업 사업체 비율 더미 
summarize p_mafirm if year==2012 & sample==1, detail 
local med =r(p50)

gen highmafirm = . 
replace highmafirm = 1 if p_mafirm  >= `med' & sample==1
replace highmafirm = 0 if p_mafirm  < `med' & sample==1 

// 제조업 종사자 비율 더미 
summarize p_malab if year==2012 & sample==1, detail 
local med =r(p50)

gen highmalab = . 
replace highmalab = 1 if p_malab  >= `med' & sample==1
replace highmalab = 0 if p_malab  < `med' & sample==1 

// 제조업 남성 종사자 비율 더미 
summarize pm_malab if year==2012 & sample==1, detail 
local med =r(p50)

gen highmmalab = . 
replace highmmalab = 1 if pm_malab  >= `med' & sample==1
replace highmmalab = 0 if pm_malab  < `med' & sample==1 

// 제조업 여성 종사자 비율 더미 
summarize pf_malab if year==2012 & sample==1, detail 
local med =r(p50)

gen highfmalab = . 
replace highfmalab = 1 if pf_malab  >= `med' & sample==1
replace highfmalab = 0 if pf_malab  < `med' & sample==1 

tab highmalab
tab highmmalab
tab highfmalab
****************************************************************************
********************* AUTOMATION(수정전) - POLITICAL POLARIZATION 
***** + 수도권/비수도권 
est clear 
xi: xtivreg2 mean_pga020 $fixed  (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 mean_pga020 $fixed  (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"&sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 이민 이질성 
xi: xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highimmi==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highimmi==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 대졸자 밀집 
est clear 

xi: xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highedu==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highedu==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 고령인구 밀집 
est clear 

xi: xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highage==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highage==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 사업체 밀집 
est clear 

xi: xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmafirm==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highmafirm==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 종사자 밀집 
est clear 

xi: xtivreg2 new $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmalab==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highmalab==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 "남성" 종사자 밀집 
est clear 

xi: xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmmalab==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highmmalab==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 "여성" 종사자 밀집 
est clear 

xi: xtivreg2 new $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highfmalab==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highfmalab==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

