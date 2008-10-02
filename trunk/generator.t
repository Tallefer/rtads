/* 
*   БИБЛИОТЕКА ГЕНЕРАТОРА ПАДЕЖЕЙ
*   требует функции 25 релиза библиотек TADS   
*   основная часть -GrAnd, 
*   отдельные моменты - Flint, Fireton
*/

#define GENERATOR_INCLUDED

#define _ON	isHim = true
#define _ONA    isHer = true

#define EDINS	                1
#define MNOZH	        2
#define MUZHR	        4
#define ZHENR	        8
#define SREDR	        12
#define SUSHE	        16
#define PRILA	                32
#define ODUSH	        64
#define UDARE	        128
#define ISDESC	        256
#define RETDET	        512


// ВНЕДРЕНИЕ ГЕНЕРАТОРА В КОД
// после проверки автором, вывод нужно отключить
generation: function
{   
   // вывод только в режиме отладки
#ifdef __DEBUG
   // вывод кода генерации. Закомментировать после проверки
    generator.printout:=true;
   // вывод использованных правил
   // generator.detailed:=true;
#endif
   
   generator.start;
}

// ОБРАЗЕЦ ИСПОЛЬЗОВАНИЯ
// Для того, чтобы генератор начал обработку, необходимо включить
// в лексему символ "/". После него могут идти флаги с указанием рода
// и числа, так как они могут отличаться от заданных в объекте.
// "M"(англ) и "М"(русская) - Мужской род
// "F" и  "Ж" - Женский род
// "N" и "С"(рус), а также "МЖ" вместе - Средний род
// "1" - единственное число
// "2" - множественное число. Вместе с 1 не указывать.
// "A"(англ) или "П" - Прилагательное (Adjective)
// "У" - сУществительное (Noun) - редко прописывается вручную
// "I" или "О" (русская) - Одушевленный (anImated)
//  Ударное окончание задаётся прописной буквой (или флагами "д" или "u")
// флаги можно писать строчными буквами

/*
testobj: item
desc='странный/1мп предмет/1м из иного/п- мира/п-'
adjective = 'плоский/1м'  'акульи/2'
noun='воблы/й' 'крюки/м2' 'рука/1ж' 'вилы/2' 'щепочка/1ж' 'быстрая/п1ж' 'блоха/ж' 'муравьИ/2ом'
isHer=true
isThem=true
;
*/

// Вносим изменения в класс объекта
modify thing
descs=nil
replace sdesc={if (descs) "<<descs[1]>>"; else pass sdesc;}
replace rdesc={if (descs) "<<descs[2]>>"; else pass rdesc;}
replace ddesc={if (descs) "<<descs[3]>>"; else pass ddesc;}
replace vdesc={if (descs) "<<descs[4]>>"; else pass vdesc;}
replace tdesc={if (descs) "<<descs[5]>>"; else pass tdesc;}
replace pdesc={if (descs) "<<descs[6]>>"; else pass pdesc;}
;

class genobj: object
sdesc="<<descs[1]>>"
rdesc="<<descs[2]>>"
ddesc="<<descs[3]>>"
vdesc="<<descs[4]>>"
tdesc="<<descs[5]>>"
pdesc="<<descs[6]>>"
;

//modify fixeditem: genobj
//;

// ОБЪЕКТ ГЕНЕРАТОРА ПАДЕЖЕЙ
// Хранит правила склонений и содержит необходимые методы
// для массовой и одиночной генерации
generator: object

// выдовать ли на печать результат генерации
printout =nil

// выводить номера применённых правил
#ifdef _GENDETAILED && _DEBUG
detailed =true
#else
detailed =nil
#endif

// задаем символьные множества
symbols=
    [['0' '[бвдзлмнпрстфц]'] 
    ['1' '[еуюа]'] 
    ['2' '[бвдзлмпрсфц]']
    ['3' '[бвгджзнрц]']                       //звонкие
    ['4' '[чшщц]']                                //шипящие
    ['6' '[бвгджзйклмнпрстфхцчшщ]']     //согласные
    ['8' '[аеёиоуыэюя]']                        //гласные
  ]

// чисто для порядка - именительный
irules = []


// правила для родительного падежа
// здесь и далее,
// требования к грам. свойствам слова, шаблон и схема замены
// числа -символьные множества
// Грам. флаги в правилах - только английские заглавные
rrules =
    [
    ['2F'    'йки'  	'ек']
    ['2F'    '(4)ки'  	'$1ек']     // болячки
    ['2F'    '(6)ки'  	'$1ок']     //6 согл
    ['2F'    'ки'   	'к']
    ['2M'    'ки'   	'ков']
    ['2F'    '(6)ги'  	'$1ог']
    ['2F'    'ги'   	'г']
    ['2'     'ги'   	'гов']
    ['2F'    '(у6)и' 	'$1']
    ['F'     'ка' 	'ки']
    ['2F'    '(.)ы'  	'$1']
    ['2'     'кна'  	'кон']
    ['2FU'   '(4)и'     '$1ей']	     // вЕщи->вещЕй, нОчи - ночЕй
    ['2F'    '(4)и'     '$1']	     // клячи, кучи
    ['2U'    '(8)и' 	'$1ёв']      // боИ  (8- гласные)
    ['2F'    '(8)и'	'$1й']       // стаи, змеи, линии, струи     
    ['2'     'ца'  	'ец']	     // коленца
    ['2F'    '(6)ли' 	'$1ель']     // капли (6 - согл)
    ['2U'    'ьи'	'ьёв']       // воробьИ, муравьИ
    ['2F'    'ы'  	'']          // соты, лисы (как записать не имеющих ед. числа?)    
    ['2U'    '(4|ж)и'   '$1ей']      // лучИ, ножИ, хлыщИ
    ['2U'    'и'  	'ов']        // пирогИ
  ]


// дательный
drules = []


// винительный
// мужской одушелвенный автоматически приравнивается родительному,
// и поэтому тут не прописывается
vrules =
[
  ['2FI' 'йки'  'ек']	   // канарейки
  ['2FI' '(4)ки'  '$1ек']  // казАчки
  ['2FI' '(0)ки'  '$1ок']  //
  ['2FI'  'ки'   'к']	   // собаки
  //['2I'  'ки'   'ков']     // моряки
  //['2M'    'ки'   'ки']    // крюки
  ['2FI' '(6)ги'  '$1ог']
  ['2FI'  'ги'  'г']
  ['2I'   'ги'   'гов']
  ['2UI' 'ьи' 'ьёв']
  //['1MI' 'ь' 'я']
  ['I'	'ий' 'его']
]


// творительный
trules=
[
   ['U'  '(4|ж)а' '$1ой']	// U - ударение, 4 - шипящие
   [''  '(4|ж)а' '$1ей']
   ['A'  '(4|ж)ой' '$1им']
   ['U' '(8[бвгджзйкмнпрстфхцчшщ])ец' '$1цом']
]


// творительный2 - украинизированная или литературная форма
trules2=
[  
  ['1U'	'(4|ж)а'	'$1ою']	//маржою
  ['1'	'(4|ж)а'	'$1ею'] //жижею
  ['1'	'а'	'ою']		//лисою
  [''	'(4|ж)ая'	'$1ею'] //рыжая, куцая
  [''	'ая'	'ою']           //толстая
  [''	'яя'	'ею']           //последняя  
  ['1U' 'я'	'ёю']           //стезЯ
  ['1F'	'я'	'ею']           //пуля
]


// предложный падеж
prules = []

// В разбиении нет особой логики, просто последовательно разделил, чтобы анализируемый
// массив укладывался в заданный по умолчанию размер буфера разборщика 
// Если при добавлении правил будет появляться ошибка, разбейте на меньшие фрагменты

// вид: требования к грам. свойствам слова, шаблон, 5 схем замены для склонений, кроме
// инменительного + комментарий (опционально)

commonrules1 =
// Множественное число существительных на -а:
[['2'	'ена'	'ён'	'енам'	'ена'	'енами'	'енах'],  // письмена
['2'	'ёна'	'ён'	'ёнам'	'ёна '	'ёнами'	'ёнах'],  // знамёна
['2'	'(6)на'	'$1ен'	'$1нам'	'$1на'	'$1нами' '$1нах'],  // брёвна, 6 -согл.

['2'	'та'	'т'	'там'	'та'	'тами'	'тах'],     // ребята, (т.ж. ворота,корыта)
['2M'	'а'	'ов'	'ам'	'а'	'ами'	'ах'],     // дома
['2'	'а'	''	'ам'	'а'	'ами'	'ах'],     // гнёзда

[''	'(0)а'  '$1ы'   '$1е'    '$1у'  '$1ой'   '$1е']    //бвдзлмнпрстфц
[''	'а'   'и'    'е'	'у'   'ой'   'е']
]
//8  - количество правил в блоке

commonrules2 = 
// все на -я
[[''	'мя'  'мени' 'мени'  'мя'  'менем' 'мени']   // время
['U'	'(4|ж)ая'  '$1ой' '$1ой'   '$1ую' '$1ой'  '$1ой']     // шипящие и 'ж' + 'ая' с ударением
[''	'(4|ж)ая'  '$1ей' '$1ей'   '$1ую' '$1ей'  '$1ей']     // шипящие и 'ж' + 'ая'
[''	'ая'  'ой'  'ой'  'ую'  'ой'   'ой']     // остальные прил. на -ая']
[''	'яя'   'ей'   'ей'   'юю'   'ей'   'ей']     // прил. на -яя + преисподняя
['2'	'ья'   'ьев'   'ьям'   'ья'   'ьями'   'ьях']   // клочья, перья
['2'	'ия'   'ий'   'иям'   'ия'   'иями'   'иях']  // покрытия
[''	'ия'   'ии'   'ии'   'ию'   'ией'   'ии']  // существительные на -ия
['U'	'я'   'и'   'е'   'ю'   'ёй'   'е']
[''	'я'   'и'   'е'   'ю'   'ей'   'е']
]
// 10

commonrules3 =
// на -й
[['n'	'ой'   'оя'   'ою'   'ой'   'оем'   'ое']  //ковбой
[''	'ой'   'ого'   'ому'   'ой'   'ым'   'ом']  //злой
[''	'(1)й'   '$1я'   '$1ю'   '$1й'   '$1ем'   '$1е']	// еуюа
[''	'ый'   'ого'   'ому'   'ый'   'ым'   'ом']
['n'	'ий'   'ия'   'ию'   'ий'   'ием'   'ии']
[''	'(к)ий'   '$1ого'   '$1ому'   '$1ий'   '$1им'   '$1ом']  // плоский
[''	'ий'   'его'   'ему'   'ий'   'им'   'ем']
[''	'й'   'и'   'и'   'й'   'ем'   'е']
]
// 8

commonrules4 =
// на о
[[''	'(6)о'   '$1а'   '$1у'   '$1о'   '$1ом'   '$1е']  // (6 - согл.)
[''	'о'   'о'   'у'   'о'   'ом'   ' е']	
    
// на -е    
[''	'(ц|щ)е'   '$1а'   '$1у'   '$1е'   '$1ем'   '$1е']   //сердце, чудище
[''	'(0)ое'   '$1ого' '$1ому' '$1ое' '$1ым'   '$1ом'] // прил., на тв. согл. (бвдзлмнпрстфц)
[''	'ое'   'ого'   'ому'   'ое'   'им'   'ом'] // прил., на м. согл.
// делимое?
[''	'(е|ё)е'   '$1го'   '$1му'   '$1е'   'им'   'ем']  
['2'	'(и|ы)е' '$1х' '$1м' '$1е' '$1ми' '$1х']
[''	'ие'   'ия'   'ию'   'ие'   'ием'   'ие']  // рвение, бдение
[''	'ье'   'ья'   'ью'   'ье'   'ьем'   'ье']  // раздолье
[''	'ьё'   'ья'   'ью'   'ье'   'ьём'   'ье']  // враньё
[''	'це'   'ца'   'цу'   'це'   'цем'   'це']
['2'	'ые'   'ых'   'ым'   'ые'   'ыми'   'ых']
[''	'(4)е'   '$1а'   '$1у'   '$1е'   '$1ем'   '$1е']
[''	'([рль])е'   '$1я'   '$1ю'   '$1е'   '$1ем'   '$1е']
]
//14 - 40

commonrules5 =
// -ё
[[''	'(6)ё'   '$1я'   '$1ю'   '$1й'   'ём'   '$1е']
[''	'ё'   'ё'   'ё'   'ё'   'ём'   'е'] 

// на -ь    
['F'	'ь'   'и'   'и'   'ь'   'ью'   'и']
// беглая гласная "е" и "о"
// -ень,-оть щебень, стержень, ломоть, лапоть, коготь; всего более 30-ти 
// но!!! -олень, тюлень, окунь, пельмень, бюллетень, ясень, ячмень (это почти все)
['M'	'ень'   'ня'   'ню'   'ень'   'нем'   'не']
['M'	'оть'   'тя'   'тю'   'оть'   'тем'   'те']
// Исключения, беглые гласные. Когда-то был огнь, угль и угрь. Угря не ввожу. 
['M'	'огонь'   'огня'   'огню'   'огонь'   'огнём'   'огне']
['M'	'уголь'   'угля'   'углю'   'уголь'   'углём'   'угле']
[''	'ь'   'я'   'ю'   'ь'   'ем'   'е']
]
// 8

commonrules6 =
// на -и
[['2A'	'ьи'   'ьих'   'ьим'   'ьи'   'ьими'   'ьих']     //козьи
['2F'	'ьи'   'ей'   'ьям'   'ьи'   'ьями'   'ьях']
['2F'	'(4|ж|й)ки' '$1ек'   '$1кам'   '$1ки' '$1ками'   '$1ках']  // (4 - шипящие)
['2F'	'ли'   'ль'   'лям'   'ли'   'лями'   'лях']   // дули

['2'	'(8|ь)и'   '$1ев'   '$1ям'   '$1и'   '$1ями'   '$1ях']  // 8 - гл-ые, ульи 
['2'	'(4|ж)и'   '$1'   '$1ам'   '$1и'   '$1ами'   '$1ах' 'Важно ударение! (р.п.)']  // тучи, мощи, ножи
['2'	'(0)и'   '$1ей'   '$1ям'   '$1и'   '$1ями'   '$1ях']  // бвдзлмнпрстфц 

//гкх. оплеУхи, пирОги, лодки; лОхи->лохОв 
['2'	'и'   ''   'ам'   'и'   'ами'   'ах' 'Важно ударение! (р.п.)'] 
// все -ы: болты, блины, курсы, вопросы. Но - лисы, стразы, ножницы, патлы   
['2'	'ы'   'ов'   'ам'   'ы'   'ами'   'ах' 'Важен пол и наличие ед. числа! (р.п.)']     
[''	'(и|ы)'   '$1'   '$1'   '$1'   '$1'   '$1']   //Натали, Оглы
]
// 9

commonrules7 =
// -к
[[''	'(66)ок' '$1ока' '$1оку' '$1ок' '$1оком' '$1оке'] 
// при двух сущ. подряд нет выпадения
[''	'ок'   'ка'   'ку'   'ок'   'ком'   'ке']  // выпадение о перед к
[''	'(8)чек' '$1чка' '$1чку' '$1чек'   '$1чком' '$1чке'] // кусочек, цветочек (8-гласные)
[''	'(8)ёк' '$1йка' '$1йку'   '$1ёк'   '$1йком' '$1йке'] // чаёк, паёк
[''	'ёк'   'ька' 'ьку'   'ёк'   'ьком'   'ьке']  // тенёк
[''	'ёл'   'ла'   'лу'   'ёл'   'лом'   'ле']  // козёл

// -ец
[''	'(а|е|о|и)ец' '$1йца' '$1йцу' '$1ец' '$1йцем' '$1йце']	//молотобоец, олимпиец
[''	'(8)лец' '$1льца' '$1льцу' '$1лец' '$1льцом' '$1льце'] // жилец, но не подлец
//резец, ловец, но не жнец. Окончание ударное. Обычно так и бывает, поэтому нет флага
[''	'(8[бвгджзйкмнпрстфхцчшщ])ец' '$1ца' '$1цу' '$1ец' '$1цем' '$1це' 'Важно ударение (т.п.)!'] //мздоимец

[''	'заяц'   'зайца'   'зайцу'   'зайца'   'зайцем'   'зайце'] // исключение

// исключения с беглыми гласными. "Сон" не добавил, вряд ли будет такой объект :)
[''	'ров'   'рва'   'рву'   'ров'   'рвом'   'рве']	
[''	'л(ё|е)д'   'льда'   'льду'   'л$1д'   'льдом'   'льде'] 

[''	'(6)' '$1а' '$1у' '$1' '$1ом' '$1е']	// -ом/ем после шипящих зависит от ударения
]

// Правила для всех склонений
commonrules = {}

// Правила для отдельных склонений
rules = [self.irules self.rrules self.drules self.vrules self.trules self.prules self.trules2]

// Схема для меток сокращений
symtemplate=''

// разбиение на слова списка лексем в одной строке
// 'палка/ брусок/ обломок/' -> 'палка/' 'брусок/' 'обломок/'
breakup(str)=
{
 local res=nil, lexems=[], lc=0, counter=0;
 
 while (res:=reSearch('([-_&@ёЁa-zA-Zа-яА-Я0-9]+/[-_ёЁa-zA-Zа-яА-Я0-9+]*)([ ,.;]*)',str), res<>nil && 
 ((counter=0 && reGetGroup(2)[2]>0) || counter>0)) 
 {
   lexems+=reGetGroup(1)[3];
   lc++;

   if (length(str)>res[1]+res[2]) 
     str:=substr(str,res[1]+res[2],length(str));
   else break;
   
   counter++;
 }
 if (lc=0) return nil;
 else return [lexems, lc]; 
}


// ЗАПУСК ГЕНЕРАТОРА
// ищем все слова и генерируем склонения
// если передали nil, то подготовить генератор, но не 
// проводить массовой генерации
start(...) =
{
    local obj, i, j, gencnt=0, makeitall:=true;
    local ftime:=gettime(GETTIME_TICKS);
    
    if (argcount>0 && getarg(1)=nil) makeitall:=nil;
    
   // Формируем шаблон быстрой проверки наличия символьного множества
   symtemplate:='(';
     
   for (i:=1; i<=length(symbols); i++) 
   {
    symtemplate+=symbols[i][1]; 
    if (i!=length(symbols)) symtemplate+='|';
   }
   symtemplate+=')';
    
  // Формируем правила из фрагментов
  commonrules := commonrules1+commonrules2+commonrules3+commonrules4+commonrules5+commonrules6+commonrules7;
  
  // перерабатываем правила с учетом шаблонов
  for (i:=1; i<=length(commonrules); i++)
      commonrules[i][2]:=generator.replacesym(commonrules[i][2]); 
  for (j:=1; j<=length(rules); j++)    
    for (i:=1; i<=length(rules[j]); i++)
      rules[j][i][2]:=generator.replacesym(rules[j][i][2]);  

  if (!makeitall) return;  
  
   // Склоняем все, что с пометкой   
   if (printout) "\nВывод сгенерированных лексем. Для отключения вывода обнулите флаг printout у объекта generator. \n
 Пояснение: \"1\" - ед. ч., \"2\" - мн. ч.; \"м\" -муж. р., \"ж\" - жен.р., \"с\" - ср. р., \"у\" - сущ-ое, \"п\" -прил-ое. \n
 Перед \"/\" -  учтенные свойства объекта. (-) - повтор. (#d)(#t) - добавлены лексемы с метками падежей. \b
 Если окончание формируется неправильно, обратите внимание на пол, число и ударение, особенно, 
 если после вывода есть предупреждение. При простановке ударения учтите, что оно может 
 перемещаться при склонении (огурЕц-огурцА). В таких случаях обозначайте ударение меткой \"д\" или заглавной последней согласной (огуреЦ).\b";
    
    obj := firstobj();
    while (obj <> nil)
    {
      local sdescstr, generated=nil;
      local i=nil, nouns, adjs;
      local nl,al;
      
      // СКЛОНЯЕМ КОРОТКИЕ ОПИСАНИЯ (DESC)
      sdescstr:=obj.desc;
      
      if (sdescstr<>nil) i:=find(sdescstr,'/');
      
      // проверяем, что слеш не из тэга html
      if (i<>nil && !(i>1 && substr(sdescstr,i-1,1)='<'))
      {
         local ret, sdesc_list=[], result=['' '' '' '' '' ''];
         
         // нарезаем на отдельные слова в список sdesc_list
         while (ret:=reSearch('([/$&@№~%ёЁ_+*#a-zA-Zа-яА-Я0-9-]+)|([][<>()!{}.,;"?\ ]+)', sdescstr), ret<>nil) 
         {
           sdesc_list+=ret[3]; 
           sdescstr:=substr(sdescstr,ret[1]+ret[2],length(sdescstr)); 
         }
         
         // проходим по списку слов и склоняем по необходимости
         for (i:=1; i<=length(sdesc_list); i++)
         {
             local j, temp;
             if (ret:=reSearch('.+/(.*)',sdesc_list[i]), ret<>nil)
             {
                 local flags:=reGetGroup(1)[3];
                 
                 //проверяем наличие флага пола и числа у объекта
                 if ((obj.isHim || obj.isHer || obj.isThem)<>true)
                 {
                   if (reSearch('[mм]',flags)<>nil) obj.isHim:=true;
                   if (reSearch('[жf]',flags)<>nil) obj.isHer:=true;
                   if (find(flags,'2')<>nil) obj.isThem:=true;
                 }
                 
             	 // Проверяем, нужно ли генерировать падежи
                 if (find(flags,'-')=nil)
                 {
                   temp:=generate(obj, sdesc_list[i], 0, ISDESC | RETDET);   
                   for (j:=1; j<=6; j++) result[j]:=result[j]+temp[j][1];
                   if (!generated) generated:=true;
                   
                   // добавляем лексему с метками для дальнейшей обработки
                   // переписать с учетом структуры предложения!
                   if (find(flags,'п')<>nil || find(flags,'a')<>nil)
                    addword(obj, &adjective, sdesc_list[i]);
                   else
                    addword(obj, &noun, sdesc_list[i]);               
                 }
                 else
                 {
                    for (j:=1; j<=6; j++) 
                      result[j]:=result[j]+replaceStr(sdesc_list[i],'(.+)/.+$','$1');
                    
                    // переписать с учетом структуры предложения!
                    if (find(flags,'п')<>nil || find(flags,'a')<>nil)
                    addword(obj, &adjective, replaceStr(sdesc_list[i],'(.+)/.+$','$1')); 
                    else
                    addword(obj, &noun, replaceStr(sdesc_list[i],'(.+)/.+$','$1')); 
                 }
             }
             else 
               for (j:=1; j<=6; j++) result[j]:=result[j]+sdesc_list[i];
          }
          
          //отчет
          if (generated) 
          {  
           obj.descs:=result;
          
#ifdef __DEBUG
           if (printout)
           {
            // выводим реальные значения склонения
            local padezhi=[&sdesc, &rdesc, &ddesc, &vdesc, &tdesc, &pdesc];
            for (i:=1; i<=6; i++) "\"<<obj.(padezhi[i])>>\" ";
            "\n";
           }
#endif
          }
      }
      
      // проводим реквизит лексических свойств
      nouns:= getwords(obj,&noun);
      adjs:= getwords(obj,&adjective);
      nl:=length(nouns);
      al:=length(adjs);
      
      
      //СКЛОНЯЕМ СУЩЕСТВИТЕЛЬНЫЕ
      for (i:=1; i<=nl; ++i)
      {
        local res=nil, sklon, temp;
        
        if (find(nouns[i],'/')) 
        {
          // делаем маленькую паузу для выводов результатов
          // при большом количестве генерация может затянуться, и поэтому лучше 
          // выдовать результат понемногу или предупредить игрока        
          if (gencnt%20=1) inputevent(1);
          
          // проверяем, нужно ли разбить лексему на отдельные части
          // 'палка/ брусок/ обломок/' -> 'палка/' 'брусок/' 'обломок/'
          // результат закинет в конец списка!
          while (temp:=self.breakup(nouns[i]), temp<>nil)
          {
           nouns-=nouns[i]; 
           nouns+=temp[1];
           nl+=temp[2]-1;
           //if (i!=1) i--;
          }      
          
          // перебираем склонения
           
          res:=generate(obj, nouns[i], 0, SUSHE|RETDET);
          
          for (sklon:=1; res<>nil && sklon<=length(res); ++sklon)
          if (res[sklon][3][1]!=0)
          {
           local same:=nil;
           local new_nouns:= getwords(obj, &noun);   
           
           res[sklon][1]:=dezyo(res[sklon][1]);       
           
           // пополняем список лексем
           if (find(new_nouns,res[sklon][1])=nil) addword(obj, &noun, res[sklon][1]);
           else same:=true;
           
           // вносим лексемы с метками
           if (sklon=3) addword(obj,&noun,res[sklon][1]+'#d');
           if (sklon=5) addword(obj,&noun,res[sklon][1]+'#t');
           if (sklon=7 && find(new_nouns,res[sklon][1])=nil) addword(obj, &noun, res[sklon][1]+'#t');
           
           // вывод информации о результате
           if (printout) 
           {
             if (sklon=1 && res[sklon][2]) 
             {
               "\n";
               // если исползовались свойства объекта, выводим их
               if (reSearch('^[^mfnia12мжсупд]*[уaп]*$',res[sklon][2])) 
                { 
                  (obj.isThem)?"2":"1";
                  if (obj.gender=3) "С";
                  else (obj.gender=1)?"М":"Ж";
                  "/";
                } 
                "<<res[sklon][2]>>\t- ";
             }
             "<<res[sklon][1]>>";
             if (same) "(-)";
             if (sklon=3) "(#d)";
             if (sklon=5) "(#t)";
             if (sklon=7 && find(new_nouns,res[sklon][1])=nil)  "(#t)";
             if (detailed && res[sklon][3]) "(<<res[sklon][3][1]>>-<<res[sklon][3][2]>>)"; 
             "\t";

           }  // if
        }  // for
        if (res<>nil) gencnt++;
        if (printout && res[length(res)][3][1]=0) " - <<res[length(res)][1]>>";
        if (printout) "\n";
       }
      }
      
      // СКЛОНЯЕМ ПРИЛАГАТЕЛЬНЫЕ
      for (i:=1; i<=al; ++i)
      {
        local res=nil, sklon, temp;
        
        if (find(adjs[i],'/')) 
        {
          
          temp:=self.breakup(adjs[i]);
          if (temp) 
          {
           adjs-=adjs[i]; 
           adjs+=temp[1];
           al+=temp[2]-1;
           break;
          }   

          res:=generate(obj, adjs[i], 0, PRILA|RETDET);
          
          for (sklon:=1; res<>nil && sklon<=length(res); ++sklon)
          {
           local same:=nil;
           local new_adjs:= getwords(obj, &adjective);          
           
           if (find(new_adjs, res[sklon][1])=nil) addword(obj, &adjective, res[sklon][1]);
           else same:=true;
           
           // вносим лексемы с метками
           if (sklon=3) addword(obj,&adjective,res[sklon][1]+'#d');
           if (sklon=5) addword(obj,&adjective,res[sklon][1]+'#t');
           if (sklon=7 && find(new_adjs, res[sklon][1])=nil) addword(obj, &adjective, res[sklon][1]+'#t');
           
           // вывод информации о результате
           if (printout) 
           {
             if (sklon=1  && res[sklon][2]) 
             {
               "\n";
               if (reSearch('^[^mfnia12мжсупд]*[уaп]*$',res[sklon][2]))
                { 
                  (obj.isThem)?"2":"1";
                  if (obj.gender=3) "С";
                  else (obj.gender=1)?"М":"Ж";
                  "/";
                }
               "<<res[sklon][2]>> \t- ";
             }
             "<<res[sklon][1]>>";
             if (same) "(-)";
             if (sklon=3) "(#d)";
             if (sklon=5) "(#t)";
             if (sklon=7 && find(new_adjs, res[sklon][1])=nil)  "(#t)";
             if (detailed && res[sklon][3]) "(<<res[sklon][3][1]>>-<<res[sklon][3][2]>>)"; 
             "\t";

           } // if
          } // for
          if (res<>nil) gencnt++;
        }
        
        if (printout) "\n";
      }
      obj := nextobj(obj);
    }
     if (printout) "\b\b";
     else clearscreen(); 
     if (printout) 
     "\nСлов: <<gencnt>>\nГенерация заняла: <<gettime(GETTIME_TICKS)-ftime>> млс.\n";
}

binarize(str) =
{
  
}

// ФУНКЦИЯ ПРОВЕРКИ СООТВЕСТВИЯ ПРАВИЛ  ЗАДАННЫМ КЛЮЧАМ И СВОЙСТВАМ ОБЪЕКТА
check(obj, rules, info) =
{
    local  gender=nil,empty_info;
    
    //TODO: определять одушевленность по классу объекта
    
    
    // проверка наличия критических условий проверки
    if (reSearch('^[^mfnia12мжсупд]*[уaп]*$',info)) empty_info:=true;
    
    // проверка требований к ударению
    if (find(rules,'U') && reSearch('u|д',info)=nil)  return true;    
    
   // Проверяем соотвествие существительного/прилагательного
    if (find(rules,'A') && (reSearch('у',info))) return true;
    if (find(rules,'n') &&  (reSearch('a|п',info))) return true;
    if (find(rules,'I') &&  (reSearch('i|о',info)=nil)) return true;     
    
    // определение требуемого пола
   if (find(rules,'M')) 
      gender:=1;
   if (find(rules,'F')) 
      { if (gender=1) gender:=3; else gender:=2; }
   if (find(rules,'N')) 
      gender:=3;
   
   
   // Если в правилах указан муж. или жен. пол
   if (gender && gender!=3)
   {
   // Если заданы ключи в слове, не ориентироваться на свойства объекта
     if (!empty_info) 
     {
         if ((reSearch('f|ж',info) && gender!=2)||(reSearch('m|м',info) && gender!=1)) return true;
         //if ( ((find(info,'f')||find(info,'ж')) && gender!=2)||((find(info,'m')||find(info,'м')) && gender!=1)) return true;
     }
     else
     {
      if ((obj.isHer && gender!=2)||(obj.isHim && gender!=1)) return true;
     }
   }
   
   //  Если в правилах указан средний род
   if (gender && gender=3)
     { 
      if (!empty_info)
       {  if (!(reSearch('f|ж',info) && reSearch('m|м',info)) || reSearch('n|с',info)=nil) return true;   }
     else 
       {if (!(obj.isHer && obj.isHim) || !(obj.isHer || obj.isHim)) return true;}
     }

   // если в правиле множественное число
   if (find(rules,'2'))
     if (!empty_info)
     {
       if (find(info,'1')) return true;
     }
     else 
     {
      if (!obj.isThem) return true;
     }
     
    // если в правиле единственное 
   if ( find(rules,'1'))
     if (!empty_info)
     {
       if (reSearch('2',info)) return true;
     }
     else 
     {
       if (obj.isThem) return true;
     }
     
     return nil;
}

// ЗАМЕНА СИМВОЛА НА ШАБЛОН
replacesym(str)=
{
    local pattern;
     // проверяем наличие кода символьного множества
    if (reSearch(symtemplate,str)) 
    {
     local c, res;
     for (c:=1; c<=length(symbols); c++)
     {
       res:=reSearch(symbols[c][1],str);
       if (res)  
       { 
         // меняем шаблон с учетом символьного множества
         pattern:=replaceStr(str, symbols[c][1], symbols[c][2]); 
         c:=500;
       }
      }
     }
     else return str;
     
     return pattern;
}
;


// ФУНКЦИЯ СКЛОНЕНИЯ
// Принимает как аргументы: объект, строку для склонения, номер склонения
// (от 0 до 7; 7 - альтернативный творительный),  бинарный флаг части речи
// [сущ - по умолчанию],  флаг возврата информации о граматических 
// свойствах слова [не возвращает по умолч.], флаг "лексема или описание" 
generate: function(obj, str, sklonenie, ...)
{
  local i, result=[], info, udarenie, startsklon, finalsklon, found_rule;
  local gr_type=SUSHE, isdesc=0, return_det=1;
  
  if (argcount=4 && datatype(getarg(4))=DTY_NUMBER) 
    {
        gr_type:=(getarg(4)&(SUSHE|PRILA));
        return_det:=(getarg(4)&RETDET);
        isdesc:=(getarg(4)&ISDESC);
    }
  
  if (sklonenie>7) sklonenie:=1;
  
  // Подстрахуемся на случай использования без запуски движка
  if (generator.symtemplate='') generator.start(nil); 

  // ищем метку и отделяем ключи от слова
  i:=find(str,'/');
  if (i) 
  {
    info:=substr(str,i+1,length(str));
    str:=substr(str,1,i-1);
  }

  i:=0; 

  info:=lowerru(info);
  
  // ставим пометку сУщ или Прил
  if (info<>nil &&  reSearch('n|у|a|п',info)=nil)
  {
    if (gr_type&PRILA) info+='п'; 
  }
  else info+='у'; 
   
    // TODO: ?
    if (str=nil || str='') return;
   
  // проверяем наличие ударения на окончании
  // указано прописной буквой
    // (строчные)(прописаная гласная)(только строчные гласные). -Ая
    if (reSearch('^[^А-ЯЁ]*[АЕЁИОУЫЭЮЯ][аеёиоуыэюя]*$',str)) 
      info+='u';
    else 
    // выделена согласная -последняя буква в слове, что обозначает
    // ударение, переходящее с основы на окончание при склонении
    if (reSearch('^[^АЕЁИОУЫЭЮЯ]+[БВГДЖЗЙКЛМНПРСТФХЧЦШЩ]$',str)) 
      info+='u';            
    else 
    // единственная гласная в окончании. -дно, ржа
    if (reSearch('^[^аеёиоуыэюя]+[аеёиоуыэюя]$',str)) 
      info+='u'; 

    // Если лексема, уменьшаем слово целиком
    if (isdesc=0)  str:=lowerru(str);
    else 
    // Если описание с ударением, то уменьшаем только последние две буквы
      if (find(info, 'u')<>nil) str:=lower2x(str);
    
   
  // если вместо склонения задан 0 - проходим по всем, иначе - только одно
  if (sklonenie=0) 
  {
    startsklon:=1; 
    finalsklon:=7;
  }
  else
  {
    startsklon:=sklonenie;
    finalsklon:=sklonenie; 
    if (!return_det) result:='';
  }
   
  // Цикл по склонениям 
   // только если в строке есть специальный флаг,
  for (sklonenie:=startsklon; sklonenie<=finalsklon && (info<>nil); sklonenie++)
  {  
       local ind_rules_applied=nil; 
       
       // ИНДИВИДУАЛЬНЫЕ ПРАВИЛА СКЛОНЕНИЙ
       // если одушевленный муж. род ед. числа, то просто приравниваем родительному
       if (sklonenie=4 && found_rule)
       {
         if (generator.check(obj, '1IM', info)<>true) 
         {     
          local temp_result:= replaceStr( str, generator.commonrules[found_rule][2]+'$', generator.commonrules[found_rule][3]);

          if (return_det) 
            result += [[temp_result info [2 found_rule]]];
          else result +=  temp_result;   
          
          ind_rules_applied:=true;         
         }
       }
       
       //остальные случаи особенных склонений
       if (sklonenie>1)
       // входим в цикл по списку индивидуальных правил
       for (i:=1; i<=length(generator.rules[sklonenie]) && ind_rules_applied=nil; i++)	
       {
           local replacement='', pattern, res;
           	  
           if (generator.check(obj, generator.rules[sklonenie][i][1], info)) continue;
           
           pattern:=generator.rules[sklonenie][i][2];
        
           // проверяем соответствие шаблону
           res:=reSearch(pattern+'$',str);
           if (res)
           { 
             local temp_result;
             temp_result:=    replaceStr(str,pattern+'$',generator.rules[sklonenie][i][3]);
             
             if (return_det) 
               result += [[temp_result info [1 i]]];
             else result +=  temp_result;
             
             ind_rules_applied:=true;
            }
       }
       
        // ОБЩИЕ ПРАВИЛА СКЛОНЕНИЙ
       // Если по индивидуальным правилам изменений не произвдено, а
       //  склонение не альтернативный творительный, переходим к общим
       if (!ind_rules_applied && sklonenie!=7)
       {
             local temp_result='';
            // ранее уже нашли правило
            if (found_rule) 
            {     
               temp_result:=    replaceStr(str,generator.commonrules[found_rule][2]+'$',generator.commonrules[found_rule][sklonenie+1]);
 
               if (return_det) 
                 result += [[temp_result info [2 found_rule]]];
               else 
                 result +=  temp_result;            
            }
            else
            // ищем правило, входим в цикл по списку правил 
            for (i:=1; i<=length(generator.commonrules) && found_rule=nil; i++)	
            {
              local replacement='', pattern, res, gender=nil;
              
              if (generator.check(obj, generator.commonrules[i][1], info)) continue;
           	  
              pattern:=generator.commonrules[i][2];
           
              // проверяем соответствие шаблону
              res:=reSearch(pattern+'$',str);
              if (res)
              { 
                 if (sklonenie!=1)
                    temp_result:=    replaceStr(str,pattern+'$',generator.commonrules[i][sklonenie+1]);
                 else 
                    temp_result:=str;
     
                    if (return_det) 
                      result += [[temp_result info [2 i]]];
                    else 
                       result +=  temp_result;
                                
                 // запоминаем найденное правило               
                 found_rule:=i;
               }
             }
         }
   } 

  if (result=[]) result:=[str]; else
  if (result=nil) result:=str; else
  // если нашли в правиле сообщение
  if (found_rule && length(generator.commonrules[found_rule])=8) 
  {
    local temp:=generator.commonrules[found_rule][8];
    // даем нули вместо информации, чтобы отличать от правил
    result+=[[temp '0' [0 0]]];
  }
  return result;
}


//Flint added this
//функция динамически добавляет слово к объекту, генерируя все необходимые падежи
addwordru: function(obj, type, word)
{
	if ( find(word, '/') )
	{
		local gtflag, sklon, res;
		
		if (type = &adjective) gtflag := PRILA;
		else gtflag := SUSHE;
		
		res := generate(obj, word, 0,  gtflag | RETDET);
          
		for (sklon := 1; res <> nil && sklon <= length(res); ++sklon)
		{
			local new_words := getwords(obj, type);
			
			generator.addLexemes(obj, res, type, sklon, new_words);
		}
	}
	else
	{
		addword(obj, type, word);
	}
}

delwordru: function(obj, type, word)
{
	if ( find(word, '/') )
	{
		local gtflag, sklon, res;
		
		if (type = &adjective) gtflag := PRILA;
		else gtflag := SUSHE;
		
		res := generate(obj, word, 0, gtflag | RETDET);
          
		for (sklon := 1; res <> nil && sklon <= length(res); ++sklon)
		{
			delword(obj, type, res[sklon][1]);
			
			if (sklon=3) delword(obj, type, res[sklon][1]+'#d');
			if (sklon=5 || sklon = 7) delword(obj, type, res[sklon][1]+'#t');
		}		
	}
	else
	{
		delword(obj, type, word);
	}
}

// Уменьшает две последние буквы строки
lower2x: function(str)
{
  local strlen=length(str);
  
  if (strlen>2) return substr(str,1,strlen-2)+loweru(substr(str,strlen-1,strlen));
  
  return str;
}