@ECHO OFF

REM Last time modified: 30.11.2021

SETLOCAL EnableExtensions EnableDelayedExpansion

SET "PSVersionRequired=4"
SET "ReportsDir=%USERPROFILE%\DCPT-Reports"

IF "%~1"=="" GOTO Syntax
IF "%~1"=="/?" GOTO Syntax
IF "%~1"=="-h" GOTO Syntax
IF "%~1"=="--help" GOTO Syntax

powershell.exe /? >NUL 2>NUL || (
    ECHO Error: PowerShell cannot be found.
    ECHO Please install PowerShell %PSVersionRequired% and run this program again.
    ENDLOCAL
    PAUSE
    EXIT /B 1
)

FOR /F "usebackq" %%A IN (`powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Write-Host $PSVersionTable.PSVersion}"`) DO (
    SET "UserPSVersion=%%A"
)

SET "UserPSVersionMajor=%UserPSVersion:~0,1%"

IF %UserPSVersionMajor% LSS %PSVersionRequired% (
    ECHO Error: PowerShell %UserPSVersionMajor% is installed, but PowerShell %PSVersionRequired% is required.
    ECHO Please install PowerShell %PSVersionRequired% and run this program again.
    ENDLOCAL
    PAUSE
    EXIT /B 1
)

IF "%~1"=="--ps-version" GOTO HandlePSVersion

SET "ScriptName=scripts\init.ps1"
SET "ScriptFullName=%~dp0%ScriptName%"

IF NOT EXIST "%ScriptFullName%" (
    ECHO Error: The script to run cannot be found: %ScriptFullName%
    ENDLOCAL
    PAUSE
    EXIT /B 1
)

SET "InputItem=%~f1"

IF NOT EXIST "%InputItem%" (
    ECHO Error: Input item cannot be found: %InputItem%
    ENDLOCAL
    PAUSE
    EXIT /B 1
)

IF EXIST "%InputItem%" (
    SET "InputItemType=File"
)

IF EXIST "%InputItem%\" (
    SET "InputItemType=Folder"
)

IF "%InputItemType%"=="File" GOTO HandleFile

IF "%InputItemType%"=="Folder" GOTO HandleFolder

GOTO Finalization



:HandleFile

IF NOT "%~x1"==".exe" (
    ECHO Error: Input item must be an EXE file.
    ENDLOCAL
    PAUSE
    EXIT /B 1
)

ECHO [%~n0] Mode: Single file

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ScriptFullName%" "%InputItem%"

GOTO Finalization



:HandleFolder

FOR /F "usebackq" %%A IN (`DIR /A-D /B "%InputItem%\*.exe" 2^>NUL ^| FIND /C /V ""`) DO (
    SET "ExeFilesCount=%%A"
)

IF %ExeFilesCount%==0 (
    ECHO Error: No EXE files found in %InputItem%
    ENDLOCAL
    PAUSE
    EXIT /B 1
)

ECHO [%~n0] Mode: Batch processing

PUSHD "%InputItem%\"

FOR %%A IN (*.exe) DO (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ScriptFullName%" "%%~fA"
)

POPD

GOTO Finalization



:HandlePSVersion

ECHO PowerShell version: %UserPSVersion%

GOTO Finalization


:Syntax

ECHO %~n0
ECHO:
ECHO DESCRIPTION
ECHO   Performs basic tests on passed arguments and runs DCPT.
ECHO:
ECHO USAGE
ECHO   %~nx0 file
ECHO   %~nx0 folder
ECHO   %~nx0 /?^|-h^|--help
ECHO   %~nx0 --ps-version
ECHO:
ECHO REQUIREMENTS
ECHO   PowerShell 4 (or higher)

GOTO Finalization


:Finalization

CHOICE /C YN /N /T 5 /D N /M "Do you want to open the directory with reports? (Y/N)"
IF %ERRORLEVEL% EQU 1 (
    EXPLORER /N,"%ReportsDir%"
)

ENDLOCAL
PAUSE
EXIT /B
