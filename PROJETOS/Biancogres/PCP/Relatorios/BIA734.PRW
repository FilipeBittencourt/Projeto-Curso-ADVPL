#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA734
@author Marcos Alberto Soprani
@since 30/08/13
@version 1.1
@description Listagem de etiquetas ainda não importadas endereçados na rua
.            RETIDO
@type function
/*/

User Function BIA734()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	If cEmpAnt == "01"
		kt_BsDad := "DADOSEOS"
		kt_Emp   := "BG"
	ElseIf cEmpAnt == "05"
		kt_BsDad := "DADOS_05_EOS"
		kt_Emp   := "IN"
	ElseIf cEmpAnt == "14"
		kt_BsDad := "DADOS_14_EOS"
		kt_Emp   := "VN"
	Else
		MsgINFO("Empresa não configurada para apontamento automático de Cerâmica!!!")
		Return
	EndIf

	nxPlan := "RETIDO"
	nxTabl := "RETIDO - " + Transform(GravaData( dDataBase, .F., 1 ), "@R 99-99-99")

	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMPR"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ETIQUETA"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "IDECO"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TRANSAÇÃO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRIÇÃO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOTEPROD"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2,.T.)
	oExcel:AddColumn(nxPlan, nxTabl, "DTREF"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "HRREF"           ,1,1)

	JK009 := " SELECT '"+kt_Emp+"' EMPR,
	JK009 += "        A.CE_NUMERO_DOCTO ETIQUET,
	JK009 += "        A.ID_MOV_PROD IDECO,
	JK009 += "        A.COD_TRANSACAO TRANSAC,
	JK009 += "        A.COD_PRODUTO PRODUT,
	JK009 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	JK009 += "        A.CE_LOTE LOTEPR,
	JK009 += "        A.CE_QTDADE QUANT,
	JK009 += "        Convert(Char(10),convert(datetime, SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112), 1, 10)),103) DTREF,
	JK009 += "        SUBSTRING(CONVERT(VARCHAR(16), B.ETIQ_DATA, 120), 12, 5) HRREF
	JK009 += "   FROM "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A
	JK009 += "   JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA
	JK009 += "                                       AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO
	JK009 += "   INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = A.COD_PRODUTO COLLATE Latin1_General_BIN
	JK009 += "  WHERE A.ID_CIA = 1
	JK009 += "    AND ( ( A.COD_TRANSACAO IN('1','20') AND A.CE_DOCTO <> 'SA') OR ( A.COD_TRANSACAO = 64 AND A.CE_DOCTO = 'CP' ) )
	JK009 += "    AND B.ETIQ_TRANSITO_PRODUCAO = 0
	JK009 += "    AND A.CE_LOTE <> ' '
	JK009 += "    AND B.COD_ENDERECO IN ( 'RETIDO' )
	JK009 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, CONVERT(VARCHAR(10), GETDATE()-30, 112)+' 06:00', 120)
	JK009 += "    AND CONVERT(SMALLDATETIME, A.CE_DATA_MOVIMENTO, 120) >= CONVERT(SMALLDATETIME, '20110510 06:00', 120)
	JK009 += "    AND ID_MOV_PROD NOT IN (SELECT D3_YIDECO
	JK009 += "                              FROM "+RetSqlName("SD3")+" SD3
	JK009 += "                             WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'
	JK009 += "                               AND SD3.D3_YIDECO <> ' '
	JK009 += "                               AND SD3.D3_YORIMOV = 'PR0'
	JK009 += "                               AND SD3.D3_ESTORNO = ' '
	JK009 += "                               AND SD3.D_E_L_E_T_ = ' ')
	JK009 += "    AND A.CE_QTDADE > 0
	JKcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,JK009),'JK09',.F.,.T.)
	dbSelectArea("JK09")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { JK09->EMPR, JK09->ETIQUET, JK09->IDECO, JK09->TRANSAC, JK09->PRODUT, JK09->DESCR, JK09->LOTEPR, JK09->QUANT, JK09->DTREF, JK09->HRREF })

		dbSelectArea("JK09")
		dbSkip()

	End

	JK09->(dbCloseArea())
	Ferase(JKcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(JKcIndex+OrdBagExt())          //indice gerado

	xArqTemp := nxPlan + dtos(dDataBase)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml"  )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return
