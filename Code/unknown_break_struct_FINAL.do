cap cd z:\files\primaries\july24_2007\
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"

*There are 49 days from 02jan2004-17feb2004, 5% on each side is 2.4 days, so I will test from 04jan2004-15feb2004, inclusive
*I am defining the breakpoint as the LAST day that represents the first part of the series, or the last observation where "after"=0
set more off

use bootsample.dta, clear
keep edate cst crb06
*drop if edate<td(01jan2004)|edate>td(02mar2004)
drop if edate<td(02jan2004)|edate>td(17feb2004)
gen after=1
gen dev=.
gen ll=.
gen ll_0=.
local brkdate=td(04jan2004) //the breakdate is LAST observation where after=0
while `brkdate'<td(16feb2004) {
	display "`brkdate'"
	replace after=0 if edate<=`brkdate'
	xi: mlogit crb06 i.cst after, base(5)
	fitstat
	replace dev=r(dev) if edate==`brkdate'
	replace ll=r(ll) if edate==`brkdate'
	replace ll_0=r(ll_0) if edate==`brkdate'
	local brkdate=`brkdate'+1
}
save structural_break_logit.dta, replace
tab crb06, gen(i_)
collapse dev ll* i_*, by(edate)
table edate, c(mean dev)
twoway (connected dev edate, sort xline(16089)), name(Deviance, replace)
twoway (connected ll edate, sort xline(16089)), name(LogLike, replace)

//before february
//from the 4th to the 15th

replace after=1
replace after=0 if edate<td(20jan2004)
xi: mlogit crb06 i.cst after, base(5)
