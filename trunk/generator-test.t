#define USE_HTML_STATUS
#define USE_HTML_PROMPT

//#define _GENDETAILED

#include <advr.t>
#include <generator.t>
#include <stdr.t>
#include <errorru.t>
#include <extendr.t>
#include <spellchecker.t>


startroom:room
;

sample: thing
gdesc='�������/1�'
noun=
'��������/2' 	//2  -���
'������/2�' 	//2  -���
'�����/2'   	//2  -(����)��
'������/2'   	//2  -��
'����/2'		//2� -�
'������/2'	//2  -�
'������/1'	//   -��
'������/1' '����/1'	//   -[�������������]�
'����/1'	//   -�

'�����/1'	//   -��
'�������/1�'	//   -���
'�����/1�'	//U  -(4|�)��
'�����/1�' '�������/1�' // -(4|�)��
'�����/1�'	//   -��
'�����������/1�' '��������/1'	//   -��
'�����/2'	//2  -��
'�����������/2'	//2  -��
'�������/1'	//   -��
'���/i ����/'	//   -�
'������/ ����/�' //-��
'�����/ ���/ ���������/� ���/' //-(����)�
'������/ ��������/ ������/' //-��
'�����/ �����/��'	//-��
'������/1� ������/1m'
'�������/'
/*
'�����/, �����/, �����/, �����/, �����/, �����; �������/, �������/'
'������/, ��������/, �����/, ����/, ����/, ����/, ��������/'
*/

/*
'�����/, �����/, ������/, ������/, �������/, ������/'
'�����/ , �����/, ������/, �������/, ������/, ����/, �����/'
'�����/, �����/, ������/, �������/, �����/'
'���/, ����/'
'��������/, �����/'
'�������/, ����/'
'������/, �����/, ������/'
*/


/*
'�����/, ����/, �����/ . ������/  ;;' // �������� ����������
*/

/*
'����������/1�'	//   -(����)��
'�����/1�'	//   -(����)(����)��
'�����/1�'	//   -(����)(����)��
'������/1�'	//   -��������� �������
*/
;