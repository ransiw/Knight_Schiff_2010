clear
clear matrix
set mem 400m

*cd "z:\files\primaries\july24_2007"
*cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
*cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
*cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
set more off

*capture log close
*log using mnl_2step_noclark_dist.log, replace

global y=1
while $y<=100{

clear
use "bootsample$y", clear
*FIX Nt problem--not necessary if use create_complete_data1 and create_complete_data1 to generate bootsamples
replace n3=7
replace n7=2
replace n9=3

* create starting value for sigmaeps

gen double sigmaeps=1

*create starting values for the key values (means, variance, alpha, beta) for each period*

global i=1
while $i<=10{
gen double mud$i=0
gen double mue$i=0
gen double sigma$i=0.5
gen double alpha$i=0.5
gen double beta$i=0.4
global i=$i+1
}

sort t
gen uc=0
gen ud=0
gen ue=0

*gen trend centered around iowa*
gen trend=edate-mdy(01,19,2004)

gen trend1=0
gen trend2=mdy(01,27,2004)-mdy(01,19,2004)
gen trend3=mdy(02,03,2004)-mdy(01,19,2004)
gen trend4=mdy(02,07,2004)-mdy(01,19,2004)
gen trend5=mdy(02,08,2004)-mdy(01,19,2004)
gen trend6=mdy(02,10,2004)-mdy(01,19,2004)
gen trend7=mdy(02,14,2004)-mdy(01,19,2004)
gen trend8=mdy(02,17,2004)-mdy(01,19,2004)
gen trend9=mdy(02,24,2004)-mdy(01,19,2004)
gen trend10=mdy(03,02,2004)-mdy(01,19,2004)

do mnl_bstrap2_trend.do
gen B1xone=[B1x]_b[one]
gen B2xone=[B2x]_b[one]
/*
matrix bs$y=e(b)
matrix bf$y=bf

svmat bf$y, names(temp)
local bfnames : colfullnames bf$y
local ctr=1
foreach item in `bfnames' {
	local newname=subinstr("`item'","o.","",.)
	local newname=subinstr("`newname'",":","",.)
	display "`newname'"
	rename temp`ctr' `newname'
	local ctr=`ctr'+1
}

svmat bs$y, names( eqcol )
*/
keep deans* edwardss* sigmaeta sigma1-sigma10 alpha1-alpha10 beta1-beta10 mud* mue* n1-n10 B1xone B2xone ldean* ledwards* *trend* btrende_col btrendd_col
drop if _n>1

save bresults$y, replace

global y=$y+1
}

clear
use bresults1

global z=2
while $z<=100{
append using bresults$z
global z=$z+1
}
save bresults_trend.dta, replace

