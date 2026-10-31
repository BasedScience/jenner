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
* Output type      : datasets: contstats_t, catstats_t

+ Program responsible : Doc Kien
+ Date of creation    : 24-Oct-2026

* Interaction         : uses output from derive_data.sas

* Input files  : der.demog (this is fas, see derive_demog.sas)
* Output files : 

+ Developed under : LINUX Jenner v1.5.110

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

*/

/*********************************************************************/
/*                      Beginning of Code                            */
/*********************************************************************/

*get stats for continuous vars;
proc sort data=der.demog out=demog;
  by trtn;
run;

ods output basicmeasures=stats (where=(locmeasure in ('Mean')))
           quantiles=qrtls
           moments=ns (where=(label1 in ('N')));
proc univariate data=demog;
  var age trtdur bmibl weightbl heightbl mmsetot educlvl;
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
       stats     (in=c)
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

*get stats: categorical vars ;
ods output crosstabfreqs=der.freqs (where=(_type_ in ('11','10')));
proc freq data=der.demog;
  tables trtn*sexc trtn*agec trtn*bmic trtn*racec trtn*durdisc / nocol nocum missprint;
run;

data der.catstats;
  format statxt $50. stat label $100.;
  set der.freqs ;
  varname=substr(table,14);
       if varname='sexc'    then label='Sex';
  else if varname='agec'    then label='Age (years)';
  else if varname='bmic'    then label='BMI (kg/m2)';
  else if varname='racec'   then label='Race';
  else if varname='durdisc' then label='Duration of disease';
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
  keep varname label statxt stat trtn frequency rowpercent;
run;

*transpose to make cats columns;
proc sort data=der.catstats;
  by varname label statxt;
run;

proc transpose data=der.catstats out=der.catstats_t (drop=_name_) prefix=trt;
  var stat;
  id trtn;
  by varname label statn_ statxt;
run;

/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
