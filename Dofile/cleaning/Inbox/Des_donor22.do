cd "/Users/ihuila/Desktop/data/master thesis/afterdonor"
use "politicianexpen_longclean22.dta", clear

* 의원*분류 단위로 합계 (year 제외)
collapse (sum) 지출액 ///
         (first) 당 당ID 지역명, ///
         by(의원번호 의원명 Congera 분류)

reshape wide 지출액, ///
             i(의원번호 의원명 Congera 당 당ID 지역명) ///
             j(분류) string

foreach v of varlist 지출액* {
    replace `v' = 0 if missing(`v')
}

egen 총지출액 = rowtotal(지출액*)

* 대분류 합산
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

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    gen 비율_`v' = 지출_`v' / 총지출액 * 100
}

* 정당 계열
gen 정당계열_v1 = ""
replace 정당계열_v1 = "Liberal"      if 당ID == 100
replace 정당계열_v1 = "Conservative" if 당ID == 200
replace 정당계열_v1 = "기타"         if 정당계열_v1 == "" & 당 != "무소속"
replace 정당계열_v1 = "무소속"       if 당 == "무소속"

gen 정당계열_v2 = ""
replace 정당계열_v2 = "Liberal"      if 당ID == 100
replace 정당계열_v2 = "Conservative" if 당ID == 200
replace 정당계열_v2 = "조국혁신당"   if 당 == "조국혁신당"
replace 정당계열_v2 = "개혁신당"     if 당 == "개혁신당"
replace 정당계열_v2 = "기타"         if 정당계열_v2 == "" & 당 != "무소속"
replace 정당계열_v2 = "무소속"       if 당 == "무소속"

gen 정당계열_v3 = ""
replace 정당계열_v3 = "범진보" if inlist(당, "더불어민주당", "조국혁신당", "사회민주당", "기본소득당", "진보당")
replace 정당계열_v3 = "범보수" if inlist(당, "국민의힘", "개혁신당")
replace 정당계열_v3 = "무소속" if 당 == "무소속"

save "politicianexpen22_wide_final.dta", replace

* ================================
cd "/Users/ihuila/Desktop/data/master thesis/afterdonor/figure/22대"
* ================================

* ================================
* Figure V1: 거대양당 비교
* ================================

* Fig V1-1: 거대양당 포트폴리오 스택바
preserve
keep if inlist(정당계열_v1, "Liberal", "Conservative")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v1)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
    over(정당계열_v1) stack ///
    title("거대양당 지출 포트폴리오 비교 (22대 국회)") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("평균 지출비율(%)") scheme(s2color)
graph export "FigV1_1_거대양당포트폴리오.png", replace width(2000)
restore

* Fig V1-2: 거대양당 총지출액 분포 박스플롯
preserve
keep if inlist(정당계열_v1, "Liberal", "Conservative")

graph box 총지출액, over(정당계열_v1) ///
    title("거대양당 총지출액 분포 (22대 국회)") ///
    ytitle("총지출액(원)") scheme(s2color)
graph export "FigV1_2_거대양당총지출분포.png", replace width(2000)
restore

* Fig V1-3: 항목별 거대양당 비교 박스플롯 패널
preserve
keep if inlist(정당계열_v1, "Liberal", "Conservative")

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    graph box 비율_`v', over(정당계열_v1) ///
        title("`v'") ytitle("비율(%)") legend(off) ///
        scheme(s2color) saving(v1_box_`v', replace)
}

graph combine ///
    v1_box_인건비.gph v1_box_사무실.gph v1_box_정치활동.gph ///
    v1_box_홍보.gph   v1_box_차량.gph   v1_box_후원.gph ///
    v1_box_교통.gph   v1_box_언론.gph   v1_box_기타.gph, ///
    cols(3) title("항목별 거대양당 지출비율 분포 (22대 국회)") ///
    note("Liberal=민주당  Conservative=국힘")
graph export "FigV1_3_거대양당항목박스.png", replace width(3000)
restore

* ================================
* Figure V2: 4개 정당 비교
* ================================

* Fig V2-1: 4개 정당 포트폴리오
preserve
keep if inlist(정당계열_v2, "Liberal", "Conservative", "조국혁신당", "개혁신당")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v2)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
    over(정당계열_v2) stack ///
    title("4개 정당 지출 포트폴리오 (22대 국회)") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("평균 지출비율(%)") scheme(s2color)
graph export "FigV2_1_4당포트폴리오.png", replace width(2000)
restore

* Fig V2-2: 4개 정당 총지출액 분포
preserve
keep if inlist(정당계열_v2, "Liberal", "Conservative", "조국혁신당", "개혁신당")

graph box 총지출액, over(정당계열_v2, label(angle(45))) ///
    title("4개 정당 총지출액 분포 (22대 국회)") ///
    ytitle("총지출액(원)") scheme(s2color)
graph export "FigV2_2_4당총지출분포.png", replace width(2000)
restore

* Fig V2-3: 항목별 4개 정당 박스플롯 패널
preserve
keep if inlist(정당계열_v2, "Liberal", "Conservative", "조국혁신당", "개혁신당")

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    graph box 비율_`v', over(정당계열_v2, label(angle(45))) ///
        title("`v'") ytitle("비율(%)") legend(off) ///
        scheme(s2color) saving(v2_box_`v', replace)
}

graph combine ///
    v2_box_인건비.gph v2_box_사무실.gph v2_box_정치활동.gph ///
    v2_box_홍보.gph   v2_box_차량.gph   v2_box_후원.gph ///
    v2_box_교통.gph   v2_box_언론.gph   v2_box_기타.gph, ///
    cols(3) title("항목별 4개 정당 지출비율 분포 (22대 국회)")
graph export "FigV2_3_4당항목박스.png", replace width(3000)
restore

* ================================
* Figure V3: 범진보/범보수/무소속
* ================================

* Fig V3-1: 범진보/범보수 포트폴리오
preserve
keep if inlist(정당계열_v3, "범진보", "범보수")
collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
               by(정당계열_v3)

graph bar 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
          비율_차량 비율_후원 비율_교통 비율_언론 비율_기타, ///
    over(정당계열_v3) stack ///
    title("범진보 vs 범보수 지출 포트폴리오 (22대 국회)") ///
    legend(label(1 "인건비") label(2 "사무실") label(3 "정치활동") ///
           label(4 "홍보") label(5 "차량") label(6 "후원") ///
           label(7 "교통") label(8 "언론") label(9 "기타") rows(2)) ///
    ytitle("평균 지출비율(%)") scheme(s2color)
graph export "FigV3_1_범진보보수포트폴리오.png", replace width(2000)
restore

* Fig V3-2: 범진보/범보수 총지출액 분포
preserve
keep if inlist(정당계열_v3, "범진보", "범보수", "무소속")

graph box 총지출액, over(정당계열_v3) ///
    title("범진보/범보수/무소속 총지출액 분포 (22대 국회)") ///
    ytitle("총지출액(원)") scheme(s2color)
graph export "FigV3_2_범진보보수총지출분포.png", replace width(2000)
restore

* Fig V3-3: 항목별 범진보/범보수 박스플롯 패널
preserve
keep if inlist(정당계열_v3, "범진보", "범보수")

foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    graph box 비율_`v', over(정당계열_v3) ///
        title("`v'") ytitle("비율(%)") legend(off) ///
        scheme(s2color) saving(v3_box_`v', replace)
}

graph combine ///
    v3_box_인건비.gph v3_box_사무실.gph v3_box_정치활동.gph ///
    v3_box_홍보.gph   v3_box_차량.gph   v3_box_후원.gph ///
    v3_box_교통.gph   v3_box_언론.gph   v3_box_기타.gph, ///
    cols(3) title("항목별 범진보/범보수 지출비율 분포 (22대 국회)") ///
    note("파란=범진보  빨간=범보수")
graph export "FigV3_3_범진보보수항목박스.png", replace width(3000)
restore


* ================================
* Fig 의원-1: 정당별 색깔 다르게 (막대별 색깔)
* ================================
foreach v in 인건비 사무실 정치활동 홍보 차량 후원 교통 언론 기타 {
    preserve
    collapse (mean) 비율_`v' (first) 당, by(의원명 의원번호)
    gsort -비율_`v'
    keep in 1/10

    * 정당별 숫자 코드
    gen pcolor = 1 if 당 == "더불어민주당"
    replace pcolor = 2 if 당 == "국민의힘"
    replace pcolor = 3 if 당 == "조국혁신당"
    replace pcolor = 4 if 당 == "개혁신당"
    replace pcolor = 5 if 당 == "진보당"
    replace pcolor = 6 if 당 == "기본소득당"
    replace pcolor = 7 if 당 == "사회민주당"
    replace pcolor = 8 if 당 == "무소속"

    * rank 변수
    gen rank = _n

    * 각 의원 이름 라벨
    tostring rank, gen(rankstr)
    forvalues i = 1/10 {
        local nm = 의원명[`i']
        local pt = 당[`i']
        local val = round(비율_`v'[`i'], 0.1)
        local lab`i' `"`nm'(`pt')"'
    }

    twoway ///
        (bar 비율_`v' rank if 당 == "더불어민주당", fcolor(blue)   lcolor(blue)   barw(0.8)) ///
        (bar 비율_`v' rank if 당 == "국민의힘",     fcolor(red)    lcolor(red)    barw(0.8)) ///
        (bar 비율_`v' rank if 당 == "조국혁신당",   fcolor(cyan)   lcolor(cyan)   barw(0.8)) ///
        (bar 비율_`v' rank if 당 == "개혁신당",     fcolor(orange) lcolor(orange) barw(0.8)) ///
        (bar 비율_`v' rank if 당 == "진보당",       fcolor(green)  lcolor(green)  barw(0.8)) ///
        (bar 비율_`v' rank if 당 == "기본소득당",   fcolor(purple) lcolor(purple) barw(0.8)) ///
        (bar 비율_`v' rank if 당 == "사회민주당",   fcolor(lime)   lcolor(lime)   barw(0.8)) ///
        (bar 비율_`v' rank if 당 == "무소속",       fcolor(gray)   lcolor(gray)   barw(0.8)), ///
        title("`v' 지출비율 상위 10인 (22대 국회)") ///
        ytitle("비율(%)") xtitle("") ///
        xlabel(1 "`lab1'" 2 "`lab2'" 3 "`lab3'" 4 "`lab4'" 5 "`lab5'" ///
               6 "`lab6'" 7 "`lab7'" 8 "`lab8'" 9 "`lab9'" 10 "`lab10'", ///
               angle(45) labsize(small)) ///
        legend(label(1 "민주당") label(2 "국힘") label(3 "조국혁신당") ///
               label(4 "개혁신당") label(5 "진보당") label(6 "기본소득당") ///
               label(7 "사회민주당") label(8 "무소속") rows(2)) ///
        scheme(s2color)
    graph export "Fig의원_상위10_`v'.png", replace width(2000)
    restore
}

* ================================
* Fig 의원-2: 지역구 vs 비례대표 (정당별 색깔)
* ================================
preserve
gen 의원유형 = "지역구"
replace 의원유형 = "비례대표" if strpos(지역명, "비례") > 0

collapse (mean) 비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
               비율_차량 비율_후원 비율_교통 비율_언론 비율_기타 ///
               (first) 당, by(의원명 의원번호 의원유형)

* 정당별 총지출비율 합산 (확인용)
egen 총비율 = rowtotal(비율_인건비 비율_사무실 비율_정치활동 비율_홍보 ///
                       비율_차량 비율_후원 비율_교통 비율_언론 비율_기타)

graph box 총비율, over(당, label(angle(45))) over(의원유형) ///
    title("지역구 vs 비례대표 지출 분포 (22대 국회)") ///
    ytitle("총지출비율(%)") ///
    marker(1, mcolor(blue))   ///
    scheme(s2color)
graph export "Fig의원_지역구비례비교.png", replace width(2000)
restore

* ================================
* Fig 의원-3: 총지출액 분포 - graph box 사용
* 알파벳 정렬: 개혁신당(1) 국민의힘(2) 기본소득당(3) 더불어민주당(4)
*              무소속(5) 사회민주당(6) 조국혁신당(7) 진보당(8)
* ================================
graph box 총지출액, ///
    over(당, label(angle(45) labsize(small))) ///
    box(1, fcolor(orange%70) lcolor(orange)) ///
    box(2, fcolor(red%70)    lcolor(red))    ///
    box(3, fcolor(purple%70) lcolor(purple)) ///
    box(4, fcolor(blue%70)   lcolor(blue))   ///
    box(5, fcolor(gray%70)   lcolor(gray))   ///
    box(6, fcolor(lime%70)   lcolor(lime))   ///
    box(7, fcolor(cyan%70)   lcolor(cyan))   ///
    box(8, fcolor(green%70)  lcolor(green))  ///
    title("정당별 의원 총지출액 분포 (22대 국회)") ///
    ytitle("총지출액(원)") ///
    scheme(s2color)
graph export "Fig의원_정당별총지출분포.png", replace width(2000)

