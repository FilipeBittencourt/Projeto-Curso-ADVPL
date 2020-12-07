#Include "Protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} BIA251
@author Marcos Alberto Soprani
@since 05/07/11
@version 1.0
@description Kardex Resumido 
@type function
/*/

User Function BIA251()

	Private tlVetEst := {}
	Private xHotOri 

	Processa({|| RptDetail()})

Return ( tlVetEst )

Static Function RptDetail()

	Local hhi

	cHInicio := Time()
	fPerg := "BIA251"

	If Alltrim(UPPER(FunName())) == "BIA620"

		xHotOri  := "1" 

		MV_PAR01 := "C1"
		MV_PAR02 := "C1ZZZZZZZZZZZZZ"
		MV_PAR03 := "    "
		MV_PAR04 := "ZZZZ"
		MV_PAR05 := stod(DF07->Z75_DATARF)
		MV_PAR06 := stod(DF07->Z75_DATARF)
		MV_PAR07 := "02"
		MV_PAR08 := 1 
		MV_PAR09 := "PA"
		MV_PAR10 := "PA"

	Else

		xHotOri  := "2" 

		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		ValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA251",fPerg)

	xf_Stri := Alltrim(MV_PAR07)
	xLike   := "'"
	cs_VetLoc := {}
	If Right(xf_Stri,1) <> ','
		xf_Stri := xf_Stri+","
	EndIf
	While .T.
		nPos := AT(",", xf_Stri )
		If nPos > 0
			xLike   += Substr(xf_Stri,1,nPos-1)
			aAdd( cs_VetLoc , Substr(xf_Stri,1,nPos-1) )
			xf_Stri := Alltrim(Substr(xf_Stri,nPos+1,Len(xf_Stri)))
		Endif
		If Empty(xf_Stri)
			xLike += "'"
			Exit
		EndIf
		xLike += "','"
	End

	aDados2 := {}

	A0001 := " SELECT ' ' PERIODO,
	A0001 += "        B1_COD PRODUTO,
	A0001 += "        SUBSTRING(B1_DESC,1,100) DESCRIC,
	A0001 += "        B1_GRUPO GRUPO,
	A0001 += "        B1_UM UM,
	A0001 += "        '' ATIVO,
	A0001 += "        0 SAL_ANT,
	If MV_PAR08 == 1
		A0001 += "        ISNULL((SELECT SUM(D3_QUANT)
	Else
		A0001 += "        ISNULL((SELECT SUM(D3_CUSTO1)
	EndIf
	A0001 += "              FROM "+RetSqlName("SD3")+" SD3
	A0001 += "             WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	A0001 += "               AND D3_COD = B1_COD
	A0001 += "               AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'
	A0001 += "               AND D3_TM <= '500'
	A0001 += "               AND D3_LOCAL IN ("+xLike+")
	A0001 += "               AND D3_ESTORNO <> 'S'
	A0001 += "               AND SD3.D_E_L_E_T_ = ' '), 0)
	If "99" $ xLike
		If MV_PAR08 == 1
			A0001 += "                                         + ISNULL((SELECT SUM(D3_QUANT)
		Else
			A0001 += "                                         + ISNULL((SELECT SUM(D3_CUSTO1)
		EndIf
		A0001 += "                                                         FROM "+RetSqlName("SD3")+" SD3
		A0001 += "                                                        WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                                                          AND D3_COD = B1_COD
		A0001 += "                                                          AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'
		A0001 += "                                                          AND D3_CF = 'RE3'
		A0001 += "                                                          AND D3_LOCAL NOT IN ('99')
		A0001 += "                                                          AND D3_ESTORNO <> 'S'
		A0001 += "                                                          AND SD3.D_E_L_E_T_ = ' '), 0) 
	EndIf
	A0001 += " MI_ENT, "
	If MV_PAR08 == 1
		A0001 += "        ISNULL((SELECT SUM(D3_QUANT)
	Else
		A0001 += "        ISNULL((SELECT SUM(D3_CUSTO1)
	EndIf
	A0001 += "              FROM "+RetSqlName("SD3")+" SD3
	A0001 += "             WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	A0001 += "               AND D3_COD = B1_COD
	A0001 += "               AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'
	A0001 += "               AND D3_TM > '500'
	A0001 += "               AND D3_LOCAL IN ("+xLike+")
	A0001 += "               AND D3_ESTORNO <> 'S'
	A0001 += "               AND SD3.D_E_L_E_T_ = ' '), 0)
	If "99" $ xLike
		If MV_PAR08 == 1
			A0001 += "                                         + ISNULL((SELECT SUM(D3_QUANT)
		Else
			A0001 += "                                         + ISNULL((SELECT SUM(D3_CUSTO1)
		EndIf
		A0001 += "                                                         FROM "+RetSqlName("SD3")+" SD3
		A0001 += "                                                        WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                                                          AND D3_COD = B1_COD
		A0001 += "                                                          AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'
		A0001 += "                                                          AND D3_CF = 'DE3'
		A0001 += "                                                          AND D3_LOCAL NOT IN ('99')
		A0001 += "                                                          AND D3_ESTORNO <> 'S'
		A0001 += "                                                          AND SD3.D_E_L_E_T_ = ' '), 0) 
	EndIf
	A0001 += " MI_SAI, "
	If MV_PAR08 == 1
		A0001 += "        ISNULL((SELECT SUM(D1_QUANT)
	Else
		A0001 += "        ISNULL((SELECT SUM(D1_CUSTO)
	EndIf
	A0001 += "              FROM "+RetSqlName("SD1")+" SD1
	A0001 += "             INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                  AND F4_CODIGO = D1_TES
	A0001 += "                                  AND F4_ESTOQUE = 'S'
	A0001 += "                                  AND SF4.D_E_L_E_T_ = ' '
	A0001 += "             WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "               AND D1_COD = B1_COD
	A0001 += "               AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'
	A0001 += "               AND D1_LOCAL IN ("+xLike+")
	A0001 += "               AND SD1.D_E_L_E_T_ = ' '),
	A0001 += "            0) NF_ENT,
	If MV_PAR08 == 1
		A0001 += "        ISNULL((SELECT SUM(D2_QUANT)
	Else
		A0001 += "        ISNULL((SELECT SUM(D2_CUSTO1)
	EndIf
	A0001 += "              FROM "+RetSqlName("SD2")+" SD2
	A0001 += "             INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                  AND F4_CODIGO = D2_TES
	A0001 += "                                  AND F4_ESTOQUE = 'S'
	A0001 += "                                  AND SF4.D_E_L_E_T_ = ' '
	A0001 += "             WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	A0001 += "               AND D2_COD = B1_COD
	A0001 += "               AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'
	A0001 += "               AND D2_LOCAL IN ("+xLike+")
	A0001 += "               AND SD2.D_E_L_E_T_ = ' '),
	A0001 += "            0) NF_SAI,
	A0001 += "            0 SALDO,
	A0001 += " 			  ISNULL(( "
	If MV_PAR08 == 1
		A0001 += "        SELECT SUM(B9_QINI)
	Else
		A0001 += "        SELECT SUM(B9_VINI1) 
	EndIf
	A0001 += " 				FROM " + RetSqlName("SB9") + " SB9 "
	A0001 += " 				WHERE B9_FILIAL = " + ValtoSql(xFilial("SB9"))
	A0001 += " 					AND B9_COD = SB1.B1_COD "
	A0001 += " 					AND B9_LOCAL IN ("+xLike+") "
	A0001 += " 					AND B9_DATA = " + ValToSql(dtos(MV_PAR06))
	A0001 += " 					AND SB9.D_E_L_E_T_ = '' "
	A0001 += " 				),0) SAL_FECH "
	
	A0001 += "   FROM "+RetSqlName("SB1")+" SB1
	A0001 += "  WHERE B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "    AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	A0001 += "    AND B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "    AND B1_TIPO BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'
	A0001 += "    AND (SELECT COUNT(*)
	A0001 += "           FROM "+RetSqlName("SB2")
	A0001 += "          WHERE B2_FILIAL = '"+xFilial("SB2")+"'
	A0001 += "            AND B2_COD = B1_COD
	A0001 += "            AND B2_LOCAL IN ("+xLike+")
	A0001 += "            AND D_E_L_E_T_ = ' ') > 0
	A0001 += "    AND ( SB1.B1_MSBLQL <> '1' OR (SELECT COUNT(*)
	A0001 += "                                     FROM "+RetSqlName("SB9")+" SB9
	A0001 += "                                    INNER JOIN "+RetSqlName("SB1")+" XB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                                                         AND B1_COD = SB9.B9_COD
	A0001 += "                                                         AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	A0001 += "                                                         AND B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "                                                         AND B1_TIPO BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'
	A0001 += "                                                         AND XB1.D_E_L_E_T_ = ' '
	A0001 += "                                    WHERE B9_FILIAL = '"+xFilial("SB9")+"'
	A0001 += "                                      AND B9_DATA = (SELECT MAX(B9_DATA)
	A0001 += "                                                       FROM "+RetSqlName("SB9")
	A0001 += "                                                      WHERE B9_FILIAL = '"+xFilial("SB9")+"'
	A0001 += " 													      AND D_E_L_E_T_ = ' ')
	A0001 += " 		                                AND B9_COD = SB1.B1_COD
	A0001 += " 		                                AND B9_QINI <> 0
	A0001 += " 								        AND SB9.D_E_L_E_T_ = ' ') > 0 )
	A0001 += "    AND SB1.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY B1_COD
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Produto: "+Alltrim(A001->PRODUTO)+" ...")
		If Alltrim(A001->GRUPO) == "PA"
			If !( Len(Alltrim(A001->PRODUTO)) == 7 .or. Len(Alltrim(A001->PRODUTO)) == 8 )
				dbSelectArea("A001")
				dbSkip()
				Loop
			EndIf
		EndIf

		gh_SalAnt := 0
		If 1 == 1
			For hhi := 1 to Len(cs_VetLoc)
				aSaldos := CalcEst(A001->PRODUTO, cs_VetLoc[hhi], MV_PAR05)
				If MV_PAR08 == 1
					gh_SalAnt += aSaldos[1]
				Else
					gh_SalAnt += aSaldos[2]
				EndIf
			Next hhi
		Else
			For hhi := 1 to Len(cs_VetLoc)
				aSaldos := CalcEstL(A001->PRODUTO, cs_VetLoc[hhi], MV_PAR05, A001->LOTE, A001->RASTRO, "", NIL)
				If MV_PAR08 == 1
					gh_SalAnt += aSaldos[1]
				Else
					gh_SalAnt += aSaldos[2]
				EndIf
			Next hhi
		EndIf

		ko_SalAtu := gh_SalAnt + A001->MI_ENT - A001->MI_SAI + A001->NF_ENT - A001->NF_SAI
		If gh_SalAnt <> 0 .or. A001->MI_ENT <> 0 .or. A001->MI_SAI <> 0 .or. A001->NF_ENT <> 0 .or. A001->NF_SAI <> 0 .Or. A001->SAL_FECH

			aAdd(aDados2, { "DE "+dtoc(MV_PAR05)+" ATÉ "+dtoc(MV_PAR06),;
			IIF(ValType(A001->PRODUTO) == "C", A001->PRODUTO, A001->PRODUTO),;
			A001->DESCRIC,;
			A001->GRUPO,;
			A001->UM,;
			A001->ATIVO,;
			Transform(gh_SalAnt   ,"@E 999,999,999.99999999"),;
			Transform(A001->MI_ENT,"@E 999,999,999.99999999"),;
			Transform(A001->MI_SAI,"@E 999,999,999.99999999"),;
			Transform(A001->NF_ENT,"@E 999,999,999.99999999"),;
			Transform(A001->NF_SAI,"@E 999,999,999.99999999"),;
			Transform(ko_SalAtu   ,"@E 999,999,999.99999999"),;
			Transform(A001->SAL_FECH,"@E 999,999,999.99999999")})

			aAdd(tlVetEst, { A001->PRODUTO               ,;
			ko_SalAtu                                    })

		EndIf

		dbSelectArea("A001")
		dbSkip()
	End
	aStru1 := ("A001")->(dbStruct())

	A001->(dbCloseArea())

	If xHotOri  <> "1" 

		U_BIAxExcel(aDados2, aStru1, "BIA251"+strzero(seconds()%3500,5) )

	EndIf

	oLogProc:LogFimProc()

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
	aAdd(aRegs,{cPerg,"01","Do Produto          ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"02","Ate Produto         ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","Do Grupo            ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"04","Ate Grupo           ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"05","Da Data             ?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ate Data            ?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Local               ?","","","mv_ch7","C",30,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Tratamento          ?","","","mv_ch8","N",01,0,0,"C","","mv_par08","Quantidade","","","","","Custo","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Do Tipo             ?","","","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Ate Tipo            ?","","","mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
