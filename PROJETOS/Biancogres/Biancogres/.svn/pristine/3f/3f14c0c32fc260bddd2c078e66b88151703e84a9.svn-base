#include "rwmake.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} MALTCLI
@author Ranisses A. Corona
@since 10/06/2014
@version 1.0
@description Grava informações adicionais no cadastro de cliente
@obs Alteração e unificacao na funcao que define o Grupo de Tributacao
@type function
/*/

User Function MALTCLI()     
Local cTrib := ""

CONOUT('Iniciando o MALTCLI...')

If !Type("SA1->A1_COD") == "U"  

	//Define o Grupo de Tributacao
	SA1->A1_GRPTRIB	:= U_fGetGrTr(SA1->A1_SUFRAMA,SA1->A1_CALCSUF,SA1->A1_TIPO,SA1->A1_CONTRIB,SA1->A1_INSCR,SA1->A1_SATIV1,SA1->A1_TPJ)
	
	RecLock('SA1',.F.)
		
	//Solicitado pelo Vagner no dia 26/08/10
	IF SA1->A1_SATIV1 == '000099'
		SA1->A1_YDTPRO := 3
	ENDIF
	
	//ticket 17773
	/*If SA1->A1_GRPVEN $ ('000010|000938|000380|000026|001307') .Or. SA1->A1_COD $ ('010083|004536|007871|026308|026423|018410|014395|018714|008615|028071')
		SA1->A1_YCDGREG := "000023"
	ElseIf SA1->A1_EST $ ('SP|RJ')
		SA1->A1_YCDGREG := "000025"
	EndIf
	*/
	
	SA1->A1_YFORMA := U_valYFORMA(cEmpAnt, SA1->A1_YCDGREG)
	
	//ticket 
	//IF SA1->A1_YCAT == 'FUNC'
	
	//ENDIF

	SA1->(MsUnLock())                     
	SA1->(dbcommitall())
	
EndIf

Return(.T.)