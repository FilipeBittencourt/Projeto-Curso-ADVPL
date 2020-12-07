#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} BIABC020
@author Barbara Luan Gomes Coelho
@since 03/11/20
@version 1.1
@description Tela de cálculo de consumo médio
@type function
/*/                                                                                               

User Function BIABC020()
	Private sdtInicial := "DATEADD(DAY, +1,EOMONTH(DATEADD(MONTH, -4,GETDATE())))"
	Private sdtFinal   := "EOMONTH(DATEADD(MONTH,-1,GETDATE())) "
	Private sAnoMes    := AnoMes ( Date() )
	Private bInsere    := .T.
	cEnter             := Chr(13) + Chr(10)
	
	Aviso('Cálculo de Consumo Médio', "Data Referência:" + MesExtenso(Month2Str( Date() ) ) + "/" + Year2Str( Date() ) + cEnter +;
	'Políticas: 4 e 8 ' + cEnter + 'Período: 3 meses',{'Ok'})
	
	/*@ 0,0 TO 230,280 DIALOG oEntra TITLE "Cálculo de Consumo médio"	
	
	@ 20,25 SAY "Data Referência (AAAAMM): " + sAnoMes
	@ 35,35 SAY "Políticas: 4 e 8" 
	@ 55,45 SAY "Período: 3 meses------------------------------------------------------------------------------------------------------" 
	
	@ 85,60 BMPBUTTON TYPE 1 ACTION Close( oEntra )*/

	ACTIVATE DIALOG oEntra CENTERED


	cQuery := "SELECT DISTINCT BM_GRUPO, BM_DESC, " + cEnter
	cQuery += "       ROUND(SUM(CUSTO)/(DATEDIFF(DAY," + sdtInicial +", " + sdtFinal + ")/30), 2) CUSTO" + cEnter
	cQuery += "  FROM (SELECT DISTINCT SBM1.BM_GRUPO, SBM1.BM_DESC," + cEnter
	cQuery += "               CASE WHEN D3_TM >= '500' THEN D3_QUANT" + cEnter
	cQuery += "               ELSE D3_QUANT * (-1) END QUANT," + cEnter
	cQuery += "               CASE WHEN D3_TM >= '500' THEN D3_CUSTO1 " + cEnter
	cQuery += "               ELSE D3_CUSTO1 * (-1) END CUSTO " + cEnter
	cQuery += "          FROM SBM010 SBM1 WITH (NOLOCK)" + cEnter
	cQuery += "         INNER JOIN SBM010 SBM2 WITH (NOLOCK) ON SBM1.BM_GRUPO = SBM2.BM_YAGRPCT AND SBM2.D_E_L_E_T_ = ''" + cEnter
	cQuery += "         INNER JOIN SB1010 SB1  WITH (NOLOCK) ON B1_GRUPO = SBM2.BM_GRUPO AND SB1.D_E_L_E_T_ = ''" + cEnter
	cQuery += "         INNER JOIN ZCN010 ZCN  WITH (NOLOCK) ON B1_COD = ZCN_COD AND ZCN_POLIT IN ('4','8') AND ZCN.D_E_L_E_T_ = ''" + cEnter
	cQuery += "         INNER JOIN SD3010 SD3  WITH (NOLOCK) ON D3_COD = ZCN_COD AND D3_LOCAL = ZCN_LOCAL AND D3_YPARADA <> 'S' AND SD3.D_E_L_E_T_ = ' '" + cEnter
	cQuery += "         WHERE SBM1.D_E_L_E_T_ = ''" + cEnter
	cQuery += "           AND D3_EMISSAO BETWEEN " + sdtInicial +" AND " + sdtFinal + cEnter
	cQuery += "           AND SBM1.BM_YAGRPCT = '')TBL" + cEnter
	cQuery += " GROUP BY BM_GRUPO, BM_DESC " + cEnter

	TCQUERY cQuery ALIAS "QRY1" NEW

	DbSelectArea("QRY1")
	DbGotop()

	While !EOF()
		DbSelectArea("ZG1")
		DbSetOrder(1)
		
		IF DbSeek(xFilial("ZG1") + QRY1->BM_GRUPO + sAnoMes)
			bInsere    := .F.
			Aviso('Cálculo Limite de Compras por Grupo de Produto', "Atenção! O cálculo já havia sido executado para o período : " + sAnoMes ,{'Ok'})
			EXIT
		ELSE	
			RecLock("ZG1",.T.)
			ZG1->ZG1_FILIAL := xFilial("ZG1")
			ZG1->ZG1_GRPROD := QRY1->BM_GRUPO
			ZG1->ZG1_VLCM   := QRY1->CUSTO
			ZG1->ZG1_ANOMES := sAnoMes

			MsUnLock("ZG1")
		ENDIF
		DbSelectArea("QRY1")
		DbSkip()
	END
	DbCloseArea("QRY1")
	
	if bInsere
		Aviso('Cálculo Limite de Compras por Grupo de Produto', "Sucesso! Cálculo executado sem problemas para o período : " + sAnoMes ,{'Ok'})
	endif
Return