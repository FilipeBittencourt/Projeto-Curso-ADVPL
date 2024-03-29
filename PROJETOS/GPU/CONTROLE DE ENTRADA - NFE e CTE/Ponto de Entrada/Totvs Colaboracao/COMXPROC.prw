#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
###########################################################################################################################
# P.E.............: COMXPROC
# DATA CRIACAO....: 07/11/2017
# AUTOR...........: WLYSSES CERQUEIRA (AUTOVIX)
# DESCRICAO.......: PONTO DE ENTRADA UTILIZADO PARA VALIDA��O DA GERA��O DE DOCUMENTOS VIA TOTVS COLABORA��O.
# RETORNO.........: L�GICO: (.T.) PARA GERAR O DOCUMENTO - (.F.) PARA N�O GERAR O DOCUMENTO.
###########################################################################################################################
# DATA ALTERACAO..:
# AUTOR...........:
# MOTIVO..........:
###########################################################################################################################
*/

User Function COMXPROC()
	
	Local lRet			:= .T.
	Local lComxProc	:= GetNewPar("MV_YCOMXPR", .T.)
	Local oObjXml 		:= VIXA258():New()
	
	If lComxProc
		
		If SDS->DS_TIPO == "T"
			
			Alert("N�o � pemitido gerar documento de entrada para CT-e pelo TOTVS Colabora��o, favor utilizar o m�dulo Frete Embarcador!")
			
			lRet := .F.
			
			Conout("MV_YCOMXPR = .T. - N�o gerar CT-e pelo Colaboracao " + SDS->DS_CHAVENF)
	
			/*
			RecLock("SDS", .F.)
			SDS->DS_STATUS := "P"
			SDS->(msUnLock())
			*/
			
		EndIf
		
	EndIf
	
	If lRet .And. !oObjXml:LibNfe()
	
		lRet := .F.
	
	EndIf
	
Return(lRet)