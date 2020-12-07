#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0042; Return()

/*
|---------------------------------------------------------|
| Classe:	| TBiaMensagemFiscalNfeSefaz										|
| Autor:  | Tiago Rossini Coradini - Facile Sistemas			|
| Data:		| 02/02/15																			|
|---------------------------------------------------------|
| Desc.:	| Classe para manipulação das mensagens fiscais |
| 				| da nota fiscal eletrônica 										|
|---------------------------------------------------------|
*/

Class TBiaMensagemFiscalNfeSefaz From LongClassName
	
	Data cMensagem
			
	Method New(cParam) Constructor
	Method Update()
	
EndClass


Method New(cParam) Class TBiaMensagemFiscalNfeSefaz
  
	::cMensagem := cParam
		
Return()


Method Update() Class TBiaMensagemFiscalNfeSefaz
Local aArea := GetArea()
Local cConPag := ""
Local cSQL := ""
Local cSD1 := RetSQLName("SD1")
Local cQry := GetNextAlias()

	
	If SFT->FT_TIPOMOV == "S"
			
		// Imprime Inscricao Suframa
		// OS: 2437-16 - Tania de Fatima - Impressao de suframa somente para notas diferentes de D/B		
		If !Alltrim(SF2->F2_TIPO) $ "D/B" .And. !Empty(AllTrim(SA1->A1_SUFRAMA))
			::cMensagem += "Insc. SUFRAMA " + SA1->A1_SUFRAMA	
		EndIf
				
		
		// Impressao Frete Autonomo
		If !Empty(SF2->F2_ICMAUTO)
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += "ART 220 DO DEC 1090-R DE 25/10/02 O RICMS/ES # "
			::cMensagem += "Resp.Frete: " + If (SC5->C5_TPFRETE == "C","REMETENTE ","ADQUIRENTE ") + "Recolh.: REMETENTE # "
			::cMensagem += "Base de Calculo: R$ " + Alltrim(Trans(SF2->F2_FRETAUT,"@E 999,999.99")) + "  /  Aliquota: 12% - ICMS: R$ " + Alltrim(Trans(SF2->F2_ICMAUTO,"@E 999,999.99"))
			
		EndIf
		

		// Impressao Regime Especial para MG
		If !Empty(SA1->A1_YREGESP) .And. cEmpAnt == "07" .And. SF2->F2_EST == "MG"
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += "Destinatario detentor de Regime Especial em Minas Gerais conf. N. RE/PTA: " + Alltrim(SA1->A1_YREGESP)
			
		EndIf
		

		// Impressao Regime Especial para BA
		If !Empty(SA1->A1_YREGESP) .AND. SF2->F2_EST == "BA"

			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf			
			
			::cMensagem += "Destinatario detentor de Regime Especial no Estado da Bahia conf. Processo nº: " + Alltrim(SA1->A1_YREGESP)
			
		EndIf


		// Mensagem de ICMS ST para BA
		If (SF2->F2_ICMSRET > 0 .And. SF2->F2_EST == "BA") 
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf

			::cMensagem += "ICMS retido por Substituição Tributária - Protocolos nºs 26/2010"
			
		EndIf

		// Mensagem de ICMS ST para ES
		If (SF2->F2_ICMSRET > 0 .And. SF2->F2_EST == "ES")
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += "ICMS retido por Substituição Tributária conf. Decreto 1090R/2002"
			
		EndIf

		
		// Mensagem ICMS ST para os estados com destaque do ICMS ST na NF exceto BA e ES
		If (SF2->F2_ICMSRET > 0 .And. SF2->F2_EST $ GetMV("MV_YUFSTCD") .And. !SF2->F2_EST $ "BA_ES" )
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
									   
			::cMensagem += "ICMS retido por Substituição Tributária - Protocolos nºs 26/2010 e 196/2009 alterado pelo 38/2013"
			
		EndIf
		
		
		// Tiago Rossini Coradini - 20/02/2017 - OS: 3006-15 - Bloco de Mensagem para Nota de Devolucao comentado pois o padrao atende 
		// Mensagem para Nota de Devolucao
		/*
		DbSelectArea("SD2")
		DbSetOrder(3)
		If SD2->(DbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
		
			While SD2->(!Eof()) .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
			
				If !Empty(SD2->D2_NFORI)
			
					If !Empty(::cMensagem)
						::cMensagem += " "
					EndIf
				
					::cMensagem += "Nota Fiscal Original No " + SD2->D2_SERIORI + Alltrim(SD2->D2_NFORI)
			
				EndIf
			
				SD2->(DbSkip())
			
			EndDo
		
		EndIf
		*/
		
		// Mensagem para Nota com Condição Pagamento Antecipado
		cConPag := Posicione("SE4", 1, xFilial("SE4") + SF2->F2_COND, "E4_DESCRI")
	
		// Tiago Rossini Coradini - OS: 2812-15 - Não imprime mensagem para a LM.
		If "ANTE" $ Alltrim(cConPag) .And. SF2->F2_CLIENTE <> "010064"
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += "Mercadoria recebida antecipada."
			
		EndIf
                    
		
		// Mensagem para Desconto Incondicional
		If !Empty(SF2->F2_DESCONT)
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += "Desconto Incondicional R$ " + Alltrim(Trans((SF2->F2_DESCONT), "@E 999,999.99"))
			
		EndIf
	
		
		// Tiago Rossini Coradini - 14/03/2016 - OS: 0115-16 - Nilmara Oliveira - Mensagem adicional na LM para revendedor dentro do ES
		If cEmpAnt == "07" .And. SF2->F2_EST == "ES" .And. SA1->A1_TIPO == "S"
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += "Base de calculo red. Conf art 534 Z-Z-A do RICMS e MVA reduzida conf. Portaria N 49-R"
			
		EndIf
		
		
		// Mensagem Padrao da Nota
		If !Empty(SF2->F2_YMENPAD) .And. !AllTrim(Formula(SF2->F2_YMENPAD)) $ ::cMensagem
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += AllTrim(Formula(SF2->F2_YMENPAD))						
			
		EndIf
	
	
	ElseIf SFT->FT_TIPOMOV == "E"
	
		// Tratamento para impressao de dados de Importacao
		If Empty(::cMensagem)
					
			cSQL := " SELECT CONVERT(VARCHAR(500), CONVERT(BINARY(500),D1_YOBS)) AS D1_YOBS "
			cSQL += " FROM "+ cSD1
			cSQL += " WHERE D1_FILIAL = "+ ValToSQL(SF1->F1_FILIAL)
			cSQL += " AND D1_DOC = "+ ValToSQL(SF1->F1_DOC)
			cSQL += " AND D1_SERIE = "+ ValToSQL(SF1->F1_SERIE)
			cSQL += " AND D1_FORNECE = "+ ValToSQL(SF1->F1_FORNECE)
			cSQL += " AND D1_LOJA = "+ ValToSQL(SF1->F1_LOJA)
			cSQL += " AND D1_FORMUL = 'S' "
			cSQL += " AND D_E_L_E_T_ = '' "
			cSQL += " ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM, D1_COD "
			
			TcQuery cSQL New Alias (cQry)
			
			If !Empty(Alltrim((cQry)->D1_YOBS))
				::cMensagem += Alltrim((cQry)->D1_YOBS)
			EndIf
			
			(cQry)->(DbCloseArea())
		
		EndIf		
	
	EndIf

	//Retira caracteres especiais - Problema na NF 4.0
	::cMensagem := U_fDelTab(::cMensagem)
			
	RestArea(aArea)
		
Return(::cMensagem)