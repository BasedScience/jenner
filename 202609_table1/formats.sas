/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
+ Project          : standard table 1 for papers. for illustration and test jenner
+ Program name     : formats.sas
+ Location         : /home/dockien/Desktop/jenner/2026_table1
+ Description      : define formats used to create char versions of vars

* Type             : SAS program
* Output type      : na

+ Program responsible : Doc Kien
+ Date of creation    : 10-Oct-2026

* Interaction         : formats are applied in derive_demog.sas

* Input files  : na
* Output files : na

+ Developed under : LINUX Jenner v1.5.110

Comments:
 [#]  Date         Author    Comment
 ---  -----------  --------  -----------

*/

/*********************************************************************/
/*                      begin formats */
/*********************************************************************/

proc format;
*patient sex;
  value $sex_f
    'M' = 'Male'
    'F' = 'Female';
*age groups;
  value age_f
    1='<65 yrs'
    2='65-80 yrs'
    3='>80 yrs';
*bmi groups;
  value bmi_f
    1='<25'
    2='25-<30'
    3='>=30';
*duration of disease;
  value durdis_f
    1='<12 months'
    2='>=12 months';
*new race cats;
  value race_f
    1='Caucasian'
    2='African descent'
    3='Hispanic'
    4='Other';
run;

/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
