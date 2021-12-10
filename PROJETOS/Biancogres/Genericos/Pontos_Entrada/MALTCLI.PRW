#include "rwmake.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} MALTCLI
@author Ranisses A. Corona
@since 10/06/2014
@version 1.0
@description Grava informações adicionais no cadastro de cliente
@history 18/02/2021, Ranisses A. Corona, Alteração e unificacao na funcao que define o Grupo de Tributacao
@type function
/*/

User Function MALTCLI()     
Local cTrib		:= ""
Local cCdRgFin	:= ""

CONOUT('Iniciando o MALTCLI...')

If !Type("SA1->A1_COD") == "U"  

	RecLock('SA1',.F.)

	cCdRgFin := U_fRegCobr(Alltrim(SA1->A1_EST), Alltrim(SA1->A1_CGC), Alltrim(SA1->A1_GRPVEN), Alltrim(SA1->A1_COD))
	If Empty(Alltrim(SA1->A1_YCDGREG)) .Or. ( !Empty(Alltrim(SA1->A1_GRPVEN)) .And. (cCdRgFin <> Alltrim(SA1->A1_YCDGREG) ))
		SA1->A1_YCDGREG := cCdRgFin
	EndIf

	//Define o Grupo de Tributacao
	SA1->A1_GRPTRIB	:= U_fGetGrTr(SA1->A1_SUFRAMA,SA1->A1_CALCSUF,SA1->A1_TIPO,SA1->A1_CONTRIB,SA1->A1_INSCR,SA1->A1_SATIV1,SA1->A1_TPJ)
		
	//Solicitado pelo Vagner no dia 26/08/10
	IF SA1->A1_SATIV1 == '000099'
		SA1->A1_YDTPRO := 3
	ENDIF
	
	SA1->A1_YFORMA	:= U_valYFORMA(cEmpAnt, SA1->A1_YCDGREG)
	
	SA1->(MsUnLock())                     
	SA1->(dbcommitall())
	
EndIf

Return(.T.)
