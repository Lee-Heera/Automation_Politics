cd "/Users/ihuila/Desktop/data/master thesis/afterdonor"
use "politicianexpen_longclean20.dta", clear

count if 지출액 == 0 // check: 0 없음 

* 의원*연도*분류 단위로 합계
collapse (sum) 지출액 ///
         (first) 당 당ID 지역명, ///
         by(의원번호 의원명 year Congera 분류)

reshape wide 지출액, ///
             i(의원번호 의원명 year Congera 당 당ID 지역명) ///
             j(분류) string

* 결측 → 0
foreach v of varlist 지출액* {
    replace `v' = 0 if missing(`v')
}

* 총지출액
egen 총지출액 = rowtotal(지출액*)

* ================================
* 대분류 합산
* ================================
egen 지출_인건비   = rowtotal(지출액인건비_급여등 지출액인건비_상여금및수당)
egen 지출_사무실   = rowtotal(지출액사무실_보증금 지출액사무실_비품및인테리어 ///
                              지출액사무실_숙소관련비용 지출액사무실_식대비 ///
                              지출액사무실_유지비용 지출액사무실_임대료및관리비)
egen 지출_정치활동 = rowtotal(지출액정치_금융비용 지출액정치_송사비용 ///
                              지출액정치_여론조사및컨설팅 지출액정치_활동비용)
egen 지출_홍보     = rowtotal(지출액홍보_문자 지출액홍보_비용등 ///
                              지출액홍보_의정보고관련비용)
egen 지출_차량     = rowtotal(지출액차량_렌터카및구입 지출액차량_유지비 ///
                              지출액차량_주유)
egen 지출_후원     = rowtotal(지출액후원_단체 지출액후원_당비 지출액후원_선물 ///
                              지출액후원_의원모임 지출액후원_정치인)
egen 지출_교통     = rowtotal(지출액교통_철도등 지출액교통_택시 ///
                              지출액교통_항공 지출액교통_해외출장)
egen 지출_언론     = rowtotal(지출액언론_광고 지출액언론_기자식대등 ///
                              지출액언론_신문구독 지출액언론_연감및도서 ///
                              지출액언론_잡지)
egen 지출_기타     = rowtotal(지출액간담회_다과 지출액간담회_식대 ///
                              지출액정책_도서및교육비 지출액정책_비용)

* ================================
* 대분류 비율 변수 생성
* ================================
foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    gen 비율_`v' = 지출_`v' / 총지출액 * 100
}

* ================================
* 정당 계열 변수 생성
* ================================
gen 정당계열 = ""
replace 정당계열 = "민주당계열" if 당ID == 100
replace 정당계열 = "국힘계열"   if 당ID == 200
replace 정당계열 = "정의당"     if 당ID == 730
replace 정당계열 = "제3지대"    if inlist(당ID, 2050, 2060, 2080, 1010, 2020)
replace 정당계열 = "무소속"     if inlist(당ID, 5000, 5010, 9999)

// gen 정당계열2 = "" 

save "politicianexpen20_wide_final.dta", replace
**********************************************************************

cd  "/Users/ihuila/Desktop/data/master thesis/afterdonor"
use "politicianexpen20_wide_final.dta", clear 

cd "/Users/ihuila/Desktop/data/master thesis/afterdonor/figure/20대"
* ================================
* Figure 1: 정당별 연도별 평균 총지출액
* ================================
preserve
collapse (mean) 총지출액, by(당 year)
keep if inlist(당, "더불어민주당", "새누리당", "자유한국당", ///
               "미래통합당", "정의당", "바른미래당", "무소속")

twoway ///
    (connected 총지출액 year if 당 == "더불어민주당", lcolor(blue)   mcolor(blue)   lpattern(solid)) ///
    (connected 총지출액 year if 당 == "새누리당",     lcolor(red)    mcolor(red)    lpattern(solid)) ///
    (connected 총지출액 year if 당 == "자유한국당",   lcolor(red)    mcolor(red)    lpattern(dash)) ///
    (connected 총지출액 year if 당 == "미래통합당",   lcolor(red)    mcolor(red)    lpattern(dot)) ///
    (connected 총지출액 year if 당 == "정의당",       lcolor(yellow) mcolor(yellow) lpattern(solid)) ///
    (connected 총지출액 year if 당 == "바른미래당",   lcolor(orange) mcolor(orange) lpattern(solid)) ///
    (connected 총지출액 year if 당 == "무소속",       lcolor(gray)   mcolor(gray)   lpattern(solid)), ///
    title("정당별 연도별 평균 지출액 (20대 국회)") ///
    xtitle("연도") ytitle("평균 지출액 (원)") ///
    legend(label(1 "민주당") label(2 "새누리당") label(3 "자유한국당") ///
           label(4 "미래통합당") label(5 "정의당") label(6 "바른미래당") ///
           label(7 "무소속") rows(2)) ///
    scheme(s2color)
graph export "Fig1_정당별연도별지출.png", replace width(2000)
restore

* ================================
* Figure 2: 민주당계열 vs 국힘계열
* 대분류별 스택바 (좌우 비교)
* ================================
preserve
keep if inlist(당ID, 100, 200)
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열 year)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
          if 정당계열 == "민주당계열", ///
    over(year) stack ///
    title("민주당 계열") ///
    legend(off) ytitle("지출비율(%)") ///
    scheme(s2color) saving(fig2_left, replace)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
          if 정당계열 == "국힘계열", ///
    over(year) stack ///
    title("국힘 계열") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("지출비율(%)") ///
    scheme(s2color) saving(fig2_right, replace)

graph combine fig2_left.gph fig2_right.gph, ///
    title("민주당 계열 vs 국힘 계열 지출 구조 비교") cols(2)
graph export "Fig2_민주국힘비교.png", replace width(2000)
restore

* ================================
* Figure 3: 지출항목별 패널
* x=연도, y=비율, 선=정당계열
* ================================
preserve
keep if inlist(정당계열, "민주당계열", "국힘계열", "정의당")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열 year)

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    twoway ///
        (connected 비율_`v' year if 정당계열 == "민주당계열", ///
            lcolor(blue)   mcolor(blue)   lpattern(dash)) ///
        (connected 비율_`v' year if 정당계열 == "국힘계열", ///
            lcolor(red)    mcolor(red)    lpattern(solid)) ///
        (connected 비율_`v' year if 정당계열 == "정의당", ///
            lcolor(green)  mcolor(green)  lpattern(dot)), ///
        title("`v'") xtitle("") ytitle("비율(%)") ///
        legend(off) scheme(s2color) ///
        saving(panel_`v', replace)
}

graph combine ///
    panel_인건비.gph panel_사무실.gph panel_정치활동.gph ///
    panel_홍보.gph   panel_차량.gph   panel_후원.gph ///
    panel_교통.gph   panel_언론.gph   panel_기타.gph, ///
    cols(3) ///
    title("지출항목별 정당계열 트렌드 (20대 국회)") ///
    note("파란점선=민주당계열  빨간실선=국힘계열  초록점=정의당")
graph export "Fig3_항목별패널.png", replace width(3000)
restore

* ================================
* Figure 4: 정당계열별 포트폴리오 스택바
* ================================
preserve
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열)
drop if 정당계열 == ""

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
    over(정당계열, label(angle(45))) stack ///
    title("정당계열별 지출 포트폴리오 (20대 국회)") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("평균 지출비율 (%)") scheme(s2color)
graph export "Fig4_정당계열포트폴리오.png", replace width(2000)
restore

display "Figure 생성 완료!"

* ================================
* Figure 5: 대분류별 상위 10명 의원 (horizontal bar)
* ================================
foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    preserve
    
    * 의원별 평균 비율
    collapse (mean) 비율_`v' (first) 당 정당계열, by(의원명 의원번호)
    
    * 상위 10명
    gsort -비율_`v'
    keep in 1/10
    
    * 정당계열별 색깔
    gen barcolor = 1 if 정당계열 == "민주당계열"
    replace barcolor = 2 if 정당계열 == "국힘계열"
    replace barcolor = 3 if 정당계열 == "정의당"
    replace barcolor = 4 if 정당계열 == "제3지대"
    replace barcolor = 5 if 정당계열 == "무소속"
    
    graph hbar 비율_`v', over(의원명, sort(비율_`v') descending) ///
        title("`v' 지출비율 상위 10인") ///
        ytitle("평균 비율(%)") ///
        blabel(bar, format(%5.1f)) ///
        scheme(s2color)
    graph export "Fig5_상위10_`v'.png", replace width(1500)
    restore
}

* ================================
* Figure 6: 의원별 지출 포트폴리오 변화
* (초선 vs 다선 비교 - 연도별 트렌드)
* ================================
preserve
* 의원별 등장 연도 수 계산 (다선 proxy)
bysort 의원번호: gen 활동연수 = _N
gen 선수구분 = "초선(1년)" if 활동연수 == 1
replace 선수구분 = "중선(2~3년)" if inrange(활동연수, 2, 3)
replace 선수구분 = "다선(4년이상)" if 활동연수 >= 4

collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(선수구분)
drop if 선수구분 == ""

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
    over(선수구분) stack ///
    title("활동연수별 지출 포트폴리오") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("평균 지출비율(%)") scheme(s2color)
graph export "Fig6_활동연수별포트폴리오.png", replace width(2000)
restore

* ================================
* Figure 7: 선거 있는 해 vs 없는 해 지출 비교
* ================================
preserve
gen 선거여부 = "선거없는해"
replace 선거여부 = "선거있는해" if inlist(year, 2016, 2020)

collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
               총지출액, by(선거여부 정당계열)
drop if 정당계열 == ""
keep if inlist(정당계열, "민주당계열", "국힘계열", "정의당")

* 총지출액 비교
graph bar 총지출액, over(선거여부) over(정당계열) ///
    title("선거 유무별 평균 총지출액") ///
    ytitle("평균 지출액(원)") ///
    legend(label(1 "선거없는해") label(2 "선거있는해")) ///
    scheme(s2color)
graph export "Fig7_선거유무별지출.png", replace width(2000)
restore

* ================================
* Figure 8: 지역구 vs 비례대표 지출 포트폴리오
* ================================
preserve
gen 의원유형 = "지역구"
replace 의원유형 = "비례대표" if strpos(지역명, "비례") > 0

collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(의원유형)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
    over(의원유형) stack ///
    title("지역구 vs 비례대표 지출 포트폴리오") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("평균 지출비율(%)") scheme(s2color)
graph export "Fig8_지역구비례비교.png", replace width(2000)
restore

* ================================
* Figure 9: 총지출액 분포 (정당계열별 박스플롯)
* ================================
preserve
drop if 정당계열 == ""
graph box 총지출액, over(정당계열, label(angle(45))) ///
    over(year) ///
    title("연도별 정당계열별 총지출액 분포") ///
    ytitle("총지출액(원)") ///
    scheme(s2color)
graph export "Fig9_총지출분포.png", replace width(2000)
restore

display "모든 Figure 생성 완료!"
