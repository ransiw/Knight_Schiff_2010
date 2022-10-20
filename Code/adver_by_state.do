*Create advertising by state
/* Method:
1) merge DMAs from Stromberg to counties from Census pop estimates, unit of observation is county (multiple counties in same DMA), save county_dma.dta
2) merge county_dma.dta by DMA code with lookup file so that we know which counties are in DMAs in the Wisconsin data, and which aren't
3) collapse demAds_subset.dta to get ads by state for three candidates 10/7/2003-3/2/2004, save this as temp.dta
4) merge county_dma with temp.dta so that each county is matched with advertising from Wisc data by DMA, if DMA was covered by Wisc data
*/
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\data\advertising"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\data\advertising"
cap cd "E:\research\momentum_in_primaries\data\advertising"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\data\advertising"
use wisc_dma_to_dma_codes.dta, clear
sort dma
save wisc_dma_to_dma_codes.dta, replace
use county_pop_estimates_2004.dta, clear
drop if sumlev==40 //Drop state totals
drop sumlev
merge state county using dma.dta  //this is the Stromberg data
replace dma=747 if ctyname=="Hoonah-Angoon Census Area"|ctyname=="Skagway Municipality" //was part of DMA 747
replace dman="Juneau" if ctyname=="Hoonah-Angoon Census Area"|ctyname=="Skagway Municipality" //was part of DMA 747
replace staten="AK" if stname=="Alaska"
replace dma=751 if ctyname=="Broomfield County" //Broomfield county was formed from other CO counties in Denver DMA
replace dman="Denver" if ctyname=="Broomfield County" //Broomfield county was formed from other CO counties in Denver DMA
replace top75=1 if ctyname=="Broomfield County" //Broomfield county was formed from other CO counties in Denver DMA
replace staten="CO" if stname=="Colorado"
drop if _merge==2 //drops Skagway and Clifton Forge (which is part of Roanoke in Census)
drop _merge
save county_dma.dta, replace
sort dma
merge dma using wisc_dma_to_dma_codes.dta
replace wisc_dma=0 if wisc_dma==. //there are 1341 counties that are not part of the Wisconsin DMAs
drop _merge
sort dma
save county_dma.dta, replace

*1)covers period between October 7, 2003 and March 2, 2004, candidates Dean, Kerry, Edwards, and separates by tone
use demAds_subset.dta, clear //demAds_subset covers period between October 7, 2003 and March 2, 2004, candidates Dean, Kerry, Edwards, and separates by tone
collapse (sum) est_cost spotleng, by(dma)
replace dma=999 if dma==. //Make 999 the dma code for what Wisconsin listed as "Cable"
sort dma
save temp.dta, replace
use county_dma.dta, clear
sort dma
cap drop _merge
merge dma using temp.dta
drop if _merge==2 //the "Cable" entry
drop _merge
//save county_dma_wisc.dta, replace
sort state county
gen spotleng_min=spotleng/60
gen person_minutes=spotleng_min*popestimate2004 //Nsm*Am
gen wisc_pop=. //This is the Nwisc: the population covered by the Wisc data, whether or not there was an ad
replace wisc_pop=popestimate2004 if wisc_dma==1
collapse (sum) person_minutes wisc_pop popestimate2004 spotleng est_cost, by(state stname staten)
gen coverage_pc=person_minutes/wisc_pop  //Sum(Nsm*Am)/Nwisc
gen tot_coverage=coverage_pc*popestimate2004 //Sum(Nsm*Am)*(Ns/Nwisc)
gen minutes_pc=spotleng/wisc_pop
gen estcost_pc=est_cost/wisc_pop
save adver_by_state.dta, replace

*2)Before Iowa: covers period between October 7, 2003 and January 19, 2004, candidates Dean, Kerry, Edwards, and separates by tone
use demAds_subset_bIowa.dta, clear //demAds_subset covers period between October 7, 2003 and March 2, 2004, candidates Dean, Kerry, Edwards, and separates by tone
collapse (sum) est_cost spotleng, by(dma)
replace dma=999 if dma==. //Make 999 the dma code for what Wisconsin listed as "Cable"
sort dma
save temp.dta, replace
use county_dma.dta, clear
sort dma
cap drop _merge
merge dma using temp.dta
drop if _merge==2 //the "Cable" entry
drop _merge
save county_dma_wisc.dta, replace
sort state county
gen person_minutes=spotleng*popestimate2004 //Nsm*Am
gen wisc_pop=. //This is the Nwisc: the population covered by the Wisc data, whether or not there was an ad
replace wisc_pop=popestimate2004 if wisc_dma==1
collapse (sum) person_minutes wisc_pop popestimate2004 spotleng est_cost, by(state stname staten)
gen coverage_pc=person_minutes/wisc_pop  //Sum(Nsm*Am)/Nwisc
gen tot_coverage=coverage_pc*popestimate2004 //Sum(Nsm*Am)*(Ns/Nwisc)
gen minutes_pc=spotleng/wisc_pop
gen estcost_pc=est_cost/wisc_pop
save adver_by_state_bIowa.dta, replace

*3)All Democratic candidates: covers period 10/7/2003-3/2/2004, separates by tone
use demAds_subset_allDems.dta, clear 
collapse (sum) est_cost spotleng, by(dma)
replace dma=999 if dma==. //Make 999 the dma code for what Wisconsin listed as "Cable"
sort dma
save temp.dta, replace
use county_dma.dta, clear
sort dma
cap drop _merge
merge dma using temp.dta
drop if _merge==2 //the "Cable" entry
drop _merge
save county_dma_wisc.dta, replace
sort state county
gen person_minutes=spotleng*popestimate2004 //Nsm*Am
gen wisc_pop=. //This is the Nwisc: the population covered by the Wisc data, whether or not there was an ad
replace wisc_pop=popestimate2004 if wisc_dma==1
collapse (sum) person_minutes wisc_pop popestimate2004 spotleng est_cost, by(state stname staten)
gen coverage_pc=person_minutes/wisc_pop  //Sum(Nsm*Am)/Nwisc
gen tot_coverage=coverage_pc*popestimate2004 //Sum(Nsm*Am)*(Ns/Nwisc)
gen minutes_pc=spotleng/wisc_pop
gen estcost_pc=est_cost/wisc_pop
save adver_by_state_allDems.dta, replace

*4)All Democratic candidates: covers period BEGINNING-3/2/2004, separates by tone
use demAds_allDems_allDates.dta, clear 
collapse (sum) est_cost spotleng, by(dma)
replace dma=999 if dma==. //Make 999 the dma code for what Wisconsin listed as "Cable"
sort dma
save temp.dta, replace
use county_dma.dta, clear
sort dma
cap drop _merge
merge dma using temp.dta
drop if _merge==2 //the "Cable" entry
drop _merge
save county_dma_wisc.dta, replace
sort state county
gen person_minutes=spotleng*popestimate2004 //Nsm*Am
gen wisc_pop=. //This is the Nwisc: the population covered by the Wisc data, whether or not there was an ad
replace wisc_pop=popestimate2004 if wisc_dma==1
collapse (sum) person_minutes wisc_pop popestimate2004 spotleng est_cost, by(state stname staten)
gen coverage_pc=person_minutes/wisc_pop  //Sum(Nsm*Am)/Nwisc
gen tot_coverage=coverage_pc*popestimate2004 //Sum(Nsm*Am)*(Ns/Nwisc)
gen minutes_pc=spotleng/wisc_pop
gen estcost_pc=est_cost/wisc_pop
sort staten
save adver_by_state_allDems_allDates.dta, replace

use complete_data1.dta, clear
gen staten=state
sort staten
save complete_data1.dta, replace

use adver_by_state_allDems_allDates.dta, clear
merge staten using complete_data1.dta, keep(vmonth vday vyear t)
drop if _merge==1
collapse (mean) minutes_pc, by(t)
twoway (connected minutes_pc t), name(allDems, replace) title(all candidates)
use adver_by_state.dta, clear
sort staten
merge staten using complete_data1.dta, keep(vmonth vday vyear t)
drop if _merge==1
gen missState=0
replace missState=1 if coverage_pc==.
gen numStates=1
collapse (sum) numStates missState (mean) coverage_pc minutes_pc, by(t)
twoway (connected coverage_pc t), name(threeCand, replace) title(three candidates)
twoway (connected minutes_pc t), name(threeCand, replace) title(three candidates)

*5)Three major Democratic candidates: covers period BEGINNING-3/2/2004, separates by tone
use demAds_threeDems_allDates.dta, clear
gen spotleng_m=spotleng/60
collapse (sum) est_cost spotleng spotleng_m numAds, by(dma)
replace dma=999 if dma==. //Make 999 the dma code for what Wisconsin listed as "Cable"
sort dma
save temp.dta, replace
use county_dma.dta, clear
sort dma
cap drop _merge
merge dma using temp.dta
drop if _merge==2 //the "Cable" entry
drop _merge
save county_dma_wisc.dta, replace
sort state county
gen person_minutes=spotleng_m*popestimate2004 //Nsm*Am
gen wisc_pop=. //This is the Nwisc: the population covered by the Wisc data, whether or not there was an ad
replace wisc_pop=popestimate2004 if wisc_dma==1
collapse (sum) person_minutes wisc_pop popestimate2004 spotleng spotleng_m est_cost numAds, by(state stname staten)
gen coverage_pc=person_minutes/wisc_pop  //Sum(Nsm*Am)/Nwisc
gen tot_coverage=coverage_pc*popestimate2004 //Sum(Nsm*Am)*(Ns/Nwisc)
gen minutes_pc=spotleng_m/wisc_pop
gen estcost_pc=est_cost/wisc_pop
gen cst=staten
sort cst
save adver_by_state_threeDems_allDates.dta, replace

*6) Create graph of percentage advertising by date (1/1/2004-3/2/2004) for three candidates
use demAds_subset.dta, clear
collapse (sum) numAds est_cost spotleng, by(date cand_id )
bysort date: egen tot_NumAds=sum(numAds)
bysort date: egen tot_estCost=sum(est_cost)
bysort date: egen tot_spotleng=sum(spotleng)
gen per_numAds=numAds/tot_NumAds
gen per_estCost=est_cost/tot_estCost
gen per_spotleng=spotleng/tot_spotleng
drop if date<td(01jan2004)
twoway (connected per_numAds date if cand_id=="US/DEAN_HOWARD") ///
(connected per_numAds date if cand_id=="US/EDWARDS_JOHN") (connected per_numAds date if cand_id=="US/KERRY_JOHN") ///
, legend(lab(1 "Dean") lab(2 "Edwards") lab(3 "Kerry")) name(per_numAds, replace) title(Percentage of total number of ads)

twoway (connected per_estCost date if cand_id=="US/DEAN_HOWARD") ///
(connected per_estCost date if cand_id=="US/EDWARDS_JOHN") (connected per_estCost date if cand_id=="US/KERRY_JOHN") ///
, legend(lab(1 "Dean") lab(2 "Edwards") lab(3 "Kerry")) name(per_estCost, replace) title(Percentage of total ad spending)

twoway (connected per_spotleng date if cand_id=="US/DEAN_HOWARD") ///
(connected per_spotleng date if cand_id=="US/EDWARDS_JOHN") (connected per_spotleng date if cand_id=="US/KERRY_JOHN") ///
, legend(lab(1 "Dean") lab(2 "Edwards") lab(3 "Kerry")) name(per_spotleng, replace) title(Percentage of total spot length )
