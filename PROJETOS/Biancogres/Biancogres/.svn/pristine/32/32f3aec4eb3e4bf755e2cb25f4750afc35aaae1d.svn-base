#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA650OK
@author Gabriel Rossi Mafioletti
@since 03/09/2018
@version 1.0
@description Ponto de entrada que controla a geração de OP's intermediárias
@type function
/*/

User Function MTA650OK()

	Local _lRet	:=	.T.
	
	Local _cMsg	:= ""	
	
	
	
	DbSelectArea("SX6")
	If !ExisteSX6("MV_YBLQRCM")
		CriarSX6("MV_YBLQRCM", 'L', 'Controle de Bloqueio de Rotinas do CMV', ".F." )
	EndIf
	

	If GetMv("MV_YBLQRCM")
		MsgInfo("Rotina bloqueada para execução pois o parâmetro do bloqueio para CMV está ativado!","MTA650OK")
		Return .F.
	EndIF	

	
	_cMsg	+=	"As OPs intermediarias e as SCs não foram geradas." + CHR(13)
	_cMsg	+=	"As opções são:"+ CHR(13)
	_cMsg	+=	"- Sim ,gerar agora."+ CHR(13)
	_cMsg	+=	"- Não ,abandona para gera-las posteriormente."+ CHR(13)
	_cMsg	+=	"Se o parametro MV_EXPLOPV estiver configurado como SIM so serao"+ CHR(13)
	_cMsg	+=	"gerados OPs Interm. / Empenhos para as OPs desse usuario."+ CHR(13)
	
	

	If MsgYesNo(_cMSg)
		_lRet	:= .T.
	Else
		_lRet	:=	.F.
	EndIf



Return _lRet