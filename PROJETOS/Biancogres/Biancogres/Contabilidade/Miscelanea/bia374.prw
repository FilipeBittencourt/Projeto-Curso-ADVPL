#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA374
@author Marcos Alberto Soprani
@since 14/10/19
@version 1.0
@description Planilha de conciliação do Orçamento
@obs Contabilidade
@type function
/*/

User Function BIA374()

	fPerg := "BIA374"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local ztx

	oExcel := FWMSEXCEL():New()

	nxPlan := "Bases"
	nxTabl := "Verificação dos dados orçados e realizados"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMPR"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FILEMP"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VERSAO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTREF"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "APLICACAO"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DRIVER"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VALOR"         ,3,2)

	msEmprComp := {}
	EB003 := " SELECT Z35_EMP, "
	EB003 += "        Z35_DREDUZ "
	EB003 += "   FROM Z35010 Z35 
	EB003 += "  WHERE Z35_TIPO = '01' "
	EB003 += "    AND Z35_FIL = '01' "
	EB003 += "    AND D_E_L_E_T_ = ' ' "
	EBcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,EB003),'EB03',.F.,.T.)
	dbSelectArea("EB03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		aadd(msEmprComp, {EB03->Z35_EMP, EB03->Z35_DREDUZ})
		dbSelectArea("EB03")
		dbSkip()

	End
	EB03->(dbCloseArea())
	Ferase(EBcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(EBcIndex+OrdBagExt())          //indice gerado

	QR002 := " WITH CONTABILX "
	QR002 += "      AS ( "
	For ztx := 1 to Len(msEmprComp)
		QR002 += "          SELECT '" + msEmprComp[ztx][1] + "' EMPR, "
		QR002 += "                 '" + msEmprComp[ztx][2] + "' NOME, "
		QR002 += "                 CT2_FILIAL FILEMP, "
		QR002 += "                 'REAL' VERSAO, "
		QR002 += "                 SUBSTRING(CT2_DATA, 1, 6) DTREF, "
		QR002 += "                 CT2_DEBITO CONTA, "
		QR002 += "                 CT2_CLVLDB CLVL, "
		QR002 += "                 CT2_VALOR VALOR, "
		QR002 += "                 CT2.CT2_YAPLIC APLICACAO, "
		QR002 += "                 CT2.CT2_YDRVDB DRIVER "
		QR002 += "          FROM CT2" + msEmprComp[ztx][1] + "0 CT2 WITH(NOLOCK) "
		QR002 += "          WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ' "
		QR002 += "                AND CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		QR002 += "                AND CT2_DEBITO <> '                    ' "
		QR002 += "                AND CT2_ROTINA NOT IN('CTBA210', 'CTBA211') "
		QR002 += "                AND CT2.D_E_L_E_T_ = ' ' "
		QR002 += "          UNION ALL "
		QR002 += "          SELECT '" + msEmprComp[ztx][1] + "' EMPR, "
		QR002 += "                 '" + msEmprComp[ztx][2] + "' NOME, "
		QR002 += "                 CT2_FILIAL FILEMP, "
		QR002 += "                 'REAL' VERSAO, "
		QR002 += "                 SUBSTRING(CT2_DATA, 1, 6) DTREF, "
		QR002 += "                 CT2_CREDIT CONTA, "
		QR002 += "                 CT2_CLVLCR CLVL, "
		QR002 += "                 CT2_VALOR * (-1) VALOR, "
		QR002 += "                 CT2.CT2_YAPLIC APLICACAO, "
		QR002 += "                 CT2.CT2_YDRVCR DRIVER "
		QR002 += "          FROM CT2" + msEmprComp[ztx][1] + "0 CT2 WITH(NOLOCK) "
		QR002 += "          WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ' "
		QR002 += "                AND CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		QR002 += "                AND CT2_CREDIT <> '                    ' "
		QR002 += "                AND CT2_ROTINA NOT IN('CTBA210', 'CTBA211') "
		QR002 += "                AND CT2.D_E_L_E_T_ = ' ' "
		If ztx < Len(msEmprComp)
			QR002 += "          UNION ALL "
		EndIf
	Next ztx
	QR002 += "           ) "
	QR002 += "      SELECT EMPR, "
	QR002 += "             NOME, "
	QR002 += "             FILEMP, "
	QR002 += "             VERSAO, "
	QR002 += "             DTREF, "
	QR002 += "             CONTA, "
	QR002 += "             CLVL, "
	QR002 += "             APLICACAO, "
	QR002 += "             DRIVER, "
	QR002 += "             ROUND(SUM(VALOR), 2) VALOR "
	QR002 += "      FROM CONTABILX "
	QR002 += "      GROUP BY EMPR, "
	QR002 += "               NOME, "
	QR002 += "               FILEMP, "
	QR002 += "               VERSAO, "
	QR002 += "               DTREF, "
	QR002 += "               CONTA, "
	QR002 += "               CLVL, "
	QR002 += "               APLICACAO, "
	QR002 += "               DRIVER "
	QR002 += "      ORDER BY EMPR, "
	QR002 += "               FILEMP, "
	QR002 += "               VERSAO, "
	QR002 += "               DTREF, "
	QR002 += "               CONTA, "
	QR002 += "               CLVL, "
	QR002 += "               APLICACAO, "
	QR002 += "               DRIVER "
	QBcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR002),'QR02',.F.,.T.)
	dbSelectArea("QR02")
	dbGoTop()
	ProcRegua(0)
	While !Eof()

		IncProc("Real: " + QR02->EMPR + "-" + QR02->NOME)

		oExcel:AddRow(nxPlan, nxTabl, { QR02->EMPR, QR02->NOME, QR02->FILEMP, QR02->VERSAO, QR02->DTREF, QR02->CONTA, QR02->CLVL, QR02->APLICACAO, QR02->DRIVER, QR02->VALOR })

		dbSelectArea("QR02")
		dbSkip()

	End
	QR02->(dbCloseArea())
	Ferase(QBcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QBcIndex+OrdBagExt())          //indice gerado

	DK004 := " WITH ORCADOX "
	DK004 += "      AS ( "
	For ztx := 1 to Len(msEmprComp)
		DK004 += "          SELECT '" + msEmprComp[ztx][1] + "' EMPR, "
		DK004 += "                 '" + msEmprComp[ztx][2] + "' NOME, "
		DK004 += "                 ZBZ_FILIAL FILEMP, "
		DK004 += "                 'ORCA' VERSAO, "
		DK004 += "                 SUBSTRING(ZBZ_DATA, 1, 6) DTREF, "
		DK004 += "                 ZBZ_DEBITO CONTA, "
		DK004 += "                 ZBZ_CLVLDB CLVL, "
		DK004 += "                 ZBZ_VALOR VALOR, "
		DK004 += "                 ZBZ.ZBZ_APLIC APLICACAO, "
		DK004 += "                 ZBZ.ZBZ_DRVDB DRIVER "
		DK004 += "          FROM ZBZ" + msEmprComp[ztx][1] + "0 ZBZ WITH(NOLOCK) "
		DK004 += "          WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
		DK004 += "                AND ZBZ_VERSAO = '" + MV_PAR03 + "' "
		DK004 += "                AND ZBZ_REVISA = '" + MV_PAR04 + "' "
		DK004 += "                AND ZBZ_ANOREF = '" + MV_PAR05 + "' "
		DK004 += "                AND ZBZ_DATA BETWEEN '" + dtos(MV_PAR06) + "' AND '" + dtos(MV_PAR07) + "' "
		DK004 += "                AND ZBZ_DEBITO <> '                    ' "
		DK004 += "                AND ZBZ.D_E_L_E_T_ = ' ' "
		DK004 += "          UNION ALL "
		DK004 += "          SELECT '" + msEmprComp[ztx][1] + "' EMPR, "
		DK004 += "                 '" + msEmprComp[ztx][2] + "' NOME, "
		DK004 += "                 ZBZ_FILIAL FILEMP, "
		DK004 += "                 'ORCA' VERSAO, "
		DK004 += "                 SUBSTRING(ZBZ_DATA, 1, 6) DTREF, "
		DK004 += "                 ZBZ_CREDIT CONTA, "
		DK004 += "                 ZBZ_CLVLCR CLVL, "
		DK004 += "                 ZBZ_VALOR * (-1) VALOR, "
		DK004 += "                 ZBZ.ZBZ_APLIC APLICACAO, "
		DK004 += "                 ZBZ.ZBZ_DRVCR DRIVER "
		DK004 += "          FROM ZBZ" + msEmprComp[ztx][1] + "0 ZBZ WITH(NOLOCK) "
		DK004 += "          WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
		DK004 += "                AND ZBZ_VERSAO = '" + MV_PAR03 + "' "
		DK004 += "                AND ZBZ_REVISA = '" + MV_PAR04 + "' "
		DK004 += "                AND ZBZ_ANOREF = '" + MV_PAR05 + "' "
		DK004 += "                AND ZBZ_DATA BETWEEN '" + dtos(MV_PAR06) + "' AND '" + dtos(MV_PAR07) + "' "
		DK004 += "                AND ZBZ_CREDIT <> '                    ' "
		DK004 += "                AND ZBZ.D_E_L_E_T_ = ' ' "
		If ztx < Len(msEmprComp)
			DK004 += "          UNION ALL "
		EndIf
	Next ztx
	DK004 += "           ) "
	DK004 += "      SELECT EMPR, "
	DK004 += "             NOME, "
	DK004 += "             FILEMP, "
	DK004 += "             VERSAO, "
	DK004 += "             DTREF, "
	DK004 += "             CONTA, "
	DK004 += "             CLVL, "
	DK004 += "             APLICACAO, "
	DK004 += "             DRIVER, "
	DK004 += "             ROUND(SUM(VALOR), 2) VALOR "
	DK004 += "      FROM ORCADOX "
	DK004 += "      GROUP BY EMPR, "
	DK004 += "               NOME, "
	DK004 += "               FILEMP, "
	DK004 += "               VERSAO, "
	DK004 += "               DTREF, "
	DK004 += "               CONTA, "
	DK004 += "               CLVL, "
	DK004 += "               APLICACAO, "
	DK004 += "               DRIVER "
	DK004 += "      ORDER BY EMPR, "
	DK004 += "               FILEMP, "
	DK004 += "               VERSAO, "
	DK004 += "               DTREF, "
	DK004 += "               CONTA, "
	DK004 += "               CLVL, "
	DK004 += "               APLICACAO, "
	DK004 += "               DRIVER "
	DKcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,DK004),'DK04',.F.,.T.)
	dbSelectArea("DK04")
	dbGoTop()
	ProcRegua(0)
	While !Eof()

		IncProc("Orca: " + DK04->EMPR + "-" + DK04->NOME)

		oExcel:AddRow(nxPlan, nxTabl, { DK04->EMPR, DK04->NOME, DK04->FILEMP, DK04->VERSAO, DK04->DTREF, DK04->CONTA, DK04->CLVL, DK04->APLICACAO, DK04->DRIVER, DK04->VALOR })

		dbSelectArea("DK04")
		dbSkip()

	End
	DK04->(dbCloseArea())
	Ferase(DKcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(DKcIndex+OrdBagExt())          //indice gerado

	YC007 := " WITH CORRENTEX "
	YC007 += "      AS ( "
	For ztx := 1 to Len(msEmprComp)
		YC007 += "          SELECT '" + msEmprComp[ztx][1] + "' EMPR, "
		YC007 += "                 '" + msEmprComp[ztx][2] + "' NOME, "
		YC007 += "                 ZBZ_FILIAL FILEMP, "
		YC007 += "                 'CORR' VERSAO, "
		YC007 += "                 SUBSTRING(ZBZ_DATA, 1, 6) DTREF, "
		YC007 += "                 ZBZ_DEBITO CONTA, "
		YC007 += "                 ZBZ_CLVLDB CLVL, "
		YC007 += "                 ZBZ_VALOR VALOR, "
		YC007 += "                 ZBZ.ZBZ_APLIC APLICACAO, "
		YC007 += "                 ZBZ.ZBZ_DRVDB DRIVER "
		YC007 += "          FROM ZBZ" + msEmprComp[ztx][1] + "0 ZBZ WITH(NOLOCK) "
		YC007 += "          WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
		YC007 += "                AND ZBZ_VERSAO = '" + MV_PAR08 + "' "
		YC007 += "                AND ZBZ_REVISA = '" + MV_PAR09 + "' "
		YC007 += "                AND ZBZ_ANOREF = '" + MV_PAR10 + "' "
		YC007 += "                AND ZBZ_DEBITO <> '                    ' "
		YC007 += "                AND ZBZ.D_E_L_E_T_ = ' ' "
		YC007 += "          UNION ALL "
		YC007 += "          SELECT '" + msEmprComp[ztx][1] + "' EMPR, "
		YC007 += "                 '" + msEmprComp[ztx][2] + "' NOME, "
		YC007 += "                 ZBZ_FILIAL FILEMP, "
		YC007 += "                 'CORR' VERSAO, "
		YC007 += "                 SUBSTRING(ZBZ_DATA, 1, 6) DTREF, "
		YC007 += "                 ZBZ_CREDIT CONTA, "
		YC007 += "                 ZBZ_CLVLCR CLVL, "
		YC007 += "                 ZBZ_VALOR * (-1) VALOR, "
		YC007 += "                 ZBZ.ZBZ_APLIC APLICACAO, "
		YC007 += "                 ZBZ.ZBZ_DRVCR DRIVER "
		YC007 += "          FROM ZBZ" + msEmprComp[ztx][1] + "0 ZBZ WITH(NOLOCK) "
		YC007 += "          WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
		YC007 += "                AND ZBZ_VERSAO = '" + MV_PAR08 + "' "
		YC007 += "                AND ZBZ_REVISA = '" + MV_PAR09 + "' "
		YC007 += "                AND ZBZ_ANOREF = '" + MV_PAR10 + "' "
		YC007 += "                AND ZBZ_CREDIT <> '                    ' "
		YC007 += "                AND ZBZ.D_E_L_E_T_ = ' ' "
		If ztx < Len(msEmprComp)
			YC007 += "          UNION ALL "
		EndIf
	Next ztx
	YC007 += "           ) "
	YC007 += "      SELECT EMPR, "
	YC007 += "             NOME, "
	YC007 += "             FILEMP, "
	YC007 += "             VERSAO, "
	YC007 += "             DTREF, "
	YC007 += "             CONTA, "
	YC007 += "             CLVL, "
	YC007 += "             APLICACAO, "
	YC007 += "             DRIVER, "
	YC007 += "             ROUND(SUM(VALOR), 2) VALOR "
	YC007 += "      FROM CORRENTEX "
	YC007 += "      GROUP BY EMPR, "
	YC007 += "               NOME, "
	YC007 += "               FILEMP, "
	YC007 += "               VERSAO, "
	YC007 += "               DTREF, "
	YC007 += "               CONTA, "
	YC007 += "               CLVL, "
	YC007 += "               APLICACAO, "
	YC007 += "               DRIVER "
	YC007 += "      ORDER BY EMPR, "
	YC007 += "               FILEMP, "
	YC007 += "               VERSAO, "
	YC007 += "               DTREF, "
	YC007 += "               CONTA, "
	YC007 += "               CLVL, "
	YC007 += "               APLICACAO, "
	YC007 += "               DRIVER "
	YCcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,YC007),'YC07',.F.,.T.)
	dbSelectArea("YC07")
	dbGoTop()
	ProcRegua(0)
	While !Eof()

		IncProc("Corr: " + YC07->EMPR + "-" + YC07->NOME)

		oExcel:AddRow(nxPlan, nxTabl, { YC07->EMPR, YC07->NOME, YC07->FILEMP, YC07->VERSAO, YC07->DTREF, YC07->CONTA, YC07->CLVL, YC07->APLICACAO, YC07->DRIVER, YC07->VALOR })

		dbSelectArea("YC07")
		dbSkip()

	End
	YC07->(dbCloseArea())
	Ferase(YCcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(YCcIndex+OrdBagExt())          //indice gerado

	// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

	xArqTemp := "BIA374_" + ALLTrim( DTOS(DATE()) + "_"+StrTran( time(),':',''))

	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	ProcRegua(0)
	IncProc("Convertendo arquivo temporário em excel")

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
	aAdd(aRegs,{cPerg,"01","Real [De Data]                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Real [Até Data]               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Comparativa - Versão Orça     ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"04","Comparativa - Revisão Ativa   ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Comparativa - Ano de Ref.     ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Comparativa - De Data         ?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Comparativa - Até Data        ?","","","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Corrente - Versão Orça        ?","","","mv_ch8","C",10,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"09","Corrente - Revisão Ativa      ?","","","mv_ch9","C",03,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Corrente - Ano de Ref.        ?","","","mv_cha","C",04,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
