*Clean Wisconsin Data
*we should cover the period between October 7, 2003 and March 2, 2004 and the candidates should be Dean, Kerry, Edwards
*we should also distinguish by tone, so, the unit of observation would be date-candidate-market-tone
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\data\advertising"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\data\advertising"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\data\advertising"
cap clear matrix
set mem 750m
use wisc_dma_to_dma_codes.dta, clear
sort market
save wisc_dma_to_dma_codes.dta, replace
use wiscads_2004_presidential.dta, clear
drop if date<td(07oct2003) | date>td(02mar2004)
keep if cand_id=="US/DEAN_HOWARD" | cand_id=="US/KERRY_JOHN" | cand_id=="US/EDWARDS_JOHN"
gen dummy=1
collapse (sum) spotleng est_cost numAds=dummy, by(date cand_id market ead_tone)
label define ead_tone 1 "attack" 2 "contrast" 3 "promote"
label values ead_tone ead_tone
sort market
merge market using wisc_dma_to_dma_codes.dta
drop if _merge==2
drop _merge
save demAds_subset.dta, replace

*The follow code segments create other subset files:

*1) data for the three candidates, from 10/7/2003-1/19/2004 (Iowa caucus)
use wiscads_2004_presidential.dta, clear
drop if date<td(07oct2003) | date>td(19jan2004)
keep if cand_id=="US/DEAN_HOWARD" | cand_id=="US/KERRY_JOHN" | cand_id=="US/EDWARDS_JOHN"
gen dummy=1
collapse (sum) spotleng est_cost numAds=dummy, by(date cand_id market ead_tone)
label define ead_tone 1 "attack" 2 "contrast" 3 "promote"
label values ead_tone ead_tone
sort market
merge market using wisc_dma_to_dma_codes.dta
drop if _merge==2
drop _merge
save demAds_subset_bIowa.dta, replace

*2) data for all candidates, normal date range 10/7/2003-3/2/2004
use wiscads_2004_presidential.dta, clear
drop if date<td(07oct2003) | date>td(02mar2004)
drop if cand_id=="US/BUSH_GEORGE"
gen dummy=1
collapse (sum) spotleng est_cost numAds=dummy, by(date cand_id market ead_tone)
label define ead_tone 1 "attack" 2 "contrast" 3 "promote"
label values ead_tone ead_tone
sort market
merge market using wisc_dma_to_dma_codes.dta
drop if _merge==2
drop _merge
save demAds_subset_allDems.dta, replace

*3) data for THREE candidates, date range BEGINNING-3/2/2004
*use wiscads_2004_presidential.dta if date<td(02mar2004), clear
use wiscads_2004_presidential.dta, clear
drop if date>td(02mar2004)
keep if cand_id=="US/DEAN_HOWARD" | cand_id=="US/KERRY_JOHN" | cand_id=="US/EDWARDS_JOHN"
gen dummy=1
collapse (sum) spotleng est_cost numAds=dummy, by(date cand_id market ead_tone)
label define ead_tone 1 "attack" 2 "contrast" 3 "promote"
label values ead_tone ead_tone
sort market
merge market using wisc_dma_to_dma_codes.dta
drop if _merge==2
drop _merge
save demAds_threeDems_allDates.dta, replace
