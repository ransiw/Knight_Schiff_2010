/*
USES:	1) 2004_dem_aggregate_cnn2.dta 2) data2004nationalrolling3.dta 3) data2004nhcross2.dta 4) state_dists_miles_wide
CREATES: complete_data.dta
The analysis programs "MNL_2step," "graphs_before," and "graphs_after" will run on complete_data.dta
*/

*cap cd "Z:\files\primaries\july24_2007\"
*cap cd "Z:\My Documents\economics\momentum_in_primaries\analysis\scratch"
*cap cd "C:\Documents and Settings\nschiff\My Documents\economics\momentum_primaries\analysis\complete"
*cap cd "Z:\My Documents\economics\momentum_in_primaries\analysis\August"
*cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
*cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"

*** Set directory to where the input data is stored ***

clear
set mem 160m
use 2004_dem_aggregate_cnn2v9.dta, clear
merge cst using state_dists_miles_wide.dta, keep(toma tonc toar tovt)
drop if t==.
drop _merge

replace dean="" if dean=="wd"
replace edwards="" if edwards=="wd"
replace edwards="" if edwards=="nb"
replace clark="" if clark=="wd"
replace lieberman="" if lieberman=="wd"
replace sharpton="" if sharpton=="wd"||sharpton=="nb"||sharpton=="-"

destring dean, gen(dean2)
destring edwards, gen(edwards2)
destring clark, gen(clark2)
destring lieberman, gen(lieberman2)
destring sharpton, gen(sharpton2)

drop dean edwards clark lieberman sharpton
rename dean2 dean
rename edwards2 edwards
rename clark2 clark
rename lieberman2 lieberman
rename sharpton2 sharpton

gen ldean=ln(dean/kerry)
gen ledwards=ln(edwards/kerry)
rename nt nt_old
bysort t: egen nt=count(t)

save complete_data1.dta, replace

collapse (mean) ldean ledwards nt tovt toma tonc, by(t)

gen reltovt=tovt-toma
gen reltonc=tonc-toma
rename nt n
gen one=1
reshape wide n ldean ledwards toma tovt tonc reltovt reltonc, j(t) i(one)

save complete_data2.dta, replace
