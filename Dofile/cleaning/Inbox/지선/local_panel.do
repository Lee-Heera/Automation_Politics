clear 

cd "/Users/ihuila/Desktop/data/master thesis/afterlocal/"

use 2006/2006localmerge.dta 

append using 2010/2010localmerge.dta 

append using 2014/2014localmerge.dta 

append using 2018/2018localmerge.dta 

append using 2022/2022localmerge.dta 

tab year 

// 2006, 2010년도는 세종시 없어서 228개 

// 제주도 이름 변경 
replace sido_nm = "제주특별자치도" if sido_nm == "제주도"

******************************** 지역코드 매치
merge m:1 sido_nm sigungu_nm year  using "/Users/ihuila/Desktop/data/master thesis/after/sigungu_code.dta" 

tab year if _merge== 1 // 지선데이터 - 2006년도 데이터 
tab year if _merge== 2 // 대선이 없던 연도 + 2010년도 세종특별자치시 데이터 

keep if _merge ==1 | _merge ==3 

**** 2006년도 지역코드 넣어주기 
* 1단계: 2010년 코드 따로 저장
preserve
    keep if year == 2010
    keep sido_nm sigungu_nm countyid regioncode
    rename countyid countyid_2010
    rename regioncode regioncode_2010
    tempfile code_2010
    save `code_2010'
restore

* 2단계: 머지
merge m:1 sido_nm sigungu_nm using `code_2010', keep(master match) nogen

* 3단계: 2006년 관측치에만 코드 채워넣기
replace countyid   = countyid_2010   if year == 2006 & missing(countyid)
replace regioncode = regioncode_2010 if year == 2006 & missing(regioncode)

drop countyid_2010 regioncode_2010
drop _merge

order sido_nm sigungu_nm year 선거인수 투표수 유효투표수 무효투표 기권 

************************************** 4단계: 변수만들기 
* Votes 
// 거대양당만 
gen loc_liberal1_st = cond(missing(열린우리당), 0, 열린우리당) + cond(missing(민주당), 0, 민주당) + cond(missing(새정치민주연합), 0, 새정치민주연합) + cond(missing(더불어민주당), 0, 더불어민주당) 

gen loc_conserv1_st = cond(missing(한나라당), 0, 한나라당) + cond(missing(새누리당), 0, 새누리당) + cond(missing(자유한국당), 0, 자유한국당) +  cond(missing(국민의힘), 0, 국민의힘)

* Two-party vote share
gen loc_conserv1_p = loc_conserv1_st / (loc_conserv1_st + loc_liberal1_st)
gen loc_liberal1_p = loc_liberal1_st / (loc_conserv1_st + loc_liberal1_st)


* Turnout
gen loc_turnout = 투표수 / 선거인수

* Change in. two-party vote share (4년 단위)
sort regioncode year
bysort regioncode (year): gen loc_d_conserv1_p = loc_conserv1_p - loc_conserv1_p[_n-1] ///
    if year - year[_n-1] == 4   // 지선은 4년 단위

bysort regioncode (year): gen loc_d_turnout = loc_turnout - loc_turnout[_n-1] ///
    if year - year[_n-1] == 4
	
* Long difference (기준: 2006년)
bysort regioncode (year): gen base_loc_conserv1_p_2006 = loc_conserv1_p if year == 2006
bysort regioncode (year): egen loc_conserv1_p_base2006 = max(base_loc_conserv1_p_2006)

bysort regioncode (year): gen base_loc_turnout_2006 = loc_turnout if year == 2006
bysort regioncode (year): egen loc_turnout_base2006 = max(base_loc_turnout_2006)

gen loc_ld_conserv1_p_2006 = loc_conserv1_p - loc_conserv1_p_base2006 if year != 2006
gen loc_ld_turnout_2006    = loc_turnout    - loc_turnout_base2006      if year != 2006

drop base_loc_conserv1_p_2006 base_loc_turnout_2006 ///
     loc_conserv1_p_base2006 loc_turnout_base2006
****************************************************** 
***** 지역 내 특정 정당이 55% 초과 유지되는지 dummy, 
** solid liberal, solid conserva, competitive 지역 변수 만들기 

* Solid/Competitive dummy
gen loc_lib1_over55 = (loc_liberal1_p > 0.55) if !missing(loc_liberal1_p)  & year != 2006 
gen loc_con1_over55 = (loc_conserv1_p > 0.55) if !missing(loc_conserv1_p) & year != 2006 

bysort regioncode: egen loc_solid_lib1 = min(loc_lib1_over55) if year != 2006
bysort regioncode: egen loc_solid_con1 = min(loc_con1_over55) if year != 2006

gen loc_dum_solid_lib1   = (loc_solid_lib1 == 1) if year != 2006
gen loc_dum_solid_con1   = (loc_solid_con1 == 1) if year != 2006
gen loc_dum_competitive1 = (loc_dum_solid_lib1 == 0 & loc_dum_solid_con1 == 0) if year != 2006

*********************************************************
* Labels
label variable loc_liberal1_st  "Liberal votes - local election (major parties)"
label variable loc_conserv1_st  "Conservative votes - local election (major parties)"
label variable loc_conserv1_p   "Conservative two-party vote share - local election"
label variable loc_liberal1_p   "Liberal two-party vote share - local election"
label variable loc_turnout       "Turnout - local election (투표수/선거인수)"
label variable loc_d_conserv1_p "Change in conservative vote share - local (t - t-1)"
label variable loc_d_turnout     "Change in turnout - local (t - t-1)"
label variable loc_dum_solid_lib1   "Solid Liberal - local (>55% all elections)"
label variable loc_dum_solid_con1   "Solid Conservative - local (>55% all elections)"
label variable loc_dum_competitive1 "Competitive - local"
label variable loc_ld_conserv1_p_2006 "Long diff: loc_conserv1_p - 2006 base"
label variable loc_ld_turnout_2006    "Long diff: loc_turnout - 2006 base"

*********************************************Robustness check 
* 1. 기본 분포 확인
tab loc_dum_solid_lib1 if year != 2006
tab loc_dum_solid_con1 if year != 2006
tab loc_dum_competitive1 if year != 2006

* 2. 세 더미 mutually exclusive & exhaustive
gen check_dum1 = loc_dum_solid_lib1 + loc_dum_solid_con1 + loc_dum_competitive1
tab check_dum1 if year != 2006
// 1만 나와야 정상
drop check_dum1

* 3. lib과 con 동시에 1인 케이스 없는지
tab loc_dum_solid_lib1 loc_dum_solid_con1 if year != 2006
// 1,1 케이스 없어야 정상

* 4. 지역별 연도 간 일관성
bysort regioncode: egen check_lib1_consistency = sd(loc_dum_solid_lib1) if year != 2006
tab check_lib1_consistency if year != 2006
// 0만 나와야 정상
drop check_lib1_consistency

bysort regioncode: egen check_con1_consistency = sd(loc_dum_solid_con1) if year != 2006
tab check_con1_consistency if year != 2006
drop check_con1_consistency

* 5. 몇 개 지역이 각 카테고리에 속하는지
preserve
    keep if year == 2010
    tab loc_dum_solid_lib1
    tab loc_dum_solid_con1
    tab loc_dum_competitive1
restore

* 6. vote share 분포 확인
sum loc_conserv1_p loc_liberal1_p if year != 2006
// 두 변수 합이 1이어야 함
gen check_share = loc_conserv1_p + loc_liberal1_p
tab check_share if year != 2006
drop check_share

* 7. turnout 범위 확인 (0~1 사이여야 함)
sum loc_turnout
// min 0, max 1 사이여야 정상

* 8. long difference 확인 (2006년은 missing이어야 함)
tab year if !missing(loc_ld_conserv1_p_2006)
// 2006 없어야 정상

sum loc_ld_conserv1_p_2006 loc_ld_turnout_2006 if year != 2006

* 9. d_ 변수 확인 (2006, 2010년은 missing이어야 함)
tab year if !missing(loc_d_conserv1_p)
// 2006 없어야 정상 (첫 차분은 2010 기준)
sum loc_d_conserv1_p loc_d_turnout if year != 2006
********************************************************* 
drop 선거인수 투표수 유효투표수 무효투표 기권 열린우리당 한나라당 민주당 새누리당 새정치민주연합 더불어민주당 자유한국당 국민의힘

drop loc_lib1_over55 loc_con1_over55 loc_solid_lib1 loc_solid_con1 

save local_panel.dta, replace 
