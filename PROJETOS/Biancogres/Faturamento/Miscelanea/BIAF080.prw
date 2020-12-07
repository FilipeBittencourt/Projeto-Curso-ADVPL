#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF080
@author Tiago Rossini Coradini
@since 12/07/2017
@version 1.0
@description Rotina generica para atualização de parametros do sistema
@obs OS: 1600-17 - Raul Viana
@type function
/*/


User Function BIAF080()
Local aArea := GetArea()

	If !Empty(SE1->E1_PEDIDO)
	
		DbSelectArea("SC5")
		DbSetOrder(1)
		If SC5->(DbSeek(xFilial("SC5") + SE1->E1_PEDIDO))
		
			If SC5->C5_YFORMA == "4"
			
				RecLock("Z99", .T.)
				
					Z99->Z99_FILIAL := xFilial("Z99")
					Z99->Z99_PREFIX := SE1->E1_PREFIXO
					Z99->Z99_NUM := SE1->E1_NUM
					Z99->Z99_PARCEL := SE1->E1_PARCELA
					Z99->Z99_EMISSA := SE1->E1_EMISSAO
					Z99->Z99_VENCTO := fGetDatVen()
				
				Z99->(MsUnLock())							
			
			EndIf
				
		EndIf
			
	EndIf
	
	RestArea(aArea)
	
Return()


Static Function fGetDatVen()
Local dRet := SE1->E1_VENCTO
Local nVlrNFS := fGetVlrNFS()
Local nVlrCT := 0
Local cSQL := ""
Local cQry := GetNextAlias()
Local lLoop := .T.              

	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VALOR, E1_VENCTO "
	cSQL += " FROM " + RetSQLName("SE1")
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND SUBSTRING(E1_PREFIXO, 1, 2) = 'CT' "
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND E1_CLIENTE = " + ValToSQL(SE1->E1_CLIENTE)
	cSQL += " AND E1_LOJA = " + ValToSQL(SE1->E1_LOJA)
	cSQL += " AND E1_PEDIDO = " + ValToSQL(SE1->E1_PEDIDO)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E1_PARCELA "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof()) .And. lLoop
	
		nVlrCT += (cQry)->E1_VALOR
		
		If nVlrCT >= nVlrNFS 
		
			lLoop := .F.
			
			dRet := sToD((cQry)->E1_VENCTO)
			
		EndIf 
		
		(cQry)->(DbSkip())				
	
	EndDo()
	
	(cQry)->(DbCloseArea())

Return(dRet)


Static Function fGetVlrNFS()
Local nRet := 0
Local cSQL := ""
Local cQry := GetNextAlias()
              
	cSQL := " SELECT SUM(E1_VALOR) AS E1_VALOR "
	cSQL += " FROM " + RetSQLName("SE1")
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_NUM <= " + ValToSQL(SE1->E1_NUM)	
	cSQL += " AND E1_TIPO = 'NF' "
	cSQL += " AND E1_CLIENTE = " + ValToSQL(SE1->E1_CLIENTE)
	cSQL += " AND E1_LOJA = " + ValToSQL(SE1->E1_LOJA)
	cSQL += " AND E1_PEDIDO = " + ValToSQL(SE1->E1_PEDIDO)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->E1_VALOR)
		
		nRet := (cQry)->E1_VALOR
		
	EndIf
	
	(cQry)->(DbCloseArea())
	
Return(nRet)


User Function BIAF080A()
Local nRecSE1 := 0
Local cSQL := ""
Local cQry := GetNextAlias()              

	DbSelectArea("Z60")
	DbSetOrder(1)	
	
	While !Z60->(Eof())
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		If SC5->(DbSeek(xFilial("SC5") + Z60->Z60_NUMPED))					
				
			cSQL := " SELECT R_E_C_N_O_ AS RECNO "
			cSQL += " FROM " + RetSQLName("SE1")
			cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
			cSQL += " AND E1_TIPO = 'NF' "
			cSQL += " AND E1_CLIENTE = " + ValToSQL(SC5->C5_CLIENTE)
			cSQL += " AND E1_LOJA = " + ValToSQL(SC5->C5_LOJACLI)
			cSQL += " AND E1_PEDIDO = " + ValToSQL(SC5->C5_NUM)
			cSQL += " AND D_E_L_E_T_ = '' "
			cSQL += " ORDER BY E1_EMISSAO "
		
			TcQuery cSQL New Alias (cQry)
		
			While !(cQry)->(Eof()) .And. !Empty((cQry)->RECNO)				
				
				nRecSE1 := (cQry)->RECNO
				
				DbSelectArea("SE1")
				SE1->(DbGoTo(nRecSE1))
				
				U_BIAF080()
										
				(cQry)->(DbSkip())
					
			EndDo
			
			(cQry)->(DbCloseArea())			
					
		EndIf
		
		Z60->(DbSkip())	
	
	EndDo	

Return()


User Function BIAF080B()
Local nCount := 0
			
	For nCount := 1 To 14

		RpcSetType(3)
		RpcSetEnv(StrZero(nCount, 2), "01")
	
		DbSelectArea("Z99")
		DbSetOrder(1)	
	
		U_BIAF080A()
	
		RpcClearEnv()
	
	Next			
	
Return()