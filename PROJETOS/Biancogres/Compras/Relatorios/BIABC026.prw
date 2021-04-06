#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIABC026
@author Barbara Coelho	  
@since 19/02/2021
@version 1.0
@description Relatório de Consumo médio dos ultimos 3 meses por departamento
@type function
/*/																								

User Function BIABC026()
	Private sdtInicial := "DATEADD(DAY, +1,EOMONTH(DATEADD(MONTH, -4,GETDATE())))"
	Private sdtFinal   := "EOMONTH(DATEADD(MONTH,-1,GETDATE())) "
	Private sAnoMes    := AnoMes ( Date() )
	Private cEnter     := CHR(13) + CHR(10)
	private aPergs := {}
	Private oExcel 	
	
	Aviso('Relatório de Consumo médio por departamento', "Consumo médio dos últimos 3 meses - mês referência " + MesExtenso(Month2Str( Date() ) ) + "/" + Year2Str( Date() ) ,{'Ok'})
	
		oExcel := nil 	
		oExcel := FWMSEXCEL():New()
		
		nxPlan := "Planilha 01"
		nxTabl := "Consumo médio dos últimos 3 meses - mês referência " + MesExtenso(Month2Str( Date() ) ) + "/" + Year2Str( Date() )
		
		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)

		oExcel:AddColumn(nxPlan, nxTabl, "DEPART",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"	,1,4)
		oExcel:AddColumn(nxPlan, nxTabl, "DOC"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "VALOR"	,3,2, .T.)
		oExcel:AddColumn(nxPlan, nxTabl, "CODPROD"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESCPROD"	,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLVL"		,1,1)
		
		GU004 := ""
		xArqTemp := ""

		GU004 := fConsSQL()
		xArqTemp := "base_ConsumoMedio3meses" + AnoMes ( Date() )

			
		GUcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
		dbSelectArea("GU04")
		dbGoTop()
		ProcRegua(RecCount())
		
		While !Eof()	
			IncProc()
				oExcel:AddRow(nxPlan, nxTabl, { GU04->DESCENTID,; 
												stod(GU04->EMISSAO),;
												GU04->DOC,;
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

Static Function fConsSQL
Local sQuery := ""

sQuery := " SELECT DISTINCT  CODENTID, DESCENTID, EMISSAO, DOC,                  	  " + cEnter
sQuery += "        ROUND(SUM(CUSTO), 2) VALOR, CODPROD, DESCPROD,CLVL				  " + cEnter
sQuery += "   FROM (SELECT DISTINCT ZCA_ENTID CODENTID , ZCA_DESCRI DESCENTID,		  " + cEnter
sQuery += "                CASE WHEN D3_TM >= '500' THEN D3_QUANT					  " + cEnter
sQuery += "                ELSE D3_QUANT * (-1) END QUANT,							  " + cEnter
sQuery += "                CASE WHEN D3_TM >= '500' THEN D3_CUSTO1 					  " + cEnter
sQuery += "                ELSE D3_CUSTO1 * (-1) END CUSTO, 						  " + cEnter
sQuery += " 			   D3_EMISSAO EMISSAO,										  " + cEnter
sQuery += " 			   D3_DOC DOC,												  " + cEnter
sQuery += " 			   B1_COD CODPROD, B1_DESC DESCPROD,						  " + cEnter
sQuery += " 			   D3_CLVL CLVL												  " + cEnter
sQuery += "           FROM " + RetSQLName("SB1") + " SB1  WITH (NOLOCK) 			  " + cEnter
sQuery += "          INNER JOIN " + RetSQLName("SD3") + " SD3  WITH (NOLOCK) 		  " + cEnter
sQuery += "             ON D3_COD = B1_COD 				  							  " + cEnter
sQuery += "            AND D3_YPARADA <> 'S' 										  " + cEnter
sQuery += "            AND SD3.D_E_L_E_T_ = ' '										  " + cEnter
sQuery += "		     INNER JOIN " + RetSQLName("ZCN") + " ZCN  WITH (NOLOCK) 		  " + cEnter
sQuery += "             ON D3_COD = ZCN_COD											  " + cEnter
sQuery += "			   AND ZCN_FILIAL = D3_FILIAL									  " + cEnter
sQuery += "			   AND ZCN_LOCAL = D3_LOCAL 									  " + cEnter
sQuery += "            AND ZCN_POLIT IN ('4','8') 									  " + cEnter
sQuery += "            AND ZCN.D_E_L_E_T_ = ''										  " + cEnter
sQuery += "          INNER JOIN " + RetSQLName("CTH") + " CTH WITH (NOLOCK)           " + cEnter
sQuery += "			    ON CTH.CTH_CLVL = D3_CLVL                                 	  " + cEnter
sQuery += "			   AND CTH.D_E_L_E_T_ = ''   									  " + cEnter
sQuery += "		     INNER JOIN " + RetSQLName("ZCA") + " ZCA WITH (NOLOCK)		      " + cEnter
sQuery += "		        ON ZCA.ZCA_ENTID = CTH.CTH_YENTID                             " + cEnter
sQuery += "          WHERE D3_EMISSAO BETWEEN " + sdtInicial + " AND " + sdtFinal       + cEnter
sQuery += "            AND SB1.D_E_L_E_T_ = '')TMP									  " + cEnter
sQuery += "  GROUP BY CODENTID, DESCENTID, CLVL, EMISSAO, DOC, CODPROD, DESCPROD" + cEnter
	
Return sQuery