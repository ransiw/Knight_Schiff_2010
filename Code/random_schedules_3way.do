clear

*cd z:\files\primaries\july24_2007\

*Create base case
use after3.dta, clear
drop if t>8
gen ve3c=exp(ledwardsc)/(1+exp(ledwardsc)+exp(ldeanc))
gen vd3c=exp(ldeanc)/(1+exp(ledwardsc)+exp(ldeanc))
gen vk3c=1/(1+exp(ledwardsc)+exp(ldeanc))
keep cst t ve* vk* vd* mue* ledwards ledwardsc* ldean ldeanc* eta*
gen iter=0
order iter
save rand3way.dta, replace

* drop the after WI observations since dean vote share cannot be measured

timer on 1
set more off
*run 1000 reorderings
forvalues i=1/1000 {
	use after3.dta, clear
	drop if t>8
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
	gen mudc1=mud1
	
	cap drop ledwardsc
	cap drop ldeanc
	
	gen ledwardsc=0
	gen ldeanc=0

	* recompute vote shares and updating for every time period and state
	
	global r=1
	while $r<=8{
		global s=$r+1
		cap replace ledwardsc=etae+alpha$r*thetae+(1-alpha$r)*muec$r if t==$r
		cap replace ldeanc=etad+alpha$r*thetad+(1-alpha$r)*mudc$r if t==$r
		egen ledwardsctemp$r=mean(ledwardsc) if t==$r
		egen ledwardsc$r=mean(ledwardsctemp$r)
		
		egen ldeanctemp$r=mean(ldeanc) if t==$r
		egen ldeanc$r=mean(ldeanctemp$r)
		
		gen muec$s=muec$r+(beta$r/alpha$r)*(ledwardsc$r-muec$r)
		gen mudc$s=mudc$r+(beta$r/alpha$r)*(ldeanc$r-mudc$r)
		global r=$r+1
	}

	* compute three-candidate vote shares
	
	gen ve3c=exp(ledwardsc)/(1+exp(ledwardsc)+exp(ldeanc))
	gen vd3c=exp(ldeanc)/(1+exp(ledwardsc)+exp(ldeanc))
	gen vk3c=1/(1+exp(ledwardsc)+exp(ldeanc))
	keep cst t ve* vk* vd* mue* ledwards ledwardsc* eta*
	gen iter=`i'
	order iter
	save tempRand3way.dta, replace
	use rand3way.dta, clear
	append using tempRand3way.dta
	save rand3way.dta, replace
}

timer off 1

sort cst
save rand3way.dta, replace
merge cst using delegates.dta
drop if _merge==2 //drops states not in counterfactual sample of 15

*Calculate winners if get plurality of states
gen edwardsWin=0
replace edwardsWin=1 if (ve3c>vk3c & ve3c>vd3c)
gen kerryWin=0
replace kerryWin=1 if (vk3c>ve3c & vk3c>vd3c)
gen deanWin=0
replace deanWin=1 if (vd3c>vk3c & vd3c>ve3c)


bysort iter: egen avEdwards=mean(ve3c)
bysort iter: egen avKerry=mean(vk3c)
bysort iter: egen avDean=mean(vd3c)
bysort iter: egen countEdwards=sum(edwardsWin)
bysort iter: egen countKerry=sum(kerryWin)
bysort iter: egen countDean=sum(deanWin)

egen election=tag(iter)
replace election=0 if iter==0
gen winner=.
replace winner=0 if (countKerry>countEdwards & countKerry>countDean & election==1)
replace winner=1 if (countEdwards>countKerry & countEdwards>countDean & election==1)
replace winner=2 if (countDean>countKerry & countDean>countEdwards & election==1)
replace winner=3 if (countEdwards==countKerry & countEdwards==countDean & election==1)
replace winner=4 if (countEdwards==countDean & countEdwards>countKerry & election==1)
replace winner=5 if (countDean==countKerry & countDean>countEdwards & election==1)
replace winner=6 if (countEdwards==countKerry & countEdwards>countDean & election==1)

label values winner winner
label define winner 0 "Kerry", add
label define winner 1 "Edwards", modify
label define winner 2 "Dean", modify
label define winner 3 "3 Way Tie", modify
label define winner 4 "Edwards Ties Dean", modify
label define winner 5 "Kerry Ties Dean", modify
label define winner 6 "Kerry Ties Edwards", modify

*Win if get plurality of delegates
gen delKerryc3=round(total*vk3c,1)
gen delEdwardsc3=round(total*ve3c,1)
gen delDeanc3=round(total*vd3c,1)
bysort iter: egen sumEdDel3=sum(delEdwardsc3)
bysort iter: egen sumKerryDel3=sum(delKerryc3)
bysort iter: egen sumDeanDel3=sum(delDeanc3)
gen edwardsWin2=0
replace edwardsWin2=1 if (sumEdDel3>sumKerryDel3 & sumEdDel3>sumDeanDel3)
gen kerryWin2=0
replace kerryWin2=1 if (sumKerryDel3>sumEdDel3 & sumKerryDel3>sumDeanDel3)
gen deanWin2=0
replace deanWin2=1 if (sumDeanDel3>sumEdDel3 & sumDeanDel3>sumKerryDel3)
gen KerryDean=0
replace KerryDean=1 if (sumDeanDel3==sumKerryDel3)
gen KerryEdwards=0
replace KerryEdwards=1 if (sumEdDel3==sumKerryDel3)

gen winner2=.
replace winner2=0 if (kerryWin2==1 & election==1)
replace winner2=1 if (edwardsWin2==1 & election==1)
replace winner2=2 if (deanWin2==1 & election==1)
replace winner2=3 if (KerryDean==1 & election==1)
replace winner2=4 if (KerryEdwards==1 & election==1)

label values winner2 winner2
label define winner2 0 "Kerry", add
label define winner2 1 "Edwards", modify
label define winner2 2 "Dean", modify
label define winner2 3 "Kerry Dean Tie", modify
label define winner2 4 "Kerry Edwards Tie", modify

tab winner
tab winner2


collapse countEdwards avEdwards countKerry avKerry countDean avDean, by(iter)
*table iter, c(mean countEdwards mean avEdwards mean countKerry mean avKerry mean countDean mean avDean)
