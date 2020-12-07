#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA687
@author Marcos Alberto Soprani
@since 04/08/16
@version 1.0
@description Relação dos valores de PIS para distinção pela Area de Livre Comercio
@obs OS: 2820-16 - Tania
@type function
/*/

User Function BIA687()

	fPerg  := "BIA687"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	xfrALC := FormatIn(Alltrim(MV_PAR04),"/")
	xfrZFM := FormatIn(Alltrim(MV_PAR05),"/")

	Processa({|| BIA687PRC() })

Return

Static Function BIA687PRC()

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha01"
	nxTabl := "ZONA FRANCA - " + Alltrim(SM0->M0_NOME)+ " - de " + dtoc(MV_PAR02) + " até " + dtoc(MV_PAR03) 

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO      "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC          "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SERIE        "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEM         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR        "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TES          "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CSTPIS       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CFOP         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLIENTE      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOJA         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SUFRAMA      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESTADO       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CODMUN       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MUNIC        "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "AREA         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VALOR        "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ICMSSOL      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCZFC      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "BASEPIS      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PISZFC       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "COFZFC       "               ,3,2)

	LZ001 := " SELECT D2_EMISSAO EMISSAO,
	LZ001 += "        D2_DOC DOC,
	LZ001 += "        D2_SERIE SERIE,
	LZ001 += "        D2_ITEM ITEM,
	LZ001 += "        D2_COD PRODUTO,
	LZ001 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	LZ001 += "        D2_TES TES,
	LZ001 += "        F4_CSTPIS CSTPIS,
	LZ001 += "        D2_CF CFOP,
	LZ001 += "        D2_CLIENTE CLIENTE,
	LZ001 += "        D2_LOJA LOJA,
	LZ001 += "        A1_NOME NOME,
	LZ001 += "        A1_SUFRAMA SUFRAMA,
	LZ001 += "        A1_EST ESTADO,
	LZ001 += "        A1_COD_MUN CODMUN,
	LZ001 += "        CC2_MUN MUNIC,
	LZ001 += "        CASE
	LZ001 += "          WHEN A1_COD_MUN IN "+xfrALC+" THEN 'AREA DE LIVRE COMERCIO'
	LZ001 += "          WHEN A1_COD_MUN IN "+xfrZFM+" THEN 'ZONA FRANCA'
	LZ001 += "          ELSE 'INDEFINIDO'
	LZ001 += "        END AREA,
	LZ001 += "        D2_TOTAL VALOR,
	LZ001 += "        D2_ICMSRET ICMSSOL,
	LZ001 += "        D2_DESCZFR DESCZFC,
	LZ001 += "        D2_BASIMP6 BASEPIS,
	LZ001 += "        D2_DESCZFP PISZFC,
	LZ001 += "        D2_DESCZFC COFZFC
	LZ001 += "   FROM " + RetSqlName("SD2") + " SD2
	LZ001 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'
	LZ001 += "                       AND B1_COD = D2_COD
	LZ001 += "                       AND SB1.D_E_L_E_T_ = ' '
	LZ001 += "  INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "'
	LZ001 += "                       AND A1_COD = D2_CLIENTE
	LZ001 += "                       AND A1_LOJA = D2_LOJA
	LZ001 += "                       AND A1_SUFRAMA <> ''
	LZ001 += "                       AND SA1.D_E_L_E_T_ = ' '
	LZ001 += "  INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '" + xFilial("SF4") + "'
	LZ001 += "                       AND F4_CODIGO = D2_TES
	LZ001 += "                       AND F4_CSTPIS = '06'
	LZ001 += "                       AND SF4.D_E_L_E_T_ = ' '
	LZ001 += "  INNER JOIN " + RetSqlName("CC2") + " CC2 ON CC2_FILIAL = '" + xFilial("CC2") + "'
	LZ001 += "                       AND CC2_EST = A1_EST
	LZ001 += "                       AND CC2_CODMUN = A1_COD_MUN
	LZ001 += "                       AND CC2.D_E_L_E_T_ = ' '
	LZ001 += "  WHERE D2_FILIAL = '" + xFilial("SD2") + "'
	LZ001 += "    AND D2_EMISSAO BETWEEN '" + dtos(MV_PAR02) + "' AND '" + dtos(MV_PAR03) + "'
	LZ001 += "    AND D2_DESCZFR <> 0
	LZ001 += "    AND SD2.D_E_L_E_T_ = ' '
	LZ001 += "  ORDER BY 1, 2, 3
	LZcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,LZ001),'LZ01',.F.,.T.)
	dbSelectArea("LZ01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { stod(LZ01->EMISSAO)   ,;
		LZ01->DOC                                             ,;
		LZ01->SERIE                                           ,;
		LZ01->ITEM                                            ,;
		LZ01->PRODUTO                                         ,;
		LZ01->DESCR                                           ,;
		LZ01->TES                                             ,;
		LZ01->CSTPIS                                          ,;
		LZ01->CFOP                                            ,;
		LZ01->CLIENTE                                         ,;
		LZ01->LOJA                                            ,;
		LZ01->NOME                                            ,;
		LZ01->SUFRAMA                                         ,;
		LZ01->ESTADO                                          ,;
		LZ01->CODMUN                                          ,;
		LZ01->MUNIC                                           ,;
		LZ01->AREA                                            ,;
		LZ01->VALOR                                           ,;
		LZ01->ICMSSOL                                         ,;
		LZ01->DESCZFC                                         ,;
		LZ01->BASEPIS                                         ,;
		LZ01->PISZFC                                          ,;
		LZ01->COFZFC                                          })

		dbSelectArea("LZ01")
		dbSkip()

	End

	LZ01->(dbCloseArea())
	Ferase(LZcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(LZcIndex+OrdBagExt())          //indice gerado

	xArqTemp := IIF(Empty(MV_PAR01), "BIA687", Alltrim(MV_PAR01) )

	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
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

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 04/08/16 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Nome do Arquivo:      ?","","","mv_ch1","C",20,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","De Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ate Data              ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Cód Município ALC (/) ?","","","mv_ch4","C",80,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Cód Município ZFM (/) ?","","","mv_ch5","C",80,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
