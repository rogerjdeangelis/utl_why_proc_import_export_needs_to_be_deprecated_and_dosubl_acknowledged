Why proc import export needs to be deprecated and dosubl acknowledged

see github
https://tinyurl.com/yda2ynqx
https://github.com/rogerjdeangelis/utl_why_proc_import_export_needs_to_be_deprecated_and_dosubl_acknowledged

Problem: Merge six sheets in two workbooks

SOAPBOX ON;
Proc import EG code is a travesty. Massive support for EG import/export
while classic SAS wanes.
SOAPBOX OFF;

    TWO RESONABLE SOLUTIONS?
       1. SQL
       2. Datastep with checking (dosubls)

INPUT
=====

 Sheets and named ranges (can use either named range ot sheet ame)

  Workbook: d:/xls/bcobs.xlsx, sheets= data other sups
  Workbook: d:/xls/hlobs.xlsx, sheets= data other sups

EXAMPLE OUTPUT
---------------

 WORK.LOG total obs=7

  WORKBOOKS    SHEETS    RC        STATUS

     bc        data       0    Sort Completed
     bc        other      0    Sort Completed
     bc        sips       0    Sort Completed
     hl        data       0    Sort Completed
     hl        other      0    Sort Completed
     hl        sips       0    Sort Completed

     hl        All        0    Merge Completed


PROCESS
=======

 1  SQL
 ------

  libname bc 'd:/xls/bcobs.xlsx';
  libname hl 'd:/xls/hlobs.xlsx';

  * assumed an inner join;
  * all the code;

  proc sql;
    create
      table hhobs as
    select
      *
    from
      bc.data a, bc.other b, bc.sips c, hl.data d, hl.other e, hl.sips f
    where
      a.siteid  =  b.siteid and
      a.siteid  =  c.siteid and
      a.siteid  =  d.siteid and
      a.siteid  =  e.siteid and
      a.siteid  =  f.siteid
  ;quit;


 2. Datastep with checking (dosubls)
 ===================================

 libname bc 'd:/xls/bcobs.xlsx';
 libname hl 'd:/xls/bcobs.xlsx';

 data log;

   do workbooks="bc","hl";
      do sheets="data  ","other","sips";

         call symputx("wkb",workbooks);
         call symputx("sht",sheets);

         rc=dosubl('
            proc sort data=&wkb..&sht out=work.&wkb.&sht;
              by siteid;
            run;quit;
            %let status=&sysrc;
         ');

         if rc=0 and "&status"="0" then status="Sort Completed ";
         else status="Sort Failed";
         output;
      end;
   end;

   rc=dosubl('
     data hbobs;
       merge bc: hl:;
     by siteID;
     run;quit;
     %let status=&sysrc;
   ');

    sheets="All";
    if rc=0 and "&status"="0" then status="Merge Completed";
    else status="Merge Failed";
    output;

    stop;
 run;quit;

 libname bc clear;
 libname hl clear;

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

 %utlfkil(d:/xls/bcobs.xlsx);  * just in case;
 %utlfkil(d:/xls/hlobs.xlsx);  * just in case;

 libname bc 'd:/xls/bcobs.xlsx';
 libname hl 'd:/xls/hlobs.xlsx';

 * note this creates new shaeet names and named ranges;
 * if you do not have named ranges use then form "data$"n.

 data bc.other bc.data bc.sips hl.other hl.data hl.sips;
      set sashelp.class(rename=name=siteid);
 run;quit;

 libname bc clear;
 libname hl clear;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process


