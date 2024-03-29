#include "rwmake.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} M030INC
@author Ranisses A. Corona
@since 14/07/17
@version 1.0
@description Atualiza variavel publica cCliBZ com o c�digo do Cliente cadastrado para o processo BIZAGI
@history 18/02/2021, Ranisses A. Corona, Altera��o e unificacao na funcao que define o Grupo de Tributacao
@type function
/*/

User Function M030INC()    
Local cCdRgFin	:= ""

CONOUT('Iniciando o M030INC...')

//Grava variaveis adicionais no cadastro de cliente
If !Type("M->A1_COD") == "U"  

	cCdRgFin := U_fRegCobr(Alltrim(SA1->A1_EST), Alltrim(SA1->A1_CGC), Alltrim(SA1->A1_GRPVEN), Alltrim(SA1->A1_COD))
	If Empty(Alltrim(SA1->A1_YCDGREG)) .Or. ( !Empty(Alltrim(SA1->A1_GRPVEN)) .And. (cCdRgFin <> Alltrim(SA1->A1_YCDGREG) ))
		SA1->A1_YCDGREG := cCdRgFin
	EndIf

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

Return
