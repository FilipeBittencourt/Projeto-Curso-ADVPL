#include "rwmake.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} M030INC
@author Ranisses A. Corona
@since 14/07/17
@version 1.0
@description Atualiza variavel publica cCliBZ com o código do Cliente cadastrado para o processo BIZAGI
@obs Alteração e unificacao na funcao que define o Grupo de Tributacao
@type function
/*/

User Function M030INC()    

CONOUT('Iniciando o M030INC...')

/*
If !Type("M->A1_COD") == "U" .And. cCliBZ <> M->A1_COD
	cCliBZ := M->A1_COD //Codigo do Cliente para o Sistema BIZAGI
	CONOUT('Gravando cCliBZ=>'+cCliBZ)	
EndIf
*/

//Grava variaveis adicionais no cadastro de cliente
If !Type("M->A1_COD") == "U"  

	//Define o Grupo de Tributacao
	SA1->A1_GRPTRIB	:= U_fGetGrTr(M->A1_SUFRAMA,M->A1_CALCSUF,M->A1_TIPO,M->A1_CONTRIB,M->A1_INSCR,M->A1_SATIV1,M->A1_TPJ)
	
	//Solicitado pelo Vagner no dia 26/08/10
	IF M->A1_SATIV1 == '000099'
		SA1->A1_YDTPRO := 3
	ENDIF
	
	//Fernando/Facile em 02/03/2017 - gravando valor default do campo NLOJA caso nao tenha sido preenchido 
	If Empty(AllTrim(M->A1_YNLOJA))
		SA1->A1_YNLOJA := AllTrim(SUBSTR(SA1->A1_NREDUZ,1,15))+'/'+AllTrim(SUBSTR(SA1->A1_MUN,1,11))+'/'+SA1->A1_EST
	EndIf

EndIf

If PARAMIXB <> 3
	If SA1->A1_GRPVEN $ ('000010|000938|000380|000026|001307') .Or. SA1->A1_COD $ ('010083|004536|007871|026308|026423|018410|014395|018714|008615|028071')
		SA1->A1_YCDGREG := "000023"
	ElseIf SA1->A1_EST $ ('SP|RJ')
		SA1->A1_YCDGREG := "000025"
	EndIf
	SA1->A1_YFORMA := U_valYFORMA(cEmpAnt, SA1->A1_YCDGREG)
EndIf

Return