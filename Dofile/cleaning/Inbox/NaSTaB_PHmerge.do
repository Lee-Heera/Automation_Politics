* 가구+개인데이터 합산 - 연도별 데이터 생성 
clear all
set more off
use "/Users/ihuila/Desktop/data/master thesis/raw/NaSTaB_sigungu/NaSTaB08H_region.dta", clear 

* 연도 매핑 설정
local year "08 09 10 11 12 13 14 15 16 17"
local real_year 2015

* 반복문을 통해 각 연도별 데이터 처리
foreach y of local year {
    
    * 가구 데이터 불러오기
    use "/Users/ihuila/Desktop/data/master thesis/raw/NaSTaB_sigungu/NaSTaB`y'H_region.dta", clear
    tempfile hdata
    save `hdata'

    * 개인 데이터 불러오기
    use "/Users/ihuila/Desktop/data/master thesis/raw/NaSTaB_P/NaSTaB`y'P.dta", clear
    tempfile pdata
    save `pdata'

    * 가구 데이터 불러오기
    use `hdata', clear

    * 개인 데이터 병합
    merge 1:m hid`y' using `pdata'

    * 가구아이디 / 개인아이디 병합된것만 
	keep if _merge==3 

    * 결과 저장
	
    save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/year`y'.dta", replace

    * 실제 연도 증가
    local real_year = `real_year' + 1
}
**********************************************
* long type data 
clear all
set more off

cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/"

* 초기 연도 데이터 불러오기
use year08.dta, clear

* 변수 접두어 정리
foreach prefix in w h p hid pid hs ps pw p_ {
    unab vars : `prefix'08*
    foreach var of local vars {
        local newname = subinstr("`var'", "`prefix'08", "`prefix'", .)
        rename `var' `newname'
    }
}

* hdf038 변수 형식 확인 및 변환
capture confirm variable hdf038
if !_rc {
    capture confirm numeric variable hdf038
    if !_rc {
        tostring hdf038, replace force
    }
}

* 실제 조사 연도 지정
gen year = 2015

* 초기 데이터 저장
save NaSTaB_long.dta, replace

* 나머지 연도 데이터 append
forvalues y = 9/17 {
    local wave = string(`y', "%02.0f")
    local surveyyear = `y' + 2007

    di in green "Appending year`wave'.dta (survey year = `surveyyear')..."

    use year`wave'.dta, clear

    * 변수 접두어 정리
    foreach prefix in w h p hid pid hs ps pw p_ {
        unab vars : `prefix'`wave'*
        foreach var of local vars {
            local newname = subinstr("`var'", "`prefix'`wave'", "`prefix'", .)
            rename `var' `newname'
        }
    }

    * hdf038 변수 형식 확인 및 변환
    capture confirm variable hdf038
    if !_rc {
        capture confirm numeric variable hdf038
        if !_rc {
            tostring hdf038, replace force
        }
    }

    * 실제 조사 연도 지정
    gen year = `surveyyear'

    * 기존 데이터에 append
    append using NaSTaB_long.dta

    * 변수 정렬
    order year hid pid

    * 병합된 데이터 저장
    save NaSTaB_long.dta, replace
}
****************************************** 재정패널 시군구 맞추기 
cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB"
use NaSTaB_long.dta, clear 

//ren hs15b11 regioncode 
decode hsb10, generate(sido_nm)
decode hsb11, generate(sigungu_nm)

order hid year sido_nm sigungu_nm 

****** 시도 맞추기 
replace sido_nm = trim(sido_nm)
replace sigungu_nm=trim(sigungu_nm)

replace sido_nm = "서울특별시" if regexm(sido_nm, "서울")
replace sido_nm = "부산광역시" if regexm(sido_nm, "부산")
replace sido_nm = "대구광역시" if regexm(sido_nm, "대구")
replace sido_nm = "인천광역시" if regexm(sido_nm, "인천")
replace sido_nm = "광주광역시" if regexm(sido_nm, "광주")
replace sido_nm = "대전광역시" if regexm(sido_nm, "대전")
replace sido_nm = "울산광역시" if regexm(sido_nm, "울산")
replace sido_nm = "세종특별자치시" if regexm(sido_nm, "세종")
replace sido_nm = "경기도" if regexm(sido_nm, "경기")
replace sido_nm = "강원도" if regexm(sido_nm, "강원")
replace sido_nm = "충청북도" if regexm(sido_nm, "충북")
replace sido_nm = "충청남도" if regexm(sido_nm, "충남")
replace sido_nm = "전라북도" if regexm(sido_nm, "전북")
replace sido_nm = "전라남도" if regexm(sido_nm, "전남")
replace sido_nm = "경상북도" if regexm(sido_nm, "경북")
replace sido_nm = "경상남도" if regexm(sido_nm, "경남")
replace sido_nm = "제주특별자치도" if regexm(sido_nm, "제주")

******* 시군구 맞추기 
tab sigungu_nm

tab sigungu_nm if strpos(sigungu_nm, " ") > 0 & ///
    !(regexm(sido_nm, "특별시") | regexm(sido_nm, "광역시") | regexm(sido_nm, "특별"))

replace sigungu_nm = "경기고양시" if regexm(sigungu_nm, "고양시")
replace sigungu_nm = "경기부천시" if regexm(sigungu_nm, "부천시")
replace sigungu_nm = "경기성남시" if regexm(sigungu_nm, "성남시")
replace sigungu_nm = "경기수원시" if regexm(sigungu_nm, "수원시")
replace sigungu_nm = "경기안산시" if regexm(sigungu_nm, "안산시")
replace sigungu_nm = "경기안양시" if regexm(sigungu_nm, "안양시")
replace sigungu_nm = "경기용인시" if regexm(sigungu_nm, "용인시")

replace sigungu_nm = "경남창원시" if regexm(sigungu_nm, "창원시")
replace sigungu_nm = "경북포항시" if regexm(sigungu_nm, "포항시")
replace sigungu_nm = "전북전주시" if regexm(sigungu_nm, "전주시")
replace sigungu_nm = "충남천안시" if regexm(sigungu_nm, "천안시")
replace sigungu_nm = "충북청주시" if regexm(sigungu_nm, "청주시")

tab sigungu_nm 

// 마산진해 -> 창원으로 
replace sigungu_nm="경남창원시" if regexm(sigungu_nm, "마산")
replace sigungu_nm="경남창원시" if regexm(sigungu_nm, "진해")

gen sigungu_nm3 = substr(sigungu_nm, 7, .)
tab sigungu_nm3 // -> 이걸로 최종 시군구명 될거임 
tab sigungu_nm if sigungu_nm3=="시" // 세종시 
replace sigungu_nm3="세종특별자치시" if sigungu_nm=="세종시" 

drop sigungu_nm 
ren sigungu_nm3 sigungu_nm

tab sigungu_nm

codebook pid 

*********** singleton 삭제 
keep hid pid year sido_nm sigungu_nm horg hmrg hsa27 hsb10 hsb11 hsb12 hsa01 pwbyr pwgen pwedu pwgrd pwgen hinc p__inc_all hba002 pga001 pga003 pga004 pga005 pga006 pga007 pga008 pga009 pga010 pga011 pga020 pga030 pga040 pgb070 pgb080 pgb090 pgb100 

order pid year 
sort pid year 

drop if pga020==. & year!=2015 // 주요 종속변수에 대해서 - 결측이 있는 관측치 삭제 (3,368개 삭제)

bysort pid (pga020): gen obs=_N // pid별로 핵심 종속변수에 한번만 등장하면 삭제 (singleton)
order pid year obs

drop if obs==1 & year!=2015 // singleton 삭제 
***************** 이사한 사람 정리 -> 이거 나중에 robustness check 

** 1차) 일단 이사한 사람은 아예 id에서 제외 
sort pid year

egen newid = group(pid)

* 이전연도의 지역과 다른지 비교하기 위해 변수 생성 
sort newid year
by newid: gen prev_hsb11 = hsb11[_n-1]

* 개인별 최초 조사참여연도 
bysort newid (year): egen minyear = min(year)
gen firstwave = (year == minyear)

* 개인별 마지막 조사 참여연도 
by newid (year): gen lastwave = (_n == _N)

* 다음 연도 지역코드와 비교해 이동 여부 판단 (마지막 연도는 비교 X)
bysort newid (year): gen moved = ///
    (hsb11 != hsb11[_n+1]) if _n < _N & firstwave != 1
replace moved=0 if firstwave==1  
replace moved=0 if lastwave == 1 & hsb11 == prev_hsb11 // 조사 마지막연도이면서 전연도 

tab moved 
br

* 총 이동횟수 변수생성 
bysort newid: egen totmoved = total(moved)
gen mover=totmoved>0 // 최소 1번이라도 이사하면 mover 변수값 1로 매기기 

tab mover 

*  클러스터 ID 생성
gen id_shifted = pid + 100000
by newid: gen clusterid=hsb11 
by newid: replace clusterid=id_shifted if mover==1 

tab clusterid 

keep if mover

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_long.dta", replace
*************************************로봇데이터랑 머지 
use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_long.dta", clear 

//replace regioncode=regioncode*10 

merge m:n year sido_nm sigungu_nm using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/SG_robot.dta"

order year sido_nm sigungu_nm hid pid

br if _merge==2 
tab year if _merge==2 
// 1. 2010~2014년도 
// 2. 2015년도 이후 자료중에서 매치안된건 - 재정패널에 없는 지역들 

drop if year>=2010 & year<=2014 & _merge==2 

br if _merge==2 

drop if _merge!=3 // 재정패널에서 조사되지 않은 시군구도 있음 
drop _merge 

br if year==2015

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_robotlong.dta", replace 
*************************************통제변수랑 머지 
use "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_robotlong.dta", clear 

// 2. 통제변수 머지하기 
merge m:n regioncode year using "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/aftercontrol/sigungucontrol.dta"

order sido_nm sigungu_nm regioncode year 

br if _merge==2 // 통제변수데이터 (2007-2015년도자료)
// 1. 2007-2015 년
// 2. 세종시 (2010-2012년)
// 3. 제주 (전년도)

tab year if _merge==2 

drop if _merge==2 & year>=2007&year<=2014 // 2015년도는 lagged control var 때문에 삭제 안함 

br if _merge==2

drop if sido_nm=="제주특별자치도" 
drop if _merge==2 

drop _merge

br 
count 


duplicates list regioncode year

sort pid year 

duplicates report pid year 

xtset pid year 

save "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterNaSTaB/NaSTaB_final.dta", replace /// obs= 14,310 


// dependent variable 

//pga001 pga003 pga004 pga005 pga006 pga007 pga008 pga009 pga010 pga011 pga020 pga030 pga040 pgb001 pgb020 pgb030  - 결측  3,368 
// pgb151 pgb152 pgb153 pgb154 pgb155 pgb156 pgb157 pgb158 pgb159 - 결측 17,868 
// pgb050 pgb060 pgb070 - 결측 3,368 

// pgb080 pgb081 pgb082 - 결측 69,344 
// pgb083 pgb084 pgb085 pgb086 - 결측 61,076
// pgb087 pgb088 - 결측 66,941 

// pgb090 pgb100 pgb110 pgb120 - 결측 3,368 


/*
use "D:\Dropbox\Jun_Keyu_Agglomeration\Immigration_Social Capital 2023\Stata_code\Data\long file merged_immi edupop.dta"

drop _merge
drop if xwaveid==""

egen newid= group(xwaveid)

sort newid year
by newid: gen PL_LGAFINAL21 = LGAFINAL21[_n-1]

sort PL_LGAFINAL21 year

merge m:1 PL_LGAFINAL21 year using `LGApanel'.dta

drop if _merge==2

sort newid year

egen minyear = min(year), by(newid)
gen firstwave = 1 if year==minyear
replace firstwave=0 if firstwave==.

by id: gen movedLGA = (LGAFINAL21 != LGAFINAL21[_n+1]) if firstwave!=1
replace movedLGA=0 if firstwave==1

by id: egen totmovedLGA = total(movedLGA)
gen mover = (totmovedLGA>0)

gen DX1=PL

gen id_6 = id+100000

by newid: gen clusterid1 = LGA_ALL
by newid: replace clusterid1 = id_6 if mover==1
*/
