/* Type these commands to install the "estout" package: 
ssc install estout
Also: Note you can type help [command] into Stata to get help on any command. 
*/

* Read in data: 
insheet using vaping-ban-panel.csv

*Label your variables
label variable lung_hospitalizations "Lung hospitalization"
label variable treatment "Vaping ban"

* generation interaction term
gen year_treatment = year*treatment
label variable year_treatment "Year*Vaping ban"

* Testing parallel assumption:  
reg lung_hospitalizations year treatment year_treatment if year < 2021

* Store regression
eststo regression_one 

* Testing diff-in-diff
gen post_treat = 0
replace post_treat = 1 if year > 2021
gen treat_post_treat = treatment*post_treat
label variable post_treat "Post-treatment"
label variable treat_post_treat "Vaping ban*Post-treatment"

reg lung_hospitalizations post_treat treat_post_treat treatment i.state_id

* Store regression
eststo regression_two

**********************************
* FOR PEOPLE USING MICROSOFT: 
global tableoptions "bf(%15.2gc) sfmt(%15.2gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab regression_one using HW2-Table1.rtf, $tableoptions
esttab regression_two using HW2-Table2.rtf, $tableoptions keep(post_treat treat_post_treat treatment)

* Graph 

bysort year treatment: egen hospitalization_mean = mean(lung_hospitalizations) 
keep hospitalization_mean year treatment

sort hospitalization_mean year treatment
quietly by hospitalization_mean year treatment:  gen dup = cond(_N==1,0,_n)
drop if dup > 1

gsort year hospitalization_mean

label variable hospitalization_mean "Mean number of hospitalization"

twoway (line hospitalization year if treatment==0, lcolor(blue)) (line hospitalization year if treatment==1, lcolor(red)), xline(2021) legend(label(1 "No treatment") label(2 "Treatment"))

graph export DnD_graph.pdf
