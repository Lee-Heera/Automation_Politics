pwd 
cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/"

use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_final2.dta", clear 

sort pid year 
duplicates report pid year

xtset pid year 
***************** 변수 다듬기 
** dependent var 
// 정치성향 pga020  - 숫자클수록 보수적 
gen poli=pga020  // 

//gen welfare=pgb100//보편복지 대 선별복지 pgb100 
gen welfare = pgb080 
tab welfare // 숫자 커질수록 확대 (1~3)
gen ability = pgb070 // 소득격차 줄이기 위해 중요한 것 pgb070, 숫자클수록 개인능력 중요 

************************** demographic characteristics 
* gender 
bysort pid (year): gen gender = pwgen if year == minyear
bysort pid (year): replace gender = gender[_n-1] if missing(gender)

* education
/*
미취학 1 
초등학교 2
중학교 3
고등학교 4
대학교 4년제미만 5
4년제이상 6
대학원 석사 7
대학원 박사 8
모름/무응답 -9 
*/
/*
-9 모름무응답 
1 재학 
2 졸업 
3 수료 
4 중퇴 
5 휴학 
*/
sort pid year
bysort pid (year): gen edu = pwedu if _n == 1
bysort pid (year): replace edu = edu[_n-1] if missing(edu)

bysort pid (year): gen grd = pwgrd if _n == 1
bysort pid (year): replace grd = grd[_n-1] if missing(grd)

gen college = .
replace college = 1 if edu==7 | edu==8 // 석박사 
replace college = 1 if edu==6 & grd==2 // 4년제 대졸 
replace college= 0 if college==. 
replace college=. if edu==-9 | grd==-9 

tab college 

* income - p__inc_all 
gen inc=p__inc_all

* home ownership - hba002 
gen hown = 1  if hba002==1 
replace hown=0 if hba002 >=2 & hba002<=6 
tab hown

* region 

* job - pwjob 

* age - pwbyr 
gen age = year-pwbyr
tabstat age, stat(mean sd)

*********************************************
// 지역단위통제변수 넣으면 cluster 되는데, 안넣으면 cluster 옵션 안됨 
*xi: xtivreg2 poli i.year (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(clusterid) robust first 
***********************political orientation 
sort pid year 
xtset pid year 

local demo L.college_final L.pop65 

est clear 
xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0), fe cluster(clusterid) robust first // left 
est store reg1

xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0) if hown==1, fe cluster(clusterid) robust first // 
est store reg2 

xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0) if hown==0, fe cluster(clusterid) robust first // left 
est store reg3 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

*************************
est clear 
xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0), fe cluster(clusterid) robust first // left 
est store reg1

xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0) if college==1, fe cluster(clusterid) robust first // left (marginal) 
est store reg2 

xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0) if college==0, fe cluster(clusterid) robust first // left 
est store reg3 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 
**********************
est clear 
xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0), fe cluster(clusterid) robust first // left 
est store reg1

xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0) if sido_nm=="서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시", fe cluster(clusterid) robust first // left 
est store reg2 

xi: xtivreg28 poli i.year $demo (p_immi0=p_iv_immi0) if sido_nm!="서울특별시" & sido_nm!="경기도" & sido_nm!="인천광역시", fe cluster(clusterid) robust first // 
est store reg3 

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

