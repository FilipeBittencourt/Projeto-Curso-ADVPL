#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TProcessoRocket
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe para tratamento de Processos de integracao com a plataforma Rocket
@type class
/*/

Class TProcessoRocket From LongClassName
	
	Data cCodPro
	Data cEmpresa
	Data cUsuario
	Data cSenha
	Data cHash
	Data cTicket	
	Data cStatus
	Data cTipo
	Data cFluxo
	Data cFluxoGrp
	Data cFluxoDev
	Data cFluxoDevGrp
	Data cIDFluxo
	Data cURLPost
	Data cXMLSend
	Data cXMLReceive
	Data oXmlReceive
	Data oLst
	Data nLimAtu // Limite de crédito atual
	Data nLimSol // Limite de crédito solicitado
	Data nLimApr // Limite de crédito aprovado pelo analista
	Data nLimSug // Limite de crédito sugerido pelo analista
	Data nRisSug // Risco sugerido
	Data nRisDef // Risco definido pelo analista
	Data nRatCal // Rating calculado
	Data nRatDef // Rating definido pelo analista
	Data nMaiAcu // Maior acumulo
	Data nVarAum // Variação percentual de aumento
	Data nValLim // validade do limite de credito, em meses
	Data cParCli // Parecer da analise do cliente
	Data cPorte // Porte do cliente
	Data cCredit // Decisão Analista - Identifica o retorno da plataforma Rocket - APROVADO; REPROVADO; APROVADO_AUTOMATICO; REPROVADO_AUTOMATICO	 
	Data lEnvProd // Ambiente de Producao
	
	Method New() Constructor
	Method Add()
	Method AddReturn()
	Method UpdCustomer()
	Method UpdCreditRequest()
	Method GetSeq()
	Method Load()
	Method Request()
	Method Response()
	Method FlowExecution()
	Method FlowStatus()
	Method HttpPost()
	Method GetRisk()
	Method FirstPurchase(cCustomer)
	Method MaxRisk()
	
EndClass


Method New() Class TProcessoRocket

	::cCodPro := ""
	::cEmpresa := "02077546000176"
	::cUsuario := "teste_ws"
	::cSenha := "teste_ws"
	::cHash := ""
	::cTicket := ""
	::cStatus := ""
	::cTipo := ""
	::cFluxo := "WS_BIANCOGRES_CREDITO_PJ_PRD"
	::cFluxoGrp := "WS_BIANCOGRES_GRUPO_PRD"
	::cFluxoDev := "WS_BIANCOGRES_CREDITO_PJ_HOMOLOG"
	::cFluxoDevGrp := "WS_BIANCOGRES_GRUPO_HOMOLOG"
	::cIDFluxo := "PJ"
	::cURLPost := "https://wsrocket.cmsw.com/Rocket_02077546000176/services"
	::cXMLSend := ""
	::cXMLReceive := ""
	::oXMLReceive := Nil
	::oLst := ArrayList():New()
	::nLimAtu := 0
	::nLimSol := 0
	::nLimApr := 0
	::nLimSug := 0
	::nRisSug := 0
	::nRisDef := 0
	::nRatCal := 0
	::nRatDef  := 0
	::nMaiAcu := 0
	::nVarAum := 0
	::nValLim := 0
	::cParCli := ""
	::cPorte := ""
	::cCredit := ""
	::lEnvProd := If (Upper(AllTrim(GetEnvserver())) $ "PRODUCAO/SCHEDULE/REMOTO/COMP-TIAGO", .T., .F.)

Return()


Method Add() Class TProcessoRocket

	RecLock("ZM3", .T.)

		ZM3->ZM3_FILIAL := xFilial("ZM3")
		ZM3->ZM3_CODPRO := ::cCodPro
		ZM3->ZM3_SEQ := ::GetSeq()
		ZM3->ZM3_DATA := dDataBase
		ZM3->ZM3_HORA := Time()
		ZM3->ZM3_HASH := ::cHash
		ZM3->ZM3_TICKET := ::cTicket
		ZM3->ZM3_STATUS := ::cStatus
		ZM3->ZM3_TIPO := ::cTipo
		
	ZM3->(MsUnLock())
	
Return()


Method GetSeq() Class TProcessoRocket
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(ZM3_SEQ), '') AS ZM3_SEQ "
	cSQL += " FROM "+ RetSQLName("ZM3")
	cSQL += " WHERE ZM3_FILIAL = "+ ValToSQL(xFilial("ZM3"))
	cSQL += " AND ZM3_CODPRO = "+ ValToSQL(::cCodPro)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	cRet := Soma1((cQry)->ZM3_SEQ)

	(cQry)->(DbCloseArea())

Return(cRet)


Method Load() Class TProcessoRocket
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 ZM3_HASH, ZM3_TICKET, ZM3_STATUS "
	cSQL += " FROM "+ RetSQLName("ZM3")
	cSQL += " WHERE ZM3_FILIAL = "+ ValToSQL(xFilial("ZM3"))
	cSQL += " AND ZM3_CODPRO = "+ ValToSQL(::cCodPro)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZM3_SEQ DESC "	

	TcQuery cSQL New Alias (cQry)

	lRet := !(cQry)->(Eof())
	
	::cHash := (cQry)->ZM3_HASH
	::cTicket := (cQry)->ZM3_TICKET
	::cStatus := (cQry)->ZM3_STATUS

	(cQry)->(DbCloseArea())

Return(lRet)


Method AddReturn() Class TProcessoRocket

	RecLock("ZM4", .T.)

		ZM4->ZM4_FILIAL := xFilial("ZM4")
		ZM4->ZM4_CODPRO := ::cCodPro
		ZM4->ZM4_DATA := dDataBase
		ZM4->ZM4_HORA := Time()
		ZM4->ZM4_VLLCA := ::nLimAtu
		ZM4->ZM4_VLLCS := ::nLimSol
		ZM4->ZM4_VLLCAA := ::nLimApr
		ZM4->ZM4_VLLCSA := ::nLimSug
		ZM4->ZM4_VLRIS := ::nRisSug
		ZM4->ZM4_VLRIA := ::nRisDef
		ZM4->ZM4_VLRAC := ::nRatCal
		ZM4->ZM4_VLRAA := ::nRatDef
		ZM4->ZM4_VLMC := ::nMaiAcu
		ZM4->ZM4_VLVA := ::nVarAum
		ZM4->ZM4_DTVLC := MonthSum(dDataBase, ::nValLim)
		ZM4->ZM4_PAC := ::cParCli
		ZM4->ZM4_PORTE := ::cPorte
		ZM4->ZM4_CREDIT := ::cCredit

	ZM4->(MsUnLock())
	

	DbSelectArea("ZM0")
	DbSetOrder(1)
	If ZM0->(DbSeek(xFilial("ZM0") + ::cCodPro))
	
		RecLock("ZM0", .F.)
					
			ZM0->ZM0_CREDIT := ::cCredit
		
		ZM0->(MsUnLock())
	
	EndIf
	
Return()


Method UpdCustomer() Class TProcessoRocket
Local aEmp := {"01", "05", "07", "12", "13", "14", "16", "17"}
Local cRisk := ::GetRisk()
Local nCount := 0
Local cSQL := ""

	For nCount := 1 To Len(aEmp)
	
		cSQL := " UPDATE " + RetFullName("SA1", aEmp[nCount])
		cSQL += " SET A1_LC = " + ValToSQL(If (::nLimApr > 0, ::nLimApr, ::nLimSug)) + ", A1_VENCLC = " + ValToSQL(MonthSum(dDataBase, ::nValLim))
		
		If !Empty(cRisk)
		
			cSQL += ", A1_RISCO = " + ValToSQL(cRisk)
		
		EndIf
		
		cSQL += " WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
		cSQL += " AND SUBSTRING(A1_CGC, 1, 8) IN "
		cSQL += " ( "
		cSQL += " 	SELECT SUBSTRING(ZM1_CNPJ, 1, 8) "
		cSQL += " 	FROM " + RetSQLName("ZM1")
		cSQL += " 	WHERE ZM1_FILIAL = " + ValToSQL(xFilial("ZM1"))
		cSQL += " 	AND ZM1_CODPRO = " + ValToSQL(::cCodPro)
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " ) "
		cSQL += " AND A1_YTIPOLC IN "
		cSQL += " ( "		
		cSQL += " 	SELECT A1_YTIPOLC
		cSQL += " 	FROM " + RetFullName("SA1", aEmp[nCount])
		cSQL += " 	WHERE A1_CGC IN
		cSQL += " 	(
		cSQL += " 		SELECT ZM1_CNPJ "
		cSQL += " 		FROM " + RetSQLName("ZM1")
		cSQL += " 		WHERE ZM1_FILIAL = " + ValToSQL(xFilial("ZM1"))
		cSQL += " 		AND ZM1_CODPRO = " + ValToSQL(::cCodPro)
		cSQL += " 		AND D_E_L_E_T_ = '' "
		cSQL += " 	)
		cSQL += " 	AND D_E_L_E_T_ = ''
		cSQL += " ) "				
		cSQL += " AND D_E_L_E_T_ = '' "
	
		TcSQLExec(cSQL)	

	Next

Return()


Method UpdCreditRequest() Class TProcessoRocket
Local cSQL := ""

	cSQL := " UPDATE " + RetFullName("SZU", "01")
	cSQL += " SET ZU_STATUS = " + ValToSQL(If (::cCredit $ "AM/AA", "APROVADO", "REPROVADO"))
	cSQL += ", ZU_DATAAPR = " + ValToSQL(dDatabase)
	cSQL += ", ZU_OBS_LIB = " + ValToSQL(::cParCli)	
	cSQL += " WHERE ZU_FILIAL = " + ValToSQL(xFilial("SZU"))
	cSQL += " AND ZU_BIZAGI = '' "
	cSQL += " AND ZU_CODPRO = " + ValToSQL(::cCodPro)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcSQLExec(cSQL)

Return()


Method Request() Class TProcessoRocket

	::FlowExecution()
	
	If ::HttpPost()
	
		If ::cIDFluxo == "PJ"
		
			If ::lEnvProd
		
				::cHash := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_CREDITO_PJ_PRDRESPONSE:_RETORNO:_PROCESSRETURN:_HASH:TEXT
				::cTicket := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_CREDITO_PJ_PRDRESPONSE:_RETORNO:_PROCESSRETURN:_TICKET:TEXT
				
			Else

				::cHash := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_CREDITO_PJ_HOMOLOGRESPONSE:_RETORNO:_PROCESSRETURN:_HASH:TEXT
				::cTicket := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_CREDITO_PJ_HOMOLOGRESPONSE:_RETORNO:_PROCESSRETURN:_TICKET:TEXT
			
			EndIf
			
		ElseIf ::cIDFluxo == "GRP"
		
			If ::lEnvProd
			
				::cHash := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_GRUPO_PRDRESPONSE:_RETORNO:_PROCESSRETURN:_HASH:TEXT
				::cTicket := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_GRUPO_PRDRESPONSE:_RETORNO:_PROCESSRETURN:_TICKET:TEXT
				
			Else
			
				::cHash := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_GRUPO_HOMOLOGRESPONSE:_RETORNO:_PROCESSRETURN:_HASH:TEXT
				::cTicket := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_GRUPO_HOMOLOGRESPONSE:_RETORNO:_PROCESSRETURN:_TICKET:TEXT
						
			EndIf		
		
		EndIf
		
		::cTipo := "1"
		
		::Add()
		
	EndIf
			
Return()


Method Response() Class TProcessoRocket
Local oXml := Nil
Local nCount := 1

	::FlowExecution()
	
	If ::HttpPost()
	
		If ::cIDFluxo == "PJ"
		
			If ::lEnvProd
				
				oXml := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_CREDITO_PJ_PRDRESPONSE:_RETORNO:_PROCESSRETURN:_VARIAVEISCONTEXTO:_VARIAVELCONTEXTO
				
			Else
			
				oXml := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_CREDITO_PJ_HOMOLOGRESPONSE:_RETORNO:_PROCESSRETURN:_VARIAVEISCONTEXTO:_VARIAVELCONTEXTO
			
			EndIf
					
		ElseIf ::cIDFluxo == "GRP"
		
			If ::lEnvProd
			
				oXml := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_GRUPO_PRDRESPONSE:_RETORNO:_PROCESSRETURN:_VARIAVEISCONTEXTO:_VARIAVELCONTEXTO
				
			Else
			
				oXml := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_WS_BIANCOGRES_GRUPO_HOMOLOGRESPONSE:_RETORNO:_PROCESSRETURN:_VARIAVEISCONTEXTO:_VARIAVELCONTEXTO
			
			EndIf
					
		EndIf
	
		While nCount <= Len(oXml)
		
			If oXml[nCount]:_NOME:TEXT == "LIMITE_ATUAL"
				
				::nLimAtu := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
			
			ElseIf oXml[nCount]:_NOME:TEXT == "LIMITE_SOLICITADO"
			
				::nLimSol := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
				
			ElseIf oXml[nCount]:_NOME:TEXT == "LIMITE_ANALISTA"
			
				::nLimApr := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
				
			ElseIf oXml[nCount]:_NOME:TEXT == "LIMITE_SUGERIDO"
				
				::nLimSug := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
			
			ElseIf oXml[nCount]:_NOME:TEXT == "RISCO_SUGERIDO"
			
				::nRisSug := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
			
			ElseIf oXml[nCount]:_NOME:TEXT == "RISCO_ANALISTA"
			
				::nRisDef := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
			
			ElseIf oXml[nCount]:_NOME:TEXT == "RATING_CALCULADO"
				
				::nRatCal := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
			
			ElseIf oXml[nCount]:_NOME:TEXT == "RATING_ANALISTA"
				
				::nRatDef := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
			
			ElseIf oXml[nCount]:_NOME:TEXT == "MAIOR_ACUMULO"
				
				::nMaiAcu := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
			
			ElseIf oXml[nCount]:_NOME:TEXT == "VARIACAO_AUMENTO"
			
				::nVarAum := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
				
			ElseIf oXml[nCount]:_NOME:TEXT == "VALIDADE_LIMITE"
				
				::nValLim := Round(Val(oXml[nCount]:_VALOR:TEXT), 2)
				
			ElseIf oXml[nCount]:_NOME:TEXT == "PARECER_ANALISE"
			
				::cParCli := oXml[nCount]:_VALOR:TEXT
				
			ElseIf oXml[nCount]:_NOME:TEXT == "PORTE_CLIENTE"
			
				::cPorte := oXml[nCount]:_VALOR:TEXT
			
			ElseIf oXml[nCount]:_NOME:TEXT == "DECISAO_ANALISTA"
			
				If Upper(oXml[nCount]:_VALOR:TEXT) == "APROVADO"
				
					::cCredit := "AM"
				
				ElseIf Upper(oXml[nCount]:_VALOR:TEXT) == "REPROVADO"
				
					::cCredit := "RM"
				
				ElseIf Upper(oXml[nCount]:_VALOR:TEXT) == "APROVADO_AUTOMATICO"
				
					::cCredit := "AA"
				
				ElseIf Upper(oXml[nCount]:_VALOR:TEXT) == "REPROVADO_AUTOMATICO"
				
					::cCredit := "RA"
				
				EndIf
			
			EndIf			
			
			nCount++
						
		EndDo()
		
		::cTipo := "3"
		
		::Add()
			
		::AddReturn()
		
		If ::cCredit == "AM" .Or. ::cCredit == "AA"
			
			::UpdCustomer()
			
		EndIf
		
		::UpdCreditRequest()
		
	EndIf
	
Return()


Method FlowExecution() Class TProcessoRocket
Local nCount := 1
Local cFluxo := ""
	
	If ::oLst:GetCount() > 0
		
		If Empty(::oLst:GetItem(nCount):cGrpVen)
		
			cFluxo := If (::lEnvProd, ::cFluxo, ::cFluxoDev)
			
			::cIDFluxo := "PJ"
		
		Else
			
			cFluxo := If (::lEnvProd, ::cFluxoGrp, ::cFluxoDevGrp)
			
			::cIDFluxo := "GRP"
		
		EndIf
		
		While nCount <= ::oLst:GetCount()

			::cXMLSend := '<?xml version="1.0" encoding="UTF-8"?>'
			::cXMLSend += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:int="http://interfaces.webservice.rocket.cmsoftware.com.br">'
			::cXMLSend += '<soap:Header/>'
			::cXMLSend += '<soap:Body>'
			::cXMLSend += '<int:'+ cFluxo +'>'
			::cXMLSend += '<int:CPROCESS>'+ ::oLst:GetItem(nCount):cCodPro +'</int:CPROCESS>'
			::cXMLSend += '<int:DATA>'+ dToS(::oLst:GetItem(nCount):dData) +'</int:DATA>'
			::cXMLSend += '<int:CODIGO>'+ ::oLst:GetItem(nCount):cCliente +'</int:CODIGO>'
			::cXMLSend += '<int:LOJA>'+ ::oLst:GetItem(nCount):cLoja +'</int:LOJA>'			
			::cXMLSend += '<int:CNPJ>'+ ::oLst:GetItem(nCount):cCnpj +'</int:CNPJ>'
			::cXMLSend += '<int:TIPO>'+ ::oLst:GetItem(nCount):cTipo +'</int:TIPO>'
			::cXMLSend += '<int:SEGMENTO>'+ ::oLst:GetItem(nCount):cSegmento +'</int:SEGMENTO>'
			::cXMLSend += '<int:GRUPO>'+ ::oLst:GetItem(nCount):cGrpVen +'</int:GRUPO>'
			::cXMLSend += '<int:ORIGEM_GRUPO>'+ cValToChar(::oLst:GetItem(nCount):nOriGrp) +'</int:ORIGEM_GRUPO>'
			::cXMLSend += '<int:PORTE>'+ ::oLst:GetItem(nCount):cPorte +'</int:PORTE>'
			::cXMLSend += '<int:DAT_PRI_COM>'+ dToS(::oLst:GetItem(nCount):dDatPriCom) +'</int:DAT_PRI_COM>'
			::cXMLSend += '<int:LIM_CRE_ATU>'+ cValToChar(::oLst:GetItem(nCount):nLimCreAtu) +'</int:LIM_CRE_ATU>'
			::cXMLSend += '<int:LIMITE_SOLICITADO>'+ cValToChar(::oLst:GetItem(nCount):nLimCreSol) +'</int:LIMITE_SOLICITADO>'
			::cXMLSend += '<int:VLR_OBRA>'+ cValToChar(::oLst:GetItem(nCount):nVlrObr) +'</int:VLR_OBRA>'
			::cXMLSend += '<int:VLR_VAR_19>'+ cValToChar(::oLst:GetItem(nCount):nVlr_19) +'</int:VLR_VAR_19>'
			::cXMLSend += '<int:QTD_VAR_20>'+ cValToChar(::oLst:GetItem(nCount):nQtd_20) +'</int:QTD_VAR_20>'
			::cXMLSend += '<int:VLR_VAR_21>'+ cValToChar(::oLst:GetItem(nCount):nVlr_21) +'</int:VLR_VAR_21>'
			::cXMLSend += '<int:QTD_VAR_22>'+ cValToChar(::oLst:GetItem(nCount):nQtd_22) +'</int:QTD_VAR_22>'
			::cXMLSend += '<int:VLR_VAR_23>'+ cValToChar(::oLst:GetItem(nCount):nVlr_23) +'</int:VLR_VAR_23>'
			::cXMLSend += '<int:VAR_CALC_01>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_01) +'</int:VAR_CALC_01>'
			::cXMLSend += '<int:VAR_CALC_02>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_02) +'</int:VAR_CALC_02>'
			::cXMLSend += '<int:VAR_CALC_03>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_03) +'</int:VAR_CALC_03>'
			::cXMLSend += '<int:VAR_CALC_04>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_04) +'</int:VAR_CALC_04>'
			::cXMLSend += '<int:VAR_CALC_05>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_05) +'</int:VAR_CALC_05>'
			::cXMLSend += '<int:VAR_CALC_06>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_06) +'</int:VAR_CALC_06>'
			::cXMLSend += '<int:VAR_CALC_07>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_07) +'</int:VAR_CALC_07>'
			::cXMLSend += '<int:VAR_CALC_08>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_08) +'</int:VAR_CALC_08>'
			::cXMLSend += '<int:VAR_CALC_09>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_09) +'</int:VAR_CALC_09>'
			::cXMLSend += '<int:VAR_CALC_10>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_10) +'</int:VAR_CALC_10>'
			::cXMLSend += '<int:VAR_CALC_11>'+ cValToChar(::oLst:GetItem(nCount):nVlrC_11) +'</int:VAR_CALC_11>'
			::cXMLSend += '<int:header>'
			::cXMLSend += '<empresa>'+ ::cEmpresa +'</empresa>'
			::cXMLSend += '<usuario>'+ ::cUsuario +'</usuario>'
			::cXMLSend += '<senha>'+ ::cSenha +'</senha>'
			::cXMLSend += '<hash>'+ ::cHash +'</hash>'
			::cXMLSend += '<ticket>'+ ::cTicket +'</ticket>'			
			::cXMLSend += '<fluxo>'+ cFluxo +'</fluxo>'
			::cXMLSend += '</int:header>'
			::cXMLSend += '</int:'+ cFluxo +'>'
			::cXMLSend += '</soap:Body>'
			::cXMLSend += '</soap:Envelope>'
					
			nCount++
			
		EndDo()
		
	EndIf
		
Return()


Method FlowStatus() Class TProcessoRocket

	::cXMLSend := '<?xml version="1.0" encoding="UTF-8"?>'
	::cXMLSend += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:int="http://interfaces.webservice.rocket.cmsoftware.com.br">'
	::cXMLSend += '<soap:Header/>'
	::cXMLSend += '<soap:Body>'
	::cXMLSend += '<int:statusProcess>'
  ::cXMLSend += '<int:hash>'+ ::cHash +'</int:hash>'
  ::cXMLSend += '<int:ticket>'+ ::cTicket +'</int:ticket>'
  ::cXMLSend += '</int:statusProcess>'
	::cXMLSend += '</soap:Body>'
	::cXMLSend += '</soap:Envelope>'

	If ::HttpPost()
	
		::cStatus := ::oXMLReceive:_ENV_ENVELOPE:_ENV_BODY:_NS2_STATUSPROCESSRESPONSE:_STATUS_PROCESSO:TEXT
		::cTipo := "2"
		
		::Add()
				
	EndIf

Return()


Method HttpPost() Class TProcessoRocket
Local lRet := .F.
Local aHeadOut := {}
Local cXMLHead := ""
Local cError := ''
Local cWarning := ''

	::cXMLReceive := EncodeUTF8(HttpPost(::cURLPost, "", ::cXMLSend, 200, aHeadOut, @cXMLHead))
	
	If !Empty(::cXMLReceive)
	
		::oXMLReceive := XMLParser(::cXMLReceive, '_', @cError, @cWarning)
		
		lRet := !Empty(::oXMLReceive)
	
	EndIf 
	
Return(lRet)


Method GetRisk() Class TProcessoRocket
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT A1_COD, A1_YTIPOLC "
	cSQL += " FROM "+ RetSQLName("SA1")
	cSQL += " WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND A1_COD IN "
	cSQL += " ( "
	cSQL += " 	SELECT ZM1_CLIENT "
	cSQL += " 	FROM " + RetSQLName("ZM1")
	cSQL += " 	WHERE ZM1_FILIAL = " + ValToSQL(xFilial("ZM1"))
	cSQL += " 	AND ZM1_CODPRO = " + ValToSQL(::cCodPro)
	cSQL += " 	AND ZM1_TIPINT = '1' "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND D_E_L_E_T_ = ''	
	
	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->A1_YTIPOLC == "C" .And. !::FirstPurchase((cQry)->A1_COD)
		
		cRet := "D"
	
	ElseIf (cQry)->A1_YTIPOLC == "G"
	
		cRet := ::MaxRisk()
		
	EndIf 
	
	(cQry)->(DbCloseArea())

Return(cRet)


Method FirstPurchase(cCustomer) Class TProcessoRocket
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT MIN(A1_PRICOM) AS A1_PRICOM "
	cSQL += " FROM
	cSQL += " (
	cSQL += " 	SELECT A1_PRICOM "
	cSQL += " 	FROM "+ RetFullName("SA1", "01")
	cSQL += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " 	AND A1_COD = " + ValToSQL(cCustomer)
	cSQL += " 	AND D_E_L_E_T_ = '' "		

	cSQL += " 	UNION ALL "

	cSQL += " 	SELECT A1_PRICOM "
	cSQL += " 	FROM "+ RetFullName("SA1", "05")
	cSQL += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " 	AND A1_COD = " + ValToSQL(cCustomer)
	cSQL += " 	AND D_E_L_E_T_ = '' "		

	cSQL += " 	UNION ALL "

	cSQL += " 	SELECT A1_PRICOM "
	cSQL += " 	FROM "+ RetFullName("SA1", "07")
	cSQL += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " 	AND A1_COD = " + ValToSQL(cCustomer)
	cSQL += " 	AND D_E_L_E_T_ = '' "		

	cSQL += "	) _SA1 "
	cSQL += "	WHERE A1_PRICOM <> '' "

	TcQuery cSQL New Alias (cQry)
	
	lRet := !Empty((cQry)->A1_PRICOM)

	(cQry)->(DbCloseArea())

Return(lRet)


Method MaxRisk() Class TProcessoRocket
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT MAX(A1_RISCO) AS A1_RISCO "
	cSQL += " FROM "+ RetSQLName("SA1")
	cSQL += " WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND A1_CGC IN "
	cSQL += " ( "
	cSQL += " 	SELECT ZM1_CNPJ "
	cSQL += " 	FROM " + RetSQLName("ZM1")
	cSQL += " 	WHERE ZM1_FILIAL = " + ValToSQL(xFilial("ZM1"))
	cSQL += " 	AND ZM1_CODPRO = " + ValToSQL(::cCodPro)
	cSQL += " 	AND ZM1_TIPINT = '2' "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND D_E_L_E_T_ = ''	
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := (cQry)->A1_RISCO

	(cQry)->(DbCloseArea())

Return(cRet)