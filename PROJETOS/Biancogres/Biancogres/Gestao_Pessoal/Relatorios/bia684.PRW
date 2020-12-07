#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA684
@description Horas Extras Intrajornadas
@author Marcos Alberto Soprani
@since 10/06/16
@version undefined
@type function
/*/

User Function BIA684()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA684"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	HyEnter := CHR(13)+CHR(10)

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Horas Extras Intrajornada"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "STATSPON"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMPR    "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SUPER   "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MATRIC  "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME    "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL    "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCLVL   "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATARF  "          ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "EVENTO  "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DEVENTO "          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "HORAS   "          ,3,2)

	DC007 := " SELECT 'FECHADO' STATSPON,                                                                          "
	DC007 += "        '"+cEmpAnt+"' EMPR,                                                                          "
	DC007 += "        RA_YSEMAIL,                                                                                  "
	DC007 += "        PH_MAT,                                                                                      "
	DC007 += "        RA_NOME,                                                                                     "
	DC007 += "        RA_CLVL,                                                                                     "
	DC007 += "        CTH_DESC01 DCLVL,                                                                            "
	DC007 += "        PH_DATA,                                                                                     "
	DC007 += "        PH_PD EVENTO,                                                                                "
	DC007 += "        P9_DESC DEVENTO,                                                                             "
	DC007 += "        PH_QUANTC HORAS                                                                              "
	DC007 += "   FROM " + RetSqlName("SPH") + " SPH                                                                "
	DC007 += "  INNER JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = '"+xFilial("SRA")+"'                       "
	DC007 += "                       AND RA_MAT = PH_MAT                                                           "
	DC007 += "                       AND SRA.D_E_L_E_T_ = ' '                                                      "
	DC007 += "  INNER JOIN " + RetSqlName("CTH") + " CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'                      "
	DC007 += "                       AND CTH_CLVL = RA_CLVL                                                        "
	DC007 += "                       AND CTH.D_E_L_E_T_ = ' '                                                      "
	DC007 += "  INNER JOIN " + RetSqlName("SP9") + " SP9 ON P9_FILIAL = '"+xFilial("SP9")+"'                       "
	DC007 += "                       AND P9_CODIGO = PH_PD                                                         "
	DC007 += "                       AND SP9.D_E_L_E_T_ = ' '                                                      "
	DC007 += "  WHERE PH_FILIAL = '"+xFilial("SPH")+"'                                                             "
	DC007 += "    AND PH_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'                                "
	DC007 += "    AND PH_PD IN('128','110','139','117','132','150','111', '118', '119', '123', '128', '130', '131', '133', '134', '139', '140', '141', '142', '150', '151', '152')                                                "
	DC007 += "    AND SPH.D_E_L_E_T_ = ' '                                                                         "
	DC007 += "  UNION ALL                                                                                          "
	DC007 += " SELECT 'ABERTO' STATSPON,                                                                           "
	DC007 += "        '"+cEmpAnt+"' EMPR,                                                                          "
	DC007 += "        RA_YSEMAIL,                                                                                  "
	DC007 += "        PC_MAT,                                                                                      "
	DC007 += "        RA_NOME,                                                                                     "
	DC007 += "        RA_CLVL,                                                                                     "
	DC007 += "        CTH_DESC01 DCLVL,                                                                            "
	DC007 += "        PC_DATA,                                                                                     "
	DC007 += "        PC_PD EVENTO,                                                                                "
	DC007 += "        P9_DESC DEVENTO,                                                                             "
	DC007 += "        PC_QUANTC HORAS                                                                              "
	DC007 += "   FROM " + RetSqlName("SPC") + " SPC                                                                "
	DC007 += "  INNER JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = '"+xFilial("SRA")+"'                       "
	DC007 += "                       AND RA_MAT = PC_MAT                                                           "
	DC007 += "                       AND SRA.D_E_L_E_T_ = ' '                                                      "
	DC007 += "  INNER JOIN " + RetSqlName("CTH") + " CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'                      "
	DC007 += "                       AND CTH_CLVL = RA_CLVL                                                        "
	DC007 += "                       AND CTH.D_E_L_E_T_ = ' '                                                      "
	DC007 += "  INNER JOIN " + RetSqlName("SP9") + " SP9 ON P9_FILIAL = '"+xFilial("SP9")+"'                       "
	DC007 += "                       AND P9_CODIGO = PC_PD                                                         "
	DC007 += "                       AND SP9.D_E_L_E_T_ = ' '                                                      "
	DC007 += "  WHERE PC_FILIAL = '"+xFilial("SPC")+"'                                                             "
	DC007 += "    AND PC_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'                                "
	DC007 += "    AND PC_PD IN('128','110','139','117','132','150','111', '118', '119', '123', '128', '130', '131', '133', '134', '139', '140', '141', '142', '150', '151', '152')                                                "
	DC007 += "    AND SPC.D_E_L_E_T_ = ' '                                                                         "
	DC007 += "  ORDER BY 1, 2, 3, 4                                                                                "
	DCcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,DC007),'DC07',.F.,.T.)
	dbSelectArea("DC07")
	dbGoTop()
	ProcRegua(RecCount())
	ckContad := 0
	While !Eof()

		ckContad ++
		IncProc("Processamento1.     " + Alltrim(Str(ckContad)))
		IncProc("Processamento1..    " + Alltrim(Str(ckContad)))
		IncProc("Processamento1...   " + Alltrim(Str(ckContad)))
		IncProc("Processamento1....  " + Alltrim(Str(ckContad)))

		oExcel:AddRow(nxPlan, nxTabl, { DC07->STATSPON    ,;
		DC07->EMPR                                        ,;
		DC07->RA_YSEMAIL                                  ,;
		DC07->PH_MAT                                      ,;
		DC07->RA_NOME                                     ,;
		DC07->RA_CLVL                                     ,;
		DC07->DCLVL                                       ,;
		stod(DC07->PH_DATA)                               ,;
		DC07->EVENTO                                      ,;
		DC07->DEVENTO                                     ,;
		DC07->HORAS                                       })

		dbSelectArea("DC07")
		dbSkip()

	End

	DC07->(dbCloseArea())
	Ferase(DCcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(DCcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "horas-intrajornadas - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
