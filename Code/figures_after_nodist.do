*cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
clear
use bresults_nodist.dta
*use bresults_nodistv9.dta, clear
collapse (median) edwardss* deans* mud1 mue1 sigmaeta B1* B2* n1 n2 n3 n4 n5 n6 n7 n8 n9 n10 ldean1 ldean2 ldean3 ldean4 ldean5 ldean6 ldean7 ldean8 ledwards1 ledwards2 ledwards3 ledwards4 ledwards5 ledwards6 ledwards7 ledwards8 ledwards9 ledwards10

*Adjust Nt to reflect 25 states with eta known in sample
replace n3=6
replace n7=1
replace n9=1
replace n10=9

gen double surprised1=ldean1-mud1
gen double surprisee1=ledwards1-mue1

gen sigma1=B1xone
gen alpha1=sigma1/(sigma1+B2xone)
gen beta1=(n1*sigma1)/(n1*sigma1+B2xone+(sigmaeta/(alpha1^2)))

global j=2
while $j<=10{

global z=$j-1

cap gen mud$j=mud$z + (beta$z/alpha$z)*(surprised$z)
cap gen mue$j=mue$z + (beta$z/alpha$z)*(surprisee$z)

cap gen double surprised$j=ldean$j-mud$j
cap gen double surprisee$j=ledwards$j-mue$j

gen sigma$j=((1/sigma$z)+((n$z)/(B2xone+(sigmaeta/(alpha$z)^2))))^(-1)
gen alpha$j=sigma$j/(sigma$j+B2xone)
gen beta$j=(n$j*sigma$j)/(n$j*sigma$j+B2xone+(sigmaeta/(alpha$j^2)))  //this will be different since nt is different
global j=$j+1
}

save after1_nodist.dta, replace

* create values that are not time-specific*
expand 10
gen t=_n

egen mud=mean(mud1)
egen mue=mean(mue1)
egen sigma=mean(sigma1)

egen alpha=mean(alpha1)
replace beta1=beta1/n1
egen beta=mean(beta1)
gen ratio=beta/alpha

*now replace according to t=2,..,10*

global c=2
while $c<=10{
*qui replace muc=muc$c if t==$c
cap replace mud=mud$c if t==$c
cap replace mue=mue$c if t==$c
cap replace sigma=sigma$c if t==$c
*qui replace muc=muc$c if t==$c
cap replace alpha=alpha$c if t==$c
cap replace beta=beta$c/n$c if t==$c
cap replace ratio=(beta$c/n$c)/(alpha$c) if t==$c


global c=$c+1
}
replace mud=. if t==10

collapse (mean) alpha beta ratio mud mue sigma, by(t)

*label variable muc "clark"
label variable mud "dean"
label variable mue "edwards"
label variable alpha "private"
label variable beta "public voting"
label variable ratio "public relative to private"

save after2_nodist.dta, replace

