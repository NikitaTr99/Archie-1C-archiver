#Использовать InternetMail
//Общие переменные
Перем параметрПутьКБД;
Перем конфигКолличествоКопий;
Перем файлКонфигурации;
Перем уровеньСжатия;
Перем часКритерий;

//Локальный режим
Перем параметрПутьКСохранениюАрхива;

//Облачный режим
Перем СсылкаАвторизацииСбердиска;
Перем СсылкаЛогинаИПароля;

Перем ЭтоАрхивацияВОблако;

Перем ЛогинСбердиска;
Перем ПарольСбердиска;

Перем БукваДиска;
Перем СетевоеРасположение;



Процедура ПриНачалеРаботыСистемы()
	Инициализация();
	ПроверитьБазыКАрхивации(параметрПутьКБД);
	Очистка();
	Если ЭтоАрхивацияВОблако Тогда
		ЗапуститьПриложение("net use " + БукваДиска + ": /DELETE");
	КонецЕсли;
КонецПроцедуры

Процедура Инициализация()

	СсылкаАвторизацииСбердиска = "https://files.sberdisk.ru/login/v2";
	СсылкаЛогинаИПароля = "https://files.sberdisk.ru/login/v2/poll";

	БукваДиска = "Z";
	СетевоеРасположение = БукваДиска + ":\";

	Аргумент = АргументыКоманднойСтроки[0];
	Если Найти(Аргумент, "local") Тогда
		ЭтоАрхивацияВОблако = Ложь;
		ИнициализироватьЛокальныйРежим();
	ИначеЕсли Найти(Аргумент, "cloud") Тогда
		ЭтоАрхивацияВОблако = Истина;
		ИнициализироватьОблачныйРежим();
	ИначеЕсли Найти(Аргумент, "-h") Тогда
		Сообщить("archie.exe [режим]" + Символы.ПС +
		"	local - Локальный режим архивации." + Символы.ПС +
		"	cloud - Архивация в облако Яндекс.Диск");
		ЗавершитьРаботу(0);
	Иначе
		Сообщить("Неизвестный аргумент - " + Аргумент);
		ЗавершитьРаботу(0);
	КонецЕсли;

КонецПроцедуры

Процедура ИнициализироватьЛокальныйРежим()

	ПутьКФайлуКонфигурации = "arch.cfg";
	Счётчик = 1;
	Пока Счётчик < АргументыКоманднойСтроки.Количество() Цикл
		Аргумент = АргументыКоманднойСтроки[Счётчик];
		Если Найти(Аргумент, "-i") Тогда
			Счётчик = Счётчик + 1;
			параметрПутьКБД = Новый Файл(АргументыКоманднойСтроки[Счётчик]);
		ИначеЕсли Найти(Аргумент, "-o") Тогда
			Счётчик = Счётчик + 1;
			параметрПутьКСохранениюАрхива = Новый Файл(АргументыКоманднойСтроки[Счётчик]);
		ИначеЕсли Найти(Аргумент, "-c") Тогда
			Счётчик = Счётчик + 1;
			конфигКолличествоКопий = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-hr") Тогда
			Счётчик = Счётчик + 1;
			часКритерий = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-z") Тогда
			Счётчик = Счётчик + 1;
			уровеньСжатияСтрока = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-cfg") Тогда
			Счётчик = Счётчик + 1;
			ПутьКФайлуКонфигурации = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-h") Тогда
			Счётчик = Счётчик + 1;
			Сообщить("archie.exe local -i <значение> -o <значение> -c <значение> -hr <значение> -z [максимальный|минимальный|оптимальный]" + Символы.ПС +
			"	-i - Путь к папке с БД 1с." + Символы.ПС +
			"	-o - Путь к папке с архивами БД (Если такой нет, то будет создана)" + Символы.ПС +
			"	-c - Количество копий БД." + Символы.ПС +
			"	-hr - Количество часов с момента прошлого изменения БД для архивации." + Символы.ПС +
			"	-z - Уровень архивации (значения: [максимальный|минимальный|оптимальный])" + Символы.ПС +
			"	-cfg - файл архивации (необязательно)" + Символы.ПС +
			"	-h - Справка.");
			ЗавершитьРаботу(0);
		КонецЕсли;
		Счётчик = Счётчик + 1;
	КонецЦикла;

	файлКонфигурации = новый Файл(ПутьКФайлуКонфигурации);

	Если уровеньСжатияСтрока <> Неопределено И Нрег(уровеньСжатияСтрока) = "максимальный" Тогда
		уровеньСжатия = УровеньСжатияZIP.Максимальный;
	ИначеЕсли Нрег(уровеньСжатияСтрока) = "минимальный" Тогда
		уровеньСжатия = УровеньСжатияZIP.Минимальный;
	ИначеЕсли Нрег(уровеньСжатияСтрока) = "оптимальный" Тогда
		уровеньСжатия = УровеньСжатияZIP.Оптимальный;
	Иначе
		Сообщить("Неизвестный уровень сжатия. Выбран параметр по умолчанию - оптимальный");
		уровеньСжатия = УровеньСжатияZIP.Оптимальный;
	КонецЕсли;

КонецПроцедуры

Процедура ИнициализироватьОблачныйРежим()

	ПутьКФайлуКонфигурации = "arch.cfg";

	Счётчик = 1;
	Пока Счётчик < АргументыКоманднойСтроки.Количество() Цикл
		Аргумент = АргументыКоманднойСтроки[Счётчик];
		Если Найти(Аргумент, "-i") Тогда
			Счётчик = Счётчик + 1;
			параметрПутьКБД = Новый Файл(АргументыКоманднойСтроки[Счётчик]);
		ИначеЕсли Найти(Аргумент, "-o") Тогда
			Счётчик = Счётчик + 1;
			параметрПутьКСохранениюАрхива = новый Файл(СетевоеРасположение + АргументыКоманднойСтроки[Счётчик]);
		ИначеЕсли Найти(Аргумент, "-c") Тогда
			Счётчик = Счётчик + 1;
			конфигКолличествоКопий = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-hr") Тогда
			Счётчик = Счётчик + 1;
			часКритерий = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-z") Тогда
			Счётчик = Счётчик + 1;
			уровеньСжатияСтрока = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-cfg") Тогда
			Счётчик = Счётчик + 1;
			ПутьКФайлуКонфигурации = АргументыКоманднойСтроки[Счётчик];
		ИначеЕсли Найти(Аргумент, "-d") Тогда
			Счётчик = Счётчик + 1;
			БукваДиска = АргументыКоманднойСтроки[Счётчик];
			СетевоеРасположение = АргументыКоманднойСтроки[Счётчик] + ":\";
		ИначеЕсли Найти(Аргумент, "-h") Тогда
			Счётчик = Счётчик + 1;
			Сообщить("archie.exe cloud -i <значение> -o <значение> -c <значение> -hr <значение> -z [максимальный|минимальный|оптимальный]" + Символы.ПС +
			"	-i - Путь к папке с БД 1с." + Символы.ПС +
			"	-d - Буква облачного диска (Строго до -o, Z по умолчанию)" + Символы.ПС +
			"	-o - Путь к папке с архивами БД на удалённом облаке (\path\to\backups)" + Символы.ПС +
			"	-c - Количество копий БД." + Символы.ПС +
			"	-hr - Количество часов с момента прошлого изменения БД для архивации." + Символы.ПС +
			"	-z - Уровень архивации (значения: [максимальный|минимальный|оптимальный])" + Символы.ПС +
			"	-cfg - файл архивации (необязательно)" + Символы.ПС +
			"	-h - Справка.");
			ЗавершитьРаботу(0);
		КонецЕсли;
		Счётчик = Счётчик + 1;
	КонецЦикла;

	Сообщить(СетевоеРасположение);

	файлКонфигурации = новый Файл(ПутьКФайлуКонфигурации);

	Если НЕ файлКонфигурации.Существует() Тогда
		Сообщить("Ошибка. Файл конфигурации не найден.");
		ЗавершитьРаботу(0);
	КонецЕсли;

	ЛогинСбердиска = ПолучитьЗначениеКонфигурацииПоКлючу("СберЛогин");
	ПарольСбердиска = ПолучитьЗначениеКонфигурацииПоКлючу("СберПароль");

	Если ЛогинСбердиска = Неопределено ИЛИ ПарольСбердиска = Неопределено Тогда
		ИнициализацияСбердиска();
	КонецЕсли;

	ОблачныйДиск = новый Файл(СетевоеРасположение);
	Если НЕ ОблачныйДиск.Существует() Тогда
		СоздатьДиск(ЛогинСбердиска, ПарольСбердиска);
	КонецЕсли;


	Если уровеньСжатияСтрока <> Неопределено И Нрег(уровеньСжатияСтрока) = "максимальный" Тогда
		уровеньСжатия = УровеньСжатияZIP.Максимальный;
	ИначеЕсли Нрег(уровеньСжатияСтрока) = "минимальный" Тогда
		уровеньСжатия = УровеньСжатияZIP.Минимальный;
	ИначеЕсли Нрег(уровеньСжатияСтрока) = "оптимальный" Тогда
		уровеньСжатия = УровеньСжатияZIP.Оптимальный;
	Иначе
		Сообщить("Неизвестный уровень сжатия. Выбран параметр по умолчанию - оптимальный");
		уровеньСжатия = УровеньСжатияZIP.Оптимальный;
	КонецЕсли;
КонецПроцедуры

Процедура ИнициализацияСбердиска()

	HTTPСоединение = Новый HTTPСоединение(СсылкаАвторизацииСбердиска,,,,,10);
	ЗапросТокена = Новый HTTPЗапрос(СсылкаАвторизацииСбердиска);
	РезультатЗапросаТокена = HTTPСоединение.ОтправитьДляОбработки(ЗапросТокена);


	ДанныеЗапросаТокена = ЧтениеJSON(РезультатЗапросаТокена.ПолучитьТелоКакСтроку());

	Токен = ДанныеЗапросаТокена.poll.token;

	Сообщить("Перенаправление на страницу авторизации. После авторизации нажмите клавижу ввода.");

	ЗапуститьПриложение(ДанныеЗапросаТокена.login);

	Строка = "";
	ВвестиСтроку(Строка);

	СсылкаЛогинаИПароляСТокеном = СсылкаЛогинаИПароля + "?token=" + Токен;
	HTTPСоединение = Новый HTTPСоединение(СсылкаЛогинаИПароляСТокеном,,,,,10);
	ЗапросЛогинаИПароля = Новый HTTPЗапрос(СсылкаЛогинаИПароляСТокеном);
	РезультатЗапросаЛогинаИПароля = HTTPСоединение.ОтправитьДляОбработки(ЗапросЛогинаИПароля);
	ДанныеЗапросаЛогинаИПароля = ЧтениеJSON(РезультатЗапросаЛогинаИПароля.ПолучитьТелоКакСтроку());

	Логин = ДанныеЗапросаЛогинаИПароля.loginName;
	Пароль = ДанныеЗапросаЛогинаИПароля.appPassword;

	ДобавитьВКонфигурацию("СберЛогин", Логин);
	ДобавитьВКонфигурацию("СберПароль", Пароль);

	Если Логин = Неопределено ИЛИ Пароль = Неопределено Тогда
		Сообщить("Ошибка авторизации");
		ЗавершитьРаботу(0);
	КонецЕсли;

	Сообщить("Добавте новый элемент сетевого рачпроложения через проводник используя следующие данные. По завершению нажмите ввод.");
	Сообщить("Сетеой адрес: https://files.sberdisk.ru/remote.php/dav/files/" + Логин);
	Сообщить("Логин: " + Логин);
	Сообщить("Пароль: " + Пароль);

	ВвестиСтроку(Строка);

	СоздатьДиск(Логин, Пароль);

КонецПроцедуры

Процедура СоздатьДиск(Логин, Пароль)
	КодВозврата = Неопределено;
	ЗапуститьПриложение("net use "+ БукваДиска +": https://files.sberdisk.ru/remote.php/dav/files/"+ Логин +" "+ Пароль +" /USER:"+ Логин +" /PERSISTENT:YES",,Истина,КодВозврата);
	Если КодВозврата > 0 Тогда
		СообщитьПоИмейлу();
		ЗавершитьРаботу(1);
	КонецЕсли;
КонецПроцедуры

Процедура ПроверитьБазыКАрхивации(входящийКаталог)
	маркерБд = НайтиФайлы(входящийКаталог.ПолноеИмя, "*.1cd");
	Если НЕ ЗначениеЗаполнено(маркерБд) Тогда
		папкиВходящегоКаталога = НайтиФайлы(входящийКаталог.ПолноеИмя, "*");
		Для каждого каталог Из папкиВходящегоКаталога Цикл
			Если каталог.ЭтоКаталог() Тогда
				ПроверитьБазыКАрхивации(каталог);
			КонецЕсли;
		КонецЦикла;
		Иначе
			ПроверитьУсловиеИАрхивировать(входящийКаталог);
	КонецЕсли;
КонецПроцедуры

Процедура ПроверитьУсловиеИАрхивировать(каталогБд)
    мВремяИзменения = каталогБд.ПолучитьВремяИзменения();
	мСекундыТаймаута = 60 * 60 * Число(часКритерий);
	мИзменениеСТаймаутом = мВремяИзменения + мСекундыТаймаута;
	Если ТекущаяДата() < мИзменениеСТаймаутом Тогда
		Сообщить("К архивации: " + каталогБд.ПолноеИмя);
		Архивировать(каталогБд);
	КонецЕсли;
КонецПроцедуры

//Принимает перменную типа Файл
Процедура Архивировать(архивируемыйКаталог)
	имяКаталогаИФайла = архивируемыйКаталог.Имя;
	контекстныйКаталогАрхивов = Новый Файл(параметрПутьКСохранениюАрхива.ПолноеИмя + "\" + имяКаталогаИФайла);

	Попытка
	Если НЕ контекстныйКаталогАрхивов.Существует() Тогда
		СоздатьКаталог(контекстныйКаталогАрхивов.ПолноеИмя);
	КонецЕсли;

	файлАрхива = СоздатьВременныйАрхив(архивируемыйКаталог, КаталогВременныхФайлов());

		КопироватьФайл(файлАрхива.ПолноеИмя, контекстныйКаталогАрхивов.ПолноеИмя + "\" + файлАрхива.Имя);
	Исключение
		СообщитьПоИмейлу();
		ЗавершитьРаботу(2);
	КонецПопытки;


КонецПроцедуры

Функция СоздатьВременныйАрхив(АрхивируемыйФайл, КаталогАрхивации)
	ДатаАрхивации = Формат(МестноеВремя(ТекущаяУниверсальнаяДата()), "ДФ=гггг.ММ.дд_ЧЧ-мм-сс");
	ПутьКВременномуАрхиву = КаталогАрхивации + АрхивируемыйФайл.Имя + "_" + ДатаАрхивации + ".zip";
	архив = Новый ЗаписьZipФайла(ПутьКВременномуАрхиву, уровеньСжатия);
	архив.Добавить(АрхивируемыйФайл.ПолноеИмя, РежимСохраненияПутейZIP.СохранятьОтносительныеПути, РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
	архив.Записать();
	Возврат новый Файл(ПутьКВременномуАрхиву);
КонецФункции

Процедура Очистка()
	Если параметрПутьКСохранениюАрхива.Существует() Тогда
		МассивКаталогов = НайтиФайлы(параметрПутьКСохранениюАрхива.ПолноеИмя, "*");
		Для Каждого Каталог Из МассивКаталогов Цикл
			МассивАрхивов = НайтиФайлы(Каталог.ПолноеИмя, "*.zip");
			Если МассивАрхивов.Количество() > Число(конфигКолличествоКопий) Тогда
				количествоКУдалению = МассивАрхивов.Количество() - Число(конфигКолличествоКопий) - 1;
				Для Сч = 0 По количествоКУдалению Цикл
					архивКУдалению = МассивАрхивов.Получить(Сч);
					УдалитьФайлы(архивКУдалению.ПолноеИмя);
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры


//////////////////////////////////////////////////////////////////
//Служебное
//////////////////////////////////////////////////////////////////
Функция УбратьКовычкиВПути(ПутьСтрока)
	Возврат СтрЗаменить(ПутьСтрока, """", "");
КонецФункции

Функция ПолучитьЗначениеКонфигурацииПоКлючу(ключ)

	Если файлКонфигурации.Существует() Тогда
		прочитанныйТекст = Новый ЧтениеТекста(файлКонфигурации.ПолноеИмя, КодировкаТекста.UTF8);
		строкаТекстовогоФайла = "";
		значение = Неопределено;
		Пока строкаТекстовогоФайла <> Неопределено Цикл
			строкаТекстовогоФайла = ПрочитанныйТекст.ПрочитатьСтроку();
			Если СтрНачинаетсяС(строкаТекстовогоФайла, ключ) Тогда
				разложеннаяСтрока = РазложитьСтрокуНаПодстроки(строкаТекстовогоФайла, "=");
				значение = разложеннаяСтрока[1];
			КонецЕсли;
		КонецЦикла;
			прочитанныйТекст.Закрыть();
	КонецЕсли;

	Возврат значение;

КонецФункции

Процедура ДобавитьВКонфигурацию(Ключ, Значение)

	Строка = Ключ + "=" + Значение;

	Если НЕ файлКонфигурации.Существует() Тогда
		ПутьКонфигурации = "arch.cfg";
	Иначе
		ПутьКонфигурации = файлКонфигурации.ПолноеИмя;
	КонецЕсли;
	Текст = Новый ТекстовыйДокумент();
	Текст.Прочитать(ПутьКонфигурации);
	Если ПолучитьЗначениеКонфигурацииПоКлючу(Ключ) <> Неопределено Тогда
		Счётчик = 0;
		Пока Счётчик < Текст.КоличествоСтрок() Цикл
			тмпСтрока = Текст.ПолучитьСтроку(Счётчик);
			Если СтрНачинаетсяС(тмпСтрока, Ключ) Тогда
				Текст.ЗаменитьСтроку(Счётчик, Строка);
			КонецЕсли;
			Счётчик = Счётчик + 1;
		КонецЦикла;
	Иначе
		Текст.ДобавитьСтроку(Строка);
	КонецЕсли;

	Текст.Записать(ПутьКонфигурации);

КонецПроцедуры

Функция РазложитьСтрокуНаПодстроки(ВходящаяСтрока, Разделитель)

	МассивСтрок = Новый Массив();
	ВходящаяСтрока = СтрЗаменить(ВходящаяСтрока, Разделитель, Символы.ПС);

	Для ИндексСтроки = 1 По СтрЧислоСтрок(ВходящаяСтрока) Цикл
		Подстрока = СтрПолучитьСтроку(ВходящаяСтрока, ИндексСтроки);
		МассивСтрок.Добавить(Подстрока);
	КонецЦикла;

	Возврат МассивСтрок;

КонецФункции

Функция ЧтениеJSON(Строка)

	ЧтениеJSON = Новый ЧтениеJSON;
    ЧтениеJSON.УстановитьСтроку(Строка);
	Возврат ПрочитатьJSON(ЧтениеJSON);

КонецФункции

Процедура СообщитьПоИмейлу()
	ЗапуститьПриложение(ПолучитьКомандуДляПочтовойОправки());
	Сообщить("ОШИБКА!!!!!");
КонецПроцедуры


Функция ПолучитьКомандуДляПочтовойОправки()
	хостЗначение = " -host:" + ПолучитьЗначениеКонфигурацииПоКлючу("логинПочты") + ":" +  ПолучитьЗначениеКонфигурацииПоКлючу("внешнийПароль") + "@smtp.mail.ru"; 
	почтаОтправителя = " -from:" + ПолучитьЗначениеКонфигурацииПоКлючу("почтаОтправителя");
	почтаПолучателя = " -to:" + ПолучитьЗначениеКонфигурацииПоКлючу("почтаПолучателя");
	темаСообщения = " -subject:" + ПолучитьЗначениеКонфигурацииПоКлючу("темаСообщения");
	текстСообщения = " -body:" + ПолучитьЗначениеКонфигурацииПоКлючу("текстСообщения");

	командаОтправленияАрхивов = "cmail.exe" + хостЗначение + почтаОтправителя +
		почтаПолучателя + темаСообщения + текстСообщения + " -starttls";
		Сообщить(хостЗначение);
	Возврат командаОтправленияАрхивов;
КонецФункции

ПриНачалеРаботыСистемы();