The files in this folder are partly identical with files in the parent directory,
and based on work by Martin and Amrita.

The folder contains Amrita's final modifications for ADC characterization,
but needs consolidation with the main files and some fixes.

These are the file dates as of 2011-04-05, the date of the original SVN checkin:

total 172
-rwxr-xr-x 1 user user 12456 2010-06-15 16:23 read_fmd_complete.m
-rw-r--r-- 1 user user  1607 2010-06-17 16:29 read_matsettings.m
-rw-r--r-- 1 user user  2804 2010-07-14 15:29 createhtml_ADC.m
-rw-r--r-- 1 user user    59 2010-08-09 14:05 dac.m
-rw-r--r-- 1 user user 28135 2010-08-13 15:49 ADC_char.m
-rw-r--r-- 1 user user  1859 2010-08-17 14:24 adcnoise.m
-rw-r--r-- 1 user user 27742 2010-08-18 16:43 ADC_char_mod.m
-rw-r--r-- 1 user user 13881 2010-08-20 19:58 ADC_char_mod_mk1.m
-rw-r--r-- 1 user user   414 2010-09-30 18:37 filenamestr.mat
-rw-r--r-- 1 user user  3892 2010-10-01 17:44 DACperuVcalc.m
-rw-r--r-- 1 user user  5968 2010-10-22 15:44 DAC_char_mod.m
-rw-r--r-- 1 user user  7965 2010-11-19 17:49 DAC_char_mod1.m
-rw-r--r-- 1 user user 14123 2010-12-22 14:37 DAC_char_mod2.m
-rw-r--r-- 1 user user 19094 2010-12-22 17:28 DAC_char_mod3.m
drwxr-xr-x 8 user user  4096 2011-04-05 17:36 ..
drwxr-xr-x 2 user user  4096 2011-04-05 17:37 .
-rw-r--r-- 1 user user     0 2011-04-05 17:37 README.txt

2011-10-21
moved all solely ADC related files from scriptmeas/

-rw-r--r-- 1 user user  2273 2010-08-03 10:56 adctest.m
-rw-r--r-- 1 user user   779 2010-10-29 18:38 dactest.m
-rw-r--r-- 1 user user 17802 2010-07-28 13:29 meas_adcchar.m
-rw-r--r-- 1 user user 18410 2010-08-13 15:46 meas_adcchar_mod.m
-rw-r--r-- 1 user user 18821 2010-08-10 15:02 meas_adcchar_monitor.m
-rw-r--r-- 1 user user  4294 2010-12-13 12:26 meas_adctovolts_dac_AL1.m
-rw-r--r-- 1 user user  4154 2010-08-20 12:30 meas_adctovolts_dac.m
-rw-r--r-- 1 user user  4017 2010-08-10 15:11 meas_adctovolts.m
-rw-r--r-- 1 user user 19887 2010-12-22 16:20 meas_dacchar_mod1.m
-rw-r--r-- 1 user user 18653 2010-11-19 17:38 meas_dacchar_mod.m
-rw-r--r-- 1 user user 20605 2010-08-25 14:25 meas_dacchar_monitor1.m
-rw-r--r-- 1 user user 22299 2010-12-22 16:48 meas_dacchar_monitor2.m
-rw-r--r-- 1 user user 20228 2010-08-18 17:05 meas_dacchar_monitor.m
-rw-r--r-- 1 user user  5246 2011-04-05 17:51 README.txt

into
scriptmeas/ADC_Analysis/scriptmeas_root/

Also moved the ADC-related power control scripts into
scriptmeas/ADC_Analysis/scriptmeas_root/ :
-rwxr-xr-x 1 user user 1557 2010-09-20 11:01 powersupply_BK9130_ADC5V.sh
-rwxr-xr-x 1 user user 1519 2010-09-20 11:15 powersupply_BK9130_ADC12V.sh
-rwxr-xr-x 1 user user 1651 2010-11-29 13:27 powersupply_BK9130_adcchar.sh
-rwxr-xr-x 1 user user 3338 2010-12-22 14:06 powersupply_2636A.sh
leaving the following non-ADC-related scripts in scriptmeas/ :
-rwxr-xr-x 1 user user 1281 2010-05-26 10:26 powersupply_BK9130_array12V.sh
-rwxr-xr-x 1 user user 1460 2010-06-03 10:17 powersupply_BK9130_arraySweep.sh
-rwxr-xr-x 1 user user 1279 2010-05-26 10:26 powersupply_BK9130_PSI24V.sh
-rwxr-xr-x 1 user user 1639 2011-03-30 11:05 powersupply_BK9130_PSI24and5V.sh

