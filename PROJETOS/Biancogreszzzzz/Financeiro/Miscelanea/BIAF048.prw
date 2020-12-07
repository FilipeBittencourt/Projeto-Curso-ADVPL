#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF048
@author Tiago Rossini Coradini
@since 12/09/2016
@version 1.0
@description Rotina para exclusão automatica de titulos provisorios, referentes ao pedido de venda de RA. 
@obs OS: 1431-16 - Elimonda Moura
@type function
/*/

User Function BIAF048(cNumPed, cCliOri)
Local cEmpPed := cEmpAnt
Local cSQL := ""
Local cQry := GetNextAlias()
Local cQryLM := GetNextAlias()
Local cSC5 := If (!Empty(cCliOri), "SC5070", RetSQLName("SE1"))
Local cSE1 := If (!Empty(cCliOri), "SE1070", RetSQLName("SE1"))

	// Busca pedido de origem na LM
	If cEmpAnt $ '01_05_13_14' .And. !Empty(cCliOri)
	
		cSQL := " SELECT C5_NUM "
		cSQL += " FROM SC5070 "
		cSQL += " WHERE C5_YPEDORI = "+ ValToSQL(cNumPed)
		cSQL += " AND C5_YEMPPED = "+ ValToSQL(cEmpAnt)
		cSQL += " AND D_E_L_E_T_ = '' "
	
		TcQuery cSQL New Alias (cQryLM)
						
		If !Empty((cQryLM)->C5_NUM)
			cNumPed := (cQryLM)->C5_NUM
			cEmpPed := "07"
		EndIf
		
		(cQryLM)->(DbCloseArea())

	EndIf
	
	
	// Busca informações do titulo provisorio 
	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA "
	cSQL += " FROM " + cSE1
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND SUBSTRING(E1_PREFIXO, 1, 2) = 'PR' "
	cSQL += " AND SUBSTRING(E1_PREFIXO, 3, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9') "
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND E1_PEDIDO = " + ValToSQL(cNumPed)
	cSQL += " AND E1_BAIXA = '' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
					
	If !Empty((cQry)->E1_PREFIXO)	
		
		If cEmpPed == "07"
		
			U_BIAMsgRun("Aguarde... Excluindo Título Provisório na LM",, {|| fDelTitPR((cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, (cQry)->E1_TIPO, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA) })
			
		Else
			
			U_BIAF048A((cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, (cQry)->E1_TIPO, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA)
			
		EndIf				
		
	EndIf

Return()


Static Function fDelTitPR(cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja) 
Local lRet := .T.

	lRet := U_FROPCPRO("07", "01", "U_BIAF048A", cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja)

Return(lRet)


User Function BIAF048A(cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja)
Local lRet := .T.
Local oConRecPR := TContaReceber():New()
					
	oConRecPR:cPrefixo := cPrefixo
	oConRecPR:cNumero := cNumero
	oConRecPR:cParcela := cParcela
	oConRecPR:cTipo := cTipo
	oConRecPR:cCliente := cCliente
	oConRecPR:cLoja := cLoja
	
	lRet := oConRecPR:Excluir()
		
Return(lRet)