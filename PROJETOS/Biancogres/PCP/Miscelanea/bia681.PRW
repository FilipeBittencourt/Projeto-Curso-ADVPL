#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA681
@author Marcos Alberto Soprani
@since 09/06/16
@version 1.0
@description Consumo versus Orçamento - por Insumo de produção
@type function
/*/
/*/{Protheus.doc} BIA681
@author Artur Antunes
@since 10/03/16
@version 1.0
@description Ajuste na barra de progressão e inclusão dos campos Codigo comum e descrição
@type function
/*/

User Function BIA681()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA681"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	htInd := 0
	htAno := Substr(dtos(MV_PAR02),1,4)
	htMes := Substr(dtos(MV_PAR02),5,2)

	xcTab := "\data\bkp_Marcos\igpm"
	dbUseArea(.T.,,xcTab+".dtc","REF1",.F.)
	dbCreateIndex(xcTab+".idx","ANO",{|| ANO })
	dbSelectArea("REF1")
	dbGoTop()
	If dbSeek(htAno)
		htInd := &("REF1->M"+htMes)
	EndIf
	REF1->(dbCloseArea())
	Ferase(xcTab+".idx")

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Consumo versus Orçamento - por Insumo de produção"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODPAI "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DFORMATO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DPROD   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "INSUMO  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DINSUM  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO    "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GRUPO   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DGRUPO  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UM      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCONTA  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BAIXA   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT   "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO   "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "IGPM    "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "APLICACAO"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CODCOMUM"	              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCOMUM" 	          ,1,1)

	JK002 := " WITH PRODUC AS (SELECT Z57_PRODUT, "
	JK002 += "                        Z57_QTDRAC, "
	JK002 += "                        SUBSTRING(Z57_PRODUT,1,7)+'1       ' PRODREF "
	JK002 += "                   FROM "+RetSqlName("Z57")+" Z57 WITH (NOLOCK) "
	JK002 += "                  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' "
	JK002 += "                                                     AND B1_COD = Z57_PRODUT "
	JK002 += "                                                     AND B1_TIPO = 'PA' "
	JK002 += "                                                     AND SB1.D_E_L_E_T_ = ' ' "
	JK002 += "                  WHERE Z57_FILIAL = '"+xFilial("Z57")+"' "
	JK002 += "                    AND Z57_DATARF = '"+dtos(MV_PAR02)+"' "
	JK002 += "                    AND Z57.D_E_L_E_T_ = ' ') "
	JK002 += " ,   INSUMOS AS (SELECT D3_COD, "
	JK002 += "                        D3_CONTA, "
	JK002 += "                        SUM(D3_QUANT) QUANT, "
	JK002 += "                        SUM(D3_CUSTO1) CUSTO "
	JK002 += "                   FROM (SELECT D3_TM, "
	JK002 += "                                D3_EMISSAO, "
	JK002 += "                                D3_COD, "
	JK002 += "                                D3_CONTA, "
	JK002 += "                                CASE "
	JK002 += "                                  WHEN D3_TM > '500' THEN D3_QUANT "
	JK002 += "                                  ELSE D3_QUANT * (-1) "
	JK002 += "                                END D3_QUANT, "
	JK002 += "                                CASE "
	JK002 += "                                  WHEN D3_TM > '500' THEN D3_CUSTO1 "
	JK002 += "                                  ELSE D3_CUSTO1 * (-1) "
	JK002 += "                                END D3_CUSTO1 "
	JK002 += "                           FROM "+RetSqlName("SD3")+" WITH (NOLOCK) "
	JK002 += "                          WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	JK002 += "                            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	JK002 += "                            AND SUBSTRING(D3_COD,1,3) <> 'MOD' "
	JK002 += "                            AND D3_CONTA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	JK002 += "                            AND D3_OP = '             ' "
	JK002 += "                            AND D3_CC = '3000' "
	JK002 += "                            AND D3_CF NOT IN('DE4','RE4','DE7','RE7') "
	JK002 += "                            AND D_E_L_E_T_ = ' ') AS TABD "
	JK002 += "                   GROUP BY D3_COD, "
	JK002 += "                            D3_CONTA) "
	JK002 += " ,    FOTOGR AS (SELECT Z46_COD, "
	JK002 += "                        Z46_COMP, "
	JK002 += "                        Z46_CONTA, "
	JK002 += "                        Z46_QUANT, "
	JK002 += "                        Z46_CTOTAL "
	JK002 += "                   FROM "+RetSqlName("Z46")+" Z46 WITH (NOLOCK) "
	JK002 += "                  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' "
	JK002 += "                                                     AND B1_COD = Z46_COD "
	JK002 += "                                                     AND B1_TIPO = 'PA' "
	JK002 += "                                                     AND SB1.D_E_L_E_T_ = ' ' "
	JK002 += "                  WHERE Z46_FILIAL = '"+xFilial("Z46")+"' "
	JK002 += "                    AND Z46_DATARF IN(SELECT MAX(XXX.Z46_DATARF) "
	JK002 += "                                        FROM "+RetSqlName("Z46")+" XXX WITH (NOLOCK) "
	JK002 += "                                       WHERE XXX.Z46_FILIAL = '"+xFilial("Z46")+"' "
	JK002 += "                                         AND XXX.Z46_COD = Z46.Z46_COD "
	JK002 += "                                         AND XXX.D_E_L_E_T_ = ' ') "
	JK002 += "                    AND Z46_CONTA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	JK002 += "                    AND Z46.D_E_L_E_T_ = ' ') "
	JK002 += " SELECT RTRIM(PRODUTO) PRODUTO, "
	JK002 += "        SUBSTRING(ZZB1.B1_DESC,1,70) DPROD, "
	JK002 += "        RTRIM(INSUMO) INSUMO, "
	JK002 += "        SUBSTRING(QQB1.B1_DESC,1,70) DINSUM, "
	JK002 += "        QQB1.B1_TIPO TIPO, "
	JK002 += "        QQB1.B1_GRUPO GRUPO, "
	JK002 += "        QQBM.BM_DESC DGRUPO, "
	JK002 += "        QQB1.B1_UM UM, "
	JK002 += "        RTRIM(CONTA) CONTA, "
	JK002 += "        CT1_DESC01 DCONTA, "
	JK002 += "        RTRIM(BAIXA) BAIXA, "
	JK002 += "        QUANT, "
	JK002 += "        CUSTO, "
	JK002 += "		  (CASE "
	JK002 += "		  	WHEN QQB1.B1_YCODCOM = ' ' THEN RTRIM(INSUMO) " 
	JK002 += "			ELSE QQB1.B1_YCODCOM " 
	JK002 += "		   END) CODCOM, "
	JK002 += "		  (CASE " 
	JK002 += "			WHEN QQB1.B1_YCODCOM = ' ' THEN SUBSTRING(QQB1.B1_DESC, 1, 70) "
	JK002 += "			ELSE (SELECT SUBSTRING(SB1A.B1_DESC, 1, 70) FROM "+RetSqlName("SB1")+" SB1A (NOLOCK) WHERE SB1A.B1_COD = QQB1.B1_YCODCOM AND SB1A.D_E_L_E_T_ = '' ) "
	JK002 += "		   END) DESCCOM "
	JK002 += "   FROM (SELECT Z56_COD PRODUTO, "
	JK002 += "                D3_COD INSUMO, "
	JK002 += "                Z56_CONTA CONTA, "
	JK002 += "                'MANUAL' BAIXA, "
	JK002 += "                QUANT * (VOLUME/ACVOL) QUANT, "
	JK002 += "                CUSTO * (VOLUME/ACVOL) CUSTO "
	JK002 += "           FROM (SELECT Z56_COD, "
	JK002 += "                        Z56_CONTA, "
	JK002 += "                        Z56_CTOTAL, "
	JK002 += "                        Z57_QTDRAC, "
	JK002 += "                        Z56_CTOTAL * Z57_QTDRAC VOLUME, "
	JK002 += "                        (SELECT SUM(X56.Z56_CTOTAL * PRD1.Z57_QTDRAC) "
	JK002 += "                           FROM "+RetSqlName("Z56")+" X56 WITH (NOLOCK) "
	JK002 += "                          INNER JOIN PRODUC PRD1 ON X56.Z56_COD = PRD1.Z57_PRODUT "
	JK002 += "                          WHERE X56.Z56_FILIAL = '"+xFilial("Z56")+"' "
	JK002 += "                            AND X56.Z56_DATARF = Z56.Z56_DATARF "
	JK002 += "                            AND X56.Z56_CONTA = Z56.Z56_CONTA "
	JK002 += "                            AND X56.D_E_L_E_T_ = ' ') ACVOL, "
	JK002 += "                        D3_COD, "
	JK002 += "                        QUANT, "
	JK002 += "                        CUSTO "
	JK002 += "                   FROM "+RetSqlName("Z56")+" Z56 WITH (NOLOCK) "
	JK002 += "                  INNER JOIN PRODUC PRDC ON Z56_COD = Z57_PRODUT "
	JK002 += "                  INNER JOIN INSUMOS INSM ON Z56_CONTA = D3_CONTA "
	JK002 += "                  WHERE Z56_FILIAL = '"+xFilial("Z56")+"' "
	JK002 += "                    AND Z56_DATARF = '"+dtos(MV_PAR02)+"' "
	JK002 += "                    AND Z56_CONTA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	JK002 += "                    AND Z56.D_E_L_E_T_ = ' ') AS TARVE "
	JK002 += "          UNION ALL "
	JK002 += "         SELECT C2_PRODUTO PRODUTO, "
	JK002 += "                D3_COD INSUMO, "
	JK002 += "                D3_CONTA CONTA, "
	JK002 += "                'AUTOMATICA' BAIXA, "
	JK002 += "                SUM(D3_QUANT) QUANT, "
	JK002 += "                SUM(D3_CUSTO1) CUSTO "
	JK002 += "           FROM (SELECT D3_TM, "
	JK002 += "                        D3_EMISSAO, "
	JK002 += "                        C2_PRODUTO, "
	JK002 += "                        D3_COD, "
	JK002 += "                        D3_CONTA, "
	JK002 += "                        CASE "
	JK002 += "                          WHEN D3_TM > '500' THEN D3_QUANT "
	JK002 += "                          ELSE D3_QUANT * (-1) "
	JK002 += "                        END D3_QUANT, "
	JK002 += "                        CASE "
	JK002 += "                          WHEN D3_TM > '500' THEN D3_CUSTO1 "
	JK002 += "                          ELSE D3_CUSTO1 * (-1) "
	JK002 += "                        END D3_CUSTO1 "
	JK002 += "                   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) "
	JK002 += "                  INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"' "
	JK002 += "                                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
	JK002 += "                                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
	JK002 += "                                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
	JK002 += "                                       AND SC2.D_E_L_E_T_ = ' ' "
	JK002 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	JK002 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	JK002 += "                    AND SUBSTRING(D3_COD,1,3) <> 'MOD' "
	JK002 += "                    AND D3_CONTA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	JK002 += "                    AND SD3.D_E_L_E_T_ = ' ') AS TABD "
	JK002 += "           GROUP BY C2_PRODUTO, "
	JK002 += "                    D3_COD, "
	JK002 += "                    D3_CONTA "
	JK002 += "          UNION ALL "
	JK002 += "         SELECT Z57_PRODUT PRODUTO, "
	JK002 += "                Z46_COMP INSUMO, "
	JK002 += "                Z46_CONTA CONTA, "
	JK002 += "                'AJUSTADA' BAIXA, "
	JK002 += "                Z57_QTDRAC * Z46_QUANT QUANT, "
	JK002 += "                Z57_QTDRAC * Z46_CTOTAL CUSTO "
	JK002 += "           FROM PRODUC PRDC  "
	JK002 += "          INNER JOIN FOTOGR FTGR ON PRODREF = Z46_COD) AS TABXX1 "
	JK002 += "  INNER JOIN "+RetSqlName("SB1")+" ZZB1 ON ZZB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	JK002 += "                        AND ZZB1.B1_COD = PRODUTO "
	JK002 += "                        AND ZZB1.D_E_L_E_T_ = ' ' "
	JK002 += "  INNER JOIN "+RetSqlName("SB1")+" QQB1 ON QQB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	JK002 += "                        AND QQB1.B1_COD = INSUMO "
	JK002 += "                        AND QQB1.D_E_L_E_T_ = ' ' "
	JK002 += "  INNER JOIN "+RetSqlName("SBM")+" QQBM ON QQBM.BM_FILIAL = '"+xFilial("SBM")+"  ' "
	JK002 += "                        AND QQBM.BM_GRUPO = QQB1.B1_GRUPO "
	JK002 += "                        AND QQBM.D_E_L_E_T_ = ' ' "
	JK002 += "  INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
	JK002 += "                        AND CT1.CT1_CONTA = CONTA "
	JK002 += "                        AND CT1.D_E_L_E_T_ = ' ' "
	JKcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,JK002),'JK02',.F.,.T.)
	dbSelectArea("JK02")
	JK02->(dbGoTop())
	
	ckContad := 0
	nTotReg  := 0
	Count To nTotReg
	ProcRegua(nTotReg)
	JK02->(dbGoTop())
	
	While !JK02->(Eof())

		ckContad ++
		IncProc("Processamento1: " + Alltrim(Str(ckContad)))

		ZZ6->(dbSetOrder(1))
		ZZ6->(dbSeek(xFilial("ZZ6")+Substr(JK02->PRODUTO,1,2)))

		oExcel:AddRow(nxPlan, nxTabl, { Substr(JK02->PRODUTO,1,7)                ,;
		JK02->PRODUTO                                                            ,;
		Substr(JK02->PRODUTO,1,2)                                                ,;
		ZZ6->ZZ6_DESC                                                            ,;
		JK02->DPROD                                                              ,;
		JK02->INSUMO                                                             ,;
		JK02->DINSUM                                                             ,;
		JK02->TIPO                                                               ,;
		JK02->GRUPO                                                              ,;
		JK02->DGRUPO                                                             ,;
		JK02->UM                                                                 ,;
		JK02->CONTA                                                              ,;
		JK02->DCONTA                                                             ,;
		JK02->BAIXA                                                              ,;
		JK02->QUANT                                                              ,;
		JK02->CUSTO * IIF(Alltrim(JK02->BAIXA) == "AJUSTADA", htInd, 1 )	     ,;
		htInd                                                                    ,;
		IIF(Alltrim(JK02->BAIXA) == "AJUSTADA", "ORÇADO", "REALIZADO")           ,;
		JK02->CODCOM															 ,;
		JK02->DESCCOM															 })

		JK02->(dbSkip())    

	End

	JK02->(dbCloseArea())
	Ferase(JKcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(JKcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "consumo-vs-orcado - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

	if !ExistDir("C:\TEMP\")
		FWMakeDir("C:\TEMP\")
	endif
	
	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1 .and. File("C:\TEMP\"+xArqTemp+".xml")
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
	aAdd(aRegs,{cPerg,"03","Da Conta                 ?","","","mv_ch3","C",20,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})
	aAdd(aRegs,{cPerg,"04","Até Conta                ?","","","mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})
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
