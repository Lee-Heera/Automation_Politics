/*==========================================================
* 1) 1~7차년도 지역코드 (klisp) 정리 (로봇데이터 기준으로)
* 2) 8~27차년도 지역코드 (klips) 정리 (로봇데이터 기준으로)
* 3) 그리고 klips 원자료 - 지역명 변수 붙이기 
* 4) 지역명을 기준으로(sido_nm, sigungu_nm) 로봇데이터의 시군구코드(regioncode)
* 5) regioncode 기준으로 Robot 데이터 머지 
 *==========================================================*/
 **********************************************************************  
* Robot and automation
* Singapore Employment Statistics clean do-file
**********************************************************************
clear all

set more off

global main    "/Users/ihuila/Research/MASTER_thesis"
global data "${main}/Data cleaned"
global raw     "${main}/Data raw"
global interim "${main}/Data interim"
global prof_raw "${main}/Data raw/professor_raw"
global final "${main}/Data final"

global codebook "${raw}/Klips27/1-27차년도 통합코드북_가구,개인,직업력,오픈코드북(release용).xls"

/*==========================================================
 * PART A: 지역코드 크로스워크 테이블 생성
 *==========================================================*/

*----------------------------------------------------------
* A1. 구코드 크로스워크 (1차-8차, Excel columns F-I)
*     매핑: (p_region=sido_old, h0142=sgg_old) → sigungu_nm
*
*     Excel 구조 (시군구명 시트):
*       행 1-4: 헤더/공백 (drop)
*       행 5+:  데이터
*       열 F: 시도코드(=p_region), G: 시도명, H: 시군구코드(=h0142), I: 시군구명
*
*     시군구명 표준화 규칙:
*       - 광역시/특별시: 구(자치구) 수준 → 단어 1개 (예: "강남구")
*       - 일반도: 일반구는 parent 시로 집계 → 첫 번째 단어만
*         예: "고양시 덕양구" → "고양시", "성남시 분당구" → "성남시"
*----------------------------------------------------------
import excel "$codebook", sheet("시군구명") allstring clear

drop in 1/4   // 헤더/공백 행 제거
keep F-I 

rename (F G H I) (sido_raw sido_nm sgg_raw sggnm_raw)

drop if missing(sido_raw) | sido_raw == ""
destring sido_raw, gen(p_region) force
destring sgg_raw,  gen(h0142)   force
drop if missing(p_region)

* 시군구명 표준화: 첫 번째 단어 (공백으로 분리)
* 광역시 구명은 단어 1개 → 그대로 유지
* 일반구 "성남시 분당구" → "성남시" (자동 집계)
gen sigungu_nm = word(trim(sggnm_raw), 1)

keep p_region sido_nm h0142 sigungu_nm sggnm_raw
label var p_region   "시도코드 (= sido_old = KLIPS p_region)"
label var sido_nm     "시도명"
label var h0142      "시군구코드 (= sgg_old = KLIPS h0142)"
label var sigungu_nm "시군구명 (표준화: 일반구→parent 시 집계)"

******************************** 시도, 시군구명 정리 
* 인천광역시 남구 -> 미추홀구 
replace sigungu_nm="미추홀구"  if sigungu_nm=="남구" & sido_nm=="인천광역시" 

* 연기군 -> 세종특별자치시로
replace sido_nm="세종특별자치시" if sigungu_nm=="연기군" 
replace sigungu_nm="세종특별자치시" if sigungu_nm=="연기군" 

* 청원군 -> 청주시로 
replace sigungu_nm="청주시" if sigungu_nm=="청원군" 

* 북제주군 -> 제주시 
* 남제주군 -> 서귀포시 
replace sido_nm="제주특별자치도" if sido_nm=="제주도" 
replace sigungu_nm="제주시" if sigungu_nm=="북제주군"
replace sigungu_nm="서귀포시" if sigungu_nm=="남제주군"

* 마산,창원, 진해 -> 창원 
replace sigungu_nm="창원시" if sigungu_nm=="진해시" 
replace sigungu_nm="창원시" if sigungu_nm=="마산시" 

* 여주군 -> 여주시
replace sigungu_nm="여주시" if sigungu_nm=="여주군"

* 당진군 -> 당진시 
 replace sigungu_nm="당진시" if sigungu_nm=="당진군"
 
* 포천군 -> 포천시 
replace sigungu_nm = "포천시" if sigungu_nm=="포천군" 

* 양주군 -> 양주시 
replace sigungu_nm = "양주시" if sigungu_nm=="양주군" 

sort p_region h0142
save "${interim}/Klips/klips_region_old.dta", replace
di "[A1] 구코드 크로스워크 (1-8차): " _N " 행 저장"

*----------------------------------------------------------
* A2. 신코드 크로스워크 (9차 이후, Excel columns B-E)
*     주의: 신코드는 sgg=0 (모름) 행 없음, sgg=1부터 시작
*----------------------------------------------------------
import excel "$codebook", sheet("시군구명") allstring clear
keep B C D E 
drop in 1/3 
rename (B C D E) (sido_raw sido_nm sgg_raw sggnm_raw)

drop if missing(sido_raw) | sido_raw == ""
drop if sido_raw == "광역시도코드"   // 컬럼 헤더 잔여 행
destring sido_raw, gen(p_region) force
destring sgg_raw,  gen(h0142)   force
drop if missing(p_region) | missing(h0142)

gen sigungu_nm = word(trim(sggnm_raw), 1)

keep p_region sido_nm h0142 sigungu_nm sggnm_raw
label var p_region   "시도코드 (KLIPS p_region)"
label var sido_nm     "시도명"
label var h0142      "시군구코드 (KLIPS h0142)"
label var sigungu_nm "시군구명 (표준화: 일반구→parent 시 집계)"

******************************** 시도, 시군구명 정리 
* 인천광역시 남구 -> 미추홀구 
replace sigungu_nm="미추홀구"  if sigungu_nm=="남구" & sido_nm=="인천광역시" 

* 연기군 -> 세종특별자치시로
replace sido_nm="세종특별자치시" if sigungu_nm=="연기군" 
replace sigungu_nm="세종특별자치시" if sigungu_nm=="연기군" 
replace sigungu_nm="세종특별자치시" if sigungu_nm=="시군구없음"

* 청원군 -> 청주시로 
replace sigungu_nm="청주시" if sigungu_nm=="청원군" 

* 북제주군 -> 제주시 
* 남제주군 -> 서귀포시 
replace sido_nm="제주특별자치도" if sido_nm=="제주도" 
replace sigungu_nm="제주시" if sigungu_nm=="북제주군"
replace sigungu_nm="서귀포시" if sigungu_nm=="남제주군"

* 마산,창원, 진해 -> 창원 
replace sigungu_nm="창원시" if sigungu_nm=="진해시" 
replace sigungu_nm="창원시" if sigungu_nm=="마산시" 
replace sigungu_nm="창원시" if sigungu_nm=="마산시(회원구)" 

* 여주군 -> 여주시
replace sigungu_nm="여주시" if sigungu_nm=="여주군"

* 당진군 -> 당진시 
replace sigungu_nm="당진시" if sigungu_nm=="당진군->당진시로"
 
sort p_region h0142
save "${interim}/Klips/klips_region_new.dta", replace
di "[A2] 신코드 크로스워크 (9차+): " _N " 행 저장"

********************************************************************
use "${raw}/Klips27/Klips_long_260522.dta", clear 
keep if wave<=8 

merge m:1 p_region h0142 using "${interim}/Klips/klips_region_old.dta"

order year p_region h0142 sido_nm sigungu_nm 
br if _merge==2 // klips 결측 

drop if _merge==2 

// 시/군/구 단위 결측 
drop if h0142==. 
drop if h0142==-1 
// _merge==1에서 19개 삭제 

br if _merge==1 // 결측  

replace sido_nm = "전라남도" if p_region==13 & h0142==5 
replace sigungu_nm = "여수시" if p_region==13 & h0142==5 

replace sido_nm = "전라남도" if p_region==13 & h0142==6 
replace sigungu_nm = "여수시" if p_region==13 & h0142==6 

replace sido_nm = "경기도" if p_region==8 & h0142==40 
replace sigungu_nm = "안산시" if p_region==8 & h0142==40 

replace sido_nm = "경기도" if p_region==8 & h0142==41
replace sigungu_nm = "안산시" if p_region==8 & h0142==41 

replace sido_nm = "경기도" if p_region==8 & h0142==42 
replace sigungu_nm = "수원시" if p_region==8 & h0142==42 

replace sido_nm = "충청북도" if p_region==10 & h0142==13 
replace sigungu_nm = "증평군" if p_region==10 & h0142==13 

replace sido_nm = "충청남도" if p_region==11 & h0142==16
replace sigungu_nm = "계룡시" if p_region==11 & h0142==16 
 
replace sido_nm = "경기도" if p_region==8 & h0142==43
replace sigungu_nm = "고양시" if p_region==8 & h0142==43 

br if _merge==1 
tab _merge 

drop _merge

save "$interim/Klips/Klips_regionmerge_old.dta",replace 
********************************************************************
use "${raw}/Klips27/Klips_long_260522.dta", clear 
keep if wave>=9 

merge m:1 p_region h0142 using "${interim}/Klips/klips_region_new.dta"
order pid year p_region h0142 

br if _merge==2 // klips 결측 

drop if _merge==2 

// 시/군/구 단위 결측 
drop if h0142==. // 
drop if h0142==-1 // 
// _merge==1 에서 1066개 삭제 

br if _merge==1 // 대구광역시에 어느 구인데 (통합코드북x,느낌상 대구광역시에 편입된 군위군인 것 같음)

replace sido_nm = "경상북도" if p_region==3 & h0142==9 
replace sigungu_nm = "군위군" if p_region==3 & h0142==9 

br if _merge==1 
tab _merge 

drop _merge 

save "$interim/Klips/Klips_regionmerge_new.dta",replace 

append using "$interim/Klips/Klips_regionmerge_old.dta"

save "$interim/Klips/Klips_regionmerge_total.dta", replace 
**************************************************************************
use "$data/sigungu_code.dta", clear 
keep if year==2022 
drop year 

merge 1:m sido_nm sigungu_nm using "$interim/Klips/Klips_regionmerge_total.dta", nogen assert(3)

merge m:1 year regioncode using "$data/X_final_klips.dta"
tab year if _merge==1 // 로봇데이터에 없는 연도 1998~2005, 2023~2024 
br if _merge==2 // Klips에 없는 지역들이 있음 

drop if _mer==2 
drop _merge 

save "$data/klips_robot.dta", replace 
