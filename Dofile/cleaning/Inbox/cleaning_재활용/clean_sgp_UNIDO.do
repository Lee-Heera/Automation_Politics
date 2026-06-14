**********************************************************************  
* Robot and automation
* Singapore Employment Statistics clean do-file
**********************************************************************
clear all

	global main "/Users/ihuila/Research/MASTER_thesis"
	global data "${main}/Data cleaned"
	global interim "${main}/Data interim"
	global final "${main}/Data final"
	global prof_raw "${main}/Data raw/professor_raw"	
	/*
	global ifr "${main}/Data raw/IFR"
	global kepco  "${main}/Data raw/KEPCO"
	global oarlr "${main}/Data raw/OARLR"
	global singapore "${main}/Data raw/Singapore"
	*/
	
	
**********************************************************************	
import excel "$prof_raw/UNIDO_singapore.xlsx", sheet("Data") firstrow

compress 
keep Year Activity ActivityCode Value 

tab ActivityCode 
destring ActivityCode, replace 
ren ActivityCode isic

// 산업매칭 
gen newindcode =. 
replace newindcode = 107 if isic >=10 & isic <=12 
replace newindcode = 108 if isic >=13 & isic <=15 
replace newindcode = 119 if isic ==16 |  isic == 31 
replace newindcode = 109 if isic ==17 |  isic == 18 

replace newindcode = 110 if isic >=19 & isic <=22 
replace newindcode = 111 if isic ==23 
replace newindcode = 112 if isic ==24 
replace newindcode = 113 if isic ==25

replace newindcode = 115 if isic >=26 & isic <=27 
 
replace newindcode = 114 if isic ==28 
replace newindcode = 116 if isic ==29 
replace newindcode = 117 if isic ==30
 
replace newindcode = 118 if isic >=32 & isic <=33 
 

// 
destring Year, replace 
ren (Year Value) (year emp)
ren Activity isicind

collapse (sum) emp , by(year newindcode)

tab year // 13개 산업 
ren emp sgp_empl 

replace sgp_empl = sgp_empl/1000 // 1000단위 맞추기 

save "$interim/UNIDO/sgp_empl.dta", replace 

// 산업 매칭 
/*
Food products
Beverages
Textiles
Wearing apparel
Leather and related products
Wood products, excluding furniture
Paper and paper products
Printing and reproduction of recorded media
Coke and refined petroleum products
Chemicals and chemical products
Pharmaceuticals,medicinal chemicals, etc.
Rubber and plastics products
Other non-metallic mineral products
Basic metals
Fabricated metal products, except machinery
Computer, electronic and optical products
Electrical equipment
Machinery and equipment n.e.c.
Motor vehicles, trailers and semi-trailers
Other transport equipment
Furniture
Other manufacturing

// 단위 천단위로 맞추기 

