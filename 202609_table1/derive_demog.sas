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

* Input files  : adsl, advs, adlb
* Output files : na

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

data der.fas;
  set raw.adsl;
*derive sex;
  sexf=put(sex,$sex_f.);
*derive age cats;
  if age ne . then do;
    if age lt 65 then agen=1;
    else if age le 80 then agen=2;
    else if age gt 80 then agen=3;
  end;
  agec=put(agen,agec_f.);
*derive race;
  if lowcase(ethnic)=:'hispanic' then racen=3;
  else if lowcase(race)=:'black' then racen=2;
  else if lowcase(race)=:'white' then racen=1;
  else if race ne '' or ethnic ne '' then racen=4;
  racec=put(racen,race_f.);
  rename trt01an=trtn trt01a=trt ittfl=fasfl;
  where ittfl='Y';
  keep usubjid trt01an trt01a ittfl
       age sex bmibl weightbl heightbl educlvl trtdur mmsetot
       sexf agen agec racen racec;
run;


/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
