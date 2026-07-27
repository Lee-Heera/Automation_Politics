********************* 지역별 합산데이터도 만들기 
use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_long.dta", clear 

keep if pga020 !=. 

collapse (mean) mean_pga020 = pga020 ///
         (median) median_pga020 = pga020 ///
         (min) min_pga020 = pga020 ///
         (max) max_pga020 = pga020 ///
         (count) n_pga020 = pga020 ///
		, by(sido_nm sigungu_nm year)
		 
save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_longregion.dta", replace 
**********************
// 1. 통제변수 머지하기 
use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_longregion.dta", clear 
 
merge m:n year sido_nm sigungu_nm using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/sigungucontrol.dta"

tab year if _merge==1 
// 1. 2024년도 데이터 
// 2. 제주도 

drop if _merge==1 

tab year if _merge==2 
br if _merge==2 & year>2015 
// 1. 재정패널에 없는 연도 (2007~2015)
// 2. 재정패널에 없는 지역 (주로 시골들)

drop if _merge==2 & year<2015 
drop if _merge==1 & year<2015
drop if _merge==1 & year==2024 

drop _merge

// 2. 싱가포르 로봇 + 원래 로봇데이터 합친 것 머지하기 
merge m:n year sido_nm sigungu_nm using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/SG_robot.dta"

tab year if _merge==1  // 없음 

tab year if _merge==2 // 2007~2014년도 데이터 

drop if _merge==2 
drop _merge 

tab year // 모든연도 229개씩 시군구 있음 

//3. immigrant 데이터 추가머지하기 
merge m:n sido_nm sigungu_nm year using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/KOREA_immigration_clean.dta"

br if _merge==1  // 제주도 (immigrant 데이터에는 제주도 없음)
drop if _merge==1 

tab year if _merge==2 // 2007~2014년도 데이터 
drop if _merge==2 
drop _merge

// 4. manufacturing 데이터 추가 머지하기 
merge m:n sido_nm sigungu_nm year using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftermanu/2010_2023.dta"

tab year if _merge==1 // 없음 

tab year if _merge==2 
br if _merge==2 & year>2014 & year<2023 

// 1. 2010~2014년도 데이터 
// 2. 2023년도 데이터 (재정패널에만 있음)
// 3. 제주도 
// 4. 마산+진해 (2015, 2016)

keep if _merge==3 
drop _merge

duplicates list regioncode year

tab year // 227개의 시군구 

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_longregion_final.dta",replace 


