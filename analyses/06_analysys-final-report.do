/***
# **Replication of a Research Claim from Fielding-Miller et al. (2020), from medRxiv**  

2020-11-23

Replication Team: *Kent Jason Cheng* and *Radoslaw Panczak*  

Research Scientist: *Nick Fox*  

Action Editor: *Gustav Nilsonne*  

Project ID: *Fielding-Miller_covid_R3pV - Cheng/Panczak - Data Analytic Replication - 615k*  

OSF project: [https://osf.io/w7gdb/](https://osf.io/w7gdb/)  

Preregistration: [https://osf.io/2kd4e](https://osf.io/2kd4e)  
***/

//OFF    
set seed 12345

if "`c(username)'" == "panczak" {
		
	cd "C:\external\SCORE_Fielding-Miller_covid_R3pV\data"

}
else {    
	* settings for other users
}	

* command to generrate the reported
* [requires markdoc package to be installed and configured]
* markdoc "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\06_analysys-final-report.do", mini export(pdf) replace style("simple")

* Creating the Stata-format shapefile
spshape2dta cb_2018_us_county_20m_prep.shp, replace
u cb_2018_us_county_20m_prep, clear
d
spset fips, modify replace
spset, modify coordsys(latlong, miles)
sa, replace 
//ON

/***
## Claim summary 

There is a negative association between insured status and mortality. This reflects the following statement from the paper's abstract: *Percentage of uninsured individuals was associated with lower reported COVID-19 mortality (b = -0.36, p = 0.001).* The claim is tested with a spatial autoregressive model to assess the association between number of deaths and percentage of uninsured individuals, adjusting for potential confounders, and fitted the model with a spatial lag of the dependent variable based on a contiguity matrix. The finding is that the percentage of uninsured individuals was associated with **lower reported COVID-19 mortality (b = -0.36, p = 0.001).**

## Replication Criteria

Criteria for a successful replication attempt is a statistically significant effect (alpha = .05, two tailed) in the same pattern as the original study on the focal hypothesis test (H*). For this study, this criteria is met by obtaining a statistically significant (p- value specified in the preprint is 0.001) regression coefficient from the adjusted model run on the subsample of non-urban counties.

## Replication Result

### Stage 1: analyses using "extended" dataset
***/

//OFF
* ***********************************
* extended analysis

** Case selection
u "merged_covid_usa_prepared_extended.dta" , clear
d

* Urban
ta nonurban, m
keep if nonurban

* Missing data 
** stata deletes cases with missing obs, then the dataset doesnt match the spatial matrix >> drop ahead as spec in preregistration
mdesc
distinct state if mi(nonenglish)
drop if mi(nonenglish)
distinct state if mi(farmwork)
drop if mi(farmwork)
distinct state if mi(poverty)
drop if mi(poverty)

** Merging covid data with the Stata-format shapefile
merge 1:1 fips using cb_2018_us_county_20m_prep
assert _merge != 1
keep if _merge == 3
drop _merge
* grmap deaths
//ON

/***
For stage 1 data collection when the dataset extended beyond the time of the preprint analyses was used, we found no significant effect of the `uninsured` variable. Table below reports full details of the regression model and number of observations used for the analysis.  

At stage 1, the replication was **unsuccessful** according to SCORE criteria. 
***/

* SAR models 
** Fitting model with a spatial lag of the dependent variable; using `gs2sls` option (instead of `ml`) to guard against potential heteroskedasticity. Using `rook` contiguity
qui: spmatrix create contiguity W, replace 
spregress deaths nonenglish farmwork uninsured poverty older pop_dens time_case1 time_case100, gs2sls dvarlag(W)
* est sto m_extended_queen
* esttab m_extended_queen, b(%6.3f) p(%6.3f) nostar wide nopa nodep nomti nonum

/***
This finding remained when sensitivity analysis using alternative definition of neighbourhoods ("rook") was used. 
***/

** Sensitivity analysis using `rook` contiguity
qui: spmatrix create contiguity W, rook replace 
spregress deaths nonenglish farmwork uninsured poverty older pop_dens time_case1 time_case100, gs2sls dvarlag(W)
* est sto m_extended_rook
* esttab m_extended_queen, b(%6.3f) p(%6.3f) nostar wide nopa nodep nomti nonum

/***
### Stage 2: analyses using "original" dataset
***/

//OFF
* ***********************************
* original analysis

** Case selection
u "merged_covid_usa_prepared_original.dta" , clear
d

* Urban
ta nonurban, m
keep if nonurban

* Missing data 
** stata deletes cases with missing obs, then the dataset doesnt match the spatial matrix >> drop ahead as spec in preregistration
mdesc
distinct state if mi(nonenglish)
drop if mi(nonenglish)
distinct state if mi(farmwork)
drop if mi(farmwork)
distinct state if mi(poverty)
drop if mi(poverty)

** Merging covid data with the Stata-format shapefile
merge 1:1 fips using cb_2018_us_county_20m_prep
assert _merge != 1
keep if _merge == 3
drop _merge
* grmap deaths
//ON

/***
For stage 2 data collection when the dataset created suing specifications from the preprint was used, we found significant effect of the `uninsured` variable. The effect was observed in the same direction, but it was weaker and the p-value higher than that reported in the preprint. Table below reports full details of the regression model and number of observations used for the analysis.  

At stage 1, the replication was **unsuccessful** according to SCORE criteria. 
***/

* SAR models 
** Fitting model with a spatial lag of the dependent variable; using `gs2sls` option (instead of `ml`) to guard against potential heteroskedasticity. Using `rook` contiguity
qui: spmatrix create contiguity W, replace 
spregress deaths nonenglish farmwork uninsured poverty older pop_dens time_case1 time_case100, gs2sls dvarlag(W)
* est sto m_original_queen
* esttab m_original_queen, b(%6.3f) p(%6.3f) nostar wide nopa nodep nomti nonum
/***
Once again the analysis was not affected by alternative definition of neighbourhoods. 
***/

** Sensitivity analysis using `rook` contiguity
qui: spmatrix create contiguity W, rook replace 
spregress deaths nonenglish farmwork uninsured poverty older pop_dens time_case1 time_case100, gs2sls dvarlag(W)
* est sto m_original_rook
* esttab m_original_rook, b(%6.3f) p(%6.3f) nostar wide nopa nodep nomti nonum

/***
## Deviations from preregistration

There were no deviations from preregistration during the analysis.

## Description of materials provided.

The following materials are publicly available on the [OSF project site](https://osf.io/w7gdb/):

- The raw spatial datafile saved as shape file: `cb_2018_us_county_20m.zip`
- The spatial data prepraration files saved as literate programing markdown for R: `01_spatial-sample.Rmd`
- The analytic spatial datafile saved as shape file: `cb_2018_us_county_20m_prep.zip`

- The raw datafile saved as Stata file: `merged_covid_usa_v2.dta`
- The data prepraration files saved as literate programing markdown for Stata: `02_data-preparation-extended.stmd` and `04_data-preparation-original.stmd`

- The analytic datafiles saved as Stata files: `merged_covid_usa_prepared_original.dta` and `merged_covid_usa_prepared_original.dta`
- The full data analysis script, provided as a Stata markdown document: `06_analysys-final-report.do` with the pdf output file being this report.

## Citation

Fielding-Miller RK, Sundaram ME, Brouwer K (2020) Social determinants of COVID-19 mortality at the county level. *medRxiv* 2020.05.03.20089698; doi: [10.1101/2020.05.03.20089698](https://doi.org/10.1101/2020.05.03.20089698)
***/
