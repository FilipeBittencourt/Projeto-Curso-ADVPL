#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA784
@author Marcos Alberto Soprani
@since 20/03/14
@version 1.0
@description Complementação da Baixa Automática
@obs ...
@type function
/*/

User Function BIA784()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	cHInicio := Time()
	fPerg := "BIA784"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_YULMES") .or. MV_PAR02 <= GetMV("MV_YULMES") ) .and. 1 = 2
		Aviso('Data de Fechamento!!!', 'Favor verificar o intervalo de datas informado, pois as movimentações de estoque estão bloqueadas para este período!!!.',{'Ok'})
		Return
	EndIf
	
	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA784",fPerg)
	
	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Baixa em batch conforme identificado ausência durante o processo automático"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Emissão"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Documento"    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "C.Custo"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Clvl"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NumSeq"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NumOP"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ProdutoOP"    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DescPrdOP"    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QtdProd"      ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Insumo"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descrição"    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QtdEmpOri"    ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QtdOriOP"     ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Total"        ,3,2)

	KY005 := " SELECT D3_EMISSAO,
	KY005 += "        D3_DOC,
	KY005 += "        D3_CC,
	KY005 += "        D4_TRT,
	KY005 += "        D3_CLVL,
	KY005 += "        D3_OP,
	KY005 += "        D3_NUMSEQ,
	KY005 += "        D3_IDENT,
	KY005 += "        D3_QUANT,
	KY005 += "        D4_COD,
	KY005 += "        D4_LOCAL,
	KY005 += "        SUBSTRING(SB1.B1_DESC,1,50) DESCRIC,
	KY005 += "        ROUND(D3_QUANT * D4_QTDEORI / C2_QUANT,8) TOTAL,
	KY005 += "        C2_PRODUTO,
	KY005 += "        SUBSTRING(XB1.B1_DESC,1,50) DESCPRDOP,
	KY005 += "        C2_QUANT,
	KY005 += "        D4_QTDEORI
	KY005 += "   FROM "+RetSqlName("SD4")+" SD4
	KY005 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"'
	KY005 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6)
	KY005 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2)
	KY005 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3)
	KY005 += "                       AND SC2.D_E_L_E_T_ = ' '
	KY005 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
	KY005 += "                       AND SB1.B1_COD = D4_COD
	KY005 += "                       AND SB1.B1_TIPO NOT IN('PA')
	KY005 += "                       AND SB1.D_E_L_E_T_ = ' '
	KY005 += "  INNER JOIN "+RetSqlName("SD3")+" SD3 ON D3_FILIAL = '"+xFilial("SD3")+"'
	KY005 += "                       AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KY005 += "                       AND D3_OP = D4_OP
	KY005 += "                       AND D3_TM = '010'
	If !Empty(MV_PAR05)
		KY005 += "                       AND D3_TIPO = '"+MV_PAR05+"'
	EndIf
	If !Empty(MV_PAR03)
		KY005 += "                       AND D3_NUMSEQ = '"+MV_PAR03+"'
	EndIf
	If !Empty(MV_PAR04)
		KY005 += "                       AND D3_OP = '"+MV_PAR04+"'
	EndIf
	KY005 += "                       AND D3_ESTORNO = ' '
	KY005 += "                       AND SD3.D_E_L_E_T_ = ' '
	KY005 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
	KY005 += "                       AND XB1.B1_COD = D3_COD
	KY005 += "                       AND XB1.D_E_L_E_T_ = ' '
	KY005 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
	KY005 += "    AND (SELECT COUNT(*)
	KY005 += "           FROM "+RetSqlName("SD3")+" XXD3
	KY005 += "          WHERE XXD3.D3_EMISSAO = SD3.D3_EMISSAO
	KY005 += "            AND XXD3.D3_OP = SD4.D4_OP
	KY005 += "            AND XXD3.D3_COD = SD4.D4_COD
	KY005 += "            AND XXD3.D3_NUMSEQ = SD3.D3_NUMSEQ
	KY005 += "            AND XXD3.D3_TM <> '010'
	KY005 += "            AND XXD3.D3_ESTORNO = ' '
	KY005 += "            AND XXD3.D_E_L_E_T_ = ' ') = 0
	KY005 += "    AND SD4.D_E_L_E_T_ = ' '
	KY005 += "  ORDER BY D3_NUMSEQ, D4_COD
	KYIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KY005),'KY05',.T.,.T.)
	dbSelectArea("KY05")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("NumOP: "+Alltrim(KY05->D3_OP)+" ... Prod: "+Alltrim(KY05->D4_COD))

		gtRetGrpB1 := Posicione("SB1", 1, xFilial("SB1") + KY05->D4_COD, "B1_GRUPO")

		jh_Quant := 0

		// Ajuste efetuado para atender a OS effettivo 4368-16
		If gtRetGrpB1 == "104B"

			SF002 := " SELECT COUNT(*) CONTAD
			SF002 += "   FROM " + RetSqlName("Z18")
			SF002 += "  WHERE Z18_FILIAL = '"+xFilial("Z18")+"'
			SF002 += "    AND Z18_DOCSD3 = '"+KY05->D3_DOC+"'
			SF002 += "    AND Z18_DATA = '"+KY05->D3_EMISSAO+"'
			SF002 += "    AND D_E_L_E_T_ = ' '
			SFIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,SF002),'SF02',.T.,.T.)
			dbSelectArea("SF02")
			dbGoTop()
			jh_Quant := SF02->CONTAD
			SF02->(dbCloseArea())
			Ferase(SFIndex+GetDBExtension())
			Ferase(SFIndex+OrdBagExt())
			If jh_Quant == 0
				dbSelectArea("KY05")
				Loop
			EndIf

		ElseIf KY05->TOTAL <> 1 .and. Substr(KY05->D4_COD,1,3) == "104"
			jh_Quant := Round(KY05->TOTAL,0)
		Else
			jh_Quant := KY05->TOTAL
		EndIf

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+KY05->D4_COD))

		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2")+KY05->D4_COD+KY05->D4_LOCAL))

		If SB2->B2_QATU >= jh_Quant .and. MV_PAR06 == 2

			RecLock("SD3",.T.)
			SD3->D3_FILIAL   := xFilial("SD3")
			SD3->D3_CF       := "RE1"
			SD3->D3_NUMSEQ   := KY05->D3_NUMSEQ
			SD3->D3_IDENT    := KY05->D3_IDENT
			SD3->D3_TM       := "999"
			SD3->D3_OP       := KY05->D3_OP
			SD3->D3_COD      := KY05->D4_COD
			SD3->D3_QUANT    := jh_Quant
			SD3->D3_QTSEGUM  := ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2)
			SD3->D3_UM       := SB1->B1_UM
			SD3->D3_SEGUM    := SB1->B1_SEGUM
			SD3->D3_LOCAL    := KY05->D4_LOCAL
			SD3->D3_TRT      := KY05->D4_TRT
			SD3->D3_CC       := KY05->D3_CC
			SD3->D3_CLVL     := KY05->D3_CLVL
			SD3->D3_CONTA    := SB1->B1_YCTRIND
			SD3->D3_TIPO     := SB1->B1_TIPO
			SD3->D3_GRUPO    := SB1->B1_GRUPO
			SD3->D3_EMISSAO  := stod(KY05->D3_EMISSAO)
			SD3->D3_DOC      := KY05->D3_DOC
			SD3->D3_USUARIO  := cUserName
			SD3->D3_YOBS     := "Baixa em batch conforme identificado ausencia durante o processo automático"
			SD3->D3_YRFCUST  := "BIA784"
			MsUnlock()

			aSaldos := CalcEst(KY05->D4_COD, KY05->D4_LOCAL, DATE()+1)
			ghQuant := aSaldos[1]
			ghCusto := aSaldos[2]

			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2") + KY05->D4_COD + KY05->D4_LOCAL)
				RecLock("SB2",.F.)
				SB2->B2_QATU     := ghQuant
				SB2->B2_QTSEGUM  := ConvUM(KY05->D4_COD, ghQuant, 0, 2)
				SB2->B2_VATU1    := ghCusto
				SB2->B2_CM1      := SB2->B2_VATU1 / SB2->B2_QATU
				MsUnLock()
			EndIf

		Else

			oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(KY05->D3_EMISSAO)), KY05->D3_DOC, KY05->D3_CC, KY05->D3_CLVL, KY05->D3_NUMSEQ, KY05->D3_OP, KY05->C2_PRODUTO, KY05->DESCPRDOP, KY05->D3_QUANT, KY05->D4_COD, KY05->DESCRIC, KY05->D4_QTDEORI, KY05->C2_QUANT, KY05->TOTAL	})

		EndIf

		dbSelectArea("KY05")
		dbSkip()

	End

	KY05->(dbCloseArea())
	Ferase(KYIndex+GetDBExtension())
	Ferase(KYIndex+OrdBagExt())

	xArqTemp := "bx-batch" + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "-" + StrZero(Year(MV_PAR02) ,4) + "-" + Alltrim(SM0->M0_NOME)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf
	
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
	aAdd(aRegs,{cPerg,"03","NumSeq Avulso          ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Numero da OP           ?","","","mv_ch4","C",13,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Tipo Produto PAI       ?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"06","Ação                   ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Conferir","","","","","Conferir/Atualizar","","","","","","","","","","","","","","","","","","",""})

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
