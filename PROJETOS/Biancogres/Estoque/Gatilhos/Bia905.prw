#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA905
@author Ranisses A. Corona
@since 31/03/04
@version 1.0
@description Adiciona o valor do campo ZJ_VLRTOT
@obs Estoque e Custos
@type function
/*/

User Function BIA905()

	wVlrTot		:= 0
	wCod		:= Gdfieldget("ZJ_COD",n)
	wLocal		:= Gdfieldget("ZJ_LOCAL",n)
	wQuant		:= Gdfieldget("ZJ_QUANT",n)
	wVlrTot		:= Gdfieldget("ZJ_VLRTOT",n)
	wEMPDEST	:= Gdfieldget("ZJ_EMPDEST",n)
	wLocal	 	:= Gdfieldget("ZJ_LOCAL",n)

	//(11/09/14 - Thiago Dantas) - Caso não tenha empresa, pega a empresa do solicitante.
	If Empty(wEMPDEST)
		wEMPDEST := M->ZI_EMPRESA
	EndIf

	//Se o Almoxarifado estiver vazio, zera a quantidade
	If Empty(Alltrim(wLocal))
		Msgbox("O campo Almoxarifado está vazio. Favor verificar o Produto e Almoxarifado!","Aviso","INFO")
		Gdfieldput('ZJ_QUANT',0,n)	
		Return(wVlrTot)
	EndIf

	cAliasTmp := GetNextAlias()
	If wEMPDEST == "01"
		BeginSql Alias cAliasTmp
			SELECT * FROM SB2010 SB2 WHERE B2_COD = %Exp:wCod% AND B2_LOCAL = %Exp:wLocal% AND %NOTDEL%
		EndSql
	ElseIf wEMPDEST == "05"
		BeginSql Alias cAliasTmp
			SELECT * FROM SB2050 SB2 WHERE B2_COD = %Exp:wCod% AND B2_LOCAL = %Exp:wLocal% AND %NOTDEL%
		EndSql
	ElseIf wEMPDEST == "14"
		BeginSql Alias cAliasTmp
			SELECT * FROM SB2140 SB2 WHERE B2_COD = %Exp:wCod% AND B2_LOCAL = %Exp:wLocal% AND %NOTDEL%
		EndSql
	EndIf

	If Alltrim(M->ZI_TIPO) == "DU"
		wVlrTot := 0.01
	Else //Utilizado para RE / DN
		wVlrTot := wQuant * (cAliasTmp)->B2_CM1
	EndIf

	(cAliasTmp)->(dbCloseArea())

Return(wVlrTot)
