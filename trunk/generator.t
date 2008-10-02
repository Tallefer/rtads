/* 
*   ���������� ���������� �������
*   ������� ������� 25 ������ ��������� TADS   
*   �������� ����� -GrAnd, 
*   ��������� ������� - Flint, Fireton
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


// ��������� ���������� � ���
// ����� �������� �������, ����� ����� ���������
generation: function
{   
   // ����� ������ � ������ �������
#ifdef __DEBUG
   // ����� ���� ���������. ���������������� ����� ��������
    generator.printout:=true;
   // ����� �������������� ������
   // generator.detailed:=true;
#endif
   
   generator.start;
}

// ������� �������������
// ��� ����, ����� ��������� ����� ���������, ���������� ��������
// � ������� ������ "/". ����� ���� ����� ���� ����� � ��������� ����
// � �����, ��� ��� ��� ����� ���������� �� �������� � �������.
// "M"(����) � "�"(�������) - ������� ���
// "F" �  "�" - ������� ���
// "N" � "�"(���), � ����� "��" ������ - ������� ���
// "1" - ������������ �����
// "2" - ������������� �����. ������ � 1 �� ���������.
// "A"(����) ��� "�" - �������������� (Adjective)
// "�" - ��������������� (Noun) - ����� ������������� �������
// "I" ��� "�" (�������) - ������������ (anImated)
//  ������� ��������� ������� ��������� ������ (��� ������� "�" ��� "u")
// ����� ����� ������ ��������� �������

/*
testobj: item
desc='��������/1�� �������/1� �� �����/�- ����/�-'
adjective = '�������/1�'  '������/2'
noun='�����/�' '�����/�2' '����/1�' '����/2' '�������/1�' '�������/�1�' '�����/�' '�������/2��'
isHer=true
isThem=true
;
*/

// ������ ��������� � ����� �������
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

// ������ ���������� �������
// ������ ������� ��������� � �������� ����������� ������
// ��� �������� � ��������� ���������
generator: object

// �������� �� �� ������ ��������� ���������
printout =nil

// �������� ������ ���������� ������
#ifdef _GENDETAILED && _DEBUG
detailed =true
#else
detailed =nil
#endif

// ������ ���������� ���������
symbols=
    [['0' '[�������������]'] 
    ['1' '[����]'] 
    ['2' '[�����������]']
    ['3' '[���������]']                       //�������
    ['4' '[����]']                                //�������
    ['6' '[���������������������]']     //���������
    ['8' '[���������]']                        //�������
  ]

// ����� ��� ������� - ������������
irules = []


// ������� ��� ������������ ������
// ����� � �����,
// ���������� � ����. ��������� �����, ������ � ����� ������
// ����� -���������� ���������
// ����. ����� � �������� - ������ ���������� ���������
rrules =
    [
    ['2F'    '���'  	'��']
    ['2F'    '(4)��'  	'$1��']     // �������
    ['2F'    '(6)��'  	'$1��']     //6 ����
    ['2F'    '��'   	'�']
    ['2M'    '��'   	'���']
    ['2F'    '(6)��'  	'$1��']
    ['2F'    '��'   	'�']
    ['2'     '��'   	'���']
    ['2F'    '(�6)�' 	'$1']
    ['F'     '��' 	'��']
    ['2F'    '(.)�'  	'$1']
    ['2'     '���'  	'���']
    ['2FU'   '(4)�'     '$1��']	     // ����->�����, ���� - �����
    ['2F'    '(4)�'     '$1']	     // �����, ����
    ['2U'    '(8)�' 	'$1��']      // ���  (8- �������)
    ['2F'    '(8)�'	'$1�']       // ����, ����, �����, �����     
    ['2'     '��'  	'��']	     // �������
    ['2F'    '(6)��' 	'$1���']     // ����� (6 - ����)
    ['2U'    '��'	'���']       // �������, �������
    ['2F'    '�'  	'']          // ����, ���� (��� �������� �� ������� ��. �����?)    
    ['2U'    '(4|�)�'   '$1��']      // ����, ����, �����
    ['2U'    '�'  	'��']        // ������
  ]


// ���������
drules = []


// �����������
// ������� ������������ ������������� �������������� ������������,
// � ������� ��� �� �������������
vrules =
[
  ['2FI' '���'  '��']	   // ���������
  ['2FI' '(4)��'  '$1��']  // �������
  ['2FI' '(0)��'  '$1��']  //
  ['2FI'  '��'   '�']	   // ������
  //['2I'  '��'   '���']     // ������
  //['2M'    '��'   '��']    // �����
  ['2FI' '(6)��'  '$1��']
  ['2FI'  '��'  '�']
  ['2I'   '��'   '���']
  ['2UI' '��' '���']
  //['1MI' '�' '�']
  ['I'	'��' '���']
]


// ������������
trules=
[
   ['U'  '(4|�)�' '$1��']	// U - ��������, 4 - �������
   [''  '(4|�)�' '$1��']
   ['A'  '(4|�)��' '$1��']
   ['U' '(8[��������������������])��' '$1���']
]


// ������������2 - ����������������� ��� ������������ �����
trules2=
[  
  ['1U'	'(4|�)�'	'$1��']	//������
  ['1'	'(4|�)�'	'$1��'] //�����
  ['1'	'�'	'��']		//�����
  [''	'(4|�)��'	'$1��'] //�����, �����
  [''	'��'	'��']           //�������
  [''	'��'	'��']           //���������  
  ['1U' '�'	'��']           //�����
  ['1F'	'�'	'��']           //����
]


// ���������� �����
prules = []

// � ��������� ��� ������ ������, ������ ��������������� ��������, ����� �������������
// ������ ����������� � �������� �� ��������� ������ ������ ���������� 
// ���� ��� ���������� ������ ����� ���������� ������, �������� �� ������� ���������

// ���: ���������� � ����. ��������� �����, ������, 5 ���� ������ ��� ���������, �����
// �������������� + ����������� (�����������)

commonrules1 =
// ������������� ����� ��������������� �� -�:
[['2'	'���'	'��'	'����'	'���'	'�����'	'����'],  // ��������
['2'	'���'	'��'	'����'	'��� '	'�����'	'����'],  // ������
['2'	'(6)��'	'$1��'	'$1���'	'$1��'	'$1����' '$1���'],  // �����, 6 -����.

['2'	'��'	'�'	'���'	'��'	'����'	'���'],     // ������, (�.�. ������,������)
['2M'	'�'	'��'	'��'	'�'	'���'	'��'],     // ����
['2'	'�'	''	'��'	'�'	'���'	'��'],     // �����

[''	'(0)�'  '$1�'   '$1�'    '$1�'  '$1��'   '$1�']    //�������������
[''	'�'   '�'    '�'	'�'   '��'   '�']
]
//8  - ���������� ������ � �����

commonrules2 = 
// ��� �� -�
[[''	'��'  '����' '����'  '��'  '�����' '����']   // �����
['U'	'(4|�)��'  '$1��' '$1��'   '$1��' '$1��'  '$1��']     // ������� � '�' + '��' � ���������
[''	'(4|�)��'  '$1��' '$1��'   '$1��' '$1��'  '$1��']     // ������� � '�' + '��'
[''	'��'  '��'  '��'  '��'  '��'   '��']     // ��������� ����. �� -��']
[''	'��'   '��'   '��'   '��'   '��'   '��']     // ����. �� -�� + �����������
['2'	'��'   '���'   '���'   '��'   '����'   '���']   // ������, �����
['2'	'��'   '��'   '���'   '��'   '����'   '���']  // ��������
[''	'��'   '��'   '��'   '��'   '���'   '��']  // ��������������� �� -��
['U'	'�'   '�'   '�'   '�'   '��'   '�']
[''	'�'   '�'   '�'   '�'   '��'   '�']
]
// 10

commonrules3 =
// �� -�
[['n'	'��'   '��'   '��'   '��'   '���'   '��']  //������
[''	'��'   '���'   '���'   '��'   '��'   '��']  //����
[''	'(1)�'   '$1�'   '$1�'   '$1�'   '$1��'   '$1�']	// ����
[''	'��'   '���'   '���'   '��'   '��'   '��']
['n'	'��'   '��'   '��'   '��'   '���'   '��']
[''	'(�)��'   '$1���'   '$1���'   '$1��'   '$1��'   '$1��']  // �������
[''	'��'   '���'   '���'   '��'   '��'   '��']
[''	'�'   '�'   '�'   '�'   '��'   '�']
]
// 8

commonrules4 =
// �� �
[[''	'(6)�'   '$1�'   '$1�'   '$1�'   '$1��'   '$1�']  // (6 - ����.)
[''	'�'   '�'   '�'   '�'   '��'   ' �']	
    
// �� -�    
[''	'(�|�)�'   '$1�'   '$1�'   '$1�'   '$1��'   '$1�']   //������, ������
[''	'(0)��'   '$1���' '$1���' '$1��' '$1��'   '$1��'] // ����., �� ��. ����. (�������������)
[''	'��'   '���'   '���'   '��'   '��'   '��'] // ����., �� �. ����.
// �������?
[''	'(�|�)�'   '$1��'   '$1��'   '$1�'   '��'   '��']  
['2'	'(�|�)�' '$1�' '$1�' '$1�' '$1��' '$1�']
[''	'��'   '��'   '��'   '��'   '���'   '��']  // ������, ������
[''	'��'   '��'   '��'   '��'   '���'   '��']  // ��������
[''	'��'   '��'   '��'   '��'   '���'   '��']  // ������
[''	'��'   '��'   '��'   '��'   '���'   '��']
['2'	'��'   '��'   '��'   '��'   '���'   '��']
[''	'(4)�'   '$1�'   '$1�'   '$1�'   '$1��'   '$1�']
[''	'([���])�'   '$1�'   '$1�'   '$1�'   '$1��'   '$1�']
]
//14 - 40

commonrules5 =
// -�
[[''	'(6)�'   '$1�'   '$1�'   '$1�'   '��'   '$1�']
[''	'�'   '�'   '�'   '�'   '��'   '�'] 

// �� -�    
['F'	'�'   '�'   '�'   '�'   '��'   '�']
// ������ ������� "�" � "�"
// -���,-��� ������, ��������, ������, ������, ������; ����� ����� 30-�� 
// ��!!! -�����, ������, �����, ��������, ���������, �����, ������ (��� ����� ���)
['M'	'���'   '��'   '��'   '���'   '���'   '��']
['M'	'���'   '��'   '��'   '���'   '���'   '��']
// ����������, ������ �������. �����-�� ��� ����, ���� � ����. ���� �� �����. 
['M'	'�����'   '����'   '����'   '�����'   '����'   '����']
['M'	'�����'   '����'   '����'   '�����'   '����'   '����']
[''	'�'   '�'   '�'   '�'   '��'   '�']
]
// 8

commonrules6 =
// �� -�
[['2A'	'��'   '���'   '���'   '��'   '����'   '���']     //�����
['2F'	'��'   '��'   '���'   '��'   '����'   '���']
['2F'	'(4|�|�)��' '$1��'   '$1���'   '$1��' '$1����'   '$1���']  // (4 - �������)
['2F'	'��'   '��'   '���'   '��'   '����'   '���']   // ����

['2'	'(8|�)�'   '$1��'   '$1��'   '$1�'   '$1���'   '$1��']  // 8 - ��-��, ���� 
['2'	'(4|�)�'   '$1'   '$1��'   '$1�'   '$1���'   '$1��' '����� ��������! (�.�.)']  // ����, ����, ����
['2'	'(0)�'   '$1��'   '$1��'   '$1�'   '$1���'   '$1��']  // ������������� 

//���. �������, ������, �����; ����->����� 
['2'	'�'   ''   '��'   '�'   '���'   '��' '����� ��������! (�.�.)'] 
// ��� -�: �����, �����, �����, �������. �� - ����, ������, �������, �����   
['2'	'�'   '��'   '��'   '�'   '���'   '��' '����� ��� � ������� ��. �����! (�.�.)']     
[''	'(�|�)'   '$1'   '$1'   '$1'   '$1'   '$1']   //������, ����
]
// 9

commonrules7 =
// -�
[[''	'(66)��' '$1���' '$1���' '$1��' '$1����' '$1���'] 
// ��� ���� ���. ������ ��� ���������
[''	'��'   '��'   '��'   '��'   '���'   '��']  // ��������� � ����� �
[''	'(8)���' '$1���' '$1���' '$1���'   '$1����' '$1���'] // �������, �������� (8-�������)
[''	'(8)��' '$1���' '$1���'   '$1��'   '$1����' '$1���'] // ���, ���
[''	'��'   '���' '���'   '��'   '����'   '���']  // ����
[''	'��'   '��'   '��'   '��'   '���'   '��']  // ����

// -��
[''	'(�|�|�|�)��' '$1���' '$1���' '$1��' '$1����' '$1���']	//����������, ��������
[''	'(8)���' '$1����' '$1����' '$1���' '$1�����' '$1����'] // �����, �� �� ������
//�����, �����, �� �� ����. ��������� �������. ������ ��� � ������, ������� ��� �����
[''	'(8[��������������������])��' '$1��' '$1��' '$1��' '$1���' '$1��' '����� �������� (�.�.)!'] //��������

[''	'����'   '�����'   '�����'   '�����'   '������'   '�����'] // ����������

// ���������� � ������� ��������. "���" �� �������, ���� �� ����� ����� ������ :)
[''	'���'   '���'   '���'   '���'   '����'   '���']	
[''	'�(�|�)�'   '����'   '����'   '�$1�'   '�����'   '����'] 

[''	'(6)' '$1�' '$1�' '$1' '$1��' '$1�']	// -��/�� ����� ������� ������� �� ��������
]

// ������� ��� ���� ���������
commonrules = {}

// ������� ��� ��������� ���������
rules = [self.irules self.rrules self.drules self.vrules self.trules self.prules self.trules2]

// ����� ��� ����� ����������
symtemplate=''

// ��������� �� ����� ������ ������ � ����� ������
// '�����/ ������/ �������/' -> '�����/' '������/' '�������/'
breakup(str)=
{
 local res=nil, lexems=[], lc=0, counter=0;
 
 while (res:=reSearch('([-_&@��a-zA-Z�-��-�0-9]+/[-_��a-zA-Z�-��-�0-9+]*)([ ,.;]*)',str), res<>nil && 
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


// ������ ����������
// ���� ��� ����� � ���������� ���������
// ���� �������� nil, �� ����������� ���������, �� �� 
// ��������� �������� ���������
start(...) =
{
    local obj, i, j, gencnt=0, makeitall:=true;
    local ftime:=gettime(GETTIME_TICKS);
    
    if (argcount>0 && getarg(1)=nil) makeitall:=nil;
    
   // ��������� ������ ������� �������� ������� ����������� ���������
   symtemplate:='(';
     
   for (i:=1; i<=length(symbols); i++) 
   {
    symtemplate+=symbols[i][1]; 
    if (i!=length(symbols)) symtemplate+='|';
   }
   symtemplate+=')';
    
  // ��������� ������� �� ����������
  commonrules := commonrules1+commonrules2+commonrules3+commonrules4+commonrules5+commonrules6+commonrules7;
  
  // �������������� ������� � ������ ��������
  for (i:=1; i<=length(commonrules); i++)
      commonrules[i][2]:=generator.replacesym(commonrules[i][2]); 
  for (j:=1; j<=length(rules); j++)    
    for (i:=1; i<=length(rules[j]); i++)
      rules[j][i][2]:=generator.replacesym(rules[j][i][2]);  

  if (!makeitall) return;  
  
   // �������� ���, ��� � ��������   
   if (printout) "\n����� ��������������� ������. ��� ���������� ������ �������� ���� printout � ������� generator. \n
 ���������: \"1\" - ��. �., \"2\" - ��. �.; \"�\" -���. �., \"�\" - ���.�., \"�\" - ��. �., \"�\" - ���-��, \"�\" -����-��. \n
 ����� \"/\" -  �������� �������� �������. (-) - ������. (#d)(#t) - ��������� ������� � ������� �������. \b
 ���� ��������� ����������� �����������, �������� �������� �� ���, ����� � ��������, ��������, 
 ���� ����� ������ ���� ��������������. ��� ����������� �������� ������, ��� ��� ����� 
 ������������ ��� ��������� (������-������). � ����� ������� ����������� �������� ������ \"�\" ��� ��������� ��������� ��������� (������).\b";
    
    obj := firstobj();
    while (obj <> nil)
    {
      local sdescstr, generated=nil;
      local i=nil, nouns, adjs;
      local nl,al;
      
      // �������� �������� �������� (DESC)
      sdescstr:=obj.desc;
      
      if (sdescstr<>nil) i:=find(sdescstr,'/');
      
      // ���������, ��� ���� �� �� ���� html
      if (i<>nil && !(i>1 && substr(sdescstr,i-1,1)='<'))
      {
         local ret, sdesc_list=[], result=['' '' '' '' '' ''];
         
         // �������� �� ��������� ����� � ������ sdesc_list
         while (ret:=reSearch('([/$&@�~%��_+*#a-zA-Z�-��-�0-9-]+)|([][<>()!{}.,;"?\ ]+)', sdescstr), ret<>nil) 
         {
           sdesc_list+=ret[3]; 
           sdescstr:=substr(sdescstr,ret[1]+ret[2],length(sdescstr)); 
         }
         
         // �������� �� ������ ���� � �������� �� �������������
         for (i:=1; i<=length(sdesc_list); i++)
         {
             local j, temp;
             if (ret:=reSearch('.+/(.*)',sdesc_list[i]), ret<>nil)
             {
                 local flags:=reGetGroup(1)[3];
                 
                 //��������� ������� ����� ���� � ����� � �������
                 if ((obj.isHim || obj.isHer || obj.isThem)<>true)
                 {
                   if (reSearch('[m�]',flags)<>nil) obj.isHim:=true;
                   if (reSearch('[�f]',flags)<>nil) obj.isHer:=true;
                   if (find(flags,'2')<>nil) obj.isThem:=true;
                 }
                 
             	 // ���������, ����� �� ������������ ������
                 if (find(flags,'-')=nil)
                 {
                   temp:=generate(obj, sdesc_list[i], 0, ISDESC | RETDET);   
                   for (j:=1; j<=6; j++) result[j]:=result[j]+temp[j][1];
                   if (!generated) generated:=true;
                   
                   // ��������� ������� � ������� ��� ���������� ���������
                   // ���������� � ������ ��������� �����������!
                   if (find(flags,'�')<>nil || find(flags,'a')<>nil)
                    addword(obj, &adjective, sdesc_list[i]);
                   else
                    addword(obj, &noun, sdesc_list[i]);               
                 }
                 else
                 {
                    for (j:=1; j<=6; j++) 
                      result[j]:=result[j]+replaceStr(sdesc_list[i],'(.+)/.+$','$1');
                    
                    // ���������� � ������ ��������� �����������!
                    if (find(flags,'�')<>nil || find(flags,'a')<>nil)
                    addword(obj, &adjective, replaceStr(sdesc_list[i],'(.+)/.+$','$1')); 
                    else
                    addword(obj, &noun, replaceStr(sdesc_list[i],'(.+)/.+$','$1')); 
                 }
             }
             else 
               for (j:=1; j<=6; j++) result[j]:=result[j]+sdesc_list[i];
          }
          
          //�����
          if (generated) 
          {  
           obj.descs:=result;
          
#ifdef __DEBUG
           if (printout)
           {
            // ������� �������� �������� ���������
            local padezhi=[&sdesc, &rdesc, &ddesc, &vdesc, &tdesc, &pdesc];
            for (i:=1; i<=6; i++) "\"<<obj.(padezhi[i])>>\" ";
            "\n";
           }
#endif
          }
      }
      
      // �������� �������� ����������� �������
      nouns:= getwords(obj,&noun);
      adjs:= getwords(obj,&adjective);
      nl:=length(nouns);
      al:=length(adjs);
      
      
      //�������� ���������������
      for (i:=1; i<=nl; ++i)
      {
        local res=nil, sklon, temp;
        
        if (find(nouns[i],'/')) 
        {
          // ������ ��������� ����� ��� ������� �����������
          // ��� ������� ���������� ��������� ����� ����������, � ������� ����� 
          // �������� ��������� ��������� ��� ������������ ������        
          if (gencnt%20=1) inputevent(1);
          
          // ���������, ����� �� ������� ������� �� ��������� �����
          // '�����/ ������/ �������/' -> '�����/' '������/' '�������/'
          // ��������� ������� � ����� ������!
          while (temp:=self.breakup(nouns[i]), temp<>nil)
          {
           nouns-=nouns[i]; 
           nouns+=temp[1];
           nl+=temp[2]-1;
           //if (i!=1) i--;
          }      
          
          // ���������� ���������
           
          res:=generate(obj, nouns[i], 0, SUSHE|RETDET);
          
          for (sklon:=1; res<>nil && sklon<=length(res); ++sklon)
          if (res[sklon][3][1]!=0)
          {
           local same:=nil;
           local new_nouns:= getwords(obj, &noun);   
           
           res[sklon][1]:=dezyo(res[sklon][1]);       
           
           // ��������� ������ ������
           if (find(new_nouns,res[sklon][1])=nil) addword(obj, &noun, res[sklon][1]);
           else same:=true;
           
           // ������ ������� � �������
           if (sklon=3) addword(obj,&noun,res[sklon][1]+'#d');
           if (sklon=5) addword(obj,&noun,res[sklon][1]+'#t');
           if (sklon=7 && find(new_nouns,res[sklon][1])=nil) addword(obj, &noun, res[sklon][1]+'#t');
           
           // ����� ���������� � ����������
           if (printout) 
           {
             if (sklon=1 && res[sklon][2]) 
             {
               "\n";
               // ���� ������������� �������� �������, ������� ��
               if (reSearch('^[^mfnia12������]*[�a�]*$',res[sklon][2])) 
                { 
                  (obj.isThem)?"2":"1";
                  if (obj.gender=3) "�";
                  else (obj.gender=1)?"�":"�";
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
      
      // �������� ��������������
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
           
           // ������ ������� � �������
           if (sklon=3) addword(obj,&adjective,res[sklon][1]+'#d');
           if (sklon=5) addword(obj,&adjective,res[sklon][1]+'#t');
           if (sklon=7 && find(new_adjs, res[sklon][1])=nil) addword(obj, &adjective, res[sklon][1]+'#t');
           
           // ����� ���������� � ����������
           if (printout) 
           {
             if (sklon=1  && res[sklon][2]) 
             {
               "\n";
               if (reSearch('^[^mfnia12������]*[�a�]*$',res[sklon][2]))
                { 
                  (obj.isThem)?"2":"1";
                  if (obj.gender=3) "�";
                  else (obj.gender=1)?"�":"�";
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
     "\n����: <<gencnt>>\n��������� ������: <<gettime(GETTIME_TICKS)-ftime>> ���.\n";
}

binarize(str) =
{
  
}

// ������� �������� ����������� ������  �������� ������ � ��������� �������
check(obj, rules, info) =
{
    local  gender=nil,empty_info;
    
    //TODO: ���������� �������������� �� ������ �������
    
    
    // �������� ������� ����������� ������� ��������
    if (reSearch('^[^mfnia12������]*[�a�]*$',info)) empty_info:=true;
    
    // �������� ���������� � ��������
    if (find(rules,'U') && reSearch('u|�',info)=nil)  return true;    
    
   // ��������� ����������� ����������������/���������������
    if (find(rules,'A') && (reSearch('�',info))) return true;
    if (find(rules,'n') &&  (reSearch('a|�',info))) return true;
    if (find(rules,'I') &&  (reSearch('i|�',info)=nil)) return true;     
    
    // ����������� ���������� ����
   if (find(rules,'M')) 
      gender:=1;
   if (find(rules,'F')) 
      { if (gender=1) gender:=3; else gender:=2; }
   if (find(rules,'N')) 
      gender:=3;
   
   
   // ���� � �������� ������ ���. ��� ���. ���
   if (gender && gender!=3)
   {
   // ���� ������ ����� � �����, �� ��������������� �� �������� �������
     if (!empty_info) 
     {
         if ((reSearch('f|�',info) && gender!=2)||(reSearch('m|�',info) && gender!=1)) return true;
         //if ( ((find(info,'f')||find(info,'�')) && gender!=2)||((find(info,'m')||find(info,'�')) && gender!=1)) return true;
     }
     else
     {
      if ((obj.isHer && gender!=2)||(obj.isHim && gender!=1)) return true;
     }
   }
   
   //  ���� � �������� ������ ������� ���
   if (gender && gender=3)
     { 
      if (!empty_info)
       {  if (!(reSearch('f|�',info) && reSearch('m|�',info)) || reSearch('n|�',info)=nil) return true;   }
     else 
       {if (!(obj.isHer && obj.isHim) || !(obj.isHer || obj.isHim)) return true;}
     }

   // ���� � ������� ������������� �����
   if (find(rules,'2'))
     if (!empty_info)
     {
       if (find(info,'1')) return true;
     }
     else 
     {
      if (!obj.isThem) return true;
     }
     
    // ���� � ������� ������������ 
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

// ������ ������� �� ������
replacesym(str)=
{
    local pattern;
     // ��������� ������� ���� ����������� ���������
    if (reSearch(symtemplate,str)) 
    {
     local c, res;
     for (c:=1; c<=length(symbols); c++)
     {
       res:=reSearch(symbols[c][1],str);
       if (res)  
       { 
         // ������ ������ � ������ ����������� ���������
         pattern:=replaceStr(str, symbols[c][1], symbols[c][2]); 
         c:=500;
       }
      }
     }
     else return str;
     
     return pattern;
}
;


// ������� ���������
// ��������� ��� ���������: ������, ������ ��� ���������, ����� ���������
// (�� 0 �� 7; 7 - �������������� ������������),  �������� ���� ����� ����
// [��� - �� ���������],  ���� �������� ���������� � ������������� 
// ��������� ����� [�� ���������� �� �����.], ���� "������� ��� ��������" 
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
  
  // ������������� �� ������ ������������� ��� ������� ������
  if (generator.symtemplate='') generator.start(nil); 

  // ���� ����� � �������� ����� �� �����
  i:=find(str,'/');
  if (i) 
  {
    info:=substr(str,i+1,length(str));
    str:=substr(str,1,i-1);
  }

  i:=0; 

  info:=lowerru(info);
  
  // ������ ������� ��� ��� ����
  if (info<>nil &&  reSearch('n|�|a|�',info)=nil)
  {
    if (gr_type&PRILA) info+='�'; 
  }
  else info+='�'; 
   
    // TODO: ?
    if (str=nil || str='') return;
   
  // ��������� ������� �������� �� ���������
  // ������� ��������� ������
    // (��������)(���������� �������)(������ �������� �������). -��
    if (reSearch('^[^�-ߨ]*[�Ũ�������][���������]*$',str)) 
      info+='u';
    else 
    // �������� ��������� -��������� ����� � �����, ��� ����������
    // ��������, ����������� � ������ �� ��������� ��� ���������
    if (reSearch('^[^�Ũ�������]+[���������������������]$',str)) 
      info+='u';            
    else 
    // ������������ ������� � ���������. -���, ���
    if (reSearch('^[^���������]+[���������]$',str)) 
      info+='u'; 

    // ���� �������, ��������� ����� �������
    if (isdesc=0)  str:=lowerru(str);
    else 
    // ���� �������� � ���������, �� ��������� ������ ��������� ��� �����
      if (find(info, 'u')<>nil) str:=lower2x(str);
    
   
  // ���� ������ ��������� ����� 0 - �������� �� ����, ����� - ������ ����
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
   
  // ���� �� ���������� 
   // ������ ���� � ������ ���� ����������� ����,
  for (sklonenie:=startsklon; sklonenie<=finalsklon && (info<>nil); sklonenie++)
  {  
       local ind_rules_applied=nil; 
       
       // �������������� ������� ���������
       // ���� ������������ ���. ��� ��. �����, �� ������ ������������ ������������
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
       
       //��������� ������ ��������� ���������
       if (sklonenie>1)
       // ������ � ���� �� ������ �������������� ������
       for (i:=1; i<=length(generator.rules[sklonenie]) && ind_rules_applied=nil; i++)	
       {
           local replacement='', pattern, res;
           	  
           if (generator.check(obj, generator.rules[sklonenie][i][1], info)) continue;
           
           pattern:=generator.rules[sklonenie][i][2];
        
           // ��������� ������������ �������
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
       
        // ����� ������� ���������
       // ���� �� �������������� �������� ��������� �� ����������, �
       //  ��������� �� �������������� ������������, ��������� � �����
       if (!ind_rules_applied && sklonenie!=7)
       {
             local temp_result='';
            // ����� ��� ����� �������
            if (found_rule) 
            {     
               temp_result:=    replaceStr(str,generator.commonrules[found_rule][2]+'$',generator.commonrules[found_rule][sklonenie+1]);
 
               if (return_det) 
                 result += [[temp_result info [2 found_rule]]];
               else 
                 result +=  temp_result;            
            }
            else
            // ���� �������, ������ � ���� �� ������ ������ 
            for (i:=1; i<=length(generator.commonrules) && found_rule=nil; i++)	
            {
              local replacement='', pattern, res, gender=nil;
              
              if (generator.check(obj, generator.commonrules[i][1], info)) continue;
           	  
              pattern:=generator.commonrules[i][2];
           
              // ��������� ������������ �������
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
                                
                 // ���������� ��������� �������               
                 found_rule:=i;
               }
             }
         }
   } 

  if (result=[]) result:=[str]; else
  if (result=nil) result:=str; else
  // ���� ����� � ������� ���������
  if (found_rule && length(generator.commonrules[found_rule])=8) 
  {
    local temp:=generator.commonrules[found_rule][8];
    // ���� ���� ������ ����������, ����� �������� �� ������
    result+=[[temp '0' [0 0]]];
  }
  return result;
}


//Flint added this
//������� ����������� ��������� ����� � �������, ��������� ��� ����������� ������
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

// ��������� ��� ��������� ����� ������
lower2x: function(str)
{
  local strlen=length(str);
  
  if (strlen>2) return substr(str,1,strlen-2)+loweru(substr(str,strlen-1,strlen));
  
  return str;
}