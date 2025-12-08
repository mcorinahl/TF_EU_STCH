		  /******************************************************************
						Estimaciones ATT - Bid-Price y Sale-Price
					TWFE, Callaway Sant Anna, Borusyak, Chaisemartin
		   ******************************************************************/

clear all
set more off
set seed 12345
global data "C:\Users\USUARIO\Documents\GitHub\TF_EU_STCH\data\final\\"
global results "C:\Users\USUARIO\Documents\GitHub\TF_EU_STCH\results\\"

/*
ssc install csdid
ssc install drdid
ssc install avar
ssc install did_imputation
ssc install eventstudyinteract, replace
ssc install did_multiplegt
ssc install gtools

net install scheme-modern, from("https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/")
net install cleanplots, from("https://tdmize.github.io/data") replace
*/



** Abrir archivo de datos simulados


import dbase "${data}simulacion.dbf", clear 

#d; 
	rename (tret_yr evnt_tm id_mnzn manzn_f 
			popultn  log_prc tretmnt dmm_sls lg_prc_)
		   (treat_year event_time id_manzana manzana_fe 
			population log_price treatment dumm_sales log_price_sales);
#d cr 

**************
* Bid - Price
**************

** TWFE - Efecto agregado (ATT)

reghdfe log_price treatment viol_pc, a(id_manzana year) vce(cluster id_manzana upz_id)

tab event_time, gen(dummy_) m

local j=1
forval i=-9(1)5 {
	
	label var dummy_`j' "`i'"
	local j = `j'+1
	
}	

** TWFE - Estudio de eventos

replace dummy_9=0
reghdfe log_price dummy_1-dummy_14 viol_pc, nocons a(id_manzana year) vce(cluster id_manzana upz_id) level(90)
estimates store coefs
	
scalar obs = e(N)	


#d;
	coefplot coefs, omitted	keep(dummy_*)									
		  vertical label 															 
		  yline(0, lpattern("--") lwidth(*0.5) lcolor(black%80))   			 
		  xline(6, lpattern("--") lwidth(*0.5) lcolor(black%80))		 	 
		  ytitle("ATT", margin(r=2))										 
		  xtitle("Time to treatment",  margin(t=2))	 						
		  name(TWFE, replace) drop(dummy_1 dummy_2 dummy_3)		                   				
		  title("Bid Price", color(black) margin(b=3))			
		  note("{bf: Obs. =} `: di %4.0f obs'")								
		  scheme(cleanplots);
#d cr 
graph export "${results}bids.pdf", replace

**************
* Sale - Price
**************

replace log_price_sales=. if dumm_sales==1


** TWFE - Estudio de eventos

replace dummy_9=0
reghdfe log_price_sales dummy_1-dummy_14 viol_pc, nocons a(id_manzana year) vce(cluster id_manzana upz_id) level(90)
estimates store coefs
	
scalar obs = e(N)	


#d;
	coefplot coefs, omitted	keep(dummy_*)									
		  vertical label 															 
		  yline(0, lpattern("--") lwidth(*0.5) lcolor(black%80))   			 
		  xline(6, lpattern("--") lwidth(*0.5) lcolor(black%80))		 	 
		  ytitle("ATT", margin(r=2))										 
		  xtitle("Time to treatment",  margin(t=2))	 						
		  name(TWFE, replace) drop(dummy_1 dummy_2 dummy_3)		                   				
		  title("Sale Price", color(black) margin(b=3))			
		  note("{bf: Obs. =} `: di %4.0f obs'")								
		  scheme(cleanplots);
#d cr 
graph export "${results}sales.pdf", replace


**************
* Robustez
**************

** Callaway - Sant Anna

encode id_manzana, gen(man_code)
encode upz_id, gen(upz_code)

replace treat_year=0 if treat_year==.
csdid log_price viol_pc, ivar(man_code) time(year) gvar(treat_year) level(90) agg(event) cluster(upz_code)

scalar obs = e(N)

mat csdid_r= J(19,4,.)

local i=5
local k=1
forvalues j=-6(1)5 {
	mat csdid_r[`k',1]=`j'
	mat csdid_r[`k',2]=r(table)[1,`i']
	mat csdid_r[`k',3]=r(table)[5,`i']
	mat csdid_r[`k',4]=r(table)[6,`i']
	local i=`i'+1 
	local k=`k'+1 
}

mat colnames csdid_r= t coef li ls

csdid log_price viol_pc, ivar(man_code) time(year) gvar(treat_year) cluster(upz_code) level(90)
estat event

scalar preaver = r(table)[1,1]
scalar prepval = r(table)[4,1]
scalar posaver = r(table)[1,2]
scalar pospval = r(table)[4,2]

preserve
clear 
svmat csdid_r, names(col)

#d;
	tw (rcap li ls t if t<0, msize(vsmall) lcolor(cranberry%60)) 				 
		(scatter coef t if t<0, msize(small) msymbol(Sh) 
			mcolor(cranberry%50))	 
	   (rcap li ls t if t>=0, msize(vsmall) lcolor(purple%60)) 				 	 
		(scatter coef t if t>=0, msize(small) msymbol(Sh) 
			mcolor(purple%50)),	 
		  yline(0, lpattern("-") lwidth(*0.5) lcolor(black%80))				
        xline(-0.5, lpattern("-") lwidth(*0.5) lcolor(black%80))																		
		  xtitle("Time to treatment", margin(t=3)) ytitle("ATT", 
			margin(r=2)) 							
		  legend(order(2 "Pre-trat" 4 "Post-trat") r(2) 
			region (style(none))) 	
		  title("Bid Price", color(black))						
		  subtitle("Callaway and Sant'Anna (2021)", margin(b=3))	
		  note("{bf: Obs. =} `: di %4.0f obs'" 
		  "{bf: Pre-Average  =}  `: di %4.2f preaver' {bf: |} {bf: P-Val=} `: di %4.2f prepval'" 
		  "{bf: Post-Average=} `: di %4.2f posaver' {bf: |} {bf: P-Val=} `: di %4.2f pospval'") 
		  scheme(cleanplots); 
#d cr 
graph export "${results}bids_csdid.pdf", replace
		
restore


****
** Gráfica con todos los coeficientes
**** 
	  
mat R = J(3,4,.)

** TWFE 
reghdfe log_price treatment viol_pc, a(id_manzana year) vce(cluster id_manzana upz_id)

mat R[1,1] = r(table)[1,1]
mat R[2,1] = r(table)[5,1]
mat R[3,1] = r(table)[6,1]

scalar N_twfe = e(N)
scalar p_twfe = r(table)[4,1]


** Borusyak et al
preserve

replace treat_year=. if treat_year==0
did_imputation log_price man_code year treat_year, timecontrols(viol_pc) cluster(man_code) autosample alpha(0.10)  maxit(200)

restore

mat R[1,2] = r(table)[1,1]
mat R[2,2] = r(table)[5,1]
mat R[3,2] = r(table)[6,1]

scalar N_bys = e(N)
scalar p_bys = r(table)[4,1]


** Sun & Abraham (2021)
preserve
replace treat_year=. if treat_year==0

cap drop never_treated
gen never_treated = (treat_year == .)

eventstudyinteract log_price dummy_1-dummy_14, cohort(treat_year) control_cohort(never_treated) absorb(i.man_code i.year) vce(cluster man_code upz_code) covariates(viol_pc)

scalar obs = e(N)	

matrix b = e(b_iw)
matrix V = e(V_iw)
ereturn post b V

lincom (dummy_10 + dummy_11 + dummy_12 + dummy_13 + dummy_14)/5, level(90)

mat R[1,3] = r(estimate)
mat R[2,3] = r(lb)
mat R[3,3] = r(ub)

scalar N_sa = obs
scalar p_sa = r(p)

restore


** Chaisemartin 
did_multiplegt_dyn log_price man_code year treatment, trends_lin cluster(man_code) controls(viol_pc) save_results("${data}chais.dta")  

preserve
use "${data}chais.dta", clear
keep if time_to_treat==1
drop time_to_treat
mkmat point_estimate up_CI_95 lb_CI_95, mat(CD) 
mkmat N, mat(N)
scalar N_chais = N[1,1]
restore

mat R[1,4] = CD[1,1]
mat R[2,4] = CD[1,3]
mat R[3,4] = CD[1,2]


****
** Gráfica con todos los coeficientes
**** 

mat colnames R = TWFE BSY SA CD


coefplot mat(R[1]), ci((2 3)) legend(off) ///
 coeflabels(TWFE = "TWFE" BSY="Borusyak et al" SA="Sun & Abraham" CD="Chaisemartin et al") ///
 scheme(modern) xline(0, lpattern("--") lwidth(*0.5) lcolor(black%80))		///
 title("Bid Price") subtitle("Average Treatment Effect on the Treated", margin(b=3)) ///
 xtitle("ATT") ///
 note("{bf: Obs. TWFE:} `: di %4.0f N_twfe'          {bf:|} {bf: P-Val. TWFE=} `: di %4.2f p_twfe'" ///
	  "{bf: Obs. Borusyak:} `: di %4.0f N_bys'    {bf: |} {bf: P-Val. Borusyak=} `: di %4.2f p_bys'" ///
	  "{bf: Obs. S&A:} `: di %4.0f N_sa'            {bf: |} {bf: P-Val. S&A=} `: di %4.2f p_sa'" ///
	  "{bf: Obs. Chaisemartin:} `: di %4.0f N_chais'" )   xlab(-0.07(0.01)0.02)
	  

graph export "${results}all_ATT_bids.pdf", replace

