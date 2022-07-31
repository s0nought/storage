# functions.ps1
# 
# Функции для DCPT.
# 
# Дата последнего изменения: 30.11.2021
# 
# Этот файл будет импортирован в init.ps1
# 
# Этот файл должен быть сохранён как functions.ps1 в кодировке UTF-8 с BOM
# 
# =================================================================
# !!! НЕ ИЗМЕНЯЙТЕ ЭТОТ ФАЙЛ, ЕСЛИ НЕ УВЕРЕНЫ В СВОИХ ДЕЙСТВИЯХ !!!
# =================================================================



# Формат даты и времени в сообщениях типа "лог"
$fLogDateTimeFormat = "dd.MM.yyyy HH:mm:ss"

# Содержимое отчёта
$fReportData = ""

# Разделитель ячеек в отчёте
$fReportCellDelimeter = "`|"

# Директория для сохранения отчётов
# Например: C:\Users\Admin\DCPT-Reports
$fReportDir = ("{0}\DCPT-Reports" -f $ENV:USERPROFILE)

# Расширение файла отчёта
$fReportFileExtension = ".dsv"

# Алгоритм подсчёта хэша
$fHashAlgorithm = "SHA256"



# Выводит $Message в stdout (стандартный поток вывода)
# и завершает программу с кодом 1
function Err
{
    Param (
        [string]$Message
    )

    Write-Host ("Error: {0}" -f $Message)
    exit 1
}



# Выводит $Message в stdout
function Log
{
    Param (
        [string]$Message
    )

    Write-Host ("[{0}] {1}" -f (Get-Date -Format "$fLogDateTimeFormat"), $Message)
}



# Записывает новую строку в $fReportData в формате DSV
function New-ReportLine
{
    Param (
        [string[]]$CellValues
    )

    $script:fReportData += ($CellValues -Join "$fReportCellDelimeter") + "`n"
}



# Записывает данные в файл отчёта
# Возвращает объект, который создаёт
# Если файл уже существует, то новый контент будет добавлен в конец документа
function Write-ReportFile
{
    Param (
        [string]$FileName
    )

    $FileFullName = ("{0}\{1}" -f $fReportDir, $FileName)

    [IO.File]::AppendAllLines([string]$FileFullName, [string[]]$fReportData)

    return (Get-Item -Path "$FileFullName")
}



# Проверяет, есть ли у данного файла действительная ЦП
function Test-HasValidDigitalSignature
{
    Param (
        [string]$PathToFile
    )

    try
    {
        & "$vPathToSignToolExe" verify /pa "$PathToFile"

        return $? # True, если $LASTEXITCODE == 0, иначе False
    }
    catch
    {
        return $False
    }
}



# Создаёт новую папку (случайное имя) в %TEMP% текущего пользователя
# Возвращает объект, который создаёт
function New-TempDir
{
    $DirName = [string]"DCPT_$(Get-Random -Minimum 1337 -Maximum 9001)"

    $Dir = (New-Item -Path "$env:TEMP" -Name "$DirName" -ItemType "Directory")

    return $Dir
}



# Извлекает файлы из архива, используя 7z.exe
function Invoke-Unzip
{
    Param (
        [string]$PathToFile,
        [string]$OutputDir
    )

    try
    {
        & "$vPathTo7zExe" x "$PathToFile" -y "-o${OutputDir}"

        return $? # True, если $LASTEXITCODE == 0, иначе False
    }
    catch
    {
        return $False
    }
}



# Проверяет, совпадает ли хеш двух файлов
function Test-HashMatches
{
    Param (
        [string]$PathToEtalon,
        [string]$PathToCandidate
    )

    if ($(Get-FileHash -Path "$PathToEtalon" -Algorithm $fHashAlgorithm).Hash -eq `
        $(Get-FileHash -Path "$PathToCandidate" -Algorithm $fHashAlgorithm).Hash)
    {
        return $True
    }
    else
    {
        return $False
    }
}



# Вызывает ProductBuilder.Exe
function Invoke-ProductBuilder
{
    Param (
        [string]$Command,
        [string]$PathToFile
    )

    & "$vPathToProductBuilderExe" "$Command" "$PathToFile"
}



# Проверяет, был ли файл зашифрован
# Побочный эффект: расшифровывает файл
# У ProductBuilder.Exe нет метода isEncrypted, поэтому пришлось сделать так
function Test-FileEncrypted
{
    Param (
        [string]$PathToFile
    )

    try
    {
        Invoke-ProductBuilder "decrypt" "$PathToFile"

        return $True
    }
    catch
    {
        return $False
    }
}



# Записывает каждую строку указанного файла в отчёт
function Write-FileContentToReport
{
    Param (
        [string]$PathToFile
    )

    (Get-Content -Path "$PathToFile") | ForEach-Object {
        if ($_.Trim() -ne '')
        {
            New-ReportLine "","$_",""
        }
    }
}



# Записывает свойства (имя, дата изменения, ЦП) указанного файла в отчёт
function Handle-FileProperties
{
    Param (
        [System.IO.FileInfo]$File
    )

    New-ReportLine "Имя","$($File.Name)",""
    New-ReportLine "Изменен","$($File.LastWriteTime.toString('dd.MM.yyyy HH:mm'))","-"

    if (Test-HasValidDigitalSignature "$($File.FullName)")
    {
        New-ReportLine "ЦП","Есть","PASS"
    }
    else
    {
        New-ReportLine "ЦП","Нет","FAIL"
    }
}



# Извлекает архив в указанную директорию
function Handle-Unzip
{
    Param (
        [string]$PathToFile,
        [string]$OutputDir
    )

    Log "Unzipping $PathToFile..."

    if (Invoke-Unzip "$PathToFile" "$OutputDir")
    {
        Log "Success"
    }
    else
    {
        New-ReportLine "Ошибка","Не удалось распаковать архив.","FAIL"
        Handle-Finalization "$fReportDir"
        Err "Failed to unzip $PathToFile"
    }
}



# Проверяет, существует ли CD.inf
# Если да, пишет его содержимое в отчёт
function Handle-CDInf
{
    Param (
        [string]$PathToFile
    )

    if (Test-Path -Path "$PathToFile" -PathType "Leaf")
    {
        New-ReportLine "CD.inf","Есть","PASS"

        Write-FileContentToReport "$PathToFile"
    }
    else
    {
        New-ReportLine "CD.inf","Отсутствует","FAIL"
    }
}



# Проверяет ЦП всех файлов, совпадающих с $FileMask, в $ParentDir (рекурсивно)
function Handle-FilesDigSig
{
    Param (
        [string]$FileMask,
        [string]$ParentDir
    )

    pushd "$ParentDir"

    ls -Path "." -File -Filter "$FileMask" -Recurse | ForEach-Object {
        $RelativePathToFile = Resolve-Path -Path "$($_.FullName)" -Relative

        if (Test-HasValidDigitalSignature "$($_.FullName)")
        {
            New-ReportLine "$RelativePathToFile","Есть ЦП","PASS"
        }
        else
        {
            New-ReportLine "$RelativePathToFile","Нет ЦП","FAIL"
        }
    }

    popd
}



# Проверяет, зашифрованы ли файлы, совпадающие с $FileMask, в $ParentDir (рекурсивно)
function Handle-AmscriptEncryption
{
    Param (
        [string]$FileMask,
        [string]$ParentDir
    )

    pushd "$ParentDir"

    ls -Path "." -File -Filter "$FileMask" -Recurse | ForEach-Object {
        $RelativePathToFile = Resolve-Path -Path "$($_.FullName)" -Relative

        if (Test-FileEncrypted "$($_.FullName)")
        {
            New-ReportLine "$RelativePathToFile","Зашифрован","PASS"
        }
        else
        {
            New-ReportLine "$RelativePathToFile","Не зашифрован","FAIL"
        }
    }

    popd
}



# Записывает каждую строку файлов, совпадающих с $FileMask, в $ParentDir (рекурсивно) в отчёт
function Handle-AmscriptContent
{
    Param (
        [string]$FileMask,
        [string]$ParentDir
    )

    pushd "$ParentDir"

    ls -Path "." -File -Filter "$FileMask" -Recurse | ForEach-Object {
        $RelativePathToFile = Resolve-Path -Path "$($_.FullName)" -Relative

        New-ReportLine "$RelativePathToFile","-","-"

        Write-FileContentToReport "$($_.FullName)"
    }

    popd
}



# Проверяет, существует ли license.lic
# Проверяет содержимое license.lic по хеш-таблице $lLicenseLicKeys
function Handle-LicenseLic
{
    Param (
        [string]$PathToFile
    )

    if (Test-Path -Path "$PathToFile" -PathType "Leaf")
    {
        New-ReportLine "license.lic","Есть","PASS"

        $LicXml = [xml](Get-Content -Path "$PathToFile")

        foreach ($key in $lLicenseLicKeys.keys)
        {
            $Description = $lLicenseLicKeys[$key]["Description"]
            $XPath = $lLicenseLicKeys[$key]["XPath"]
            $WhatToGet = $lLicenseLicKeys[$key]["WhatToGet"]
            $ExpectedValue = $lLicenseLicKeys[$key]["ExpectedValue"]

            try
            {
                $FoundNodes = Select-Xml -Xml $LicXml -XPath "$XPath"

                if ($FoundNodes)
                {
                    $FoundNodes | ForEach-Object {
                        if ("$WhatToGet" -eq '#text')
                        {
                            $Result = $_.Node.'#text'
                        }
                        elseif ("$WhatToGet" -eq 'value')
                        {
                            $Result = $_.Node.value
                        }

                        if ("$ExpectedValue" -ne '')
                        {
                            if ("$Result" -eq "$ExpectedValue")
                            {
                                New-ReportLine "$Description","$Result","PASS"
                            }
                            else
                            {
                                New-ReportLine "$Description","$Result","FAIL","Ожидание: $ExpectedValue"
                            }
                        }
                        else
                        {
                            New-ReportLine "$Description","$Result",""
                        }
                    }
                }
                else
                {
                    New-ReportLine "$Description","-","-","Ключ не найден" # две пустых ячейки подряд делать нельзя
                }
            }
            catch
            {
                New-ReportLine "$Description","Нод не найден","FAIL"
            }
        }
    }
    else
    {
        New-ReportLine "license.lic","Отсутствует","FAIL"
    }
}



# Для всех эталонов из $DirEtalons проверить,
# что соответствующие им кандидаты совпадают с ними по хешу.
function Handle-Etalons
{
    Param (
        [string]$PathToDirWithEtalons,
        [string]$PathToDirWithCandidates
    )

    pushd "$PathToDirWithEtalons"

    ls -Path "." -File -Recurse | ForEach-Object {
        $RelativePathToFile = Resolve-Path -Path "$($_.FullName)" -Relative

        $Etalon = $RelativePathToFile
        $Candidate = "${PathToDirWithCandidates}\$RelativePathToFile"

        if (Test-Path -Path "$Candidate" -PathType "Leaf")
        {
            if (Test-HashMatches "$Etalon" "$Candidate")
            {
                New-ReportLine "$Etalon","Совпадает с эталоном","PASS"
            }
            else
            {
                New-ReportLine "$Etalon","Не совпадает с эталоном","FAIL"
            }
        }
        else
        {
            New-ReportLine "$Etalon","Отсутствует","FAIL"
        }
    }

    popd
}



# Финализация

function Handle-Finalization
{
    Param (
        [string]$PathToDirWithReports
    )

    if (-not (Test-Path -Path "$PathToDirWithReports" -PathType "Container"))
    {
        [void](New-Item -Path "$PathToDirWithReports" -ItemType "Directory") # void - не выводить результат
    }

    $ReportFile = Write-ReportFile "$script:iReportName"
    Log "Writing report to $($ReportFile.FullName)"

    Log "Removing $InputFileUnzipDir"

    # Даже с -Force может не удалить все файлы, известная проблема
    Remove-Item -Path "$InputFileUnzipDir" -Recurse -Force

    Log "Done."
}
