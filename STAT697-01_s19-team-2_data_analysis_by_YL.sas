*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that will generate final analytic file;
%include '.\STAT697-01_s19-team-2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify = left
'Question: What are the distributions of age, weight, and sex of patients in two different groups?'
;

title2 justify = left
"Rationale: This would help to decide if the study randomized the choices of treatment. In other words, we want to be sure that the the grouping wasn't biased."
;

*
Note: This compares the age, weight, race columns in the patient_info dataset.

Limitations: Descriptive statistics are useful, but eyeballing the differences
between treatment and placebo groups is not accurate. Besides, there are other
factors that may underlie the difference for these two groups, like the genetic
issues(some genotypes are more prone to have adverse effect).

Methodoloy: Use proc report and proc sgplot to create summary tables and graphs
to identify the distributions of factors for both placebo and treatment groups

Followup Steps: The significance of these distribution differences need to be
tested or proved by statistical methods
;

title3
"Summary table of the average age and weight for both placebo and treatment groups."
;

footnote1 justify = left
'The age and weight seem to have similar values, which indicates that there is no bias when assigning groups.'
;

proc report data = adverser_analytical_file;
    columns
            treatment_group
            age = age_mean
            weight = weight_mean
    ;
    define treatment_group / group;
    define age_mean / mean 'mean of age';
    define weight_mean / mean 'mean of weight';
run;
title;
footnote;

title1
"Summary table of sex frequencies for both groups."
;

footnote1 justify = left
'The sex ratio in two groups were very different though. Placebo group has a female:male of 15:1, whereas treatment group only has a ration of 3:1. This suggests that we should take sex into consideration in our regression model later.'
;
proc report data = adverser_analytical_file;
    columns
            treatment_group
            sex
            N
    ;
    define treatment_group / group;
    define sex / across;
    define N / 'count';
run;
title;
footnote;

title1
"Box plot for the age distribution of both groups."
;

footnote1 justify = left
"The box plots showed similar distributions for age of both placebo and drug treatment group."
;
proc sgplot
    data = adverser_analytical_file;
    vbox age / category = treatment_group;
run;
title;
footnote;

title1
"Box plot for the weight distribution of both groups."
;

footnote1 justify = left
"The box plots showed similar distributions for weight of both placebo and drug treatment group."
;
proc sgplot
    data = adverser_analytical_file;
    vbox weight / category = treatment_group;
run;
title;
footnote;

title1
"Stacked bar chart for the sex ratio for both groups."
;

footnote1 justify = left
"The stacked bar chart shows a much higher sex ratio in the placebo group."
;
proc sgplot
    data = adverser_analytical_file;
    vbar treatment_group / group = sex;
run;
title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify = left
'Question: Was the drug treatment having significant adverse reactions?'
;

title2 justify = left
'Rationale: This would help us to identify whether the reported adverse reactions were from placebo effect or they really exist.'
;

*
Note: This compares columns adverse_reaction and severity in placebo and 
treatment datasets.

Limitations: There are so many different types of adverse reactions, and each
reactions have different severities and durations. Severities might positively
correlate to durations, but it's also possible that they are negatively related

Methodology: Use summary table and t test to see the difference in adverse
distribution.

Followup Steps: other columns like Severity and adverse reactions can also be 
used to data analysis.
;
title3
"Summary table of adverse duarations for both groups."
;

footnote1 justify = left
'From the summary table, we can see that placebo group has a smaller duration.'
;

footnote2 justify = left
'However, we are not sure if the difference is significant.'
;
proc sql;
    select
         treatment_group
        ,avg(adr_duration) as AvgDuration
    from adverser_analytical_file
    group by treatment_group
    ;
quit;
title;
footnote;

title1
"Two-sample t test"
;

footnote1 justify = left
'A two-sample t test is used to compare if the adverse durations are significantly different for two groups.'
;

footnote2 justify = left
'A p value smaller than 0.05 indicates that the adverse durations are different for two groups.'
;
proc ttest 
    data = adverser_analytical_file;
    class treatment_group;
    var adr_duration;
run;
title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify = left
'Question: What are other factors that might affect the patients reactions to drugs/placebo?'
;

title2 justify = left
"Rationale: This could help us to find more potential factors that affect people's reactions to drugs."
;

*
Note: This compares the columns age, weight from patient_info to the column 
adverse_reaction and severity from placebo and treatment.

Limitations: To construct a predicative or classifcation model for adverse
reactions, we can build models based on different combinations of variables in
the given dataset. However, the variables given may not have a clear
explanation for the response variables. Besides, the response variable has a
few choices, picking up the suited one is critial.

Methodology: use proc sql to create views that compare the adverse durations
for races, and then proc glm to compare a few factors.

Followup Steps: A regression model that includes both cateorical and continuous
variables can be employed in the late steps.
;
title3
"Summary table of average adverse duration for different races"
;

footnote1 justify = left
'Different race has huge different duration time for adverse reaction.'
;
proc sql;
    select
         race
        ,avg(adr_duration) as AvgDuration
    from adverser_analytical_file
    group by race
    ;
quit;
title;
footnote;

title1
"General Linear Model of adverse duration Vs race, sex and treatment groups."
;

footnote1
"After taking race and sex into considertion, treatment group is not a significant factor for adverse reactions."
;

proc glm data = adverser_analytical_file;
    class treatment_group sex race;
    model adr_duration = treatment_group sex race;
run;
quit;
title;
footnote;
