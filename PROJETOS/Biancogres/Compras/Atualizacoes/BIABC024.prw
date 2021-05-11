#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} BIABC024
@author Barbara Luan Gomes Coelho
@since 03/11/20
@version 1.1
@description Tela de cálculo de consumo médio por departamento
@type function
/*/                                                                                               

User Function BIABC024()
    Local nCnt 
    
	Private sdtInicial := "DATEADD(DAY, +1,EOMONTH(DATEADD(MONTH, -4,GETDATE())))"
	Private sdtFinal   := "EOMONTH(DATEADD(MONTH,-1,GETDATE())) "
	Private sAnoMes    := AnoMes ( Date() )
	Private bInsere    := .T.
	cEnter             := Chr(13) + Chr(10)
	
	Aviso('Cálculo de Consumo Médio por Departamento', ;
	'Data Referência:' + MesExtenso(Month2Str( Date() ) ) + '/' + Year2Str( Date() ) + cEnter +;
	'Políticas: 4 e 8 ' + cEnter + 'Período: 3 meses',{'Ok'})


	cQuery := "SELECT DISTINCT CODENTID, DESCENTID, " + cEnter
	cQuery += "       ROUND(SUM(CUSTO)/(DATEDIFF(DAY," + sdtInicial +", " + sdtFinal + ")/30), 2) CUSTO" + cEnter
	cQuery += "  FROM (SELECT DISTINCT ZCA_ENTID CODENTID, ZCA_DESCRI DESCENTID," + cEnter
	cQuery += "               CASE WHEN D3_TM >= '500' THEN D3_QUANT" + cEnter
	cQuery += "               ELSE D3_QUANT * (-1) END QUANT," + cEnter
	cQuery += "               CASE WHEN D3_TM >= '500' THEN D3_CUSTO1 " + cEnter
	cQuery += "               ELSE D3_CUSTO1 * (-1) END CUSTO " + cEnter
	cQuery += "          FROM SB1010 SB1  WITH (NOLOCK)" + cEnter 
	cQuery += "         INNER JOIN ZCN010 ZCN  WITH (NOLOCK) " + cEnter
	cQuery += "            ON B1_COD = ZCN_COD " + cEnter
	cQuery += "           AND ZCN_POLIT IN ('4','8') " + cEnter
	cQuery += "           AND ZCN.D_E_L_E_T_ = ''" + cEnter
	cQuery += "         INNER JOIN SD3010 SD3  WITH (NOLOCK) " + cEnter
	cQuery += "            ON D3_COD = ZCN_COD " + cEnter
	cQuery += "           AND D3_LOCAL = ZCN_LOCAL " + cEnter
	cQuery += "           AND D3_YPARADA <> 'S' " + cEnter
	cQuery += "           AND SD3.D_E_L_E_T_ = '' " + cEnter
	cQuery += "         INNER JOIN CTH010 CTH " + cEnter
	cQuery += "	           ON CTH.CTH_CLVL = SD3.D3_CLVL 
	cQuery += "	          AND CTH.D_E_L_E_T_ = '' " + cEnter
	cQuery += "	        INNER JOIN ZCA010 ZCA WITH (NOLOCK) " + cEnter
	cQuery += "	           ON ZCA.ZCA_ENTID = CTH.CTH_YENTID AND ZCA.D_E_L_E_T_ = '' " + cEnter
	cQuery += "         WHERE D3_EMISSAO BETWEEN " + sdtInicial +" AND " + sdtFinal + cEnter
	cQuery += "           AND SB1.D_E_L_E_T_ = '')TBL" + cEnter
	cQuery += " GROUP BY CODENTID, DESCENTID " + cEnter	

	TCQUERY cQuery ALIAS "QRY1" NEW

	DbSelectArea("QRY1")
	DbGotop()

	While !EOF()
		DbSelectArea("ZG4")
		DbSetOrder(3)
		
		IF DbSeek(xFilial("ZG4") + QRY1->CODENTID + sAnoMes + DTOS( FirstDate ( Date() )))
			bInsere    := .F.
			Aviso('Cálculo Limite de Compras por Departamento', "Atenção! O cálculo já havia sido executado para o período : " + sAnoMes ,{'Ok'})
			EXIT
		ELSE	
           For nCnt := 0 To 12 Step 1
			  RecLock("ZG4",.T.)
			
			  ZG4->ZG4_FILIAL := xFilial("ZG4")
			  ZG4->ZG4_ENTID  := QRY1->CODENTID
			  ZG4->ZG4_VLCM   := QRY1->CUSTO
			  ZG4->ZG4_ANOMES := AnoMes ( MonthSum( Date(),nCnt ) )
			  ZG4->ZG4_DTCALC := FirstDate ( Date() )
			
			  MsUnLock("ZG4")
			Next
		ENDIF
		DbSelectArea("QRY1")
		DbSkip()
	END
	(QRY1)->(DbCloseArea())
	
	if bInsere
		Aviso('Cálculo Limite de Compras por Departamento', "Sucesso! Cálculo executado sem problemas para o período : " + sAnoMes ,{'Ok'})
	endif
Return
