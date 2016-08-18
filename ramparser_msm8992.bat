@echo off

set CUR_PATH=%~dp0
cd %CUR_PATH%
for /f "delims=" %%i in (' cd ') do (set CUR_PATH=%%i)

set PYTHON_EXE=%CUR_PATH%\toolkit\python\python.exe
set RAMPARSER_EXE=%CUR_PATH%\toolkit\ramparser\ramparse.py
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
echo %LINUX_VER% > %CUR_PATH%\linux_version.txt

:: Kernel 
%CURL_EXE% --data-urlencode "version=%LINUX_VER%" %FIND_CGI% 2>nul | %BUSYBOX_EXE% grep "kernel symbols" -A 1 | %BUSYBOX_EXE% tail -1 | ^
%BUSYBOX_EXE% sed "s/smb:\/\//\\\\/g" | %BUSYBOX_EXE% sed "s/\//\\/g" | clip.exe
for /f "delims=" %%i in (' %PASTE_EXE% ') do (set SMB_PATH=%%i)
echo %SMB_PATH%
if not exist %CUR_PATH%\vmlinux (
	copy /y %SMB_PATH%\vmlinux %CUR_PATH%\vmlinux
)



::Start parse
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
	--force-hardware 8992 ^
	--outdir %CUR_PATH%\ap-log\ ^
	--ram-file ./OCIMEM.BIN 0xFE800000 0xFE80FFFF ^
	--ram-file ./DDRCS0_0.BIN 0x00000000 0x2FFFFFFF ^
	--ram-file ./DDRCS0_1.BIN 0x80000000 0xAFFFFFFF ^
	--ram-file ./DDRCS1_0.BIN 0x30000000 0x5FFFFFFF ^
	--ram-file ./DDRCS1_1.BIN 0xB0000000 0xDFFFFFFF
:: 3g	--ram-file ./DDRCS0_0.BIN 0x00000000 0x2FFFFFFF ^
:: 3g	--ram-file ./DDRCS0_1.BIN 0x80000000 0xAFFFFFFF ^
:: 3g	--ram-file ./DDRCS1_0.BIN 0x30000000 0x5FFFFFFF ^
:: 3g	--ram-file ./DDRCS1_1.BIN 0xB0000000 0xDFFFFFFF
:: 2g	--ram-file ./DDRCS0_0.BIN 0x00000000 0x1FFFFFFF ^
:: 2g	--ram-file ./DDRCS0_1.BIN 0x40000000 0x5FFFFFFF ^
:: 2g	--ram-file ./DDRCS1_0.BIN 0x20000000 0x3FFFFFFF ^
:: 2g	--ram-file ./DDRCS1_1.BIN 0x60000000 0x7FFFFFFF
:: 2gB	--ram-file ./DDRCS0_0.BIN 0x00000000 0x3FFFFFFF ^
:: 2gB	--ram-file ./DDRCS0_1.BIN 0x40000000 0x7FFFFFFF

pause