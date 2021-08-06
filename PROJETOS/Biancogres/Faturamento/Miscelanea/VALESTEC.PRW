#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TOPCONN.CH"

User Function VALESTEC(cCarga)
	
	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local cAliasTmp 	:= GetNextAlias()
	Local cMsg			:= ""
	Local lOk			:= .T.
	Local cBanco		:= ""
	
	If(AllTrim(cEmpAnt) == '01')
		cBanco		:= "DADOSEOS"
	ElseIf(AllTrim(cEmpAnt) == '05')
		cBanco		:= "DADOS_05_EOS"
	ElseIf(AllTrim(cEmpAnt) == '13')
		cBanco		:= "DADOS_13_EOS"
	ElseIf(AllTrim(cEmpAnt) == '14')
		cBanco		:= "DADOS_14_EOS"			
	EndIf
		
	cQuery += " select C9_PRODUTO, C9_LOTECTL, C9_QTDLIB, cod_produto, sdo_lote, SALDO_ECOS=sdo_saldo_estoque 	"+ CRLF
	cQuery += " from "+ RetSqlName("ZZW")+" ZZW                                                     			"+ CRLF
	cQuery += " JOIN "+ RetSqlName("SC9")+" SC9 ON                                                  			"+ CRLF
	cQuery += " 	C9_PEDIDO			= ZZW_PEDIDO                                                			"+ CRLF
	cQuery += " 	AND C9_ITEM			= ZZW_ITEM                                                  			"+ CRLF
	cQuery += " 	AND C9_SEQUEN		= ZZW_SEQUEN                                                			"+ CRLF
	cQuery += " 	AND C9_FILIAL		= ZZW_FILIAL                                                			"+ CRLF
	cQuery += " 	AND SC9.D_E_L_E_T_	= ''                                                        			"+ CRLF
	cQuery += " JOIN ["+cBanco+"].[dbo].[cep_saldo_produto]  ON                                       			"+ CRLF
	cQuery += " 	cod_produto COLLATE Latin1_General_BIN = RTRIM(C9_PRODUTO)                      			"+ CRLF
	cQuery += " 	AND sdo_lote COLLATE Latin1_General_BIN = RTRIM(C9_LOTECTL)                     			"+ CRLF
	cQuery += " where ZZW_CARGA = '"+cCarga+"'                                                         			"+ CRLF
	cQuery += " 	AND ZZW.D_E_L_E_T_ = ''                                                         			"+ CRLF
	cQuery += " 	AND ZZW.ZZW_FILIAL = '"+ xFilial("ZZW") +"'													"+ CRLF
	cQuery += " 	AND ZZW.ZZW_STATUS = '1'																	"+ CRLF
				
	TcQuery cQuery New Alias (cAliasTmp)
	
	cMsg += "<p>Os Produtos/Lote listados abaixo não tem saldo suficiente no ecosis:</p>"
	While (!(cAliasTmp)->(Eof()))
		
		If ((cAliasTmp)->SALDO_ECOS <= (cAliasTmp)->C9_QTDLIB)
			
			cMsg += "<p>Produto/Lote: "+(cAliasTmp)->C9_PRODUTO+"/"+(cAliasTmp)->C9_LOTECTL+", Quantidade Lib.: "+cvaltochar((cAliasTmp)->C9_QTDLIB)+", Saldo Ecosis: "+cvaltochar((cAliasTmp)->SALDO_ECOS)+"</p>"
			
			lOk := .F.
			
		EndIf
		
		(cAliasTmp)->(DbSkip())	
	EndDo
	
	(cAliasTmp)->(DbCloseArea())
	
	If (!lOk)
		MsgAlert(cMsg, "")
	EndIf

	RestArea(aArea)
	
Return lOk
