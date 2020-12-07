#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA554
@author Marcos Alberto Soprani
@since 24/02/16
@version 1.0
@description Contabilização para encontro de contas de custo do consumo de
.            de MP para produção de PI (Esmalte e MASSA) que ora transitam
.            dentro das contas de Ativo mas que prejudicam a visualização
.            do custo por conta de custo dentro do GMCD - Orçado vs Real
@type function
/*/

User Function BIA554()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hr
	Private dtRefEmi := dDataBase

	cHInicio := Time()
	fPerg := "BIA554"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	If 1 = 2
		If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
			MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA554 - Data de Fechamento!!!")
			Return
		EndIf

		If dDataBase <> GetMV("MV_YULMES")
			MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA554 - Data de Fechamento!!!")
			Return
		EndIf
	Endif

	xValidCt := .F.
	xMensErr := "Os seguintes documentos já estão contabilizados para esta operação: "
	CH003 := " SELECT CT2_DOC
	CH003 += "   FROM  "+RetSqlName("CT2")
	CH003 += "  WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
	CH003 += "    AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CH003 += "    AND CT2_ORIGEM LIKE '%66W001%'
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
		Aviso('BIA554', xMensErr, {'Ok'}, 3)
		Return
	EndIf

	fgLanPad := "66W"
	fgLotCtb := "008840"
	fgVetCtb := {}
	fgPermDg := .F.

	EF004 := " SELECT SB1.B1_YCTRIND DEBITO, "
	EF004 += "        XB1.B1_YCTRIND CREDIT, "
	EF004 += "        D3_CLVL CLVL, "
	EF004 += "        D3_ITEMCTA ITEMCTA, "
	EF004 += "        ROUND(SUM(D3_CUSTO1),2) CUSTO, "
	EF004 += "        'REQ MAT.PRIMA P/ PROD.INTERMEDIARIO MES' HIST, "
	EF004 += "        D3_CC CCUSTO, "
	EF004 += "        '66W001 ' + SPACE(13) + Space(15) + SPACE(10) ORIGEM, "
	EF004 += "        D3_YAPLIC APLIC, "
	EF004 += "        D3_YDRIVER DRIVER "
	EF004 += "   FROM "+RetSqlName("SD3")+" SD3 "
	EF004 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	EF004 += "                       AND SB1.B1_COD = D3_COD "
	EF004 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	EF004 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"' "
	EF004 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
	EF004 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
	EF004 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
	EF004 += "                       AND SC2.D_E_L_E_T_ = ' ' "
	EF004 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 ON XB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	EF004 += "                       AND XB1.B1_COD = C2_PRODUTO "
	EF004 += "                       AND XB1.B1_CONTA = D3_CONTA "
	EF004 += "                       AND XB1.D_E_L_E_T_ = ' ' "
	EF004 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	EF004 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	EF004 += "    AND D3_TM = '999' "
	EF004 += "    AND D3_CONTA < '6' "
	EF004 += "    AND D3_TIPO = 'MP' "
	EF004 += "    AND SB1.B1_YCTRIND <> XB1.B1_YCTRIND "
	EF004 += "    AND SD3.D_E_L_E_T_ = ' ' "
	EF004 += "  GROUP BY SB1.B1_YCTRIND, "
	EF004 += "           XB1.B1_YCTRIND, "
	EF004 += "           D3_CLVL, "
	EF004 += "           D3_ITEMCTA, "
	EF004 += "           D3_CC, "
	EF004 += "           D3_YAPLIC, "
	EF004 += "           D3_YDRIVER "
	EFIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,EF004),'EF04',.T.,.T.)
	aStru1 := ("EF04")->(dbStruct())
	dbSelectArea("EF04")
	dbGoTop()
	ProcRegua(RecCount())
	cgCont := 0
	While !Eof()

		cgCont ++

		IncProc("Processando... " + Alltrim(Str(cgCont)))

		// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM
		Aadd(fgVetCtb, { EF04->DEBITO, EF04->CREDIT, EF04->CLVL, EF04->CLVL, EF04->ITEMCTA, EF04->ITEMCTA, EF04->CUSTO, EF04->HIST, EF04->CCUSTO, EF04->CCUSTO, EF04->ORIGEM, EF04->APLIC, EF04->DRIVER })

		dbSelectArea("EF04")
		dbSkip()

	End

	EF04->(dbCloseArea())
	Ferase(EFIndex+GetDBExtension())
	Ferase(EFIndex+OrdBagExt())

	U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

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
