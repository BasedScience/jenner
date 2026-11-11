/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
+ Project          : standard table 1 for papers, illustration
+ Program name     : checks.sas
+ Location         : /home/dockien/Desktop/jenner/2026_table1
+ Description      : misc checks

* Type             : Jenner program (sas compatible code)
* Output type      : NA

+ Programmer responsible : Doc Kien
+ Date of creation    : 07-Nov-2026

* Interaction         : 

* Input files  : NA
* Output files : NA

+ Developed under : LINUX Jenner v1.5.113

Comments :
 [#]  Date         Author     Comment
 ---  -----------  --------   -----------

*/

/*********************************************************************/
/*                      Beginning of Code                            */
/*********************************************************************/

*confirm cv from proc ttest;
data logdata;
  set der.demog;
  if alt > 0 then logalt = log(alt);
  if ast > 0 then logast = log(ast);
run;

proc means data=logdata noprint;
  var logalt logast;
  output out=stats1 std=sdlogalt sdlogast;
run;

data der.check1;
  set stats1;
  cvalt=100*sqrt(exp(sdlogalt**2)-1);
  cvast=100*sqrt(exp(sdlogast**2)-1);
run;

ods graphics off; /*suppress unwanted plots*/
ods output statistics=stats2 (rename=(geometricmean=gm coefvar=cv_));
proc ttest data=der.demog dist=lognormal;
  var alt ast;
run;

data der.check2;
  set stats2;
  cv=100*cv_;
run;
*seems to give only one obs in ods;
*otherwise the cv is correct;

*check univariates is not giving varname;
proc sort data=der.demog out=demog;
  by trtn;
run;

ods output basicmeasures=der.stats2 (where=(locmeasure in ('Mean')));
proc univariate data=demog;
  var age durdis bmibl weightbl heightbl mmsetot educlvl;
  by trtn;
run;
*it gives the label instead of the var name, would make merge with pvals by varname fail;
*flagged this with jenner;

*will use kruskall-wallis to obtain pvalues, test npar1way. but want to
 check p-values from ancova match those in csr;
*need to restructure dataset;
data der.check;
  set der.demog;
  where trtn ne 100;
  keep newsubjid trtn age durdis bmibl weightbl heightbl mmsetot educlvl;
run;

proc transpose data=der.check out=der.check_t (rename=(col1=aval));
  var age durdis bmibl weightbl heightbl mmsetot educlvl;
  by newsubjid trtn;
run;

proc sort data=der.check_t;
  by _name_;
run;

ods output modelanova=check2;
proc anova data=der.check_t;
  class trtn;
  model aval=trtn;
  by _name_;
run;

data der.check2;
  set check2;
  pval=put(probf,pvalue6.4);
run;

ods output overallanova=der.check3 (where=(source='trtn'));
proc glm data=der.check_t;
  class trtn;
  model aval=trtn;
  by _name_;
run;
*matches;

/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
