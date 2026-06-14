***** KSDC 데이터 클리닝 - 2012년 대선 
clear 
import excel "/Users/ihuila/Desktop/data/master thesis/raw/KSDC/presi/2012.xlsx", sheet("Sheet1") firstrow

*ren PQ1 sido_nm 
*ren PQ11 sigungu_nm

***** 시도명 정리 
gen sido_nm=""
rename * ,lower 

replace sido_nm="서울특별시" if pq1==1 
replace sido_nm="부산광역시" if pq1==2 
replace sido_nm="대구광역시" if pq1==3 
replace sido_nm="인천광역시" if pq1==4 
replace sido_nm="광주광역시" if pq1==5 
replace sido_nm="대전광역시" if pq1==6 
replace sido_nm="울산광역시" if pq1==7 
replace sido_nm="경기도" if pq1==8 
replace sido_nm="강원도" if pq1==9 
replace sido_nm="충청북도" if pq1==10 
replace sido_nm="충청남도" if pq1==11
replace sido_nm="전라북도" if pq1==12
replace sido_nm="전라남도" if pq1==13
replace sido_nm="경상북도" if pq1==14
replace sido_nm="경상남도" if pq1==15

tab sido_nm

***** 시군구명 정리 
ren pq11 sigungu_nm

order sido_nm sigungu_nm

replace sigungu_nm = "청주시" if sigungu_nm=="청원군" 

keep pq2 pq3 sido_nm sigungu_nm v1 v21 v22 v324 v3213 v3214 sq1 sq2 sq3 sq4 sq5 sq6 sq7 rsq7 resq7 

ren pq2 urban // 1. 대도시 2. 중소도시 3. 읍면 
ren pq3 gender // 1. 남성 2. 여성 
ren sq1 job // 1. 농/임/어 2. 자영업 ~ 
ren sq2 edu // 1. 중졸이하 2. 고졸 3. 대재 이상 9.무응답 
ren sq3 bornregion // 1. 서울 2. 인천경기 3. 대전충청 4. ~ 
ren sq4 inc 
ren sq5 religion
ren sq6 marital 
ren sq7 birthy
ren rsq7 age
ren resq7 age60

// v1 대통령 선거에 얼마나 관심이 있습니까 ? - 4점척도 (1 매우많았따 ~ 4 전혀없었다, 9무응답)
// -> 얼마나 정치에 관심이 있었는지에 대한 문항은 없음 
// v21 경제민주화 사안에 대해 얼마나 관심이 있습니까 - 10점 척도 (1매우많~10 전혀없, 99무응답)
// v22 복지확대 사안에 대해 얼마나 관심이 있습니까 - 10점 척도 (1매우많~10 전혀없, 99무응답)
// v324 정치인들은 나같은 사람이 어떤 생각을 하는지에 대해 별로 관심이 없다 - 4점척도 (1매우공감 ~ 4 전혀공감, 9무응답)
// v3213 재벌이 스스로 개혁을 못하더라도 기업활동에 정부는 간섭하지 말아야 한다 - 4점척도 (1매우공감 ~ 4 전혀공감, 9무응답)
// v3214 세금을 내더라도 복지수준을 높여야 한다 - 4점척도 (1매우공감 ~ 4 전혀공감, 9무응답)

gen poliatt = 5-v1 if v1 !=9 // 역코딩 
tab poliatt 

gen regula=5-v3213 if v3213!=9 // 역코딩 
gen redistri=5-v3214 if v3214 !=9 // 역코딩 

keep urban gender job edu bornregion inc religion inc marital birthy age age60 sido_nm sigungu_nm poliatt regula redistri 

collapse (mean) poliatt_mean = poliatt regula_mean = regula redistri_mean=redistri ///
         (median) poliatt_median = poliatt regula_median = regula redistri_median=redistri , ///
         by(sido_nm sigungu_nm)
		 
gen year = 2012 

cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterksdc_presi"
save 2012.dta, replace 
*************************** 2017년 대선 
clear 
import excel "/Users/ihuila/Desktop/data/master thesis/raw/KSDC/presi/2017.xlsx", sheet("2017 제19대 대선관련 유권자조사") firstrow

rename *, lower 

gen sido_nm=""
replace sido_nm="서울특별시" if dq1==1 
replace sido_nm="부산광역시" if dq1==2 
replace sido_nm="대구광역시" if dq1==3 
replace sido_nm="인천광역시" if dq1==4 
replace sido_nm="광주광역시" if dq1==5 
replace sido_nm="대전광역시" if dq1==6 
replace sido_nm="울산광역시" if dq1==7 
replace sido_nm="경기도" if dq1==8 
replace sido_nm="강원도" if dq1==9 
replace sido_nm="충청북도" if dq1==10 
replace sido_nm="충청남도" if dq1==11
replace sido_nm="전라북도" if dq1==12
replace sido_nm="전라남도" if dq1==13
replace sido_nm="경상북도" if dq1==14
replace sido_nm="경상남도" if dq1==15

gen sigungu_nm = ""
replace sigungu_nm = "양천구" if dq1a == 1
replace sigungu_nm = "강서구" if dq1a == 2
replace sigungu_nm = "구로구" if dq1a == 3
replace sigungu_nm = "금천구" if dq1a == 4
replace sigungu_nm = "동작구" if dq1a == 5
replace sigungu_nm = "관악구" if dq1a == 6
replace sigungu_nm = "서초구" if dq1a == 7
replace sigungu_nm = "강남구" if dq1a == 8
replace sigungu_nm = "송파구" if dq1a == 9
replace sigungu_nm = "종로구" if dq1a == 10
replace sigungu_nm = "성동구" if dq1a == 11
replace sigungu_nm = "동대문구" if dq1a == 12
replace sigungu_nm = "강북구" if dq1a == 13
replace sigungu_nm = "도봉구" if dq1a == 14
replace sigungu_nm = "노원구" if dq1a == 15
replace sigungu_nm = "은평구" if dq1a == 16
replace sigungu_nm = "서대문구" if dq1a == 17
replace sigungu_nm = "서구" if dq1a == 18 & sido_nm=="부산광역시"
replace sigungu_nm = "영도구" if dq1a == 19
replace sigungu_nm = "부산진구" if dq1a == 20
replace sigungu_nm = "남구" if dq1a == 21 & sido_nm=="부산광역시"
replace sigungu_nm = "북구" if dq1a == 22 & sido_nm=="부산광역시"
replace sigungu_nm = "연제구" if dq1a == 23
replace sigungu_nm = "동구" if dq1a == 24 & sido_nm=="대구광역시"
replace sigungu_nm = "남구" if dq1a == 25 & sido_nm=="대구광역시"
replace sigungu_nm = "북구" if dq1a == 26 & sido_nm=="대구광역시"
replace sigungu_nm = "달서구" if dq1a == 27 & sido_nm=="대구광역시"

replace sigungu_nm = "중구" if dq1a == 28 & sido_nm=="인천광역시"
replace sigungu_nm = "동구" if dq1a == 29 & sido_nm=="인천광역시"
replace sigungu_nm = "연수구" if dq1a == 30 & sido_nm=="인천광역시"
replace sigungu_nm = "서구" if dq1a == 31 & sido_nm=="인천광역시"

replace sigungu_nm = "서구" if dq1a == 32 & sido_nm=="광주광역시"
replace sigungu_nm = "북구" if dq1a == 33 & sido_nm=="광주광역시"

replace sigungu_nm = "중구" if dq1a == 34 & sido_nm=="대전광역시"
replace sigungu_nm = "유성구" if dq1a == 35

replace sigungu_nm = "남구" if dq1a == 36& sido_nm=="울산광역시"
replace sigungu_nm = "북구" if dq1a == 37& sido_nm=="울산광역시"

replace sigungu_nm = "수원시" if dq1a == 38
replace sigungu_nm = "안양시" if dq1a == 39
replace sigungu_nm = "광명시" if dq1a == 40
replace sigungu_nm = "평택시" if dq1a == 41
replace sigungu_nm = "안산시" if dq1a == 42
replace sigungu_nm = "과천시" if dq1a == 43
replace sigungu_nm = "오산시" if dq1a == 44
replace sigungu_nm = "시흥시" if dq1a == 45
replace sigungu_nm = "의왕시" if dq1a == 46
replace sigungu_nm = "용인시" if dq1a == 47
replace sigungu_nm = "성남시" if dq1a == 48
replace sigungu_nm = "김포시" if dq1a == 49
replace sigungu_nm = "화성시" if dq1a == 50
replace sigungu_nm = "양평군" if dq1a == 51
replace sigungu_nm = "의정부시" if dq1a == 52
replace sigungu_nm = "동두천시" if dq1a == 53
replace sigungu_nm = "남양주시" if dq1a == 54
replace sigungu_nm = "구리시" if dq1a == 55
replace sigungu_nm = "가평군" if dq1a == 56

replace sigungu_nm = "춘천시" if dq1a == 57
replace sigungu_nm = "강릉시" if dq1a == 58
replace sigungu_nm = "홍천군" if dq1a == 59

replace sigungu_nm = "청주시" if dq1a == 60
replace sigungu_nm = "충주시" if dq1a == 61
replace sigungu_nm = "진천군" if dq1a == 62

replace sigungu_nm = "공주시" if dq1a == 63
replace sigungu_nm = "보령시" if dq1a == 64
replace sigungu_nm = "금산군" if dq1a == 65

replace sigungu_nm = "익산시" if dq1a == 66
replace sigungu_nm = "정읍시" if dq1a == 67
replace sigungu_nm = "완주군" if dq1a == 68

replace sigungu_nm = "목포시" if dq1a == 69
replace sigungu_nm = "여수시" if dq1a == 70
replace sigungu_nm = "해남군" if dq1a == 71

replace sigungu_nm = "포항시" if dq1a == 72
replace sigungu_nm = "경주시" if dq1a == 73
replace sigungu_nm = "상주시" if dq1a == 74
replace sigungu_nm = "고령군" if dq1a == 75

replace sigungu_nm = "창원시" if dq1a == 76
replace sigungu_nm = "진주시" if dq1a == 77
replace sigungu_nm = "김해시" if dq1a == 78
replace sigungu_nm = "밀양시" if dq1a == 79
replace sigungu_nm = "함안군" if dq1a == 80

tab sigungu_nm

order sido_nm sigungu_nm

keep sido_nm sigungu_nm dq2 dq3 q1 q50a16 q50a17 q58a4 q58a5 q58a6 q58a7 sq1 sq2 sq3 sq5 sq6 sq7 sq8 sq9 sq10 demo04

ren dq2 urban 
ren dq3 gender 
ren sq1 edu 
ren sq2 job
ren sq3 jobst
ren sq5 bornregion
ren sq6 inc
ren sq7 wealth
ren sq8 home 
ren sq9 religion
ren sq10 marital
ren demo04 age 

//q1 얼마나 정치에 관심있는지 - 4점척도 (1매우많~4전혀없)
//q50a16 재벌이 스스로 개혁을 못한다하더라도 기업활동에 - 4점척도(1매우공감 ~ )
//q50a17 세금을 더 내더라도 복지수준을 높여야 한다 - 4점척도(1매우공감 ~ )
//q58a4 지금보다 복지를 더 확대해야 한다 - 4점척도 (1매우찬성~)
//q58a5 지금보다 세금을 더 걷어야 한다 - 4점척도 (1매우찬성~)
//q58a6 최저임금을 상향조정해야 한다 - 4점척도 (1매우찬성~)
//q58a7 대기업 규제를 강화해야한다 - 4점척도 (1매우찬성~)

// q23 현재 우리사회에서 가장 시급하게 해결되어야 할 과제 
// q50a14 민주주의는 문제가 있기는 하지만 그래도 다른 어떤 정부형태보다도 낫다
//q50a15 북한의 무력도발과 상관없이 민족적 차원에서 북한에 대한 지원은 가능한 한 많이 해야한다

gen poliatt = 5-q1 // 역코딩 
gen regula = 5-q50a16 // 역코딩 
gen redistri = 5-q50a17 // 역코딩 

keep urban gender edu job jobst bornregion inc wealth home religion marital age sido_nm sigungu_nm poliatt regula redistri 

// age edu inc gender marital sido_nm sigungu_nm 
// poliatt regula redistri 

collapse (mean) poliatt_mean = poliatt regula_mean = regula redistri_mean=redistri ///
         (median) poliatt_median = poliatt regula_median = regula redistri_median=redistri , ///
         by(sido_nm sigungu_nm)

gen year=2017 
cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterksdc_presi"
save 2017.dta, replace 

******************************2022년 대선 
clear 
import excel "/Users/ihuila/Desktop/data/master thesis/raw/KSDC/presi/2022.xlsx", sheet("data") firstrow

rename * ,lower 

gen sido_nm ="" 
gen sigungu_nm=""

replace sido_nm="서울특별시" if q4==1 
replace sido_nm="부산광역시" if q4==2 
replace sido_nm="대구광역시" if q4==3 
replace sido_nm="인천광역시" if q4==4 
replace sido_nm="광주광역시" if q4==5 
replace sido_nm="대전광역시" if q4==6 
replace sido_nm="울산광역시" if q4==7 
replace sido_nm="경기도" if q4==8 
replace sido_nm="강원도" if q4==9 
replace sido_nm="충청북도" if q4==10 
replace sido_nm="충청남도" if q4==11
replace sido_nm="전라북도" if q4==12
replace sido_nm="전라남도" if q4==13
replace sido_nm="경상북도" if q4==14
replace sido_nm="경상남도" if q4==15
replace sido_nm="제주도" if q4==16
replace sido_nm="세종특별자치시" if q4==17


**** 시군구명 정리 
replace sigungu_nm="세종특별자치시" if aq4 >= 1700 & aq4<=1800

replace sigungu_nm="제주시" if aq4 ==1601
replace sigungu_nm="서귀포시" if aq4 ==1602

replace sigungu_nm = "강북구" if aq4 == 101
replace sigungu_nm = "광진구" if aq4 == 102
replace sigungu_nm = "노원구" if aq4 == 103
replace sigungu_nm = "도봉구" if aq4 == 104
replace sigungu_nm = "동대문구" if aq4 == 105
replace sigungu_nm = "성동구" if aq4 == 106
replace sigungu_nm = "성북구" if aq4 == 107
replace sigungu_nm = "중랑구" if aq4 == 108
replace sigungu_nm = "마포구" if aq4 == 109
replace sigungu_nm = "서대문구" if aq4 == 110
replace sigungu_nm = "은평구" if aq4 == 111
replace sigungu_nm = "용산구" if aq4 == 112
replace sigungu_nm = "종로구" if aq4 == 113
replace sigungu_nm = "중구" if aq4 == 114
replace sigungu_nm = "강남구" if aq4 == 115
replace sigungu_nm = "강동구" if aq4 == 116
replace sigungu_nm = "서초구" if aq4 == 117
replace sigungu_nm = "송파구" if aq4 == 118
replace sigungu_nm = "강서구" if aq4 == 119
replace sigungu_nm = "관악구" if aq4 == 120
replace sigungu_nm = "구로구" if aq4 == 121
replace sigungu_nm = "금천구" if aq4 == 122
replace sigungu_nm = "동작구" if aq4 == 123
replace sigungu_nm = "양천구" if aq4 == 124
replace sigungu_nm = "영등포구" if aq4 == 125

replace sigungu_nm = "강서구" if aq4 == 201 & sido_nm == "부산광역시"
replace sigungu_nm = "금정구" if aq4 == 202 & sido_nm == "부산광역시"
replace sigungu_nm = "기장군" if aq4 == 203 & sido_nm == "부산광역시"
replace sigungu_nm = "남구"   if aq4 == 204 & sido_nm == "부산광역시"
replace sigungu_nm = "동구"   if aq4 == 205 & sido_nm == "부산광역시"
replace sigungu_nm = "동래구" if aq4 == 206 & sido_nm == "부산광역시"
replace sigungu_nm = "부산진구" if aq4 == 207 & sido_nm == "부산광역시"
replace sigungu_nm = "북구"   if aq4 == 208 & sido_nm == "부산광역시"
replace sigungu_nm = "사상구" if aq4 == 209 & sido_nm == "부산광역시"
replace sigungu_nm = "사하구" if aq4 == 210 & sido_nm == "부산광역시"
replace sigungu_nm = "서구"   if aq4 == 211 & sido_nm == "부산광역시"
replace sigungu_nm = "수영구" if aq4 == 212 & sido_nm == "부산광역시"
replace sigungu_nm = "연제구" if aq4 == 213 & sido_nm == "부산광역시"
replace sigungu_nm = "영도구" if aq4 == 214 & sido_nm == "부산광역시"
replace sigungu_nm = "중구"   if aq4 == 215 & sido_nm == "부산광역시"
replace sigungu_nm = "해운대구" if aq4 == 216 & sido_nm == "부산광역시"

replace sigungu_nm = "남구"     if aq4 == 301 & sido_nm == "대구광역시"
replace sigungu_nm = "달서구"   if aq4 == 302 & sido_nm == "대구광역시"
replace sigungu_nm = "달성군"   if aq4 == 303 & sido_nm == "대구광역시"
replace sigungu_nm = "동구"     if aq4 == 304 & sido_nm == "대구광역시"
replace sigungu_nm = "북구"     if aq4 == 305 & sido_nm == "대구광역시"
replace sigungu_nm = "서구"     if aq4 == 306 & sido_nm == "대구광역시"
replace sigungu_nm = "수성구"   if aq4 == 307 & sido_nm == "대구광역시"
replace sigungu_nm = "중구"     if aq4 == 308 & sido_nm == "대구광역시"

replace sigungu_nm = "강화군"   if aq4 == 401 & sido_nm == "인천광역시"
replace sigungu_nm = "계양구"   if aq4 == 402 & sido_nm == "인천광역시"
replace sigungu_nm = "남동구"   if aq4 == 404 & sido_nm == "인천광역시"
replace sigungu_nm = "동구"     if aq4 == 405 & sido_nm == "인천광역시"
replace sigungu_nm = "부평구"   if aq4 == 406 & sido_nm == "인천광역시"
replace sigungu_nm = "서구"     if aq4 == 407 & sido_nm == "인천광역시"
replace sigungu_nm = "연수구"   if aq4 == 408 & sido_nm == "인천광역시"
replace sigungu_nm = "옹진군"   if aq4 == 409 & sido_nm == "인천광역시"
replace sigungu_nm = "중구"     if aq4 == 410 & sido_nm == "인천광역시"
replace sigungu_nm = "미추홀구" if aq4 == 411 & sido_nm == "인천광역시"

replace sigungu_nm = "동구"     if aq4 == 501 & sido_nm == "광주광역시"
replace sigungu_nm = "서구"   if aq4 == 502 & sido_nm == "광주광역시"
replace sigungu_nm = "남구"   if aq4 == 503 & sido_nm == "광주광역시"
replace sigungu_nm = "북구"     if aq4 == 504 & sido_nm == "광주광역시"
replace sigungu_nm = "광산구" if aq4 == 505 & sido_nm == "광주광역시"

replace sigungu_nm = "대덕구"     if aq4 == 601 & sido_nm == "대전광역시"
replace sigungu_nm = "동구"   if aq4 == 602 & sido_nm == "대전광역시"
replace sigungu_nm = "서구"   if aq4 == 603 & sido_nm == "대전광역시"
replace sigungu_nm = "유성구"     if aq4 == 604 & sido_nm == "대전광역시"
replace sigungu_nm = "중구" if aq4 == 605 & sido_nm == "대전광역시"

replace sigungu_nm = "남구"     if aq4 == 701 & sido_nm == "울산광역시"
replace sigungu_nm = "동구"   if aq4 == 702 & sido_nm == "울산광역시"
replace sigungu_nm = "북구"   if aq4 == 703 & sido_nm == "울산광역시"
replace sigungu_nm = "울주군"     if aq4 == 704 & sido_nm == "울산광역시"
replace sigungu_nm = "중구" if aq4 == 705 & sido_nm == "울산광역시"

replace sigungu_nm = "가평군" if aq4 == 801
replace sigungu_nm = "고양시" if aq4 == 802
replace sigungu_nm = "과천시" if aq4 == 803
replace sigungu_nm = "광명시" if aq4 == 804
replace sigungu_nm = "광주시" if aq4 == 805
replace sigungu_nm = "구리시" if aq4 == 806
replace sigungu_nm = "군포시" if aq4 == 807
replace sigungu_nm = "김포시" if aq4 == 808
replace sigungu_nm = "남양주시" if aq4 == 809
replace sigungu_nm = "동두천시" if aq4 == 810
replace sigungu_nm = "부천시" if aq4 == 811
replace sigungu_nm = "성남시" if aq4 == 812
replace sigungu_nm = "수원시" if aq4 == 813
replace sigungu_nm = "시흥시" if aq4 == 814
replace sigungu_nm = "안산시" if aq4 == 815
replace sigungu_nm = "안성시" if aq4 == 816
replace sigungu_nm = "안양시" if aq4 == 817
replace sigungu_nm = "양주시" if aq4 == 818
replace sigungu_nm = "양평군" if aq4 == 819
replace sigungu_nm = "여주시" if aq4 == 820
replace sigungu_nm = "연천군" if aq4 == 821
replace sigungu_nm = "오산시" if aq4 == 822
replace sigungu_nm = "용인시" if aq4 == 823
replace sigungu_nm = "의왕시" if aq4 == 824
replace sigungu_nm = "의정부시" if aq4 == 825
replace sigungu_nm = "이천시" if aq4 == 826
replace sigungu_nm = "파주시" if aq4 == 827
replace sigungu_nm = "평택시" if aq4 == 828
replace sigungu_nm = "포천시" if aq4 == 829
replace sigungu_nm = "하남시" if aq4 == 830
replace sigungu_nm = "화성시" if aq4 == 831

replace sigungu_nm = "강릉시" if aq4 == 901
replace sigungu_nm = "고성군" if aq4 == 902
replace sigungu_nm = "동해시" if aq4 == 903
replace sigungu_nm = "삼척시" if aq4 == 904
replace sigungu_nm = "속초시" if aq4 == 905
replace sigungu_nm = "양구군" if aq4 == 906
replace sigungu_nm = "양양군" if aq4 == 907
replace sigungu_nm = "영월군" if aq4 == 908
replace sigungu_nm = "원주시" if aq4 == 909
replace sigungu_nm = "인제군" if aq4 == 910
replace sigungu_nm = "정선군" if aq4 == 911
replace sigungu_nm = "철원군" if aq4 == 912
replace sigungu_nm = "춘천시" if aq4 == 913
replace sigungu_nm = "태백시" if aq4 == 914
replace sigungu_nm = "평창군" if aq4 == 915
replace sigungu_nm = "홍천군" if aq4 == 916
replace sigungu_nm = "화천군" if aq4 == 917
replace sigungu_nm = "횡성군" if aq4 == 918

replace sigungu_nm = "괴산군" if aq4 == 1001
replace sigungu_nm = "단양군" if aq4 == 1002
replace sigungu_nm = "보은군" if aq4 == 1003
replace sigungu_nm = "영동군" if aq4 == 1004
replace sigungu_nm = "옥천군" if aq4 == 1005
replace sigungu_nm = "음성군" if aq4 == 1006
replace sigungu_nm = "제천시" if aq4 == 1007
replace sigungu_nm = "증평군" if aq4 == 1008
replace sigungu_nm = "진천군" if aq4 == 1009
replace sigungu_nm = "청주시" if aq4 == 1011
replace sigungu_nm = "충주시" if aq4 == 1012

replace sigungu_nm = "계룡시" if aq4 == 1101
replace sigungu_nm = "공주시" if aq4 == 1102
replace sigungu_nm = "금산군" if aq4 == 1103
replace sigungu_nm = "논산시" if aq4 == 1104
replace sigungu_nm = "당진시" if aq4 == 1105
replace sigungu_nm = "보령시" if aq4 == 1106
replace sigungu_nm = "부여군" if aq4 == 1107
replace sigungu_nm = "서산시" if aq4 == 1108
replace sigungu_nm = "서천군" if aq4 == 1109
replace sigungu_nm = "아산시" if aq4 == 1110
replace sigungu_nm = "예산군" if aq4 == 1112
replace sigungu_nm = "천안시" if aq4 == 1113
replace sigungu_nm = "청양군" if aq4 == 1114
replace sigungu_nm = "태안군" if aq4 == 1115
replace sigungu_nm = "홍성군" if aq4 == 1116

replace sigungu_nm = "고창군" if aq4 == 1201
replace sigungu_nm = "군산시" if aq4 == 1202
replace sigungu_nm = "김제시" if aq4 == 1203
replace sigungu_nm = "남원시" if aq4 == 1204
replace sigungu_nm = "무주군" if aq4 == 1205
replace sigungu_nm = "부안군" if aq4 == 1206
replace sigungu_nm = "순창군" if aq4 == 1207
replace sigungu_nm = "완주군" if aq4 == 1208
replace sigungu_nm = "익산시" if aq4 == 1209
replace sigungu_nm = "임실군" if aq4 == 1210
replace sigungu_nm = "장수군" if aq4 == 1211
replace sigungu_nm = "전주시" if aq4 == 1212
replace sigungu_nm = "정읍시" if aq4 == 1213
replace sigungu_nm = "진안군" if aq4 == 1214

replace sigungu_nm = "강진군" if aq4 == 1301
replace sigungu_nm = "고흥군" if aq4 == 1302
replace sigungu_nm = "곡성군" if aq4 == 1303
replace sigungu_nm = "광양시" if aq4 == 1304
replace sigungu_nm = "구례군" if aq4 == 1305
replace sigungu_nm = "나주시" if aq4 == 1306
replace sigungu_nm = "담양군" if aq4 == 1307
replace sigungu_nm = "목포시" if aq4 == 1308
replace sigungu_nm = "무안군" if aq4 == 1309
replace sigungu_nm = "보성군" if aq4 == 1310
replace sigungu_nm = "순천시" if aq4 == 1311
replace sigungu_nm = "신안군" if aq4 == 1312
replace sigungu_nm = "여수시" if aq4 == 1313
replace sigungu_nm = "영광군" if aq4 == 1314
replace sigungu_nm = "영암군" if aq4 == 1315
replace sigungu_nm = "완도군" if aq4 == 1316
replace sigungu_nm = "장성군" if aq4 == 1317
replace sigungu_nm = "장흥군" if aq4 == 1318
replace sigungu_nm = "진도군" if aq4 == 1319
replace sigungu_nm = "함평군" if aq4 == 1320
replace sigungu_nm = "해남군" if aq4 == 1321
replace sigungu_nm = "화순군" if aq4 == 1322

replace sigungu_nm = "경산시" if aq4 == 1401
replace sigungu_nm = "경주시" if aq4 == 1402
replace sigungu_nm = "고령군" if aq4 == 1403
replace sigungu_nm = "구미시" if aq4 == 1404
replace sigungu_nm = "군위군" if aq4 == 1405
replace sigungu_nm = "김천시" if aq4 == 1406
replace sigungu_nm = "문경시" if aq4 == 1407
replace sigungu_nm = "봉화군" if aq4 == 1408
replace sigungu_nm = "상주시" if aq4 == 1409
replace sigungu_nm = "성주군" if aq4 == 1410
replace sigungu_nm = "안동시" if aq4 == 1411
replace sigungu_nm = "영덕군" if aq4 == 1412
replace sigungu_nm = "영양군" if aq4 == 1413
replace sigungu_nm = "영주시" if aq4 == 1414
replace sigungu_nm = "영천시" if aq4 == 1415
replace sigungu_nm = "예천군" if aq4 == 1416
replace sigungu_nm = "울진군" if aq4 == 1417
replace sigungu_nm = "의성군" if aq4 == 1418
replace sigungu_nm = "청도군" if aq4 == 1419
replace sigungu_nm = "청송군" if aq4 == 1420
replace sigungu_nm = "칠곡군" if aq4 == 1421
replace sigungu_nm = "포항시" if aq4 == 1422
replace sigungu_nm = "울릉군" if aq4 == 1423

replace sigungu_nm = "거제시" if aq4 == 1501
replace sigungu_nm = "거창군" if aq4 == 1502
replace sigungu_nm = "고성군" if aq4 == 1503
replace sigungu_nm = "김해시" if aq4 == 1504
replace sigungu_nm = "남해군" if aq4 == 1505
replace sigungu_nm = "밀양시" if aq4 == 1506
replace sigungu_nm = "사천시" if aq4 == 1507
replace sigungu_nm = "산청군" if aq4 == 1508
replace sigungu_nm = "양산시" if aq4 == 1509
replace sigungu_nm = "의령군" if aq4 == 1510
replace sigungu_nm = "진주시" if aq4 == 1511
replace sigungu_nm = "창녕군" if aq4 == 1512
replace sigungu_nm = "창원시" if aq4 == 1513
replace sigungu_nm = "통영시" if aq4 == 1514
replace sigungu_nm = "하동군" if aq4 == 1515
replace sigungu_nm = "함안군" if aq4 == 1516
replace sigungu_nm = "함양군" if aq4 == 1517
replace sigungu_nm = "합천군" if aq4 == 1518

gen year=2022

keep sido_nm sigungu_nm q1 q2_1 q3 q7 q74 q75 q182 q183 q186 q187 q188 q191 q192 q193 q194 q196

ren q1 gender 
ren q2_1 birthy
ren q3 age 
ren q182 jobst
ren q183 job 
ren q187 edu 
ren q188 bornregion
ren q191 home
ren q192 inc
ren q193 wealth
ren q194 religion
ren q196 marital  

gen poliatt=q7 
gen regula=q75 
gen redistri= 5-q74 // 역코딩 (숫자높을수록 복지)

//q186 주관적 계층의식 
// q7 평소에 정치에 대해 얼마나 관심이 있는가 - 4점척도 (1전혀없다~4매우많다)
// q74 복지보다 경제발전에 더욱 - 4점척도(1매우반대~)
// q75 기업과 고소득자들이 현재보다 세금을 더 많이 내게 해야한다- 4점척도(1매우반대~)


// q108 q109 q110 q111 q112 q113 q114 q115 q116 q117 q118 q164 	q165 q166 
//q71 상황에 관계없이 대북지원은 지속되어야 한다 - 
// q72 소수자에 대한 지원과 보호는 더욱 강화되어야 한다 
// q73 난민과 이민자에 대한 문호를 더 개방해야 한다  
// q78 소득의 공평성과 관련하여 어느 의견에 더  가까운가 

keep sido_nm sigungu_nm gender birthy age jobst job edu bornregion home inc wealth religion marital poliatt regula redistri 

collapse (mean) poliatt_mean = poliatt regula_mean = regula redistri_mean=redistri ///
         (median) poliatt_median = poliatt regula_median = regula redistri_median=redistri , ///
         by(sido_nm sigungu_nm)

gen year=2022 

cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterksdc_presi"
save 2022.dta, replace 
************************************************************************
use 2012.dta, clear 

append using 2017.dta 
append using 2022.dta

cd "/Users/ihuila/Desktop/data/master thesis/raw/afterclean/afterksdc_presi"
save KSDCmerge.dta, replace 

