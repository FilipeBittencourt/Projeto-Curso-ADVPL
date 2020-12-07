#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Ponto de Entrada no TudoOk da tela de geração de Borderô
@author Gabriel Mafioletti
@since 12/12/2019
@version 1.0
@type Function
/*/

User Function F240OK2()

	Local _oSemaforo	:=	tBiaSemaforo():New()	
	Local _lRet	:=	.T.
	
	_oSemaforo:cGrupo	:=	"FIN_BORDERO"
	
	If !_oSemaforo:GeraSemaforo()
		_lret	:=	.F.
	Else
		_oSemaforo:LiberaSemaforo()
	EndIf
		

Return _lRet