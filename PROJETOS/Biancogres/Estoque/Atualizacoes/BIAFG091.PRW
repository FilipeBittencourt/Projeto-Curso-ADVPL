#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG091
@author Gabriel Rossi Mafioletti
@since 27/05/2019 
@version 1.0
@description Job para Integra��o das Pr�-Requisi��es vindas do BIZAGI
@type function
/*/

User Function BIAFG091()

	fProcessa('01','01')

	fProcessa('14','01')


RETURN

Static Function fProcessa(_cEmp,_cFil)
	Local _cAlias
	Local _aRet
	Local _cSql
	Local _cRecnos	:=	""
	Local _nI

	Private _cErro	:=	""

	RpcSetType(3)
	RPCSetEnv(_cEmp, _cFil)

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		%NoParser%
		SELECT ID,
			   ISNULL(EMPRESA,'01'),
		       DADOS_ENTRADA DADOS,
		       PROCESSO_BIZAGI PROCBIZ
		  FROM BZINTEGRACAO (NOLOCK)
		 WHERE PROCESSO_NOME = 'PRQ'
		   AND STATUS = 'IB'
		   AND DADOS_ENTRADA IS NOT NULL
		   AND ISNULL(EMPRESA,'01') = %Exp:cEmpAnt%
		   AND NOT EXISTS (SELECT 1
		                     FROM %TABLE:SZI% (NOLOCK)
							WHERE ZI_YBIZAGI = PROCESSO_BIZAGI
							  AND %NotDel%)
	EndSql

	While (_cAlias)->(!EOF())
		_cErro		:=	""
		_cRecnos	:=	""
		_aRet		:=	fDados((_cAlias)->DADOS)

		If Empty(_aRet[1]) .Or. Empty(_aRet[2])
			(_cAlias)->(DbSkip())
			Loop
		ElseIf !fValItens(_aRet[2])
			(_cAlias)->(DbSkip())
			Loop
		EndIF

		BEGIN TRANSACTION
			DbSelectArea("ZZY")
			DbSetOrder(3)
			DbSeek(xFilial("ZZY")+_aRet[1,3])

			_msDocSZI := GetSxENum("SZI","ZI_DOC")
			SZI->(dbSetOrder(1))
			If SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
				While .T.
					_msDocSZI := GetSxENum("SZI","ZI_DOC")
					SZI->(dbSetOrder(1))
					If !SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
						Exit
					EndIf
				End
			EndIf

			RecLock("SZI",.T.)
			SZI->ZI_FILIAL	:=	xFilial("SZI")
			SZI->ZI_DOC		:=	_msDocSZI
			SZI->ZI_TIPO	:=	_aRet[1,1]
			SZI->ZI_EMISSAO	:=	Date()
			SZI->ZI_CLVL	:=	_aRet[1,2]
			SZI->ZI_CC		:=	U_B902BCC(SZI->ZI_CLVL)
			SZI->ZI_MATRIC	:=	_aRet[1,3]
			SZI->ZI_NOME	:=	ZZY->ZZY_NOME
			SZI->ZI_BAIXA	:=	"N"
			SZI->ZI_EMPRESA	:=	cEmpAnt
			SZI->ZI_YLOCAL	:=	_aRet[2,1,3]
			SZI->ZI_YSI		:=	_aret[1,4]
			SZI->ZI_ITEMCTA	:=	_aret[1,5]
			SZI->ZI_YSUBITE	:=	_aret[1,6]

			If FIELDPOS("ZI_YBIZAGI") > 0
				SZI->ZI_YBIZAGI	:=	(_cAlias)->PROCBIZ
			EndIf
			SZI->(MsUnlock())
			_cRecnos	:=	"{SZI," + Alltrim(Str(SZI->(RECNO()))) + "};{SZJ"

			For _nI	:=	1 to Len(_aRet[2])
				Reclock("SZJ",.T.)
				SZJ->ZJ_FILIAL	:=	xFilial("SZJ")
				SZJ->ZJ_DOC		:=	SZI->ZI_DOC
				SZJ->ZJ_COD		:=	_aRet[2,_nI,1]
				SZJ->ZJ_DESCRI	:=	POSICIONE("SB1",1,xFilial("SB1")+_aRet[2,_nI,1],"B1_DESC")
				SZJ->ZJ_LOCAL	:=	_aRet[2,_nI,3]
				SZJ->ZJ_UM		:=	POSICIONE("SB1",1,xFilial("SB1")+_aRet[2,_nI,1],"B1_UM")
				SZJ->ZJ_QUANT	:=	Val(_aRet[2,_nI,2])
				SZJ->ZJ_VLRTOT	:=	Iif(SZI->ZI_TIPO == "DU",0.01,fRetCm(SZJ->ZJ_COD,SZJ->ZJ_LOCAL) * SZJ->ZJ_QUANT)
				SZJ->ZJ_APLIC	:=	Iif(Empty(_aRet[2,_nI,6]),'0',_aRet[2,_nI,6])
				SZJ->ZJ_TAG		:=	_aRet[2,_nI,5]
				SZJ->ZJ_YLOCALI	:=	Posicione("ZCN",2,xFilial("ZCN")+SZJ->ZJ_COD+SZJ->ZJ_LOCAL,"ZCN_LOCALI")
				SZJ->ZJ_YMELHOR	:=	Iif(_aRet[2,_nI,7] == "000000", "", _aRet[2,_nI,7]) //Verificar Melhoria
				SZJ->ZJ_EMPRESA	:=	cEmpAnt
				SZJ->ZJ_EMPDEST	:=	cEmpAnt
				SZJ->ZJ_CONTA	:=	_aRet[2,_nI,4]
				SZJ->ZJ_CLVL	:=	SZI->ZI_CLVL
				SZJ->ZJ_YPARADA	:=	Iif(UPPER(_aRet[2,_nI,10]) == 'TRUE','S','N')
				SZJ->ZJ_QTAPROV	:=	SZJ->ZJ_QUANT
				SZJ->ZJ_YDRIVER	:=	Iif(_aRet[2,_nI,8] == "-1","",_aRet[2,_nI,8])
				SZJ->ZJ_YJTDRV	:=	_aRet[2,_nI,9]

				If len(_aRet[2,_nI]) >= 11
					SZJ->ZJ_YMATORI :=  _aRet[2,_nI,11]
				EndIf

				SZJ->(MsUnlock())
				_cRecnos	+=	","+Alltrim(Str(SZJ->(Recno())))

				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek(xFilial("SB2")+SZJ->ZJ_COD+SZJ->ZJ_LOCAL))
					CriaSb2(SZJ->ZJ_COD,SZJ->ZJ_LOCAL)
					If !_aRet[1,1] $ "DU_DN"
						_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(0)) + CRLF
					EndIf
				Else
					If !_aRet[1,1] $ "DU_DN"
						If SZJ->ZJ_QUANT > (SB2->B2_QATU - SB2->B2_RESERVA)
							_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(SB2->B2_QATU - SB2->B2_RESERVA)) + CRLF
						EndIf
					EndIf
				EndIf

				If SZI->ZI_TIPO == 'RE'
					_cSql := "UPDATE "+RetSqlName("SB2")+" SET B2_RESERVA = B2_RESERVA + "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
					TcSQLExec(_cSql)
				EndIf
			Next

			_cRecnos	+= "}"

			If !Empty(_cErro)
				DisarmTransaction()
				_cSql	:=	"UPDATE BZINTEGRACAO SET STATUS = 'ER', DADOS_RETORNO = " + ValtoSql(_cErro) + " WHERE ID = " + ValtoSql((_cAlias)->ID)
			Else
				//corre��o feita para evitar erro ocorrido no ticket 22716 - Rodrigo
				_cSql	:=	"UPDATE BZINTEGRACAO SET STATUS = 'AP', DADOS_RETORNO = " + ValtoSql(SZI->ZI_DOC) + ", DATA_INTEGRACAO_PROTHEUS = GetDate(), RECNO_RETORNO = " + ValtoSql(_cRecnos) + " WHERE ID = " + ValtoSql((_cAlias)->ID)
			EndIf

			TcSqlExec(_cSql)

		END TRANSACTION

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

	RpcClearEnv()
Return

Static Function fDados(_cDados)

	Local _aRet	:=	{;
		{},; //Cabe�alho
	{};  //Itens
	}

	Local _aDados	:=	{}
	Local _aItens	:=	{}

	Local _nI

	_aDados	:=	StrtoKArr(Alltrim(_cDados),";")

	DO CASE
	CASE Alltrim(_aDados[5]) $ "DU_DN_RE"
		aAdd(_aRet[1],_aDados[5])
	OTHERWISE
		aAdd(_aRet[1],"RE")
	ENDCASE

	aAdd(_aRet[1],_aDados[6]) //Classe de Valor
	aAdd(_aRet[1],_aDados[2]) //Matr�cula

	If Len(_aDados) >= 11
		aAdd(_aRet[1],Iif(Alltrim(_aDados[10]) == 'null','',_aDados[10]))
		aAdd(_aRet[1],Iif(Alltrim(_aDados[11]) == 'null','',_aDados[11]))
	Else
		aAdd(_aRet[1],"")
		aAdd(_aRet[1],"")
	EndIf
	If Len(_aDados) >= 12
		aAdd(_aRet[1],Iif(Alltrim(_aDados[12]) == 'null','',_aDados[12]))
	Else
		aAdd(_aRet[1],"")
	EndIf


	/*
	_aDados[9] - Itens
	1 - C�digo Produto
	2 - Quantidade
	3 - Local
	4 - Conta
	5 - Tag
	6 - Aplica��o
	7 - Melhoria
	8 - Driver
	9 - Justificativa Driver
	10 - Parada
	*/
	_aItens	:=	StrToKArr(REPLACE(REPLACE(_aDados[9],"[",""),"]",""),"&")

	For _nI	:=	1 to Len(_aItens)
		aAdd(_aRet[2],StrToKarr(_aItens[_nI],"|"))
	Next

Return _aRet

Static Function fRetCm(_cCod,_cLocal)

	Local _nCm		:=	0
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		SELECT ISNULL(B2_CM1,0) B2_CM1
		FROM %TABLE:SB2% (NOLOCK)
		WHERE B2_FILIAL = %XFILIAL:SB2%
		AND B2_COD = %Exp:_cCod%
		AND B2_LOCAL = %Exp:_cLocal%
		AND %NotDel%
	EndSql

	_nCm	:=	(_cAlias)->B2_CM1

	(_cAlias)->(DbCloseArea())

Return _nCm

Static Function fValItens(_aItens)

	Local _lRet	:=	.T.
	Local _nI

	For _nI	:= 1 to Len(_aItens)

		If Len(_aItens[_nI]) < 10
			_lRet	:=	.F.
			Exit
		EndIf
	Next

Return _lRet
