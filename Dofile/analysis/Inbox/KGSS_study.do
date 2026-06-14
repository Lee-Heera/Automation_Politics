use "/Users/ihuila/Desktop/meta_data/횡단/KGSS/2003-2023_KGSS.dta", clear 

// region 
tab region

gen sudo=1 if region<=2 
replace sudo=0 if sudo==. 

tab sudo 
