#Include 'Protheus.ch'

/*/{Protheus.doc} MA410MNU
@description PONTO DE ENTRADA PARA A INCLUSAO DE BOTOES NA ROTINA DE PEDIDOS DE VENDA
@author Rubens Junior (FACILE SISTEMAS)
@since 15/04/2014
@type function
/*/
User Function MA410MNU()

	Local oAceTela 			:= TAcessoTelemarketing():New()

	If (!oAceTela:UserTelemaketing())

		aadd(arotina, {"Solic. Credito",'U_GetSolCred()',0,7,0,NIL})
		aadd(arotina, {"Imprimir",'U_BIAFR006()',0,7,0,NIL})

		//Fernando - Comentado em 28/10/2015 - possibilidade de alguem fazer ao mesmo tempo que o representante e duplicar pedidos - criar um parametro para impedir
		//A schedule esta replicando automatico 15 minutos depois
		If AllTrim(CEMPANT) == "07" .And. Upper(AllTrim(getenvserver())) $ "COMP-WANISAY###COMP-FERNANDO###COMP-RANISSES###COMP-FERNANDO-TESTE-FACILE###COMP-PEDRO###DEV-PEDRO###DEV-VINILICO###"
			aadd(arotina, {"Replicar Pedido",'U_FCOMRT01(SC5->C5_NUM, .T., .F.)',0,4,0,NIL})
		EndIf

		If AllTrim(CEMPANT) $ "01_05_13_14" .And. TYPE("CREPATU")<>"U" .And. Empty(CREPATU) .And. AllTrim(CUSERNAME) == "FACILE"
			aadd(arotina, {"Proc.Reservas Pedido",'U_FROPRT05(.F.)',0,4,0,NIL})
		EndIf

		aAdd(arotina, {"Vlr Min Parc Contrato", 'U_BIAF079("MV_YVRPARM", "043")',0,4,0,NIL})

		//If Upper(AllTrim(getenvserver())) $ "COMP-FERNANDO"
		aadd(arotina, {"Recalcular Baixas AI",'U_B410CBAI()',0,4,0,NIL})
		//EndIf

		aadd(arotina, {"Pedido x Aprovadores",'U_BACP0006(SC5->C5_NUM, SC5->C5_FILIAL)',0,4,0,NIL})

		aadd(arotina, {"Fat. em partes", 'U_BACP0020()',0,4,0,NIL})

		If U_VALOPER("C10",.F.) .Or. ( TYPE("CREPATU")<>"U" .And. !Empty(CREPATU) .And. Date() <= STOD("20200930") )
			aadd(arotina, {"Reajuste de Preço", 'U_M410RPRC()',0,4,0,NIL})
		EndIf

		// Ticket: 25655 - Tela para monitoramento do processo automatico de devolucao.
		//aadd(arotina, {"Monitor Devolucao", 'U_BIA702()',0,4,0,NIL})

		// Emerson (Facile) em 27/08/2021 - Tela Rateio RPV (BIAFG106)
		aadd(arotina, {"Rateio RPV",'U_BIAFG106("2",0)',0,4,0,NIL})

	EndIf

Return()
