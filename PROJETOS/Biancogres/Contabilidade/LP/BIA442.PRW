#include "rwmake.ch"
#include "topconn.ch"

User Function BIA442()

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA442     � Autor � MICROSIGA VITORIA     � Data � 25/09/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Rotina origem na movimentacao bancaria                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador x Base                                         ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Private cConta
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

cArq  := Alias()
cInd  := IndexOrd()
cReg  := Recno()
             
IF SE5->E5_MOTBX == "DEB" .OR. ALLTRIM(FUNNAME()) == "FINA090"
   cConta := "11105002"
ELSE
   cConta := SA6->A6_CONTA
ENDIF                                                                                                               

DbSelectArea("SE5")    
DbSetOrder(1)
RecLock("SE5",.F.)
SE5->E5_YORIGEM := ALLTRIM(FUNNAME())
MsUnLock()

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(cConta)