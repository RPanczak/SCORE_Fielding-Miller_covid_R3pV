capture log close
log using "analyses\02_data-preparation-extended", smcl replace
//_1
display c(current_date)
//_2q
set seed 12345
    
if "`c(username)'" == "panczak" {
            
    cd "C:\external\SCORE_Fielding-Miller_covid_R3pV"
}
else {    
    * adapt settings for other users
    * cd ...
}    
    
use "data-raw\Script\merged_covid_usa_v2.dta" , clear
    
* crap date handling in original files?
tostring date, replace
gen date_proper = date(date, "YMD")
format date_proper %tdCCYY-NN-DD
order date_proper, a(date)
    
la var cases "Cases"
d
//_3q
su date_proper, format
//_4
drop if county == "Unknown"
//_5
mdesc
//_6
preserve
keep if mi(fips)
fre county
* fre state
restore
//_7
preserve
keep if mi(date_proper)
* fre fips
distinct fips
restore
//_8
count if inlist(fips, 36005, 36047, 36061, 36081, 36085)
//_9
drop if mi(fips)
drop if mi(date_proper)
//_10
drop if state == "Northern Mariana Islands"
drop if state == "Puerto Rico"
    
* first two could be also achieved with 
* drop if fips >= 60000
* su fips
//_11
* ta county if mi(S1602_C01_001E) // & date == "2020-04-26"
* ta county if mi(S1701_C03_001E) // & date == "2020-04-26"
* ta county if mi(LABOR)             // & date == "2020-04-26"
distinct county if mi(S1602_C01_001E) & date_proper == date("2020-07-16", "YMD")
distinct county if mi(S1701_C03_001E) & date_proper == date("2020-07-16", "YMD")
distinct county if mi(LABOR)             & date_proper == date("2020-07-16", "YMD")
    
fre state if mi(LABOR)             & date_proper == date("2020-07-16", "YMD")
//_12q
* count if inlist(fips, 36005, 36047, 36061, 36081, 36085)
//_13
ren S1602_C01_001E nonenglish
order nonenglish, a(deaths)
la var nonenglish "% nonenglish speaking hh"
univar nonenglish, d(1)
//_14
gen farmwork = (LABOR / DP05_0001E) * 100
order farmwork, a(nonenglish)
la var farmwork "% engaged in farmwork"
univar farmwork, d(1)
drop LABOR DP05_0001E
//_15
gen uninsured = S2701_C05_011E + S2701_C05_012E
order uninsured, a(farmwork)
la var uninsured "% uninsured under 65"
univar uninsured, d(1)
drop S2701_C05_011E S2701_C05_012E
//_16
ren S1701_C03_001E poverty
order poverty, a(uninsured)
la var poverty "% below poverty line"
univar poverty, d(1)
//_17
ren DP05_0024PE older
order older, a(poverty)
la var older "% aged 65 and above"
univar older, d(1)
//_18
ren A00002_002 pop_dens
order pop_dens, a(older)
la var pop_dens "Pop density"
univar pop_dens, d(1)
//_19
gen nonurban = pop_dens <= 1000
order nonurban, a(date_proper)
la var nonurban "Non-urban counties flag"
la de nonurban 0 "urban" 1 "non-urban"
la val nonurban nonurban
fre nonurban if date_proper == date("2020-07-16", "YMD")
//_20
sort fips date_proper, stable    
by fips: egen date_case1 = min(date_proper)
format date_case1 %tdCCYY-NN-DD
gen time_case1 = date_proper - date_case1
*drop date_case1
la var date_case1 "Date of case 1"
la var time_case1 "Days since case 1 in county"
//_21q
    
* minimum dates as spec by data finder
qui{
    drop sip_effect
    gen sip_effect = date("20200404", "YMD")      if state=="Alabama" 
    replace sip_effect = date("20200328", "YMD") if state=="Alaska" 
    replace sip_effect = date("20200331", "YMD") if state=="Arizona" 
    replace sip_effect = date("20200319", "YMD") if state=="California" 
    replace sip_effect = date("20200326", "YMD") if state=="Colorado" 
    replace sip_effect = date("20200323", "YMD") if state=="Connecticut" 
    replace sip_effect = date("20200324", "YMD") if state=="Delaware" 
    replace sip_effect = date("20200401", "YMD") if state=="District of Columbia" 
    replace sip_effect = date("20200403", "YMD") if state=="Florida" 
    replace sip_effect = date("20200403", "YMD") if state=="Georgia" 
    replace sip_effect = date("20200325", "YMD") if state=="Hawaii" 
    replace sip_effect = date("20200325", "YMD") if state=="Idaho" 
    replace sip_effect = date("20200321", "YMD") if state=="Illinois" 
    replace sip_effect = date("20200324", "YMD") if state=="Indiana" 
    replace sip_effect = date("20200330", "YMD") if state=="Kansas" 
    replace sip_effect = date("20200326", "YMD") if state=="Kentucky" 
    replace sip_effect = date("20200323", "YMD") if state=="Louisiana" 
    replace sip_effect = date("20200402", "YMD") if state=="Maine" 
    replace sip_effect = date("20200330", "YMD") if state=="Maryland" 
    replace sip_effect = date("20200324", "YMD") if state=="Massachusetts" 
    replace sip_effect = date("20200324", "YMD") if state=="Michigan"
    replace sip_effect = date("20200327", "YMD") if state=="Minnesota" 
    replace sip_effect = date("20200403", "YMD") if state=="Mississippi" 
    replace sip_effect = date("20200406", "YMD") if state=="Missouri" 
    replace sip_effect = date("20200328", "YMD") if state=="Montana" 
    replace sip_effect = date("20200401", "YMD") if state=="Nevada" 
    replace sip_effect = date("20200327", "YMD") if state=="New Hampshire" 
    replace sip_effect = date("20200324", "YMD") if state=="New Jersey" 
    replace sip_effect = date("20200324", "YMD") if state=="New Mexico" 
    replace sip_effect = date("20200322", "YMD") if state=="New York" 
    replace sip_effect = date("20200330", "YMD") if state=="North Carolina" 
    replace sip_effect = date("20200323", "YMD") if state=="Ohio" 
    replace sip_effect = date("20200328", "YMD") if state=="Oklahoma" 
    replace sip_effect = date("20200323", "YMD") if state=="Oregon" 
    replace sip_effect = date("20200401", "YMD") if state=="Pennsylvania" 
    replace sip_effect = date("20200328", "YMD") if state=="Rhode Island" 
    replace sip_effect = date("20200406", "YMD") if state=="South Carolina" 
    *replace sip_effect = date("", "YMD") if state=="South Dakota" 
    replace sip_effect = date("20200331", "YMD") if state=="Tennessee" 
    replace sip_effect = date("20200402", "YMD") if state=="Texas" 
    replace sip_effect = date("20200330", "YMD") if state=="Utah" 
    replace sip_effect = date("20200325", "YMD") if state=="Vermont" 
    replace sip_effect = date("20200330", "YMD") if state=="Virginia" 
    replace sip_effect = date("20200323", "YMD") if state=="Washington" 
    replace sip_effect = date("20200324", "YMD") if state=="West Virginia"
    replace sip_effect = date("20200325", "YMD") if state=="Wisconsin" 
    * replace sip_effect = date("20200328", "YMD") if state=="Wyoming" // inonsistent with preprint info - keeping preprint even if incorrect
        
    format sip_effect %tdCCYY-NN-DD
    la var sip_effect "SIP effect start date"
}
    
* fre state if mi(sip_effect) // not all good here

//_22
gen temp = date_proper if cases >= 100
sort fips date_proper, stable    
by fips: egen date_case100 = min(temp)
drop temp
format date_case100 %tdCCYY-NN-DD
    
gen time_case100 = date_case100 - sip_effect
*drop date_case100
    
* this states are 0 as per preprint specs 
replace time_case100 = 0 if inlist(state, "Arkansas", "Iowa", "Nebraska", "North Dakota", "Wyoming")

* this state is not mentioned in the preprint but should be 0 according to data finder 
replace time_case100 = 0 if inlist(state, "South Dakota")
    
la var date_case100 "Date of case 100"
la var time_case100 "Days between case 100 in county and SIP in state"
//_23
distinct fips if mi(time_case100)
    
replace time_case100 = 0 if mi(time_case100) & mi(date_case100)
//_24
la var deaths "Deaths"
univar deaths, d(0)
univar deaths, d(0) by(nonurban)
//_25q
sort fips date_proper, stable,
by fips: keep if _n == _N
su date_proper, format
drop date_proper
* d
* distinct fips
fre nonurban
qui compress
sa "data\merged_covid_usa_prepared_extended.dta" , replace
d
//_26q

import delim "data\fips_sample.csv", clear
sa "data\fips_sample.dta", replace

u "data\merged_covid_usa_prepared_extended.dta" , clear
mmerge fips using "data\fips_sample.dta", t(1:1)
* br if _merge == 2
keep if _merge == 3
drop _merge
sa "data\merged_covid_usa_prepared_extended_sample.dta" , replace    
d
//_27q
u "data\merged_covid_usa_prepared_extended.dta" , clear
keep fips
export delim "data\fips_extended.csv", replace
//_28q
u "data\merged_covid_usa_prepared_extended.dta" , clear
keep if mi(farmwork)
keep fips county state
export delim "data\fips_missing_farmwork.csv", replace
//_^
log close
