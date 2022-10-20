cap cd "z:\files\primaries\july24_2007\"
cap cd "C:\Users\schiff\Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
*Create Baseline Case

use after3.dta, clear
keep t cst alpha* beta* eta* theta* mue* mud* ve vk
gen ve2=ve/(ve+vk)
gen muec1=mue1
sort t cst
gen stNum=_n //the sort order is very important: there should be 25 states sorted first by period and then alphabetically

*First calculate indirect utility from each candidate under simultaneous election, NOTE that indirect utility is also log of vote share ratio
gen u_ed_sim=etae+alpha1*thetae+(1-alpha1)*mue1
gen etae2=etae+1
gen u_ed_sim2=etae2+alpha1*thetae+(1-alpha1)*mue1 //shock eta, calculate new indirect utility
gen v_ed_sim_base=exp(u_ed_sim)/(1+exp(u_ed_sim))
gen v_ed_sim_shock=exp(u_ed_sim2)/(1+exp(u_ed_sim2))
gen diff_sim=v_ed_sim_shock-v_ed_sim_base

*IGNORE: V2 CHANGE: compute vote shares for every time period and state IN THE ABSENCE OF SOCIAL LEARNING
*IGNORE: replace ledwardsceta=etae+alpha1*thetae+(1-alpha1)*mue1

gen u_ed_sl_base=0 //indirect utility from Edwards under social learning, Base Case
forvalues per=1(1)10 {
	replace u_ed_sl_base=etae+alpha`per'*thetae+(1-alpha`per')*muec`per' if t==`per'
	egen ledwardsctemp`per'=mean(u_ed_sl_base) if t==`per' //Again, note that indirect utility is also ln(vc/v0)
	egen ledwardsc`per'=mean(ledwardsctemp`per') //this fills in values for all 25 observations
	local nextper=`per'+1
	gen muec`nextper'=muec`per'+(beta`per'/alpha`per')*(ledwardsc`per'-muec`per')
}
gen v_ed_sl_base=exp(u_ed_sl_base)/(1+exp(u_ed_sl_base)) //v_ed_sl_base will differ from full sample vote share (ve2) starting in period 4 due to different number of states (see above)
save tempStart.dta, replace
keep cst t ve2 v_ed* mue* u_ed* eta*
gen adjState="00" //string value for shocked state
gen adjStateBin=0 //binary for shocked state: 0 no shock, 1 shock
gen shockPeriod=0
save equityEta_allstates.dta, replace

*Loop through shocking each of the 25 states, creating a data file that has 26*25 rows
forvalues st=1(1)25 {
	use tempStart.dta, clear
	drop muec* ledwardsc* etae2
	gen etae2=etae
	replace etae2=etae+1 if stNum==`st'
	gen adjStateBin=0
	replace adjStateBin=1 if stNum==`st'
	gen muec1=mue1
	gen u_ed_sl_shock=0
	forvalues per=1(1)10 {
		replace u_ed_sl_shock=etae2+alpha`per'*thetae+(1-alpha`per')*muec`per' if t==`per'
		egen ledwardsctemp`per'=mean(u_ed_sl_shock) if t==`per' //Again, note that indirect utility is also ln(vc/v0)
		egen ledwardsc`per'=mean(ledwardsctemp`per') //this fills in values for all 25 observations
		local nextper=`per'+1
		gen muec`nextper'=muec`per'+(beta`per'/alpha`per')*(ledwardsc`per'-muec`per')
	}
	gen v_ed_sl_shock=exp(u_ed_sl_shock)/(1+exp(u_ed_sl_shock)) //vote share for Edwards after shocking eta of one state
	gen adjState=cst if stNum==`st'
	gsort - adjState
	replace adjState=adjState[_n-1] if _n!=1
	sort t cst
	sum t if stNum==`st'
	gen shockPeriod=r(mean)
	keep cst t ve2 v_ed* mue* u_ed* eta* adjState* shockPeriod
	save tempEquityEta.dta, replace
	use equityEta_allstates.dta, clear
	append using tempEquityEta.dta
	save equityEta_allstates.dta, replace
}
	
*Weights using actual vote ratio
gen u_ed_sl_base2=u_ed_sl_base
replace u_ed_sl_base2=u_ed_sl_base+1 if adjStateBin==1
gen v_ed_sl_base2=v_ed_sl_base
replace v_ed_sl_base2=exp(u_ed_sl_base2)/(1+exp(u_ed_sl_base2))
bysort adjState: egen av_ved_simbase=mean(v_ed_sim_base) //average vote share for Edwards under simultaneous primaries
bysort adjState: egen av_ved_slbase=mean(v_ed_sl_base) //average vote share for Edwards
bysort adjState: egen av_ved_slbase2=mean(v_ed_sl_base2) //Direct effect: av vote share (Edwards) when shock state, GIVEN indirect utility with social learning but effect does not carry
bysort adjState: egen av_ved_slshock=mean(v_ed_sl_shock) //Total effect: av vote share (Edwards) with social learning and shocking eta for a given state
gen sl_effect=av_ved_slshock-av_ved_slbase2 //Indirect effect: total effect-direct effect
sort t cst
save equityEta_allstates.dta, replace
table adjState, c(mean v_ed_sl_shock mean v_ed_sl_base mean v_ed_sl_base2 mean sl_effect mean shockPeriod)
browse t cst adjState* shockPeriod v_ed* av_ved* etae*

*Collapse and calculate weights
collapse baseVShare=v_ed_sl_base directEffect=v_ed_sl_base2 totalEffect=v_ed_sl_shock indirectEffect=sl_effect shockPeriod, by(adjState) 
gen deltaTotal=totalEffect-baseVShare
gen deltaDirect=directEffect-baseVShare

*Generate weights by period by averaging all states in given period
bysort shockPeriod: egen avDirect=mean(deltaDirect)
bysort shockPeriod: egen avIndirect=mean(indirectEffect)
bysort shockPeriod: egen avTotal=mean(deltaTotal)
sum avTotal if shockPeriod==10
scalar total10=r(mean)
gen totWeight=avTotal/total10
sum avDirect if shockPeriod==10
scalar direct10=r(mean)
gen directWeight=avDirect/direct10
label variable totWeight "Total effect: direct + indirect"
label variable directWeight "Direct effect alone"
label variable shockPeriod "Period"

*Generate weights for each state, normalizing by average of period 10
gen stTotal=deltaTotal/total10
label variable stTotal "Total effect: direct + indirect"
gen stDirect=deltaDirect/direct10
label variable stDirect "Direct effect alone"
sort shockPeriod
save equityEta_weights.dta, replace


*OLD--------------------------------------------------------------------------------------------------

collapse v_ed_sl_base* v_ed_sl_shock sl_effect shockPeriod, by(adjState) 
gen diff= v_ed_sl_shock- v_ed_sl_base
bysort shockPeriod: egen av_diff=mean(diff)
sum av_diff if shockPeriod==10
scalar baseDiff=r(mean)
gen etaWeight=av_diff/baseDiff


gen stDiff=0
replace stDiff=ve2ceta-baseCase if shockedSt==1
bysort shockPeriod: egen avVe2ceta=mean(ve2ceta)
gen ve2ceta_2=ve2ceta-stDiff
bysort shockPeriod: egen avVe2ceta_2=mean(ve2ceta_2)
sum avVe2ceta if shockPeriod==0
scalar baseVe=r(mean) //this is the same for avVe2ceta_2
gen VeDiff=avVe2ceta-baseVe
gen VeDiff2=avVe2ceta_2-baseVe
sum VeDiff if shockPeriod==10
scalar per10Diff=r(mean)
gen etaWeight=VeDiff/per10Diff
sum VeDiff2 if shockPeriod==10
scalar per10Diff2=r(mean)
gen etaWeight2=VeDiff2/per10Diff2
twoway (connected etaWeight shockPeriod if shockPeriod>0), yscale(r(1 6)) ylabel(1(1)6) xtitle(Period of shock to state preference) ytitle(Weight relative to period 10 shock) title(Figure 10: Impact of shock to state preference by period) xscale(range(1 10))
graph save fig10a.gph, replace
twoway (connected VeDiff2 shockPeriod if shockPeriod>0), xtitle(Period of shock to state preference) ytitle(Vote share change from shock) title(Figure 10: Impact of shock to state preference by period) xscale(range(1 10))
line etaWeight shockPeriod if shockPeriod>0
table shockPeriod if shockPeriod>0, c(mean etaWeight)	

	
	
	
	
global r=1
while $r<=10{
	global s=$r+1
	replace ledwardsceta=etae+alpha$r*thetae+(1-alpha$r)*muec$r if t==$r
	egen ledwardsctemp$r=mean(ledwardsceta) if t==$r
	egen ledwardsc$r=mean(ledwardsctemp$r)
	gen muec$s=muec$r+(beta$r/alpha$r)*(ledwardsc$r-muec$r)
	global r=$r+1
}

* compute two-candidate vote shares (edwards relative to kerry)
gen ve2ceta=exp(ledwardsceta)/(1+exp(ledwardsceta)) //ve2ceta will differ from ve2 starting in period 4 due to different number of states (see above)
gen ve2=ve/(ve+vk)
gen baseCase=ve2ceta

keep cst t ve* mue* ledwards ledwardsceta eta* baseCase
gen adjState="00"
gen shockPeriod=0
gen shockedSt=0
save equityEta_v2.dta, replace


*Loop Through, Shocking Alphabetically-First State in each Period
*IA(1), NH(2), AZ(3), MI(4), ME(5), TN(6), NV(7), WI(8), UT(9), CA(10)

set more off
local states IA NH AZ MI ME TN NV WI UT CA
local per=1
foreach state of local states {
	use tempStart.dta, clear
	drop muec* ledwardsc* ve2c*
	*use after3.dta, clear
	replace etae=etae+1 if cst=="`state'"
	gen shockedSt=0
	replace shockedSt=1 if cst=="`state'"
	gen muec1=mue1
	
	gen ledwardsceta=0
	
	* recompute vote shares and updating for every time period and state
	
	global r=1
	while $r<=10{
		global s=$r+1
		cap replace ledwardsceta=etae+alpha$r*thetae+(1-alpha$r)*muec$r if t==$r
		egen ledwardsctemp$r=mean(ledwardsceta) if t==$r
		egen ledwardsc$r=mean(ledwardsctemp$r)
		gen muec$s=muec$r+(beta$r/alpha$r)*(ledwardsc$r-muec$r)
		global r=$r+1
	}
	
	* compute two-candidate vote shares (edwards relative to kerry)
	
	gen ve2ceta=exp(ledwardsceta)/(1+exp(ledwardsceta)) //calculate counterfactual vote share
		
	sort t
	list cst ve2 ve2ceta
	keep cst t ve* mue* ledwards ledwardsceta eta* shockedSt baseCase
	gen adjState="`state'"
	gen shockPeriod=`per'
	order adjState shockPeriod
	save tempEquityEta.dta, replace
	use equityEta_v2.dta, clear
	append using tempEquityEta.dta
	save equityEta_v2.dta, replace
	local per=`per'+1
}

*Weights using actual vote ratio
gen stDiff=0
replace stDiff=ve2ceta-baseCase if shockedSt==1
bysort shockPeriod: egen avVe2ceta=mean(ve2ceta)
gen ve2ceta_2=ve2ceta-stDiff
bysort shockPeriod: egen avVe2ceta_2=mean(ve2ceta_2)
sum avVe2ceta if shockPeriod==0
scalar baseVe=r(mean) //this is the same for avVe2ceta_2
gen VeDiff=avVe2ceta-baseVe
gen VeDiff2=avVe2ceta_2-baseVe
sum VeDiff if shockPeriod==10
scalar per10Diff=r(mean)
gen etaWeight=VeDiff/per10Diff
sum VeDiff2 if shockPeriod==10
scalar per10Diff2=r(mean)
gen etaWeight2=VeDiff2/per10Diff2
twoway (connected etaWeight shockPeriod if shockPeriod>0), yscale(r(1 6)) ylabel(1(1)6) xtitle(Period of shock to state preference) ytitle(Weight relative to period 10 shock) title(Figure 10: Impact of shock to state preference by period) xscale(range(1 10))
graph save fig10a.gph, replace
twoway (connected VeDiff2 shockPeriod if shockPeriod>0), xtitle(Period of shock to state preference) ytitle(Vote share change from shock) title(Figure 10: Impact of shock to state preference by period) xscale(range(1 10))
line etaWeight shockPeriod if shockPeriod>0
table shockPeriod if shockPeriod>0, c(mean etaWeight)

*Weights using log(vote ratio)
bysort shockPeriod: egen avLedwards=mean(ledwardsceta)
sum ledwardsceta if shockPeriod==0
scalar baseLedwards=r(mean)
gen edDiff=avLedwards-baseLedwards
sum edDiff if shockPeriod==10
scalar per10edDiff=r(mean)
gen etaWeight2=edDiff/per10edDiff
twoway (connected etaWeight2 shockPeriod if shockPeriod>0), yscale(r(1 6)) ylabel(1(1)6) xtitle(Period of shock to state preference) ytitle(Weight relative to period 10 shock) title(Figure 10: Impact of shock to state preference by period) xscale(range(1 10))
graph save fig10b.gph, replace
line etaWeight2 shockPeriod if shockPeriod>0
table shockPeriod if shockPeriod>0, c(mean etaWeight2)
save equityEta_v2.dta, replace

*sort t cst shockPeriod
gen tempVe=ve2ceta if shockPeriod==0
bysort t cst: egen baseVe2ceta=sum(tempVe)
gen shockEffect=ve2ceta-baseVe2ceta
bysort shockPeriod t: egen avEffect=mean(shockEffect)

gen tempLed=ledwardsceta if shockPeriod==0
bysort t cst: egen baseLedceta=sum(tempLed)
gen shockEffect2=ledwardsceta-baseLedceta
bysort shockPeriod t: egen avEffect2=mean(shockEffect2)

*Average where each time period counts equally
egen shkperT=tag(shockPeriod t)
gen temp2ledwardsceta=.
replace temp2ledwardsceta=ledwardsceta if shkperT==1
bysort shockPeriod: egen avLedwards2=mean(temp2ledwardsceta)
sum avLedwards2 if shockPeriod==0
scalar avLedwards2_base=r(mean)
gen diff3=avLedwards2-avLedwards2_base
sum diff3 if shockPeriod==10
scalar per10diff3=r(mean)
gen etaWeight3=diff3/per10diff3
line etaWeight32 shockPeriod if shockPeriod>0


bysort shockPeriod: egen avLed_t=mean(ledwardsceta), [fweight=shkperT]
