/*
 *   Copyright (c) 2008 by GrAnd (rtads@mail.ru)
 *   ��  4.07.08
 *
 */

// ����� ������-����
menu: object
   sdesc=""  			// ��������� ����. ��������� �� ����� �������� �������
   btn=[]			// ������� ������� ����
   bgcolor = 'statusbg'     	// ���� ���� ����
   fgcolor = 'statustext'     	// ���� ������ ����
   select=1			// ��������� ���������� ������
   pMenu=nil			// ���������� ����
   endit=nil
   seen=nil			// ��������� �� ����� ����� ����

   // ����� (��� ����������� ���), ��������� �� ������� ����� ��� ��������� �������� ����
   txt={}

   // post scriptum (������ txt, �� ������ ������)
   ps={}

   // �������� ������� ������� ����
   go(topMenu)=
   {

    local key;
    local i, events;

    endit:=nil;

    // ��� �� ����� ����� ����� ��� �������� ����
    mainmenu.curmenu:=self;

    // ��������� ��� ����������� ����
    self.pMenu:=topMenu;
    
    // ��������, ��������, �� ����������, ��� ��� ������ ��� ����
    self.seen:=true;

    // ��������� ���� ���� � ������ 
    txt; "\b";

    ps; "\n";

    // ���� � ���� ���� sdesc, �� �� ����� ������� � ��������� ������
    if (dToS(self,&sdesc)!='') self.topBanner;

    // ���� � ������� ��� � ������ ���� ��� ������ ������� � ������� �������,
    // ��� ���������� ������� � ������ ������, �� ������������� ����� �� ������
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

    // ������� � ���������: ������� ������ ��� ���� ����?

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

   // �������� ������ � ���� � ����������
   del= {
      "<banner remove id=MenuTitle><banner remove id=questions>";
   }

   // ��������, ���������� �� ������� � ��������� �����?
   endcheck=nil

   // ����� ���������
   topBanner = 
    {
        "<banner id=MenuTitle><body bgcolor=\"<<self.bgcolor>>\" text=\"<<self.fgcolor>>\">";
        "\n<<self.sdesc>>\n";
        "</banner>";
    }

   // ��������� ����������� ������� ���� � ���������� �����
   mgoto(newMenu) = {
       mainmenu.jgt:=true; self.endit:=true; mainmenu.mmenu := newMenu;
   }
;

/* 
 *   ������� ����������� ����, ��������������� ��� ������� �������
 *   � ���������� ������������������ ����
 */
mainmenu: menu
   // ���� ����� ������� ������������ ������ ���������� ����, ����� �� ���� ��������,
   // �.�. ��� � �������� ����� �������� ������������ �����.
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

// ��������� ����, � ������� ����� ��������� ����
smenu: menu
   // ��������� ���� ������ ���� ������ � ������, ������� ������� ����� txt
   ps=
   { 
    self.btn:=self.btn-[sysm '��������� ����'];
    self.btn:=self.btn+[sysm '��������� ����'];
   }
;


// ����� ����, ��������� �� �������
ifbtn: function(usl,btntoadd)
{
   mainmenu.curmenu.btn:=mainmenu.curmenu.btn-btntoadd;
   if (usl) mainmenu.curmenu.btn:=mainmenu.curmenu.btn+btntoadd; 
}

//=----------------------------------------------------------------------------=
//                           ����� ���������� ����
//=----------------------------------------------------------------------------=
sysm: menu
    curmenu = nil
    sdesc = "��������� ����"
    btn=[savem '��������� ����' loadm '������������ ����' restartm '������ ���� ������'
    sysquit '����� �� ����' self.pMenu '�������']
;

savem: menu
   txt = {
       local savefile;
        
       mainmenu.mmenu:=sysm.pMenu;

       savefile := askfile('���� ��� ����������:',
                           ASKFILE_PROMPT_SAVE, FILE_TYPE_SAVE,
                           ASKFILE_EXT_RESULT);
       switch(savefile[1])
       {
       case ASKFILE_SUCCESS:
           if (save(savefile[2]))
           {
            " �� ����� ���������� ��������� ������. ";
            return nil;
           }
           else
           { "���������. "; return true; }

       case ASKFILE_CANCEL:   "��������. ";  return nil;
            
       case ASKFILE_FAILURE:
       default:        "�������. "; return nil;
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
            "�������������� ��������. ";
            return nil;

         case ASKFILE_FAILURE:
         default:
            "�������. ";
            return nil;
        }
   }
   endcheck={mainmenu.mmenu:=sysm.pMenu; return nil;}
;

restartm: menu
   txt="�� ����� ������ ������ ���� ������?"
   btn=[sysm '���' restsysyes '��']
;

restsysyes: menu
   go(topMenu)={
    scoreStatus(0, 0);
    restart(initRestart, global.initRestartParam);
   }
;

sysquit: menu
   sdesc="������������� ������"
   txt="�� �������?"
   btn=[sysm '���' sysqyes '��']
;

sysqyes: menu
   go(topMenu)={quit();}
;