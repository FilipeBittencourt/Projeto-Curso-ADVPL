#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF031
@author Tiago Rossini Coradini
@since 08/04/2019
@project Automação Financeira
@version 1.0
@description Processa conciliacao bancaria
@type function
/*/

User Function BAF031()
	Local oParam := TParBAF031():New()
	Local _oSemaforo	:=	tBiaSemaforo():New()	
	
	//Teste para bloquear conflitos/locks - esta chamando em cada botao da tela - Fernando
	//If ( U_BMONCHKC("BAN001") )
	//	Return()
	//EndIf
	_oSemaforo:cGrupo	:=	"FIN_TESOURARIA"
	
	If _oSemaforo:GeraSemaforo("JOB - BAF031")
		If oParam:Box()
	
			U_BIAMsgRun("Selecionando Extrato e Movimento Bancário...", "Aguarde!", {|| fProcess(oParam) })
	
		EndIf

		_oSemaforo:LiberaSemaforo()
	
	EndIf

Return()


Static Function fProcess(oParam)
	Local oObj := Nil

	oObj := TWAFConciliacaoBancaria():New(oParam)

	oObj:Activate()

Return()