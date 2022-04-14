// @strict-types

#Область ПрограммныйИнтерфейс

// Извлечь тело запроса по указанной схеме
// 
// Параметры:
//  Источник - HTTPСервисЗапрос,Строка,Поток,ДвоичныеДанные - Источник для извлечения
//  ТипXDTO - ТипОбъектаXDTO,ТипЗначенияXDTO - Источник хттп
//  ДопПараметры - Неопределено, Структура - Доп параметры (Параметры прокидываются во всех переопределяемые процедуры)
//  Кодировка - Строка,КодировкаТекста - Кодировка считывания тела запроса
// 
// Возвращаемое значение:
//  ОбъектXDTO,СписокXDTO
Функция ИзвлечьТелоJSONПоСхеме(Источник, ТипXDTO, ДопПараметры = Неопределено, Кодировка = Неопределено) Экспорт
	
	ЧтениеJson = ЧтениеJsonИзИсточника(Источник, Кодировка);
	
	Попытка
		//@skip-check invocation-parameter-type-intersect
		ОбъектXDTO = ФабрикаXDTO.ПрочитатьJSON(
			ЧтениеJSON,
			ТипXDTO,
			"ВосстановитьЗначениеXDTO", // Можно переопределить в см. ВосстановлениеXDTOПереопределяемый 
			ВосстановлениеXDTO,
			ДопПараметры
		); // ОбъектXDTO, СписокXDTO
	Исключение
		ТекстОшибки = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключениеПроверки(ТекстОшибки);
	КонецПопытки;
	
	Возврат ОбъектXDTO;
	
КонецФункции

// Извлекает параметры из запроса, проверяет наличие обязательных параметров, преобразует
// параметры запроса в примитивные типы, переименовывает параметры в локальное представление
// 
// Параметры:
//  Запрос - HTTPСервисЗапрос
//  ПроверяемыеПараметры - Массив из см. НовыйПараметрЗапроса
// 
// Возвращаемое значение:
//  Соответствие из КлючИЗначение - Параметры запроса:
//	* Ключ - Строка
//	* Значение - Строка,Булево,Число
Функция ПараметрыЗапроса(Запрос, ПроверяемыеПараметры) Экспорт
	
	ПараметрыЗапроса = Новый Соответствие();
	
	Для Каждого Элемент Из Запрос.ПараметрыЗапроса Цикл
		ПараметрыЗапроса.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла;
	
	Для Каждого Элемент Из Запрос.ПараметрыURL Цикл
		ПараметрыЗапроса.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла;
	
	Для Каждого ЗапрашиваемыйПараметр Из ПроверяемыеПараметры Цикл
		Если ЗапрашиваемыйПараметр.Обязательный И ПараметрыЗапроса.Получить(ЗапрашиваемыйПараметр.Имя) = Неопределено Тогда
			ВызватьИсключениеПроверки(СтрШаблон("No required parameter [%1]", ЗапрашиваемыйПараметр.Имя));
		КонецЕсли;
		
		Если ПараметрыЗапроса.Получить(ЗапрашиваемыйПараметр.Имя) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ЗначениеПараметра = ПараметрыЗапроса.Получить(ЗапрашиваемыйПараметр.Имя); // Строка
		
		Если ЗапрашиваемыйПараметр.ВозможныеЗначения.Количество() > 0
			И ЗапрашиваемыйПараметр.ВозможныеЗначения.Найти(НРег(ЗначениеПараметра)) = Неопределено Тогда
				ТекстОшибки = СтрШаблон(
					"Invalid parameter value for parameter [%1], only following values are available [%2]",
					ЗапрашиваемыйПараметр.Имя,
					СтрСоединить(ЗапрашиваемыйПараметр.ВозможныеЗначения, ",")
				);
				ВызватьИсключениеПроверки(ТекстОшибки);
		КонецЕсли;
		
		Тип = ВРЕГ(ЗапрашиваемыйПараметр.Тип);
		Если Тип = "БУЛЕВО" Тогда
			Попытка
				ЗначениеБулево = Булево(ЗначениеПараметра);
				ПараметрыЗапроса.Вставить(ЗапрашиваемыйПараметр.Имя, ЗначениеБулево);
			Исключение
				ВызватьИсключениеПроверки(СтрШаблон("failed to convert value [%1] to boolean", ЗначениеПараметра));
			КонецПопытки;
		ИначеЕсли Тип = "ЧИСЛО" Тогда
			Попытка
				ЗначениеЧислом = Число(ЗначениеПараметра);
				ПараметрыЗапроса.Вставить(ЗапрашиваемыйПараметр.Имя, ЗначениеЧислом);
			Исключение
				ВызватьИсключениеПроверки(СтрШаблон("failed to convert value [%1] to number", ЗначениеПараметра));
			КонецПопытки;
		ИначеЕсли Тип = "ИД" Тогда
			Попытка
				ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("https://github.com/Daabramov/1c-http-framework", "guid"), ЗначениеПараметра);
				ПараметрыЗапроса.Вставить(ЗапрашиваемыйПараметр.Имя, ЗначениеПараметра);
			Исключение
				ВызватьИсключениеПроверки(СтрШаблон("value [%1] is not guid", ЗначениеПараметра));
			КонецПопытки;
		ИначеЕсли Тип = "СТРОКА" Тогда
			Продолжить;
		Иначе
			ВызватьИсключение СтрШаблон("Неподдерживаемый тип параметра %1 для %2", Тип, ЗапрашиваемыйПараметр.Имя);
		КонецЕсли;
	КонецЦикла;
	
	Возврат ПараметрыЗапроса;
	
КонецФункции

// Новый параметр запроса.
// 
// Параметры:
//  Имя - Строка - Имя
//  Тип - Строка - Описание типа строкой (Число,Строка,Булево,Ид)
//  Обязательный - Булево - Признак обязательности параметра
// 
// Возвращаемое значение:
//  Структура - Новый параметр запроса:
// * Имя - Строка
// * Обязательный - Булево
// * Тип - Строка - Тип строкой "Число", "Строка", "Булево" или "Ид"
// * ВозможныеЗначения - Массив из Строка - возможные значения строк указывать в нижнем регистре
Функция НовыйПараметрЗапроса(Имя, Тип = "Строка", Обязательный = Ложь) Экспорт
	
	Параметр = Новый Структура();
	Параметр.Вставить("Имя", Имя);
	Параметр.Вставить("Обязательный", Обязательный);
	Параметр.Вставить("Тип", Тип);
	Параметр.Вставить("ВозможныеЗначения", Новый Массив());
	
	Возврат Параметр;
	
КонецФункции

// Выполняет чтение тела запроса HTTP-сервиса, имеющее составное содержимое (multipart/form-data) и возвращает поля
// этого содержимого в виде соответствия. В качестве ключа используется имя поля.
//
// Параметры:
//  Запрос - HTTPСервисЗапрос - запрос, полученный HTTP-сервисом.
// 
// Возвращаемое значение:
//  Соответствие из КлючИЗначение - соответствие, содержащее описание полей составного содержимого:
//  * Ключ - Строка - В качестве ключа используется имя поля
//  * Значение - см. ПолеСоставногоСодержимогоЗапроса
//
// Ссылки: 
// https://infostart.ru/public/1277790/
Функция ПрочитатьСоставноеСодержимоеЗапроса(Запрос) Экспорт
	ПоляЗапроса = Новый Соответствие;

	РазделительПолей = ПолучитьРазделитьПолейСоставногоСодержимого(Запрос);
	ОкончаниеПолей = "--";

	ТелоЗапроса = Запрос.ПолучитьТелоКакПоток();
	ЧтениеДанных = Новый ЧтениеДанных(ТелоЗапроса);

	ЕстьДанные = Истина;
	Пока ЕстьДанные Цикл

		//@skip-check invocation-parameter-type-intersect
		РезультатЧтения = ЧтениеДанных.ПрочитатьДо(РазделительПолей);
		ЕстьДанные = РезультатЧтения.МаркерНайден;

		Если ЕстьДанные Тогда
			Строка = ЧтениеДанных.ПрочитатьСтроку();
			ЕстьДанные = (Строка <> ОкончаниеПолей);
		КонецЕсли;

		Если РезультатЧтения.Размер = 0 Тогда
			Продолжить;
		КонецЕсли;

		Поток = РезультатЧтения.ОткрытьПотокДляЧтения();

		Поле = ПрочитатьПолеСоставногоСодержимогоИзПотока(Поток);
		ПоляЗапроса.Вставить(Поле.Имя, Поле);

		Поток.Закрыть();

	КонецЦикла;

	ЧтениеДанных.Закрыть();
	ТелоЗапроса.Закрыть();

	Возврат ПоляЗапроса;
КонецФункции

// Ответ из объекта.
// 
// Параметры:
//  Объект - Структура,Соответствие,Массив,ФиксированнаяКоллекция
//  Код - Число - Код
//  ДопПараметры - Структура:
//  * ПараметрыПреобразованияJson - см. КоннекторХТТПСлужебный.ПараметрыПреобразованияJSONПоУмолчанию
//  * ПараметрыЗаписиJson - см. КоннекторХТТПСлужебный.ПараметрыЗаписиJSONПоУмолчанию
// 
// Возвращаемое значение:
//  HTTPСервисОтвет - Ответ из объекта
Функция ОтветИзОбъекта(Объект, Код = 200, ДопПараметры = Неопределено) Экспорт
	//@skip-check invocation-parameter-type-intersect
	СтрокаJson = КоннекторХТТПСлужебный.ОбъектВJson(
		Объект,
		ОбщегоНазначенияХТТП.ЗначениеПоКлючу(ДопПараметры, "ПараметрыПреобразованияJson"),
		ОбщегоНазначенияХТТП.ЗначениеПоКлючу(ДопПараметры, "ПараметрыЗаписиJson")
	);
	Ответ = ОтветИзСтроки(СтрокаJson, Код);
	Ответ.Заголовки.Вставить("Content-Type", "application/json");
	Возврат Ответ;
КонецФункции

// Ответ из строки.
// 
// Параметры:
//  ТелоОтвета - Строка - Тело ответа
//  Код - Число - Код
// 
// Возвращаемое значение:
//  HTTPСервисОтвет - Ответ из строка
Функция ОтветИзСтроки(ТелоОтвета, Код = 200) Экспорт
	Ответ = ОтветПоКоду(Код);
	Ответ.УстановитьТелоИзСтроки(ТелоОтвета);
	Возврат Ответ;
КонецФункции

// Ответ из двоичных данных.
// 
// Параметры:
//  Данные - ДвоичныеДанные - Данные
//  Код - Число - Код
// 
// Возвращаемое значение:
//  HTTPСервисОтвет - Ответ из двоичных данных
Функция ОтветИзДвоичныхДанных(Данные, Код = 200) Экспорт
	Ответ = ОтветПоКоду(Код);
	Ответ.УстановитьТелоИзДвоичныхДанных(Данные);
	Ответ.Заголовки.Вставить("Content-Type", "application/octet-stream");
	Возврат Ответ;
КонецФункции

// Ответ по коду.
// 
// Параметры:
//  Код - Число - Код
// 
// Возвращаемое значение:
//  HTTPСервисОтвет - Ответ по коду
Функция ОтветПоКоду(Код = 200) Экспорт
	Ответ = Новый HTTPСервисОтвет(Код);
	Возврат Ответ;
КонецФункции

// Плохой запрос (400).
// 
// Параметры:
//  Сообщение - Строка - Тест ошибки проверки
//  Код - Число - Код ХТТП ответа
// 
// Возвращаемое значение:
//  HTTPСервисОтвет - Новый плохой запрос
Функция ПлохойЗапрос(Сообщение, Код = 400) Экспорт
	
	ОписаниеПроблемы = Новый Структура(
		"error",
		СтрЗаменить(Сообщение, ОбработкаЗапросовПовтИсп.БазовыйКодОшибкиПроверки(), "")
	);
	Возврат ОтветИзОбъекта(ОписаниеПроблемы, Код);
	
КонецФункции

// Ошибка Сервиса (500).
// 
// Параметры:
//  Сообщение - Строка - Тест ошибки проверки
//  ИдентификатораОшибки - Строка - Идентификатор ошибки
//  Код - Число - Код ХТТП ответа
// 
// Возвращаемое значение:
//  HTTPСервисОтвет - Новый плохой запрос
Функция ОшибкаСервера(Сообщение, ИдентификатораОшибки, Код = 500) Экспорт
	ОписаниеОшибки = Новый Структура("trace_code", ИдентификатораОшибки);
	Если ЗначениеЗаполнено(Сообщение) Тогда
		ОписаниеОшибки.Вставить("error", Сообщение);
	КонецЕсли;
	Возврат ОтветИзОбъекта(ОписаниеОшибки, Код);
КонецФункции

// Вызвать исключение проверки.
// 
// Параметры:
//  Сообщение - Строка - Передаваемое сообщение ошибки проверки
Процедура ВызватьИсключениеПроверки(Сообщение) Экспорт
	ВызватьИсключение СтрШаблон(
		"%1%2",
		ОбработкаЗапросовПовтИсп.БазовыйКодОшибкиПроверки(),
		Сообщение
	);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЧтениеJsonИзИсточника(Источник, Кодировка)
	ЧтениеJson = Новый ЧтениеJSON;
	Если ТипЗнч(Источник) = Тип("HTTPСервисЗапрос") Тогда
		Поток = Источник.ПолучитьТелоКакПоток();
		Если Поток.Размер() = 0 Тогда
			ВызватьИсключениеПроверки("body is empty");
		КонецЕсли;
		ЧтениеJson.ОткрытьПоток(Поток, Кодировка);
	ИначеЕсли ТипЗнч(Источник) = Тип("Поток") Тогда
		Если Источник.Размер() = 0 Тогда
			ВызватьИсключениеПроверки("body is empty");
		КонецЕсли;
		ЧтениеJson.ОткрытьПоток(Источник, Кодировка);
	ИначеЕсли ТипЗнч(Источник) = Тип("ДвоичныеДанные") Тогда
		Если Источник.Размер() = 0 Тогда
			ВызватьИсключениеПроверки("body is empty");
		КонецЕсли;
		ЧтениеJson.УстановитьСтроку(ПолучитьСтрокуИзДвоичныхДанных(Источник, Кодировка));
	ИначеЕсли ТипЗнч(Источник) = Тип("Строка") Тогда
		Если Не ЗначениеЗаполнено(Источник) Тогда
			ВызватьИсключениеПроверки("body is empty");
		КонецЕсли;
		ЧтениеJson.УстановитьСтроку(Источник);
	Иначе
		ВызватьИсключение "Недопустимый тип данных";
	КонецЕсли;
	Возврат ЧтениеJson
КонецФункции

// Выполняет чтение поля составного содержимого из потока, полученного из тела запроса.
//
// Параметры:
//  Поток - Поток - поток, содержащий данные поля составного содержимого.
// 
// Возвращаемое значение:
//  Структура - см. ПолеСоставногоСодержимогоЗапроса
//
Функция ПрочитатьПолеСоставногоСодержимогоИзПотока(Поток)
	
	Поле = ПолеСоставногоСодержимогоЗапроса();
	
	ЧтениеДанных = Новый ЧтениеДанных(Поток);
	
	ЭтоСодержимое = Ложь;
	Пока Не ЭтоСодержимое Цикл
		Строка = ЧтениеДанных.ПрочитатьСтроку();
		
		Если ЗначениеЗаполнено(Строка) Тогда
			ОбработатьЗаголовокСоставногоСодержимого(Поле, Строка);
		Иначе
			// Пустая строка является разделителем заголовков и содержимого поля.
			ЭтоСодержимое = Истина;
		КонецЕсли; 
	КонецЦикла; 
	
	РезультатЧтения = ЧтениеДанных.Прочитать();
	
	Если РезультатЧтения.Размер > 0 Тогда
		
		ПотокСодержимого = РезультатЧтения.ОткрытьПотокДляЧтения();
		ЧтениеДанныхСодержимого = Новый ЧтениеДанных(ПотокСодержимого);
		
		ДвоичноеСодержимое = (Поле.ИмяФайла <> Неопределено);
		Если ДвоичноеСодержимое Тогда
			РазмерСодержимого = РезультатЧтения.Размер - 2; // Конечный разделитель строк (ВК + ПС) не нужен.
			РезультатЧтенияСодержимого = ЧтениеДанныхСодержимого.Прочитать(РазмерСодержимого);
			
			Поле.Содержимое = РезультатЧтенияСодержимого.ПолучитьДвоичныеДанные();
		Иначе
			Поле.Содержимое = ЧтениеДанныхСодержимого.ПрочитатьСимволы();
			
			// Конечный разделитель строк (ПС) не нужен (согласно RFC7578 разделителем строк является ВК + ПС, но 1С
			// конвертирует в ПС при чтении строк).
			Поле.Содержимое = Лев(Поле.Содержимое, СтрДлина(Поле.Содержимое) - 1);
		КонецЕсли; 
		
		ЧтениеДанныхСодержимого.Закрыть();
		ПотокСодержимого.Закрыть();
		
	КонецЕсли; 
	
	ЧтениеДанных.Закрыть();
	
	Возврат Поле;
	
КонецФункции 

// Обрабатывает строку заголовка поля составного содержимого (multipart/form-data) и заполняет свойства "Имя",
// "ИмяФайла" и "ТипСодержимого" (в зависимости от заголока) структуры, описывающей это поле.
//
// Параметры:
//  Поле - см. ПолеСоставногоСодержимогоЗапроса
//  ПолныйЗаголовок - Строка - полный заголовок поля составного содержимого. Например,
//                             Content-Disposition: form-data; name="file"; filename="image01.jpg"
//
Процедура ОбработатьЗаголовокСоставногоСодержимого(Поле, ПолныйЗаголовок)
	
	Поз = СтрНайти(ПолныйЗаголовок, ":");
	Заголовок = НРег(Лев(ПолныйЗаголовок, Поз - 1));
	
	Если Заголовок = "content-disposition" Тогда
		
		Поз = СтрНайти(ПолныйЗаголовок, ";");
		СвойстваЗаголовка = СокрЛ(Сред(ПолныйЗаголовок, Поз + 1));
		
		МассивСвойств = СтрРазделить(СвойстваЗаголовка, ";");
		Для каждого Свойство Из МассивСвойств Цикл
			
			КлючЗначение = СтрРазделить(СокрЛП(Свойство), "=");
			Ключ = НРег(СокрЛП(КлючЗначение[0]));
			Значение = УдалитьОбрамляющиеКавычкиИзСтроки(СокрЛП(КлючЗначение[1]));
			
			Если Ключ = "name" Тогда
				Поле.Имя = Значение;
			ИначеЕсли Ключ = "filename" Тогда
				Поле.ИмяФайла = Значение;
			КонецЕсли; 
			
		КонецЦикла;
		
	ИначеЕсли Заголовок = "content-type" Тогда
		
		Поле.ТипСодержимого = СокрЛ(Сред(ПолныйЗаголовок, Поз + 1));
		
	КонецЕсли; 
	
КонецПроцедуры 

// Возвращает инициализированную структуру, описывающую поле составного запроса.
// 
// Возвращаемое значение:
//  Структура - структура, описывающая поле составного содержимого запроса:
//    * Имя - Строка - имя поля (name).
//    * ИмяФайла - Строка - имя файла (filename). Если имя файла указано, то содержимое является двоичными данными.
//    * ТипСодержимого - Строка - тип содержимого, указанный в заголовке Content-Type поля. 
//                                Например: text/plain, image/jpeg и т.п. Может отсутствовать.
//    * Содержимое - Строка, ДвоичныеДанные - содержимое поля. Если указано имя файла, то содержит двоичные данные,
//                                            иначе Строка.
//
Функция ПолеСоставногоСодержимогоЗапроса()
	
	Возврат Новый Структура("Имя, ИмяФайла, ТипСодержимого, Содержимое");
	
КонецФункции

// Получает разделитель (boundary) составного содержимого (multipart/form-data) из заголовка Content-Type.
// Если значение заголовка Content-Type не равно multipart/form-data или свойство boundary не указано, то будет вызвано
// исключение.
//
// Параметры:
//  Запрос - HTTPСервисЗапрос - запрос, полученный HTTP-сервисом.
// 
// Возвращаемое значение:
//  Строка - значение свойства boundary заголовка Content-Type для multipart/form-data.
//
Функция ПолучитьРазделитьПолейСоставногоСодержимого(Запрос)
	
	ПолныйТипСодержимого = Запрос.Заголовки["Content-Type"]; // Строка
	
	Поз = СтрНайти(ПолныйТипСодержимого, ";");
	ТипСодержимого = НРег(?(Поз > 0, Лев(ПолныйТипСодержимого, Поз - 1), ПолныйТипСодержимого));
	
	Если ТипСодержимого <> "multipart/form-data" Тогда
		ВызватьИсключениеПроверки("The request value is not multipart content or the Content-Type header is incorrect");
	КонецЕсли; 
	
	Поз = СтрНайти(ПолныйТипСодержимого, "boundary", , Поз + 1);
	Если Поз = 0 Тогда
		ВызватьИсключениеПроверки("The boundary of the multipart content in the Content-Type header is not specified'");
	КонецЕсли; 
	
	Поз = СтрНайти(ПолныйТипСодержимого, "=", , Поз);
	Если Поз = 0 Тогда
		ВызватьИсключениеПроверки("The boundary value of the multipart content in the Content-Type header is not specified");
	КонецЕсли; 
	
	ПозНачалаРазделителя = Поз + 1;
	ПозОкончанияРазделителя = СтрНайти(ПолныйТипСодержимого, ";", , ПозНачалаРазделителя);
	
	Если ПозОкончанияРазделителя = 0 Тогда
		РазделительПолей = СокрЛП(Сред(ПолныйТипСодержимого, ПозНачалаРазделителя));
	Иначе
		КоличествоСимволов = ПозОкончанияРазделителя - ПозНачалаРазделителя;
		РазделительПолей = СокрЛП(Сред(ПолныйТипСодержимого, ПозНачалаРазделителя, КоличествоСимволов));
	КонецЕсли; 
	
	Если Не ЗначениеЗаполнено(РазделительПолей) Тогда
		ВызватьИсключениеПроверки("The boundary value of the multipart content in the Content-Type header is not specified");
	КонецЕсли; 
	
	Возврат "--" + РазделительПолей;
	
КонецФункции 

// Если строка указана в кавычках, то выполняет удаление этих кавычек в начале и конце строки.
// Например, строка "Пример" будет преобразована в Пример (без кавычек).
//
// Параметры:
//  Строка - Строка - строка, указанная в кавычках
// 
// Возвращаемое значение:
//  Строка - строка, переданная в параметре без кавычек.
//
Функция УдалитьОбрамляющиеКавычкиИзСтроки(Строка)
	
	ПервыйСимвол = Лев(Строка, 1);
	ПоследнийСимвол = Прав(Строка, 1);
	
	СтрокаВКавычках = (ПервыйСимвол = """" И ПоследнийСимвол = """");
	
	Возврат ?(СтрокаВКавычках,
				Сред(Строка, 2, СтрДлина(Строка) - 2),
				Строка);
	
КонецФункции 

#КонецОбласти
