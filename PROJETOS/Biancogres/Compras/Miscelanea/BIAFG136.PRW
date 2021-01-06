#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG136
@author Gabriel Rossi Mafioletti
@since 02/11/2020
@version 1.0
@description Validações e gatilhos referentes ao grupo de clientes e categoria
@type function
/*/


//Gatilho do campo A1_GRPVEN, para alterar a cagetoria de maior faturamento do grupo
User function BFG136A()

	Local _aArea	:= GetArea()
	Local _cAlias	:=	GetNextAlias()
	Local _cCateg	:=	M->A1_YCATEG
	
	If !Empty(M->A1_GRPVEN) 

		BeginSql Alias _cAlias
			%NoParser%
			SELECT TOP 1 A.CATCLI
				,A.CLIENTE
				,A.LOJA
				,SUM(A.VALOR)
			FROM VW_SAP_CML_MOVVENDAS A
			JOIN %TABLE:SA1% SA1 WITH(NOLOCK) ON A.CLIENTE = SA1.A1_COD
				AND A.LOJA = SA1.A1_LOJA
				AND SA1.A1_GRPVEN = %Exp:M->A1_GRPVEN%
				AND SA1.A1_MSBLQL <> '1'
				AND SA1.%NotDel%
			WHERE A.DTEMIS >= CONVERT(VARCHAR, DATEADD(M, - 6, GETDATE()), 112)
				AND A.%NotDel%
				AND A.ATUDPL = 'S'
				AND A.RESULT1 = 'S'
				AND A.RESULT2 = 'S'
			GROUP BY CATCLI
				,CLIENTE
				,LOJA
			ORDER BY 4 DESC
		EndSql

		If (_cAlias)->(!EOF())
			_cCateg	:=	(_cAlias)->CATCLI
		EndIf
		
		(_cAlias)->(DbCloseArea())
	EndIf

	RestArea(_aArea)

Return _cCateg

//Validação para preencher a categoria dos demais clientes do grupo ao alterar a categoria de um cliente
User function BFG136B()
	Local _cSql	:=	""
	If !Empty(M->A1_GRPVEN) .And. !Empty(M->A1_YCAT) .And. MsgYesNo("Deseja replicar a nova categoria para todos os clientes do atual grupo de vendas?")
		_cSql	:=	" UPDATE " + RetSqlName("SA1") + CRLF
		_cSql	+=	" SET A1_YCAT = " + ValtoSql(M->A1_YCAT) + CRLF
		_cSql	+=	" WHERE A1_GRPVEN = " + ValtoSql(M->A1_GRPVEN)
	
		TcSqlExec(_cSql)
	EndIf
Return .T.