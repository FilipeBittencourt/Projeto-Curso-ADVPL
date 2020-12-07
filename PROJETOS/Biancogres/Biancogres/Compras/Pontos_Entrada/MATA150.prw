#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"  

User Function MATA150()
	Local aArea			:= GetArea()
	Local cCotacao 		:= ''//SC8->C8_NUM
	Local cXlmBiz		:= ''
	Local nProcBiz  	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C8_YPRCBIZ" } )
	Local lFornDel		:= (Len(aCols)==1) .And. (Acols[1][Len(aHeader)+1])
	Local nCont 
	Private cProcBiz 	:= ''
	Private cTaskBiz 	:= ''
	Private Ws

	// Tiago Rossini Coradini - 29/03/16 - OS: 0784-16 - Luana Marin - Ajuste na criação de processo no Bizagi ao adicionar novo participante em cotação
	If l150Inclui

		If MsgYesNo("Deseja enviar o e-mail para o novo participante da cotação?" + Chr(13) + Chr(10) +; 
		"Participante: " + SC8->C8_FORNECE + "-" + SC8->C8_LOJA + " - " + Capital(AllTrim(Posicione("SA2", 1, xFilial("SA2") + SC8->(C8_FORNECE + C8_LOJA), "A2_NOME"))))

			ExecBlock("MT131WF",.F.,.F.,{SC8->C8_NUM, SC8->C8_FORNECE, SC8->C8_LOJA})

		EndIf

	ElseIf l150Deleta .Or. lFornDel

		oWS := WSWorkflowEngineSOA():New()

		nCont := 0
		For nCont := 1 To Len(aCols)
			cProcBiz := aCols[nCont][nProcBiz]
			CancelProc(cProcBiz)	
		Next 

	EndIf

	RestArea(aArea)
Return


Static Function CancelProc(cProc)

	/*
	Operações WS BIZAGI
	4 - Gera Cotacao
	5 - Deleta
	*/

	If oWS != NIL
		If IsInCallStack("A150Digita") .And. !l150Inclui .And. !Altera

			cXlmBiz := U_GetXmlBiz('5',cProcBiz)

			lEnviou := .F.
			While !lEnviou
				IncProc('Gerando a cotação no Bizagi...')
				oResult := oWS:performActivityAsString(cXlmBiz)
				lEnviou := (oResult != NIL)

				//Caso não tenha enviado.
				If !lEnviou
					IncProc('Não foi possível comunicar com o Bizagi! Nova tentativa em 10 seg...')
					Sleep(10*1000)// espera 10 segundos para a proxima tentativa...	
				EndIf
			End
		EndIf
	EndIf

Return


User Function GetXmlBiz(cOper,cProcBiz)
	Local cXmlRet := ""

	cXmlRet += "<BizAgiWSParam>										"
	cXmlRet += "  <domain>FORNECEDOR</domain>                       "
	cXmlRet += "  <userName>fornecedor01</userName>                 "
	cXmlRet += "  <ActivityData>                                    "
	cXmlRet += "    <radNumber>"+cProcBiz+"</radNumber>             "
	cXmlRet += "    <taskName>AtvPreencherCotacao</taskName>        "
	cXmlRet += "  </ActivityData>                                   "
	cXmlRet += "  <ActivityData>                                    "
	cXmlRet += "    <radNumber>"+cProcBiz+"</radNumber>             "
	cXmlRet += "    <taskName>AtvVerificarLicenca</taskName>        "
	cXmlRet += "  </ActivityData>                                   "
	cXmlRet += "  <Entities>                                        "
	cXmlRet += "  	<SolicitarCotacao>                  			"
	cXmlRet += "    	<Status>"+cOper+"</Status>   				"
	cXmlRet += "    </SolicitarCotacao>                 			"
	cXmlRet += "  </Entities>                                       "
	cXmlRet += "</BizAgiWSParam>                                    "

Return cXmlRet
//-----------------------------------------------------------------------------