# main.ps1
# 
# Так называемый "Main".
# 
# Дата последнего изменения: 30.11.2021
# 
# Базовые проверки входного файла выполняются в run_dcpt.bat
# 
# Этот файл должен быть сохранён как main.ps1 в кодировке UTF-8 с BOM
# 
# =================================================================
# !!! НЕ ИЗМЕНЯЙТЕ ЭТОТ ФАЙЛ, ЕСЛИ НЕ УВЕРЕНЫ В СВОИХ ДЕЙСТВИЯХ !!!
# =================================================================



# Сохранить свойства входного файла: Имя, Дата изменения, ЦП
# $InputFile - из init.ps1

Log "Get input file properties..."
Handle-FileProperties $InputFile



# Распаковать входной файл в новую папку в %TEMP%

$InputFileUnzipDir = New-TempDir
Log "Created temp directory: $($InputFileUnzipDir.FullName)"
Handle-Unzip "$($InputFile.FullName)" "$($InputFileUnzipDir.FullName)"



# Проверить, что кандидаты совпадают с эталонами (только файлы!)
# Если среди эталонов есть *.amscript файлы, то этот блок
# должен быть выше, чем проверки *.amscript файлов

Log "Test candidate files match etalon files..."
Handle-Etalons "$iDirEtalons" "$($InputFileUnzipDir.FullName)"



# Проверить наличие CD.inf, сохранить его содержимое в отчёт

$CDInfName = "CD.inf"
Log "Test $CDInfName..."
Handle-CDInf "$($InputFileUnzipDir.FullName)\$CDInfName"



# Проверить цифровую подпись *.exe файлов (рекурсивно)

Log "Test digital signature of EXE files..."
Handle-FilesDigSig "*.exe" "$($InputFileUnzipDir.FullName)"



# Проверить цифровую подпись *.dll файлов (рекурсивно)

# Log "Test digital signature of DLL files..."
# Handle-FilesDigSig "*.dll" "$($InputFileUnzipDir.FullName)"



# Проверить, что зашифрованы *.amscript файлы, а также расшифровать их (рекурсивно)

Log "Test amscript files are encrypted (and decrypt them)..."
Handle-AmscriptEncryption "*.amscript" "$($InputFileUnzipDir.FullName)"



# Сохранить содержимое *variables.amscript файлов в отчёт

Log "Get content of *variables.amscript files..."
Handle-AmscriptContent "*variables.amscript" "$($InputFileUnzipDir.FullName)"



# Проверить наличие license.lic, проверить его содержимое по license-lic.ps1

$LicenseLicName = "PROTECT\license.lic"
Log "Test $LicenseLicName..."
Handle-LicenseLic "$($InputFileUnzipDir.FullName)\$LicenseLicName"



# Сохранить отчёт, завершить программу

Handle-Finalization "$fReportDir"
