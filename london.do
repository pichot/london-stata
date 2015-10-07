// DEPENDENT: 
// -- How satisfied or dissatisfied are you with London as a city to live in?

rename q3satisfied_london satisfied
label var satisfied "Satisfied with London"

// Drop missing and "don't know" responses
drop if satisfied == . | satisfied == 6

fre satisfied
tab satisfied
sum satisfied
histogram satisfied


// INDEPENDENTS: 
// -- How long have you been living in London?

rename q1living_in_london living
label var living "How long lived in London"

// Drop if "don't know/can't remember" how long. (Note: no missing)
drop if living == 9

fre living
tab living
histogram living


// -- Community Services Index (from 0 to 4)
//    Composite of: Q11. Thinking about your local area, please tell us how strongly
//    you agree or disagree with each of the following statements about local services.

// Create local macro that includes all service variables. Keeps things pretty.
local ServiceVars q5local_good_schools q5local_activities_young_people q5local_transport_links q5local_leisure_facilities q5local_Police_visible

// Find how many answers each person didn't know.
egen dont_know_services_count = anycount(`ServiceVars'), values(6)

// Drop the lazy ones. (People who didn't know any of the 7 questions.)
drop if dont_know_services_count == 5

// Loop over variables, giving them appropriate numbers for the community index.
// Since we know how many of the q7 questions someone DIDN'T answer, we can make
// 'Don't Know' (6) disappear by adding zero.
foreach q5 of varlist `ServiceVars' {
  recode `q5' (1=4) (2=3) (3=2) (4=1) (5/6=0)
}

// MAGIC! The Community Services Index is created by adding all community services
// variables (q5) and dividing by the number of answers not answered with "Don't Know"
egen services_totals = rowtotal(`ServiceVars')
gen services_index = services_totals / (5 - dont_know_services_count)

// Label the variables and their values
label def services_labels 0 "Strongly Disagree" 1 "Tend to disagree" 2 "Neither agree nor disagree" 3 "Tend to agree" 4 "Strongly agree"
label val services_index services_labels
label var services_index "Community Services Index"

fre services_index
sum services_index
hist services_index


// -- Mayoral Responsibility Index (from 0 to 2)
//    Composite of: Q47. For which of the following do you think the Mayor of London 
//    has responsibility? Would you say he has...total, some or no responsibility when it comes to...

// Create local macro that includes all mayoral variables. Keeps things pretty.
local MayorVars q41mayor_resp_economic_dev q41mayor_resp_police q41mayor_resp_housing q41mayor_resp_transport q41mayor_resp_roads q41mayor_resp_tourism q41mayor_resp_fire q41mayor_resp_education q41mayor_resp_major_planning q41mayor_resp_environment q41mayor_resp_2012legacy q41mayor_resp_budgets q41mayor_resp_tax q41mayor_resp_abroad q41mayor_resp_justice q41mayor_resp_events q41mayor_resp_sporting_event

// Loop over variables, giving them appropriate numbers for the community index.
foreach q41 of varlist `MayorVars' {
  recode `q41' (1=2) (2=1) (3=0)
}

// Good job Boris! The mayoral responsibility index is created by adding all weighted answers
// to mayoral responsibility questions and dividing by the total number of questions: 17.
egen mayor_totals = rowtotal(`MayorVars')
gen mayor_index = mayor_totals / 17

// Label the variables and their values
label def mayor_labels 0 "Strongly Disagree" 1 "Tend to disagree" 2 "Neither agree nor disagree" 3 "Tend to agree" 4 "Strongly agree"
label val mayor_index mayor_labels
label var mayor_index "Mayoral Responsibility Index"

fre mayor_index
sum mayor_index
hist mayor_index
