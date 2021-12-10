#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} NOME_SOL
@author Tiago Rossini Coradini
@since 28/03/2016
@version 2.0
@description Exibe o nome do solicitante do Pedido de Compra,
@description Atualização do fonte, retirada a consulta via RPC, tratamento efetuando via SQL 
@type function
/*/

User Function NOME_SOL()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cQrySRA := GetNextAlias()
Local cNomSol := ""
Local vgCrLf := Chr(13) + Chr(10)
Local cMat := ""
Local cSolEmp := ""
Local cNumSC := ""
Local cItemSC := ""

	If FunName() == "MATA150"

		cSQL := " SELECT DISTINCT C1_YMAT, C1_YSOLEMP, C1_NUM, C1_ITEM "
		cSQL += " FROM " + RetSQLName("SC1")
		cSQL += " WHERE C1_FILIAL = "+ ValToSQL(xFilial("SC1"))
		cSQL += " AND C1_NUM IN "
		cSQL += " ( "
		cSQL += " 	SELECT DISTINCT C8_NUMSC "
		cSQL += " 	FROM " + RetSQLName("SC8")
		cSQL += " 	WHERE C8_FILIAL =  "+ ValToSQL(xFilial("SC8"))
		cSQL += " 	AND C8_NUM = " + ValToSQL(cA150Num)
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " ) "				
		cSQL += " AND D_E_L_E_T_ = '' "
	
	Else
		
		cSQL := " SELECT DISTINCT C7_YMAT, C7_YSOLEMP, C7_NUMSC, C7_ITEMSC "
		cSQL += " FROM " + RetSQLName("SC7")
		cSQL += " WHERE C7_FILIAL = "+ ValToSQL(xFilial("SC7"))
		cSQL += " AND C7_NUM = "+ ValToSQL(cA120Num)
		cSQL += " AND D_E_L_E_T_ = '' "
		
	EndIf

	TcQuery cSQL New Alias (cQry)
		
	While !(cQry)->(Eof())	
	
		If FunName() == "MATA150"
			
			cMat := (cQry)->C1_YMAT
			cSolEmp := (cQry)->C1_YSOLEMP
			cNumSC := (cQry)->C1_NUM
			cItemSC := (cQry)->C1_ITEM
			
		Else

			cMat := (cQry)->C7_YMAT
			cSolEmp := (cQry)->C7_YSOLEMP
			cNumSC := (cQry)->C7_NUMSC
			cItemSC := (cQry)->C7_ITEMSC
		
		EndIf
		

		If !Empty(cMat)

			If !Empty(cSolEmp) //.And. cSolEmp <> cEmpAnt Ticket 34671 - Rotina MATA094 não está aparecendo o nome do solicitante.

				cSQL := " SELECT RA_NOME "
				cSQL += " FROM "+ RetFullName("SRA", cSolEmp)
				cSQL += " WHERE RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
				cSQL += " AND RA_MAT = "+ ValToSQL(cMat)
				cSQL += " AND D_E_L_E_T_ = '' "

				TcQuery cSQL New Alias (cQrySRA)

				If !(cQrySRA)->(Eof()) 
				
					If !AllTrim(SRA->RA_NOME) $ cNomSol
					
						cNomSol += AllTrim((cQrySRA)->RA_NOME) + vgCrLf
						
					EndIf

				EndIf

				(cQrySRA)->(DbCloseArea())
				
				if Empty(cNomSol)
					cSQL := " SELECT RA_NOME "
					cSQL += " FROM "+ RetFullName("SRA", cSolEmp)
					cSQL += " WHERE RA_FILIAL +
					cSQL += " RA_MAT = "+ ValToSQL(cMat)
					cSQL += " AND D_E_L_E_T_ = '' "

					TcQuery cSQL New Alias (cQrySRA)
						If !(cQrySRA)->(Eof()) 
				
							If !AllTrim(SRA->RA_NOME) $ cNomSol
					
								cNomSol += AllTrim((cQrySRA)->RA_NOME) + vgCrLf
						
							EndIf

						EndIf
					(cQrySRA)->(DbCloseArea())
				ENDIF
			Else

				DbSelectArea("SRA")
				DbSetOrder(1)
				If SRA->(DbSeek(xFilial("SRA") + cMat))
					
					If !AllTrim(SRA->RA_NOME) $ cNomSol 
					
						cNomSol += AllTrim(SRA->RA_NOME) + vgCrLf
					
					EndIf

				EndIf			

			EndIf

		Else

			DbSelectArea("SC1")
			DbSetOrder(1)
			If SC1->(DbSeek(xFilial("SC1")+ cNumSC + cItemSC))

				If !AllTrim(SC1->C1_SOLICIT) $ cNomSol
					
					cNomSol += AllTrim(SC1->C1_SOLICIT) + vgCrLf
					
				EndI

			EndIf

		EndIf

		(cQry)->(dbSkip())

	EndDo()

	(cQry)->(DbCloseArea())	

	MsgAlert("Nome do Solicitante: " + vgCrLf + vgCrLf + cNomSol)
	
	If !FunName() == "MATA150"
		MsgAlert("Observação: " + vgCrLf + vgCrLf + Space(20) + AllTrim(SC7->C7_YOBS))
	EndIf	

Return()
