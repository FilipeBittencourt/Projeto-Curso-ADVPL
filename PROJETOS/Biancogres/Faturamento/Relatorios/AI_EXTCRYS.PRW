
#include "protheus.ch"

/*/{Protheus.doc} AI_EXTCRYS
@description Relatorio em Crystal - Extrato de Autorizacao de Investimento
@author Fernando Rocha
@since 30/03/2017
@version undefined
@type function
/*/
User Function AI_EXTCRYS

Local aPergs 	:= {}
Local aRet	 	:= {Space(6)}

Private cNumAI

aAdd( aPergs ,{1,"Número da AI:" ,Space(6),"",'',"",'.T.',50,.T.})
If !ParamBox(aPergs ,"Extrato da AI",aRet,,,,,,,,.F.,.F.)
	Return
EndIf
cNumAI  := aRet[1]


SZO->(DbSetOrder(5))
If SZO->(DbSeek(XFilial("SZO")+cNumAI))
	
	If Type("CREPATU") <> "U" .And. !Empty(CREPATU)
		If Empty(SZO->ZO_REPRE) .Or. AllTrim(CREPATU) <> Alltrim(SZO->ZO_REPRE)
			MsgAlert("Usuário sem acesso a esta AI!","AI_EXTCRYS")
			Return
		EndIf
	EndIf	
	
	U_BIAMsgRun("Aguarde... Gerando Relatório...",,{|| ProcRel()})

Else
	MsgAlert("AI não existe!","AI_EXTCRYS")
EndIf

Return


Static Function ProcRel

Private cSQL
Private cOpcao 	:= ""


If (Upper(AllTrim(getenvserver())) $ "FACILE-PROD-FERNANDO")

	cSQL := "truncate table [DADOSTESTE].[dbo].[TAB_SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"]"
	TcSQLExec(cSQL)
	
	cSQL := "insert into [DADOSTESTE].[dbo].[TAB_SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"] exec [DADOSTESTE].[dbo].[SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"] '"+cNumAI+"'"
	TcSQLExec(cSQL)
	
	cSQL := "ALTER VIEW VW_POL_GET_BAIXAS_AI AS SELECT * FROM [DADOSTESTE].[dbo].[TAB_SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"] "      
	TcSQLExec(cSQL)
	
	cOpcao	:=	"6;0;1;Extrato de Autorização de Investimento"

	CallCrys("EXTRATO_TST_AI_"+AllTrim(CEMPANT), cEmpant, cOpcao, .T., .T., .T., .F. )
	
	Return

Else

	cSQL := "truncate table [dbo].[TAB_SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"]"
	TcSQLExec(cSQL)
	
	cSQL := "insert into [dbo].[TAB_SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"] exec [dbo].[SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"] '"+cNumAI+"'"
	TcSQLExec(cSQL)
	
	cSQL := "ALTER VIEW VW_POL_GET_BAIXAS_AI AS SELECT * FROM [dbo].[TAB_SP_POL_GET_BAIXAS_AI_"+ ALLTRIM(CEMPANT) +"] "      
	TcSQLExec(cSQL)
	
EndIf


cOpcao	:=	"6;0;1;Extrato de Autorização de Investimento"

CallCrys("EXTRATO_AI_"+AllTrim(CEMPANT), cEmpant, cOpcao, .T., .T., .T., .F. )

Return

