// @strict-types

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область АПИ

// В формат.
// 
// Параметры:
//  Ссылка - СправочникСсылка.Демо_Проекты
//  Данные - см. НовыеДанные
//  Кеш - Структура - Кеш
// 
// Возвращаемое значение:
//  см. СхемаОтветаАПИ
Функция ВФормат(Ссылка, Данные = Неопределено, Кеш = Неопределено) Экспорт
	
	ЛокальныйКеш = Кеширование.ЛокальныйКеш(Кеш, "Формат_Демо_Проект");
	Если ЛокальныйКеш <> Неопределено И Кеширование.ЗначениеИзКеша(Ссылка, ЛокальныйКеш) <> Неопределено Тогда
		Возврат Кеширование.ЗначениеИзКеша(Ссылка, ЛокальныйКеш);	
	КонецЕсли;
	
	//	Здесь уже можно заполнять при наличии БСП удобнее
	//  Реквизиты = ОбщегоНазначения.ЗначенияРеквизитов() 
	Если Данные = Неопределено Тогда
		Реквизиты = НовыеДанные();
		ЗаполнитьЗначенияСвойств(Реквизиты, Ссылка, , "Файлы");
		Реквизиты.Файлы = Ссылка.Файлы.Выгрузить();
	Иначе
		Реквизиты = Данные;
	КонецЕсли;
	
	Результат = СхемаОтветаАПИ();
	Результат.id = XMLСтрока(Ссылка);
	Результат.name = Реквизиты.Наименование;
	Результат.project_owner = Реквизиты.Ответственный;
	
	Для Каждого Файл Из Реквизиты.Файлы Цикл
		ФайлВФормате = СхемаФайлаПроектаАПИ();
		ФайлВФормате.fileID = XMLСтрока(Файл.Идентификатор);
		ФайлВФормате.filename = Файл.ИмяФайла;	// Строка
		Результат.files.Добавить(ФайлВФормате);
	КонецЦикла;
	
	Кеширование.ПоместитьЗначениеВКеш(Новый ФиксированнаяСтруктура(Результат), Ссылка, ЛокальныйКеш);
	
	Возврат Результат;
КонецФункции

// Схема ответа АПИ.
// 
// Возвращаемое значение:
//  Структура - Схема ответа АПИ:
// * name - Строка
// * project_owner - Строка
// * id - Строка
// * files - Массив из см. СхемаФайлаПроектаАПИ
Функция СхемаОтветаАПИ() Экспорт
	
	Схема = Новый Структура();
	Схема.Вставить("name", "");
	Схема.Вставить("project_owner", "");
	Схема.Вставить("id", "");
	Схема.Вставить("files", Новый Массив());
	
	Возврат Схема;
	
КонецФункции

// Схема файла проекта АПИ.
// 
// Возвращаемое значение:
//  Структура - Схема файла проекта АПИ:
// * filename - Строка -
// * fileID - Строка -
Функция СхемаФайлаПроектаАПИ() Экспорт
	Схема = Новый Структура;
	Схема.Вставить("filename", "");
	Схема.Вставить("fileID", "");

	Возврат Схема;
КонецФункции

// Новые данные.
// 
// Возвращаемое значение:
//  Структура - Новые данные:
// * Наименование - Строка
// * Ответственный - Строка
// * Файлы - ТаблицаЗначений
Функция НовыеДанные() Экспорт
	НовыеДанные = Новый Структура();
	НовыеДанные.Вставить("Наименование");
	НовыеДанные.Вставить("Ответственный");
	НовыеДанные.Вставить("Файлы");
	
	Возврат НовыеДанные;
КонецФункции

#КонецОбласти

#Область Общее

// Добавить файл.
// 
// Параметры:
//  Проект - СправочникСсылка.Демо_Проекты
//  ИмяФайла - Строка
//  ДД - ДвоичныеДанные
// 
// Возвращаемое значение:
//  
Функция ДобавитьФайл(Проект, ИмяФайла, ДД) Экспорт
	ПроектОбъект = Проект.ПолучитьОбъект();
	Файл = ПроектОбъект.Файлы.Добавить();
	Файл.Идентификатор = Новый УникальныйИдентификатор();
	Файл.ИмяФайла = ИмяФайла;
	Файл.Файл = Новый ХранилищеЗначения(ДД, Новый СжатиеДанных(9));
	ПроектОбъект.Записать();
	
	Возврат Файл.Идентификатор;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#КонецЕсли
