#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA433
@author Wanisay William
@since 13/02/08
@version 1.0
@description Acerto dos saldos finais
@type function
/*/

User Function BIA433()

	Private xExistB9 := .F.

	cHInicio := Time()
	fPerg    := "BIA433"
	fTamX1   := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If MV_PAR01 <= GetMV("MV_ULMES")
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA433 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA433 - Data de Fechamento!!!")
		Return
	EndIf

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"

	fCabec   := "Produtos com quantidade zero e valor diferente de zero. "
	fCabec2  := ""
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

	fImpCabec()

	// Incluido em 02/04/13 para tratamento da geração da planilha mesmo nao estando fechado o mes em questão. Por Marcos Alberto Soprani
	G7B01 := " SELECT COUNT(*) CONTAD
	G7B01 += "   FROM " + RetSqlName("SB9")
	G7B01 += "  WHERE B9_FILIAL = '"+xFilial("SB9")+"'
	G7B01 += "    AND B9_DATA = '"+dtos(MV_PAR01)+"'
	G7B01 += "    AND D_E_L_E_T_ = ' '
	G7B01 := ChangeQuery(G7B01)
	cIndex := CriaTrab(Nil,.f.)
	If chkfile("G7B1")
		dbSelectArea("G7B1")
		dbCloseArea()
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,G7B01),'G7B1',.T.,.T.)
	dbSelectArea("G7B1")
	dbGoTop()
	If G7B1->CONTAD > 0
		xExistB9 := .T.
	EndIf
	G7B1->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado

	If xExistB9
		A001 := " SELECT B9_COD, B9_LOCAL, B9_DATA, B9_QINI, B9_VINI1, B1_DESC, B1_TIPO, B1_GRUPO "
		A001 += "   FROM "+RetSqlName("SB9")+" SB9, "+RetSqlName("SB1")+" SB1 "
		A001 += "  WHERE B9_FILIAL = '"+xFilial("SB9")+"' "
		A001 += "    AND B9_DATA = '"+dtos(MV_PAR01)+"'"
		// Em 04/01/13 durante o fechamento de estoque e dezembro de 2012 foi necessário implementar o tratamento "B9_VINI1 <> 0"  antes era assim "B9_VINI1 > 0". Por Marcos Alberto Soprani
		A001 += "    AND B9_QINI = 0 "
		A001 += "    AND B9_VINI1 <> 0 "
		If !cEmpAnt $ "07/13"
			A001 += "    AND B9_COD <= '6' "
		EndIf
		A001 += "    AND B9_COD = B1_COD "
		A001 += "    AND SB9.D_E_L_E_T_ = ' ' "
		A001 += "    AND SB1.D_E_L_E_T_ = ' ' "
		A001 += " ORDER BY B9_COD "
	Else                           // Retirado por Marcos Alberto Soprani em 08/04/13 para atender a nova forma de fechamento de custo
		******************************************************************************************************************************
		A001 := " SELECT B2_COD B9_COD, "
		A001 += "        B2_LOCAL B9_LOCAL, "
		A001 += "        '        ' B9_DATA, "
		A001 += "        B2_QFIM B9_QINI, "
		A001 += "        B2_VFIM1 B9_VINI1, "
		A001 += "        B1_DESC, "
		A001 += "        B1_TIPO, "
		A001 += "        B1_GRUPO "
		A001 += "   FROM "+RetSqlName("SB2")+" SB2, "+RetSqlName("SB1")+" SB1 "
		A001 += "  WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
		// Em 04/11/15 foi necessário efetuar o tratamento de custo menor que zero restante em estoque. Por Marcos Alberto Soprani
		A001 += "    AND ( ( B2_QFIM = 0 AND B2_VFIM1 <> 0 ) OR (B2_VFIM1 < 0) )
		// Em 04/01/13 durante o fechamento de estoque e dezembro de 2012 foi necessário implementar o tratamento "B9_VINI1 <> 0"  antes era assim "B9_VINI1 > 0". Por Marcos Alberto Soprani
		//A001 += "    AND B2_QFIM = 0 "
		//A001 += "    AND B2_VFIM1 <> 0 "
		If !cEmpAnt $ "07/13"
			A001 += "    AND B2_COD <= '6' "
		EndIf
		A001 += "    AND B2_COD = B1_COD "
		A001 += "    AND SB2.D_E_L_E_T_ = ' ' "
		A001 += "    AND SB1.D_E_L_E_T_ = ' ' "
		A001 += " ORDER BY B2_COD "
	EndIf
	If chkfile("A001")
		DbSelectArea("A001")
		DbCloseArea()
	EndIf
	TcQuery A001 New Alias "A001"

	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())

	kp_Valor1 := 0

	While !Eof()
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Atualizando....    Tempo: "+cTempo)

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		xf_Item := +;
		Padr(A001->B9_COD                                                                            ,15)+"  "+;
		Padr(A001->B1_TIPO                                                                           ,02)+"  "+;
		Padr(A001->B1_GRUPO                                                                          ,04)+"  "+;
		Padr(A001->B1_DESC                                                                           ,40)+"  "+;
		Padl(Transform(A001->B9_QINI,  "@E 9,999,999.99")                                            ,12)+"  "+;
		Padl(Transform(A001->B9_VINI1, "@E 9,999,999.99")                                            ,12)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050

		kp_Valor1 += A001->B9_VINI1

		fGravaSD3()

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		DbSelectArea("A001")
		DbSkip()
	End

	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf

	xf_Item := +;
	Padr(""                                                                                      ,15)+"  "+;
	Padr(""                                                                                      ,02)+"  "+;
	Padr(""                                                                                      ,04)+"  "+;
	Padr("Total"                                                                                 ,40)+"  "+;
	Padl(""                                                                                      ,12)+"  "+;
	Padl(Transform(kp_Valor1, "@E 9,999,999.99")                                                 ,12)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050

	A001->(dbCloseArea())

	//Ajusta fechamento de estoque na tabela SBJ para registros com quantidade diferente de zero e sem numlote.
	cSql := ""
	cSql += "UPDATE "+RetSqlName("SBJ")+" "
	cSql += "   SET BJ_QINI = 0,  BJ_QISEGUM = 0 "
	cSql += " WHERE BJ_FILIAL = '"+xFilial("SBJ")+"' "
	cSql += "  AND BJ_DATA = '"+dtos(MV_PAR01)+"'"
	cSql += "  AND BJ_QINI <> 0 "
	cSql += "  AND BJ_NUMLOTE = ' ' "
	cSql += "  AND D_E_L_E_T_ = ' ' "
	TCSQLExec(cSql)

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fGravaSD3¦ Autor ¦ Wanisay WilliamS      ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGravaSD3()

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+A001->B9_COD)

	DbSelectArea("SD3")
	RecLock("SD3",.T.)
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_TM      := "514"
	SD3->D3_COD     := SB1->B1_COD
	SD3->D3_UM      := SB1->B1_UM
	SD3->D3_QUANT   := 0
	SD3->D3_QTSEGUM := 0
	SD3->D3_CF      := "RE6"
	SD3->D3_LOCAL   := A001->B9_LOCAL
	SD3->D3_DOC     := "INVENT"
	SD3->D3_NUMSEQ  := ProxNum()
	SD3->D3_EMISSAO := MV_PAR01
	SD3->D3_GRUPO   := SB1->B1_GRUPO
	SD3->D3_TIPO    := SB1->B1_TIPO
	SD3->D3_CHAVE   := "E0"
	SD3->D3_USUARIO := cUserName
	SD3->D3_SEGUM   := SB1->B1_SEGUM
	SD3->D3_CUSTO1  := A001->B9_VINI1
	SD3->D3_YROM    := "N"
	SD3->D3_YCHAVE  := ''
	SD3->D3_CONTA   := SB1->B1_YCTRIND                        // SB1->B1_YCTRADM - Substituido em 12/06/12 por Marcos Alberto em atendimento a OS Effettivo 1247-12
	SD3->D3_CC      := "3000"                                 // "1000"
	SD3->D3_CLVL    := IIF(cEmpAnt <> "05", "3110", "3200")   // "1000"
	MsUnLock()
	DbCommitAll()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aualiza saldo no SB2 e SB9  								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL,.F.)
		RecLock("SB2",.F.)
		SB2->B2_VFIM1  := 0
		SB2->B2_VFIM2  := 0
		SB2->B2_VFIM3  := 0
		SB2->B2_VFIM4  := 0
		SB2->B2_VFIM5  := 0
		MsUnlock()
	End

	DbSelectArea("SB9")
	DbSetOrder(1)
	If DbSeek(xFilial("SB9")+A001->B9_COD+A001->B9_LOCAL+DTOS(MV_PAR01),.F.)
		RecLock("SB9",.F.)
		SB9->B9_VINI1  := 0
		SB9->B9_VINI2  := 0
		SB9->B9_VINI3  := 0
		SB9->B9_VINI4  := 0
		SB9->B9_VINI5  := 0
		MsUnlock()
	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay WilliamS      ¦ Data ¦ 13.02.08 ¦¦¦
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
	nRow1 += 150

	xf_Titu := +;
	Padc("Produto"                    ,15)+"  "+;
	Padr("Tipo"                       ,02)+"  "+;
	Padr("Grupo"                      ,04)+"  "+;
	Padr("Descricao"                  ,40)+"  "+;
	Padr("Quantidade"                 ,12)+"  "+;
	Padl("Valor"                      ,12)

	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

	nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 010, 2300, 3550)
	oPrint:Say  (2300+30 , 010,"Prog.: BIA433"                                        ,oFont7)
	oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local j,i
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Data                   ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
