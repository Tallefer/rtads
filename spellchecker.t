/* Copyright (c) 2007-2008 ������ ������� aka Flint (nadvoretrava@mail.ru)

                          RTADS spellchecker v1.0

���������� ���� ���� � �����, ��� � ��� ���������� TADS Author's Kit, � �����
������ ���������� ������ � ����� ����, ����� �������� � �� �������� ����������:
#include <spellchecker.t>

� ��� ������ ���� 24 ��� ���� ������ ���������!

�� ���� �������� ����������/����������� �������� "����".
�� ���� �������� ����������/����������� ������ global.spellchecking (true - ��������, nil - ���������).

�� �������� ��������� ������ � ����������� � ������� ����������� � ������� ��� ����������.
*/

modify global
	spellchecking = true;
;

replace additionalPreparsing: function(comStr)
{     
     //��������� ����������
     comStr := checkString(comStr);
    
     return comStr;
};

orfoVerb : sysverb
	verb = 'orfo' '����'
	sdesc = "����"
	
	action(actor) =
	{
		if (global.spellchecking)
		{
			"�������� ���������� ���������. ";
			global.spellchecking := nil;
		}
		else
		{
			"�������� ���������� ��������. ";
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
		  			"��������, �� ����� � ���� <b>&laquo;<<correct>>&raquo;</b>.<br><br>";
				else
			  		"��������, �� ����� � ���� \"<<correct>>\"\b";
			}
		}
	}
	
	return str;
};

spellcheck: function(word)
{
	local ruslet := '�������������������������������';
	local englet := 'abcdefghijklmnopqrstuvwxyz';
	local curlet := ruslet;
	local i, j, k;
	
	local TYPES = [PRSTYP_NOUN PRSTYP_VERB PRSTYP_ADJ];
	local variants = [];
	local found;
	
	//���� ������ 4 �������� ��� ������� 17 ��������, �� �� ������������
	if (length(word) <= 3 || length(word) > 17)
		return nil;

	//������, ���������� �� ��� ����� ��� ���	
	if ( reSearch('[a-z]', word) )
		curlet := englet;
	
	//����������� �����
	for (i := 1; i <= length(curlet); i++)
	{
		for (j := 0; j <= length(word); j++)
		{
			variants += substr(word, 1, j) + substr(curlet, i, 1) + substr(word, j + 1, length(word));
		}
	}
	
	//������ �����
	for (i := 0; i < length(word); i++)
	{
		variants += substr(word, 1, i) + substr(word, i + 2, length(word));
	}
	
	
	//������������ �����
	for (i := 1; i <= length(curlet); i++)
	{
		for (j := 0; j < length(word); j++)
		{
			variants += substr(word, 1, j) + substr(curlet, i, 1) + substr(word, j + 2, length(word));
		}
	}
	
	//������������ ������� �����
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
