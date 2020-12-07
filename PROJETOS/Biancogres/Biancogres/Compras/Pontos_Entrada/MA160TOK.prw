#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MA160TOK
@author Tiago Rossini Coradini
@since 21/02/2017
@version 1.0
@description Ponto de entrada valida��o da analise de cota��es.
@obs OS: 4533-16 - Claudia Carvalho
@type function
/*/

#DEFINE nA_Planilha 3
#DEFINE nF_CHECK 1
#DEFINE nF_FORNECE 2
#DEFINE nF_LOJA 3
#DEFINE nF_NOME 4
#DEFINE nF_NUMPRO 5
#DEFINE nF_ITEMCT 12

User Function MA160TOK()
Local lRet := .T.
Local nX := 1
Local nY := 0
Local aPlanilha := ParamIxb[nA_Planilha]

	While nX <= Len(aPlanilha) .And. lRet
		
		// Loop nos fornecedores da cotacao
		For nY := 1 To Len(aPlanilha[nX])
		
			// Verifica se o fornecedor atual foi selecionado para gerar pedido
			If Upper(aPlanilha[nX][nY][nF_CHECK]) == "XX"
							
				If !fVldDatChe(SC8->C8_NUM, aPlanilha[nX][nY][nF_FORNECE], aPlanilha[nX][nY][nF_LOJA], aPlanilha[nX][nY][nF_ITEMCT], aPlanilha[nX][nY][nF_NUMPRO])									
					
					lRet := .F.
					
					MsgStop("Aten��o, o campo Data de Chegada do item: "+ aPlanilha[nX][nY][nF_ITEMCT] +", fornecedor:" + aPlanilha[nX][nY][nF_FORNECE];
					  			+"-"+ aPlanilha[nX][nY][nF_LOJA] +"-"+ AllTrim(aPlanilha[nX][nY][nF_NOME]) + " n�o foi preenchido.", "Campo Obrigat�rio")
					
				EndIf
				
			EndIf
		
		Next
	
		nX++
		
	EndDo()

Return(lRet)


Static Function fVldDatChe(cNum, cFornece, cLoja, cItem, cNumPro)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT C8_YDATCHE "
	cSQL += " FROM "+ RetSQLName("SC8")
	cSQL += " WHERE C8_FILIAL = "+ ValToSQL(xFilial("SC8"))
	cSQL += " AND C8_NUM = "+ ValToSQL(cNum) 
	cSQL += " AND C8_FORNECE = "+ ValToSQL(cFornece)
	cSQL += " AND C8_LOJA = "+ ValToSQL(cLoja)
	cSQL += " AND C8_ITEM = "+ ValToSQL(cItem)
	cSQL += " AND C8_NUMPRO = "+ ValToSQL(cNumPro)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	If Empty((cQry)->C8_YDATCHE)
		lRet := .F.
	EndIf
	
	(cQry)->(DbCloseArea())
	
Return(lRet)