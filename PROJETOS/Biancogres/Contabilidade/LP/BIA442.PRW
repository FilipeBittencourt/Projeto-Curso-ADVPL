#include "rwmake.ch"
#include "topconn.ch"

User Function BIA442()

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA442     � Autor � MICROSIGA VITORIA     � Data � 25/09/08 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Grava Rotina origem na movimentacao bancaria                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
