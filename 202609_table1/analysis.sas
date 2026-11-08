/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
+ Project          : standard table 1 for papers, illustration
+ Program name     : analysis.sas
+ Location         : /home/dockien/Desktop/jenner/2026_table1
+ Description      : collect stats needed for table 1

* Type             : Jenner program (sas compatible code)
* Output type      : datasets: contstats_t2, catstats_t2

+ Program responsible : Doc Kien
+ Date of creation    : 24-Oct-2026

* Interaction         : uses output from derive_data.sas

* Input files  : der.demog (this is fas. it contains a total group which must
                 be removed before running trt group comparisons. see derive_demog.sas)
* Output files : 

+ Developed under : LINUX Jenner v1.5.113

Comments:
 [#]  Date         Author     Comment
 ---  -----------  --------   -----------
 [1]  17oct2026    Doc Kien   validation is against the csr table
 [2]  24oct2026    Doc Kien   pvalues are in the csr table. purpose
      is to examine jenner, thus pvalues are produced even though
      this does not make sense in a table 1 like this
 [3]  31oct2026    Doc Kien   the csr table displays n for each factor,
      some factors have summary stats and categorical stats, in this case n
      is not repeated. they dont display the number missing
 [4]  31oct2026    Doc Kien   the csr table gives all continuous vars the
      same precision, this may not make sense although it seems standard
      these days. also, min, max and mostly median are actual values
      and should be presented as such
 [5]  31oct2026   Doc Kien    the csr table doesnt display mean (sd).
      do it the standard way though
 [6]  31oct2026, they used ancova and pearson, i will use kruskall wallis
      and pearson. i checked ancova p-values, see checks.sas

*/

/*********************************************************************/
/*                      Beginning of Code                            */
/*********************************************************************/

*get stats for continuous vars;
proc sort data=der.demog out=demog;
  by trtn;
run;

*for geom means and cv;
*ods graphics off; /*suppress unwanted plots*/
*ods output statistics=stats1;* (rename=(variable=varname geommean=gm cv=cv_));
*proc ttest data=demog dist=lognormal;
*  var alt ast;
*  by trtn;
*run;
*
*data der.stats1;
*  set stats1;
*  *cv=100*cv_;
*  *keep varname trtn gm cv;
*run;
*need to check it is giving correct cv;
*need stats for both vars in the ods, need the same var names that sas uses;

*for arithmetic means and std dev;
ods output basicmeasures=stats2 (where=(locmeasure in ('Mean')))
           quantiles=qrtls
           moments=ns (where=(label1 in ('N')));
proc univariate data=demog;
  var age durdis bmibl weightbl heightbl mmsetot educlvl;
  by trtn;
run;

proc sort data=qrtls;
   by trtn varname;
run;

*min and max;
proc transpose data=qrtls (where=(quantile in ('0% Min','100% Max')))
                out=qrtls_t1 (drop=_name_ _label_);
   var estimate;
   by trtn varname;
   id quantile;
run;

*quartiles;
proc transpose data=qrtls (where=(quantile in ('25% Q1','50% Median','75% Q3')))
                out=qrtls_t2 (drop=_name_ _label_);
   var estimate;
   by trtn varname;
   id quantile;
run;

*put all together (statn_ is used for sorting below when creating dataset for proc report);
data der.contstats;
  format statxt $50. varname $50. statn_ 4.1 statmp stat $100.;
  set ns        (in=a)
      qrtls_t1  (in=b)
      stats2    (in=c)
      qrtls_t2  (in=d);
  if a then do;
    statn_=0.1;
    statxt='N';
    statmp=put(nvalue1,5.);
  end;
  else if b then do;
    statn_=0.2;
    statxt='Min, Max';
    statmp=compbl(put(_0__Min,6.1)||', '||put(_100__Max,6.1));
  end;
  else if c then do;
    statn_=0.3;
    statxt='Mean (SD)';
    statmp=compbl(put(locvalue,6.1)||' ('||put(varvalue,6.1)||')');
  end;
  else if d then do;
    statn_=0.4;
    statxt='Median (Q1,Q3)';
    statmp=compbl(put(_50__Median,6.1)||' ('||put(_25__Q1,6.1)||','||put(_75__Q3,6.1)||')');
  end;
*remove unwanted space;
  stat=tranwrd(statmp,'( ','(');
  keep trtn varname statn_ statxt stat;
run;

*transpose to make trts columns;
proc sort data=der.contstats;
  by varname statn_ statxt;
run;

proc transpose data=der.contstats out=der.contstats_t (drop=_name_) prefix=trt;
  var stat;
  id trtn;
  by varname statn_ statxt;
run;

*pvals for contin vars;
ods output KruskalWallisTest=kwpval (rename=(variable=varname));
proc npar1way data=der.demog wilcoxon plots=none;
  class trtn ;
  var age durdis bmibl weightbl heightbl mmsetot educlvl;
quit;

data der.kwpval;
  format varname $50.;
  set kwpval;
  pval=put(prob,pvalue6.4);
  keep varname pval;
run;

proc sort data=der.kwpval;
  by varname;
run;

*merge p-values on;
data der.contstats_t2;
  merge der.contstats_t der.kwpval;
  by varname;
run;

*get stats: categorical vars ;
ods output crosstabfreqs=der.freqs (where=(_type_ in ('11','10')));
proc freq data=der.demog;
  tables trtn*sexc trtn*agec trtn*bmic trtn*racec trtn*durdisc / nocol nocum missprint;
run;

data der.catstats;
  format statxt $50. stat $100.;
  set der.freqs ;
  varname=substr(table,14);
  if _type_='11' then do;
    stat=put(frequency,5.)||' ('||put(rowpercent,5.1)||'%)';
    statxt=left(sexc||agec||bmic||racec||durdisc);
    statn_=0.2;
  end;
  else if _type_='10' then do;
    stat=put(frequency,5.);
    statxt='N';
    statn_=0.1;
  end;
  keep varname statn_ statxt stat trtn frequency rowpercent;
run;

*transpose to make cats columns;
proc sort data=der.catstats;
  by varname statn_ statxt;
run;

proc transpose data=der.catstats out=der.catstats_t (drop=_name_) prefix=trt;
  var stat;
  id trtn;
  by varname statn_ statxt;
run;

*get p-values;
ods output chisq=chisq;
proc freq data=der.demog (where=(trtn ne 100));
   tables trtn*sexc trtn*agec trtn*bmic trtn*racec trtn*durdisc/ chisq;
run;

data der.chisq;
  format varname $50.;
  set chisq;
  varname=substr(table,14);
  pval=put(prob,pvalue6.4);
  if statistic=:'Chi' then output;
  keep varname pval;
run;

proc sort data=der.chisq;
  by varname;
run;
*bmi pvalue differs, probably because of the way the missings have been handled-yes, they 
 put missings in the lowest cat;

proc sort data=der.chisq;
  by varname;
run;

*merge p-values onto stats;
data der.catstats_t2;
  merge der.catstats_t der.chisq;
  by varname;
run;


/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
