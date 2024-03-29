#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA650OK
@author Gabriel Rossi Mafioletti
@since 03/09/2018
@version 1.0
@description Ponto de entrada que controla a gera��o de OP's intermedi�rias
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
		MsgInfo("Rotina bloqueada para execu��o pois o par�metro do bloqueio para CMV est� ativado!","MTA650OK")
		Return .F.
	EndIF	

	
	_cMsg	+=	"As OPs intermediarias e as SCs n�o foram geradas." + CHR(13)
	_cMsg	+=	"As op��es s�o:"+ CHR(13)
	_cMsg	+=	"- Sim ,gerar agora."+ CHR(13)
	_cMsg	+=	"- N�o ,abandona para gera-las posteriormente."+ CHR(13)
	_cMsg	+=	"Se o parametro MV_EXPLOPV estiver configurado como SIM so serao"+ CHR(13)
	_cMsg	+=	"gerados OPs Interm. / Empenhos para as OPs desse usuario."+ CHR(13)
	
	

	If MsgYesNo(_cMSg)
		_lRet	:= .T.
	Else
		_lRet	:=	.F.
	EndIf



Return _lRet