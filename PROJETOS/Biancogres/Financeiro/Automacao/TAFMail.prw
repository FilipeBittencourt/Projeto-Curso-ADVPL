#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFMail
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe para envio/recebimento de e-mail
@type class
/*/

Class TAFMail From LongClassName

	Public Data oServer
	Public Data oMessage
	Public Data cServer
	Public Data nSmtpPort
	Public Data cAccount
	Public Data cPassword
	Public Data lAuth
	Public Data nTimeOut	
	Public Data lUseSSL
	Public Data lUseTLS
	
	Public Data cFrom
	Public Data cTo
	Public Data cCc
	Public Data cBcc
	Public Data cSubject 			
	Public Data cBody
	Public Data cAttachFile
		
	Public Method New() Constructor
	Public Method Send()

EndClass


Method New() Class TAFMail
Local nPos := 0
	
	::oServer := TMailManager():New()	
	::cServer := GetMv("MV_RELSERV")
	
	If (nPos := At(':', ::cServer)) > 0 
	 	
	 	::nSmtpPort := Val(Substr(::cServer, nPos + 1, Len(::cServer)))
	 	
	 	::cServer := Substr(::cServer, 0, nPos - 1)
	 	
	EndIf	
	
	If ::nSmtpPort == 0
		
		If GETMV("MV_PORSMTP") == 0
			
			::nSmtpPort := 25
		
		Else
			
			::nSmtpPort := GETMV("MV_PORSMTP")
			
		EndIf
		
	EndIf
	
	::cAccount := GetMv("MV_RELACNT")
	::cPassword := GetMv("MV_RELPSW")
	::lAuth := GetMv("MV_RELAUTH")
	::nTimeOut := GetMv("MV_RELTIME")
	::lUseSSL := GetMv("MV_RELSSL")
	::lUseTLS := GetMv("MV_RELTLS")

	::oMessage := TMailMessage():New()		
	::cFrom := GetMv("MV_RELFROM")
	::cTo := ""
	::cCc := ""
	::cBcc := ""
	::cSubject := ""		
	::cBody := ""
	::cAttachFile := ""
				
Return()


Method Send() Class TAFMail
Local lRet := .T. 
	
	::oServer:SetUseSSL(::lUseSSL)
	
	::oServer:SetUseTLS(::lUseTLS)
		
	::oServer:Init("", ::cServer, ::cAccount, ::cPassword,, ::nSmtpPort)
		
	::oServer:SetSmtpTimeOut(60)
		
	If (lRet := ::oServer:SmtpConnect() == 0)

		If ::lAuth
		
			lRet := ::oServer:SmtpAuth(::cAccount, ::cPassword) == 0
		
		EndIf
		
		If lRet
								
			::oMessage:cFrom := ::cFrom
			::oMessage:cTo := ::cTo
			::oMessage:cCc := ::cCc
			::oMessage:cBcc := ::cBcc
			::oMessage:cSubject := ::cSubject + If(Upper(AllTrim(GetSrvProfString("DbAlias", ""))) == "PRODUCAO", "", " - (AMBIENTE DE TESTE)")
			::oMessage:cBody := ::cBody
			::oMessage:AttachFile(::cAttachFile)
																
			If (lRet := ::oMessage:Send(::oServer) == 0)
			
				::oServer:SmtpDisconnect()
								
			EndIf
			
		EndIf
		
	EndIf

Return(lRet)