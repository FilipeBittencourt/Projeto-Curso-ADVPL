#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA763
@author Marcos Alberto Soprani
@since 05/03/16
@version 1.1
@description Acompanhar cancelamento e etiquetas por motivo e envolvidos.
@type function
/*/

User Function BIA763()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local xt

	fPerg := "BIA763"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Etiquetas canceladas: de " + dtoc(MV_PAR01) + " a " + dtoc(MV_PAR02) + ". Empresa: " + Alltrim(SM0->M0_NOME)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMPR"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ETIQUET"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "IDECO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TRANSAC"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUT"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOTEPR"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MOTCANC"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "IDCANC"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTCANC"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUEMIMPR"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TURMA"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DIAS"             ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QUEMSOLIC"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUEMACEIT"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTACEITE"         ,1,1)

	If cEmpAnt == "01"
		kt_BsDad := "DADOSEOS"
	ElseIf cEmpAnt == "05"
		kt_BsDad := "DADOS_05_EOS"
	Else
		MsgINFO("Empresa não configurada para apontamento automático de Cerâmica!!!")
		Return
	EndIf

	NV002 := " SELECT 'BG' EMPR,
	NV002 += "        A.CE_NUMERO_DOCTO ETIQUET,
	NV002 += "        A.ID_MOV_PROD IDECO,
	NV002 += "        A.COD_TRANSACAO TRANSAC,
	NV002 += "        A.COD_PRODUTO PRODUT,
	NV002 += "        (SELECT SUBSTRING(B1_DESC,1,50)
	NV002 += "           FROM " + RetSqlName("SB1")
	NV002 += "          WHERE B1_FILIAL = '"+xFilial("SB1")+"'
	NV002 += "            AND B1_COD COLLATE Latin1_General_BIN = A.COD_PRODUTO
	NV002 += "            AND D_E_L_E_T_ = ' ') DESCR,
	NV002 += "        A.CE_LOTE LOTEPR,
	NV002 += "        A.CE_QTDADE QUANT,
	NV002 += "        B.ETIQ_DATA EMISSAO,
	NV002 += "        B.etiq_motivo_cancela MOTCANC,
	NV002 += "        B.id_motivo_cancela IDCANC,
	NV002 += "        B.etiq_data_cancelada DTCANC,
	NV002 += "        B.etiq_usuario QUEMIMPR,
	NV002 += "        B.etiq_turma TURMA,
	NV002 += "        B.etiq_forno FORNO,
	NV002 += "        ROUND(CONVERT(FLOAT,DATEDIFF(SECOND,B.ETIQ_DATA,etiq_data_cancelada))/60/60/24,2)  DIAS,
	NV002 += "        C.sc_usuario QUEMSOLIC,
	NV002 += "        C.sc_usuario_aceite QUEMACEIT,
	NV002 += "        C.sc_data_aceite DTACEITE
	NV002 += "   FROM "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A
	NV002 += "   JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA
	NV002 += "                                       AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO
	NV002 += "   JOIN "+kt_BsDad+"..cep_solicitacao_cancelamento C ON C.cod_etiqueta = A.CE_NUMERO_DOCTO
	NV002 += "  WHERE A.ID_CIA = 1
	NV002 += "    AND A.COD_TRANSACAO = 64
	NV002 += "    AND A.CE_DOCTO = 'CP'
	NV002 += "    AND B.ETIQ_TRANSITO_PRODUCAO = 0
	NV002 += "    AND SUBSTRING(CONVERT(VARCHAR(10), B.etiq_data_cancelada, 112), 1, 10) BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	NVcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,NV002),'NV02',.F.,.T.)
	dbSelectArea("NV02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { NV02->EMPR, NV02->ETIQUET, NV02->IDECO, NV02->TRANSAC, NV02->PRODUT, NV02->DESCR, NV02->LOTEPR, NV02->QUANT, NV02->EMISSAO, NV02->MOTCANC, NV02->IDCANC, NV02->DTCANC, NV02->QUEMIMPR, NV02->TURMA, NV02->FORNO, NV02->DIAS, NV02->QUEMSOLIC, NV02->QUEMACEIT, NV02->DTACEITE })

		dbSelectArea("NV02")
		dbSkip()

	End

	NV02->(dbCloseArea())
	Ferase(NVcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(NVcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "etiquetas-canceladas " + dtos(MV_PAR01) + " a " + dtos(MV_PAR02) + "-" + Alltrim(SM0->M0_NOME)

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
