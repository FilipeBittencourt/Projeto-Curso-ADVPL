#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'

User Function BIA359()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA359
Empresa   := Biancogres Cerâmica S/A
Data      := 17/12/15
Uso       := Custos
Aplicação := Análise de Movimento de Produto Acabado
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

cHInicio := Time()
fPerg := "BIA359"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

sdtIni := stod(MV_PAR01 + "01")
sdtFim := UltimoDia(sdtIni)

aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
fCabec   := "ANÁLISE DE MOVIMENTO DE ESTOQUE"
fCabe02  := ""
wnPag    := 0
nRow1    := 0
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetPaperSize(09)
oPrint:SetLandscape()
oPrint:Setup()

cTempo := Alltrim(ElapTime(cHInicio, Time()))
IncProc("Armazenando....   Tempo: "+cTempo)

fImpCabec()
kTotQtd := 0
kTotCst := 0
kFimQtd := 0
kFimCst := 0

QT007 := " WITH MOVIMENTOS AS(
QT007 += "                     SELECT '000-SB9' TABL,
QT007 += "                            B9_COD PRODUTO,
QT007 += "                            '000' TES,
QT007 += "                            'SALDO INICIAL' MVTO,
QT007 += "                            '0000' CFOP,
QT007 += "                            'SALDO ANTERIOR' FINALID,
QT007 += "                            SUM(B9_QINI) QUANT,
QT007 += "                            SUM(B9_VINI1) CUSTO
QT007 += "                       FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK)
QT007 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
QT007 += "                                                         AND B1_COD = B9_COD
QT007 += "                                                         AND B1_TIPO = 'PA'
QT007 += "                                                         AND SB1.D_E_L_E_T_ = ' '
QT007 += "                      WHERE B9_FILIAL = '"+xFilial("SB9")+"'
QT007 += "                        AND B9_DATA = '"+dtos(sdtIni-1)+"'
QT007 += "                        AND ( B9_QINI <> 0 OR B9_VINI1 <> 0 )
QT007 += "                        AND SB9.D_E_L_E_T_ = ' '
QT007 += "                      GROUP BY B9_COD
QT007 += "                      UNION ALL
QT007 += "                     SELECT '001-SD1' TABL,
QT007 += "                            D1_COD PRODUTO,
QT007 += "                            D1_TES TES,
QT007 += "                            F4_TEXTO MVTO,
QT007 += "                            D1_CF CFOP,
QT007 += "                            X5_DESCRI FINALID,
QT007 += "                            D1_QUANT QUANT,
QT007 += "                            D1_CUSTO CUSTO
QT007 += "                       FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)
QT007 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
QT007 += "                                                         AND B1_COD = D1_COD
QT007 += "                                                         AND B1_TIPO = 'PA'
QT007 += "                                                         AND SB1.D_E_L_E_T_ = ' '
QT007 += "                      INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'
QT007 += "                                                         AND F4_CODIGO = D1_TES
QT007 += "                                                         AND F4_ESTOQUE = 'S'
QT007 += "                                                         AND SF4.D_E_L_E_T_ = ' '
QT007 += "                       LEFT JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON X5_FILIAL = '"+xFilial("SX5")+"'
QT007 += "                                                         AND X5_TABELA = '13'
QT007 += "                                                         AND X5_CHAVE = D1_CF
QT007 += "                                                         AND SX5.D_E_L_E_T_ = ' '
QT007 += "                      WHERE D1_FILIAL = '"+xFilial("SD1")+"'
QT007 += "                        AND D1_DTDIGIT BETWEEN '"+dtos(sdtIni)+"' AND '"+dtos(sdtFim)+"'
QT007 += "                        AND SD1.D_E_L_E_T_ = ' '
QT007 += "                      UNION ALL
QT007 += "                     SELECT '002-SD2' TABL,
QT007 += "                            D2_COD PRODUTO,
QT007 += "                            D2_TES TES,
QT007 += "                            F4_TEXTO MVTO,
QT007 += "                            D2_CF CFOP,
QT007 += "                            X5_DESCRI FINALID,
QT007 += "                            D2_QUANT * (-1) QUANT,
QT007 += "                            D2_CUSTO1 * (-1) CUSTO
QT007 += "                       FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)
QT007 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
QT007 += "                                                         AND B1_COD = D2_COD
QT007 += "                                                         AND B1_TIPO = 'PA'
QT007 += "                                                         AND SB1.D_E_L_E_T_ = ' '
QT007 += "                      INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'
QT007 += "                                                         AND F4_CODIGO = D2_TES
QT007 += "                                                         AND F4_ESTOQUE = 'S'
QT007 += "                                                         AND SF4.D_E_L_E_T_ = ' '
QT007 += "                       LEFT JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON X5_FILIAL = '"+xFilial("SX5")+"'
QT007 += "                                                         AND X5_TABELA = '13'
QT007 += "                                                         AND X5_CHAVE = D2_CF
QT007 += "                                                         AND SX5.D_E_L_E_T_ = ' '
QT007 += "                      WHERE D2_FILIAL = '"+xFilial("SD2")+"'
QT007 += "                        AND D2_EMISSAO BETWEEN '"+dtos(sdtIni)+"' AND '"+dtos(sdtFim)+"'
QT007 += "                        AND SD2.D_E_L_E_T_ = ' '
QT007 += "                      UNION ALL
QT007 += "                     SELECT '003-SD3' TABL,
QT007 += "                            D3_COD PRODUTO,
QT007 += "                            D3_TM TES,
QT007 += "                            ISNULL(F5_TEXTO,
QT007 += "                                            CASE
QT007 += "                                              WHEN D3_TM = '999' THEN 'REQUISICAO AUTOMATICA'
QT007 += "                                              WHEN D3_TM = '499' THEN 'DEVOLUCAO AUTOMATICA'
QT007 += "                                            END) MVTO,
QT007 += "                            D3_CF CFOP,
QT007 += "                            CASE
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E0' AND  D3_ESTORNO <> 'S' THEN 'MANUAL DE MATERIAL APROP. DIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E1' AND  D3_ESTORNO <> 'S' THEN 'AUTOMATICO DE MATERIAL APROP. DIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E2' AND  D3_ESTORNO <> 'S' THEN 'AUTOMATICO DE MATERIAL APROP. INDDIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E3' AND  D3_ESTORNO <> 'S' THEN 'MANUAL DE MATERIAL APROP. INDIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E4' AND  D3_ESTORNO <> 'S' THEN 'TRANSFERENCIA EM GERAL'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E5' AND  D3_ESTORNO <> 'S' THEN 'APROP. DIRETA ENTRADA NA OP'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E6' AND  D3_ESTORNO <> 'S' THEN 'MANUAL DE MATERIAL VALORIZADO'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E7' AND  D3_ESTORNO <> 'S' THEN 'DESMONTAGEM DE PRODUTOS'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E8' AND  D3_ESTORNO <> 'S' THEN 'INTEGRACAO MODULO IMPORTACAO'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E9' AND  D3_ESTORNO <> 'S' THEN 'MOVIMENTOS PARA OP SEM AGREG.CUSTO'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'EA' AND  D3_ESTORNO <> 'S' THEN 'MOVIMENTOS DE REAVALIACAO DE CUSTO'
QT007 += "                              WHEN SUBSTRING(D3_CF,1,2)= 'PR' AND  D3_ESTORNO <> 'S' THEN 'PRODUCAO'
QT007 += "                              WHEN D3_ESTORNO = 'S' THEN 'CANCELADO'
QT007 += "                            END FINALID,
QT007 += "                            D3_QUANT QUANT,
QT007 += "                            D3_CUSTO1 CUSTO
QT007 += "                       FROM "+RetSqlName("SD3")+" SD1 WITH (NOLOCK)
QT007 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
QT007 += "                                                         AND B1_COD = D3_COD
QT007 += "                                                         AND B1_TIPO = 'PA'
QT007 += "                                                         AND SB1.D_E_L_E_T_ = ' '
QT007 += "                       LEFT JOIN "+RetSqlName("SF5")+" SF5 WITH (NOLOCK) ON F5_CODIGO = D3_TM
QT007 += "                                                         AND SF5.D_E_L_E_T_ = ' '
QT007 += "                      WHERE D3_FILIAL = '"+xFilial("SD3")+"'
QT007 += "                        AND D3_EMISSAO BETWEEN '"+dtos(sdtIni)+"' AND '"+dtos(sdtFim)+"'
QT007 += "                        AND D3_TM <= '500'
QT007 += "                        AND SD1.D_E_L_E_T_ = ' '
QT007 += "                      UNION ALL
QT007 += "                     SELECT '004-SD3' TABL,
QT007 += "                            D3_COD PRODUTO,
QT007 += "                            D3_TM TES,
QT007 += "                            ISNULL(F5_TEXTO,
QT007 += "                                            CASE
QT007 += "                                              WHEN D3_TM = '999' THEN 'REQUISICAO AUTOMATICA'
QT007 += "                                              WHEN D3_TM = '999' THEN 'DEVOLUCAO AUTOMATICA'
QT007 += "                                            END) MVTO,
QT007 += "                            D3_CF CFOP,
QT007 += "                            CASE
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E0' AND  D3_ESTORNO <> 'S' THEN 'MANUAL DE MATERIAL APROP. DIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E1' AND  D3_ESTORNO <> 'S' THEN 'AUTOMATICO DE MATERIAL APROP. DIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E2' AND  D3_ESTORNO <> 'S' THEN 'AUTOMATICO DE MATERIAL APROP. INDDIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E3' AND  D3_ESTORNO <> 'S' THEN 'MANUAL DE MATERIAL APROP. INDIRETA'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E4' AND  D3_ESTORNO <> 'S' THEN 'TRANSFERENCIA EM GERAL'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E5' AND  D3_ESTORNO <> 'S' THEN 'APROP. DIRETA ENTRADA NA OP'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E6' AND  D3_ESTORNO <> 'S' THEN 'MANUAL DE MATERIAL VALORIZADO'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E7' AND  D3_ESTORNO <> 'S' THEN 'DESMONTAGEM DE PRODUTOS'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E8' AND  D3_ESTORNO <> 'S' THEN 'INTEGRACAO MODULO IMPORTACAO'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'E9' AND  D3_ESTORNO <> 'S' THEN 'MOVIMENTOS PARA OP SEM AGREG.CUSTO'
QT007 += "                              WHEN SUBSTRING(D3_CF,2,2)= 'EA' AND  D3_ESTORNO <> 'S' THEN 'MOVIMENTOS DE REAVALIACAO DE CUSTO'
QT007 += "                              WHEN SUBSTRING(D3_CF,1,2)= 'PR' AND  D3_ESTORNO <> 'S' THEN 'PRODUCAO'
QT007 += "                              WHEN D3_ESTORNO = 'S' THEN 'CANCELADO'
QT007 += "                            END FINALID,
QT007 += "                            D3_QUANT * (-1) QUANT,
QT007 += "                            D3_CUSTO1 * (-1) CUSTO
QT007 += "                       FROM "+RetSqlName("SD3")+" SD1 WITH (NOLOCK)
QT007 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
QT007 += "                                                         AND B1_COD = D3_COD
QT007 += "                                                         AND B1_TIPO = 'PA'
QT007 += "                                                         AND SB1.D_E_L_E_T_ = ' '
QT007 += "                       LEFT JOIN "+RetSqlName("SF5")+" SF5 WITH (NOLOCK) ON F5_CODIGO = D3_TM
QT007 += "                                                         AND SF5.D_E_L_E_T_ = ' '
QT007 += "                      WHERE D3_FILIAL = '"+xFilial("SD3")+"'
QT007 += "                        AND D3_EMISSAO BETWEEN '"+dtos(sdtIni)+"' AND '"+dtos(sdtFim)+"'
QT007 += "                        AND D3_TM > '500'
QT007 += "                        AND SD1.D_E_L_E_T_ = ' '
QT007 += "                      UNION ALL
QT007 += "                     SELECT '005-SB9' TABL,
QT007 += "                            B9_COD PRODUTO,
QT007 += "                            'ZZZ' TES,
QT007 += "                            'SALDO FINAL' MVTO,
QT007 += "                            'ZZZZ' CFOP,
QT007 += "                            'SALDO ATUAL' FINALID,
QT007 += "                            SUM(B9_QINI) QUANT,
QT007 += "                            SUM(B9_VINI1) CUSTO
QT007 += "                       FROM "+RetSqlName("SB9")+" SB9 WITH (NOLOCK)
QT007 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
QT007 += "                                                         AND B1_COD = B9_COD
QT007 += "                                                         AND B1_TIPO = 'PA'
QT007 += "                                                         AND SB1.D_E_L_E_T_ = ' '
QT007 += "                      WHERE B9_FILIAL = '"+xFilial("SB9")+"'
QT007 += "                        AND B9_DATA = '"+dtos(sdtFim)+"'
QT007 += "                        AND ( B9_QINI <> 0 OR B9_VINI1 <> 0 )
QT007 += "                        AND SB9.D_E_L_E_T_ = ' '
QT007 += "                      GROUP BY B9_COD)
QT007 += "  SELECT TABL,
QT007 += "         TES,
QT007 += "         MVTO,
QT007 += "         CFOP,
QT007 += "         FINALID,
QT007 += "         SUM(QUANT) QUANT,
QT007 += "         SUM(CUSTO) CUSTO
QT007 += "    FROM MOVIMENTOS
QT007 += "   GROUP BY TABL,
QT007 += "            TES,
QT007 += "            MVTO,
QT007 += "            CFOP,
QT007 += "            FINALID
QTIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QT007),'QT07',.T.,.T.)
dbSelectArea("QT07")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	nRow1 += 050
	xchv := Substr(QT07->TABL, 1,3)
	While !Eof() .and. Substr(QT07->TABL, 1,3) == xchv
		
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		
		xf_CbNumOp := +;
		Padr(QT07->TABL                                       ,07)+"    "+;
		Padr(QT07->TES                                        ,03)+"    "+;
		Padr(QT07->MVTO                                       ,30)+"    "+;
		Padr(QT07->CFOP                                       ,05)+"    "+;
		Padr(QT07->FINALID                                    ,60)+"    "+;
		Padl(Transform(ABS(QT07->QUANT), "@E 999,999,999.99") ,14)+"    "+;
		Padl(Transform(ABS(QT07->CUSTO), "@E 999,999,999.99") ,14)
		
		oPrint:Say  (nRow1 ,0050 ,xf_CbNumOp                               ,oFont8)
		nRow1 += 075
		
		If QT07->TABL <> "005-SB9"
			kTotQtd += QT07->QUANT
			kTotCst += QT07->CUSTO
		Else
			kFimQtd += QT07->QUANT
			kFimCst += QT07->CUSTO
		EndIf
		
		dbSelectArea("QT07")
		dbSkip()
		
	End
	oPrint:Line (nRow1+35-075, 050, nRow1+35-075, 3300)
	
	dbSelectArea("QT07")
	
End

QT07->(dbCloseArea())
Ferase(QTIndex+GetDBExtension())
Ferase(QTIndex+OrdBagExt())

If nRow1 > 2250
	fImpRoda()
	fImpCabec()
EndIf

xf_CbNumOp := +;
Padr(""                                               ,07)+"    "+;
Padr(""                                               ,03)+"    "+;
Padr("DIVERGENCIA"                                    ,30)+"    "+;
Padr(""                                               ,05)+"    "+;
Padr(""                                               ,60)+"    "+;
Padl(Transform(kTotQtd-kFimQtd, "@E 999,999,999.99")  ,14)+"    "+;
Padl(Transform(kTotCst-kFimCst, "@E 999,999,999.99")  ,14)

nRow1 += 075
oPrint:Say  (nRow1 ,0050 ,xf_CbNumOp                               ,oFont8)
nRow1 += 075

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

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
sw_Perid :=  "Periodo: "+ dtoc(sdtIni) +" até " + dtoc(sdtFim)
oPrint:Say  (nRow1     ,0050 ,Padc(fCabec,110)                                           ,oFont14)
oPrint:Say  (nRow1+10  ,3000 ,"Página:"                                                  ,oFont7)
oPrint:Say  (nRow1+05  ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
oPrint:Say  (nRow1+60  ,3000 ,"Emissão:"                                                 ,oFont7)
oPrint:Say  (nRow1+65  ,3150 ,dtoc(dDataBase)                                            ,oFont8)
oPrint:Say  (nRow1+75  ,0050 ,Padc(sw_Perid,150)                                         ,oFont10)
nRow1 += 150
oPrint:Line (nRow1, 050, nRow1, 3300)
nRow1 += 050

xf_CbNumOp := +;
Padr("Tabela"                                         ,07)+"    "+;
Padr("TES"                                            ,03)+"    "+;
Padr("Movimento"                                      ,30)+"    "+;
Padr("CFOP"                                           ,05)+"    "+;
Padr("Finalidade"                                     ,60)+"    "+;
Padl("Quantidade"                                     ,14)+"    "+;
Padl("Custo"                                          ,14)

oPrint:Say  (nRow1 ,0050 ,xf_CbNumOp                               ,oFont8)
oPrint:Line (nRow1+35, 050, nRow1+35, 3300)
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

oPrint:Line (2300, 050, 2300, 3300)
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
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Ano / Mês           ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
