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

title1
'[Question 1] What is the distribution of sex between groups?'; 

title2 justify=left
'Rationale: This would help to find out whether the distribution between groups is significantly large, and lead to the consideration of if sex would be one factor that contribute the difference in adverse reaction.';

footnote1 justify=left
'Based on the table, we can see that number of females is significantly higher than male, either in treatment group or in placebo. Thus this experience choose patients randomly, it might still worth to find out if sex would be a factor to patient reaction.';

*
Note: This compares the sex columns in the original patient_info dataset.

Limitations: Values of "Adverser reaction" equal to zero should be excluded 
from the analysis, since they are potentially missing data values.

Methodology: Use proc report to create the summary table.

Followup Steps: Clean up values in order to filter out any possible illegal 
values. Display a visual summary (boxplot) to illustrate the difference
between genders in groups.
;

proc report data=Adverser_analytical_file;
	columns
		treatment_group
		sex
	;
	define treatment_group / group;
	define sex / across;
run;
	
* clear titles/footnotes;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'[Question 2] Does the duration on drug has significant impact on adverse severity?';

title2 justify=left
'Rationale: This could help us to identify whether the reported adverse severity were based on the treatment itself or/and the duration on drug.';

footnote1 justify=left
'Since p-value=0.5804 > alpha=0.05, failed to conclude that the duration on drug has significant impact on adverse severity; treatment group as factor, with p-value=0.4411 has no significant impact on adverse severity as well.';

*
Note: This compares columns Day_on_drug, and severity in placebo and 
treatment datasets.

Limitations: Values of "Adverse severity" equal to zero should be excluded 
from the analysis, since they are potentially missing data values.

Methodology: Use proc logistic to perform a logistic regression analysis.

Followup Steps: Consider other factors that might affect patiens reactions
on drugs (or placebo)
;

proc logistic data=Adverser_analytical_file;
	class treatment_group;
	model adr_severity = treatment_group day_on_drug /influence;
run;
quit;

* clear titles/footnotes;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'[Question 3] Was the adverse reaction times differ significantly between two groups of patients? ';

title2 justify=left 
'Rationale: This could help us to figure out whether the duration of adverse reaction has impact (other than treatments effect) between two groups.';

*
Note: This compares the columns ADR_DURATION from adverse_reaction and 
severity from placebo and treatment.

Limitations: Values of "treatments (groups of patients)" equal to zero should
be excluded from the analysis, since they are potentially missing data values. 

Methodology: Use proc glm to perform the regression analysis.

Followup Steps: Since the F value of the treatment group has significant p-value
indicating there is a different in ADR duration in treatment vs placebo groups. 
We would like to conduct an one-sided hypothesis analysis to find out how was 
the difference between groups.
;

footnote1 justify=left
'Assuming the variables have homogeneity variances and residuals are normally distributed (assumptions checked performed at the end).';

footnote2 justify=left
'Since F value for treatment group is 3.90, with p-value=0.0492 < alpha=0.05, reject H0. There is enough evident to show that the ADR duration time is different between treatment group, however, the result is not significant.';

proc glm data=Adverser_analytical_file;
	class treatment_group;
	model adr_duration = treatment_group /solution;
	output out=residuals r=resid;
run;
quit;

* clear titles/footnotes;
title;
footnote;


/* 
Check Assumptions for valid ANOVA:
1. Homogeneity variances
proc glm data=Adverser_analytical_file; 
	class treatment_group; 
	model adr_duration = treatment_group /solution;
	means treatment_group / hovtest = levene; 
	*
	H0: Homogeneity variances
	Ha: Not all variances are the same
	Since p-value=0.3197 > alpha=0.05, Homogeneity variance.
	;
run; 

2. Normality of residuals
proc univariate data=residuals plot normal; 
	var resid; 
	*
	H0: Normal residuals
	Ha: Residuals not normally distributed
	Since p-value<0.0001, Residuals are normally distributed.
	;
run; 

* Based on above validation, model is valid ANOVA;
*/
