
#Использовать v8runner
#Использовать logos

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
    
    ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Создание архива для удобного тиражирования");
    
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-in", "Путь к каталогу дистрибутива");
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-name-prefix", "Префикс имени архива, например erp20");
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-mdinfo", "Каталог с файлом v8-metadata.info, генерируемым командой make-dist");
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-out", "Выходной каталог с архивом");
    
    Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие ключей командной строки и их значений
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
    Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы()); 

    УправлениеКонфигуратором = ОкружениеСборки.ПолучитьКонфигуратор();

    КаталогДляАрхивации = ПараметрыКоманды["-in"];
    Если Не ЗначениеЗаполнено(КаталогДляАрхивации) Тогда
        КаталогДляАрхивации = ОбъединитьПути(УправлениеКонфигуратором.КаталогСборки(), ОкружениеСборки.ИмяКаталогаФормированияДистрибутива());
    КонецЕсли;

    Каталог = Новый Файл(КаталогДляАрхивации);
    Если Не Каталог.Существует() Тогда
        ВызватьИсключение СтрШаблон("Каталог %1 не существует", КаталогДляАрхивации);
    КонецЕсли;

    Если ЗначениеЗаполнено(ПараметрыКоманды["-mdinfo"]) Тогда
        ФайлМетаданных = Новый Файл(ОбъединитьПути(ПараметрыКоманды["-mdinfo"], ОкружениеСборки.ИмяФайлаИнформацииОМетаданных()));
    Иначе
        ФайлМетаданных = Новый Файл(ОбъединитьПути(УправлениеКонфигуратором.КаталогСборки(), ОкружениеСборки.ИмяФайлаИнформацииОМетаданных()));
    КонецЕсли;

    Лог.Отладка("Имя файла метаданных:" + ФайлМетаданных.ПолноеИмя);
    Если ФайлМетаданных.Существует() Тогда
        ОписаниеМетаданных = ОкружениеСборки.ПрочитатьИнформациюОМетаданных(ФайлМетаданных.ПолноеИмя);
        Лог.Информация("Текущая версия конфигурации: " + ОписаниеМетаданных.Версия);
        ИмяАрхива = СформироватьИмяАрхива(ПараметрыКоманды["-name-prefix"], ОписаниеМетаданных);
    Иначе
        ИмяАрхива = СформироватьИмяАрхива(ПараметрыКоманды["-name-prefix"], Неопределено);
    КонецЕсли;

    ВыходнойКаталог = ?(ПустаяСтрока(ПараметрыКоманды["-out"]),УправлениеКонфигуратором.КаталогСборки(),ПараметрыКоманды["-out"]);
    АрхивироватьДистрибутив(ВыходнойКаталог, ИмяАрхива, КаталогДляАрхивации);

КонецФункции

Функция СформироватьИмяАрхива(Знач Префикс, Знач ОписаниеМетаданных)
    
    Если Не ЗначениеЗаполнено(Префикс) Тогда
        Префикс = ОкружениеСборки.ИмяКаталогаФормированияДистрибутива();
    КонецЕсли;

	Имя = ?(ПустаяСтрока(Префикс),"", Префикс + "-");
    Если ЗначениеЗаполнено(ОписаниеМетаданных) Тогда
        Имя = Имя + ОкружениеСборки.ОпределитьСтандартноеИмяКаталогаШаблона(ОписаниеМетаданных);
    КонецЕсли;

    Возврат Имя + ".zip";

КонецФункции // СформироватьИмяАрхива(Знач Префикс, Знач Версия = "")

Процедура АрхивироватьДистрибутив(Знач ВыходнойКаталог, Знач ИмяАрхива, Знач КаталогДляАрхивации)
    
    Лог.Отладка("ВыходнойКаталог = " + ВыходнойКаталог);
    Лог.Отладка("ИмяАрхива = " + ИмяАрхива);
    Лог.Отладка("КаталогДляАрхивации = " + КаталогДляАрхивации);

    ОбъектКаталога = Новый Файл(ВыходнойКаталог);
    Если Не ОбъектКаталога.Существует() Тогда
        СоздатьКаталог(ОбъектКаталога.ПолноеИмя);
    КонецЕсли;

    ПолноеИмяАрхива = ОбъединитьПути(ОбъектКаталога.ПолноеИмя, ИмяАрхива);
    ЗаписьZIP = Новый ЗаписьZipФайла(ПолноеИмяАрхива);
    ЗаписьZIP.Добавить(
        ОбъединитьПути(КаталогДляАрхивации, ПолучитьМаскуВсеФайлы()),
        РежимСохраненияПутейZIP.СохранятьОтносительныеПути,
        РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
    ЗаписьZIP.Записать();

    Лог.Информация("Архив: " + ПолноеИмяАрхива + " создан.");

КонецПроцедуры