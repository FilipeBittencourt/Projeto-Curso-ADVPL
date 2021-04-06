#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAprovaPedidoVendaEMail
@author Tiago Rossini Coradini
@since 27/07/2017
@version 1.0
@description Classe para controle de aprovação de pedidos de venda por e-mail 
@obs OS: 4538-16 - Claudeir Fadini
@type class
/*/

Class TAprovaPedidoVendaEMail From LongClassName

	Data cNumPed
	Data cCodApr
	Data cEmailApr
	Data cCodAprT
	Data cEmailAprT
	Data lEnvMail
	Data lBlqCondPag
	

	Data oServidor
	Data oMensagem
	Data cServidor
	Data cSrvPOP
	Data cConta
	Data cSenha
	Data cEmail
	Data cContaRec
	Data cSenhaRec
	Data cIDMsg
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
	Method RetNomCli()
	Method RetHtml()
	Method RetAnexo()
	Method RetIDMsg()
	Method RetMotBlq()
	Method LoadAprovador()

	Method RetAcaoMsg()
	Method VerificaAcao()
	Method Recusar()
	Method Revisar()
	Method RetHtmlBody()

	Method GetTextoHtml()
	Method GetTextoTag()
	Method GetBase64()

EndClass


Method New() Class TAprovaPedidoVendaEMail

	::cNumPed 		:= ""

	::cCodApr 		:= ""
	::cEmailApr 	:= ""
	::cCodAprT 		:= ""
	::cEmailAprT 	:= ""
	::lEnvMail		:= .F.
	::lBlqCondPag  	:= .F.

	::oServidor := TMailManager():New()
	::oMensagem := TMailMessage():New()
	
	::cServidor := SubStr(GetMv("MV_RELSERV"),1,RAT(':',GetMv("MV_RELSERV"))-1)
	::cSrvPOP	:= SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)
	::cConta 	:= GetMv("MV_YPVCTAP")
	::cSenha 	:= GetMv("MV_YPVSNAP")
	::cEmail 	:= GetMv("MV_YPVCTAP")
	::lUseTLS 	:= GetMv("MV_RELTLS")
	::lUseSSL 	:= GetMv("MV_RELSSL")
	::lUseAUT 	:= GetMv("MV_RELAUTH")
	::cContaRec := GetMv("MV_YPVCTAP")
	::cSenhaRec := GetMv("MV_YPVSNAP")
	::cPtSMTP   := Val(SubStr(GetMv("MV_RELSERV"),RAT(':',GetMv("MV_RELSERV"))+1,Len(Alltrim(GetMv("MV_RELSERV")))))    
	::cPtPOP3   := Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP")))))    
	

	::cIDMsg 	:= ""

Return()


Method Inclui() Class TAprovaPedidoVendaEMail

	If ::Existe()

		::Exclui()

	EndIf

	RecLock("ZC1", .T.)

	ZC1->ZC1_FILIAL		:= xFilial("ZC1")
	ZC1->ZC1_EMP 		:= cEmpAnt
	ZC1->ZC1_FIL 		:= cFilAnt
	ZC1->ZC1_PEDIDO		:= ::cNumPed
	ZC1->ZC1_APROV 		:= ::cCodApr
	ZC1->ZC1_EMAIL 		:= ::cEmailApr
	ZC1->ZC1_APROVT 	:= ::cCodAprT
	ZC1->ZC1_EMAILT 	:= ::cEmailAprT
	ZC1->ZC1_CHAVE 		:= ::cIDMsg
	ZC1->ZC1_DATENV 	:= dDataBase
	ZC1->ZC1_STATUS 	:= "E"

	ZC1->(MsUnlock())

Return()


Method Exclui() Class TAprovaPedidoVendaEMail

	RecLock("ZC1", .F.)

	ZC1->(DbDelete())

	MsUnlock()

Return()


Method Atualiza() Class TAprovaPedidoVendaEMail

	If ::Existe()

		RecLock("ZC1", .F.)

		ZC1->ZC1_DATREC := dDataBase
		ZC1->ZC1_STATUS := "R"

		ZC1->(MsUnlock())

	EndIf

Return()


Method Existe() Class TAprovaPedidoVendaEMail
	Local lRet := .F.

	DbSelectArea("ZC1")
	DbSetOrder(1)
	lRet := ZC1->(DbSeek(xFilial("ZC1") + ::cIDMsg))

Return(lRet)

Method VerificaAcao() Class TAprovaPedidoVendaEMail

	Local cRetAcao	:= ::RetAcaoMsg()

	::Atualiza()

	If (AllTrim(cRetAcao) == 'APROVAR')
		::Aprova()
	ElseIf (AllTrim(cRetAcao) == 'RECUSAR')
		::Recusar()
	ElseIf (AllTrim(cRetAcao) == 'REVISAR')
		::Revisar()
	EndIf


Return

Method Recusar() Class TAprovaPedidoVendaEMail

	Local oLibBloq 		:= TLiberacaoBloqueioPedidoVenda():New()

	oLibBloq:cEmp 		:= ZC1->ZC1_EMP
	oLibBloq:cFil 		:= ZC1->ZC1_FIL
	oLibBloq:cNumPed	:= ZC1->ZC1_PEDIDO
	oLibBloq:cCodAprov	:= If (!Empty(ZC1->ZC1_APROVT), ZC1->ZC1_APROVT, ZC1->ZC1_APROV)
	oLibBloq:lAprovTemp	:= If (!Empty(ZC1->ZC1_APROVT), .T., .F.)
	oLibBloq:cOrigem	:= 'E'
	oLibBloq:lJob		:= .T.
	oLibBloq:cObs		:= ::oMensagem:cBody

	oLibBloq:Recusar()

Return

Method Revisar() Class TAprovaPedidoVendaEMail

	Local oLibBloq 		:= TLiberacaoBloqueioPedidoVenda():New()

	oLibBloq:cEmp 		:= ZC1->ZC1_EMP
	oLibBloq:cFil 		:= ZC1->ZC1_FIL
	oLibBloq:cNumPed	:= ZC1->ZC1_PEDIDO
	oLibBloq:cCodAprov	:= If (!Empty(ZC1->ZC1_APROVT), ZC1->ZC1_APROVT, ZC1->ZC1_APROV)
	oLibBloq:lAprovTemp	:= If (!Empty(ZC1->ZC1_APROVT), .T., .F.)
	oLibBloq:cOrigem	:= 'E'
	oLibBloq:lJob		:= .T.
	oLibBloq:cObs		:= ::oMensagem:cBody

	oLibBloq:Revisar()

Return

Method Aprova() Class TAprovaPedidoVendaEMail

	Local oLibBloq 		:= TLiberacaoBloqueioPedidoVenda():New()

	oLibBloq:cEmp 		:= ZC1->ZC1_EMP
	oLibBloq:cFil 		:= ZC1->ZC1_FIL
	oLibBloq:cNumPed	:= ZC1->ZC1_PEDIDO
	oLibBloq:cCodAprov	:= If (!Empty(ZC1->ZC1_APROVT), ZC1->ZC1_APROVT, ZC1->ZC1_APROV)
	oLibBloq:lAprovTemp	:= If (!Empty(ZC1->ZC1_APROVT), .T., .F.)
	oLibBloq:cOrigem	:= 'E'
	oLibBloq:lJob		:= .T.
	oLibBloq:cObs		:= ::oMensagem:cBody

	oLibBloq:Liberar()

Return()

Method LoadAprovador() Class TAprovaPedidoVendaEMail

	Local cIdZKL := ""
	oPedAprov := TPedidoAprovador():New(::cNumPed)
	cIdZKL := oPedAprov:GetIdAprov()

	If (!Empty(cIdZKL))

		DbSelectArea("ZKL")
		ZKL->(DbGoto(cIdZKL))

		::cCodApr		:= AllTrim(ZKL->ZKL_APROV)
		::cEmailApr		:= UsrRetMail(::cCodApr)
		::lEnvMail		:= (ZKL->ZKL_ENVEM == 'S')

		//::cEmailApr		:= 'pedro@facilesistemas.com.br;barbara.madeira@biancogres.com.br'
		//::cEmailApr		:= 'thiago.oliveira@biancogres.com.br'//'pablo.nascimento@biancogres.com.br'

		::cCodAprT		:= ""
		::cEmailAprT 	:= ""

	Else

		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:CarregaAprovadores() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " -- Codigo Tabela ZKL: " + cIdZKL)

	EndIf

Return


Method Envia() Class TAprovaPedidoVendaEMail

	::LoadAprovador()

	If (!::lEnvMail)
		Return
	EndIf

	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:Envia() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " - STARTED")

	//TICKET 23728 - ocorreu alguma mudanca no servidor de email que passou a nao aceitar poerta 25 - mudando para 587	
	::oServidor:SetUseTLS(::lUseTLS)

	::oServidor:SetUseSSL(::lUseSSL)
	
	::oServidor:Init("", ::cServidor, ::cConta, ::cSenha, 0, ::cPtSMTP)	
	
	::oServidor:SetSmtpTimeOut(60)

	If ::oServidor:SmtpConnect() == 0
		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:Envia() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " - CONNECTED")

		If ::lUseAUT 
			_nErro := ::oServidor:SmtpAuth(::cConta, ::cSenha)
		Else
			_nErro := 0
		EndIf

		If _nErro == 0
			ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:Envia() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " - ATHENTICATED")

			::cIDMsg := Upper(HMAC(cEmpAnt + cFilAnt + ::cNumPed, "Bi@nCoGrEs", 1))

			::oMensagem := TMailMessage():New()

			//'barbara.madeira@biancogres.com.br;pedro@facilesistemas.com.br'//
			
			::oMensagem:cFrom		:= ::cEmail
			::oMensagem:cTo 		:= ::RetEmailApr()
			::oMensagem:cCc 		:= ""
			::oMensagem:cBcc 		:= ""
			::oMensagem:cSubject	:= "Pedido: " + ::cNumPed + " - Cliente: " + ::RetNomCli()
			::oMensagem:cBody 		:= ::RetHtml()

			//Ticket 24249 - Pablo S. Nascimento: remover anexo dos emails de aprovação de pedido de venda, pois não é mais necessário.
			//cRetAnexo := ::RetAnexo()
			cRetAnexo := ""

			If (cRetAnexo <> Nil .And. !Empty(cRetAnexo))
				::oMensagem:AttachFile(cRetAnexo)
			EndIf
			
			If ::oMensagem:Send(::oServidor) == 0

				ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:Envia() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " - SENDED")

				ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:Envia() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed + " -- Email: " + ::oMensagem:cTo)

				::oServidor:SmtpDisconnect()

				::Inclui()

			EndIf
		
		Else
		
			ConOut( "TAprovaPedidoVendaEMail:Envia() => ERRO ao autenticar: " + str(_nErro,6), ::oServidor:GetErrorString( _nErro ) )

		EndIf

	EndIf

Return()


Method GetTextoTag(cLinha) Class TAprovaPedidoVendaEMail

	Local nI		:= 1
	Local cTexto	:= ""
	Local lIni		:= .F.

	While (nI <= Len(cLinha))

		cNovaLinha := SubStr(cLinha, nI, 1 )

		If (cNovaLinha == '>' .And. SubStr(cLinha, nI+1, 1 ) <> '<')
			lIni := .T.
			nI += 1
		EndIf

		If (lIni .And. cNovaLinha <> '<')
			cNovaLinha := SubStr(cLinha, nI, 1 )
			cTexto += cNovaLinha
		EndIf

		If (lIni .And. cNovaLinha == '<')
			lIni := .F.
		EndIf

		nI += 1

	EndDo

	cTexto := StrTran( cTexto, "&nbsp;", " " )
	cTexto := StrTran( cTexto, "&nbs", " " )
	cTexto := StrTran( cTexto, "=E7", "ç" )
	cTexto := StrTran( cTexto, "=E3", "ã" )

	If !(Empty(cTexto))
		cTexto := cTexto+CRLF
	EndIf

Return cTexto

Method GetTextoHtml(cFile) Class TAprovaPedidoVendaEMail

	Local oFile 	:= FWFileReader():New(cFile)
	Local lBody		:= .F.
	Local cBody		:= ''
	Local cLinha	:= ''

	If (oFile:Open())

		While (oFile:hasLine())

			cLinha := oFile:GetLine()

			If (SubStr(cLinha, -1, 1) == "=")
				cLinha := SubStr(cLinha, 1, Len(cLinha)-1)+oFile:GetLine()
			EndIf

			If ('<body' $ cLinha)
				lBody := .T.
			EndIf

			If (lBody .And. !('<img' $ cLinha))

				if (SubStr(cLinha, -1, 1) == "=")
					cBody += ::GetTextoTag(SubStr(cLinha, 1, Len(cLinha)-1))
				Else
					cBody += ::GetTextoTag(SubStr(cLinha, 1, Len(cLinha)))
				EndIf

			EndIf

			If ('</body>' $ cLinha .Or. '<img' $ cLinha)
				exit
			EndIf

		EndDo

		oFile:Close()

	EndIf

	If (Empty(cBody))
		cBody := ::GetBase64(cFile)
	EndIf

Return cBody


Method GetBase64() Class TAprovaPedidoVendaEMail

	Local cLinha			:= ""
	Local cLinhaCompleta	:= ""
	Local oFile 			:= FWFileReader():New(cFile)

	If (oFile:Open())

		While (oFile:hasLine())

			cLinha := oFile:GetLine()

			If (AllTrim(cLinha) == "Content-Transfer-Encoding: base64")

				cLinhaCompleta := ""
				While (oFile:hasLine())

					cLinha 			:= oFile:GetLine()
					cLinhaCompleta	+= cLinha

					If (Empty(cLinha) .Or. !oFile:hasLine())

						If (;
								Mod(Len(cLinhaCompleta), 4) == 0 .And. ;
								SubStr(cLinhaCompleta, Len(cLinhaCompleta)) == "=" .And.;
								!(cLinhaCompleta $ ":|-+;*");
								)

							cLinhaCompleta := AllTrim(Decode64(cLinhaCompleta))
							exit
						EndIf

						cLinhaCompleta := ""

					EndIf

				EndDo

			EndIf

		EndDo

		oFile:Close()

	EndIf

	nbody	:= At("body", cLinhaCompleta)

	If(nbody > 0)
		nIni	:= At(">", cLinhaCompleta, nBody)+1
		nFim	:= At("<", cLinhaCompleta, nBody)-1

		cLinhaCompleta := SubStr(cLinhaCompleta, nIni, (nFim-nIni))
	EndIf

Return cLinhaCompleta

Method Recebe() Class TAprovaPedidoVendaEMail

	Local nMsg := 0
	Local nTotMsg := 0
	Local nRet
	Local nI
	
	::oServidor:SetUseSSL(::lUseSSL)

	::oServidor:Init(::cSrvPOP, "", ::cContaRec, ::cSenhaRec, ::cPtPOP3, 0)

	nRet := ::oServidor:PopConnect()

	If nRet == 0

		::oServidor:GetNumMsgs(@nTotMsg)

		For nMsg := 1 To nTotMsg

			::oMensagem:Clear()

			::oMensagem:Receive(::oServidor, nMsg)

			If (Empty(::oMensagem:cBody))

				cFile := "\temp\" + cValToChar( nMsg ) + ".eml"
				Conout( "salvando mensagem " + cValToChar( nMsg ) + " to " + cFile )
				::oMensagem:Save( cFile )


				nAttach := ::oMensagem:GetAttachCount()
				For nI := 1 To nAttach
					cAttach := ::oMensagem:GetAttach( nI )
					aAttInfo := ::oMensagem:GetAttachInfo( nI )
					varinfo( "", aAttInfo )

					cName := "\temp\"

					If aAttInfo[1] == ""
						cName += "mensagem"+cvaltochar(nMsg)+"."+ SubStr( aAttInfo[2], At( "/", aAttInfo[2] ) + 1, Len( aAttInfo[2] ) )
					Else
						cName += aAttInfo[1]
					EndIf

					ConOut( "salvando anexos " + cValToChar( nI ) + ": " + cName )

					xRet := ::oMensagem:SaveAttach( nI, cName )
					If xRet == .F.
						ConOut( "Nao e possivel salvar anexos " + cName  )
						loop
					Endif

				Next nI

				::oMensagem:cBody := ::GetTextoHtml(cFile)

				ConOut(::oMensagem:cBody)
			/*If FERASE(cFile) == -1
				ConOut('Falha na deleção do Arquivo')
			Else
				ConOut('Arquivo deletado com sucesso.')
			EndIf
			*/
		EndIf

		ConOut(::oMensagem:cBody)

		ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:Recebe()")

		If ::Valida()

			::VerificaAcao()

		EndIf

		::oServidor:DeleteMsg(nMsg)

	Next

	::oServidor:POPDisconnect()
Else

	conout( nRet )
	conout( ::oServidor:GetErrorString( nRet ) )

EndIf

Return()


Method Valida()	Class TAprovaPedidoVendaEMail

	Local lRet		:= .F.
	Local nI		:= 0
	Local aEmails	:= {}

	::cIDMsg := ::RetIDMsg()

	If !Empty(::cIDMsg) .And. ::Existe()

		If ZC1->ZC1_STATUS == "E"

			aEmails := StrToKArr(AllTrim(ZC1->ZC1_EMAIL+";"+ZC1->ZC1_EMAILT),";")

			For nI := 1 To Len(aEmails)

				If !(Empty(aEmails[nI]))

					If (Lower(AllTrim(aEmails[nI])) $ Lower(::oMensagem:cFrom))

						lRet := .T.

					EndIf
				EndIf

			Next nI

		EndIf

	EndIf

	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TAprovaPedidoVendaEMail:Valida() -- Email: "+ Lower(::oMensagem:cFrom) +" -- Chave: "+ ::cIDMsg + " -- Chave Valida: " + If (lRet, "SIM", "NAO") )

Return(lRet)


Method RetEMailApr() Class TAprovaPedidoVendaEMail

	Local cRet := ""

	If !Empty(::cCodAprT)
		cRet := ::cEmailAprT
	Else
		cRet := ::cEmailApr
	EndIf

Return(cRet)


Method RetNomCli() Class TAprovaPedidoVendaEMail

	Local cRet := ""

	DbSelectArea("SA1")
	DbSetOrder(1)
	If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

		cRet := Capital(AllTrim(SA1->A1_NOME))

		//Ticket 1526 - Fernando - 27/02/2018
		If ( AllTrim(SA1->A1_YCAT) == 'LOJA ESPEC' )

			cRet += " (LOJA ESPECIALIZADA)"

		EndIf

	EndIf

Return(cRet)


Method RetHtmlBody() Class TAprovaPedidoVendaEMail

	Local aArea			:= GetArea()
	
	Local cCRLF
	Local cAliasTmp 	:= GetNextAlias()
	Local cQuery		:= ""
	Local cHTML			:= ""
	Local cLinkAprovar	:= ""
	Local cLinkRecusar	:= ""
	Local cLinkRevisar	:= ""
	Local cSubTp		:= ""
	Local cObservacao	:= ""
	Local nSomaQuant 	:= 0
	Local nSomaPreco	:= 0
	Local nSomaValor	:= 0
	Local nZKLRecNo

	DbSelectArea('SC5')
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial('SC5')+::cNumPed))

	DbSelectArea('SC6')
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial('SC6')+::cNumPed))

	DbSelectArea('SA1')
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

	DbSelectArea('SA3')
	SA3->(DbSetOrder(1))
	SA3->(DbSeek(xFilial('SA3')+SC5->C5_VEND1))

	DbSelectArea('SE4')
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
	
	cCRLF:=CRLF

	//Ticket 30360 - Aumentado o VARCHAR de 1024 para o MAX para contemplar a informação completa
	cQuery += "SELECT ZKL.R_E_C_N_O_ ZKLRECNO "+cCRLF
	cQuery += "  FROM "+ RetSqlName("ZKL")+" ZKL "+cCRLF
	cQuery += " WHERE ZKL.D_E_L_E_T_=''"+cCRLF
	cQuery += "	  AND ZKL.ZKL_PEDIDO= '"+::cNumPed+"'"+cCRLF
	cQuery += "	  AND ZKL.ZKL_FILIAL= '"+xFilial('ZKL')+"'"+cCRLF
	cQuery += "	  AND ZKL.ZKL_STATUS='2'"+cCRLF
	cQuery += "	ORDER BY ZKL.R_E_C_N_O_	"+cCRLF

	TcQuery cQuery New Alias (cAliasTmp)


	cSubTp := Tabela("DJ",Alltrim(SC5->C5_YSUBTP))


	cLinkAprovar 	:= '<a class="btn" href="mailto:'+ ::cEmail +'?subject=Aprovar pedido: '+ ::cNumPed + ' - ACTION:APROVAR - KEY:'+ ::cIDMsg +'">APROVAR</a>'
	cLinkRecusar 	:= '<a class="btn" href="mailto:'+ ::cEmail +'?subject=Recusar pedido: '+ ::cNumPed + ' - ACTION:RECUSAR - KEY:'+ ::cIDMsg +'">RECUSAR</a>'
	cLinkRevisar 	:= '<a class="btn" href="mailto:'+ ::cEmail +'?subject=Revisar pedido: '+ ::cNumPed + ' - ACTION:REVISAR - KEY:'+ ::cIDMsg +'">REVISAR</a>'


	cHTML += ' <!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">																			'
	cHTML += ' <html xmlns="http://www.w3.org/1999/xhtml">                                                                                                                                                        '
	cHTML += ' 	<head>                                                                                                                                                                                          '
	cHTML += ' 	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />                                                                                                                           '
	cHTML += ' 	<title>Workflow</title>                                                                                                                                                                         '
	cHTML += ' 	<style type="text/css">                                                                                                                                                                         '
	cHTML += ' 		body{ font-family: Verdana; font-size: 14px; }                                                                                                                                              '
	cHTML += ' 		a{text-decoration: none;}                                                                                                                                                                   '
	cHTML += ' 		.mainTableCss{ width: 100%;  }                                                                                                                                                              '
	cHTML += ' 		.tblDadosComprador,.tblDadosFornecedor,.tblDadosItens,.tblTotais,.tblDadosTransportadora { border: 1px solid #c6c6c6; padding: 5px; width: 100%; }                                          '
	cHTML += ' 		.mainTableCss tr,.tblDadosComprador tr,.tblDadosFornecedor tr,.tblTotais tr,.tblDadosTransportadora tr{ }                                                                                   '
	cHTML += ' 		.mainTableCss th,.tblDadosComprador th,.tblDadosFornecedor th,.tblDadosItens th,.tblTotais th,.tblDadosTransportadora th{ padding: 10px; }                                                  '
	cHTML += ' 		.mainTableCss td,.tblDadosComprador td,.tblDadosFornecedor td,.tblDadosItens td,.tblTotais td,.tblDadosTransportadora td{ padding: 2px 10px 2px 10px; font-size: 12px; }                    '
	cHTML += ' 		.tblItensPedido td{border-top: 1px solid #c6c6c6; border-bottom: 1px solid #c6c6c6; }                                                                                                       '
	cHTML += ' 		.tblItensPedido-border-left{ border-left: 1px solid #c6c6c6; padding:1px 1px 1px 1px; }                                                                                                     '
	cHTML += ' 		.tblItensPedido-border-right{ border-right: 1px solid #c6c6c6; border-left: 1px solid #c6c6c6; padding:1fpx 1px 1px 1px;}                                                                   '
	cHTML += ' 		.titleCss{ font-size: 14px; }                                                                                                                                                               '
	cHTML += ' 		.obsCss{ font-size: 10px; }                                                                                                                                                                 '
	cHTML += ' 		.titleTable{ background-color: #C6C6C6; font-size: 14px; }                                                                                                                                  '
	cHTML += ' 		.link{ font-size: 16px; font-weight: bold;  color: #fff;}                                                                                                                                                '
	cHTML += ' 		.btn {padding: 10px 10px;line-height: 1.5; color: #fff;text-decoration: none;border-radius: 6px;}                                                                                           '
	cHTML += ' 		.revisar {background-color: #f5db11;}                                                                                                                                                       '
	cHTML += ' 		.aprovar {background-color: #50a75b;}                                                                                                                                                       '
	cHTML += ' 		.recusar {background-color: #f50e18;}                                                                                                                                                       '

	if(Alltrim(SC5->C5_YSUBTP) $ "B_G_D")
		cHTML += ' 		.pedido-detalhe-cor {color: red;}                                                                                                                                   '
	else
		cHTML += ' 		.pedido-detalhe-cor {}                                                                                                                                   '
	endif

	cHTML += ' 		.pedido-detalhe {font-weight: bold; background: #f6f6f6;}                                                                                                                                   '
	cHTML += ' 	</style>		                                                                                                                                                                                '
	cHTML += ' 	</head>                                                                                                                                                                                         '
	cHTML += ' 	<body>	                                                                                                                                                                                        '
	cHTML += ' 		<div>                                                                                                                                                                                       '
	cHTML += ' 			Prezado,                                                                                                                                                                                '
	cHTML += ' 			<br>                                                                                                                                                                                    '
	cHTML += ' 			<br>                                                                                                                                                                                    '
	cHTML += ' 			Segue em anexo pedido de venda para aprovação.                                                                                                                                          '
	cHTML += ' 			<br>                                                                                                                                                                                    '
	cHTML += ' 		                                                                                                                                                                                            '
	cHTML += ' 			<table class="mainTableCss" >                                                                                                                                                           '
	cHTML += ' 			<tr class="">                                                                                                                                                                           '
	cHTML += ' 				<th valign="top" align="center">                                                                                                                                                                   '
	cHTML += ' 							<table width="90%" align="center" cellpadding="4" cellspacing="4">							'
	cHTML += ' 								<tr class="aprovar">	'
	cHTML += ' 									<td align="center">	'

	cHTML += ' 											<span class="link">		'
	cHTML += cLinkAprovar
	cHTML += '											</span>'

	cHTML += ' 		 							</td>	'
	cHTML += ' 								<tr>	'
	cHTML += ' 							</table>	'
	cHTML += ' 				</th>                                                                                                                                                                               '
	cHTML += ' 				<th valign="top" align="center">                                                                                                                                                                   '
	cHTML += ' 							<table width="90%" align="center" cellpadding="4" cellspacing="4">							'
	cHTML += ' 								<tr class="revisar">	'
	cHTML += ' 									<td align="center">	'

	cHTML += ' 											<span class="link">		'
	cHTML += cLinkRevisar
	cHTML += '											</span>'

	cHTML += ' 		 							</td>	'
	cHTML += ' 								<tr>	'
	cHTML += ' 							</table>	'
	cHTML += ' 				</th>                                                                                                                                                                               '
	cHTML += ' 				<th valign="top" align="center">                                                                                                                                                                   '
	cHTML += ' 							<table width="90%" align="center" cellpadding="4" cellspacing="4">							'
	cHTML += ' 								<tr class="recusar">	'
	cHTML += ' 									<td align="center">	'

	cHTML += ' 											<span class="link">		'
	cHTML += cLinkRecusar
	cHTML += '											</span>'

	cHTML += ' 		 							</td>	'
	cHTML += ' 								<tr>	'
	cHTML += ' 							</table>	'
	cHTML += ' 				</th>                                                                                                                                                                               '

	cHTML += ' 		                                                                                                                                                                                            '
	cHTML += ' 			<tr>                                                                                                                                                                                    '
	cHTML += ' 				<td colspan="3" valign="top">                                                                                                                                                       '
	cHTML += ' 					<table class="tblDadosItens" cellpadding="4" cellspacing="4">                                                                                                                   '
	cHTML += ' 						<tr class="titleTable"><th>PEDIDO DE VENDA</th></tr>                                                                                                                        '
	cHTML += ' 						<tr>                                                                                                                                                                        '
	cHTML += ' 							<td>                                                                                                                                                                    '
	cHTML += ' 								<table width="100%" class="tblItensPedido" cellpadding="0" cellspacing="0">                                                                                         '
	
	cHTML += ' 									 <tr style="color: red;">                                                                                                                                                           '
	cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> TIPO BLOQUEIO(S): </td>                                                                                   '
	cHTML += ' 										<td colspan="3" align="left"> '+::RetMotBlq()+' </td>                                                                                                                                   '
	cHTML += ' 									 </tr>                                                                                                                                                          '
	
	_cMotivoRej := ""
	While !SC6->(Eof())  .And. SC6->C6_FILIAL == xFilial('SC6') .AND. SC6->C6_NUM == ::cNumPed
		
		If (!Empty(SC6->C6_YMOTFRA))
			DbSelectArea('PZ7')
			PZ7->(DbSetOrder(1))
			If (PZ7->(DbSeek(xFilial('PZ7')+SC6->C6_YMOTFRA)))
				If(!Empty(_cMotivoRej))
					_cMotivoRej += "/"
				EndIf
				_cMotivoRej += PZ7->PZ7_DESCRI 
			EndIf
		EndIf		
		SC6->(DbSkip())
	EndDo
	
	
	If (!Empty(_cMotivoRej))
		cHTML += ' 									 <tr style="color: red;">                                                                                                                                                           '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> MOTIVO REJEIÇÃO: </td>                                                                                   '
		cHTML += ' 										<td colspan="3" align="left"> '+_cMotivoRej+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>                                                                                                                                                          '
	EndIf
	
	SC6->(DbGoTop())
	
	
	cHTML += ' 									 <tr>                                                                                                                                                           '
	cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> NÚMERO: </td>                                                                                          '
	cHTML += ' 										<td align="left"> '+SC5->C5_NUM+' </td>                                                                                                                     '
	cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> EMISSÃO: </td>                                                                                          '
	cHTML += ' 										<td align="left"> '+cvaltochar(DTOC(SC5->C5_EMISSAO))+' </td>                                                                                               '
	cHTML += ' 									 </tr>                                                                                                                                                          '

	cHTML += ' 									 <tr>                                                                                                                                                           '
	cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> CLIENTE: </td>                                                                                         '
	cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NOME)+ ", " + AllTrim(SA1->A1_MUN) + " - " + AllTrim(SA1->A1_EST) + ' </td>      '
	cHTML += ' 									 </tr>                                                                                                                                                          '


	If (::lBlqCondPag)
		
		cHTML += ' 									  <tr style="color: red;">                                                                                                                                                          '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> COND.DE PAG: </td>                                                                           '
		cHTML += ' 										<td align="left"> '+AllTrim(SE4->E4_DESCRI)+' </td>                                                                                                                                   '
		
		DbSelectArea('SE4')
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+SA1->A1_COND))
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> COND.DE PAG. CAD.: </td>                                                                           '
		cHTML += ' 										<td align="left"> '+AllTrim(SE4->E4_DESCRI)+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>  
		                                                                                                                                                        '
	Else
	
		cHTML += ' 									  <tr>                                                                                                                                                          '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> CONDIÇÃO DE PAGAMENTO: </td>                                                                           '
		cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SE4->E4_DESCRI)+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>     
		                                                                                                                                                     '
	EndIf
	
	
	cHTML += ' 									  <tr>                                                                                                                                                          '
	cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> TIPO PEDIDO: </td>                                                                           '
	if(!Empty(STR(SC5->C5_YPRZINC)) .And. SC5->C5_YPRZINC > 0)
		cHTML += ' 										<td colspan="1" align="left" class="pedido-detalhe-cor"> '+AllTrim(cSubTp)+' </td>                                                                                                                                   '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> Incr. Vencimento: </td>                                                                                          '
		cHTML += ' 										<td align="left"> '+ STR(SC5->C5_YPRZINC)+' dias </td>  
	else
		cHTML += ' 										<td colspan="3" align="left" class="pedido-detalhe-cor"> '+AllTrim(cSubTp)+' </td>                                                                                                                                   '
	endif
	cHTML += ' 									 </tr>                                                                                                                                                          '

	cHTML += ' 									  <tr>                                                                                                                                                          '
	cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> VENDEDOR: </td>                                                                           '
	if !Empty(DTOS(SC5->C5_YDTINC))
		cHTML += ' 										<td colspan="1" align="left"> '+AllTrim(SA3->A3_COD)+" - "+AllTrim(SA3->A3_NREDUZ)+' </td>                                                                                                                                   '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> Data Incremento: </td>                                                                                          '
		cHTML += ' 										<td align="left"> '+ DTOS(SC5->C5_YDTINC)+' </td>  
	else
		cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SA3->A3_COD)+" - "+AllTrim(SA3->A3_NREDUZ)+' </td>                                                                                                                                   '
	endif
	cHTML += ' 									 </tr>                                                                                                                                                          '

	
	If (!Empty(SC5->C5_YOBS))
		cHTML += ' 									 <tr>                                                                                                                                                           '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> OBSERVAÇÃO: </td>                                                                                   '
		cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SC5->C5_YOBS)+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>                                                                                                                                                          '
	EndIf


	If (!Empty(SC5->C5_YOBDCOU))
		cHTML += ' 									 <tr>                                                                                                                                                           '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> OBS. DESC. OUTROS: </td>                                                                                   '
		cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SC5->C5_YOBDCOU)+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>                                                                                                                                                          '
	EndIf

	If (!Empty(SC5->C5_YNOUTAI))
		cHTML += ' 									 <tr>                                                                                                                                                           '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> Nº AI OUTRAS: </td>                                                                                   '
		cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SC5->C5_YNOUTAI)+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>                                                                                                                                                          '
	EndIf

	If (!Empty(SC5->C5_YCLVL))
		cHTML += ' 									 <tr>                                                                                                                                                           '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> COD. CL VALOR: </td>                                                                                   '
		cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SC5->C5_YCLVL)+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>                                                                                                                                                          '
	EndIf

	If (!Empty(SC5->C5_YITEMCT))
		cHTML += ' 									 <tr>                                                                                                                                                           '
		cHTML += ' 										<td align="left" width="20%" class="pedido-detalhe"> ITEM CONTAB.: </td>                                                                                   '
		cHTML += ' 										<td colspan="3" align="left"> '+AllTrim(SC5->C5_YITEMCT)+' </td>                                                                                                                                   '
		cHTML += ' 									 </tr>                                                                                                                                                          '
	EndIf


	cHTML += ' 									                                                                                                                                                                '
	cHTML += ' 								</table>                                                                                                                                                            '
	cHTML += ' 							</td>                                                                                                                                                                   '
	cHTML += ' 						</tr>                                                                                                                                                                       '
	cHTML += ' 					</table>                                                                                                                                                                        '
	cHTML += ' 				</td>                                                                                                                                                                               '
	cHTML += ' 			</td>                                                                                                                                                                                   '
	cHTML += ' 			<tr>                                                                                                                                                                                    '
	cHTML += ' 				<td>                                                                                                                                                                                '
	cHTML += ' 				</td>                                                                                                                                                                               '
	cHTML += ' 			</tr>                                                                                                                                                                                   '
	cHTML += ' 			<tr>                                                                                                                                                                                    '
	cHTML += ' 				<td colspan="3" valign="top">                                                                                                                                                       '
	cHTML += ' 					<table class="tblDadosItens">                                                                                                                                                   '
	cHTML += ' 						<tr class="titleTable"><th>ITENS DO PEDIDO DE VENDA</th></tr>                                                                                                               '
	cHTML += ' 						<tr>                                                                                                                                                                        '
	cHTML += ' 							<td>                                                                                                                                                                    '
	cHTML += ' 								<table width="100%" class="tblItensPedido" cellpadding="0" cellspacing="0">                                                                                         '
	cHTML += ' 									 <tr>                                                                                                                                                           '
	cHTML += ' 										<th> CODIGO </th>                                                                                                                                           '
	cHTML += ' 										<th> DESCRIÇÃO </th>                                                                                                                                        '
	cHTML += ' 										<th> UN </th>                                                                                                                                               '
	cHTML += ' 										<th> QUANTIDADE </th>                                                                                                                                       '
	cHTML += ' 										<th> PREÇO </th>                                                                                                                                            '
	cHTML += ' 										<th> TOTAL </th>                                                                                                                                            '
	cHTML += ' 										<th> PALETIZADO %</th>                                                                                                                                       '
	cHTML += ' 										<th> POLÍTICA %</th>                                                                                                                                       	'

	//Ticket 23392 - Pablo S. Nascimento: Solicitação Claudeir para ajustes no layout
	//configurar variaveis para saber se iremos imprimir a coluna apenas se algum dos itens tiver valor.
	cYDNV 	:= 0
	cYDACO 	:= 0
	cYDVER	:= 0
	cYDAI 	:= 0
	nYDFRA 	:= 0

	_cARejeicao		:= ""
	_cAExclusivo	:= ""
	_lNaoPalete		:= .F.
	
	DbSelectArea('SC6')
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial('SC6')+::cNumPed))
	
	while !SC6->(Eof())  .And. SC6->C6_FILIAL == xFilial('SC6') .AND. SC6->C6_NUM == ::cNumPed
		cYDNV 	:= cYDNV + SC6->C6_YDNV
		cYDACO 	:= cYDACO + SC6->C6_YDACO
		cYDVER 	:= cYDVER + SC6->C6_YDVER
		cYDAI 	:= cYDAI + SC6->C6_YDAI
		nYDFRA 	:= nYDFRA + SC6->C6_YDFRA
		
		
		If (!_lNaoPalete)
			aRetPalete := StaticCall( FROPGA02, CalcPalete, SC6->C6_QTDVEN)
			If (aRetPalete[2] <> SC6->C6_QTDVEN)
				_lNaoPalete := .T.
			EndIf
		EndIf
		
		If (AllTrim(_cARejeicao) =="")
			_cARejeicao := IIF(!Empty(SC6->C6_YMOTREJ) .Or. !Empty(SC6->C6_YMOTFRA), 'X', '')
		EndIf
		
		
		cYEXCL := Posicione('SB1',1,xFilial('SB1')+SC6->C6_PRODUTO, 'B1_YEXCL') 
		
		If (AllTrim(_cAExclusivo) == "")
			If (cYEXCL == 'H' .And. AllTrim(SA1->A1_YTPSEG) <> 'E')
				_cAExclusivo := AllTrim(NGRetSX3Box("B1_YEXCL", cYEXCL))
			EndIf
			
			If (cYEXCL == 'E' .And. AllTrim(SA1->A1_YCAT) <> 'LOJA ESPEC')
				_cAExclusivo := AllTrim(NGRetSX3Box("B1_YEXCL", cYEXCL))
			EndIf
		EndIf
		
		conout("_lNaoPalete: "+cvaltochar(_lNaoPalete)+", _cAExclusivo:"+_cAExclusivo+", _cARejeicao:"+_cARejeicao)

	
		SC6->(DbSkip())

	EndDo()
	
	conout("_lNaoPalete: "+cvaltochar(_lNaoPalete)+", _cAExclusivo:"+_cAExclusivo+", _cARejeicao:"+_cARejeicao)
		
	
	DbSelectArea('SC6')
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial('SC6')+::cNumPed))

	If(cYDNV > 0)
		cHTML += ' 										<th> NORMA % </th>                                                                                                                                       		'
	EndIf

	If(cYDACO > 0)
		cHTML += ' 										<th>   AO % </th>   	                                                                                                                                    	'
	EndIf

	If(cYDVER > 0)
		cHTML += ' 										<th> VERBA % </th>                                                                                                                                       		'
	EndIf

	If(cYDAI > 0)
		cHTML += ' 										<th>   AI % </th>   	                                                                                                                                    	'
	EndIf
	
	If(nYDFRA > 0)
		cHTML += ' 										<th>   Fra. % </th>   	                                                                                                                                    	'
	EndIf
	
	cHTML += ' 										<th> OUTROS % </th>        
	
	cHTML += ' 										<th> DT. ENT. </th>        
	cHTML += ' 										<th> DT. NECE. </th>    
	
	If (AllTrim(SA1->A1_YTPSEG) == 'E')
		cHTML += ' 										<th> DT.NEC.REAL </th>
	EndIf
	
	If (AllTrim(_cARejeicao) != "")    
		cHTML += ' 										<th> REJEIÇÃO % </th>        
	EndIf
	
	If (AllTrim(_cAExclusivo) != "")   
		cHTML += ' 										<th> PROD. EXCLUSIVO </th>                                                                                                                                  '
	EndIf
	
	If (_lNaoPalete)
		cHTML += ' 										<th> DESPALETIZADO </th>                                                                                                                                  '
	EndIf
	
	cHTML += ' 									 </tr>                                                                                                                                                          '
	cHTML += ' 		                                                                                                                                                                                            '

	
	//ITENS
	While !SC6->(Eof())  .And. SC6->C6_FILIAL == xFilial('SC6') .AND. SC6->C6_NUM == ::cNumPed

		cHtml += '							 <tr>
		cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(SC6->C6_PRODUTO) +'</td>
		cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(SC6->C6_DESCRI) +'</td>
		cHtml += '								<td align="left" class="tblItensPedido-border-left">'+ Alltrim(SC6->C6_UM) +'</td>
		cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_QTDVEN	,"@E 999,999,999.99") +'</td>
		cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_PRCVEN	,"@E 999,999,999.99") +'</td>
		cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_VALOR, "@E 999,999,999.99") +'</td>
		cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_YDPAL, "@E 999.99") +' %</td>
		cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_YPERC, "@E 999.99") +' %</td>

		If(cYDNV > 0)
			cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_YDNV, "@E 999.99") +' %</td>
		EndIf

		If(cYDACO > 0)
			cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_YDACO, "@E 999.99") +' %</td>
		EndIf

		If(cYDVER > 0)
			cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_YDVER, "@E 999.99") +' %</td>
		EndIf

		If(cYDAI > 0)
			cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_YDAI, "@E 999.99") +' %</td>
		EndIf
		
		If(nYDFRA > 0)
			cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(SC6->C6_YDFRA, "@E 999.99") +' %</td>
		EndIf
		
		cHtml += '								<td align="right" class="tblItensPedido-border-right">'+ TRANSFORM(SC6->C6_YDESP, "@E 999,999,999.99") +' %</td>
		
		cHtml += '								<td align="right" class="tblItensPedido-border-right">'+cvaltochar(DTOC(SC6->C6_ENTREG)) +' </td>
		cHtml += '								<td align="right" class="tblItensPedido-border-right">'+cvaltochar(DTOC(SC6->C6_YDTNECE)) +' </td>
		
		If (AllTrim(SA1->A1_YTPSEG) == 'E')
			cHTML += ' 							<td align="right" class="tblItensPedido-border-right">'+cvaltochar(DTOC(SC6->C6_YDTNERE)) +' </td>
		EndIf
		
		If (AllTrim(_cARejeicao) != "")    
			cHtml += '								<td align="right" style="color: red;" class="tblItensPedido-border-right">'+IIF(!Empty(SC6->C6_YMOTREJ) .Or. !Empty(SC6->C6_YMOTFRA), 'X', '') +' </td>
		EndIf
		
		cYEXCL := Posicione('SB1',1,xFilial('SB1')+SC6->C6_PRODUTO, 'B1_YEXCL') 
		
		_cExclusivo := ""
		If (cYEXCL == 'H' .And. AllTrim(SA1->A1_YTPSEG) <> 'E')
			_cExclusivo := AllTrim(NGRetSX3Box("B1_YEXCL", cYEXCL))
		EndIf
		
		If (cYEXCL == 'E' .And. AllTrim(SA1->A1_YCAT) <> 'LOJA ESPEC')
			_cExclusivo := AllTrim(NGRetSX3Box("B1_YEXCL", cYEXCL))
		EndIf
		
		If (AllTrim(_cAExclusivo) != "")   
			cHtml += '								<td align="right" style="color: red;" class="tblItensPedido-border-right">'+_cExclusivo +' </td>
		EndIf
		
		If (_lNaoPalete)
			
			aRetPalete := StaticCall(FROPGA02, CalcPalete, SC6->C6_QTDVEN)
			cHtml += '								<td align="right" style="color: red;" class="tblItensPedido-border-right">'+IIf (aRetPalete[2] <> SC6->C6_QTDVEN, 'X', '')+'</td>
		EndIf
		
		cHtml += '							 </tr>'

		
		nSomaQuant += SC6->C6_QTDVEN
		nSomaPreco += SC6->C6_PRCVEN
		nSomaValor += SC6->C6_VALOR

		SC6->(DbSkip())

	EndDo()

	cHtml += '							 <tr>
	cHtml += '								<td class="tblItensPedido-border-left" colspan="13"></td>
	//cHtml += '								<td align="right" class="tblItensPedido-border-right"></td>
	cHtml += '							 </tr>'

	cHtml += '							 <tr>
	cHtml += '								<td class="tblItensPedido-border-left" colspan="3">Totais: </td>
	cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(nSomaQuant	,"@E 999,999,999.99") +'</td>
	cHtml += '								<td align="right" class="tblItensPedido-border-left">    </td>
	cHtml += '								<td align="right" class="tblItensPedido-border-left">'+ TRANSFORM(nSomaValor, "@E 999,999,999.99") +'</td>
	cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>

	If(cYDNV > 0)
		cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>
	EndIf

	If(cYDACO > 0)
		cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>
	EndIf

	If(cYDVER > 0)
		cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>
	EndIf

	If(cYDAI > 0)
		cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>
	EndIf
	
	If(nYDFRA > 0)
		cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>
	EndIf

	If (AllTrim(_cARejeicao) != "")    
		cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>
	EndIf
	
	If (AllTrim(_cAExclusivo) != "")   
		cHtml += '								<td align="right" class="tblItensPedido-border-left"></td>
	EndIf
	
	If (_lNaoPalete)
		cHtml += '								<td align="right" class="tblItensPedido-border-right"></td>
	EndIf
	
	cHtml += '							 </tr>'

	cHTML += '                                                                                                                                                                                                    '
	cHTML += ' 								</table>                                                                                                                                                            '
	cHTML += ' 							</td>                                                                                                                                                                   '
	cHTML += ' 						</tr>                                                                                                                                                                       '
	cHTML += ' 					</table>                                                                                                                                                                        '
	cHTML += ' 		                                                                                                                                                                                            '
	cHTML += ' 				</td>                                                                                                                                                                               '
	cHTML += ' 			</tr>                                                                                                                                                                                   '
	cHTML += '                                                                                                                                                                                                    '
	cHTML += ' 			<tr>                                                                                                                                                                                    '
	cHTML += ' 				<td>                                                                                                                                                                                '
	cHTML += ' 				</td>                                                                                                                                                                               '
	cHTML += ' 			</tr>                                                                                                                                                                                   '
	cHTML += ' 			<tr>                                                                                                                                                                                    '
	cHTML += ' 				<td colspan="3" valign="top">

	If ((cAliasTmp)->(!Eof()))

		cHTML += ' 					<table class="tblDadosItens">                                                                                                                                                   '
		cHTML += ' 						<tr class="titleTable"><th>Log Bloqueio do Pedido</th></tr>                                                                                                               '
		cHTML += ' 						<tr>                                                                                                                                                                        '
		cHTML += ' 							<td>                                                                                                                                                                    '
		cHTML += ' 								<table width="100%" class="tblItensPedido" cellpadding="0" cellspacing="0">                                                                                         '
		cHTML += ' 									 <tr>                                                                                                                                                           '
		cHTML += ' 										<th> APROVADOR </th>                                                                                                                                           '
		cHTML += ' 										<th> DATA </th>                                                                                                                                        '
		cHTML += ' 										<th> HORA </th>                                                                                                                                               '
		cHTML += ' 										<th> AÇÃO </th>                                                                                                                                       '
		cHTML += ' 										<th> ORDEM </th>                                                                                                                                            '
		cHTML += ' 										<th> NIVEL </th>                                                                                                                                            '
		cHTML += ' 										<th> OBS. </th>                                                                                                                                            '
		cHTML += ' 									 </tr>                                                                                                                                                          '
		cHTML += ' 		                                                                                                                                                                                            '

		//ITENS
		While (cAliasTmp)->(!Eof())

			nZKLRecNo:=(cAliasTmp)->ZKLRECNO
			ZKL->(dbGoTo(nZKLRecNo))

			cObservacao:=ZKL->ZKL_OBS
			cObservacao:=SQLStripHTML():StripHTML(cObservacao)
			aObservacao:=StrToKArr2(cObservacao,CRLF)
			cObservacao:=""
			aEval(aObservacao,{|c|if(!empty(c),cObservacao+=(c+CRLF),nil)})

			cHtml += '							 <tr>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(UsrRetName(ZKL->ZKL_APROV)) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ DTOC(ZKL->ZKL_DATA) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ Alltrim(ZKL->ZKL_HORA) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ AllTrim(NGRetSX3Box("ZKL_ACAO", ZKL->ZKL_ACAO)) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ AllTrim(ZKL->ZKL_ORDEM) +'</td>
			cHtml += '								<td class="tblItensPedido-border-left">'+ AllTrim(NGRetSX3Box("ZKL_NIVEL",ZKL->ZKL_NIVEL))+' </td>
			cHtml += '								<td class="tblItensPedido-border-right">'+ AllTrim(cObservacao)+' </td>
			cHtml += '							 </tr>'

			(cAliasTmp)->(DbSkip())

		EndDo()

		cHTML += '                                                                                                                                                                                                    '
		cHTML += ' 								</table>                                                                                                                                                            '
		cHTML += ' 							</td>                                                                                                                                                                   '
		cHTML += ' 						</tr>                                                                                                                                                                       '
		cHTML += ' 					</table>


	EndIf

	(cAliasTmp)->(DbCloseArea())

	'
	cHTML += ' 				</td>                                                                                                                                                                               '
	cHTML += ' 			</tr>                                                                                                                                                                                   '
	cHTML += '                                                                                                                                                                                                    '
	cHTML += ' 		</table>                                                                                                                                                                                    '
	cHTML += '                                                                                                                                                                                                    '
	cHTML += ' 		</div>                                                                                                                                                                                      '
	cHTML += ' 	</body>                                                                                                                                                                                         '
	cHTML += ' </html>	                                                                                                                                                                                        '

	RestArea(aArea)

Return(cHTML)


Method RetHtml() Class TAprovaPedidoVendaEMail

	Local cRet 	:= ""
	cRet += ::RetHtmlBody()

Return(cRet)


Method RetAnexo() Class TAprovaPedidoVendaEMail

	Local cRet := ""
	Local cOpcao :=	"6;0;1;Pedido de Venda"

	cRet := U_BIACallCrys("PEDIDO_MAIL", cEmpAnt +";"+ ::cNumPed, cOpcao, .T., .F., .T., .T.)

Return(cRet)


Method RetIDMsg() Class TAprovaPedidoVendaEMail

	Local cRet := ""

	If 'KEY:' $ ::oMensagem:cSubject

		cRet := SubStr(AllTrim(::oMensagem:cSubject), At('KEY:', ::oMensagem:cSubject) + 3, 32)

	EndIf

Return(cRet)


Method RetAcaoMsg() Class TAprovaPedidoVendaEMail

	Local cRet := ""

	If 'ACTION:' $ ::oMensagem:cSubject

		cRet := SubStr(AllTrim(::oMensagem:cSubject), At('ACTION:', ::oMensagem:cSubject) + 6, 7)

	EndIf

Return(cRet)

Method RetMotBlq() Class TAprovaPedidoVendaEMail

	Local cRet 		:= ""
	Local aRegras	:= {}
	Local nI		:= 0


	oPedAprov := TPedidoAprovador():New(::cNumPed)
	cIdZKL := oPedAprov:GetIdAprov()

	If (!Empty(cIdZKL))

		DbSelectArea("ZKL")
		ZKL->(DbGoto(cIdZKL))

		aRegras := StrTokArr(ZKL->ZKL_REGRA, "/")

		For nI := 1 To Len (aRegras)

			DbSelectArea("ZKI")
			ZKI->(DbSetOrder(1))

			If (ZKI->(DbSeek(xFilial('ZKI')+aRegras[nI])))

				If (!Empty(cRet))
					cRet += "/"
				EndIf
				
				cRet += ZKI->ZKI_DESBLQ
				
				If (AllTrim(ZKI->ZKI_TPBLQ) == 'D')
					::lBlqCondPag	:= .T.
				EndIf
				
			EndIf

		Next nI

	EndIf


Return(cRet)
