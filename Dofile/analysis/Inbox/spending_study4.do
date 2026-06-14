use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterspending/spendingimmi.dta", clear 

global cont i.year L.college_final L.pop65
sort regioncode year 
duplicates drop regioncode year, force 

xtset regioncode year 

summarize DRobot_exp_all1995 if year == 2010, detail
local med = r(p50)

gen highro = .
replace highro = 1 if DRobot_exp_all1995 >= `med'
replace highro = 0 if DRobot_exp_all1995 < `med' 

// 대졸자비율 - 중윗값 더미 만들기 
summarize college_final if year==2010 , detail 
local med =r(p50)

gen highedu= . 
replace highedu = 1 if college_final >= `med' 
replace highedu = 0 if college_final < `med' 

// 고령인구 더미 
summarize pop65 if year==2010, detail 
local med =r(p50)

gen highage= . 
replace highage = 1 if pop65  >= `med' 
replace highage = 0 if pop65  < `med' 

// 제조업 사업체 비율 더미 
summarize p_mafirm if year==2010, detail 
local med =r(p50)

gen highmafirm = . 
replace highmafirm = 1 if p_mafirm  >= `med' 
replace highmafirm = 0 if p_mafirm  < `med' 

// 제조업 종사자 비율 더미 
summarize p_malab if year==2010, detail 
local med =r(p50)

gen highmalab = . 
replace highmalab = 1 if p_malab  >= `med' 
replace highmalab = 0 if p_malab  < `med' 

// 제조업 남성 종사자 비율 더미 
summarize pm_malab if year==2010, detail 
local med =r(p50)

gen highmmalab = . 
replace highmmalab = 1 if pm_malab  >= `med' 
replace highmmalab = 0 if pm_malab  < `med' 

// 제조업 여성 종사자 비율 더미 
summarize pf_malab if year==2010, detail 
local med =r(p50)

gen highfmalab = . 
replace highfmalab = 1 if pf_malab  >= `med' 
replace highfmalab = 0 if pf_malab  < `med' 

tab highmalab
tab highmmalab
tab highfmalab
***************************************************
********* 싱가포르 로봇 ******* 
est clear 
xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logenvir $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 loghealth $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logart $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logadmin $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logpubsafe $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logindus $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logtrans $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logregion $cont (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg12

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)
********************************************************
****** immigrants - spending 
est clear 

xi: xtivreg2 spend_all $cont (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first // marginally significant 

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0) , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logenvir $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logart $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logadmin $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logpubsafe $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logindus $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logtrans $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logregion $cont spend_all (p_immi0=p_iv_immi0), fe cluster(regioncode) robust first 
est store reg12

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)
*****************************************************
*******immigrants - welfare + HETERO 
est clear 

** 수도권/비수도권
xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0) if sido_nm=="서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0) if sido_nm!="서울특별시" & sido_nm!="경기도" & sido_nm!="인천광역시" , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)

** 대졸자 밀집
xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highedu==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highedu==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 고령인구 밀집 
xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0) if highage==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0) if highage==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 사업체 밀집 
xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highmafirm==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highmafirm==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 종사자 밀집 
xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highmalab==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highmalab==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 남성 종사자 밀집 
xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highmmalab==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highmmalab==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 여성 종사자 밀집 
xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highfmalab==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare $cont spend_all (p_immi0=p_iv_immi0)  if highfmalab==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)

*************************************************************************
*******immigrants - health + HETERO 
est clear 

** 수도권/비수도권
xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0) if sido_nm=="서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0) if sido_nm!="서울특별시" & sido_nm!="경기도" & sido_nm!="인천광역시" , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)

** 대졸자 밀집
xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highedu==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highedu==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 고령인구 밀집 
xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0) if highage==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0) if highage==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 사업체 밀집 
xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highmafirm==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highmafirm==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 종사자 밀집 
xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highmalab==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highmalab==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 남성 종사자 밀집 
xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highmmalab==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highmmalab==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)


** 제조업 여성 종사자 밀집 
xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highfmalab==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth $cont spend_all (p_immi0=p_iv_immi0)  if highfmalab==0 , fe cluster(regioncode) robust first 
est store reg2 

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)

