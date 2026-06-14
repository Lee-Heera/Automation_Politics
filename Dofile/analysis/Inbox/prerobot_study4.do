use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterdata/prerobot.dta", clear 

sort regioncode year 
xtset regioncode year 

global fixed i.year 
global demo L.college_final L.pop65 
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
