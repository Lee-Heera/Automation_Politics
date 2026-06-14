// 싱가폴 로봇데이터 + 통제변수 + 대선 정당별 득표율 + 대선 투표율 + 이민 데이터 
// immi0 - 외국인 주민(국적취득자, 국적미취득자, 외국인주민 자녀) 숫자, 
// p_immi0 - 위 변수의 비율 
// 
use "/Users/ihuila/Desktop/data/master thesis/after/Robot_pres_merge.dta", clear 
br

sort regioncode year 
xtset regioncode year

sort regioncode year
bysort regioncode (year): gen lag_college = college_final[_n-1]
bysort regioncode (year): gen lag_pop65   = pop65[_n-1]

global fixed i.year 
global demo lag_college lag_pop65 

ren immi_total tot_immi 

***************** 이질성 분석용 변수 만들기 ***************** 
* ============================================
* 1. 이민자 비율 변수 생성 -> 이질성분석용 (2007년도 기준)
* ============================================
gen he_p_immi0 = immi0 / pop
gen he_p_immi  = immi  / pop
gen he_p_immi2 = immi2 / pop
gen he_p_immi3 = immi3 / pop

* ============================================
* 2. 2007년 기준 중위수 더미 생성
* ============================================
foreach v in he_p_immi0 he_p_immi he_p_immi2 he_p_immi3 {
    bysort regioncode (year): gen `v'_base = `v' if year == 2007
    bysort regioncode: egen `v'_2007 = max(`v'_base)
    drop `v'_base
    
    qui sum `v'_2007, detail
    local med = r(p50)
    gen dum_`v' = (`v'_2007 >= `med') if !missing(`v'_2007)  // dum_he_p_immi0 등으로 생성
    di "중위수 (`v'): `med'"
}

rename dum_he_p_immi0 dum_high_p_immi0
rename dum_he_p_immi  dum_high_p_immi
rename dum_he_p_immi2 dum_high_p_immi2
rename dum_he_p_immi3 dum_high_p_immi3
****************************** pilot study ****************************** 
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995),fe cluster(regioncode) robust first

xi: xtivreg2 d_conserv1_p $fixed (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995),fe cluster(regioncode) robust first

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995),fe cluster(regioncode) robust first


cd "/Users/ihuila/Desktop/data/master thesis/table/pilot"
est clear
local first_table = 1
* ============================================
* 사전 설정
* ============================================
cd "/Users/ihuila/Desktop/data/master thesis/table/pilot"

* X-Z 쌍 정의
local xvar1 "DRobot_exp_all1995"
local xvar2 "DRobot_exp_all1995"
local xvar3 "DRobot_exp_u_all1995"
local xvar4 "DRobot_exp_u_all1995"

local zvar1 "SG_DRobot_exp_all1995"
local zvar2 "Z_DRobot_exp_all1995"
local zvar3 "SG_DRobot_exp_u_all1995"
local zvar4 "Z_DRobot_exp_u_all1995"

* 종속변수 쌍 정의
local dv1_1 "d_turnout"        
local dv2_1 "d_conserv1_p"
local dv1_2 "d_turnout"        
local dv2_2 "d_conserv2_p"
local dv1_3 "turnout"          
local dv2_3 "conserv1_p"
local dv1_4 "turnout"          
local dv2_4 "conserv2_p"
local dv1_5 "ld_turnout_2007"  
local dv2_5 "ld_conserv1_p_2007"
local dv1_6 "ld_turnout_2007"  
local dv2_6 "ld_conserv2_p_2007"

* suffix별 이질성 더미
local het_s1 "dum_solid_lib1 dum_solid_con1 dum_competitive1"
local het_s2 "dum_solid_lib2 dum_solid_con2 dum_competitive2"
local het_immi "dum_high_p_immi0 dum_high_p_immi dum_high_p_immi2 dum_high_p_immi3"

local first_table = 1

* ============================================
* 메인 반복문
* ============================================
forvalues p = 1/6 {
    
    * suffix 판별 (종속변수2 기준)
    local dv2 "`dv2_`p''"
    if strpos("`dv2'", "conserv1") > 0 {
        local het_solid "`het_s1'"
        local sfx "1"
    }
    else if strpos("`dv2'", "conserv2") > 0 {
        local het_solid "`het_s2'"
        local sfx "2"
    }

    forvalues i = 1/4 {
        local xvar "`xvar`i''"
        local zvar "`zvar`i''"
        local dv1  "`dv1_`p''"
        local dv2  "`dv2_`p''"

        est clear

        * Col1: 전체 dv1
        xi: xtivreg2 `dv1' $fixed $demo (`xvar'=`zvar'), fe cluster(regioncode) robust first
        local fs_F=e(first)[4,1]
        local fs_b=e(first)[1,1]
        local fs_se=e(first)[2,1]
        estimates store p`p'i`i'_c1
        estadd scalar fs_Fstat=`fs_F'
        estadd scalar fs_coef=`fs_b'
        estadd scalar fs_se=`fs_se'
        estimates store p`p'i`i'_c1

        * Col2: 전체 dv2
        xi: xtivreg2 `dv2' $fixed $demo (`xvar'=`zvar'), fe cluster(regioncode) robust first
        local fs_F=e(first)[4,1]
        local fs_b=e(first)[1,1]
        local fs_se=e(first)[2,1]
        estimates store p`p'i`i'_c2
        estadd scalar fs_Fstat=`fs_F'
        estadd scalar fs_coef=`fs_b'
        estadd scalar fs_se=`fs_se'
        estimates store p`p'i`i'_c2

        * Col3~7: solid 이질성
        local c = 3
        foreach hetvar of local het_solid {
            xi: xtivreg2 `dv2' $fixed $demo (`xvar'=`zvar') if `hetvar'==1, fe cluster(regioncode) robust
            estimates store p`p'i`i'_c`c'
            local c = `c' + 1
        }

        * Col8~11: immi 이질성
        foreach hetvar of local het_immi {
            xi: xtivreg2 `dv2' $fixed $demo (`xvar'=`zvar') if `hetvar'==1, fe cluster(regioncode) robust
            estimates store p`p'i`i'_c`c'
            local c = `c' + 1
        }

        * Col10: 수도권
        xi: xtivreg2 `dv2' $fixed $demo (`xvar'=`zvar') if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
        estimates store p`p'i`i'_c`c'
        local c = `c' + 1

        * Col11: 비수도권
        xi: xtivreg2 `dv2' $fixed $demo (`xvar'=`zvar') if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
        estimates store p`p'i`i'_c`c'

        * esttab 저장
        if `first_table' == 1 {
            esttab p`p'i`i'_c1 p`p'i`i'_c2 p`p'i`i'_c3 p`p'i`i'_c4 p`p'i`i'_c5 ///
                   p`p'i`i'_c6 p`p'i`i'_c7 p`p'i`i'_c8 p`p'i`i'_c9 p`p'i`i'_c10 p`p'i`i'_c11 ///
                using "results_all.csv", ///
                title("Pair`p': `dv1' & `dv2' | i=`i' | X:`xvar' | IV:`zvar'") ///
                keep(`xvar') ///
                stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
                star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
                mtitles("dv1(전체)" "dv2(전체)" "dv2(lib`sfx')" "dv2(con`sfx')" "dv2(comp`sfx')" ///
                        "dv2(immi0)" "dv2(immi)" "dv2(immi2)" "dv2(immi3)" ///
                        "dv2(수도권)" "dv2(비수도권)") ///
                csv replace
            local first_table = 0
        }
        else {
            esttab p`p'i`i'_c1 p`p'i`i'_c2 p`p'i`i'_c3 p`p'i`i'_c4 p`p'i`i'_c5 ///
                   p`p'i`i'_c6 p`p'i`i'_c7 p`p'i`i'_c8 p`p'i`i'_c9 p`p'i`i'_c10 p`p'i`i'_c11 ///
                using "results_all.csv", ///
                title("Pair`p': `dv1' & `dv2' | i=`i' | X:`xvar' | IV:`zvar'") ///
                keep(`xvar') ///
                stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
                star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
                mtitles("dv1(전체)" "dv2(전체)" "dv2(lib`sfx')" "dv2(con`sfx')" "dv2(comp`sfx')" ///
                        "dv2(immi0)" "dv2(immi)" "dv2(immi2)" "dv2(immi3)" ///
                        "dv2(수도권)" "dv2(비수도권)") ///
                csv append
        }

        di "완료: Pair`p' | i=`i' | X:`xvar' | Y1:`dv1' | Y2:`dv2'"
    }
}

di "전체 분석 완료!"

********************************************************************************
* PAIR 1: d_turnout + d_conserv1_p
********************************************************************************
*** i=1: X=DRobot_exp_all1995, Z=SG_DRobot_exp_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i1_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i1_c1

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i1_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i1_c2

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p1i1_c3
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p1i1_c4
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p1i1_c5
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p1i1_c6
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p1i1_c7
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p1i1_c8
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p1i1_c9
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i1_c10
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i1_c11

esttab p1i1_c1 p1i1_c2 p1i1_c3 p1i1_c4 p1i1_c5 p1i1_c6 p1i1_c7 p1i1_c8 p1i1_c9 p1i1_c10 p1i1_c11 ///
    using "results_all.csv", ///
    title("Pair1: d_turnout & d_conserv1_p | i=1 | X:DRobot_exp_all1995 | IV:SG_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con1(전체)" "d_con1(lib1)" "d_con1(con1)" "d_con1(comp1)" "d_con1(immi0)" "d_con1(immi)" "d_con1(immi2)" "d_con1(immi3)" "d_con1(수도권)" "d_con1(비수도권)") ///
    csv replace

*** i=2: X=DRobot_exp_all1995, Z=Z_DRobot_exp_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i2_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i2_c1

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i2_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i2_c2

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p1i2_c3
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p1i2_c4
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p1i2_c5
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p1i2_c6
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p1i2_c7
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p1i2_c8
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p1i2_c9
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i2_c10
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i2_c11

esttab p1i2_c1 p1i2_c2 p1i2_c3 p1i2_c4 p1i2_c5 p1i2_c6 p1i2_c7 p1i2_c8 p1i2_c9 p1i2_c10 p1i2_c11 ///
    using "results_all.csv", ///
    title("Pair1: d_turnout & d_conserv1_p | i=2 | X:DRobot_exp_all1995 | IV:Z_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con1(전체)" "d_con1(lib1)" "d_con1(con1)" "d_con1(comp1)" "d_con1(immi0)" "d_con1(immi)" "d_con1(immi2)" "d_con1(immi3)" "d_con1(수도권)" "d_con1(비수도권)") ///
    csv append

*** i=3: X=DRobot_exp_u_all1995, Z=SG_DRobot_exp_u_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i3_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i3_c1

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i3_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i3_c2

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p1i3_c3
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p1i3_c4
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p1i3_c5
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p1i3_c6
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p1i3_c7
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p1i3_c8
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p1i3_c9
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i3_c10
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i3_c11

esttab p1i3_c1 p1i3_c2 p1i3_c3 p1i3_c4 p1i3_c5 p1i3_c6 p1i3_c7 p1i3_c8 p1i3_c9 p1i3_c10 p1i3_c11 ///
    using "results_all.csv", ///
    title("Pair1: d_turnout & d_conserv1_p | i=3 | X:DRobot_exp_u_all1995 | IV:SG_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con1(전체)" "d_con1(lib1)" "d_con1(con1)" "d_con1(comp1)" "d_con1(immi0)" "d_con1(immi)" "d_con1(immi2)" "d_con1(immi3)" "d_con1(수도권)" "d_con1(비수도권)") ///
    csv append

*** i=4: X=DRobot_exp_u_all1995, Z=Z_DRobot_exp_u_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i4_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i4_c1

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p1i4_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p1i4_c2

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p1i4_c3
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p1i4_c4
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p1i4_c5
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p1i4_c6
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p1i4_c7
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p1i4_c8
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p1i4_c9
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i4_c10
xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p1i4_c11

esttab p1i4_c1 p1i4_c2 p1i4_c3 p1i4_c4 p1i4_c5 p1i4_c6 p1i4_c7 p1i4_c8 p1i4_c9 p1i4_c10 p1i4_c11 ///
    using "results_all.csv", ///
    title("Pair1: d_turnout & d_conserv1_p | i=4 | X:DRobot_exp_u_all1995 | IV:Z_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con1(전체)" "d_con1(lib1)" "d_con1(con1)" "d_con1(comp1)" "d_con1(immi0)" "d_con1(immi)" "d_con1(immi2)" "d_con1(immi3)" "d_con1(수도권)" "d_con1(비수도권)") ///
    csv append

********************************************************************************
* PAIR 2: d_turnout + d_conserv2_p
********************************************************************************

*** i=1: X=DRobot_exp_all1995, Z=SG_DRobot_exp_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i1_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i1_c1

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i1_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i1_c2

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p2i1_c3
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p2i1_c4
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p2i1_c5
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p2i1_c6
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p2i1_c7
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p2i1_c8
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p2i1_c9
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i1_c10
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i1_c11

esttab p2i1_c1 p2i1_c2 p2i1_c3 p2i1_c4 p2i1_c5 p2i1_c6 p2i1_c7 p2i1_c8 p2i1_c9 p2i1_c10 p2i1_c11 ///
    using "results_all.csv", ///
    title("Pair2: d_turnout & d_conserv2_p | i=1 | X:DRobot_exp_all1995 | IV:SG_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con2(전체)" "d_con2(lib2)" "d_con2(con2)" "d_con2(comp2)" "d_con2(immi0)" "d_con2(immi)" "d_con2(immi2)" "d_con2(immi3)" "d_con2(수도권)" "d_con2(비수도권)") ///
    csv append

*** i=2: X=DRobot_exp_all1995, Z=Z_DRobot_exp_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i2_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i2_c1

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i2_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i2_c2

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p2i2_c3
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p2i2_c4
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p2i2_c5
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p2i2_c6
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p2i2_c7
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p2i2_c8
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p2i2_c9
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i2_c10
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i2_c11

esttab p2i2_c1 p2i2_c2 p2i2_c3 p2i2_c4 p2i2_c5 p2i2_c6 p2i2_c7 p2i2_c8 p2i2_c9 p2i2_c10 p2i2_c11 ///
    using "results_all.csv", ///
    title("Pair2: d_turnout & d_conserv2_p | i=2 | X:DRobot_exp_all1995 | IV:Z_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con2(전체)" "d_con2(lib2)" "d_con2(con2)" "d_con2(comp2)" "d_con2(immi0)" "d_con2(immi)" "d_con2(immi2)" "d_con2(immi3)" "d_con2(수도권)" "d_con2(비수도권)") ///
    csv append

*** i=3: X=DRobot_exp_u_all1995, Z=SG_DRobot_exp_u_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i3_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i3_c1

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i3_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i3_c2

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p2i3_c3
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p2i3_c4
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p2i3_c5
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p2i3_c6
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p2i3_c7
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p2i3_c8
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p2i3_c9
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i3_c10
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i3_c11

esttab p2i3_c1 p2i3_c2 p2i3_c3 p2i3_c4 p2i3_c5 p2i3_c6 p2i3_c7 p2i3_c8 p2i3_c9 p2i3_c10 p2i3_c11 ///
    using "results_all.csv", ///
    title("Pair2: d_turnout & d_conserv2_p | i=3 | X:DRobot_exp_u_all1995 | IV:SG_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con2(전체)" "d_con2(lib2)" "d_con2(con2)" "d_con2(comp2)" "d_con2(immi0)" "d_con2(immi)" "d_con2(immi2)" "d_con2(immi3)" "d_con2(수도권)" "d_con2(비수도권)") ///
    csv append

*** i=4: X=DRobot_exp_u_all1995, Z=Z_DRobot_exp_u_all1995
est clear
xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i4_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i4_c1

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p2i4_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p2i4_c2

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p2i4_c3
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p2i4_c4
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p2i4_c5
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p2i4_c6
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p2i4_c7
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p2i4_c8
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p2i4_c9
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i4_c10
xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p2i4_c11

esttab p2i4_c1 p2i4_c2 p2i4_c3 p2i4_c4 p2i4_c5 p2i4_c6 p2i4_c7 p2i4_c8 p2i4_c9 p2i4_c10 p2i4_c11 ///
    using "results_all.csv", ///
    title("Pair2: d_turnout & d_conserv2_p | i=4 | X:DRobot_exp_u_all1995 | IV:Z_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("d_turn(전체)" "d_con2(전체)" "d_con2(lib2)" "d_con2(con2)" "d_con2(comp2)" "d_con2(immi0)" "d_con2(immi)" "d_con2(immi2)" "d_con2(immi3)" "d_con2(수도권)" "d_con2(비수도권)") ///
    csv append

********************************************************************************
* PAIR 3: turnout + conserv1_p
********************************************************************************

*** i=1
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i1_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i1_c1

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i1_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i1_c2

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p3i1_c3
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p3i1_c4
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p3i1_c5
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p3i1_c6
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p3i1_c7
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p3i1_c8
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p3i1_c9
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i1_c10
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i1_c11

esttab p3i1_c1 p3i1_c2 p3i1_c3 p3i1_c4 p3i1_c5 p3i1_c6 p3i1_c7 p3i1_c8 p3i1_c9 p3i1_c10 p3i1_c11 ///
    using "results_all.csv", ///
    title("Pair3: turnout & conserv1_p | i=1 | X:DRobot_exp_all1995 | IV:SG_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con1(전체)" "con1(lib1)" "con1(con1)" "con1(comp1)" "con1(immi0)" "con1(immi)" "con1(immi2)" "con1(immi3)" "con1(수도권)" "con1(비수도권)") ///
    csv append

*** i=2
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i2_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i2_c1

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i2_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i2_c2

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p3i2_c3
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p3i2_c4
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p3i2_c5
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p3i2_c6
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p3i2_c7
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p3i2_c8
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p3i2_c9
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i2_c10
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i2_c11

esttab p3i2_c1 p3i2_c2 p3i2_c3 p3i2_c4 p3i2_c5 p3i2_c6 p3i2_c7 p3i2_c8 p3i2_c9 p3i2_c10 p3i2_c11 ///
    using "results_all.csv", ///
    title("Pair3: turnout & conserv1_p | i=2 | X:DRobot_exp_all1995 | IV:Z_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con1(전체)" "con1(lib1)" "con1(con1)" "con1(comp1)" "con1(immi0)" "con1(immi)" "con1(immi2)" "con1(immi3)" "con1(수도권)" "con1(비수도권)") ///
    csv append

*** i=3
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i3_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i3_c1

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i3_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i3_c2

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p3i3_c3
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p3i3_c4
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p3i3_c5
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p3i3_c6
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p3i3_c7
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p3i3_c8
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p3i3_c9
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i3_c10
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i3_c11

esttab p3i3_c1 p3i3_c2 p3i3_c3 p3i3_c4 p3i3_c5 p3i3_c6 p3i3_c7 p3i3_c8 p3i3_c9 p3i3_c10 p3i3_c11 ///
    using "results_all.csv", ///
    title("Pair3: turnout & conserv1_p | i=3 | X:DRobot_exp_u_all1995 | IV:SG_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con1(전체)" "con1(lib1)" "con1(con1)" "con1(comp1)" "con1(immi0)" "con1(immi)" "con1(immi2)" "con1(immi3)" "con1(수도권)" "con1(비수도권)") ///
    csv append

*** i=4
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i4_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i4_c1

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p3i4_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p3i4_c2

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p3i4_c3
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p3i4_c4
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p3i4_c5
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p3i4_c6
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p3i4_c7
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p3i4_c8
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p3i4_c9
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i4_c10
xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p3i4_c11

esttab p3i4_c1 p3i4_c2 p3i4_c3 p3i4_c4 p3i4_c5 p3i4_c6 p3i4_c7 p3i4_c8 p3i4_c9 p3i4_c10 p3i4_c11 ///
    using "results_all.csv", ///
    title("Pair3: turnout & conserv1_p | i=4 | X:DRobot_exp_u_all1995 | IV:Z_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con1(전체)" "con1(lib1)" "con1(con1)" "con1(comp1)" "con1(immi0)" "con1(immi)" "con1(immi2)" "con1(immi3)" "con1(수도권)" "con1(비수도권)") ///
    csv append

********************************************************************************
* PAIR 4: turnout + conserv2_p
********************************************************************************

*** i=1
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i1_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i1_c1

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i1_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i1_c2

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p4i1_c3
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p4i1_c4
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p4i1_c5
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p4i1_c6
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p4i1_c7
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p4i1_c8
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p4i1_c9
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i1_c10
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i1_c11

esttab p4i1_c1 p4i1_c2 p4i1_c3 p4i1_c4 p4i1_c5 p4i1_c6 p4i1_c7 p4i1_c8 p4i1_c9 p4i1_c10 p4i1_c11 ///
    using "results_all.csv", ///
    title("Pair4: turnout & conserv2_p | i=1 | X:DRobot_exp_all1995 | IV:SG_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con2(전체)" "con2(lib2)" "con2(con2)" "con2(comp2)" "con2(immi0)" "con2(immi)" "con2(immi2)" "con2(immi3)" "con2(수도권)" "con2(비수도권)") ///
    csv append

*** i=2
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i2_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i2_c1

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i2_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i2_c2

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p4i2_c3
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p4i2_c4
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p4i2_c5
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p4i2_c6
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p4i2_c7
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p4i2_c8
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p4i2_c9
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i2_c10
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i2_c11

esttab p4i2_c1 p4i2_c2 p4i2_c3 p4i2_c4 p4i2_c5 p4i2_c6 p4i2_c7 p4i2_c8 p4i2_c9 p4i2_c10 p4i2_c11 ///
    using "results_all.csv", ///
    title("Pair4: turnout & conserv2_p | i=2 | X:DRobot_exp_all1995 | IV:Z_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con2(전체)" "con2(lib2)" "con2(con2)" "con2(comp2)" "con2(immi0)" "con2(immi)" "con2(immi2)" "con2(immi3)" "con2(수도권)" "con2(비수도권)") ///
    csv append

*** i=3
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i3_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i3_c1

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i3_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i3_c2

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p4i3_c3
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p4i3_c4
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p4i3_c5
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p4i3_c6
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p4i3_c7
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p4i3_c8
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p4i3_c9
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i3_c10
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i3_c11

esttab p4i3_c1 p4i3_c2 p4i3_c3 p4i3_c4 p4i3_c5 p4i3_c6 p4i3_c7 p4i3_c8 p4i3_c9 p4i3_c10 p4i3_c11 ///
    using "results_all.csv", ///
    title("Pair4: turnout & conserv2_p | i=3 | X:DRobot_exp_u_all1995 | IV:SG_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con2(전체)" "con2(lib2)" "con2(con2)" "con2(comp2)" "con2(immi0)" "con2(immi)" "con2(immi2)" "con2(immi3)" "con2(수도권)" "con2(비수도권)") ///
    csv append

*** i=4
est clear
xi: xtivreg2 turnout $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i4_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i4_c1

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p4i4_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p4i4_c2

xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p4i4_c3
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p4i4_c4
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p4i4_c5
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p4i4_c6
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p4i4_c7
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p4i4_c8
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p4i4_c9
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i4_c10
xi: xtivreg2 conserv2_p $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p4i4_c11

esttab p4i4_c1 p4i4_c2 p4i4_c3 p4i4_c4 p4i4_c5 p4i4_c6 p4i4_c7 p4i4_c8 p4i4_c9 p4i4_c10 p4i4_c11 ///
    using "results_all.csv", ///
    title("Pair4: turnout & conserv2_p | i=4 | X:DRobot_exp_u_all1995 | IV:Z_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("turn(전체)" "con2(전체)" "con2(lib2)" "con2(con2)" "con2(comp2)" "con2(immi0)" "con2(immi)" "con2(immi2)" "con2(immi3)" "con2(수도권)" "con2(비수도권)") ///
    csv append

********************************************************************************
* PAIR 5: ld_turnout_2007 + ld_conserv1_p_2007
********************************************************************************

*** i=1
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i1_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i1_c1

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i1_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i1_c2

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p5i1_c3
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p5i1_c4
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p5i1_c5
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p5i1_c6
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p5i1_c7
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p5i1_c8
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p5i1_c9
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i1_c10
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i1_c11

esttab p5i1_c1 p5i1_c2 p5i1_c3 p5i1_c4 p5i1_c5 p5i1_c6 p5i1_c7 p5i1_c8 p5i1_c9 p5i1_c10 p5i1_c11 ///
    using "results_all.csv", ///
    title("Pair5: ld_turnout_2007 & ld_conserv1_p_2007 | i=1 | X:DRobot_exp_all1995 | IV:SG_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con1(전체)" "ld_con1(lib1)" "ld_con1(con1)" "ld_con1(comp1)" "ld_con1(immi0)" "ld_con1(immi)" "ld_con1(immi2)" "ld_con1(immi3)" "ld_con1(수도권)" "ld_con1(비수도권)") ///
    csv append

*** i=2
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i2_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i2_c1

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i2_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i2_c2

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p5i2_c3
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p5i2_c4
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p5i2_c5
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p5i2_c6
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p5i2_c7
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p5i2_c8
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p5i2_c9
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i2_c10
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i2_c11

esttab p5i2_c1 p5i2_c2 p5i2_c3 p5i2_c4 p5i2_c5 p5i2_c6 p5i2_c7 p5i2_c8 p5i2_c9 p5i2_c10 p5i2_c11 ///
    using "results_all.csv", ///
    title("Pair5: ld_turnout_2007 & ld_conserv1_p_2007 | i=2 | X:DRobot_exp_all1995 | IV:Z_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con1(전체)" "ld_con1(lib1)" "ld_con1(con1)" "ld_con1(comp1)" "ld_con1(immi0)" "ld_con1(immi)" "ld_con1(immi2)" "ld_con1(immi3)" "ld_con1(수도권)" "ld_con1(비수도권)") ///
    csv append

*** i=3
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i3_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i3_c1

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i3_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i3_c2

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p5i3_c3
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p5i3_c4
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p5i3_c5
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p5i3_c6
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p5i3_c7
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p5i3_c8
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p5i3_c9
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i3_c10
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i3_c11

esttab p5i3_c1 p5i3_c2 p5i3_c3 p5i3_c4 p5i3_c5 p5i3_c6 p5i3_c7 p5i3_c8 p5i3_c9 p5i3_c10 p5i3_c11 ///
    using "results_all.csv", ///
    title("Pair5: ld_turnout_2007 & ld_conserv1_p_2007 | i=3 | X:DRobot_exp_u_all1995 | IV:SG_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con1(전체)" "ld_con1(lib1)" "ld_con1(con1)" "ld_con1(comp1)" "ld_con1(immi0)" "ld_con1(immi)" "ld_con1(immi2)" "ld_con1(immi3)" "ld_con1(수도권)" "ld_con1(비수도권)") ///
    csv append

*** i=4
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i4_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i4_c1

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p5i4_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p5i4_c2

xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_lib1==1, fe cluster(regioncode) robust
estimates store p5i4_c3
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_con1==1, fe cluster(regioncode) robust
estimates store p5i4_c4
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_competitive1==1, fe cluster(regioncode) robust
estimates store p5i4_c5
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p5i4_c6
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p5i4_c7
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p5i4_c8
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p5i4_c9
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i4_c10
xi: xtivreg2 ld_conserv1_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p5i4_c11

esttab p5i4_c1 p5i4_c2 p5i4_c3 p5i4_c4 p5i4_c5 p5i4_c6 p5i4_c7 p5i4_c8 p5i4_c9 p5i4_c10 p5i4_c11 ///
    using "results_all.csv", ///
    title("Pair5: ld_turnout_2007 & ld_conserv1_p_2007 | i=4 | X:DRobot_exp_u_all1995 | IV:Z_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con1(전체)" "ld_con1(lib1)" "ld_con1(con1)" "ld_con1(comp1)" "ld_con1(immi0)" "ld_con1(immi)" "ld_con1(immi2)" "ld_con1(immi3)" "ld_con1(수도권)" "ld_con1(비수도권)") ///
    csv append

********************************************************************************
* PAIR 6: ld_turnout_2007 + ld_conserv2_p_2007
********************************************************************************

*** i=1
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i1_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i1_c1

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i1_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i1_c2

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p6i1_c3
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p6i1_c4
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p6i1_c5
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p6i1_c6
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p6i1_c7
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p6i1_c8
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p6i1_c9
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i1_c10
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=SG_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i1_c11

esttab p6i1_c1 p6i1_c2 p6i1_c3 p6i1_c4 p6i1_c5 p6i1_c6 p6i1_c7 p6i1_c8 p6i1_c9 p6i1_c10 p6i1_c11 ///
    using "results_all.csv", ///
    title("Pair6: ld_turnout_2007 & ld_conserv2_p_2007 | i=1 | X:DRobot_exp_all1995 | IV:SG_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con2(전체)" "ld_con2(lib2)" "ld_con2(con2)" "ld_con2(comp2)" "ld_con2(immi0)" "ld_con2(immi)" "ld_con2(immi2)" "ld_con2(immi3)" "ld_con2(수도권)" "ld_con2(비수도권)") ///
    csv append

*** i=2
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i2_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i2_c1

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i2_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i2_c2

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p6i2_c3
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p6i2_c4
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p6i2_c5
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p6i2_c6
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p6i2_c7
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p6i2_c8
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p6i2_c9
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i2_c10
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i2_c11

esttab p6i2_c1 p6i2_c2 p6i2_c3 p6i2_c4 p6i2_c5 p6i2_c6 p6i2_c7 p6i2_c8 p6i2_c9 p6i2_c10 p6i2_c11 ///
    using "results_all.csv", ///
    title("Pair6: ld_turnout_2007 & ld_conserv2_p_2007 | i=2 | X:DRobot_exp_all1995 | IV:Z_DRobot_exp_all1995") ///
    keep(DRobot_exp_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con2(전체)" "ld_con2(lib2)" "ld_con2(con2)" "ld_con2(comp2)" "ld_con2(immi0)" "ld_con2(immi)" "ld_con2(immi2)" "ld_con2(immi3)" "ld_con2(수도권)" "ld_con2(비수도권)") ///
    csv append

*** i=3
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i3_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i3_c1

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i3_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i3_c2

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p6i3_c3
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p6i3_c4
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p6i3_c5
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p6i3_c6
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p6i3_c7
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p6i3_c8
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p6i3_c9
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i3_c10
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i3_c11

esttab p6i3_c1 p6i3_c2 p6i3_c3 p6i3_c4 p6i3_c5 p6i3_c6 p6i3_c7 p6i3_c8 p6i3_c9 p6i3_c10 p6i3_c11 ///
    using "results_all.csv", ///
    title("Pair6: ld_turnout_2007 & ld_conserv2_p_2007 | i=3 | X:DRobot_exp_u_all1995 | IV:SG_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con2(전체)" "ld_con2(lib2)" "ld_con2(con2)" "ld_con2(comp2)" "ld_con2(immi0)" "ld_con2(immi)" "ld_con2(immi2)" "ld_con2(immi3)" "ld_con2(수도권)" "ld_con2(비수도권)") ///
    csv append

*** i=4
est clear
xi: xtivreg2 ld_turnout_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i4_c1
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i4_c1

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995), fe cluster(regioncode) robust first
local fs_F=e(first)[4,1]
local fs_b=e(first)[1,1]
local fs_se=e(first)[2,1]
estimates store p6i4_c2
estadd scalar fs_Fstat=`fs_F'
estadd scalar fs_coef=`fs_b'
estadd scalar fs_se=`fs_se'
estimates store p6i4_c2

xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_lib2==1, fe cluster(regioncode) robust
estimates store p6i4_c3
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_solid_con2==1, fe cluster(regioncode) robust
estimates store p6i4_c4
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_competitive2==1, fe cluster(regioncode) robust
estimates store p6i4_c5
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi0==1, fe cluster(regioncode) robust
estimates store p6i4_c6
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi==1, fe cluster(regioncode) robust
estimates store p6i4_c7
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi2==1, fe cluster(regioncode) robust
estimates store p6i4_c8
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if dum_high_p_immi3==1, fe cluster(regioncode) robust
estimates store p6i4_c9
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i4_c10
xi: xtivreg2 ld_conserv2_p_2007 $fixed $demo (DRobot_exp_u_all1995=Z_DRobot_exp_u_all1995) if !inlist(sido_nm,"서울특별시","경기도","인천광역시"), fe cluster(regioncode) robust
estimates store p6i4_c11

esttab p6i4_c1 p6i4_c2 p6i4_c3 p6i4_c4 p6i4_c5 p6i4_c6 p6i4_c7 p6i4_c8 p6i4_c9 p6i4_c10 p6i4_c11 ///
    using "results_all.csv", ///
    title("Pair6: ld_turnout_2007 & ld_conserv2_p_2007 | i=4 | X:DRobot_exp_u_all1995 | IV:Z_DRobot_exp_u_all1995") ///
    keep(DRobot_exp_u_all1995) ///
    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
    star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ///
    mtitles("ld_turn(전체)" "ld_con2(전체)" "ld_con2(lib2)" "ld_con2(con2)" "ld_con2(comp2)" "ld_con2(immi0)" "ld_con2(immi)" "ld_con2(immi2)" "ld_con2(immi3)" "ld_con2(수도권)" "ld_con2(비수도권)") ///
    csv append

di "전체 분석 완료!"

/*
*********** HETEROGENEITY ANALYSIS 3: manufacuring factories 
est clear 
xi:  xtivreg2 vote $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmafirm==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmafirm == 1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

xi:  xtivreg2 vote $fixed  $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highmafirm==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg4

xi:  xtivreg2 new $fixed  $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highmafirm ==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg5

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 
 
*********************** 수도권 / 비수도권 
est clear 

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm== "서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm!= "서울특별시" & sido_nm!="경기도" & sido_nm!="인천광역시" , fe cluster(regioncode) robust first 
est store reg2


xi: xtivreg2 turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm== "서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 turnout $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm!= "서울특별시" & sido_nm!="경기도" & sido_nm!="인천광역시" , fe cluster(regioncode) robust first 
est store reg4 


esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 


est clear 

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm== "서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm!= "서울특별시" & sido_nm!="경기도" & sido_nm!="인천광역시" , fe cluster(regioncode) robust first 
est store reg2


xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm== "서울특별시" | sido_nm=="경기도" | sido_nm=="인천광역시" , fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_u_all1995=SG_DRobot_exp_u_all1995) if sido_nm!= "서울특별시" & sido_nm!="경기도" & sido_nm!="인천광역시" , fe cluster(regioncode) robust first 
est store reg4 


esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 
*/


