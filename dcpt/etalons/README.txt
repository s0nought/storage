В эту директорию необходимо поместить эталоны, с которыми будут сравнены файлы из архива, переданного в run_dcpt.bat

Структура каталогов в папке etalons должна повторять структуру каталогов архива, переданного в run_dcpt.bat

Пример:

.\etalons
    \LICENSE
        \LICENSE_RU.RTF

.\unzipped-file-passed-to-run_dcpt.bat
    \LICENSE
        \LICENSE_RU.RTF

Этот файл следует удалить перед запуском run_dcpt.bat