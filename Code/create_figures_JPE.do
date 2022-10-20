*Create Figures in JPE Style

*Figure 1: primaries in 2004 vs 2008
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use primaries.dta, clear
label variable num_2004 "2004"
label variable num_2008 "2008"
format date %tdMon_dd
twoway (bar num_2004 date) (bar num_2008 date), scheme(s1mono) ytitle("Count") xtitle("Date") title("Figure 1: Number of Primaries by Date") name(fig1, replace)
*Now use the graph editor to change 2008 series so that there is no fill and the outline thickness is "v.thin" 
gr use fig1
gr export "../../documents/JPE_Paperwork/Fig1_JPE.eps", replace

*Figures 2-4
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use iowa_data.dta, clear
bysort cdate: egen i_dean2=mean(i_2) if (i_2==1 | i_3==1 | i_5==1)
bysort cdate: egen i_edwards2=mean(i_3) if (i_2==1 | i_3==1 | i_5==1)
bysort cdate: egen i_kerry2=mean(i_5) if (i_2==1 | i_3==1 | i_5==1)
collapse (mean)  i_kerry2 i_edwards2 i_dean2 kerryvs edwardsvs deanvs, by(edate)

drop if (edate<d(15dec2003) | edate>d(27jan2004))

gen twoDayDean=(i_dean2[_n-1]+i_dean2)/2 if mod(_n,2)==0
twoway (line twoDayDean edate, sort) (scatter i_dean2 edate, sort) (scatter deanvs edate, sort msize(large) mcolor(black)) ///
if edate>=d(15dec2003) & edate<d(27jan2004), xline(16089) title(Figure 2: Dean before and after the Iowa primary) ///
legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result") rows(1) region(lstyle(none))) ytitle("Voteshare") xtitle("Date") name(dean, replace) scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig2_JPE.eps", replace

gen twoDayKerry=(i_kerry2[_n-1]+i_kerry2)/2 if mod(_n,2)==0
twoway (line twoDayKerry edate, sort) (scatter i_kerry2 edate, sort) (scatter kerryvs edate, sort msize(large) mcolor(black)) ///
if edate>=d(15dec2003) & edate<d(27jan2004), xline(16089) title(Figure 3: Kerry before and after the Iowa primary) ///
legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result") rows(1) region(lstyle(none))) ytitle("Voteshare") xtitle("Date") name(kerry, replace) scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig3_JPE.eps", replace

gen twoDayEdwards=(i_edwards2[_n-1]+i_edwards2)/2 if mod(_n,2)==0
twoway (line twoDayEdwards edate, sort) (scatter i_edwards2 edate, sort) (scatter edwardsvs edate, sort msize(large) mcolor(black)) ///
if edate>=d(15dec2003) & edate<d(27jan2004), xline(16089) title(Figure 4: Edwards before and after the Iowa primary) ///
legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result") rows(1) region(lstyle(none))) ytitle("Voteshare") xtitle("Date") name(edwards, replace) scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig4_JPE.eps", replace

*Figure 5
use after2_nodist.dta, replace
label variable t "Period (t)"
twoway (connected mud t, sort) (connected mue t, sort), ///
ttext(.8 1.6  "Dean") ttext(-.8 1.75  "Edwards") name(fig5a, replace) title(Figure 5a: Mean of prior (Kerry=0)) xscale(range(1 10)) xlabel(1(1)10) ///
ytitle(Mean of prior at t) yline(0) legend(off) scheme(s1mono)
twoway (connected sigma t), name(fig5b, replace)  yscale(range(0 2.5)) ytitle(Variance of prior at t) title(Figure 5b: Variance of prior) xscale(range(1 10)) xlabel(1(1)10) scheme(s1mono)
gr combine fig5a fig5b, col(1) scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig5_JPE.eps", replace

*Figure 6: combines public, private, and ratio of weights
twoway (connected alpha t, sort) (connected beta t, sort) (connected ratio t, sort), xscale(range(1 10)) xlabel(1(1)10) title(Figure 6: Weights on private and public voting signals) xscale(range(1 10)) ytitle(Weight) legend(lab(1 "Private") lab(2 "Public") lab(3 "Public relative to private") rows(1) region(lstyle(none))) scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig6_JPE.eps", replace
/*
*twoway (connected alpha t, mcolor(green) clcolor(green)) (connected beta t, sort mcolor(red) clcolor(red)), xtitle(t) title(Figure 4: Weights on Private and Public Voting Signals) xscale(range(1 10)) xlabel(1(1)10) ytitle(weight)
*fig
*twoway (connected ratio t), xtitle(t) ytitle(Ratio of public to private weight) title(Figure 5: Social learning falls over time) xscale(range(1 10)) xlabel(1(1)10)
*Combining figures 4 and 5
twoway (connected alpha t, mcolor(green) clcolor(green)) (connected beta t, sort mcolor(red) clcolor(red)) (connected ratio t, sort mcolor(blue) clcolor(blue)), xscale(range(1 10)) xlabel(1(1)10) title(Figure 4: Weights on Private and Public Voting Signals) xscale(range(1 10)) ytitle(weight)
*/

*Figure 7: Structural break analysis
*------------------------------------------------------------------------------------------------
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use structural_break_logit.dta, clear
tab crb06, gen(i_)
collapse ll* dev i_*, by(edate)
table edate, c(mean dev)
//twoway (connected dev edate, title("Figure 7: Testing for structural break") ytitle("Fit (deviance)") xtitle("Break date (series splits after break date)") sort xline(16089)), name(Deviance, replace) ttext(4150 16093 "Iowa (1/19)")
twoway (connected ll edate, title("Figure 7: Testing for structural break") ytitle("Fit (log likelihood)") ///
xtitle("Break date") sort xline(16089)), name(LogLIke, replace) ttext(-2075 16093 "Iowa (1/19)") scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig7_JPE.eps", replace
/* OLD
use structural_break.dta, clear
replace after=1
replace after=0 if day<td(23jan2004)
reg EdKerry_coeff after
predict yhat
gr twoway (connected EdKerry_coeff day) (connected yhat day if day<td(23jan2004)) (connected yhat day if day>=td(23jan2004)), xline(16089) ttext(.75 16100  "Iowa 1/19, break at 1/22") name(EdKerry, replace) title("Edwards vs Kerry") legend(off)

cap drop yhat
replace after=1
replace after=0 if day<td(20jan2004)
reg DeanKerry_coeff after
predict yhat
gr twoway (connected DeanKerry_coeff day) (connected yhat day if day<td(20jan2004)) (connected yhat day if day>=td(20jan2004)), xline(16089) ttext(3 16093  "Iowa 1/19") name(DeanKerry, replace) title("Dean vs Kerry") legend(off)

cap drop yhat
replace after=1
replace after=0 if day<td(20jan2004)
reg EdDean_coeff after
predict yhat
gr twoway (connected EdDean_coeff day) (connected yhat day if day<td(20jan2004)) (connected yhat day if day>=td(20jan2004)), xline(16089) ttext(.75 16093  "Iowa 1/19") name(EdDean, replace) title("Edwards vs Dean") legend(off)
*/

*Figure 8: Campaign Contribution Share
*---------------------------------------------------------------------------------------------------------------------
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use contributions.dta, clear
label variable edate "Data of contribution"
twoway (connected share_kerry edate, sort xline(16089)), name(KerryContrib, replace) scheme(s1mono)
twoway (connected share_dean edate, sort xline(16089)), name(DeanContrib, replace) scheme(s1mono)
twoway (connected share_edwards edate, sort xline(16089)), name(EdwardsContrib, replace) scheme(s1mono)
gr combine KerryContrib DeanContrib EdwardsContrib, col(1) title(Figure 8: Candidate share of campaign contributions) ycommon xcommon scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig8_JPE.eps", replace
*Figure 9: Advertising Expenditure Share
*----------------------------------------------------------------------------------------------------------------------
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\data\advertising"
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\data\advertising"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\data\advertising"
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
label variable date "Date ad aired"
save fig9.dta, replace
twoway (connected KerrySpend date, sort xline(16089)), name(KerrySpend, replace) scheme(s1mono)
twoway (connected DeanSpend date, sort xline(16089)), name(DeanSpend, replace) scheme(s1mono)
twoway (connected EdwardsSpend date, sort xline(16089)), name(EdwardsSpend, replace) scheme(s1mono)
gr combine KerrySpend DeanSpend EdwardsSpend, col(1) title(Figure 9: Candidate share of campaign expenditures) ycommon xcommon scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig9_JPE.eps", replace
*Figure 10: Voting weights (eta shock measure) by period, both total effect (direct + indirect) and direct effect alone
*----------------------------------------------------------------------------------------------------------------------
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use adver_analysis.dta, clear
bysort shockPeriod: egen avCoverage=mean(coverage_pc)
replace avCoverage=avCoverage/1000
label variable avCoverage "Minutes of exposure per capita (000's)"
label variable shockPeriod "Period (t)"
*use equityEta_weights.dta, replace
*gr twoway (connected totWeight shockPeriod if shockPeriod>0) (connected directWeight shockPeriod if shockPeriod>0), xscale(range(1 10)) xlabel(1(1)10) title("Figure 9: Implied Voting Weights")
gr twoway (connected totWeight shockPeriod if shockPeriod>0) (connected directWeight shockPeriod if shockPeriod>0), xscale(range(1 10)) xlabel(1(1)10) name(voteWeights, replace) title("Implied voting weights") ytitle("Weight") scheme(s1mono)
gr twoway (connected avCoverage shockPeriod if shockPeriod>0), xscale(range(1 10)) xlabel(1(1)10) note("Advertising from 2/18/2003-3/2/2004 for 3 candidates; data not available for ND, RI, and UT.") name(adCoverage, replace) title("Advertising coverage") scheme(s1mono)
gr combine voteWeights adCoverage, col(1) title("Figure 10: Advertising coverage vs implied voting weights") scheme(s1mono)
gr export "../../documents/JPE_Paperwork/Fig10_JPE.eps", replace
