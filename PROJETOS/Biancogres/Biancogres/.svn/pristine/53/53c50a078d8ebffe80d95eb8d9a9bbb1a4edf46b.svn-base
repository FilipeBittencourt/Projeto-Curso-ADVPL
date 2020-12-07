#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIABC013
@author Barbara Coelho	  
@since 10/06/2020
@version 1.0
@description base de pedidos de venda do mês selecionado - Marcas: Bianco e Incesa
@type function
/*/																								

User Function BIABC013()
	Local i
	Private cEnter := CHR(13)+CHR(10)
	private aPergs := {}
	Private oExcel 	
	
	If !fValidPerg()
		Return
	EndIf
	
	For I := 1 To 2	
		oExcel := nil 	
		oExcel := FWMSEXCEL():New()
		
		nxPlan := "Planilha 01"
		nxTabl := "Base de Pedidos - mês " + MesExtenso(Month2Str(MV_PAR01))+"/"+ Year2Str(MV_PAR01)
		
		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "EMPRESA_ORI"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "GRUPO"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESC_GRUPO"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLIENTE"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NOME"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "SEGMENTO"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CATEGORIA"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DCAT"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "VENDEDOR"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NOME_VEND"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PEDIDO"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "TIPO_PEDIDO"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "COND_PG"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "ITEM"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PRF"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NF"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"		,1,4)
		oExcel:AddColumn(nxPlan, nxTabl, "STATUS_PROD"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESC_PROD"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESC_FORM"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PACOTE"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "FC"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DCAT_PEDIDO"	,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "DCAT_TABELA"	,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "DGER"			,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "DPAL"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DNV"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DREG"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESP"			,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "DTOT"			,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "DAO"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DVERBA"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DOUTAI"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "ALIQ_ICMS"    ,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "ALIQ_COF"		,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "ALIQ_PIS"		,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "ALIQ_COMISSAO",3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "QUANT"		,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "VALOR"		,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "PRC_VENDA"	,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "PRC_TAB"		,3,2, .T.)
	
		GU004 := ""
		xArqTemp := ""

		if I = 1 	
			GU004 := fSQLBianco()
			xArqTemp := "base_" + substr(dtos(MV_PAR01),1,6) + "_Biancogres"
		else
			GU004 := fSQLIncesa()
			xArqTemp := "base_" + substr(dtos(MV_PAR01),1,6) + "_Incesa"
		endif
			
		GUcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
		dbSelectArea("GU04")
		dbGoTop()
		ProcRegua(RecCount())
		
		While !Eof()	
			IncProc()
				oExcel:AddRow(nxPlan, nxTabl, { GU04->EMPRESA_ORI,;
												GU04->GRUPO,; 
												GU04->DESC_GRUPO,;
												GU04->CLIENTE,;
												GU04->NOME,;
												GU04->SEGMENTO,;
												GU04->CATEGORIA,;
												GU04->DCAT,;
												GU04->VENDEDOR,;
												GU04->NOME_VEND,;
												GU04->PEDIDO,;
												GU04->TIPO_PEDIDO,;
												GU04->COND_PG,;
												GU04->ITEM,;
												GU04->PRF,;
												GU04->NF,;
												GU04->EMISSAO,;
												GU04->STATUS_PROD, ;
												GU04->PRODUTO,;
												GU04->DESC_PROD,;
												GU04->FORMATO,;
												GU04->DESC_FORM,;
												GU04->PACOTE,;
												GU04->FC,;
												Round(GU04->DCAT_PEDIDO,2),;
												Round(GU04->DCAT_TABELA,2),;
												Round(GU04->DGER,2),;
												GU04->DPAL,;
												GU04->DNV,;
												GU04->DREG,;
												Round(GU04->DESP,2),;
												Round(GU04->DTOT,2),;
												GU04->DAO,;
												GU04->DVERBA,;
												GU04->DOUTAI,;
												Round(GU04->ALIQ_ICMS,2),;
												Round(GU04->ALIQ_COF,2),;
												Round(GU04->ALIQ_PIS,2),;
												Round(GU04->ALIQ_COMISSAO,2),;
												Round(GU04->QUANT,2),;
												Round(GU04->VALOR,2),;
												Round(GU04->PRC_VENDA,2),;
												Round(GU04->PRC_TAB,2)}) 
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
	Next
Return

Static Function fSQLBianco
Local sQuery := ""

	sQuery := " WITH tab_ped AS " + cEnter
	sQuery += " (SELECT EMPRESA_ORIGEM = 'BIANCOGRES' " + cEnter
	sQuery += "		, CLIENTE = C5_CLIENTE " + cEnter
	sQuery += "		, LOJA = C5_LOJACLI " + cEnter
	sQuery += "		, VENDEDOR = C5_VEND1 " + cEnter
	sQuery += "		, PEDIDO = C6_NUM " + cEnter
	sQuery += "		, TIPO_PEDIDO = C5_YSUBTP " + cEnter
	sQuery += "		, COND_PG = C5_CONDPAG " + cEnter
	sQuery += "		, ITEM = C6_ITEM " + cEnter
	sQuery += "		, PRF = D2_SERIE " + cEnter
	sQuery += "		, NF = D2_DOC " + cEnter
	sQuery += "		, EMISSAO = D2_EMISSAO " + cEnter
	sQuery += "		, STATUS_PROD = (CASE WHEN B1_YSTATUS = '1' THEN 'ATIVO' WHEN B1_YSTATUS = '2' THEN 'DESCONTINUADO' WHEN B1_YSTATUS = '3' THEN 'OBSOLETO' ELSE '' END) " + cEnter
	sQuery += "		, PRODUTO = C6_PRODUTO " + cEnter
	sQuery += "		, DESC_PROD = C6_DESCRI " + cEnter
	sQuery += "		, FORMATO = B1_YFORMAT " + cEnter
	sQuery += "		, DESC_FORM = ZZ6_DESC " + cEnter
	sQuery += "		, PACOTE = B1_YPCGMR3 " + cEnter
	sQuery += "		, FC = ZA4_FC " + cEnter
	sQuery += "		, DCAT = C6_YDCAT " + cEnter
	sQuery += "		, DGER = C6_YDMIX " + cEnter
	sQuery += "		, DPAL = C6_YDPAL " + cEnter
	sQuery += "		, DNV = C6_YDNV " + cEnter
	sQuery += "		, DREG = C6_YDREG " + cEnter
	sQuery += "		, DESP = C6_YDESP " + cEnter
	sQuery += "		, DTOT = C6_YDESC " + cEnter
	sQuery += "		, DAO = C6_YDACO " + cEnter
	sQuery += "		, DVERBA = C6_YDVER " + cEnter
	sQuery += "		, DOUTAI = C6_YDAI " + cEnter
	sQuery += "		, ALIQ_ICMS = D2_PICM " + cEnter
	sQuery += "		, ALIQ_COF = D2_ALQIMP5 " + cEnter
	sQuery += "		, ALIQ_PIS = D2_ALQIMP6 " + cEnter
	sQuery += "		, ALIQ_COMISSAO = D2_COMIS1 " + cEnter
	sQuery += "		, QUANT = D2_QUANT " + cEnter
	sQuery += "		, VALOR = D2_TOTAL " + cEnter
	sQuery += "		, PRC_VENDA = D2_PRCVEN " + cEnter
	sQuery += "		, PRC_TAB = D2_YPRCTAB " + cEnter
	sQuery += "		, EMISS_PED = C5_EMISSAO " + cEnter
	sQuery += "		, MARCA_PED = C5_YEMP " + cEnter
	sQuery += "	FROM SD2010 SD2 (NOLOCK) " + cEnter
	sQuery += "	INNER JOIN SC6010 SC6 (NOLOCK) ON SC6.C6_FILIAL = SD2.D2_FILIAL " + cEnter
	sQuery += "	AND SC6.C6_NUM = SD2.D2_PEDIDO " + cEnter
	sQuery += "	AND SC6.C6_ITEM = SD2.D2_ITEMPV " + cEnter
	sQuery += "	AND SC6.D_E_L_E_T_ = '' " + cEnter
	sQuery += "	INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.B1_COD = SC6.C6_PRODUTO " + cEnter
	sQuery += "	AND SB1.B1_TIPO = 'PA' " + cEnter
	sQuery += "	AND SB1.D_E_L_E_T_ = '' " + cEnter
	sQuery += "	INNER JOIN SC5010 SC5 (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL " + cEnter
	sQuery += "	AND SC5.C5_NUM = SC6.C6_NUM  " + cEnter
	sQuery += "	AND SC5.D_E_L_E_T_ = '' " + cEnter
	sQuery += "	INNER JOIN ZZ6010 ZZ6 (NOLOCK) ON ZZ6.ZZ6_COD = SB1.B1_YFORMAT " + cEnter
	sQuery += "	AND ZZ6.D_E_L_E_T_ = '' " + cEnter
	sQuery += "	LEFT JOIN ZA4010 ZA4 (NOLOCK) ON ZA4.ZA4_PEDIDO = SC6.C6_NUM " + cEnter
	sQuery += "	AND ZA4.ZA4_ITEM = SC6.C6_ITEM " + cEnter
	sQuery += "	AND ZA4.ZA4_TIPO = 'DCAT' " + cEnter
	sQuery += "	AND ZA4.ZA4_STATUS = '' " + cEnter
	sQuery += "	AND ZA4.D_E_L_E_T_ = '' " + cEnter
	sQuery += "	WHERE D2_FILIAL = '01' " + cEnter
	sQuery += "	AND SD2.D2_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter
	sQuery += "	AND SD2.D_E_L_E_T_ = '' " + cEnter
	sQuery += "	UNION ALL " + cEnter
	sQuery += "	SELECT EMPRESA_ORIGEM = 'LM' " + cEnter
	sQuery += "		, CLIENTE = C5_CLIENTE " + cEnter
	sQuery += "		, LOJA = C5_LOJACLI " + cEnter
	sQuery += "		, VENDEDOR = C5_VEND1 " + cEnter
	sQuery += "		, PEDIDO = C6_NUM " + cEnter
	sQuery += "		, TIPO_PEDIDO = C5_YSUBTP " + cEnter
	sQuery += "		, COND_PG = C5_CONDPAG " + cEnter
	sQuery += "		, ITEM = C6_ITEM " + cEnter
	sQuery += "		, PRF = D2_SERIE " + cEnter
	sQuery += "		, NF = D2_DOC " + cEnter
	sQuery += "		, EMISSAO = D2_EMISSAO " + cEnter
	sQuery += "		, STATUS_PROD = (CASE WHEN B1_YSTATUS = '1' THEN 'ATIVO' WHEN B1_YSTATUS = '2' THEN 'DESCONTINUADO' WHEN B1_YSTATUS = '3' THEN 'OBSOLETO' ELSE '' END) " + cEnter
	sQuery += "		, PRODUTO = C6_PRODUTO " + cEnter
	sQuery += "		, DESC_PROD = C6_DESCRI " + cEnter
	sQuery += "		, FORMATO = B1_YFORMAT " + cEnter
	sQuery += "		, DESC_FORM = ZZ6_DESC " + cEnter
	sQuery += "		, PACOTE = B1_YPCGMR3 " + cEnter
	sQuery += "		, FC = ZA4_FC " + cEnter
	sQuery += "		, DCAT = C6_YDCAT " + cEnter
	sQuery += "		, DGER = C6_YDMIX " + cEnter
	sQuery += "		, DPAL = C6_YDPAL " + cEnter
	sQuery += "		, DNV = C6_YDNV " + cEnter
	sQuery += "		, DREG = C6_YDREG " + cEnter
	sQuery += "		, DESP = C6_YDESP " + cEnter
	sQuery += "		, DTOT = C6_YDESC " + cEnter
	sQuery += "		, DAO = C6_YDACO " + cEnter
	sQuery += "		, DVERBA = C6_YDVER " + cEnter
	sQuery += "		, DOUTAI = C6_YDAI" + cEnter
	sQuery += "		, ALIQ_ICMS = D2_PICM" + cEnter
	sQuery += "		, ALIQ_COF = D2_ALQIMP5" + cEnter
	sQuery += "		, ALIQ_PIS = D2_ALQIMP6" + cEnter
	sQuery += "		, ALIQ_COMISSAO = D2_COMIS1" + cEnter
	sQuery += "		, QUANT = D2_QUANT" + cEnter
	sQuery += "		, VALOR = D2_TOTAL" + cEnter
	sQuery += "		, PRC_VENDA = D2_PRCVEN" + cEnter
	sQuery += "		, PRC_TAB = D2_YPRCTAB" + cEnter
	sQuery += "		, EMISS_PED = C5_EMISSAO" + cEnter
	sQuery += "		, MARCA_PED = C5_YEMP" + cEnter
	sQuery += "	FROM SD2070 SD2 (NOLOCK)" + cEnter
	sQuery += "	INNER JOIN SC6070 SC6 (NOLOCK) ON SC6.C6_FILIAL = SD2.D2_FILIAL" + cEnter
	sQuery += "	AND SC6.C6_NUM = SD2.D2_PEDIDO" + cEnter
	sQuery += "	AND SC6.C6_ITEM = SD2.D2_ITEMPV" + cEnter
	sQuery += "	AND SC6.D_E_L_E_T_ = ''" + cEnter
	sQuery += "	INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.B1_COD = SC6.C6_PRODUTO" + cEnter
	sQuery += "	AND SB1.B1_TIPO = 'PA'" + cEnter
	sQuery += "	AND SB1.D_E_L_E_T_ = ''" + cEnter
	sQuery += "	INNER JOIN SC5070 SC5 (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL" + cEnter
	sQuery += "	AND SC5.C5_NUM = SC6.C6_NUM" + cEnter
	sQuery += "	AND SC5.D_E_L_E_T_ = ''" + cEnter
	sQuery += "	INNER JOIN ZZ6010 ZZ6 (NOLOCK) ON ZZ6.ZZ6_COD = SB1.B1_YFORMAT" + cEnter
	sQuery += "	AND ZZ6.D_E_L_E_T_ = ''" + cEnter
	sQuery += "	LEFT JOIN ZA4070 ZA4 (NOLOCK) ON ZA4.ZA4_PEDIDO = SC6.C6_NUM" + cEnter
	sQuery += "	AND ZA4.ZA4_ITEM = SC6.C6_ITEM" + cEnter
	sQuery += "	AND ZA4.ZA4_TIPO = 'DCAT'" + cEnter
	sQuery += "	AND ZA4.ZA4_STATUS = ''" + cEnter
	sQuery += "	AND ZA4.D_E_L_E_T_ = ''" + cEnter
	sQuery += "	WHERE SD2.D2_FILIAL = '01'" + cEnter
	sQuery += "	AND SD2.D2_YEMP = '0101' " + cEnter
	sQuery += "	AND SD2.D2_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter
	sQuery += "	AND SD2.D_E_L_E_T_ = '')" + cEnter
	sQuery += "	, ZA0 AS" + cEnter
	sQuery += "	(SELECT '0101' MARCA, * FROM ZA0010 WHERE D_E_L_E_T_ = ''  AND ZA0_MARCA IN ('0101','XXXX') AND D_E_L_E_T_ = ''" + cEnter
	sQuery += "	UNION ALL" + cEnter
	sQuery += "	SELECT '0501' MARCA, * FROM ZA0010 WHERE D_E_L_E_T_ = ''  AND ZA0_MARCA IN ('0501','05XX','XXXX') AND D_E_L_E_T_ = ''" + cEnter
	sQuery += "	UNION ALL" + cEnter
	sQuery += "	SELECT '0599' MARCA, * FROM ZA0010 WHERE D_E_L_E_T_ = ''  AND ZA0_MARCA IN ('0599','05XX','XXXX') AND D_E_L_E_T_ = '')" + cEnter
	sQuery += "	SELECT EMPRESA_ORIGEM" + cEnter
	sQuery += "		, GRUPO  = A1_GRPVEN" + cEnter
	sQuery += "		, DESC_GRUPO = isnull(ACY_DESCRI, 'SEM GRUPO')" + cEnter
	sQuery += "		, CLIENTE = A1_COD" + cEnter
	sQuery += "		, NOME = A1_NOME" + cEnter
	sQuery += "		, SEGMENTO = A1_YTPSEG" + cEnter
	sQuery += "		, CATEGORIA = A1_YCAT" + cEnter
	sQuery += "		, DCAT = ZA0_PDESC" + cEnter
	sQuery += "		, tab_ped.VENDEDOR" + cEnter
	sQuery += "		, NOME_VEND = SA3.A3_NOME" + cEnter
	sQuery += "		, PEDIDO" + cEnter
	sQuery += "		, TIPO_PEDIDO" + cEnter
	sQuery += "		, COND_PG" + cEnter
	sQuery += "		, ITEM" + cEnter
	sQuery += "		, PRF" + cEnter
	sQuery += "		, NF" + cEnter
	sQuery += "		, EMISSAO = convert(varchar(10), convert(date, EMISSAO), 103)" + cEnter
	sQuery += "		, STATUS_PROD" + cEnter
	sQuery += "		, PRODUTO" + cEnter
	sQuery += "		, DESC_PROD" + cEnter
	sQuery += "		, FORMATO" + cEnter
	sQuery += "		, DESC_FORM" + cEnter
	sQuery += "		, PACOTE" + cEnter
	sQuery += "		, ISNULL(FC,0) FC" + cEnter
	sQuery += "		, DCAT_PEDIDO = DCAT" + cEnter
	sQuery += "		, DCAT_TABELA = ZA0_PDESC" + cEnter
	sQuery += "		, DGER" + cEnter
	sQuery += "		, DPAL" + cEnter
	sQuery += "		, DNV" + cEnter
	sQuery += "		, DREG" + cEnter
	sQuery += "		, DESP" + cEnter
	sQuery += "		, DTOT" + cEnter
	sQuery += "		, DAO" + cEnter
	sQuery += "		, DVERBA" + cEnter
	sQuery += "		, DOUTAI" + cEnter
	sQuery += "		, ALIQ_ICMS" + cEnter
	sQuery += "		, ALIQ_COF" + cEnter
	sQuery += "		, ALIQ_PIS" + cEnter
	sQuery += "		, ALIQ_COMISSAO" + cEnter
	sQuery += "		, QUANT" + cEnter
	sQuery += "		, VALOR" + cEnter
	sQuery += "		, PRC_VENDA" + cEnter
	sQuery += "		, PRC_TAB" + cEnter
	sQuery += "	FROM tab_ped" + cEnter
	sQuery += "	INNER JOIN SA1010 SA1 (NOLOCK) ON SA1.A1_FILIAL = ''" + cEnter
	sQuery += "	AND SA1.A1_COD = tab_ped.CLIENTE" + cEnter
	sQuery += " AND SA1.A1_LOJA = tab_ped.LOJA" + cEnter
	sQuery += "	AND SA1.D_E_L_E_T_ = ''" + cEnter
	sQuery += "	INNER JOIN ZA0 ON ZA0_FILIAL = ''" + cEnter
	sQuery += "	AND ZA0_TIPO = 'DCAT'" + cEnter
	sQuery += "	AND ZA0_CAT = SA1.A1_YCAT" + cEnter
	sQuery += "	AND EMISS_PED BETWEEN ZA0_VIGINI AND ZA0_VIGFIM" + cEnter
	sQuery += "	AND MARCA = MARCA_PED" + cEnter
	sQuery += "	INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.A3_FILIAL = ''" + cEnter
	sQuery += "	AND SA3.A3_COD = tab_ped.VENDEDOR" + cEnter
	sQuery += "	AND SA3.D_E_L_E_T_ = ''" + cEnter
	sQuery += "	LEFT JOIN ACY010 ACY (NOLOCK) ON ACY.ACY_FILIAL = ''" + cEnter
	sQuery += "	AND ACY.ACY_GRPVEN = SA1.A1_GRPVEN" + cEnter
	sQuery += "	AND ACY.D_E_L_E_T_=''" + cEnter
	sQuery += "	ORDER BY EMPRESA_ORIGEM,DESC_GRUPO,VENDEDOR, PEDIDO, ITEM" + cEnter
	
Return sQuery

Static Function fSQLIncesa
Local sQuery := ""
	sQuery := " WITH tab_ped AS " + cEnter
	sQuery += " (SELECT EMPRESA_ORIGEM = 'INCESA' " + cEnter
	sQuery += " 	, CLIENTE = C5_CLIENTE " + cEnter
	sQuery += " 	, LOJA = C5_LOJACLI " + cEnter
	sQuery += " 	, VENDEDOR = C5_VEND1 " + cEnter
	sQuery += " 	, PEDIDO = C6_NUM " + cEnter
	sQuery += " 	, TIPO_PEDIDO = C5_YSUBTP " + cEnter
	sQuery += " 	, COND_PG = C5_CONDPAG " + cEnter
	sQuery += " 	, ITEM = C6_ITEM " + cEnter
	sQuery += " 	, PRF = D2_SERIE " + cEnter
	sQuery += " 	, NF = D2_DOC " + cEnter
	sQuery += " 	, EMISSAO = D2_EMISSAO " + cEnter
	sQuery += " 	, STATUS_PROD = (CASE WHEN B1_YSTATUS = '1' THEN 'ATIVO' WHEN B1_YSTATUS = '2' THEN 'DESCONTINUADO' WHEN B1_YSTATUS = '3' THEN 'OBSOLETO' ELSE '' END) " + cEnter
	sQuery += " 	, PRODUTO = C6_PRODUTO " + cEnter
	sQuery += " 	, DESC_PROD = C6_DESCRI " + cEnter
	sQuery += " 	, FORMATO = B1_YFORMAT " + cEnter
	sQuery += " 	, DESC_FORM = ZZ6_DESC " + cEnter
	sQuery += " 	, PACOTE = B1_YPCGMR3 " + cEnter
	sQuery += " 	, FC = ZA4_FC " + cEnter
	sQuery += " 	, DCAT = C6_YDCAT " + cEnter
	sQuery += " 	, DGER = C6_YDMIX " + cEnter
	sQuery += " 	, DPAL = C6_YDPAL " + cEnter
	sQuery += " 	, DNV = C6_YDNV " + cEnter
	sQuery += " 	, DREG = C6_YDREG " + cEnter
	sQuery += " 	, DESP = C6_YDESP " + cEnter
	sQuery += " 	, DTOT = C6_YDESC " + cEnter
	sQuery += " 	, DAO = C6_YDACO " + cEnter
	sQuery += " 	, DVERBA = C6_YDVER " + cEnter
	sQuery += " 	, DOUTAI = C6_YDAI " + cEnter
	sQuery += " 	, ALIQ_ICMS = D2_PICM " + cEnter
	sQuery += " 	, ALIQ_COF = D2_ALQIMP5 " + cEnter
	sQuery += " 	, ALIQ_PIS = D2_ALQIMP6 " + cEnter
	sQuery += " 	, ALIQ_COMISSAO = D2_COMIS1 " + cEnter
	sQuery += " 	, QUANT = D2_QUANT " + cEnter
	sQuery += " 	, VALOR = D2_TOTAL " + cEnter
	sQuery += " 	, PRC_VENDA = D2_PRCVEN " + cEnter
	sQuery += " 	, PRC_TAB = D2_YPRCTAB " + cEnter
	sQuery += " 	, EMISS_PED = C5_EMISSAO " + cEnter
	sQuery += " 	, MARCA_PED = C5_YEMP " + cEnter
	sQuery += " FROM SD2050 SD2 (NOLOCK) " + cEnter
	sQuery += " 	INNER JOIN SC6050 SC6 (NOLOCK) ON SC6.C6_FILIAL = SD2.D2_FILIAL " + cEnter
	sQuery += " 		AND SC6.C6_NUM = SD2.D2_PEDIDO " + cEnter
	sQuery += " 		AND SC6.C6_ITEM = SD2.D2_ITEMPV " + cEnter
	sQuery += " 		AND SC6.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.B1_COD = SC6.C6_PRODUTO " + cEnter
	sQuery += " 		AND SB1.B1_TIPO = 'PA' " + cEnter
	sQuery += " 		AND SB1.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	INNER JOIN SC5050 SC5 (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL " + cEnter
	sQuery += " 		AND SC5.C5_NUM = SC6.C6_NUM  " + cEnter
	sQuery += " 		AND SC5.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	INNER JOIN ZZ6010 ZZ6 (NOLOCK) ON ZZ6.ZZ6_COD = SB1.B1_YFORMAT " + cEnter
	sQuery += " 		AND ZZ6.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	LEFT JOIN ZA4050 ZA4 (NOLOCK) ON ZA4.ZA4_PEDIDO = SC6.C6_NUM " + cEnter
	sQuery += " 		AND ZA4.ZA4_ITEM = SC6.C6_ITEM " + cEnter
	sQuery += " 		AND ZA4.ZA4_TIPO = 'DCAT' " + cEnter
	sQuery += " 		AND ZA4.ZA4_STATUS = '' " + cEnter
	sQuery += " 		AND ZA4.D_E_L_E_T_ = '' " + cEnter
	sQuery += " WHERE D2_FILIAL = '01' " + cEnter
	sQuery += " 	AND SD2.D2_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter
	sQuery += " 	AND SD2.D_E_L_E_T_ = '' " + cEnter
	sQuery += "  " + cEnter
	sQuery += " UNION ALL " + cEnter
	sQuery += "  " + cEnter
	sQuery += " SELECT EMPRESA_ORIGEM = 'LM' " + cEnter
	sQuery += " 	, CLIENTE = C5_CLIENTE " + cEnter
	sQuery += " 	, LOJA = C5_LOJACLI " + cEnter
	sQuery += " 	, VENDEDOR = C5_VEND1 " + cEnter
	sQuery += " 	, PEDIDO = C6_NUM " + cEnter
	sQuery += " 	, TIPO_PEDIDO = C5_YSUBTP " + cEnter
	sQuery += " 	, COND_PG = C5_CONDPAG " + cEnter
	sQuery += " 	, ITEM = C6_ITEM " + cEnter
	sQuery += " 	, PRF = D2_SERIE " + cEnter
	sQuery += " 	, NF = D2_DOC " + cEnter
	sQuery += " 	, EMISSAO = D2_EMISSAO " + cEnter
	sQuery += " 	, STATUS_PROD = (CASE WHEN B1_YSTATUS = '1' THEN 'ATIVO' WHEN B1_YSTATUS = '2' THEN 'DESCONTINUADO' WHEN B1_YSTATUS = '3' THEN 'OBSOLETO' ELSE '' END) " + cEnter
	sQuery += " 	, PRODUTO = C6_PRODUTO " + cEnter
	sQuery += " 	, DESC_PROD = C6_DESCRI " + cEnter
	sQuery += " 	, FORMATO = B1_YFORMAT " + cEnter
	sQuery += " 	, DESC_FORM = ZZ6_DESC " + cEnter
	sQuery += " 	, PACOTE = B1_YPCGMR3 " + cEnter
	sQuery += " 	, FC = ZA4_FC " + cEnter
	sQuery += " 	, DCAT = C6_YDCAT " + cEnter
	sQuery += " 	, DGER = C6_YDMIX " + cEnter
	sQuery += " 	, DPAL = C6_YDPAL " + cEnter
	sQuery += " 	, DNV = C6_YDNV " + cEnter
	sQuery += " 	, DREG = C6_YDREG " + cEnter
	sQuery += " 	, DESP = C6_YDESP " + cEnter
	sQuery += " 	, DTOT = C6_YDESC " + cEnter
	sQuery += " 	, DAO = C6_YDACO " + cEnter
	sQuery += " 	, DVERBA = C6_YDVER " + cEnter
	sQuery += " 	, DOUTAI = C6_YDAI " + cEnter
	sQuery += " 	, ALIQ_ICMS = D2_PICM " + cEnter
	sQuery += " 	, ALIQ_COF = D2_ALQIMP5 " + cEnter
	sQuery += " 	, ALIQ_PIS = D2_ALQIMP6 " + cEnter
	sQuery += " 	, ALIQ_COMISSAO = D2_COMIS1 " + cEnter
	sQuery += " 	, QUANT = D2_QUANT " + cEnter
	sQuery += " 	, VALOR = D2_TOTAL " + cEnter
	sQuery += " 	, PRC_VENDA = D2_PRCVEN " + cEnter
	sQuery += " 	, PRC_TAB = D2_YPRCTAB " + cEnter
	sQuery += " 	, EMISS_PED = C5_EMISSAO " + cEnter
	sQuery += " 	, MARCA_PED = C5_YEMP " + cEnter
	sQuery += " FROM SD2070 SD2 (NOLOCK) " + cEnter
	sQuery += " 	INNER JOIN SC6070 SC6 (NOLOCK) ON SC6.C6_FILIAL = SD2.D2_FILIAL " + cEnter
	sQuery += " 		AND SC6.C6_NUM = SD2.D2_PEDIDO " + cEnter
	sQuery += " 		AND SC6.C6_ITEM = SD2.D2_ITEMPV " + cEnter
	sQuery += " 		AND SC6.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	INNER JOIN SB1010 SB1 (NOLOCK) ON SB1.B1_COD = SC6.C6_PRODUTO " + cEnter
	sQuery += " 		AND SB1.B1_TIPO = 'PA' " + cEnter
	sQuery += " 		AND SB1.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	INNER JOIN SC5070 SC5 (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL " + cEnter
	sQuery += " 		AND SC5.C5_NUM = SC6.C6_NUM " + cEnter
	sQuery += " 		AND SC5.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	INNER JOIN ZZ6010 ZZ6 (NOLOCK) ON ZZ6.ZZ6_COD = SB1.B1_YFORMAT " + cEnter
	sQuery += " 		AND ZZ6.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	LEFT JOIN ZA4070 ZA4 (NOLOCK) ON ZA4.ZA4_PEDIDO = SC6.C6_NUM " + cEnter
	sQuery += " 		AND ZA4.ZA4_ITEM = SC6.C6_ITEM " + cEnter
	sQuery += " 		AND ZA4.ZA4_TIPO = 'DCAT' " + cEnter
	sQuery += " 		AND ZA4.ZA4_STATUS = '' " + cEnter
	sQuery += " 		AND ZA4.D_E_L_E_T_ = '' " + cEnter
	sQuery += " WHERE SD2.D2_FILIAL = '01' " + cEnter
	sQuery += " 	AND SD2.D2_YEMP <> '0101'  " + cEnter
	sQuery += " 	AND SD2.D2_EMISSAO BETWEEN '"+ dtos(MV_PAR01)+ "' AND '"+ dtos(MV_PAR02)+ "'" + CEnter
	sQuery += " 	AND SD2.D_E_L_E_T_ = '') " + cEnter
	sQuery += "  " + cEnter
	sQuery += " , ZA0 AS " + cEnter
	sQuery += " (SELECT '0101' MARCA, * FROM ZA0010 WHERE D_E_L_E_T_ = ''  AND ZA0_MARCA IN ('0101','XXXX') AND D_E_L_E_T_ = '' " + cEnter
	sQuery += " UNION ALL " + cEnter
	sQuery += " SELECT '0501' MARCA, * FROM ZA0010 WHERE D_E_L_E_T_ = ''  AND ZA0_MARCA IN ('0501','05XX','XXXX') AND D_E_L_E_T_ = '' " + cEnter
	sQuery += " UNION ALL " + cEnter
	sQuery += " SELECT '0599' MARCA, * FROM ZA0010 WHERE D_E_L_E_T_ = ''  AND ZA0_MARCA IN ('0599','05XX','XXXX') AND D_E_L_E_T_ = '') " + cEnter
	sQuery += "  " + cEnter
	sQuery += "  " + cEnter
	sQuery += " SELECT EMPRESA_ORIGEM " + cEnter
	sQuery += " 	, GRUPO  = A1_GRPVEN " + cEnter
	sQuery += " 	, DESC_GRUPO = isnull(ACY_DESCRI, 'SEM GRUPO') " + cEnter
	sQuery += " 	, CLIENTE = A1_COD " + cEnter
	sQuery += " 	, NOME = A1_NOME " + cEnter
	sQuery += " 	, SEGMENTO = A1_YTPSEG " + cEnter
	sQuery += " 	, CATEGORIA = A1_YCAT " + cEnter
	sQuery += " 	, DCAT = ZA0_PDESC " + cEnter
	sQuery += " 	, tab_ped.VENDEDOR " + cEnter
	sQuery += " 	, NOME_VEND = SA3.A3_NOME " + cEnter
	sQuery += " 	, PEDIDO " + cEnter
	sQuery += " 	, TIPO_PEDIDO " + cEnter
	sQuery += " 	, COND_PG " + cEnter
	sQuery += " 	, ITEM " + cEnter
	sQuery += " 	, PRF " + cEnter
	sQuery += " 	, NF " + cEnter
	sQuery += " 	, EMISSAO = convert(varchar(10), convert(date, EMISSAO), 103) " + cEnter
	sQuery += " 	, STATUS_PROD " + cEnter
	sQuery += " 	, PRODUTO " + cEnter
	sQuery += " 	, DESC_PROD " + cEnter
	sQuery += " 	, FORMATO " + cEnter
	sQuery += " 	, DESC_FORM " + cEnter
	sQuery += " 	, PACOTE " + cEnter
	sQuery += " 	, ISNULL(FC,0) FC " + cEnter
	sQuery += " 	, DCAT_PEDIDO = DCAT " + cEnter
	sQuery += " 	, DCAT_TABELA = ZA0_PDESC " + cEnter
	sQuery += " 	, DGER " + cEnter
	sQuery += " 	, DPAL " + cEnter
	sQuery += " 	, DNV " + cEnter
	sQuery += " 	, DREG " + cEnter
	sQuery += " 	, DESP " + cEnter
	sQuery += " 	, DTOT " + cEnter
	sQuery += " 	, DAO " + cEnter
	sQuery += " 	, DVERBA " + cEnter
	sQuery += " 	, DOUTAI " + cEnter
	sQuery += " 	, ALIQ_ICMS " + cEnter
	sQuery += " 	, ALIQ_COF " + cEnter
	sQuery += " 	, ALIQ_PIS " + cEnter
	sQuery += " 	, ALIQ_COMISSAO " + cEnter
	sQuery += " 	, QUANT " + cEnter
	sQuery += " 	, VALOR " + cEnter
	sQuery += " 	, PRC_VENDA " + cEnter
	sQuery += " 	, PRC_TAB " + cEnter
	sQuery += " FROM tab_ped " + cEnter
	sQuery += " 	INNER JOIN SA1050 SA1 (NOLOCK) ON SA1.A1_FILIAL = '' " + cEnter
	sQuery += " 		AND SA1.A1_COD = tab_ped.CLIENTE " + cEnter
	sQuery += " 		AND SA1.A1_LOJA = tab_ped.LOJA " + cEnter
	sQuery += " 		AND SA1.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	INNER JOIN ZA0 ON ZA0_FILIAL = '' " + cEnter
	sQuery += " 		AND ZA0_TIPO = 'DCAT' " + cEnter
	sQuery += " 		AND ZA0_CAT = SA1.A1_YCAT " + cEnter
	sQuery += " 		AND EMISS_PED BETWEEN ZA0_VIGINI AND ZA0_VIGFIM " + cEnter
	sQuery += " 		AND MARCA = MARCA_PED " + cEnter
	sQuery += " 	INNER JOIN SA3010 SA3 (NOLOCK) ON SA3.A3_FILIAL = '' " + cEnter
	sQuery += " 		AND SA3.A3_COD = tab_ped.VENDEDOR " + cEnter
	sQuery += " 		AND SA3.D_E_L_E_T_ = '' " + cEnter
	sQuery += " 	LEFT JOIN ACY010 ACY (NOLOCK) ON ACY.ACY_FILIAL = '' " + cEnter
	sQuery += " 		AND ACY.ACY_GRPVEN = SA1.A1_GRPVEN " + cEnter
	sQuery += " 		AND ACY.D_E_L_E_T_='' " + cEnter
	sQuery += " ORDER BY EMPRESA_ORIGEM,DESC_GRUPO,VENDEDOR, PEDIDO, ITEM " + cEnter

Return sQuery

Static Function fValidPerg()

	local cLoad	    := "BIABC013"
	local cFileName := RetCodUsr() + "_PedidoVenda_"+cEmpAnt
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	
	aAdd( aPergs ,{1,"Data Inicial ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Data Final   ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	

	If ParamBox(aPergs ,"Pedidos de Venda ",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf
Return lRet