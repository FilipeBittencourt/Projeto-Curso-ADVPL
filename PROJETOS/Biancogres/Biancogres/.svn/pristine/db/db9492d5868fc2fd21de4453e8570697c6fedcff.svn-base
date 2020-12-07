#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA548
@author Marcos Alberto Soprani
@since 02/02/16
@version 1.0
@description Análise de Movimento de Compras
@type function
/*/

User Function BIA548()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi

	cHInicio := Time()
	fPerg := "BIA548"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Análise de Movimento de Compras"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DTDIGIT"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNECE"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOJA"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PEDIDO"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEMPC"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "OBS1"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "OBS2"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TES"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESTOQUE"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DUPLIC"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CF"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCONTA"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "APLICACAO"   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "dAPLIC"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR_SB1"   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR_SC7"   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"       ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"       ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TAG"         ,1,1)

	QR006 := " SELECT D1_DTDIGIT, "
	QR006 += "        D1_EMISSAO, "
	QR006 += "        D1_DOC, "
	QR006 += "        D1_FORNECE, "
	QR006 += "        D1_LOJA, "
	QR006 += "        A2_NOME, "
	QR006 += "        D1_TIPO, "
	QR006 += "        D1_PEDIDO, "
	QR006 += "        D1_ITEMPC, "
	QR006 += "        RTRIM(ISNULL(C7_YOBS, '')) C7_YOBS, "
	QR006 += "        D1_TES, "
	QR006 += "        F4_ESTOQUE, "
	QR006 += "        F4_DUPLIC, "
	QR006 += "        D1_CF, "
	QR006 += "        D1_CONTA, "
	QR006 += "        CT1_DESC01, "
	QR006 += "        D1_YAPLIC, "
	QR006 += "        CASE "
	QR006 += "          WHEN D1_YAPLIC = ' ' THEN 'Vazio' "
	QR006 += "          WHEN D1_YAPLIC = '0' THEN 'Nenhum' "
	QR006 += "          WHEN D1_YAPLIC = '1' THEN 'Producao' "
	QR006 += "          WHEN D1_YAPLIC = '2' THEN 'Manutencao' "
	QR006 += "          WHEN D1_YAPLIC = '3' THEN 'Melhoria' "
	QR006 += "          WHEN D1_YAPLIC = '4' THEN 'Seguranca' "
	QR006 += "          WHEN D1_YAPLIC = '5' THEN 'Calibracao' "
	QR006 += "          ELSE 'Erro' "
	QR006 += "        END DAPLIC, "
	QR006 += "        D1_COD, "
	QR006 += "        B1_DESC, "
	QR006 += "        RTRIM(ISNULL(C7_DESCRI, '')) C7_DESCRI, "
	QR006 += "        D1_CLVL, "
	QR006 += "        D1_QUANT, "
	QR006 += "        D1_CUSTO, "
	QR006 += "        D1_YTAG "
	QR006 += "   FROM "+RetSqlName("SD1")+" SD1 "
	QR006 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' "
	QR006 += "                       AND B1_COD = D1_COD "
	QR006 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	QR006 += "   LEFT JOIN "+RetSqlName("SC7")+" SC7 ON C7_FILIAL = '"+xFilial("SC7")+"' "
	QR006 += "                       AND C7_NUM = D1_PEDIDO "
	QR006 += "                       AND C7_ITEM = D1_ITEMPC "
	QR006 += "                       AND SC7.D_E_L_E_T_ = ' ' "
	QR006 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"' "
	QR006 += "                       AND F4_CODIGO = D1_TES "
	QR006 += "                       AND F4_YCCONT NOT IN('999','050') "
	QR006 += "                       AND SF4.D_E_L_E_T_ = ' ' "
	QR006 += "  INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' "
	QR006 += "                       AND A2_COD = D1_FORNECE "
	QR006 += "                       AND A2_LOJA = D1_LOJA "
	QR006 += "                       AND SA2.D_E_L_E_T_ = ' ' "
	QR006 += "  INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' "
	QR006 += "                       AND CT1_CONTA = D1_CONTA "
	QR006 += "                       AND CT1.D_E_L_E_T_ = ' ' "
	QR006 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
	QR006 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	QR006 += "    AND D1_CONTA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	QR006 += "    AND SD1.D_E_L_E_T_ = ' ' "
	QRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR006),'QR06',.F.,.T.)
	dbSelectArea("QR06")
	dbGoTop()
	ProcRegua(RecCount())
	xContad := 0
	While !Eof()

		xContad ++
		IncProc(Alltrim(Str(xContad)))

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(QR06->D1_DTDIGIT)) ,;
		dtoc(stod(QR06->D1_EMISSAO))                                 ,;
		QR06->D1_DOC                                                 ,;
		QR06->D1_FORNECE                                             ,;
		QR06->D1_LOJA                                                ,;
		QR06->A2_NOME                                                ,;
		QR06->D1_TIPO                                                ,;
		QR06->D1_PEDIDO                                              ,;
		QR06->D1_ITEMPC                                              ,;
		StrTran(Substr(QR06->C7_YOBS,  1,150),'<','MENOR ')          ,;
		StrTran(Substr(QR06->C7_YOBS,151,150),'<','MENOR ')          ,;
		QR06->D1_TES                                                 ,;
		QR06->F4_ESTOQUE                                             ,;
		QR06->F4_DUPLIC                                              ,;
		QR06->D1_CF                                                  ,;
		QR06->D1_CONTA                                               ,;
		QR06->CT1_DESC01                                             ,;
		QR06->D1_YAPLIC                                              ,;
		QR06->DAPLIC                                                 ,;
		QR06->D1_COD                                                 ,;
		StrTran(QR06->B1_DESC,'<','MENOR ')                          ,;
		StrTran(QR06->C7_DESCRI,'<','MENOR ')                        ,;
		QR06->D1_CLVL                                                ,;
		QR06->D1_QUANT                                               ,;
		QR06->D1_CUSTO                                               ,;
		QR06->D1_YTAG                                                })

		dbSelectArea("QR06")
		dbSkip()

	End

	QR06->(dbCloseArea())
	Ferase(QRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QRcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "AnaliseCompras - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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
	aAdd(aRegs,{cPerg,"01","Da Data (Digitação) ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data (Digitação)?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Conta            ?","","","mv_ch3","C",20,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})
	aAdd(aRegs,{cPerg,"04","Ate Conta           ?","","","mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})

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
