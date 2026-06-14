clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftergender"
use genderbudgetrobot.dta

global cont i.year L.college_final L.pop65
sort regioncode year 
duplicates drop regioncode year, force 

xtset regioncode year 

gen loggen=log(성인지예산액)

xi: xtivreg2 loggen $cont (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first 
