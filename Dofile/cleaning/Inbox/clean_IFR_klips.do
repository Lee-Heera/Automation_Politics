**********************************************************************  
* Robot and automation
* Singapore Employment Statistics clean do-file
**********************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global data "${main}/Data cleaned"
	global interim "${main}/Data interim"
	global final "${main}/Data final"
	global prof_raw "${main}/Data raw/professor_raw"	
	/*
	global ifr "${main}/Data raw/IFR"
	global kepco  "${main}/Data raw/KEPCO"
	global oarlr "${main}/Data raw/OARLR"
	global singapore "${main}/Data raw/Singapore"
	*/
	
********************************************************************** 
use "$prof_raw/IFR2023_industry.dta" 

merge m:1 industry using "$prof_raw/RobotInd.dta"
tab _merge // all matched 
drop _merge 

compress 
destring newindcode, replace 
drop delivered // operatinoal stock만 사용 

// 필터링 
keep if country == "Singapore" | country == "Rep. of Korea"
keep if year>=2005

tab newindcode, m  // 100=all industries, 200 = metal, unspecified, 300 = unspecified 

drop if newindcode==100 | newindcode == 200 
drop if newindcode==. 

bysort year country: egen tot_opstock = total(op_stock) // unspeicified, classified 포함 total stock 

sort country year newindcode 
tab newindcode // 각산업별로 동일 관측치 개수인지 확인하기 
tab year 
tab year country // unspecified 포함 20개씩 
********************************************************************** 
* STEP 3: total unclassified (300번만)
********************************************************************** 
gen is_unclas = (newindcode == 300)

* unclassified 총합 (year-country 단위)
bysort year country: egen tot_unclas = total(op_stock * is_unclas)
label variable tot_unclas "Total unclassified op_stock (300번)"
********************************************************************** 
* STEP 4: total classified (unclassified 제외한 나머지)
********************************************************************** 
bysort year country: egen classified_opstock = total(op_stock * (is_unclas == 0))
label variable classified_opstock "Total classified op_stock (300번 제외)"

**********************************************************************
* STEP 5: 300번 행 제거
**********************************************************************
sort country year newindcode 
order year country industrycode industry newind newindcode countrycode op_stock tot_opstock is_unclas tot_unclas classified_opstock

// drop if is_unclas == 1

**********************************************************************
* STEP 6: 산업비중 계산 (in classified data)
**********************************************************************
gen ind_share_opstock = op_stock / classified_opstock if newindcode !=300 
label variable ind_share_opstock "산업비중: op_stock_j / classified_opstock"

sort country year newindcode 
**********************************************************************
* STEP 7: unclassified 배분 → 최종값
**********************************************************************
gen final_opstock = op_stock + (tot_unclas * ind_share_opstock) if newindcode !=300 
label variable final_opstock "배분후 최종 op_stock (adjusted)"

sort year country newindcode 

drop if newindcode ==300 

/*
* 검증 
bys year country: egen final_sum = total(final_opstock)
count if final_sum != tot_opstock
br if final_sum != tot_opstock 
*/

********************************************************************** 
* STEP 8: Reshape 
* country-year-industry → year-industry (국가별 변수 분리) 
* -> industry 단위 데이터로 
**********************************************************************
drop country industrycode industry op_stock tot_opstock tot_unclas classified_opstock ind_share_opstock is_unclas 
		   
// Reshape: long → wide
reshape wide final_opstock, i(year newindcode newind) j(countrycode) string

save "$interim/IFR/IFR_long.dta",replace 

rename final_opstockKR rb_kr 
rename final_opstockSG rb_sg

xtset newindcode year 
bys newindcode : gen drobot_kr = rb_kr - L1.rb_kr 
bys newindcode : gen drobot_sg = rb_sg - L1.rb_sg 

save "$data/IFR_long.dta", replace  

/*
********************************************************************** 
* STEP 9: Construct Variable (difference in the stock of robot in each country)
**********************************************************************
foreach ctr in sg kr { 
	** 대선 
	gen drobot_`ctr'_0722 = rb_`ctr'2022 - rb_`ctr'2007
	
	gen drobot_`ctr'_0712 = rb_`ctr'2012 - rb_`ctr'2007
	gen drobot_`ctr'_1217 = rb_`ctr'2017 - rb_`ctr'2012
	gen drobot_`ctr'_1722 = rb_`ctr'2022 - rb_`ctr'2017
	
	gen drobot_`ctr'_0717 = rb_`ctr'2017 - rb_`ctr'2007

	/*
	** 총선 
	gen drobot_`ctr'_1216 = rb_`ctr'2016 - rb_`ctr'2012
	gen drobot_`ctr'_1220 = rb_`ctr'2020 - rb_`ctr'2012
	gen drobot_`ctr'_1620 = rb_`ctr'2020 - rb_`ctr'2016
	*/
}
*/
// save "$data/IFR_robot.dta", replace  

/*
********************************************************************** 
* wood & furniture 통합
********************************************************************** 
replace newindcode = 118 if newindcode == 119
replace newind = "other manufacturing" if newindcode == 118

collapse (sum) op_stock delivered, by(year country newindcode newind)
*/

/*
**********************************************************************
* STEP 10: 저장 — Long Difference
**********************************************************************

* ── 대선 LD ──────────────────────────────────────────────────────────
preserve
    keep newindcode newind drobot_sg_0712 drobot_sg_0717 drobot_sg_0722 drobot_sg_1222
    save "$data/IFR_LD_대선.dta", replace
restore

* ── 총선 LD ──────────────────────────────────────────────────────────
preserve
    keep newindcode newind drobot_sg_1216 drobot_sg_1220
    save "$data/IFR_LD_총선.dta", replace
restore

**********************************************************************
* STEP 11: 저장 — Stacked Difference
**********************************************************************

* ── 대선 SD (cohort: 1217, 1722) ─────────────────────────────────────
preserve
    keep newindcode newind drobot_sg_1217 drobot_sg_1722
    reshape long drobot_sg_, i(newindcode newind) j(cohort) string
    rename drobot_sg_ drobot_sg
    label variable drobot_sg "ΔRobot_sg (싱가포르, 해당 코호트 구간)"
    save "$data/IFR_SD_대선.dta", replace
restore

* ── 총선 SD (cohort: 1216, 1620) ─────────────────────────────────────
preserve
    keep newindcode newind drobot_sg_1216 drobot_sg_1620
    reshape long drobot_sg_, i(newindcode newind) j(cohort) string
    rename drobot_sg_ drobot_sg
    label variable drobot_sg "ΔRobot_sg (싱가포르, 해당 코호트 구간)"
    save "$data/IFR_SD_총선.dta", replace
restore
*/

/*

xtivreg vote_choice Z_controls i.year ///
    (regional_exposure = singapore_iv), ///
    fe vce(cluster p_region)
	*/
	