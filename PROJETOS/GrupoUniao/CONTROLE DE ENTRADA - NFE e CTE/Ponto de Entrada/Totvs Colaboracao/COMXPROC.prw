#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
###########################################################################################################################
# P.E.............: COMXPROC
# DATA CRIACAO....: 07/11/2017
# AUTOR...........: WLYSSES CERQUEIRA (AUTOVIX)
# DESCRICAO.......: PONTO DE ENTRADA UTILIZADO PARA VALIDAÇÃO DA GERAÇÃO DE DOCUMENTOS VIA TOTVS COLABORAÇÃO.
# RETORNO.........: LÓGICO: (.T.) PARA GERAR O DOCUMENTO - (.F.) PARA NÃO GERAR O DOCUMENTO.
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
			
			Alert("Não é pemitido gerar documento de entrada para CT-e pelo TOTVS Colaboração, favor utilizar o módulo Frete Embarcador!")
			
			lRet := .F.
			
			Conout("MV_YCOMXPR = .T. - Não gerar CT-e pelo Colaboracao " + SDS->DS_CHAVENF)
	
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