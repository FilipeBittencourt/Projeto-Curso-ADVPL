#include "rwmake.ch"
#include "topconn.ch"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA823     � Autor � Ranisses A. Corona    � Data � 24/06/10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Execblock para Mensagem no CNAB do Contas a Receber.         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Financeiro                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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