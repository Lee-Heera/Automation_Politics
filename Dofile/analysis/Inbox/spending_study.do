*******************************************************************
use "/Users/ihuila/Desktop/data/master thesis/spendingrobot.dta", clear 

xtset regioncode year // 2010-2021년도 
drop region

egen welfare = rowtotal(welfare*)
egen envir = rowtotal(envir*)
egen edu  = rowtotal(edu*)
egen health = rowtotal(health*)
egen art  = rowtotal(art*)

gen log_welfa = log(welfare)
gen log_envir = log(envir)
gen log_edu = log(edu)
gen log_health = log(health)
gen log_art = log(art)

egen admin = rowtotal(admin*)
egen pubsafe = rowtotal(pubsafe*)
egen indus = rowtotal(indus*)
egen trans = rowtotal(trans*)
egen agri = rowtotal(agri*)
egen tech = rowtotal(tech*)
egen region = rowtotal(region*)

gen log_admin = log(admin)
gen log_pubsafe = log(pubsafe)
gen log_indus = log(indus)
gen log_trans = log(trans)
gen log_agri = log(agri)
gen log_tech = log(tech)
gen log_region = log(region)

gen log_prespend = log(prespend)

// 사회복지예산 - 세부카테고리 
// welfare081 기초생활수급자, welfare082 취약계층, welfare084 보육가족여성, welfare085 노인 청소년, welfare086 노동, welfare087 보훈, welfare088 주택, welfare089 사회복지일반 

gen log_wel081=log(welfare081)
gen log_wel082=log(welfare082)
gen log_wel084=log(welfare084)
gen log_wel085=log(welfare085)
gen log_wel086=log(welfare086)
gen log_wel087=log(welfare087)
gen log_wel088=log(welfare088)
gen log_wel089=log(welfare089)

// 변수 라벨링 
label variable log_welfa "사회복지"
label variable log_envir "환경보호"
label variable log_edu "교육"
label variable log_health "보건"
label variable log_art "문화 및 관광"
label variable log_admin "일반공공행정"
label variable log_pubsafe "공공질서"
label variable log_indus "산업중소기업"
label variable log_trans "수송및교통"
label variable log_agri "농림해양수산"
label variable log_tech "과학기술"
label variable log_region "국토및지역개발"

label variable log_wel081 "기초생활보장"
label variable log_wel082 "취약계층지원"
label variable log_wel084 "보육 가족및여성"
label variable log_wel085 "노인 청소년"
label variable log_wel086 "노동"
label variable log_wel087 "보훈"
label variable log_wel088 "주택"
label variable log_wel089 "사회복지일반"

// 평균 출력 (한 번에 요약)
summarize log_welfa log_envir log_edu log_health log_art log_admin log_pubsafe log_indus log_trans log_agri log_tech log_region 

// 평균 높은순서대로: 사회복지 - 환경 - 지역개발 - 일반행정 - 수송및교통 - 문화및관광 - 농림수산해양 - 건강 -  중소및산업 - 공공질서 - 교육 -  과학기술 
// top5: 사회복지 - 환경 - 지역개발 - 일반행정 - 수송및교통 

centile log_welfa log_envir log_edu log_health log_art log_admin log_pubsafe log_indus log_trans log_agri log_tech log_region, centile(50)
// 중위값 높은순서대로: 사회복지 - 농림수산해양 - 환경 - 지역개발 - 일반행정 - 수송및교통 - 문화및관광 - 건강 - 중소및산업 - 공공질서 - 교육 - 과학기술 


******************************* 전국 - 재정 대범주 *******************************************
**** IV 95년도로 
cd "/Users/ihuila/Desktop/data/master thesis/tables"
log using spendingrobot_oneout.smcl, replace 

* clusterid3 에 시군구코드 변수를 넣으면 됨 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg logwelfare i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg logenvir i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg2

xi: reg loghealth i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg3

xi: reg logart i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg4

xi: reg logadmin i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg5

xi: reg logpubsafe i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg6

xi: reg logindus i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg7

xi: reg logtrans i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg8

xi: reg logregion i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg9

esttab reg* using Table_spending.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 log_envir i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 log_edu i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 log_health i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 log_art i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 log_admin i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 log_pubsafe i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 log_indus i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 log_trans i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 log_agri i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 log_tech i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 log_region i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg12

esttab reg* using Table_spending.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation
xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 log_envir i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 log_edu i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 log_health i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 log_art i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 log_admin i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 log_pubsafe i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 log_indus i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 log_trans i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 log_agri i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 log_tech i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 log_region i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg12

esttab reg* using Table_spending.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close

********************** 2.전국(지역별) +  사회복지에산 + 나머지 세부지역 다 쪼개서 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 
cd "/Users/ihuila/Desktop/data/master thesis/tables"
log using spendingrobot_twoout.smcl, replace 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="서울특별시", vce(cluster regioncode)
est store reg2

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="부산광역시" , vce(cluster regioncode)
est store reg3

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="인천광역시", vce(cluster regioncode)
est store reg4

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="대구광역시", vce(cluster regioncode)
est store reg5

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="대전광역시", vce(cluster regioncode)
est store reg6

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="광주광역시", vce(cluster regioncode)
est store reg7

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="울산광역시", vce(cluster regioncode)
est store reg8

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경기도", vce(cluster regioncode)
est store reg9

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="충청남도" | sido_nm=="충청북도", vce(cluster regioncode)
est store reg10

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", vce(cluster regioncode)
est store reg11

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="전라남도" | sido_nm=="전라북도", vce(cluster regioncode)
est store reg12

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="강원도", vce(cluster regioncode)
est store reg13

esttab reg* using Table1A_POLS_twoout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13
esttab reg* using Table1B_FE_twoout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="서울특별시", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="부산광역시", fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="인천광역시", fe cluster(regioncode) robust first 
est store reg4

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="대구광역시", fe cluster(regioncode) robust first 
est store reg5

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="대전광역시", fe cluster(regioncode) robust first 
est store reg6

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="광주광역시", fe cluster(regioncode) robust first 
est store reg7

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="울산광역시", fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="충청남도" | sido_nm=="충청북도", fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="경상남도" | sido_nm=="경상북도", fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="전라남도" | sido_nm=="전라북도", fe cluster(regioncode) robust first 
est store reg12

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm=="강원도", fe cluster(regioncode) robust first 
est store reg13
esttab reg* using Table3_FEIV_twoout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close
********************** 3.사회복지예산 + 수도권vs.비수도권 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 
log using prerobotstudy_threeout.smcl, replace 

cd "/Users/ihuila/Desktop/data/master thesis/tables"

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", vce(cluster regioncode)
est store reg2

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도" , vce(cluster regioncode)
est store reg3

esttab reg* using Table1A_POLS_threeout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3


esttab reg* using Table1B_FE_threeout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도", fe cluster(regioncode) robust first 
est store reg3

esttab reg* using Table3_FEIV_threeout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close

**********************4. 사회복지예산 + 수도권vs.비수도권 광역시 vs. 비수도권 지방 *********************
* clusterid3 에 시군구코드 변수를 넣으면 됨 

log using prerobotstudy_fourout.smcl, replace 

cd "/Users/ihuila/Desktop/data/master thesis/tables"

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", vce(cluster regioncode)
est store reg2

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0 , vce(cluster regioncode)
est store reg3

xi: reg log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0 , vce(cluster regioncode)
est store reg4

esttab reg* using Table1A_POLS_fourout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995  if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0, fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0, fe cluster(regioncode) robust first 
est store reg4

esttab reg* using Table1B_FE_fourout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation

xi: xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) , fe cluster(regioncode) robust first 
est store reg1

xi:  xtivreg2 log_welfa i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시"|sido_nm=="인천광역시"|sido_nm=="경기도", fe cluster(regioncode) robust first 
est store reg2

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")!=0, fe cluster(regioncode) robust first 
est store reg3

xi:  xtivreg2 log_welfa i.year tot_pop20 DRobot_exp_all1995 if sido_nm!="서울특별시"&sido_nm!="인천광역시"& sido_nm!="경기도"& regexm(sido_nm, "광역시")==0, fe cluster(regioncode) robust first 
est store reg4

esttab reg* using Table3_FEIV_fourout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close
******************** 5. 전국 + 사회복지예산 세부카테고리별 ***************************
* clusterid3 에 시군구코드 변수를 넣으면 됨 

cd "/Users/ihuila/Desktop/data/master thesis/tables"
log using spendingrobot_fiveout.smcl, replace 

//TABLE 1 (panel A): pooled OLS estimation results
est clear

xi: reg log_wel081 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg1

xi: reg log_wel082 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg2

xi: reg log_wel084 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg4

xi: reg log_wel085 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg5

xi: reg log_wel086 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg6

xi: reg log_wel087 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg7

xi: reg log_wel088 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg8

xi: reg log_wel089 i.year tot_pop20 DRobot_exp_all1995, vce(cluster regioncode)
est store reg9

esttab reg* using Table1A_POLS_fiveout.csv, nogap stats(N r2) title("Table 1A: POLS")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear

//TABLE 1 (panel B): fixed effect estimation results
xi: xtivreg2 log_wel081 i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 log_wel082  i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 log_wel084 i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 log_wel085 i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 log_wel086 i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 log_wel087 i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 log_wel088 i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 log_wel089 i.year tot_pop20 DRobot_exp_all1995, fe cluster(regioncode) robust first 
est store reg9

esttab reg* using Table1B_FE_fiveout.csv, nogap stats(N r2) title("Table 1B: FE")   r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
**********ROBUST STANDARD ERRORS, CLUSTERED AT LGA LEVEL:*******************
//TABLE 2: FE-IV estimation
xi: xtivreg2 log_wel081 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 log_wel082 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 log_wel084 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 log_wel085 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 log_wel086 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 log_wel087 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 log_wel088 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 log_wel089 i.year tot_pop20 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg9

esttab reg* using Table3_FEIV_fiveout.csv, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

est clear
log close

