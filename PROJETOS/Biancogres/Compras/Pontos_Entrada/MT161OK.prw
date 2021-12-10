#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "BUTTOM.CH"

/*/{Protheus.doc} MT161OK
@author Tiago Rossini Coradini
@since 25/02/2021
@version 1.0
@description O ponto de entrada MT161OK é usado para validar as propostas dos fornecedores no momento da gravação da análise da cotação, após o fechamento da tela. 
@type function
/*/

User Function MT161OK()
    Local lRetPE     := .F.
	
	If Len(AcolsAud) > 0 .and. lMarkVenc
		If lMarkVenc .and. Empty(AcolsAud[1][12])
				MsgAlert("Foi alterada a proposta vencedora, preencha o motivo na auditoria!")
				lRetPE := .F.
		ElseiF lMarkVenc .and. !Empty(AcolsAud[1][12])
			lRetPE := .T.
		EndIf
	ElseIf Len(AcolsAud) > 0 .and. !lMarkVenc
		lRetPE := .T.		
	ElseIf !lMarkVenc
		lRetPE := .T.	
	ElseIf Len(AcolsAud) == 0 .and. lMarkVenc
		lRetPE := .F.	
		MsgAlert("Foi alterada a proposta vencedora, preencha o motivo na auditoria!")
	EndIf
	
Return(lRetPE)

User Function GatSce()

	Local cMot     := M->CE_MOTIVO
	Local cMotVenc := ""
	Local cQuery   := ""
	Local nX       := 0



	If !Empty(cMot)
		For nX := 1 To Len(AcolsAud)
			cQuery := ""
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SX5")+" "
			cQuery += "WHERE X5_TABELA = 'ZS' "
			cQuery += "AND X5_CHAVE = '"+Alltrim(cMot)+"' "
			cQuery += "AND D_E_L_E_T_ <> '*' "

			If Select("MOT") > 0
				MOT->(dbCloseArea())
			EndIf

			TcQuery cQuery New Alias "MOT"

			cMotvenc := DTOS(DATE())+TIME()+MOT->x5_DESCRI
			AcolsAud[nX][12] := cMotvenc
		Next
	EndIf

Return
