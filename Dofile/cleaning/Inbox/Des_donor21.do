cd "/Users/ihuila/Desktop/data/master thesis/afterdonor"
use "politicianexpen_longclean21.dta", clear

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
* 정당 계열 변수 생성 (21대) - 3가지 버전
* ================================

* Version 1: 거대양당만
gen 정당계열_v1 = ""
replace 정당계열_v1 = "Liberal"      if inlist(당ID, 100, 1010)   // 더불어민주당, 열린민주당
replace 정당계열_v1 = "Conservative" if inlist(당ID, 200, 5000)   // 국민의힘, 자유통일당
replace 정당계열_v1 = "기타"         if 정당계열_v1 == "" & 당ID != 9999
replace 정당계열_v1 = "무소속"       if 당ID == 9999

* Version 2: 거대양당 + 의석수 상위 2개 추가 (4개 카테고리)
* 21대 기준: 더불어민주당(180) > 국민의힘(103) > 정의당(6) > 국민의당(3)
gen 정당계열_v2 = ""
replace 정당계열_v2 = "Liberal"      if inlist(당ID, 100, 1010)
replace 정당계열_v2 = "Conservative" if inlist(당ID, 200, 5000)
replace 정당계열_v2 = "정의당"       if 당ID == 730
replace 정당계열_v2 = "국민의당"     if 당ID == 2080
replace 정당계열_v2 = "기타"         if 정당계열_v2 == "" & 당ID != 9999
replace 정당계열_v2 = "무소속"       if 당ID == 9999

* Version 3: 범진보/범보수/무소속
gen 정당계열_v3 = ""
* 범진보
replace 정당계열_v3 = "범진보" if inlist(당ID, 100, 1010, 730, 710, 750, 1020, 800, 2100)
* 범보수
replace 정당계열_v3 = "범보수" if inlist(당ID, 200, 5000, 2090, 2080, 1030)
* 무소속
replace 정당계열_v3 = "무소속" if 당ID == 9999

save "politicianexpen21_wide_final.dta", replace

* ================================
cd "/Users/ihuila/Desktop/data/master thesis/afterdonor/figure/21대"
* ================================

* ================================
* Figure V1: 거대양당만 (정당계열_v1)
* ================================

* Fig V1-1: 연도별 총지출 트렌드
preserve
keep if inlist(정당계열_v1, "Liberal", "Conservative")
collapse (mean) 총지출액, by(정당계열_v1 year)

twoway ///
    (connected 총지출액 year if 정당계열_v1 == "Liberal",      lcolor(blue) mcolor(blue) lpattern(solid)) ///
    (connected 총지출액 year if 정당계열_v1 == "Conservative", lcolor(red)  mcolor(red)  lpattern(solid)), ///
    title("거대양당 연도별 평균 지출액 (21대 국회)") ///
    xtitle("연도") ytitle("평균 지출액(원)") ///
    legend(label(1 "Liberal(민주당)") label(2 "Conservative(국힘)") rows(1)) ///
    scheme(s2color)
graph export "FigV1_1_거대양당지출트렌드.png", replace width(2000)
restore

* Fig V1-2: 거대양당 포트폴리오 비교
preserve
keep if inlist(정당계열_v1, "Liberal", "Conservative")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v1 year)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
          if 정당계열_v1 == "Liberal", ///
    over(year) stack title("Liberal(민주당)") ///
    legend(off) ytitle("지출비율(%)") scheme(s2color) ///
    saving(v1_left, replace)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
          if 정당계열_v1 == "Conservative", ///
    over(year) stack title("Conservative(국힘)") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("지출비율(%)") scheme(s2color) ///
    saving(v1_right, replace)

graph combine v1_left.gph v1_right.gph, ///
    title("거대양당 지출 포트폴리오 비교 (21대 국회)") cols(2)
graph export "FigV1_2_거대양당포트폴리오.png", replace width(2000)
restore

* Fig V1-3: 항목별 패널 (거대양당)
preserve
keep if inlist(정당계열_v1, "Liberal", "Conservative")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v1 year)

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    twoway ///
        (connected 비율_`v' year if 정당계열_v1 == "Liberal",      lcolor(blue) mcolor(blue) lpattern(solid)) ///
        (connected 비율_`v' year if 정당계열_v1 == "Conservative", lcolor(red)  mcolor(red)  lpattern(solid)), ///
        title("`v'") xtitle("") ytitle("비율(%)") legend(off) ///
        scheme(s2color) saving(v1_panel_`v', replace)
}

graph combine ///
    v1_panel_인건비.gph v1_panel_사무실.gph v1_panel_정치활동.gph ///
    v1_panel_홍보.gph   v1_panel_차량.gph   v1_panel_후원.gph ///
    v1_panel_교통.gph   v1_panel_언론.gph   v1_panel_기타.gph, ///
    cols(3) title("항목별 거대양당 트렌드 (21대 국회)") ///
    note("파란=Liberal(민주당)  빨간=Conservative(국힘)")
graph export "FigV1_3_거대양당항목패널.png", replace width(3000)
restore

* ================================
* Figure V2: 거대양당 + 정의당 + 국민의당 (4개)
* ================================

* Fig V2-1: 연도별 총지출 트렌드
preserve
keep if inlist(정당계열_v2, "Liberal", "Conservative", "정의당", "국민의당")
collapse (mean) 총지출액, by(정당계열_v2 year)

twoway ///
    (connected 총지출액 year if 정당계열_v2 == "Liberal",      lcolor(blue)   mcolor(blue)   lpattern(solid)) ///
    (connected 총지출액 year if 정당계열_v2 == "Conservative", lcolor(red)    mcolor(red)    lpattern(solid)) ///
    (connected 총지출액 year if 정당계열_v2 == "정의당",       lcolor(green)  mcolor(green)  lpattern(dash)) ///
    (connected 총지출액 year if 정당계열_v2 == "국민의당",     lcolor(orange) mcolor(orange) lpattern(dash)), ///
    title("4개 정당 연도별 평균 지출액 (21대 국회)") ///
    xtitle("연도") ytitle("평균 지출액(원)") ///
    legend(label(1 "Liberal(민주당)") label(2 "Conservative(국힘)") ///
           label(3 "정의당") label(4 "국민의당") rows(1)) ///
    scheme(s2color)
graph export "FigV2_1_4당지출트렌드.png", replace width(2000)
restore

* Fig V2-2: 포트폴리오 스택바 (4개)
preserve
keep if inlist(정당계열_v2, "Liberal", "Conservative", "정의당", "국민의당")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v2)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
    over(정당계열_v2) stack ///
    title("4개 정당 지출 포트폴리오 (21대 국회)") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("평균 지출비율(%)") scheme(s2color)
graph export "FigV2_2_4당포트폴리오.png", replace width(2000)
restore

* Fig V2-3: 항목별 패널 (4개 정당)
preserve
keep if inlist(정당계열_v2, "Liberal", "Conservative", "정의당", "국민의당")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v2 year)

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    twoway ///
        (connected 비율_`v' year if 정당계열_v2 == "Liberal",      lcolor(blue)   mcolor(blue)   lpattern(solid)) ///
        (connected 비율_`v' year if 정당계열_v2 == "Conservative", lcolor(red)    mcolor(red)    lpattern(solid)) ///
        (connected 비율_`v' year if 정당계열_v2 == "정의당",       lcolor(green)  mcolor(green)  lpattern(dash)) ///
        (connected 비율_`v' year if 정당계열_v2 == "국민의당",     lcolor(orange) mcolor(orange) lpattern(dash)), ///
        title("`v'") xtitle("") ytitle("비율(%)") legend(off) ///
        scheme(s2color) saving(v2_panel_`v', replace)
}

graph combine ///
    v2_panel_인건비.gph v2_panel_사무실.gph v2_panel_정치활동.gph ///
    v2_panel_홍보.gph   v2_panel_차량.gph   v2_panel_후원.gph ///
    v2_panel_교통.gph   v2_panel_언론.gph   v2_panel_기타.gph, ///
    cols(3) title("항목별 4개 정당 트렌드 (21대 국회)") ///
    note("파란=Liberal  빨간=Conservative  초록점선=정의당  주황점선=국민의당")
graph export "FigV2_3_4당항목패널.png", replace width(3000)
restore

* ================================
* Figure V3: 범진보/범보수/무소속
* ================================

* Fig V3-1: 연도별 총지출 트렌드
preserve
keep if inlist(정당계열_v3, "범진보", "범보수", "무소속")
collapse (mean) 총지출액, by(정당계열_v3 year)

twoway ///
    (connected 총지출액 year if 정당계열_v3 == "범진보", lcolor(blue) mcolor(blue) lpattern(solid)) ///
    (connected 총지출액 year if 정당계열_v3 == "범보수", lcolor(red)  mcolor(red)  lpattern(solid)) ///
    (connected 총지출액 year if 정당계열_v3 == "무소속", lcolor(gray) mcolor(gray) lpattern(dot)), ///
    title("범진보/범보수 연도별 평균 지출액 (21대 국회)") ///
    xtitle("연도") ytitle("평균 지출액(원)") ///
    legend(label(1 "범진보") label(2 "범보수") label(3 "무소속") rows(1)) ///
    scheme(s2color)
graph export "FigV3_1_범진보보수지출트렌드.png", replace width(2000)
restore

* Fig V3-2: 포트폴리오 비교 (좌우)
preserve
keep if inlist(정당계열_v3, "범진보", "범보수")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v3 year)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
          if 정당계열_v3 == "범진보", ///
    over(year) stack title("범진보") ///
    legend(off) ytitle("지출비율(%)") scheme(s2color) ///
    saving(v3_left, replace)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
          if 정당계열_v3 == "범보수", ///
    over(year) stack title("범보수") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("지출비율(%)") scheme(s2color) ///
    saving(v3_right, replace)

graph combine v3_left.gph v3_right.gph, ///
    title("범진보 vs 범보수 지출 포트폴리오 (21대 국회)") cols(2)
graph export "FigV3_2_범진보보수포트폴리오.png", replace width(2000)
restore

* Fig V3-3: 항목별 패널 (범진보/범보수)
preserve
keep if inlist(정당계열_v3, "범진보", "범보수")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v3 year)

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    twoway ///
        (connected 비율_`v' year if 정당계열_v3 == "범진보", lcolor(blue) mcolor(blue) lpattern(solid)) ///
        (connected 비율_`v' year if 정당계열_v3 == "범보수", lcolor(red)  mcolor(red)  lpattern(solid)), ///
        title("`v'") xtitle("") ytitle("비율(%)") legend(off) ///
        scheme(s2color) saving(v3_panel_`v', replace)
}

graph combine ///
    v3_panel_인건비.gph v3_panel_사무실.gph v3_panel_정치활동.gph ///
    v3_panel_홍보.gph   v3_panel_차량.gph   v3_panel_후원.gph ///
    v3_panel_교통.gph   v3_panel_언론.gph   v3_panel_기타.gph, ///
    cols(3) title("항목별 범진보/범보수 트렌드 (21대 국회)") ///
    note("파란=범진보  빨간=범보수")
graph export "FigV3_3_범진보보수항목패널.png", replace width(3000)
restore

display "21대 모든 Figure 생성 완료!"
