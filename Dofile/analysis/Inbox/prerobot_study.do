clear 
set more off 
set matsize 2000

use "/Users/ihuila/Desktop/data/master thesis/prerobot.dta"
cd "/Users/ihuila/Desktop/data/master thesis/tables"

xtset regioncode year

gen id=_n 
************************************ 전국 **************************** 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year , fe robust first  // liberal 

************************ 모든 도/광역시 세부로 쪼개서 **********************
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="서울특별시" , fe robust first // conserv 

xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="부산광역시" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="인천광역시" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="대구광역시" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="대전광역시" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="광주광역시" , fe robust first // liberal 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="울산광역시" , fe robust first 

xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="세종특별자치시" , fe robust first // obs 너무작음 

xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="강원도" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="경기도" , fe robust first
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="충청북도" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="충청남도" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="전라북도" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="전라남도" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="경상북도" , fe robust first // liberal 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="경상남도", fe robust first // liberal 

xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="제주특별자치도" , fe robust first // obs 너무 작음. 
************************ 크게 도를 쪼갰을 때 *****************************
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="충청남도" | sido_nm=="충청북도" , fe robust first
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="경기도" , fe robust first 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="경상남도" | sido_nm=="경상북도" , fe robust first //liberal 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="전라남도" | sido_nm=="전라북도" , fe robust first // liberal 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="강원도" , fe robust first 
*********************** 수도권 vs. 비수도권 **************************
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="경기도" | sido_nm=="서울특별시" | sido_nm=="인천광역시" , fe robust first // 수도권 - 오른쪽으로 감 (conserv)
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm!="경기도" & sido_nm!="서울특별시" & sido_nm!="인천광역시" , fe robust first // 비수도권 - 왼쪽으로 감 (liberal)

********************* 수도권 vs. 비수도권 광역시 vs. 비수도궈 나머지 지방 ******* 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm=="경기도" | sido_nm=="서울특별시" | sido_nm=="인천광역시" , fe robust first // 수도권 - conserv 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm!="경기도" & sido_nm!="서울특별시" & sido_nm!="인천광역시" & regexm(sido_nm, "광역시")!=0 , fe robust first // 비수도권 광역시 
xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) tot_pop20 i.year if sido_nm!="경기도" & sido_nm!="서울특별시" & sido_nm!="인천광역시" & regexm(sido_nm, "광역시")==0 , fe robust first // 비수도권 나머지 지방 - liberal 
*************************taables******************************************
log using prerobotstudy_oneout.smcl, replace 

cd "/Users/ihuila/Desktop/data/master thesis/tables"

********************** 1.전국 + 나머지 세부지역 다 쪼개서 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg new i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="서울특별시", vce(cluster regioncode)
est store reg2

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="부산광역시" , vce(cluster regioncode)
est store reg3

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="인천광역시", vce(cluster regioncode)
est store reg4

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="대구광역시", vce(cluster regioncode)
est store reg5

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="대전광역시", vce(cluster regioncode)
est store reg6

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="광주광역시", vce(cluster regioncode)
est store reg7

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="울산광역시", vce(cluster regioncode)
est store reg8

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경기도", vce(cluster regioncode)
est store reg9

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="충청남도" | sido_nm=="충청북도", vce(cluster regioncode)
est store reg10

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", vce(cluster regioncode)
est store reg11

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="전라남도" | sido_nm=="전라북도", vce(cluster regioncode)
est store reg12

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="강원도", vce(cluster regioncode)
est store reg13

esttab reg* using election_Table1A_POLS_oneout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13
esttab reg* using election_Table1B_FE_oneout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13
esttab reg* using election_Table3_FEIV_oneout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close

*************************tables******************************************
log using prerobotstudy_twoout.smcl, replace 

cd "/Users/ihuila/Desktop/data/master thesis/tables"

********************** 2.수도권vs.비수도권 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg new i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", vce(cluster regioncode)
est store reg2

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도" , vce(cluster regioncode)
est store reg3

esttab reg* using election_Table1A_POLS_twoout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3


esttab reg* using election_Table1B_FE_twoout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3

esttab reg* using election_Table3_FEIV_twoout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close

*************************tables******************************************
log using prerobotstudy_threeout.smcl, replace 

cd "/Users/ihuila/Desktop/data/master thesis/tables"

********************** 3.수도권vs.비수도권 광역시 vs. 비수도권 지방 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg new i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", vce(cluster regioncode)
est store reg2

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0 , vce(cluster regioncode)
est store reg3

xi: reg new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0 , vce(cluster regioncode)
est store reg4

esttab reg* using election_Table1A_POLS_threeout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0, fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0, fe cluster(regioncode) robust first 
est store reg4

esttab reg* using election_Table1B_FE_threeout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 new i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0, fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 new i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0, fe cluster(regioncode) robust first 
est store reg4

esttab reg* using election_Table3_FEIV_threeout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close


