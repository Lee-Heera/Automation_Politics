clear 
set more off 
set matsize 2000

use "/Users/ihuila/Desktop/data/master thesis/prerobot2.dta"
cd "/Users/ihuila/Desktop/data/master thesis/tables2"

sort year regioncode 
xtset regioncode year
gen logtot20 = log(tot_pop20)
gen logtot = log(tot_pop)

xi: xtivreg2 new (DRobot_exp_all1995=Z_DRobot_exp_all1995) logtot20  i.year if sido_nm=="경기도" | sido_nm=="서울특별시" | sido_nm=="인천광역시" , fe robust cluster(regioncode) first // 수도권 - conserv 

xi: xtivreg2 new i.year logtot (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm=="서울특별시" | sido_nm=="경기도"|sido_nm=="인천광역시" , fe cluster(regioncode) robust first 

xi: xtivreg2 new i.year tot_pop (DRobot_exp_all1995=Z_DRobot_exp_all1995) if sido_nm!="서울특별시" & sido_nm!="경기도"& sido_nm!="인천광역시" , fe cluster(regioncode) robust first  // 대선은 통제변수 조정해야할듯, high educated 등 

xi: xtivreg2 new i.year 인구수 자치단체예산규모 교부액 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 

xi: xtivreg2 new i.year L.재정자립도최종개편전 (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 

