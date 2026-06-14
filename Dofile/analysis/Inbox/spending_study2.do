*******************************************************************
use "/Users/ihuila/Desktop/data/master thesis/spendingrobot2.dta", clear 


ren 재정자립도 inde

/*
ren 지방세액 localtax
ren 교부액 gyubu 
ren 세출결산액 texpend
ren 자치단체예산규모 tbudget 
*/

sort regioncode year
duplicates drop sigungu_nm sido_nm year, force 

xtset regioncode year   

cd "/Users/ihuila/Desktop/data/master thesis/tables2"

******************************* 전국 - 재정 대범주 *******************************************
**** IV 95년도로 
est clear 
xi: xtivreg2 logwelfare (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logedu (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 logadmin (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logpubsafe (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logenvir (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logregion1 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logagri (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg8

xi: xtivreg2 logart (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg9

xi: xtivreg2 logtech (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg10

xi: xtivreg2 logindus (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg11

xi: xtivreg2 logtrans (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg12

esttab reg* using Table3_FEIV재정대분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정대분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

******************* 사회복지 - 재정소범주 
est clear 
xi: xtivreg2 logwelfare081 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logwelfare082 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logwelfare084 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 logwelfare085 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logwelfare086 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logwelfare087 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg6

xi: xtivreg2 logwelfare088 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg7

xi: xtivreg2 logwelfare089 (DRobot_exp_all1995=Z_DRobot_exp_all1995) i.year L.인구수 L.교부액, fe cluster(regioncode) robust first 
est store reg8

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 

***************** 건강 - 소분류 
est clear 

xi: xtivreg2 loghealth091  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 loghealth093 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

***************** 교육 - 소분류 
est clear 
 
xi: xtivreg2 logedu051  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logedu052 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logedu053 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

***************** 일반행정 - 소분류 
est clear 
 
xi: xtivreg2 logadmin011   i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logadmin013 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logadmin014 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 logadmin016  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

**************** 공공질서안전 - 소분류
est clear 
 
xi: xtivreg2 logpubsafe023  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logpubsafe025 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logpubsafe026 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append


**************** 환경 - 소분류
est clear 
 
xi: xtivreg2 logenvir071   i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logenvir072 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logenvir073 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 logenvir074  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logenvir075 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logenvir076  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg6

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

**************** 지역개발 - 소분류
est clear 
 
xi: xtivreg2 logregion141  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logregion142 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logregion143 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

*************** 농림수산 - 소분류 
est clear 
 
xi: xtivreg2 logagri101  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logagri102 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logagri103 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

*************** 문화및관광 - 소분류 
est clear 
 
xi: xtivreg2 logart061   i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logart062 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logart063 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 logart064  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logart065 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append
************** 산업 - 소분류
est clear 
 
xi: xtivreg2 logindus111   i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logindus112 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logindus113 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 logindus114  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logindus115 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 logindus116  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg6

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append


************** 수송및교통 - 소부뉼 
est clear 
 
xi: xtivreg2 logtrans121   i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 logtrans123 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 logtrans124 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 logtrans125  i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 logtrans126 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
est store reg5

esttab reg* using Table3_FEIV재정소분류.csv, nogap stats(N cdf arf arfp) title("Table 3: FEIV_재정소분류")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) append

/*
***********************************사회복지예산 - 수도권 vs. 비수도권 ******************
est clear 

xi: xtivreg2 logwelfare i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg1 

xi: xtivreg2 logwelfare i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm!="서울특별시" & sido_nm!="경기도" & sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg2

esttab reg*, nogap stats(N cdf arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 


************** 사회복지 - 기초생활 지원 
xi: xtivreg2 logwelfare082 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg1 

xi: xtivreg2 logwelfare082 i.year L.인구수 L.자치단체예산규모 L.교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm!="서울특별시" & sido_nm!="경기도" & sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg2

esttab reg*, nogap stats(N cdf arf arfp) r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) 
*/
