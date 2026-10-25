/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
+ Project          : standard table 1 for papers. for illustration and test jenner
+ Program name     : run_all.sas
+ Location         : /home/dockien/Desktop/jenner/2026_table1
+ Description      : clean run of all programs, in the right order, capture log

* Type             : Jenner program (sas compatible code)
* Output type      : na

+ Programmer responsible : Doc Kien
+ Date of creation    : 10-Oct-2026

* Interaction         : na

* Input files  : na
* Output files : na

+ Developed under : LINUX Jenner v1.5.97

Comments:
 [#]  Date         Author     Comment
 ---  -----------  --------   -----------

*/


/*********************************************************************/
/*                      preamble */
/*********************************************************************/

*set project path;
%let path=/home/dockien/Desktop/code/jenner/202609_table1;

*save log for documentation;
proc printto
  log="&path/output/run_all.log"
  print="&path/output/run_all.lst"
  new ;
run;

*define data libraries;
libname raw "/home/dockien/Desktop/github/jenner/sourcedata/tdf_adam/";
*libname der "/home/dockien/Desktop/code/jenner/202609_table1/data/";
libname der "&path/data/";

*clear datasets to start session;
proc datasets lib=der kill memtype=data;
run;
quit;

*cancel all currently defined titles and footnotes;
title;
footnote;

*calculate run time;
%let total_t0 = %sysfunc(datetime()); 

/*********************************************************************/
/*                      macros and formats */
/*********************************************************************/

%include "&path/formats.sas"; /*define formats*/


/*********************************************************************/
/*                      data prep */
/*********************************************************************/

%include "&path/inspect_data.sas"; /*check contents of datasets*/
%include "&path/derive_demog.sas"; /*gather required variables for fas*/

/*********************************************************************/
/*                      analysis programs */
/*********************************************************************/

%include "&path/analysis.sas"; /*get basic stats and pvals as per csr*/

/*********************************************************************/
/*                      create outputs */
/*********************************************************************/

*%include "&path/table1.sas"; /*create table as txt and pdf*/

*output speed;
%let total_speed = %sysevalf(%sysfunc(datetime()) - &total_t0);
data _null_;
  put "NOTE: Total runtime: %sysfunc(putn(&total_speed,time8.))";
run;

*reset log;
proc printto; 
run;



/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
