/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
+ Project          : standard table 1 for papers, illustration
+ Program name     : derive_demog.sas
+ Location         : /home/dockien/Desktop/jenner/2026_table1
+ Description      : collect relevant vars, derive categorical vars, select analysis popn,
                       add total group

* Type             : Jenner program (sas compatible code)
* Output type      : dataset

+ Programmer responsible : Doc Kien
+ Date of creation    : 20-Oct-2026

* Interaction         : uses formats defined in formats.sas

* Input files  : adsl, advs
* Output files : der.demog

+ Developed under : LINUX Jenner v1.5.97

Comments :
 [#]  Date         Author     Comment
 ---  -----------  --------   -----------
 [1]  12oct2026    Doc Kien   data source:
 https://github.com/elong0527/r4csr/tree/main/data-adam
 want to reproduce csr table 14-2.01 for itt pop: Summary of Demographic and Baseline Characteristics

*/

/*********************************************************************/
/*                      Beginning of Code                            */
/*********************************************************************/

*collect relevant demog vars and derive required cat vars;
data der.adsl;
  set raw.adsl;
*derive sex;
  sexf=put(sex,$sex_f.);
*age cats;
  if age ne . then do;
    if age lt 65 then agen=1;
    else if age le 80 then agen=2;
    else if age gt 80 then agen=3;
  end;
  agec=put(agen,age_f.);
*bmi cats;
  if bmibl ne . then do;
    if bmibl lt 25 then bmin=1;
    else if bmibl lt 30 then bmin=2;
    else bmin=3;
  end;
  bmic=put(bmin,bmi_f.);
*duration of disease
 -this is already available in the dataset, i derive it to check it;
  if durdis ne . then do;
    if durdis lt 12 then durdisn=1;
    else durdisn=2;
  end;
  durdisc=put(durdisn,durdis_f.);
*new race cats;
  if lowcase(race)=:'white' and lowcase(ethnic)=:'not' then racen=1;
  else if lowcase(race)=:'black' then racen=2;
  else if lowcase(ethnic)=:'hispanic' then racen=3;
  else if race ne '' or ethnic ne '' then racen=4;
  racec=put(racen,race_f.);
*use succint var names;
  rename trt01an=trtn trt01a=trt ittfl=fasfl;
  keep usubjid trt01an trt01a ittfl
       age bmibl weightbl heightbl educlvl trtdur mmsetot
       sexf agen agec bmin bmic durdisn durdisc racen racec;
run;

*check no duplicates;
proc sort data=der.adsl nodupkey;
  by usubjid;
run;
*when there are no duplicates it doesnt indicate this in log????;

*get blood pressure;
data der.advs;
  set raw.advs;
  where paramcd in ('SYSBP','DIABP') and lowcase(atpt)=:'after lying'
    and ablfl='Y'; /*there is no anelfl flag in the dataset*/
  keep usubjid paramcd aval;
run;

*check no duplicates;
proc sort data=der.advs nodupkey;
  by usubjid paramcd;
run;

proc transpose data=der.advs out=der.advs_t (drop=_name_ _label_);
  var aval;
  id paramcd;
  by usubjid;
run;

*merge vars together and select study pop;
data slvs;
  merge der.adsl der.advs_t;
  by usubjid;
  if fasfl='Y' then output;
run;

*add total group: needed for total column in summary table;
data demog;
  set slvs (in=a) slvs;
  if a then do;
    newsubjid='T'||usubjid;
    trt='Total';
    trtn=100;
  end;
  else newsubjid=usubjid;
  drop usubjid;
run;

*put vars in sensible order using retain;
data der.demog;
  retain newsubjid;
  set demog;
run;

proc sort data=der.demog;
  by newsubjid;
run;


/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
