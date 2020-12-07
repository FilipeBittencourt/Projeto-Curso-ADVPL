#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFReenvioRemessaReceber
@author Tiago Rossini Coradini
@since 15/01/2019
@project Automação Financeira
@version 1.0
@description Classe para tratar os reenvio de titulos a receber
@type class
/*/

#DEFINE nP_JUROS 1
#DEFINE nP_PJUROS 2
#DEFINE nP_DTREF 3
#DEFINE nP_RECNO 4
	
Class TAFReenvioRemessaReceber From TAFAbstractClass			

	Data aTit // Titulos selecionados para envio
	Data oMrr // Objeto de movimento de remessa a receber
	Data oApi // Objeto de integracao com a API 

	Method New() Constructor
	Method Get()
	Method Resend()
	
EndClass


Method New() Class TAFReenvioRemessaReceber

	_Super:New()

	::aTit := {}
	::oMrr := TAFMovimentoRemessaReceber():New()
	::oApi := TAFIntegracaoApi():New()
								
Return()


Method Get() Class TAFReenvioRemessaReceber
Local aArea := GetArea()
Local nCount := 0
Local oLst := ArrayList():New()
Local oObj := Nil

	For nCount := 1 To Len(::aTit)

		DbSelectArea("SE1")
		SE1->(DbGoTo(::aTit[nCount, nP_RECNO]))
		
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

		oObj := TIAFMovimentoFinanceiro():New()
		 
		oObj:cPrefixo := SE1->E1_PREFIXO
		oObj:cNumero := SE1->E1_NUM
		oObj:cParcela := SE1->E1_PARCELA
		oObj:cTipo := SE1->E1_TIPO
		oObj:cCliFor := SE1->E1_CLIENTE
		oObj:cLoja := SE1->E1_LOJA
		oObj:nValor := SE1->E1_VALOR
		oObj:nSaldo := SE1->E1_SALDO
		oObj:nAbat := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA)
		oObj:nDesc := SE1->E1_DECRESC
		oObj:nAcre := ::oMrr:GetAcre(SA1->A1_YTFGNRE, SE1->E1_YCLASSE, AllTrim(SE1->E1_YEMP), AllTrim(SE1->E1_YUFCLI))
		oObj:nPerJur := SE1->E1_PORCJUR
		oObj:dEmissao := SE1->E1_EMISSAO
		oObj:dVencto := SE1->E1_VENCTO
		oObj:dVencRea := SE1->E1_VENCREA
		oObj:cNumBor := SE1->E1_NUMBOR
		oObj:cNumBco := SE1->E1_NUMBCO
		oObj:cIDCnab := SE1->E1_IDCNAB
		oObj:cPedido := SE1->E1_PEDIDO
		oObj:lRecAnt := If (oObj:cTipo == "BOL" .And. SubStr(oObj:cPrefixo, 1, 2) $ "PR/CT" .And. !Empty(oObj:cPedido), .T., .F.)		
		oObj:cBanco := SE1->E1_PORTADO
		oObj:cAgencia := SE1->E1_AGEDEP		
		oObj:cConta := SE1->E1_CONTA
		oObj:cSubCta := ""
		
		oObj:nRecNo := SE1->(RecNo())		
						
		// Somente calcular juros para boletos vencidos e com a opcao de calculo = 'S'
		If ::aTit[nCount, nP_JUROS] == "S" .And. oObj:dVencto < ::aTit[nCount, nP_DTREF]
		
			oObj:lJuros := .T.
			
			// Atribui o percentual de juros, padrao = 0.2 dia ou valor definido na tela
			If (oObj:nPerJur := (::aTit[nCount, nP_PJUROS] / 30)) <= 0
				
				oObj:nPerJur := SE1->E1_PORCJUR
				
			EndIf
							
			oObj:nJuros := NoRound(oObj:nPerJur * oObj:nSaldo / 100, 2) * (::aTit[nCount, nP_DTREF] - oObj:dVencto)
			oObj:dVencOri := oObj:dVencto
			oObj:nSalOri := oObj:nSaldo - oObj:nAbat
							
		Else
		
			// Se nao calcula juros (Titulo postergado), envia o valor do juros diarios para a impressao diretamente via API
			oObj:nJurosDia := (oObj:nPerJur / 100) * oObj:nSaldo + oObj:nJuros - oObj:nAbat
									
		EndIf
				
		// Calculo do valor total do boleto
		oObj:nValorBol := oObj:nSaldo + oObj:nJuros - oObj:nAbat
								
		// Tratamento de mensagens livres
		oObj:cMsgLiv1 := If(Empty(oObj:cMsgLiv1), oObj:cMsgLiv1, oObj:cMsgLiv1 + " ") + "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA " + dToC(oObj:dVencto)
				
		If oObj:lJuros
						
			oObj:cMsgLiv2 := "VENCIMENTO ORIGINAL: "+ dToC(oObj:dVencOri) +;
											 Space(1) + "VALOR ORIGINAL: "+ Alltrim(Transform(oObj:nSalOri, "@E 99,999,999.99")) +;
											 Space(1) + "ENCARGOS: " + Alltrim(Transform(oObj:nJuros, "@E 99,999,999.99"))												 												

		ElseIf oObj:nJurosDia > 0
		
			oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "JUROS POR DIA: R$ " + Alltrim(Transform(oObj:nJurosDia, "@E 99,999,999.99"))
		
		EndIf
			
		If oObj:lRecAnt
			
			oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "BOLETO REFERENTE AO PEDIDO DE VENDA: " + Upper(oObj:cPedido)
			
		EndIf
				
		If AllTrim(oObj:cTipo) == "FT"
						
			oObj:cMsgLiv3 := If(Empty(oObj:cMsgLiv3), oObj:cMsgLiv3, oObj:cMsgLiv3 + " ") + ::GetFatura(oObj:cPrefixo, oObj:cNumero, oObj:cParcela)
		
		EndIf

		If oObj:lJuros
			
			oObj:dVencto := ::aTit[nCount, nP_DTREF]
			
		EndIf
		
		oLst:Add(oObj)
								
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"	
		::oLog:cMetodo := "S_REE_TIT"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := SE1->(RecNo())
		::oLog:cEnvWF := "S"
		
		::oLog:Insert()
		
	Next
	
	RestArea(aArea)

Return(oLst)


Method Resend() Class TAFReenvioRemessaReceber

	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_REE_TIT"

	::oLog:Insert()
	
	::oApi:cTipo := "R"
	::oApi:cOpcEnv := "L"
	::oApi:cReimpr := "S"
	::oApi:GArqRem := "N"
	::oApi:oLst := ::Get()
			
	::oApi:Send(::oPro:cIDProc)

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_REE_TIT"

	::oLog:Insert()
	
	::oPro:Finish()	
		
Return()