/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
+ Project          : standard table 1 for papers. for illustration and test jenner
+ Program name     : inspect_data.sas
+ Location         : /home/dockien/Desktop/jenner/2026_table1
+ Description      : check contents and formats, should be adam

* Type             : Jenner program (sas compatible code)
* Output type      : na

+ Program responsible : Doc Kien
+ Date of creation    : 10-Oct-2026

* Interaction         : none

* Input files  : raw.adsl, advs
* Output files : na

+ Developed under : LINUX Jenner v1.5.97

Comments:
 [#]  Date         Author     Comment
 ---  -----------  --------   -----------

*/

/*********************************************************************/
/*                      begin  */
/*********************************************************************/

*check datasets available;
proc datasets library=raw;
quit;
*there is no med hist (admh) or conmeds (adcm), there are a couple lab datasets (lb);

proc contents data=raw.adsl out=der.contents;
run;
*from var list, note: use ittfl flag;

*check n;
proc freq data=raw.adsl;
  tables ittfl*trt01a / list;
run;

*check number missing;
proc means data=raw.advs n nmiss;
  where paramcd='SYSBP';
  var aval;
run;
*4 missing, make sure this appears in the summary table;


/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
