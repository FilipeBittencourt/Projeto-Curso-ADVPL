#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Class TContaPagarLoad From LongClassName
	
	Method New() Constructor
	Method BuscarPorRecno() 

EndClass

Method New() Class TContaPagarLoad

Return()


Method BuscarPorRecno(_nId) Class TContaPagarLoad

	Local aArea				:= SE2->(GetArea())
	Local oCPStruct			:= Nil
	
	DbSelectArea('SE2')
	SE2->(DbSetOrder(0))
	SE2->(DbGoTo(_nId))
	
	If (!SE2->(Eof()))
	
		oCPStruct				:=  TContaPagarStruct():New()
		oCPStruct:cPrefixo 		:= SE2->E2_PREFIXO
		oCPStruct:cNumero 		:= SE2->E2_NUM
		oCPStruct:cParcela 		:= SE2->E2_PARCELA
		oCPStruct:cTipo 		:= SE2->E2_TIPO
		oCPStruct:cNatureza 	:= SE2->E2_NATUREZ
		oCPStruct:cFornecedor	:= SE2->E2_FORNECE
		oCPStruct:cLoja			:= SE2->E2_LOJA
		oCPStruct:dEmissao		:= SE2->E2_EMISSAO
		oCPStruct:dVencto		:= SE2->E2_VENCTO
		oCPStruct:nValor 		:= SE2->E2_VALOR
		oCPStruct:nPerJur 		:= SE2->E2_PORCJUR
		oCPStruct:dVencReal		:= SE2->E2_VENCREA
		oCPStruct:dVencOri	 	:= SE2->E2_VENCORI
		oCPStruct:nSaldo 		:= SE2->E2_SALDO
		
		
	EndIf

	SE2->(RestArea(aArea))
	
Return(oCPStruct)