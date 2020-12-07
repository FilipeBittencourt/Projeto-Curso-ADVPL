#INCLUDE "PROTHEUS.CH"
/*
##############################################################################################################
# PROGRAMA...: FA090TIT         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 01/11/2013                      
# DESCRICAO..: Ponto de Entrada para tratar Baixa Automatica com Portador diferente do portador do Bordero
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/
 
User Function FA090TIT()

	Local lPrimeiraVez := .F.
	Local cPortador := PARAMIXB[1]
	Local cAgencia := PARAMIXB[2]
	Local cConta := PARAMIXB[3]

	Static cBordero
	Static cPrimBordero
	Static lRet := .T.

	If Empty(cBordero)
		cBordero := SEA->EA_NUMBOR
		lPrimeiraVez := .T.
		cPrimBordero := SEA->EA_NUMBOR
	EndIf
	//VALIDACOES PARA CASO ACESSE NOVAMENTE A ROTINA, PARA REINICIAR AS VARIAVEIS STATICAS
	If !(Empty(cPrimBordero)) .And. (cBordero != cPrimBordero)
		If(Alltrim(cPrimBordero) == Alltrim(SEA->EA_NUMBOR))
			cBordero := SEA->EA_NUMBOR
			lPrimeiraVez := .T.
		EndIf
	EndIf
        
	If Alltrim(cBordero) != '' .And. ((Alltrim(cBordero) != Alltrim(SEA->EA_NUMBOR)) .Or. lPrimeiraVez)
		If(Alltrim(SEA->EA_PORTADO) != Alltrim(cPortador)) .Or. (Alltrim(SEA->EA_AGEDEP) != Alltrim(cAgencia)) .Or. (Alltrim(SEA->EA_NUMCON) != Alltrim(cConta))
			MSGINFO( "Não é permitido baixar um título com um Portador diferente do Portador do Bordero.", "FA090TIT")
			lRet := .F.
		EndIf
		cBordero := SEA->EA_NUMBOR
	EndIf
	
	If ExisteMovPA()
		
		lRet := .F.
	
	Else
	
		lRet := .T.
	
	EndIf

Return lRet


Static Function ExisteMovPA()

	Local lRet := .F.
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSE5 := SE5->(GetArea())
	
	SE2->(DBGoTo((cAliasSE2)->NUM_REG))
	
	If !SE2->(EOF()) .And. AllTrim(SE2->E2_TIPO) == "PA"
		
		DBSelectArea("SE5")
		SE5->(DBSetOrder(7)) // E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_
		
		If SE5->(DbSeek(xFilial("SE5") + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
			
			/*
			If MsgYesNo("Identificado movimentação da PA - Titulo: " + SE2->E2_NUM + " tipo: " + SE2->E2_TIPO + " tipo: " + SE2->E2_PREFIXO + " parcela: " + SE2->E2_PARCELA + CRLF + CRLF + "Deseja baixar novamente?")
				
				lRet := .F.
				
			Else
			
				lRet := .T.
				
			EndIf
			*/
			
			MsgInfo("Identificado movimentação da PA - Titulo: " + SE2->E2_NUM + " tipo: " + SE2->E2_TIPO + " tipo: " + SE2->E2_PREFIXO + " parcela: " + SE2->E2_PARCELA)
			
			lRet := .T.
			
		EndIf
	
	EndIf
	
	RestArea(aAreaSE2)
	RestArea(aAreaSE5)

Return(lRet)