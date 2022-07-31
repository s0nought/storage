# license-lic.ps1
# 
# Описание license.lic для main.ps1
# 
# Дата последнего изменения: 30.11.2021
# 
# Этот файл будет импортирован в init.ps1
# 
# Отредактируйте этот файл перед запуском run_dcpt.bat
# 
# Этот файл должен быть сохранён как license-lic.ps1 в кодировке UTF-8 с BOM
# 
# 
# 
# Про синтаксис XPath см. https://www.w3schools.com/xml/xpath_syntax.asp
# 
# ======
# ФОРМАТ
# ======
# 
# Хеш-таблица, каждый ключ которой - хеш-таблица.
# 
# Вложенные хеш-таблицы должны содержать четыре пары <ключ>=<значение>:
#     Description   - строка. Описание искомого нода. Будет записано в отчёт.
#     XPath         - строка. XPath искомого нода.
#     WhatToGet     - строка. Имя свойства или атрибута, который нужно получить (см. ниже).
#     ExpectedValue - строка. Ожидаемое значение.
# 
# Как выбрать WhatToGet:
#     Если нод имеет атрибуты:
#         <nmt value="true" /> -> 'value'
#     Если нод не имеет атрибутов:
#         <ProductId>3922</ProductId> -> '#text'
# 
# Как записать ExpectedValue:
#     Если на вход будет передан один файл,
#         то следует заполнить ExpectedValue для всех ключей $lLicenseLicKeys.
#     Если на вход будет передан набор файлов,
#         то следует оставить ExpectedValue как пустую строку для тех ключей,
#         где значение будет меняться от файла к файлу.



$lLicenseLicKeys = [ordered]@{
    ProductId = @{
        Description = 'Идентификатор'
        XPath = '//LicenseInfo/ProductId'
        WhatToGet = '#text'
        ExpectedValue = ''
    }

    State = @{
        Description = 'Состояние'
        XPath = '//LicenseInfo/State'
        WhatToGet = '#text'
        ExpectedValue = '1'
    }

    BeforeActivation = @{
        Description = 'Время работы до активации'
        XPath = '//LicenseInfo/BeforeActivation'
        WhatToGet = '#text'
        ExpectedValue = '7'
    }

    AfterActivation = @{
        Description = 'Время работы после активации'
        XPath = '//LicenseInfo/AfterActivation'
        WhatToGet = '#text'
        ExpectedValue = ''
    }

    localizations = @{
        Description = 'Интерфейс, Языки'
        XPath = '//LicenseInfo/Features/localizations'
        WhatToGet = 'value'
        ExpectedValue = ''
    }

    ru_prodtitle = @{
        Description = 'Интерфейс, Название, ru'
        XPath = '//LicenseInfo/Features/ru_prodtitle'
        WhatToGet = 'value'
        ExpectedValue = 'PROMT Master Neural 22'
    }

    en_prodtitle = @{
        Description = 'Интерфейс, Название, en'
        XPath = '//LicenseInfo/Features/en_prodtitle'
        WhatToGet = 'value'
        ExpectedValue = 'PROMT Master Neural 22'
    }

    de_prodtitle = @{
        Description = 'Интерфейс, Название, de'
        XPath = '//LicenseInfo/Features/de_prodtitle'
        WhatToGet = 'value'
        ExpectedValue = 'PROMT Master Neural 22'
    }

    fr_prodtitle = @{
        Description = 'Интерфейс, Название, fr'
        XPath = '//LicenseInfo/Features/fr_prodtitle'
        WhatToGet = 'value'
        ExpectedValue = 'PROMT Master Neural 22'
    }

    es_prodtitle = @{
        Description = 'Интерфейс, Название, es'
        XPath = '//LicenseInfo/Features/es_prodtitle'
        WhatToGet = 'value'
        ExpectedValue = 'PROMT Master Neural 22'
    }

    zh_prodtitle = @{
        Description = 'Интерфейс, Название, zh'
        XPath = '//LicenseInfo/Features/zh_prodtitle'
        WhatToGet = 'value'
        ExpectedValue = 'PROMT Master Neural 22'
    }

    CanInstallSamples = @{
        Description = 'Установка базы примеров'
        XPath = '//LicenseInfo/Features/CanInstallSamples'
        WhatToGet = 'value'
        ExpectedValue = 'false'
    }

    codeid = @{
        Description = 'AlgorithmId'
        XPath = '//LicenseInfo/Features/codeid'
        WhatToGet = 'value'
        ExpectedValue = '2177799105'
    }

    nmt = @{
        Description = 'NMT перевод'
        XPath = '//LicenseInfo/Features/nmt'
        WhatToGet = 'value'
        ExpectedValue = 'true'
    }

    trru_config = @{
        Description = 'Конфиг онлайн направлений'
        XPath = '//LicenseInfo/Features/trru_config'
        WhatToGet = 'value'
        ExpectedValue = ''
    }

    easypayurl = @{
        Description = 'URL EasyPay'
        XPath = '//LicenseInfo/Features/easypayurl'
        WhatToGet = 'value'
        ExpectedValue = ''
    }

    lease_url = @{
        Description = 'URL страницы продления аренды'
        XPath = '//LicenseInfo/Features/lease_url'
        WhatToGet = 'value'
        ExpectedValue = ''
    }

    try_url = @{
        Description = 'URL страницы пробной версии'
        XPath = '//LicenseInfo/Features/try_url'
        WhatToGet = 'value'
        ExpectedValue = ''
    }

    managers = @{
        Description = 'Менеджеры'
        XPath = '//LicenseInfo/Features/managers'
        WhatToGet = 'value'
        ExpectedValue = 'false'
    }

    SessionTime = @{
        Description = 'Время жизни сессии'
        XPath = '//LicenseInfo/SessionTime'
        WhatToGet = '#text'
        ExpectedValue = '30'
    }

    freelance = @{
        Description = 'Freelance'
        XPath = '//LicenseInfo/Features/freelance'
        WhatToGet = 'value'
        ExpectedValue = 'true'
    }

    broadcast = @{
        Description = 'ЗМИЛС'
        XPath = '//LicenseInfo/Features/broadcast'
        WhatToGet = 'value'
        ExpectedValue = 'false'
    }

    MaxRegisteredUsers = @{
        Description = 'Конкурентных пользователей'
        XPath = '//LicenseInfo/MaxRegisteredUsers'
        WhatToGet = '#text'
        ExpectedValue = '0'
    }

    MaxUsers = @{
        Description = 'Пользователей'
        XPath = '//LicenseInfo/MaxUsers'
        WhatToGet = '#text'
        ExpectedValue = '0'
    }

    MaxServers = @{
        Description = 'Серверов'
        XPath = '//LicenseInfo/MaxServers'
        WhatToGet = '#text'
        ExpectedValue = '0'
    }

    mysettings = @{
        Description = 'Мои настройки'
        XPath = '//LicenseInfo/Features/mysettings'
        WhatToGet = 'value'
        ExpectedValue = 'true'
    }

    documents = @{
        Description = 'Документы'
        XPath = '//LicenseInfo/Features/documents'
        WhatToGet = 'value'
        ExpectedValue = 'true'
    }

    lingvo = @{
        Description = 'Lingvo'
        XPath = '//LicenseInfo/Features/lingvo'
        WhatToGet = 'value'
        ExpectedValue = 'false'
    }

    CanInstallTradosAddOnWithoutActivation = @{
        Description = 'Установка аддона для Trados'
        XPath = '//LicenseInfo/Features/CanInstallTradosAddOnWithoutActivation'
        WhatToGet = 'value'
        ExpectedValue = 'false'
    }
}
