#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA712
@author Marcos Alberto Soprani
@since 10/02/14
@version 1.0
@description Valorização das MOD's
@obs Em 06/03/17... Ajuste na linha R09
@type function
/*/

User Function BIA712()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local xrEnter   := CHR(13) + CHR(10)

	cHInicio := Time()
	fPerg := "BIA712"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA712 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA712 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA712",fPerg)

	kjDtINI := MV_PAR01
	kjDtFIM := MV_PAR02

	aVetSB2 := { {"PERIODO"  , "C", 06, 0},;
	{             "TIPO" 	 , "C", 15, 0},;
	{             "QUANT" 	 , "N", 18, 8},;
	{             "VALOR" 	 , "N", 18, 8} }
	T001 := CriaTrab(aVetSB2,.T.)
	cInd := CriaTrab(Nil,.F.)
	dbUseArea(.T.,,T001,"T001",.F.,.F.)
	IndRegua("T001",cInd,"PERIODO+TIPO",,,"Selecionando registros...")

	aDados2 := {}

	JK007 := " UPDATE " + RetSqlName("SB2")
	JK007 += "    SET B2_CM1 = 0,
	JK007 += "        B2_CMFIM1 = 0
	JK007 += "  WHERE B2_FILIAL = '"+xFilial("SB2")+"'
	JK007 += "    AND SUBSTRING(B2_COD,1,3) = 'MOD'
	JK007 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(JK007)

	msKernelCt := U_BIA185( kjDtINI, kjDtFIM )
	msNomeTMP  := "##TMPBIA712" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	msMontaSql := msKernelCt + "SELECT * INTO " + msNomeTMP + " FROM TABFINAL "
	U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(msMontaSql)})

	GT009 := Alltrim(" SELECT '"+Substr(dtos(kjDtINI),1,6)+"' PERIODO,                                               ") + xrEnter
	GT009 += Alltrim("        SUBSTRING(MODS, 1, 15) TIPO,                                                           ") + xrEnter
	GT009 += Alltrim("        CONTRAP,                                                                               ") + xrEnter
	GT009 += Alltrim("        REGRAC,                                                                                ") + xrEnter
	GT009 += Alltrim("        SUM(VALOR) VALOR,                                                                      ") + xrEnter
	GT009 += Alltrim("        ISNULL((SELECT SUM(D3_QUANT)                                                           ") + xrEnter
	GT009 += Alltrim("                  FROM " + RetSqlName("SD3") + " (NOLOCK)                                      ") + xrEnter
	GT009 += Alltrim("                 WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                        ") + xrEnter
	GT009 += Alltrim("                   AND D3_EMISSAO BETWEEN '"+dtos(kjDtINI)+"' AND '"+dtos(kjDtFIM)+"'          ") + xrEnter
	GT009 += Alltrim("                   AND D3_COD = MODS                                                           ") + xrEnter
	GT009 += Alltrim("                   AND D3_TM >= '500'                                                          ") + xrEnter
	GT009 += Alltrim("                   AND D3_ESTORNO = ' '                                                        ") + xrEnter
	GT009 += Alltrim("                   AND D_E_L_E_T_ = ' '), 0) + ISNULL((SELECT SUM(D3_QUANT)*(-1)               ") + xrEnter
	GT009 += Alltrim("                                                         FROM " + RetSqlName("SD3") + " (NOLOCK)                                 ") + xrEnter
	GT009 += Alltrim("                                                        WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                   ") + xrEnter
	GT009 += Alltrim("                                                          AND D3_EMISSAO BETWEEN '"+dtos(kjDtINI)+"' AND '"+dtos(kjDtFIM)+"'     ") + xrEnter
	GT009 += Alltrim("                                                          AND D3_COD = MODS                    ") + xrEnter
	GT009 += Alltrim("                                                          AND D3_TM < '500'                    ") + xrEnter
	GT009 += Alltrim("                                                          AND D3_ESTORNO = ' '                 ") + xrEnter
	GT009 += Alltrim("                                                          AND D_E_L_E_T_ = ' '), 0) QUANT      ") + xrEnter
	GT009 += Alltrim(" FROM " + msNomeTMP + "                                                                        ") + xrEnter
	GT009 += Alltrim(" WHERE RTRIM(MODS) <> 'DIRETA'                                                                 ") + xrEnter
	GT009 += Alltrim(" GROUP BY MODS,                                                                                ") + xrEnter
	GT009 += Alltrim("          CONTRAP,                                                                             ") + xrEnter
	GT009 += Alltrim("          REGRAC                                                                               ") + xrEnter
	GT009 += Alltrim(" HAVING SUM(VALOR) <> 0                                                                        ") + xrEnter
	GT009 += Alltrim(" ORDER BY MODS                                                                                 ") + xrEnter
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GT009),'GT09',.T.,.T.)
	aStru1 := ("GT09")->(dbStruct())
	dbSelectArea("GT09")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		IncProc("Primeiro Processamento")
		dbSelectArea("T001")
		If !dbSeek(GT09->PERIODO+GT09->TIPO)
			RecLock("T001",.T.)
			T001->PERIODO := GT09->PERIODO
			T001->TIPO    := GT09->TIPO
		Else
			RecLock("T001",.F.)
		EndIf
		T001->QUANT += GT09->QUANT
		T001->VALOR += GT09->VALOR
		MsUnLock()
		dbSelectArea("GT09")
		dbSkip()
	End
	GT09->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())
	Ferase(cIndex+OrdBagExt())

	kj_GrvCustM := MsgYESNO("Deseja atualiza o Custo de MÃO-de-OBRA???")

	If kj_GrvCustM
		dbSelectArea("T001")
		dbGoTop()
		While !Eof()
			If Month(MV_PAR01) == Month(MV_PAR02) .and. Year(MV_PAR01) == Year(MV_PAR02)
				If MV_PAR01 > GetMv("MV_ULMES")
					kj_Cod := T001->TIPO
					If T001->QUANT > 0
						EX001 := " UPDATE " + RetSqlName("SB2")
						EX001 += "    SET B2_CM1 = "+Alltrim(Str(Round(T001->VALOR/T001->QUANT,4)))+","
						EX001 += "        B2_CMFIM1 = "+Alltrim(Str(Round(T001->VALOR/T001->QUANT,4)))
						EX001 += "  WHERE B2_FILIAL = '"+xFilial("SB2")+"'
						EX001 += "    AND B2_COD = '"+kj_Cod+"'
						EX001 += "    AND D_E_L_E_T_ = ' '
						TCSQLEXEC(EX001)
					EndIf
				Else
					MsgSTOP("Não será possível prosseguir por está fora do período de fechamento de estoque.", "BIA700")
					T001->(dbCloseArea())
					Return
				EndIf
			EndIf
			aAdd(aDados2, {T001->PERIODO,;
			T001->TIPO,;
			Transform(T001->QUANT, "@E 999,999,999.99999999"),;
			Transform(T001->VALOR, "@E 999,999,999.99999999")} )
			dbSelectArea("T001")
			dbSkip()
		End
	EndIf
	T001->(dbCloseArea())

	U_BIAxExcel(aDados2,aVetSB2, "BIA712"+strzero(seconds()%3500,5) )

	oLogProc:LogFimProc()

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
	aAdd(aRegs,{cPerg,"01","Da Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
