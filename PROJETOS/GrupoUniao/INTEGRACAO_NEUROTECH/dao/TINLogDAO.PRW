#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINLogDAO
@description Classe DAO para interações com banco 
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/


Class TINLogDAO From LongClassName
   
    Data oLog 

    Method New() Constructor
	Method Insert(oLog)
	 

EndClass

Method New() Class TINLogDAO

	::oLog := ""

Return Self


Method Insert(oLog) Class TINLogDAO
    
	Local aArea := ZZ8->(GetArea())	 		
	Local lRet  := .T.		 
	
	ZZ8->(DbSetOrder(1)) 
	RecLock("ZZ8",.T.)

		ZZ8->ZZ8_FILIAL := oLog:cFilialx	
		ZZ8->ZZ8_NUMPED := oLog:cNumPedido		  
		ZZ8->ZZ8_CNTNEU := oLog:cNumNeu
		ZZ8->ZZ8_DTENVI := oLog:dDtEnvNeu //Ctod(oLog:dDtEnvNeu)
		ZZ8->ZZ8_HRENVI := oLog:cHrEnvNeu
		ZZ8->ZZ8_DTRESN := oLog:dDtResNeu //Ctod(oLog:dDtResNeu)
		ZZ8->ZZ8_HRRESN := oLog:cHrResNeu
		ZZ8->ZZ8_LIMCAL := oLog:cLimitNeu
		ZZ8->ZZ8_MOTBLQ := oLog:cMotivNeu
		ZZ8->ZZ8_CODVEN := oLog:cCodVend
		ZZ8->ZZ8_CODOPE := oLog:cCodOper
		ZZ8->ZZ8_STATUS := oLog:cStatus
		ZZ8->ZZ8_CLIENT := oLog:cCodCli 	
		ZZ8->ZZ8_LOJA   := oLog:cCliLoja 
		ZZ8->ZZ8_NOMCLI	:= oLog:cCliNome
		ZZ8->ZZ8_CNPJ	:= oLog:cCliCGC
		ZZ8->ZZ8_MOTLIB	:= oLog:cMotivLib
		
		ZZ8->ZZ8_ROTINA := oLog:cRotina
		ZZ8->ZZ8_OUTXML := oLog:cOutXML
		ZZ8->ZZ8_INXML	:= oLog:cInXML	
		ZZ8->ZZ8_ERRCOM	:= oLog:cErroNeu	
		ZZ8->ZZ8_CODNEU	:= cValToChar(oLog:cCodNeu)
		ZZ8->ZZ8_LIMCAL := oLog:nVlrNeu
		
	ConfirmSx8()
	ZZ8->(msUnLock())
 	
	RestArea(aArea)	

Return lRet	