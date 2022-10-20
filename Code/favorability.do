*sysdir set PERSONAL "Z:\My Documents\economics\ado\personal"
*sysdir set PLUS "Z:\My Documents\economics\ado\plus"
cap cd "C:\Users\Administrator.MJ09220\Documents\research\momentum_in_primaries\analysis\july_2010"
clear
use complete_data.dta
sort t
cap drop _merge
merge t using after2_nodist.dta

*cap log close
*log using favorability.log, replace

rename cab01 favork
rename cac26 favord
rename cac04 favore

rename cab02 caresk
rename cac27 caresd
rename cac06 carese

rename cab03 inspirk
rename cac28 inspird
rename cac07 inspire

rename cab04 strongk
rename cac29 strongd
rename cac08 stronge

rename cab05 trustwk
rename cac30 trustwd
rename cac09 trustwe

rename cab06 sharesk
rename cac31 sharesd
rename cac10 sharese

rename cab07 knowlek
rename cac32 knowled
rename cac11 knowlee

rename cab08 recklek
rename cac33 reckled
rename cac12 recklee

replace favork=. if favork>10
replace favord=. if favord>10
replace favore=. if favore>10

replace caresk=. if caresk>10
replace caresd=. if caresd>10
replace carese=. if carese>10

replace inspirk=. if inspirk>10
replace inspird=. if inspird>10
replace inspire=. if inspire>10

replace strongk=. if strongk>10
replace strongd=. if strongd>10
replace stronge=. if stronge>10

replace trustwk=. if trustwk>10
replace trustwd=. if trustwd>10
replace trustwe=. if trustwe>10

replace sharesk=. if sharesk>10
replace sharesd=. if sharesd>10
replace sharese=. if sharese>10

replace knowlek=. if knowlek>10
replace knowled=. if knowled>10
replace knowlee=. if knowlee>10

replace recklek=. if recklek>10
replace reckled=. if reckled>10
replace recklee=. if recklee>10

gen favordr=favord-favork
gen favorer=favore-favork

gen caresdr=caresd-caresk
gen careser=carese-caresk

gen inspirdr=inspird-inspirk
gen inspirer=inspire-inspirk

gen strongdr=strongd-strongk
gen stronger=stronge-strongk

gen trustwdr=trustwd-trustwk
gen trustwer=trustwe-trustwk

gen sharesdr=sharesd-sharesk
gen shareser=sharese-sharesk

gen knowledr=knowled-knowlek
gen knowleer=knowlee-knowlek

gen reckledr=reckled-recklek
gen reckleer=recklee-recklek

* pooled analysis
gen ind=_n

expand 2
gen muc=mud
replace muc=mue if _n>4084 //Dean is first 4084 obs, Edwards is 4085-8168

gen cd=1
replace cd=0 if _n>4084

gen favorc=favordr
replace favorc=favorer if _n>4084
regress favorc muc cd, cluster(ind) //this clusters on the individual
*outreg using favorability, se bdec(3) bracket replace
outreg2 using favorability, replace excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)

gen caresc=caresdr
replace caresc=careser if _n>4084
regress caresc muc cd, cluster(ind)
*outreg using favorability, se bdec(3) bracket append
outreg2 using favorability, excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)

gen inspirc=inspirdr
replace inspirc=inspirer if _n>4084
regress inspirc muc cd, cluster(ind)
*outreg using favorability, se bdec(3) bracket append
outreg2 using favorability, excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)

gen strongc=strongdr
replace strongc=stronger if _n>4084
regress strongc muc cd, cluster(ind)
*outreg using favorability, se bdec(3) bracket append
outreg2 using favorability, excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)

gen trustwc=trustwdr
replace trustwc=trustwer if _n>4084
regress trustwc muc cd, cluster(ind)
*outreg using favorability, se bdec(3) bracket append
outreg2 using favorability, excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)

gen sharesc=sharesdr
replace sharesc=shareser if _n>4084
regress sharesc muc cd, cluster(ind)
*outreg using favorability, se bdec(3) bracket append
outreg2 using favorability, excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)

gen knowlec=knowledr
replace knowlec=knowleer if _n>4084
regress knowlec muc cd, cluster(ind)
*outreg using favorability, se bdec(3) bracket append
outreg2 using favorability, excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)

gen recklec=reckledr
replace recklec=reckleer if _n>4084
regress recklec muc cd, cluster(ind)
*outreg using favorability, se bdec(3) bracket append
outreg2 using favorability, excel alpha(.05, .1) 2aster bracket bdec(3) rdec(3)
