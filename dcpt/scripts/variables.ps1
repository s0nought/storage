# variables.ps1
# 
# Пользовательские переменные.
# 
# Дата последнего изменения: 30.11.2021
# 
# Этот файл будет импортирован в init.ps1
# 
# Отредактируйте этот файл перед запуском run_dcpt.bat
# 
# Этот файл должен быть сохранён как variables.ps1 в кодировке UTF-8 с BOM
# 
# Формат:
# <имя переменной> = "<значение переменной>"
# 
# ==================================
# !!! НЕ МЕНЯТЬ <ИМЯ ПЕРЕМЕННОЙ> !!!
# ==================================



# Полный путь до 7z.exe
$vPathTo7zExe = "C:\Program Files (x86)\7-Zip\7z.exe"

# Полный путь до signtool.exe
$vPathToSignToolExe = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64\signtool.exe"

# Полный путь до ProductBuilder.exe
$vPathToProductBuilderExe = "C:\Program Files (x86)\ProductBuilder\ProductBuilder.exe"
