use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterksdc_presi/KSDCrobotmerge.dta", clear

sort regioncode year 
xtset regioncode year

xi: xtivreg28 poliatt_mean i.year pop65 college_final (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first

xi: xtivreg28 poliatt_median i.year pop65 college_final (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first

xi: xtivreg28 regula_mean i.year pop65 college_final (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first

xi: xtivreg28 regula_median i.year pop65 college_final (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first

xi: xtivreg28 redistri_mean i.year pop65 college_final (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first

xi: xtivreg28 redistri_median i.year pop65 college_final (DRobot_exp_all1995=SG_DRobot_exp_all1995) , fe cluster(regioncode) robust first
