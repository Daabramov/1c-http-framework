// @strict-types

#Область СлужебныйПрограммныйИнтерфейс

// Создать заявку.
// 
// Параметры:
//  Запрос - HTTPСервисЗапрос - Входящий запрос
//  МетаданныеСервиса - ОбъектМетаданныхHTTPСервис - Исходные метаданные сервиса
// 
// Возвращаемое значение:
//	HTTPСервисОтвет - Ответ
Функция СоздатьЗаявку(Запрос, МетаданныеСервиса) Экспорт
	
	ДопПараметры = Новый Структура();
	
	ДанныеЗапроса = СервисыОбщее.ИзвлечьТелоJSONПоСхеме(
		Запрос,
		ФабрикаXDTO.Тип("http://www.example.com/api/common/1.0", "request.create"),
		ДопПараметры
	);
	
	ПараметрыВосстановления = ВосстановлениеXDTO.НовыеПараметрыВосстановления();
	ОбщегоНазначенияХТТП.ДополнитьТаблицу(Документы.Демо_Заявка.ФункцииВосстановления(), ПараметрыВосстановления);
	ВосстановленныеДанные = ВосстановлениеXDTO.КонвертироватьИзФормата(
		ДанныеЗапроса,
		ПараметрыВосстановления,
		ДопПараметры
	);
	
	ПараметрыСозданияЗаявки = Новый Структура(
		"Тема,Проект,Срочный,Сообщение",
		ВосстановленныеДанные.Получить("Тема"),
		ВосстановленныеДанные.Получить("Проект"),
		ВосстановленныеДанные.Получить("Срочный"),
		ВосстановленныеДанные.Получить("Сообщение").Получить("ТелоСообщения")
	);
	
	Заявка = Демо_Заявки.СоздатьЗаявку(ПараметрыСозданияЗаявки);
	
	ЗаявкаВФормате = документы.Демо_Заявка.ВФормат(Заявка);
	
	Возврат СервисыОбщее.ОтветИзОбъекта(ЗаявкаВФормате);
	
КонецФункции

// Создать проект.
// 
// Параметры:
//  Запрос - HTTPСервисЗапрос - Входящий запрос
//  МетаданныеСервиса - ОбъектМетаданныхHTTPСервис - Исходные метаданные сервиса
// 
// Возвращаемое значение:
//	HTTPСервисОтвет - Ответ
Функция СоздатьПроект(Запрос, МетаданныеСервиса) Экспорт
	ДопПараметры = Новый Структура();
	
	ДанныеЗапроса = СервисыОбщее.ИзвлечьТелоJSONПоСхеме(
		Запрос,
		ФабрикаXDTO.Тип("http://www.example.com/api/common/1.0", "project.create"),
		ДопПараметры
	);
	
	Проект = Справочники.Демо_Проекты.СоздатьЭлемент();
	Проект.Заполнить(Неопределено);
	//@skip-check statement-type-change, property-return-type
	Проект.Наименование = ДанныеЗапроса.name;
	//@skip-check statement-type-change, property-return-type
	Проект.Ответственный = ДанныеЗапроса.project_owner;
	Проект.Записать();
	
	ПроектВФормате = Справочники.Демо_Проекты.ВФормат(Проект.Ссылка);
	Возврат СервисыОбщее.ОтветИзОбъекта(ПроектВФормате);
КонецФункции

// Получить проекты
// 
// Параметры:
//  Запрос - HTTPСервисЗапрос - Входящий запрос
//  МетаданныеСервиса - ОбъектМетаданныхHTTPСервис - Исходные метаданные сервиса
// 
// Возвращаемое значение:
//	HTTPСервисОтвет - Ответ
Функция ПолучитьПроекты(Запрос, МетаданныеСервиса) Экспорт
	
	
	ВыборкаПроектов = Справочники.Демо_Проекты.Выбрать();
	
	Результат = Новый Массив();
	ДанныеПроектов = Новый Соответствие();
	Пока ВыборкаПроектов.Следующий() Цикл
		ДанныеПроекта = Справочники.Демо_Проекты.НовыеДанные();
		ДанныеПроекта.Наименование = ВыборкаПроектов.Наименование;
		ДанныеПроекта.Ответственный = ВыборкаПроектов.Ответственный;
		ДанныеПроектов.Вставить(ВыборкаПроектов.Ссылка, ДанныеПроекта);
		Результат.Добавить(ВыборкаПроектов.Ссылка);
	КонецЦикла;
	
	ДопПараметры = Новый Структура();
	ДопПараметры.Вставить("ДанныеПроектов", ДанныеПроектов);
	
	ПараметрыПреобразования = ОбщиеПараметрыПреобразования(ДопПараметры);
	ДопПараметры.Вставить("ПараметрыПреобразованияJson", ПараметрыПреобразования);
	
	Возврат СервисыОбщее.ОтветИзОбъекта(
		Результат,
		200,
		ДопПараметры
	);
		
	
КонецФункции

// Получить проекты
// 
// Параметры:
//  Запрос - HTTPСервисЗапрос - Входящий запрос
//  МетаданныеСервиса - ОбъектМетаданныхHTTPСервис - Исходные метаданные сервиса
// 
// Возвращаемое значение:
//	HTTPСервисОтвет - Ответ
Функция ПолучитьПроект(Запрос, МетаданныеСервиса) Экспорт
	
	ПараметрАйдиПроекта = СервисыОбщее.НовыйПараметрЗапроса("project_id", "ИД", Истина);
	ПараметрКод = СервисыОбщее.НовыйПараметрЗапроса("code", "Число");
	ПараметрУдален = СервисыОбщее.НовыйПараметрЗапроса("deleted", "Булево");
	ПараметрСтатус = СервисыОбщее.НовыйПараметрЗапроса("status");
	ПараметрСтатус.ВозможныеЗначения.Добавить("active");
	ПараметрСтатус.ВозможныеЗначения.Добавить("disabled");
	
	ОжидаемыеПараметры = Новый Массив();
	ОжидаемыеПараметры.Добавить(ПараметрАйдиПроекта);
	ОжидаемыеПараметры.Добавить(ПараметрКод);
	ОжидаемыеПараметры.Добавить(ПараметрУдален);
	ОжидаемыеПараметры.Добавить(ПараметрСтатус);
	
	ПараметрыЗапроса = СервисыОбщее.ПараметрыЗапроса(
		Запрос,
		ОжидаемыеПараметры
	);
	
	Проект = Демо_ФункцииВосстановления.ВосстановитьПроект(
		ПараметрыЗапроса.Получить("project_id")
	); // СправочникСсылка.Демо_Проекты
	
	Возврат СервисыОбщее.ОтветИзОбъекта(
		Справочники.Демо_Проекты.ВФормат(Проект)
	);
		
	
КонецФункции

// Преобразование.
// 
// Параметры:
//  Свойство - Строка
//  Значение - Произвольный
//  ДополнительныеПараметры - Структура
//  Отказ - Булево
// 
// Возвращаемое значение:
//  Произвольный
Функция Преобразование(Свойство, Значение, ДополнительныеПараметры, Отказ) Экспорт
	Если ТипЗнч(Значение) = Тип("СправочникСсылка.Демо_Проекты") Тогда
		ЛокальныйКеш = Кеширование.ЛокальныйКеш(ДополнительныеПараметры, "ДанныеПроектов");
		ДанныеПроекта = Кеширование.ЗначениеИзКеша(Значение, ЛокальныйКеш);
		
		Возврат Справочники.Демо_Проекты.ВФормат(Значение, ДанныеПроекта, ДополнительныеПараметры);
		
	КонецЕсли;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Общие параметры преобразования.
// 
// Параметры:
//  ДопПараметры - Структура
// 
// Возвращаемое значение:
//  Структура - см. КоннекторХТТПСлужебный.ПараметрыПреобразованияJSONПоУмолчанию
Функция ОбщиеПараметрыПреобразования(ДопПараметры)
	Параметры = КоннекторХТТПСлужебный.ПараметрыПреобразованияJSONПоУмолчанию();
	Параметры.ИмяФункцииПреобразования = "Преобразование";
	Параметры.МодульФункцииПреобразования = Демо_КонтроллерСервиса;
	Параметры.ДополнительныеПараметрыФункцииПреобразования = ДопПараметры;
	Возврат Параметры;
КонецФункции

#КонецОбласти

