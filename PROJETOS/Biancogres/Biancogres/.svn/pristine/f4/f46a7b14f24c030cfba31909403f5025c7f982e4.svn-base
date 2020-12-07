#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "topconn.ch"


User Function VRESPEDI(_aCols, _aHeader, cPed)

	Local __lOK			:= .T.
	Local __cMsg		:= ""	
	Local __nI			:= 0
	Local __cProd		:= ""
	Local __cItem		:= ""
	Local __cTpEst		:= ""
	Local __cLote		:= "" 	
	Local __cPed		:= cPed
	Local __cEmpPed		:= ""
	Local cAliasTemp	:= Nil
	Local cQuery 		:= ""
		
	For __nI := 1 To Len(_aCols)
	
			
		If !_aCols[__nI][Len(_aHeader)+1]
			
			If (__nI == 1)
				loop
			EndIf
		
			//Tratamento outro produtos
			__cProd 	:= _aCols[__nI][aScan(_aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
			__cItem 	:= _aCols[__nI][aScan(_aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})]
			__cTpEst 	:= _aCols[__nI][aScan(_aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})]
			__cLote		:= _aCols[__nI][aScan(_aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})]
			
			If SB1->(DbSeek(XFilial("SB1")+__cProd)) .And. AllTrim(SB1->B1_TIPO) ==  "PA"

				If AllTrim(cEmpAnt+cFilAnt) == "0701" .Or. AllTrim(cEmpAnt+cFilAnt) == "1401"
					__cEmpPed	:= _aCols[__nI][aScan(_aHeader,{|x| AllTrim(x[2]) == "C6_YEMPPED"})]
					
					//Alert(__cEmpPed)
					If (Empty(__cEmpPed))
						__cEmpPed := "01"
					EndIf
					
					If (AllTrim(__cTpEst) == 'E')
						cQuery := " select * from SC0"+__cEmpPed+"0  						"
						cQuery += " where C0_PRODUTO	= '"+__cProd+"' 					"
						cQuery += " AND C0_FILIAL 		= '"+xFilial('SC0')+"' 				"
						cQuery += "	AND C0_LOTECTL 		= '"+__cLote+"' 					"
						cQuery += "	AND C0_YPITORI 		= '"+__cPed+__cItem+"' 				"
						cQuery += "	AND C0_YEMPORI 		= '"+cEmpAnt+cFilAnt+"'				"
						cQuery += "	AND C0_YTEMP   		= 'S'		 						"
						cQuery += "	AND D_E_L_E_T_ 		= ''			 					"
					ElseIf (AllTrim(__cTpEst) == 'R')
						cQuery := " select * from PZ0"+__cEmpPed+"0  						"
						cQuery += " where PZ0_CODPRO	= '"+__cProd+"' 					"
						cQuery += " AND PZ0_FILIAL 		= '"+xFilial('PZ0')+"' 				"
						cQuery += "	AND PZ0_PEDIDO 		= '"+__cPed+"' 						"
						cQuery += "	AND PZ0_ITEMPV 		= '"+__cItem+"' 					"
						cQuery += "	AND PZ0_STATUS 		= 'T'								"
						cQuery += "	AND D_E_L_E_T_ 		= ''			 					"
					EndIf
																	
				Else
					__cEmpPed	:= cEmpAnt
					
					If (AllTrim(__cTpEst) == 'E')
						cQuery := " select * from SC0"+__cEmpPed+"0						  	"
						cQuery += " where C0_PRODUTO 	= '"+__cProd+"' 					"
						cQuery += " AND C0_FILIAL 		= '"+xFilial('SC0')+"' 				"
						cQuery += "	AND C0_LOTECTL 		= '"+__cLote+"' 					"
						cQuery += "	AND C0_YPEDIDO 		= '"+__cPed+"' 						"
						cQuery += "	AND C0_YITEMPV 		= '"+__cItem+"' 					"
						cQuery += "	AND C0_YTEMP   		= 'S'		 						"
						cQuery += "	AND D_E_L_E_T_ 		= ''			 					"
					ElseIf (AllTrim(__cTpEst) == 'R')
						cQuery := " select * from PZ0"+__cEmpPed+"0 					 	"
						cQuery += " where PZ0_CODPRO	= '"+__cProd+"' 					"
						cQuery += " AND PZ0_FILIAL 		= '"+xFilial('PZ0')+"' 				"
						cQuery += "	AND PZ0_PEDIDO 		= '"+__cPed+"' 						"
						cQuery += "	AND PZ0_ITEMPV 		= '"+__cItem+"' 					"
						cQuery += "	AND PZ0_STATUS 		= 'T'								"
						cQuery += "	AND D_E_L_E_T_ 		= ''			 					"
					EndIf		
					
				EndIf
				
				conout(cQuery)
				If (!Empty(cQuery))
					cAliasTemp := GetNextAlias()
					TcQuery cQuery New Alias (cAliasTemp)
					
					If ((cAliasTemp)->(Eof()))
						__lOK 	:= .F.
						__cMsg	+= " O Produto/Lote: "+__cProd+"/"+__cLote+" teve sua reserva temporária excluida. Favor selecionar a linha do pedido e reservar o produto novamente."+CRLF
					EndIf
					(cAliasTemp)->(DbCloseArea())					
				EndIf						
			EndIf
			
		EndIf	
					
	Next __nI
	
	If (!__lOK)
		MsgAlert(__cMsg, "MT410TOK")
	EndIf

Return __lOK