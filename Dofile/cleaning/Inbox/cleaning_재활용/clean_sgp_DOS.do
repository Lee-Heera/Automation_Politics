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
	
	
/*******************************************************************************
	import excel
*******************************************************************************/
import excel "$prof_raw/mrsd_65_annl_emp_lvl_by_ind_singapore.xlsx", sheet("SSIC1996") cellrange(A3) firstrow clear
//drop SSIC1996
forvalues i = 1990(1)2000 {
	rename Dec`i' sgp_empl`i'

	destring sgp_empl`i', force replace
}
drop if Industry == ""
drop N O P
save "$interim/DOS/sgp_empl1.dta", replace


import excel "$prof_raw/mrsd_65_annl_emp_lvl_by_ind_singapore.xlsx", sheet("SSIC2005") cellrange(A3) firstrow clear
//drop SSIC2005
	rename C sgp_empl2001
	rename D sgp_empl2002
	rename E sgp_empl2003
	rename F sgp_empl2004
	rename G sgp_empl2005
	rename H sgp_empl2006
	rename I sgp_empl2007
forvalues i = 2001(1)2007 {
	destring sgp_empl`i', force replace
}
drop if Industry == ""
drop J - O
save "$interim/DOS/sgp_empl2.dta", replace

import excel "$prof_raw/mrsd_65_annl_emp_lvl_by_ind_singapore.xlsx", sheet("SSIC2020") cellrange(A3) firstrow clear
//drop SSIC2020
	rename C sgp_empl2008
	rename D sgp_empl2009
	rename E sgp_empl2010
	rename F sgp_empl2011
	rename G sgp_empl2012
	rename H sgp_empl2013
	rename I sgp_empl2014
	rename J sgp_empl2015
	rename K sgp_empl2016
	rename L sgp_empl2017
	rename M sgp_empl2018
	rename N sgp_empl2019
	rename O sgp_empl2020
	rename P sgp_empl2021
	rename Q sgp_empl2022
	rename R sgp_empl2023
	rename S sgp_empl2024
	rename T sgp_empl2025
forvalues i = 2008(1)2025 {
	destring sgp_empl`i', force replace
}
drop if Industry == ""
drop U - W
save "$interim/DOS/sgp_empl3.dta", replace

/*******************************************************************************
 sgp_empl2, sgp_empl3 cleaning (about non-manufacturing industries)
********************************************************************************/
use "$interim/DOS/sgp_empl2.dta", clear 

ren Industry SSIC2005nm 

ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

// 산업분류 
* 106: Services 
gen newindcode = 106 if inlist(SSIC2005 , "G50-51", "H52-56", "J58")
replace newindcode = 106 if inlist(SSIC2005, "K60-63", "L65-66", "M70-71", "O78") 

* 104: Construction 
replace newindcode = 104 if SSIC2005  == "F45" 

* 999: 수동조절 
replace  newindcode = 999 if inlist(SSIC2005 , "N73-76", "P80-V99")
replace  newindcode = 999 if inlist(SSIC2005 , "N75-76", "P80")

* 998 -> 분리예정 
replace newindcode = 998 if SSIC2005 == "A, B, D, E, W"

order newindcode SSIC2005 SSIC2005nm 

keep if newindcode !=. 

*--------------------------------------------
* Step : 998 → A=101, B=102, D&E=103, W=300 분리
*--------------------------------------------
expand 4 if newindcode == 998

bysort SSIC2005nm: gen _seq = _n if newindcode == 998

foreach var of varlist sgp_empl2001-sgp_empl2007 {
    replace `var' = `var' / 4 if newindcode == 998
}

replace newindcode = 101 if newindcode == 998 & _seq == 1
replace newindcode = 102 if newindcode == 998 & _seq == 2
replace newindcode = 103 if newindcode == 998 & _seq == 3
replace newindcode = 300 if newindcode == 998 & _seq == 4

replace SSIC2005nm = "Agriculture, forestry, fishing" if newindcode == 101
replace SSIC2005nm = "Mining and quarrying"           if newindcode == 102
replace SSIC2005nm = "Electricity, gas, water supply" if newindcode == 103
replace SSIC2005nm = "Unspecified"               if newindcode == 300

drop _seq

*--------------------------------------------
* Step 4: 999 수동 조정
*--------------------------------------------
preserve
    use "$interim/DOS/sgp_empl2.dta", clear
    ren Industry SSIC2005nm
	
	ds, has(type string)
	foreach var of varlist `r(varlist)' {
		replace `var' = ustrtrim(`var') if !missing(`var')
	}
	
    keep if inlist(SSIC2005, "N73-76", "N75-76", "P80-V99", "P80")

    gen newindcode = .

    * --- N73-76 처리 ---
    * N73-76행: N75-76 절반만큼 차감 → 106
    foreach var of varlist sgp_empl2001-sgp_empl2007 {
        quietly sum `var' if SSIC2005 == "N75-76"
        local n7576_half = r(sum) * 0.5
        replace `var' = `var' - `n7576_half' if SSIC2005 == "N73-76"
    }
    replace newindcode = 106 if SSIC2005 == "N73-76"

    * N75-76행: 절반만 → 105
    foreach var of varlist sgp_empl2001-sgp_empl2007 {
        replace `var' = `var' * 0.5 if SSIC2005 == "N75-76"
    }
    replace newindcode = 105 if SSIC2005 == "N75-76"

    * --- P80-V99 처리 ---
    * P80-V99행: P80만큼 차감 → 106
    foreach var of varlist sgp_empl2001-sgp_empl2007 {
        quietly sum `var' if SSIC2005 == "P80"
        local p80_val = r(sum)
        replace `var' = `var' - `p80_val' if SSIC2005 == "P80-V99"
    }
    replace newindcode = 106 if SSIC2005 == "P80-V99"

    * P80행: 그대로 → 105
    replace newindcode = 105 if SSIC2005 == "P80"

    * 확인
    list SSIC2005 newindcode sgp_empl2001

    tempfile n_p_adjusted
    save `n_p_adjusted'
restore

drop if newindcode == 999
drop if newindcode == 300 
append using `n_p_adjusted'


collapse (sum) sgp_empl2001-sgp_empl2007, by(newindcode)

reshape long  sgp_empl, i(newindcode) j(year)

save "$interim/DOS/sgp_empl2_clean.dta", replace 
/*******************************************************************************
 sgp_empl3 cleaning (SSIC2020)
********************************************************************************/
use "$interim/DOS/sgp_empl3.dta", clear
ren Industry SSIC2020nm

ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}

*--------------------------------------------
* Step 1: 산업분류
*--------------------------------------------
gen newindcode = .

* 106: Services
replace newindcode = 106 if inlist(SSIC2020, "G46-47", "H49-53", "I55-56")
replace newindcode = 106 if inlist(SSIC2020, "J58-63", "K64-66", "L68")
replace newindcode = 106 if inlist(SSIC2020, "N77-82")

* 104: Construction
replace newindcode = 104 if SSIC2020 == "F41-43"

* 999: 수동조절
replace newindcode = 999 if inlist(SSIC2020, "M69-75", "M72-75")
replace newindcode = 999 if inlist(SSIC2020, "O84-U99", "O85")

* 998: A,B,D,E 분리예정
replace newindcode = 998 if SSIC2020 == "A, B, D, E"

order newindcode SSIC2020 SSIC2020nm
keep if newindcode != .

*--------------------------------------------
* Step 2: 998 → A=101, B=102, D&E=103 분리
* W 없으므로 3개로만 분리
*--------------------------------------------
expand 3 if newindcode == 998

bysort SSIC2020nm: gen _seq = _n if newindcode == 998

foreach var of varlist sgp_empl2008-sgp_empl2025 {
    replace `var' = `var' / 3 if newindcode == 998
}

replace newindcode = 101 if newindcode == 998 & _seq == 1
replace newindcode = 102 if newindcode == 998 & _seq == 2
replace newindcode = 103 if newindcode == 998 & _seq == 3

replace SSIC2020nm = "Agriculture, forestry, fishing" if newindcode == 101
replace SSIC2020nm = "Mining and quarrying"           if newindcode == 102
replace SSIC2020nm = "Electricity, gas, water supply" if newindcode == 103

drop _seq

*--------------------------------------------
* Step 3: 999 수동 조정 (tempfile)
*--------------------------------------------
preserve
    use "$interim/DOS/sgp_empl3.dta", clear
    ren Industry SSIC2020nm

    ds, has(type string)
    foreach var of varlist `r(varlist)' {
        replace `var' = ustrtrim(`var') if !missing(`var')
    }

    keep if inlist(SSIC2020, "M69-75", "M72-75", "O84-U99", "O85")

    gen newindcode = .

    * --- M69-75 처리 ---
    * M69-75행: M72-75 * 1/4 만큼 차감 → 106
    foreach var of varlist sgp_empl2008-sgp_empl2025 {
        quietly sum `var' if SSIC2020 == "M72-75"
        local m7275_quarter = r(sum) * 0.25
        replace `var' = `var' - `m7275_quarter' if SSIC2020 == "M69-75"
    }
    replace newindcode = 106 if SSIC2020 == "M69-75"

    * M72-75행: 1/4만 → 105
    foreach var of varlist sgp_empl2008-sgp_empl2025 {
        replace `var' = `var' * 0.25 if SSIC2020 == "M72-75"
    }
    replace newindcode = 105 if SSIC2020 == "M72-75"

    * --- O84-U99 처리 ---
    * O84-U99행: O85 만큼 차감 → 106
    foreach var of varlist sgp_empl2008-sgp_empl2025 {
        quietly sum `var' if SSIC2020 == "O85"
        local o85_val = r(sum)
        replace `var' = `var' - `o85_val' if SSIC2020 == "O84-U99"
    }
    replace newindcode = 106 if SSIC2020 == "O84-U99"

    * O85행: 그대로 → 105
    replace newindcode = 105 if SSIC2020 == "O85"

    list SSIC2020 newindcode sgp_empl2008

    tempfile m_o_adjusted
    save `m_o_adjusted'
restore

*--------------------------------------------
* Step 4: 999 제거 후 append
*--------------------------------------------
drop if newindcode == 999
append using `m_o_adjusted'

collapse (sum) sgp_empl2008-sgp_empl2025, by(newindcode)

reshape long sgp_empl, i(newindcode) j(year)

sort newindcode year

save "$interim/DOS/sgp_empl3_clean.dta", replace

/*
**********************************************************************
* 제조업만 포함 버전 (newindcode 107~119)
**********************************************************************
use "$interim/DOS/sgp_empl2_clean.dta", clear
keep if newindcode >= 107 & newindcode <= 119
save "$interim/DOS/sgp_empl2_clean_mfg.dta", replace

use "$interim/DOS/sgp_empl3_clean.dta", clear
keep if newindcode >= 107 & newindcode <= 119
save "$interim/DOS/sgp_empl3_clean_mfg.dta", replace
*/

