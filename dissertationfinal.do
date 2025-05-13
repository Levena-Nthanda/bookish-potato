************************************************************************
*Title     :  The Price of Ageing in Malawi: Is Age Really Just a Number?
*By        :  Levena Banda
*Date      :  14/01/2025
*Supervisor:  Dr Farai Chigaru
**********************************************************
**********************************************************
*** Github
    ! echo # github-tutorial  >> README.md
    ! git init
	
    shell git add .
    shell git commit -m "updated"
    shell git push
	
*** Macros for all file paths
    macro drop all
    global wf          "C:\Users\Levena\OneDrive\Desktop\Dissertation"
    global datain      "C:\Users\Levena\OneDrive\Desktop\Dissertation\datain\IHS5"
    global dataout     "C:\Users\Levena\OneDrive\Desktop\Dissertation\dataout"
    global logs        "C:\Users\Levena\OneDrive\Desktop\Dissertation\log files"
    global output      "C:\Users\Levena\OneDrive\Desktop\Dissertation\results in graphs"

*** Defining working folder
    cd "$wf"

**********************************************************
**********************************************************

*** LOADING COMMUNITY MODULE (com_cd)
    use "$datain\com_cd", clear
 
*** Keeping relevant variables
    keep ea_id com_cd60a 

    rename com_cd60a distance
    label variable dis "distance to the nearest health facility"
	
	generate dist_cat = .
    replace dist_cat = 1 if distance >= 0 & distance <= 50
    replace dist_cat = 2 if distance > 50 & distance <= 200
    replace dist_cat = 3 if distance > 200
    label define dist_cat_label 1 "0-50 km" 2 "50-200 km" 3 ">200 km"

    label values dist_cat dist_cat_label

    save "$dataout\com_cd", replace
	
**********************************************************
*********************************************************

*** LOADING HOUSEHOLD MODULE A (hh_mod_a_filt)
    use "$datain\hh_mod_a_filt.dta", clear

*** Keeping relevant variables
    keep case_id HHID ea_id reside hh_wgt

*** Urban/Rural
    generate urban = .
    replace urban = 1 if reside == 1
    replace urban = 0 if reside == 2
    label variable urban "1 when urban, 0 when rural" //assigning variable label
    label values urban urban_rural

   drop reside
   save "$dataout\HH_MOD_A", replace

**********************************************************
**********************************************************

*** LOADING HOUSEHOLD ROSTER MODULE (HH_MOD_B)
    use "$datain\HH_MOD_B", clear

*** Keeping relevant variables
    keep case_id HHID PID hh_b03 hh_b05a hh_b21

    rename hh_b21 par_edu
    rename hh_b05a age
    gen age2 = age^2
    winsor2 age, replace cuts(1 95)
    winsor2 age2, replace cuts(1 90)

*** Generating age groups
    gen age_group = .
    replace age_group = 0 if age < 1 // Less than 1 year
    replace age_group = 1 if age >= 1 & age <= 4 // 1–4 years
    replace age_group = 2 if age >= 5 & age <= 9 // 5–9 years
    replace age_group = 3 if age >= 10 & age <= 14 // 10–14 years
    replace age_group = 4 if age >= 15 & age <= 19 // 15–19 years
    replace age_group = 5 if age >= 20 & age <= 24 // 20–24 years
    replace age_group = 6 if age >= 25 & age <= 29 // 25–29 years
    replace age_group = 7 if age >= 30 & age <= 34 // 30–34 years
    replace age_group = 8 if age >= 35 & age <= 39 // 35–39 years
    replace age_group = 9 if age >= 40 & age <= 44 // 40–44 years
    replace age_group = 10 if age >= 45 & age <= 49 // 45–49 years
    replace age_group = 11 if age >= 50 & age <= 54 // 50–54 years
    replace age_group = 12 if age >= 55 & age <= 59 // 55–59 years
    replace age_group = 13 if age >= 60 & age <= 64 // 60–64 years
    replace age_group = 14 if age >= 65 & age <= 69 // 65–69 years
    replace age_group = 15 if age >= 70 & age <= 74 // 70–74 years
    replace age_group = 16 if age >= 75 & age <= 79 // 75–79 years
    replace age_group = 17 if age >= 80 & age <= 84 // 80–84 years
    replace age_group = 18 if age >= 85 // 85+ years

*** Labeling variables 
    label variable age_group "Age category"
    label define age_grp_lbl 0 "Less than 1 year" 1 "1–4 years" 2 "5–9 years" 3 "10–14 years" 4 "15–19 years" 5 "20–24 years" 6 "25–29 years" 7 "30–34 years" 8 "35–39 years" 9 "40–44 years" 10 "45–49 years" 11 "50–54 years" 12 "55–59 years" 13 "60–64 years" 14 "65–69 years" 15 "70–74 years" 16 "75–79 years" 17 "80–84 years" 18 "85+ years"
    label values age_group age_grp_lbl

*** Generate Age specific mortality rate (asmr) as sourced from WHO https://apps.who.int/gho/data/view.main.60980

    gen asmr = .
    replace asmr = 0.0324722 if age_group == 0     // Less than 1 year
    replace asmr = 0.002838493 if age_group == 1   // 1–4 years
    replace asmr = 0.001525151 if age_group == 2   // 5–9 years
    replace asmr = 0.000917927 if age_group == 3   // 10–14 years
    replace asmr = 0.001316518 if age_group == 4   // 15–19 years
    replace asmr = 0.001917068 if age_group == 5   // 20–24 years
    replace asmr = 0.002403554 if age_group == 6   // 25–29 years
    replace asmr = 0.003347853 if age_group == 7   // 30–34 years
    replace asmr = 0.004739455 if age_group == 8   // 35–39 years
    replace asmr = 0.006810075 if age_group == 9   // 40–44 years
    replace asmr = 0.009153809 if age_group == 10  // 45–49 years
    replace asmr = 0.012800768 if age_group == 11  // 50–54 years
    replace asmr = 0.016760151 if age_group == 12  // 55–59 years
    replace asmr = 0.023783161 if age_group == 13  // 60–64 years
    replace asmr = 0.033689986 if age_group == 14  // 65–69 years
    replace asmr = 0.050953828 if age_group == 15  // 70–74 years
    replace asmr = 0.075182251 if age_group == 16  // 75–79 years
    replace asmr = 0.113600394 if age_group == 17  // 80–84 years
    replace asmr = 0.187334654 if age_group == 18  // 85+ years

*** Labelling
    label variable asmr "Age-Specific Mortality Rate"


*** Generating Life Expectancy (Expectation of life at year x) sourced from world bank
    gen life_exp = .
    replace life_exp = 65.62457949 if age < 1
    replace life_exp = 66.76667991 if age >= 1 & age <= 4
    replace life_exp = 63.50995627 if age >= 5 & age <= 9
    replace life_exp = 58.97698382 if age >= 10 & age <= 14
    replace life_exp = 54.23678887 if age >= 15 & age <= 19
    replace life_exp = 49.57847554 if age >= 20 & age <= 24
    replace life_exp = 45.03191195 if age >= 25 & age <= 29
    replace life_exp = 40.54614064 if age >= 30 & age <= 34
    replace life_exp = 36.18838044 if age >= 35 & age <= 39
    replace life_exp = 31.99627566 if age >= 40 & age <= 44
    replace life_exp = 28.01803047 if age >= 45 & age <= 49
    replace life_exp = 24.21332004 if age >= 50 & age <= 54
    replace life_exp = 20.64900046 if age >= 55 & age <= 59
    replace life_exp = 17.23641361 if age >= 60 & age <= 64
    replace life_exp = 14.09958643 if age >= 65 & age <= 69
    replace life_exp = 11.2332431 if age >= 70 & age <= 74
    replace life_exp = 8.783004152 if age >= 75 & age <= 79
    replace life_exp = 6.691529922 if age >= 80 & age <= 84
    replace life_exp = 5.016670329 if age >= 85

*** Generating Sex(Gender) variable
    gen sex = .
    replace sex = 1 if hh_b03 == 1
    replace sex = 0 if hh_b03 == 2
    label variable sex "1 when male, 0 when female"
    label values sex gender

  drop hh_b03
  save "$dataout\HH_MOD_B", replace

**********************************************************
**********************************************************

*** Loading Education Module (HH_MOD_C)
    use "$datain\HH_MOD_C", clear

*** Keeping relevant variables
    keep case_id HHID PID hh_c08

*** Generate Education variable	
    gen edu = .
    replace edu = 0 if hh_c08 == 0              // Nursery/Preschool
    replace edu = 1 if inrange(hh_c08, 1, 8)    // Primary (Standards 1–8)
    replace edu = 2 if inrange(hh_c08, 9, 14)   // Secondary (Forms 1–6)
    replace edu = 3 if inrange(hh_c08, 15, 19)  // Tertiary (University 1–4)
    replace edu = 4 if inrange(hh_c08, 20, 23)  // Technical Training (1–4 years)

    label variable edu "Highest Class Attended"
    label define edu_label 0 "Nursery/Preschool" 1 "Primary" 2 "Secondary" 3 "Tertiary" 4 "Technical Training"
    label value edu edu_label


   drop hh_c08
   save "$dataout\HH_MOD_C", replace

**********************************************************
**********************************************************

*** LOADING HH_MOD_D HOUSEHOLD HEALTH MODULE
    use "$datain\HH_MOD_D", clear

*** Keeping relevant variables
    keep case_id HHID PID hh_d04 hh_d07a hh_d07b hh_d10 hh_d34a hh_d34b hh_d11 hh_d12 hh_d12_1

*** Generate dummy for insurance
    gen insurance = .
    replace insurance = 1 if hh_d12_1 > 0
    replace insurance = 0 if hh_d12_1 == 0

*** Labelling
    label variable insurance "1=insured 0=not insured"
	label define insurance 1 "Insured" 0 "Not Insured"
	label values insurance insurance_cat
	
*** Generate Private Spending Dummy
	gen pvt = 0  
    replace pvt = 1 if hh_d07a == 7  // Assign 1 (yes) to those who visited a private facility

    label variable pvt "Private Healthcare Spending (1 = Yes, 0 = No)"
    label define private_spending_label 0 "No" 1 "Yes"
    label value pvt private_spending_label


*** Generate health_seek variable
    gen health_seek = 0

*** Set health_seek to 1 if hh_d04 is "yes" and action taken is not "did nothing"
    replace health_seek = 1 if hh_d04 == 1 & (hh_d07a != 1 & hh_d07a != 2)
    replace health_seek = 1 if hh_d04 == 1 & (hh_d07b != 1 & hh_d07b != 2)

*** Ensure health_seek is 0 if the individual did nothing for both illnesses
    replace health_seek = 0 if hh_d04 == 1 & (hh_d07a == 1 | hh_d07a == 2) & missing(hh_d07b)
    replace health_seek = 0 if hh_d04 == 1 & (hh_d07b == 1 | hh_d07b == 2) & missing(hh_d07a)

*** Label health seek
    label variable health_seek "Reported illness and sought help"
	
*** Generate Healthcare Expenditure HCE 
    generate hce = hh_d10 + hh_d11 + hh_d12 

*** Generate the natural log of HCE to handle skewed data
    gen lnhce = ln(hce + 1) //to account for all the zero values
    label variable lnhce "adjusted natural log of HCE"

*** Generate the COM variable and initialize it to 0
    gen com = 0

* Count the number of unique chronic illnesses
    foreach var in hh_d34a hh_d34b {
    replace com = com + !missing(`var')
}

*** Categorize the COM variable 
    gen COM_category = .
    replace COM_category = 0 if com == 0 
    replace COM_category = 1 if com == 1 
    replace COM_category = 2 if com == 2
    replace COM_category = 3 if com >= 3
 
    list hh_d34a hh_d34b com COM_category

    label variable com "Count of chronic illnesses present"
    label variable COM_category "level of comorbidity"
    label define com_label 0 "No Comorbidity" 1 "Low Comorbidity" 2 "Moderate Comorbidity" 4 "High Comorbidity"
    label value COM_category com_label

    drop com hh_d10 hh_d11 hh_d12 hh_d12_1
    rename COM_category com

    save "$dataout\HH_MOD_D", replace

**********************************************************
**********************************************************

*** LOADING MODULE E (TIME USE AND LABOUR)
    use "$datain\HH_MOD_E", clear
    keep case_id HHID PID hh_e25 hh_e39 hh_e59 hh_e06_8a hh_e06_8b

*** Generate Employment type (based on main economic activity)
    gen employment_status = .
    replace employment_status = 1 if hh_e06_8a == 1
    replace employment_status = 2 if hh_e06_8a == 2
    replace employment_status = 3 if hh_e06_8a == 3
    replace employment_status = 3 if hh_e06_8a == 4
    replace employment_status = 4 if hh_e06_8a == 5
    replace employment_status = 5 if missing(employment_status)

    label variable employment_status "1=Employed 2=Business 3=Unpaid 4=Ganyu 5=Unemployed"
    label define employment_status 1 "Formal Employment" 2 "Business" 3 "Unpaid Work" 4 "Ganyu" 5 "Unemployed"
    label values employment_status employment_cat

*** Generate Income	
	generate income = 0
    replace income = income + hh_e25 if !missing(hh_e25)
    replace income = income + hh_e39 if !missing(hh_e39)
    replace income = income + hh_e59 if !missing(hh_e59)

    gen lnincome = log(income + 1)
    label variable lnincome "adj natural log of income"
    drop hh_e25 hh_e39 hh_e59

    save "$dataout\HH_MOD_E", replace

**********************************************************
**********************************************************

*** LOADING SUBJECTOVE ASSESSMENT OF WELLBEING MODULE (HH_MOD_T)
    use "$datain\HH_MOD_T", clear

*** Keeping relevant variables
    keep case_id HHID hh_t04

*** Generate Percieved Health Status	
    gen health_status = . //Self assessed health level or status
    replace health_status = 1 if hh_t04 == 1
    replace health_status = 2 if hh_t04 == 2 
    replace health_status = 3 if hh_t04 == 3

    label variable health_status "Health Level"
    label define hs_label 1 "Less than Adequate" 2 "Just Adequate" 3 "More than Adequate"
    label value health_status hs_label

    drop hh_t04
    save "$dataout\HH_MOD_T", replace

**********************************************************
**********************************************************

*** LOADING CONSUMPTION AGGREGATE DATASET
    use "$datain\ihs5_consumption_aggregate", clear

*** Keeping relevant variables
    keep case_id HHID ea_id rexpaggpc rexp_cat02 poor

    rename rexpaggpc consumption 
    gen lnconsumption = log(consumption)
    rename rexp_cat02 alc_tob

    drop consumption

    save "$dataout\ihs5_consumption_aggregate" , replace

**********************************************************
**********************************************************

*** MERGING THE DATA 
    merge 1:1 case_id HHID using "$dataout\HH_MOD_A"
    drop _merge

    merge m:1 ea_id using "$dataout\com_cd"
    drop _merge

    merge 1:m case_id HHID using "$dataout\HH_MOD_B"
    drop _merge

    merge 1:1 case_id HHID PID using "dataout\HH_MOD_C"
    drop _merge

    merge 1:1 case_id HHID PID using "$dataout\HH_MOD_D" 
    drop _merge

    merge 1:1 case_id HHID PID using "$dataout\HH_MOD_E"
    drop _merge

    merge m:1 case_id HHID using "$dataout\HH_MOD_T"
    drop _merge
	
*********************************************************
*********************************************************

*** Adding interaction terms 
    gen sex_urban = sex * urban
    gen sex_age = sex * age
	gen urban_poor = urban * poor
 
*** CREATING HEALTH ADJUSTED LIFE EXPECTANCY
    rename hh_d34a chronic1
	rename hh_d34b chronic2 
	
    gen malaria = (chronic1 == 1 | chronic2 == 1)
    gen tuberculosis = (chronic1 == 2 | chronic2 == 2)
    gen hiv = (chronic1 == 3 | chronic2 == 3)
    gen diabetes = (chronic1 == 4 | chronic2 == 4)
    gen asthma = (chronic1 == 5 | chronic2 == 5) // Adjust 'chronic' to your specific variable
    gen schistosomiasis = (chronic1 == 6 | chronic2 == 6)
    gen arthritis = (chronic1 == 7 | chronic2 == 7)
    gen nerve_disorder = (chronic1 == 8 | chronic2 == 8)
    gen stomach_disorder = (chronic1 == 9 | chronic2 == 9)
    gen sores = (chronic1 == 10)
    gen cancer = (chronic1 == 11 | chronic2 == 10)
    gen pneumonia = (chronic1 == 12 | chronic2 == 11)
    gen epilepsy = (chronic1 == 13| chronic2 == 12)
    gen mental_illness = (chronic1 == 14 | chronic2 == 13)
    gen other = (chronic1 == 15 | chronic2 == 14)

***************************************************
***************************************************

*** Disability burden (averaged from Global Disease Burden)
    gen com_index = malaria * 0.13 + tuberculosis * 0.495 + hiv * 0.381 + diabetes * 0.282 + asthma * 0.133 + schistosomiasis * 0.325 + arthritis * 0.581 + nerve_disorder * 0.4145 + stomach_disorder * 0.5 + sores * 0.133 + cancer * 0.54 + pneumonia * 0.296 + epilepsy * 0.552 + mental_illness * 0.5905
    gen disability_burden = com_index
	

*** Disability weights
    gen disability_weight = disability_burden / life_exp
    gen hale = life_exp * (1 - (disability_weight)) // Health Adjusted Life Expectancy

    gen adj_disability = min(disability_weight * 10, 0.5) //scaling up so its effects arent so minimal
    gen HALE = life_exp * (1 - adj_disability) //exactly the same as life_exp :(

*** Mort as a proxy for TTD
    gen mort_risk = asmr * disability_burden 
	gen mortality_risk = mort_risk * 100
	
*** Dropping missing variables
    drop if missing(lnhce, age, age2, life_exp, com, urban, sex, health_seek, ///
health_status, insurance, lnincome, edu, sex_age, sex_urban, ///
employment_status, par_edu, distance)

*** Ordering
	order age age2 age_group life_exp sex com mortality_risk health_seek health_status urban pvt lnhce lnincome asmr insurance employment_status par_edu alc_tob distance sex_urban sex_age hh_wgt hh_d04 hh_d07a hh_d07b lnconsumption case_id HHID PID hce

	drop if missing(edu, distance, health_status)
    save "$dataout\DIZZE", replace

*****************************************************
*****************************************************					
 gen ttd = .
*** ANALYSIS

*** Descriptive statistics
   gen mortality_binary = 0
    replace mortality_binary = 1 if mortality_risk > 0.0156673

   gen mort_cat = .
    replace mort_cat = 0 if disability_burden == 0
    replace mort_cat = 1 if inrange(disability_burden, 0.01, 0.5)
    replace mort_cat = 2 if disability_burden > 0.5
    label define mort_label 0 "No burden" 1 "Low" 2 "High"
    label values mort_cat mort_label

	
*****************************************************
*****************************************************

*** MODEL SPECIFICATIONS?

*** Two part model
    tpm (first: lnhce = age sex urban poor edu insurance health_status distance par_edu) ///
	(second: lnhce = age age2 sex life_exp com health_status health_seek employment_status insurance urban poor pvt sex_age sex_ur) ///
	, f(probit) s(regress) vce(robust)
    estat ic
	margins, dydx(_all)
    marginsplot
	

*****************************************************
*****************************************************

*** DHREG
    dhreg lnhce age age2 life_exp com poor urban sex health_seek health_status insurance sex_age sex_urban employment_status, hd(age sex urban edu insurance poor health_status par_edu)
    estat ic
	margins, dydx(_all)
	
*****************************************************
*****************************************************

*** NEHURDLE
     nehurdle lnhce age age2 life_exp poor com urban sex health_seek health_status insurance sex_age employment_status, ///
    trunc select(age sex insurance health_status distance edu poor par_edu)
    estat ic
	margins, dydx(_all)
	
*****************************************************
*****************************************************

*** CHURDLE (Winner- lower AIC + easier post estimation)
    churdle linear lnhce age age2 com urban mortality_risk i.sex health_seek i.health_status insurance employment_status poor pvt i.urban_poor sex_age sex_urban, ///
	select(i.sex urban age edu insurance i.health_status dist_cat par_edu) ll(0) vce(cluster HHID) 

    estat ic
	margins, dydx(*) predict(pr(0,1))   // Effect on the probability of participation (Tier 1)
    margins, dydx(*) predict(ystar(2,.))   // Effect on intensity (Tier 2)
	
	margins, dydx(*) predict(ystar(0,.)) //unconditional

    margins, dydx(_all)
	
**********************************************************
   
    churdle linear lnhce age age2 com urban mortality_risk i.sex health_seek i.health_status insurance employment_status poor i.urban_poor sex_age sex_urban, ///
    select(i.sex urban age edu insurance i.health_status dist_cat par_edu) ///
    het(urban age insurance) ///
    ll(0) //using het instead of vce for heteroskedasticty? not much changed

*********************************************************
*********************************************************

*** CRAGGIT
    gen hce_binary = hce > 0
    craggit lnhce_binary age distance par_edu sex urban poor edu insurance health_status, ///
	sec(lnhce age age2 life_exp mortality_risk com urban sex health_seek health_status insurance employment_status poor) ///
	vce(robust)
	
	estat ic
	predict xb1, eq(Tier1)    // Predicted values for first hurdle
    generate p1 = normal(xb1) // Probability of participation
    margins, dydx(*) predict(xb1)  // Marginal effects for participation

	predict xb2, eq(Tier2)   // Predicted values for second hurdle
    predict sigma, eq(sigma) // Standard deviation of error term
    generate imr = normalden(xb2/sigma) / normal(xb2/sigma)  // Inverse Mills Ratio
    generate ycond = xb2 + sigma * imr  // Expected spending given participation
    margins, dydx(*) predict(ycond)  // Marginal effects for spending

	margins, dydx(*)
	margins, dydx(*) predict(ycond)
    esttab, wide


**********************************************************
**********************************************************
 
*** DIAGNOSTICS

*** Multicollinearity
    vif
	
*** Heteroskedasticity
    estat hettest
    estat imtest, white
    histogram expected_expenditure, bin(20) normal
	
	predict xbhat if lnhce > 0, xb
    gen xbhat2 = xbhat^2
    gen xbhat3 = xbhat^3

    reg lnhce xbhat xbhat2 xbhat3 if lnhce > 0
    capture program drop boot_churdle
    program define boot_churdle, rclass
    churdle linear lnhce age age2 com urban mortality_risk i.sex ///
        health_seek i.health_status insurance employment_status poor ///
        i.urban_poor sex_age sex_urban, ///
        select(i.sex urban age edu insurance i.health_status dist_cat par_edu) ///
        het(urban age insurance) ll(0)
    end

    bootstrap, reps(300) seed(1234): boot_churdle
    churdle linear lnhce age age2 com urban mortality_risk v_mortality i.sex health_seek ///
    i.health_status insurance employment_status poor i.urban_poor sex_age sex_urban, ///
    select(i.sex urban age edu insurance i.health_status par_edu) ///
	ll(0) vce(cluster HHID)


*** Breaush Pagan Test
    predict residuals, resid
    gen res2 = res^2
    reg res2 age age2 sex life_exp com health_status urban_rural health_seek sex_age sex_ur lnincome
    list res2 var_est if abs(res2 - var_est) > 0.0001

    rvfplot
	
*** Normality of residuals
    histogram residuals, normal
    kdensity residuals, normal
    swilk residuals

*** Omitted variables
    estat ovtest 
    linktest

	estat overid
	estat endog
	
***********************************************************
***********************************************************

*** GRAPHS
 twoway (lpolyci lnhce chronic1 if mortality_q==1, bw(5) lcolor(blue)) ///
      (lpolyci lnhce chronic1 if mortality_q==0, bw(5) lcolor(red)), ///
       legend(order(1 "High Mortality Risk" 2 "Low Mortality Risk")) ///
       xtitle("Chronic Ilness") ytitle("Log of Health Care Costs") ///
      title("Health Care Costs by Age and Mortality Risk") ///
      scheme(s2color)

graph bar (mean) mortality_risk, over(chronic1, label(labsize(small))) ///
       title("Mean Mortality Risk by Chronic Illness Category") ///
       ytitle("Mean Mortality Risk") ///
       bar(1, lcolor(black) lwidth(medium)) ///
       bar(1, bcolor(blue%30)) ///
       blabel(bar, size(medium) color(black)) ///
       xtitle ("Chronic Illness Category")



drop mortality_q
xtile mortality_q = mortality_risk, nq(4)  // Divides into 4 quartiles

twoway (lowess lnhce mortality_risk_group, bw(0.2) clcolor(blue)) ///
       (lowess lnhce age, bw(0.2) clcolor(red)), ///
       legend(order(1 "Mortality Risk" 2 "Age")) ///
       title("Log HCE by Mortality Risk and Age")

gen mortality_risk_percentile = .
replace mortality_risk_percentile = 1 if mortality_risk <= r(p75)
replace mortality_risk_percentile = 2 if mortality_risk > r(p75) & mortality_risk <= r(p90)
replace mortality_risk_percentile = 3 if mortality_risk > r(p90) & mortality_risk <= r(p95)
replace mortality_risk_percentile = 4 if mortality_risk > r(p99)
sort age


*precautions
	gen disability_burden2 = (prev_malaria * 0.13) + ///  
                        (prev_hiv * 0.381) + ///
                        (prev_tuberculosis * 0.495) + ///
                        (prev_asthma * 0.133) + ///
                        (prev_diabetes * 0.282) + ///
                        (prev_arthritis * 0.581) + ///
                        (prev_epilepsy * 0.552) + ///
                        (prev_stomach_disorder * 0.5) + ///
                        (prev_mental_illness * 0.5905) + ///
                        (prev_schistosomiasis * 0.325) + ///
                        (prev_nerve_disorder * 0.4145) + ///
                        (prev_pneumonia * 0.296) + ///
                        (prev_sores * 0.133) + ///
                        (prev_cancer * 0.54) //using extremes

						gen disability_burden3 = (prev_malaria * 0.0623) + ///
                        (prev_tuberculosis * 0.4172) + ///
                        (prev_hiv * 0.2179) + ///
                        (prev_diabetes * 0.183) + ///
                        (prev_asthma * 0.0613) + ///
                        (prev_schistosomiasis * 0.0698) + ///
                        (prev_arthritis * 0.3383) + ///
                        (prev_nerve_disorder * 0.2727) + ///
                        (prev_stomach_disorder * 0.3038) + ///
                        (prev_sores * 0.0633) + ///
                        (prev_cancer * 0.3042) + ///
                        (prev_pneumonia * 0.16) + ///
                        (prev_epilepsy * 0.288) + ///
                        (prev_mental_illness * 0.2715) //using averaged?


gen total_prev = prev_arthritis + prev_asthma + prev_cancer + prev_diabetes + prev_epilepsy + prev_hiv + prev_malaria + prev_mental_illness + prev_nerve_disorder + prev_pneumonia + prev_schistosomiasis + prev_sores + prev_stomach_disorder + prev_tuberculosis

gen years_with_illness = life_exp * total_prev
gen hale_corrected = life_exp - (years_with_illness * disability_burden2)

*** is hce individual or household level?
    bysort HHID (hce): gen dup = hce != hce[_n-1]
    bysort HHID: egen unique_vals = total(dup)

    list HHID hce unique_vals if unique_vals > 1, sepby(HHID) //individual

	//testing to see if if stata has synced with github
	