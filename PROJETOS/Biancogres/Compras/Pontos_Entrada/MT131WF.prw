#include "protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "apwebsrv.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT131WF   ºAutor  ³ZAGO                º Data ³  03/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PONTO DE ENTRADA NA ROTINA DE GERAR COTACOES               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION MT131WF
	LOCAL aArea     	:= GetArea()
	LOCAL cUserMail		:= UsrRetMail(RetCodUsr())
	LOCAL cFornMail 	:= ""
	LOCAL cSC8      	:= GetNextAlias()
	LOCAL TabSC8    	:= RetSqlName("SC8")
	LOCAL cWhere    	:= ""
	LOCAL cSuporte  	:= ""
	Local oObjCot     := Nil
	Private cCotacao	:= ParamIxb[1]
	Private cFornece  := ''
	Private cLoja	  	:= ''
	Private cIdProces	:= ''
	Private cErroBiz 	:= ''

	IF LEN(ParamIxb) == 3
		cFornece  	:= ParamIxb[2]
		cLoja	  	:= ParamIxb[3]
	EndIf

	dbSelectArea("SM0")
	dbSeek(cEmpAnt+cFilAnt,.T.)

	cWhere += "%"
	IF LEN(ParamIxb) == 3
		cWhere += " AND C8_FORNECE = "+ValToSql(ParamIxb[2])
		cWhere += " AND C8_LOJA = "+ValToSql(ParamIxb[3])
	ENDIF
	cWhere += "%"



	BEGINSQL ALIAS cSC8
		SELECT C8_FILIAL, C8_FORNECE, C8_LOJA, C8_YPRCBIZ, C8_VALIDA
		FROM %TABLE:SC8% SC8
		WHERE C8_FILIAL = %XFILIAL:SC8%
		AND C8_NUM    = %EXP:cCotacao%
		AND SC8.%NotDel%
		%Exp:cWhere%
		GROUP BY C8_FILIAL, C8_FORNECE, C8_LOJA, C8_YPRCBIZ, C8_VALIDA
	ENDSQL

	SET CENTURY ON

	WHILE !(cSC8)->(EOF())
		cFornMail := POSICIONE("SA2",1,XFILIAL("SA2")+(cSC8)->(C8_FORNECE+C8_LOJA),"A2_EMAIL")
		IF EMPTY(POSICIONE("SE4",1,XFILIAL("SE4")+SA2->A2_COND,"E4_YDESC")) .AND. SE4->(FOUND())
			RecLock("SE4",.F.)
			SE4->E4_YDESC := SE4->E4_DESCRI
			MsUnlock()
		ENDIF
		IF !EMPTY(cFornMail)

			lBizagi := .T.

			_cTipo := POSICIONE("SC1", 5, XFILIAL("SC1")+cCotacao, "C1_YTIPO")
			If (AllTrim(_cTipo) $ '1_2')//quando vem do portal esse campo e preenchido
				lBizagi := .F.
			EndIf


			If lBizagi

				IncProc('Gerando a cotação no Bizagi...')
				If !EMPTY((cSC8)->C8_YPRCBIZ)

					//CancelarCotacaoNoBizagiId -> Primeiro Cancela a cotação no bizagi para gerar a mesma do protheus apenas com outro código bizagi
					oObjCot := TBizagiIntegracaoCotacao():New()

					If !oObjCot:CancelarCotacaoNoBizagiId((cSC8)->C8_YPRCBIZ)
						MsgBox('Houve um problema na comunicação do processo de geração da cotação do BIZAGI.' ,'ERRO', 'STOP'  )
						RETURN .F.
					EndIf

				EndIf

				cIdProces := U_BIAB002((cSC8)->C8_FORNECE, (cSC8)->C8_LOJA)

			Else

				cAssunto := RTRIM(SM0->M0_NOMECOM)+" - Cotação Num. "+cCotacao
				cBody    := MemoRead("\workflow\cotacao\modelo_email.html")
				cBody    := FormatMail(cBody, cSC8, cCotacao, cUserMail)
				Notifica(cFornMail, cUserMail, cSuporte, cAssunto, cBody)
			EndIf

			cSQL := "UPDATE "+TabSC8+CRLF
			cSQL += "   SET  C8_YEMAIL = "+ValToSql(cUserMail)+","+CRLF

			If Alltrim(GetSrvProfString("RpoVersion","")) == "120"
				cSQL += "        C8_OBS = CONVERT(VARBINARY(MAX),' '),"+CRLF
			Else
				cSQL += "        C8_OBS = ' ',"+CRLF
			EndIf

			cSQL += "        C8_YTPPSS   = "+ValToSql(_cTipo)+","+CRLF

			cSQL += "        C8_YFLAG   = ' ',"+CRLF
			cSQL += "        C8_YMARCA  = ' ',"+CRLF
			cSQL += "        C8_YDATCHE = ' ',"+CRLF
			cSQL += "        C8_YCOND   = ' ',"+CRLF
			cSQL += "        C8_YFINAL  = ' '"+CRLF

			If lBizagi
				cSQL += "		 ,C8_YPRCBIZ = "+ValToSql(cIdProces)+CRLF
			EndIf

			cSQL += " WHERE  C8_FILIAL = "+ValToSql(xFilial("SC8"))+CRLF
			cSQL += "   AND     C8_NUM = "+ValToSql(cCotacao)+CRLF
			cSQL += "   AND C8_FORNECE = "+ValToSql(SA2->A2_COD)+CRLF
			cSQL += "   AND    C8_LOJA = "+ValToSql(SA2->A2_LOJA)+CRLF
			cSQL += "   AND D_E_L_E_T_ = ' '"

			TCSQLEXEC(cSQL)


			TCREFRESH(TabSC8)
		ENDIF

		(cSC8)->(DBSKIP())
	ENDDO

	SET CENTURY OFF
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOTIFICA  ºAutor  ³ZAGO                º Data ³  03/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ROTINA PARA ENVIO DE EMAIL VIA JOB                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION Notifica(cDest, cCC, cCCO, cTitulo, cBody)
	LOCAL lHTML      := .T.

	U_BIAEnvMail(,cDest,cTitulo,cBody,,,,cCC)
	//STARTJOB( "U_JBSENDMAIL", GetEnvServer(), .F., {cEmpAnt ,cFilAnt ,lHTML, cBody, cTitulo, cRemetente, cDest,cCC,cCCO})
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GETUSRMAILºAutor  ³ZAGO                º Data ³  03/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RETORNA O EMAIL DO USUARIO A PARTIR DO CADASTRO DO SIGAPSS º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GetUsrMail
	LOCAL cUserMail := ""

	//PswOrder(1)
	PswOrder(2)
	//PswSeek(RetCodUsr())
	PswSeek(UsrRetName(RetCodUsr()))
	cUserMail := AllTrim(PswRet()[1][14])
RETURN cUserMail

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FORMATMAILºAutor  ³ZAGO                º Data ³  03/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FORMATA O CORPO DO EMAIL COM BASE NO ARQUIVO DE MODELO     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION FormatMail(cBody, cSC8, cCotacao, cUserMail)
	LOCAL cStatus:= ""
	LOCAL nDias  := 4
	cBody := STRTRAN(cBody,"!numero!", cCotacao)
	cBody := STRTRAN(cBody,"!datahora!", DTOC(Date())+" - "+LEFT(Time(),5))
	cPrazo:= "N"//""POSICIONE("SC1",1,XFILIAL("SC1")+(cSC8)->C8_NUMSC,"C1_YSTATUS")
	IF cPrazo == "N"
		nDias   := 7
		cStatus := "NORMAL"
	ELSEIF cPrazo == "U"
		nDias := 1
		cStatus := "URGENTE"
	ELSEIF cPrazo == "E"
		nDias := 0
		cStatus := "EMERGENCIA"
	ELSEIF cPrazo == "P"
		nDias := 0
		cStatus := "PARADA"
	ENDIF

	// NUMERO DE DIAS MAXIMO = 2, DEFINIDO PELA CLAUDIA
	nDias := 2

	cPrazo:= DTOC(DataValida(Date()+nDias))+" - "+LEFT(Time(),5)

	cBody := STRTRAN(cBody,"!prazo!", cPrazo)
	cBody := STRTRAN(cBody,"!status!", cStatus)
	IF EMPTY(SA2->A2_YSHA1)
		RECLOCK("SA2",.F.)
		SA2->A2_YSHA1 := GeraHash(SA2->(A2_COD+A2_LOJA))
		MSUNLOCK()
	ENDIF

	If cEmpAnt == "01"
		cEmailXML := "nf-e.biancogres@biancogres.com.br "
	ElseIf cEmpAnt == "05"
		cEmailXML := "nf-e.incesa@incesa.ind.br "
	ElseIf cEmpAnt == "07"
		cEmailXML := "nf-e.lmcomercio@biancogres.com.br "
	ElseIf cEmpAnt == "12"
		cEmailXML := "nf-e.stgestao@biancogres.com.br "
	ElseIf cEmpAnt == "13"
		cEmailXML := "nf-e.mundi@biancogres.com.br "
	Else
		cEmailXML := "nf-e.biancogres@biancogres.com.br "
	EndIf

	cBody := STRTRAN(cBody,CRLF,"")
	cBody := STRTRAN(cBody,"!link!", SA2->A2_YSHA1)
	cBody := STRTRAN(cBody,"!emp!", cEmpAnt)
	cBody := STRTRAN(cBody,"!razaoComprador!", CAPITAL(ALLTRIM(UPPER(SM0->M0_NOMECOM))))
	cBody := STRTRAN(cBody,"!razaoFornecedor!", CAPITAL(ALLTRIM(UPPER(SA2->A2_NOME))))
	cBody := STRTRAN(cBody,"!cnpjComprador!", ALLTRIM(SM0->M0_CGC))
	cBody := STRTRAN(cBody,"!cnpjFornecedor!", ALLTRIM(SA2->A2_CGC))
	cBody := STRTRAN(cBody,"!endComprador!", CAPITAL(ALLTRIM(SM0->M0_ENDENT)))
	cBody := STRTRAN(cBody,"!endFornecedor!", CAPITAL(ALLTRIM(SA2->A2_END)))
	cBody := STRTRAN(cBody,"!munComprador!", CAPITAL(ALLTRIM(SM0->M0_CIDENT)))
	cBody := STRTRAN(cBody,"!munFornecedor!", CAPITAL(ALLTRIM(SA2->A2_MUN)))
	cBody := STRTRAN(cBody,"!estComprador!", ALLTRIM(SM0->M0_ESTENT))
	cBody := STRTRAN(cBody,"!estFornecedor!", ALLTRIM(SA2->A2_EST))
	cBody := STRTRAN(cBody,"!cepComprador!", ALLTRIM(SM0->M0_CEPENT))
	cBody := STRTRAN(cBody,"!cepFornecedor!", ALLTRIM(SA2->A2_CEP))
	cBody := STRTRAN(cBody,"!paisComprador!", "BRASIL")
	cBody := STRTRAN(cBody,"!paisFornecedor!", ALLTRIM(POSICIONE("CCH",1,XFILIAL("CCH")+SA2->A2_CODPAIS,"CCH_PAIS")))
	cBody := STRTRAN(cBody,"!nomeContato!", CAPITAL(ALLTRIM(UsrFullName(RetCodUsr()))))
	cBody := STRTRAN(cBody,"!nomeFornecedor!", CAPITAL(ALLTRIM(SA2->A2_CONTATO)))
	cBody := STRTRAN(cBody,"!emailContato!", ALLTRIM(cUserMail))
	cBody := STRTRAN(cBody,"!emailFornecedor!", ALLTRIM(SA2->A2_EMAIL))
	cBody := STRTRAN(cBody,"!telContato!", ALLTRIM(SM0->M0_TEL))
	cBody := STRTRAN(cBody,"!telFornecedor!", ALLTRIM(SA2->A2_TEL))
	cBody := STRTRAN(cBody,"!ramal!", ALLTRIM(GetUsrRamal()))
	cBody := STRTRAN(cBody,"!emailXML!", cEmailXML)
RETURN cBody

//USER FUNCTION MTA160MNU
//aAdd(aRotina, {"Env.Email","U_REENVIAEML" , 0 , 2, 0, nil})
//aadd(aRotina, {"Portal WebSC","U_A130WEB",0,6,0,nil})
//RETURN

USER FUNCTION REENVIAEML
	LOCAL cNum     := SC8->C8_NUM
	LOCAL cFornece := SC8->C8_FORNECE
	LOCAL cLoja    := SC8->C8_LOJA
	Local i

	IF EXISTBLOCK("MT131WF") .And. MsgYesNo("Confirma envio de email para Fornecedor?")
		U_BIAMsgRun(,,{|| EXECBLOCK("MT131WF",.F.,.F.,{cNum, cFornece, cLoja})})
	ELSE
		MsgInfo("Rotina de envio de email da cotação cancelada ou desabilitada.")
	ENDIF
RETURN


STATIC FUNCTION GeraHash(cCode)
	LOCAL nSeed := Randomize(500,10000)
	Local i

	FOR i := 1 TO nSeed
		cCode := SHA1(cCode)
	NEXT i

RETURN cCode

STATIC FUNCTION getUsrRamal
	LOCAL cRamal := ""

	psworder(1)
	pswseek(__cUserId)
	cRamal := PswRet()[1][20]

RETURN cRamal

//----------------------------------------------------------------------------------------
// Autor: Thiago Dantas
// Data	: 07/04/2015
// Desc	: Gera Processo no Bizagi
//----------------------------------------------------------------------------------------
User Function BIAB002(pFornece,pLoja)
	Local cRet := ''
	Private cFornCot := pFornece
	Private cLojaCot := pLoja

	// Testa Envio de Xml para o bizagi.

	If AllTrim(UPPER(GetEnvServer())) == "PRODUCAO"
		cRet := GeraProcBZ()
	EndIf


Return cRet


Static Function GeraProcBZ()
	Local oWS
	Local oCotacao
	Local oResultado
	Local cXmlCot := ''
	Local cXmlRet := ''
	Local aXmlRet := {}
	Local oXmlRetCot

	Local cErro := ''
	Local cAviso := ''
	Local Enter := CHR(13) + CHR(10)

	oWS := WSWorkflowEngineSOA():New()

	cXmlCot := cGetXmlCot()

	If oWs != Nil
		lEnviou := .F.
		While !lEnviou
			IncProc('Gerando a cotação no Bizagi...')
			oResult := oWS:createCasesAsString(cXmlCot)

			CONOUT("COTAÇÃO BIZAGI-------------------------------")
			CONOUT(__cUserId)
			CONOUT("COTAÇÃO BIZAGI-------------------------------")
			CONOUT(cXmlCot)
			CONOUT("COTAÇÃO BIZAGI-------------------------------")
			CONOUT(oResult)
			CONOUT("COTAÇÃO BIZAGI-------------------------------")

			lEnviou := (oResult != NIL)

			//Caso não tenha enviado.
			If !lEnviou
				IncProc('Não foi possível comunicar com o Bizagi! Nova tentativa em 10 seg...')
				Sleep(10*1000)// espera 10 segundos para a proxima tentativa...
			EndIf
		End

		If !Empty(oWs:ccreateCasesAsStringResult)

			cXmlRet 	:= EncodeUTF8(oWs:ccreateCasesAsStringResult)
			cIdProces 	:= ''

			CONOUT(cXmlRet)
			CONOUT("COTAÇÃO BIZAGI-------------------------------")

			If !Empty(cXmlRet)

				oXmlRetCot := XmlParser(cXmlRet,"_",@cErro,@cAviso)


				CONOUT("@cErro: "+cErro)
				CONOUT("@cAviso: "+cAviso)
				CONOUT(oXmlRetCot)
				CONOUT("COTAÇÃO BIZAGI-------------------------------")

				If oXmlRetCot != NIL
					oErroCode := oXmlRetCot:_PROCESSES:_PROCESS:_PROCESSERROR
					lErro 	  := .F.

					If oErroCode != NIL
						If !Empty(oErroCode:_ERRORCODE:TEXT)
							lErro := .T.
							CONOUT("Erro ao Gerar Processo no BIZAGI: "+oErroCode:_ERRORMESSAGE:TEXT)
							CONOUT("COTAÇÃO BIZAGI-------------------------------")
							MsgBox('Erro ao Gerar Processo no BIZAGI: '+oErroCode:_ERRORMESSAGE:TEXT,'ERRO', 'STOP'  )
						EndIf
					EndIf

					oProcNum := NIL

					If !lErro
						oProcNum  := oXmlRetCot:_Processes:_PROCESS:_PROCESSRADNUMBER
					EndIf

					If oProcNum != NIL .And. !lErro
						cIdProces := oProcNum:TEXT
					Else
						MsgBox('Houve um problema na geração da cotação do BIZAGI. '+Enter+cErro+Enter,'ERRO', 'STOP'  )
						CONOUT("[ ERRO COTACAO X BIZAGI] "+Time()+' - '+cErro+Enter+Enter)
						CONOUT("--------> (XML ENVIADO) : "+Enter +cXmlCot+Enter+Enter)
						CONOUT("--------> (XML RECEBIDO) : "+Enter +cXmlRet+Enter+Enter)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf


Return cIdProces


Static Function cGetXmlCot()
	Local aAreaAux 	:= GetArea()
	Local cXml 		:= ''
	Local cEmailComp:= UsrRetMail(RetCodUsr())
	Local cNomeComp := CAPITAL(ALLTRIM(UsrFullName(RetCodUsr())))
	Local cRamalComp:= ALLTRIM(GetUsrRamal())
	Local cCotNum 	:= cCotacao//'009412'
	Local cFornCod	:= ''
	Local cPrior	:= "N"
	LOCAL nDias  	:= 4
	Local cEmiss	:= cValToChar(YEAR(Date()))+'-'+cValToChar(MONTH(DATE()))+'-'+cValToChar(DAY(DATE()))+'T'+Time()
	Local dPrazo	:= DataValida(Date()+nDias)
	Local cPrazo	:= cValToChar(YEAR(dPrazo))+'-'+cValToChar(MONTH(dPrazo))+'-'+cValToChar(DAY(dPrazo))+'T'+Time()
	Local lTeste	:= .T.
	Private Enter	:= CHR(13) + CHR(10)


	cSQL := "SELECT C8_FORNECE, C8_LOJA, C8_NUMPRO, C8_ITEM, C8_PRODUTO, C1_DESCRI, C8_UM, C8_QUANT, C8_DATPRF, C8_NUMSC, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C8_OBS)),'') C8_OBS " + Enter
	cSQL +=	"FROM "+RetSqlName("SC8")+" SC8 INNER JOIN "+RetSqlName("SC1")+" SC1 ON " + Enter
	cSQL += "		C8_NUMSC	= C1_NUM 		AND	" + Enter
	cSQL += "		C8_PRODUTO  = C1_PRODUTO	AND	" + Enter
	cSQL += "		C8_ITEMSC   = C1_ITEM			" + Enter
	cSQL += " WHERE C8_FILIAL = "+ValToSql(xFilial("SC8"))+Enter
	cSQL += "   AND C8_NUM = "+ValToSql(cCotNum)+Enter
	cSQL += "	AND C8_FORNECE = "+ValToSql(cFornCot)+Enter
	cSQL += "	AND C8_LOJA = "+ValToSql(cLojaCot)+Enter
	cSQL += "   AND SC8.D_E_L_E_T_ = '' 	" + Enter
	cSQL += "   AND SC1.D_E_L_E_T_ = ''	 	" + Enter
	cSQL += "ORDER BY C8_FORNECE, C8_LOJA, C8_ITEM " + Enter
	TCQUERY CSQL ALIAS "TSC8" NEW
	dbSelectArea("TSC8")

	If !TSC8->(Eof())

		cXml := ""
		cXml += "<BizAgiWSParam>"

		//PARAMETROS PARA AMBIENTE DE PRODUCAO
		cXml += "<domain>DOMAIN</domain>"
		cXml += "<userName>admon</userName>"
		cXml += "<Cases>"

		While(!TSC8->(Eof()))

			cFornCod := TSC8->C8_FORNECE
			cFornLoja:= TSC8->C8_LOJA

			//dbSelectArea("SA2")
			//dbSeek(xFilial("SA2")+cFornCod+cFornLoja)


			cXml += "<Case>"
			cXml += "<Process>SolicitarCotacao</Process>"
			cXml += "<Entities>"
			cXml += "<SolicitarCotacao>"
			cXml += "<DataEnvio>"+cEmiss+"</DataEnvio>"
			cXml += "<TelefoneComprador>"+ALLTRIM(SM0->M0_TEL)+"</TelefoneComprador>"
			cXml += "<NomeComprador>"+cNomeComp+"</NomeComprador>"
			cXml += '<EmpresaCompradora entityName="VW_BZ_DADOS_EMPRESA">'
			cXml += "<Codigo>"+cEmpAnt+"</Codigo>"
			cXml += "</EmpresaCompradora>"
			cXml += "<EmailComprador>"+cEmailComp+"</EmailComprador>"
			cXml += "<PrazoFinal>"+cPrazo+"</PrazoFinal>"
			cXml += "<NumeroCotacao>"+cCotNum+"</NumeroCotacao>"
			cXml += "<RamalComprador>"+cRamalComp+"</RamalComprador>"
			cXml += '<Fornecedor entityName= "VW_BZ_FORNECEDOR">'
			cXml += "<Codigo>"+cFornCod+"</Codigo>"
			cXml += "<Loja>"+cFornLoja+"</Loja>"
			cXml += "</Fornecedor>"
			/* */
			cXml += "<CotacaoEmbalagem>false</CotacaoEmbalagem>"
			cXml += "<CotacaoTabelaPreco>false</CotacaoTabelaPreco>"
			cXml += "<CotacaoSolCotacao>true</CotacaoSolCotacao>"
			/* */ 
			cXml += "<NumSC>"+AllTrim(TSC8->C8_NUMSC)+"</NumSC>"
			cXml += '<PrioridadeCotacao>'
			cXml += cPrior
			cXml += "</PrioridadeCotacao>"
			cXml += "<ItensCotacao>"

			While cFornCod == TSC8->C8_FORNECE .And. (!TSC8->(Eof()))

				cXml += "<ItemCotacao>"

				//cXml += '<ProdutoCotacao entityName="VW_BZ_PRODUTO_COTACAO">'
				//cXml += "<EMPRESA>"+cEmpAnt+cFilAnt+"</EMPRESA>"
				//cXml += "<CODIGO>"+TSC8->C8_PRODUTO+"</CODIGO>"
				//cXml += "</ProdutoCotacao>"

				/*
				cXml += '<ProdCotacaoVirtualizado entityName="VW_BZ_VIRT_PROD_COT">'
				cXml += "<EMPRESA>"+cEmpAnt+cFilAnt+"</EMPRESA>"                                                                       
				cXml += "<CODIGO>"+TSC8->C8_PRODUTO+"</CODIGO>" 
				cXml += "</ProdCotacaoVirtualizado>"
				*/

				cXml += '<ProdCotacaoVirtualizado entityName="VW_BZ_VIRT_PROD_COT" businessKey="EMPRESA='
				cXml +=  "'"+cEmpAnt+cFilAnt+"' AND CODIGO= '"+TSC8->C8_PRODUTO+"'"+'" />'

				dEntrega := SToD(TSC8->C8_DATPRF)
				cEntrega := cValToChar(YEAR(dEntrega))+'-'+cValToChar(MONTH(dEntrega))+'-'+cValToChar(DAY(dEntrega))+'T'+Time()

				cXml += "<NumItem>" + TSC8->C8_ITEM + "</NumItem>"
				cXml += "<NumProposta>" + TSC8->C8_NUMPRO + "</NumProposta>"

				cXml += "<DatadeEntrega>" + cEntrega + "</DatadeEntrega>"
				cXml += "<DescricaoSC>" + TSC8->C1_DESCRI + "</DescricaoSC>"
				cXml += "<Quantidade>" + cValToChar(TSC8->C8_QUANT) + "</Quantidade>"
				cXml += "<ObservacaoComprador>" + TSC8->C8_OBS + "</ObservacaoComprador>"
				cXml += "</ItemCotacao>"

				TSC8->(DbSkip())
			End

			cXml += "</ItensCotacao>"
			cXml += "</SolicitarCotacao>"
			cXml += "</Entities>"
			cXml += "</Case>"

			//	TSC8->(DbSkip())
		End

		cXml += "</Cases>"
		cXml += "</BizAgiWSParam>"

		TSC8->(dbCloseArea())

	EndIf

	RestArea(aAreaAux)

Return cXml
