#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG126
@author Gabriel Rossi Mafioletti
@since 13/05/2019
@version 1.0
@description Job para Impressão de Etiquetas - Novo 
@type function
/*/

User Function BIAFG126()

	Local _cAlias
	Local msAliasImp
	Local _aRet
	Local _cSql
	Local _nI
	Local msImpsVald

	Private _cErro	:=	""

	RpcSetType(3)
	RpcSetEnv("01","01")

	msAliasImp := GetNextAlias()

	BeginSql Alias msAliasImp

		%NoParser%
		SELECT CODIGO
		FROM VW_BZ_IMPRESSORAS

	EndSql

	msImpsVald := ""
	While (msAliasImp)->(!EOF())

		msImpsVald += (msAliasImp)->CODIGO + "/"
		(msAliasImp)->(DbSkip())

	EndDo

	(msAliasImp)->(DbCloseArea())

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		%NoParser%
		SELECT ID 
		,DADOS_ENTRADA DADOS
		,PROCESSO_BIZAGI PROCBIZ
		FROM BZINTEGRACAO
		WHERE PROCESSO_NOME = 'RM' 
		AND ((STATUS = 'AP' 
		AND STATUS_ERP = 1) OR (
			STATUS = 'IB'
			AND DATA_INTEGRACAO_PROTHEUS >= '20210223 13:40'
			AND STATUS_ERP = '2'
			))
		AND GETDATE() - CONVERT(DATETIME, DATA_INTEGRACAO_PROTHEUS) < '1900-01-01 00:30:00.000'
		AND EMPRESA = %Exp:cEmpAnt%
		AND FILIAL = %Exp:cFilAnt%

	EndSql

	While (_cAlias)->(!EOF())

		_cErro	:=	""
		_aRet	:=	fDados((_cAlias)->DADOS)

		If !_aRet[1][5] $ msImpsVald

			(_cAlias)->(DbSkip())
			Loop

		EndIf 

		If Empty(_aRet[1]) .Or. Empty(_aRet[2]) 
			_cErro	:=	"INCONSISTENCIA NO REGISTRO"
			_cSql	:=	"UPDATE BZINTEGRACAO SET STATUS = 'EI', DADOS_RETORNO = "+ValtoSql(_cErro)+" WHERE ID = " + ValtoSql((_cAlias)->ID) 
			TcSqlExec(_cSql)
			(_cAlias)->(DbSkip())
			Loop

		ElseIf !fValItens(_aRet[2])
			_cErro	:= "INCONSISTENCIA NOS ITENS"
			_cSql	:=	"UPDATE BZINTEGRACAO SET STATUS = 'EI', DADOS_RETORNO = "+ValtoSql(_cErro)+" WHERE ID = " + ValtoSql((_cAlias)->ID) 
			TcSqlExec(_cSql)
			(_cAlias)->(DbSkip())
			Loop

		ElseIf Empty(_aRet[1,5])
			_cErro	:= "INCONSISTENCIA NO REGISTRO - IMPRESSORA NAO INFORMADA"
			_cSql	:=	"UPDATE BZINTEGRACAO SET STATUS = 'EI', DADOS_RETORNO = "+ValtoSql(_cErro)+" WHERE ID = " + ValtoSql((_cAlias)->ID) 
			TcSqlExec(_cSql)
			(_cAlias)->(DbSkip())
			Loop				

		EndIF

		For _nI	:= 1 To Len(_aRet[2])

			If _aRet[2,_nI,4] > 0

				fImpEtiq(_aRet[1,1],_aRet[1,2],_aRet[1,3],_aRet[1,4],_aRet[2,_nI,1],_aRet[2,_nI,2],_aRet[2,_nI,4],_aRet[1,5])

			EndIf

		Next

		If Empty(_cErro)

			_cSql	:=	"UPDATE BZINTEGRACAO SET STATUS = 'IM' WHERE ID = " + ValtoSql((_cAlias)->ID) 
			TcSqlExec(_cSql)	

		Else

			_cSql	:=	"UPDATE BZINTEGRACAO SET STATUS = 'EI', DADOS_RETORNO = "+ValtoSql(_cErro)+" WHERE ID = " + ValtoSql((_cAlias)->ID) 
			TcSqlExec(_cSql)			

		EndIf

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

	UP002 := " UPDATE A SET STATUS = 'IM' "
	UP002 += " FROM BZINTEGRACAO A "
	UP002 += " WHERE PROCESSO_NOME = 'RM' "
	UP002 += "       AND STATUS = 'AP' "
	UP002 += "       AND STATUS_ERP = 1 "
	UP002 += "       AND GETDATE() - CONVERT(DATETIME, DATA_INTEGRACAO_PROTHEUS) > '1900-01-01 23:59:59.999' "
	UP002 += "       AND EMPRESA = '" + cEmpAnt + "' "
	UP002 += "       AND FILIAL = '" + cFilAnt + "' "	
	TcSqlExec(UP002)

	RpcClearEnv()

Return

Static Function fDados(_cDados)

	Local _aRet	:=	{;
	{},; //Cabeçalho
	{};  //Itens
	}

	Local _aDados	:=	{}
	Local _aItens	:=	{}

	Local _nI

	_aDados	:=	StrtoKArr(Alltrim(_cDados),";")

	/*
	Cabeçalho
	01 - Chave
	02 - NF
	03 - Série
	04 - Cliente
	05 - Loja
	06 - Nome Cliente
	07 - CNPJ Cliente
	08 - Recebido?
	09 - Branco
	10 - Itens
	11 - Impressora
	*/

	aAdd(_aRet[1],_aDados[2])
	aAdd(_aRet[1],_aDados[3])
	aAdd(_aRet[1],_aDados[4])
	aAdd(_aRet[1],_aDados[5])

	If Len(_aDados) < 11
		aAdd(_aRet[1],"")
	Else
		aAdd(_aRet[1],_aDados[11])
	EndIf

	/*
	_aDados[10] - Itens
	1 - Item Nota
	2 - Código Produto
	3 - Recebido?
	4 - Qtd Etiquetas
	*/

	_aItens	:=	StrToKArr(REPLACE(REPLACE(_aDados[10],"[",""),"]",""),"&")

	For _nI	:=	1 to Len(_aItens)
		aAdd(_aRet[2],StrToKarr(_aItens[_nI],"|"))
		If Len(_aRet[2,_nI]) >= 4
			_aRet[2,_nI,4]	:=	Val(_aRet[2,_nI,4])
		EndIf
	Next

Return _aRet

Static Function fValItens(_aItens)

	Local _lRet	:=	.T.
	Local _nI	

	For _nI	:= 1 to Len(_aItens)

		If Len(_aItens[_nI]) < 4
			_lRet	:=	.F.
			Exit
		EndIf
	Next

Return _lRet

Static Function fImpEtiq(_cNota,_cSerie,_cFornece,_cLoja,_cItem,_cCod,_nEtiq,_cImpr)

	Local _cAlias	:=	GetNextAlias()
	//Local _cParPc	:=	Alltrim(GetMv("MV_YPCETIQ"))
	//Local _aPcEtiq	:=	StrToKarr(_cParPc,';')
	//Local wString
	//Local _cPcEtiq	:=	""
	//Local _cArqEtiq	:=	""

	BeginSql Alias _cAlias

		SELECT ISNULL(SC1.C1_SOLICIT ,'') SOLICIT,
		SC7.C7_NUM NUMPED,
		SC7.C7_LOCAL ALMOX,
		SB1.B1_UM UM,
		ZCN.ZCN_LOCALI LOCALI,
		SB1.B1_COD CODPRO,
		SB1.B1_DESC DESPRO,
		ZCN.ZCN_SEQUEN SEQ,
		'' MARCA,
		'' PN
		FROM %TABLE:SD1% SD1
		JOIN %TABLE:SC7% SC7 ON SD1.D1_FILIAL = SC7.C7_FILIAL
		AND SD1.D1_PEDIDO = SC7.C7_NUM
		AND SD1.D1_ITEMPC = SC7.C7_ITEM
		AND SC7.%NotDel%
		JOIN %TABLE:SB1% SB1 ON SB1.B1_COD = SD1.D1_COD
		AND SB1.%NotDel%
		LEFT JOIN %TABLE:SC1% SC1 ON SC1.C1_FILIAL = SC7.C7_FILIAL
		AND SC1.C1_NUM = SC7.C7_NUMSC
		AND SC1.C1_ITEM = SC7.C7_ITEMSC
		AND SC1.%NotDel%
		JOIN %TABLE:ZCN% ZCN ON ZCN.ZCN_FILIAL = SD1.D1_FILIAL
		AND ZCN.ZCN_COD = SD1.D1_COD
		AND ZCN.ZCN_LOCAL = SD1.D1_LOCAL
		AND ZCN.%NotDel%

		WHERE SD1.D1_FILIAL = %XFILIAL:SD1%
		AND SD1.D1_DOC = %Exp:_cNota%
		AND SD1.D1_SERIE = %Exp:_cSerie%
		AND SD1.D1_FORNECE = %Exp:_cFornece%
		AND SD1.D1_LOJA = %Exp:_cLoja%
		AND SD1.D1_TIPO = 'N'
		AND SD1.D1_ITEM = %Exp:_cItem%
		AND SD1.D1_COD = %Exp:_cCod%
		AND SD1.%NotDel%

	EndSql

	If (_cAlias)->(!EOF())

		U_BIAFG124((_cAlias)->CODPRO,_nEtiq,(_cAlias)->NUMPED,_cImpr,"BIZ",(_cAlias)->ALMOX)		

		Sleep(5000 * _nEtiq)

	Else

		_cerro	+=	" Item: " + _cItem + " nao encontrado "

	EndIf


	(_cAlias)->(DbCloseArea())

Return
