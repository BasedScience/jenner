/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
  Property of Accovion GmbH

+ Program name     : derive_data.sas
+ Location         : /home/dockien/Desktop/jenner/2026_table1
+ Description      : standard table 1 for papers, illustration

* Type             : SAS program
* Output type      : Table

+ Program responsible : Doc Kien
+ Date of creation    : 02-Nov-2026

* Interaction         : uses estimates from analysis.sas

* Input files  : der.catstats_t2, der.contstats_t2 (see analysis.sas)
* Output files : table1.txt

+ Developed under : LINUX Jenner v1.5.113

Comments:
 [#]  Date         Author      Description
 ---  -----------  --------            -----------
 [1] 08nov2026,   Doc Kien     In inspect_data.sas i note 4 missings,
     note ths appears in table


*/

/*********************************************************************/
/*                      Beginning of Code                            */
/*********************************************************************/



*see notes in notes.txt;



data table1;
*use retain statement to put variables in a sensible order;
  retain varname label posn posn_ statyp trt:;
  format label $100. posn 4.1;
  set der.catstats_t2 der.contstats_t2;
*add labels (from eg param variable in adlbc);
       if lowcase(varname)='age'      then label='Age (y)';
  else if lowcase(varname)='agec'     then label='Age group (y), n (%)';
  else if lowcase(varname)='sexc'     then label='Sex';
  else if lowcase(varname)='racec'    then label='Race (Origin)';
  else if lowcase(varname)='mmsetot'  then label='MMSE';
  else if lowcase(varname)='durdis'   then label='Duration of disease (months)';
  else if lowcase(varname)='durdisc'  then label='Duration of disease groups (months), n (%)';
  else if lowcase(varname)='educlvl'  then label='Years of education';
  else if lowcase(varname)='weightbl' then label='Weight (kg)';
  else if lowcase(varname)='heightbl' then label='Height (cm)';
  else if lowcase(varname)='bmi'      then label='BMI (kg/m2)';
  else if lowcase(varname)='bmic'     then label='BMI group (kg/m2), n (%)';
  else if lowcase(varname)='ast'      then label='Aspartate Aminotransferase in Serum (U/L)';
  else if lowcase(varname)='alt'      then label='Alanine Aminotransferase in Serum (U/L)';
*add var to sort;
       if lowcase(varname)='age'      then posn = 1+posn_;
  else if lowcase(varname)='agec'     then posn = 2+posn_;
  else if lowcase(varname)='sexc'     then posn = 3+posn_;
  else if lowcase(varname)='racec'    then posn = 4+posn_;
  else if lowcase(varname)='mmsetot'  then posn = 5+posn_;
  else if lowcase(varname)='durdis'   then posn = 6+posn_;
  else if lowcase(varname)='durdisc'  then posn = 7+posn_;
  else if lowcase(varname)='educlvl'  then posn = 8+posn_;
  else if lowcase(varname)='weightbl' then posn = 9+posn_;
  else if lowcase(varname)='heightbl' then posn = 10+posn_;
  else if lowcase(varname)='bmibl'    then posn = 11+posn_;
  else if lowcase(varname)='bmic'     then posn = 12+posn_;
  else if lowcase(varname)='ast'      then posn = 13+posn_;
  else if lowcase(varname)='alt'      then posn = 14+posn_;
  pagen=floor(divide(posn,4));
  label statyp='statistic';
run;

proc sort data=table1;
  by posn label;
run;

data der.table1;
  set table1;
  by posn label;
  if not first.label then pval='';
run;

*get ns for table headings;
ods output onewayfreqs=getns;
proc freq data=der.demog;
  tables trtn / nocum nopercent;
run;

data _null_;
  set getns;
       if trtn = 0   then call symput("trtn0",trim(left(put(frequency,5.))));
  else if trtn = 54  then call symput("trtn54",trim(left(put(frequency,5.))));
  else if trtn = 81  then call symput("trtn81",trim(left(put(frequency,5.))));
  else if trtn = 100 then call symput("trtn100",trim(left(put(frequency,5.))));
run;

*output table;
options nodate nonumber orientation=landscape leftmargin=1cm rightmargin=1cm;

filename outfile "&path/output/table1.txt";
proc printto file=outfile new;
run;

title1 j=r " ";
title2 j=l "Table 1. Summary of Baseline Demographics";

proc report data=der.table1
   spacing=1 nowd headline formchar(2)='_' headskip split='#' ls=150 ps=200;
  compute after label;
    line @1 '';
  endcomp;
  column (pagen label statyp trt: pval);
  define pagen      / order order=data noprint;
  define label      / order order=data width=35 left "Characteristic" flow;
  define statyp     / order order=data width=19 left "Statistic" flow;
  define trt0       / display width=22 "Cagrisema (n=&trtn0)";
  define trt54      / display width=22 "Placebo (n=&trtn54)";
  define trt81      / display width=22 "Placebo (n=&trtn81)";
  define trt100     / display width=22 "Total (n=&trtn100)";
  define pval       / display width=22 "p-value[1]"; /*should display one for row only*/
  compute after;
    line @1 '             ____________________________________________________________________________________________________________________________';
    line @1 "             [1] P-values for a difference between treatment groups is from Kruskall-Wallis for continuous variables and Pearson's chi-square test for categorical variables....";
  endcomp;
run;

proc printto;
run;



/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
