#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TPoliticaCredito
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe para tratamento de Politica de Credito
@type class
/*/

Class TPoliticaCredito From LongClassName
	
	Data cCodPro
	Data dData
	Data cCliente
	Data cLoja
	Data cGrpVen
	Data cCnpj
	Data nLimCreSol
	Data nVlrObr	
	Data cOrigem
	Data oVariavel
	Data oRocket
		
	Method New() Constructor
	Method Process()
	Method UpdProcess()
	Method InProcess()
	Method AddProcess()
	Method AddVariable()
	Method ProcessWSRocket()
	Method UpdStatus(cStatus)
	Method NextCode()

EndClass


Method New() Class TPoliticaCredito

	::cCodPro := ""
	::dData := dDataBase
	::cCliente := ""
	::cLoja := ""
	::cGrpVen := ""
	::cCnpj := ""
	::nLimCreSol := 0
	::nVlrObr := 0	
	::cOrigem := "1"
	::oVariavel := TVariavelCliente():New()
	::oRocket := TProcessoRocket():New()

Return()


Method Process() Class TPoliticaCredito

	If !::InProcess()
	
		Begin Transaction
			
			::AddProcess()

			// Somente a rotina de Update adiciona as variaves e a integracao com o Rocket
			
			//::AddVariable()
			
			//::ProcessWSRocket()
			
		End Transaction
	
	EndIf

Return()


Method UpdProcess() Class TPoliticaCredito
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ZM0_CODIGO, ZM0_DATINI, ZM0_DATINI, ZM0_CLIENT, ZM0_LOJA, ZM0_GRUPO, ZM0_CNPJ, ZM0_VLSOL, ZM0_VLOBRA, ZM0_ORIGEM "
	cSQL += " FROM "+ RetSQLName("ZM0")
	cSQL += " WHERE ZM0_FILIAL = "+ ValToSQL(xFilial("ZM0"))
	cSQL += " AND ZM0_STATUS IN ('1', '2') "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		::cCodPro := (cQry)->ZM0_CODIGO
		::dData := sToD((cQry)->ZM0_DATINI)
		::cCliente := (cQry)->ZM0_CLIENT
		::cLoja := (cQry)->ZM0_LOJA
		::cGrpVen := (cQry)->ZM0_GRUPO
		::cCnpj := (cQry)->ZM0_CNPJ
		::nLimCreSol := (cQry)->ZM0_VLSOL
		::nVlrObr := (cQry)->ZM0_VLOBRA
		::cOrigem := (cQry)->ZM0_ORIGEM
			
		Begin Transaction
			
			::oVariavel:cCodPro := ::cCodPro
			
			If ::oVariavel:Exist()
			
				::oRocket:cCodPro := ::cCodPro
				
				If ::oRocket:Load()
				
					::oRocket:oLst := ::oVariavel:Get()
						
					::oRocket:FlowStatus()
					
					If ::oRocket:cStatus $ "PD/PF"
					
						::oRocket:Response()
						
						::UpdStatus("3")
					
					ElseIf ::oRocket:cStatus == "ER"
					
						::UpdStatus("4")
						
					EndIf
				
				EndIf
				
			Else

				::AddVariable()
				
				::ProcessWSRocket()
						
			EndIf
			
		End Transaction
								
		(cQry)->(DbSkip())
								
	EndDo()

	(cQry)->(DbCloseArea())

Return()


Method InProcess() Class TPoliticaCredito
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(R_E_C_N_O_, 0) AS RECNO "
	cSQL += " FROM "+ RetSQLName("ZM0")
	cSQL += " WHERE ZM0_FILIAL = "+ ValToSQL(xFilial("ZM0"))
	cSQL += " AND ZM0_STATUS IN ('1', '2') "

	If !Empty(::cGrpVen)

		cSQL += " AND SUBSTRING(ZM0_CNPJ, 1, 8) IN "
		cSQL += " (
		cSQL += " 	SELECT SUBSTRING(A1_CGC, 1, 8) AS A1_CGC "
		cSQL += " 	FROM "+ RetFullName("SA1", "01")
		cSQL += " 	WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
		cSQL += " 	AND A1_GRPVEN = "+ ValToSQL(::cGrpVen)
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " 	GROUP BY SUBSTRING(A1_CGC, 1, 8) "
	
		cSQL += " 	UNION "

		cSQL += " 	SELECT SUBSTRING(A1_CGC, 1, 8) AS A1_CGC "
		cSQL += " 	FROM "+ RetFullName("SA1", "05")
		cSQL += " 	WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
		cSQL += " 	AND A1_GRPVEN = "+ ValToSQL(::cGrpVen)
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " 	GROUP BY SUBSTRING(A1_CGC, 1, 8) "

		cSQL += " 	UNION "

		cSQL += " 	SELECT SUBSTRING(A1_CGC, 1, 8) AS A1_CGC "
		cSQL += " 	FROM "+ RetFullName("SA1", "07")
		cSQL += " 	WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
		cSQL += " 	AND A1_GRPVEN = "+ ValToSQL(::cGrpVen)
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " 	GROUP BY SUBSTRING(A1_CGC, 1, 8) "
		cSQL += " ) "
		
	Else
		
		cSQL += " AND ZM0_CLIENT = "+ ValToSQL(::cCliente)
		cSQL += " AND ZM0_LOJA = "+ ValToSQL(::cLoja)
	
	EndIf
	
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->RECNO > 0

	(cQry)->(DbCloseArea())

Return(lRet)


Method AddProcess() Class TPoliticaCredito

	// Adiciona novo processo de solicitacao de credito
	::cCodPro := ::NextCode()
	
	RecLock("ZM0", .T.)

		ZM0->ZM0_FILIAL := xFilial("ZM0")
		ZM0->ZM0_CODIGO := ::cCodPro
		ZM0->ZM0_CLIENT := ::cCliente
		ZM0->ZM0_LOJA := ::cLoja
		ZM0->ZM0_GRUPO := ::cGrpVen
		ZM0->ZM0_CNPJ := ::cCnpj
		ZM0->ZM0_VLSOL := ::nLimCreSol
		ZM0->ZM0_VLOBRA := ::nVlrObr			
		ZM0->ZM0_DATINI := ::dData
		ZM0->ZM0_HORINI := Time()
		ZM0->ZM0_STATUS := "1"
		ZM0->ZM0_ORIGEM := ::cOrigem
	
	ZM0->(MsUnLock())
		
Return()


Method AddVariable() Class TPoliticaCredito

	// Adiciona variaves do cliente
	::oVariavel:cCodPro := ::cCodPro
	::oVariavel:dData := ::dData
	::oVariavel:cCliente := ::cCliente
	::oVariavel:cLoja := ::cLoja
	::oVariavel:cGrpVen := ::cGrpVen
	::oVariavel:cCnpj := ::cCnpj
	::oVariavel:nLimCreSol := ::nLimCreSol
	::oVariavel:nVlrObr := ::nVlrObr
	
	::oVariavel:Add()

Return()


Method ProcessWSRocket() Class TPoliticaCredito
Local nCount := 1
Local lLoop := .T.
	
	::oRocket:cCodPro := ::cCodPro
	
	::oRocket:cHash := ""
	
	::oRocket:cTicket := ""
	
	::oRocket:oLst := ::oVariavel:Get()
	
	If ::oRocket:oLst:GetCount() > 0
		
		::oRocket:Request()
		
		::UpdStatus("2")
			
		If !Empty(::oRocket:cHash) .And. !Empty(::oRocket:cTicket)
		
			// Consulta Status do processo 3x
			While nCount <= 3 .And. lLoop
			
				Sleep(500)
				
				::oRocket:FlowStatus()
				
				/*
					ER - Erro no Processamento, na TAG MENSAGEM constará a descrição do erro
					PR - Em Processamento
					PD/PF - Processo disponível / Processo finalizado
					NE - Ticke Não Existente
					URL - Se existir uma tarefa do Decision Console no fluxo (mesa de análise) ou um WebQuiz (Modulo adicional Rocket), será retornada uma URL (exceto se a tarefa do Decision Console estiver com o status de Ação Não Executada)
				*/
								
				If ::oRocket:cStatus $ "PD/PF"
				
					::oRocket:Response()
					
					::UpdStatus("3")
					
					lLoop := .F.
				
				ElseIf ::oRocket:cStatus == "ER"
					
					::UpdStatus("4")
					
					lLoop := .F.
							
				EndIf
					
				nCount++
				
			EndDo()
		
		EndIf
		
	EndIf	

Return()


Method UpdStatus(cStatus) Class TPoliticaCredito
	
	DbSelectArea("ZM0")
	DbSetOrder(1)
	If ZM0->(DbSeek(xFilial("ZM0") + ::cCodPro))
	
		RecLock("ZM0", .F.)
					
			ZM0->ZM0_STATUS := cStatus
		
			If cStatus == "3"
		
				ZM0->ZM0_DATFIM := ::dData
				ZM0->ZM0_HORFIN := Time()
				
			EndIf
		
		ZM0->(MsUnLock())
	
	EndIf
	
Return()


Method NextCode() Class TPoliticaCredito
Local cRet := ""
Local lLoop := .T.
Local cAuxCode := ""
Local cSQL := ""
Local cQry := GetNextAlias()
	
	While lLoop

		cAuxCode := GetSxEnum('ZM0', 'ZM0_CODIGO', 'POL_CRED')
		
		cSQL := " SELECT COUNT(ZM0_CODIGO) AS COUNT "
		cSQL += " FROM "+ RetSQLName("ZM0")
		cSQL += " WHERE ZM0_FILIAL = "+ ValToSQL(xFilial("ZM0"))
		cSQL += " AND ZM0_CODIGO = "+ ValToSQL(cAuxCode)
		cSQL += " AND D_E_L_E_T_ = '' "
	
		TcQuery cSQL New Alias (cQry)
	
		If (cQry)->COUNT == 0
		
			ConfirmSx8()
			
			cRet := cAuxCode
			
			lLoop := .F.
			
		EndIf 
	
		(cQry)->(DbCloseArea())
		
	EndDo

Return(cRet)