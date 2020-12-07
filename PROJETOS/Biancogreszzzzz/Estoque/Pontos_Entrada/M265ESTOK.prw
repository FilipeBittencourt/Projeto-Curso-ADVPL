#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} M265ESTOK
@author Marcos Alberto Soprani
@since 29/01/14
@version 1.0
@description Confirmação da gravação do Estorno
@type function
/*/

User Function M265ESTOK()

	Private lRet := .T.

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+M->DA_PRODUTO,.F.)
	
	If !(SB1->B1_TIPO $ "PA#PP") .And. M->DA_LOCAL $ "02#04"
		MsgBox("Almoxarifado informado incorreto: " + cAlmVend,"M265ESTOK","STOP")
		lRet := .F.			
	EndIf
	
	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf
	
	//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
	// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
	If M->DA_DATA <= GetMv("MV_YULMES")
		MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","M265ESTOK")
		lRet := .F.
	EndIf

Return(lRet)
