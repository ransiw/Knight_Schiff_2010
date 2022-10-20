*Analyzes the advertising data to show relationship between implied voting weights and advertising
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use complete_data1.dta, clear
sort cst
save complete_data1.dta, replace
use equityEta.dta, clear
sort shockPeriod
save equityEta.dta, replace
use equityTheta.dta, clear
sort shockPeriod
save equityTheta.dta, replace
*use adver_by_state.dta, clear
use adver_by_state_threeDems_allDates.dta, clear
sort cst
merge cst using complete_data1.dta, keep(vmonth vday vyear t)
drop if _merge==1
drop _merge
gen shockPeriod=t
sort shockPeriod
merge shockPeriod using equityEta_weights.dta, keep(stDirect stTotal totWeight directWeight)
drop if _merge==2
duplicates drop
drop _merge
sort shockPeriod
merge shockPeriod using equityTheta.dta, keep(thetaWeight thetaWeight2)
drop if _merge==2
duplicates drop
drop _merge
save adver_analysis.dta, replace

*Run regression of coverage on implied voting weights
reg coverage_pc stTotal, robust
outreg2 using results\voteWeights, bdec(3) excel bracket label replace
reg coverage_pc thetaWeight, robust
outreg2 using results\voteWeights, bdec(3) excel bracket label append

*Run regression of coverage on implied voting weights USING LOG MEASURES
reg coverage_pc etaWeight2, robust
outreg2 using results\voteWeights, bdec(3) excel bracket label append
reg coverage_pc thetaWeight2, robust
outreg2 using results\voteWeights, bdec(3) excel bracket label append

*Create figures of coverage vs implied voting weights
gen missState=0
replace missState=1 if coverage_pc==. //we have no advertising data for ND, RI, and UT
gen numStates=1
collapse (sum) numStates missState (mean) coverage_pc minutes_pc etaWeight etaWeight2 thetaWeight thetaWeight2, by(t)
twoway (connected coverage_pc t, yaxis(1)) (connected etaWeight t, yaxis(2)), name(adver_eta, replace) title(Advertising Coverage vs Implied Voting Weights) ///
 note("From 2/18/2003-3/2/2004 for Dean, Edwards, Kerry")
twoway (connected coverage_pc t, yaxis(1)) (connected thetaWeight t, yaxis(2)), name(adver_theta, replace) title(Advertising Coverage vs Implied Voting Weights) ///
 note("From 2/18/2003-3/2/2004 for Dean, Edwards, Kerry")
twoway (connected coverage_pc t, yaxis(1)) (connected etaWeight2 t, yaxis(2)), name(adver_leta, replace) title(Advertising Coverage vs Implied LOG Voting Weights) ///
 note("From 2/18/2003-3/2/2004 for Dean, Edwards, Kerry")
twoway (connected coverage_pc t, yaxis(1)) (connected thetaWeight2 t, yaxis(2)), name(adver_ltheta, replace) title(Advertising Coverage vs Implied LOG Voting Weights) ///
 note("From 2/18/2003-3/2/2004 for Dean, Edwards, Kerry")

*Create graph of percentage advertising by date (1/1/2004-3/2/2004) for three candidates
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\data\advertising"
use demAds_subset.dta, clear
collapse (sum) numAds est_cost spotleng, by(date cand_id )
gen cID=2 if cand_id=="US/DEAN_HOWARD"
replace cID=3 if cand_id=="US/EDWARDS_JOHN"
replace cID=5 if cand_id=="US/KERRY_JOHN"
drop cand_id
reshape wide numAds est_cost spotleng, i(date) j(cID)
egen tot_NumAds=rowtotal(numAds2 numAds3 numAds5)
egen tot_estCost=rowtotal(est_cost2 est_cost3 est_cost5)
egen tot_spotleng=rowtotal(spotleng2 spotleng3 spotleng5)
gen DeanSpend=est_cost2/tot_estCost
replace DeanSpend=0 if DeanSpend==.
gen EdwardsSpend=est_cost3/tot_estCost
replace EdwardsSpend=0 if EdwardsSpend==.
gen KerrySpend=est_cost5/tot_estCost
replace KerrySpend=0 if KerrySpend==.

label variable DeanSpend "Dean (share)"
label variable EdwardsSpend "Edwards (share)"
label variable KerrySpend "Kerry (share)"
label variable date "Date Ad Aired"

drop if date<td(01jan2004)

format %d date
twoway (connected KerrySpend date, sort xline(16089)), name(KerrySpend, replace)
twoway (connected DeanSpend date, sort xline(16089)), name(DeanSpend, replace)
twoway (connected EdwardsSpend date, sort xline(16089)), name(EdwardsSpend, replace)
gr combine KerrySpend DeanSpend EdwardsSpend, col(1) title(Figure 8: Candidate Share of Campaign Expenditures) ycommon xcommon

twoway (connected per_numAds date if cand_id=="US/DEAN_HOWARD") ///
(connected per_numAds date if cand_id=="US/EDWARDS_JOHN") (connected per_numAds date if cand_id=="US/KERRY_JOHN") ///
, legend(lab(1 "Dean") lab(2 "Edwards") lab(3 "Kerry")) name(per_numAds, replace) title(Percentage of total number of ads)




twoway (connected per_estCost date if cand_id=="US/DEAN_HOWARD") ///
(connected per_estCost date if cand_id=="US/EDWARDS_JOHN") (connected per_estCost date if cand_id=="US/KERRY_JOHN") ///
, legend(lab(1 "Dean") lab(2 "Edwards") lab(3 "Kerry")) name(per_estCost, replace) title(Percentage of total ad spending)

twoway (connected per_spotleng date if cand_id=="US/DEAN_HOWARD") ///
(connected per_spotleng date if cand_id=="US/EDWARDS_JOHN") (connected per_spotleng date if cand_id=="US/KERRY_JOHN") ///
, legend(lab(1 "Dean") lab(2 "Edwards") lab(3 "Kerry")) name(per_spotleng, replace) title(Percentage of total spot length )
