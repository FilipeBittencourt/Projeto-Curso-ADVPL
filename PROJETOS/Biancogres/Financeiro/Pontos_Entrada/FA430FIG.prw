#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA430FIG
@author Tiago Rossini Coradini
@since 13/03/2018
@version 1.0
@description Permite modificar o CNPJ obtido da leitura do arquivo de retorno DDA, de modo que a tabela SA2 seja posicionada através do CNPJ  
@obs Ticket: 936
@type Function
/*/

User Function FA430FIG()
Local cRet := ""
Local aArea := GetArea()
Local cCNPJ := ParamIxb[1]	
	
	cRet := U_BIAF108(cCNPJ, dBaixa, nValPgto)
		
	RestArea(aArea)
	
Return(cRet)