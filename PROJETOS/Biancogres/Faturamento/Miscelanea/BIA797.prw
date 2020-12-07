#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} BIA797
@author Marcos Alberto Soprani
@since 18/04/2013
@version 1.0
@description Rotina para Integração do Guardian com Protheus
@type function
/*/

User Function BIA797()
	Local aArea := GetArea()

	RPCSetType(3)
	WfPrepEnv("01", "01")

	U_BIA797A()

	RpcClearEnv()

	RestArea(aArea)

Return()


// Integração do Guardian com Protheus
User Function BIA797A()
	Local cArqSem := ""
	Local nHandle := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nQtdSeq := 0
	Local cTicket := ""	
	Local Enter := CHR(13)+CHR(10)

	If cEmpAnt == "01"

		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Integracao_Guardian_Protheus -- Empresa: "+ cEmpAnt)

		// Cria arquivo semafaro para controle de acessos simultâneos
		cArqSem := GetSrvProfString("Startpath","") + "BIA797_" + cEmpAnt + ".txt"

		// Cria arquivo semafaro para controle de acessos simultâneos
		If File(cArqSem)

			Aviso('Integracao Guardian x Protheus', 'Esta rotina já está em uso em outra estação de trabalho!!! Necessário aguardar.', {'Ok'})

			Return()

		Else

			nHandle := fCreate(cArqSem, FC_NORMAL)

			FCLOSE(nHandle)

		EndIf

		cSQL := " SELECT TICKET.TCK_CODIGO PESAGE, TICKET.TCK_PLACA_CARRETA PCAVAL, '' OPERIN, " + Enter
		cSQL += " Convert(Char(10), Convert(DateTime, OPER_ENT.OTK_DATA), 112) DATAIN, " + Enter
		cSQL += " Convert(Char(05), Convert(DateTime, OPER_ENT.OTK_DATA), 108) HORAIN, " + Enter
		cSQL += " OPER_ENT.OTK_PESO PESOIN, '' OPERSA, " + Enter
		cSQL += " Convert(Char(10),convert(datetime, OPER_SAI.OTK_DATA),112) DATASA, " + Enter
		cSQL += " Convert(Char(05),convert(datetime, OPER_SAI.OTK_DATA),108) HORASA, " + Enter
		cSQL += " OPER_SAI.OTK_PESO PESOSA, OPER_SAI.OTK_PESO_LIQUIDO PESLIQ, " + Enter
		cSQL += " CASE WHEN OPER_ENT.OTK_PESO > OPER_SAI.OTK_PESO THEN 1 ELSE 2 END MERCAD " + Enter
		cSQL += " FROM ZEUS.GUARDIAN.dbo.tbTicket TICKET " + Enter
		cSQL += " LEFT JOIN ZEUS.GUARDIAN.dbo.tbOperacoesTicket OPER_ENT " + Enter 
		cSQL += " ON OPER_ENT.TCK_SEQUENCIAL = TICKET.TCK_SEQUENCIAL " + Enter
		cSQL += " AND OPER_ENT.OTK_SEQUENCIAL = " + Enter 
		cSQL += " ( " + Enter
		cSQL += " 	SELECT MIN(OTK_SEQUENCIAL) " + Enter
		cSQL += " 	FROM ZEUS.GUARDIAN.dbo.tbOperacoesTicket CHQ " + Enter
		cSQL += " 	WHERE CHQ.TCK_SEQUENCIAL = TICKET.TCK_SEQUENCIAL " + Enter
		cSQL += " 	AND CHQ.OTK_ESTADO <> 0 " + Enter
		cSQL += " 	AND NOT CHQ.PRF_SEQUENCIAL IS NULL " + Enter
		cSQL += " ) " + Enter
		cSQL += " LEFT JOIN ZEUS.GUARDIAN.dbo.tbOperacoesTicket OPER_SAI " + Enter 
		cSQL += " ON OPER_SAI.TCK_SEQUENCIAL = TICKET.TCK_SEQUENCIAL " + Enter
		cSQL += " AND OPER_SAI.OTK_SEQUENCIAL = " + Enter 
		cSQL += " ( " + Enter
		cSQL += " 	SELECT MAX(OTK_SEQUENCIAL) " + Enter
		cSQL += " 	FROM ZEUS.GUARDIAN.dbo.tbOperacoesTicket CHQ " + Enter
		cSQL += " 	WHERE CHQ.TCK_SEQUENCIAL = TICKET.TCK_SEQUENCIAL " + Enter
		cSQL += " 	AND CHQ.OTK_ESTADO <> 0 " + Enter
		cSQL += " 	AND NOT CHQ.PRF_SEQUENCIAL IS NULL " + Enter
		cSQL += " ) " + Enter
		cSQL += " WHERE TICKET.TCK_CODIGO COLLATE Latin1_General_BIN NOT IN " + Enter
		cSQL += " ( " + Enter
		cSQL += " 	SELECT Z11_GUARDI " + Enter
		cSQL += " 	FROM " + RetSqlName("Z11") + Enter
		cSQL += " 	WHERE Z11_FILIAL = "+ ValToSQL(xFilial("Z11")) + Enter
		cSQL += " 	AND Z11_GUARDI <> '' " + Enter
		cSQL += " 	AND D_E_L_E_T_ = '' " + Enter
		cSQL += " ) " + Enter
		cSQL += " AND " + Enter
		cSQL += " 	( " + Enter
		cSQL += " 		SELECT COUNT(*) " + Enter 
		cSQL += " 		FROM ZEUS.GUARDIAN.dbo.tbOperacoesTicket CHQ " + Enter 
		cSQL += " 		WHERE CHQ.TCK_SEQUENCIAL = TICKET.TCK_SEQUENCIAL " + Enter 
		cSQL += " 		AND CHQ.OTK_ESTADO <> 0 " + Enter 
		cSQL += " 		AND NOT CHQ.PRF_SEQUENCIAL IS NULL " + Enter
		cSQL += " 	) >= 2 " + Enter
		cSQL += " AND OPER_ENT.OTK_ESTADO <> 0 " + Enter
		cSQL += " ORDER BY PESAGE " + Enter

		TcQuery cSQL New Alias (cQry)

		While (cQry)->(!Eof())

			nQtdSeq := 0

			cTicket := ""

			// Verifica se existe uma placa em aberto no sistema para não criar uma nova ocorrência antes de fechar a ocorrência existente
			If fExiste(AllTrim((cQry)->PCAVAL), (cQry)->MERCAD, @cTicket)

				DbSelectArea("Z11")
				DbSetOrder(1)			
				If Z11->(DbSeek(xFilial("Z11") + cTicket))

					Reclock("Z11", .F.)

					Z11->Z11_GUARDI := (cQry)->PESAGE
					Z11->Z11_MERCAD := (cQry)->MERCAD
					Z11->Z11_PCAVAL := Substr((cQry)->PCAVAL, 1, 3) + Substr((cQry)->PCAVAL, 5, 4)
					Z11->Z11_DATAIN := sToD((cQry)->DATAIN)
					Z11->Z11_HORAIN := (cQry)->HORAIN
					Z11->Z11_PESOIN := (cQry)->PESOIN
					Z11->Z11_DATASA := sToD((cQry)->DATASA)
					Z11->Z11_HORASA := (cQry)->HORASA
					Z11->Z11_PESOSA := (cQry)->PESOSA
					Z11->Z11_OPERSA := __cUserID
					Z11->Z11_PESLIQ := (cQry)->PESLIQ
					

					If (cQry)->MERCAD == 1

						Z11->Z11_SEQB := ""

					Else

						Z11->Z11_SEQB := Alltrim(Str(If(nQtdSeq == 0, 1, nQtdSeq + 1)))

					EndIf

					Z11->(MsUnLock())

				EndIf

				// Caso nao exista ticket em aberto
			Else

				nQtdSeq := fGetQtdSeq(AllTrim((cQry)->PCAVAL), (cQry)->DATAIN)

				cTicket := GetSx8Num("Z11", "Z11_PESAGE")

				Reclock("Z11", .T.)

				Z11->Z11_FILIAL := xFilial("Z11")
				Z11->Z11_GUARDI := (cQry)->PESAGE
				Z11->Z11_PESAGE := cTicket
				Z11->Z11_MERCAD := (cQry)->MERCAD
				Z11->Z11_PCAVAL := Substr((cQry)->PCAVAL, 1, 3) + Substr((cQry)->PCAVAL, 5, 4)
				Z11->Z11_DATAIN := sToD((cQry)->DATAIN)
				Z11->Z11_HORAIN := (cQry)->HORAIN
				Z11->Z11_PESOIN := (cQry)->PESOIN
				Z11->Z11_DATASA := sToD((cQry)->DATASA)
				Z11->Z11_HORASA := (cQry)->HORASA
				Z11->Z11_PESOSA := (cQry)->PESOSA
				Z11->Z11_PESLIQ := (cQry)->PESLIQ
				Z11->Z11_DATACA := dDataBase
				
				If (cQry)->MERCAD == 1

					Z11->Z11_SEQB := ""

				Else

					Z11->Z11_SEQB := Alltrim(Str(If(nQtdSeq == 0, 1, nQtdSeq + 1)))

				EndIf			

				Z11->(MsUnLock())

				Z11->(ConfirmSX8())

			EndIf

			ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Integracao_Guardian_Protheus -- Empresa: "+ cEmpAnt +" -- Ticket Guardian: "+ AllTrim((cQry)->PESAGE) +" -- Ticket Protheus: "+ AllTrim(cTicket))		

			(cQry)->(DbSkip())	

		EndDo()
		(cQry)->(DbCloseArea())
		// Libera arquivo semafaro para controle de acessos simultâneos
		If File(cArqSem)

			fErase(cArqSem)

		EndIf

		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- Integracao_Guardian_Protheus -- Empresa: "+ cEmpAnt)

	EndIf

Return()


Static Function fExiste(cPlaca, cMercad, cTicket)
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	If At("-", cPlaca) > 0

		cPlaca1 := cPlaca
		cPlaca2 := Substr(cPlaca, 1, 3) + Substr(cPlaca, 5, 4)

	Else

		cPlaca1 := cPlaca
		cPlaca2 := Substr(cPlaca, 1, 3) + "-" + Substr(cPlaca, 4, 4)

	EndIf

	cSQL := " SELECT COUNT(Z11_PESAGE) AS COUNT, Z11_PESAGE, Z11_MOTORI "
	cSQL += " FROM "+ RetSqlName("Z11")
	cSQL += " WHERE Z11_FILIAL = "+ ValToSQL(xFilial("Z11"))
	cSQL += " AND Z11_MERCAD = '2' "
	cSQL += " AND NOT(Z11_PESOIN <> 0 AND Z11_PESOSA <> 0) "
	cSQL += " AND (Z11_PCAVAL = "+ ValToSQL(cPlaca1) +" OR Z11_PCAVAL = "+ ValToSQL(cPlaca2) +") "
	cSQL += " AND D_E_L_E_T_ = ''
	cSQL += " GROUP BY Z11_PESAGE, Z11_MOTORI "

	TcQuery cSQL New Alias (cQry)

	If (cQry)->COUNT >= 1 .And. cMercad <> 1

		lRet := .T.

		cTicket := (cQry)->Z11_PESAGE

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)


Static Function fGetQtdSeq(cPlaca, cDataIn)
	Local nRet := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()

	If At("-", cPlaca) > 0

		cPlaca1 := cPlaca
		cPlaca2 := Substr(cPlaca, 1, 3) + Substr(cPlaca, 5, 4)

	Else

		cPlaca1 := cPlaca
		cPlaca2 := Substr(cPlaca, 1, 3) + "-" + Substr(cPlaca, 4, 4)

	EndIf

	cSQL := " SELECT ISNULL(COUNT(Z11_PCAVAL),0) AS QUANT "
	cSQL += " FROM "+ RetSqlName("Z11")
	cSQL += " WHERE Z11_FILIAL = "+ ValToSQL(xFilial("Z11"))
	cSQL += " AND (Z11_PCAVAL = "+ ValToSQL(cPlaca1) +" OR Z11_PCAVAL = "+ ValToSQL(cPlaca2) +") "	
	cSQL += " AND Z11_DATAIN = "+ ValToSQL(cDataIn)
	cSQL += " AND Z11_MERCAD = '2' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->QUANT

	(cQry)->(DbCloseArea())

Return(nRet)