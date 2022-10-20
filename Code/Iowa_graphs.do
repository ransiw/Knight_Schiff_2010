*cap cd "Z:\My Documents\economics\momentum_in_primaries\analysis\August"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use complete_data1.dta, clear
sort vyear vmonth vday
save complete_data1.dta, replace
use complete_data.dta, clear
rename month vmonth
rename year vyear
rename day vday
sort vyear vmonth vday
cap drop _merge
save iowa_data.dta, replace
merge vyear vmonth vday using complete_data1, keep(kerry edwards dean)
gen kerryvs=kerry/(kerry+edwards+dean)
gen edwardsvs=edwards/(kerry+edwards+dean)
gen deanvs=dean/(kerry+edwards+dean)

egen double uniqelec=tag(kerry)
replace kerryvs=. if uniqelec==0
replace edwardsvs=. if uniqelec==0
replace deanvs=. if uniqelec==0

save iowa_data.dta, replace
bysort cdate: egen i_dean2=mean(i_2) if (i_2==1 | i_3==1 | i_5==1)
bysort cdate: egen i_edwards2=mean(i_3) if (i_2==1 | i_3==1 | i_5==1)
bysort cdate: egen i_kerry2=mean(i_5) if (i_2==1 | i_3==1 | i_5==1)
collapse (mean)  i_kerry2 i_edwards2 i_dean2 kerryvs edwardsvs deanvs, by(edate)

drop if (edate<d(15dec2003) | edate>d(27jan2004))

gen twoDayKerry=(i_kerry2[_n-1]+i_kerry2)/2 if mod(_n,2)==0
twoway (line twoDayKerry edate, sort) (scatter i_kerry2 edate, sort) (scatter kerryvs edate, sort msize(large) mcolor(black)) if edate>=d(15dec2003) & edate<d(27jan2004), xline(16089) title(Figure 4: Kerry before and after the Iowa primary) legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result")) ytitle("Voteshare") xtitle("Date") name(kerry, replace)
*graph export IowaKerry.eps, replace

gen twoDayEdwards=(i_edwards2[_n-1]+i_edwards2)/2 if mod(_n,2)==0
twoway (line twoDayEdwards edate, sort) (scatter i_edwards2 edate, sort) (scatter edwardsvs edate, sort msize(large) mcolor(black)) if edate>=d(15dec2003) & edate<d(27jan2004), xline(16089) title(Figure 5: Edwards before and after the Iowa primary) legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result")) ytitle("Voteshare") xtitle("Date") name(edwards, replace)
*graph export IowaEdwards.eps, replace

gen twoDayDean=(i_dean2[_n-1]+i_dean2)/2 if mod(_n,2)==0
twoway (line twoDayDean edate, sort) (scatter i_dean2 edate, sort) (scatter deanvs edate, sort msize(large) mcolor(black)) if edate>=d(15dec2003) & edate<d(27jan2004), xline(16089) title(Figure 3: Dean before and after the Iowa primary) legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result")) ytitle("Voteshare") xtitle("Date") name(dean, replace)
*graph export IowaDean.eps, replace



twoway (line twoDayKerry edate, sort) (scatter i_kerry2 edate, sort) (scatter kerryvs edate, sort msize(large) mcolor(black)) if edate>=d(15dec2003), xline(16089) xline(16097) xline(16104) xline(16108) xline(16109) xline(16111) xline(16115)  title(Figure 4: Kerry before and after the Iowa primary) legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result")) ytitle("Voteshare") xtitle("Date") name(kerry, replace)
*graph export IowaKerry.eps, replace
twoway (connected i_kerry2 edate, sort) (scatter kerryvs edate, sort msize(large) mcolor(black)) if edate>=d(15dec2003), xline(16089) xline(16097) xline(16104) xline(16108) xline(16109) xline(16111) xline(16115)  title(Figure 4: Kerry before and after the Iowa primary) legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result")) ytitle("Voteshare") xtitle("Date") name(kerry, replace)

twoway (line twoDayEdwards edate, sort) (scatter i_edwards2 edate, sort) (scatter edwardsvs edate, sort msize(large) mcolor(black)) if edate>=d(15dec2003), xline(16089) title(Figure 5: Edwards before and after the Iowa primary) legend(lab(1 "Two day average") lab(2 "Single day") lab(3 "Primary result")) ytitle("Voteshare") xtitle("Date") name(edwards, replace)
*graph export IowaEdwards.eps, replace


cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
use pred_market.dta, clear
reshape wide units volume lowprice highprice avgprice lastprice, i(edate date) j(contract) string
format edate %d
twoway (connected avgpriceROF edate if edate>td(01jan2004)&edate<td(23jan2004)) (connected avgpriceEdwards edate if edate>td(22jan2004)&edate<td(02mar2004)) (connected avgpriceDean edate if edate>td(01jan2004)&edate<td(02mar2004)) (connected avgpriceKerry edate if edate>td(01jan2004)&edate<td(02mar2004)), xline(16089) xline(16097) xline(16104) xline(16108) xline(16109) xline(16111) xline(16115) name(predMarket, replace)
