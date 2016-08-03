@echo off

set CUR_PATH=%~dp0
set BUSYBOX_EXE=%CUR_PATH%\toolkit\win32\busybox.exe

%BUSYBOX_EXE% rm -rf %CUR_PATH%\ap-log\
%BUSYBOX_EXE% rm -rf %CUR_PATH%\tz-log\

%BUSYBOX_EXE% find %CUR_PATH% -type f ^
! -name "ramparser_msm8996.bat" ^
! -name "ramparser_msm8992.bat" ^
! -name "ramparser_msm8974.bat" ^
! -name "ramparser_msm8939.bat" ^
! -name "ramparser_clean.bat" ^
! -name "rampdump.exe" ^
-maxdepth 1  -delete