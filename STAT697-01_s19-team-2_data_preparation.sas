*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] patient_info

[Dataset Description] This dataset contains the basic information about 
patients in the study, including sex, age, weight and race.

[Experimental Unit Description] Each patient in this study

[Number of Observations] 357
                    
[Number of Features] 5

[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web

[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4

[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset1DSN = patient_info;
%let inputDataset1URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/patient_info.xlsx?raw=true
;
%let inputDataset1Type = XLSX;


*
[Dataset 2 Name] placebo

[Dataset Description] The dataset contains the recorded adverse reactions of 
patients in the placebo group.

[Experimental Unit Description] Each patient in this study

[Number of Observations] 130
                    
[Number of Features] 8

[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web

[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4

[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset2DSN = placebo;
%let inputDataset2URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/placebo.xlsx?raw=true
;
%let inputDataset2Type = XLSX;


*
[Dataset 3 Name] treatment

[Dataset Description] The dataset contains the recorded adverse reactions of 
patients in the drug-treated group.

[Experimental Unit Description] Each patient in the study

[Number of Observations] 127
                    
[Number of Features] 8

[Data Source] https://semanticommunity.info/@api/deki/files/25541/adverser.xls?origin=mt-web

[Data Dictionary] https://semanticommunity.info/Data_Science/SAS_Public_Data_Sets#Sample_Data_4

[Unique ID Schema] There's one column named patient_id which specifies the 
identities of patients.
;
%let inputDataset3DSN = treatment;
%let inputDataset3URL =
https://github.com/yli110-stat697/team-2_project_repo/blob/master/data/treatment.xlsx?raw=true
;
%let inputDataset3Type = XLSX;

options fullstimer;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 3;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets


* check the dataset patient_info for possible duplicate patients/observations;
proc sql;
    create table patient_info_dups as
        select
             patient_id
            ,count(*) as row_count_for_patient_id
        from
            patient_info
        group by
            patient_id
        having
            row_count_for_patient_id > 1
    ;
    /* there are some replicated observations, meaning that this dataset nees
    to be cleaned*/
    create table patient_info_final as
        select
            distinct *
        from
            patient_info
        where
            not(missing(patient_id))
    ;
quit;


* check placebo dataset using the same techniques as above;
proc sql;
    create table placebo_dups as
        select
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
            ,count(*) as row_count_for_placebo_obs
        from
            placebo
        group by
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
        having
            row_count_for_placebo_obs > 1
    ;
    create table placebo_final as
        select
            distinct *
        from
            placebo
    ;
quit;


* check treatment dataset using the same techniques as above;
proc sql;
    create table treat_dups as
        select
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
            ,count(*) as row_count_for_treat_obs
        from
            treatment
        group by
             patient_id
            ,day_on_drug
            ,adr_severity
            ,relation_to_drug
            ,adverse_reaction
            ,adr_duration
        having
            row_count_for_treat_obs > 1
    ;
    create table treatment_final as
        select
            distinct *
        from
            treatment
    ;
quit;


**Build analytical file by a single PROC SQL;
proc sql;
    create table adverser_analytical_file_raw as 
        select
             coalesce(A.patient_id, B.patient_id) as patient_id
            ,age
            ,sex
            ,weight
            ,race
            ,day_on_drug
            ,adverse_reaction
            ,relation_to_drug
            ,adr_severity
            ,adr_duration
            ,treatment_group
            ,total_daily_dose
        from
            patient_info_final as A
            full join
            (
            select *
                from treatment_final
            union corr
            select *
                from placebo_final
            ) as B
            on A.patient_id = B.patient_id
        order by 
             patient_id
            ,adverse_reaction 
            ,adr_severity 
            ,day_on_drug 
            ,adr_duration
    ;
quit;

**remove duplicate records from the analytical_file above;
proc sort
        noduprecs
        data = adverser_analytical_file_raw
        out = adverser_analytical_file
    ;
    by
        patient_id treatment_group adverse_reaction
    ;
run;

