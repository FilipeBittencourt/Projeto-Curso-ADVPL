#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MSC0430A
@author Tiago Rossini Coradini
@since 25/04/2017
@version 1.0
@description Ponto de entrada ao gravar reserva de estoque   
@obs OS: 4621-16 - Raul Viana - Tratamento de data de ultima alteração da reserva
/*/

Static __SC0_EMISSAO
Static __SC0_LINE

User Function MSC0430A()
Local aArea := GetArea()

	If !Inclui
		
		If !GdDeleted(__SC0_LINE)
		
			DbSelectArea("SC0")
			DbSetOrder(1)
			If SC0->(DbSeek(xFilial("SC0") + C0_NUM + GdFieldGet("C0_PRODUTO", __SC0_LINE) + GdFieldGet("C0_LOCAL", __SC0_LINE)))

				fUpdate()
				
				fAddHis("B")
	
			EndIf
		
		Else
		
			fAddHis("C")
		
		EndIf					
		
	Else
	
		fAddHis("A")
			
	EndIf
	
	__SC0_LINE++

	RestArea(aArea)
	
Return()


Static Function fUpdate()
	
	RecLock("SC0", .F.)
	
		If !Empty(__SC0_EMISSAO)
			SC0->C0_EMISSAO := __SC0_EMISSAO
		EndIf
		
		SC0->C0_YDATALT := dDataBase
	
	SC0->(MsUnLock())

Return()


// Ponto de entrada na validação da reserva, utilizado para tratar campo de data de alteração
User Function M430TOK()
	
	IF INCLUI
		__SC0_EMISSAO := Posicione("SC0", 1, xFilial("SC0") + M->C0_NUM, "C0_EMISSAO")
	ELSE
		__SC0_EMISSAO := Posicione("SC0", 1, xFilial("SC0") + SC0->C0_NUM, "C0_EMISSAO")
	ENDIF
	
	__SC0_LINE := 1
	
Return(.T.)


// Adiciona historico de alteracoes de reserva
Static Function fAddHis(cTipo)
	
	If GdFieldGet("C0_YHIST", __SC0_LINE) == "S"
		
		RecLock("ZCD", .T.)
		
			ZCD->ZCD_FILIAL := xFilial("ZCD")
			ZCD->ZCD_CODIGO := GetSxEnum("ZCD", "ZCD_CODIGO")
			ZCD->ZCD_TIPO := cTipo
			ZCD->ZCD_DATA := dDataBase
			ZCD->ZCD_HORA := Time()
			ZCD->ZCD_PRODUT := GdFieldGet("C0_PRODUTO", __SC0_LINE)
			ZCD->ZCD_LOCAL := GdFieldGet("C0_LOCAL", __SC0_LINE)
			ZCD->ZCD_QTD := GdFieldGet("C0_QUANT", __SC0_LINE)
			ZCD->ZCD_LOTE := GdFieldGet("C0_LOTECTL", __SC0_LINE)
			ZCD->ZCD_USR := cUserName
	
		ZCD->(MsUnLock())
		
	EndIf
	
Return()