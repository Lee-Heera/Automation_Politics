use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterdata/voterobot.dta", clear

sort regioncode year 
xtset regioncode year 

global cont i.year L.college_final L.pop65

use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterdata/voterobot.dta", clear 

sort regioncode year 
xtset regioncode year 

global cont i.year L.college_final L.pop65

*************************tables******************************************
cd "/Users/ihuila/Desktop/data/master thesis/tables5"
log using Table_presinga.smcl, replace 

********************** 1.전국 + 나머지 세부지역 다 쪼개서 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg vote $cont  DRobot_exp_u_all1995 , vce(cluster regioncode)
est store reg1

xi: reg vote  $cont  DRobot_exp_u_all1995  if sido_nm=="서울특별시", vce(cluster regioncode)
est store reg2

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="부산광역시" , vce(cluster regioncode)
est store reg3

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="인천광역시", vce(cluster regioncode)
est store reg4

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="대구광역시", vce(cluster regioncode)
est store reg5

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="대전광역시", vce(cluster regioncode)
est store reg6

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="광주광역시", vce(cluster regioncode)
est store reg7

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="울산광역시", vce(cluster regioncode)
est store reg8

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="경기도", vce(cluster regioncode)
est store reg9

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="충청남도" | sido_nm=="충청북도", vce(cluster regioncode)
est store reg10

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", vce(cluster regioncode)
est store reg11

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="전라남도" | sido_nm=="전라북도", vce(cluster regioncode)
est store reg12

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="강원도", vce(cluster regioncode)
est store reg13

esttab reg* using Table_presinga.csv, nogap stats(N r2) title("Table 1A: POLS") r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 vote $cont  DRobot_exp_u_all1995  , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote $cont   DRobot_exp_u_all1995  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 vote $cont  DRobot_exp_u_all1995 if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 vote $cont  DRobot_exp_u_all1995 if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 vote $cont   DRobot_exp_u_all1995  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 vote  $cont  DRobot_exp_u_all1995  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 vote  $cont  DRobot_exp_u_all1995  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 vote $cont   DRobot_exp_u_all1995  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 vote $cont   DRobot_exp_u_all1995 if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 vote $cont   DRobot_exp_u_all1995  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 vote  $cont  DRobot_exp_u_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 vote $cont DRobot_exp_u_all1995  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 vote $cont   DRobot_exp_u_all1995 if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13

esttab reg* using Table_presinga.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 vote $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 vote $cont   (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 vote $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 vote  $cont (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 vote $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13
esttab reg* using Table_presinga.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close
********************** 2.수도권vs.비수도권 *********************
cd "/Users/ihuila/Desktop/data/master thesis/tables5"

log using Table2_presinga.smcl, replace 

* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg vote $cont DRobot_exp_u_all1995, vce(cluster regioncode)
est store reg1

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", vce(cluster regioncode)
est store reg2

xi: reg vote  $cont  DRobot_exp_u_all1995  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도" , vce(cluster regioncode)
est store reg3

esttab reg* using Table2_presinga.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 vote  $cont  DRobot_exp_u_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote  $cont  DRobot_exp_u_all1995  if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 vote  $cont  DRobot_exp_u_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3


esttab reg* using Table2_presinga.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 vote $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)

esttab reg* using Table2_presinga.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close
********************** 3.수도권vs.비수도권 광역시 vs. 비수도권 지방 *********************
log using Table3_presinga.smcl, replace 

cd "/Users/ihuila/Desktop/data/master thesis/tables5"
* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg vote  $cont  DRobot_exp_u_all1995, vce(cluster regioncode)
est store reg1

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", vce(cluster regioncode)
est store reg2

xi: reg vote $cont  DRobot_exp_u_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0 , vce(cluster regioncode)
est store reg3

xi: reg vote  $cont  DRobot_exp_u_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0 , vce(cluster regioncode)
est store reg4

esttab reg* using Table3_presinga.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 vote  $cont  DRobot_exp_u_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote  $cont  DRobot_exp_u_all1995  if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 vote  $cont  DRobot_exp_u_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0, fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 vote  $cont DRobot_exp_u_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0, fe cluster(regioncode) robust first 
est store reg4

esttab reg* using Table3_presinga.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 vote  $cont (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0, fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 vote  $cont  (DRobot_exp_u_all1995=SG_Robot_exp_u_all1995) if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0, fe cluster(regioncode) robust first 
est store reg4

esttab reg* using Table3_presinga.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close
