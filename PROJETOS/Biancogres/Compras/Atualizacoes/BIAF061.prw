#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF061
@author Tiago Rossini Coradini
@since 27/12/2016
@version 1.0
@description Rotina para tratamento do preenchimento automático do código do fornecedor levando em consideração o CNPJ e Filial. 
@obs OS: 4324-16 - Claudia Carvalho
@type function
/*/

User Function BIAF061()
Local lRet := .T.
Local oModel := FwModelActive()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cFornece := ""
Local cLoja := ""

	If M->A2_TIPO <> 'F' .And. Len(AllTrim(M->A2_CGC)) > 11

		cSQL := " SELECT ISNULL(MAX(A2_COD), '') AS A2_COD, ISNULL(MAX(A2_LOJA), '') AS A2_LOJA "
		cSQL += " FROM "+ RetSQLName("SA2")
		cSQL += " WHERE A2_FILIAL = "+ ValToSQL(xFilial("SA2"))
		cSQL += " AND A2_COD BETWEEN '000000' AND '999999' "
		cSQL += " AND SUBSTRING(A2_CGC, 1, 8) = "+ ValToSQL(SubStr(AllTrim(M->A2_CGC), 1, 8))
		cSQL += " AND A2_COD <> '009653' "
		cSQL += " AND D_E_L_E_T_ = ' ' "
		
		TcQuery cSQL New Alias (cQry)

		If !Empty((cQry)->A2_COD)

			cFornece := (cQry)->A2_COD
			cLoja := Soma1((cQry)->A2_LOJA)			

		Else

			cFornece := U_BIAF060()
			cLoja := "01"			

		EndIf

		(cQry)->(DbCloseArea())

	Else

		cFornece := U_BIAF060()
		cLoja := "01"			

	EndIf	

	oModel:SetValue("SA2MASTER", "A2_COD", cFornece)
	oModel:SetValue("SA2MASTER", "A2_LOJA", cLoja)
	
Return(cFornece)