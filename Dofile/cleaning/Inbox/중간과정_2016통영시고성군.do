***************************************************************************
******** 2016년도 통영시 고성군 보충해야함 (선거인수 데이터만 추가가능)
*****************고성군 
clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과/2016 통영시고성군" 

import excel "선거인수현황[제20대][국회의원선거][경상남도][고성군].xlsx", sheet(Sheet1) firstrow 

drop B C D E H I J K L M N O P Q

ren G 선거인수 
ren 중앙선거관리위원회선거통계시스템 읍면동

compress 
drop in 1/3

* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}


gen sido_nm = "경상남도"
gen sigungu_nm = "고성군"
gen sggName = "통영시고성군"
gen year = 2016 

drop if 읍면동==""
drop if F == "확정선거인수"
drop F
drop if 읍면동=="읍면동명" 

order sido_nm sigungu_nm sggName 읍면동
destring 선거인수, replace ignore(",")

cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
save 2016고성군_읍면동.dta, replace 

*****************통영시 
clear 
cd "/Users/ihuila/Desktop/data/master thesis/raw/CongWin/읍면동별 개표결과/2016 통영시고성군" 

import excel "선거인수현황[제20대][국회의원선거][경상남도][통영시].xlsx", sheet(Sheet1) firstrow 

drop B C D E H I J K L M N O P Q

ren G 선거인수 
ren 중앙선거관리위원회선거통계시스템 읍면동

compress 
drop in 1/3

* 문자열인 변수 - 문자열 앞뒤공백 제거 
ds, has(type string)
foreach var of varlist `r(varlist)' {
    replace `var' = ustrtrim(`var') if !missing(`var')
}
gen sido_nm = "경상남도"
gen sigungu_nm = "통영시"
gen sggName = "통영시고성군"
gen year = 2016 

drop if 읍면동==""
drop if F == "확정선거인수"
drop F
drop if 읍면동=="읍면동명" 

order sido_nm sigungu_nm sggName 읍면동
destring 선거인수, replace ignore(",")

cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
save 2016통영시_읍면동.dta, replace 

********************* 2016년 통영시고성군 데이터 
clear 
cd "/Users/ihuila/Desktop/data/master thesis/aftercongwin/congturn"
use 2016고성군_읍면동.dta

append using 2016통영시_읍면동

drop if 읍면동 =="합계" 

bysort sido_nm sigungu_nm: egen 선거인수2=total(선거인수)
bysort sido_nm sggName: egen 선거인수3=total(선거인수)

duplicates drop sido_nm sggName 선거인수3, force

drop sigungu_nm 읍면동 선거인수 선거인수2
ren 선거인수3 선거인수 

save 2016_통영시고성군_선거구.dta,replace  
