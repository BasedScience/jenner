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

data der.table1;
*use retain statement to put variables in a sensible order;
  retain varname label statn statn_ statxt trt:;
  format label $100. statn 4.1;
  set der.catstats_t2 der.contstats_t2;
*add labels;
       if varname='sexc'    then label='Sex';
  else if varname='agec'    then label='Age (years)';
  else if varname='bmic'    then label='BMI (kg/m2)';
  else if varname='racec'   then label='Race';
  else if varname='durdisc' then label='Duration of disease';
*add var to sort;
       if varname='age'   then statn = 1+statn_;
  else if varname='agec'  then statn = 1+statn_;
  else if varname='sexc'  then statn = 2;
  else if varname='mmse'  then statn = 3+statn_;
  *pagen=floor(divide(statn,5));
  pagen=1;
  label statxt='statistic';
run;

proc sort data=der.table1;
  by statn ;
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
title2 j=l "Table 1. Summary of Baseline Demographics*";

proc report data=der.table1
   spacing=1 nowd headline formchar(2)='_' headskip split='#' ls=150 ps=200;
  compute after grpn;
    line @1 '';
  endcomp;
  compute before label2;
    line @14 label2 $100.;
  endcomp;
  column (pagen label statxt trt: );
  define pagen      / order order=data noprint;
  define label      / order order=data width=35 left "Characteristic" flow;
  define statxt     / order order=data width=19 left "Statistic" missing flow;
  define trt0       / display width=22 "Cagrisema (n=&trtn0)";
  define trt54       / display width=22 "Placebo (n=&trtn54)";
  define trt81       / display width=22 "Placebo (n=&trtn81)";
  define trt100       / display width=22 "Total (n=&trtn100)";
  compute after;
    line @1 '             ____________________________________________________________________________________________________________________________';
    line @1 "             [1] P-values from Kruskall-Wallis for continuous variables and Pearson's chi-square test for categorical variables....";
  endcomp;
run;

proc printto;
run;



/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
