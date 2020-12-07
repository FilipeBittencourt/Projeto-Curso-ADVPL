#Include "Protheus.CH"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"
#Include "tbiconn.ch"

/*/{Protheus.doc} BACP0017
@description Monitor de Impressao Automatica
@author Fernando Rocha
@since 27/11/2019
@version 1.0
@type function
/*/
User Function BACP0017(cCarga)

	Local xv_Emps	:= {}
	Local nI		:= 0

	Default cCarga := ""

	RpcSetEnv('01','01')

	xv_Emps    := U_BAGtEmpr("01_05_13")

	RpcClearEnv()

	For nI := 1 to Len(xv_Emps)
		
		RPCSetType(3)
		RPCSetEnv(xv_Emps[nI, 1], xv_Emps[nI, 2])
			
			//Parametro para desligar os Jobs Automaticos em caso de Necessidade
			If (U_GETBIAPAR("BIA_FATAUTO", .T. , xv_Emps[nI,1], xv_Emps[nI,2]))
				ProcImpressao(cCarga)
			Else
				ConOut("BACP0017 ==> Cancelado/Desligado[BIA_FATAUTO] - " + Time()+" => Empresa: "+xv_Emps[nI,1]+" Filial: "+xv_Emps[nI,2])
			EndIf
			
		
		RpcClearEnv()
		
	Next nI

Return()

Static Function ProcImpressao(cCarga)

	Local cQuery		:= ""
	Local cIdEnt		:= ""
	Local cAliasTemp	:= Nil
	Local oObj			:= Nil

	cAliasTemp	:= GetNextAlias()
	cIdEnt		:= GetCfgEntidade()	
	oObj		:= TFaturamentoMonitor():New()

	cQuery := " SELECT TAB.*, ZZV_FIMP, ZZV_DATAAG " + CRLF 
	cQuery += " FROM   ( " + CRLF 
	cQuery += "            SELECT DISTINCT SUBSTRING(A.F2_YAGREG, 5, 4) CARGA " + CRLF 
	cQuery += "            FROM   " + RetSqlName("SF2") + " A (NOLOCK) " + CRLF 
	cQuery += "            WHERE  A.F2_FILIAL = '01' " + CRLF 
	cQuery += "              AND  A.F2_EMISSAO >= " + ValToSql(dDataBase) + CRLF

	If !Empty(cCarga)
		
		cQuery += " AND SUBSTRING(A.F2_YAGREG, 5, 4) = '" + cCarga + "' "+CRLF
		
	EndIf

	cQuery += "              AND  A.D_E_L_E_T_ = '' " + CRLF 
	cQuery += "        ) TAB " + CRLF 
	cQuery += " JOIN    "+RetSqlName("ZZV")+"  ZZV (NOLOCK) " + CRLF 
	cQuery += "   ON ( " + CRLF 
	cQuery += "          ZZV_FILIAL    = '01' " + CRLF 
	cQuery += "    AND   ZZV_FIMP      = 'A' " + CRLF 
	cQuery += "    AND   ZZV.ZZV_CARGA = TAB.CARGA " + CRLF 
	cQuery += "      ) " + CRLF 

	If Empty(cCarga)

		cQuery += " WHERE  NOT EXISTS ( " + CRLF 
		cQuery += "                       SELECT OK " + CRLF 
		cQuery += "                       FROM   ( " + CRLF 
		cQuery += "                                  SELECT ZZW_CARGA, " + CRLF 
		cQuery += "                                         NFBIA = C9_NFISCAL, " + CRLF 
		cQuery += "                                         OK = CASE " + CRLF 
		cQuery += "                                                   WHEN C9_CLIENTE <> '010064' " + CRLF 
		cQuery += "                                                    AND C9_NFISCAL <> '' THEN 'S' " + CRLF 
		cQuery += "                                                   ELSE " + CRLF 
		cQuery += "                                                       CASE " + CRLF 
		cQuery += "                                                            WHEN ( " + CRLF 
		cQuery += "                                                                     SELECT TOP 1 C9_NFISCAL " + CRLF 
		cQuery += "                                                                     FROM   SC9070 C9LM (NOLOCK) " + CRLF 
		cQuery += "                                                                     WHERE  C9LM.C9_FILIAL = '01' " + CRLF 
		cQuery += "                                                                       AND  C9LM.C9_BLINF   = '01' + SC9.C9_NFISCAL " + CRLF 
		cQuery += "                                                                                              + SC9.C9_SERIENF + SC9.C9_PEDIDO " + CRLF 
		cQuery += "                                                                                              + SC9.C9_ITEM + SC9.C9_SEQUEN " + CRLF 
		cQuery += "                                                                       AND  D_E_L_E_T_      = '' " + CRLF 
		cQuery += "                                                                 ) <> '' THEN 'S' " + CRLF 
		cQuery += "                                                            ELSE 'NOTLM' END END " + CRLF 
		cQuery += "                                  FROM   " + RetSqlName("ZZW") + " ZZW (NOLOCK) " + CRLF 
		cQuery += "                                  JOIN   " + RetSqlName("SC9") + " SC9 (NOLOCK) " + CRLF 
		cQuery += "                                    ON C9_FILIAL      = ZZW_FILIAL " + CRLF 
		cQuery += "                                   AND C9_PEDIDO      = ZZW_PEDIDO " + CRLF 
		cQuery += "                                   AND C9_ITEM        = ZZW_ITEM " + CRLF 
		cQuery += "                                   AND C9_SEQUEN      = ZZW_SEQUEN " + CRLF 
		cQuery += "                                   AND SC9.D_E_L_E_T_ = '' " + CRLF 
		cQuery += "                                  WHERE  ZZW_FILIAL    = ZZV_FILIAL " + CRLF 
		cQuery += "                                    AND  ZZW_CARGA      = ZZV_CARGA " + CRLF 
		cQuery += "                                    AND  ZZW.D_E_L_E_T_ = '' " + CRLF 
		cQuery += "                              ) TAB " + CRLF 
		cQuery += "                       WHERE  OK <> 'S' " + CRLF 
		cQuery += "                   ) " + CRLF 

	EndIf

	TcQuery cQuery New Alias (cAliasTemp)	

	DBSelectArea("ZZV")
	ZZV->(DbSetOrder(1))

	While !(cAliasTemp)->(EoF())

		If ZZV->(DbSeek(xFilial("ZZV") + (cAliasTemp)->CARGA))

			Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Processo iniciado - [ZZV_FIMP] = " + ZZV->ZZV_FIMP)

			If ZZV->ZZV_FIMP == "A"

				If oObj:CargaOk((cAliasTemp)->CARGA)
					
					oObj:SetPrintOk((cAliasTemp)->CARGA, "1")

					Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Gerando documentos")

					//BEGIN TRANSACTION

						Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Gerando documentos [NF-e ] - Inicio")
						U_FPRCARGA((cAliasTemp)->CARGA, .T., .F.) // NF-e
						Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Gerando documentos [NF-e ] - Fim")

						Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Gerando documentos [MDF-e] - Inicio")
						U_BACP0015((cAliasTemp)->CARGA, .T.) // MDF-e
						Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Gerando documentos [MDF-e] - Fim")

						Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Gerando documentos [GNR-e] - Inicio")
						U_BACP0016((cAliasTemp)->CARGA, .T.) // GNR-e
						Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Gerando documentos [GNR-e] - Fim")

					//END TRANSACTION

				Else

					Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Processo incompleto")

				EndIf

			EndIf

			Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Processo Finalizado")

		Else

			Conout("BACP0017 ==> Carga: " + (cAliasTemp)->CARGA + " [" + Time() + "] - Processo Finalizado - [Carga nao encontrada!]")

		EndIf

		(cAliasTemp)->(DbSkip())

	EndDo

	(cAliasTemp)->(DbCloseArea())

Return()