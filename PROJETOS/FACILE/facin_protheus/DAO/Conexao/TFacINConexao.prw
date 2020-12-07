#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINConexao
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/
 
 
Class TFacINConexao From LongClassName
	 
	Data oUserM	
	Data cHostWS 				
	Data aHeader

	Method New() Constructor	 
	Method PLOGIN(aHeader, cHostWS)

EndClass

Method New() Class TFacINConexao

	::aHeader   := {"Content-Type: application/json","Job:True"}
	::cHostWS   := "https://facinbackend.azurewebsites.net"
	//::cHostWS   := "http://localhost:11540"
	::oUserM    := ::PLOGIN() 

Return Self

// POST  LOGIN
Method PLOGIN() Class TFacINConexao
	
	Local oRestCli  := FWRest():New(::cHostWS) 		
	Local cLogin	:= SuperGetMV("ZF_USERLOG",.F.,"facinpth@facilesistemas.com.br")
	Local cPassword	:= SuperGetMV("ZF_USERPSW",.F.,"123456")		
	Local oJsonOBJ  := ""	 
	Local cJSBody := ""
		  cJSBody += '{"Email": "' + cLogin + '",'
		  cJSBody += '"password": "' + cPassword + '",'
		  cJSBody += '"Empresa":{"CpfCnpj":"' + SM0->M0_CGC + '" }}'  
	


	oRestCli:setPath("/api/usuario/login")	 
    oRestCli:SetPostParams(cJSBody)	

	::oUserM := Nil
	If oRestCli:Post(::aHeader ) .OR. !Empty( oRestCli:GetResult() )
		If (oRestCli:ORESPONSEH:CSTATUSCODE != "404")
			cStringJS :=  oRestCli:GetResult()
			FWJsonDeserialize(cStringJS, @oJsonOBJ)	
			::oUserM := TFacINUsuarioModel():New()	 
			::oUserM:cToken  :=  oJsonOBJ:Token
			::oUserM:cNome   :=  oJsonOBJ:Nome
			::oUserM:cEmail  :=  oJsonOBJ:Email	
			 Aadd(::aHeader,"Authorization:"+::oUserM:cToken+"")
		EndIf	
	Else
		conout(oRestCli:GetLastError())
	Endif

Return ::oUserM 
 
 /*
Class TFacINConexao From LongClassName
	 
	Data oUserM	 	
	Data cHostWS	
	Data cContent
	Data aHeader
	Method New() Constructor	 
	Method PLOGIN(cHostWS, cContent)
EndClass
Method New() Class TFacINConexao
	::cHostWS   := "https://facinbackend.azurewebsites.net"		
	::cContent  := "Content-Type: application/json"
	::aHeader   := {}
	::oUserM    := ::PLOGIN(::cHostWS, ::cContent)
	if !Empty(::oUserM)
		Aadd(::aHeader,"Content-Type: application/json")	
		Aadd(::aHeader,"Authorization: "+::oUserM:cToken+" ")
	EndIf
Return Self
// POST  LOGIN
Method PLOGIN(cHostWS, cContent) Class TFacINConexao
	
	Local oRestCli  := FWRest():New(cHostWS) 	
	Local aHeader	:= {}	
	Local oJsonOBJ  := ""
	Local cLogin	:= SuperGetMV("ZF_USERLOG",.F.,"facin@facilesistemas.com.br")
	Local cPassword	:= SuperGetMV("ZF_USERPSW",.F.,"123456")
 
	Local cJSBody := ""
		  cJSBody += '{"Email": "' + cLogin + '",'
		  cJSBody += '"password": "' + cPassword + '",'
		  cJSBody += '"Empresa":{"CpfCnpj":"' + SM0->M0_CGC + '" }}'  
	Aadd(aHeader,cContent)	
	oRestCli:setPath("/api/usuario/login")	 
    oRestCli:SetPostParams(cJSBody)	
	::oUserM := Nil
	If oRestCli:Post(aHeader) .OR. !Empty( oRestCli:GetResult() )
		If (oRestCli:ORESPONSEH:CSTATUSCODE != "404")
			cStringJS :=  oRestCli:GetResult()
			FWJsonDeserialize(cStringJS, @oJsonOBJ)	
			::oUserM := TFacINUsuarioModel():New()	 
			::oUserM:cToken  :=  oJsonOBJ:Token
			::oUserM:cNome   :=  oJsonOBJ:Nome
			::oUserM:cEmail  :=  oJsonOBJ:Email	
		EndIf	
	Else
		conout(oRestCli:GetLastError())
	Endif
Return ::oUserM 

 */