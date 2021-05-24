#INCLUDE "TOTVS.CH"

User Function FIDC0001(_nID)

	Local aArea		:= GetArea()
	Local _lOk		:= .T.
	
	Local oJSONFIDC
	Local oJSONOrigem

	Default _nID	:= 0
	
	If (_nID != 0)
		
		conout("=== Inicio criação de titulo FIDC pagar ===")
		conout("FIDC Pagar Data/Hora: "+dtoc(Date())+' '+ SubStr(Time(), 1, 4))

		Begin Transaction
			
			oCPStruct		:= TContaPagarStruct():New()
			oCPLoad 		:= TContaPagarLoad():New()
			oContaPagar		:= TContaPagar():New()
			oCPStruct		:= oCPLoad:BuscarPorRecno(_nID)

			If (oCPStruct != Nil)

				oJSONOrigem:=JSONArray():New()
				oJSONOrigem:fromJSON(oJSONOrigem:toJSON(oCPStruct))
				cacheData():Set("FIDC0001","ORIGEM",oJSONOrigem)

				_cPreAnt			:= oCPStruct:cPrefixo
				_cNumAnt			:= oCPStruct:cNumero
				_cParAnt			:= oCPStruct:cParcela
				_cTipoAnt			:= oCPStruct:cTipo 
				_cForneceAnt		:= oCPStruct:cFornecedor
				_cLojaAnt			:= oCPStruct:cLoja
				
				_cPreNovo			:= ""
				_cNumNovo			:= ""
				_cParNovo			:= _cParAnt
				_cTipoNovo			:= "DP" 
				_cForneceNovo		:= "015050"
				_cLojaNovo			:= "01"				
				
				oCPStruct:cPrefixo 		:= _cPreNovo
				oCPStruct:cNumero		:= _cNumNovo
				oCPStruct:cParcela 		:= _cParNovo
				oCPStruct:cTipo 		:= _cTipoNovo
				oCPStruct:cNatureza 	:= "2990"
				oCPStruct:cFornecedor	:= _cForneceNovo
				oCPStruct:cLoja			:= _cLojaNovo
				oCPStruct:dEmissao		:= dDataBase
				oCPStruct:dVencto		:= oCPStruct:dVencOri

				oJSONFIDC:=JSONArray():New()
				oJSONFIDC:fromJSON(oJSONFIDC:toJSON(oCPStruct))
				cacheData():Set("FIDC0001","FIDC",oJSONFIDC)

				oResult:=oContaPagar:Incluir(oCPStruct)
				
				If (oResult:lOk)
					
					conout("FIDC - titulo pagar sucesso: "+oResult:cMensagem)
					
					//gerar rastreabilidade
					_cNumNovo					:= oContaPagar:oObj:cNumero //novo numero gerado
					
					oCPRStruct					:=  TContaPagarRastreabilidadeStruct():New()
					oCPRStruct:cFilOri 			:= cFilAnt
					oCPRStruct:cPrefOri 		:= _cPreAnt
					oCPRStruct:cNumOri			:= _cNumAnt
					oCPRStruct:cParOri          := _cParAnt
					oCPRStruct:cTipoOri         := _cTipoAnt	
					oCPRStruct:cForneceOri      := _cForneceAnt
					oCPRStruct:cLojaOri         := _cLojaAnt
										
					oCPRStruct:cFilDest         := cFilAnt
					oCPRStruct:cPrefDest        := _cPreNovo
					oCPRStruct:cNumDest         := _cNumNovo
					oCPRStruct:cParDest         := _cParNovo
					oCPRStruct:cTipoDest        := _cTipoNovo
					oCPRStruct:cForneceDest     := _cForneceNovo
					oCPRStruct:cLojaDest        := _cLojaNovo
					
					oCPRStruct:nValor           := 0 //TODO TRATAR
					oCPRStruct:dData            := dDataBase
					oCPRStruct:cStatus          := '0' //0=Ativo
					
				
					oContaPagarRast:=TContaPagarRastreabilidade():New()
					
					oResult:=oContaPagarRast:Incluir(oCPRStruct)
					
					If (oResult:lOk)
						conout("FIDC - titulo pagar rastreabilidade sucesso: "+oResult:cMensagem)
					Else
						conout("FIDC - titulo pagar rastreabilidade erro: "+oResult:cMensagem)
						_lOk := .F.
					EndIf
					
				Else
					conout("FIDC - titulo pagar erro: "+oResult:cMensagem)
					_lOk := .F.
				EndIf
				
				cacheData():delSection("FIDC0001")

			EndIf
			
			If (!_lOk)
				DisarmTransaction()
				//TODO enviar e-mail
			EndIf
			
		End Transaction 
		
		conout("=== Final criação de titulo FIDC pagar ===")
		conout("FIDC Pagar Data/Hora: "+dtoc(Date())+' '+ SubStr(Time(), 1, 4))
		
	EndIf
	
	RestArea(aArea)
		
Return _lOk
