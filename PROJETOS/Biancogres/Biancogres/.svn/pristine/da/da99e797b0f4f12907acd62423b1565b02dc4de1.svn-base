#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"


/*/{Protheus.doc} BIAFG021
@author Gabriel Rossi Mafioletti
@since 28/08/2017
@version 1.0
@description Relatório de Empenho X Estoque Novo (Para a rotina BIA570)
@type function
/*/

User Function BIAFG020()
/*
Variáveis Private da Rotina BIA570
	yyDtIni		Data Inicial
	yyDtFim		Data Fim
	oNGDd1Ap	GetDados 
*/

Local _nPosOp	:=	asCan(oNGDd1Ap:aHeader,{|x| UPPER(ALLTRIM(x[2])) == "NUMOP"})
Local _nPosQtd	:=	asCan(oNGDd1Ap:aHeader,{|x| UPPER(ALLTRIM(x[2])) == "QTDM2"})
Local _nPosPrd	:=	asCan(oNGDd1Ap:aHeader,{|x| UPPER(ALLTRIM(x[2])) == "PROD"})
Local _nPosDMov	:=	asCan(oNGDd1Ap:aHeader,{|x| UPPER(ALLTRIM(x[2])) == "DTMOV"})

Local _aRegs	:=	{}
Local _nI
Local _npos
Local _aSintetico	:=	{}
Local _aAnalit	:=	{}
Local _cAlias
Local _nSaldo	:=	0
Local _cOpNFirm	:=	""

/*
_aSintetico
1- Local
2- Produto
3- Descrição
4- Saldo Inicial
5- Movimentação(QTD do Insumo na SD4/QTD do PA ba SC2 * Somatório da _aRegs)
6- Saldo Final
*/


For _nI := 1 to Len(oNGDd1Ap:aCols)
	If !Empty(oNGDd1Ap:aCols[_nI,_nPosOp]) .And. Alltrim(oNGDd1Ap:aCols[_nI,_nPosOp]) <> "Err:_LOCALIZ" 
		If (_nPos := aScan(_aRegs,{|x| x[1] == Substr(oNGDd1Ap:aCols[_nI,_nPosOp],1,8)}))> 0
			_aRegs[_nPos,2]	+=	oNGDd1Ap:aCols[_nI,_nPosQtd]
		Else
			aAdd(_aRegs,{Substr(oNGDd1Ap:aCols[_nI,_nPosOp],1,8),oNGDd1Ap:aCols[_nI,_nPosQtd],"FIRME",oNGDd1Ap:aCols[_nI,_nPosDmov]})
		EndIf
	Else
		_cOpNFirm	:=	fGetOpNFir(oNGDd1Ap:aCols[_nI,_nPosPrd])
		If !Empty(_cOpNFirm)
			If (_nPos := aScan(_aRegs,{|x| x[1] == _cOpNFirm}))> 0
				_aRegs[_nPos,2]	+=	oNGDd1Ap:aCols[_nI,_nPosQtd]
			Else
				aAdd(_aRegs,{_cOpNFirm,oNGDd1Ap:aCols[_nI,_nPosQtd],"NFIRME",oNGDd1Ap:aCols[_nI,_nPosDMov]})
			EndIf		
		EndIf
	EndIf
Next

For _nI	:= 1 to Len(_aRegs)

	_cAlias	:=	GetNextAlias()
	fGetIns(_cAlias, _aRegs[_nI,1])
	
	While (_cAlias)->(!EOF())

		_nSaldo	:=	0
		SB2->(DbSetOrder(1))
		If SB2->(DbSeek(xFilial("SB2")+(_cAlias)->(D4_COD+D4_LOCAL)))
			_nSaldo	:=	SB2->B2_QATU - SB2->B2_RESERVA
		EndIf

		If (_nPos	:= aScan(_aSintetico,{|x| x[1] == (_cAlias)->D4_LOCAL .And. X[2] == (_cAlias)->D4_COD })) == 0	
			aAdd(_aSintetico,;
					{;
						(_cAlias)->D4_LOCAL,;
						(_cAlias)->D4_COD,;
						(_cAlias)->B1_DESC,;
						_nSaldo,;
						(_cAlias)->QTD * _aRegs[_nI,2],;
						_nSaldo - ((_cAlias)->QTD * _aRegs[_nI,2]);
					};
				)
		Else
			_aSintetico[_nPos,5]	+= (_cAlias)->QTD * _aRegs[_nI,2]
			_aSintetico[_nPos,6]	-= (_cAlias)->QTD * _aRegs[_nI,2] 
		EndIf
		
		aAdd(_aAnalit,;
				{;
					(_cAlias)->OP,;
					(_cAlias)->D4_LOCAL,;
					(_cAlias)->D4_COD,;
					(_cAlias)->B1_DESC,;
					_nSaldo,;
					(_cAlias)->QTD * _aRegs[_nI,2],;
					_nSaldo - ((_cAlias)->QTD * _aRegs[_nI,2]),;
					POSICIONE("SC2",1,xFilial("SC2")+Alltrim((_cAlias)->OP)+"001","C2_PRODUTO"),;
					Dtoc(_aRegs[_nI,4]),;
					_aRegs[_nI,3];
				};
			)		
		
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbCloseArea())
Next

fGeraRel(_aSintetico,_aAnalit)

Return

Static Function fGetIns(_cAlias, _cOp)
	
	BeginSql Alias _cAlias
	
		SELECT  C2_NUM + SC2.C2_ITEM AS OP ,
				SC2.C2_EMISSAO,
		        D4_LOCAL ,
		        SD4.D4_COD ,
		        SB1.B1_DESC ,
		        SD4.D4_PRODUTO,
		        SUM(SD4.D4_QTDEORI / SC2.C2_QUANT) QTD
		FROM    %TABLE:SD4% SD4
		        JOIN %TABLE:SC2% SC2 ON C2_FILIAL = %XFILIAL:SC2%
		                           AND C2_NUM + C2_ITEM + SC2.C2_SEQUEN = SD4.D4_OP
		                           AND SC2.%NOTDEL%
		        JOIN SB1010 SB1 ON SB1.B1_COD = SD4.D4_COD
		                           AND SB1.%NOTDEL%
		                           AND SB1.B1_TIPO <> 'PP'
		WHERE   SC2.C2_SEQUEN IN ('001','002')
				AND SD4.D4_FILIAL = %XFILIAL:SD4%
		        AND SUBSTRING(SD4.D4_OP, 1, 8) = %Exp:_cOp%
		        AND SD4.%NOTDEL%
		GROUP BY C2_NUM + C2_ITEM ,
				SC2.C2_EMISSAO,
		        D4_LOCAL ,
		        SD4.D4_PRODUTO,
		        SD4.D4_COD ,
		        SB1.B1_DESC 

	EndSql

Return

Static Function fGeraRel(_aSintetico,_aAnalit)

	Local nTotReg	:=	Len(_aSintetico) + Len(_aAnalit)
	local nRegAtu   := 0

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIAFG020_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	Local _nI

	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio Analitico",{20,60,60,60,27,45,255,37,255,51,62,47},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,10) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,10) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Empenho x Estoque - Analitico",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,10)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("OP"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Status"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Emissão"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Local"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Prod. Pai"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Insumo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Inicial"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)			
	oExcel:AddCelula("Movimentação"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Final"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		
	
	For _nI	:=	1 to Len(_aAnalit)

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( _aAnalit[_nI,1]															,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,10]															,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,9]															,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)		
		oExcel:AddCelula( _aAnalit[_nI,2]															,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,8]															,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Posicione("SB1",1,xFilial("SB1")+_aAnalit[_nI,8],"B1_DESC") 				,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,3]															,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,4] 															,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,5]															,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,6]															,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aAnalit[_nI,7]															,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)		


		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")


	Next


	oExcel:AddPlanilha("Relatorio Sintetico",{20,27,37,255,51,62,47},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,5) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,5) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Empenho x Estoque - Sintetico",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,5)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Local"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Insumo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Inicial"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)			
	oExcel:AddCelula("Movimentação"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Final"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		
	
	For _nI	:=	1 to Len(_aSintetico)

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( _aSintetico[_nI,1]															,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aSintetico[_nI,2]															,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aSintetico[_nI,3]															,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aSintetico[_nI,4] 															,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aSintetico[_nI,5]															,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _aSintetico[_nI,6]															,0		 					,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		


		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")


	Next

	oExcel:SaveXml(AllTrim(GetTempPath()),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	
Return

Static Function fGetOpNFirm(_cCOd)

	Local _cOp	:=	""
	Local _cAlias	:=	GetNextAlias()
	
	
	BEGINSQL Alias _cALias
		%NoParser%
		SELECT C2_NUM + C2_ITEM AS OP
		FROM %TABLE:SC2% SC2 WITH (NOLOCK)
		INNER JOIN %TABLE:SB1% SB1 WITH (NOLOCK) ON B1_FILIAL = %XFILIAL:SB1%
			AND B1_COD = C2_PRODUTO
			AND B1_YSTATUS = '1'
			AND SB1.%NotDel%
		LEFT JOIN %TABLE:SD4% SD4 WITH (NOLOCK) ON D4_FILIAL = %XFILIAL:SD4%
			AND D4_OP = C2_NUM + C2_ITEM + C2_SEQUEN + '  '
			AND (
				SELECT COUNT(*)
				FROM %TABLE:SB1% WITH (NOLOCK)
				WHERE B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = D4_COD
					AND B1_TIPO IN (
						'PS'
						,'PA'
						)
					AND %NotDel%
				) > 0
			AND SD4.%NotDel%
		WHERE C2_FILIAL = %XFILIAL:SC2%
			AND C2_PRODUTO = %Exp:_cCod%
			AND C2_DATRF = '        '
			AND C2_YDTFIRM = '        '
			AND SC2.%NotDel%
		ORDER BY C2_EMISSAO DESC

	EndSql

	If (_cAlias)->(!EOF())
		_cOp	:=	(_cAlias)->OP
	EndIf
	
	(_cAlias)->(DbCloseArea())
Return _cOp
