#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAprovaProcessoEmail
@author Filipe Bittencourt
@since 29/09/2021
@version 1.0
@description Classe para controle de aprovação de pedidos de compra por e-mail - baseado no TAprovaPedidoVendaEMail
@type class
/*/

Class TAprovaProcessoEmail From LongClassName

	//DADOS PARA CONFIGURAÇÃO DO EMAIL
	Data oMensagem
	Data oServidor
	Data cSrvSMTP
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
	Method EnviaEmail()

	Method Inclui()
	Method Exclui()
	Method Atualiza()
	Method Existe()
	Method Recusar()
	Method RetHtml()

	Method Recebe()
	Method RecebeManual(_cIDMSG, _cACTION)
	Method Valida()
	Method RetEMailApr()
	Method RetNomFor()
	Method RetIDMsg()
	Method RetHtmlBody()
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


Method New() Class TAprovaProcessoEmail


	::oServidor := TMailManager():New()
	::oMensagem := TMailMessage():New()

	::cSrvSMTP	:= SubStr(GetMv("MV_RELSERV"),1,RAT(':',GetMv("MV_RELSERV"))-1)
	::cSrvPOP	  := SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)
	::cConta   	:= "aprova.processo@biancogres.com.br" //GetMv("MV_YPCCTAP")
	::cSenha 	  := "gBmS%j1S"                          //GetMv("MV_YPCSNAP")
	::cEmail 	  := "aprova.processo@biancogres.com.br" //GetMv("MV_YPCCTAP")
	::lUseTLS 	:= GetMv("MV_RELTLS")
	::lUseSSL 	:= GetMv("MV_RELSSL")
	::lUseAUT 	:= GetMv("MV_RELAUTH")
	::cPtSMTP   := Val(SubStr(GetMv("MV_RELSERV"),RAT(':',GetMv("MV_RELSERV"))+1,Len(Alltrim(GetMv("MV_RELSERV")))))
	::cPtPOP3   := Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP")))))

	::cContaRec := "aprova.processo@biancogres.com.br" //GetMv("MV_YPCCTAP")
	::cSenhaRec := "gBmS%j1S"                         //GetMv("MV_YPCSNAP")

	::cIDMsg    := ""
	::cAction   := ""

Return()


Method EnviaEmail() Class TAprovaProcessoEmail

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

			_nErro := ::oMensagem:Send( ::oServidor )

			If(_nErro != 0)

				ConOut( "TAprovaProcessoEmail:Envia() => ERRO ao enviar e-mail: " + ::oServidor:GetErrorString( _nErro ) )

			Else

// COLOCAR ERRO AQUI OU RETORNAR A MSG

			EndIf

		Else

			ConOut( "TAprovaProcessoEmail:Envia() => ERRO ao autenticar: " + str(_nErro,6), ::oServidor:GetErrorString( _nErro ) )

		EndIf

		::oServidor:SmtpDisconnect()

	EndIf

Return()


Method RetIDMsg() Class TAprovaProcessoEmail

	Local cRet := ""

	If 'KEY:' $ ::oMensagem:cSubject

		cRet := SubStr(AllTrim(::oMensagem:cSubject), At('KEY:', ::oMensagem:cSubject) + 3, 32)

	EndIf

	If 'ACTION:' $ ::oMensagem:cSubject

		::cAction := SubStr(AllTrim(::oMensagem:cSubject), At('ACTION:', ::oMensagem:cSubject) + 6, 6)

	EndIf

Return(cRet)

Method Inclui() Class TAprovaProcessoEmail

Return()

Method Exclui() Class TAprovaProcessoEmail

	RecLock("ZC1", .F.)

	ZC1->(DbDelete())

	MsUnlock()

Return()

Method Atualiza() Class TAprovaProcessoEmail

	If ::Existe()

		RecLock("ZC1", .F.)

		ZC1->ZC1_DATREC := dDataBase
		ZC1->ZC1_STATUS := "R"

		ZC1->(MsUnlock())

	EndIf

Return()

Method Existe() Class TAprovaProcessoEmail

	Local lRet := .F.

	DbSelectArea("ZC1")
	DbSetOrder(1)
	lRet := ZC1->(DbSeek(xFilial("ZC1") + ::cIDMsg)) .And. ZC1->ZC1_TIPDOC == "PC"

	If !lRet

		lRet := ZC1->(DbSeek(xFilial("ZC1") + ::cIDMsg)) .And. ZC1->ZC1_TIPDOC == "MC"

	EndIf

Return(lRet)

Method RetHtml() Class TAprovaProcessoEmail

	Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cRet += '<head>'
	cRet += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
	cRet += ' <title>Workflow</title>'
	cRet += '</head>'
	cRet += '<body>'

	cRet += ::RetHtmlBody()

	cRet += '</body>'
	cRet += '</html>'

Return(cRet)

Method RetHtmlBody() Class TAprovaProcessoEmail
Return()
