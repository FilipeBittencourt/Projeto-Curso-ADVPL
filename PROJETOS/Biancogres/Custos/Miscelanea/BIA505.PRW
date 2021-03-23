#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'

/*/{Protheus.doc} BIA505
@author Marcos Alberto Soprani
@since 22/08/14
@version 1.0
@description Quantidade referente para unitário do realizado no PAC
@type function
/*/

/*/{Protheus.doc} BIA505
@author Artur Antunes
@since 19/04/17
@version 1.1
@description Inclusão de controle de processamento via SX6 (MV_YULRAC) 
@obs OS 2304-16
@type function
/*/

User Function BIA505()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	cHInicio := Time()
	fPerg := "BIA505"

	xdDeData  := ctod("  /  /  ")
	xdAteData := ctod("  /  /  ")
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf
	MV_PAR01 := xdDeData
	MV_PAR02 := xdAteData

	If !cEmpAnt $ "01/06"
		MsgSTOP("Empresa não configurada para cálculo da RAC Realizada!!!")
		Return
	Endif

	If !U_BiaULRAC(MV_PAR01)
		Return
	EndIf

	ProcRegua(1000)
	IncProc("Preparando dados...")
	Sleep(5000)

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP003 := " UPDATE " + RetSqlName("SD3") + " SET D3_YQTDPAC = 0
	ZP003 += "   FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	ZP003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	ZP003 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	ZP003 += "    AND D_E_L_E_T_ = ' '
	U_BIAMsgRun("Aguarde... Zerando QTD RAC nas movimentações internas",,{|| TCSQLExec(ZP003)})

	//                                         Atualiza quantidade RAC (inicialmente PAC) quanto a OPs
	**************************************************************************************************
	ZP007 := " SELECT D3_EMISSAO,
	ZP007 += "        C2_PRODUTO,
	ZP007 += "        D3_NUMSEQ,
	ZP007 += "        D3_YITCUS,
	ZP007 += "        SUM(D3_CUSTO1) CUSTO1,
	ZP007 += "        COUNT(*) CONTAD,
	ZP007 += "        SUM(D3_QUANT) QUANT,
	ZP007 += "        MIN(SD3.R_E_C_N_O_) REGSD3
	ZP007 += "   FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	ZP007 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 WITH (NOLOCK) ON C2_FILIAL = '" + xFilial("SC2") + "'
	ZP007 += "                                     AND C2_NUM = SUBSTRING(D3_OP,1,6)
	ZP007 += "                                     AND C2_ITEM = SUBSTRING(D3_OP,7,2)
	ZP007 += "                                     AND C2_SEQUEN = SUBSTRING(D3_OP,9,3)
	ZP007 += "                                     AND SC2.D_E_L_E_T_ = ' '
	ZP007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'
	ZP007 += "                                     AND B1_COD = C2_PRODUTO
	If cEmpAnt $ "01"
		ZP007 += "                                     AND B1_TIPO IN('PP','PA','PS')
	ElseIf cEmpAnt == "06"
		ZP007 += "                                     AND B1_TIPO IN('MP','PI','PA')
	EndIf
	ZP007 += "                                     AND SB1.D_E_L_E_T_ = ' '
	ZP007 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	ZP007 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	ZP007 += "    AND SD3.D_E_L_E_T_ = ' '
	ZP007 += "  GROUP BY D3_EMISSAO,
	ZP007 += "           C2_PRODUTO,
	ZP007 += "           D3_NUMSEQ,
	ZP007 += "           D3_YITCUS
	ZP007 += "  ORDER BY C2_PRODUTO,
	ZP007 += "           D3_NUMSEQ,
	ZP007 += "           D3_YITCUS
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP007),'ZP07',.T.,.T.)
	dbSelectArea("ZP07")
	dbGoTop()
	x1Contad := 1
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Gravando... " + Alltrim(ZP07->C2_PRODUTO) + " " + ZP07->D3_NUMSEQ + " " + ZP07->D3_YITCUS + " " + Alltrim(Str(x1Contad)))

		x1CodProd := ZP07->C2_PRODUTO
		x1NumSeq  := ZP07->D3_NUMSEQ
		x1QtdPac  := 0
		If ZP07->D3_YITCUS == "001"
			x1QtdPac := ZP07->QUANT
		EndIf

		While !Eof() .and. ZP07->C2_PRODUTO == x1CodProd .and. ZP07->D3_NUMSEQ == x1NumSeq

			x1Contad ++

			dbSelectArea("SD3")
			dbGoTo(ZP07->REGSD3)
			RecLock("SD3",.F.)
			SD3->D3_YQTDPAC = x1QtdPac
			MsUnLock()

			dbSelectArea("ZP07")
			dbSkip()

		End

		dbSelectArea("ZP07")

	End

	ZP07->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())
	Ferase(ZPcIndex+OrdBagExt())

	ProcRegua(1000)
	IncProc("Preparando dados...")

	//                        Atualiza quantidade RAC (inicialmente PAC) quanto a Movimento Valorizado
	**************************************************************************************************
	ZP004 := " SELECT SUBSTRING(D3_EMISSAO,1,6) EMISSAO,
	ZP004 += "        D3_COD,
	ZP004 += "        D3_YITCUS,
	ZP004 += "        SUM(D3_CUSTO1) CUSTO1,
	ZP004 += "        COUNT(*) CONTAD,
	ZP004 += "        (SELECT SUM(ZSD3.D3_QUANT)
	ZP004 += "           FROM " + RetSqlName("SD3") + " ZSD3 WITH (NOLOCK)
	ZP004 += "          WHERE ZSD3.D3_FILIAL = '" + xFilial("SD3") + "'
	ZP004 += "            AND SUBSTRING(ZSD3.D3_EMISSAO,1,6) = SUBSTRING(SD3.D3_EMISSAO,1,6)
	ZP004 += "            AND ZSD3.D3_COD = SD3.D3_COD
	ZP004 += "            AND ZSD3.D3_TM = '010'
	ZP004 += "            AND ZSD3.D_E_L_E_T_ = ' ') QUANT,
	ZP004 += "        MIN(SD3.R_E_C_N_O_) REGSD3
	ZP004 += "   FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	ZP004 += "  INNER JOIN " + RetSqlName("SF5") + " SF5 WITH (NOLOCK)  ON F5_FILIAL = '" + xFilial("SF5") + "'
	ZP004 += "                       AND F5_CODIGO = D3_TM
	ZP004 += "                       AND F5_VAL = 'S'
	ZP004 += "                       AND F5_QTDZERO <> '2'
	ZP004 += "                       AND SF5.D_E_L_E_T_ = ' '
	ZP004 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	ZP004 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	If cEmpAnt $ "01"
		ZP004 += "    AND D3_TIPO IN('PP','PA','PS')
	ElseIf cEmpAnt == "06"
		ZP004 += "    AND D3_TIPO IN('MP','PI','PA')
	EndIf
	ZP004 += "    AND RTRIM(D3_YRFCUST) NOT IN('BIA705','MANUAL')
	ZP004 += "    AND SD3.D_E_L_E_T_ = ' '
	ZP004 += "  GROUP BY SUBSTRING(D3_EMISSAO,1,6),
	ZP004 += "           D3_COD,
	ZP004 += "           D3_YITCUS
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP004),'ZP04',.T.,.T.)
	dbSelectArea("ZP04")
	dbGoTop()
	x1Contad := 1
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Gravando... " + Alltrim(ZP04->D3_COD) + " " + ZP04->D3_YITCUS + " " + Alltrim(Str(x1Contad)))

		x1CodProd := ZP04->D3_COD
		x1QtdPac  := ZP04->QUANT

		While !Eof() .and. ZP04->D3_COD == x1CodProd

			x1Contad ++

			dbSelectArea("SD3")
			dbGoTo(ZP04->REGSD3)
			RecLock("SD3",.F.)
			SD3->D3_YQTDPAC = x1QtdPac
			MsUnLock()

			dbSelectArea("ZP04")
			dbSkip()

		End

		dbSelectArea("ZP04")

	End

	ZP04->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())
	Ferase(ZPcIndex+OrdBagExt())

	Aviso('BIA505','Fim do SEGUNDO Processamento...',{'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fPergHotB ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 12/12/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergHotB()

	Local bProcOk  := .T.
	Local aPergs 	:= {}
	Local cLoad	    := fPerg + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	xdDeData        := ctod("  /  /  ")
	xdAteData       := ctod("  /  /  ")

	aAdd( aPergs ,{1,"De Data:"                      ,xdDeData    ,,"NAOVAZIO()",,'.T.',015,.F.})	
	aAdd( aPergs ,{1,"Até Data:"                     ,xdAteData   ,,"NAOVAZIO()",,'.T.',015,.F.})	

	If ParamBox(aPergs ,"Parâmetros",,,,,,,,cLoad,.T.,.T.)      
		xdDeData    := ParamLoad(cFileName,,1,xdDeData)
		xdAteData   := ParamLoad(cFileName,,2,xdAteData)
	Else
		bProcOk := .F.
	Endif

Return ( bProcOk ) 
