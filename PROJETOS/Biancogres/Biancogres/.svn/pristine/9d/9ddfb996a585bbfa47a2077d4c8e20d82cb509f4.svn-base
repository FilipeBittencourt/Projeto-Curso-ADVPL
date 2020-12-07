#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA715
@author Marcos Alberto Soprani
@since 21/03/13
@version 1.0
@description Conferência de Baixa Automática de Caixa e Pallet
@obs ...
@type function
/*/

User Function BIA715()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi

	cHInicio := Time()
	fPerg := "BIA715"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aDados2 := {}

	TG005 := "   WITH D3CAIXAS AS(SELECT D3_NUMSEQ CXNUMSEQ, XD3.D3_COD CXCOMP, XD3.D3_QUANT CXQUANT
	TG005 += "                      FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	TG005 += "                     INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_COD = XD3.D3_COD
	TG005 += "                                          AND B1_GRUPO = '104A'
	TG005 += "                                          AND SB1.D_E_L_E_T_ = ' '
	TG005 += "                     WHERE XD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TG005 += "                       AND XD3.D3_OP <> '             '
	TG005 += "                       AND XD3.D_E_L_E_T_ = ' '
	//Gabriel - Solicitado Por Marcos - OS 3432-17 - Inserido UNION para recuperar casos referentes às operações com caixa
	TG005 += "  			UNION ALL SELECT SUBSTRING(D3_YOBS,CHARINDEX('NUMSEQ: ',D3_YOBS) + 8, 6  ) NUMSEQ,
	TG005 += "  							SUBSTRING(D3_YOBS,CHARINDEX('Prod: ',D3_YOBS) + 6, CHARINDEX('DOC:',D3_YOBS) - 8 )  AS PROD,
	TG005 += "  							D3_QUANT
	TG005 += "                      FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	TG005 += "                     INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_COD = XD3.D3_COD
	TG005 += "                                          AND B1_GRUPO = '104A'
	TG005 += "                                          AND SB1.D_E_L_E_T_ = ' '
	TG005 += "                     WHERE XD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TG005 += "								AND D3_YOBS <> '' 
	TG005 += "								AND D3_CF = 'DE4' 
	TG005 += "								AND D3_TM = '499' 
	TG005 += "								AND D3_LOCAL ='07' 
	TG005 += "								AND D3_YOBS LIKE '%Prod:%DOC:%NUMSEQ:%'
	TG005 += "                       		AND XD3.D_E_L_E_T_ = ' ')
	
	TG005 += " ,     D3PALLET AS (SELECT D3_NUMSEQ PLNUMSEQ, XD3.D3_COD PLCOMP, XD3.D3_QUANT PLQUANT
	TG005 += "                      FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	TG005 += "                     INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '  '
	TG005 += "                                          AND B1_COD = XD3.D3_COD
	TG005 += "                                          AND B1_GRUPO = '104B'
	TG005 += "                                          AND SB1.D_E_L_E_T_ = ' '
	TG005 += "                     WHERE XD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TG005 += "                       AND XD3.D3_OP <> '             '
	TG005 += "                       AND XD3.D_E_L_E_T_ = ' ')
	TG005 += " SELECT D3_TM,
	TG005 += "        D3_EMISSAO,
	TG005 += "        D3_OP,
	TG005 += "        D3_DOC,
	TG005 += "        D3_NUMSEQ,
	TG005 += "        D3_COD,
	TG005 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	TG005 += "        D3_QUANT,
	TG005 += "        CXA.CXCOMP CAIXA,
	TG005 += "        CXA.CXQUANT QTD_CX,
	TG005 += "        PLT.PLCOMP PALLET,
	TG005 += "        PLT.PLQUANT QTD_PALLET
	TG005 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	TG005 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_COD = D3_COD
	TG005 += "                       AND SB1.D_E_L_E_T_ = ' '
	TG005 += "   LEFT JOIN D3CAIXAS CXA ON CXA.CXNUMSEQ = SD3.D3_NUMSEQ
	TG005 += "   LEFT JOIN D3PALLET PLT ON PLT.PLNUMSEQ = SD3.D3_NUMSEQ
	TG005 += "  WHERE D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TG005 += "    AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	TG005 += "    AND D3_TIPO = 'PA'
	TG005 += "    AND D3_TM = '010'
	TG005 += "    AND D3_ESTORNO = ' '
	TG005 += "    AND SD3.D_E_L_E_T_ = ' '
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TG005),'TG05',.T.,.T.)
	dbSelectArea("TG05")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		aAdd(aDados2, { TG05->D3_TM,;
		dtoc(stod(TG05->D3_EMISSAO)),;
		TG05->D3_OP,;
		TG05->D3_DOC,;
		TG05->D3_NUMSEQ,;
		TG05->D3_COD,;
		TG05->DESCR,;
		Transform(TG05->D3_QUANT   ,"@E 999,999,999.9999"),;
		TG05->CAIXA,;
		Transform(TG05->QTD_CX,"@E 999,999,999.9999"),;
		TG05->PALLET,;
		Transform(TG05->QTD_PALLET,"@E 999,999,999.9999")} )

		dbSelectArea("TG05")
		dbSkip()

	End
	aStru1 := ("TG05")->(dbStruct())
	TG05->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado

	U_BIAxExcel(aDados2, aStru1, "BIA715"+strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do Produto          ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Ate Produto         ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
