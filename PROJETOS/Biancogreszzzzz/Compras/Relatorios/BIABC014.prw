#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIABC014
@author Barbara Coelho	  
@since 10/06/2020
@version 1.0
@description base de pedidos de compra do periodo selecionado
@type function
/*/																								

User Function BIABC014()
	Local i
	Private cEnter := CHR(13)+CHR(10)
	private aPergs := {}
	Private oExcel := nil 
	
	If !fValidPerg()
		Return
	EndIf
	
	oExcel := FWMSEXCEL():New()
		
	nxPlan := "Planilha 01"
	nxTabl := "Base de Solicitação de Compras - Período " + DTOC(MV_PAR01) + " - " + DTOC(MV_PAR02)
		
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Armazem"					,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SC Bizagi"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt. Abertura SC Bizagi"	,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "SC Protheus"				,1,1)		
	oExcel:AddColumn(nxPlan, nxTabl, "Dt. Aprovação SC Bizagi"	,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Solicitante Real"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Pedido"					,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt. Emissão Pedido"		,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt. Aprovação Pedido"		,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Item SC"					,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Cod Produto"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descrição Produto"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Quantidade"				,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "UM"						,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Valor"					,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Valor Total"				,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Aprovador"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Cod Fornecedor"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Nome Fornecedor"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TAG"						,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"						,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt. Previsão"				,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Status SC Bizagi"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt. Entrada"				,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Comprador"				,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Observação SC Bizagi"		,1,1)	
	GU004 := ""
	xArqTemp := ""

	GU004 := fSQL()
	xArqTemp := "basePC_" + dtos(MV_PAR01)+"_"+dtos(MV_PAR02)

			
	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
	dbSelectArea("GU04")
	dbGoTop()
	ProcRegua(RecCount())
	
	While !Eof()	
		IncProc()
			oExcel:AddRow(nxPlan, nxTabl, { GU04->Armazem,;
											GU04->SCBizagi,;
											stod(GU04->DtAbertSCBizagi),;
											GU04->SCProtheus,;
											stod(GU04->DtAprovSCBizagi),;
											GU04->SolicitReal,;
											GU04->Pedido,;
											stod(GU04->DtEmisPedido),;
											stod(GU04->DtAprovPedido),; 
											GU04->ItemSC,; 
											GU04->CodProduto,;
											GU04->DescrProduto,;
											GU04->Quantidade,;
											GU04->UM,;
											GU04->Valor,;
											GU04->ValorTotal,;
											GU04->Aprovador,;
											GU04->CodFornecedor,;
											GU04->NomeFornecedor,;
											GU04->TAG,;
											GU04->CLVL,;
											stod(GU04->DtPrevisao),;
											GU04->StatusSCBizagi,;
											stod(GU04->DtEntrada),;
											GU04->Comprador,;
											GU04->ObsSCBizagi}) 
		dbSelectArea("GU04")
		dbSkip()	
	End
		
	GU04->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(GUcIndex+OrdBagExt())          //indice gerado	
		
	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
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

Static Function fSQL
Local sQuery := ""

	sQuery := " SELECT 	C1_LOCAL AS Armazem, " + CEnter
	sQuery += "			C1_YBIZAGI AS SCBizagi,	" + CEnter	
	sQuery += "     	C1_EMISSAO AS DtAbertSCBizagi," + cEnter
	sQuery += "			C1_NUM AS SCProtheus, " + CEnter		
	sQuery += "			C1_YDTINCB AS DtAprovSCBizagi, " + CEnter		
	sQuery += "			C1_SOLICIT AS SolicitReal, " + CEnter
	sQuery += "			C1_PEDIDO AS Pedido, " + CEnter	 
	sQuery += "			C7_EMISSAO AS DtEmisPedido, " + CEnter		 
	sQuery += "			CR_DATALIB AS DtAprovPedido, " + CEnter
	sQuery += "			C1_ITEM AS ItemSC, " + CEnter
	sQuery += "			C1_PRODUTO AS CodProduto," + CEnter
	sQuery += "			C7_DESCRI AS DescrProduto, " + CEnter
	sQuery += "			C1_QUANT AS Quantidade, " + CEnter
	sQuery += "			C1_UM AS UM, " + CEnter
	sQuery += "			C7_PRECO AS Valor, " + CEnter
	sQuery += "			C7_TOTAL AS ValorTotal, " + CEnter
	sQuery += "			AK_NOME AS Aprovador, " + CEnter
	sQuery += "			C1_FORNECE AS CodFornecedor, " + CEnter
	sQuery += "			A2_NOME AS NomeFornecedor, " + CEnter
	sQuery += "			C1_YTAG AS TAG, " + CEnter
	sQuery += "			C1_CLVL AS CLVL, " + CEnter		 
	sQuery += "			C7_YDATCHE AS DtPrevisao, " + CEnter
	sQuery += "			CASE C1_YSTATUS " + CEnter
	sQuery += "				WHEN 'N' THEN 'NORMAL'" + CEnter
	sQuery += "				WHEN 'U' THEN 'URGENTE' " + CEnter
	sQuery += "				WHEN 'E' THEN 'EMERGENCIA'" + CEnter
	sQuery += "				WHEN 'P' THEN 'PARADA' END AS StatusSCBizagi, " + CEnter
	sQuery += "			D1_DTDIGIT AS DtEntrada, " + CEnter		
	sQuery += "			SY1C.Y1_NOME AS Comprador, " + CEnter
	sQuery += "			C1_YOBS ObsSCBizagi" + CEnter
	sQuery += "	   FROM SC1010 SC1 WITH (NOLOCK)" + CEnter
	sQuery += "	  INNER JOIN SC7010 SC7 WITH (NOLOCK) ON (C1_PEDIDO = C7_NUM AND C1_ITEMPED = C7_ITEM AND SC7.D_E_L_E_T_ = '')" + CEnter
	sQuery += "	  INNER JOIN SA2010 SA2 WITH (NOLOCK) ON C7_FORNECE = A2_COD" + CEnter
	sQuery += "	   LEFT JOIN SY1010 SY1C WITH (NOLOCK) ON SC7.C7_USER = SY1C.Y1_USER AND SY1C.D_E_L_E_T_ = '' AND SY1C.Y1_MSBLQL <> 1" + CEnter
	sQuery += "	   LEFT JOIN SCR010 SCR WITH (NOLOCK) ON CR_NUM = C7_NUM AND CR_GRUPO = C7_APROV AND SCR.D_E_L_E_T_ = ''" + CEnter
	sQuery += "	   LEFT JOIN SAK010 SAK WITH (NOLOCK) ON SCR.CR_APROV = SAK.AK_COD  AND SAK.D_E_L_E_T_ = ''" + CEnter
	sQuery += "	   LEFT JOIN SD1010 SD1 WITH (NOLOCK) ON C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SD1.D_E_L_E_T_ = ''" + CEnter
	sQuery += "	  WHERE SC1.D_E_L_E_T_ = ''" + CEnter
	sQuery += "	    AND C1_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter
	sQuery += "	UNION ALL" + CEnter
	sQuery += " SELECT C1_LOCAL AS Armazem, " + CEnter
	sQuery += "		C1_YBIZAGI AS SCBizagi, " + CEnter	
	sQuery += "     C1_EMISSAO AS DtAbertSCBizagi," + cEnter
	sQuery += "		C1_NUM AS SCProtheus, " + CEnter		
	sQuery += "		C1_YDTINCB AS DtAprovSCBizagi," + CEnter		
	sQuery += "		C1_SOLICIT AS SolicitanteReal, " + CEnter
	sQuery += "		C1_PEDIDO AS Pedido, " + CEnter		 
	sQuery += "		C7_EMISSAO AS DtEmissaoPedido," + CEnter		 
	sQuery += "		CR_DATALIB AS DtAprovPedido," + CEnter
	sQuery += "		C1_ITEM AS ItemSC," + CEnter
	sQuery += "		C1_PRODUTO AS CodProduto," + CEnter
	sQuery += "		C7_DESCRI AS DescrProduto, " + CEnter
	sQuery += "		C1_QUANT AS Quantidade," + CEnter
	sQuery += "		C1_UM AS UM, " + CEnter
	sQuery += "		C7_PRECO AS Valor, " + CEnter
	sQuery += "		C7_TOTAL AS ValorTotal," + CEnter
	sQuery += "		AK_NOME AS Aprovador," + CEnter
	sQuery += "		C1_FORNECE AS CodFornecedor," + CEnter
	sQuery += "		A2_NOME AS NomeFornecedor," + CEnter
	sQuery += "		C1_YTAG AS TAG," + CEnter
	sQuery += "		C1_CLVL AS CLVL," + CEnter		 
	sQuery += "		C7_YDATCHE AS DtPrevisao," + CEnter
	sQuery += "		CASE C1_YSTATUS" + CEnter 
	sQuery += "			WHEN 'N' THEN 'NORMAL'" + CEnter
	sQuery += "			WHEN 'U' THEN 'URGENTE' " + CEnter
	sQuery += "			WHEN 'E' THEN 'EMERGENCIA'" + CEnter
	sQuery += "			WHEN 'P' THEN 'PARADA' END AS StatusSCBizagi," + CEnter
	sQuery += "		D1_DTDIGIT AS DtEntrada, " + CEnter		
	sQuery += "		SY1C.Y1_NOME AS Comprador, " + CEnter
	sQuery += "		C1_YOBS ObsSCBizagi" + CEnter
	sQuery += "		FROM SC1050 SC1 WITH (NOLOCK)" + CEnter
	sQuery += "		INNER JOIN SC7050 SC7 WITH (NOLOCK) ON (C1_PEDIDO = C7_NUM AND C1_ITEMPED = C7_ITEM AND SC7.D_E_L_E_T_ = '')" + CEnter
	sQuery += "		INNER JOIN SA2010 SA2 WITH (NOLOCK) ON C7_FORNECE = A2_COD" + CEnter
	sQuery += "		LEFT JOIN SY1010 SY1C WITH (NOLOCK) ON SC7.C7_USER = SY1C.Y1_USER AND SY1C.D_E_L_E_T_ = '' AND SY1C.Y1_MSBLQL <> 1" + CEnter
	sQuery += "		LEFT JOIN SCR010 SCR WITH (NOLOCK) ON CR_NUM = C7_NUM AND CR_GRUPO = C7_APROV AND SCR.D_E_L_E_T_ = ''" + CEnter
	sQuery += "		LEFT JOIN SAK010 SAK WITH (NOLOCK) ON SCR.CR_APROV = SAK.AK_COD  AND SAK.D_E_L_E_T_ = ''" + CEnter
	sQuery += "	    LEFT JOIN SD1010 SD1 WITH (NOLOCK) ON C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SD1.D_E_L_E_T_ = ''" + CEnter
	sQuery += "		WHERE SC1.D_E_L_E_T_ = ''" + CEnter
	sQuery += "		AND C1_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter

Return sQuery

Static Function fValidPerg()

	local cLoad	    := "BIABC014"
	local cFileName := RetCodUsr() + "_SolicitCompra_"+cEmpAnt
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	
	aAdd( aPergs ,{1,"Dt Emissão Inicial ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Dt Emissão Final   ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	

	If ParamBox(aPergs ,"Controle de Solicitações de Compra ",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf
Return lRet