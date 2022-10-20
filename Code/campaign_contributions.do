cap cd "z:\files\primaries"
cap cd "C:\Documents and Settings\nschiff\My Documents\research\momentum_in_primaries\analysis\july_2010"


clear
insheet using contributions_dean.txt

keep if recipient_ext_id=="N00025663"
keep if transaction_type=="15"

drop if amount>2000
drop if amount<0

collapse (sum) amount, by(date)
rename amount amount_dean

sort date
save contributions_dean.dta, replace

clear
insheet using contributions_edwards.txt

keep if recipient_ext_id=="N00002283"
keep if transaction_type=="15"
drop if amount>2000
drop if amount<0

collapse (sum) amount, by(date)
rename amount amount_edwards

sort date
save contributions_edwards.dta, replace

clear
insheet using contributions_kerry.txt

keep if recipient_ext_id=="N00000245"
keep if transaction_type=="15"
drop if amount>2000
drop if amount<0

collapse (sum) amount, by(date)
rename amount amount_kerry

save contributions_kerry.dta, replace
sort date
merge date using contributions_edwards.dta
drop _merge
sort date
merge date using contributions_dean.dta

gen share_dean=amount_dean/(amount_edwards+amount_dean+amount_kerry)
gen share_edwards=amount_edwards/(amount_edwards+amount_dean+amount_kerry)
gen share_kerry=amount_kerry/(amount_edwards+amount_dean+amount_kerry)
replace share_dean=0 if share_dean==.
replace share_edwards=0 if share_edwards==.
replace share_kerry=0 if share_kerry==.
label variable share_dean "Dean (share)"
label variable share_edwards "Edwards (share)"
label variable share_kerry "Kerry (share)"
generate edate = date(date, "MDY")
label variable edate "Date of Contribution"
format %d edate

save contributions.dta, replace
