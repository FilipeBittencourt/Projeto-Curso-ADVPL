#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAprovaPedidoCompraEMail
@author Fernando Rocha
@since 27/07/2017
@version 1.0
@description Classe para controle de aprovação de pedidos de compra por e-mail - baseado no TAprovaPedidoVendaEMail
@type class
/*/

Class TAprovaPedidoCompraEMail From LongClassName	

	Data cNumPed
	Data cCodApr
	Data cEmpPed
	Data cFilPed
	Data cEmailApr
	Data cCodAprT
	Data cEmailAprT
	Data nRecMaster

	Data oServidor
	Data oMensagem
	Data cServidor
	Data cSrvPOP
	Data cConta
	Data cSenha
	Data cEmail
	Data cIDMsg
	Data cAction
	Data cContaRec
	Data cSenhaRec
	Data cPtSMTP
	Data cPtPOP3
	Data lUseTLS
	Data lUseSSL
	Data lUseAut


	Method New() Constructor
	Method Inclui()
	Method Exclui()
	Method Atualiza()
	Method Existe()
	Method Aprova()
	Method Recusar()
	Method Envia()
	Method Recebe()
	Method RecebeManual(_cIDMSG, _cACTION)
	Method Valida()
	Method RetEMailApr()
	Method RetNomFor()
	Method RetHtml()
	Method RetIDMsg()
	Method RetHtmlBody()
	Method SetEmpresa()

	Method EnviaPendentes()
	Method GeraChPend()
	Method HtmlPend()
	Method SendPend()
	Method AprTodos()
	Method RecTodos()
	Method RetSol(cMat, cSolEmp)

	Method EnvConfirmacao()
	Method HtmlConfirm()

EndClass


Method New() Class TAprovaPedidoCompraEMail

	::cNumPed := ""
	::cCodApr := ""
	::cEmailApr := ""
	::cCodAprT := ""
	::cEmailAprT := ""	
	::nRecMaster := 0
	::cEmpPed := ""
	::cFilPed := ""

	::oServidor := TMailManager():New()
	::oMensagem := TMailMessage():New()
	
	::cServidor	:= SubStr(GetMv("MV_RELSERV"),1,RAT(':',GetMv("MV_RELSERV"))-1)
	::cSrvPOP	:= SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)
	::cConta 	:= GetMv("MV_YPCCTAP")
	::cSenha 	:= GetMv("MV_YPCSNAP")
	::cEmail 	:= GetMv("MV_YPCCTAP")
	::lUseTLS 	:= GetMv("MV_RELTLS")
	::lUseSSL 	:= GetMv("MV_RELSSL")
	::lUseAUT 	:= GetMv("MV_RELAUTH")
	::cPtSMTP   := Val(SubStr(GetMv("MV_RELSERV"),RAT(':',GetMv("MV_RELSERV"))+1,Len(Alltrim(GetMv("MV_RELSERV")))))    
	::cPtPOP3   := Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP")))))   
	

	::cContaRec := GetMv("MV_YPCCTAP")
	::cSenhaRec := GetMv("MV_YPCSNAP")

	::cIDMsg := ""
	::cAction := ""

Return()

Method SetEmpresa() Class TAprovaPedidoCompraEMail 

	If AllTrim(cEmpAnt) <> ::cEmpPed 

		RpcClearEnv()

		RpcSetType(3)
		RpcSetEnv(::cEmpPed, ::cFilPed)

	EndIf

Return()

Method Inclui() Class TAprovaPedidoCompraEMail 

	If ::Existe()

		::Exclui()

	EndIf

	RecLock("ZC1", .T.)

	ZC1->ZC1_FILIAL	:= xFilial("ZC1")
	ZC1->ZC1_EMP 	:= cEmpAnt
	ZC1->ZC1_FIL 	:= cFilAnt
	ZC1->ZC1_PEDIDO	:= ::cNumPed
	ZC1->ZC1_APROV 	:= ::cCodApr
	ZC1->ZC1_EMAIL 	:= ::cEmailApr
	ZC1->ZC1_APROVT := ::cCodAprT
	ZC1->ZC1_EMAILT := ::cEmailAprT
	ZC1->ZC1_CHAVE 	:= ::cIDMsg		
	ZC1->ZC1_DATENV := dDataBase
	ZC1->ZC1_STATUS := "E"

	If ZC1->(FieldPos("ZC1_TIPDOC")) > 0
		ZC1->ZC1_TIPDOC := "PC"
	EndIf

	ZC1->(MsUnlock())

Return()


Method Exclui() Class TAprovaPedidoCompraEMail

	RecLock("ZC1", .F.)

	ZC1->(DbDelete())

	MsUnlock()

Return()


Method Atualiza() Class TAprovaPedidoCompraEMail

	If ::Existe()

		RecLock("ZC1", .F.)

		ZC1->ZC1_DATREC := dDataBase
		ZC1->ZC1_STATUS := "R"

		ZC1->(MsUnlock())

	EndIf

Return()


Method Existe() Class TAprovaPedidoCompraEMail

	Local lRet := .F.

	DbSelectArea("ZC1")
	DbSetOrder(1)
	lRet := ZC1->(DbSeek(xFilial("ZC1") + ::cIDMsg)) .And. ZC1->ZC1_TIPDOC == "PC"

	If !lRet

		lRet := ZC1->(DbSeek(xFilial("ZC1") + ::cIDMsg)) .And. ZC1->ZC1_TIPDOC == "MC"

	EndIf

Return(lRet)


Method Aprova() Class TAprovaPedidoCompraEMail

	::SetEmpresa()

	BEGIN TRANSACTION

		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7") + ::cNumPed)) .And. SC7->C7_CONAPRO == "B"

			While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed

				RecLock("SC7", .F.)
				SC7->C7_CONAPRO := "L"
				SC7->(MsUnLock())

				SC7->(DbSkip())

			EndDo()
			
			DbSelectArea("SCR")
			DbSetOrder(1)
			If DbSeek(xFilial("SCR")+"PC"+::cNumPed)
				While !SCR->(Eof()) .And. SCR->CR_FILIAL == cFilAnt .And. AllTrim(SCR->CR_NUM) == AllTrim(::cNumPed)
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

			::Atualiza()

			//email de confirmacao para comprador
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(xFilial("SC7") + ::cNumPed))

				::EnvConfirmacao()

				// Avalia se envia e-mail automatico
				U_BIAF091(AllTrim(::cNumPed), "A")

				SCR->(DbSetOrder(1))  //CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL, R_E_C_N_O_, D_E_L_E_T_
				If SCR->(DbSeek(XFilial("SCR")+"PC"+::cNumPed))
					// Alteração automática das datas de entrega e de chegada apos aprovação do pedido
					U_BIAF093(AllTrim(::cNumPed), SCR->CR_YDTINCL, SCR->CR_DATALIB)
				EndIf

			EndIf

			ConOut( "TAprovaPedidoCompraEMail:Envia() => PEDIDO "+::cNumPed+" Aprovado com sucesso." )

		Else
			ConOut( "TAprovaPedidoCompraEMail:Envia() => PEDIDO "+::cNumPed+" Nao encontrado ou já foi aprovado." )
		EndIf

	END TRANSACTION

Return()


Method AprTodos() Class TAprovaPedidoCompraEMail

	Local __cAliasApr
	Local _nMaster := ::nRecMaster

	::SetEmpresa()

	IF _nMaster > 0

		__cAliasApr := GetNextAlias()

		BeginSql Alias __cAliasApr

			select REC = R_E_C_N_O_, ZC1_PEDIDO, ZC1_CHAVE from %Table:ZC1% where ZC1_RECGR = %Exp:_nMaster% and D_E_L_E_T_ = ''

		EndSql

		IF !(__cAliasApr)->(Eof())

			While !(__cAliasApr)->(Eof())

				ZC1->(DbSetOrder(0))
				ZC1->(DbGoTo((__cAliasApr)->REC))
				If !ZC1->(Eof()) .And. ZC1->ZC1_TIPDOC == "MC"

					::cNumPed := (__cAliasApr)->ZC1_PEDIDO
					::cIDMsg := (__cAliasApr)->ZC1_CHAVE 

					::Aprova()

				EndIf

				(__cAliasApr)->(DbSkip())
			EndDo

		ENDIF

		(__cAliasApr)->(DbCloseArea())

	ENDIF

Return


Method Recusar() Class TAprovaPedidoCompraEMail

	::SetEmpresa()

	BEGIN TRANSACTION

		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7") + ::cNumPed))

			While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed

				RecLock("SC7", .F.)
				SC7->C7_CONAPRO := "R"
				SC7->(MsUnLock())

				SC7->(DbSkip())

			EndDo()
			
			DbSelectArea("SCR")
			DbSetOrder(1)
			If DbSeek(xFilial("SCR")+"PC"+::cNumPed)
				While !SCR->(Eof()) .And. SCR->CR_FILIAL == cFilAnt .And. AllTrim(SCR->CR_NUM) == AllTrim(::cNumPed)
					While !Reclock("SCR",.F.);EndDo		
					SCR->CR_STATUS := '04'
					SCR->CR_DATALIB := dDataBase 
					SCR->CR_USERLIB := SCR->CR_USER 
					SCR->CR_VALLIB := SCR->CR_TOTAL 
					SCR->CR_LIBAPRO := SCR->CR_APROV
					MsUnlock()
							
					SCR->(DbSkip())
				EndDo
			EndIf

			::Atualiza()

		EndIf

	END TRANSACTION

Return()


Method RecTodos() Class TAprovaPedidoCompraEMail

	Local cAliasTmp
	Local _nMaster := ::nRecMaster

	IF _nMaster > 0

		cAliasTmp := GetNextAlias()

		BeginSql Alias cAliasTmp

			select REC = R_E_C_N_O_, ZC1_PEDIDO, ZC1_CHAVE from %Table:ZC1% where ZC1_RECGR = %Exp:_nMaster% and D_E_L_E_T_ = ''

		EndSql

		IF !(cAliasTmp)->(Eof())

			While !(cAliasTmp)->(Eof())

				ZC1->(DbSetOrder(0))
				ZC1->(DbGoTo((cAliasTmp)->REC))
				If !ZC1->(Eof()) .And. ZC1->ZC1_TIPDOC == "MC"

					::cNumPed := (cAliasTmp)->ZC1_PEDIDO
					::cIDMsg := (cAliasTmp)->ZC1_CHAVE 

					::Recusar()

				EndIf

				(cAliasTmp)->(DbSkip())
			EndDo

		ENDIF

		(cAliasTmp)->(DbCloseArea())

	ENDIF

Return


Method Envia() Class TAprovaPedidoCompraEMail

	//TICKET 23728 - ocorreu alguma mudanca no servidor de email que passou a nao aceitar poerta 25 - mudando para 587	
	::oServidor:SetUseTLS(::lUseTLS)
	::oServidor:SetUseSSL(::lUseSSL)

	::oServidor:Init("", ::cServidor, ::cConta, ::cSenha, 0, ::cPtSMTP)		

	::oServidor:SetSmtpTimeOut(60)

	If ::oServidor:SmtpConnect() == 0

		If ::lUseAUT 
			_nErro := ::oServidor:SmtpAuth(::cConta, ::cSenha)
		Else
			_nErro := 0
		EndIf
		
		If _nErro == 0

			::cIDMsg := Upper(HMAC(cEmpAnt + cFilAnt + ::cNumPed, "Bi@nCoGrEs", 1))

			::oMensagem := TMailMessage():New()
			::oMensagem:Clear() 

			::cEmailApr := UsrRetMail(::cCodApr)
			::cEmailAprT := UsrRetMail(::cCodAprT)

			::oMensagem:cFrom := ::cEmail
			
			If Upper(AllTrim(getenvserver())) $ "COMP-FERNANDO"			
				::oMensagem:cTo := "fernando@facilesistemas.com.br"
			ElseIf Upper(AllTrim(getenvserver())) $ "COMP-RANISSES"
				::oMensagem:cTo := "ranisses@outlook.com"
			Else
				::oMensagem:cTo := ::RetEmailApr()
			EndIf
			::oMensagem:cCc	 := ""
			::oMensagem:cBcc := ""
			::oMensagem:cSubject := "Pedido de Compra: " + ::cNumPed + " - Fornecedor: " + ::RetNomFor() 			
			::oMensagem:cBody := ::RetHtml()

			_nErro := ::oMensagem:Send( ::oServidor )
			
			If( _nErro != 0 )

				ConOut( "TAprovaPedidoCompraEMail:Envia() => ERRO ao enviar e-mail: " + ::oServidor:GetErrorString( _nErro ) )

			Else

				ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoCompraEMail:Envia() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " -- Email: " + ::oMensagem:cTo)
				::Inclui()

			EndIf
		
		Else
		
			ConOut( "TAprovaPedidoCompraEMail:Envia() => ERRO ao autenticar: " + str(_nErro,6), ::oServidor:GetErrorString( _nErro ) ) 
		
		EndIf

		::oServidor:SmtpDisconnect()

	EndIf

Return()


Method Recebe() Class TAprovaPedidoCompraEMail

	Local nMsg := 0
	Local nTotMsg := 0 
	
	::oServidor:SetUseSSL(::lUseSSL)

	::oServidor:Init(::cSrvPOP, "", ::cContaRec, ::cSenhaRec, ::cPtPOP3, 0) 

	ConOut( "TAprovaPedidoCompraEMail:Recebe() => Iniciando conexão com "+::cSrvPOP+", "+::cContaRec+" " )

	_nRet := ::oServidor:PopConnect()	

	If (_nRet == 0)

		::oServidor:GetNumMsgs(@nTotMsg)	  

		For nMsg := 1 To nTotMsg

			::oMensagem:Clear()

			::oMensagem:Receive(::oServidor, nMsg)	    	    	     	    	    

			ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoCompraEMail:Recebe()")

			//recuperar chave da mensagem
			::cIDMsg := ::RetIDMsg()

			//se for mensagem de pre-nota ignorar
			//_oAPC := TAprovaPreNotaEMail():New()
			//_oAPC:cIDMsg := ::cIDMsg
			//If _oAPC:Existe()
			//	loop
			//EndIf

			If ::Valida()

				ConOut( "TAprovaPedidoCompraEMail:Recebe() => Recebendo mensagem ID = "+AllTrim(::cIDMsg)+", ACTION = "+AllTrim(::cAction)+" " )

				If ::cAction == "RECUSA"

					::Recusar()

				ElseIf ::cAction == "APROVA"

					::Aprova()

				ElseIf ::cAction == "APRALL"

					::AprTodos()

				ElseIf ::cAction == "RECALL"

					::RecTodos()

				EndIf

			EndIf

			::oServidor:DeleteMsg(nMsg)	    

		Next

		::oServidor:POPDisconnect()

	Else

		ConOut( "TAprovaPedidoCompraEMail:Recebe() => ERRO ao conectar com servidor POP: " + ::oServidor:GetErrorString( _nRet ) )

	EndIf

Return()


Method RecebeManual(_cIDMSG, _cACTION) Class TAprovaPedidoCompraEMail

	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoCompraEMail:Recebe()")

	//recuperar chave da mensagem
	::cIDMsg := _cIDMSG

	If ::Existe()

		::cNumPed := ZC1->ZC1_PEDIDO
		::nRecMaster := ZC1->(RecNo())
		::cEmpPed := ZC1->ZC1_EMP
		::cFilPed := ZC1->ZC1_FIL

		ConOut( "TAprovaPedidoCompraEMail:Recebe() => Recebendo mensagem ID = "+AllTrim(::cIDMsg)+", ACTION = "+AllTrim(_cACTION)+" " )

		If _cACTION == "RECUSA"

			::Recusar()

		ElseIf _cACTION == "APROVA"

			::Aprova()

		ElseIf _cACTION == "APRALL"

			::AprTodos()

		ElseIf _cACTION == "RECALL"

			::RecTodos()

		EndIf

	EndIf

Return


Method Valida()	Class TAprovaPedidoCompraEMail

	Local lRet := .F.
	Local aEmails
	Local I

	If !Empty(::cIDMsg) .And. ::Existe()	

		::cNumPed := ZC1->ZC1_PEDIDO
		::nRecMaster := ZC1->(RecNo())
		::cEmpPed := ZC1->ZC1_EMP
		::cFilPed := ZC1->ZC1_FIL

		If ZC1->ZC1_STATUS == "E" 

			aEmails := StrToKArr(AllTrim(ZC1->ZC1_EMAIL),";")

			If (Lower(AllTrim(ZC1->ZC1_EMAILT)) $ Lower(::oMensagem:cFrom))

				lRet := .T.

			Else

				For I := 1 To Len(aEmails)

					IF (Lower(AllTrim(aEmails[I])) $ Lower(::oMensagem:cFrom))

						lRet := .T.

					ENDIF

				Next I

			EndIf

		EndIf

	EndIf

	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoCompraEMail:Valida() -- Email: "+ Lower(::oMensagem:cFrom) +" -- Chave: "+ ::cIDMsg + " -- Chave Valida: " + If (lRet, "SIM", "NAO") )

Return(lRet)

Method RetEMailApr() Class TAprovaPedidoCompraEMail

	Local cRet := ""

	If !Empty(::cCodAprT)

		cRet := ::cEmailAprT

	Else

		cRet := ::cEmailApr

	EndIf

Return(cRet)


Method RetNomFor() Class TAprovaPedidoCompraEMail

	Local cRet := ""

	SC7->(DbSetOrder(1))
	SA2->(DbSetOrder(1))

	If SC7->(DbSeek(xFilial("SC7") + ::cNumPed))

		If SA2->(DbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

			cRet := Capital(AllTrim(SA2->A2_NOME))

		EndIf

	EndIf

Return(cRet)


Method RetHtml() Class TAprovaPedidoCompraEMail

	Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	cRet += ' <title>Workflow</title>
	cRet += '</head>
	cRet += '<body>	

	cRet += ::RetHtmlBody()	

	cRet += '</body>
	cRet += '</html>

Return(cRet)


Method RetIDMsg() Class TAprovaPedidoCompraEMail

	Local cRet := ""

	If 'KEY:' $ ::oMensagem:cSubject

		cRet := SubStr(AllTrim(::oMensagem:cSubject), At('KEY:', ::oMensagem:cSubject) + 3, 32)

	EndIf

	If 'ACTION:' $ ::oMensagem:cSubject

		::cAction := SubStr(AllTrim(::oMensagem:cSubject), At('ACTION:', ::oMensagem:cSubject) + 6, 6)

	EndIf		

Return(cRet)


Method RetHtmlBody() Class TAprovaPedidoCompraEMail
Local cSQL := ""
Local cQry := GetNextAlias()
Local cHtml := ""
Local nCount := 1
Local cSolicit := ""
Local cLinkApr := ""
Local cLinkRec := ""
Local solDif := 0

	cSQL := " SELECT C7_USER, C7_NUM, C7_PRODUTO, C7_DESCRI, C7_UM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_NUMSC, C7_ITEMSC, C7_MOEDA, C7_COND, C7_IPI, C7_VALFRE, "
	cSQL += " C7_VLDESC, C7_CLVL, CTH_DESC01, C7_ITEMCTA, C7_YCONTR, C7_YMAT, C7_YOBSCOM, C7_YOBS, C1_YMAT, C1_YSOLEMP "
	cSQL += " FROM "+RetSQLName("SC7")+" SC7 "
	cSQL += " LEFT JOIN "+RetSQLName("SC1")+" SC1 ON C1_FILIAL = C7_FILIAL AND C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC AND SC1.D_E_L_E_T_='' "
	cSQL += " LEFT JOIN CTH010 CTH ON CTH.CTH_CLVL = C7_CLVL AND CTH.D_E_L_E_T_='' "
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_NUM = " + ValToSQL(::cNumPed)
	cSQL += "	AND C7_RESIDUO = '' "
	//cSQL += "	AND C7_ENCER = '' "
	//cSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	cSQL += " and SC7.D_E_L_E_T_='' "

	TcQuery cSQL New Alias (cQry)

	If !(cQry)->(Eof()) 
		
		cSolicit := ::RetSol((cQry)->C1_YMAT, (cQry)->C1_YSOLEMP)

		cLinkApr := '<a href="mailto:'+ ::cEmail +'?subject=Aprovar pedido de compra: '+ ::cNumPed + ' - ACTION:APROVA - KEY:'+ ::cIDMsg +'" style="color: green"><u>CLIQUE AQUI PARA APROVAR.</u></a>'
		cLinkRec := '<a href="mailto:'+ ::cEmail +'?subject=Recusar pedido de compra: '+ ::cNumPed + ' - ACTION:RECUSA - KEY:'+ ::cIDMsg +'" style="color: red"><u>CLIQUE AQUI PARA RECUSAR.</u></a>'

		cHtml := '<style type="text/css">'
		cHtml += 'body{ font-family: Verdana; font-size: 10px; }'
		cHtml += 'a{text-decoration: none;}'
		cHtml += '.mainTableCss{ max-width: 950px;  }'
		cHtml += '.tblDadosComprador,.tblDadosFornecedor,.tblDadosItens,.tblTotais,.tblDadosTransportadora { border: 1px solid #c6c6c6; padding: 5px; width: 100%; }'
		cHtml += '.mainTableCss tr,.tblDadosComprador tr,.tblDadosFornecedor tr,.tblTotais tr,.tblDadosTransportadora tr{ }'
		cHtml += '.mainTableCss th,.tblDadosComprador th,.tblDadosFornecedor th,.tblDadosItens th,.tblTotais th,.tblDadosTransportadora th{ padding: 10px; }'
		cHtml += '.mainTableCss td,.tblDadosComprador td,.tblDadosFornecedor td,.tblDadosItens td,.tblTotais td,.tblDadosTransportadora td{ padding: 2px 10px 2px 10px; font-size: 12px; }'
		cHtml += '.tblItensPedido td{border-top: 1px solid #c6c6c6; border-bottom: 1px solid #c6c6c6; }' 
		cHtml += '.tblItensPedido-border-left{ border-left: 1px solid #c6c6c6; padding:1px 1px 1px 1px; }' 
		cHtml += '.tblItensPedido-border-right{ border-right: 1px solid #c6c6c6; border-left: 1px solid #c6c6c6; padding:1fpx 1px 1px 1px;}' 
		cHtml += '.titleCss{ font-size: 14px; }' 
		cHtml += '.obsCss{ font-size: 10px; }'
		cHtml += '.titleTable{ background-color: #C6C6C6; font-size: 14px; }'
		cHtml += '.link{ font-size: 16px; font-weight: bold; }'
		cHtml += '</style>'
		cHtml += '<table class="mainTableCss" >'
		cHtml += '	<tr class="">'
		cHtml += '		<th colspan="2" valign="top">'
		cHtml += '			<span class="link">'+cLinkApr+'</span>'		
		cHtml += '		</th>'
		cHtml += '	</tr>'
		cHtml += '	<tr class="">'
		cHtml += '		<th colspan="2" valign="top">'
		cHtml += '			<span class="link">'+cLinkRec+'</span>'		
		cHtml += '		</th>'
		cHtml += '	</tr>'
		cHtml += '	<tr class="">'
		cHtml += '		<th colspan="2" valign="top">'
		cHtml += '			<span class="titleCss">PEDIDO DE COMPRA: '+((cQry)->C7_NUM)+'</span><span>'
		cHtml += '		</th>'
		cHtml += '	</tr>'
		cHtml += '	<tr class="">'
		cHtml += '		<th colspan="2" valign="top">'
		cHtml += '			<span class="">Classe de Valor: '+((cQry)->C7_CLVL)+' - '+Alltrim((cQry)->CTH_DESC01)+'</span><span>'
		cHtml += '		</th>'
		cHtml += '	</tr>'

		cHtml += '	<tr>'
		cHtml += '		<td>'
		cHtml += '		</td>'
		cHtml += '	</tr>'
		cHtml += '	<tr>'
		cHtml += '		<td colspan="2" valign="top">'
		cHtml += '			<table class="tblDadosItens">'
		cHtml += '				<tr class="titleTable"><th>ITENS DO PEDIDO DE COMPRA</th></tr>'
		cHtml += '				<tr>'
		cHtml += '					<td>'
		cHtml += '						<table class="tblItensPedido" cellpadding="0" cellspacing="0">'
		cHtml += '							 <tr>'
		cHtml += '								<th> CODIGO </th>'
		cHtml += '								<th> DESCRIÇÃO </th>'
		cHtml += '								<th> UN </th>'
		cHtml += '								<th> QUANTIDADE </th>'
		cHtml += '								<th> PREÇO </th>'
		cHtml += '								<th> TOTAL MERCADORIA </th>'

		cHtml += '								<th> IPI </th>'		
		cHtml += '								<th> FRETE </th>'
		cHtml += '								<th> DESCONTO </th>'
		cHtml += '								<th> TOTAL GERAL </th>'		
						
		cHtml += '								<th> S.C </th>'
		cHtml += '								<th> MOEDA </th>'
		cHtml += '								<th> ITEM CONTA </th>'
		cHtml += '								<th> Nº CONTRATO </th>'
		cHtml += '								<th> SOLICITANTE </th>'
		cHtml += '								<th> OBS. S.C </th>'
		cHtml += '								<th> OBS. COMPRAS </th>'				
		cHtml += '							 </tr>'

		//ITENS
		While !(cQry)->(Eof())
		
			cSolicitIt := ::RetSol((cQry)->C7_YMAT, cEmpAnt)
			
			//se os solicitantes nao sao os mesmos para todos os itens, nao imprimir o solicitante ao final da tabela

      //                 01002947_c7              01002947_c7  <>   01002947_c1
			if(!Empty(AllTrim(cSolicitIt)) .And. AllTrim(cSolicitIt) != AllTrim(cSolicit))
				solDif := 1
			endif
					
			cHtml += '							 <tr>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_PRODUTO) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_DESCRI) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_UM) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_QUANT	,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_PRECO	,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_TOTAL, "@E 999,999,999.99") +'</td>

			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM(Round((((cQry)->C7_PRECO / 100) * (cQry)->C7_IPI) * (cQry)->C7_QUANT, 2), "@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_VALFRE, "@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->C7_VLDESC, "@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM(((cQry)->C7_TOTAL + Round((((cQry)->C7_PRECO / 100) * (cQry)->C7_IPI) * (cQry)->C7_QUANT, 2) + (cQry)->C7_VALFRE) - (cQry)->C7_VLDESC, "@E 999,999,999.99") +'</td>
			
			cHtml += '								<td class="tblItensPedido-border-left">'+ (cQry)->C7_NUMSC +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(GetMv("MV_MOEDA" + Alltrim(Str((cQry)->C7_MOEDA)))) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_ITEMCTA) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_YCONTR) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(cSolicitIt) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_YOBS) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_YOBSCOM) +'</td>						
			cHtml += '							 </tr>'

			(cQry)->(DbSkip())

			nCount ++

		EndDo()     

		//cHtml += '							 </tr>' 
		cHtml += '						</table>'
		cHtml += '					</td>'
		cHtml += '				</tr>'
		cHtml += '			</table>'
		cHtml += '		</td>'
		cHtml += '	</tr>'
		cHtml += '	<tr>'
		cHtml += '		<td>'
		cHtml += '		</td>'
		cHtml += '	</tr>'

		if(solDif == 0)
			cHtml += '	<tr class="">'
			cHtml += '		<th colspan="2" valign="top" align="left">'
			cHtml += '			<span class="obsCss">SOLICITANTE: '+cSolicit+'</span>'
			cHtml += '		</th>'
			cHtml += '	</tr>'
		endif

		cHtml += '	<tr>'
		cHtml += '		<td>'
		cHtml += '		</td>'
		cHtml += '	</tr>'

		cHtml += '</table>'

	EndIf

	(cQry)->(DbCloseArea()) 

Return(cHtml)


Method EnviaPendentes() Class TAprovaPedidoCompraEMail

	Local cSQL
	Local cAprov := ""
	Local aItensAP := {}
	Local cHtml
	Local cQry := GetNextAlias()

	cSQL := " select "+CRLF 
	cSQL += " USERAP = isnull((select top 1 CR_USER from "+RetSQLName("SCR")+" where CR_TIPO = 'PC' and CR_NUM = C7_NUM and D_E_L_E_T_=''),''), "+CRLF
	cSQL += " C7_NUM, A2_NOME, C7_EMISSAO, "+CRLF
	cSQL += " C7_TOTAL = SUM(C7_TOTAL + ((((C7_PRECO / 100) * C7_IPI) * C7_QUANT) + C7_VALFRE) - C7_VLDESC), "+CRLF
	cSQL += " COMPRADOR = Y1_NOME, SOLICITANTE = isnull(RA_NOME, C1_SOLICIT) "+CRLF
	cSQL += " from "+RetSQLName("SC7")+" SC7  "+CRLF
	cSQL += " join "+RetSQLName("SA2")+" SA2 on A2_FILIAL = '  ' and A2_COD = C7_FORNECE and A2_LOJA = C7_LOJA and SA2.D_E_L_E_T_='' "+CRLF
	cSQL += " left join "+RetSQLName("SY1")+" SY1 on Y1_FILIAL = ' ' and Y1_USER = C7_USER and SY1.D_E_L_E_T_='' "+CRLF
	cSQL += " left join "+RetSQLName("SC1")+" SC1 on C1_FILIAL = C7_FILIAL and C1_NUM = C7_NUMSC and C1_ITEM = C7_ITEMSC and SC1.D_E_L_E_T_='' "+CRLF 
	cSQL += " left join "+RetSQLName("SRA")+" SRA on RA_FILIAL = C1_FILIAL and RA_MAT = C1_YMAT and SRA.D_E_L_E_T_=''  "+CRLF
	cSQL += " where C7_FILIAL = '01' "+CRLF 
	cSQL += " AND C7_CONAPRO = 'B' "+CRLF
	cSQL += " AND C7_RESIDUO = '' "+CRLF
	cSQL += " AND C7_ENCER = '' "+CRLF 	
	cSQL += " AND (C7_QUANT-C7_QUJE) > 0 "+CRLF  
	cSQL += " and C7_YCONTR = '' "+CRLF
	cSQL += " and SC7.D_E_L_E_T_='' "+CRLF
	cSQL += " and isnull((select top 1 CR_USER from "+RetSQLName("SCR")+" where CR_TIPO = 'PC' and CR_NUM = C7_NUM and D_E_L_E_T_=''),'') <> '' "+CRLF
	cSQL += " group by C7_NUM, A2_NOME, C7_EMISSAO, Y1_NOME, RA_NOME, C1_SOLICIT "+CRLF

	cSQL += " order by 1,4 "+CRLF

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If Len(aItensAP) > 0

			::GeraChPend(cAprov, @aItensAP) 
			cHtml := ::HtmlPend(aItensAP)
			::SendPend(cHtml)

			aItensAP := {}
		EndIf

		cAprov := (cQry)->USERAP		

		While !(cQry)->(Eof()) .And. (cQry)->USERAP == cAprov

			AAdd(aItensAP, {(cQry)->C7_NUM, (cQry)->A2_NOME, (cQry)->C7_EMISSAO, (cQry)->C7_TOTAL, (cQry)->COMPRADOR, (cQry)->SOLICITANTE, ""/*chv registro filho*/ })

			(cQry)->(DbSkip())
		EndDo

	EndDo

	If Len(aItensAP) > 0

		::GeraChPend(cAprov, @aItensAP) 
		cHtml := ::HtmlPend(aItensAP)
		::SendPend(cHtml)

		aItensAP := {}
	EndIf

Return


Method GeraChPend(cAprov, aItensAP) Class TAprovaPedidoCompraEMail

	Local I
	Local _ChvPC
	Local __NRECMASTER

	//Gera Chave Registro Master - Aprovador
	::cIDMsg := Upper(HMAC(cEmpAnt + cFilAnt + cAprov + DTOS(dDataBase) +  SubStr(TIme(),1,2) + SubStr(TIme(),4,2) + SubStr(TIme(),7,2) , "Bi@nCoGrEs", 1))

	SAK->(DbSetOrder(2))  //AK_FILIAL, AK_USER, R_E_C_N_O_, D_E_L_E_T_

	If SAK->(DbSeek(XFilial("SAK")+cAprov))

		//Preenche dados master
		::cCodApr := SAK->AK_USER
		::cEmailApr := UsrRetMail(::cCodApr)

		//Grava registro master - para aprovar/recusar todos
		RecLock("ZC1", .T.)

		ZC1->ZC1_FILIAL	:= xFilial("ZC1")
		ZC1->ZC1_EMP := cEmpAnt
		ZC1->ZC1_FIL := cFilAnt
		ZC1->ZC1_PEDIDO	:= ""
		ZC1->ZC1_APROV := ::cCodApr
		ZC1->ZC1_EMAIL := ::cEmailApr //"wadson.goncalves@biancogres.com.br;saulo.graize@biancogres.com.br;leticia.vicente@biancogres.com.br"
		ZC1->ZC1_APROVT := ::cCodAprT
		ZC1->ZC1_EMAILT := ::cEmailAprT
		ZC1->ZC1_CHAVE := ::cIDMsg		
		ZC1->ZC1_DATENV := dDataBase
		ZC1->ZC1_STATUS := "E"

		If ZC1->(FieldPos("ZC1_TIPDOC")) > 0
			ZC1->ZC1_TIPDOC := "MC"
		EndIf

		ZC1->(MsUnlock())

		__NRECMASTER := ZC1->(RecNo())

		For I := 1 To Len(aItensAP)

			_ChvPC := Upper(HMAC(cEmpAnt + cFilAnt + aItensAP[I][1] + AllTrim(Str(__NRECMASTER)), "Bi@nCoGrEs", 1))

			aItensAP[I][7] := _ChvPC

			RecLock("ZC1", .T.)

			ZC1->ZC1_FILIAL	:= xFilial("ZC1")
			ZC1->ZC1_EMP := cEmpAnt
			ZC1->ZC1_FIL := cFilAnt
			ZC1->ZC1_PEDIDO	:= aItensAP[I][1]
			ZC1->ZC1_APROV := ::cCodApr
			ZC1->ZC1_EMAIL := ::cEmailApr //"wadson.goncalves@biancogres.com.br;saulo.graize@biancogres.com.br;leticia.vicente@biancogres.com.br"
			ZC1->ZC1_APROVT := ::cCodAprT
			ZC1->ZC1_EMAILT := ::cEmailAprT
			ZC1->ZC1_CHAVE := _ChvPC	
			ZC1->ZC1_DATENV := dDataBase
			ZC1->ZC1_STATUS := "E"

			If ZC1->(FieldPos("ZC1_TIPDOC")) > 0
				ZC1->ZC1_TIPDOC := "MC"
				ZC1->ZC1_RECGR := __NRECMASTER
			EndIf

			ZC1->(MsUnlock())

		Next I

	EndIf


Return


Method HtmlPend(aItensAP) Class TAprovaPedidoCompraEMail

	Local nX
	Local cHtml := ""

	Local cLinkApr := ""
	Local cLinkRec := ""

	cHtml := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">
	cHtml += '<head>
	cHtml += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	cHtml += ' <title>Workflow</title>
	cHtml += '</head>
	cHtml += '<body>	

	cLinkApr := '<a href="mailto:'+ ::cEmail +'?subject=Aprovar pedidos de compra pendentes - ACTION:APRALL - KEY:'+ ::cIDMsg +'" style="color: green"><u>APROVAR TODOS</u></a>'
	cLinkRec := '<a href="mailto:'+ ::cEmail +'?subject=Recusar pedidos de compra pendentes - ACTION:RECALL - KEY:'+ ::cIDMsg +'" style="color: red"><u>RECUSAR TODOS</u></a>'

	cHtml := '<style type="text/css">'
	cHtml += 'body{ font-family: Verdana; font-size: 10px; }'
	cHtml += 'a{text-decoration: none;}'
	cHtml += '.mainTableCss{ max-width: 950px;  }'
	cHtml += '.tblDadosComprador,.tblDadosFornecedor,.tblDadosItens,.tblTotais,.tblDadosTransportadora { border: 1px solid #c6c6c6; padding: 5px; width: 100%; }'
	cHtml += '.mainTableCss tr,.tblDadosComprador tr,.tblDadosFornecedor tr,.tblTotais tr,.tblDadosTransportadora tr{ }'
	cHtml += '.mainTableCss th,.tblDadosComprador th,.tblDadosFornecedor th,.tblDadosItens th,.tblTotais th,.tblDadosTransportadora th{ padding: 10px; }'
	cHtml += '.mainTableCss td,.tblDadosComprador td,.tblDadosFornecedor td,.tblDadosItens td,.tblTotais td,.tblDadosTransportadora td{ padding: 2px 10px 2px 10px; font-size: 12px; }'
	cHtml += '.tblItensPedido td{border-top: 1px solid #c6c6c6; border-bottom: 1px solid #c6c6c6; }' 
	cHtml += '.tblItensPedido-border-left{ border-left: 1px solid #c6c6c6; padding:1px 1px 1px 1px; }' 
	cHtml += '.tblItensPedido-border-right{ border-right: 1px solid #c6c6c6; border-left: 1px solid #c6c6c6; padding:1fpx 1px 1px 1px;}' 
	cHtml += '.titleCss{ font-size: 14px; }' 
	cHtml += '.obsCss{ font-size: 10px; }'
	cHtml += '.titleTable{ background-color: #C6C6C6; font-size: 14px; }'
	cHtml += '.link{ font-size: 16px; font-weight: bold; }'
	cHtml += '</style>'
	cHtml += '<table class="mainTableCss" >'
	cHtml += '	<tr class="">'
	cHtml += '		<th colspan="2" valign="top">'
	cHtml += '			Clique aqui para: <span class="link">'+cLinkApr+'</span>'		
	cHtml += '		</th>'
	cHtml += '	</tr>'
	cHtml += '	<tr class="">'
	cHtml += '		<th colspan="2" valign="top">'
	cHtml += '			Clique aqui para: <span class="link">'+cLinkRec+'</span>'		
	cHtml += '		</th>'
	cHtml += '	</tr>'
	cHtml += '	<tr>'
	cHtml += '		<td>'
	cHtml += '		</td>'
	cHtml += '	</tr>'
	cHtml += '	<tr>'
	cHtml += '		<td colspan="2" valign="top">'
	cHtml += '			<table class="tblDadosItens">'
	cHtml += '				<tr class="titleTable"><th>PEDIDOS DE COMPRAS PENDENTES DE APROVAÇÃO</th></tr>'
	cHtml += '				<tr>'
	cHtml += '					<td>'
	cHtml += '						<table class="tblItensPedido" cellpadding="0" cellspacing="0">'
	cHtml += '							 <tr>'
	cHtml += '								<th> NUMERO PC </th>'
	cHtml += '								<th> FORNECEDOR </th>'
	cHtml += '								<th> DATA EMISSÃO </th>'
	cHtml += '								<th> VALOR TOTAL </th>'
	cHtml += '								<th> COMPRADOR </th>'
	cHtml += '								<th> SOLICITANTE </th>'
	cHtml += '								<th> APROVAR/RECUSAR </th>'
	cHtml += '							 </tr>'

	For nX := 1 To Len(aItensAP)

		cLinkApr := '<a href="mailto:'+ ::cEmail +'?subject=Aprovar pedido de compra: '+ aItensAP[nX][1] + ' - ACTION:APROVA - KEY:'+ aItensAP[nX][7] +'" style="color: green"><u>Aprovar</u></a>'
		cLinkRec := '<a href="mailto:'+ ::cEmail +'?subject=Recusar pedido de compra: '+ aItensAP[nX][1] + ' - ACTION:RECUSA - KEY:'+ aItensAP[nX][7] +'" style="color: red"><u>Recusar</u></a>'

		cHtml += '							 <tr>
		cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(aItensAP[nX][1]) +'</td>
		cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(aItensAP[nX][2]) +'</td>
		cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(DTOC(STOD(aItensAP[nX][3]))) +'</td>
		cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM(aItensAP[nX][4]	,"@E 999,999,999.99") +'</td>
		cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(aItensAP[nX][5]) +'</td>
		cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(aItensAP[nX][6]) +'</td>

		cHtml += '								<td class="tblItensPedido-border-left">'+ cLinkApr +'  '+ cLinkRec +'</td>
		cHtml += '							 </tr>'

	Next   nX 

	cHtml += '						</table>'
	cHtml += '					</td>'
	cHtml += '				</tr>'
	cHtml += '			</table>'
	cHtml += '		</td>'
	cHtml += '	</tr>'
	cHtml += '	<tr>'
	cHtml += '		<td>'
	cHtml += '		</td>'
	cHtml += '	</tr>'

	cHtml += '	<tr>'
	cHtml += '		<td>'
	cHtml += '		</td>'
	cHtml += '	</tr>'

	cHtml += '</table>'

	cHtml += '</body>
	cHtml += '</html>

Return(cHtml)


Method SendPend(_cHtml) Class TAprovaPedidoCompraEMail

	::oServidor:Init("", ::cServidor, ::cConta, ::cSenha)		

	::oServidor:SetSmtpTimeOut(60)

	If ::oServidor:SmtpConnect() == 0

		If ::lUseAUT 
			_nErro := ::oServidor:SmtpAuth(::cConta, ::cSenha)
		Else
			_nErro := 0
		EndIf

		If _nErro == 0

			::oMensagem := TMailMessage():New()
			::oMensagem:Clear() 
			::oMensagem:cFrom := ::cEmail

			//If Upper(AllTrim(getenvserver())) $ "DEV-PABLO"
			//::oMensagem:cTo := "pablo.nascimento@biancogres.com.br"
			If Upper(AllTrim(getenvserver())) $ "COMP-TIAGO-PROD"
				::oMensagem:cTo := "tiago@facilesistemas.com.br"			
			Else
				::oMensagem:cTo := ::RetEmailApr() //"wadson.goncalves@biancogres.com.br;saulo.graize@biancogres.com.br;leticia.vicente@biancogres.com.br"
			EndIf

			::oMensagem:cCc := ""
			::oMensagem:cBcc := ""
			::oMensagem:cSubject := "Pedidos de Compra Pendentes de Aprovação. "+IIF(AllTrim(CEMPANT)=="01","[BIANCOGRES]","[INCESA]")
			::oMensagem:cBody := _cHtml

			_nErro := ::oMensagem:Send( ::oServidor )
			
			If( _nErro != 0 )

				ConOut( "TAprovaPedidoCompraEMail:SendPend() => ERRO ao enviar e-mail: " + ::oServidor:GetErrorString( _nErro ) )

			Else

				ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoCompraEMail:SendPend() -- Empresa: "+ cEmpAnt +" -- Pedidos Pendentes -- Email: " + ::oMensagem:cTo)

			EndIf

		Else
		
			ConOut( "TAprovaPedidoCompraEMail:SendPend() => ERRO ao autenticar: " + str(_nErro,6), ::oServidor:GetErrorString( _nErro ) )
		
		EndIf

		::oServidor:SmtpDisconnect()

	EndIf

Return()


/*/{Protheus.doc} EnvConfirmacao
@description Metodo para enviar o e-mail de confirmacao para o Aprovador após a aprovacao - copiado do MTA097.PRW
@author Fernando Rocha
@since 30/07/2018
@version 1.0
@type function
/*/
Method EnvConfirmacao() Class TAprovaPedidoCompraEMail

	Local cMailComprador := ""
	Local cNomeAprovador := ""
	Local lOk

	If !Empty(SC7->C7_USER)

		PswOrder(1)
		PswSeek(SC7->C7_USER, .T.)

		cMailComprador := AllTrim(PswRet(1)[1][14])

	EndIf

	SCR->(DbSetOrder(1))  //CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL, R_E_C_N_O_, D_E_L_E_T_

	IF SCR->(DbSeek(XFilial("SCR")+"PC"+::cNumPed))

		SAK->(DbSetOrder(2))  //AK_FILIAL, AK_USER, R_E_C_N_O_, D_E_L_E_T_

		If SAK->(DbSeek(XFilial("SAK")+SCR->CR_USER))

			self:cCodApr := SAK->AK_USER

			//Bucar dados do Aprovador
			PswOrder(1)
			PswSeek(SAK->AK_USER, .T.)

			cNomeAprovador := PswRet(1)[1][4]  

		EndIf

	ENDIF

	IF !Empty(cNomeAprovador) .And. !Empty(cMailComprador)

		cData := DTOC(DDATABASE)
		cTitulo := "Pedido de compra "
		cMensagem := "Email enviado automaticamente pelo PROTHEUS. " + CHR(13)+CHR(10)
		cMensagem += "Informamos que foi liberado, no sistema Microsiga, o pedido de compra numero: "+::cNumPed+" pelo Sr(a). "+PADC(cNomeAprovador,50)+CHR(13)+CHR(10)
		cMensagem += "Atenciosamente,"+CHR(13)+CHR(10)
		cMensagem += CHR(13)+CHR(10)
		cMensagem += PADC(" Setor de Compras",50)+CHR(13)+CHR(10)

		SM0->(DbSetOrder(1))
		SM0->(DbSeek(CEMPANT+CFILANT))

		If SUBSTR(ALLTRIM(SM0->M0_NOMECOM),1,1) == 'B'
			cMensagem += "Biancogres Ceramica S/A"
		ElseIf SUBSTR(ALLTRIM(SM0->M0_NOMECOM),1,1) == 'I'
			cMensagem += "Incesa Revestimento Ceramico LTDA"
		ElseIF SUBSTR(ALLTRIM(SM0->M0_NOMECOM),1,1) == 'V'
			cMensagem += "Vitcer Retifica e Complementos Ceramicos LTDA"
		Else
			cMensagem += "Biancogres Ceramica S/A"	
		EndIf

		cMensagem += CHR(13)+CHR(10)
		cMensagem += CHR(13)+CHR(10)
		cMensagem += CHR(13)+CHR(10)

		lOk := U_BIAEnvMail(,cMailComprador, cTitulo, cMensagem) 

		If !lOk

			ConOut( "TAprovaPedidoCompraEMail:EnvConfirmacao() => ERRO ao enviar e-mail de confirmação para comprador. ")

		EndIf 

	ELSE

		ConOut( "TAprovaPedidoCompraEMail:EnvConfirmacao() => Não localizado Aprovador OU Comprador do Pedido "+::cNumPed+". ")

	ENDIF

Return


Method RetSol(cMat, cSolEmp) Class TAprovaPedidoCompraEMail

	Local cRet   := ""
	Local cSQL   := ""
	Local cQry   := GetNextAlias()


	If !Empty(cMat)				

		if Len(cMat) > 6
			cMat := SUBSTR(cMat,3,6)
		EndIf
	
		If !Empty(cSolEmp) .And. cSolEmp <> cEmpAnt
	
			cSQL := " SELECT RA_NOME "
			cSQL += " FROM "+ RetFullName("SRA", cSolEmp)
			cSQL += " WHERE RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
			cSQL += " AND RA_MAT = "+ ValToSQL(cMat)
			cSQL += " AND D_E_L_E_T_ = '' "
	
			TcQuery cSQL New Alias (cQry)
	
			If !Empty((cQry)->RA_NOME)
			
				cRet := AllTrim((cQry)->RA_NOME)
	
			EndIf
	
			(cQry)->(DbCloseArea())
	
		Else
	
			DbSelectArea("SRA")
			DbSetOrder(1)
			If SRA->(DbSeek(xFilial("SRA") + cMat))
				
				If !Empty(SRA->RA_NOME)
				
					cRet := AllTrim(SRA->RA_NOME)
		
				EndIf
				
			EndIf			
	
		EndIf
	
	EndIf	

Return(cRet)
