#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#include "rwmake.ch"


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Barbara Luan Gomes Coelho
Programa  := BIABC005
Empresa   := Biancogres Cerâmica S/A
Data      := 02/04/19
Uso       := Compras
Aplicação := Retorna todos os pedidos de compra pendentes de aprovação do grupo de aprovação do aprovador logado 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function BIABC005()
Local cSQL := ""
Local cQry := GetNextAlias()
Private cEnter := CHR(13)+CHR(10)

Private oExcel      := nil 

	oExcel := FWMSEXCEL():New()
	
	nxPlan := "Planilha 01"
	nxTabl := "Pedidos Pendentes de Aprovação"
	
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Empresa"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Pedido"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SC Protheus"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SC Bizagi"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Solicitante"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Classe de Valor"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Comprador"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt Emissão"		,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt Chegada"		,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt Entrega"		,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Dt Expiração"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Almoxarifado"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Item"			    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Produto"			,1,1)	
	oExcel:AddColumn(nxPlan, nxTabl, "Quant"			,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Valor Produto"	,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Total Produto"	,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Total Pedido"		,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "Aprovador"		,1,1)
	
	GU004 := ""
	GU004 := " SELECT 'BIANCOGRES' AS EMPRESA, C7_NUM, C7_NUMSC, C1_YBIZAGI,C1_SOLICIT, C7_CLVL, Y1_NOME AS COMPRADOR," + cEnter
	GU004 += "        LTRIM(RTRIM(C7_PRODUTO))+'-'+LTRIM(RTRIM(C7_DESCRI)) AS PRODUTO, " + cEnter
	GU004 += "        C7_ITEM, C7_QUANT, C7_PRECO, C7_TOTAL, CR_TOTAL, AK_NOME AS APROVADOR, C7_LOCAL," + cEnter
	GU004 += "        (CASE C7_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C7_EMISSAO),103) END) AS DTEMISSAO," + cEnter
	GU004 += "        (CASE CR_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,DATEADD(DAY, 10, CR_EMISSAO)),103) END) AS DTEXPIRAC, " + cEnter
	GU004 += "        (CASE C7_YDATCHE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C7_YDATCHE),103) END) AS DTCHEGADA," + cEnter   
	GU004 += "        (CASE C7_DATPRF WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C7_DATPRF),103) END) AS DTENTREGA " + cEnter  
	GU004 += "   FROM SC7010 SC7 " + cEnter
	GU004 += "  INNER JOIN SCR010 SCR " + cEnter
	GU004 += "     ON (CR_NUM = C7_NUM  AND SCR.D_E_L_E_T_ = ' ') " + cEnter
	GU004 += "  INNER JOIN SC1010 SC1 " + cEnter 
	GU004 += "     ON (C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM AND SC1.D_E_L_E_T_ = ' ') " + cEnter
	GU004 += "  INNER JOIN SAK010 SAK " + cEnter
    GU004 += "     ON (CR_APROV = AK_COD AND SAK.D_E_L_E_T_ = ' ')" + cEnter
    GU004 += " LEFT JOIN SY1010 SY1 "
    GU004 += "    ON (Y1_FILIAL = ' ' AND Y1_USER = C7_USER and SY1.D_E_L_E_T_ = ' ') "+cEnter
	GU004 += "  WHERE CR_TIPO = 'PC'  " + cEnter	
	GU004 += "    AND CR_LIBAPRO = ''" + cEnter		 
	GU004 += "    AND CR_LIBAPRO = ''" + cEnter	
	GU004 += "    AND CR_DATALIB = ''" + cEnter	 
	GU004 += "    AND CR_USERLIB = ''" + cEnter	 
	GU004 += "    AND CR_VALLIB = 0 " + cEnter	
	GU004 += "    AND SCR.D_E_L_E_T_ = ''" + cEnter	 
	GU004 += "    AND C7_RESIDUO <> 'S' " + cEnter	
	GU004 += "    AND C7_ENCER <> 'E' " + cEnter	
	GU004 += "    AND SC7.D_E_L_E_T_ = '' " + cEnter	
	GU004 += "    AND C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	GU004 += "    AND EXISTS (SELECT 1" + cEnter	
	GU004 += "                  FROM SAL010  SAL" + cEnter	
	//GU004 += "                 WHERE AL_USER = '001327' " + cEnter	
	GU004 += "                 WHERE AL_USER = '" +__cUserID + "'" + cEnter	
	GU004 += "                   AND  C7_CLVL = AL_YCLVL" + cEnter	
	GU004 += "                   AND SAL.D_E_L_E_T_ = '')" + cEnter
	GU004 += " UNION" + cEnter	
	GU004 += " SELECT 'INCESA' AS EMPRESA, C7_NUM, C7_NUMSC, C1_YBIZAGI,C1_SOLICIT, C7_CLVL, Y1_NOME AS COMPRADOR," + cEnter
	GU004 += "        LTRIM(RTRIM(C7_PRODUTO))+'-'+LTRIM(RTRIM(C7_DESCRI)) AS PRODUTO," + cEnter
	GU004 += "        C7_ITEM, C7_QUANT, C7_PRECO, C7_TOTAL, CR_TOTAL, AK_NOME AS APROVADOR, C7_LOCAL," + cEnter
	GU004 += "        (CASE C7_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C7_EMISSAO),103) END) AS DTEMISSAO," + cEnter
	GU004 += "        (CASE CR_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,DATEADD(DAY, 10, CR_EMISSAO)),103) END) AS DTEXPIRAC, " + cEnter
	GU004 += "        (CASE C7_YDATCHE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C7_YDATCHE),103) END) AS DTCHEGADA," + cEnter   
	GU004 += "        (CASE C7_DATPRF WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C7_DATPRF),103) END) AS DTENTREGA " + cEnter  
	GU004 += "   FROM SC7050 SC7 " + cEnter
	GU004 += "  INNER JOIN SCR050 SCR " + cEnter
	GU004 += "     ON (CR_NUM = C7_NUM  AND SCR.D_E_L_E_T_ = ' ') " + cEnter
	GU004 += "  INNER JOIN SC1050 SC1 " + cEnter 
	GU004 += "     ON (C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM AND SC1.D_E_L_E_T_ = ' ') " + cEnter
	GU004 += "  INNER JOIN SAK010 SAK " + cEnter
    GU004 += "     ON (CR_APROV = AK_COD AND SAK.D_E_L_E_T_ = ' ')" + cEnter
    GU004 += " LEFT JOIN SY1050 SY1 "
    GU004 += "    ON (Y1_FILIAL = ' ' AND Y1_USER = C7_USER and SY1.D_E_L_E_T_ = ' ') "+ cEnter
	GU004 += "  WHERE CR_TIPO = 'PC'  " + cEnter	
	GU004 += "    AND CR_LIBAPRO = ''" + cEnter		 
	GU004 += "    AND CR_LIBAPRO = ''" + cEnter	
	GU004 += "    AND CR_DATALIB = ''" + cEnter	 
	GU004 += "    AND CR_USERLIB = ''" + cEnter	 
	GU004 += "    AND CR_VALLIB = 0 " + cEnter	
	GU004 += "    AND SCR.D_E_L_E_T_ = ''" + cEnter	 
	GU004 += "    AND C7_RESIDUO <> 'S' " + cEnter	
	GU004 += "    AND C7_ENCER <> 'E' " + cEnter	
	GU004 += "    AND SC7.D_E_L_E_T_ = '' " + cEnter	
	GU004 += "    AND C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	GU004 += "    AND EXISTS (SELECT 1" + cEnter	
	GU004 += "                  FROM SAL010 SAL " + cEnter	
	//GU004 += "                 WHERE AL_USER = '001327' " + cEnter	
	GU004 += "                 WHERE AL_USER = '" +__cUserID + "'" + cEnter	
	GU004 += "                   AND  C7_CLVL = AL_YCLVL " + cEnter	
	GU004 += "                   AND SAL.D_E_L_E_T_ = '')" + cEnter		
	
	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
	dbSelectArea("GU04")
	dbGoTop()
	ProcRegua(RecCount())
    
    While !Eof()	
		IncProc()
			
		oExcel:AddRow(nxPlan, nxTabl, { GU04->EMPRESA,;
										GU04->C7_NUM,;
		 								GU04->C7_NUMSC,;
		 								GU04->C1_YBIZAGI,;
		 								GU04->C1_SOLICIT,;
		 								GU04->C7_CLVL,;
		 								GU04->COMPRADOR,;
		                                GU04->DTEMISSAO,;
		                                GU04->DTCHEGADA,;
		                                GU04->DTENTREGA,;
		                                GU04->DTEXPIRAC,;
		                                GU04->C7_LOCAL,;
		                                GU04->C7_ITEM,;
		                                GU04->PRODUTO,;		                                
		                                GU04->C7_QUANT,;
		                                Round(GU04->C7_PRECO,2),;
		                                Round(GU04->C7_TOTAL,2),;
		                                Round(GU04->CR_TOTAL,2),;
		                                GU04->APROVADOR})
		
		dbSelectArea("GU04")
		dbSkip()	
	End
	
	GU04->(dbCloseArea())
	Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(GUcIndex+OrdBagExt())          //indice gerado
	
	xArqTemp := "pedidos_pendentes_"+cEmpAnt
	
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