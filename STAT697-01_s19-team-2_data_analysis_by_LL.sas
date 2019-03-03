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

ods listing style=listing;
ods graphics / width=8in height=8in;
title1
'Question: What is the distribution of days on drug and duration of adverse 
 reaction for placebo and non placebo patients?';

title2
'Rationale: This would help formulate more questions around how some patients 
 react whether age, weight and/or sex could be a factor.';

footnote1
'Here we can see that majority of the placebo and drug groups stay within a
 one to one days on drugs and reaction but there are a few that have a high
 adverse reaction for such a low amount of time on the drug or placebo';

footnote2
'I find this to be significant because it is not limited to just the drug 
 but also appears with the placebo and I would like to know what factors
 might play a part within these individuals to cause such a reaction.';

footnote3
'I think it might have to do with ones physical measurements either their
 weight, age or perhaps their sex. Perhaps there is a sweet spot that 
 these individuals fall under that could help eliminate outliers in 
 further studies.'

*
Note: This compares the column Day_On_Drug and ADR_Duration with 
Treatment_Group from Placebo and Treatment.

Limitations: Some limiations might include that our adr_duration and 
Day_on_Drug have 0 values and very high values that might skew our data.
;

proc sgplot
  data = adverser_analytical_file
  ;
  scatter X = day_on_drug Y = adr_duration / group = treatment_group
  ;
run;
title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Question: Is the duration of the reaction correlated with the age, sex, 
 weight, and day on drug of the patient?';

title2
'Rationale: Would like to see if the severity and duration align with the same
 factors that are significant.';

footnote1
'Here we see the parameter estimates table and find that day on drug is the
 only significant factor within our regression test.'

footnote2
'I find this to be interesting since from our initial distribution we saw 
 that some people would have a very adverse reaction within just a couple
 of days while others would have a low reaction from a long usage time.'

footnote3
'I am not sure what to make of these findings but I hope to see if our
 other test will align with similar findings.'

*
Note: This compares the column ADR_duration from Placebo and Treatment to the 
column Age, Weight, and Sex from Patient_Info

Limitations: Again our issue might be based on how common one severity is 
versus the other ones which might prove to lack our correlation with soeme
of the variables.
;
ods html close;
ods listing close;
proc glmmod 
        data = adverser_analytical_file
        outdesign = adverser_analytical_file_2
        outparm= GLMParm
    ;
    class sex;
    model adr_duration =  day_on_drug age weight sex;
run;
ods html;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;


title1
'Question: Is there a correlation with Severity of reaction from age, weight,
and sex?';

title2
'Rationale: This would help identify any significant factors that contribute to 
the severity of the drug reaction.';

footnote1
'Here we see that a moderate reaction is much more significant than a mild
 reaction and yet the days on drugs is not as significant as opposed to
 our last regression model, yet weight is a factor.';

footnote2
'I find this to be significant because this lines up more with our graph
 showing that the amount of time on the drug or placebo does not correlate
 with how long their reaction is.';

footnote3
'It is interesting to me why weight is a factor in the reaction but not the
 duration. Could this be due to nutrition and if so is there a weight range
 that would cause a certain type of reaction?';

*
Note: This compares the column ADR_Severity from Placebo and Treatment to the 
column Age, Weight, and Sex from Patient_Info.

Limitations: Might have a limitation for our character variable and how 
accurate some of our results might be due to our lack of variety in 
ADR_Severity
;

proc logistic
			data = adverser_analytical_file
	;
	class sex;
	model adr_severity = age weight sex day_on_drug;
	ods select ParameterEstimates;
run;
title;
footnote;
