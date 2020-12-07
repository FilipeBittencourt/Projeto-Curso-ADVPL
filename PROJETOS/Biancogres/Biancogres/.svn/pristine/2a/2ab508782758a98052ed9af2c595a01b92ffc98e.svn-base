#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA759
@author Marcos Alberto Soprani
@since 21/02/14
@version 1.0
@description Conciliar TM 010
@type function
/*/

User Function BIA759()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA759"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA759",fPerg)

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Conciliar TM 010 " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "TAM"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_EMISSAO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_NUMSEQ"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_COD"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "B1_TIPO"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUM_OP"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_OP"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TM_010"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TM_999_MP"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TM_999_PP"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TM_999_MOD"        ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TM_499"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "OUTROS"            ,3,2)

	KS006 := " SELECT LEN(RTRIM(D3_COD)) TAM,
	KS006 += "        TAB.*,
	KS006 += "        B1_TIPO,
	KS006 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	KS006 += "        ISNULL((SELECT D3_OP
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM = '010'
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) NUM_OP,
	KS006 += "        ISNULL((SELECT D3_QUANT
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM = '010'
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) QTD_OP,
	KS006 += "        ISNULL((SELECT SUM(D3_CUSTO1) CUSTO
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_OP <> '             '
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM = '010'
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) TM_010,
	KS006 += "        ISNULL((SELECT SUM(D3_CUSTO1) CUSTO
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_OP <> '             '
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM = '999'
	KS006 += "                    AND D3_TIPO <> 'PP'
	KS006 += "                    AND SUBSTRING(D3_COD,1,3) <> 'MOD'
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) TM_999_MP,
	KS006 += "        ISNULL((SELECT SUM(D3_CUSTO1) CUSTO
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_OP <> '             '
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM = '999'
	KS006 += "                    AND D3_TIPO = 'PP'
	KS006 += "                    AND SUBSTRING(D3_COD,1,3) <> 'MOD'
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) TM_999_PP,
	KS006 += "        ISNULL((SELECT SUM(D3_CUSTO1) CUSTO
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_OP <> '             '
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM = '999'
	KS006 += "                    AND SUBSTRING(D3_COD,1,3) = 'MOD'
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) TM_999_MOD,
	KS006 += "        ISNULL((SELECT SUM(D3_CUSTO1) CUSTO
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_OP <> '             '
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM = '499'
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) TM_499,
	KS006 += "        ISNULL((SELECT SUM(D3_CUSTO1) CUSTO
	KS006 += "                   FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	KS006 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "                    AND D3_OP <> '             '
	KS006 += "                    AND D3_NUMSEQ = TAB.D3_NUMSEQ
	KS006 += "                    AND D3_TM NOT IN('010','999','499')
	KS006 += "                    AND D3_ESTORNO = ' '
	KS006 += "                    AND D_E_L_E_T_ = ' '), 0) OUTROS
	KS006 += "   FROM (SELECT D3_EMISSAO, D3_NUMSEQ, D3_COD
	KS006 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	KS006 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	KS006 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KS006 += "            AND D3_OP <> '             '
	KS006 += "            AND D3_TIPO <> 'PI'
	KS006 += "            AND D3_TM = '010'
	KS006 += "            AND D_E_L_E_T_ = ' '
	KS006 += "          GROUP BY D3_EMISSAO, D3_NUMSEQ, D3_COD) AS TAB
	KS006 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	KS006 += "                       AND B1_COD = D3_COD
	KS006 += "                       AND SB1.D_E_L_E_T_ = ' '
	KScIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KS006),'KS06',.F.,.T.)
	dbSelectArea("KS06")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { KS06->TAM, dtoc(stod(KS06->D3_EMISSAO)), KS06->D3_NUMSEQ, KS06->D3_COD, KS06->B1_TIPO, KS06->DESCR, KS06->NUM_OP, KS06->QTD_OP, KS06->TM_010, KS06->TM_999_MP, KS06->TM_999_PP, KS06->TM_999_MOD, KS06->TM_499, KS06->OUTROS })

		dbSelectArea("KS06")
		dbSkip()

	End

	KS06->(dbCloseArea())
	Ferase(KScIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(KScIndex+OrdBagExt())          //indice gerado

	xArqTemp := "concilia-tm-010 " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "-" + StrZero(Year(MV_PAR02) ,4) + "-" + Substr(SM0->M0_NOME,1,2)

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
