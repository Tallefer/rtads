/* Copyright (c) 2007-2008 Михаил Гранкин aka Flint (nadvoretrava@mail.ru)

                          RTADS spellchecker v1.0

Скопируйте этот файл в папку, где у вас установлен TADS Author's Kit, а потом
просто подключите модуль к своей игре, чтобы добавить в неё проверку орфографии:
#include <spellchecker.t>

У вас должна быть 24 или выше версия библиотек!

Из игры проверка включается/выключается командой "орфо".
Из кода проверка включается/выключается флагом global.spellchecking (true - включена, nil - выключена).

Не забудьте поставить игрока в известность о наличии спеллчекера и способе его отключения.
*/

modify global
	spellchecking = true;
;

replace additionalPreparsing: function(comStr)
{     
     //Проверяем орфографию
     comStr := checkString(comStr);
    
     return comStr;
};

orfoVerb : sysverb
	verb = 'orfo' 'орфо'
	sdesc = "орфо"
	
	action(actor) =
	{
		if (global.spellchecking)
		{
			"Проверка орфографии отключена. ";
			global.spellchecking := nil;
		}
		else
		{
			"Проверка орфографии включена. ";
			global.spellchecking := true;
		}
	}
;

checkString: function(str)
{
	local wordlist, typelist;
	local i;
	local correct, pos;
	
	if (not global.spellchecking)
		return str;
	
	wordlist := parserTokenize(str);
	typelist := parserGetTokTypes(wordlist);
	
	for (i := 1; i <= length(typelist); i++)
	{	
		if ((typelist[i] & PRSTYP_UNKNOWN) != 0)
		{
			correct := spellcheck(wordlist[i]);
			if (correct)
			{
				pos := reSearch(wordlist[i], lower(str));
				str := substr(str, 1, pos[1] - 1) + correct + substr(str, pos[1] + pos[2], length(str));

				if (systemInfo(__SYSINFO_SYSINFO) = true && systemInfo(__SYSINFO_HTML) = 1)
		  			"Возможно, вы имели в виду <b>&laquo;<<correct>>&raquo;</b>.<br><br>";
				else
			  		"Возможно, вы имели в виду \"<<correct>>\"\b";
			}
		}
	}
	
	return str;
};

spellcheck: function(word)
{
	local ruslet := 'абвгдежзиклмнопрстуфхцчшщьыъэюя';
	local englet := 'abcdefghijklmnopqrstuvwxyz';
	local curlet := ruslet;
	local i, j, k;
	
	local TYPES = [PRSTYP_NOUN PRSTYP_VERB PRSTYP_ADJ];
	local variants = [];
	local found;
	
	//Если короче 4 символов или длиннее 17 символов, то не обрабатываем
	if (length(word) <= 3 || length(word) > 17)
		return nil;

	//узнаем, английский ли это текст или нет	
	if ( reSearch('[a-z]', word) )
		curlet := englet;
	
	//пропущенные буквы
	for (i := 1; i <= length(curlet); i++)
	{
		for (j := 0; j <= length(word); j++)
		{
			variants += substr(word, 1, j) + substr(curlet, i, 1) + substr(word, j + 1, length(word));
		}
	}
	
	//лишние буквы
	for (i := 0; i < length(word); i++)
	{
		variants += substr(word, 1, i) + substr(word, i + 2, length(word));
	}
	
	
	//неправильные буквы
	for (i := 1; i <= length(curlet); i++)
	{
		for (j := 0; j < length(word); j++)
		{
			variants += substr(word, 1, j) + substr(curlet, i, 1) + substr(word, j + 2, length(word));
		}
	}
	
	//перепутанные местами буквы
	for (i := 0; i < length(word) - 1; i++)
	{
		variants += substr(word, 1, i) + substr(word, i + 2, 1) + substr(word, i + 1, 1) + substr(word, i + 3, length(word));
	}
	
	for (i := 1; i <= length(TYPES); i++)
	{
		for (j := 1; j <= length(variants); j++)
		{
			found := parserDictLookup([] + variants[j], [] + TYPES[i]);
						
			for (k := 1; k <= length(found); k++)
			{
				if (TYPES[i] = PRSTYP_VERB)
					return variants[j];

				if ( found[k].isVisible(parserGetMe()) )
					return variants[j];
			}
		}
	}
	
	return nil;
};
