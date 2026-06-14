// 싱가폴 로봇데이터 + 통제변수 + 대선 정당별 득표율 + 대선 투표율 + 이민 데이터 
// immi0 - 외국인 주민(국적취득자, 국적미취득자, 외국인주민 자녀) 숫자, 
// p_immi0 - 위 변수의 비율 
// 
use "/Users/ihuila/Desktop/data/master thesis/after/Robot_local_merge.dta", clear 
br

sort regioncode year 
xtset regioncode year

sort regioncode year
bysort regioncode (year): gen lag_college = college_final[_n-1]
bysort regioncode (year): gen lag_pop65   = pop65[_n-1]

global fixed i.year 
global demo lag_college lag_pop65 

ren immi_total tot_immi 

****************************** pilot study ****************************** 
xi:xtivreg2 loc_d_conserv1_p $fixed (DRobot_exp_all1994 = Z_DRobot_exp_all1994), fe cluster(regioncode) robust first 

***************** automation, immigration, political polarization 
est clear 

global xvar_list  "DRobot_exp_all1995 DRobot_exp_all1995 DRobot_exp_u_all1995 DRobot_exp_u_all1995"
global zvar_list  "SG_DRobot_exp_all1995 Z_DRobot_exp_all1995 SG_DRobot_exp_u_all1995 Z_DRobot_exp_u_all1995"
global n_robot = 4

local depvars     "loc_turnout loc_conserv1_p"
local depvars_dif "loc_d_turnout loc_d_conserv1_p"
local depvars_longdif "loc_ld_turnout_2006 loc_ld_conserv1_p_2006"

local depgroup_list "depvars depvars_dif depvars_longdif"

/*
global imm_level_list "immi0 immi immi2 immi3"
global imm_iv_level   "iv_immi0 iv_immi iv_immi2 iv_immi3"
global n_imm_lv = 4

global imm_ratio_list "p_immi0 p_immi p_immi2 p_immi3"
global imm_iv_ratio   "p_iv_immi0 p_iv_immi p_iv_immi2 p_iv_immi3"
global n_imm_rt = 4
*/


* ============================================
* 각 경우의 수에 맞게 루프문으로 분석, 
* X-Z 쌍은 총 4가지 
* Y 변수는 총 세가지 종류에 대해 3가지 버전

* 총 model 36개 
* ============================================
cd "/Users/ihuila/Desktop/data/master thesis/table/pilot"
est clear

local first_table_2nd = 1
local first_table_1st = 1

forvalues i = 1/$n_robot {
    local xvar = word("$xvar_list", `i')
    local zvar = word("$zvar_list", `i')

    foreach dg of local depgroup_list {
        local estnames_2nd ""
        local estnames_1st ""

        foreach depvar of local `dg' {
            local estname_2nd "a`i'_`depvar'"
            local estname_1st "a`i'_`depvar'_fs"

            cap qui xi: xtivreg2 `depvar' $fixed $demo ///
                (`xvar' = `zvar'), ///
                fe cluster(regioncode) robust first

            if _rc == 0 {
                * Second-stage 저장
                estimates store `estname_2nd'
                local estnames_2nd "`estnames_2nd' `estname_2nd'"

                * First-stage: e(first) 매트릭스에서 직접 꺼내기
                mat fs_`estname_1st' = e(first)
                * F-stat, 계수 등 first-stage 스칼라 저장
                local fs_F    = e(first)[4,1]   // F-statistic
                local fs_b    = e(first)[1,1]   // 계수
                local fs_se   = e(first)[2,1]   // SE

                * 임시 추정치로 저장 (postfile 방식)
                * → 간단하게 second-stage에 estadd로 붙이기
                estimates restore `estname_2nd'
                estadd scalar fs_Fstat = `fs_F'
                estadd scalar fs_coef  = `fs_b'
                estadd scalar fs_se    = `fs_se'
                estimates store `estname_2nd'   // 업데이트

                local estnames_1st "`estnames_1st' `estname_1st'"
            }
            else {
                di as error "FAILED: i=`i' | X=`xvar' | Z=`zvar' | Y=`depvar'"
            }
        }

        * ---- Second-stage CSV 저장 ----
        if "`estnames_2nd'" != "" {
            if `first_table_2nd' == 1 {
                esttab `estnames_2nd' using "results_2nd_stage.csv", ///
                    title("2nd Stage | i=`i' | X: `xvar' | IV: `zvar' | Group: `dg'") ///
                    keep(`xvar') ///
                    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
                    star(* 0.1 ** 0.05 *** 0.01) ///
                    b(3) se(3) ///
                    mtitles("Turnout" "Conserv1_p" "Conserv2_p") ///
                    csv replace
                local first_table_2nd = 0
            }
            else {
                esttab `estnames_2nd' using "local_results_2nd_stage.csv", ///
                    title("2nd Stage | i=`i' | X: `xvar' | IV: `zvar' | Group: `dg'") ///
                    keep(`xvar') ///
                    stats(N r2_within fs_Fstat, labels("N" "R2 within" "1st-stage F")) ///
                    star(* 0.1 ** 0.05 *** 0.01) ///
                    b(3) se(3) ///
                    mtitles("Turnout" "Conserv1_p" "Conserv2_p") ///
                    csv append
            }
        }
    }
}

di "저장 완료: local_results_2nd_stage.csv"

****************************************************************************
*********** HETEROGENEITY ANALYSIS 2: 이민자 밀집 지역 
est clear 
xi:  xtivreg2 d_turnout $fixed  $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highimmi==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg2

xi:  xtivreg2 d_conserv1_p $fixed  $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highimmi==1, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg3

xi:  xtivreg2 vote $fixed $demo  (DRobot_exp_all1995=Z_DRobot_exp_all1995) if highimmi==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg4

xi:  xtivreg2 new $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995)  if highimmi==0, fe cluster(regioncode) robust first savefprefix(fs_)
est store reg5

esttab reg* , nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

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
 
***************************** 이질성 분석 
***** Solid conserva, Solid liberal, Competitive  (difference)
est clear 

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive1==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive2==1 , fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib1==1 , fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib2==1 , fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con1==1 , fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 d_turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con2==1 , fe cluster(regioncode) robust first 
est store reg6

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 


est clear 

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive1==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib1==1 , fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 d_conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con1==1 , fe cluster(regioncode) robust first 
est store reg5


esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 


est clear 

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive2==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib2==1 , fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 d_conserv2_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con2==1 , fe cluster(regioncode) robust first 
est store reg5


esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 

***** Solid conserva, Solid liberal, Competitive - vote share 

est clear 

xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive1==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive2==1 , fe cluster(regioncode) robust first 
est store reg2

xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib1==1 , fe cluster(regioncode) robust first 
est store reg3

xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib2==1 , fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con1==1 , fe cluster(regioncode) robust first 
est store reg5

xi: xtivreg2 turnout $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con2==1 , fe cluster(regioncode) robust first 
est store reg6

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 


est clear 

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive1==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib1==1 , fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 conserv1_p $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con1==1 , fe cluster(regioncode) robust first 
est store reg5


esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) // 


est clear 

xi: xtivreg2 conserv2_p  $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if dum_competitive2==1 , fe cluster(regioncode) robust first 
est store reg1

xi: xtivreg2 conserv2_p  $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_lib2==1 , fe cluster(regioncode) robust first 
est store reg4

xi: xtivreg2 conserv2_p  $fixed $demo (DRobot_exp_all1995=Z_DRobot_exp_all1995) if  dum_solid_con2==1 , fe cluster(regioncode) robust first 
est store reg5

esttab reg*, nogap stats(N cdf arf arfp) title("Table 2: FEIV")  r2(%8.3f) b(%8.3f) se(%8.3f) label star(* 0.10 ** 0.05 *** 0.01) //

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


 

