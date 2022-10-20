cap cd z:\files\primaries\annenberg\
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"

clear
set mem 400m

set more off
use data2004nationalrolling2.dta

keep cda23* cda24* cda27* cda28* cda29* cda30* cst cdate crb06

save knowlege_national.dta, replace

clear

use data2004nhcross.dta

keep cda23* cda24* cda27* cda28* cda29* cda30* cst cdate crb06

append using knowlege_national.dta
save table3b.dta, replace

** analysis **

clear

cap log close
log using knowledge.log, replace

use table3b.dta, clear


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

gen voted=0
replace voted=1 if cst=="IA"&edate>mdy(1,18,2004)
replace voted=1 if cst=="NH"&edate>mdy(1,26,2004)
replace voted=1 if cst=="AZ"&edate>mdy(2,2,2004)
replace voted=1 if cst=="DE"&edate>mdy(2,2,2004)
replace voted=1 if cst=="MO"&edate>mdy(2,2,2004)
replace voted=1 if cst=="NM"&edate>mdy(2,2,2004)
replace voted=1 if cst=="OK"&edate>mdy(2,2,2004)
replace voted=1 if cst=="SC"&edate>mdy(2,2,2004)
replace voted=1 if cst=="MI"&edate>mdy(2,6,2004)
replace voted=1 if cst=="WA"&edate>mdy(2,6,2004)
replace voted=1 if cst=="ME"&edate>mdy(2,7,2004)
replace voted=1 if cst=="TN"&edate>mdy(2,9,2004)
replace voted=1 if cst=="VA"&edate>mdy(2,9,2004)
replace voted=1 if cst=="NV"&edate>mdy(2,13,2004)
replace voted=1 if cst=="WI"&edate>mdy(2,16,2004)
replace voted=1 if cst=="UT"&edate>mdy(2,23,2004)
replace voted=1 if cst=="CA"&edate>mdy(3,1,2004)
replace voted=1 if cst=="CT"&edate>mdy(3,1,2004)
replace voted=1 if cst=="GA"&edate>mdy(3,1,2004)
replace voted=1 if cst=="MA"&edate>mdy(3,1,2004)
replace voted=1 if cst=="MD"&edate>mdy(3,1,2004)
replace voted=1 if cst=="MN"&edate>mdy(3,1,2004)
replace voted=1 if cst=="NY"&edate>mdy(3,1,2004)
replace voted=1 if cst=="OH"&edate>mdy(3,1,2004)
replace voted=1 if cst=="RI"&edate>mdy(3,1,2004)


gen correct_23=0
replace correct_23=1 if cda23_1==3
replace correct_23=. if cda23_1==.

gen correct_27=0
replace correct_27=1 if cda27_1==2
replace correct_27=. if cda27_1==.

gen correct_29=0
replace correct_29=1 if cda29_1==3
replace correct_29=. if cda29_1==.

gen correct_total=correct_23+correct_27+correct_29

xi: regress correct_23 voted i.cdate, robust
xi: regress correct_27 voted i.cdate, robust
xi: regress correct_29 voted i.cdate, robust
xi: regress correct_total voted i.cdate, robust

xi: regress correct_23 voted i.cdate i.cst, robust
xi: regress correct_27 voted i.cdate i.cst, robust
xi: regress correct_29 voted i.cdate i.cst, robust
xi: regress correct_total voted i.cdate i.cst, robust


