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
use "$prof_raw/employmentCOE.dta" 

tab newindcode // 101~119 까지 사용 

keep if newindcode >= 101 & newindcode <= 119 

drop if year < 1995 

replace allempl = allempl/1000  // 1000명 단위
replace fullempl = fullempl/1000
replace partempl = partempl/1000

/*
* wood & furniture 통합 (필요 시 주석 해제)
replace newindcode = 118 if newindcode == 119
replace newind = "other manufacturing" if newindcode == 118
collapse (sum) fullempl partempl allempl firm, by(year sido_nm sigungu_nm regioncode newindcode newind)
*/

tab newindcode year 
********************************************************************** 
* 사업체 없는 (region × industry × year) 조합에 0 채우기

* ── 1. fillin 전에 string lookup 보존 ───────────────────────────────────────
* fillin은 새 행의 string 변수를 missing으로 만들므로 미리 저장
* isid: 코드 → 라벨이 진짜 1:1인지 명시 검증 (깨지면 코드 충돌)
preserve
    keep regioncode sido_nm sigungu_nm
    duplicates drop
    isid regioncode
    tempfile region_lut
    save `region_lut'
restore

preserve
    keep newindcode newind
    duplicates drop
    isid newindcode
    tempfile ind_lut
    save `ind_lut'
restore

* ── 2. fillin: 존재하지 않는 조합 추가 ──────────────────────────────────────
fillin year regioncode newindcode

* ── 3. 수치 변수 0 채우기 (사업체 없음 = 고용 0) ──────────────────────────
foreach var of varlist allempl fullempl partempl firm {
    replace `var' = 0 if _fillin == 1
}

quietly count if _fillin == 1
di "fillin 추가 셀: " r(N) "개 (전체의 " %4.1f r(N)/_N*100 "%)"

* ── 4. string 변수 lookup에서 복원 (mode() 대신 merge) ─────────────────────
* fillin이 만든 새 행 포함 모든 행이 매칭돼야 함 → assert(3)으로 보장
drop sido_nm sigungu_nm newind
merge m:1 regioncode using `region_lut', nogen assert(3)
merge m:1 newindcode  using `ind_lut',   nogen assert(3)

br 

********************************************************************
* 확인 
preserve
    bysort year regioncode: gen n_ind = _N
    assert n_ind == 19

    bysort year regioncode: keep if _n == 1
    bysort year: gen n_region = _N
    assert n_region == 229
restore
********************************************************************
* emp i,j,t 
* emp i,t 
* emp j,t 
**********************************************************************
// 원본 변수명 정리
rename allempl emp_ijt
label variable emp_ijt "All employment in region i, industry j, year t"

bysort regioncode year: egen emp_it = total(emp_ijt)
label variable emp_it "Total employment in region i, year t"

bysort newindcode year: egen emp_jt = total(emp_ijt)
label variable emp_jt "Total employment in industry j, year t"

save "$interim/COE_empl_control.dta" , replace 
*********************************************************************
* base year 기준 
*********************************************************************
foreach yr in 1995 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022  {
    preserve
        keep if year == `yr'
        keep regioncode newindcode emp_ijt emp_it emp_jt
        rename emp_ijt emp_ij`yr'
        rename emp_it  emp_i`yr'
        rename emp_jt  emp_j`yr'
        tempfile base`yr'
        save `base`yr''
    restore
    merge m:1 regioncode newindcode using `base`yr'', nogen assert(3)
    label variable emp_ij`yr' "Employment in region i, industry j, year `yr'"
    label variable emp_i`yr'  "Total employment in region i, year `yr'"
    label variable emp_j`yr'  "Total employment in industry j, year `yr'"
}

**********************************************************************
* Employment Shares 계산
********************************************************************** 
count if emp_i1995==0 // 532개(울산광역시 북구)
count if missing(emp_i1995) // 없음 
gen share95 = emp_ij1995 / emp_i1995 
replace share95 = 0 if emp_i1995==0 // 울산광역시 북구의 경우 분모가 0 (KOSIS에서 확인결과 0)
label variable share95 "Employment share (1995 base): emp_ij1995 / emp_i1995" 

foreach yr in 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 { 
	
	count if emp_i`yr' == 0 
	count if missing(emp_i`yr')
	gen share`yr' = emp_ij`yr' / emp_i`yr'
	label variable share`yr' ///
	"Employment share (`yr' base): emp_ij`yr' / emp_i`yr'"
}
*******************************************************************************
drop _fillin fullempl partempl emp_ijt emp_it emp_jt 

sort year regioncode newindcode 
// keep if year >= 2005 
// time period 1995~2022

save "$data/kor_empl.dta",replace
**********************************************************************
* 제조업만 포함 버전 (newindcode 107~119)
**********************************************************************
use "$interim/COE_empl_control.dta", clear

keep if newindcode >= 107 & newindcode <= 119

* emp_it는 전산업(제조업+비제조업) 기준 지역 총고용을 그대로 사용 (재계산하지 않음)
rename emp_ijt emp_ijt_manu
label variable emp_ijt_manu "Manufacturing employment in region i, industry j, year t"

drop emp_jt
bysort newindcode year: egen emp_jt_manu = total(emp_ijt_manu)
label variable emp_jt_manu "Total manufacturing employment in industry j, year t"

foreach yr in 1995 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022  {
    preserve
        keep if year == `yr'
        keep regioncode newindcode emp_ijt_manu emp_it emp_jt_manu
        rename emp_ijt_manu emp_ij`yr'_manu
        rename emp_it       emp_i`yr' // emp i,t 는 제조업 비제조업 모두 포함한 
        rename emp_jt_manu  emp_j`yr'_manu
        tempfile basemfg`yr'
        save `basemfg`yr''
    restore
    merge m:1 regioncode newindcode using `basemfg`yr'', nogen assert(3)
    label variable emp_ij`yr'_manu "Manufacturing employment in region i, industry j, year `yr'"
    label variable emp_i`yr'       "Total employment in region i, year `yr' (전산업 기준)"
    label variable emp_j`yr'_manu  "Total manufacturing employment in industry j, year `yr'"
}

count if emp_i1995==0
count if missing(emp_i1995)
gen share95_manu = emp_ij1995_manu / emp_i1995
replace share95_manu = 0 if emp_i1995==0
label variable share95_manu "Manufacturing employment share (1995 base): emp_ij1995_manu / emp_i1995 (전산업 대비)"

foreach yr in 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 {
	count if emp_i`yr' == 0
	count if missing(emp_i`yr')
	gen share`yr'_manu = emp_ij`yr'_manu / emp_i`yr'
	label variable share`yr'_manu ///
	"Manufacturing employment share (`yr' base): emp_ij`yr'_manu / emp_i`yr' (전산업 대비)"
}

drop _fillin fullempl partempl emp_ijt_manu emp_it emp_jt_manu

sort year regioncode newindcode

save "$data/kor_empl_mfg.dta",replace
