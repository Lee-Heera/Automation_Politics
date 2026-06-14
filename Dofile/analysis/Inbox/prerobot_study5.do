// 싱가폴 로봇데이터 + 통제변수 + 대선 정당별 득표율 + 대선 투표율 + 이민 데이터 
// immi0 - 외국인 주민(국적취득자, 국적미취득자, 외국인주민 자녀) 숫자, 
// p_immi0 - 위 변수의 비율 
// 
use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterdata/prerobot4.dta", clear 

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
xi: reg vote $fixed DRobot_exp_all1995, vce(cluster regioncode)

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
****** year fixed, region fixed effect 
est clear 
xi: xtivreg2 vote $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1 

xi: xtivreg2 new $fixed (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg2 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

****** robustness checks (added lagged control var)
est clear 
xi: xtivreg2 vote $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1 

xi: xtivreg2 new $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg2 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

*********** HETEROGENEITY ANALYSIS 1 : 수도권 vs. 비수도권
est clear 
xi:  xtivreg2 vote $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

xi:  xtivreg2 vote $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"&sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg4

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"&sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg5

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

*********** HETEROGENEITY ANALYSIS 2: 이민자 밀집 지역 
est clear 
xi:  xtivreg2 vote $fixed  $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highimmi==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highimmi==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

xi:  xtivreg2 vote $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highimmi==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg4

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highimmi==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg5

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

*********** HETEROGENEITY ANALYSIS 3: manufacuring factories 
est clear 
xi:  xtivreg2 vote $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmafirm==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmafirm == 1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

xi:  xtivreg2 vote $fixed  $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmafirm==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg4

xi:  xtivreg2 new $fixed  $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highmafirm ==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg5

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

********************* AUTOMATION(수정전) - Political engagement 
***** + 수도권/비수도권 
est clear 
xi: xtivreg2 vote $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 vote $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"&sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 
******************** AUTOMATION(수정전) - POLITICAL POLARIZATION 
***** + 수도권/비수도권 
est clear 
xi: xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
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

********************************************************************************
**** IMMIGRANT - POLITICAL POLARIZATION: ANALYSIS ******
***** + 수도권/비수도권 
est clear 

xi: xtivreg2 new $fixed  (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed  (p_immi0=p_iv_immi0) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (p_immi0=p_iv_immi0)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"&sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 이민 이질성 
est clear 
xi: xtivreg2 new $fixed  (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed  (p_immi0=p_iv_immi0) if highimmi==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (p_immi0=p_iv_immi0)  if highimmi==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 대졸자 밀집 
est clear 

xi: xtivreg2 new $fixed  (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed  (p_immi0=p_iv_immi0) if highedu==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (p_immi0=p_iv_immi0)  if highedu==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 고령인구 밀집 
est clear 

xi: xtivreg2 new $fixed  (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0) if highage==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed  (p_immi0=p_iv_immi0)  if highage==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 사업체 밀집 
est clear 

xi: xtivreg2 new $fixed (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0) if highmafirm==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0)  if highmafirm==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 종사자 밀집 
est clear 

xi: xtivreg2 new $fixed (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0) if highmalab==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0)  if highmalab==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 "남성" 종사자 밀집 
est clear 

xi: xtivreg2 new $fixed (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0) if highmmalab==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0)  if highmmalab==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** + 제조업 "여성" 종사자 밀집 
est clear 

xi: xtivreg2 new $fixed (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0) if highfmalab==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed (p_immi0=p_iv_immi0)  if highfmalab==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

// p_immi p_immi2 p_immi3 p_immi0
// p_iv_immi p_iv_immi2 p_iv_immi3 p_iv_immi0


**** AUTOMATION - POLITICAL 

/*
*************추가 HETEROGENOUS ANALYSIS 
// 로봇노출 - 중윗값 더미변수 만듦 
xi: reg vote $fixed DRobot_exp_all1995, vce(cluster regioncode)
gen sample=e(sample)

summarize DRobot_exp_all1995 if year == 2012 & sample==1, detail
local med = r(p50)

gen highro = .
replace highro = 1 if DRobot_exp_all1995 >= `med' & sample==1
replace highro = 0 if DRobot_exp_all1995 < `med' & sample==1 

// 
summarize college_final if year==2012 & sample==1, detail 
local med =r(p50)

gen highedu= . 
replace highedu = 1 if college_final >= `med' & sample==1
replace highedu = 0 if college_final < `med' & sample==1 

// 
summarize pop65 if year==2012 & sample==1, detail 
local med =r(p50)

gen highage= . 
replace highage = 1 if pop65  >= `med' & sample==1
replace highage = 0 if pop65  < `med' & sample==1 

******************************예심발표 테이블용 **********************
************************* 1. 전체 main table ******************
cd "/Users/ihuila/Desktop/data/master thesis/tables4"

log using main_regressions_oneout.smcl, replace 

// Table1 (Panel A)
* clusterid3 에 시군구코드 변수를 넣으면 됨 
est clear 

xi: reg vote $fixed DRobot_exp_all1995, vce(cluster regioncode)
est store reg1 

xi: reg new $fixed DRobot_exp_all1995, vce(cluster regioncode)
est store reg2 

esttab reg* using Table1A_POLS_oneout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear 
// Table 1 (Panel B) : FE
xi: xtivreg28 vote $fixed DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg28 new $fixed DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg2

esttab reg* using Table1B_FE_oneout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear 
// Table 2 : FE-IV estimation 
xi: xtivreg2 vote $fixed (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first savefprefix(fs_)
est store reg1 

xi: xtivreg2 new $fixed (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

esttab reg* using Table3_FEIV_oneout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

log close 

********************** 2. robustness checks ************************
cd "/Users/ihuila/Desktop/data/master thesis/tables4"

log using robustness.smcl, replace 

// Table1 (Panel A)
* clusterid3 에 시군구코드 변수를 넣으면 됨 
est clear 

xi: reg vote $fixed $demo DRobot_exp_all1995, vce(cluster regioncode)
est store reg1 

xi: reg new $fixed $demo DRobot_exp_all1995, vce(cluster regioncode)
est store reg2 

esttab reg* using Table1A_POLS_oneout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear 
// Table 1 (Panel B) : FE
xi: xtivreg28 vote $fixed $demo DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg28 new $fixed $demo DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg2

esttab reg* using Table1B_FE_oneout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear 
// Table 2 : FE-IV estimation 
xi: xtivreg2 vote $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first savefprefix(fs_)
est store reg1 

xi: xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

esttab reg* using Table3_FEIV_oneout.csv, nogap first stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

log close 

***********************3. 수도권 vs. 비수도권 ******************
cd "/Users/ihuila/Desktop/data/master thesis/tables4"

log using heterogenous.smcl, replace 

est clear 
xi: xtivreg2 vote $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote  $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 vote $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_) 
est store reg3

xi: xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg5

xi:  xtivreg2 new $fixed  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg6

esttab reg*  using Table3_FEIV_oneout.csv, nogap first stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

log close
*************************Summary statistics ***********************
tabstat vote if sample==1, stat(mean median sd min max N)
tabstat new if sample==1, stat(mean median sd min max N)
tabstat DRobot_exp_all1995 if sample==1, stat(mean median sd min max N)
tabstat Z_DRobot_exp_all1995 if sample==1, stat(mean median sd min max N)

***********************************************************************
******************로봇노출도가 높은지역 / 그렇지 않은지역 ************************************
est clear 
xi: xtivreg2 vote $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote  $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highro==1, fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 vote $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highro==0, fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 new $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 new  $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highro==1, fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 new $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highro==0, fe cluster(regioncode) robust first 
est store reg6


esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 
*************************************************************************
***** 새로운 IV (싱가포르) 분석용 - 정치적양극화 - 결과 안나옴 ㅠㅠ 
est clear 

xi: xtivreg2 new $fixed $demo  (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first // 유의미하지 않음 
est store reg1 

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first // 유의미하지않음 
est store reg2 

xi:  xtivreg2 new $fixed $demo  (DRobot_exp_all1995=SG_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3  //유의미하지않음 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


est clear 
xi: xtivreg2 new $fixed $demo  (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) , fe cluster(regioncode) robust first savefprefix(fs_) // 유의미하지 않음 
est store reg1 

xi:  xtivreg2 new $fixed $demo  (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first savefprefix(fs_) // 유의미하지않음 
est store reg2 

xi:  xtivreg2 new $fixed $demo   (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3  //유의미하지않음 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)  
************************
******싱가포르 + 정치참여 -> 이건 결과 잘 나옴 
est clear  

xi: xtivreg2 vote $fixed $demo  (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first // 유의미하지 않음 
est store reg1 

xi:  xtivreg2 vote $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first // 유의미하지않음 
est store reg2 

xi:  xtivreg2 vote $fixed $demo  (DRobot_exp_all1995=SG_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3  //유의미하지않음 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)

est clear 
xi: xtivreg2 vote $fixed $demo  (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) , fe cluster(regioncode) robust first // 유의미하지 않음 
est store reg1 

xi:  xtivreg2 vote $fixed $demo  (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first // 유의미하지않음 
est store reg2 

xi:  xtivreg2 vote $fixed $demo   (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3  //유의미하지않음 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)
*****************
*/
