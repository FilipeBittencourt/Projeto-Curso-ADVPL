#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA787
@author Marcos Alberto Soprani
@since 24/04/14
@version 1.0
@description Verificação das MOD's gravadas por D3_NUMSEQ
@type function
/*/

User Function BIA787()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi

	cHInicio := Time()
	fPerg := "BIA787"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA787",fPerg)

	// Grava XML
	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Checa MOD's"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "REFEREN"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TPPROD"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UNID"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"         ,3,2)

	xCampAdc := 10
	xrQtdCmp := xCampAdc
	axVetPro := {}
	axVetCab := {}
	axVetTot := {}
	BK004 := " SELECT SD3.D3_COD PRODUTO,
	BK004 += "        "+Alltrim(Str(xCampAdc))+" + ROW_NUMBER() OVER(ORDER BY SD3.D3_COD) SEQ
	BK004 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	BK004 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = '"+xFilial("SC2")+"'
	BK004 += "                       AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP,1,6)
	BK004 += "                       AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP,7,2)
	BK004 += "                       AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP,9,3)
	BK004 += "                       AND SC2.D_E_L_E_T_ = ' '
	BK004 += "  INNER JOIN "+RetSqlName("SB1")+" SB1SC2 WITH (NOLOCK) ON SB1SC2.B1_FILIAL = '"+xFilial("SB1")+"'
	BK004 += "                          AND SB1SC2.B1_COD = SC2.C2_PRODUTO
	BK004 += "                          AND SB1SC2.B1_TIPO = '"+MV_PAR03+"'
	BK004 += "                          AND SB1SC2.D_E_L_E_T_ = ' '
	BK004 += "  WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'
	BK004 += "    AND SD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	BK004 += "    AND SUBSTRING(SD3.D3_COD,1,3) = 'MOD'
	BK004 += "    AND SD3.D3_NUMSEQ <> '      '
	BK004 += "    AND SD3.D3_ESTORNO = ' '
	BK004 += "    AND SD3.D_E_L_E_T_ = ' '
	BK004 += "  GROUP BY SD3.D3_COD
	BK004 += "  ORDER BY SD3.D3_COD
	BKIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,BK004),'BK04',.T.,.T.)
	aStruX := ("BK04")->(dbStruct())
	gh_IndX := "PRODUTO"
	If !chkfile("BK05")
		BK05 := U_BIACrTMP(aStruX)
		dbUseArea( .T.,, BK05, "BK05", .F., .F. )
		dbCreateInd(BK05, gh_IndX,{ || gh_IndX })
	EndIf
	dbSelectArea("BK05")
	APPEND FROM ("BK04")
	If Select("BK04") > 0
		BK04->(dbCloseArea())
		Ferase(BKIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(BKIndex+OrdBagExt())          //indice gerado
	Endif
	dbSelectArea("BK05")
	dbGoTop()
	While !Eof()

		xrQtdCmp ++

		SB1->(dbSeek(xFilial("SB1")+BK05->PRODUTO))
		oExcel:AddColumn(nxPlan, nxTabl, Alltrim(SB1->B1_DESC)          ,1,1)

		dbSelectArea("BK05")
		dbSkip()

	End

	xrQtdCmp ++
	oExcel:AddColumn(nxPlan, nxTabl, "STATUS"        ,1,1)

	GR007 := " SELECT SC2.C2_PRODUTO PRODOP,
	GR007 += "        SD3.D3_CLVL CLVL,
	GR007 += "        D3_EMISSAO EMISSAO,
	GR007 += "        SB1SC2.B1_YFORMAT FORMATO,
	GR007 += "        D3_TM TM,
	GR007 += "        SD3.D3_NUMSEQ NUMSEQ,
	GR007 += "        SD3.D3_TIPO TPPROD,
	GR007 += "        SD3.D3_COD PRODUTO,
	GR007 += "        SUBSTRING(SB1SD3.B1_DESC,1,50) DESCR,
	GR007 += "        SD3.D3_UM UNID,
	GR007 += "        SD3.D3_QUANT QUANT
	GR007 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	GR007 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = '"+xFilial("SC2")+"'
	GR007 += "                       AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP,1,6)
	GR007 += "                       AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP,7,2)
	GR007 += "                       AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP,9,3)
	If !Empty(MV_PAR04)
		GR007 += "                       AND SC2.C2_PRODUTO = '"+MV_PAR04+"'
	EndIf
	GR007 += "                       AND SC2.D_E_L_E_T_ = ' '
	GR007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1SD3 WITH (NOLOCK) ON SB1SD3.B1_FILIAL = '"+xFilial("SB1")+"'
	GR007 += "                          AND SB1SD3.B1_COD = SD3.D3_COD
	GR007 += "                          AND SB1SD3.D_E_L_E_T_ = ' '
	GR007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1SC2 WITH (NOLOCK) ON SB1SC2.B1_FILIAL = '"+xFilial("SB1")+"'
	GR007 += "                          AND SB1SC2.B1_COD = SC2.C2_PRODUTO
	GR007 += "                          AND SB1SC2.B1_TIPO = '"+MV_PAR03+"'
	GR007 += "                          AND SB1SC2.D_E_L_E_T_ = ' '
	GR007 += "  WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'
	GR007 += "    AND SD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	GR007 += "    AND ( SD3.D3_TM = '010' OR SUBSTRING(SD3.D3_COD,1,3) = 'MOD' )
	GR007 += "    AND SD3.D3_NUMSEQ <> '      '
	GR007 += "    AND SD3.D3_ESTORNO = ' '
	GR007 += "    AND SD3.D_E_L_E_T_ = ' '
	GR007 += "  ORDER BY SC2.C2_PRODUTO,
	GR007 += "           SD3.D3_NUMSEQ,
	GR007 += "           SD3.D3_TM,
	GR007 += "           SD3.D3_COD
	GRIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GR007),'GR07',.T.,.T.)
	dbSelectArea("GR07")
	dbGoTop()
	ProcRegua(RecCount())
	kkjjCont := 0
	kItmCont := 0
	While !Eof()

		kkjjCont ++
		IncProc("Proc... " + GR07->PRODUTO + " " + Alltrim(Str(kkjjCont)))

		hyProdt := GR07->PRODOP

		Aadd( axVetTot, Array(xrQtdCmp) )
		axVetTot[Len(axVetTot)][1] := ""
		axVetTot[Len(axVetTot)][2] := ""
		axVetTot[Len(axVetTot)][3] := "TOTAIS"
		axVetTot[Len(axVetTot)][4] := GR07->FORMATO
		axVetTot[Len(axVetTot)][5] := Substr(GR07->PRODUTO,1,7)
		axVetTot[Len(axVetTot)][6] := GR07->TPPROD
		axVetTot[Len(axVetTot)][7] := GR07->PRODUTO
		axVetTot[Len(axVetTot)][8] := GR07->DESCR
		axVetTot[Len(axVetTot)][9] := GR07->UNID
		axVetTot[Len(axVetTot)][10] := 0

		gyPrimeiro := 0
		gySomaMods := 0
		gyColunaCt := 0
		gyBaseVerf := 0
		While !Eof() .and. GR07->PRODOP == hyProdt

			hyNumsq := GR07->NUMSEQ

			Aadd( axVetPro, Array(xrQtdCmp) )
			axVetPro[Len(axVetPro)][1] := GR07->CLVL
			axVetPro[Len(axVetPro)][2] := dtoc(stod(GR07->EMISSAO))
			axVetPro[Len(axVetPro)][3] := GR07->NUMSEQ
			axVetPro[Len(axVetPro)][4] := GR07->FORMATO
			axVetPro[Len(axVetPro)][5] := Substr(GR07->PRODUTO,1,7)
			axVetPro[Len(axVetPro)][6] := GR07->TPPROD
			axVetPro[Len(axVetPro)][7] := GR07->PRODUTO
			axVetPro[Len(axVetPro)][8] := GR07->DESCR
			axVetPro[Len(axVetPro)][9] := GR07->UNID
			axVetPro[Len(axVetPro)][10] := GR07->QUANT

			While !Eof() .and. GR07->PRODOP == hyProdt .and. GR07->NUMSEQ == hyNumsq

				kItmCont ++
				IncProc("Proc... " + hyProdt + " " + Alltrim(Str(kkjjCont)) + " " + Alltrim(Str(kItmCont)) )

				dbSelectArea("BK05")
				If dbSeek(GR07->PRODUTO)
					axVetPro[Len(axVetPro)][BK05->SEQ] := "X"
				EndIf

				dbSelectArea("GR07")
				dbSkip()

			End

			For hhi := 1 to xrQtdCmp
				If ValType(axVetPro[Len(axVetPro)][hhi]) == "C"
					If axVetPro[Len(axVetPro)][hhi] == "X"
						If axVetTot[Len(axVetTot)][hhi] == nil
							gyBaseVerf ++
							If gyColunaCt == 0
								gyColunaCt := hhi
							EndIf
							axVetTot[Len(axVetTot)][hhi] := 1
						Else
							axVetTot[Len(axVetTot)][hhi] += 1
						EndIf
						If gyColunaCt == hhi
							gyPrimeiro ++
						EndIf
						gySomaMods ++
					EndIf
				EndIf
			Next hhi

			oExcel:AddRow(nxPlan, nxTabl, axVetPro[Len(axVetPro)] )

		End

		gyStatus := ""
		If gySomaMods / gyBaseVerf == gyPrimeiro .and. gyPrimeiro <> 0
			gyStatus := "Ok"
		Else
			gyStatus := "Verificar"
		EndIf
		axVetTot[Len(axVetTot)][xrQtdCmp] := gyStatus

		oExcel:AddRow(nxPlan, nxTabl, axVetTot[Len(axVetTot)] )
		axVetTot := {}

	End

	GR07->(dbCloseArea())
	Ferase(GRIndex+GetDBExtension())
	Ferase(GRIndex+OrdBagExt())

	BK05->(dbCloseArea())
	Ferase(BK05+GetDBExtension())
	Ferase(BK05+OrdBagExt())

	xArqTemp := "checamods - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)+" - "+MV_PAR03

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
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Tipo de Produto     ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"04","Produto Especifico   ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

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
