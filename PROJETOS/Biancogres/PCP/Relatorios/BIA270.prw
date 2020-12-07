#Include "Protheus.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA270
Empresa   := Biancogres Cerâmica S/A
Data      := 31/10/11
Uso       := PCP
Aplicação := Relatório de Produção versus Consumo - InterCompany
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA270()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	cHInicio := Time()
	fPerg := "BIA270"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA270",fPerg)

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "Produção vs Consumo"

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	xj_Empr := Space(02)
	If cEmpAnt == "01"
		xj_Empr := "05"
	ElseIf cEmpAnt == "05"
		xj_Empr := "01"
	EndIf

	aDados2 := {}

	fImpCabec()
	A0001 := " SELECT D3_EMISSAO EMISSAO,
	A0001 += "        D3_TM TM,
	A0001 += "        D3_CF CF,
	A0001 += "        D3_OP OP,
	A0001 += "        ' ' REV,
	A0001 += "        D3_COD COD,
	A0001 += "        SUBSTRING(SB1.B1_DESC,1,70) DESCRIC,
	A0001 += "        SB1.B1_UM UM,
	A0001 += "        SB1.B1_TIPO TIPO,
	A0001 += "        SB1.B1_GRUPO GRUPO,
	A0001 += "        D3_LOCAL LC,
	A0001 += "        D3_QUANT QUANT,
	A0001 += "        SB1.B1_CONV,
	A0001 += "        D3_QUANT QTDCNV,
	A0001 += "        0 PUMID,
	A0001 += "        0 QTD_SECA,
	A0001 += "        '"+cEmpAnt+"' EMPR,
	A0001 += "        D3_DOC DOC,
	A0001 += "        D3_YOBS OBS,
	A0001 += "        ISNULL((SELECT SG1.G1_PERDA FROM SG1010 SG1 WITH(NOLOCK) WHERE SG1.G1_FILIAL = '01' AND SG1.G1_COD = SC2.C2_PRODUTO AND SG1.G1_COMP = SD3.D3_COD AND SD3.D3_EMISSAO BETWEEN SG1.G1_INI AND SG1.G1_FIM AND SG1.D_E_L_E_T_ = ''), 0) PERC_PERDA
	A0001 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	A0001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                       AND SB1.B1_COD = D3_COD
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6)
	A0001 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2)
	A0001 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3)
	A0001 += "                       AND SC2.D_E_L_E_T_ = ' '
	A0001 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 WITH (NOLOCK) ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                       AND XB1.B1_COD = C2_PRODUTO
	A0001 += "                       AND XB1.B1_TIPO BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'
	A0001 += "                       AND XB1.B1_GRUPO BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'
	A0001 += "                       AND XB1.D_E_L_E_T_ = ' '
	A0001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "    AND D3_OP <> '             '
	If !Empty(MV_PAR03) .or. !Empty(MV_PAR04)
		A0001 += "    AND D3_OP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	EndIf
	A0001 += "    AND D3_ESTORNO = ' '
	A0001 += "    AND SD3.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY D3_EMISSAO, D3_OP, D3_DOC, D3_TM
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Imprimindo....    Tempo: "+cTempo)

		fr_Emiss := A001->EMISSAO
		fr_NumOp := A001->OP
		fr_GrpPr := A001->GRUPO
		fr_QtdPr := 0
		fr_QtdRq := 0
		fr_QdUmd := 0
		While !Eof() .and. A001->EMISSAO ==  fr_Emiss .and. A001->OP == fr_NumOp

			cTempo := Alltrim(ElapTime(cHInicio, Time()))
			IncProc("Imprimindo... Tempo: " + cTempo + "  OP:" + A001->OP)

			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf

			hj_QtdMv := A001->QUANT

			hj_B1Conv := A001->B1_CONV
			hj_QtdMv  := A001->QUANT
			If Substr(A001->COD,1,3) <> '102'
				If A001->UM <> "T "
					hj_QtdMv := ConvUM(A001->COD, A001->QUANT, 0, 2)
				EndIf
			Else
				hj_B1Conv := 1
			EndIf

			dbSelectArea("SC2")
			dbSetOrder(1)
			dbSeek(xFilial("SC2")+A001->OP)
			xk_Rev := SC2->C2_REVISAO

			dbSelectArea("SD4")
			dbSetOrder(1)
			dbSeek(xFilial("SD4")+A001->OP+A001->COD)

			nPPerda:= 0
			nQPerda := hj_QtdMv
			
			nPPerda := A001->PERC_PERDA
			
			nQPerda := nQPerda * nPPerda / 100

			xf_Item := +;
			Padr(dtoc(stod(A001->EMISSAO))                        ,08)+" "+;
			Padr(A001->TM                                         ,03)+" "+;
			Padr(A001->CF                                         ,03)+" "+;
			Padr(A001->OP                                         ,13)+" "+;
			Padr(xk_Rev                                           ,03)+" "+;
			Padr(A001->COD                                        ,15)+" "+;
			Padr(A001->DESCRIC                                    ,50)+" "+;
			Padr(A001->UM                                         ,02)+" "+;
			Padr(A001->TIPO                                       ,02)+" "+;
			Padc(A001->LC                                         ,02)+" "+;
			Padl(Transform(A001->QUANT,"@E 999,999,999.99")       ,14)+" "+;
			Padl(Transform(hj_B1Conv,"@E 9999.99")                ,07)+" "+;
			Padl(Transform(hj_QtdMv,"@E 999,999,999.99")          ,14)+"    "+;
			Padc(A001->EMPR                                       ,02)+" "+;
			Padc(A001->DOC                                        ,09)+" "+;
			Padr(A001->OBS                                        ,15)+" "+;
			Padr(Transform(nQPerda,"@E 999,999,999.99")          ,14)
			oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont8)
			nRow1 += 050

			aAdd(aDados2, {dtoc(stod(A001->EMISSAO)),;
			A001->TM,;
			A001->CF,;
			A001->OP,;
			xk_Rev,;
			A001->COD,;
			A001->DESCRIC,;
			A001->UM,;
			A001->TIPO,;
			A001->GRUPO,;
			A001->LC,;
			Transform(A001->QUANT,"@E 999,999,999.99"),;
			Transform(hj_B1Conv,"@E 9999.99"),;
			Transform(hj_QtdMv,"@E 999,999,999.99"),;
			0,;
			0,;
			A001->EMPR,;
			A001->DOC,;
			A001->OBS,;
			Transform(nQPerda,"@E 999,999,999.99")} )

			If A001->TM <= "500"
				fr_QtdPr += hj_QtdMv
			Else
				fr_QtdRq += hj_QtdMv
			EndIf

			If "Umid:" $ Alltrim(A001->OBS) 
				fr_QdUmd += hj_QtdMv
			EndIf

			dbSelectArea("A001")
			dbSkip()
		End
		oPrint:Say  (nRow1 ,0050 ,"Total de PRODUÇÃO da Ordem de Produção:   " + Transform(fr_QtdPr,"@E 999,999,999.99")      ,oFont8)

		If Alltrim(fr_GrpPr) == "PI01"

			ET003 := " SELECT SUM(G1_YMISTUR) MIST
			ET003 += "   FROM " + RetSqlName("SG1") + " WITH (NOLOCK)
			ET003 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "'
			ET003 += "    AND G1_COD = '"+SC2->C2_PRODUTO+"'
			ET003 += "    AND G1_TRT = '"+xk_Rev+"'
			ET003 += "    AND D_E_L_E_T_ = ' '
			ElIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,ET003),'ET03',.T.,.T.)
			dbSelectArea("ET03")
			dbGoTop()
			weQtdMist := ET03->MIST
			ET03->(dbCloseArea())
			Ferase(ElIndex+GetDBExtension())
			Ferase(ElIndex+OrdBagExt())
			oPrint:Say  (nRow1 ,1500 ,"Retorno =====>> " + Alltrim(Transform(100-weQtdMist,"@E 999,999,999.99"))+"%"      ,oFont8)

		EndIf

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		nRow1 += 050
		oPrint:Say  (nRow1 ,0050 ,"Total de REQUISIÇÃO da Ordem de Produção: " + Transform(fr_QtdRq-fr_QdUmd,"@E 999,999,999.99")      ,oFont8)
		oPrint:Say  (nRow1 ,1500 ,"Qtd Umida =====>> " + Alltrim(Transform(fr_QdUmd,"@E 999,999,999.99"))                              ,oFont8)
		oPrint:Say  (nRow1 ,2000 ,"Total requisitado =====>> " + Alltrim(Transform(fr_QtdRq,"@E 999,999,999.99"))                      ,oFont8)

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		nRow1 += 050
		oPrint:Line (nRow1+35, 050, nRow1+35, 3350)
		nRow1 += 100

		dbSelectArea("A001")

	End

	aStru1 := ("A001")->(dbStruct())
	fImpRoda()
	A001->(dbCloseArea())

	If MV_PAR05 == 1

		U_BIAxExcel(aDados2, aStru1, "BIA270"+strzero(seconds()%3500,5) )

	Else

		oPrint:EndPage()
		oPrint:Preview()

	EndIf

	oLogProc:LogFimProc()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025
	sw_Perid := "Periodo: "+ dtoc(MV_PAR01) +" até " + dtoc(MV_PAR02)
	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
	oPrint:Say  (nRow1+75 ,0050 ,Padc(sw_Perid,110)                                         ,oFont14)
	oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

	nRow1 += 175
	oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

	xf_CbOp := +;
	Padr("Emissão"                                  ,08)+" "+;
	Padr("TM"                                       ,03)+" "+;
	Padr("CF"                                       ,03)+" "+;
	Padr("NumOp"                                    ,13)+" "+;
	Padr("Rev"                                      ,03)+" "+;
	Padr("Produto"                                  ,15)+" "+;
	Padr("Descrição"                                ,50)+" "+;
	Padr("UM"                                       ,02)+" "+;
	Padr("Tp"                                       ,02)+" "+;
	Padc("Lc"                                       ,02)+" "+;
	Padl("Qtd_Ori"                                  ,14)+" "+;
	Padl("Conv"                                     ,07)+" "+;
	Padl("Qtd_Ton"                                  ,14)+"    "+;
	Padc("Ep"                                       ,02)+" "+;
	Padc("Documento"                                ,09)+" "+;
	Padr("Obs"                                      ,15)+" "+;
	Padr("Perda"                                    ,14)
	oPrint:Say  (nRow1 ,0050 ,xf_CbOp                               ,oFont8)
	oPrint:Line (nRow1+35, 050, nRow1+35, 3350)
	nRow1 += 065

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 050, 2300, 3350)
	oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
	oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

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
	aRegs := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Op               ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SC2"})
	aAdd(aRegs,{cPerg,"04","Ate Op              ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SC2"})
	aAdd(aRegs,{cPerg,"05","Gerar Excel         ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","De Tipo             ?","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"07","Ate Tipo            ?","","","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"08","De Grupo            ?","","","mv_ch8","C",04,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"09","Ate Grupo           ?","","","mv_ch9","C",04,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
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
