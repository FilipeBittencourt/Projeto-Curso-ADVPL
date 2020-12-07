#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF125
@author Tiago RossinPos CoradinPos
@since 12/11/2018
@version 1.0
@description Exibe mensagem de cliente na zona suframa
@obs Ticket: 8329
@type Function
/*/

Static __NumPedDe := Nil
Static __NumPedAte := Nil
Static __NumCarDe := Nil
Static __NumCarAte := Nil


User Function BIAF125(cAlias)
Local aArea := GetArea()
Local cSQL 	:= ""
Local cQry 	:= GetNextAlias()
Local cUF 	:= GetMv("MV_UFSUFRAMA",,"AC/RO/RR/AM")
Local cMsg 	:= ""
Local Enter	:= CHR(13)+CHR(10)

	If ValType(__NumPedDe) == "U"
		__NumPedDe := MV_PAR05
	EndIf
	
	If ValType(__NumPedAte) == "U"
		__NumPedAte := MV_PAR06
	EndIf
	
	If ValType(__NumCarDe) == "U"
		__NumCarDe := MV_PAR19
	EndIf
	
	If ValType(__NumCarAte) == "U"
		__NumCarAte := MV_PAR20
	EndIf			
	
	cSQL := "SELECT SC9.C9_CLIENTE" + Enter
	cSQL += "	, SC9.C9_LOJA" + Enter
	cSQL += "	, SA1.A1_NOME" + Enter
	cSQL += "	, SA1.A1_EST" + Enter
	cSQL += "FROM " + RetSQLName("SC9") + " SC9 WITH(NOLOCK)" + Enter
	cSQL += "	INNER JOIN " + RetSQLName("SA1") + " SA1 WITH(NOLOCK) ON SC9.C9_CLIENTE = SA1.A1_COD" + Enter
	cSQL += "		AND SC9.C9_LOJA = SA1.A1_LOJA" + Enter
	cSQL += "	INNER JOIN " + RetSQLName("SC5") + " SC5 WITH(NOLOCK) ON SC9.C9_PEDIDO = SC5.C5_NUM" + Enter
	cSQL += "		AND SC9.C9_CLIENTE = SC5.C5_CLIENTE" + Enter
	cSQL += "		AND SC9.C9_LOJA = SC5.C5_LOJACLI" + Enter
	cSQL += "WHERE SC9.C9_FILIAL = " + ValToSQL(xFilial("SC9")) + Enter
	cSQL += "	AND SC9.C9_NFISCAL = ''" + Enter
	cSQL += "	AND SC9.C9_PEDIDO BETWEEN " + ValToSQL(__NumPedDe) + " AND " + ValToSQL(__NumPedAte) + Enter
	cSQL += "	AND SC9.C9_AGREG BETWEEN " + ValToSQL(__NumCarDe) + " AND " + ValToSQL(__NumCarAte) + Enter
	cSQL += "	AND SC9.C9_OK " + If (ThisInv(), "<>", "=") + ValToSQL(ThisMark()) + Enter
	cSQL += "	AND SC9.D_E_L_E_T_ = ''" + Enter
	cSQL += "	AND SA1.A1_FILIAL = " + ValToSQL(xFilial("SA1")) + Enter
	cSQL += "	AND SA1.A1_EST IN " + FormatIn(cUF, "/") + Enter
	cSQL += "	AND SA1.D_E_L_E_T_ = ''" + Enter
	cSQL += "	AND SC5.C5_FILIAL = " + ValToSQL(xFilial("SC9"))+ Enter	
	cSQL += "	AND SC5.C5_TIPO NOT IN ('D','B')" + Enter
	cSQL += "	AND SC5.D_E_L_E_T_ = ''" + Enter
	cSQL += "GROUP BY SC9.C9_CLIENTE" + Enter
	cSQL += "	, SC9.C9_LOJA" + Enter
	cSQL += "	, SA1.A1_NOME" + Enter
	cSQL += "	, SA1.A1_EST" + Enter
	cSQL += "ORDER BY SC9.C9_CLIENTE" + Enter
	cSQL += "	, SC9.C9_LOJA" + Enter
	cSQL += "	, SA1.A1_NOME" + Enter
	cSQL += "	, SA1.A1_EST" + Enter
	
	TcQuery cSQL New Alias (cQry)
	  			
	While (cQry)->(!Eof())
		
		If Empty(cMsg)

			cMsg := PadR("Cliente", 10) + PadR("Loja", 10) + PadR("Nome", 60) + Chr(13) + Chr(10)
			
		EndIf
		
		cMsg += PadR((cQry)->C9_CLIENTE, 10) + PadR((cQry)->C9_LOJA, 10) + PadR((cQry)->A1_NOME, 60) + Chr(13) + Chr(10)
		
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
	
	If !Empty(cMsg)
	
		U_FROPMSG("Clientes com insenção fiscal na Zona Suframada", cMsg)
		
	EndIf
	
	RestArea(aArea)
	
	MA460NOTA(cAlias)

Return()