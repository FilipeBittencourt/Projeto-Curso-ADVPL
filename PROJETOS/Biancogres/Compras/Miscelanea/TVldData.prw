#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TVldData
@author Tiago Rossini Coradini
@since 26/02/2018
@version 1.0
@description Classe para validação dos campos de data de entrega, chegada e necessidade no pedido de compra 
@obs Ticket: 2209
@type Function
/*/

Class TVldData
  
	Data cId // Identificador
	Data cFItem // Nome do Campo Item
	Data cFProd // Nome do campo Produto
	Data cFDatEmi // Nome do campo data de emissao
	Data cFDatEnt // Nome do campo data de entrega
	Data cFDatChe // Nome do campo data de chegada
	Data cFDatNec // Nome do campo data de necessidade
	Data cFNumSC // Nome do campo do numero da SC
	Data cFItemSC // Nome do campo do item da SC	
	
	Data cItem // Item
	Data cProd // Produto
	Data dDatEmi // Data de emissao
	Data dDatEnt // Data de entrega
	Data dDatChe // Data de chegada
	Data dDatNec // Data de necessidade
	Data cNumSC // Numero da SC
	Data cItemSC // Item da SC
	Data dDatEmiSC // Data de emissao da SC
		
	Data cMsg // Mensagem de bloqueio
		
	Method New(cId)
	Method GetValue(nLine) // Retorna valores
	Method ValidLine(nLine, cField) // Valida linha
	Method ValidField(cMField) // Valida campo
	
EndClass


Method New(cId) CLass TVldData

	::cId := Upper(cId)

	If Upper(::cId) == "PEDCOM" // Pedido de Compra
	
		::cFItem := "C7_ITEM"
		::cFProd := "C7_PRODUTO"
		::cFDatEmi := "C7_EMISSAO" 
		::cFDatEnt := "C7_DATPRF" 
		::cFDatChe := "C7_YDATCHE"
		::cFDatNec := "C7_YDTNECE"
		::cFNumSC := "C7_NUMSC"
		::cFItemSC := "C7_ITEMSC"

  EndIf
  
  ::cItem := ""
	::cProd := ""
	::dDatEmi := cToD("")
	::dDatEnt := cToD("")
	::dDatChe := cToD("")
	::dDatNec := cToD("")
	::dDatEmiSC := cToD("")
	::cNumSC := ""
	::cItemSC := ""
	  
  ::cMsg := ""
 	
Return()


Method GetValue(nLine) Class TVldData
	
	::cItem := If (!Empty(::cFItem), GDFieldGet(::cFItem, nLine), StrZero(nLine, 4)) 
	::cProd := GDFieldGet(::cFProd, nLine, .T.)	
	::dDatEmi := dA120Emis
	::dDatEnt := GDFieldGet(::cFDatEnt, nLine, .T.)
	::dDatChe := GDFieldGet(::cFDatChe, nLine, .T.)
	::dDatNec := GDFieldGet(::cFDatNec, nLine, .T.)
	::cNumSC := GDFieldGet(::cFNumSC, nLine, .T.)
	::cItemSC := GDFieldGet(::cFItemSC, nLine, .T.)
	
	If !Empty(::cNumSC) .And. !Empty(::cItemSC)
	
		DbSelectArea("SC1")
		DbSetOrder(1)
		If SC1->(DbSeek(xFilial("SC1")+ ::cNumSC + ::cItemSC))
		
			::dDatEmiSC := SC1->C1_EMISSAO
		
		EndIf
				
	EndIf
	
	::cMsg := "Item: "+ ::cItem +" - Produto: "+ AllTrim(::cProd) +" - INVÁLIDO."+ Chr(13)+Chr(10) +"Motivo: "
			
Return()


Method ValidLine(nLine, cField) Class TVldData
Local lRet := .T.

	Default cField := ""
	
	::GetValue(nLine)
	  
	If !Empty(::cProd)
	
		If (Empty(cField) .Or. cField == ::cFDatNec) .And. !Empty(::dDatEmiSC) .And. !Empty(::dDatNec) .And. ::dDatNec < ::dDatEmiSC 

			lRet := .F.
			MsgAlert(::cMsg + "Data de necessidade: "+ cValToChar(::dDatNec) +" menor que a data de emissão da SC: "+ cValToChar(::dDatEmiSC), "Validação de data de necessidade")				

		ElseIf (Empty(cField) .Or. cField == ::cFDatEnt) .And. !Empty(::dDatEnt) .And. ::dDatEnt < ::dDatEmi

			lRet := .F.
			MsgAlert(::cMsg + "Data de entrega: "+ cValToChar(::dDatEnt) +" menor que a data de emissão: "+ cValToChar(::dDatEmi), "Validação de data de entrega")
		
		ElseIf (Empty(cField) .Or. cField == ::cFDatChe) .And. !Empty(::dDatChe) .And. ::dDatChe < ::dDatEmi

			lRet := .F.
			MsgAlert(::cMsg + "Data de chegada: "+ cValToChar(::dDatChe) +" menor que a data de emissão: "+ cValToChar(::dDatEmi), "Validação de data de chegada")
		
		EndIf
								
	EndIf
	
Return(lRet)


Method ValidField(cMField) Class TVldData
Local lRet := .T. 
Local cField := SubStr(cMField, 4, Len(cMField))
	
	If cField $ (::cFDatEnt + "/" + ::cFDatChe + "/" + ::cFDatNec)
		
		If !::ValidLine(N, cField)
			lRet := .F.	    			
		EndIf
		
	EndIf
		
Return(lRet)