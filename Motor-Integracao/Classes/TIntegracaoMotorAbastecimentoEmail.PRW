#include "TOTVS.CH"
 

CLASS TIntegracaoMotorAbastecimentoEmail From LongClassName

    Data oJSon

    Method New() CONSTRUCTOR
    Method EnvEmail(oJSEmail)     

ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoEmail
    ::oJSon := JsonObject():New() 
Return self
 

METHOD EnvEmail(oJSEmail) CLASS TIntegracaoMotorAbastecimentoEmail
 
    Local oEmail      := TMailManager():New()
    Local cServidor   := "gmail.smtp.com"
    Local cConta      := "fsbvieira@gmail.com"
    Local cContaSenha := "123456"

    Local cFrom        := "fsbvieira@gmail.com"  
    Local cSubject     := "Erro WS Pedido de compra POST - Metodo"

    Local nPorta      := 587  //587, 465 ou 25 
    Local nTimeOut    := 40 // segundos
    Local nErro       := 0
    Local lTSL        := .T.
    Local lSSL        := .T.
    Local cBody       := ""

  
    cBody := "<html>"
    cBody += "<body>"
    cBody += "<BR><BR><BR>"
    cBody += "pedidocompra - POST METHOD<BR>"

    cBody += "[INFO ][SERVER] [Thread 8172] JOB Thread finished<BR>"
    cBody += "Processo nõo concluido. Verificar arquivo!error.log<BR>"
    cBody += "                        Automatic routine ended with error<BR>"
    cBody += "Error: Erro no Gatilho: C7_DATPRF<BR>"
    cBody += "type mismatch on -<BR>"
    cBody += "Tabela SC7 09/09/20 19:12:04<BR>"
    cBody += "                    - aValores[3] :=             0<BR>"
    cBody += "                    - aValores[4] :=             0<BR>"
    cBody += "                    - aValores[7] :=             0<BR>"
    cBody += "                    - cMsg        :=COMPRA REALIZADA PELO MOTOR DE ABASTECIMENTO CITEL VIA WEBSERVICE < -- Invalido<BR>"
    cBody += "                    - cReajuste   :=             0<BR>
    cBody += "--------------------------------------------------------------------------------"


    cBody += "<BR><BR>"
    cBody += "Error: Erro no Gatilho : C7_DATPRF<BR>"
    cBody += "type mismatch on -<BR>"
    cBody += "Tabela SC7 09/09/20 19:12:04<BR>"
                        cBody += "- aValores[3] :=             0<BR>" 
                        cBody += "- aValores[4] :=             0<BR>"
                        cBody += "- aValores[7] :=             0<BR>"
                        cBody += "- cMsg        :=COMPRA REALIZADA PELO MOTOR DE ABASTECIMENTO CITEL VIA WEBSERVICE < -- Invalido<BR>" 
                        cBody += "- cReajuste   :=             0<BR>"
    cBody += "</body>"
    cBody += "</html>"	

    oEmail:cFrom    := cFrom
    oEmail:cTo      := "filipe.bittencourt@gmail.com"
    oEmail:cCc      := ""
    oEmail:cSubject := cSubject
    oEmail:cBody    := cBody	
	
    If lTSL
	    oEmail:SetUseTLS(lTSL)	
    Else
        oEmail:SetUseSSL(lSSL)	
    EndIf
    
	

	ConOut('Conectando ao SMTP')
	oEmail:Init("", cServidor, cConta, cContaSenha, 0, nPorta)
	oEmail:SetSmtpTimeOut(nTimeOut)
	nErro := oEmail:SmtpConnect()

	If nErro <> 0

		ConOut("ERRO: " + oEmail:GetErrorString(nErro))
		oEmail:SMTPDisconnect()
		Return .F.

	EndIf

 
    ConOut('Autenticando no SMTP')    
    nErro := oEmail:SMTPAuth(cConta, cContaSenha)

    If nErro <> 0

        ConOut("ERRO:" + oEmail:GetErrorString(nErro))
        oEmail:SMTPDisconnect()
        Return .F.

    Endif

	
	
		
		If Empty(nErro)
			nErro := oEmail:Send(oEmail)
			If nErro <> 0
				ConOut("ERRO:" + oEmail:GetErrorString(nErro))
			Endif		
		EndIf
	

	ConOut("Desconectando do SMTP")

	oEmail:SMTPDisconnect()

Return .T.
