#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAprovaPreNotaEMail
@author Fernadno Rocha
@since 27/07/2017
@version 1.0
@description Classe para controle de aprovação de pedidos de compra por e-mail - baseado no TAprovaPedidoVendaEMail
@type class
/*/

Class TAprovaPreNotaEMail From LongClassName	

	Data cNumPed
	Data cCodApr
	Data cEmailApr
	Data cCodAprT
	Data cEmailAprT

	Data cDoc
	Data cSerie
	Data cCliFor
	Data cLoja

	Data oServidor
	Data oMensagem
	Data cServidor
	Data cSrvPOP
	Data cConta
	Data cSenha
	Data cEmail
	Data cIDMsg
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
	Method Envia()
	Method Recebe()
	Method Valida()
	Method RetEMailApr()
	Method RetNomFor()
	Method RetHtml()
	Method RetIDMsg()
	Method RetHtmlBody()

EndClass


Method New() Class TAprovaPreNotaEMail

	::cNumPed := ""
	::cCodApr := ""
	::cEmailApr := ""
	::cCodAprT := ""
	::cEmailAprT := ""	
	::cDoc := ""
	::cSerie := ""
	::cCliFor := ""
	::cLoja := ""

	::oServidor := TMailManager():New()
	::oMensagem := TMailMessage():New()	
	
	::cServidor := SubStr(GetMv("MV_RELSERV"),1,RAT(':',GetMv("MV_RELSERV"))-1)
	::cSrvPOP	:= SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)
	::cConta 	:= GetMv("MV_YPCCTAP")
	::cSenha 	:= GetMv("MV_YPCSNAP")
	::cEmail 	:= GetMv("MV_YPCCTAP")
	::lUseTLS 	:= GetMv("MV_RELTLS")
	::lUseSSL 	:= GetMv("MV_RELSSL")
	::lUseAUT 	:= GetMv("MV_RELAUTH")
	::cContaRec := GetMv("MV_YPCCTAP")
	::cSenhaRec := GetMv("MV_YPCSNAP")
	::cPtSMTP   := Val(SubStr(GetMv("MV_RELSERV"),RAT(':',GetMv("MV_RELSERV"))+1,Len(Alltrim(GetMv("MV_RELSERV")))))    
	::cPtPOP3   := Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP"))))) 

	::cIDMsg := ""

Return()


Method Inclui() Class TAprovaPreNotaEMail 

	If ::Existe()

		::Exclui()

	EndIf

	RecLock("ZC1", .T.)

	ZC1->ZC1_FILIAL	:= xFilial("ZC1")
	ZC1->ZC1_EMP := cEmpAnt
	ZC1->ZC1_FIL := cFilAnt
	ZC1->ZC1_PEDIDO	:= ::cNumPed
	ZC1->ZC1_APROV := ::cCodApr
	ZC1->ZC1_EMAIL := ::cEmailApr
	ZC1->ZC1_APROVT := ::cCodAprT
	ZC1->ZC1_EMAILT := ::cEmailAprT
	ZC1->ZC1_CHAVE := ::cIDMsg		
	ZC1->ZC1_DATENV := dDataBase
	ZC1->ZC1_STATUS := "E"

	If ZC1->(FieldPos("ZC1_TIPDOC")) > 0
		ZC1->ZC1_TIPDOC := "PN"

		ZC1->ZC1_DOC	:= ::cDoc
		ZC1->ZC1_SERIE	:= ::cSerie
		ZC1->ZC1_CLIFOR	:= ::cCliFor
		ZC1->ZC1_LOJA	:= ::cLoja

	EndIf

	ZC1->(MsUnlock())

Return()


Method Exclui() Class TAprovaPreNotaEMail

	RecLock("ZC1", .F.)

	ZC1->(DbDelete())

	MsUnlock()

Return()


Method Atualiza() Class TAprovaPreNotaEMail

	If ::Existe()

		RecLock("ZC1", .F.)

		ZC1->ZC1_DATREC := dDataBase
		ZC1->ZC1_STATUS := "R"

		ZC1->(MsUnlock())

	EndIf

Return()


Method Existe() Class TAprovaPreNotaEMail

	Local lRet := .F.

	DbSelectArea("ZC1")
	DbSetOrder(1)
	lRet := ZC1->(DbSeek(xFilial("ZC1") + ::cIDMsg)) .And. ZC1->ZC1_TIPDOC == "PN"

Return(lRet)


Method Aprova() Class TAprovaPreNotaEMail

	BEGIN TRANSACTION

		SF1->(DbSetOrder(1))  //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		If SF1->(DbSeek(xFilial("SF1") + ::cDoc + ::cSerie + ::cCliFor + ::cLoja))

			RecLock("SF1", .F.)
			SF1->F1_YSERAPR := "S"
			SF1->(MsUnLock())

			::Atualiza()

		EndIf

	END TRANSACTION

Return()


Method Envia() Class TAprovaPreNotaEMail

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

			::cIDMsg := Upper(HMAC(cEmpAnt + cFilAnt + ::cDoc + ::cSerie + ::cCliFor + ::cLoja, "Bi@nCoGrEs", 1))

			::oMensagem := TMailMessage():New()
			::oMensagem:Clear() 

			::cEmailApr := UsrRetMail(::cCodApr)
			::cEmailAprT := UsrRetMail(::cCodAprT)

			::oMensagem:cFrom := ::cEmail
			::oMensagem:cTo := ::RetEmailApr()
			::oMensagem:cCc := ""
			::oMensagem:cBcc := ""
			::oMensagem:cSubject := "Confirmar Entrada de Pré-Nota de Serviço: " + ::cDoc + " - Fornecedor: " + ::RetNomFor() 			
			::oMensagem:cBody := ::RetHtml()

			_nErro := ::oMensagem:Send( ::oServidor )
			If( _nErro != 0 )

				conout( "TAprovaPreNotaEMail => ERRO ao enviar e-mail: " + ::oServidor:GetErrorString( _nErro ) )

			Else

				ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPreNotaEMail:Envia() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " -- Email: " + ::oMensagem:cTo)
				::Inclui()

			EndIf

		Else
		
			ConOut( "TAprovaPreNotaEMail:Envia() => ERRO ao autenticar: " + str(_nErro,6), ::oServidor:GetErrorString( _nErro ) ) 

		EndIf

		::oServidor:SmtpDisconnect()

	EndIf

Return()


Method Recebe() Class TAprovaPreNotaEMail

	Local nMsg := 0
	Local nTotMsg := 0 
	
	::oServidor:SetUseSSL(::lUseSSL)

	::oServidor:Init(::cSrvPOP, "", ::cContaRec, ::cSenhaRec, ::cPtPOP3, 0)

	conout( "TAprovaPreNotaEMail (RECEBE) => Iniciando conexão com "+::cSrvPOP+", "+::cContaRec+" " )

	_nRet := ::oServidor:PopConnect()

	If (_nRet == 0)

		::oServidor:GetNumMsgs(@nTotMsg)	  

		For nMsg := 1 To nTotMsg

			::oMensagem:Clear()

			::oMensagem:Receive(::oServidor, nMsg)	    	    	     	    	    

			ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPreNotaEMail:Recebe()")

			::cIDMsg := ::RetIDMsg()

			//se for mensagem de pedido de compra ignorar
			_oAPC := TAprovaPedidoCompraEMail():New()
			_oAPC:cIDMsg := ::cIDMsg
			If _oAPC:Existe()
				loop
			EndIf

			If ::Valida()

				::Aprova()

			EndIf

			::oServidor:DeleteMsg(nMsg)	    

		Next

		::oServidor:POPDisconnect()

	Else

		conout( "TAprovaPreNotaEMail (RECEBE) => ERRO ao conectar com servidor POP: " + ::oServidor:GetErrorString( _nRet ) )

	EndIf

Return()


Method Valida()	Class TAprovaPreNotaEMail

	Local lRet := .F.			

	If !Empty(::cIDMsg) .And. ::Existe()	

		::cNumPed 	:= ZC1->ZC1_PEDIDO		
		::cDoc 		:= ZC1->ZC1_DOC
		::cSerie 	:= ZC1->ZC1_SERIE
		::cCliFor 	:= ZC1->ZC1_CLIFOR
		::cLoja 	:= ZC1->ZC1_LOJA

		If ZC1->ZC1_STATUS == "E" .And. (Lower(AllTrim(ZC1->ZC1_EMAIL)) $ Lower(::oMensagem:cFrom) .Or. Lower(AllTrim(ZC1->ZC1_EMAILT)) $ Lower(::oMensagem:cFrom))

			lRet := .T.

		EndIf

	EndIf

	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPreNotaEMail:Valida() -- Email: "+ Lower(::oMensagem:cFrom) +" -- Chave: "+ ::cIDMsg + " -- Chave Valida: " + If (lRet, "SIM", "NAO") )

Return(lRet)

Method RetEMailApr() Class TAprovaPreNotaEMail

	Local cRet := ""

	If !Empty(::cCodAprT)

		cRet := ::cEmailAprT

	Else

		cRet := ::cEmailApr

	EndIf

Return(cRet)


Method RetNomFor() Class TAprovaPreNotaEMail

	Local cRet := ""

	SC7->(DbSetOrder(1))
	SA2->(DbSetOrder(1))

	If SC7->(DbSeek(xFilial("SC7") + ::cNumPed))

		If SA2->(DbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

			cRet := Capital(AllTrim(SA2->A2_NOME))

		EndIf

	EndIf

Return(cRet)


Method RetHtml() Class TAprovaPreNotaEMail

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


Method RetIDMsg() Class TAprovaPreNotaEMail

	Local cRet := ""

	If 'KEY:' $ ::oMensagem:cSubject

		cRet := SubStr(AllTrim(::oMensagem:cSubject), At('KEY:', ::oMensagem:cSubject) + 3, 32)

	EndIf	

Return(cRet)


Method RetHtmlBody() Class TAprovaPreNotaEMail

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cHtml := ""
	Local cNomCon := ""
	Local cEmailCon := ""
	Local nCount := 1
	Local cConPag := ""
	Local nTotMer := 0
	Local nTotIpi := 0
	Local nTotFre := 0
	Local nTotDes := 0
	Local nTotGer := 0
	Local cObs := ""
	Local cImp := ""
	Local cTpFre := ""

	cSQL := ""
	cSQL += " SELECT C7_USER, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE, C7_TPFRETE, D1_COD, C7_DESCRI, C7_UM, C7_DATPRF, C7_YICMS, C7_YPIS, C7_YCOF, C7_YIPI, "+CRLF 
	cSQL += " D1_QUANT, D1_VUNIT, D1_TOTAL, D1_IPI, C7_NUMSC, C7_MOEDA, C7_OBS, C7_COND, C7_TOTAL, C7_PRECO, C7_IPI, C7_QUANT, C7_VALFRE, C7_VLDESC, C7_VLDESC, C7_YTRANSP "+CRLF
	cSQL += " FROM SD1010 SD1 "+CRLF
	cSQL += " JOIN SC7010 SC7 on C7_FILIAL = D1_FILIAL and C7_NUM = D1_PEDIDO and C7_ITEM = D1_ITEMPC "+CRLF
	cSQL += " WHERE D1_FILIAL = '01' "+CRLF
	cSQL += " AND D1_DOC = '000060035' "+CRLF
	cSQL += " AND D1_SERIE = '1  ' "+CRLF
	cSQL += " AND D1_FORNECE = '011576' "+CRLF
	cSQL += " AND D1_LOJA	= '01' "+CRLF
	cSQL += " AND SD1.D_E_L_E_T_ = '' "+CRLF
	cSQL += " AND SC7.D_E_L_E_T_ = '' "+CRLF

	TcQuery cSQL New Alias (cQry)

	If !(cQry)->(Eof()) 

		cNomCon := (cQry)->C7_USER	
		cEmailCon :=	Lower(UsrRetMail(cNomCon))

		PswOrder(1)

		If (!Empty(cNomCon) .And. PswSeek(cNomCon))	

			cNomCon:= PswRet(1)[1][4]

		EndIf
		
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2") + (cQry)->D1_FORNECE + (cQry)->D1_LOJA))

		cLink := '<a href="mailto:'+ ::cEmail +'?subject=Confirmar serviço realizado - PC: '+ ::cNumPed + ' - KEY:'+ ::cIDMsg +'">CLIQUE AQUI PARA CONFIRMAR.</a>'

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
		cHtml += '.titleTable{ background-color: #C6C6C6; font-size: 14px; }'
		cHtml += '.linkConfirmacao{ font-size: 16px; color: blue; font-weight: bold; }'
		cHtml += '</style>'
		cHtml += '<table class="mainTableCss" >'
		cHtml += '	<tr class="">'
		cHtml += '		<th colspan="2" valign="top">'
		cHtml += '			<u><span class="linkConfirmacao"></u>' + cLink		
		cHtml += '		</th>'
		cHtml += '	</tr>'
		cHtml += '	<tr class="">'
		cHtml += '		<th colspan="2" valign="top">'
		cHtml += '			<span class="titleCss">FOI INCLUÍDA A PRÉ NOTA: '+(cQry)->D1_DOC+', SÉRIE: '+(cQry)->D1_SERIE+'</span><span>'
		cHtml += '		</th>'
		cHtml += '	</tr>'
		cHtml += '	<tr>'
		cHtml += '		<td align="left" valign="top">'
		cHtml += '			<table class="tblDadosComprador">'
		cHtml += '				<tr class="titleTable"><th>DADOS DO COMPRADOR</th></tr>'
		cHtml += '				<tr><td><b>Razão Social do Comprador:&nbsp;</b>'+ Capital(SM0->M0_NOMECOM) +'</td></tr>'
		cHtml += '				<tr><td><b>CNPJ:&nbsp;</b>' + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") +'</td></tr>'
		cHtml += '				<tr><td><b>Endereço:&nbsp;</b>'+ Capital(SM0->M0_ENDCOB) +'</td></tr>'
		cHtml += '				<tr><td><b>Município:&nbsp;</b>'+ Capital(SM0->M0_CIDCOB) +'</td></tr>'
		cHtml += '				<tr><td><b>Estado:&nbsp;</b>'+ SM0->M0_ESTCOB +'</td></tr>'
		cHtml += '				<tr><td><b>CEP:&nbsp;</b>'+ TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999") +'</td></tr>'
		cHtml += '				<tr><td><b>País:&nbsp;</b>Brasil</td></tr>'
		cHtml += '				<tr><td><b>Contato:&nbsp;</b>'+ Capital(cNomCon) +'</td></tr>'
		cHtml += '				<tr><td><b>E-mail:&nbsp;</b>'+ Lower(Alltrim(cEmailCon)) +'</td></tr>'
		cHtml += '				<tr><td><b>Telefone:&nbsp;</b>'+ AllTrim(SM0->M0_TEL) +'</td></tr>'
		cHtml += '			</table>'
		cHtml += '		</td>'
		cHtml += '		<td align="right" valign="top">'
		cHtml += '			<table class="tblDadosFornecedor">'
		cHtml += '				<tr class="titleTable"><th>DADOS DO FORNECEDOR</th></tr>'
		cHtml += '				<tr><td><b>Razão Social do Comprador:&nbsp;</b>'+ Capital(Alltrim(SA2->A2_NOME)) +'</td></tr>'

		If Alltrim(SA2->A2_TIPO) == "J"
			cHtml += '				<tr><td><b>CNPJ:&nbsp;</b>'+ TRANSFORM(SA2->A2_CGC,"@R 99.999.999/9999-99") +'</td></tr>'
		Else
			cHtml += '				<tr><td><b>CPF:&nbsp;</b>'+ TRANSFORM(SA2->A2_CGC,"@R 999.999.999-99") +'</td></tr>'
		EndIf

		cHtml += '				<tr><td><b>Endereço:&nbsp;</b>'+ Capital(Alltrim(SA2->A2_END)) +'</td></tr>'
		cHtml += '				<tr><td><b>Município:&nbsp;</b>'+ Capital(SA2->A2_MUN) +'</td></tr>'
		cHtml += '				<tr><td><b>Estado:&nbsp;</b>'+ SA2->A2_EST +'</td></tr>'
		cHtml += '				<tr><td><b>CEP:&nbsp;</b>'+ TRANSFORM(SA2->A2_CEP,"@R 99999-999") +'</td></tr>'
		cHtml += '				<tr><td><b>País:&nbsp;</b>'+ If (Alltrim(SA2->A2_EST) == 'EX', 'Exterior', 'Brasil') +'</td></tr>'
		cHtml += '				<tr><td><b>Contato:&nbsp;</b>'+ Capital(Alltrim(SA2->A2_CONTATO)) +'</td></tr>'
		cHtml += '				<tr><td><b>E-mail:&nbsp;</b>'+ Lower(Alltrim(SA2->A2_EMAIL)) +'</td></tr>'
		cHtml += '				<tr><td><b>Telefone:&nbsp;</b>'+ Alltrim(SA2->A2_TEL) +'</td></tr>'
		cHtml += '			</table>'
		cHtml += '		</td>'
		cHtml += '	</tr>'
		cHtml += '	<tr>'
		cHtml += '		<td>'
		cHtml += '		</td>'
		cHtml += '	</tr>'
		cHtml += '	<tr>'
		cHtml += '		<td colspan="2" valign="top">'
		cHtml += '			<table class="tblDadosItens">'
		cHtml += '				<tr class="titleTable"><th>ITENS DA PRÉ-NOTA</th></tr>'
		cHtml += '				<tr>'
		cHtml += '					<td>'
		cHtml += '						<table class="tblItensPedido" cellpadding="0" cellspacing="0">'
		cHtml += '							 <tr>'
		cHtml += '								<th> ITEM </th>'
		cHtml += '								<th> TP </th>'
		cHtml += '								<th> CODIGO </th>'
		cHtml += '								<th> DESCRIÇÃO </th>'
		cHtml += '								<th> UN </th>'
		cHtml += '								<th> SAIDA </th>'
		cHtml += '								<th> IMP </th>'
		cHtml += '								<th> QUANTIDADE </th>'
		cHtml += '								<th> PREÇO </th>'
		cHtml += '								<th> IPI </th>'
		cHtml += '								<th> TOTAL </th>'
		cHtml += '								<th> S.C </th>'
		cHtml += '								<th> MOEDA </th>'
		cHtml += '								<th> OBSERVAÇÃO </th>'
		cHtml += '							 </tr>'

		nTotMer := 0
		nTotIpi := 0
		nTotFre := 0
		nTotDes := 0

		cTpFre := IIf((cQry)->C7_TPFRETE == "C", "CIF", "FOB")

		//ITENS
		While !(cQry)->(Eof())

			cHtml += '							 <tr>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM(nCount	,"@E 999,999,999") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ POSICIONE("SB1",1,XFILIAL("SB1")+(cQry)->D1_COD,"B1_TIPO") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->D1_COD) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_DESCRI) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim((cQry)->C7_UM) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ SUBSTR((cQry)->C7_DATPRF,7,2)+"/"+SUBSTR((cQry)->C7_DATPRF,5,2)+"/"+SUBSTR((cQry)->C7_DATPRF,1,4) +'</td>

			cImp := IIf((cQry)->C7_YICMS = "S","M","") + IIf((cQry)->C7_YPIS = "S","P","")
			cImp += IIf((cQry)->C7_YCOF = "S","M","C") + IIf((cQry)->C7_YIPI = "S","I","")

			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(cImp) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->D1_QUANT	,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->D1_VUNIT	,"@E 999,999,999.9999") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->D1_IPI		,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ TRANSFORM((cQry)->D1_TOTAL	,"@E 999,999,999.99") +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ (cQry)->C7_NUMSC +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(GetMv("MV_MOEDA" + Alltrim(Str((cQry)->C7_MOEDA)))) +'</td>
			cHtml += '								<td class="tblItensPedido-border-right">'+ ALLTRIM((cQry)->C7_OBS) +'</td>

			cConPag := Posicione("SE4",1,xFilial("SE4")+(cQry)->C7_COND,"E4_DESCRI")
			nTotMer += (cQry)->C7_TOTAL
			nTotIpi += round((( (cQry)->C7_PRECO/100)* (cQry)->C7_IPI) * (cQry)->C7_QUANT,2)
			nTotFre += (cQry)->C7_VALFRE
			nTotDes += (cQry)->C7_VLDESC

			IIf(Empty(cObs), cObs := (cQry)->C7_VLDESC, "") 

			(cQry)->(DbSkip())

			nCount ++

		EndDo()     

		nTotGer := (nTotMer+nTotIpi+nTotFre) - nTotDes

		cHtml += '							 </tr>' 
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
		cHtml += '		<td valign="top">'
		cHtml += '			<table class="tblTotais" >'
		cHtml += '				<tr class="titleTable"><th colspan="2">TOTAIS</th></tr>'
		cHtml += '				<tr><td><b>Total das Mercadorias:&nbsp;</b></td><td>'+ Transform(nTotMer,"@E 999,999,999.99") +'</td></tr>'
		cHtml += '				<tr><td><b>Valor IPI:&nbsp;</b></td><td>'+ Transform(nTotIpi,"@E 999,999,999.99") +'</td></tr>'
		cHtml += '				<tr><td><b>Tipo FRETE:&nbsp;</b></td><td>'+ cTpFre +'</td></tr>'
		cHtml += '				<tr><td><b>Valor FRETE:&nbsp;</b></td><td>'+ Transform(nTotFre,"@E 999,999,999.99") +'</td></tr>'
		cHtml += '				<tr><td><b>Desconto:&nbsp;</b></td><td>'+ Transform(nTotDes,"@E 999,999,999.99") +'</td></tr>'
		cHtml += '				<tr><td><b>Total Geral:&nbsp;</b></td><td>'+ Transform(nTotGer,"@E 999,999,999.99") +'</td></td>'
		cHtml += '				<tr><td><b>Cond. Pagamento:&nbsp;</b></td><td>'+ Alltrim(cConPag) +'</td></tr>'
		cHtml += '			</table>'
		cHtml += '		</td>'
		cHtml += '		<td valign="top">'
		cHtml += '			<table class="tblDadosTransportadora">'
		cHtml += '				<tr class="titleTable"><th colspan="2">DADOS DA TRANSPORTADORA</th></tr>'
		cHtml += '				<tr><td><b>TRANSPORTADORA:&nbsp;</b></td><td>'+ Capital(Alltrim(Posicione("SA4", 1, xFilial("SA4") + (cQry)->C7_YTRANSP, "A4_NOME"))) +'</td></tr>'
		cHtml += '			</table>'
		cHtml += '		</td>'			
		cHtml += '	</tr>'
		cHtml += '	<tr>'
		cHtml += '		<td>'
		cHtml += '		</td>'
		cHtml += '	</tr>'

		cHtml += '</table>'

	EndIf

	(cQry)->(DbCloseArea()) 

Return(cHtml)