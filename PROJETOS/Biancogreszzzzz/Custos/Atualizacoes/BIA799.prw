#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA799
@author Marcos Alberto Soprani
@since 04/06/14
@version 1.0
@description Contabilização do movimento ADICIONAR na preparação de esmalte
@obs Estoque e Custos
@type function
/*/

User Function BIA799()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hr
	Private dtRefEmi := dDataBase

	cHInicio := Time()
	fPerg := "BIA799"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA799 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA799 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA799",fPerg)

	xValidCt := .F.
	xMensErr := "Os seguintes documentos já estão contabilizados para esta operação: "
	CH003 := " SELECT CT2_DOC
	CH003 += "   FROM  "+RetSqlName("CT2")
	CH003 += "  WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
	CH003 += "    AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CH003 += "    AND ( CT2_ORIGEM LIKE '%66Y001%' OR CT2_ORIGEM LIKE '%66Y002%' )
	CH003 += "    AND D_E_L_E_T_ = ' '
	CH003 += "  GROUP BY CT2_DOC
	CHIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,CH003),'CH03',.T.,.T.)
	aStru1 := ("CH03")->(dbStruct())
	dbSelectArea("CH03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		xValidCt := .T.

		xMensErr += CH03->CT2_DOC+", "

		dbSelectArea("CH03")
		dbSkip()

	End

	xMensErr += " necessário excluir estes documentos antes de efetuar nova contabilização."

	CH03->(dbCloseArea())
	Ferase(CHIndex+GetDBExtension())
	Ferase(CHIndex+OrdBagExt())

	If xValidCt
		Aviso('BIA799', xMensErr, {'Ok'}, 3)
		Return
	EndIf

	UP003 := " UPDATE "+RetSqlName("SD3")+" SET D3_YRFCUST = 'ADC'
	UP003 += "   FROM "+RetSqlName("SD3")
	UP003 += "  WHERE D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	UP003 += "    AND D3_CF IN('DE4','RE4')
	UP003 += "    AND D3_COD < '2'
	UP003 += "    AND D3_TIPO NOT IN('PP', 'PA', 'MC', 'OI', 'PC', 'ME')
	UP003 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(UP003)

	fgLanPad := "66Y"
	fgLotCtb := "008840"
	fgVetCtb := {}
	fgPermDg := .F.

	JK009 := " SELECT CASE
	JK009 += "          WHEN D3_TM > '500' THEN ' '
	JK009 += "          ELSE D3_CONTA
	JK009 += "        END DEBITO,
	JK009 += "        CASE
	JK009 += "          WHEN D3_TM > '500' THEN D3_CONTA
	JK009 += "          ELSE ' '
	JK009 += "        END CREDIT,
	JK009 += "        D3_CLVL CLVL,
	JK009 += "        D3_ITEMCTA ITEMCTA,
	JK009 += "        D3_CUSTO1 CUSTO,
	JK009 += "        CASE
	JK009 += "          WHEN D3_TM > '500' THEN 'REQ P/ ADICIONAIS DOC '+D3_DOC
	JK009 += "          ELSE 'DEV P/ ADICIONAIS DOC '+D3_DOC+'/'+D3_NUMSEQ
	JK009 += "        END HIST,
	JK009 += "        D3_CC CCUSTO,
	JK009 += "        CASE
	JK009 += "          WHEN D3_TM > '500' THEN '66Y002 ' + Space(13) + Space(15) + Str(SD3.R_E_C_N_O_)
	JK009 += "          ELSE                    '66Y001 ' + Space(13) + Space(15) + Str(SD3.R_E_C_N_O_)
	JK009 += "        END ORIGEM,
	JK009 += " 	      D3_YAPLIC APLIC,
	JK009 += " 	      D3_YDRIVER DRIVER
	JK009 += "   FROM "+RetSqlName("SD3")+" SD3
	JK009 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	JK009 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	JK009 += "    AND D3_CF IN('DE4','RE4')
	JK009 += "    AND D3_TIPO NOT IN('PP','PA')
	JK009 += "    AND D3_YRFCUST = 'ADC'
	JK009 += "    AND (SELECT D3_CONTA
	JK009 += "           FROM "+RetSqlName("SD3")+" XD3
	JK009 += "          WHERE XD3.D3_FILIAL = '"+xFilial("SD3")+"'
	JK009 += "            AND XD3.D3_EMISSAO = SD3.D3_EMISSAO
	JK009 += "            AND XD3.D3_NUMSEQ = SD3.D3_NUMSEQ
	JK009 += "            AND XD3.D3_TM <> SD3.D3_TM
	JK009 += "            AND XD3.D_E_L_E_T_ = ' ') <> D3_CONTA
	JK009 += "    AND SD3.D_E_L_E_T_ = ' '
	JK009 += "  ORDER BY SD3.D3_NUMSEQ, D3_TM
	JKIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,JK009),'JK09',.T.,.T.)
	aStru1 := ("JK09")->(dbStruct())
	dbSelectArea("JK09")
	dbGoTop()
	ProcRegua(RecCount())
	cgCont := 0
	While !Eof()

		cgCont ++

		IncProc("Processando... " + Alltrim(Str(cgCont)))

		// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM
		Aadd(fgVetCtb, { JK09->DEBITO, JK09->CREDIT, JK09->CLVL, JK09->CLVL, JK09->ITEMCTA, JK09->ITEMCTA, JK09->CUSTO, JK09->HIST, JK09->CCUSTO, JK09->CCUSTO, JK09->ORIGEM, JK09->APLIC, JK09->DRIVER })

		dbSelectArea("JK09")
		dbSkip()

	End

	JK09->(dbCloseArea())
	Ferase(JKIndex+GetDBExtension())
	Ferase(JKIndex+OrdBagExt())

	U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

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
	aAdd(aRegs,{cPerg,"01","De Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
