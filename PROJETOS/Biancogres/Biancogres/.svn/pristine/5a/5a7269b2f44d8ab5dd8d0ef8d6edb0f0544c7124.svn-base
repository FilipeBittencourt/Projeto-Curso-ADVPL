#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF004
@author Tiago Rossini Coradini
@since 02/09/2018
@project Automação Financeira
@version 1.0
@description Processa retorno de titulos a receber 
@type function
/*/

User Function BAF004()
	Local oObj := Nil
	Local _oSemaforo	:=	tBiaSemaforo():New()

	U_GravaPZ2(0,"SE1","BAF004","INICIO","EMP:"+CEMPANT,"MNT",CUSERNAME)

	_oSemaforo:cGrupo	:=	"FIN_BAIXAS"

	If _oSemaforo:GeraSemaforo("JOB - BAF004")

		oObj := TAFRetornoReceber():New()
		oObj:Receive()

		oObj := TAFBaixaReceber():New()
		oObj:Process()

		_oSemaforo:LiberaSemaforo()

	EndIf

	U_GravaPZ2(0,"SE1","BAF004","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)

Return()