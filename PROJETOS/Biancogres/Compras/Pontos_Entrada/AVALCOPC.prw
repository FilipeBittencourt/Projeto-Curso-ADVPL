#include "protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AVALCOPC  ºAutor  ³ZAGO                º Data ³  03/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PONTO DE ENTRADA NA ROTINA DE GERAR COTACOES               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION AVALCOPC

	Local aArea := GetArea()

	DA120EMIS := SC7->C7_EMISSAO
	CA120NUM  := SC7->C7_NUM
	CA120FORN := SC7->C7_FORNECE
	CA120LOJ  := SC7->C7_LOJA
	U_WFW120P()
	
	If (!(Alltrim(FunName()) == 'MATA161' .And. AllTrim(SC8->C8_YTPPSS)=="1"))
		//Fernando em 29/06/2018 => Ticket 5309 => Envio de email para aprovação automatica
		IF SC7->C7_CONAPRO == "B" 
	
			dbSelectArea("ZC1")
			If ZC1->(FieldPos("ZC1_TIPDOC")) > 0
				U_FPFCRT01(SC7->C7_NUM)
			EndIf
	
		ENDIF
	EndIf
	RestArea(aArea)

RETURN   

USER FUNCTION MT160GRPC
	Local aArea	   := GetArea()
	Local aCotVenc := paramixb[1] //cotação vencedora
	Local aFornCot := paramixb[2] //fornecedores da cotação
	Local cFornVenc:= SC8->C8_FORNECE 
	Local cFornLoja:= SC8->C8_LOJA
	Local cProcBiz := SC8->C8_YPRCBIZ
	Local cNumCot  := SC8->C8_NUM	
	Local nCont
	Local nCot

	If !Empty(cProcBiz)

		nCot := 0
		For nCot := 1 To Len(aFornCot)
			aCotAux := aFornCot[nCot]

			nCont:= 0
			For nCont:= 1 To Len(aCotAux)

				aCotProFor := aCotAux[nCont]

				nFornAux 	:= aScan( aCotProFor, { |x| AllTrim( x[1] ) == "C8_FORNECE" } )
				nLojanAux 	:= aScan( aCotProFor, { |x| AllTrim( x[1] ) == "C8_LOJA" } )

				cFornAux 	:= aCotProFor[nFornAux][2]
				cLojaAux 	:= aCotProFor[nLojanAux][2]	

				If !Empty(cFornAux) .And. !Empty(cLojaAux)  .And. !(AllTrim(cFornAux) == AllTrim(cFornVenc) .And. AllTrim(cFornLoja) ==  AllTrim(cLojaAux))
					//Notifica o Bizagi
					NotFimBiz(cNumCot, cFornAux, cLojaAux)
				EndIf

			Next
		Next
	EndIf	

	//CA120NUM       := SC7->C7_NUM
	SC7->C7_YEMAIL := "N"
	//SC7->C7_APROV  := U_MT120APV()
	RestArea(aArea)	         
RETURN
//---------------------------------------------------------
Static Function NotFimBiz(pCot,pForn,pLoja)
	Local aArea := GetArea()
	Local oWs

	dbSelectArea('SC8')
	dbSetOrder(1)

	cProcBiz := POSICIONE("SC8",1,XFILIAL("SC8")+pCot+pForn+pLoja,"C8_YPRCBIZ")
	If !Empty(cProcBiz)

		cXlmBiz := U_GetXmlBiz('4',cProcBiz)

		oWS := WSWorkflowEngineSOA():New()

		If oWS != NIL 
			lEnviou := .F.
			While !lEnviou
				IncProc('Notificando o Bizagi...')
				oResult := oWS:performActivityAsString(cXlmBiz)
				lEnviou := (oResult != NIL)

				//Caso não tenha enviado.
				If !lEnviou
					IncProc('Não foi possível comunicar com o Bizagi! Nova tentativa em 10 seg...')
					Sleep(10*1000)// espera 10 segundos para a proxima tentativa...	
				EndIf
			End
		EndIf
	EndIF

	RestArea(aArea)
Return  
//---------------------------------------------------------
