/*
 *   Copyright (c) 2008 by GrAnd (rtads@mail.ru)
 *   от  4.07.08
 *
 */

// Класс объект-меню
menu: object
   sdesc=""  			// Заголовок меню. Выводится на месте названия локации
   btn=[]			// Подписи пунктов меню
   bgcolor = 'statusbg'     	// Цвет фона меню
   fgcolor = 'statustext'     	// Цвет текста меню
   select=1			// Указатель выбранного пункта
   pMenu=nil			// Предыдущее меню
   endit=nil
   seen=nil			// Выводился ли ранее пункт меню

   // Текст (или исполняемый код), выводимый на главный экран при появлении текущего меню
   txt={}

   // post scriptum (второй txt, на всякий случай)
   ps={}

   // Основная функция запуска меню
   go(topMenu)=
   {

    local key;
    local i, events;

    endit:=nil;

    // Так мы везде будем знать имя текущего меню
    mainmenu.curmenu:=self;

    // Сохраняем имя предыдущего меню
    self.pMenu:=topMenu;
    
    // Возможно, рановато, но запоминаем, что уже видели это меню
    self.seen:=true;

    // Запускаем блок кода и текста 
    txt; "\b";

    ps; "\n";

    // Если у меню есть sdesc, то он будет вынесен в статусную строку
    if (dToS(self,&sdesc)!='') self.topBanner;

    // Если в прошлый раз в данном меню был выбран элемент с номером большим,
    // чем количество пунктов в данный момент, то устанавливаем выбор на первый
    if ( select > length(btn)/2 ) select:=1;

    while (!self.endit && btn!=[])
    {
      "<banner id=questions align=bottom><body bgcolor=\"<<self.bgcolor>>\" text=\"<<self.fgcolor>>\">";
      if (!(systemInfo(__SYSINFO_SYSINFO) and systemInfo(__SYSINFO_HTML) = 1)) "\b";
      for (i:=1;i<=length(btn)/2;i++)
      {

       if (systemInfo(__SYSINFO_SYSINFO) and systemInfo(__SYSINFO_HTML) = 1) {
        if (select != i)
          "<font color=\"<<self.bgcolor>>\">&gt;</font>";
        else "&gt;"; 
       }
       else {
        say(i); if (select = i) ">"; else " ";
       }    

       "<a plain href=\"<<i>>\">";

       say(btn[i*2]);

       "</a>\n";

      }
     "</banner>";

    // Ожидаем и проверяем: нажатие кнопки или клик мыши?

    events := inputevent();

    if (events[1] = INPUT_EVENT_HREF) 
     {
      select := cvtnum(events[2]);
      key := ' ';
     }
    else key := loweru(events[2]);

    if (key='[up]' or key='=' or key='+')
     if (select!=1)
      select:=select-1;

    if (key='[down]' or key='-')
     if (select!=length(btn)/2) 
      select:=select+1; 
   
    if (key='1' or key='2' or key='3' or key='4' or key='5' or key='6' or key='7' or key='8' or key='9')
      if (cvtnum(key)<=length(btn)/2) {
        select:=cvtnum(key);
        self.endit:=true;
        mainmenu.mmenu:=self;
        } 

    if (key=' ' or key='\n') 
       { self.endit:=true; mainmenu.mmenu:=self; } 
    
    }
   }

   // Удаление банера с меню и заголовком
   del= {
      "<banner remove id=MenuTitle><banner remove id=questions>";
   }

   // Проверка, необходимо ли перейти в текстовый режим?
   endcheck=nil

   // Вывод заголовка
   topBanner = 
    {
        "<banner id=MenuTitle><body bgcolor=\"<<self.bgcolor>>\" text=\"<<self.fgcolor>>\">";
        "\n<<self.sdesc>>\n";
        "</banner>";
    }

   // процедура закрывающая текущее меню и вызывающее новое
   mgoto(newMenu) = {
       mainmenu.jgt:=true; self.endit:=true; mainmenu.mmenu := newMenu;
   }
;

/* 
 *   Главное управляющее меню, предназначенное для ведения очереди
 *   и исполнения последовательности меню
 */
mainmenu: menu
   // Меню через функцию осуществляет запуск следующего меню, чтобы не было рекурсии,
   // т.к. она в конечном итоге вызывает переполнение стека.
   mmenu=nil
   jgt=nil
   start(firstmenu)= {mmenu:=firstmenu; mmenu.go(nil); self.zapusk;}
   justgoto={mmenu.go(mmenu.pMenu);}
   zapusk=
   {
    while (mmenu.endcheck=nil && mainmenu.endcheck=nil)
    {
     if (self.jgt) {mmenu.go(mmenu.pMenu); self.jgt:=nil;}
      else
      if (mmenu.select>0 and mmenu.select<=length(mmenu.btn)/2)
       {
        if (mmenu.btnprint) "\n<<mmenu.btn[mmenu.select*2]>>\n";
        mmenu.btn[1+((mmenu.select-1)*2)].go(mmenu);
       }
    }
    self.del;
   }
;

// Опредеяем меню, в котором будет системное меню
smenu: menu
   // Системное меню должно быть нижним в списке, поэтому выводим после txt
   ps=
   { 
    self.btn:=self.btn-[sysm 'Системное меню'];
    self.btn:=self.btn+[sysm 'Системное меню'];
   }
;


// Пункт меню, выводимый по условию
ifbtn: function(usl,btntoadd)
{
   mainmenu.curmenu.btn:=mainmenu.curmenu.btn-btntoadd;
   if (usl) mainmenu.curmenu.btn:=mainmenu.curmenu.btn+btntoadd; 
}

//=----------------------------------------------------------------------------=
//                           Класс системного меню
//=----------------------------------------------------------------------------=
sysm: menu
    curmenu = nil
    sdesc = "Системное меню"
    btn=[savem 'Сохранить игру' loadm 'Восстановить игру' restartm 'Начать игру заново'
    sysquit 'Выйти из игры' self.pMenu 'Обратно']
;

savem: menu
   txt = {
       local savefile;
        
       mainmenu.mmenu:=sysm.pMenu;

       savefile := askfile('Файл для сохранения:',
                           ASKFILE_PROMPT_SAVE, FILE_TYPE_SAVE,
                           ASKFILE_EXT_RESULT);
       switch(savefile[1])
       {
       case ASKFILE_SUCCESS:
           if (save(savefile[2]))
           {
            " Во время сохранения произошла ошибка. ";
            return nil;
           }
           else
           { "Сохранено. "; return true; }

       case ASKFILE_CANCEL:   "Отменено. ";  return nil;
            
       case ASKFILE_FAILURE:
       default:        "Неудача. "; return nil;
       }

   }
   endcheck={mainmenu.mmenu:=sysm.pMenu; return nil;}
;

loadm: menu
   txt = {
       local savefile;
        
       mainmenu.mmenu:=sysm.pMenu;

       savefile := askfile('File to restore game from',
                            ASKFILE_PROMPT_OPEN, FILE_TYPE_SAVE,
                            ASKFILE_EXT_RESULT);
       switch(savefile[1])
       {
         case ASKFILE_SUCCESS: 
            return mainRestore(savefile[2]);

         case ASKFILE_CANCEL:
            "Восстановление отменено. ";
            return nil;

         case ASKFILE_FAILURE:
         default:
            "Неудача. ";
            return nil;
        }
   }
   endcheck={mainmenu.mmenu:=sysm.pMenu; return nil;}
;

restartm: menu
   txt="Вы точно хотите начать игру заново?"
   btn=[sysm 'Нет' restsysyes 'Да']
;

restsysyes: menu
   go(topMenu)={
    scoreStatus(0, 0);
    restart(initRestart, global.initRestartParam);
   }
;

sysquit: menu
   sdesc="Подтверждение выхода"
   txt="Вы уверены?"
   btn=[sysm 'Нет' sysqyes 'Да']
;

sysqyes: menu
   go(topMenu)={quit();}
;