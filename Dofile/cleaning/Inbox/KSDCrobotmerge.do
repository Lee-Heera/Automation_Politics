use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterksdc_presi/KSDCmerge.dta", clear 

merge m:n sido_nm sigungu_nm year using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/SG_robot.dta"

br if _merge==1 // 제주 

keep if _merge==3 

drop _merge

merge m:n sido_nm sigungu_nm year using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftercontrol/sigungucontrol.dta"

keep if _merge==3 

drop _merge

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterksdc_presi/KSDCrobotmerge.dta", replace 
***********************************
