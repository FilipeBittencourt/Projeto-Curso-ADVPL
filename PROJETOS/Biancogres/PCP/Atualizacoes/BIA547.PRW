#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA547
@author Marcos Alberto Soprani
@since 02/02/16
@version 1.1
@description Armazenamento Pendente
@type function
/*/

User Function BIA547()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi

	cHInicio := Time()
	fPerg := "BIA547"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Armazenamento Pendente"

	If cEmpAnt == "01"
		kt_BsDad := "DADOSEOS"
	ElseIf xyEmpr == "05"
		kt_BsDad := "DADOS_05_EOS"
	Else
		MsgINFO("Empresa não configurada para apontamento automático de Cerâmica!!!")
		Return
	EndIf

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "HRTURNO"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ETIQUET"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "IDECO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TRANSAC"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUT"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOTEPR"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TURNO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "USUARIO"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ETIQ_DATA"   ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA_TURNO"  ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "ETIQ_ARMAZ"  ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "TEMPO"       ,3,2)

	IK007 := " WITH ETQREF AS (SELECT A.CE_NUMERO_DOCTO ETIQUET, "
	IK007 += "                        A.ID_MOV_PROD IDECO, "
	IK007 += "                        A.COD_TRANSACAO TRANSAC, "
	IK007 += "                        A.COD_PRODUTO PRODUT, "
	IK007 += "                        SUBSTRING(B1_DESC,1,50) DESCR, "
	IK007 += "                        A.CE_LOTE LOTEPR, "
	IK007 += "                        A.CE_QTDADE QUANT, "
	IK007 += "                        A.CE_TURNO TURNO, "
	IK007 += "                        A.CE_FORNO FORNO, "
	IK007 += "                        A.CE_USUARIO USUARIO, "
	IK007 += "                        B.ETIQ_DATA ETIQ_DATA, "
	IK007 += "                        B.ETIQ_DATA_ARMAZENADO ETIQ_ARMAZ, "
	IK007 += "                        CASE "

	//IK007 += "                          WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'00:00:00' AND SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'05:59:59' THEN  "
	//IK007 += "                            CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR,DATEADD(DAY, -1, B.ETIQ_DATA),120),1,11)+'18:00:00') "
	//IK007 += "                          WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'18:00:00' AND SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'23:59:59' THEN  "
	//IK007 += "                            CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'18:00:00') "
	//IK007 += "                          WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'06:00:00' AND SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'17:59:59' THEN  "
	//IK007 += "                            CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR,DATEADD(DAY, 0, B.ETIQ_DATA),120),1,11)+'06:00:00') "

	IK007 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
	IK007 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
	IK007 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, B.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
	IK007 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
	IK007 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '18:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
	IK007 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
	IK007 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
	IK007 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '17:59:59' "
	IK007 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00') "
	IK007 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
	IK007 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
	IK007 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, B.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
	IK007 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
	IK007 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '22:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
	IK007 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
	IK007 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
	IK007 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '14:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '21:59:59' "
	IK007 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '14:00:00') "
	IK007 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
	IK007 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '13:59:59' "
	IK007 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00') "

	IK007 += "                        END DATA_TURNO "
	IK007 += "                   FROM " + kt_BsDad + "..CEP_MOVIMENTO_PRODUTO A "
	IK007 += "                   JOIN " + kt_BsDad + "..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA "
	IK007 += "                                                       AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO "
	IK007 += "                  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = A.COD_PRODUTO COLLATE SQL_Latin1_General_CP1_CI_AS "
	IK007 += "                                       AND SB1.D_E_L_E_T_ = ' ' "
	IK007 += "                  WHERE A.ID_CIA = 1 "
	IK007 += "                    AND A.COD_TRANSACAO IN('1')  "
	IK007 += " 				      AND SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112), 1, 10) BETWEEN '" + dtos(MV_PAR01-30) + "' AND '" + dtos(MV_PAR02+30) + "' "
	IK007 += " 				      AND (SELECT COUNT(*) "
	IK007 += " 				             FROM " + kt_BsDad + "..CEP_MOVIMENTO_PRODUTO XX "
	IK007 += " 				            WHERE XX.ce_numero_docto = A.ce_numero_docto "
	IK007 += " 				              AND XX.COD_TRANSACAO = 64 "
	IK007 += " 				              AND XX.CE_DOCTO = 'CP') = 0 ) "
	IK007 += " SELECT SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5) HRTURNO, "
	IK007 += "        ETIQUET, "
	IK007 += "        IDECO, "
	IK007 += "        TRANSAC, "
	IK007 += "        PRODUT, "
	IK007 += "        DESCR, "
	IK007 += "        LOTEPR, "
	IK007 += "        QUANT, "
	IK007 += "        TURNO, "
	IK007 += "        FORNO, "
	IK007 += "        USUARIO, "
	IK007 += "        CONVERT(VARCHAR, ETIQ_DATA, 121) ETIQ_DATA, "
	IK007 += "        CONVERT(VARCHAR, DATA_TURNO, 121) DATA_TURNO, "
	IK007 += "        CONVERT(VARCHAR, ETIQ_ARMAZ, 121) ETIQ_ARMAZ, "
	IK007 += "        ROUND(CONVERT(FLOAT,DATEDIFF(MINUTE,DATA_TURNO,ETIQ_ARMAZ))/60,8) TEMPO "
	IK007 += "   FROM ETQREF "
	IK007 += "  WHERE SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	IK007 += "    AND ETIQ_ARMAZ - CONVERT(DATETIME, DATA_TURNO,120) > CONVERT(DATETIME, '1900-01-01 14:00:00', 120) "
	IK007 += "    AND ETIQ_ARMAZ <> '' "
	IK007 += "  ORDER BY ETIQUET "
	IKcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,IK007),'IK07',.F.,.T.)
	dbSelectArea("IK07")
	dbGoTop()
	ProcRegua(RecCount())
	xContad := 0
	While !Eof()

		xContad ++
		IncProc(Alltrim(Str(xContad)))

		oExcel:AddRow(nxPlan, nxTabl, { IK07->HRTURNO   ,;
		IK07->ETIQUET                                   ,;
		IK07->IDECO                                     ,;
		IK07->TRANSAC                                   ,;
		IK07->PRODUT                                    ,;
		IK07->DESCR                                     ,;
		IK07->LOTEPR                                    ,;
		IK07->QUANT                                     ,;
		IK07->TURNO                                     ,;
		IK07->FORNO                                     ,;
		IK07->USUARIO                                   ,;
		IK07->ETIQ_DATA                                 ,;
		IK07->DATA_TURNO                                ,;
		IK07->ETIQ_ARMAZ                                ,;
		IK07->TEMPO                                     })

		dbSelectArea("IK07")
		dbSkip()

	End

	IK07->(dbCloseArea())
	Ferase(IKcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(IKcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "ArmazenamentoPendente - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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
