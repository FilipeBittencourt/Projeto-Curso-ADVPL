#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA790
@author Marcos Alberto Soprani
@since 08/05/14
@version 1.0
@description Gera Devolução / Requisição Valorizada para valorizar as movi-
.            tações de PA resultado de beneficiamento próprio a partir das
.            requisições de encerramento de lote - TM 517
@type function
/*/

User Function BIA790()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local vf

	cHInicio := Time()
	fPerg := "BIA790"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA790 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA790 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA790",fPerg)

	zlTotCusQbr := 0
	kkTotssCts  := 0
	//*******************************************************************************************************************
	// Em 07/04/17... a partir deste ponto rateio de retifica/polimento
	zlCusQbr := 0
	ZL001 := " SELECT SUM(D3_CUSTO1) CUSTO1
	ZL001 += "    FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	ZL001 += "   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	ZL001 += "     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	ZL001 += "     AND D3_TM IN('517')
	ZL001 += "     AND SUBSTRING(D3_COD,1,2) = 'C1'
	ZL001 += "     AND D3_ESTORNO = ' '
	ZL001 += "     AND SD3.D_E_L_E_T_ = ' '
	ZLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZL001),'ZL01',.T.,.T.)
	dbSelectArea("ZL01")
	dbGoTop()
	zlCusQbr    := ZL01->CUSTO1
	zlTotCusQbr += ZL01->CUSTO1
	ZL01->(dbCloseArea())
	Ferase(ZLIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZLIndex+OrdBagExt())          //indice gerado

	zlTotProd := 0
	LZ005 := " SELECT SUM(D3_QUANT) M2TOT
	LZ005 += "    FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	LZ005 += "   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	LZ005 += "     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	LZ005 += "     AND SUBSTRING(D3_COD,1,2) IN('B9', 'BO', 'C6')
	LZ005 += "     AND D3_TM = '010'
	LZ005 += "     AND D3_TIPO = 'PA'
	LZ005 += "     AND D3_ESTORNO = ' '
	LZ005 += "     AND SD3.D_E_L_E_T_ = ' '
	LZIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,LZ005),'LZ05',.T.,.T.)
	dbSelectArea("LZ05")
	dbGoTop()
	zlTotProd := LZ05->M2TOT
	LZ05->(dbCloseArea())
	Ferase(ZLIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZLIndex+OrdBagExt())          //indice gerado

	TQ007 := " SELECT D3_COD,
	TQ007 += "        D3_EMISSAO D3EMISS,
	TQ007 += "        D3_LOCAL D3LOCAL,
	TQ007 += "        D3_CLVL CLVL,
	TQ007 += "        SUM(D3_QUANT) M2IND
	TQ007 += "    FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	TQ007 += "   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	TQ007 += "     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TQ007 += "     AND SUBSTRING(D3_COD,1,2) IN('B9', 'BO', 'C6')
	TQ007 += "     AND D3_TM = '010'
	TQ007 += "     AND D3_TIPO = 'PA'
	TQ007 += "     AND D3_ESTORNO = ' '
	TQ007 += "     AND SD3.D_E_L_E_T_ = ' '
	TQ007 += "   GROUP BY D3_COD,
	TQ007 += "            D3_EMISSAO,
	TQ007 += "            D3_LOCAL,
	TQ007 += "            D3_CLVL
	TQIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TQ007),'TQ07',.T.,.T.)
	dbSelectArea("TQ07")
	dbGoTop()
	kkjjCont := 0
	kkssCts  := 0
	While !Eof()

		kkjjCont ++
		IncProc("Proc... " + TQ07->D3_COD + " " + Alltrim(Str(kkjjCont)))

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+TQ07->D3_COD))

		jhCusto := TQ07->M2IND / zlTotProd * zlCusQbr

		If zlCusQbr > 0
			kk_TM := "352"
			kk_CF := "DE6"
		Else
			kk_TM := "852"
			kk_CF := "RE6"
		EndIf

		RecLock("SD3",.T.)
		SD3->D3_FILIAL   := xFilial("SD3")
		SD3->D3_TM       := kk_TM
		SD3->D3_COD      := TQ07->D3_COD
		SD3->D3_UM       := SB1->B1_UM
		SD3->D3_LOCAL    := TQ07->D3LOCAL
		SD3->D3_CC       := "3000"
		SD3->D3_CLVL     := TQ07->CLVL
		SD3->D3_CONTA    := SB1->B1_CONTA
		SD3->D3_TIPO     := SB1->B1_TIPO
		SD3->D3_GRUPO    := SB1->B1_GRUPO
		SD3->D3_CUSTO1   := Round(ABS(jhCusto),2)
		SD3->D3_EMISSAO  := stod(TQ07->D3EMISS)
		SD3->D3_DOC      := "DEVVAL517"
		SD3->D3_USUARIO  := cUserName
		SD3->D3_CF       := kk_CF
		SD3->D3_NUMSEQ   := ProxNum()
		SD3->D3_CHAVE    := "E0"
		SD3->D3_YOBS     := "Devolução valorizada referente requisição de saldo físico de produto semi-classificado para retífica própria. Valor Original rateado "+Alltrim(Str(zlCusQbr))
		SD3->D3_YRFCUST  := "BIA790"
		MsUnlock()
		kkssCts    += SD3->D3_CUSTO1
		kkTotssCts += SD3->D3_CUSTO1

		dbSelectArea("TQ07")
		dbSkip()

	End

	TQ07->(dbCloseArea())
	Ferase(TQIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TQIndex+OrdBagExt())          //indice gerado

	//*******************************************************************************************************************
	// Em 07/04/17... a partir deste ponto rateio de RODAPÉ
	zlCusQbr := 0
	ZL001 := " SELECT SUM(D3_CUSTO1) CUSTO1
	ZL001 += "    FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	ZL001 += "   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	ZL001 += "     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	ZL001 += "     AND D3_TM IN('517')
	ZL001 += "     AND SUBSTRING(D3_COD,1,2) <> 'C1'
	ZL001 += "     AND D3_ESTORNO = ' '
	ZL001 += "     AND SD3.D_E_L_E_T_ = ' '
	ZLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZL001),'ZL01',.T.,.T.)
	dbSelectArea("ZL01")
	dbGoTop()
	zlCusQbr    := ZL01->CUSTO1
	zlTotCusQbr += ZL01->CUSTO1
	ZL01->(dbCloseArea())
	Ferase(ZLIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZLIndex+OrdBagExt())          //indice gerado

	zlTotProd := 0
	LZ005 := " SELECT SUM(D3_QUANT) M2TOT
	LZ005 += "    FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	LZ005 += "   INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'
	LZ005 += "                        AND B1_COD = D3_COD
	LZ005 += "                        AND B1_YTPPROD = 'RP'
	LZ005 += "                        AND SB1.D_E_L_E_T_ = ' '
	LZ005 += "   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	LZ005 += "     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	LZ005 += "     AND D3_TM = '010'
	LZ005 += "     AND D3_TIPO = 'PA'
	LZ005 += "     AND D3_ESTORNO = ' '
	LZ005 += "     AND SD3.D_E_L_E_T_ = ' '
	LZIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,LZ005),'LZ05',.T.,.T.)
	dbSelectArea("LZ05")
	dbGoTop()
	zlTotProd := LZ05->M2TOT
	LZ05->(dbCloseArea())
	Ferase(ZLIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZLIndex+OrdBagExt())          //indice gerado

	TQ007 := " SELECT D3_COD,
	TQ007 += "        D3_EMISSAO D3EMISS,
	TQ007 += "        D3_LOCAL D3LOCAL,
	TQ007 += "        D3_CLVL CLVL,
	TQ007 += "        SUM(D3_QUANT) M2IND
	TQ007 += "    FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	TQ007 += "   INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'
	TQ007 += "                        AND B1_COD = D3_COD
	TQ007 += "                        AND B1_YTPPROD = 'RP'
	TQ007 += "                        AND SB1.D_E_L_E_T_ = ' '
	TQ007 += "   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	TQ007 += "     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TQ007 += "     AND D3_TM = '010'
	TQ007 += "     AND D3_TIPO = 'PA'
	TQ007 += "     AND D3_ESTORNO = ' '
	TQ007 += "     AND SD3.D_E_L_E_T_ = ' '
	TQ007 += "   GROUP BY D3_COD,
	TQ007 += "            D3_EMISSAO,
	TQ007 += "            D3_LOCAL,
	TQ007 += "            D3_CLVL
	TQIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TQ007),'TQ07',.T.,.T.)
	dbSelectArea("TQ07")
	dbGoTop()
	kkjjCont := 0
	kkssCts  := 0
	While !Eof()

		kkjjCont ++
		IncProc("Proc... " + TQ07->D3_COD + " " + Alltrim(Str(kkjjCont)))

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+TQ07->D3_COD))

		jhCusto := TQ07->M2IND / zlTotProd * zlCusQbr

		If zlCusQbr > 0
			kk_TM := "352"
			kk_CF := "DE6"
		Else
			kk_TM := "852"
			kk_CF := "RE6"
		EndIf

		RecLock("SD3",.T.)
		SD3->D3_FILIAL   := xFilial("SD3")
		SD3->D3_TM       := kk_TM
		SD3->D3_COD      := TQ07->D3_COD
		SD3->D3_UM       := SB1->B1_UM
		SD3->D3_LOCAL    := TQ07->D3LOCAL
		SD3->D3_CC       := "3000"
		SD3->D3_CLVL     := TQ07->CLVL
		SD3->D3_CONTA    := SB1->B1_CONTA
		SD3->D3_TIPO     := SB1->B1_TIPO
		SD3->D3_GRUPO    := SB1->B1_GRUPO
		SD3->D3_CUSTO1   := Round(ABS(jhCusto),2)
		SD3->D3_EMISSAO  := stod(TQ07->D3EMISS)
		SD3->D3_DOC      := "DEVVAL517"
		SD3->D3_USUARIO  := cUserName
		SD3->D3_CF       := kk_CF
		SD3->D3_NUMSEQ   := ProxNum()
		SD3->D3_CHAVE    := "E0"
		SD3->D3_YOBS     := "Devolução valorizada referente requisição de saldo físico de produto semi-classificado para retífica própria. Valor Original rateado "+Alltrim(Str(zlCusQbr))
		SD3->D3_YRFCUST  := "BIA790"
		MsUnlock()
		kkssCts    += SD3->D3_CUSTO1
		kkTotssCts += SD3->D3_CUSTO1

		dbSelectArea("TQ07")
		dbSkip()

	End

	TQ07->(dbCloseArea())
	Ferase(TQIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TQIndex+OrdBagExt())          //indice gerado

	// ******************************************* Verificação dos Rateios **********************************************************
	fwRestRest := zlTotCusQbr - kkTotssCts

	MsgINFO("Diferença final após processamento de devolução valorizada: " + Alltrim(Str(fwRestRest)) + CHR(13) + CHR(13) + "Se a diferença ainda for grande, necessário verificar. Fim do Processamento!!!" )
	// ******************************************************************************************************************************

	// Grava XML
	oExcel := FWMSEXCEL():New()

	// *******************************************************************************************************
	// Lançamento das quebras
	nxPlan := "Planilha 01"
	nxTabl := "Verificar gravação - relação de quebras de placa no processo de Ind. Própria: " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO1"       ,3,2)

	PL008 := " SELECT D3_EMISSAO EMISSAO,
	PL008 += "        D3_TM TM,
	PL008 += "        D3_COD PRODUTO,
	PL008 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	PL008 += "        D3_DOC DOC,
	PL008 += "        D3_CUSTO1 CUSTO1
	PL008 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	PL008 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	PL008 += "                       AND B1_COD = D3_COD
	PL008 += "                       AND SB1.D_E_L_E_T_ = ' '
	PL008 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	PL008 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	PL008 += "    AND D3_TM IN('517')
	PL008 += "    AND D3_ESTORNO = ' '
	PL008 += "    AND SD3.D_E_L_E_T_ = ' '
	PLcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,PL008),'PL08',.F.,.T.)
	dbSelectArea("PL08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(PL08->EMISSAO)), PL08->TM, PL08->PRODUTO, PL08->DESCR, PL08->DOC, PL08->CUSTO1 })

		dbSelectArea("PL08")
		dbSkip()

	End

	PL08->(dbCloseArea())
	Ferase(PLcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(PLcIndex+OrdBagExt())          //indice gerado

	// *******************************************************************************************************
	// Apropriação das quebras
	nxPlan := "Planilha 02"
	nxTabl := "Verificar gravação - devolução valorizada referente quebras de placas no processo de Ind. Própria: " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO1"       ,3,2)

	PL008 := " SELECT D3_EMISSAO EMISSAO,
	PL008 += "        D3_TM TM,
	PL008 += "        D3_COD PRODUTO,
	PL008 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	PL008 += "        D3_DOC DOC,
	PL008 += "        D3_CUSTO1 CUSTO1
	PL008 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	PL008 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	PL008 += "                       AND B1_COD = D3_COD
	PL008 += "                       AND SB1.D_E_L_E_T_ = ' '
	PL008 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	PL008 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	PL008 += "    AND D3_YRFCUST = 'BIA790'
	PL008 += "    AND D3_ESTORNO = ' '
	PL008 += "    AND SD3.D_E_L_E_T_ = ' '
	PLcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,PL008),'PL08',.F.,.T.)
	dbSelectArea("PL08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(PL08->EMISSAO)), PL08->TM, PL08->PRODUTO, PL08->DESCR, PL08->DOC, PL08->CUSTO1 })

		dbSelectArea("PL08")
		dbSkip()

	End

	PL08->(dbCloseArea())
	Ferase(PLcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(PLcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "devvalquebraplaca - " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "-" + StrZero(Year(MV_PAR02) ,4) + "-" + Substr(SM0->M0_NOME,1,2)

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
	aAdd(aRegs,{cPerg,"01","De Data              ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
