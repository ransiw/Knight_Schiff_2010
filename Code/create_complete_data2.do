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
*cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"

clear
set mem 160m
set more off

use "data2004nationalrolling4.dta", clear
append using data2004nhcross3.dta

gen year=int(cdate/10000)
gen month=int((cdate-year*10000)/100)
gen day=cdate-year*10000-month*100
gen edate=mdy(month,day,year)
format edate %d

*drop states with very small sample sizes (<20 between dean/edwards/kerry/clark)
drop if cst=="DC"
*drop if cst=="DE"
drop if cst=="ID"
*drop if cst=="MT"
drop if cst=="ND"
*drop if cst=="RI"
drop if cst=="WY"
drop if cst=="SD"
drop if cst=="KS"
drop if cst=="AR"
drop if cst=="VT"

tabulate crb06, generate(i_)
sum i_*
tabulate cst, generate(s_)

*modify state dummy variables so that sum to zero--nh (#24) is omitted category*

global k=1
while $k<=23{
replace s_$k=s_$k-s_24
global k=$k+1
}

global l=25
while $l<=41{
replace s_$l=s_$l-s_24
global l=$l+1
}

drop if cdate>20040302

*drop missing observations
drop if crb06==.

*focus on dean/edwards/kerry
drop if i_13==1
drop if i_12==1
drop if i_11==1
drop if i_10==1
drop if i_9==1
drop if i_8==1
drop if i_7==1
drop if i_6==1
drop if i_4==1
drop if i_1==1

gen t=1
replace t=2 if cdate>20040119&cdate<=20040127
replace t=3 if cdate>20040127&cdate<=20040203
replace t=4 if cdate>20040203&cdate<=20040207
replace t=5 if cdate>20040207&cdate<=20040208
replace t=6 if cdate>20040208&cdate<=20040210
replace t=7 if cdate>20040210&cdate<=20040214
replace t=8 if cdate>20040214&cdate<=20040217
replace t=9 if cdate>20040217&cdate<=20040224
replace t=10 if cdate>20040224&cdate<=20040302

quietly tabulate t, generate(t_)
sort cst

//Add distance from polled respondent to candidates' states
merge cst using state_dists_miles_wide.dta, keep(toma tonc toar tovt)
drop _merge

gen reltovt=tovt-toma
gen reltonc=tonc-toma

bysort cdate: egen i_clark=mean(i_1)
bysort cdate: egen i_dean=mean(i_2)
bysort cdate: egen i_edwards=mean(i_3)
bysort cdate: egen i_gephardt=mean(i_4)
bysort cdate: egen i_kerry=mean(i_5)
bysort cdate: egen i_kucinich=mean(i_6)
bysort cdate: egen i_lieberman=mean(i_7)
bysort cdate: egen i_sharpton=mean(i_9)

format edate %d

gen one=1
sort one

merge one using complete_data2

drop if i_2==.

save complete_data.dta, replace
save bootsample.dta, replace


* create bootstap samples

set seed 682150

global y=1
while $y<=1000{

clear
use bootsample.dta

bsample 4084
bysort cst: egen stated=sum(i_2) if t==1
bysort cst: egen statee=sum(i_3) if t==1 
bysort cst: egen statek=sum(i_5) if t==1
gen statemin=min(stated,statee,statek)
bysort cst: egen statemin2=mean(statemin)
tab statemin2
tab cst if statemin2<1
drop if statemin2<1
save bootsample$y, replace

global y=$y+1
}
