#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF081
@author Tiago Rossini Coradini
@since 02/07/2017
@version 2.0
@description Rotina aprovação automática de pedidos de compra
@obs OS: 2040-17 e 2047-17; Ticket: 3751 
@type function
/*/

// Dados anteriores a alteracao do pedido
Static __nVrTotAnt // Valor total
Static __nPerTol // Percentual de tolerancia
Static __aDatEnt // Datas de entrega
Static __lPedLib // Liberacao do pedido

// Indices das colunas do array de datas de entrega (__aDatEnt)
#Define _nNumPed 1
#Define _nItem 2
#Define _nDatEnt 3
#Define _nDatChe 4


User Function BIAF081(cNumPed)
Local aArea := GetArea()

	If fLibAutPed(cNumPed)
		
		If ValidCtr(cNumPed)
										
			fUpdSC7(cNumPed)
			
			fUpdSCR(cNumPed)
			
		EndIf
		
	EndIf
						
	RestArea(aArea)
	
Return()


// Analisa se o pedido podera ser liberado automaticamente
Static Function fLibAutPed(cNumPed)
Local lRet := .F. 

	If fAprCom(cNumPed) .And. (fTabPrc(cNumPed) .Or. fUltCom(cNumPed)) .Or. (__lPedLib .And. fRetVlrPed(cNumPed) <= __nVrTotAnt .And. fDatEnt(cNumPed)) 
	
		lRet := .T.
		
	EndIf

Return(lRet)


// Analisa se o pedido esta associado ao aprovador especifico
Static Function fAprCom(cNumPed)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()              
	
	cSQL := " SELECT COUNT(CR_USER) AS COUNT "
	cSQL += " FROM " + RetSQLName("SCR")
	cSQL += " WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR"))
	cSQL += " AND CR_NUM = " + ValToSQL(cNumPed)
	cSQL += " AND CR_USER = '000204' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If (cQry)->COUNT > 0
		
		lRet := .T.
		
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


// Analisa se o pedido possui tabela de preco
Static Function fTabPrc(cNumPed)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()              

	cSQL := " SELECT COUNT(C7_CODTAB) AS COUNT "
	cSQL += " FROM " + RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_NUM = " + ValToSQL(cNumPed)
	cSQL += " AND C7_CODTAB <> '' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If (cQry)->COUNT > 0
		
		lRet := .T.
		
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


// Analisa ultimas compras
Static Function fUltCom(cNumPed)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT C7_NUM, C7_PRODUTO, C7_QUANT, C7_PRECO "
	cSQL += " FROM " + RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_NUM = " + ValToSQL(cNumPed)
	cSQL += " AND C7_CONAPRO = 'B' "
	cSQL += " AND D_E_L_E_T_ = '' "
		
	TcQuery cSQL New Alias (cQry)	

	lRet := !(cQry)->(Eof())
		
	While !(cQry)->(Eof()) .And. lRet

		lRet := fPrcUltCom(cNumPed, (cQry)->C7_PRODUTO, (cQry)->C7_PRECO)	
	
		(cQry)->(DbSkip())				
	
	EndDo()
	
	(cQry)->(DbCloseArea())
		
Return(lRet)


// Analisa preco das ultimas compras
Static Function fPrcUltCom(cNumPed, cProd, nPrcCom)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()	        

	cSQL := " SELECT * " 
	cSQL += " FROM ( "
	cSQL += " SELECT TOP 1 C7_EMISSAO, C7_NUM, C7_QUANT, C7_PRECO "
	cSQL += " FROM SC7010 "
	cSQL += " WHERE C7_FILIAL = '01' "
	cSQL += " AND C7_NUM <> " + ValToSQL(cNumPed)
	cSQL += " AND C7_PRODUTO = "+ ValToSQL(cProd)
	cSQL += " AND C7_RESIDUO = '' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY C7_EMISSAO DESC "
	cSQL += " ) AS PEDC_BIANCO "
	
	cSQL += " UNION ALL "
	
	cSQL += " SELECT * "
	cSQL += " FROM ( "
	cSQL += " SELECT TOP 1 C7_EMISSAO, C7_NUM, C7_QUANT, C7_PRECO "
	cSQL += " FROM SC7050 "
	cSQL += " WHERE C7_FILIAL = '01' "
	cSQL += " AND C7_NUM <> " + ValToSQL(cNumPed)
	cSQL += " AND C7_PRODUTO = "+ ValToSQL(cProd)
	cSQL += " AND C7_RESIDUO = '' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY C7_EMISSAO DESC "
	cSQL += " ) AS PEDC_INCESA "
	
	cSQL += " UNION ALL "
	
	cSQL += " SELECT *
	cSQL += " FROM (
	cSQL += " SELECT TOP 1 C7_EMISSAO, C7_NUM, C7_QUANT, C7_PRECO "
	cSQL += " FROM SC7140 "
	cSQL += " WHERE C7_FILIAL = '01' "
	cSQL += " AND C7_NUM <> " + ValToSQL(cNumPed)
	cSQL += " AND C7_PRODUTO = "+ ValToSQL(cProd)
	cSQL += " AND C7_RESIDUO = '' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY C7_EMISSAO DESC "
	cSQL += " ) AS PEDC_VITCER "
	cSQL += " ORDER BY C7_EMISSAO DESC "

	TcQuery cSQL New Alias (cQry)

	lRet := !(cQry)->(Eof())
	  		
	If lRet
	
		If nPrcCom > (cQry)->C7_PRECO
			
			lRet := .F.
			
		EndIf
	
	EndIf
		
	(cQry)->(DbCloseArea())
	
Return(lRet)


// Aprova pedido
Static Function fUpdSC7(cNumPed)
Local nRecNo := 0
		
	nRecNo := SC7->(RecNo())
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	SC7->(DbSeek(xFilial("SC7") + cNumPed))
	
	While !SC7->(Eof()) .And. SC7->C7_NUM == cNumPed
	
		RecLock("SC7", .F.)
		
			SC7->C7_CONAPRO := "L"
			
		SC7->(MsUnLock())
		
		SC7->(DbSkip())
	
	EndDo()
	
	SC7->(DbGoTo(nRecNo))

Return()


// Aprova tabela de liberacao de pedido
Static Function fUpdSCR(cNumPed)
	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek(xFilial("SCR")+"PC"+cNumPed)
		While !SCR->(Eof()) .And. SCR->CR_FILIAL == cFilAnt .And. AllTrim(SCR->CR_NUM) == AllTrim(cNumPed)
			While !Reclock("SCR",.F.);EndDo		
			SCR->CR_STATUS := '03'
			SCR->CR_DATALIB := dDataBase 
			SCR->CR_USERLIB := SCR->CR_USER 
			SCR->CR_VALLIB := SCR->CR_TOTAL 
			SCR->CR_LIBAPRO := SCR->CR_APROV
			MsUnlock()
					
			SCR->(DbSkip())
		EndDo
	EndIf

Return()


// NAO REMOVER DO FONTE
// Ponto de entrada na gravacao do pedido, utilizado para preencher variaveis de conrole de alteracao
User Function MTA120G1()
	
	__nVrTotAnt := 0
	__nPerTol := Val(SuperGetMv("BIA_3751", .F., "0.5"))
	__aDatEnt := {}
	__lPedLib := .F.
	
	If Altera .And. fPedLib(SC7->C7_NUM)

		__nVrTotAnt := fRetVlrPed(SC7->C7_NUM)
		__nVrTotAnt += __nVrTotAnt * (__nPerTol / 100)
		__aDatEnt := fRetDatEnt(SC7->C7_NUM)
		__lPedLib := .T.
			
	EndIf

Return()


// Analisa se o pedido ja foi liberado
Static Function fPedLib(cNumPed)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(CR_NUM) AS COUNT "
	cSQL += " FROM "+ RetSQLName("SCR")
	cSQL += " WHERE CR_FILIAL = "+ ValToSQL(xFilial("SCR"))
	cSQL += " AND CR_NUM = "+ ValToSQL(cNumPed)
	cSQL += " AND CR_STATUS = '03'
	cSQL += " AND CR_DATALIB <> '' " 
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)	

	lRet := (cQry)->COUNT > 0
			
	(cQry)->(DbCloseArea())

Return(lRet)


// Retorna valor total do pedido
Static Function fRetVlrPed(cNumPed)
Local nRet := 0
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT SUM(C7_TOTAL - C7_VLDESC) + SUM(C7_TOTAL * C7_IPI / 100) AS C7_TOTAL "
	cSQL += " FROM " + RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_NUM = " + ValToSQL(cNumPed)
	cSQL += " AND D_E_L_E_T_ = '' "
		
	TcQuery cSQL New Alias (cQry)	

	nRet := (cQry)->C7_TOTAL
			
	(cQry)->(DbCloseArea())

Return(nRet)


// Analisa datas de entrega
Static Function fDatEnt(cNumPed)
Local lRet := .T.
Local aDatEnt := fRetDatEnt(cNumPed)
Local nCount := 1	
	
	If Len(__aDatEnt) == Len(aDatEnt)
	
		While nCount <= Len(__aDatEnt) .And. lRet
		
			nPos := aScan(aDatEnt, {|x| x[_nNumPed] == __aDatEnt[nCount, _nNumPed] .And. x[_nItem] == __aDatEnt[nCount, _nItem] })
			
			If nPos > 0					
			
				If __aDatEnt[nCount, _nDatEnt] <> aDatEnt[nPos, _nDatEnt] .Or. __aDatEnt[nCount, _nDatChe] <> aDatEnt[nPos, _nDatChe]
				
					lRet := .F.
				
				EndIf
			
			Else
				
				lRet := .F.
				
			EndIf		
		
			nCount++
			
		EndDo()
	
	Else
		
		lRet := .F.
		
	EndIf

Return(lRet)


// Retorna datas de entrega
Static Function fRetDatEnt(cNumPed)
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT C7_NUM, C7_ITEM, C7_DATPRF, C7_YDATCHE "
	cSQL += " FROM " + RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_NUM = " + ValToSQL(cNumPed)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY C7_NUM, C7_ITEM "
		
	TcQuery cSQL New Alias (cQry)	

	While !(cQry)->(Eof())
	
		aAdd(aRet, {(cQry)->C7_NUM, (cQry)->C7_ITEM, (cQry)->C7_DATPRF, (cQry)->C7_YDATCHE})
		
		(cQry)->(DbSkip())
		
	EndDo()
			
	(cQry)->(DbCloseArea())

Return(aRet)


Static Function ValidCtr(cNumPed)
Local lRetorno := .T.  
Local aAreaSCR := SCR->(GetArea())
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSC3 := SC3->(GetArea())
Local oContrato  := Nil
Private  SQL := ""
Private ENTER := CHR(13) + CHR(10)
	
	CC_PEDIDO := ALLTRIM(cNumPed)
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek(xFilial("SC7") + CC_PEDIDO)

	IF SUBSTRING(SC7->C7_CLVL,1,1) == '8' .OR. ALLTRIM(SC7->C7_CLVL) == '2130' .OR. ALLTRIM(SC7->C7_CLVL) == '1045' .OR. ALLTRIM(SC7->C7_CLVL) == '3145' .OR. ALLTRIM(SC7->C7_CLVL) == '3184' .OR. ALLTRIM(SC7->C7_CLVL) == '3185' .OR. ALLTRIM(SC7->C7_CLVL) == '4011'
		
		CC_PEDIDO := ALLTRIM(cNumPed)
		CSQL := "SELECT C7_YCONTR FROM "+RETSQLNAME("SC7")+" WHERE C7_NUM = '"+CC_PEDIDO+"' AND D_E_L_E_T_ = '' AND C7_CLVL = '"+SC7->C7_CLVL+"' "
		IF CHKFILE("_PEDI")
			DBSELECTAREA("_PEDI")
			DBCLOSEAREA()
		ENDIF
		
		TCQUERY CSQL ALIAS "_PEDI" NEW
		IF _PEDI->(EOF())
			lRetorno := .F.
		END IF
		
		IF ALLTRIM(_PEDI->C7_YCONTR) = ""
			lRetorno := .F.
		END IF
	
		//Tratamento dos contratos Genéricos
		IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
			CC_CONTRATO := _PEDI->C7_YCONTR
		ELSE
			CC_CONTRATO := SUBSTR(_PEDI->C7_YCONTR,1,5)
		ENDIF
	
		If !Empty(CC_CONTRATO)
		
			oContrato := TContratoParceria():New()
			
			oContrato:cNumero := _PEDI->C7_YCONTR
			
			If oContrato:Validate(CC_CONTRATO)
					
				DbSelectArea("SC3")
				DbSetOrder(1)
				If DbSeek(xFilial("SC3") + CC_CONTRATO)
						
					oContrato:Get()
	
					If oContrato:nValor == 0
						
						lRetorno := .F.
						
					Else
					
						SALDO_LIBERAR := oContrato:nSaldo
						PC_ATUAL := SCR->CR_TOTAL
							
						If (SALDO_LIBERAR - PC_ATUAL) < -1
							
							lRetorno := .F.
							
							MsgAlert("Este pedido não poderá ser liberado pois o valor limite do contrato será ultrapassado!", "BIAF081")
							
						EndIf
						
					EndIf
	
				EndIf
			
			Else
			
				lRetorno := .F.
				
			EndIf
			
		EndIf
		
	EndIf

RestArea(aAreaSC7)
RestArea(aAreaSCR)
RestArea(aAreaSC3)

Return(lRetorno)