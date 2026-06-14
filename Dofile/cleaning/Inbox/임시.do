clear 
import excel "/Users/ihuila/Desktop/research/mater thesis/국회의원선거구역/예나씨/제22대_선거구구역표.xlsx", sheet("Sheet1") firstrow

ren 시도 sido_nm 
ren 시군구 sigungu_nm1 

gen year_sgg = 2024
gen year = 2024 

drop in 1

// 
replace sigungu_nm1 = "중구" if 선거구명 == "중구성동구갑" & 


clear 
import excel "/Users/ihuila/Desktop/research/mater thesis/국회의원선거구역/예나씨/센서스 공간정보 지역 코드.xlsx", sheet("2024년 6월")

drop in 1
ren A sido_code
ren B sido_nm 
ren C sigungu_code
ren D sigungu_nm 
ren E emd_code
ren F emd_nm 

drop in 1

sort year sido_nm sigungu_nm1 


////// 이름잘못라벨링 
// 서울특별시 
br if sido_nm== "서울특별시"
replace sido_nm = "부산광역시" if sigungu_nm1 == "금정구"
replace sido_nm = "부산광역시" if sigungu_nm1 == "남구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="부산진구" 
replace sido_nm = "부산광역시" if sigungu_nm1=="북구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="사하구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="서구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if 선거구명=="중구영도구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="해운대구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="수영구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="연제구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="기장군" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="사상구" & sido_nm=="서울특별시" 
replace sido_nm = "부산광역시" if sigungu_nm1=="동래구" & sido_nm=="서울특별시" 


// 대구광역시 
br if sido_nm=="대구광역시" 

// 대전광역시 
br if sido_nm=="대전광역시" 

// 전북특별자치도 
replace 선거구명 = "군산시김제시부안군갑" if sido_nm=="전북특별자치도" & sigungu_nm1=="" & 선거구명=="갑"
replace 선거구명 = "군산시김제시부안군을" if sido_nm=="전북특별자치도" & sigungu_nm1=="김제시" & 선거구명=="을"


// 전북특별자치도 





읍면동
성동구왕십리제2동
왕십리도선동
마장동
사근동
행당제1동
행당제2동




bys sido_nm : gen sigungu_n = _N 
