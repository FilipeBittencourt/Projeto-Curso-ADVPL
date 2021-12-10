#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRegraComunicacaoBancariaPagar
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras de comunicação bancaria a pagar
@type class
/*/

Class TAFRegraComunicacaoBancariaPagar From LongClassName

	Data cOpc // E=Envio; R=Retorno
	Data oLst // Lista de titulos a analisar
	Data cIDProc // Identificar do processo
	Data oLog // Objeto de Log

	Method New() Constructor
	Method Set()
	Method Get()
	Method GetRule(cGroup)
	Method GetRuleBorManu(oLst)
	Method IsMultiple(cGroup)
	Method ValidGroup(cGroup, nRecno)
	Method ValidRule(cRule, lMultiple)
	Method Validate()

EndClass


Method New() Class TAFRegraComunicacaoBancariaPagar

	::cOpc := "E"
	::oLst := Nil
	::cIDProc := ""
	::oLog := TAFLog():New()

Return()


Method Set() Class TAFRegraComunicacaoBancariaPagar
	Local nCount := 0
	Local aAreaSA2 := SA2->(GetArea())
	Local aAreaSF6 := SF6->(GetArea())

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_RCB"

	::oLog:Insert()

	For nCount := 1 To ::oLst:GetCount()

		If ::cOpc == "E"

			// Significa que foi gerado um bordero manual
			// Devera ser buscado uma regra equivalente
			If ! Empty(::oLst:GetItem(nCount):cNumBor) .And. Empty(::oLst:GetItem(nCount):cRCB)

				::oLst:GetItem(nCount):cGRCB := ::GetRuleBorManu(@::oLst:GetItem(nCount))

			EndIf

			If ::oLst:GetItem(nCount):lValid

				// Valida grupo de regras
				If ::ValidGroup(::oLst:GetItem(nCount):cGRCB, ::oLst:GetItem(nCount):nRecNo)

					::oLog:cIDProc := ::cIDProc
					::oLog:cOperac := "P"
					::oLog:cMetodo := "VG_RCB"
					::oLog:cTabela := RetSQLName("SE2")
					::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
					::oLog:cHrFin := Time()

					::oLog:Insert()

					// Regra multipla
					If ::IsMultiple(::oLst:GetItem(nCount):cGRCB)

						::oLst:GetItem(nCount):lMRCB := .T.

					Else

						::oLst:GetItem(nCount):cRCB := ::GetRule(::oLst:GetItem(nCount):cGRCB)

					EndIf

					// Valida regra
					If ::ValidRule(::oLst:GetItem(nCount):cRCB, ::oLst:GetItem(nCount):lMRCB)

						::oLog:cIDProc := ::cIDProc
						::oLog:cOperac := "P"
						::oLog:cMetodo := "VR_RCB"
						::oLog:cTabela := RetSQLName("SE2")
						::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
						::oLog:cHrFin := Time()

						::oLog:Insert()

						// Varificar regras por empresa e filial
						DBSelectArea("ZK1")
						DbSetOrder(1)
						If ZK1->(DbSeek(xFilial("ZK1") + ::oLst:GetItem(nCount):cRCB))

							::oLst:GetItem(nCount):cBanco := PADR(ZK1->ZK1_BANCO, TamSx3("EE_CODIGO")[1])
							::oLst:GetItem(nCount):cAgencia := PADR(ZK1->ZK1_AGENCI, TamSx3("EE_AGENCIA")[1])
							::oLst:GetItem(nCount):cConta := PADR(ZK1->ZK1_CONTA, TamSx3("EE_CONTA")[1])
							::oLst:GetItem(nCount):cSubCta := PADR(ZK1->ZK1_SUBCTA, TamSx3("EE_SUBCTA")[1])
							::oLst:GetItem(nCount):cTpCom := ZK1->ZK1_TPCOM
							::oLst:GetItem(nCount):cFormPg := ZK1->ZK1_FORMPG
							::oLst:GetItem(nCount):cOperPg := ZK1->ZK1_FORMPO
							::oLst:GetItem(nCount):cModelo := ZK1->ZK1_MODELO
							::oLst:GetItem(nCount):cTpPag := ZK1->ZK1_TPPAG
							::oLst:GetItem(nCount):nVlrTarifa := ZK1->ZK1_VLRTAR
							::oLst:GetItem(nCount):lDescTarif := ZK1->ZK1_DESCTF == "1"

							::oLst:GetItem(nCount):cArqcfg := ZK1->ZK1_ARQCFG
							::oLst:GetItem(nCount):cArqUser := ZK1->ZK1_ARQUSE
							::oLst:GetItem(nCount):cAmbiente := ZK1->ZK1_AMBIEN
							::oLst:GetItem(nCount):cLayout := ZK1->ZK1_LAYOUT

							DbSelectArea("SE2")
							SE2->(DbGoTo(::oLst:GetItem(nCount):nRecNo))

							// Caso o envio seja pelo ERP e não esteja prenchido os campos de config do CNAB, bloqueia.
							If ::oLst:GetItem(nCount):cAmbiente == "1" .And. ( Empty(::oLst:GetItem(nCount):cArqcfg) .Or. Empty(::oLst:GetItem(nCount):cArqUser) )

								::oLst:GetItem(nCount):lValid := .F.

								::oLog:cIDProc := ::cIDProc
								::oLog:cOperac := "P"
								::oLog:cMetodo := "CP_TIT_INC"
								::oLog:cTabela := RetSQLName("SE2")
								::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
								::oLog:cHrFin := Time()
								::oLog:cRetMen := "Campo 'Arq.Configur' ou 'Arq.Saida' não preenchido, revise o cadastro de regras."
								::oLog:cEnvWF := "S"

								::oLog:Insert()

							EndIf

							// Caso seja debito automatico ou regra sem integracao, nao processa
							If ::oLst:GetItem(nCount):cFormPg $ "3" .Or. ::oLst:GetItem(nCount):cTpCom $ "0"

								::oLst:GetItem(nCount):lValid := .F.

								RecLock("SE2", .F.)
								SE2->E2_YSITAPI := "4"
								SE2->(MsUnlock())

							EndIf

							// Se o titulo for boleto e nao tiver codigo de barras e ou linha digitavel preenchidos, envia workflow para o usuario
							If ::oLst:GetItem(nCount):cFormPg $ "1" .And. Empty(::oLst:GetItem(nCount):cCodBar) .And. Empty(::oLst:GetItem(nCount):cLinDig)

								::oLst:GetItem(nCount):lValid := .F.

								::oLog:cIDProc := ::cIDProc
								::oLog:cOperac := "P"
								::oLog:cMetodo := "CP_TIT_INC"
								::oLog:cTabela := RetSQLName("SE2")
								::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
								::oLog:cHrFin := Time()
								::oLog:cRetMen := "Código de barras e/ou linha digitável não preenchidos"
								::oLog:cEnvWF := "S"

								::oLog:Insert()

							EndIf

							// Se o titulo for deposito em conta e nao tiver a conta preenchida preenchida, envia workflow para o usuario
							If ::oLst:GetItem(nCount):cFormPg $ "2|3" .And. ( Empty(::oLst:GetItem(nCount):cBancoFor) .Or. Empty(::oLst:GetItem(nCount):cAgenciaFor) .Or. Empty(::oLst:GetItem(nCount):cContaFor) )

								::oLst:GetItem(nCount):lValid := .F.

								::oLog:cIDProc := ::cIDProc
								::oLog:cOperac := "P"
								::oLog:cMetodo := "CP_TIT_INC"
								::oLog:cTabela := RetSQLName("SE2")
								::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
								::oLog:cHrFin := Time()
								::oLog:cRetMen := "Conta do fornecedor não cadastrada"
								::oLog:cEnvWF := "S"

								::oLog:Insert()

							EndIf

							// Se o titulo for transferencia e o banco do fornecedor for diferente da regra, envia workflow para o usuario
							If ::oLst:GetItem(nCount):cOperPg $ "2" .And. !Empty(::oLst:GetItem(nCount):cBancoFor) .And. ::oLst:GetItem(nCount):cBancoFor <> ::oLst:GetItem(nCount):cBanco

								::oLst:GetItem(nCount):lValid := .F.

								::oLog:cIDProc := ::cIDProc
								::oLog:cOperac := "P"
								::oLog:cMetodo := "CP_TIT_INC"
								::oLog:cTabela := RetSQLName("SE2")
								::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
								::oLog:cHrFin := Time()
								::oLog:cRetMen := "Obrigatória para operações de transferencia"
								::oLog:cEnvWF := "S"

								::oLog:Insert()

							EndIf

							// Se o titulo for DOC/TED e o banco do fornecedor for igual da regra, envia workflow para o usuario
							If ::oLst:GetItem(nCount):cOperPg $ "7" .And. ::oLst:GetItem(nCount):cBancoFor == ::oLst:GetItem(nCount):cBanco

								::oLst:GetItem(nCount):lValid := .F.

								::oLog:cIDProc := ::cIDProc
								::oLog:cOperac := "P"
								::oLog:cMetodo := "CP_TIT_INC"
								::oLog:cTabela := RetSQLName("SE2")
								::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
								::oLog:cHrFin := Time()
								::oLog:cRetMen := "Obrigatória para operações DOC/TED"
								::oLog:cEnvWF := "S"

								::oLog:Insert()

							EndIf

							// Se for GNR-e e o codigo de barras do SE2 for diferente do SF6
							If ::oLst:GetItem(nCount):cOperPg $ "5"

								DBSelectArea("SA2")
								SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_

								If SA2->(DBSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))

									DBSelectArea("SF6")
									SF6->(DBSetOrder(1)) // F6_FILIAL, F6_EST, F6_NUMERO, R_E_C_N_O_, D_E_L_E_T_

									If SF6->(DBSeek(xFilial("SF6") + SA2->A2_EST + SE2->E2_PREFIXO + SE2->E2_NUM))

										If SF6->F6_EST $ GetNewPar("MV_UFGNRE", "") // Feito pela rotina FISA095

											// AJUSTES NA VALIDAÇÃO DO CODIGO DE BARRAS ,
											// REMOVENDO COMPARAÇÕES FEITAS PELA VERSÃO ANTERIOR(1.0  da GNRE) - 34256 | GNRE/DIFAL com erros
											If ( !Empty(SE2->E2_CODBAR) .And. AllTrim(SF6->F6_CDBARRA) <> AllTrim(SE2->E2_CODBAR) ) .Or.;
													( Empty(SE2->E2_LINDIG) .And. Empty(SE2->E2_CODBAR) ) .Or.;
													( Replicate("0", 10) $ SubStr(SE2->E2_CODBAR, 1, 10) ) .Or.;
													( Replicate("0", 10) $ SubStr(SE2->E2_LINDIG, 1, 10) )

												::oLst:GetItem(nCount):lValid := .F.

												::oLog:cIDProc := ::cIDProc
												::oLog:cOperac := "P"
												::oLog:cMetodo := "CP_TIT_INC"
												::oLog:cTabela := RetSQLName("SE2")
												::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
												::oLog:cHrFin := Time()
												::oLog:cRetMen := "Código de barras não preenchido ou zerado ou diferente da guia (SF6/SE2)"
												::oLog:cEnvWF := "S"

												::oLog:Insert()

											EndIf

										Else // Feito manual

											If ( Empty(SE2->E2_CODBAR) .Or. Replicate("0", 10) $ SubStr(SE2->E2_CODBAR, 1, 10) ) .And.;
													( Empty(SE2->E2_LINDIG) .Or. Replicate("0", 10) $ SubStr(SE2->E2_LINDIG, 1, 10) ) .And.;
													( Empty(SE2->E2_YLINDIG) .Or. Replicate("0", 10) $ SubStr(SE2->E2_YLINDIG, 1, 10) )

												::oLst:GetItem(nCount):lValid := .F.

												::oLog:cIDProc := ::cIDProc
												::oLog:cOperac := "P"
												::oLog:cMetodo := "CP_TIT_INC"
												::oLog:cTabela := RetSQLName("SE2")
												::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
												::oLog:cHrFin := Time()
												::oLog:cRetMen := "Código de barras não preenchido"
												::oLog:cEnvWF := "S"

												::oLog:Insert()

											EndIf

										EndIf

									EndIf

								EndIf

							EndIf

							// Caso não seja debito automatico e não seja regra sem integracao, faz validação
							If ::oLst:GetItem(nCount):cFormPg <> "3" .And. ::oLst:GetItem(nCount):cTpCom <> "0"

								DBSelectArea("SA6")
								SA6->(DbSetOrder(1)) // A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, R_E_C_N_O_, D_E_L_E_T_

								If SA6->( dbSeek(xFilial("SA6") + ::oLst:GetItem(nCount):cBanco + ::oLst:GetItem(nCount):cAgencia + ::oLst:GetItem(nCount):cConta) )

									DBSelectArea("SEE")
									SEE->(DbSetOrder(1)) // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA, R_E_C_N_O_, D_E_L_E_T_

									If SEE->( dbSeek(xFilial("SEE") + ::oLst:GetItem(nCount):cBanco + ::oLst:GetItem(nCount):cAgencia + ::oLst:GetItem(nCount):cConta + ::oLst:GetItem(nCount):cSubCta) )

										If !Empty(SEE->EE_FAXFIM) .and. !Empty(SEE->EE_FAXATU) .and. Val(SEE->EE_FAXFIM)-Val(SEE->EE_FAXATU) < 100

											::oLst:GetItem(nCount):lValid := .F.

											::oLog:cIDProc := ::cIDProc
											::oLog:cOperac := "P"
											::oLog:cMetodo := "CP_TIT_INC"
											::oLog:cTabela := RetSQLName("SE2")
											::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
											::oLog:cHrFin := Time()
											::oLog:cRetMen := "O campo 'Faixa Fim' não pode ser menor que o campo 'Faixa Atual' no cadastro de Parametros de bancos (FINA130)."
											::oLog:cEnvWF := "S"

											::oLog:Insert()

										Endif

									Else

										::oLst:GetItem(nCount):lValid := .F.

										::oLog:cIDProc := ::cIDProc
										::oLog:cOperac := "P"
										::oLog:cMetodo := "CP_TIT_INC"
										::oLog:cTabela := RetSQLName("SE2")
										::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
										::oLog:cHrFin := Time()
										::oLog:cRetMen := "Conta [" + ::oLst:GetItem(nCount):cBanco + ::oLst:GetItem(nCount):cAgencia + ::oLst:GetItem(nCount):cConta + ::oLst:GetItem(nCount):cSubCta + "] não encontrada no cadastro de Parametros de bancos (FINA130)."
										::oLog:cEnvWF := "S"

										::oLog:Insert()

									EndIf

								Else

									::oLst:GetItem(nCount):lValid := .F.

									::oLog:cIDProc := ::cIDProc
									::oLog:cOperac := "P"
									::oLog:cMetodo := "CP_TIT_INC"
									::oLog:cTabela := RetSQLName("SE2")
									::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
									::oLog:cHrFin := Time()
									::oLog:cRetMen := "Conta bancaria [" + ::oLst:GetItem(nCount):cBanco + ::oLst:GetItem(nCount):cAgencia + ::oLst:GetItem(nCount):cConta + "] informada não encontrada no cadastro de bancos (MATA070)."
									::oLog:cEnvWF := "S"

									::oLog:Insert()

								EndIf

							EndIf

							::oLog:cIDProc := ::cIDProc
							::oLog:cOperac := "P"
							::oLog:cMetodo := "S_RCB"
							::oLog:cTabela := RetSQLName("SE2")
							::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
							::oLog:cHrFin := Time()

							::oLog:Insert()

						EndIf

					Else

						::oLst:GetItem(nCount):lValid := .F.

						::oLog:cIDProc := ::cIDProc
						::oLog:cOperac := "P"
						::oLog:cMetodo := "CP_NVR_RCB"
						::oLog:cTabela := RetSQLName("SE2")
						::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
						::oLog:cHrFin := Time()
						::oLog:cRetMen := If(::oLst:GetItem(nCount):lMRCB, "Grupo: " + ::oLst:GetItem(nCount):cGRCB + " Multiplo", "")
						::oLog:cEnvWF := "S"

						::oLog:Insert()

					EndIf

				Else

					::oLst:GetItem(nCount):lValid := .F.

				EndIf

			EndIf

		ElseIf ::cOpc == "R"

		EndIf

	Next

	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "F_RCB"
	::oLog:cHrFin := Time()

	::oLog:Insert()

	RestArea(aAreaSA2)
	RestArea(aAreaSF6)

Return()


Method Get() Class TAFRegraComunicacaoBancariaPagar
	Local cSQL := ""
	Local cQry := GetNextAlias()

	::oLst := ArrayList():New()

	cSQL := " SELECT ZK1_BANCO, ZK1_AGENCI, ZK1_CONTA, ZK1_SUBCTA "
	cSQL += " FROM " + RetSQLName("ZK1")
	cSQL += " WHERE ZK1_FILIAL = " + ValToSQL(xFilial("ZK1"))
	cSQL += " AND ZK1_CODEMP = " + ValToSQL(cEmpAnt)
	cSQL += " AND ZK1_FORMPG = '2' " // Mudat filtro para o campo ZK1_OPERAC = '1' - Fornecedor
	cSQL += " AND ZK1_BANCO <> '' "
	cSQL += " AND ZK1_AGENCI <> '' "
	cSQL += " AND ZK1_CONTA <> '' "
	cSQL += " AND ZK1_SUBCTA <> '' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY ZK1_BANCO, ZK1_AGENCI, ZK1_CONTA, ZK1_SUBCTA "
	cSQL += " ORDER BY ZK1_BANCO, ZK1_AGENCI, ZK1_CONTA, ZK1_SUBCTA "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		oObj := TIAFBanco():New()

		oObj:cBanco := (cQry)->ZK1_BANCO
		oObj:cAgencia := (cQry)->ZK1_AGENCI
		oObj:cConta := (cQry)->ZK1_CONTA
		oObj:cSubCta := (cQry)->ZK1_SUBCTA

		::oLst:Add(oObj)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(::oLst)


Method GetRuleBorManu(oLst) Class TAFRegraComunicacaoBancariaPagar
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local aGrupo := {}
	Local cGrupo := ""

	DbSelectArea("SE2")
	SE2->(DbGoTo(oLst:nRecNo))

	DBSelectArea("SEA")
	SEA->(DBSetOrder(2))

	If SEA->(DBSeek(xFilial("SEA") + SE2->E2_NUMBOR + "P" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO))

		cSQL := " SELECT DISTINCT TOP 1 ZK0_CODGRU "
		cSQL += " FROM " + RetSQLName("ZK1") + " ZK1 "
		cSQL += " JOIN " + RetSQLName("ZK0") + " ZK0 ON ( "
		cSQL += " 											ZK0_FILIAL = " + ValToSQL(xFilial("ZK0")) + " AND "
		cSQL += "											ZK0_CODREG = ZK1_CODREG AND "
		cSQL += "											ZK0.D_E_L_E_T_ = '' "
		cSQL += "	 									 )
		cSQL += " WHERE ZK1_FILIAL = " + ValToSQL(xFilial("ZK1"))
		cSQL += " AND ( "
		cSQL += " 			( ZK1.ZK1_CODEMP = '' AND ZK1.ZK1_CODFIL = '' ) OR "
		cSQL += "			( ZK1.ZK1_CODEMP = '" + cEmpAnt + "' AND ZK1.ZK1_CODFIL = '' ) OR "
		cSQL += "			( ZK1.ZK1_CODEMP = '" + cEmpAnt + "' AND ZK1.ZK1_CODFIL = '" + cFilAnt + "' ) "
		cSQL += "	   ) "
		cSQL += " AND ZK1_OPERAC = '1' "
		cSQL += " AND ZK1_MODELO = " + ValToSQL(SEA->EA_MODELO)
		cSQL += " AND ZK1_TPPAG  = " + ValToSQL(SEA->EA_TIPOPAG)
		cSQL += " AND ZK1_BANCO  = " + ValToSQL(SEA->EA_PORTADO)
		cSQL += " AND ZK1_AGENCI = " + ValToSQL(SEA->EA_AGEDEP)
		cSQL += " AND ZK1_CONTA  = " + ValToSQL(SEA->EA_NUMCON)

		// Siginifica que foi feito algum desconto
		// portanto busca uma regra com desconto
		//If SE2->E2_SALDO < SE2->E2_VALOR .And. Empty(SE2->E2_CODBAR)

		//cSQL += " AND ZK1_VLRTAR > 0 "

		//Else

		cSQL += " AND ZK1_VLRTAR = 0 "

		//EndIf

		//cSQL += " AND ZK1_SUBCTA <> '' "
		cSQL += " AND ZK1.D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		While !(cQry)->(Eof())

			aAdd(aGrupo, (cQry)->ZK0_CODGRU)

			(cQry)->(DbSkip())

		EndDo

		(cQry)->(DbCloseArea())

	EndIf

	If Len(aGrupo) > 0

		cGrupo := aGrupo[1]

	Else

		oLst:lValid := .F.

		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_TIT_INC"
		::oLog:cTabela := RetSQLName("SE2")
		::oLog:nIDTab := oLst:nRecNo
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Bordero manual não encontrado regra equivalente."
		::oLog:cEnvWF := "S"

		::oLog:Insert()

	EndIf

Return(cGrupo)


Method GetRule(cGroup) Class TAFRegraComunicacaoBancariaPagar
	Local cRet := ""

	DBSelectArea("ZK0")
	ZK0->(DbSetOrder(1))

	DBSelectArea("ZK1")
	ZK1->(DbSetOrder(1))

	If ZK0->(DbSeek(xFilial("ZK0") + cGroup))

		While ZK0->(! EOF()) .And. ZK0->(ZK0_FILIAL + ZK0_CODGRU) == xFilial("ZK0") + cGroup

			If ZK1->(DbSeek(xFilial("ZK1") + ZK0->ZK0_CODREG))

				If (Empty(ZK1->ZK1_CODEMP) .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
						(ZK1->ZK1_CODEMP == cEmpAnt .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
						(ZK1->ZK1_CODEMP == cEmpAnt .And. ZK1->ZK1_CODFIL == cFilAnt)

					cRet := ZK0->ZK0_CODREG

				EndIf

			EndIf

			ZK0->(DBSkip())

		EndDo

	EndIf

Return(cRet)


Method IsMultiple(cGroup) Class TAFRegraComunicacaoBancariaPagar
	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(ZK0_CODGRU) AS COUNT "
	cSQL += " FROM " + RetSQLName("ZK0") + " ZK0 "
	cSQL += " WHERE ZK0_FILIAL = "+ ValToSQL(xFilial("ZK0"))
	cSQL += " AND ZK0_CODGRU = "+ ValToSQL(cGroup)
	cSQL += " AND EXISTS "
	cSQL += " ( "
	cSQL += "		SELECT * "
	cSQL += "		FROM " + RetSQLName("ZK1") + " ZK1 "
	cSQL += "		WHERE ZK1_FILIAL = " + ValToSQL(xFilial("ZK1"))
	cSQL += "		AND ZK1_CODREG = ZK0_CODREG "
	cSQL += "		AND ((ZK1_CODEMP = '' AND ZK1_CODFIL = '') "
	cSQL += "		OR (ZK1_CODEMP = " + ValToSQL(cEmpAnt) + " AND ZK1_CODFIL = '') "
	cSQL += "		OR (ZK1_CODEMP = " + ValToSQL(cEmpAnt) + " AND ZK1_CODFIL = " + ValToSQL(cFilAnt) + "))"
	cSQL += "		AND ZK1.D_E_L_E_T_ = '' "
	cSQL += "	) "
	cSQL += " AND ZK0.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT > 1

	(cQry)->(DbCloseArea())

Return(lRet)


Method ValidGroup(cGroup, nRecno) Class TAFRegraComunicacaoBancariaPagar
	Local lRet := .F.
	Local oLog := TAFLog():New()

	Default cGroup := ""
	Default nRecno := 0

	If !Empty(cGroup)

		// Verifica se grupo de regra existe
		DBSelectArea("ZK0")
		ZK0->(DbSetOrder(1))

		DBSelectArea("ZK1")
		ZK1->(DbSetOrder(1))

		If ZK0->(DbSeek(xFilial("ZK0") + cGroup))

			While ZK0->(! EOF()) .And. ZK0->(ZK0_FILIAL + ZK0_CODGRU) == xFilial("ZK0") + cGroup

				If ZK1->(DbSeek(xFilial("ZK1") + ZK0->ZK0_CODREG))

					If (Empty(ZK1->ZK1_CODEMP) .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
							(ZK1->ZK1_CODEMP == cEmpAnt .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
							(ZK1->ZK1_CODEMP == cEmpAnt .And. ZK1->ZK1_CODFIL == cFilAnt)

						lRet := .T.

					EndIf

				EndIf

				ZK0->(DBSkip())

			EndDo

		Else

			// Regra inexistente, envia workflow informativo
			lRet := .F.

			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_NVG_RCB"
			::oLog:cTabela := RetSQLName("SE2")
			::oLog:nIDTab := nRecno
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Grupo " + cGroup + " inexistente"
			::oLog:cEnvWF := "S"

			::oLog:Insert()

		EndIf

		// Cliente/Fornecedor sem grupo de regra definido, envia workflow informativo
	Else

		lRet := .F.

		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_NVG_RCB"
		::oLog:cTabela := RetSQLName("SE2")
		::oLog:nIDTab := nRecno
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Grupo não preenchido no cadastro do fornecedor"
		::oLog:cEnvWF := "S"

		::oLog:Insert()

	EndIf

Return(lRet)


Method ValidRule(cRule, lMultiple) Class TAFRegraComunicacaoBancariaPagar
	Local lRet := .T.

	// Titulo sem regra definida, envia workflow informativo
	If lMultiple

		lRet := .F.

		// Cliente/Fornecedor sem regra definida, envia workflow informativo
	ElseIf Empty(cRule)

		lRet := .F.

	Else

		// Verifica se grupo de regra existe
		DBSelectArea("ZK1")
		DbSetOrder(1)
		If !ZK1->(DbSeek(xFilial("ZK1") + cRule))

			// Regra inexistente, envia workflow informativo
			lRet := .F.

		EndIf

	EndIf

Return(lRet)


Method Validate() Class TAFRegraComunicacaoBancariaPagar
	Local lRet := .F.
	Local nCount := 1

	lRet := aScan(::oLst:ToArray(), {|x| !Empty(x:cBanco) }) > 0

Return(lRet)