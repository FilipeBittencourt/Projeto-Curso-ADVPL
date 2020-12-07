#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BACP0021
@description Monitor de Impressao Automatica
@author Fernando Rocha
@since 27/11/2019
@version 1.0
@type function
/*/

User Function BACP0021()

	Local cQuery		:= ""
	Local cAliasTemp	:= GetNextAlias()
	Local oObj			:= TGnreTransmissao():New(.T.)
		
	cQuery += " SELECT " + CRLF
	cQuery += " F2_DOC, F2_SERIE " + CRLF
	cQuery += " FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " + CRLF	     	
	cQuery += " WHERE " + CRLF       
	cQuery += " F2_FILIAL	 = " + ValToSql(xFilial("SF2")) + CRLF    
	cQuery += " AND F2_CHVNFE = '' " + CRLF
	cQuery += " AND F2_EMISSAO BETWEEN CONVERT(VARCHAR, GETDATE() -30, 112) AND CONVERT(VARCHAR, GETDATE() -1, 112) "
	//cQuery += " AND F2_EMISSAO = '20200113' 
	cQuery += " AND D_E_L_E_T_ = '' " + CRLF

	TcQuery cQuery New Alias (cAliasTemp)	

	While !(cAliasTemp)->(EoF())
		
		oObj:MonitoraNFe((cAliasTemp)->F2_SERIE, (cAliasTemp)->F2_DOC)

		(cAliasTemp)->(DbSkip())

	EndDo

	(cAliasTemp)->(DbCloseArea())
	
	RpcClearEnv()
	
Return()
