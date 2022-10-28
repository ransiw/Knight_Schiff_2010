clear

*cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
*cd z:\files\primaries\july24_2007\

use after1_nodist.dta, clear

expand 41
global v=1
gen etad=0
gen etae=0

gen statecd=0

global v=1
while $v<=41{
 
gen s_$v=0
replace s_$v=1 if $v==_n
replace statecd=$v if s_$v==1
replace etad=deans_$v if $v==_n
replace etae=edwardss_$v if $v==_n
global v=$v+1
}

sort statecd

save counter1.dta, replace
sum etad etae

use complete_data1.dta

gen statecd=.
replace statecd=2 if cst=="AZ"
replace statecd=3 if cst=="CA"
replace statecd=5 if cst=="CT"
replace statecd=. if cst=="DC"
replace statecd=6 if cst=="DE"
replace statecd=8 if cst=="GA"
replace statecd=. if cst=="HI"
replace statecd=9 if cst=="IA"
replace statecd=. if cst=="ID"
replace statecd=14 if cst=="MA"
replace statecd=15 if cst=="MD"
replace statecd=16 if cst=="ME"
replace statecd=17 if cst=="MI"
replace statecd=18 if cst=="MN"
replace statecd=19 if cst=="MO"
replace statecd=. if cst=="ND"
replace statecd=24 if cst=="NH"
replace statecd=26 if cst=="NM"
replace statecd=27 if cst=="NV"
replace statecd=28 if cst=="NY"
replace statecd=29 if cst=="OH"
replace statecd=30 if cst=="OK"
replace statecd=33 if cst=="RI"
replace statecd=34 if cst=="SC"
replace statecd=35 if cst=="TN"
replace statecd=37 if cst=="UT"
replace statecd=38 if cst=="VA"
replace statecd=. if cst=="VT"
replace statecd=39 if cst=="WA"
replace statecd=40 if cst=="WI"

sort statecd
cap drop _merge
merge statecd using counter1.dta

gen thetad=0
gen thetae=0
gen ldeanc=0
gen ledwardsc=0
global r=1
while $r<=10{
cap replace ldeanc=etad+(alpha1/alpha$r)*(ldean-(1-alpha$r)*mud$r-etad)+(1-alpha1)*mud1 if t==$r
cap replace ledwardsc=etae+(alpha1/alpha$r)*(ledwards-(1-alpha$r)*mue$r-etae)+(1-alpha1)*mue1 if t==$r
cap replace thetad=(1/alpha$r)*(ldean-(1-alpha$r)*mud$r-etad) if t==$r
cap replace thetae=(1/alpha$r)*(ledwards-(1-alpha$r)*mue$r-etae) if t==$r
global r=$r+1
}

*replace thetad=. if t>8
*replace ldeanc=. if t>8

save counter2.dta, replace

gen vd=exp(ldean)/(1+exp(ldean)+exp(ledwards))
gen ve=exp(ledwards)/(1+exp(ldean)+exp(ledwards))
gen vk=1/(1+exp(ldean)+exp(ledwards))

replace ve=exp(ledwards)/(1+exp(ledwards)) if t>8
replace vk=1/(1+exp(ledwards)) if t>8
replace vd=. if t>8

gen vdc3=exp(ldeanc)/(1+exp(ldeanc)+exp(ledwardsc))
gen vec3=exp(ledwardsc)/(1+exp(ldeanc)+exp(ledwardsc))
gen vkc3=1/(1+exp(ldeanc)+exp(ledwardsc))
replace vdc3=. if t>8
replace vec3=. if t>8
replace vkc3=. if t>8

gen vec2=exp(ledwardsc)/(1+exp(ledwardsc))
gen vkc2=1/(1+exp(ledwardsc))


/*
replace ve=exp(ledwards)/(1+exp(ledwards)) if t>8
replace vec=exp(ledwardsc)/(1+exp(ledwardsc)) if t>8
replace vkc=1/(1+exp(ledwardsc)) if t>8
*/

drop if t==.
drop if vkc2==.
sort t cst
browse t cst vmonth vday vyear vd ve vk vdc3 vec3 vkc3 vec2 vkc2
*list t cst v*

save after3.dta, replace

*Run counterfactual weighting by delegates
sort cst
save after3.dta, replace

* The delegates.dta files was not provided by the authors so cannot merge
cap drop _merge
merge cst using delegates.dta

gen delKerry=round(total*vk,1)
gen delDean=round(total*vd,1)
gen delEdwards=round(total*ve,1)
sum delKerry
scalar KerryDelegates=r(mean)*r(N)
sum delDean
scalar DeanDelegates=r(mean)*r(N)
sum delEdwards
scalar EdwardsDelegates=r(mean)*r(N)

gen delKerryc3=round(total*vkc3,1)
gen delDeanc3=round(total*vdc3,1)
gen delEdwardsc3=round(total*vec3,1)
sum delKerryc3
scalar KerryDelegatesc3=r(mean)*r(N)
sum delDeanc3
scalar DeanDelegatesc3=r(mean)*r(N)
sum delEdwardsc3
scalar EdwardsDelegatesc3=r(mean)*r(N)

gen delKerryc2=round(total*vkc2,1)
gen delEdwardsc2=round(total*vec2,1)
sum delKerryc2
scalar KerryDelegatesc2=r(mean)*r(N)
sum delEdwardsc2
scalar EdwardsDelegatesc2=r(mean)*r(N)

gen winDean=0
replace winDean=1 if (vd>vk & vd>ve)
gen winEdwards=0
replace winEdwards=1 if ((ve>vk & ve>vd & t<9) | (ve>vk & t>8))
gen winKerry=0
replace winKerry=1 if ((vk>vd & vk>ve & t<9) | (vk>ve & t>8))

gen winDean3=0
replace winDean3=1 if (vdc3>vkc3 & vdc3>vec3)
gen winEdwards3=0
replace winEdwards3=1 if (vec3>vkc3 & vec3>vdc3)
gen winKerry3=0
replace winKerry3=1 if (vkc3>vec3 & vkc3>vdc3)

gen winEdwards2=0
replace winEdwards2=1 if vec2>vkc2
gen winKerry2=0
replace winKerry2=1 if vkc2>vec2

drop if t==.
sort t cst
browse t cst vmonth vday vyear vd ve vk vdc3 vec3 vkc3 vec2 vkc2 delDean delEdwards delKerry delDeanc3 delEdwardsc3 delKerryc3 delEdwardsc2 delKerryc2 win*
browse t cst vmonth vday vyear vd ve vk delDean delEdwards delKerry vdc3 vec3 vkc3 delDeanc3 delEdwardsc3 delKerryc3 vec2 vkc2 delEdwardsc2 delKerryc2
