@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges... 
goto request
) else (goto init)

:request
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /b

:init
echo ***************************************************
echo *                                                 *
echo *                  免责声明                       *
echo *                                                 *
echo *  使用本脚本修改bios导致损坏的，需自行承担后果。 *
echo *                                                 *
echo *           支持转载，但请注明出处                *
echo *                                                 *
echo ***************************************************
pause
pushd %~dp0
echo.
echo 正在初始化备份工作……
echo.
WDFInst.exe
if exist Backup/SaSetup_Original.txt (
	echo 已存在 SaSetup 备份文件
) else H2OUVE-W-CONSOLEx64.exe -gv Backup/SaSetup_Original.txt -n SaSetup

if exist Backup/PchSetup_Original.txt (
	echo 已存在 PchSetup 备份文件
) else H2OUVE-W-CONSOLEx64.exe -gv Backup/PchSetup_Original.txt -n PchSetup

if exist Backup/CpuSetup_Original.txt (
	echo 已存在CpuSetup备份文件
) else H2OUVE-W-CONSOLEx64.exe -gv Backup/CpuSetup_Original.txt -n CpuSetup

echo.
goto start 

:SetKernelDebugSerialPort
pushd %~dp0
WDFInst.exe
H2OUVE-W-CONSOLEx64.exe -gv SetKernelDebugSerialPort_Original.txt -n PchSetup
for /f "tokens=1,10" %%i in (SetKernelDebugSerialPort_Original.txt) do if %%i==00000000: (
	if %%j == 00 ( 
		echo Kernel Debug Serial Port模式已经修改，无需再修改
		del SetKernelDebugSerialPort_Original.txt
		pause
		goto start		
	)
)
if exist "SetKernelDebugSerialPort.txt" (
    echo 正在写入……
	H2OUVE-W-CONSOLEx64.exe -sv SetKernelDebugSerialPort.txt -n PchSetup
) else (
    if exist "SetKernelDebugSerialPort_Original.txt" (
		powershell -Command "(gc SetKernelDebugSerialPort_Original.txt) -replace '00000000: (.{23}) 03 (.*)', '00000000: $1 00 $2' | Out-File SetKernelDebugSerialPort.txt -Encoding ASCII"
		echo 正在写入……
		H2OUVE-W-CONSOLEx64.exe -sv SetKernelDebugSerialPort.txt -n PchSetup
		del SetKernelDebugSerialPort_Original.txt
		del SetKernelDebugSerialPort.txt
	) else (
		echo 无法找到 SetKernelDebugSerialPort_Original.txt
	)
)
echo.
pause
goto start

:SetGPIO
pushd %~dp0
WDFInst.exe
H2OUVE-W-CONSOLEx64.exe -gv SetGPIO_Original.txt -n PchSetup
for /f "tokens=1,10" %%i in (SetGPIO_Original.txt) do if %%i==00000010: (
	if %%j == 01 ( 
		echo GPIO中断模式已开启，无需修改
		del SetGPIO_Original.txt
		pause
		goto start		
	)
)
if exist "SetGPIO.txt" (
    echo 正在写入……
	H2OUVE-W-CONSOLEx64.exe -sv SetGPIO.txt -n PchSetup
) else (
    if exist "SetGPIO_Original.txt" (
		powershell -Command "(gc SetGPIO_Original.txt) -replace '00000010: (.{23}) 00 (.*)', '00000010: $1 01 $2' | Out-File SetGPIO.txt -Encoding ASCII"
		echo 正在写入……
		H2OUVE-W-CONSOLEx64.exe -sv SetGPIO.txt -n PchSetup
		del SetGPIO_Original.txt
		del SetGPIO.txt
	) else (
		echo 无法找到 SetGPIO_Original.txt
	)
)
echo.
pause
goto start

:BiosLock
pushd %~dp0
WDFInst.exe
H2OUVE-W-CONSOLEx64.exe -gv BiosLock_Original.txt -n PchSetup
for /f "tokens=1,9" %%i in (BiosLock_Original.txt) do if %%i==00000010: (
	set t1=%%j )
for /f "tokens=1,3" %%m in (BiosLock_Original.txt) do if %%m==000006D0: (
	set t2=%%n )

if %t1% == 00 (
	if %t2% == 00 (
		echo BIOS烧写已解锁，不需要修改
		del BiosLock_Original.txt
		pause
		goto start )
)
if exist "BiosLock.txt" (
    echo 正在写入……
    H2OUVE-W-CONSOLEx64.exe -sv BiosLock.txt -n PchSetup
) else (
    if exist "BiosLock_Original.txt" (
		powershell -Command "(gc BiosLock_Original.txt) -replace '00000010: (.{20}) 01 (.*)', '00000010: $1 00 $2' | Out-File BiosLock_Temp.txt -Encoding ASCII"
		powershell -Command "(gc BiosLock_Temp.txt) -replace '000006D0: (.{2}) 01 (.*)', '000006D0: $1 00 $2' | Out-File BiosLock.txt -Encoding ASCII"		
		echo 正在写入……
		H2OUVE-W-CONSOLEx64.exe -sv BiosLock.txt -n PchSetup
		del BiosLock_Temp.txt
		del BiosLock_Original.txt
		del BiosLock.txt
	) else (
		echo 无法找到 BiosLock_Original.txt
	)
)
echo.
pause
goto ex

:CfgLock
pushd %~dp0
WDFInst.exe
H2OUVE-W-CONSOLEx64.exe -gv CfgLock_Original.txt -n CpuSetup
for /f "tokens=1,16" %%i in (CfgLock_Original.txt) do if %%i==00000030: (
	if %%j == 00 ( 
		echo CFG Lock已解锁，不需要修改
		del CfgLock_Original.txt
		pause
		goto start		
	)
)
if exist "CfgLock.txt" (
    echo 正在写入……
    H2OUVE-W-CONSOLEx64.exe -sv CfgLock.txt -n CpuSetup
) else (
    if exist "CfgLock_Original.txt" (
		powershell -Command "(gc CfgLock_Original.txt) -replace '00000030: (.{41}) 01 (.*)', '00000030: $1 00 $2' | Out-File CfgLock.txt -Encoding ASCII"
		echo 正在写入……
		H2OUVE-W-CONSOLEx64.exe -sv CfgLock.txt -n CpuSetup
		del CfgLock.txt
		del CfgLock_Original.txt
	) else (
		echo 无法找到 CfgLock_Original.txt
	)
)
echo.
pause
goto start

:SetDvmt
pushd %~dp0
WDFInst.exe
H2OUVE-W-CONSOLEx64.exe -gv SetDvmt_Original.txt -n SaSetup
for /f "tokens=1,9" %%i in (SetDvmt_Original.txt) do if %%i==00000100: (
	if %%j == 02 ( 
		echo DVMT Pre-Allocated已为64M，不需要修改
		del SetDvmt_Original.txt
		pause
		goto start		
	)
)
if exist "SetDvmt.txt" (
    echo 正在写入……
    H2OUVE-W-CONSOLEx64.exe -sv SetDvmt.txt -n SaSetup
) else (
    if exist "SetDvmt_Original.txt" (
		powershell -Command "(gc SetDvmt_Original.txt) -replace '00000100: (.{20}) 01 (.*)', '00000100: $1 02 $2' | Out-File SetDvmt.txt -Encoding ASCII"
		echo 正在写入……
		H2OUVE-W-CONSOLEx64.exe -sv SetDvmt.txt -n SaSetup
		del SetDvmt_Original.txt
		del SetDvmt.txt
	) else (
		echo 无法找到 SetDvmt_Original.txt
	)
)
echo.
pause
goto start

:CloseThunderboltSecure
pushd %~dp0
WDFInst.exe
H2OUVE-W-CONSOLEx64.exe -gv CloseThunderboltSecure_Original.txt -n Setup
for /f "tokens=1,10" %%i in (CloseThunderboltSecure_Original.txt) do if %%i==00000500: (
	if %%j == 00 ( 
		echo Security Level已为禁用，不需要修改
		del CloseThunderboltSecure_Original.txt
		pause
		goto start		
	)
)
if exist "CloseThunderboltSecure.txt" (
    echo 正在写入……
    H2OUVE-W-CONSOLEx64.exe -sv CloseThunderboltSecure.txt -n Setup
) else (
    if exist "CloseThunderboltSecure_Original.txt" (
		powershell -Command "(gc CloseThunderboltSecure_Original.txt) -replace '00000500: (.{23}) 01 (.*)', '00000500: $1 00 $2' | Out-File CloseThunderboltSecure.txt -Encoding ASCII"
		echo 正在写入……
		H2OUVE-W-CONSOLEx64.exe -sv CloseThunderboltSecure.txt -n SaSetup
		del CloseThunderboltSecure_Original.txt
		del CloseThunderboltSecure.txt
	) else (
		echo 无法找到 CloseThunderboltSecure_Original.txt
	)
)
echo.
pause
goto start

:start
cls
title 联想拯救者Y7000系列一键修改BIOS设置_V1.0
:menu
echo.
echo =============================================================
echo.
echo                 请选择要进行的操作
echo.
echo          拯救者Y7000系列黑苹果3群：477839538
echo.
echo =============================================================
echo.
echo  1、八代处理器安装 10.15+ 必须执行
echo.
echo  2、强制加载触控板
echo.
echo  3、关闭 BIOS Lock
echo.
echo  4、关闭 CFG Lock
echo.
echo  5、修改 DVMT 为 64M
echo.
echo  6、关闭雷电安全特性
echo.
echo  0、退出
echo.

:sel
set sel=
set /p sel= 请选择:  
IF NOT "%sel%"=="" SET sel=%sel:~0,1%
if /i "%sel%"=="0" goto ex
if /i "%sel%"=="1" goto SetKernelDebugSerialPort
if /i "%sel%"=="2" goto SetGPIO
if /i "%sel%"=="3" goto BiosLock
if /i "%sel%"=="4" goto CfgLock
if /i "%sel%"=="5" goto SetDvmt
if /i "%sel%"=="6" goto CloseThunderboltSecure
echo 选择无效，请重新输入
echo.
goto sel
echo.

:ex
choice /C yn /M "Y：立即重启  N：稍后重启"
if errorlevel 2 goto end
if errorlevel 1 goto restart

:restart
%systemroot%\system32\shutdown -r -t 0

:end
echo 感谢关注
