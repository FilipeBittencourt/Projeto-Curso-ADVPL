#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFROPRT07	บAutor  ณFernando Rocha      บ Data ณ 23/01/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ EMAIL PLANILHA DE PEDIDOS SEM RESERVA - JOB				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BIANCOGRES												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPRT07() 

	Local xv_Emps    := U_BAGtEmpr("01_14") //01_05
	Local nI

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		//Gera o html do WF.
		Processa({|| ProcRT07()})

		RpcClearEnv()
	Next nI

Return

Static Function ProcRT07()

	Local cAliasAux       
	Local cFiltro

	//Ticket 26154: Camila solicitou alterar para data vigente + 180 dias.
	cFiltro := "% EMPRESA in ('BIANCO', 'INCESA','BELLACASA','MUNDIALLI', 'PEGASUS','VINILICO') %"
	cDtNece := "% DT_NECESSIDADE <= ( convert(varchar(8),GetDate()+180,112) ) %"

	/*If AllTrim(cEmpAnt) == "01"
	cFiltro := "% EMPRESA in ('BIANCO') %"
	cDtNece := "% DT_NECESSIDADE <= ( convert(varchar(8),GetDate()+120,112) ) %"
	Else
	cFiltro := "% EMPRESA in ('INCESA','BELLACASA','MUNDIALLI')  %"
	cDtNece := "% DT_NECESSIDADE <= ( convert(varchar(8),GetDate()+90,112) ) %"
	EndIf
	*/

	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux   
		%NOPARSER%

		SELECT * FROM (
		SELECT
		EMPRESA = CASE WHEN ZZ7_EMP = '0101' THEN 'BIANCO' WHEN ZZ7_EMP = '0199' THEN 'PEGASUS' WHEN ZZ7_EMP = '0501' THEN 'INCESA' WHEN ZZ7_EMP = '1302' THEN 'VINILICO' WHEN ZZ7_EMP = '1399' THEN 'MUNDIALLI' WHEN ZZ7_EMP = '1401' THEN 'VITCER' WHEN ZZ7_EMP = '0599' THEN 'BELLACASA' ELSE '' END
		,CODEMP = '01'
		,EMISSAO = SC5.C5_EMISSAO
		,PEDIDO = SC5.C5_NUM
		,ITEM = C6_ITEM
		,CLIENTE = case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end
		,NOME_CLIENTE = (select top 1 A1_NOME from SA1010 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and D_E_L_E_T_='')
		,SEGMENTO = (select top 1 A1_YTPSEG from SA1010 SA1 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and SA1.D_E_L_E_T_='')
		,PRODUTO = C6_PRODUTO
		,SALDO_PED = ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9010 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2)
		//,VENDEDOR = SC5.C5_VEND1
		,VENDEDOR = (CASE WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO <= '20111231' THEN SC5.C5_VEND1 WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE SC5.C5_VEND1 END) + ' - ' + 
		case when LC5.C5_VEND1 is not null then SA3.A3_NREDUZ else SA3V.A3_NREDUZ END

		,DIGITADO_POR = SC5.C5_YDIGP
		,LINHA = SC5.C5_YLINHA
		,TIPO_RES = C6_YTPEST
		,ENTREGA = C6_ENTREG
		,DT_NECESSIDADE = C6_YDTNECE
		,DT_NECES_REAL = C6_YDTNERE
		,NOME_PROD = SB1.B1_DESC 

		,LOG_RES_SC0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA 
		from PZ2010 A (nolock) where PZ2_CODENT = 'SC0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC0010 X (nolock) where C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_RES_PZ0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2010 A (nolock) where PZ2_CODENT = 'PZ0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from PZ0010 X (nolock) where PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_DEL_SC9 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CONT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2010 A (nolock) where PZ2_CODENT = 'SC9' and PZ2_CODMOT = 'C9E' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC9010 X (nolock) where C9_FILIAL = '01' and C6_NUM = C9_PEDIDO and C6_ITEM = C9_ITEM order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,OBS = C6_YOBS

		FROM SC5010 SC5 (nolock)
		JOIN SC6010 SC6 (nolock) ON C6_FILIAL = SC5.C5_FILIAL AND SC5.C5_NUM = C6_NUM
		JOIN SB1010 SB1 (nolock) ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO
		JOIN ZZ7010 ZZ7 (nolock) ON B1_YLINHA = ZZ7_COD AND B1_YLINSEQ = ZZ7_LINSEQ
		left join SC0010 SC0 (nolock) on C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV and C6_PRODUTO = C0_PRODUTO and SC0.D_E_L_E_T_ = ''
		left join PZ0010 PZ0 (nolock) on PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO and PZ0.D_E_L_E_T_ = ''
		LEFT JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '01' AND SC5.C5_NUM  = LC5.C5_YPEDORI	AND SC5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = SC5.C5_YCLIORI AND SC5.C5_YLOJORI = LC5.C5_LOJACLI AND SC5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' 
		left join SA3010 SA3 with (nolock) on SA3.A3_COD = LC5.C5_VEND1 
		left join SA3010 SA3V with (nolock) on SA3V.A3_COD = SC5.C5_VEND1 

		WHERE
		SC5.C5_FILIAL = '01'
		AND SC5.C5_YSUBTP NOT IN ('A','RI')
		AND SC5.C5_EMISSAO >= '20140101'
		AND C6_BLQ <> 'R'
		AND B1_TIPO = 'PA'
		and C0_PRODUTO is null
		and PZ0_CODPRO is null
		and ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9010 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0

		AND SC5.D_E_L_E_T_=' '
		AND SC6.D_E_L_E_T_=' '
		AND SB1.D_E_L_E_T_=' ' 
		AND ZZ7.D_E_L_E_T_=' ' 

		UNION ALL

		SELECT
		EMPRESA = CASE WHEN ZZ7_EMP = '0101' THEN 'BIANCO' WHEN ZZ7_EMP = '0199' THEN 'PEGASUS' WHEN ZZ7_EMP = '0501' THEN 'INCESA' WHEN ZZ7_EMP = '1302' THEN 'VINILICO' WHEN ZZ7_EMP = '1399' THEN 'MUNDIALLI' WHEN ZZ7_EMP = '1401' THEN 'VITCER' WHEN ZZ7_EMP = '0599' THEN 'BELLACASA' ELSE '' END
		,CODEMP = '05'
		,EMISSAO = SC5.C5_EMISSAO
		,PEDIDO = SC5.C5_NUM
		,ITEM = C6_ITEM
		,CLIENTE = case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end
		,NOME_CLIENTE = (select top 1 A1_NOME from SA1010 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and D_E_L_E_T_='')
		,SEGMENTO = (select top 1 A1_YTPSEG from SA1010 SA1 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and SA1.D_E_L_E_T_='')
		,PRODUTO = C6_PRODUTO
		,SALDO_PED = ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9050 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2)
		//,VENDEDOR = SC5.C5_VEND1
		,VENDEDOR = (CASE WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO <= '20111231' THEN SC5.C5_VEND1 WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE SC5.C5_VEND1 END) + ' - ' + 
		case when LC5.C5_VEND1 is not null then SA3.A3_NREDUZ else SA3V.A3_NREDUZ END

		,DIGITADO_POR = SC5.C5_YDIGP
		,LINHA = SC5.C5_YLINHA
		,TIPO_RES = C6_YTPEST
		,ENTREGA = C6_ENTREG
		,DT_NECESSIDADE = C6_YDTNECE
		,DT_NECES_REAL = C6_YDTNERE 
		,NOME_PROD = SB1.B1_DESC 

		,LOG_RES_SC0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA 
		from PZ2050 A (nolock) where PZ2_CODENT = 'SC0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC0050 X (nolock) where C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_RES_PZ0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2050 A (nolock) where PZ2_CODENT = 'PZ0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from PZ0050 X (nolock) where PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_DEL_SC9 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CONT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2050 A (nolock) where PZ2_CODENT = 'SC9' and PZ2_CODMOT = 'C9E' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC9050 X (nolock) where C9_FILIAL = '01' and C6_NUM = C9_PEDIDO and C6_ITEM = C9_ITEM order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,OBS = C6_YOBS

		FROM SC5050 SC5 (nolock)
		JOIN SC6050 SC6 (nolock) ON C6_FILIAL = SC5.C5_FILIAL AND SC5.C5_NUM = C6_NUM
		JOIN SB1010 SB1 (nolock) ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO  
		JOIN ZZ7010 ZZ7 (nolock) ON B1_YLINHA = ZZ7_COD AND B1_YLINSEQ = ZZ7_LINSEQ
		left join SC0050 SC0 (nolock) on C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV and C6_PRODUTO = C0_PRODUTO and SC0.D_E_L_E_T_ = ''
		left join PZ0050 PZ0 (nolock) on PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO and PZ0.D_E_L_E_T_ = ''
		LEFT JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '01' AND SC5.C5_NUM  = LC5.C5_YPEDORI	AND SC5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = SC5.C5_YCLIORI AND SC5.C5_YLOJORI = LC5.C5_LOJACLI AND SC5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' 
		left join SA3010 SA3 with (nolock) on SA3.A3_COD = LC5.C5_VEND1 
		left join SA3010 SA3V with (nolock) on SA3V.A3_COD = SC5.C5_VEND1 

		WHERE
		SC5.C5_FILIAL = '01'
		AND SC5.C5_YSUBTP NOT IN ('A','RI')
		AND SC5.C5_EMISSAO >= '20140101'
		AND C6_BLQ <> 'R'
		AND B1_TIPO = 'PA'
		and C0_PRODUTO is null
		and PZ0_CODPRO is null
		and ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9050 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0

		AND SC5.D_E_L_E_T_=' '
		AND SC6.D_E_L_E_T_=' '
		AND SB1.D_E_L_E_T_=' '      
		AND ZZ7.D_E_L_E_T_=' ' 

		UNION ALL

		SELECT
		EMPRESA = CASE WHEN ZZ7_EMP = '0101' THEN 'BIANCO' WHEN ZZ7_EMP = '0199' THEN 'PEGASUS' WHEN ZZ7_EMP = '0501' THEN 'INCESA' WHEN ZZ7_EMP = '1302' THEN 'VINILICO' WHEN ZZ7_EMP = '1399' THEN 'MUNDIALLI' WHEN ZZ7_EMP = '1401' THEN 'VITCER' WHEN ZZ7_EMP = '0599' THEN 'BELLACASA' ELSE '' END
		,CODEMP = '13'
		,EMISSAO = SC5.C5_EMISSAO
		,PEDIDO = SC5.C5_NUM
		,ITEM = C6_ITEM
		,CLIENTE = case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end
		,NOME_CLIENTE = (select top 1 A1_NOME from SA1010 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and D_E_L_E_T_='')
		,SEGMENTO = (select top 1 A1_YTPSEG from SA1010 SA1 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and SA1.D_E_L_E_T_='')
		,PRODUTO = C6_PRODUTO
		,SALDO_PED = ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9130 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2)
		//,VENDEDOR = SC5.C5_VEND1
		,VENDEDOR = (CASE WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO <= '20111231' THEN SC5.C5_VEND1 WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE SC5.C5_VEND1 END) + ' - ' + 
		case when LC5.C5_VEND1 is not null then SA3.A3_NREDUZ else SA3V.A3_NREDUZ END

		,DIGITADO_POR = SC5.C5_YDIGP
		,LINHA = SC5.C5_YLINHA
		,TIPO_RES = C6_YTPEST
		,ENTREGA = C6_ENTREG
		,DT_NECESSIDADE = C6_YDTNECE
		,DT_NECES_REAL = C6_YDTNERE
		,NOME_PROD = SB1.B1_DESC 

		,LOG_RES_SC0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA 
		from PZ2130 A (nolock) where PZ2_CODENT = 'SC0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC0130 X (nolock) where C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_RES_PZ0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2130 A (nolock) where PZ2_CODENT = 'PZ0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from PZ0130 X (nolock) where PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_DEL_SC9 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CONT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2130 A (nolock) where PZ2_CODENT = 'SC9' and PZ2_CODMOT = 'C9E' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC9130 X (nolock) where C9_FILIAL = '01' and C6_NUM = C9_PEDIDO and C6_ITEM = C9_ITEM order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,OBS = C6_YOBS

		FROM SC5130 SC5 (nolock)
		JOIN SC6130 SC6 (nolock) ON C6_FILIAL = SC5.C5_FILIAL AND SC5.C5_NUM = C6_NUM
		JOIN SB1010 SB1 (nolock) ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO  
		JOIN ZZ7010 ZZ7 (nolock) ON B1_YLINHA = ZZ7_COD AND B1_YLINSEQ = ZZ7_LINSEQ
		left join SC0130 SC0 (nolock) on C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV and C6_PRODUTO = C0_PRODUTO and SC0.D_E_L_E_T_ = ''
		left join PZ0130 PZ0 (nolock) on PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO and PZ0.D_E_L_E_T_ = ''
		LEFT JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '01' AND SC5.C5_NUM  = LC5.C5_YPEDORI	AND SC5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = SC5.C5_YCLIORI AND SC5.C5_YLOJORI = LC5.C5_LOJACLI AND SC5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' 
		left join SA3010 SA3 with (nolock) on SA3.A3_COD = LC5.C5_VEND1 
		left join SA3010 SA3V with (nolock) on SA3V.A3_COD = SC5.C5_VEND1 

		WHERE
		SC5.C5_FILIAL = '01'
		AND SC5.C5_YSUBTP NOT IN ('A','RI')
		AND SC5.C5_EMISSAO >= '20140101'
		AND C6_BLQ <> 'R'
		AND B1_TIPO = 'PA'
		and C0_PRODUTO is null
		and PZ0_CODPRO is null
		and ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9130 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0

		AND SC5.D_E_L_E_T_=' '
		AND SC6.D_E_L_E_T_=' '
		AND SB1.D_E_L_E_T_=' ' 
		AND ZZ7.D_E_L_E_T_=' ' 

		//Vinilico
		UNION ALL

		SELECT
		EMPRESA = CASE WHEN ZZ7_EMP = '0101' THEN 'BIANCO' WHEN ZZ7_EMP = '0199' THEN 'PEGASUS' WHEN ZZ7_EMP = '0501' THEN 'INCESA' WHEN ZZ7_EMP = '1302' THEN 'VINILICO' WHEN ZZ7_EMP = '1399' THEN 'MUNDIALLI' WHEN ZZ7_EMP = '1401' THEN 'VITCER' WHEN ZZ7_EMP = '0599' THEN 'BELLACASA' ELSE '' END
		,CODEMP = '14'
		,EMISSAO = SC5.C5_EMISSAO
		,PEDIDO = SC5.C5_NUM
		,ITEM = C6_ITEM
		,CLIENTE = case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end
		,NOME_CLIENTE = (select top 1 A1_NOME from SA1010 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and D_E_L_E_T_='')
		,SEGMENTO = (select top 1 A1_YTPSEG from SA1010 SA1 (nolock) where A1_COD = (case when SC5.C5_YCLIORI <> '' then SC5.C5_YCLIORI else SC5.C5_CLIENTE end) and SA1.D_E_L_E_T_='')
		,PRODUTO = C6_PRODUTO
		,SALDO_PED = ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9140 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2)
		//,VENDEDOR = SC5.C5_VEND1
		,VENDEDOR = (CASE WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO <= '20111231' THEN SC5.C5_VEND1 WHEN SC5.C5_YCLIORI <> '' AND SC5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE SC5.C5_VEND1 END) + ' - ' + 
		case when LC5.C5_VEND1 is not null then SA3.A3_NREDUZ else SA3V.A3_NREDUZ END

		,DIGITADO_POR = SC5.C5_YDIGP
		,LINHA = SC5.C5_YLINHA
		,TIPO_RES = C6_YTPEST
		,ENTREGA = C6_ENTREG
		,DT_NECESSIDADE = C6_YDTNECE
		,DT_NECES_REAL = C6_YDTNERE
		,NOME_PROD = SB1.B1_DESC 

		,LOG_RES_SC0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA 
		from PZ2140 A (nolock) where PZ2_CODENT = 'SC0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC0140 X (nolock) where C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_RES_PZ0 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CODMOT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2140 A (nolock) where PZ2_CODENT = 'PZ0' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from PZ0140 X (nolock) where PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,LOG_DEL_SC9 = 
		(select top 1 RTRIM(PZ2_CODENT)+'-'+RTRIM(PZ2_CONT)+'-'+RTRIM(PZ2_USURES)+'-'+RTRIM(convert(varchar(10),convert(smalldatetime,PZ2_DATA),103))+'-'+PZ2_HORA
		from PZ2140 A (nolock) where PZ2_CODENT = 'SC9' and PZ2_CODMOT = 'C9E' and PZ2_ID = 
		(select top 1 X.R_E_C_N_O_ from SC9140 X (nolock) where C9_FILIAL = '01' and C6_NUM = C9_PEDIDO and C6_ITEM = C9_ITEM order by X.R_E_C_N_O_ desc)
		order by A.R_E_C_N_O_ desc)

		,OBS = C6_YOBS

		FROM SC5140 SC5 (nolock)
		JOIN SC6140 SC6 (nolock) ON C6_FILIAL = SC5.C5_FILIAL AND SC5.C5_NUM = C6_NUM
		JOIN SB1010 SB1 (nolock) ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO  
		JOIN ZZ7010 ZZ7 (nolock) ON B1_YLINHA = ZZ7_COD AND B1_YLINSEQ = ZZ7_LINSEQ
		left join SC0140 SC0 (nolock) on C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV and C6_PRODUTO = C0_PRODUTO and SC0.D_E_L_E_T_ = ''
		left join PZ0140 PZ0 (nolock) on PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO and PZ0.D_E_L_E_T_ = ''
		LEFT JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '01' AND SC5.C5_NUM  = LC5.C5_YPEDORI	AND SC5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = SC5.C5_YCLIORI AND SC5.C5_YLOJORI = LC5.C5_LOJACLI AND SC5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' 
		left join SA3010 SA3 with (nolock) on SA3.A3_COD = LC5.C5_VEND1 
		left join SA3010 SA3V with (nolock) on SA3V.A3_COD = SC5.C5_VEND1 

		WHERE
		SC5.C5_FILIAL = '01'
		AND SC5.C5_YSUBTP NOT IN ('A','RI')
		AND SC5.C5_EMISSAO >= '20140101'
		AND C6_BLQ <> 'R'
		AND B1_TIPO = 'PA'
		and C0_PRODUTO is null
		and PZ0_CODPRO is null
		and ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9140 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0

		AND SC5.D_E_L_E_T_=' '
		AND SC6.D_E_L_E_T_=' '
		AND SB1.D_E_L_E_T_=' ' 
		AND ZZ7.D_E_L_E_T_=' ' 
		) TAB

		WHERE %EXP:cFiltro% 
		//Ticket 31731 apresentar todos pedidos que estejam sem reserva independente da data.
		//AND %EXP:cDtNece%
		ORDER BY 3,1,4,5

	EndSql 

	MemoWrite("\FROPRT07_SQL.TXT", GetLastQuery()[2]) 

	_lOk := !(cAliasAux)->(Eof())

	If _lOk             

		SM0->(DbSetOrder(1))
		SM0->(DbSeek(CEMPANT+CFILANT))

		_cArquivo := ProcExcel(cAliasAux)  

		//cRecebe 	:= AllTrim(GetNewPar("FA_R07MAIL","fernando@facilesistemas.com.br",CEMPANT))
		cRecebe		:= U_EmailWF("FROPRT07", CEMPANT)+";"
		cRecebe		+= U_EmailWF("FROPRT07", '05')
		cRecebe		:= DelMailDu(cRecebe)

		cRecebeCC	:= U_FMAATEMP(CEMPANT)+";"
		cRecebeCC	+= U_FMAATEMP('05')
		cRecebeCC	:= DelMailDu(cRecebeCC)


		cRecebeCO	:= ""
		cAssunto	:= AllTrim(SM0->M0_NOME)+" - LISTA DE PEDIDOS SEM RESERVA"   
		cMensagem 	:= "Segue anexo, lista de pedidos pendentes sem reserva de estoque ou OP"
		cAnexos		:= _cArquivo

		U_BIAEnvMail(,cRecebe,cAssunto,cMensagem,,cAnexos,.F.,cRecebeCC)

	EndIf

	If Select(cAliasAux) > 0
		(cAliasAux)->(DbCloseArea())
	EndIf

Return()     


Static Function DelMailDu(cLista)

	Local cNLista	:= ""
	Local aResult	:= StrTokArr(cLista, ";")
	Local nI		:= 0
	Local aRetAux	:= {}	
	Local cValor	:= ""
	Local aListaEN	:= {'jaqueline.goncalves@biancogres.com.br'}

	For nI := 1 to Len (aResult)
		cValor := aResult[nI]
		If (!Empty(cValor) .And. aScan(aRetAux, {|x| AllTrim(x) == AllTrim(cValor)}) == 0 )

			If (aScan(aListaEN, {|x| AllTrim(x) == AllTrim(cValor)}) == 0)

				AAdd(aRetAux, AllTrim(cValor))
				cNLista += cValor+";"

			EndIf

		EndIf
	Next nI

Return cNLista

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
FUNCAO PARA RETORNAR O RELATORIO DO PROCESSAMENTO EM EXCEL
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ProcExcel(cAliasAux)

	Local aArea := GetArea()
	Local oFWExcel := Nil
	Local oMsExcel := Nil
	Local cDir := "\P10\DOCTEMP\"//GetSrvProfString("Startpath", "")
	Local cFile := "PEDIDOS_SEM_RESERVA_EXCEL-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	Local cWorkSheet := ""
	Local cTable := ""
	Local cAliasTab

	cWorkSheet := "Pedidos pendentes de entrega e sem reserva."
	cTable := cWorkSheet + " - Data: "+DTOC(dDataBase)+" - Hora: "+SubStr(Time(),1,5)

	oFWExcel := FWMsExcel():New()
	oFWExcel:AddWorkSheet(cWorkSheet)
	oFWExcel:AddTable(cWorkSheet, cTable)

	oFWExcel:AddColumn(cWorkSheet, cTable, "EMPRESA"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "EMISSAO"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "PEDIDO"			, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "ITEM"			, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "CLIENTE"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "NOME CLIENTE"	, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "SEGMENTO"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "PRODUTO"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "SALDO_PED"		, 1, 2)
	oFWExcel:AddColumn(cWorkSheet, cTable, "VENDEDOR"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "DIGITADO_POR"	, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "LINHA"			, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "TIPO_RES"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "ENTREGA"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "DT_NECESSIDADE"	, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "DT_NECES_REAL"	, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "ATENDENTE"		, 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Log Exclusao SC0", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Log Exclusao PZ0", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Log Exclusao SC9", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "OBSERVAวรO ITEM", 1, 1)


	(cAliasAux)->(DbGoTop())
	While !(cAliasAux)->(Eof())

		aAux := {}                           
		AAdd(aAux, (cAliasAux)->EMPRESA)
		AAdd(aAux, DTOC(STOD((cAliasAux)->EMISSAO))) 
		AAdd(aAux, (cAliasAux)->PEDIDO)      
		AAdd(aAux, (cAliasAux)->ITEM)
		AAdd(aAux, (cAliasAux)->CLIENTE)     
		AAdd(aAux, (cAliasAux)->NOME_CLIENTE)
		AAdd(aAux, (cAliasAux)->SEGMENTO)      
		AAdd(aAux, AllTrim((cAliasAux)->PRODUTO)+" - "+AllTrim((cAliasAux)->NOME_PROD))     
		AAdd(aAux, (cAliasAux)->SALDO_PED)     
		AAdd(aAux, (cAliasAux)->VENDEDOR)     
		AAdd(aAux, (cAliasAux)->DIGITADO_POR)     
		AAdd(aAux, (cAliasAux)->LINHA)     
		AAdd(aAux, (cAliasAux)->TIPO_RES)     
		AAdd(aAux, DTOC(STOD((cAliasAux)->ENTREGA)))     
		AAdd(aAux, DTOC(STOD((cAliasAux)->DT_NECESSIDADE)))
		AAdd(aAux, DTOC(STOD((cAliasAux)->DT_NECES_REAL)))     


		AAdd(aAux, U_FCHKATEN((cAliasAux)->PEDIDO, (cAliasAux)->CODEMP) )  //atendente

		AAdd(aAux, (cAliasAux)->LOG_RES_SC0)     
		AAdd(aAux, (cAliasAux)->LOG_RES_PZ0)      
		AAdd(aAux, (cAliasAux)->LOG_DEL_SC9)

		AAdd(aAux, (cAliasAux)->OBS)

		oFWExcel:AddRow(cWorkSheet, cTable,	aAux)

		(cAliasAux)->(DbSkip())
	EndDo 


	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cDir+cFile)
	oFWExcel:DeActivate()

	RestArea(aArea)
Return(cDir + cFile)
