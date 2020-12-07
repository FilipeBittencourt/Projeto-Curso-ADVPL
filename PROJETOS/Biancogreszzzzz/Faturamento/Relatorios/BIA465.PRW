#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "vkey.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA465   ºAutor  ³ Wanisay William    º Data ³  26/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Curva ABC Produto                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA465()

	local i 

	Private _cTab := GetNextAlias()
	Private _cTab2 := GetNextAlias()
	Private _cTab3 := GetNextAlias()

	cHInicio := Time()
	fPerg := "BIA465"
	//ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo de trabalho                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Realizar Ranking do periodo anterior por formato e linha
	_aCampos := { {"LINHA","C",04, 0},;
	{"SEQ     ","C",02, 0},;
	{"FORMATO ","C",02, 0},;
	{"DATAPCOM","C",10, 0},;
	{"RANK    ","N",03, 0} }

	_cArq := CriaTrab(_aCampos,.T.)

	If Select(_cTab) > 0
		(_cTab)->(DbCloseArea())
	EndIf

	DbUseArea(.T.,,_cArq, _cTab)
	DbCreateInd(_cArq, "LINHA+SEQ+FORMATO",{||LINHA+SEQ+FORMATO})

	//Totaliza vendas por formato
	_aCampos := { {"FORMATO","C",02, 0},;
	{"DESC    ","C",15, 0},;
	{"QUANT   ","N",12, 2},;
	{"RET     ","C",01, 0} }

	_cArq2 := CriaTrab(_aCampos,.T.)

	If Select(_cTab2) > 0
		(_cTab2)->(DbCloseArea())
	EndIf

	DbUseArea(.T.,,_cArq2, _cTab2)
	DbCreateInd(_cArq2, "FORMATO",{||FORMATO})

	//Totaliza vendas por fornecedor
	_aCampos := { {"FORNECE","C",03, 0},;
	{"QUANT   ","N",12, 2} }

	_cArq3 := CriaTrab(_aCampos,.T.)

	If Select(_cTab3) > 0
		(_cTab3)->(DbCloseArea())
	EndIf

	DbUseArea(.T.,,_cArq3, _cTab3)
	DbCreateInd(_cArq3, "FORNECE",{||FORNECE})

	Processa({|| RptDet_1()})

	(_cTab)->(DbCloseArea())
	aEval(Directory(_cArq+".*"),{ |aFile| FErase(aFile[1])})

	(_cTab2)->(DbCloseArea())
	aEval(Directory(_cArq2+".*"),{ |aFile| FErase(aFile[1])})

	(_cTab3)->(DbCloseArea())
	aEval(Directory(_cArq3+".*"),{ |aFile| FErase(aFile[1])})

Return


Static Function RptDet_1()
	LOCAL nPosCnt	:= 0
	local i 
	IF cEmpAnt == '01'
		aBitmap  := "LOGOPRI01.BMP"
	ELSE
		aBitmap  := "LOGOPRI05.BMP"
	ENDIF


	cMesIni  := U_DATAR(MV_PAR01,4)
	cMesFim  := U_DATAR(MV_PAR02,4)
	cAno     := SUBSTR(DTOS(MV_PAR01),1,4)
	dDataIni := SUBSTR(DTOS(MV_PAR01),1,4)+"0101"

	nMedia := ROUND((MV_PAR02-MV_PAR01)/30,0)

	aAno   := {VAL(SUBSTR(DTOS(MV_PAR01),1,4)) - 2, VAL(SUBSTR(DTOS(MV_PAR01),1,4)) - 1, VAL(SUBSTR(DTOS(MV_PAR01),1,4))}
	aMes   := {1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12}
	aDia   := {31,28,31,30,31,30,31,31,30,31,30,31,31,28,31,30,31,30,31,31,30,31,30,31,31,28,31,30,31,30,31,31,30,31,30,31}

	nMesI  := aMES[MONTH(MV_PAR01) + 24 - nMedia]
	nMesF  := aMES[MONTH(MV_PAR02) + 24 - nMedia]
	nDia   := aDia[MONTH(MV_PAR02) + 24 - nMedia]

	DO CASE
		CASE (MONTH(MV_PAR01) + 24 - nMedia) <= 12
		nAnoI := aAno[1]
		CASE (MONTH(MV_PAR01) + 24 - nMedia) >= 25
		nAnoI := aAno[3]
		OTHERWISE
		nAnoI := aAno[2]
	ENDCASE

	DO CASE
		CASE (MONTH(MV_PAR02) + 24 - nMedia) <= 12
		nAnoF := aAno[1]
		CASE (MONTH(MV_PAR02) + 24 - nMedia) >= 25
		nAnoF := aAno[3]
		OTHERWISE
		nAnoF := aAno[2]
	ENDCASE

	sDataI := STRZERO(nAnoI,4)+STRZERO(nMesI,2)+"01"
	sDataF := STRZERO(nAnoF,4)+STRZERO(nMesF,2)+STRZERO(nDia,2)

	fCabec   := "Curva ABC Produto. Média de "+cMesIni+" a "+cMesFim

	// Tiago Rossini Coradini - OS: 0925-13 - Mateus Fadini
	If cEmpAnt == '05'

		fCabec2 := "Marca: "

		If MV_PAR19 == 1
			fCabec2 += "Todas"
		ElseIf MV_PAR19 == 2
			fCabec2 += "Incesa"
		ElseIf MV_PAR19 == 3
			fCabec2 += "Bellacasa"
		EndIf

	Else
		fCabec2 := " "
	EndIf

	wnPag    := 0
	nRow1    := 0

	CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)

	cFor01  := "RET."
	cFor02  := ""
	cFor03  := ""
	cFor04  := ""
	cFor05  := ""
	cFor06  := ""
	cFor07  := ""
	cFor08  := ""
	cFor09  := "ANT."
	cFor10  := "ATUAL"

	cCodF02  := ""
	cCodF03  := ""
	cCodF04  := ""
	cCodF05  := ""
	cCodF06  := ""
	cCodF07  := ""
	cCodF08  := ""

	For i = 1 TO LEN(MV_PAR16)
		cFormato := SUBSTR(MV_PAR16,i,2)
		i := i + 2
		IF !EMPTY(ALLTRIM(cFormato))
			DbSelectArea("ZZ6")
			DbSetOrder(1)
			DbSeek(xFilial("ZZ6")+ALLTRIM(cFormato))
			IF ZZ6->ZZ6_TPPROD <> 'RE'
				DO CASE
					CASE EMPTY(cFor02)
					cFor02  := SUBSTR(ZZ6->ZZ6_DESC,1,5)
					cCodF02 := ZZ6->ZZ6_COD
					CASE EMPTY(cFor03)
					cFor03 := SUBSTR(ZZ6->ZZ6_DESC,1,5)
					cCodF03 := ZZ6->ZZ6_COD
					CASE EMPTY(cFor04)
					cFor04 := SUBSTR(ZZ6->ZZ6_DESC,1,5)
					cCodF04 := ZZ6->ZZ6_COD
					CASE EMPTY(cFor05)
					cFor05 := SUBSTR(ZZ6->ZZ6_DESC,1,5)
					cCodF05 := ZZ6->ZZ6_COD
					CASE EMPTY(cFor06)
					cFor06 := SUBSTR(ZZ6->ZZ6_DESC,1,5)
					cCodF06 := ZZ6->ZZ6_COD
					CASE EMPTY(cFor07)
					cFor07 := SUBSTR(ZZ6->ZZ6_DESC,1,5)
					cCodF07 := ZZ6->ZZ6_COD
					CASE EMPTY(cFor08)
					cFor08 := SUBSTR(ZZ6->ZZ6_DESC,1,5)
					cCodF08 := ZZ6->ZZ6_COD
				ENDCASE
			ENDIF
		ENDIF
	Next

	nRank01  := 0
	nRank02  := 0
	nRank03  := 0
	nRank04  := 0
	nRank05  := 0
	nRank06  := 0
	nRank07  := 0
	nRank08  := 0
	nRank09  := 0
	nRank10  := 0

	nRankA01 := 0
	nRankA02 := 0
	nRankA03 := 0
	nRankA04 := 0
	nRankA05 := 0
	nRankA06 := 0
	nRankA07 := 0
	nRankA08 := 0

	fImpCabec()

	//Busca a quantidade total faturada no periodo para calculo dos percentuais
	A0001 := " SELECT D2_YEMP , SUM(D2_QUANT) AS D2_QUANT, SUM(D2_TOTAL) AS D2_TOTAL "
	A0001 += " FROM VW_SF2 SF2, VW_SD2 SD2, SB1010 SB1, "+RetSqlName("SA1")+" SA1, ZZ7010 ZZ7, ZZ6010 ZZ6, ZZN010 ZZN "
	A0001 += " WHERE SF2.F2_FILIAL           = '"+xFilial("SF2")+"' AND "
	A0001 += "             SD2.D2_FILIAL     = '"+xFilial("SD2")+"' AND "
	A0001 += "             SB1.B1_FILIAL     = '"+xFilial("SB1")+"' AND "
	A0001 += "             SA1.A1_FILIAL     = '"+xFilial("SA1")+"' AND "
	A0001 += "             ZZ7.ZZ7_FILIAL    = '"+xFilial("ZZ7")+"' AND "
	A0001 += "             ZZN.ZZN_FILIAL    = '"+xFilial("ZZN")+"' AND "
	A0001 += "             SF2.F2_DOC        = SD2.D2_DOC           AND "
	A0001 += "             SF2.F2_SERIE      = SD2.D2_SERIE         AND "
	A0001 += "             SF2.F2_CLIENTE    = SD2.D2_CLIENTE       AND "
	A0001 += "             SF2.F2_LOJA       = SD2.D2_LOJA          AND "
	A0001 += "	           SF2.F2_YEMP		 = SD2.D2_YEMP		    AND " //RANISSES
	A0001 += "	           SF2.F2_YEMPORI	 = SD2.D2_YEMPORI	    AND " //RANISSES
	A0001 += "             SD2.F4_DUPLIC     = 'S'                  AND "
	A0001 += "             SD2.D2_GRUPO      = 'PA'                 AND "
	A0001 += "             SD2.D2_COD        = B1_COD               AND "
	A0001 += "             SF2.F2_CLIENTE    = A1_COD               AND "
	A0001 += "             SF2.F2_LOJA       = A1_LOJA              AND "
	A0001 += "             ZZ7.ZZ7_COD       = B1_YLINHA            AND "
	A0001 += "             ZZ7.ZZ7_LINSEQ    = B1_YLINSEQ           AND "
	A0001 += "             ZZ6.ZZ6_COD       = B1_YFORMAT           AND "
	A0001 += "             ZZ7.ZZ7_COD       = ZZN.ZZN_LINHA        AND "
	A0001 += "             ZZ6.ZZ6_COD       = ZZN.ZZN_FORMAT       AND "
	A0001 += "             SB1.B1_COD        >= 'A'                       AND "
	A0001 += "             SF2.F2_EMISSAO    BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
	A0001 += "             SF2.F2_VEND1      BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
	A0001 += "             SF2.F2_CLIENTE    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
	A0001 += "             SB1.B1_YFORMAT    BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "
	A0001 += "             SB1.B1_YCLASSE    BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' AND "
	DO CASE
		CASE cEmpAnt == '01'
		A0001 += " SD2.D2_YEMP IN ('0101') AND "
		CASE cEmpAnt == '05'

		// Tiago Rossini Coradini - OS: 0925-13 - Mateus Fadini		
		If MV_PAR19 == 1
			A0001 += " SD2.D2_YEMP IN ('0501','0599') AND "
		ElseIf MV_PAR19 == 2
			A0001 += " SD2.D2_YEMP IN ('0501') AND "
		ElseIf MV_PAR19 == 3
			A0001 += " SD2.D2_YEMP IN ('0599') AND "
		EndIf

	ENDCASE
	A0001 += "		       SF2.F2_YEMPORI	 = SD2.D2_YEMPORI	    AND  " //RANISSES
	A0001 += "             SA1.A1_GRPVEN     BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
	A0001 += "             SA1.A1_YTPSEG     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
	A0001 += "             SB1.B1_UM         = 'M2' AND  "

	DO CASE
		CASE MV_PAR17 == 1
		A0001 += "       (ZZN.ZZN_ATIVO <> 'S' OR ZZ6.ZZ6_TPPROD  = 'RE') AND "
		CASE MV_PAR17 == 2
		A0001 += "       (ZZN.ZZN_ATIVO =  'S' AND ZZ6.ZZ6_TPPROD  <> 'RE') AND "
	ENDCASE

	IF MV_PAR18 == 2
		A0001 += "       ZZ6.ZZ6_TPPROD  <> 'RE' AND "
	ENDIF

	A0001 += "             SB1.D_E_L_E_T_    = ''   AND  "
	A0001 += "             ZZ6.D_E_L_E_T_    = ''   AND  "
	A0001 += "             ZZ7.D_E_L_E_T_    = ''   AND  "
	A0001 += "             ZZN.D_E_L_E_T_    = ''   AND  "
	A0001 += "             SA1.D_E_L_E_T_    = '' "
	A0001 += " GROUP BY D2_YEMP "
	If chkfile("A001")
		dbSelectArea("A001")
		dbCloseArea()
	EndIf
	TcQuery A0001 New Alias "A001"

	nTotQtd := 0
	DbSelectArea("A001")
	DbGoTop()
	While !EOF()                   

		nTotQtd := nTotQtd + A001->D2_QUANT

		DbSelectArea("A001")
		DbSkip()
		Loop
	END               

	nTotQtd := nTotQtd/nMedia

	//Busca a data do primeiro faturamento da linha e formato
	A0002 := " SELECT      D2_YEMP , B1_YLINHA, B1_YLINSEQ, B1_YFORMAT, ZZ7_DESC,  ZZ6_DESC, MIN(F2_EMISSAO) AS F2_EMISSAO "
	A0002 += " FROM VW_SF2 SF2, VW_SD2 SD2, SB1010 SB1, "+RetSqlName("SA1")+" SA1, ZZ7010 ZZ7, ZZ6010 ZZ6, ZZN010 ZZN "
	A0002 += " WHERE SF2.F2_FILIAL           = '"+xFilial("SF2")+"' AND "
	A0002 += "             SD2.D2_FILIAL     = '"+xFilial("SD2")+"' AND "
	A0002 += "             SB1.B1_FILIAL     = '"+xFilial("SB1")+"' AND "
	A0002 += "             SA1.A1_FILIAL     = '"+xFilial("SA1")+"' AND "
	A0002 += "             ZZ7.ZZ7_FILIAL    = '"+xFilial("ZZ7")+"' AND "
	A0002 += "             ZZ6.ZZ6_FILIAL    = '"+xFilial("ZZ6")+"' AND "
	A0002 += "             ZZN.ZZN_FILIAL    = '"+xFilial("ZZN")+"' AND "
	A0002 += "             SF2.F2_DOC        = SD2.D2_DOC           AND "
	A0002 += "             SF2.F2_SERIE      = SD2.D2_SERIE         AND "
	A0002 += "             SF2.F2_CLIENTE    = SD2.D2_CLIENTE       AND "
	A0002 += "             SF2.F2_LOJA       = SD2.D2_LOJA          AND "
	A0002 += "			   SF2.F2_YEMP		 = SD2.D2_YEMP		    AND " //RANISSES
	A0002 += "			   SF2.F2_YEMPORI	 = SD2.D2_YEMPORI	    AND " //RANISSES
	A0002 += "             SD2.F4_DUPLIC     = 'S'                  AND "
	A0002 += "             SD2.D2_GRUPO      = 'PA'                 AND "
	A0002 += "             SD2.D2_COD        = B1_COD               AND "
	A0002 += "             SF2.F2_CLIENTE    = A1_COD               AND "
	A0002 += "             SF2.F2_LOJA       = A1_LOJA              AND "
	A0002 += "             ZZ7.ZZ7_COD       = B1_YLINHA            AND "
	A0002 += "             ZZ7.ZZ7_LINSEQ    = B1_YLINSEQ           AND "
	A0002 += "             ZZ6.ZZ6_COD       = B1_YFORMAT           AND "
	A0002 += "             ZZ7.ZZ7_COD       = ZZN.ZZN_LINHA        AND "
	A0002 += "             ZZ6.ZZ6_COD       = ZZN.ZZN_FORMAT       AND "
	A0002 += "             SB1.B1_COD        >= 'A'                       AND "
	A0002 += "             SF2.F2_EMISSAO    BETWEEN ' ' AND '"+dtos(MV_PAR02)+"' AND "
	A0002 += "             SF2.F2_VEND1      BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
	A0002 += "             SF2.F2_CLIENTE    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
	A0002 += "             SB1.B1_YFORMAT    BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "
	A0002 += "             SB1.B1_YCLASSE    BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' AND "
	DO CASE
		CASE cEmpAnt == '01'
		A0002 += " SD2.D2_YEMP IN ('0101') AND "
		CASE cEmpAnt == '05'

		// Tiago Rossini Coradini - OS: 0925-13 - Mateus Fadini
		If MV_PAR19 == 1
			A0002 += " SD2.D2_YEMP IN ('0501','0599') AND "
		ElseIf MV_PAR19 == 2
			A0002 += " SD2.D2_YEMP IN ('0501') AND "
		ElseIf MV_PAR19 == 3
			A0002 += " SD2.D2_YEMP IN ('0599') AND "
		EndIf

	ENDCASE
	A0002 += "		       SF2.F2_YEMPORI	 = SD2.D2_YEMPORI	    AND " //RANISSES
	A0002 += "             SA1.A1_GRPVEN     BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
	A0002 += "             SA1.A1_YTPSEG     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
	A0002 += "             SB1.B1_UM         = 'M2' AND  "

	DO CASE
		CASE MV_PAR17 == 1
		A0002 += "       (ZZN.ZZN_ATIVO <> 'S' OR ZZ6.ZZ6_TPPROD  = 'RE') AND "
		CASE MV_PAR17 == 2
		A0002 += "       (ZZN.ZZN_ATIVO =  'S' AND ZZ6.ZZ6_TPPROD  <> 'RE') AND "
	ENDCASE

	IF MV_PAR18 == 2
		A0002 += "       ZZ6.ZZ6_TPPROD  <> 'RE' AND "
	ENDIF

	A0002 += "             SB1.D_E_L_E_T_    = ''   AND  "
	A0002 += "             ZZ7.D_E_L_E_T_    = ''   AND  "
	A0002 += "             ZZ6.D_E_L_E_T_    = ''   AND  "
	A0002 += "             ZZN.D_E_L_E_T_    = ''   AND  "
	A0002 += "             SA1.D_E_L_E_T_    = '' "
	A0002 += " GROUP BY D2_YEMP, B1_YLINHA, B1_YLINSEQ, B1_YFORMAT, ZZ7_DESC, ZZ6_DESC "
	If chkfile("A002")
		dbSelectArea("A002")
		dbCloseArea()
	EndIf
	TcQuery A0002 New Alias "A002"
	DbSelectArea("A002")

	//Realiza o ranking das linhas e formatos do trimestre anterior
	A0003 := " SELECT      D2_YEMP , B1_YLINHA, B1_YLINSEQ, B1_YFORMAT, ZZ7_DESC,  ZZ6_DESC, "
	A0003 += "             SUM(D2_QUANT) AS D2_QUANT, SUM(D2_TOTAL) AS D2_TOTAL "
	A0003 += " FROM VW_SF2 SF2, VW_SD2 SD2, SB1010 SB1, "+RetSqlName("SA1")+" SA1, ZZ7010 ZZ7, ZZ6010 ZZ6, ZZN010 ZZN "
	A0003 += " WHERE SF2.F2_FILIAL           = '"+xFilial("SF2")+"' AND "
	A0003 += "             SD2.D2_FILIAL     = '"+xFilial("SD2")+"' AND "
	A0003 += "             SB1.B1_FILIAL     = '"+xFilial("SB1")+"' AND "
	A0003 += "             SA1.A1_FILIAL     = '"+xFilial("SA1")+"' AND "
	A0003 += "             ZZ7.ZZ7_FILIAL    = '"+xFilial("ZZ7")+"' AND "
	A0003 += "             ZZ6.ZZ6_FILIAL    = '"+xFilial("ZZ6")+"' AND "
	A0003 += "             ZZN.ZZN_FILIAL    = '"+xFilial("ZZN")+"' AND "
	A0003 += "             SF2.F2_DOC        = SD2.D2_DOC           AND "
	A0003 += "             SF2.F2_SERIE      = SD2.D2_SERIE         AND "
	A0003 += "             SF2.F2_CLIENTE    = SD2.D2_CLIENTE       AND "
	A0003 += "             SF2.F2_LOJA       = SD2.D2_LOJA          AND "
	A0003 += "			   SF2.F2_YEMP		 = SD2.D2_YEMP		    AND " //RANISSES
	A0003 += "			   SF2.F2_YEMPORI	 = SD2.D2_YEMPORI	    AND " //RANISSES
	A0003 += "             SD2.F4_DUPLIC     = 'S'                  AND "
	A0003 += "             SD2.D2_GRUPO      = 'PA'                 AND "
	A0003 += "             SD2.D2_COD        = B1_COD               AND "
	A0003 += "             SF2.F2_CLIENTE    = A1_COD               AND "
	A0003 += "             SF2.F2_LOJA       = A1_LOJA              AND "
	A0003 += "             ZZ7.ZZ7_COD       = B1_YLINHA            AND "
	A0003 += "             ZZ7.ZZ7_LINSEQ    = B1_YLINSEQ           AND "
	A0003 += "             ZZ6.ZZ6_COD       = B1_YFORMAT           AND "
	A0003 += "             ZZ7.ZZ7_COD       = ZZN.ZZN_LINHA        AND "
	A0003 += "             ZZ6.ZZ6_COD       = ZZN.ZZN_FORMAT       AND "
	A0003 += "             SB1.B1_COD        >= 'A'                       AND "
	A0003 += "             SF2.F2_EMISSAO    BETWEEN '"+sDataI+"' AND '"+sDataF+"' AND "
	A0003 += "             SF2.F2_VEND1      BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
	A0003 += "             SF2.F2_CLIENTE    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
	A0003 += "             SB1.B1_YFORMAT    BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "
	A0003 += "             SB1.B1_YCLASSE    BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' AND "
	DO CASE
		CASE cEmpAnt == '01'
		A0003 += " SD2.D2_YEMP IN ('0101') AND "
		CASE cEmpAnt == '05'

		// Tiago Rossini Coradini - OS: 0925-13 - Mateus Fadini
		If MV_PAR19 == 1
			A0003 += " SD2.D2_YEMP IN ('0501','0599') AND "
		ElseIf MV_PAR19 == 2
			A0003 += " SD2.D2_YEMP IN ('0501') AND "
		ElseIf MV_PAR19 == 3
			A0003 += " SD2.D2_YEMP IN ('0599') AND "
		EndIf

	ENDCASE
	A0003 += "		       SF2.F2_YEMPORI   = SD2.D2_YEMPORI		AND " //RANISSES
	A0003 += "             SA1.A1_GRPVEN     BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
	A0003 += "             SA1.A1_YTPSEG     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
	A0003 += "             SB1.B1_UM         = 'M2' AND  "

	DO CASE
		CASE MV_PAR17 == 1
		A0003 += "       (ZZN.ZZN_ATIVO <> 'S' OR ZZ6.ZZ6_TPPROD  = 'RE') AND "
		CASE MV_PAR17 == 2
		A0003 += "       (ZZN.ZZN_ATIVO =  'S' AND ZZ6.ZZ6_TPPROD  <> 'RE') AND "
	ENDCASE

	IF MV_PAR18 == 2
		A0003 += "       ZZ6.ZZ6_TPPROD  <> 'RE' AND "
	ENDIF

	A0003 += "             SB1.D_E_L_E_T_    = ''   AND  "
	A0003 += "             ZZ7.D_E_L_E_T_    = ''   AND  "
	A0003 += "             ZZ6.D_E_L_E_T_    = ''   AND  "
	A0003 += "             ZZN.D_E_L_E_T_    = ''   AND  "
	A0003 += "             SA1.D_E_L_E_T_    = '' "
	A0003 += " GROUP BY D2_YEMP, B1_YLINHA, B1_YLINSEQ, B1_YFORMAT, ZZ7_DESC, ZZ6_DESC "
	A0003 += " ORDER BY D2_QUANT DESC "
	If chkfile("A003")
		dbSelectArea("A003")
		dbCloseArea()
	EndIf
	TcQuery A0003 New Alias "A003"

	DbSelectArea("A003")
	DbGoTop()
	nCont := 0
	While !EOF()
		nCont := nCont + 1
		DbSelectArea(_cTab)
		RecLock(_cTab, .T.)
		(_cTab)->LINHA   := A003->B1_YLINHA
		(_cTab)->SEQ     := A003->B1_YLINSEQ
		(_cTab)->FORMATO := A003->B1_YFORMAT
		(_cTab)->RANK    := nCont
		MsUnLock()
		DbSelectArea("A003")
		DbSkip()
	END

	DbSelectArea("A002")
	DbGoTop()
	While !EOF()
		DbSelectArea(_cTab)
		IF DbSeek(A002->B1_YLINHA+A002->B1_YLINSEQ+A002->B1_YFORMAT)
			RecLock(_cTab,.F.)
			(_cTab)->DATAPCOM := A002->F2_EMISSAO
			MsUnLock()
		ELSE
			RecLock(_cTab,.T.)
			(_cTab)->LINHA    := A002->B1_YLINHA
			(_cTab)->SEQ      := A002->B1_YLINSEQ
			(_cTab)->FORMATO  := A002->B1_YFORMAT
			(_cTab)->DATAPCOM := A002->F2_EMISSAO
			(_cTab)->RANK     := 0
			MsUnLock()
		ENDIF
		DbSelectArea("A002")
		DbSkip()
	END

	//Realizar o ranking das linhas e formatos do ultimo trimestre
	A0000 := " SELECT      D2_YEMP , B1_YLINHA, B1_YLINSEQ, B1_YFORMAT, ZZ7_DESC,  ZZ6_DESC, "
	A0000 += "             SUM(D2_QUANT) AS D2_QUANT, SUM(D2_TOTAL) AS D2_TOTAL "
	A0000 += " FROM VW_SF2 SF2, VW_SD2 SD2, SB1010 SB1, "+RetSqlName("SA1")+" SA1, ZZ7010 ZZ7, ZZ6010 ZZ6, ZZN010 ZZN "
	A0000 += " WHERE SF2.F2_FILIAL           = '"+xFilial("SF2")+"' AND "
	A0000 += "             SD2.D2_FILIAL     = '"+xFilial("SD2")+"' AND "
	A0000 += "             SB1.B1_FILIAL     = '"+xFilial("SB1")+"' AND "
	A0000 += "             SA1.A1_FILIAL     = '"+xFilial("SA1")+"' AND "
	A0000 += "             ZZ7.ZZ7_FILIAL    = '"+xFilial("ZZ7")+"' AND "
	A0000 += "             ZZ6.ZZ6_FILIAL    = '"+xFilial("ZZ6")+"' AND "
	A0000 += "             ZZN.ZZN_FILIAL    = '"+xFilial("ZZN")+"' AND "
	A0000 += "             SF2.F2_DOC        = SD2.D2_DOC           AND "
	A0000 += "             SF2.F2_SERIE      = SD2.D2_SERIE         AND "
	A0000 += "             SF2.F2_CLIENTE    = SD2.D2_CLIENTE       AND "
	A0000 += "             SF2.F2_LOJA       = SD2.D2_LOJA          AND "
	A0000 += "		       SF2.F2_YEMP		 = SD2.D2_YEMP		    AND " //RANISSES
	A0000 += "		       SF2.F2_YEMPORI	 = SD2.D2_YEMPORI	    AND " //RANISSES
	A0000 += "             SD2.F4_DUPLIC     = 'S'                  AND "
	A0000 += "             SD2.D2_GRUPO      = 'PA'                 AND "
	A0000 += "             SD2.D2_COD        = B1_COD               AND "
	A0000 += "             SF2.F2_CLIENTE    = A1_COD               AND "
	A0000 += "             SF2.F2_LOJA       = A1_LOJA              AND "
	A0000 += "             ZZ7.ZZ7_COD       = B1_YLINHA            AND "
	A0000 += "             ZZ7.ZZ7_LINSEQ    = B1_YLINSEQ           AND "
	A0000 += "             ZZ6.ZZ6_COD       = B1_YFORMAT           AND "
	A0000 += "             ZZ7.ZZ7_COD       = ZZN.ZZN_LINHA        AND "
	A0000 += "             ZZ6.ZZ6_COD       = ZZN.ZZN_FORMAT       AND "
	A0000 += "             SB1.B1_COD        >= 'A'                       AND "
	A0000 += "             SF2.F2_EMISSAO    BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
	A0000 += "             SF2.F2_VEND1      BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
	A0000 += "             SF2.F2_CLIENTE    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
	A0000 += "             SB1.B1_YFORMAT    BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "
	A0000 += "             SB1.B1_YCLASSE    BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' AND "
	DO CASE
		CASE cEmpAnt == '01'
		A0000 += " SD2.D2_YEMP IN ('0101') AND "
		CASE cEmpAnt == '05'

		// Tiago Rossini Coradini - OS: 0925-13 - Mateus Fadini
		If MV_PAR19 == 1
			A0000 += " SD2.D2_YEMP IN ('0501','0599') AND "
		ElseIf MV_PAR19 == 2
			A0000 += " SD2.D2_YEMP IN ('0501') AND "
		ElseIf MV_PAR19 == 3
			A0000 += " SD2.D2_YEMP IN ('0599') AND "
		EndIf

	ENDCASE
	A0000 += "             SA1.A1_GRPVEN     BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
	A0000 += "             SA1.A1_YTPSEG     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
	A0000 += "             SB1.B1_UM         = 'M2' AND  "

	DO CASE
		CASE MV_PAR17 == 1
		A0000 += "       (ZZN.ZZN_ATIVO <> 'S' OR ZZ6.ZZ6_TPPROD  = 'RE') AND "
		CASE MV_PAR17 == 2
		A0000 += "       (ZZN.ZZN_ATIVO =  'S' AND ZZ6.ZZ6_TPPROD  <> 'RE') AND "
	ENDCASE

	IF MV_PAR18 == 2
		A0000 += "       ZZ6.ZZ6_TPPROD  <> 'RE' AND "
	ENDIF

	A0000 += "             SB1.D_E_L_E_T_    = ''   AND  "
	A0000 += "             ZZ7.D_E_L_E_T_    = ''   AND  "
	A0000 += "             ZZ6.D_E_L_E_T_    = ''   AND  "
	A0000 += "             ZZN.D_E_L_E_T_    = ''   AND  "
	A0000 += "             SA1.D_E_L_E_T_    = '' "
	A0000 += " GROUP BY D2_YEMP, B1_YLINHA, B1_YLINSEQ, B1_YFORMAT, ZZ7_DESC, ZZ6_DESC "
	A0000 += " ORDER BY D2_QUANT DESC "
	If chkfile("A000")
		dbSelectArea("A000")
		dbCloseArea()
	EndIf
	TcQuery A0000 New Alias "A000"

	nPerc    := 0
	nAcum    := 0
	nTotLanc := 0
	nQtdLanc := 0
	nQtdRet  := 0
	nTotRet  := 0
	nTotFor  := 0
	nTotGer  := 0
	nQtdProd := 0
	nTotFora := 0

	DbSelectArea("A000")
	DbGoTop()
	While !EOF()

		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Processando: "+cTempo)

		If nRow1 > 2200
			fImpRoda()
			fImpCabec()
		EndIf

		IF  A000->B1_YLINHA == '118E
			LTOK := .T.
		ENDIF

		nPerc := (A000->D2_QUANT/nMedia)/nTotQtd
		nAcum := nAcum + ((A000->D2_QUANT/nMedia)/nTotQtd)
		lRet  := .F.

		DbSelectArea("ZZ6")
		DbSetOrder(1)
		DbSeek(xFilial("ZZ6")+A000->B1_YFORMAT)
		IF ZZ6->ZZ6_TPPROD == 'RE'
			nRank01  := nRankA01 + 1
			nRankA01 := nRank01
			nTotRet  := nTotRet + (A000->D2_QUANT/nMedia)
			nQtdRet  := nQtdRet + 1
			lRet 	 := .T.
		ELSE
			nTotFor  := nTotFor + (A000->D2_QUANT/nMedia)
		ENDIF

		DO CASE
			CASE A000->B1_YFORMAT == cCodF02
			nRank02  := nRankA02 + 1
			nRankA02 := nRank02
			CASE A000->B1_YFORMAT == cCodF03
			nRank03  := nRankA03 + 1
			nRankA03 := nRank03
			CASE A000->B1_YFORMAT == cCodF04
			nRank04  := nRankA04 + 1
			nRankA04 := nRank04
			CASE A000->B1_YFORMAT == cCodF05
			nRank05  := nRankA05 + 1
			nRankA05 := nRank05
			CASE A000->B1_YFORMAT == cCodF06
			nRank06  := nRankA06 + 1
			nRankA06 := nRank06
			CASE A000->B1_YFORMAT == cCodF07
			nRank07  := nRankA07 + 1
			nRankA07 := nRank07
			CASE A000->B1_YFORMAT == cCodF08
			nRank08  := nRankA08 + 1
			nRankA08 := nRank08
		ENDCASE

		DbSelectArea("ZZN")
		DbSetOrder(1)
		DbSeek(xFilial("ZZN")+A000->B1_YFORMAT+A000->B1_YLINHA)

		IF ZZN->ZZN_AMOSTR == 'S'
			cAmostra := 'S'
		ELSE
			cAmostra := 'N'
		ENDIF

		cFornec  := ALLTRIM(ZZN->ZZN_FABR)
		cObs     := '' //SUBSTR(SB1->B1_OBS,1,15)

		IF EMPTY(cFornec)
			cFornec := '0' //Fabrica
		ENDIF

		IF ZZN->ZZN_ATIVO == 'S'
			cAtivo   := 'S'
			cEmProd  := 'Sim'
			nQtdProd := nQtdProd + 1
		ELSE
			cAtivo   := 'N'
			cEmProd  := 'NÃO'
			nTotFora := nTotFora + (A000->D2_QUANT/nMedia)
		ENDIF

		DbSelectArea(_cTab)
		DbSeek(A000->B1_YLINHA+A000->B1_YLINSEQ+A000->B1_YFORMAT)
		nRank09 := (_cTab)->RANK
		nRank10 := nRank10 + 1
		IF STOD((_cTab)->DATAPCOM) >= (MV_PAR02-365) .AND. ZZ6->ZZ6_TPPROD <> 'RE'
			dLanca   := (_cTab)->DATAPCOM
			nQtdLanc := nQtdLanc + 1
			nTotLanc := nTotLanc + (A000->D2_QUANT/nMedia)
		ELSE
			dLanca   := ''
		ENDIF

		DbSelectArea("A000")
		fr_Quebra := +;
		Padr(IIF(nRank01==0,'',nRank01)                                            								,05)+" "+;
		Padr(IIF(nRank02==0,'',nRank02)                        	                       							,05)+" "+;
		Padr(IIF(nRank03==0,'',nRank03)                            	                   							,05)+" "+;
		Padr(IIF(nRank04==0,'',nRank04)                               	               							,05)+" "+;
		Padr(IIF(nRank05==0,'',nRank05)                                  	           							,05)+" "+;
		Padr(IIF(nRank06==0,'',nRank06)                                            								,05)+" "+;
		Padr(IIF(nRank07==0,'',nRank07)                                            								,05)+" "+;
		Padr(IIF(nRank08==0,'',nRank08)                                            								,05)+" "+;
		Padr(IIF(nRank09==0,'',nRank09)                                            								,05)+" "+;
		Padr(IIF(nRank10==0,'',nRank10)                                        				   				 	,05)+" "+;
		Padr(ALLTRIM(A000->ZZ7_DESC)+"-"+SUBSTR(A000->ZZ6_DESC,1,15)										    ,37)+" "+;
		Padr(A000->B1_YFORMAT+'?'+A000->B1_YLINHA  																,08)+" "+;
		Padl(Transform(A000->D2_QUANT/nMedia, "@E 9,999,999.99")        	       			    				,14)+" "+;
		Padl(Transform(nPerc*100, "@E 99.99")                                    	   							,08)+" "+;
		Padl(Transform(nAcum*100, "@E 999.99")                                     								,08)+" "+;
		Padr(STOD(dLanca)                                                          								,10)+" "+;
		Padc(cAtivo                                                                								,05)+" "+;
		Padc(cEmProd                                                               								,08)+" "+;
		Padc(cAmostra                                                              								,10)+" "+;
		Padr(cFornec                                                               								,07)+" "+;
		Padr(cObs                                                                  								,15)

		oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
		nRow1 += 030
		oPrint:Line (nRow1, 010, nRow1, 3550)
		nRow1 += 020

		If nRow1 > 2200
			fImpRoda()
			fImpCabec()
		EndIf

		DbSelectArea(_cTab2)
		IF !DbSeek(A000->B1_YFORMAT)
			RecLock(_cTab2,.T.)
			(_cTab2)->FORMATO := A000->B1_YFORMAT
			(_cTab2)->DESC    := ZZ6->ZZ6_DESC
			(_cTab2)->QUANT   := A000->D2_QUANT/nMedia
			IF lRet
				(_cTab2)->RET := 'S'
			ELSE
				(_cTab2)->RET := 'N'
			ENDIF
			MsUnLock()
		ELSE
			RecLock(_cTab2,.F.)
			(_cTab2)->QUANT   := (_cTab2)->QUANT + (A000->D2_QUANT/nMedia)
			MsUnLock()
		ENDIF

		nTotGer  := nTotGer + (A000->D2_QUANT/nMedia)

		DbSelectArea(_cTab3)
		IF !DbSeek(cFornec)
			RecLock(_cTab3,.T.)
			(_cTab3)->FORNECE := cFornec
			(_cTab3)->QUANT   := (A000->D2_QUANT/nMedia)
		ELSE
			RecLock(_cTab3,.F.)
			(_cTab3)->QUANT   := (_cTab3)->QUANT + (A000->D2_QUANT/nMedia)
			MsUnLock()
		ENDIF

		nRank01 := 0
		nRank02 := 0
		nRank03 := 0
		nRank04 := 0
		nRank05 := 0
		nRank06 := 0
		nRank07 := 0
		nRank08 := 0

		DbSelectArea("A000")
		DbSkip()
		Loop
	END

	//------------------------------------------------------
	fr_Quebra := +;
	Padr(''                                                            								,106)+" "+;
	Padl(Transform(nTotGer, "@E 9,999,999.99") 			        	       							,14)+" "+;
	Padl(Transform(100, "@E 999.99")                                   								,08)+" "+;
	Padl(''							                                  								,06)+" "+;
	Padl(Transform(nQtdLanc, "@E 999")	                             								,08)+" "+;
	Padl(Transform(nQtdProd, "@E 999")	                             								,07)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	//-----------------------------------------------------
	fr_Quebra := +;
	Padr('Soma de Lançamentos(M2)'                                     								,52)+" "+;
	Padl(Transform(nTotLanc, "@E 999,999.99")  			        	       							,12)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	//-----------------------------------------------------
	fr_Quebra := +;
	Padr('Quant.Produtos Fora de Linha (M2)'                           								,52)+" "+;
	Padl(Transform(nTotFora, "@E 999,999.99")  			        	       							,12)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	//-----------------------------------------------------
	fr_Quebra := +;
	Padr('Quant.Lançamentos/Quant.Produtos em Linha (%)'              								,52)+" "+;
	Padl(Transform(nQtdLanc/nQtdProd*100, "@E 999.99")           	       							,12)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	//-----------------------------------------------------
	fr_Quebra := +;
	Padr('Venda Lançamento/Venda Total (%)'                          								,52)+" "+;
	Padl(Transform(nTotLanc/nTotGer*100, "@E 999.99") 	        	       							,12)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	//-----------------------------------------------------
	nRow1 += 020
	fr_Quebra := +;
	Padr('RETIFICADO'                                                  								,110)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 020

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	DbSelectArea(_cTab2)
	DbGoTop()
	While !Eof()
		IF (_cTab2)->RET == 'S'
			fr_Quebra := +;
			Padr((_cTab2)->FORMATO+"-"+(_cTab2)->DESC                          								,40)+" "+;
			Padl(Transform((_cTab2)->QUANT, "@E 999,999.99") 	        	       							,12)+" "+;
			Padl(Transform((_cTab2)->QUANT/nTotRet*100, "@E 999,999.99")			   							,12)+" "+;
			Padr(''                                                            								,55)

			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020

			If nRow1 > 2200
				fImpRoda()
				fImpCabec()
			EndIf
		ENDIF

		DbSelectArea(_cTab2)
		DbSkip()
	End

	fr_Quebra := +;
	Padr('TOTAL RETIFICADO'					                          								,40)+" "+;
	Padl(Transform(nTotRet, "@E 999,999.99")							   							,12)+" "+;
	Padl(Transform(100, "@E 999.99")                                   								,12)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 020

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	//-----------------------------------------------------
	nRow1 += 020
	fr_Quebra := +;
	Padr('RESUMO POR FORMATO'                                          								,40)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 020

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	DbSelectArea(_cTab2)
	DbGoTop()
	While !Eof()
		IF (_cTab2)->RET == 'N'
			fr_Quebra := +;
			Padr((_cTab2)->FORMATO+"-"+(_cTab2)->DESC                          								,40)+" "+;
			Padl(Transform((_cTab2)->QUANT, "@E 999,999.99") 	        	       							,12)+" "+;
			Padl(Transform((_cTab2)->QUANT/nTotFor*100, "@E 999,999.99")    	       							,12)+" "+;
			Padr(''                                                            								,55)

			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020

			If nRow1 > 2200
				fImpRoda()
				fImpCabec()
			EndIf
		ENDIF

		DbSelectArea(_cTab2)
		DbSkip()
	End

	fr_Quebra := +;
	Padr('TOTAL FORMATO'					                          								,40)+" "+;
	Padl(Transform(nTotFor, "@E 999,999.99")							   							,12)+" "+;
	Padl(Transform(100, "@E 999.99")                                   								,12)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 020

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	//-----------------------------------------------------
	nRow1 += 020
	fr_Quebra := +;
	Padr('FORNECEDOR'                                                 								,40)+" "+;
	Padr(''                                                            								,55)

	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 020

	If nRow1 > 2200
		fImpRoda()
		fImpCabec()
	EndIf

	DbSelectArea(_cTab3)
	DbGoTop()
	While !Eof()
		fr_Quebra := +;
		Padr((_cTab3)->FORNECE					                          								,40)+" "+;
		Padl(Transform((_cTab3)->QUANT/nTotGer*100, "@E 999,999.99")	        	       					,12)+" "+;
		Padr(''                                                            								,55)

		oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
		nRow1 += 030
		oPrint:Line (nRow1, 010, nRow1, 3550)
		nRow1 += 020

		If nRow1 > 2200
			fImpRoda()
			fImpCabec()
		EndIf

		DbSelectArea(_cTab3)
		DbSkip()
	End

	A000->(dbCloseArea())
	A001->(dbCloseArea())
	A002->(dbCloseArea())
	A003->(dbCloseArea())

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
	EndIf
	nRow1 += 025
	oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
	oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
	oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
	nRow1 += 075
	oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
	nRow1 += 075

	xf_Titu := +;
	Padr("Rank."    									     ,05)+" "+;
	Padr("Rank."            								 ,05)+" "+;
	Padr("Rank."            						 	     ,05)+" "+;
	Padr("Rank."          							         ,05)+" "+;
	Padr("Rank."                 							 ,05)+" "+;
	Padr("Rank."                   							 ,05)+" "+;
	Padr("Rank."                   							 ,05)+" "+;
	Padr("Rank."		                        			 ,05)+" "+;
	Padr("Rank."	      		                   			 ,05)+" "+;
	Padr("Rank."        		                   			 ,05)+" "+;
	Padr("Produto"           	                  			 ,45)+" "+;
	Padl("Previsto M2 "                   				 	 ,14)+" "+;
	Padl("Part(%)"                   						 ,08)+" "+;
	Padl("Acum."	            			   				 ,08)+" "+;
	Padl("Lançamento"			               				 ,10)+" "+;
	Padr("Ativo"     			               				 ,05)+" "+;
	Padc("Em"	     		                				 ,08)+" "+;
	Padr("Enviar   "   	    		         				 ,10)+" "+;
	Padr("Fornec."                							 ,07)+" "+;
	Padr("Observação     "         							 ,15)

	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)

	nRow1 += 050

	xf_Titu2 := +;
	Padr(""+cFor01						     		 		 ,05)+" "+;
	Padr(""+cFor02		       								 ,05)+" "+;
	Padr(""+cFor03		 	               					 ,05)+" "+;
	Padr(""+cFor04		       								 ,05)+" "+;
	Padr(""+cFor05		           							 ,05)+" "+;
	Padr(""+cFor06		   		       						 ,05)+" "+;
	Padr(""+cFor07		        							 ,05)+" "+;
	Padr(""+cFor08		        							 ,05)+" "+;
	Padr(""+cFor09		        							 ,05)+" "+;
	Padr(""+cFor10		           							 ,05)+" "+;
	Padr("" 			                   					 ,45)+" "+;
	Padr("Media "+STRZERO(nMedia,2)+" Meses"   				 ,14)+" "+;
	Padr("        " 			               				 ,08)+" "+;
	Padr("        "		                       				 ,08)+" "+;
	Padr("          "   	 	               				 ,10)+" "+;
	Padr("     "        	 	               				 ,05)+" "+;
	Padr("Producao"				              				 ,08)+" "+;
	Padc("Amostra"	    		               				 ,10)+" "+;
	Padr("       "             								 ,07)+" "+;
	Padr("               "              					 ,15)

	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont7)
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
	nRow1 += 075

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 010, 2300, 3550)
	oPrint:Say  (2300+30 , 010,"Prog.: BIA465"                                        ,oFont7)
	oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Wanisay William       ¦ Data ¦ 28.04.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	local j,i
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,6)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da  Data               ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","(MV_PAR02 - MV_PAR01) <= 365","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do  Segmento           ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Segmento           ?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do  Representante      ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ate Representante      ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Do  Cliente            ?","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Ate Cliente            ?","","","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Do  Grupo Cliente      ?","","","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Ate Grupo Cliente      ?","","","mv_cha","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Do  Formato            ?","","","mv_chb","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Ate Formato            ?","","","mv_chc","C",02,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Da  Classe             ?","","","mv_chd","C",01,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Ate Classe             ?","","","mv_che","C",01,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"15","Imprime Linha          ?","","","mv_chf","C",01,0,0,"C","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"16","Formatos               ?","","","mv_chg","C",30,0,0,"C","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"17","Situação dos Produtos  ?","","","mv_chh","C",01,0,0,"C","","mv_par17","Fora de Linha","Fora de Linha","Fora de Linha","","","Em Produção","Em Produção","Em Produção","","","Todos","Todos","Todos","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"18","Retificados            ?","","","mv_chi","C",01,0,0,"C","","mv_par18","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","",""})

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