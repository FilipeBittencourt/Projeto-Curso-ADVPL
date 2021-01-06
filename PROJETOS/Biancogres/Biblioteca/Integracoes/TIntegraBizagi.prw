#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFAbstractClass
@author Rodrigo Ribeiro Agostini
@since 10/06/2019
@project Portaria Fiscal
@version 1.0
@description Classe base para integração entre Protheus x BIZAGI
@type class
/*/
Class TIntegraBizagi From LongClassName

	Method New() Constructor
	Method ConfNFE(cChaveF1,cEntrega,cChvNF)
	Method AprvNFS(cChaveF1,cEntrega,cChvNF)  
	Method XmlConfCegas(cEntrega,cChvNF,cNumeroNF,cCodEmp,cSerieNF,cCNPJ)
	Method XmlAprvNFS(cAprovador,cEmissao,cNotaFiscal,cFornecedor,aProduto)

EndClass

Method New() Class TIntegraBizagi

Return()

Method ConfNFE(cChaveF1,cEntrega,cChvNF) Class TIntegraBizagi

	Local aLst	:=	{}
	Local aProd	:= {}
	Local cInsertSQL := ""
	Local cLstRecno := ""
	Local lRetBz
	Local cNumeroNF := ""
	Local cCodEmp := ""
	Local cSerieNF := ""
	Local cCNPJ := ""
	Local cLojaCNPJ := ""
	Local cDscPrd := ""
	Local cUMPrd := ""
	Local cXmlRetorno := ""	
	Local cGrpPrd := ""
	Local cTpReceb := ""
	Local cRecEqMP := GetMV("MV_RECEQMP")


	SF1->(DbSetOrder(1))		
	If (SF1->(DbSeek(cChaveF1)))		

		If (SF1->F1_YFLAGBZ == "R")
			Return .T.
		EndIf

		BEGIN TRANSACTION	

			RecLock("SF1",.F.)

			cNumeroNF := SF1->F1_DOC
			cCodEmp := cEmpAnt
			cSerieNF := SF1->F1_SERIE

			If SF1->F1_TIPO $ "B/D"
				SA1->( dbSetOrder(1) )
				SA1->( dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA ) )
				cCNPJ := Alltrim(SA1->A1_CGC)
				cLojaCNPJ := Alltrim(SA1->A1_LOJA)
			Else
				SA2->( dbSetOrder(1) )
				SA2->( dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA ) )
				cCNPJ := Alltrim(SA2->A2_CGC)
				cLojaCNPJ := Alltrim(SA2->A2_LOJA) 
			EndIf		

			SF1->F1_YFLAGBZ := "R"			
			SF1->(MsUnlock()) 					

			SD1->(DbSetOrder(1))
			If (SD1->(DbSeek(cChaveF1)))			
				While !SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cChaveF1

					RecLock("SD1",.F.)					

					SD1->D1_YFLAGBZ := "R"			
					SD1->(MsUnlock())

					If (!Empty(cLstRecno))
						cLstRecno += ","
					EndIf

					cLstRecno += ALLTRIM(STR(SD1->(RECNO())))

					/**/
					zp2Area := GetArea()									
					ZP002 := "SELECT C7.C7_YMAT AS 'SOLICITANTE', ISNULL(C1.C1_YBIZAGI,'-') AS 'BIZAGI', ISNULL(C1.C1_NUM,'-') AS 'SC', C7.C7_DESCRI AS 'DESCRICAO_ITEM', C7.C7_UM AS 'UNIDADE_MEDIDA' "
					ZP002 += "  FROM " + RetSqlName("SC7") + " C7 (NOLOCK) "
					ZP002 += " LEFT JOIN " + RetSqlName("SC1") + " C1 (NOLOCK) ON C1.C1_FILIAL = C7.C7_FILIAL AND C1.C1_NUM = C7.C7_NUMSC AND C1.C1_ITEM = C7.C7_ITEMSC AND C1.D_E_L_E_T_ = '' "
					ZP002 += " WHERE C7.C7_FILIAL = " + xFilial("SC7") + " "
					ZP002 += "   AND C7.C7_NUM IN ('" + SD1->D1_PEDIDO + "') "
					ZP002 += "   AND C7.C7_ITEM = '" + SD1->D1_ITEMPC +  "' "
					ZP002 += "   AND C7.D_E_L_E_T_ = '' "					
					ZPcIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP002),'ZP002',.T.,.T.)
					dbSelectArea("ZP002")
					dbGoTop()
					cDscPrd := ZP002->DESCRICAO_ITEM
					cUMPrd := ZP002->UNIDADE_MEDIDA
					ZP002->(dbCloseArea())
					Ferase(ZPcIndex+GetDBExtension())
					Ferase(ZPcIndex+OrdBagExt())
					RestArea(zp2Area)	

					If Empty(cTpReceb)
						If ( ALLTRIM((SD1->D1_GRUPO)) $ "101A,101B,101C,101D,101E" ) 
							cTpReceb := "MPM"
						ElseIf ( ALLTRIM((SD1->D1_GRUPO)) $ "102A,102B,102C,102D,102E,102F,102G,102H,102I,104A,104B" )
							cTpReceb := "MP"
						ElseIf ( ALLTRIM((SD1->D1_GRUPO)) $ "104C" .And. ALLTRIM((SD1->D1_COD)) $ cRecEqMP )
							cTpReceb := "MP"
						Else
							cTpReceb := "ALM"				
						EndIf
					EndIf

					aProd := {}					
					aadd(aProd, ALLTRIM(SD1->D1_ITEM)) /* ITEM */
					aadd(aProd, ALLTRIM(SD1->D1_COD)) /* PRODUTO */
					aadd(aProd, SD1->D1_QUANT) /* QUANTIDADE */
					aadd(aProd, ALLTRIM(SD1->D1_LOCAL)) /* ARMAZEM */
					aadd(aProd, ALLTRIM(SD1->D1_PEDIDO)) /* PEDIDO */
					aadd(aProd, ALLTRIM(StrTran( cDscPrd, "'", " " ))) /* DESCRICAO */
					aadd(aProd, ALLTRIM(cUMPrd)) /* UNIDADE DE MEDIDA */					
					aadd(aLst,aProd)					

					SD1->(DbSkip())				
				EndDo
			EndIf

			If Len(aLst) > 0 					

				// ([DATA_INTEGRACAO_BIZAGI],[DATA_INTEGRACAO_PROTHEUS],[STATUS],[DADOS_ENTRADA],[DADOS_RETORNO],[PROCESSO_BIZAGI],[RECNO_RETORNO],[EMPRESA],[FILIAL],[PROCESSO_NOME],[RET_ERP],[STATUS_ERP],[GUID])
				cInsertSQL := " INSERT INTO BZINTEGRACAO ([DATA_INTEGRACAO_PROTHEUS],[STATUS],[DADOS_ENTRADA],[DADOS_ENTRADA_EXTRA],[DADOS_ENTRADA_EXTRA1],[DADOS_ENTRADA_EXTRA2],[DADOS_ENTRADA_EXTRA3],[RECNO_RETORNO],[EMPRESA],[FILIAL],[PROCESSO_NOME])"
				cInsertSQL += " SELECT FORMAT(GETDATE(),'yyyy-MM-dd HH:mm:ss')  'AS DATA_INTEGRACAO_PROTHEUS' "
				cInsertSQL += " , 'IP' AS 'STATUS' "

				cXmlRetorno := ::XmlConfCegas(cEntrega,cChvNF,cNumeroNF,cCodEmp,cSerieNF,cCNPJ,cLojaCNPJ,aLst,cTpReceb)
				If Len(cXmlRetorno) <= 4000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 8000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,   1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 12000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,   1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,8001,4000) + "' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 16000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,    1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 8001,4000) + "' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,12001,4000) + "' AS 'DADOS_ENTRADA_EXTRA2 "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 20000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,    1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 8001,4000) + "' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,12001,4000) + "' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,16001,4000) + "' AS 'DADOS_ENTRADA_EXTRA3' "
				End If

				cInsertSQL += " , '{F1," + ALLTRIM(STR(SF1->(RECNO()))) + "};{D1," + cLstRecno + "}' AS 'RECNO_RETORNO' "
				cInsertSQL += " , '" + cEmpAnt + "' AS 'EMPRESA' "
				cInsertSQL += " , '" + cFilAnt + "' AS 'FILIAL' "
				cInsertSQL += " , 'RM' AS 'PROCESSO_NOME' "

				lRetBz := TcSqlExec(cInsertSQL)

				If lRetBz < 0
					DisarmTransaction()
					MsgInfo("Erro no processo de integração PROTHEUS x BIZAGI. Favor procurar a TI. (TIntegraBizagi:ConfNFE - BZINTEGRACAO) - Erro : " + TCSQLError())	
				EndIf									

			EndIf			

		END TRANSACTION

	EndIf

Return()

Method AprvNFS(cChaveF1,cEntrega,cChvNF) Class TIntegraBizagi

	Local aLst	:=	{}
	Local aProd	:= {}
	Local cIdAprv := ""
	Local cMailApv := ""
	Local cSolicit := ""
	Local cSC := ""
	Local cSCBiz := ""
	Local cDscServ := ""
	Local cEmiss := ""
	Local cNF := ""
	Local cFornc := ""
	Local cInsertSQL := ""
	Local cLstRecno := ""
	Local lRetBz
	Local cXmlRetorno := ""
	Local cBizagi	:= U_fGetBase("2")

	Local aAreaF1 := SF1->(GetArea())
	Local aAreaD1 := SD1->(GetArea())

	SF1->(DbSetOrder(1))		
	If (SF1->(DbSeek(cChaveF1)))		

		If (SF1->F1_YFLAGBZ == "R")
			Return .T.
		EndIf

		BEGIN TRANSACTION	

			RecLock("SF1",.F.)
			SF1->F1_YFLAGBZ := "R"			
			SF1->F1_CODNFE := cChvNF
			SF1->(MsUnlock()) 					

			cEmiss := SF1->F1_EMISSAO
			cNF := SF1->F1_DOC
			cFornc := SF1->F1_FORNECE 

			SD1->(DbSetOrder(1))
			If (SD1->(DbSeek(cChaveF1)))			
				While !SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cChaveF1

					RecLock("SD1",.F.)
					SD1->D1_YFLAGBZ := "R"			
					SD1->(MsUnlock())

					If (!Empty(cLstRecno))
						cLstRecno += ","
					EndIf

					cLstRecno += ALLTRIM(STR(SD1->(RECNO())))

					/**/
					zp2Area := GetArea()									
					ZP002 := "SELECT C7.C7_YMAT AS 'SOLICITANTE', C1.C1_YBIZAGI AS 'BIZAGI', C1.C1_NUM AS 'SC', C7.C7_DESCRI AS 'DESCRICAO_ITEM', C7.C7_UM AS 'UNIDADE_MEDIDA' "
					ZP002 += "  FROM " + RetSqlName("SC7") + " C7 (NOLOCK) "
					ZP002 += " INNER JOIN " + RetSqlName("SC1") + " C1 (NOLOCK) ON C1.C1_FILIAL = C7.C7_FILIAL AND C1.C1_NUM = C7.C7_NUMSC AND C1.C1_ITEM = C7.C7_ITEMSC AND C1.D_E_L_E_T_ = '' "
					ZP002 += " WHERE C7.C7_FILIAL = " + xFilial("SC7") + " "
					ZP002 += "   AND C7.C7_NUM IN ('" + SD1->D1_PEDIDO + "') "
					ZP002 += "   AND C7.C7_ITEM = '" + SD1->D1_ITEMPC +  "' "
					ZP002 += "   AND C7.D_E_L_E_T_ = '' "					
					ZPcIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP002),'ZP002',.T.,.T.)
					dbSelectArea("ZP002")
					dbGoTop()
					cSC := ZP002->SC
					cSCBiz := ZP002->BIZAGI
					cDscServ := ZP002->DESCRICAO_ITEM
					ZP002->(dbCloseArea())
					Ferase(ZPcIndex+GetDBExtension())
					Ferase(ZPcIndex+OrdBagExt())
					RestArea(zp2Area)			

					If AllTrim(cSC) <> "" .And. AllTrim(cSCBiz) <> ""
						/**/
						zp3Area := GetArea()									
						ZP003 := "SELECT "
						ZP003 += "  BIZAGI "
						ZP003 += ", PROTHEUS "
						ZP003 += ", EMPRESA "
						ZP003 += ", SOLICITANTE "
						ZP003 += ", NOME_SOLICITANTE "
						ZP003 += ", EMAIL_SOLICITANTE "
						ZP003 += ", APROVADOR "
						ZP003 += ", NOME_APROVADOR "
						ZP003 += ", EMAIL_APROVADOR "
						ZP003 += "FROM "+cBizagi+".dbo.VW_SC_SOL_APRV "
						ZP003 += "WHERE BIZAGI = '" + cSCBiz + "' AND PROTHEUS =  '" + cSC + "'"
						ZPcIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP003),'ZP003',.T.,.T.)
						dbSelectArea("ZP003")
						dbGoTop()		

						If Empty(cIdAprv)
							If (SD1->D1_CLVL $ ('3190,3290'))
								cIdAprv := ZP003->APROVADOR
							Else
								cIdAprv := ZP003->SOLICITANTE
							EndIf					
						EndIf		

						cSolicit := ZP003->NOME_SOLICITANTE
						ZP003->(dbCloseArea())
						Ferase(ZPcIndex+GetDBExtension())
						Ferase(ZPcIndex+OrdBagExt())
						RestArea(zp3Area)					

						aProd := {} 											
						aadd(aProd, ALLTRIM(SD1->D1_COD)) /* PRODUTO */
						aadd(aProd, SD1->D1_VUNIT) /* VALOR UNITARIO */
						aadd(aProd, ALLTRIM(SD1->D1_CC)) /* CENTRO DE CUSTO */
						aadd(aProd, ALLTRIM(SD1->D1_PEDIDO)) /* PEDIDO */
						aadd(aProd, SD1->D1_QUANT) /* QUANTIDADE */
						aadd(aProd, ALLTRIM(SD1->D1_CONTA)) /* CONTA CONTABIL */
						aadd(aProd, cSolicit) /* SOLICITANTE */
						aadd(aProd, SD1->D1_TOTAL) /* VALOR TOTAL */
						aadd(aProd, ALLTRIM(SD1->D1_CLVL)) /* CLASSE DE VALOR */
						aadd(aProd, cSC) /* NUMERO SC */
						aadd(aProd, cSCBiz) /* NUMERO SC BIZAGI */
						aadd(aProd, StrTran( cDscServ, "'", " " )) /* DESCRICAO ITEM */

						aadd(aLst,aProd)
					EndIf

					SD1->(DbSkip())				
				EndDo
			EndIf

			If Len(aLst) > 0 					

				// ([DATA_INTEGRACAO_BIZAGI],[DATA_INTEGRACAO_PROTHEUS],[STATUS],[DADOS_ENTRADA],[DADOS_RETORNO],[PROCESSO_BIZAGI],[RECNO_RETORNO],[EMPRESA],[FILIAL],[PROCESSO_NOME],[RET_ERP],[STATUS_ERP],[GUID])
				cInsertSQL := " INSERT INTO BZINTEGRACAO ([DATA_INTEGRACAO_PROTHEUS],[STATUS],[DADOS_ENTRADA],[DADOS_ENTRADA_EXTRA],[DADOS_ENTRADA_EXTRA1],[DADOS_ENTRADA_EXTRA2],[DADOS_ENTRADA_EXTRA3],[RECNO_RETORNO],[EMPRESA],[FILIAL],[PROCESSO_NOME])"
				cInsertSQL += " SELECT FORMAT(GETDATE(),'yyyy-MM-dd HH:mm:ss')  'AS DATA_INTEGRACAO_PROTHEUS' "
				cInsertSQL += " , 'IP' AS 'STATUS' "

				cXmlRetorno := ::XmlAprvNFS(cIdAprv, cEmiss, cNF, cFornc, aLst)
				If Len(cXmlRetorno) <= 4000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 8000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,   1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 12000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,   1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,8001,4000) + "' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 16000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,    1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 8001,4000) + "' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,12001,4000) + "' AS 'DADOS_ENTRADA_EXTRA2 "
					cInsertSQL += " , '' AS 'DADOS_ENTRADA_EXTRA3' "
				ElseIf Len(cXmlRetorno) <= 20000
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,    1,4000) + "' AS 'DADOS_ENTRADA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 4001,4000) + "' AS 'DADOS_ENTRADA_EXTRA' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno, 8001,4000) + "' AS 'DADOS_ENTRADA_EXTRA1' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,12001,4000) + "' AS 'DADOS_ENTRADA_EXTRA2' "
					cInsertSQL += " , '" + SUBSTR(cXmlRetorno,16001,4000) + "' AS 'DADOS_ENTRADA_EXTRA3' "
				End If

				cInsertSQL += " , '{F1,[" + ALLTRIM(STR(SF1->(RECNO()))) + "]}{D1,[" + cLstRecno + "]}' AS 'RECNO_RETORNO' "
				cInsertSQL += " , '" + cEmpAnt + "' AS 'EMPRESA' "
				cInsertSQL += " , '" + cFilAnt + "' AS 'FILIAL' "
				cInsertSQL += " , 'ASP' AS 'PROCESSO_NOME' "

				lRetBz := TcSqlExec(cInsertSQL)						

				If lRetBz < 0
					DisarmTransaction()
					MsgInfo("Erro no processo de integração PROTHEUS x BIZAGI. Favor procurar a TI. (BZINTEGRACAO) - Erro : " + TCSQLError())	
				EndIf
			EndIf

		END TRANSACTION

	EndIf

	RestArea(aAreaF1)
	RestArea(aAreaD1)

	//MsgInfo("Processo de Aprovação de NF de Serviço inserido com sucesso!")

Return()


Method XmlConfCegas(cEntrega,cChvNF,cNumeroNF,cCodEmp,cSerieNF,cCNPJ,cLojaCNPJ,aProduto,cTpReceb) Class TIntegraBizagi

	Local cXml := ""
	Local nI

	cXml += '<BizAgiWSParam>'
	cXml += '<domain>domain</domain>'
	cXml += '<userName>admon</userName>'
	cXml += '<Cases>'
	cXml += '<Case>'
	cXml += '<Process>ReceberMaterial</Process>'
	cXml += '<Entities>'
	cXml += '<ReceberMaterial>'
	cXml += '<Placa>--------</Placa>'
	cXml += '<Motorista>' + cEntrega + '</Motorista>'
	cXml += '<ObservacaodoRecebimento>ABERTURA VIA PROTHEUS - DOCUMENTO DE ENTRADA</ObservacaodoRecebimento>'
	cXml += '<RecebimentoCompartilhado>false</RecebimentoCompartilhado>'
	cXml += '<ListaEntradaMaterial>'
	cXml += '<EntradadeMaterial>'
	cXml += '<EmpresadeDescarga entityName="VW_BZ_DADOS_EMPRESA">'
	cXml += '<Codigo>' + cCodEmp + '</Codigo>'
	cXml += '</EmpresadeDescarga>'
	cXml += '<CNPJ>' + cCNPJ + '</CNPJ>'
	cXml += '<LojaCNPJ>' + cLojaCNPJ + '</LojaCNPJ>'
	cXml += '<NumeroNF>' + cNumeroNF + '</NumeroNF>'
	cXml += '<SerieNF>' + cSerieNF + '</SerieNF>'
	cXml += '<NotaFiscal>' + cChvNF + '</NotaFiscal>'
	cXml += '<TipoRecebimento>' + cTpReceb + '</TipoRecebimento>'
	/**/
	cXml += '<ItensdaNotaFiscal>'
	For nI:=1 to Len(aProduto)		
		cXml += '<ItemdaNotaFiscalEM>'
		cXml += '<NumerodoItem>' + aProduto[nI][1] + '</NumerodoItem>'
		cXml += '<CodigodoProduto>' + aProduto[nI][2] + '</CodigodoProduto>'
		cXml += '<QuantidadeNF>' + cValToChar(aProduto[nI][3]) + '</QuantidadeNF>'
		cXml += '<Armazem>' + aProduto[nI][4] + '</Armazem>'
		cXml += '<NumeroPedido>' + aProduto[nI][5] + '</NumeroPedido>'
		cXml += '<DescricaodoProduto>' + aProduto[nI][6] + '</DescricaodoProduto>'
		cXml += '<UnidadedeMedida>' + aProduto[nI][7] + '</UnidadedeMedida>'
		cXml += '</ItemdaNotaFiscalEM>'			
	Next
	cXml += '</ItensdaNotaFiscal>'
	/**/
	cXml += '</EntradadeMaterial>'
	cXml += '</ListaEntradaMaterial>'
	cXml += '<IniciadoAutomaticamente>true</IniciadoAutomaticamente>'
	cXml += '</ReceberMaterial>'
	cXml += '</Entities>'
	cXml += '</Case>'
	cXml += '</Cases>'
	cXml += '</BizAgiWSParam>'

Return cXml


Method XmlAprvNFS(cAprovador,cEmissao,cNotaFiscal,cFornecedor,aProduto) Class TIntegraBizagi

	Local nI := 1
	Local cXml := ""	
	cXml += '<BizAgiWSParam>'
	cXml += '<domain>domain</domain>'
	cXml += '<userName>admon</userName>'
	cXml += '<Cases>'
	cXml += '<Case>'
	cXml += '<Process>AprovacaoDeServicoPrestado</Process>'
	cXml += '<Entities>'
	cXml += '<AprovacaodeServicoPresta>'
	cXml += '<Aprovador>' + cValToChar(cAprovador) + '</Aprovador>'
	cXml += '<DataEmissao>' + DtoC(cEmissao) + '</DataEmissao>'
	cXml += '<NumeroNotaFiscal>' + cNotaFiscal + '</NumeroNotaFiscal>'
	cXml += '<Fornecedor><Codigo>' + cFornecedor + '</Codigo></Fornecedor>'
	cXml += '<ItemNotaFiscalServico>'	

	For nI:=1 to Len(aProduto)		
		cXml += '<ItemNotaFiscalServico>'
		cXml += '<Produto><Codigo>' + aProduto[nI][1] + '</Codigo></Produto>'
		cXml += '<ValorUnitario>' + cValToChar(aProduto[nI][2]) + '</ValorUnitario>'
		cXml += '<CentrodeCusto><CODIGO>' + aProduto[nI][3] + '</CODIGO></CentrodeCusto>'
		cXml += '<NumeroPedido>' + aProduto[nI][4] + '</NumeroPedido>'
		cXml += '<Quantidade>' + cValToChar(aProduto[nI][5]) + '</Quantidade>'
		cXml += '<ContaContabil><Codigo>' + aProduto[nI][6] + '</Codigo></ContaContabil>'
		cXml += '<NomeSolicitante>' + aProduto[nI][7] + '</NomeSolicitante>'
		cXml += '<ValorTotal>' + cValToChar(aProduto[nI][8]) + '</ValorTotal>'
		cXml += '<ClasseValor><Codigo>' + aProduto[nI][9] + '</Codigo></ClasseValor>'
		cXml += '<NumeroSC>' + aProduto[nI][10] + '</NumeroSC>'
		cXml += '<NumeroBizagi>' + aProduto[nI][11] + '</NumeroBizagi>'
		cXml += '<DescricaoItem>' + aProduto[nI][12] + '</DescricaoItem>'
		cXml += '</ItemNotaFiscalServico>'			
	Next

	cXml += '</ItemNotaFiscalServico>'
	cXml += '</AprovacaodeServicoPresta>'
	cXml += '</Entities>'
	cXml += '</Case>'
	cXml += '</Cases>'
	cXml += '</BizAgiWSParam>'		

Return cXml