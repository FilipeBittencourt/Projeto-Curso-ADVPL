#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA758
@author Marcos Alberto Soprani
@since 20/02/14
@version 1.0
@description Conciliar MODs apropriadas
@type function
/*/

User Function BIA758()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA758"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA758",fPerg)

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Concilia o Saldo em estoque (qtd e custo) do " + MV_PAR01 + " - " + Alltrim(SM0->M0_NOME)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOC"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QFIM"           ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "VFIM"           ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CTA"            ,1,1)

	FH009 := " SELECT B2_COD PRODUTO,
	FH009 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	FH009 += "        B2_LOCAL LOC,
	FH009 += "        B2_QFIM QFIM,
	FH009 += "        B2_VFIM1 VFIM,
	FH009 += "        B1_CONTA CTA
	FH009 += "   FROM "+RetSqlName("SB2")+" SB2
	FH009 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	FH009 += "                       AND B1_COD = B2_COD
	FH009 += "                       AND B1_TIPO = '"+MV_PAR01+"'
	FH009 += "                       AND SB1.D_E_L_E_T_ = ' '
	FH009 += "  WHERE B2_FILIAL = '"+xFilial("SB2")+"'
	FH009 += "    AND ( B2_QFIM <> 0 OR B2_VFIM1 <> 0 )
	FH009 += "    AND SB2.D_E_L_E_T_ = ' '
	FHcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,FH009),'FH09',.F.,.T.)
	dbSelectArea("FH09")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { FH09->PRODUTO, FH09->DESCR, FH09->LOC, FH09->QFIM, FH09->VFIM, FH09->CTA })

		dbSelectArea("FH09")
		dbSkip()

	End

	FH09->(dbCloseArea())
	Ferase(FHcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(FHcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "saldoestfim - " + cEmpAnt + " - " + MV_PAR01

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
	aAdd(aRegs,{cPerg,"01","Tipo de Produto      ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","02"})
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
