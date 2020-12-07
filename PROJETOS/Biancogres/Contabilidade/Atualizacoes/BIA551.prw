#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

User Function BIA551()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA551
Empresa   := Biancogres Ceramica S.A.
Data      := 22/06/15
Uso       := Contabilidade
Aplicação := Rateio para Unidade de Negócio
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local hr
Private dtRefEmi := dDataBase

fgLanPad := "D01"
fgLotCtb := "002700"
fgVetCtb := {}
fgPermDg := .F.

cHInicio := Time()
fPerg := "BIA551"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

wPeriod := MV_PAR01
wPerDe  := MV_PAR01+"01"
wPerAte := dtos(UltimoDia(stod(wPerDe)))

dDataBase := stod(wPerAte)

If cEmpAnt <> "91"
	Aviso('Rateio UN','Esta Rotina somente poderá ser ezecutada para a empresa UNIDADE DE NEGÓCIO - 91' ,{'Ok'})
	Return
EndIf

//                                                Lançamentos rateáveis - CT2
*****************************************************************************
LR003 := " SELECT Z59_EMPR, Z59_PERCEN
LR003 += "   FROM " + RetSqlName("Z59")
LR003 += "  WHERE Z59_UN = '"+cFilAnt+"'
LR003 += "    AND Z59_PERIOD = '"+MV_PAR01+"'
//LR003 += "    AND 1 = 2
LR003 += "    AND D_E_L_E_T_ = ' '
LR003 += "  ORDER BY Z59_EMPR
LRcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,LR003),'LR03',.T.,.T.)
dbSelectArea("LR03")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	wEmpr    := LR03->Z59_EMPR
	wPercent := LR03->Z59_PERCEN
	
	HW007 := " SELECT CONTA,
	HW007 += "        CLVL,
	HW007 += "        ROUND(SUM(VALOR),2) VALOR
	HW007 += "   FROM (SELECT CT2_DEBITO CONTA, CT2_CLVLDB CLVL, SUM(CT2_VALOR) VALOR
	HW007 += "           FROM CT2"+wEmpr+"0
	HW007 += "          WHERE CT2_DATA BETWEEN '"+wPerDe+"' AND '"+wPerAte+"'
	HW007 += "            AND SUBSTRING(CT2_DEBITO, 1, 1) IN( '3', '4', '6' )
	HW007 += "            AND SUBSTRING(CT2_DEBITO, 1, 3) NOT IN('411','412','413')
	HW007 += "            AND SUBSTRING(CT2_DEBITO, 1, 5) NOT IN('31401','31403','31406')
	//HW007 += "            AND CT2_CLVLDB = ''
	HW007 += "            AND D_E_L_E_T_ = ' '
	HW007 += "          GROUP BY CT2_DEBITO, CT2_CLVLDB
	HW007 += "          UNION ALL
	HW007 += "         SELECT CT2_CREDIT CONTA, CT2_CLVLCR CLVL, SUM(CT2_VALOR)*(-1) VALOR
	HW007 += "           FROM CT2"+wEmpr+"0
	HW007 += "          WHERE CT2_DATA BETWEEN '"+wPerDe+"' AND '"+wPerAte+"'
	HW007 += "            AND SUBSTRING(CT2_CREDIT, 1, 1) IN( '3', '4', '6' )
	HW007 += "            AND SUBSTRING(CT2_CREDIT, 1, 3) NOT IN('411','412','413')
	HW007 += "            AND SUBSTRING(CT2_CREDIT, 1, 5) NOT IN('31401','31403','31406')
	//HW007 += "            AND CT2_CLVLCR = ''
	HW007 += "            AND D_E_L_E_T_ = ' '
	HW007 += "          GROUP BY CT2_CREDIT, CT2_CLVLCR) AS TABK
	HW007 += "   GROUP BY CONTA,
	HW007 += "            CLVL
	/*
	HW007 := " SELECT CTI_CONTA,
	HW007 += "        CLVL,
	HW007 += "        SUM(VALOR) VALOR
	HW007 += "   FROM (SELECT CTI_CONTA,
	HW007 += "                CTI_CLVL CLVL,
	HW007 += "                SUM(CTI_DEBITO - CTI_CREDIT) VALOR
	HW007 += "           FROM CTI"+wEmpr+"0 CTI
	HW007 += "          WHERE CTI_DATA BETWEEN '"+wPerDe+"' AND '"+wPerAte+"'
	HW007 += "            AND SUBSTRING(CTI_CONTA, 1, 1) IN( '3', '4', '6' )
	HW007 += "            AND SUBSTRING(CTI_CONTA, 1, 3) NOT IN('411','412','413')
	HW007 += "            AND SUBSTRING(CTI_CONTA, 1, 5) NOT IN('31401','31403','31406')
	HW007 += "            AND CTI.D_E_L_E_T_ = ' '
	HW007 += "          GROUP BY CTI_CONTA,
	HW007 += "                   CTI_CLVL) AS VALORES
	HW007 += "  GROUP BY CTI_CONTA,
	HW007 += "           CLVL
	HW007 += "  ORDER BY CTI_CONTA,
	HW007 += "           CLVL
	*/
	HWcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HW007),'HW07',.T.,.T.)
	dbSelectArea("HW07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		IncProc()
		
		If HW07->VALOR <> 0
			
			wDebito := ""
			wCredit := ""
			wClvlDB := ""
			wClvlCR := ""
			wVlrLnc := ABS(HW07->VALOR) * wPercent / 100
			wHistr  := "AJUSTE PARA DRE U.N."
			wCustDB := ""
			wCustCR := ""
			wOrigem := "LANCTO AJUSTE P/ DRE UN - EMPR: " + wEmpr + " Perc.: " + Transform(wPercent, "@E 9,999,999.99") + " Vlr Origem: " + Transform(HW07->VALOR, "@E 999,999,999,999.99")
			If HW07->VALOR > 0
				wDebito := HW07->CONTA
				wClvlDB := HW07->CLVL
				wCustDB := U_B478RTCC(HW07->CLVL)[1] //IIF(Substr(HW07->CLVL,1,1) $ "1/4/5/8", "1000", IIF(Substr(HW07->CLVL,1,1) $ "2", "2000", "3000"))
				wCredit := "51101001"
				wClvlCR := ""
				wCustCR := ""
			Else
				wCredit := HW07->CONTA
				wClvlCR := HW07->CLVL
				wCustCR := U_B478RTCC(HW07->CLVL)[1] //IIF(Substr(HW07->CLVL,1,1) $ "1/4/5/8", "1000", IIF(Substr(HW07->CLVL,1,1) $ "2", "2000", "3000"))
				wDebito := "51101001"
				wClvlDB := ""
				wCustDB := ""
			EndIf
			
			// Vetor ==>>     Debito, Credito,  ClVl_D,  ClVl_C, Item_Contab_D, Item_Contab_C,   Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM
			Aadd(fgVetCtb, { wDebito, wCredit, wClvlDB, wClvlCR, ""           , ""           , wVlrLnc, wHistr    , wCustDB     , wCustCR     , wOrigem      })
			
		EndIf
		
		dbSelectArea("HW07")
		dbSkip()
		
	End
	Ferase(HWcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(HWcIndex+OrdBagExt())          //indice gerado
	HW07->(dbCloseArea())
	
	dbSelectArea("LR03")
	dbSkip()
	
End
Ferase(LRcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(LRcIndex+OrdBagExt())          //indice gerado
LR03->(dbCloseArea())

//                                            Lançamentos NÃO rateáveis - CT2
//                                               Específico para a empresa 07
*****************************************************************************
If cFilAnt $ "01/05" //.AND. 1 == 2
	
	HW007 := " SELECT CTI_CONTA,
	HW007 += "        CLVL,
	HW007 += "        SUM(VALOR) VALOR,
	HW007 += "        CTH_YCLVLG,
	HW007 += "        CTH_YUN
	HW007 += "   FROM (SELECT CTI_CONTA,
	HW007 += "                CTI_CLVL CLVL,
	HW007 += "                SUM(CTI_DEBITO - CTI_CREDIT) VALOR
	HW007 += "           FROM CTI070 CTI
	HW007 += "          WHERE CTI_DATA BETWEEN '"+wPerDe+"' AND '"+wPerAte+"'
	HW007 += "            AND ( SUBSTRING(CTI_CONTA, 1, 3) IN('413') OR SUBSTRING(CTI_CONTA, 1, 5) IN('31401','31403','31406') )
	HW007 += "            AND CTI.D_E_L_E_T_ = ' '
	HW007 += "          GROUP BY CTI_CONTA,
	HW007 += "                   CTI_CLVL) AS VALORES
	HW007 += "  INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_CLVL = CLVL
	HW007 += "                       AND CTH_YUN = '"+cFilAnt+"'
	HW007 += "                       AND CTH.D_E_L_E_T_ = ' '
	HW007 += "  WHERE VALOR <> 0
	HW007 += "  GROUP BY CTI_CONTA,
	HW007 += "           CLVL,
	HW007 += "           CTH_YCLVLG,
	HW007 += "           CTH_YUN
	HW007 += "  ORDER BY CTI_CONTA,
	HW007 += "           CLVL
	HWcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HW007),'HW07',.T.,.T.)
	dbSelectArea("HW07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		IncProc()
		
		wDebito := ""
		wCredit := ""
		wClvlDB := ""
		wClvlCR := ""
		wVlrLnc := ABS(HW07->VALOR)
		wHistr  := "AJUSTE PARA DRE U.N. (REC/CPV)"
		wCustDB := ""
		wCustCR := ""
		wOrigem := "LANCTO AJUSTE P/ DRE UN - EMPR: 07 Vlr Origem: " + Transform(HW07->VALOR, "@E 999,999,999,999.99")
		If HW07->VALOR > 0
			wDebito := HW07->CTI_CONTA
			wClvlDB := HW07->CLVL
			wCustDB := U_B478RTCC(HW07->CLVL)[1] //IIF(Substr(HW07->CLVL,1,1) $ "1/4/5/8", "1000", IIF(Substr(HW07->CLVL,1,1) $ "2", "2000", "3000"))
			wCredit := "51101001"
			wClvlCR := ""
			wCustCR := ""
		Else
			wCredit := HW07->CTI_CONTA
			wClvlCR := HW07->CLVL
			wCustCR := U_B478RTCC(HW07->CLVL)[1] //IIF(Substr(HW07->CLVL,1,1) $ "1/4/5/8", "1000", IIF(Substr(HW07->CLVL,1,1) $ "2", "2000", "3000"))
			wDebito := "51101001"
			wClvlDB := ""
			wCustDB := ""
		EndIf
		
		// Vetor ==>>     Debito, Credito,  ClVl_D,  ClVl_C, Item_Contab_D, Item_Contab_C,   Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM
		Aadd(fgVetCtb, { wDebito, wCredit, wClvlDB, wClvlCR, ""           , ""           , wVlrLnc, wHistr    , wCustDB     , wCustCR     , wOrigem      })
		
		dbSelectArea("HW07")
		dbSkip()
		
	End
	Ferase(HWcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(HWcIndex+OrdBagExt())          //indice gerado
	HW07->(dbCloseArea())
	
EndIf

//                                                Lançamentos rateáveis - Z48
*****************************************************************************
LR003 := " SELECT Z59_EMPR, Z59_PERCEN
LR003 += "   FROM " + RetSqlName("Z59")
LR003 += "  WHERE Z59_UN = '"+cFilAnt+"'
LR003 += "    AND Z59_PERIOD = '"+MV_PAR01+"'
//LR003 += "    AND 1 = 2
LR003 += "    AND D_E_L_E_T_ = ' '
LR003 += "  ORDER BY Z59_EMPR
LRcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,LR003),'LR03',.T.,.T.)
dbSelectArea("LR03")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	wEmpr    := LR03->Z59_EMPR
	wPercent := LR03->Z59_PERCEN
	
	QL002 := " INSERT INTO Z48"+cEmpAnt+"0
	QL002 += " (Z48_FILIAL,
	QL002 += "  Z48_DATA  ,
	QL002 += "  Z48_LOTE  ,
	QL002 += "  Z48_SBLOTE,
	QL002 += "  Z48_DOC   ,
	QL002 += "  Z48_LINHA ,
	QL002 += "  Z48_DC    ,
	QL002 += "  Z48_DEBITO,
	QL002 += "  Z48_CREDIT,
	QL002 += "  Z48_VALOR ,
	QL002 += "  Z48_CLVLDB,
	QL002 += "  Z48_CLVLCR,
	QL002 += "  Z48_ITEMD ,
	QL002 += "  Z48_ITEMC ,
	QL002 += "  Z48_CCD   ,
	QL002 += "  Z48_CCC   ,
	QL002 += "  Z48_HIST  ,
	QL002 += "  Z48_ORIGEM,
	QL002 += "  Z48_TPSALD,
	QL002 += "  Z48_MOEDLC,
	QL002 += "  Z48_EMPORI,
	QL002 += "  Z48_FILORI,
	QL002 += "  Z48_ROTINA,
	QL002 += "  Z48_SEQLAN,
	QL002 += "  Z48_SI    ,
	QL002 += "  Z48_UN    ,
	QL002 += "  D_E_L_E_T_,
	QL002 += "  R_E_C_N_O_,
	QL002 += "  Z48_YDELTA)
	QL002 += " SELECT '"+cFilAnt+"' Z48_FILIAL,
	QL002 += "        Z48_DATA  ,
	QL002 += "        Z48_LOTE  ,
	QL002 += "        Z48_SBLOTE,
	QL002 += "        Z48_DOC   ,
	QL002 += "        Z48_LINHA ,
	QL002 += "        Z48_DC    ,
	QL002 += "        Z48_DEBITO,
	QL002 += "        Z48_CREDIT,
	QL002 += "        ROUND(( Z48_VALOR * "+Alltrim(Str(wPercent))+" / 100),2) Z48_VALOR,
	QL002 += "        Z48_CLVLDB,
	QL002 += "        Z48_CLVLCR,
	QL002 += "        Z48_ITEMD ,
	QL002 += "        Z48_ITEMC ,
	QL002 += "        Z48_CCD   ,
	QL002 += "        Z48_CCC   ,
	QL002 += "        Z48_HIST  ,
	QL002 += "        'LANCTO AJUSTE P/ DRE UN - EMPR: ' + '"+wEmpr+"' + ' Perc.: ' + '"+Transform(wPercent, "@E 9,999,999.99")+"' + ' Vlr Origem: ' + CONVERT(VARCHAR, CONVERT(NUMERIC(18,2), Z48_VALOR)) Z48_ORIGEM,
	QL002 += "        Z48_TPSALD,
	QL002 += "        Z48_MOEDLC,
	QL002 += "        Z48_EMPORI,
	QL002 += "        Z48_FILORI,
	QL002 += "        Z48_ROTINA,
	QL002 += "        Z48_SEQLAN,
	QL002 += "        Z48_SI    ,
	QL002 += "        Z48_UN    ,
	QL002 += "        D_E_L_E_T_,
	QL002 += "        (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM Z48"+cEmpAnt+"0) + ROW_NUMBER() OVER(ORDER BY Z48.R_E_C_N_O_) AS R_E_C_N_O_,
	QL002 += "        Convert(Char(10),convert(datetime, SYSDATETIME()),112) Z48_YDELTA
	QL002 += "   FROM Z48"+wEmpr+"0 Z48
	QL002 += "  WHERE D_E_L_E_T_ = ' '
	QL002 += "    AND Z48_DATA BETWEEN '"+wPerDe+"' AND '"+wPerAte+"'
	QL002 += "    AND NOT ( Z48_DEBITO LIKE '%611%' OR Z48_CREDIT LIKE '%611%' )
	
	U_BIAMsgRun("Aguarde... Consolidando Base... ",,{|| TcSQLExec(QL002)})
	
	dbSelectArea("LR03")
	dbSkip()
	
End
Ferase(LRcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(LRcIndex+OrdBagExt())          //indice gerado
LR03->(dbCloseArea())

//                                     Contabilização
*****************************************************
If !Empty(fgVetCtb)
	U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)
EndIf

dDataBase := dtRefEmi

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
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
aAdd(aRegs,{cPerg,"01","Período de referência  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
