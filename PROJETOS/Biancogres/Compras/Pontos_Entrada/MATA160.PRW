#include "rwmake.ch"        
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un嚻o	 � MATA160    Autor � Nilton				 � Data �04/04/03  潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri嚻o � Solicitar a linha na cotacao 			                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so		 � SIGAEST													   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
User Function MATA160()     
aArea := GetArea()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Solicitar a linha                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
/*
Private aitens := {"Linha 01","Linha 02"}, oDlg1, nList := 1
@ 0,0 TO 200,300 DIALOG oDlg1 TITLE "Selecione a linha de Producao"
@ 10,10 SAY "Linha:"
@ 20,10  LISTBOX nlist  ITEMS aitens SIZE 40,40
@ 30,100 BMPBUTTON TYPE 1 ACTION Close(oDlg1)
ACTIVATE DIALOG oDlg1 CENTER
DbSelectArea("SC7")
DbSetOrder(1)
DbSeek(xFilial("SC7")+SC8->C8_NUMPED)
Do while .not. eof() .and. C7_FILIAL == xFilial("SC7") .AND. ;
                             C7_NUM == SC8->C8_NUMPED
   DbSelectArea("SC7")
   RecLock("SC7",.f.)
   SC7->C7_YLINHA  := Str(nlist,1)
   MsUnlock()                               
   DbSkip()
EndDo             
*/
RestArea(aArea)
Return