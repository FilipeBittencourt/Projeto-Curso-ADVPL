#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} VLDCHVNFE
@description Rotina para valdiar CHAVE de NFE Sefaz - baseada na rotina padrao da TOTVS usando o TSS
@author ferna
@since 10/06/2019
@version 1.0
@return .T. ou .F. e mensagens
@param cVarChvNfe, characters, descricao
@type function
/*/
User Function VLDCHVNFE(cVarChvNfe)

	Local lRet	  	:= .F.   
	Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cIdEnt   	:= ""
	Local cChaveNFe := ""
	Local cCodRet	:= "Codigo de retorno: "
	Local cMensRet  := "Mensagem de retorno: " 
	Local cProt		:= "Protocolo: "

	local lUsaGesEmp	:= .F.
	local lEnvCodEmp	:= .F.

	Private oWS

	Default cVarChvNfe	:= ""

	If IsReady(cURL)

		cChaveNFe  		:= cVarChvNfe

		lEnvCodEmp	:= getNewPar("MV_ENVCDGE",.F.)
		lUsaGesEmp	:= iif(findFunction("FWFilialName") .And. findFunction("FWSizeFilial") .And. FWSizeFilial() >= 2,.T.,.F.)

		//Obtem o codigo da entidade 
		oWS := WsSPEDAdm():New()
		oWS:cUSERTOKEN := "TOTVS"
		oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
		oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
		oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
		oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
		oWS:oWSEMPRESA:cFANTASIA   := iif(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
		oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
		oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
		oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
		oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
		oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
		oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
		oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
		oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
		oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
		oWS:oWSEMPRESA:cCEP_CP     := Nil
		oWS:oWSEMPRESA:cCP         := Nil
		oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
		oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
		oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
		oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
		oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
		oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
		oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cINDSITESP  := ""
		oWS:oWSEMPRESA:cID_MATRIZ  := ""

		if( lUsaGesEmp .and. lEnvCodEmp )
			oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
		endif

		oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
		oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

		If oWs:ADMEMPRESAS()
			cIdEnt  := oWs:cADMEMPRESASRESULT
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		EndIf  

		oWs:= WsNFeSBra():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		ows:cCHVNFE		 := cChaveNFe
		oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

		If oWs:ConsultaChaveNFE()
			If Type ("oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO") == "U" .OR. Empty (oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
				If AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "731" .or. AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "526"

					If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
					cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
					"Verificar se o Ano-Mês da Chave de Acesso está com atraso"+CRLF+;
					"superior a 6 meses em relação ao Ano-Mês atual."+CRLF+CRLF+CRLF+;
					"Deseja prosseguir com esta chave mesmo assim?")
						lRet := .T.
					Else
						lRet := .F.
					EndIf

				ElseIf AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"

					If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
					cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+; 
					cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF+CRLF+CRLF+;
					"Deseja prosseguir com esta chave mesmo assim?")
						lRet := .T.
					Else		    
						lRet := .F.
					EndIf

				Else
					MsgAlert("A chave digitada não foi encontrada na Sefaz, favor verificar")
					lRet := .F.
				endIf
			Else
				If AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"

					If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
					cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+; 
					cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF+CRLF+CRLF+;
					"Deseja prosseguir com esta chave mesmo assim?")
						lRet := .T.
					Else		    
						lRet := .F.
					EndIf

				Else	
					lRet := .T.

					MsgAlert(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
					cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
					cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)

				EndIf
			EndIf
		Else

			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
			lRet := .T.

		EndIf
	Else
		Help(" ",1,"TSSINATIVO")	
		lRet := .F.
	EndIf	

Return  lRet 

Static Function IsReady(cURLTss)

	Local oWS
	Local lRetorno := .F.    

	DEFAULT cURLTss  := PadR(GetNewPar("MV_SPEDURL","http://"),250)

	oWs := WsSpedCfgNFe():New()
	oWs:cUserToken := "TOTVS"
	oWS:_URL := AllTrim(cURLTss)+"/SPEDCFGNFe.apw"

	If oWs:CFGCONNECT()
		lRetorno := .T.
	EndIf

Return lRetorno