#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG102
@author Gabriel Rossi Mafioletti
@since 07/05/2019
@version 1.0
@description Job para Impressão de Etiquetas 
@type function
/*/



User Function BIAFG102()

	Local _cAlias
	Local _aRet
	Local _cSql
	Local _nI
	
	Private _cErro	:=	""

	RpcSetType(3)
	RpcSetEnv("01","01")

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		SELECT TOP 1 ID 
				,DADOS_ENTRADA DADOS
				,PROCESSO_BIZAGI PROCBIZ
		FROM BZINTEGRACAO
		WHERE PROCESSO_NOME = 'RM' 
			AND ((STATUS = 'AP' AND STATUS_ERP = '1') OR (STATUS = 'IB' AND DATA_INTEGRACAO_PROTHEUS >= '20210223 13:40' AND STATUS_ERP = '2')) 
			AND EMPRESA = %Exp:cEmpAnt%
			AND FILIAL = %Exp:cFilAnt%

	EndSql
	
		While (_cAlias)->(!EOF())
			_cErro	:=	""
			_aRet	:=	fDados((_cAlias)->DADOS)
			
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
			EndIF
		
			For _nI	:= 1 To Len(_aRet[2])
				If _aRet[2,_nI,4] > 0
					
					fImpEtiq(_aRet[1,1],_aRet[1,2],_aRet[1,3],_aRet[1,4],_aRet[2,_nI,1],_aRet[2,_nI,2],_aRet[2,_nI,4])
					
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
	*/

	aAdd(_aRet[1],_aDados[2])
	aAdd(_aRet[1],_aDados[3])
	aAdd(_aRet[1],_aDados[4])
	aAdd(_aRet[1],_aDados[5])
	
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

Static Function fImpEtiq(_cNota,_cSerie,_cFornece,_cLoja,_cItem,_cCod,_nEtiq)

	Local _cAlias	:=	GetNextAlias()
	Local _cParPc	:=	Alltrim(GetMv("MV_YPCETIQ"))
	Local _aPcEtiq	:=	StrToKarr(_cParPc,';')
	
	Local wString
	
	Local _cPcEtiq	:=	""
	Local _cArqEtiq	:=	""
	
	BeginSql Alias _cAlias
	
		SELECT ISNULL(SC1.C1_SOLICIT ,'') SOLICIT,
		 		SC7.C7_NUM NUMPED,
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

		_cPcEtiq	:=	_aPcEtiq[Val((_cAlias)->SEQ)]

		_cArqEtiq	:=	(_cAlias)->NUMPED+'-'+Alltrim((_cAlias)->CODPRO) + ".TMP"


		If File("D:\PROTHEUS12\Protheus_Data\ImpAutoEtiq\" + _cArqEtiq)
			_nRet	:=	FErase( "D:\PROTHEUS12\Protheus_Data\ImpAutoEtiq\" + _cArqEtiq )
		EndIf

		wString := "O0220" + Chr(13)
		wString := wString + "M0350"  + Chr(13)
		wString := wString + "c0000"  + Chr(13)
		wString := wString + "f000"   + Chr(13)
		wString := wString + "e"      + Chr(13)
		wString := wString + "LC0000" + Chr(13)
		wString := wString + "H09"     + Chr(13)
		wString := wString + "D11"     + Chr(13)
		wString := wString + "SC"      + Chr(13)
		wString := wString + "PC"      + Chr(13)
		wString := wString + "R0000"   + Chr(13)
		wString := wString + "z"       + Chr(13)
		wString := wString + "W"       + Chr(13)
		wString := wString + "^01"     + Chr(13)
		wString := wString + "121100001180007   DATA:" + DTOC(DATE()) + Chr(13)
		wString := wString + "121100000980007   UND.:" +AllTrim((_cAlias)->UM) + Chr(13)
		wString := wString + "121100000780007   LOC.:"     + SUBSTR((_cAlias)->LOCALI,01,18) + Chr(13)
		wString := wString + "1e5204000870140" + AllTrim((_cAlias)->CODPRO) + Chr(13)
		wString := wString + "113100000800140" + AllTrim((_cAlias)->CODPRO) + Chr(13)
		wString := wString + "121100000550020" + SUBSTR((_cAlias)->DESPRO   ,01,48) + Chr(13)
		wString := wString + "121100000420020" + SUBSTR((_cAlias)->DESPRO   ,49,48) + Chr(13)		
		wString := wString + "121100000220007   PC: " + (_cAlias)->NUMPED + "      SOLIC: "  + (_cAlias)->SOLICIT + Chr(13)
		wString := wString + "121100000020007   MARCA: "     + Alltrim((_cAlias)->MARCA) + "  P/N: " + Alltrim((_cAlias)->PN) + Chr(13)
		wString := wString + "Q"                           + StrZero(_nEtiq,4)                               + Chr(13)
		wString := wString + "E"                                                                           + Chr(13)

		MemoWrite("D:\PROTHEUS12\Protheus_Data\ImpAutoEtiq\" + _cArqEtiq,wString)
	
		//Apaga mapeamento
		WinExec("net use lpt3 /delete")
		//Realiza o mapeamento 
		WinExec("net use lpt3 \\"+_cPcEtiq+"\ARGOX")
		//Realiza a Impressão
		WinExec("CMD /C TYPE D:\PROTHEUS12\Protheus_Data\ImpAutoEtiq\" + _cArqEtiq + " > LPT3")

		Sleep(5000 + (2000 * (_nEtiq -1)))

		If File("D:\PROTHEUS12\Protheus_Data\ImpAutoEtiq\" + _cArqEtiq)
			_nRet	:=	FErase( "D:\PROTHEUS12\Protheus_Data\ImpAutoEtiq\" + _cArqEtiq )
		EndIf

	Else
		_cerro	+=	" Item: " + _cItem + " nao encontrado "

	EndIf
	
	
	
Return