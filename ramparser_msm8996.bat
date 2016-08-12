@echo off

set CUR_PATH=%~dp0

set PYTHON_EXE=%CUR_PATH%\toolkit\python\python.exe
set RAMPARSER_EXE=%CUR_PATH%\toolkit\ramparser_8996\ramparse.py
set TZPARSER_EXE=%CUR_PATH%\toolkit\tz\tz_diag_parser_msm8996.py
set NM_EXE=%CUR_PATH%\toolkit\toolchains\aarch64-linux-gnu-nm.exe
set GDB_EXE=%CUR_PATH%\toolkit\toolchains\aarch64-linux-gnu-gdb.exe
set BUSYBOX_EXE=%CUR_PATH%\toolkit\win32\busybox.exe
set PASTE_EXE=%CUR_PATH%\toolkit\win32\paste.exe
set CURL_EXE=%CUR_PATH%\toolkit\win32\curl.exe

set FIND_CGI=http://172.16.2.18/cgi-bin/vmlinux-lookup.cgi

:: Linux version
%BUSYBOX_EXE% dd if=%CUR_PATH%\DDRCS0.BIN bs=20M count=1 2>nul | %BUSYBOX_EXE% strings | %BUSYBOX_EXE% grep "Linux version" | %BUSYBOX_EXE% head -n 1 | clip.exe
for /f "delims=" %%i in (' %PASTE_EXE% ') do (set LINUX_VER=%%i)
echo %LINUX_VER%

:: Kernel 
%CURL_EXE% --data-urlencode "version=%LINUX_VER%" %FIND_CGI% 2>nul | %BUSYBOX_EXE% grep "kernel symbols" -A 1 | %BUSYBOX_EXE% tail -1 | ^
%BUSYBOX_EXE% sed "s/smb:\/\//\\\\/g" | %BUSYBOX_EXE% sed "s/\//\\/g" | clip.exe
for /f "delims=" %%i in (' %PASTE_EXE% ') do (set SMB_PATH=%%i)
echo %SMB_PATH%
if not exist %CUR_PATH%\vmlinux (
	copy /y %SMB_PATH%\vmlinux %CUR_PATH%\vmlinux
)

:: OEM
%CURL_EXE% --data-urlencode "version=%LINUX_VER%" %FIND_CGI% 2>nul | %BUSYBOX_EXE% grep "OEM symbols" -A 1 | %BUSYBOX_EXE% tail -1 | ^
%BUSYBOX_EXE% sed "s/smb:\/\//\\\\/g" | %BUSYBOX_EXE% sed "s/\//\\/g" | clip.exe
for /f "delims=" %%i in (' %PASTE_EXE% ') do (set SMB_PATH=%%i)
echo %SMB_PATH%
copy /y %SMB_PATH%\trustzone_images\core\securemsm\trustzone\qsee\qsee.elf %CUR_PATH%\tzelf
copy /y %SMB_PATH%\rpm_proc\core\bsp\rpm\build\RPM_AAAAANAAR.elf %CUR_PATH%\rpmelf


::Start parse
echo msm8996 ram parser Linux start
%BUSYBOX_EXE% rm -rf %CUR_PATH%\ap-log
%BUSYBOX_EXE% mkdir %CUR_PATH%\ap-log
%BUSYBOX_EXE% rm -rf %CUR_PATH%\tz-log
%BUSYBOX_EXE% mkdir %CUR_PATH%\tz-log

%PYTHON_EXE% %RAMPARSER_EXE% ^
	--nm-path %NM_EXE% ^
	--gdb-path %GDB_EXE%^
	--vmlinux %CUR_PATH%\vmlinux ^
	-a %CUR_PATH% ^
	-x --64-bit ^
	--ipc-skip ^
	--force-hardware 8996 ^
	--outdir %CUR_PATH%\ap-log

%PYTHON_EXE% %TZPARSER_EXE% OCIMEM.BIN DDRCS0.BIN PIMEM.BIN > %CUR_PATH%\tz-log\tz_log.txt
pause