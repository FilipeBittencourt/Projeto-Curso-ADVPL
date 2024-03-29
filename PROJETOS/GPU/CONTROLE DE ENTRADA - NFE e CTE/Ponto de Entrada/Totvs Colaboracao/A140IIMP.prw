#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
###########################################################################################################################
# P.E.............: A140IIMP
# DATA CRIACAO....: 20/09/2017
# AUTOR...........: WLYSSES CERQUEIRA (GRUPO UNIAO)
# DESCRICAO.......: EXECUTADO NA LEITURA DOS ARQUIVOS XML CONTIDOS NA ESTRUTURA DE PASTAS DO TOTVS COLABORACAO. 
# RETORNO.........: L�GICO.
###########################################################################################################################
# DATA ALTERACAO..:
# AUTOR...........:
# MOTIVO..........:
###########################################################################################################################
*/

User Function _A140IIMP() // Aberto chamado 4364285 (PE nao funciona)
	
	Local lRet := .T.
	Local oObjXml := VIXA258():New()
	
	If !oObjXml:Validate()
	
		lRet := .F.
		
		Conout("PE: ENTREI A140IIMP")
		
	Else
	
		Conout("PE: NAO ENTREI A140IIMP")
	
	EndIf	
	
Return(lRet)

//U_SCHEDWSC
User Function SCHEDWSC()
	
	Local aParam := {"08", "01"}
	
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"COM")
	
	BEGIN TRANSACTION
	
	COLAUTOREAD(aParam)
	SchedComCol(aParam)
	
	//DisarmTransaction()
	
	END TRANSACTION
	
	RpcClearEnv()
	
Return()