/* 
Copyright (c) 2026 Doc Kien
   Licensed under the MIT License.
*/
/*
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

+ Developed under : LINUX Jenner v1.5.78

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
*age group;
  value agec_f
    1='<65 yrs'
    2='65-80 yrs'
    3='>80 yrs';
*age group;
  value race_f
    1='Caucasian'
    2='African descent'
    3='Hispanic'
    4='Other';
run;

/*********************************************************************/
/*                         End of Code                               */
/*********************************************************************/
