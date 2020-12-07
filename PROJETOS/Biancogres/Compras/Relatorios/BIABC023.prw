#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIABC023
@author Barbara Coelho	  
@since 10/06/2020
@version 1.0
@description Relatório de Compras realizadas no mês corrente
@type function
/*/																								

User Function BIABC023()
	Private cEnter := CHR(13)+CHR(10)
	private aPergs := {}
	Private sAnoMes    := AnoMes ( Date() )
	Private oExcel 	
	
    Aviso('Relatório de Compras Realizadas', "Compras realizadas do mês de " + MesExtenso(Month2Str( Date() ) ) + "/" + Year2Str( Date() ) ,{'Ok'})

	oExcel := nil 	
	oExcel := FWMSEXCEL():New()
		
	nxPlan := "Planilha 01"
	nxTabl := "Compras realizadas no mês " + MesExtenso(Month2Str(Date()))+"/"+ Year2Str(Date())
		
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
		
	oExcel:AddColumn(nxPlan, nxTabl, "GRUPO"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"	,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SERIE"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEM"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VALOR"	,3,2, .T.)
	oExcel:AddColumn(nxPlan, nxTabl, "CODPROD"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCPROD"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"		,1,1)
		
	GU004 := ""
	xArqTemp := ""
	
	GU004 := fConsultaSQL()
	xArqTemp := "base_ComprasRealizadas" + AnoMes ( Date() )
			
	GUcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
	dbSelectArea("GU04")
	dbGoTop()
	ProcRegua(RecCount())
	
	While !Eof()	
		IncProc()
		oExcel:AddRow(nxPlan, nxTabl, { GU04->GRUPO,;
		                                GU04->TIPO,; 
										stod(GU04->EMISSAO),;
										GU04->DOC,;
										GU04->SERIE,; 
										GU04->ITEM,;
										Round(GU04->VALOR,2),;
										GU04->CODPROD,;
										GU04->DESCPROD,;
										GU04->CLVL;
										}) 
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

Static Function fConsultaSQL
	Local sQuery := ""

	sQuery := " SELECT * FROM (                                                    " + cEnter
	sQuery += " SELECT DISTINCT SUBSTRING(D1_GRUPO,1,3) GRUPO,                     " + cEnter
	sQuery += " 	            'NOTA' TIPO,                                       " + cEnter
	sQuery += "                 D1_DTDIGIT EMISSAO,                                " + cEnter
	sQuery += " 				D1_DOC DOC,                                        " + cEnter
	sQuery += " 				D1_SERIE SERIE,                                    " + cEnter
	sQuery += " 				D1_ITEM ITEM,                                      " + cEnter
	sQuery += "                	ROUND((D1_QUANT * D1_VUNIT),2)  VALOR,             " + cEnter
	sQuery += " 				D1_COD CODPROD,                                    " + cEnter
	sQuery += " 				B1_DESC DESCPROD,                                  " + cEnter
	sQuery += " 				D1_CLVL CLVL                                       " + cEnter
	sQuery += "   FROM " + RetSQLName("SD1") + " SD1  WITH(NOLOCK)                 " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("SF4") + " SF4  WITH(NOLOCK)		       " + cEnter 
	sQuery += "     ON F4_FILIAL = D1_FILIAL				                       " + cEnter
	sQuery += "    AND F4_CODIGO  = D1_TES 				                           " + cEnter
	sQuery += "    AND SF4.F4_DUPLIC = 'S' --GERA DUPLICATA                        " + cEnter
	sQuery += "    AND SF4.D_E_L_E_T_ = ''				                           " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("SF1") + " SF1  WITH(NOLOCK)		       " + cEnter 
	sQuery += "     ON SF1.F1_FILIAL = SD1.D1_FILIAL		                       " + cEnter
	sQuery += "    AND F1_SERIE = D1_SERIE				                           " + cEnter
	sQuery += "    AND F1_DOC = D1_DOC					                           " + cEnter
	sQuery += "    AND F1_FORNECE = D1_FORNECE			                           " + cEnter
	sQuery += "    AND F1_LOJA = D1_LOJA					                       " + cEnter
	sQuery += "    AND SF1.D_E_L_E_T_ = ''				                           " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("ZCN") + " ZCN  WITH(NOLOCK)		       " + cEnter
	sQuery += "     ON ZCN_COD = D1_COD 					           		       " + cEnter
	sQuery += "    AND ZCN_POLIT IN ('4','8') 			          		           " + cEnter
	sQuery += "    AND ZCN_ATIVO <> 'N' 					         		       " + cEnter
	sQuery += "    AND ZCN.D_E_L_E_T_ = ''				           		           " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("SB1") + " SB1  WITH(NOLOCK)            " + cEnter
	sQuery += "     ON B1_COD = D1_COD					         		           " + cEnter
	sQuery += "    AND SB1.D_E_L_E_T_ = ''				       		               " + cEnter
	sQuery += "  WHERE F1_TIPO IN ('N','C')				       		               " + cEnter
	sQuery += "    AND SD1.D_E_L_E_T_ = ''				       		               " + cEnter
	sQuery += "    AND SUBSTRING(D1_DTDIGIT,1,6) = '202011'     		           " + cEnter
	sQuery += " UNION ALL												           " + cEnter
	sQuery += " SELECT DISTINCT SUBSTRING(D2_GRUPO,1,3) GRUPO, 			           " + cEnter
	sQuery += "                 'DEVOLUCAO' TIPO,						           " + cEnter
	sQuery += "                 D2_EMISSAO EMISSAO,						           " + cEnter
	sQuery += " 				D2_DOC DOC,								           " + cEnter
	sQuery += " 				D2_SERIE SERIE,							           " + cEnter
	sQuery += " 				D2_ITEM ITEM, 							           " + cEnter
	sQuery += "   				ROUND(D2_QUANT * D2_PRUNIT,2) VALOR,	           " + cEnter
	sQuery += " 				D2_COD CODPROD,							           " + cEnter
	sQuery += " 				B1_DESC DESCPROD,						           " + cEnter
	sQuery += " 				D2_CLVL CLVL							           " + cEnter
	sQuery += "   FROM " + RetSQLName("SD2") + " SD2  WITH(NOLOCK)				   " + cEnter 
	sQuery += "  INNER JOIN " + RetSQLName("SF4") + " SF4  WITH(NOLOCK)		       " + cEnter 
	sQuery += "     ON  F4_FILIAL = D2_FILIAL				                       " + cEnter
	sQuery += "    AND F4_CODIGO  = D2_TES 				                           " + cEnter
	sQuery += "    AND SF4.F4_DUPLIC = 'S' --GERA DUPLICATA                        " + cEnter
	sQuery += "    AND SF4.D_E_L_E_T_ = ''				                           " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("SF2") + " SF2  WITH(NOLOCK)		       " + cEnter 
	sQuery += "     ON SF2.F2_FILIAL = SD2.D2_FILIAL		                       " + cEnter
	sQuery += "    AND F2_SERIE = D2_SERIE				                           " + cEnter
	sQuery += "    AND F2_DOC = D2_DOC					                           " + cEnter
	sQuery += "    AND F2_CLIENTE = D2_CLIENTE			                           " + cEnter
	sQuery += "    AND F2_LOJA = D2_LOJA					                       " + cEnter
	sQuery += "    AND SF2.D_E_L_E_T_ = ''				                           " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("ZCN") + " ZCN  WITH(NOLOCK)	           " + cEnter 
	sQuery += "     ON ZCN_COD = D2_COD 					                       " + cEnter
	sQuery += "    AND ZCN_POLIT IN ('4','8') 			                           " + cEnter
	sQuery += "    AND ZCN_ATIVO <> 'N' 					                       " + cEnter
	sQuery += "    AND ZCN.D_E_L_E_T_ = ''				                           " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("SB1") + " SB1  WITH(NOLOCK)		       " + cEnter
	sQuery += "     ON B1_COD = D2_COD					                           " + cEnter
	sQuery += "    AND SB1.D_E_L_E_T_ = ''				                           " + cEnter
	sQuery += "  WHERE F2_TIPO IN ('D','C')				                           " + cEnter
	sQuery += "    AND SD2.D_E_L_E_T_ = ''				                           " + cEnter
	sQuery += "    AND SUBSTRING(D2_EMISSAO,1,6) = '202011'                        " + cEnter
	sQuery += " UNION ALL												           " + cEnter
	sQuery += " SELECT DISTINCT SUBSTRING(B1_GRUPO,1,3) GRUPO,			           " + cEnter
	sQuery += "                 'PEDIDO' TIPO,							           " + cEnter
	sQuery += "                 C7_DATPRF EMISSAO,						           " + cEnter
	sQuery += " 				C7_NUM DOC,								           " + cEnter
	sQuery += " 				''SERIE,								           " + cEnter
	sQuery += " 				C7_ITEM ITEM,							           " + cEnter
	sQuery += " 				ROUND((C7_QUANT - C7_QUJE) * C7_PRECO,2) VALOR,    " + cEnter
	sQuery += "                 C7_PRODUTO CODPROD,                                " + cEnter 
	sQuery += " 				B1_DESC DESCPROD,						           " + cEnter
	sQuery += " 				C7_CLVL CLVL  						               " + cEnter
	sQuery += "   FROM " + RetSQLName("SC7") + " SC7 WITH(NOLOCK)				   " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("ZCN") + " ZCN  WITH(NOLOCK)	           " + cEnter
	sQuery += "     ON ZCN_FILIAL = C7_FILIAL							           " + cEnter
	sQuery += "    AND ZCN_COD = C7_PRODUTO 							           " + cEnter
	sQuery += "    AND ZCN_POLIT IN ('4','8') 							           " + cEnter
	sQuery += "    AND ZCN_ATIVO <> 'N' 								           " + cEnter
	sQuery += "    AND ZCN_LOCAL = C7_LOCAL								           " + cEnter
	sQuery += "    AND ZCN.D_E_L_E_T_ = ''								           " + cEnter
	sQuery += "  INNER JOIN " + RetSQLName("SB1") + " SB1  WITH(NOLOCK)	           " + cEnter 
	sQuery += "     ON B1_COD = C7_PRODUTO								           " + cEnter
	sQuery += "    AND SB1.D_E_L_E_T_ = ''								           " + cEnter
	sQuery += "  WHERE C7_QUANT > C7_QUJE                     			           " + cEnter
	sQuery += "    AND C7_CONAPRO = 'L' 								           " + cEnter
	sQuery += "    AND C7_RESIDUO = ''									           " + cEnter
	sQuery += "    AND C7_ENCER = ''									           " + cEnter
	sQuery += "    AND SC7.D_E_L_E_T_ = ''								           " + cEnter
	sQuery += "    AND SUBSTRING(C7_DATPRF,1,6) = '" + sAnoMes + "')TBL			   " + cEnter
	sQuery += " ORDER BY TIPO, GRUPO, EMISSAO, DOC, ITEM				           " + cEnter
	
Return sQuery