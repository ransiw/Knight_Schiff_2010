*1st step (estimate state-specific dummies and initial means*
mlogit crb06 s_1-s_23 s_25-s_41 if t==1, base(5)

*Calculate probabilities of voting for each candidate by state by period
predict tempd1 if e(sample), index outcome(2)
predict tempe1 if e(sample), index outcome(3)

*predict tempd if t>1, index outcome(2)
*predict tempe if t>1, index outcome(3)
predict tempd, index outcome(2)
predict tempe, index outcome(3)

gen indexd1=.
gen indexe1=.

//Calculate unobserved preferences only by subtracting out coefficient on distance
replace indexd1=tempd1 if t==1
replace indexe1=tempe1 if t==1

gen indexd=.
gen indexe=.

replace indexd=tempd
replace indexe=tempe
*replace indexd=tempd if t>1
*replace indexe=tempe if t>1

cap drop mud1 mue1

egen double uniqst=tag(cst) if t==1
replace indexd1=. if t==1&uniqst==0
egen mud1=mean(indexd1)
replace indexe1=. if t==1&uniqst==0
egen mue1=mean(indexe1)

gen etad1=indexd1-mud1
gen etae1=indexe1-mue1

gen etad=indexd-mud1
gen etae=indexe-mue1

*Following code can be used in any specification to back out etas but etas MUST BE calculated for IA!
gen stNum=.
local ctr=1
foreach state in AL	AZ	CA	CO	CT	DE	FL	GA	IA	IL	IN	KY	LA	MA	MD	ME	MI	MN	MO	MS	MT	NC	NE	NH	NJ	NM	NV	NY	OH	///
OK	OR	PA	RI	SC	TN	TX	UT	VA	WA	WI	WV {
	qui replace stNum=`ctr' if cst=="`state'"
	local ctr=`ctr'+1
}
forvalues stCtr=1(1)41 {
	qui sum etad if stNum==`stCtr'
	qui gen deans_`stCtr'=r(mean)
	qui sum etae if stNum==`stCtr'
	qui gen edwardss_`stCtr'=r(mean)
}

*step 1b*

sum etad1 if uniqst==1

cons 1 [etad1]reltovt=[etae1]reltonc
sureg (etad1 reltovt) (etae1 reltonc) if uniqst==1, cons(1)

scalar gamma=[etad1]_b[reltovt]
scalar dean_cons=[etad1]_b[_cons]
scalar edwards_cons=[etae1]_b[_cons]
gen gamma_col=gamma
predict tempd1b if e(sample), equation(etad1) residuals
predict tempe1b if e(sample), equation(etae1) residuals

local states AL	AZ	CA	CO	CT	DE	FL	GA	IA	IL	IN	KY	LA	MA	MD	ME	MI	MN	MO	MS	MT	NC	NE	NH	NJ	NM	NV	NY	OH	OK	OR	PA	RI	SC	TN	TX	UT	VA	WA	WI	WV
local i=1
foreach state of local states {
gen temp_d_`i'=tempd1b if(uniqst==1 & cst=="`state'")
gen temp_e_`i'=tempe1b if(uniqst==1 & cst=="`state'")
egen r_d_`i'=sum(temp_d_`i')
egen r_e_`i'=sum(temp_e_`i')
local i=`i'+1
}
drop temp_*

egen sigmaetad=sd(tempd1b)
egen sigmaetae=sd(tempe1b)
gen sigmaeta=(sigmaetad^2+sigmaetae^2)/2
sum sigmaeta

*set first period choices to missing so that ignored in 2nd step*

*set first period choices to missing so that ignored in 2nd step*

replace i_2=. if t==1
replace i_3=. if t==1
replace i_5=. if t==1

save temp1.dta, replace

*program for second step*

program drop _all

program define ml1
args lnf B1x B2x

tempvar sigmaeps2 sigmadeps sigmaeeps sigmadeta sigmaeeta tagd tage tag2d tag2e etad etae thetad thetae ///
distd1 distd2 distd3 distd4 distd5 distd6 distd7 distd8 distd9 distd10 ///
diste1 diste2 diste3 diste4 diste5 diste6 diste7 diste8 diste9 diste10 ///
surprised1 surprised2 surprised3 surprised4 surprised5 surprised6 surprised7 surprised8 surprised9 surprised10 ///
surprisee1 surprisee2 surprisee3 surprisee4 surprisee5 surprisee6 surprisee7 surprisee8 surprisee9 surprisee10

qui gen double `surprised1'=ldean1-mud1-(gamma*reltovt1)-dean_cons //difference between primary result(s) and prior for dean in period 1 (state mean)
qui gen double `surprisee1'=ledwards1-mue1-(gamma*reltonc1)-edwards_cons

qui replace sigma1=`B1x'
qui replace alpha1=sigma1/(sigma1+`B2x')
qui replace beta1=(n1*sigma1)/(n1*sigma1+`B2x'+(sigmaeta/(alpha1^2)))

*iterate through t=2 to 10*

global j=2
while $j<=10{

global z=$j-1

qui replace mud$j=mud$z + (beta$z/alpha$z)*(`surprised$z')
qui replace mue$j=mue$z + (beta$z/alpha$z)*(`surprisee$z')

qui gen double `surprised$j'=ldean$j-mud$j-(gamma*reltovt$j)-dean_cons //Dean, does this mean same expectation for every state?
qui gen double `surprisee$j'=ledwards$j-mue$j-(gamma*reltonc$j)-edwards_cons //Edwards

*sigma updates using equation 9 or eq 19)
qui replace sigma$j=((1/sigma$z)+((n$z)/(`B2x'+(sigmaeta/(alpha$z)^2))))^(-1)

qui replace alpha$j=sigma$j/(sigma$j+`B2x')
qui replace beta$j=(n$j*sigma$j)/(n$j*sigma$j+`B2x'+(sigmaeta/(alpha$j^2)))

qui replace ud=etad + mud$j if t==$j	//util from Dean
qui replace ue=etae + mue$j if t==$j	//util from Edwards

global j=$j+1
} //end while loop

* this is the likelihood*

quietly replace `lnf' = i_2*ln(exp(ud)/(1+exp(ud)+exp(ue))) + i_3*ln(exp(ue)/(1+exp(ud)+exp(ue))) + (1-i_2-i_3)*ln(1/(1+exp(ud)+exp(ue))) if t<7
quietly replace `lnf' = i_2*ln(exp(ud)/(1+exp(ud)+exp(ue))) + i_3*ln(exp(ue)/(1+exp(ud)+exp(ue))) + (1-i_2-i_3)*ln(1/(1+exp(ud)+exp(ue))) if t>6&t<9
quietly replace `lnf' = i_3*ln(exp(ue)/(1+exp(ue))) + (1-i_3)*ln(1/(1+exp(ue))) if t>8

end

ml model lf ml1 (B1x: i_1=one, nocons) (B2x: i_2=one, nocons), maximize search(off) difficult trace init(5 2, copy) technique(dfp)
