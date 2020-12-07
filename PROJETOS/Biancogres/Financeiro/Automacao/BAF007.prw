#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF007
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Teste remessa a receber - Envio de boletos para a API 
@type function
/*/

User Function BAF007()
Local aArea := GetArea()
Local oParam := TParBAF007():New()
	
	If oParam:Box()
					
		U_BIAMsgRun("Gerando boletos via - [API Facile.Net]...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
	RestArea(aArea)

Return()


Static Function fProcess(oParam)
Local cSQL := ""
Local cQry := GetNextAlias()
Local oLstTit := ArrayList():New()
Local oMovFin := TIAFMovimentoFinanceiro():New()
Local oRcb := TAFRegraComunicacaoBancaria():New()
Local oIApi := TAFIntegracaoApi():New()

	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, E1_SALDO, E1_DECRESC, E1_PORCJUR, E1_EMISSAO, E1_VENCTO, E1_VENCREA, " 
	cSQL += " E1_NUMBOR, E1_NUMBCO, E1_IDCNAB, E1_PEDIDO, E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_SITUACA, E1_YCDGREG, E1_YCLASSE, E1_YEMP, E1_YUFCLI, SE1.R_E_C_N_O_ AS SE1_RECNO, " 
	cSQL += " A1_YCDGREG, A1_YDTPRO, A1_YTFGNRE, E1_NATUREZ "
	cSQL += " FROM "+ RetSQLName("SE1") + " SE1 "
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " SA1 "
	cSQL += " ON E1_CLIENTE = A1_COD "
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_NUMBOR BETWEEN "+ ValToSQL(oParam:cNumBorDe) + " AND " + ValToSQL(oParam:cNumBorAte) 
	cSQL += " AND SE1.D_E_L_E_T_ = '' "
	cSQL += " AND A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E1_NUMBOR, E1_CLIENTE, A1_YCDGREG "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
		
		oMovFin := TIAFMovimentoFinanceiro():New()
		 
		oMovFin:cPrefixo := (cQry)->E1_PREFIXO
		oMovFin:cNumero := (cQry)->E1_NUM
		oMovFin:cParcela := (cQry)->E1_PARCELA
		oMovFin:cTipo := (cQry)->E1_TIPO
		oMovFin:cCliFor := (cQry)->E1_CLIENTE
		oMovFin:cLoja := (cQry)->E1_LOJA
		oMovFin:nValor := (cQry)->E1_VALOR
		oMovFin:nSaldo := (cQry)->E1_SALDO
		oMovFin:nAbat := SomaAbat((cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, "R", 1,, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA)
		oMovFin:nDesc := (cQry)->E1_DECRESC
		oMovFin:nAcre := fGetAcre((cQry)->A1_YTFGNRE, (cQry)->E1_YCLASSE, AllTrim((cQry)->E1_YEMP), AllTrim((cQry)->E1_YUFCLI))
		oMovFin:nPerJur := (cQry)->E1_PORCJUR
		oMovFin:dEmissao := sToD((cQry)->E1_EMISSAO)
		oMovFin:dVencto := If (sToD((cQry)->E1_VENCTO) < dDataBase, dDataBase, sToD((cQry)->E1_VENCTO))
		oMovFin:dVencRea := sToD((cQry)->E1_VENCREA)
		oMovFin:cNumBor := (cQry)->E1_NUMBOR
		oMovFin:cNumBco := (cQry)->E1_NUMBCO
		oMovFin:cIDCnab := (cQry)->E1_IDCNAB
		oMovFin:lRecAnt := If (oMovFin:cTipo == "BOL" .And. SubStr(oMovFin:cPrefixo, 1, 2) $ "PR/CT" .And. !Empty(oMovFin:cPedido), .T., .F.)
		oMovFin:nRecNo := (cQry)->SE1_RECNO
		
		oMovFin:cBanco := (cQry)->E1_PORTADO
		oMovFin:cAgencia := (cQry)->E1_AGEDEP
		oMovFin:cConta := (cQry)->E1_CONTA
		oMovFin:cSubCta := ""
		oMovFin:cSituacao := "1"
		oMovFin:cEspecie := ""		
		
		// Tratamento de juros
		If sToD((cQry)->E1_VENCTO) < dDataBase
		
			oMovFin:lJuros := .T.
			oMovFin:nJuros := NOROUND((cQry)->E1_PORCJUR * (cQry)->E1_VALOR / 100, 2) * (dDataBase - sToD((cQry)->E1_VENCTO))		
			oMovFin:dVencOri := sToD((cQry)->E1_VENCTO)
			oMovFin:nSalOri := oMovFin:nSaldo - oMovFin:nAbat
		
		EndIf
		
		oMovFin:nJurosDia := ((6/30) / 100) * oMovFin:nSaldo + oMovFin:nJuros - oMovFin:nAbat
				
		// Tratamento de multa
		oMovFin:nMulta := 0
		
		oMovFin:nValorBol := oMovFin:nSaldo - oMovFin:nJuros - oMovFin:nAbat
		
		// Tratamento de protesto				
		oMovFin:nCodProt := If ((cQry)->A1_YDTPRO >= 6, 1, 2)
		oMovFin:nDiaProt := (cQry)->A1_YDTPRO
		
		// Tratamento de mensagens livres		
		If oMovFin:lRecAnt .Or. oMovFin:lJuros
		
			oMovFin:cMsgLiv1 := "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA "+ dToC(oMovFin:dVencto)
			
			If oMovFin:lRecAnt
			
				oMovFin:cMsgLiv2 := "BOLETO REFERENTE AO PEDIDO DE VENDA: "+ Upper(oMovFin:cPedido)				
				oMovFin:cMsgLiv3 := If (oMovFin:nDesc > 0, "DESCONTO CONCEDIDO: " + oMovFin:nDesc, "")
			
			ElseIf oMovFin:lJuros
			
				oMovFin:cMsgLiv2 := "VENCIMENTO ORIGINAL: "+ dToC(oMovFin:dVencOri) +;
												 Space(1) + "VALOR ORIGINAL: "+ Alltrim(Transform(oMovFin:nSalOri, "@E 99,999,999.99")) +;
												 Space(1) + "ENCARGOS: " + Alltrim(Transform(oMovFin:nJuros, "@E 99,999,999.99")) +;
												 If (oMovFin:nAcre > 0 .And. AllTrim((cQry)->E1_NATUREZ) == "1230", Space(2) + " TARIFA GNRE ELETRONICA: R$ " + Alltrim(Transform(oMovFin:nAcre, "@E 99,999,999.99")), "")							
			EndIf
		
		EndIf
		
		If AllTrim(oMovFin:cTipo) == "FT"
						
			oMovFin:cMsgLiv3 := If (Empty(oMovFin:cMsgLiv3), "", Chr(13) + Chr10) + fGetFatura(oMovFin:cPrefixo, oMovFin:cNumero, oMovFin:cParcela)
		
		EndIf

		oMovFin:cGRCB := (cQry)->A1_YCDGREG
		oMovFin:cRCB := (cQry)->E1_YCDGREG
		oMovFin:lMRCB := .F.
								
		oLstTit:Add(oMovFin)
				
		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())
 
	If oLstTit:GetCount() > 0
		
		// Define regras de comunicacao bancaria
		oRcb:cTipo := "R"
		oRcb:cOpc := "E"
		oRcb:oLst := oLstTit
		oRcb:Set()
		
		oIApi:cTipo := "R"
		oIApi:cOpcEnv := oParam:cOpcEnv
		oIApi:cReimpr := oParam:cReimpr
		oIApi:oLst := oLstTit
		
		oIApi:Send()
					
	EndIf
	
Return()


Static Function fGetAcre(cGNRE, cClasse, cEmpTit, cUFCli)
Local nRet := 0
	
	If cGNRE == "S"
	
		If cClasse == "1"
		
			If cEmpAnt == "07" .And. cEmpTit == "0599" .And. cUFCli $ "SP_MG" 
				
				If Dtos(SE1->E1_EMISSAO) >= "20150903"
				
					oTafNFRE	:= TAFTarifaGNRE():New()
					nRet 		:= oTafNFRE:TarifaPorEstado(cUFCli)
				
					/*If cUFCli == "MG"
					
						nRet := GetMv("MV_YVLBLMG")
					
					ElseIf cUFCli == "SP"
						
						nRet := GetMv("MV_YVLBLSP")
						
					EndIf
					*/
					
				Else
					
					nRet := 0
					
				EndIf
				
			Else			
				
				oTafNFRE	:= TAFTarifaGNRE():New()
				nRet 		:= oTafNFRE:TarifaPorEstado(cUFCli)
				
				
				/*If cUFCli == "MG"
					
					nRet := GetMv("MV_YVLBLMG")
					
				ElseIf cUFCli == "ES"
					
					nRet:= GetMv("MV_YVLBLES")
					
				ElseIf cUFCli == "SP"
					
					nRet:= GetMv("MV_YVLBLSP")
					
				ElseIf cUFCli == "BA"
					
					nRet := GetMv("MV_YVLBLBA")
					
				ElseIf cUFCli == "RJ"
					
					nRet := GetMv("MV_YVLBLRJ")
					
				ElseIf cUFCli == "AL"
					
					nRet := GetMv("MV_YVLBLAL")
					
				ElseIf cUFCli == "RS"
					
					nRet := GetMv("MV_YVLBLRS")
					
				ElseIf cUFCli == "PR"
					
					nRet := GetMv("MV_YVLBLPR")
					
				ElseIf cUFCli == "SC"
					
					nRet := GetMv("MV_YVLBLSC")
					
				ElseIf cUFCli == "AP"
					
					nRet := GetMv("MV_YVLBLAP")
					
				ElseIf cUFCli == "PE"
					
					nRet := GetMv("MV_YVLBLPE")
								
				Else
					
					nRet	:= 0
					
				EndIf
				
				*/
				
			EndIf
					
		EndIf
		
	EndIf
	
Return(nRet)


Static Function fGetFatura(cPrefixo, cNumero, cParcela)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT DISTINCT E1_NUM, E1_PARCELA "
	cSQL += " FROM " + RetSqlName("SE1")
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_FATPREF = "+ ValToSQL(cPrefixo)
	cSQL += " AND E1_FATURA = "+ ValToSQL(cNumero)
	cSQL += " AND E1_YPARCFT = "+ ValToSQL(cParcela)
	cSQL += " AND E1_TIPOFAT = 'FT' "
	cSQL += " AND E1_FLAGFAT = 'S' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		If Empty(cRet)
			
			cRet := "Fatura Ref NF/Parcela:"
			
		EndIf		
		
		cRet += AllTrim((cQry)->E1_NUM) + '/' + AllTrim((cQry)->E1_PARCELA) + Space(1)
				
		(cQry)->(DbSkip())
			
	EndDo()

Return(cRet)