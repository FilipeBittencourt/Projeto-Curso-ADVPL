#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA764
@author Marcos Alberto Soprani
@since 10/03/14
@version 1.0
@description Consumo versus Produção
@type function
/*/

User Function BIA764()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi

	cHInicio := Time()
	fPerg := "BIA764"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA764",fPerg)

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Produção versus Consumo"

	FG004 := " SELECT SD3.D3_NUMSEQ NUMSEQ,
	FG004 += "        SD3.D3_OP NUMOP,
	FG004 += "        SC2.C2_REVISAO REVOP,
	FG004 += "        SB1.B1_YFORMAT FT,
	FG004 += "        SC2.C2_PRODUTO PROD_OP,
	FG004 += "        SUBSTRING(SB1.B1_DESC,1,50) DESC_PROD,
	FG004 += "        SC2.C2_QUANT QTD_OP,
	FG004 += "        SD3.D3_EMISSAO EMISSAO,
	FG004 += "        SD3.D3_TM TM,
	FG004 += "        SD3.D3_CF CF,
	FG004 += "        SD3.D3_COD COD_APON,
	FG004 += "        SUBSTRING(XB1.B1_DESC,1,50) DESC_COD,
	FG004 += "        SD3.D3_TIPO TP,
	FG004 += "        SD3.D3_GRUPO GP,
	FG004 += "        SD3.D3_QUANT QUANT,
	FG004 += "        XB1.B1_UM UNID,
	FG004 += "        SD3.D3_CUSTO1 CUSTO,
	FG004 += "        0 PONDERADO,
	FG004 += "        0 LINEAR,
	FG004 += "        (SELECT D3_QUANT
	FG004 += "           FROM "+RetSqlName("SD3")+" ZZD3 WITH (NOLOCK)
	FG004 += "          WHERE ZZD3.D3_FILIAL = '"+xFilial("SD3")+"'
	FG004 += "            AND ZZD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	FG004 += "            AND ZZD3.D3_NUMSEQ = SD3.D3_NUMSEQ
	FG004 += "            AND ZZD3.D3_TM = '010'
	FG004 += "            AND ZZD3.D_E_L_E_T_ = ' ') QTD_APON,
	FG004 += "        (SELECT SUM(D3_QUANT)
	FG004 += "           FROM "+RetSqlName("SD3")+" ZZD3 WITH (NOLOCK)
	FG004 += "          WHERE ZZD3.D3_FILIAL = '"+xFilial("SD3")+"'
	FG004 += "            AND ZZD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	FG004 += "            AND ZZD3.D3_COD = SC2.C2_PRODUTO
	FG004 += "            AND SUBSTRING(ZZD3.D3_EMISSAO,1,6) = SUBSTRING(SD3.D3_EMISSAO,1,6)
	FG004 += "            AND ZZD3.D3_TM = '010'
	FG004 += "            AND ZZD3.D_E_L_E_T_ = ' ') QTD_ACUM,
	FG004 += "        ISNULL((SELECT SUM(D4_QTDEORI)
	FG004 += "                  FROM "+RetSqlName("SD4")+" ZZD4 WITH (NOLOCK)
	FG004 += "                 WHERE ZZD4.D4_FILIAL = '"+xFilial("SD4")+"'
	FG004 += "                   AND ZZD4.D4_OP = SD3.D3_OP
	FG004 += "                   AND ZZD4.D4_COD = SD3.D3_COD
	FG004 += "                   AND ZZD4.D_E_L_E_T_ = ' '), 0) QTD_EMP,
	FG004 += "        0 MEDIO_BX,
	FG004 += "        0 MEDIO_EP,
	FG004 += "        ISNULL((SELECT SUM(G1_QUANT)
	FG004 += "                  FROM "+RetSqlName("SG1")+" ZZG1 WITH (NOLOCK)
	FG004 += "                 WHERE ZZG1.G1_FILIAL = '"+xFilial("SG1")+"'
	FG004 += "                   AND ZZG1.G1_COD = SC2.C2_PRODUTO
	FG004 += "                   AND ZZG1.G1_COMP = SD3.D3_COD
	FG004 += "                   AND ZZG1.G1_INI <= SD3.D3_EMISSAO
	FG004 += "                   AND ZZG1.G1_FIM >= SD3.D3_EMISSAO
	FG004 += "                   AND ZZG1.D_E_L_E_T_ = ' '), 0) QTD_ESTR,
	FG004 += "        SD3.D3_YRFCUST REFMOV,
	FG004 += "        SUBSTRING(SD3.D3_YOBS, 28, 16) PESO,
	FG004 += "        SUBSTRING(SD3.D3_YOBS, 49, 16) M2,
	FG004 += "        SUBSTRING(SD3.D3_YOBS, 74, 16) ESTRUT,
	FG004 += "        SD3.D3_LOTECTL LOTECTL
	FG004 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	FG004 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = '"+xFilial("SC2")+"'
	FG004 += "                       AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP,1,6)
	FG004 += "                       AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP,7,2)
	FG004 += "                       AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP,9,3)
	FG004 += "                       AND SC2.C2_PRODUTO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	FG004 += "                       AND SC2.D_E_L_E_T_ = ' '
	FG004 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
	FG004 += "                       AND SB1.B1_COD = SC2.C2_PRODUTO
	FG004 += "                       AND SB1.B1_TIPO = '"+MV_PAR03+"'
	FG004 += "                       AND SB1.D_E_L_E_T_ = ' '
	FG004 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 WITH (NOLOCK) ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
	FG004 += "                       AND XB1.B1_COD = SD3.D3_COD
	FG004 += "                       AND XB1.D_E_L_E_T_ = ' '
	FG004 += "  WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'
	FG004 += "    AND SD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	FG004 += "    AND SD3.D3_ESTORNO = ' '
	FG004 += "    AND SD3.D_E_L_E_T_ = ' '

	If MV_PAR06 == 1

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ"          ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NUMOP"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "REVOP"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "FT"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PROD_OP"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESC_PROD"       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "QTD_OP"          ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "TM"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CF"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "COD_APON"        ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESC_COD"        ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "TP"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "GP"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "UNID"            ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"           ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "PONDERADO"       ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "LINEAR"          ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "QTD_APON"        ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "QTD_EMP"         ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "MEDIO_BX"        ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "MEDIO_EP"        ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "QTD_ESTR"        ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "REFMOV"          ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PESO"            ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "M2"              ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "ESTRUT"          ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "LOTECTL"         ,1,1)

		FG004 += "  ORDER BY SD3.D3_OP, SD3.D3_NUMSEQ, SD3.D3_TM, SD3.D3_COD
		FGcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,FG004),'FG04',.F.,.T.)
		dbSelectArea("FG04")
		dbGoTop()
		ProcRegua(RecCount())
		xContad := 0
		While !Eof()

			xContad ++
			IncProc(Alltrim(Str(xContad)))

			xpPonderado := FG04->CUSTO / FG04->QTD_APON
			xpLinear    := FG04->CUSTO / FG04->QUANT
			xpMedioBx   := FG04->QUANT / FG04->QTD_APON
			xpMedioEp   := FG04->QTD_EMP / FG04->QTD_OP

			oExcel:AddRow(nxPlan, nxTabl, { FG04->NUMSEQ        ,;
			FG04->NUMOP                                         ,;
			FG04->REVOP                                         ,;
			FG04->FT                                            ,;
			FG04->PROD_OP                                       ,;
			FG04->DESC_PROD                                     ,;
			FG04->QTD_OP                                        ,;
			dtoc(stod(FG04->EMISSAO))                           ,;
			FG04->TM                                            ,;
			FG04->CF                                            ,;
			FG04->COD_APON                                      ,;
			FG04->DESC_COD                                      ,;
			FG04->TP                                            ,;
			FG04->GP                                            ,;
			FG04->QUANT                                         ,;
			FG04->UNID                                          ,;
			FG04->CUSTO                                         ,;
			xpPonderado                                         ,;
			xpLinear                                            ,;
			FG04->QTD_APON                                      ,;
			FG04->QTD_EMP                                       ,;
			Round(xpMedioBx,5)                                  ,;
			Round(xpMedioEp,5)                                  ,;
			Round(FG04->QTD_ESTR,5)                             ,;
			FG04->REFMOV                                        ,;
			FG04->PESO                                          ,;
			FG04->M2                                            ,;
			FG04->ESTRUT                                        ,;
			FG04->LOTECTL                                       })

			dbSelectArea("FG04")
			dbSkip()

		End

	Else

		xcTab := "\data\bkp_Marcos\igpm"
		dbUseArea(.T.,,xcTab+".dtc","REF1",.F.)
		dbCreateIndex(xcTab+".idx","ANO",{|| ANO })
		dbSelectArea("REF1")
		dbGoTop()

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "TPMOV"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PROD_OP"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESC_PROD"       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PERIODO"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "COD_APON"        ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESC_COD"        ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "TP"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "GP"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "QTDAPON"         ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "QTDAPONAGP"      ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"           ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "MEDIO_QTD"       ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "MEDIO_CST"       ,3,2)

		XX001 := " SELECT PROD_OP,
		XX001 += "        DESC_PROD,
		XX001 += "        SUBSTRING(EMISSAO,1,6) PERIODO,
		XX001 += "        COD_APON,
		XX001 += "        DESC_COD,
		XX001 += "        TP,
		XX001 += "        GP,
		XX001 += "        SUM(QTD_APON) QTDAPON,
		XX001 += "        QTD_ACUM QTDACUM,
		XX001 += "        SUM(QUANT) QUANT,
		XX001 += "        SUM(CUSTO) CUSTO,
		XX001 += "        SUM(QUANT) / SUM(QTD_APON) QTD_MEDIA,
		XX001 += "        SUM(CUSTO) / SUM(QTD_APON) CUSTO_MED
		XX001 += "   FROM (

		XX001 += FG004

		XX001 += "         ) AS TABLSINT
		XX001 += "   WHERE TM <> '010'
		XX001 += "     AND SUBSTRING(COD_APON,1,3) <> 'MOD'
		XX001 += "   GROUP BY PROD_OP,
		XX001 += "            DESC_PROD,
		XX001 += "            SUBSTRING(EMISSAO,1,6),
		XX001 += "            COD_APON,
		XX001 += "            DESC_COD,
		XX001 += "            TP,
		XX001 += "            GP, QTD_ACUM
		XX001 += "   ORDER BY PROD_OP,
		XX001 += "            DESC_PROD,
		XX001 += "            SUBSTRING(EMISSAO,1,6),
		XX001 += "            COD_APON,
		XX001 += "            DESC_COD,
		XX001 += "            TP,
		XX001 += "            GP

		FG004 := XX001

		FGcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,FG004),'FG04',.F.,.T.)
		dbSelectArea("FG04")
		dbGoTop()
		ProcRegua(RecCount())
		xContad := 0
		While !Eof()

			tfProd := FG04->PROD_OP
			tfPeri := FG04->PERIODO
			tfQuan := FG04->QTDACUM
			While !Eof() .and. FG04->PROD_OP == tfProd .and. FG04->PERIODO == tfPeri

				xContad ++
				IncProc(Alltrim(Str(xContad)))

				oExcel:AddRow(nxPlan, nxTabl, { 'REAL'              ,;
				FG04->PROD_OP                                       ,;
				FG04->DESC_PROD                                     ,;
				FG04->PERIODO                                       ,;
				FG04->COD_APON                                      ,;
				FG04->DESC_COD                                      ,;
				FG04->TP                                            ,;
				FG04->GP                                            ,;
				FG04->QTDAPON                                       ,;
				tfQuan                                              ,;
				FG04->QUANT                                         ,;
				FG04->CUSTO                                         ,;
				FG04->QUANT / tfQuan                                ,;
				FG04->CUSTO / tfQuan                                })

				dbSelectArea("FG04")
				dbSkip()

			End

			jklPeriod := Substr(dtos(UltimoDia(stod(tfPeri+"01"))+1),1,6)
			OR002 := " SELECT Z46_SG1COD, "
			OR002 += "        SUBSTRING(SB1.B1_DESC,1,50) DESCRPAI, "
			OR002 += "        '' PERIOD, "
			OR002 += "        Z46_COMP, "
			OR002 += "        SUBSTRING(XB1.B1_DESC,1,50) DESCRCOM, "
			OR002 += "        XB1.B1_TIPO TP, "
			OR002 += "        XB1.B1_GRUPO GP, "
			OR002 += "        0 QTDAPON, "
			OR002 += "        0 TFQUAN, "
			OR002 += "        0 QUANT, "
			OR002 += "        0 CUSTO, "
			OR002 += "        SUM(Z46_QUANT) MEDIO_QTD, "
			OR002 += "        SUM(Z46_CTOTAL) + SUM(Z46_CUSTAC) MEDIO_CST "
			OR002 += "   FROM "+RetSqlName("Z46")+" Z46 WITH (NOLOCK) "
			OR002 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
			OR002 += "                       AND SB1.B1_COD = Z46_SG1COD "
			OR002 += "                       AND SB1.B1_TIPO = '"+MV_PAR03+"' "
			OR002 += "                       AND SB1.D_E_L_E_T_ = ' ' "
			OR002 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 WITH (NOLOCK) ON XB1.B1_FILIAL = '"+xFilial("SB1")+"' "
			OR002 += "                       AND XB1.B1_COD = Z46_COMP "
			OR002 += "                       AND XB1.B1_GRUPO NOT IN('PV') "
			OR002 += "                       AND XB1.D_E_L_E_T_ = ' ' "
			OR002 += "  WHERE Z46_FILIAL = '"+xFilial("Z46")+"' "
			OR002 += "    AND Z46_SG1COD = '"+Alltrim(tfProd)+"' "
			OR002 += "    AND Z46_DATARF IN(SELECT MAX(XXX.Z46_DATARF) "
			OR002 += "                        FROM "+RetSqlName("Z46")+" XXX "
			OR002 += "                       WHERE XXX.Z46_FILIAL = '"+xFilial("Z46")+"' "
			OR002 += "                         AND XXX.Z46_SG1COD = Z46.Z46_SG1COD "
			OR002 += "                         AND SUBSTRING(XXX.Z46_DATARF,1,6) <= '"  + jklPeriod +  "' "
			OR002 += "                         AND XXX.Z46_ANOREF = '"  + Substr(jklPeriod,1,4) +  "' "
			OR002 += "                         AND XXX.D_E_L_E_T_ = ' ') "
			OR002 += "    AND Z46_COD IN(SELECT MAX(XXX.Z46_COD) "
			OR002 += "                     FROM "+RetSqlName("Z46")+" XXX "
			OR002 += "                    WHERE XXX.Z46_FILIAL = '"+xFilial("Z46")+"' "
			OR002 += "                      AND XXX.Z46_DATARF = Z46.Z46_DATARF "
			OR002 += "                      AND XXX.Z46_SG1COD = Z46.Z46_SG1COD "
			OR002 += "                      AND XXX.Z46_COMP = Z46.Z46_COMP "
			OR002 += "                      AND SUBSTRING(XXX.Z46_DATARF,1,6) <= '"  + jklPeriod +  "' "
			OR002 += "                      AND XXX.Z46_ANOREF = '"  + Substr(jklPeriod,1,4) +  "' "
			OR002 += "                      AND XXX.D_E_L_E_T_ = ' ') "
			OR002 += "    AND Z46.D_E_L_E_T_ = ' ' "
			OR002 += "  GROUP BY Z46_SG1COD, "
			OR002 += "           SUBSTRING(SB1.B1_DESC,1,50), "
			OR002 += "           Z46_COMP, "
			OR002 += "           SUBSTRING(XB1.B1_DESC,1,50), "
			OR002 += "           XB1.B1_TIPO, "
			OR002 += "           XB1.B1_GRUPO "
			ORcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,OR002),'OR02',.F.,.T.)
			dbSelectArea("OR02")
			dbGoTop()
			ProcRegua(RecCount())
			fgCta := 0
			While !Eof()

				fgCta ++
				IncProc(Alltrim(Str(xContad)) + "  " + Alltrim(Str(fgCta)))

				frAno  := Substr(tfPeri,1,4)
				frMes  := Substr(tfPeri,5,2)
				frIgpm := 1

				dbSelectArea("REF1")
				dbGoTop()
				If dbSeek(frAno)
					frIgpm := &("REF1->M"+frMes)
				EndIf

				// Incluída tratativa para IGPM, mesmo critério do programa BIA347
				If dtos(MV_PAR01) >= "20170101"
					If Alltrim(Posicione("SB1", 1, xFilial("SB1") + OR02->Z46_COMP, "B1_YCTRIND")) <> "61103001"
						frIgpm := 1
					EndIf
				EndIf

				oExcel:AddRow(nxPlan, nxTabl, { 'ORCA'              ,;
				OR02->Z46_SG1COD                                    ,;
				OR02->DESCRPAI                                      ,;
				tfPeri                                              ,;
				OR02->Z46_COMP                                      ,;
				OR02->DESCRCOM                                      ,;
				OR02->TP                                            ,;
				OR02->GP                                            ,;
				OR02->QTDAPON                                       ,;
				OR02->TFQUAN                                        ,;
				OR02->QUANT                                         ,;
				OR02->CUSTO                                         ,;
				OR02->MEDIO_QTD                                     ,;
				OR02->MEDIO_CST * frIgpm                            })

				dbSelectArea("OR02")
				dbSkip()
			End
			OR02->(dbCloseArea())
			Ferase(ORcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(ORcIndex+OrdBagExt())          //indice gerado

			dbSelectArea("FG04")

		End

		REF1->(dbCloseArea())
		Ferase(xcTab+".idx")

	EndIf

	FG04->(dbCloseArea())
	Ferase(FGcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(FGcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "ProducaoConsumo - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)+" - "+MV_PAR03

	/*verificando se arquivo já existe na pasta antes de tentar excluir para evitar msg errada ao usuário - Pablo S. Nascimento*/
	IF FILE("C:\TEMP\"+xArqTemp+".xml")
		//se ja existe, tenta exclui-lo
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Não foi possível excluir o arquivo ' + 'C:\TEMP\'+xArqTemp+'.xml. Verifique se o arquivo está aberto e feche-o. (FError '+str(ferror(),4)+'            )',{'Ok'})
		EndIf
	ENDIF

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel não encontrado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		Sleep(2000) //garantir que o Excel já carregou os dados para não aparecer planilha vazia.
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
	aAdd(aRegs,{cPerg,"01","Da Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do Tipo             ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"04","Do Produto          ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","Ate Produto         ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"06","Forma do Relatório  ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Analítica","","","","","Sintética","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Data Fotografia     ?","","","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
