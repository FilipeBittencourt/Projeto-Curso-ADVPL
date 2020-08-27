#include "PROTHEUS.CH"
#include "AP5MAIL.CH"
//
//
User Function EnvEmail(aUsu) //(cPara, cAssunto, cMsg, xAnexo)
	Local cServidor   := AllTrim(GetMv("MV_RELSERV"))
	Local cConta      := AllTrim(GetMv("MV_RELACNT"))
	Local cContaSenha := AllTrim(GetMv("MV_RELPSW"))
	Local cUsuarioAut := AllTrim(GetMv("MV_RELAUSR"))
	Local cSenhaAut   := AllTrim(GetMv("MV_RELAPSW"))
	Local cDe         := AllTrim(GetMv("MV_RELFROM"))
	Local lAut        := GetMv("MV_RELAUTH")
	Local lSSL        := GetMv("MV_RELSSL")
	Local lTSL        := GetMv("MV_RELTLS" )
	Local nTimeOut    := GetMv("MV_RELTIME")
	Local nPorta      := 0
	Local nX          := 0
	Local oGerencia, oEmail
	Local nErro, nPosPorta

	If Empty(aUsu)
		ConOut("aUsu vazio.")
		Return .F.
	End If

	cUsuarioAut := If(Empty(cUsuarioAut), cConta, cUsuarioAut)
	cSenhaAut   := If(Empty(cSenhaAut), cContaSenha, cSenhaAut)
	cDe         := If(Empty(cDe), "workflow@protheus.com.br", cDe)
	nTimeOut    := If(Empty(nTimeOut), 120, nTimeOut)
	nPosPorta   := At(":", cServidor)

	If nPosPorta > 0
		nPorta    := Val(AllTrim(SubStr(cServidor, nPosPorta + 1)))
		cServidor := SubStr(cServidor, 1, nPosPorta - 1)
	End If

	oGerencia := TMailManager():New()

	If Empty(nPorta)
		Do Case
		Case lTSL
			nPorta := 587
		Case !lTSL .And. lSSL
			nPorta := 465
		OtherWise
			nPorta := 25
		End Case
	End If

	If lTSL
		oGerencia:SetUseTLS(lTSL)
	ElseIf lSSL
		oGerencia:SetUseSSL(lSSL)
	End If

	oGerencia:Init("", cServidor, cConta, cContaSenha, 0, nPorta)
	oGerencia:SetSmtpTimeOut(nTimeOut)

	ConOut('Conectando ao SMTP')

	nErro := oGerencia:SmtpConnect()

	If nErro <> 0
		ConOut("ERRO: " + oGerencia:GetErrorString(nErro))
		oGerencia:SMTPDisconnect()
		Return .F.
	End If

	If lAut
		ConOut('Autenticando no SMTP')

		nErro := oGerencia:SMTPAuth(cUsuarioAut, cSenhaAut)

		If nErro <> 0
			ConOut("ERRO:" + oGerencia:GetErrorString(nErro))
			oGerencia:SMTPDisconnect()
			Return .F.
		Endif
	End If

	For nX := 1 To Len(aUsu)
		oEmail := TMailMessage():New()
		oEmail:Clear()
		oEmail:cFrom    := cDe
		oEmail:cTo      := aUsu[nX,01]
		oEmail:cCc      := ""
		oEmail:cSubject := aUsu[nX,02]
		oEmail:cBody    := aUsu[nX,03]

		If !Empty(aUsu[nX,04])
			nErro := oEmail:AttachFile(aUsu[nX,04])
			If nErro <> 0
				ConOut("Erro ao atachar o arquivo")
			End If
		End If

		If Empty(nErro)
			nErro := oEmail:Send(oGerencia)
			If nErro <> 0
				ConOut("ERRO:" + oGerencia:GetErrorString(nErro))
			Endif
		End If
	Next nX

	ConOut("Desconectando do SMTP")

	oGerencia:SMTPDisconnect()
Return .T.
