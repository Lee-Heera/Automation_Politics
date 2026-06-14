use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterdata/spendingrobot.dta", clear

global cont i.year L.college_final L.pop65
sort regioncode year 
duplicates drop regioncode year, force 

xtset regioncode year 


cd "/Users/ihuila/Desktop/data/master thesis/tables3"

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 

gen sample=e(sample)

xtsum Z_DRobot_exp_all1995 if sido_nm == "세종특별자치시"

/*
******************************* 전국 - 재정 대범주 *******************************************
**** IV 95년도로 
cd "/Users/ihuila/Desktop/data/master thesis/tables3"
log using Table_spending.smcl, replace 

* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg logwelfare $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg logenvir $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg2

xi: reg loghealth $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg4

xi: reg logart $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg5

xi: reg logadmin $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg6

xi: reg logpubsafe $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg7

xi: reg logindus $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg8

xi: reg logtrans $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg9

xi: reg logregion $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg12

esttab reg* using Table_spending.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 logwelfare i.year L.college_final L.pop65 DRobot_exp_all1995, fe cluster(regioncode) robust first 

xi: xtivreg2 logwelfare $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logenvir $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 loghealth $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logart $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logadmin $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logpubsafe $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logindus $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logtrans $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logregion $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg12

esttab reg* using Table_spending.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation
xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logenvir $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 loghealth $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logart $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logadmin $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logpubsafe $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logindus $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logtrans $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logregion $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg12

esttab reg* using Table_spending.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close

********************** 2.전국(지역별) +  사회복지에산 + 나머지 세부지역 다 쪼개서 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 
cd "/Users/ihuila/Desktop/data/master thesis/tables3"
log using Table2_spending.smcl, replace 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg logwelfare $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="서울특별시", vce(cluster regioncode)
est store reg2

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="부산광역시" , vce(cluster regioncode)
est store reg3

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="인천광역시", vce(cluster regioncode)
est store reg4

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="대구광역시", vce(cluster regioncode)
est store reg5

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="대전광역시", vce(cluster regioncode)
est store reg6

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="광주광역시", vce(cluster regioncode)
est store reg7

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="울산광역시", vce(cluster regioncode)
est store reg8

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="경기도", vce(cluster regioncode)
est store reg9

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="충청남도" | sido_nm=="충청북도", vce(cluster regioncode)
est store reg10

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", vce(cluster regioncode)
est store reg11

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="전라남도" | sido_nm=="전라북도", vce(cluster regioncode)
est store reg12

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="강원도", vce(cluster regioncode)
est store reg13

esttab reg* using Table2_spending.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 logwelfare $cont DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995 if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995 if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logwelfare $cont DRobot_exp_all1995 if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 logwelfare $cont DRobot_exp_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13

esttab reg* using Table2_spending.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13
esttab reg* using Table2_spending.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close
********************** 3.사회복지예산 + 수도권vs.비수도권 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 
log using Table3_spending.smcl, replace 

cd "/Users/ihuila/Desktop/data/master thesis/tables3"

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg logwelfare $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", vce(cluster regioncode)
est store reg2

xi: reg logwelfare $cont DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도" , vce(cluster regioncode)
est store reg3

esttab reg* using Table3_spending.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 logwelfare $cont DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995  if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 logwelfare $cont DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3


esttab reg* using Table3_spending.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01)

esttab reg* using Table3_spending.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close
******************** 4. 전국 + 사회복지예산 세부카테고리별 ***************************
* clusterid3 에 시군구코드 변수를 넣으면 됨 

cd "/Users/ihuila/Desktop/data/master thesis/tables3"
log using Table4_spending.smcl, replace 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg logwel081 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg logwel082 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg2

xi: reg logwel084 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg4

xi: reg logwel085 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg5

xi: reg logwel086 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg6

xi: reg logwel087 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg7

xi: reg logwel088 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg8

xi: reg logwel089 $cont DRobot_exp_all1995, vce(cluster regioncode)
est store reg9

esttab reg* using Table4_spending.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 logwel081 $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwel082  $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logwel084 $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logwel085 $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logwel086 $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logwel087 $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logwel088 $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logwel089 $cont DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg9

esttab reg* using Table4_spending.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation
xi: xtivreg2 logwel081 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwel082 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logwel084 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logwel085 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logwel086 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logwel087 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logwel088 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logwel089 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg9

esttab reg* using Table4_spending.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close

*/

*************************** 발표용 테이블 *************************************
**** Results 1 (예산 대분류 - 통제변수 없고, year / region fixed effect만)
est clear 

xi: xtivreg2 logwelfare i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logenvir i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 loghealth i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logart i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logadmin i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logpubsafe i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logindus i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logtrans i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logregion i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg12

esttab reg* using Table_results1.csv, nogap stats(N cdf arf arfp) title("Table 1: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

********Results 2 (예산 소분류 - 통제변수없고 year, region fixed effect만)

xi: xtivreg2 logwel081 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwel082 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logwel084 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logwel085 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logwel086 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logwel087 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logwel088 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logwel089 i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg9

esttab reg* using Table_results1.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

***** Robustness check 1 예산 대분류 (통제 모두)
est clear 

xi: xtivreg2 logwelfare $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logenvir $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 loghealth $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logart $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logadmin $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logpubsafe $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logindus $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logtrans $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1 , fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logregion $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sample==1, fe cluster(regioncode) robust first 
est store reg12

esttab reg* using Table_robust.csv, nogap stats(N cdf arf arfp) title("Table 1: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

***** Robustness check 2 사회복지예산 소분류 (통제 모두)
xi: xtivreg2 logwel081 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwel082 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logwel084 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logwel085 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logwel086 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logwel087 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logwel088 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logwel089 $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg9

esttab reg* using Table_robust.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
********************
**** Sumamry statistics 
tabstat logwelfare if sample==1, stat(N mean sd min max)
tabstat logenvir if sample==1, stat(N mean sd min max)
tabstat loghealth if sample==1, stat(N mean sd min max)
tabstat logart if sample==1, stat(N mean sd min max)
tabstat logadmin if sample==1, stat(N mean sd min max)
tabstat logpubsafe if sample==1, stat(N mean sd min max)
tabstat logindus if sample==1, stat(N mean sd min max)
tabstat logtrans if sample==1, stat(N mean sd min max)
tabstat logregion if sample==1, stat(N mean sd min max)

tabstat logwel081 if sample==1, stat(N mean sd min max)

