#include "rwmake.ch"
#include "topconn.ch"

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA823     � Autor � Ranisses A. Corona    � Data � 24/06/10 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para Mensagem no CNAB do Contas a Receber.         ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Financeiro                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

User Function BIA823()
Private nMsg	:= ""
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

If SA1->A1_YDTPRO >= 6
	nMsg := "PROTESTAR APOS "+Alltrim(Str(SA1->A1_YDTPRO))+" DIAS CORRIDOS"
Else
	nMsg := "PROTESTAR APOS "+Alltrim(Str(SA1->A1_YDTPRO))+" DIAS UTEIS"
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(nMsg)