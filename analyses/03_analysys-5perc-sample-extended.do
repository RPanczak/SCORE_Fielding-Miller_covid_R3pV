capture log close
log using "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\03_analysys-5perc-sample-extended", smcl replace
//_1
display c(current_date)
//_2q
set seed 12345
    
if "`c(username)'" == "panczak" {
            
cd "C:\external\SCORE_Fielding-Miller_covid_R3pV\data"
    
}
else {    
    * settings for other users
}    
    
u "merged_covid_usa_prepared_extended_sample.dta" , clear
* u "merged_covid_usa_prepared_extended.dta" , clear
    
d
//_3
mdesc
//_4
ta state, m
//_5
ta nonurban, m
//_6
univar deaths, dec(0)
* hist deaths, width(10)
//_7
spshape2dta cb_2018_us_county_20m_prep_sample.shp, replace
* spshape2dta cb_2018_us_county_20m_prep.shp, replace
    
u cb_2018_us_county_20m_prep_sample, clear
d
spset fips, modify replace
spset, modify coordsys(latlong, miles)
sa, replace 
//_8
u "merged_covid_usa_prepared_extended_sample.dta" , clear
* u "merged_covid_usa_prepared_extended.dta" , clear
keep if nonurban
    
* stata deletes cases with missing obs
* then the dataset doesnt match the spatial matrix
* either fix missings or drop
mdesc
drop if mi(farmwork)
drop if mi(poverty)
//_9
merge 1:1 fips using cb_2018_us_county_20m_prep_sample
* merge 1:1 fips using cb_2018_us_county_20m_prep
assert _merge != 1
keep if _merge == 3
drop _merge
    
* grmap deaths
//_10
spmatrix create contiguity W, replace 

spregress deaths nonenglish farmwork uninsured poverty older pop_dens time_case1 time_case100, gs2sls dvarlag(W)
    
* estat impact
    
est sto m_extended_queen

//_11
spmatrix create contiguity W, rook replace 

spregress deaths nonenglish farmwork uninsured poverty older pop_dens time_case1 time_case100, gs2sls dvarlag(W)
    
est sto m_extended_rook
    
est tab m_extended_queen m_extended_rook , b(%6.3f) p(%6.3f)
//_^
log close
