clear

*cd z:\files\primaries\july24_2007\

*Create base case
use after3.dta, clear
gen ve2c=exp(ledwards)/(1+exp(ledwards))
gen vk2c=1/(1+exp(ledwards))
gen soc_ratio=.
global r=1
while $r<=10 {
		replace soc_ratio=beta$r/(nt*alpha$r) if t==$r
		global r=$r+1
}
keep cst t ve* vk* mue* ledwards ledwardsc* eta* soc_ratio
gen r=0
order r
save rand2way.dta, replace

timer on 1
set more off
*Run 1000 reorderings
forvalues i=1/1000 {
	use after3.dta, clear
	* create random schedule
	drawnorm z
	egen seq=rank(z)
	replace t=1 if seq==1
	replace t=2 if seq==2
	replace t=3 if seq>2&seq<9
	replace t=4 if seq>8&seq<11
	replace t=5 if seq==11
	replace t=6 if seq>11&seq<14
	replace t=7 if seq==14
	replace t=8 if seq==15
	replace t=8 if seq==15
	replace t=9 if seq==16
	replace t=10 if seq>16
	
	cap drop ledwardsc
	cap drop ledwardsc1-ledwardsc10
	cap drop ledwardsc1temp-ledwardsc10temp
	gen muec1=mue1
	cap drop ledwardsc
	gen ledwardsc=0
	
	* recompute vote shares and updating for every time period and state
	gen soc_ratio=.
	global r=1
	while $r<=10{
		global s=$r+1
		cap replace ledwardsc=etae+alpha$r*thetae+(1-alpha$r)*muec$r if t==$r
		egen ledwardsctemp$r=mean(ledwardsc) if t==$r
		egen ledwardsc$r=mean(ledwardsctemp$r)
		gen muec$s=muec$r+(beta$r/alpha$r)*(ledwardsc$r-muec$r)
		replace soc_ratio=beta$r/(nt*alpha$r) if t==$r
		global r=$r+1
	}
	* compute two-candidate vote shares
	gen ve2c=exp(ledwardsc)/(1+exp(ledwardsc))
	gen vk2c=1/(1+exp(ledwardsc))
	keep cst t ve* vk* mue* ledwards ledwardsc* eta* soc_ratio
	gen r=`i'
	order r
	save tempRand2way.dta, replace
	use rand2way.dta, clear
	append using tempRand2way.dta
	save rand2way.dta, replace
}

timer off 1
timer list

sort cst
save rand2way.dta, replace
merge cst using delegates.dta
drop if _merge==2 //drops states not in counterfactual sample of 25

*Win if get plurality of states
gen edwardsWin=0
replace edwardsWin=1 if ve2c>vk2c
bysort r: egen avEdwards=mean(ve2c)
bysort r: egen avKerry=mean(vk2c)
bysort r: egen countEdwards=sum(edwardsWin)
gen kerryWin=0
replace kerryWin=1 if ve2c<vk2c
bysort r: egen countKerry=sum(kerryWin)
egen election=tag(r)
replace election=0 if r==0
gen winner=.
replace winner=0 if (countKerry>countEdwards & election==1)
replace winner=1 if (countEdwards>countKerry & election==1)
replace winner=2 if (countEdwards==countKerry & election==1)
label values winner winner
label define winner 0 "Kerry", add
label define winner 1 "Edwards", modify
label define winner 2 "tie", modify

*Win if get plurality of delegates
gen delKerryc2=round(total*vk2c,1)
gen delEdwardsc2=round(total*ve2c,1)
bysort r: egen sumEdDel2=sum(delEdwardsc2)
bysort r: egen sumKerryDel2=sum(delKerryc2)
gen edwardsWin2=0
replace edwardsWin2=1 if sumEdDel2>sumKerryDel2
gen kerryWin2=0
replace kerryWin2=1 if sumEdDel2<sumKerryDel2
gen tie=0
replace tie=1 if sumEdDel2==sumKerryDel2

gen winner2=.
replace winner2=0 if (kerryWin2==1 & election==1)
replace winner2=1 if (edwardsWin2==1 & election==1)
replace winner2=2 if (tie==1 & election==1)
label values winner2 winner2
label define winner2 0 "Kerry", add
label define winner2 1 "Edwards", modify
label define winner2 2 "tie", modify

tab winner
tab winner2
table r, c(mean countEdwards mean avEdwards mean countKerry mean avKerry)

/*
bysort r: egen countKerry2=sum(kerryWin2)
bysort r: egen countEdwards2=sum(edwardsWin2)
*/
