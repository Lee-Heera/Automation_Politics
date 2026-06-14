**********************************************************************
* Robot and automation
* SD_turnout / SD_conserv1_p choropleth maps (시군구 단위)
**********************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global data "${main}/Data cleaned"
	global interim "${main}/Data interim"
	global final "${main}/Data final"
	global prof_raw "${main}/Data raw/professor_raw"
	global mapdir "${main}/Map"
	global output "${main}/Output"

local mapyear 2007

**********************************************************************
* 0. korea_map.dta(시군구 경계, sigungu_cd) <-> regioncode 크로스워크
*    - 횡단(cross-section, 250개 시군구) 단계에서 먼저 매칭
*    - 기본: regioncode = floor(sigungu_cd/10)
*    - 광역시/도에 편입된 '군' 단위는 sigungu_cd가 20 더 크게 부여되어 있어 -20 보정
*      (예: 기장군 sigungu_cd=21510 -> regioncode 2131)
*    - 제주시/서귀포시는 Final_president에 없는 지역이라 결측 처리됨
**********************************************************************
use "$final/Final_president.dta", clear
keep regioncode sido_nm sigungu_nm 
duplicates drop
tempfile region_codes
save `region_codes'

use "$mapdir/korea_map.dta", clear
rename sigungu_nm sigungu_nm_map
gen regioncode = floor(sigungu_cd/10)
merge m:1 regioncode using `region_codes', gen(_m1) keep(master match)
replace regioncode = floor(sigungu_cd/10) - 20 if _m1 == 1
drop _m1

* -20 보정으로 새로 매칭된 84개 지역은 sido_nm/sigungu_nm이 1차 merge에서
* 이미 missing으로 채워진 채 master에 존재 -> 2차 merge에서 using 값으로
* 자동 대체되지 않으므로, 별도 변수로 받아서 missing인 경우만 채워줌
preserve
    use `region_codes', clear
    rename sido_nm sido_nm_rc
    rename sigungu_nm sigungu_nm_rc
    tempfile region_codes2
    save `region_codes2'
restore
merge m:1 regioncode using `region_codes2', gen(_m2) keep(master match)
replace sido_nm    = sido_nm_rc    if missing(sido_nm)
replace sigungu_nm = sigungu_nm_rc if missing(sigungu_nm)
drop sido_nm_rc sigungu_nm_rc _m2

**********************************************************************
* 1. 크로스워크(250, 횡단) -> Final_president(패널, 227*6) joinby
*    - regioncode 1개에 여러 시군구(분구)가 매칭되는 경우, 패널 6개 연도가
*      각 시군구마다 복제됨 (248개 매칭 시군구 * 6개 연도 = 1,488행)
*    - unmatched(master): 제주(2개)는 패널 매칭이 없으므로 그대로 유지
*      (SD_* 등 결측, year도 결측 -> 아래서 mapyear로 채움)
**********************************************************************
joinby regioncode using "$final/Final_president.dta", unmatched(master) _merge(_mj)

replace year = `mapyear' if _mj == 1
drop _mj

cd "$output/figure/0607"

**********************************************************************
* 1-1. spmap 좌표파일 형식 맞추기 (id/_x/_y -> _ID/_X/_Y)
**********************************************************************
capture confirm file "$data/korea_coord_spmap.dta"
if _rc != 0 {
    preserve
        use "$mapdir/korea_coord.dta", clear
        rename id _ID
        rename _x _X
        rename _y _Y
        save "$data/korea_coord_spmap.dta"
    restore
}
local coord "$data/korea_coord_spmap.dta"

**********************************************************************
* 2. 특정 연도(`mapyear') 선택 후 지도 그리기
**********************************************************************
preserve
    keep if year == `mapyear'
	drop if inlist(sigungu_cd, 39010, 39020)
	
    * 자동화 가설: 자동화 ↑ -> 투표율 변화(LD_turnout) ↓
    * => 값이 낮을수록 가설과 일치 -> 낮은 값 = 진한색이 되도록 Blues 색상순서 반전
    spmap LD_turnout_0722 using "`coord'", id(id) ///
        fcolor("8 81 156" "49 130 189" "107 174 214" "189 215 231" "239 243 255") ///
        clmethod(quantile) clnumber(5) ///
        legend(position(5) size(*0.8)) ///
        title("", size(medium))
    graph export "map_LD_turnout_0722.pdf", replace // width(2000) height(2400)

    spmap LD_conserv1_p_0722 using "`coord'", id(id) ///
        fcolor(Blues) clmethod(quantile) clnumber(5) ///
        legend(position(5) size(*0.8)) ///
        title("", size(medium))
    graph export "map_LD_conserv1_p_0722.pdf", replace //width(2000) height(2400)
	
	spmap X_LD2005_0722 using "`coord'", id(id) ///
        fcolor(Blues) clmethod(quantile) clnumber(5) ///
        legend(position(5) size(*0.8)) ///
        title("", size(medium))
    graph export "map_LD_X_0722.pdf", replace //width(2000) height(2400)
restore
