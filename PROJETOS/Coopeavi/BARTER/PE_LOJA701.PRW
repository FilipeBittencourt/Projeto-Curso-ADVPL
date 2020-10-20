#include "PROTHEUS.CH"

#DEFINE _BOTAOCUSTOM1	"Negocia็ใo"

// -----------------------------------------------------
// cFluigLib
// Inicializa็ใo: LJ7030
//
// Quando o processo de valida็๕es de al็ada, controlado
// pelos parโmetros MV_YALCORC e MV_YORCFLU, estiver
// ativo e executando via Fluig e ocorrer algum bloqueio
// no or็amento, essa variแvel conterแ o c๓digo da
// solicita็ใo iniciada via Fluig.
// -----------------------------------------------------
Static cFluigLib 	:= ""

// -----------------------------------------------------
// lBloqAnt
// Inicializa็ใo: LJ7032
//
// Indica se havia um bloqueio no or็amento no momento
// do acesso via ATENDIMENTO ou FINALIZAR VENDA.
//
// Se havia bloqueio, seu valor serแ .T.
// -----------------------------------------------------
Static lBloqAnt		:= .F.

// -----------------------------------------------------
// lCotacao, lDesconto, lCredito, lVenFut
//
// Inicializa็ใo: LJ7030
// Indicam se houve  bloqueio do or็amento por cota็ใo,
// desconto, cr้dito ou VEF.
//
// Se houve bloqueio, seus valores serใo .T.
// -----------------------------------------------------
Static lCotacao		:= .F.
Static lDesconto	:= .F.
Static lCredito		:= .F.
Static lVenFut		:= .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7001 	บAuthor ณ Ylram Mariani		 บ Date ณ  17/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esse ponto de entrada e chamado antes do inicio da		  บฑฑ
ฑฑบ          ณ gravacao do orcamento. Utilizado para validacoes no final  บฑฑ
ฑฑบ          ณ da venda.												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nOpc - Contem o tipo de operacao de gravacao, sendo:		  บฑฑ
ฑฑบ          ณ 1 - orcamento, 2 - venda, 3 - pedido						  บฑฑ
ฑฑบ          ณ aDadosDev - Array de 1 dimensao contendo os dados da 	  บฑฑ
ฑฑบ          ณ devolucao na seguinte ordem: 1 - serie da NF de devolucao, บฑฑ
ฑฑบ          ณ 2 - numero da NF de devolucao, 3 - cliente, 4 - loja do 	  บฑฑ
ฑฑบ          ณ cliente, 5 - tipo de operacao (1 - troca; 2 - devolucao)   บฑฑ
ฑฑบ          ณ nTipoDoc - Tipo de documento impresso pela venda de acordo บฑฑ
ฑฑบ          ณ com as opcoes: 1 - Cupom fiscal / 2 - Nota fiscal		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - Se permite ou nao finalizar a venda.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7001()

	Local nOpc			:= PARAMIXB[1]
	Local aDadosDev		:= PARAMIXB[2]
	Local nTipoDoc		:= PARAMIXB[3]
	Local aLimTotal		:= {}
	Local cLimForma		:= ""
	Local cLimValor		:= ""
	Local cForma		:= ""
	Local cMsg			:= ""
	Local cQuery		:= ""
	Local cAliasQry1 	:= ""
	Local cItem			:= ""
	Local lRet			:= .T.
	Local nP			:= 0
	Local nLinha 		:= 0
	Local nOldPos		:= 0
	Local lEmitNfce		:= FindFunction("LjEmitNFCe") .And. LjEmitNFCe()			// Sinaliza se utiliza NFC-e
	Local lYLJRESO		:= GetMv("MV_YLJRESO")										// Se obrigatorio efetuar a reserva de estoque no orcamento
	Local cYMODEVT		:= GetMV("MV_YMODEVT")										// Modo de configuracao do evento atual: 1 = Offline, 2 = Offline + Online (WS), 3 = Online.
	Local cYLJESTE		:= GetMv("MV_YLJESTE")			   							// Codigo da estacao relacionada a eventos
	Local cYBLQDIN		:= GetMv("MV_YBLQDIN")	  									// Filiais com bloqueio para vendas em DINHEIRO (R$)
	Local cYLJLVFP		:= GetMv("MV_YLJLVFP")	  									// Limite de valores de orcamento em aberto por forma de pagamento.
	Local cYLJMBFP		:= GetMv("MV_YLJMBFP")	  									// Mensagem de bloqueio por forma de pagamento.
	Local cYLJPERE		:= GetMv("MV_YLJPERE")	  									// Periodo de vigencia do evento corrente.
	Local cYLJCLCF		:= GetMv("MV_YLJCLCF")
	Local cYFILVEF 		:= GetMv("MV_YFILVEF")
	Local nPItem		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]		// Posicao do Item
	Local nPProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do Produto
	Local nPDescr		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_DESCRI"})][2]		// Posicao da Descricao do produto
	Local nPDReserv		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_RESERVA"})				// Posicao do codigo da reserva no array de detalhes

	Local aAreaSZS	:= SZS->(GetArea())

	//Tratamento para nao processar quando EXECAUTO a partir de rotinas customizadas.
	If !lAutoExec

		cForma := U_CLJFPG()

		//O ponteiro n indica a linha posicionada no browser, por padrao mesmo que nao existem itens na venda o browser possui uma linha em branco portanto n = 1.
		//Verifica se foi informado algum item no browser ou se foi chamado a partir da tela de pagamentos no caso da rotina RECEBIMENTOS, caso em que nao ha itens informados.
		If (!Empty(aCols[n,nPProd]) .Or. Len(aCols) > 1)

			//Tratamento da gravacao como orcamento.
			If nOpc == 1
				If cFilAnt $ cYFILVEF
					//Grava o campo que determina a origem do estoque no processo VENDA ENTREGA FUTURA.
					//Como o campo nao existe na tela de venda, mas sim foi obtido a partir de um dialogo a parte, o sistema nao faz a gravacao por padrao.
					If M->LQ_YVENFUT == "S"
						M->LQ_YESTVEF := IIf(!Empty(M->LQ_YESTVEF),M->LQ_YESTVEF,SL1->L1_YESTVEF)
					EndIf
				EndIf
			EndIf

			//Verifica filiais com bloqueio para vendas em DINHEIRO (R$)
			If nOpc <> 1 .And. cFilAnt $ cYBLQDIN
				//Verifica forma de pagamento
				If "R$" $ cForma
					Aviso("Erro", "Nใo ้ permitido venda em DINHEIRO (R$) nesta filial. Altere a forma de pagamento das parcelas.", {"Ok"},,"Aten็ใo")
					lRet := .F.
				EndIf
			EndIf

			//EVENTOS - Verifica limite de valores de orcamento em aberto por forma de pagamento.
			If nOpc <> 2 .And. cEstacao == cYLJESTE .And. !Empty(cYLJLVFP) .And. cForma $ cYLJLVFP
				//Monta o array de formas de pagamento e seus respectivos limites.
				Do While !Empty(cYLJLVFP)
					//Obtem a primeira forma de pagamento e seu limite.
					nP 		:= At(";",cYLJLVFP)	 	//Separador de forma de pagamento.
					cItem	 	:= SubStr(cYLJLVFP,1,nP-1)
					cYLJLVFP 	:= SubStr(cYLJLVFP,nP+1)

					//Obtem o limite de valor.
					nP 		:= At("=",cItem)		//Separador do limite de valor.
					cLimForma	:= SubStr(cItem,1,nP-1)
					cLimValor	:= SubStr(cItem,nP+1)

					If !Empty(cLimValor)
						AAdd(aLimTotal,{cLimForma,Val(cLimValor)})
					EndIf
				EndDo

				cAliasQry1 := GetNextAlias()

				//Totaliza os orcamentos em aberto por forma de pagamento.
				cQuery := "SELECT E4_FORMA, SUM(L1_VLRLIQ) AS L1_VLRLIQ "
				cQuery += " FROM "+RetSqlName("SL1")+" SL1 "
				cQuery += " JOIN "+RetSqlName("SE4")+" SE4 ON (SE4.E4_CODIGO = SL1.L1_CONDPG AND SE4.D_E_L_E_T_ = ' ') "
				cQuery += " WHERE SL1.L1_FILIAL = '"+xFilial("SL1")+"' "
				If !Empty(cYLJPERE)
					//Se houver um evento vigente, considera somente os orcamentos do periodo do evento.
					cQuery  += " AND SL1.L1_EMISSAO >= '"+AllTrim(SubStr(cYLJPERE,1,At("-",cYLJPERE)-1))+"' AND SL1.L1_EMISSAO <= '"+AllTrim(SubStr(cYLJPERE,At("-",cYLJPERE)+1))+"' "
				EndIf
				cQuery += " AND SL1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SL1.L1_DOC = ' ' "
				cQuery += " AND SL1.L1_NUM <> '"+M->LQ_NUM+"' "
				cQuery += " GROUP BY SE4.E4_FORMA "

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry1,.T.,.T.)

				(cAliasQry1)->(DbGoTop())
				Do While !(cAliasQry1)->(EoF())
					nP := AScan(aLimTotal,{ |aItem| aItem[1] == AllTrim((cAliasQry1)->E4_FORMA) })
					//Verifica se o total de orcamentos supera o limite estabelecido para a forma de pagamento.
					If !Empty(nP) .And. ((cAliasQry1)->L1_VLRLIQ + IIf(AllTrim((cAliasQry1)->E4_FORMA) $ cForma,Lj7T_Total(2),0)) > aLimTotal[nP,2]
						ShowHelpDlg("LJ7001",{AllTrim(SubStr(cYLJMBFP,1,At(";",cYLJMBFP)-1))},5,{AllTrim(SubStr(cYLJMBFP,At(";",cYLJMBFP)+1))},5)
						lRet := .F.
					EndIf
					(cAliasQry1)->(DbSkip())
				EndDo

				(cAliasQry1)->(DbCloseArea())
			EndIf

			//EVENTOS - Se modo de evento OFFLINE, valida a filial de retirada e local de estoque.
			If lRet .And. nOpc <> 2 .And. cEstacao == cYLJESTE .And. cYMODEVT == "1"
				//Valida se foi informada a filial de retirada (FILIAL PEDIDO).
				lRet := U_CLJVFR()
			EndIf

			If lRet
				//Valida se foi informado o VENDEDOR 2.
				lRet := U_CLJVV2()
			EndIf

			//Verifica DESPESA ou SEGURO
			SZS->(DbSetOrder(1))
			If lRet .And. nOpc <> 1 .And. SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. !SZS->ZS_TIPOFIL == "8"
				LJ7Frete(4)
				If !Empty(M->LQ_SEGURO+M->LQ_DESPESA)
					Aviso("Erro", "Nใo ้ permitido o acrescimo de valores referente a DESPESA ou SEGURO."+Chr(13)+Chr(10)+"Efetue a corre็ใo na tela de detalhes do frete (tecla F9).", {"Ok"},,"Aten็ใo")
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. lYLJRESO .And. M->LQ_YVENFUT != "S"
				//O ponteiro n indica a linha posicionada no browser, por padrao mesmo que nao existem itens na venda o browser
				//possui uma linha em branco portanto n = 1.

				//Grava o ponteiro atual aCols
				nOldPos	:= n := oGetVA:oBrowse:nAt

				For n := 1 to Len(aCols)
					//Se aplica apenas a itens nao deletados no aCols.
					If !GdDeleted(n, aHeader, aCols)
						//Altera o ponteiro do aCols a ser processado
						oGetVA:oBrowse:nAt := @n
						//Chama a rotina para atualizacao do preco de tabela conforme regras de desconto e acrescimo
						If Empty(aColsDet[n,nPDReserv])
							cMsg := cMsg + Chr(10) + aCols[n,nPItem] + "-" + Trim(aCols[n,nPProd]) + " " + Trim(aCols[n,nPDescr])
						EndIf
					EndIf
				Next

				If !Empty(cMsg)
					MsgAlert( "Nใo foram realizadas as reservas dos produtos: "+Chr(10)+cMsg )
					lRet := .F.
				EndIf

				//Restaura o ponteiro do aCols e demais propriedades do objeto
				oGetVA:oBrowse:nAt := n := nOldPos
				oGetVA:SetArray(aCols)
				eval(bRefresh)
			EndIf
		Else

			//Quando chamado da rotina RECEBIMENTOS somente permite forma de pagamento CARTAO DE DEBITO AUTOMATICO (CD) ou CARTAO DE CREDITO (CC).
			If !("CD" $ cForma .Or. "CC" $ cForma)
				Aviso("Erro", "Somente serแ permitido o recebimento em CARTAO DE DEBITO AUTOMATICO (CD) ou CARTAO DE CREDITO (CC)."+Chr(13)+Chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
				lRet := .F.
			EndIf

		EndIf

		//-----------------------------------------------------------------------------
		// Inicio das tratativas referente ao Posto de Combustivel
		//-----------------------------------------------------------------------------
		If lRet
			SZS->(DbSetOrder(1))
			If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"

				//Acrescentamos essa linha pra atualizar os abastecimentos logo apรณs a confirmaรงรฃo do orรงamento.
				LjMsgRun("Atualizando os abastecimento...",,{||PCLAbast():GravaAbast(M->LQ_NUM,.T.)})
				U_LOJAY046()
			EndIf
		EndIf
		//-----------------------------------------------------------------------------
		// Fim das tratativas referente ao Posto de Combustivel
		//-----------------------------------------------------------------------------
	EndIf

	RestArea(aAreaSZS)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7002 	บAuthor ณ Ylram Mariani		 บ Date ณ  07/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada chamado depois de toda a gravacao dos 	  บฑฑ
ฑฑบ          ณ dados e impressao do cupom fiscal na Venda Assistida.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nOpc - Contem o tipo de operacao de gravacao, sendo:		  บฑฑ
ฑฑบ          ณ 1 - orcamento, 2 - venda, 3 - pedido						  บฑฑ
ฑฑบ          ณ aDadosDev - Array de 1 dimensao contendo os dados da 	  บฑฑ
ฑฑบ          ณ devolucao na seguinte ordem: 1 - serie da NF de devolucao, บฑฑ
ฑฑบ          ณ 2 - numero da NF de devolucao, 3 - cliente, 4 - loja do 	  บฑฑ
ฑฑบ          ณ cliente, 5 - tipo de operacao (1 - troca; 2 - devolucao)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7002()

	Local nOpc			:= PARAMIXB[1]
	Local aDadosDev		:= PARAMIXB[2]
	Local nPProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do Produto
	Local cFluig		:= ""
	Local cErro			:= ""

	Local aAreaSZS		:= SZS->(GetArea())
	Local aAreaSZB 		:= SZB->(GetArea())
	Local aAreaSC0 		:= SC0->(GetArea())
	Local aAreaSL2 		:= SL2->(GetArea())
	Local aAreaSL4 		:= SL4->(GetArea())
	Local aAreaSE1 		:= SE1->(GetArea())
	Local aAreaSE4 		:= SE4->(GetArea())
	Local aAreaSE5 		:= SE5->(GetArea())
	Local aAreE5_2		:= SE5->(GetArea())
	Local aAreaSD2 		:= SD2->(GetArea())
	Local aAreaSA1 		:= SA1->(GetArea())
	Local aAreaSB1 		:= SB1->(GetArea())
	Local aAreaSF4 		:= SF4->(GetArea())
	Local aAreaZB6 		:= ZB6->(GetArea())
	Local aOperacao		:= {}
	Local aPrazos		:= {}
	Local cNomCli		:= ""
	Local cForma		:= ""
	Local cCLASFIS 		:= ""
	Local cCF			:= ""
	Local cBanco		:= ""
	Local cAgencia		:= ""
	Local cConta		:= ""
	Local cYBCOBOL		:= ""
	Local cErro			:= ""
	Local cAux			:= ""
	Local cItem			:= ""
	Local cNumSer		:= ""
	Local cMsgErro		:= ""
	Local cMsgCon		:= ""
	Local cCondpg		:= ""
	Local nTotChq		:= 0
	Local nTotDin		:= 0
	Local nTrocoChq		:= 0
	Local nDiasVcto		:= 0
	Local nVlrBxAut		:= 0
	Local nPJuros		:= 0
	Local nPDesc		:= 0
	Local nPDescFN		:= 0
	Local nDias			:= 0
	Local nPos			:= 0
	Local nQtdCup		:= 0
	Local dUltVcto 		:= DDATABASE
	Local LR_			:= .T.
	Local lImpNota		:= .F.
	Local lYBOLGRF		:= .F.
	Local lCockpit		:= .T.
	Local lEmitNfce		:= FindFunction("LjEmitNFCe") .And. LjEmitNFCe()			// Sinaliza se utiliza NFC-e
	Local lYLJBENO		:= GetMv("MV_YLJBENO")
	Local lYHDGBAT		:= GetMV("MV_YHDGBAT")  // Habilita ou desabilita processo de geracao de base de atendimento
	Local lYATPCPL		:= GetMv("MV_YATPCPL")  // Ativa ou desativa o envio de pedido para o Cockpit Logistico.
	Local cYFVECPL		:= GetMv("MV_YFVECPL")  // Filiais que realizam pedidos do tipo VE para integracao com o cockpit logistico (NEOLOG).
	Local cYMODEVT		:= GetMV("MV_YMODEVT")	// Modo de configuracao do evento atual: 1 = Offline, 2 = Offline + Online (WS), 3 = Online.
	Local cYAMBEVT		:= GetMV("MV_YAMBEVT")	// Identifica o ambiente do evento atual: 1 = Offline (PDV), 2 = Online (Retaguarda)
	Local cYLJESTE		:= GetMv("MV_YLJESTE")	// Codigo da estacao relacionada a eventos
	Local cYFILVEF 		:= GetMv("MV_YFILVEF")
	Local cYGRBCBA		:= GetMv("MV_YGRBCBA")	// Lista do grupo de produtos que irao gerar base de atendimento
	Local cYMSGCON		:= GetMv("MV_YMSGCON")
	Local cYPEDACD		:= GetMv("MV_YPEDACD")
	Local cYFILSOR		:= GetMv("MV_YFILSOR")	// Filiais que irใo imprimir cupom de sorteio
	Local cYDTVGSO		:= GetMv("MV_YDTVGSO")	// Periodo de vig๊ncia da campanha
	Local cYCPGREC		:= GetMV("MV_YCPGREC")
	Local oProcess		:= Nil
	Local oHtml			:= Nil

	//Grava os campos customizados que sao informados na rotina de frete.
	//Ver FTVD7006 e LJ7006.

	//O ponteiro n indica a linha posicionada no browser, por padrao mesmo que nao existem itens na venda o browser possui uma linha em branco portanto n = 1.
	//Verifica se foi informado algum item no browser ou se foi chamado a partir da tela de pagamentos no caso da rotina RECEBIMENTOS, caso em que nao ha itens informados.
	If (!Empty(aCols[n,nPProd]) .Or. Len(aCols) > 1)
		RecLock("SL1",.F.)
		SL1->L1_YVEICUL	:= M->LQ_YVEICUL
		SL1->L1_YOBS 	:= M->LQ_YOBS
		SL1->(MsUnLock())

		//Chama a rotina para concluir a gravacao da venda.

		If lEmitNfce .And. (nOpc == 2 .And. !Empty(SL1->L1_DOC) .And. !Empty(SL1->L1_SERIE))
			//Quando na gravacao como venda e tendo confirmado o DOCUMENTO/SERIE, se for ambiente NFC-e nao grava o numero DAV ou PRE.
			If !Empty(SL1->L1_NUMORC) .Or. SL1->L1_TPORC <> "E"
				RecLock("SL1",.F.)
				SL1->L1_TPORC 	:= "E"
				SL1->L1_NUMORC 	:= Space(Len(SL1->L1_NUMORC))
				SL1->(MsUnLock())
			EndIf
		EndIf

		//Verifica o DOCUMENTO/SERIE na gravacao como venda, caso esteja em branco a operacao foi cancelada anteriormente.
		//Esta situacao ocorre como exemplo quando se trata de emissao de NOTA FISCAL e o usuario cancelou na tela de selecao da SERIE.
		If !lAutoExec .And. !(nOpc == 2 .And. Empty(SL1->L1_DOC) .And. Empty(SL1->L1_SERIE))

			// Grava็ใo como or็amento ou venda
			If nOpc == 1 .Or. nOpc == 2

				If M->LQ_YVENFUT == "S" .And. !Empty(M->LQ_YESTVEF)
					RecLock("SL1",.F.)
					SL1->L1_YESTVEF	:= M->LQ_YESTVEF
					SL1->(MsUnLock())
				EndIf

				// ----------------------------------------------
				//  INICIO - Integra็ใo com o Cockpit Logํstico
				// ----------------------------------------------

				If lYATPCPL
					// Frete Logistica, Or็amento VEF filho ou Or็amento nใo VEF
					lCockpit := lCockpit .And. SL1->L1_YTIPENT == 'L' .And. SL1->L1_YVENFUT == "N"

					If lCockpit
						SA1->(DbSetOrder(1))
						If SA1->(DbSeek(xFilial("SL1") + SL1->L1_CLIENTE + SL1->L1_LOJA))
							lCockpit := SA1->A1_YENVCPL == "1"
						EndIf
					EndIf

					If lCockpit

						// Verifica se hแ produtos que podem ser enviados para o CPL
						aAreaSL2 := SL2->(GetArea())

						SB1->(DbSetOrder(1))
						SB5->(DbSetOrder(1))
						SL2->(DbSetOrder(1))

						If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
							Do While SL2->L2_FILIAL == xFilial("SL2") .And. SL2->L2_NUM == SL1->L1_NUM .And. !SL2->(Eof()) .And. lCockpit
								If lCockpit .And. SB5->(DbSeek(xFilial("SB5") + SL2->L2_PRODUTO))
									If SB5->B5_YENVCPL == "0"
										If SB1->(DbSeek(xFilial("SB1") + SB5->B5_COD))
											If SBM->(DbSeek(xFilial("SBM") + SB1->B1_GRUPO))
												lCockpit := SBM->BM_YENVCPL == "1"
											EndIf
										EndIf
									Else
										lCockpit := SB5->B5_YENVCPL == "1"
									EndIf
								EndIf

								SL2->(DbSkip())
							EndDo
						EndIf

						RestArea(aAreaSL2)

					EndIf

					If lCockpit
						U_LIBY006A(SL1->(Recno()), "O")
					EndIf
				EndIf

				// ----------------------------------------------
				//  FIM - Integra็ใo com o Cockpit Logํstico
				// ----------------------------------------------

				// Movimenta o processo de libera็ใo no Fluig
				If !(cEstacao == cYLJESTE .And. cYAMBEVT = "1")
					If lBloqAnt
						// Tratamento para processos de alcada via Fluig
						// Verifica se existe solicita็ใo
						cFluig := U_ZAXPSeek("SL1", SL1->(Recno()), "Alcadas_Liberacao_Orcamento")

						// Se houver uma solicitacao, cancela
						If U_FLUIG02D(cFluig)
							// Se cancelou, apaga da ZAX.
							U_ZAXPDel("SL1", SL1->(Recno()), "Alcadas_Liberacao_Orcamento")
						EndIf
					EndIf

					If !Empty(cFluigLib) .And. cFluigLib <> cFluig // Foi aberta nova solicitacao
						U_ZAXNovo("SL1", SL1->(Recno()), "Alcadas_Liberacao_Orcamento", cFluigLib)

						If lCredito
							U_FLUIG02B(cFluigLib, 74, {}, "Movimentado para anแlise do financeiro", .F., @cErro)
						ElseIf lCotacao .Or. lDesconto .Or. lVenFut
							U_FLUIG02B(cFluigLib, 14, {"Pool:Group:WF_Alcadas_Liberacao_Orcamento_14"}, "Movimentado para anแlise do compras", .F., @cErro)
						EndIf

						If !Empty(cErro)
							ShowHelpDlg("LOJAY019", {"Falha ao movimentar o processo de al็adas de libera็ใo de or็amentos.", cErro}, 3, {"Procure o setor de Tecnologia da Informa็ใo"}, 2)
							cFluig := ""
						EndIf

					EndIf

					// Grava nova solicitacao e atualiza os bloqueios
					If lCotacao .Or. lDesconto .Or. lVenFut
						If lCredito
							Reclock("SL1", .F.)
							SL1->L1_YBLOQ := "T"
							SL1->(MsUnlock())
						Else
							Reclock("SL1", .F.)
							SL1->L1_YBLOQ := "D"
							SL1->(MsUnlock())
						EndIf
					ElseIf lCredito
						Reclock("SL1", .F.)
						SL1->L1_YBLOQ := "C"
						SL1->(MsUnlock())
					Else
						Reclock("SL1", .F.)
						SL1->L1_YBLOQ := " "
						SL1->(MsUnlock())
					EndIf
				EndIf

			EndIf

			//Tratamento da gravacao como venda.
			If nOpc == 2

				nDiasVcto	:= GetMv("MV_YDIANCC")	// Numero de dias a acrescer ao vencimento da NCC
				nVlrBxAut	:= GetMv("MV_YVBXAUT")	// Valor minimo para baixa automatica da NCC
				nPJuros		:= GetMv("MV_YACRESC")	// Percentual de juros ao dia
				nPDesc		:= GetMv("MV_YCOPDS")	// Percentual de desconto financeiro ao mes
				nPDescFN	:= GetMv("MV_YCOPDFN")	// Percentual de desconto financeiro ao mes para financiamento
				nYDesCMM	:= GetMv("MV_YDESCMM")	// Percentual de desconto financeiro ao mes para Campanhas plus
				nDias		:= GetMv("MV_YCOPDIA")	// Numero de dias de antecipacao para desconto financeiro
				lYBOLGRF 	:= GetMv("MV_YBOLGRF")	// Verifica se imprime boleto grafico
				//lImpNota	:= GetMv("MV_FISNOTA")	// Se utiliza a pergunta imprime nota fiscal ou cupom fiscal T/F

				aAreaSZB 	:= SZB->(GetArea())
				aAreaSL2 	:= SL2->(GetArea())
				aAreaSL4 	:= SL4->(GetArea())
				aAreaSE1 	:= SE1->(GetArea())
				aAreaSE4 	:= SE4->(GetArea())
				aAreaSE5 	:= SE5->(GetArea())
				aAreaSD2 	:= SD2->(GetArea())
				aAreaSB1 	:= SB1->(GetArea())
				aAreaSF4 	:= SF4->(GetArea())
				aAreaSA1 	:= SA1->(GetArea())
				aAreaZB6 	:= ZB6->(GetArea())

				SZB->(DbSetOrder(1))
				SL4->(DbSetOrder(1))
				SE1->(DbSetOrder(1))
				SB1->(DbSetOrder(1))
				SF4->(DbSetOrder(1))
				SA1->(DbSetOrder(1))

				// ------------------------------------------------
				// Verifica se ้ projeto de irriga็ใo
				// ------------------------------------------------

				ZB6->(DbSetOrder(2))
				If ZB6->(DbSeek(SL1->L1_YFILPED + SL1->L1_FILIAL + SL1->L1_NUM))

					// ------------------------------------------------
					// Vincula a nota mใe ao projeto
					// ------------------------------------------------

					Reclock("ZB6", .F.)
					ZB6->ZB6_DOC 	:= SL1->L1_DOC
					ZB6->ZB6_SERIE 	:= SL1->L1_SERIE
					ZB6->(MsUnlock())

					oProcess := TWFProcess():New('Mail','E-mail de notificacao')
					oProcess:NewTask("Projeto de Irriga็ใo Faturado","\web\wf\venda_irrigacao.html")
					oProcess:cSubject := "Projeto de Irriga็ใo Faturado"
					oProcess:bReturn  := ""
					oHtml := oProcess:oHtml

					oHtml:ValByName("cFilial"	   		, SL1->L1_FILIAL)
					oHtml:ValByName("cFilialPedido"		, ZB6->ZB6_FILIAL)
					oHtml:ValByName("cData"	   			, DToC(SL1->L1_EMISSAO))
					oHtml:ValByName("cOrcamento"		, Alltrim(SL1->L1_NUM))
					oHtml:ValByName("cNF"				, Alltrim(SL1->L1_DOC + " " + SL1->L1_SERIE))

					oHtml:ValByName("it.Produto"		,{})
					oHtml:ValByName("it.Descricao"		,{})
					oHtml:ValByName("it.Grupo"			,{})
					oHtml:ValByName("it.DescGrupo"		,{})
					oHtml:ValByName("it.Qtd"			,{})

					aAreaSL2 := SL2->(GetArea())

					SL2->(DbSetOrder(1))
					If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
						Do While SL2->L2_FILIAL == xFilial("SL2") .And. SL2->L2_NUM == SL1->L1_NUM .And. !SL2->(Eof())
							If SB1->(DbSeek(xFilial("SB1") + SL2->L2_PRODUTO))
								If SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
									AAdd(oHtml:ValByName("it.Produto")		, AllTrim(SB1->B1_COD))
									AAdd(oHtml:ValByName("it.Descricao")	, AllTrim(SB1->B1_DESC))
									AAdd(oHtml:ValByName("it.Grupo")		, AllTrim(SB1->B1_GRUPO))
									AAdd(oHtml:ValByName("it.DescGrupo")	, AllTrim(SBM->BM_DESC))
									AAdd(oHtml:ValByName("it.Qtd")			, Alltrim(Transform(SL2->L2_QUANT, PesqPict("SL2","L2_QUANT"))))
								EndIf
							EndIf

							SL2->(DbSkip())
						EndDo
					EndIf

					RestArea(aAreaSL2)

					oProcess:cTo := AllTrim(cYPEDACD)
					oProcess:Start()
					oProcess:Finish()
				EndIf

				// ------------------------------------------------
				//  Verifica se ้ VEF CD
				// ------------------------------------------------

				If SL1->L1_YVENFUT == "S"
					If SL1->L1_YESTVEF == "C"
						// Gera pedido avulso
						StartJob("U_LOJAY004()", GetEnvServer(), .F., cEmpAnt, cFilAnt, SL1->(Recno()))
					EndIf
				EndIf

				//Verifica se a condicao de pagamento e VENDA ENTREGA FUTURA, BONIFICACAO ou COMODATO
				If SL1->L1_CONDPG $ "BON_COM_VEF" .Or. SL1->L1_YCOND $ "BON_COM_VEF"

					//Zerar campos de pagamento do orcamento para o resumo de caixa
					RecLock("SL1",.F.)
					SL1->L1_DINHEIR := 0
					SL1->L1_CHEQUES := 0
					SL1->L1_CARTAO  := 0
					SL1->L1_CONVENI := 0
					SL1->L1_VALES   := 0
					SL1->L1_FINANC  := 0
					SL1->L1_OUTROS  := 0
					SL1->L1_ENTRADA := 0
					SL1->(MsUnLock())

					//Exclui negociacao de pagamento
					SZB->(DbSeek(XFilial("SZB")+SL1->L1_NUM))

					Do While SZB->ZB_FILIAL == xFilial("SZB") .And. SZB->ZB_ORCAMEN == SL1->L1_NUM .And. !SZB->(Eof())
						RecLock("SZB",.F.)
						SZB->(DbDelete())
						SZB->(MsUnLock())
						SZB->(Dbskip())
					EndDo

					//Zerar o valor das condicoes negociadas
					SL4->(DbSeek(XFilial("SL4")+SL1->L1_NUM))

					Do While SL4->L4_FILIAL == xFilial("SL4") .And. SL4->L4_NUM == SL1->L1_NUM .And. !SL4->(Eof())
						RecLock("SL4",.F.)
						SL4->L4_VALOR := 0
						SL4->(MsUnLock())
						SL4->(DbSkip())
					EndDo

				Else

					If SZB->(DbSeek(xFilial("SZB")+SL1->L1_NUM))

						SA1->(DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))

						cNomCli := SA1->A1_NREDUZ

						Do While SZB->ZB_FILIAL == xFilial("SZB") .And. SZB->ZB_ORCAMEN == SL1->L1_NUM .And. !SZB->(Eof())
							If DToS(SZB->ZB_VENCTO) >= DToS(dUltVcto)
								dUltVcto := SZB->ZB_VENCTO
							EndIf
							If SZB->ZB_CHEQUE == "N"
								nTotDin += SZB->ZB_VALOR
							Else
								nTotChq += SZB->ZB_VALOR
							EndIf
							SZB->(DbSkip())
						EndDo

						//Verifica se tem troco para cheques.
						nTrocoChq := (nTotChq - SL1->L1_VLRLIQ)

						If nTrocoChq > 0

							//Excluir linha de troco gerada, at้ que tenhamos resposta da TOTVS
							aAreE5_2 	:= SE5->(GetArea())
							SE5->(DbSetOrder(18))

							If SE5->(DbSeek(xFilial("SE5") + SL1->L1_SERIE + SL1->L1_DOC + SL1->L1_OPERADO + "TC"))
								RecLock("SE5", .F.)
								SE5->(DbDelete())
								SE5->(MsUnLock())
							EndIf
							RestArea(aAreE5_2)

							//O vencimento do titulo de troco NCC sera acrecido do numero de dias indicado no parametro MV_YDIANCC
							dUltVcto += nDiasVcto

							//Incluir o titulo de troco NCC no arquivo de contas a receber SE1
							RecLock("SE1",.T.)

							SE1->E1_FILIAL  := XFILIAL("SE1")
							SE1->E1_PREFIXO := SL1->L1_SERIE
							SE1->E1_NUM     := SL1->L1_DOC
							SE1->E1_TIPO    := "NCC"
							SE1->E1_NATUREZ := U_NATNCCTRC()
							SE1->E1_PORTADO := SL1->L1_OPERADO
							SE1->E1_CLIENTE := SL1->L1_CLIENTE
							SE1->E1_LOJA    := SL1->L1_LOJA
							SE1->E1_HIST    := "EMISSAO NCC TRO/VD "+SL1->L1_OPERADO
							SE1->E1_NOMCLI  := cNomCli
							SE1->E1_EMISSAO := DDATABASE
							SE1->E1_VENCTO  := dUltVcto
							SE1->E1_VENCREA := dUltVcto
							SE1->E1_VALOR   := nTrocoChq
							SE1->E1_EMIS1   := DDATABASE
							SE1->E1_SITUACA := "0"
							SE1->E1_SALDO   := nTrocoChq
							SE1->E1_VENCORI := dUltVcto
							SE1->E1_MOEDA   := 1
							SE1->E1_VLCRUZ  := nTrocoChq
							SE1->E1_MULTNAT := "2"
							SE1->E1_VLRREAL := nTrocoChq
							SE1->E1_FILORIG := SM0->M0_CODFIL
							SE1->E1_MSFIL   := SM0->M0_CODFIL
							SE1->E1_MSEMP   := SM0->M0_CODIGO
							SE1->E1_PORCJUR := 0
							SE1->E1_DESCFIN := 0
							//Efetua baixa do titulo de troco NCC se valor menor que o indicado no parametro MV_YVBXAUT
							If Round(nTrocoChq,0) <= nVlrBxAut
								SE1->E1_STATUS  := "B"
								SE1->E1_BAIXA   := DDATABASE
								SE1->E1_MOVIMEN := DDATABASE
								SE1->E1_SALDO   := 0
								SE1->E1_VALLIQ  := nTrocoChq
							Else
								SE1->E1_STATUS  := "A"
							EndIf

							SE1->(MsUnLock())

							//Grava movimento bancario pagar do titulo de troco NCC
							//Considerando a baixa automatica quando valor menor que o indicado no parametro MV_YVBXAUT
							If Round(nTrocoChq,0) <= nVlrBxAut

								//Movimento bancario para referente a baixa no financeiro
								RecLock("SE5",.T.)

								SE5->E5_FILIAL  := XFILIAL("SE5")
								SE5->E5_DATA    := DDATABASE
								SE5->E5_TIPO    := "NCC"
								SE5->E5_BANCO   := SL1->L1_OPERADO
								SE5->E5_AGENCIA := "."
								SE5->E5_CONTA   := "."
								SE5->E5_VALOR   := nTrocoChq
								SE5->E5_NATUREZ := U_NATPAGNCC()
								SE5->E5_VENCTO  := DDATABASE
								SE5->E5_RECPAG  := "P"
								SE5->E5_BENEF   := cNomCli
								SE5->E5_HISTOR  := "PAGAMENTO NCC TRO/VD "+SL1->L1_OPERADO
								SE5->E5_TIPODOC := "BA"
								SE5->E5_LA      := "N"
								SE5->E5_VLMOED2 := nTrocoChq
								SE5->E5_PREFIXO := SL1->L1_SERIE
								SE5->E5_NUMERO  := SL1->L1_DOC
								SE5->E5_LOJA    := SL1->L1_LOJA
								SE5->E5_DTDIGIT := DDATABASE
								SE5->E5_MOTBX   := "NOR"
								SE5->E5_SEQ     := "01"
								SE5->E5_DTDISPO := DDATABASE
								SE5->E5_FILORIG := SM0->M0_CODFIL
								SE5->E5_CLIFOR  := SL1->L1_CLIENTE
								SE5->E5_CLIENTE := SL1->L1_CLIENTE

								SE5->(MsUnLock())

								//Movimento bancario para fechamento de caixa
								RecLock("SE5",.T.)

								SE5->E5_FILIAL  := XFILIAL("SE5")
								SE5->E5_DATA    := DDATABASE
								SE5->E5_MOEDA   := "M1"
								SE5->E5_VALOR   := nTrocoChq
								SE5->E5_NATUREZ := U_NATPAGNCC()
								SE5->E5_BANCO   := SL1->L1_OPERADO
								SE5->E5_AGENCIA := "."
								SE5->E5_CONTA   := "."
								SE5->E5_VENCTO  := DDATABASE
								SE5->E5_RECPAG  := "P"
								SE5->E5_BENEF   := cNomCli
								SE5->E5_HISTOR  := "PAGAMENTO NCC TRO/VD "+SL1->L1_OPERADO
								SE5->E5_LA      := " "
								SE5->E5_DTDIGIT := DDATABASE
								SE5->E5_DTDISPO := DDATABASE
								SE5->E5_RATEIO  := "N"
								SE5->E5_FILORIG := SM0->M0_CODFIL
								SE5->E5_MODSPB  := "1"
								SE5->E5_CODORCA := "PADRAOPR"
								SE5->E5_CLIFOR  := SL1->L1_CLIENTE
								SE5->E5_CLIENTE := SL1->L1_CLIENTE

								SE5->(MsUnLock())

							EndIf

						EndIf

					EndIf

				EndIf

				RestArea(aAreaSZB)
				RestArea(aAreaSL4)
				RestArea(aAreaSE1)
				RestArea(aAreaSE5)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava campos customizados no item do documento de saida		        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				SD2->(DbSetOrder(3))
				SL2->(DbSetOrder(1))
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				Do While SL2->L2_FILIAL == xFilial("SL2") .And. SL2->L2_NUM == SL1->L1_NUM .And. !SL2->(Eof())
					If SD2->(DbSeek(xFilial("SD2")+SL1->L1_DOC+SL1->L1_SERIE+SL1->L1_CLIENTE+SL1->L1_LOJA+SL2->L2_PRODUTO+SL2->L2_ITEM))
						If !Empty(SL2->L2_YCULTRA)
							RecLock("SD2",.F.)
							SD2->D2_YCULTRA := SL2->L2_YCULTRA
							SD2->(MsUnLock())
						EndIf

						// Grava valor de transfer๊ncia no item

						If !Empty(SL1->L1_YFILPED)
							nValor := U_RETCMFOR(SD2->D2_FILIAL, SL1->L1_YFILPED, SD2->D2_COD, SD2->D2_LOCAL)

							Reclock("SD2", .F.)
							SD2->D2_YVALTRF := nValor
							SD2->(MsUnLock())
						EndIf

					EndIf
					SL2->(DbSkip())
				EndDo
				RestArea(aAreaSD2)
				RestArea(aAreaSL2)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava percentual de desconto e juros nos titulos da venda           ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				/*
				SE1->(DbSetOrder(2))
				If SE1->(DbSeek(xFilial("SE1")+SL1->L1_CLIENTE+SL1->L1_LOJA+SL1->L1_SERIE+SL1->L1_DOC))
				Do While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SL1->L1_CLIENTE .And. SE1->E1_LOJA == SL1->L1_LOJA .And. SE1->E1_PREFIXO == SL1->L1_SERIE .And. SE1->E1_NUM == SL1->L1_DOC .And. !SE1->(Eof())
				RecLock("SE1",.F.)
				If SE1->E1_TIPO != "NCC"
				If AllTrim(SE1->E1_TIPO) == "CH"
				SE1->E1_PORCJUR := 0
				SE1->E1_VALJUR  := 0
				Else
				SE1->E1_PORCJUR := nPJuros
				EndIf
				If Alltrim(SE1->E1_TIPO) == "FN"
				SE1->E1_DESCFIN := nPDescFN
				Else
				SE1->E1_DESCFIN := nPDesc
				EndIf
				SE1->E1_DIADESC := nDias
				SE1->E1_TIPODES := "2" //Proporcional
				EndIf
				SE1->(MsUnLock())
				SE1->(DbSkip())
				EndDo
				EndIf

				SE1->(DbGoTop())
				SE1->(DbSetOrder(1))
				If SE1->(DbSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC))
				Do While SE1->E1_FILIAL == xFilial("SE1") .And. AllTrim(SE1->E1_CLIENTE) $ "N01_N02_N03_N04_N05_N06_N07_N08_N09_N10_N11_N12" .And. SE1->E1_LOJA == SL1->L1_LOJA .And. SE1->E1_PREFIXO == SL1->L1_SERIE .And. SE1->E1_NUM == SL1->L1_DOC .And. !SE1->(Eof())
				RecLock("SE1",.F.)
				If SE1->E1_TIPO != "NCC"
				If AllTrim(SE1->E1_TIPO) =="CC"
				SE1->E1_PORCJUR := 0
				SE1->E1_VALJUR  := 0
				ElseIf AllTrim(SE1->E1_TIPO) == "CD"
				SE1->E1_PORCJUR := 0
				SE1->E1_VALJUR  := 0
				EndIf
				EndIf
				SE1->(MsUnLock())
				SE1->(DbSkip())
				EndDo
				EndIf
				*/

				SE1->(DbSetOrder(1))
				If SE1->(DbSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC))
					SE4->(DbSetOrder(1))
					SE4->(DbSeek(xFilial("SE4")+SL1->L1_YCOND))

					Do While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_PREFIXO == SL1->L1_SERIE .And. SE1->E1_NUM == SL1->L1_DOC .And. !SE1->(Eof())
						RecLock("SE1",.F.)
						If AllTrim(SE1->E1_TIPO) != "NCC"
							If AllTrim(SE1->E1_TIPO) == "CC"
								SE1->E1_PORCJUR := 0
								SE1->E1_VALJUR  := 0
								SE1->E1_DESCFIN := 0
							ElseIf AllTrim(SE1->E1_TIPO) == "CD"
								SE1->E1_PORCJUR := 0
								SE1->E1_VALJUR  := 0
								SE1->E1_DESCFIN := 0
							ElseIf AllTrim(SE1->E1_TIPO) == "CH"
								SE1->E1_PORCJUR := 0
								SE1->E1_VALJUR  := 0
								SE1->E1_DESCFIN := 0
							ElseIf AllTrim(SE1->E1_TIPO) == "FN"
								SE1->E1_PORCJUR := nPJuros
								SE1->E1_DESCFIN := nPDescFN
							ElseIf AllTrim(SE1->E1_TIPO) == "CMM"
								SE1->E1_PORCJUR := nPJuros
								SE1->E1_DESCFIN := nYDesCMM
							ElseIf AllTrim(SE1->E1_TIPO) == "CM"
								SE1->E1_PORCJUR := nPJuros
								If SE4->E4_YPERCAD > 0
									SE1->E1_DESCFIN	:= SE4->E4_YPERCAD
								Else
									SE1->E1_DESCFIN := nPDesc
								EndIf
							Else
								SE1->E1_PORCJUR := nPJuros
								SE1->E1_DESCFIN := nPDesc
							EndIf
							SE1->E1_DIADESC := nDias
							SE1->E1_TIPODES := "2" //Proporcional
						EndIf
						SE1->E1_YFILPED	:= SL1->L1_YFILPED
						SE1->(MsUnLock())
						SE1->(DbSkip())
					EndDo
				EndIf
				RestArea(aAreaSE1)
				RestArea(aAreaSE4)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava campos customizados no SF2                                    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				//Verifica se existe mensagem vinculada com a condicao de pagamento.
				Do While !Empty(cYMSGCON) .And. Empty(cMsgCon)
					//Obtem a primeira forma de pagamento e seu limite.
					nPos 		:= At(";",cYMSGCON)	 	//Separador da condicao de pagamento.
					cItem	 	:= SubStr(cYMSGCON,1,nPos-1)
					cYMSGCON 	:= SubStr(cYMSGCON,nPos+1)

					//Obtem o limite de valor.
					nPos 		:= At("=",cItem)		//Separador da mensagem da condicao de pagamento.
					cCondPg		:= SubStr(cItem,1,nPos-1)
					cMsgCon		:= SubStr(cItem,nPos+1)
				EndDo

				SD2->(DbSetOrder(3))
				If SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
					RecLock("SF2",.F.)
					SF2->F2_YLIBDEV := !AllTrim(SD2->D2_CF) $ "5101_5102_5405_5656_5117_5116_5118_5922_6101_6102_6405_6656_6117_6116_6118_6922"
					SF2->(MsUnLock())
				EndIf

				RecLock("SF2",.F.)
				SF2->F2_YOBS 	:= AllTrim(cMsgCon)+"; "+AllTrim(SL1->L1_YOBS)
				SF2->F2_VEICUL1	:= SL1->L1_YVEICUL
				SF2->F2_YFILPED	:= SL1->L1_YFILPED
				SF2->F2_VEND2	:= SL1->L1_YVEND2
				SF2->(MsUnLock())

				//Faz a impressao da NCC de troco
				If nTrocoChq > 0 .And. Aviso("Confirma็ใo", "Foi gerada uma NCC de troco de cheque no valor de R$ "+Alltrim(u_fvlr(nTrocoChq,6,2))+" para vencimento no dia "+DtoC(dUltVcto)+"."+Chr(13)+Chr(10)+"Deseja imprimir esta NCC de troco?", {"Sim","Nใo"},,"Aten็ใo") == 1
					U_COPR100(SL1->L1_SERIE,SL1->L1_DOC," ")
				EndIf

				//Verifica forma de pagamento
				cForma := U_CLJFPG()

				//Se for boleto grafico nao imprime nota fiscal para cupom dentro da rotina VENDA ASSISTIDA
				If !lYBOLGRF
					If ("BO" $ cForma .Or. "FN" $ cForma .Or. "TR" $ cForma)
						//Quando for BOLETO BANCARIO, FINANCIAMENTO ou TROCA, sempre imprime a nota fiscal MOD1.
						lImpNota := .T.
					ElseIf SL1->L1_CONDPG $ "BON_COM" .Or. SL1->L1_YCOND $ "BON_COM"
						lImpNota := Aviso("Confirma็ใo", "Deseja imprimir nota fiscal para o cupom de "+Iif((SL1->L1_CONDPG $ "BON" .Or. SL1->L1_YCOND $ "BON"),"BONIFICACAO","COMODATO")+"?", {"Sim","Nใo"},,"Aten็ใo") == 1
					Else
						lImpNota := Aviso("Confirma็ใo", "Nใo foi gerado BOLETO BANCARIO para esta venda. Deseja imprimir a nota fiscal assim mesmo?", {"Sim","Nใo"},,"Aten็ใo") == 1
					EndIf

					If lImpNota
						//Atualiza parametros da rotina LJR130 com dados do cupom impresso de modo que o usuario nao necessita digitar.
						U_GRVPERG("LJR130",{ {"01",SL1->L1_DOC},{"02",SL1->L1_SERIE} })

						//Chama a rotina padrao para impressao de nota fiscal para cupom fiscal.
						LOJR130()
					EndIf
				EndIf

				// CHAMA IMPRESSรO DE CUPONS DE SORTEIO
				If cFilAnt $ cYFILSOR .And. SubStr(SL1->L1_CLIENTE, 1, 1) == 'S' .And. SL1->L1_VLRTOT >= 500 .And. (SL1->L1_EMISSAO >= SToD(SubStr(cYDTVGSO,1,8)) .And.  SL1->L1_EMISSAO <= SToD(SubStr(cYDTVGSO,10,8)))

					nQtdCup	:= Int(SL1->L1_VLRTOT / 500)

					U_LOJRY015(SL1->L1_CLIENTE, 1, nQtdCup, IIF(SL1->L1_ESTACAO == "001" .Or. SL1->L1_ESTACAO == cYLJESTE, 2, 1), SL1->L1_EMISSAO, AllTrim(SL1->L1_DOC) + "-" + AllTrim(SL1->L1_SERIE))

				EndIf

				SZS->(DbSetOrder(1))
				If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"
					If Val(SL1->L1_SERIE) < 200

						SL2->(DbSetOrder(1))
						ZPA->(DbSetOrder(1))
						If SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))
							Do While SL1->L1_FILIAL == SL2->L2_FILIAL .And. SL1->L1_NUM == SL2->L2_NUM .And. !SL2->(Eof())
								If ZPA->(DbSeek(xFilial("ZPA") + SL2->L2_YABAST))
									RecLock("ZPA",.F.)
									ZPA->ZPA_NUMORC := SL1->L1_NUM
									ZPA->ZPA_FILORC := SL1->L1_FILIAL
									ZPA->ZPA_ITEORC	:= SL2->L2_ITEM
									ZPA->(MsUnLock())
								EndIf
								SL2->(DbSkip())
							EndDo
						EndIf
					EndIf

					If SL1->L1_CONDPG $ cYCPGREC
						U_LOJRY019()
					EndIf
				EndIf

				//Se for BOLETO BANCARIO, FINANCIAMENTO, FINANCIAMENTO MAQUINAS, BARTER ou CAMPANHA e foi gerado contas a receber, chama a tela de impressao do boleto.
				If ("BO" $ cForma .Or. "FN" $ cForma .Or. "MQ" $ cForma .Or. "CM" $ cForma .Or. "CMM" $ cForma) .And. SE1->(DbSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC)) .And. SE1->E1_LOJA <> "43"
					//Banco, agencia e conta corrente para impressao do boleto bancario
					cYBCOBOL := GetMv("MV_YBCOBOL")

					If Empty(cYBCOBOL)
						Aviso("Erro", "Configure o parametro MV_YBCOBOL para efetuar a impressใo do boleto bancแrio.", {"Ok"},,"Aten็ใo")
					Else
						If lYBOLGRF
							cBanco		:= SubStr(cYBCOBOL,1,At("/",cYBCOBOL)-1)
							cYBCOBOL	:= SubStr(cYBCOBOL,At("/",cYBCOBOL)+1)
							cAgencia	:= SubStr(cYBCOBOL,1,At("/",cYBCOBOL)-1)
							cYBCOBOL	:= SubStr(cYBCOBOL,At("/",cYBCOBOL)+1)
							cConta		:= Alltrim(cYBCOBOL)

							//Atualiza parametros da rotina COPR005 com dados do cupom impresso de modo que o usuario nao necessita digitar.
							U_GRVPERG("COPR05",{ {"01",cBanco},{"02",cAgencia},{"03",cConta},{"04",SL1->L1_SERIE},{"05",SL1->L1_SERIE},{"06",SL1->L1_DOC},{"07",SL1->L1_DOC},{"08"," "},{"09"," "},{"10",SL1->L1_OPERADO},{"11",SL1->L1_OPERADO},{"12",SL1->L1_CLIENTE},{"13",SL1->L1_CLIENTE},{"14",SL1->L1_LOJA},{"15",SL1->L1_LOJA},{"16","  /  /  "},{"17","  /  /  "},{"18","  /  /  "},{"19","  /  /  "} })
							//Chama a rotina customizada de impressao do boleto grafico
							U_COPR005(.T.)
						Else
							If !Empty(At("/",cYBCOBOL))
								cBanco	:= SubStr(cYBCOBOL,1,At("/",cYBCOBOL)-1)
							Else
								cBanco 	:= Alltrim(cYBCOBOL)
							EndIf
							//Atualiza parametros da rotina C_FINR600 com dados do cupom impresso de modo que o usuario nao necessita digitar.
							U_GRVPERG("COO001",{ {"01",cBanco},{"02",SL1->L1_DOC},{"03",SL1->L1_DOC},{"04",NIL},{"05",NIL},{"06",NIL},{"07",NIL},{"08",NIL},{"09",SL1->L1_SERIE} })
							//Chama a rotina customizada de impressao do boleto em formulario matricial
							U_C_FINR600()
						EndIf
					EndIf

					//IMPRESSAO DE DUPLICATA DESENVOLVIDA BRASOFT... BRADUP.PRW

				ElseIf "DU" $ cForma .And. SE1->(DbSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC)) .And. SE1->E1_LOJA <> "43"
					SZS->(DbSetOrder(1))
					If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. !SZS->ZS_TIPOFIL == "8"
						U_LOJRY010(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_PORTADO,SE1->E1_CLIENTE, SE1->E1_LOJA, DTOS(SE1->E1_EMISSAO), DTOS(SE1->E1_VENCREA)  )
					EndIf
				EndIf

				//Gera Base de atendimento no modulo gestao de servicos
				//Autor: Daniel Neumann - Data: 24/03/2017
				If lYHDGBAT
					If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
						cAux := '001'

						Do While SL2->L2_FILIAL == xFilial("SL2") .And. SL2->L2_NUM == SL1->L1_NUM .And. !SL2->(EoF())
							If SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO)) .And. SB1->B1_GRUPO $ cYGRBCBA
								For nI := 1 To SL2->L2_QUANT
									cNumSer := SL1->L1_FILIAL + "-" + Padl(AllTrim(SL1->L1_DOC), 9, '0') + '-' + Padl(AllTrim(SL1->L1_SERIE), 3, '0') + "-" + cAux

									RecLock("ZC6",.T.)
									ZC6->ZC6_FILIAL	:= xFilial("ZC6")
									ZC6->ZC6_PRODUT	:= SL2->L2_PRODUTO
									ZC6->ZC6_SERIE	:= cNumSer
									ZC6->ZC6_CLIENT	:= SL1->L1_CLIENTE
									ZC6->ZC6_LOJA	:= SL1->L1_LOJA
									ZC6->ZC6_DTVEND	:= dDataBase
									ZC6->ZC6_STATUS := "1"
									ZC6->(MsUnLock())

									cAux := Soma1(cAux)
								Next
							EndIf
							SL2->(DbSkip())
						EndDo
					EndIf
				EndIf

				RestArea(aAreaSZB)
				RestArea(aAreaSL2)
				RestArea(aAreaSL4)
				RestArea(aAreaSE1)
				RestArea(aAreaSE4)
				RestArea(aAreaSE5)
				RestArea(aAreaSD2)
				RestArea(aAreaSB1)
				RestArea(aAreaSF4)
				RestArea(aAreaSA1)
				RestArea(aAreaZB6)
				RestArea(aAreaSZS)

			EndIf

			//Gera o contrato dependendo da condi็ใo de pagamento
			cCondpg := ALLTRIM(SL1->L1_CONDPG)
			If ((cCondpg == "M01") .OR. (cCondpg == "M02") .OR. (cCondpg == "M03") .OR. (cCondpg == "M04") .OR. (cCondpg == "M05") .OR. (cCondpg == "M06") .OR. (cCondpg == "M07") .OR. (cCondpg == "M08") .OR. (cCondpg == "M09") .OR. (cCondpg == "M10") .OR. (cCondpg == "M11") .OR. (cCondpg == "M12") .OR. (cCondpg == "M13"))
				U_LOJRY011(SL1->L1_FILIAL, SL1->L1_NUM)
			Endif

		EndIf

	EndIf

Return

//------------------------------------------------------------------------
/*/{Protheus.doc} LJ7003
@description Esse ponto de entrada ้ utilizado para a valida็ใo da
dele็ใo / recupera็ใo de um item da aCols. Obs.: Ponto
de entrada chamado depois das valida็๕es do sistema.
@author Guilherme Covre Dalleprane
@since 04.01.2017
@version 1.0
/*/
//------------------------------------------------------------------------

User Function LJ7003()
	Local lRet := .T.
	Local nPProd 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_PRODUTO"})
	Local nPDesc 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_DESCRI"})
	Local nPItem 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_ITEM"})
	Local aAreaSZS	:= SZS->(GetArea())

	ZB6->(DbSetOrder(2))
	ZB7->(DbSetOrder(1))
	If ZB6->(DbSeek(M->LQ_YFILPED + M->LQ_FILIAL + M->LQ_NUM))
		If lRet .And. !GdDeleted(n, aHeader, aCols)
			If ZB7->(DbSeek(xFilial("ZB7") + ZB6->ZB6_COD + aCols[n, nPItem] + aCols[n, nPProd]))
				Aviso("Aten็ใo!", "O produto "+AllTrim(aCols[n,nPDesc])+" nใo pode ser removido do or็amento, pois ele estแ vinculado a um projeto de irriga็ใo.", {"Ok"})
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//-----------------------------------------------------------------------------
	// Inicio das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------

	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"

		cCodAbast 	:= GDFieldGet("LR_YABAST")

		// Atualiza a tabela de abastecimsntos com os dados do cupom
		If !Empty(cCodAbast) .And. !GDDeleted()

			dbSelectArea("ZPA")
			dbSetOrder(1) //ZPA_FILIAL+ZPA_CODIGO

			If ZPA->(dbSeek(xFilial("ZPA")+cCodAbast))

				aZPA := {}
				aAdd(aZPA,{"ZPA_NUMORC"	,""})
				aAdd(aZPA,{"ZPA_ITEORC"	,""})
				aAdd(aZPA,{"ZPA_FILORC"	,""})
				aAdd(aZPA,{"ZPA_SITUA"	,"00"})

				FRTGeraSL("ZPA",aZPA,.F.)

			EndIf

		EndIf

	EndIf
	//-----------------------------------------------------------------------------
	// Fim das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------

	// Para uso do processo BARTER
	U_LOJAY50A(.T.)	
	// Fim Para uso do processo BARTER

	RestArea(aAreaSZS)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7006 	บAuthor ณ Ylram Mariani		 บ Date ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esse ponto de entrada e chamado na rotina de frete.		  บฑฑ
ฑฑบ          ณ E utilizado para exibir algum campo de usuario na tela	  บฑฑ
ฑฑบ          ณ frete.													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ aCampos - Array bidimencional com informacoes dos campos,  บฑฑ
ฑฑบ          ณ sendo: [1] Nome do campo / [2] Numero do folder que 		  บฑฑ
ฑฑบ          ณ aparecera (1, 2 ou 3).									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7006()

	Local aCampos 	:= {}
	Local lYCALFRE	:= GetMv("MV_YCALFRE")

	If lYCALFRE
		//No caso do calculo pelo TOTAL (LQ_FRETE) somente se atualiza o valor do campo.
		M->LQ_FRETE	:= U_CLJFRT()
	EndIf

	//Folder Transporte
	AAdd(aCampos,{"LQ_YVEICUL",1})

	//Folder Dados Complementares
	AAdd(aCampos,{"LQ_YOBS",2})

	//Folder Valores

Return aCampos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7007 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada acionado na montagem dos botoes da tela	  บฑฑ
ฑฑบ          ณ de definicao de pagamentos.								  บฑฑ
ฑฑบ          ณ Cada botao corresponde a dois elementos do array retorno.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ aBotao - Array com dados para criacao do botao.			  บฑฑ
ฑฑบ          ณ aRet[1]:= Nome do primeiro botao 						  บฑฑ
ฑฑบ          ณ aRet[2]:= Nome da funcao que sera executada primeiro botao บฑฑ
ฑฑบ          ณ aRet[3]:= Nome do segundo botao							  บฑฑ
ฑฑบ          ณ aRet[4]:= Nome da funcao que sera executada segundo botao  บฑฑ
ฑฑบ          ณ (...)  													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7007()

	Local aRet := {}

	#IFDEF TOP
	AAdd(aRet,_BOTAOCUSTOM1)
	AAdd(aRet,"U_CLJ004()")
	#ENDIF

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7009 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada acionado na validacao da alteracao das	  บฑฑ
ฑฑบ          ณ parcelas na tela de pagamento, seja a partir do MBrowser   บฑฑ
ฑฑบ          ณ ou a partir dos botoes de formas de pagamento.		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ aParcOri - Array com os dados originais das parcelas.	  บฑฑ
ฑฑบ          ณ aParcAlt - Array com os dados alterados das parcelas.	  บฑฑ
ฑฑบ          ณ A estrutura dos arrays recebidos e do retornado e:		  บฑฑ
ฑฑบ          ณ [1] Data (data)											  บฑฑ
ฑฑบ          ณ [2] Valor (numerico) 									  บฑฑ
ฑฑบ          ณ [3] Descri็ใo da forma de pagamento				 		  บฑฑ
ฑฑบ          ณ [4] Checkbox "Utiliza nas proximas parcelas" (logico) 	  บฑฑ
ฑฑบ          ณ [5] Identificacao sequencial do cartao (1 caracter)		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ xRet - Array ou booleano.								  บฑฑ
ฑฑบ	         ณ Deve retornar um boleano ou um vetor. Se retornar falso,   บฑฑ
ฑฑบ	         ณ nao permite que os dados informados pelo usuario sejam	  บฑฑ
ฑฑบ	         ณ confirmados. Se retornar um vetor, a parcela atual sera	  บฑฑ
ฑฑบ	         ณ atualizada com os dados do vetor. 						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7009()

	Local aParcOri	:= PARAMIXB[1]
	Local aParcAlt	:= PARAMIXB[2]
	Local xRet 		:= .T.
	Local cForma	:= ""
	Local cCondPg	:= M->LQ_YCOND
	Local cYLJCNDB	:= GetMV("MV_YLJCNDB")
	Local nYTDALTV	:= GetMv("MV_YTDALTV")
	//Brasoft - Ini
	Local _nLimVl	:= GetMV("MV_YLIMVL")
	Local _cFrmPg	:= GetMV("MV_YFORPG")
	Local cYFILDUP	:= GetMv("MV_YFILDUP")
	//Brasoft - Fim

	Local aAreaSZS	:= SZS->(GetArea())

	#IFDEF TOP

	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. !SZS->ZS_TIPOFIL == "8"
		//Verifica forma de pagamento
		cForma := U_CLJFPG()

		//Caso tenham sido informada negociacao de pagamento, nao permite alterar os dados das parcelas
		//visto que estes sao gerados automaticamente.
		If SZB->(DbSeek(XFilial("SZB")+M->LQ_NUM))
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando existe negociacao do pagamento.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf M->LQ_CONDPG $ "BON_COM" .Or. M->LQ_YCOND $ "BON_COM"
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de BONIFICACAO ou COMODATO.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf M->LQ_CONDPG $ "VEF" .Or. M->LQ_YCOND $ "VEF"
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de VENDA ENTREGA FUTURA.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf "CC" $ cForma
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de CARTAO DE CREDITO.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf "CD" $ cForma
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de CARTAO DE DEBITO AUTOMATICO.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf "TR" $ cForma
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de TROCA.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf "FN" $ cForma
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de FINANCIAMENTO.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf "TF" $ cForma
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de TROCA FUTURA.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf "CM" $ cForma
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de CAMPANHA.", {"Ok"},,"Aten็ใo")
			xRet := .F.
			//ElseIf "MQ" $ cForma
			//	Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de FINANCIAMENTO MAQUINAS.", {"Ok"},,"Aten็ใo")
			//	xRet := .F.
		ElseIf "BT" $ cForma
			Aviso("Erro", "Nใo ้ permitido altera็ใo das parcelas quando se trata de BARTER.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf AllTrim(aParcAlt[3]) == _BOTAOCUSTOM1
			Aviso("Erro", "Forma de pagamento nใo disponivel! Utilize a rotina de negocia็ใo de pagamento.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcOri[3])) != "CARTAO CREDITO" .And. Upper(Alltrim(aParcAlt[3])) == "CARTAO DE CREDITO"
			Aviso("Erro", "Nใo ้ permitido alterar a forma de pagamento para CARTAO DE CREDITO."+chr(13)+chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcOri[3])) != "CARTAO DE DEBITO AUTOMATICO" .And. Upper(Alltrim(aParcAlt[3])) == "CARTAO DE DEBITO AUTOMATICO"
			Aviso("Erro", "Nใo ้ permitido alterar a forma de pagamento para CARTAO DE DEBITO AUTOMATICO."+chr(13)+chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcOri[3])) != "FINANCIAMENTO" .And. Upper(Alltrim(aParcAlt[3])) == "FINANCIAMENTO"
			Aviso("Erro", "Nใo ้ permitido alterar a forma de pagamento para FINANCIAMENTO."+chr(13)+chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcOri[3])) != "FINANCIAMENTO MAQUINAS" .And. Upper(Alltrim(aParcAlt[3])) == "FINANCIAMENTO MAQUINAS"
			Aviso("Erro", "Nใo ้ permitido alterar a forma de pagamento para FINANCIAMENTO MAQUINAS."+chr(13)+chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcOri[3])) != "CAMPANHA" .And. Upper(Alltrim(aParcAlt[3])) == "CAMPANHA"
			Aviso("Erro", "Nใo ้ permitido alterar a forma de pagamento para CAMPANHA."+chr(13)+chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcOri[3])) != "TROCA FUTURA" .And. Upper(Alltrim(aParcAlt[3])) == "TROCA FUTURA"
			Aviso("Erro", "Nใo ้ permitido alterar a forma de pagamento para TROCA FUTURA."+chr(13)+chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcOri[3])) != "TROCA" .And. Upper(Alltrim(aParcAlt[3])) == "TROCA"
			Aviso("Erro", "Nใo ้ permitido alterar a forma de pagamento para TROCA."+chr(13)+chr(10)+"Utilize uma condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf nRotina == 4 .and. aParcOri[1] <> aParcAlt[1]
			//nRotina - Variavel que indica qual a opcao selecionada no menu (aRotina) | 1-Pesquisar 2-Visualizar 3-Atendimento 4-Finaliza Venda
			//Nao permite alterar o vencimento em um orcamento ja gravado, pois nao eh possivel controlar a data de vencimento calculada
			//quando da inclusao do orcamento, de modo a verificar a toleracia de alteracao.
			Aviso("Erro", "Nใo ้ permitido altera็ใo da data de vencimento das parcelas de um or็amento jแ gravado.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf Abs(aPgtos[oPgtosAna:nAt,5]-aParcAlt[1]) > nYTDALTV
			//oPgtosAna:nAt contem o ponteiro que indica qual parcela esta sendo alterada.
			//A dimensao 5 do array aPgtos e customizada pelo usuario e neste caso, contem a data de vencimento original calculada pelo sistema.
			//Verifica a tolerancia em dias para alteracao da data de vencimento.
			Aviso("Erro", "Tolerancia mแxima de "+Alltrim(Str(nYTDALTV))+" dias para altera็ใo da data de vencimento.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf aParcOri[2] != aParcAlt[2]
			//Nao permite alterar o valor da parcela.
			Aviso("Erro", "Nใo ้ permitido alterar o valor da parcela.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf cCondPg $ cYLJCNDB .And. aPgtos[oPgtosAna:nAt,5] != aParcAlt[1]
			//Nao permite alterar a data da parcela se for uma das condicoes de pagamento parametrizadas.
			Aviso("Erro", "Nใo ้ permitido alterar data da parcela.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		ElseIf aParcOri[2] <= _nLimVl .And. Upper(Alltrim(aParcAlt[3])) == "BOLETO BANCARIO"
			MsgAlert("Nใo ้ permitido usar a forma de pagamento BOLETO para compras com valor abaixo de " + AllTrim(Str(_nLimVl)) + " reais!")
			xRet := .F.
		ElseIf Upper(Alltrim(aParcAlt[3])) == _cFrmPg .And. !cFilAnt $ cYFILDUP
			Aviso("Aten็ใo", "Nใo ้ permitido alterar a forma de pagamento para DUPLICATA para a sua filial."+chr(13)+chr(10)+"Utilize outra condi็ใo de pagamento configurada para esta finalidade.", {"Ok"},,"Aten็ใo")
			xRet := .F.
		EndIf

		//Restaura a condicao de pagamento visto que ao acessar algum botao, o sistema apaga a mesma.
		M->LQ_CONDPG := cCondPg
		#ENDIF
	EndIf

	RestArea(aAreaSZS)
Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7010 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao a ser executada pelo botao "Zera pagamentos". 	  บฑฑ
ฑฑบ          ณ Sera executada no lugar da funcao Lj7ZeraPgtos().		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7010()

	Local aAreaSL4 	:= {}
	Local nPProd	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do Produto
	Local aAreaSZS	:= SZS->(GetArea())

	If !U_CLJCXL()

		SZS->(DbSetOrder(1))

		//O ponteiro n indica a linha posicionada no browser, por padrao mesmo que nao existem itens na venda o browser possui uma linha em branco portanto n = 1.
		//Verifica se foi informado algum item no browser ou se foi chamado a partir da tela de pagamentos no caso da rotina RECEBIMENTOS, caso em que nao ha itens informados.
		If (!Empty(aCols[n,nPProd]) .Or. Len(aCols) > 1) .And. SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. !SZS->ZS_TIPOFIL == "8"
			If M->LQ_CONDPG $ "BON_COM" .Or. M->LQ_YCOND $ "BON_COM"
				Aviso("Erro", "Nใo ้ permitido zerar pagamento quando se trata de BONIFICACAO ou COMODATO.", {"Ok"},,"Aten็ใo")
			ElseIf M->LQ_CONDPG $ "VEF" .Or. M->LQ_YCOND $ "VEF"
				Aviso("Erro", "Nใo ้ permitido zerar pagamento quando se trata de VENDA ENTREGA FUTURA.", {"Ok"},,"Aten็ใo")
				/*
				ElseIf M->LQ_YBLOQ == "P"
				//EVENTOS - No caso de orcamentos que foram gravados como pedido nao sera possivel zerar pagamento.
				Aviso("Erro", "Nใo ้ permitido zerar pagamento quando or็amento efetivado como pedido.", {"Ok"},,"Aten็ใo")
				*/
			ElseIf Aviso("Confirma็ใo", "Caso exista negocia็ใo de pagamento, libera็ใo de cr้dito ou desconto para este or็amento, as informa็๕es serใo excluํdas."+Chr(13)+Chr(10)+"Deseja gerar novamente as parcelas com base na condi็ใo de pagamento selecionada?", {"Sim","Nใo"},,"Aten็ใo") == 1
				//Negociacao de pagamento
				SZB->(DbSeek(xFilial("SZB")+M->LQ_NUM))
				Do While SZB->ZB_FILIAL == xFilial("SZB") .And. SZB->ZB_ORCAMEN == M->LQ_NUM .And. !SZB->(EoF())
					RecLock("SZB",.F.)
					SZB->(DbDelete())
					SZB->(MsUnLock())
					SZB->(DbSkip())
				EndDo

				//Parcelas do orcamento
				aAreaSL4 := SL4->(GetArea())
				SL4->(DbSetOrder(1))
				SL4->(DbSeek(xFilial("SL4")+M->LQ_NUM))
				Do While SL4->L4_FILIAL == xFilial("SL4") .And. SL4->L4_NUM == M->LQ_NUM .And. !SL4->(EoF())
					RecLock("SL4",.F.)
					SL4->(DbDelete())
					SL4->(MsUnLock())
					SL4->(DbSkip())
				EndDo
				RestArea(aAreaSL4)

				//Ver rotina LJ7030, LJ7031 e CLJGPG
				M->LQ_HORA		:= Space(Len(M->LQ_HORA))
				M->LQ_CONDPG	:= M->LQ_YCOND
				M->LQ_YBLOQ		:= " "

				//Recalcula as parcelas com base na forma de pagamento
				U_CLJGPG(M->LQ_YCOND)
			EndIf
		Else
			//Quando chamado da rotina RECEBIMENTOS executa a funcao padrao.
			Lj7ZeraPgtos()
		EndIf
	Else
		Aviso("Erro", "Usuแrio nใo possui acesso para zerar pagamentos!", {"Ok"},,"Aten็ใo")
	EndIf

	RestArea(aAreaSZS)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7011 	บAuthor ณ Ylram Mariani		 บ Date ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esse ponto de entrada sera chamado ao acionar F7 para  	  บฑฑ
ฑฑบ          ณ voltar da tela de pagamento para a tela de itens na venda. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - Se permite ou nao a troca de tela.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7011()

	Local lRet 		:= .T.
	Local cYFILVEF 	:= GetMv("MV_YFILVEF")

	#IFDEF TOP
	//nRotina - Variavel que indica qual a opcao selecionada no menu (aRotina) | 1-Pesquisar 2-Visualizar 3-Atendimento 4-Finaliza Venda
	If nRotina == 4

		If lRet
			If  U_CLJCXL() //SM0->M0_ESTENT == "MG" .And.
				//Quando a venda for feita por empresa de MG o cupom fiscal e impresso na entrada da tela
				//de venda assistida. logo ao clicar na opcao Finaliza Venda.
				//Portanto quando usuario caixa nao sera permitido acessar outras telas, visto que os valores do orcamento nao podem ser alterados.
				Aviso("Erro", "Cupom fiscal jแ impresso! Nใo ้ possํvel acessar ou alterar os itens do or็amento."+chr(13)+chr(10)+"Voc๊ deve utilizar a op็ใo de grava็ใo como or็amento ou venda.", {"Ok"},,"Aten็ใo")
				lRet := .F.
				/*
				ElseIf M->LQ_YBLOQ == "P"
				//EVENTOS - No caso de orcamentos que foram gravados como pedido nao sera possivel alterar o orcamento.
				Aviso("Erro", "Or็amento gravado como pedido em evento! Nใo ้ possํvel acessar ou alterar os itens do or็amento."+chr(13)+chr(10)+"Voc๊ deve utilizar a op็ใo de grava็ใo como or็amento ou venda.", {"Ok"},,"Aten็ใo")
				lRet := .F.
				*/
			ElseIf M->LQ_YBLOQ == "L"
				If Aviso("Confirma็ใo", "Foi feito libera็ใo de cr้dito ou desconto para este or็amento."+chr(13)+chr(10)+"Ao acessar a tela de itens, a libera็ใo atual serแ perdida e voc๊ deverแ solicitar uma nova libera็ใo."+chr(13)+chr(10)+"Deseja continuar?", {"Sim","Nใo"},,"Aten็ใo") == 1
					M->LQ_YBLOQ	:= " "
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	#ENDIF

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7012 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada que possibilita adicionar uma coluna 	  บฑฑ
ฑฑบ          ณ customizada no aPgtos (array de parcelas).				  บฑฑ
ฑฑบ          ณ Para alimentar essa coluna, devera manipular a 5a coluna   บฑฑ
ฑฑบ          ณ do array aPgtos. Exemplo: aPgtos[nLinha][5] = "xxx"        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ aColuna - Array com a definicao do titulo e posicao no	  บฑฑ
ฑฑบ          ณ MBrowse de parcelas: {cTitulo,nPicao}         			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7012()

	Local aColuna := {"Original",2}
	Local i		  := 0

	For i := 1 to Len(aPgtos)
		If Empty(aPgtos[i,5])
			aPgtos[i,5] := aPgtos[i,1]
		EndIf
	Next

Return aColuna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7013 	บAuthor ณ Ylram Mariani		 บ Date ณ  01/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada que possibilita alterar as informacoes a  บฑฑ
ฑฑบ          ณ serem enviadas ao ECF.									  บฑฑ
ฑฑบ          ณ Esse ponto de entrada e acionado antes da chamada da funcaoบฑฑ
ฑฑบ          ณ de registro do item no ECF.							      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ PARAMIXB - Array com os dados do item a ser impresso no	  บฑฑ
ฑฑบ          ณ ECF. A estrutura do array recebido e retornado consiste:	  บฑฑ
ฑฑบ          ณ [1] Codigo do produto									  บฑฑ
ฑฑบ          ณ [2] Descricao do produto 								  บฑฑ
ฑฑบ          ณ [3] Quantidade				 		  					  บฑฑ
ฑฑบ          ณ [4] Valor unitario 	  									  บฑฑ
ฑฑบ          ณ [5] Desconto		  										  บฑฑ
ฑฑบ          ณ [6] Situacao tributaria e aliquota		  				  บฑฑ
ฑฑบ          ณ [7] Valor total do item									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ Array com a mesma estrutura acima.				 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7013()

	Local cCodProd		:= PARAMIXB[1]
	Local cDescriProd	:= PARAMIXB[2]
	Local cQuant		:= PARAMIXB[3]
	Local cVrUnit		:= PARAMIXB[4]
	Local cDesconto		:= PARAMIXB[5]
	Local cSitTrib		:= PARAMIXB[6]
	Local cVlrItem		:= PARAMIXB[7]
	Local aAreaSB1		:= SB1->(GetArea())

	//-----------------------------------------------------------------------------
	// Inicio das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------
	Local cCodAbast		:= ""
	Local cItem			:= ""
	Local cOrcam		:= ""
	Local cDescricao	:= ""
	Local nPosDtLocal	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOCAL"})
	Local bStrTran      := {|c| If( Subs(c,5,1) $ "01234", "5", cValToChar(Val(Subs(c,5,1))+1) ) }
	Local bVlrFracao    := { |nVlrIt,nVlrUn|  Left(cValToChar(nVlrIt / nVlrUn),4) + eVal(bStrTran,cValToChar(nVlrIt / nVlrUn)) }
	Local aAreaSZS		:= SZS->(GetArea())
	//-----------------------------------------------------------------------------
	// Fim das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodProd))

	If !(AllTrim(SB1->B1_DESC) == AllTrim(cDescriProd))
		cDescriProd := SB1->B1_DESC
	EndIf

	//Verifica se inclui as informacoes do lote na descricao do produto no documento fiscal.
	If SB1->B1_RASTRO == "L"
		cDescriProd := AllTrim(cDescriProd)+" Lote: "+AllTrim(SL2->L2_LOTECTL)+" - Val.: "+DToC(SL2->L2_DTVALID)
	EndIf

	RestArea(aAreaSB1)

	//-----------------------------------------------------------------------------
	// Inicio das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------

	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"
		dbSelectArea("ZPB")
		dbSetOrder(1) //ZPB_FILIAL+ZPB_BICO+ZPB_TANQUE

		If GetNewPar("MV_YPCLHAB",.F.)

			If GetNewPar("MV_LJVACC",.T.)

				If !Empty(GDFieldGet("LR_YBOMBA"))
					cOrcam		:= M->LQ_NUM
					cItem		:= GDFieldGet("LR_ITEM")
					cCodAbast 	:= GDFieldGet("LR_YABAST")
					cCodigo		:= GDFieldGet("LR_PRODUTO")
					cDescricao 	:= Alltrim(ParamIXB[2])+;
					" BO:"+GDFieldGet("LR_YBOMBA")+;
					" BI:"+GDFieldGet("LR_YBICO")
				Else
					cDescricao	:= ParamIXB[2]
				Endif

			Else

				If !Empty(SL2->L2_YBOMBA)
					cOrcam			:= SL2->L2_NUM
					cItem				:= SL2->L2_ITEM
					cCodAbast 	:= SL2->L2_YABAST
					cDescricao	:= Alltrim(ParamIXB[2])+" BO:"+SL2->L2_YBOMBA+" BI:"+SL2->L2_YBICO
				Else
					cDescricao	:= ParamIXB[2]
				Endif

			Endif

			// [1] - C๓digo do produto
			//* [2] - Descri็ใo do produto
			//* [3] - Quantidade
			//* [4] - Valor unitแrio
			//* [5] - Desconto
			//* [6] - Situa็ใo tributแria e alํquota
			//* [7] - Valor total do item

			aRet:= {ParamIXB[1],cDescricao,ParamIXB[3],ParamIXB[4],ParamIXB[5],ParamIXB[6],ParamIXB[7]}

			If !Empty(cCodAbast)

				dbSelectArea("ZPA")
				dbSetOrder(1) //ZPA_FILIAL+ZPA_CODIGO

				If ZPA->(dbSeek(xFilial("ZPA")+cCodAbast))

					aZPA := {}
					aAdd(aZPA,{"ZPA_NUMORC"	,cOrcam})
					aAdd(aZPA,{"ZPA_ITEORC"	,cItem})
					aAdd(aZPA,{"ZPA_FILORC"	,cFilAnt})
					aAdd(aZPA,{"ZPA_SITUA"	,"00"})

					FRTGeraSL("ZPA",aZPA,.F.)

				EndIf

			EndIf

		Else

			//* [1] - C๓digo do produto
			//* [2] - Descri็ใo do produto
			//* [3] - Quantidade
			//* [4] - Valor unitแrio
			//* [5] - Desconto
			//* [6] - Situa็ใo tributแria e alํquota
			//* [7] - Valor total do item

			aRet:= {ParamIXB[1],ParamIXB[2],ParamIXB[3],ParamIXB[4],ParamIXB[5],ParamIXB[6],ParamIXB[7]}

		EndIf
		//-----------------------------------------------------------------------------
		// Fim das tratativas referente ao Posto de Combustivel
		//-----------------------------------------------------------------------------
	EndIf

	RestArea(aAreaSZS)

Return {cCodProd, cDescriProd, cQuant, cVrUnit, cDesconto, cSitTrib, cVlrItem}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7016 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada acionado na montagem da tela de vendas.	  บฑฑ
ฑฑบ          ณ Permite incluir funcoes do usuario.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nOpc - Opcao que foi selecionada no menu (aRotina).        บฑฑ
ฑฑบ          ณ 1-Pesquisar 2-Visualizar 3-Atendimento 4-Finaliza Venda    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ aRet - Array com as funcoes a serem incluidas.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7016()

	Local aRet := {}
	Local aAreaSZS	:= SZS->(GetArea())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do array aFuncoes												ณ
	//ณ 																		ณ
	//ณ Tem como objetivo definir TODAS as funcoes que estao disponiveis para 	ณ
	//ณ a interface de venda													ณ
	//ณ 															 			ณ
	//ณ Observacoes:		 													ณ
	//ณ 	1) Dimensao n x 8	 									 			ณ
	//ณ 															 			ณ
	//ณ Conteudo das colunas										 			ณ
	//ณ 															 			ณ
	//ณ [1] - Titulo para o menu										 		ณ
	//ณ [2] - Titulo para botao	(tip)											ณ
	//ณ [3] - Resource															ณ
	//ณ [4] - Funcao a ser executada 										 	ณ
	//ณ [5] - Aparece na toolbar lateral ? (TRUE / FALSE)						ณ
	//ณ [6] - Habilitada ? (TRUE / FALSE)					 					ณ
	//ณ [7] - Grupo	(1- Gravacao, 2- Detalhes, 3- Estoque, 4- Outros)           ณ
	//ณ [8] - Tecla de atalho                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	aAdd(aRet,{"Titulos em Aberto"	, "Titulos em Aberto"	, "POSCLI"	, {|| U_C_Fc010Br() } , .F., .T., 4, {20,"Ctrl+T"} } )
	aAdd(aRet,{"Abrir Gaveta"		, "Abrir Gaveta"		, 'FINAL' 	, {|| U_CLJGAV() } , .F., .T., 4, {08,'Ctrl+H'} } )
	aAdd(aRet,{"Venda Perdida"		, "Venda Perdida"		, 'FINAL' 	, {|| StaticCall(LOJAY006, LOJAY06B, 'I') }	, .F., .T., 4, {16,"Ctrl+P"} } )

	//-----------------------------------------------------------------------------
	// Inicio das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------
	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"
		If GetNewPar("MV_YPCLHAB",.F.)

			aAdd( aRet,	 {"Abastecimento"			,"Tela de Abastecimentos "		, "SIMULACAO"	,	{||PCLAbast():Tela()}, .F., .T., 4, {10,"Ctrl+J"}})
			aAdd( aRet,	 {"Voltar Abastecimento"	,"Voltar Abastecimentos"		, "SIMULACAO"	,	{||U_PCLA303()}, .F., .T., 4, {11,"Ctrl+K"}})

		EndIf
	EndIf
	//-----------------------------------------------------------------------------
	// Fim das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------

	RestArea(aAreaSZS)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7018 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada que possibilita ao cliente controlar a 	  บฑฑ
ฑฑบ          ณ liberacao de um desconto maior que o limite indicado na    บฑฑ
ฑฑบ          ณ configuracao do caixa.							          บฑฑ
ฑฑบ          ณ Se refere ao desconto sobre o total do orcamento, ou seja, บฑฑ
ฑฑบ          ณ nao se trata do desconto no item.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nPerDesc - Percentual de desconto informado.				  บฑฑ
ฑฑบ          ณ nVlrDesc	- Valor do desconto informado.	   				  บฑฑ
ฑฑบ          ณ nTipo - Indica se a funcao de validacao de desconto esta	  บฑฑ
ฑฑบ          ณ sendo chamada do GET do percentual ou do valor. 			  บฑฑ
ฑฑบ          ณ 1 - percentual / 2 - valor.	   							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - Se libera ou nao o desconto.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7018( nPerDesc , nVlrDesc , nTipo )

	Local lRet 		:= .F.
	Local aAreaSZS	:= SZS->(GetArea())

	//-----------------------------------------------------------------------------
	// Inicio das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------
	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"

		lRet := .T.

		//-----------------------------------------------------------------------------
		// Fim das tratativas referente ao Posto de Combustivel
		//-----------------------------------------------------------------------------
	Else

		Aviso("Erro", "Nใo ้ permitido desconto no total da venda, apenas nos itens.", {"Ok"},,"Aten็ใo")
	EndIf

	RestArea(aAreaSZS)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7020 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada na montagem dos botoes da tela de   	  บฑฑ
ฑฑบ          ณ pagamentos. 												  บฑฑ
ฑฑบ          ณ Os botoes sao criados a partir da parametrizacao de formas บฑฑ
ฑฑบ          ณ de pagamento no arquivo SX5 (tabela 24) e no arquivo SAE.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ cTexto - Contem o texto do botao da condicao de pagamento. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - Se cria ou nao o botao.							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7020()

	Local cTexto := PARAMIXB[1]
	Local lRet 	 := .T.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Estrutura do array aAdmFinanc                                ณ
	//ณฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤณ
	//ณ [1] - Tipo de Pagamento (SAE->AE_TIPO, SX5->X5_TABELA = 24)  ณ
	//ณ [2] - Nome da Administradora (SAE->AE_DESC)  				 ณ
	//ณ [3] - Codigo da Administradora (SAE->AE_COD)                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If cTexto $ "COND.NEGOCIADA" .Or. !Empty(Ascan(aAdmFinanc,{ |aItem| aItem[1] == SAE->AE_TIPO }))
		lRet := .F.
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7023 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada na montagem dos botoes da tela de   	  บฑฑ
ฑฑบ          ณ pagamentos. 												  บฑฑ
ฑฑบ          ณ Permite desabilitar a exibicao dos botoes.		  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ cTexto - Contem o texto do botao da condicao de pagamento. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - TRUE para que o botao seja desabilitado na tela.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7023()

	Local cTexto 	:= PARAMIXB[1]
	Local lRet 	 	:= .F.
	Local aAreaSZS	:= SZS->(GetArea())

	//Verifica se a condicao de pagamento e VENDA ENTREGA FUTURA, BONIFICACAO ou COMODATO
	If M->LQ_CONDPG $ "BON_COM_VEF" .Or. M->LQ_YCOND $ "BON_COM_VEF"
		//Desabilita todos os botoes da tela de pagamentos.
		lRet := .T.
	ElseIf !(cTexto $ "ZERAR PAGAMENTOS_"+Upper(_BOTAOCUSTOM1))
		lRet := .T.
	EndIf

	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"
		If cTexto $ "CARTAO DE DEBITO AUTOMATICO/CARTAO DE CREDITO/DINHEIRO"
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSZS)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7030 	บAuthor ณ Ylram Mariani		 บ Date ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esse ponto de entrada e chamado na LinOk e na TudoOk da 	  บฑฑ
ฑฑบ          ณ rotina de venda assistida.								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nTipo - 1 = Indica que o ponto esta sendo chamado a partir บฑฑ
ฑฑบ          ณ da LinOk / 2 = Indica que o ponto esta sendo chamado a 	  บฑฑ
ฑฑบ          ณ partir da TudoOk.										  บฑฑ
ฑฑบ          ณ nOpc - Quando chamado da TudoOk (validacao total) informa  บฑฑ
ฑฑบ          ณ o tipo de operacao, sendo 1 - Salvar como orcamento; 	  บฑฑ
ฑฑบ          ณ 2 - Salvar como venda; 3 - Salvar como pedido. Se chamada  บฑฑ
ฑฑบ          ณ da LinOk ou TudoOk quando esta na tela de itens da venda	  บฑฑ
ฑฑบ          ณ o valor sera 0.											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - Se validou ou nao.								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7030()

	Local nTipo		:= PARAMIXB[1]
	Local nOpc		:= PARAMIXB[2]
	Local lRet  	:= .T.
	Local aArea 	:= GetArea()
	Local aAreaSL2	:= SL2->(GetArea())
	Local aAreaSB1 	:= SB1->(GetArea())
	Local aAreaSB2 	:= SB2->(GetArea())
	Local aAreaSB5 	:= SB5->(GetArea())
	Local aAreaZCP 	:= ZCP->(GetArea())
	Local aAreaZCQ 	:= ZCQ->(GetArea())
	Local aAreaSZS 	:= SZS->(GetArea())
	Local aFormaPg	:= {}
	Local nI		:= 0
	Local cMsg  	:= ""
	Local cCod		:= ""
	Local cNome 	:= ""
	Local cDoc		:= ""
	Local cEnd		:= ""
	Local cBai		:= ""
	Local cCid		:= ""
	Local cEst		:= ""
	Local cErro		:= ""
	Local cMsg		:= ""
	Local cForma	:= ""
	Local cSolDesc	:= ""
	Local lPanVA3	:= .F.
	Local nAuxTotal	:= 0
	Local nVlUnit	:= 0
	Local lYALCORC	:= GetMv("MV_YALCORC")
	Local lYLORFLU	:= GetMv("MV_YLORFLU")
	Local lYLJBENO	:= GetMv("MV_YLJBENO")
	Local cYAMBEVT	:= GetMV("MV_YAMBEVT")	// Identifica o ambiente do evento atual: 1 = Offline (PDV), 2 = Online (Retaguarda)
	Local cYLJESTE	:= GetMv("MV_YLJESTE")	// Codigo da estacao relacionada a eventos
	Local cYLJCLCF	:= GetMv("MV_YLJCLCF")
	Local cYLJFPCF	:= GetMv("MV_YLJFPCF")
	Local nYLJLVCF	:= GetMv("MV_YLJLVCF")
	Local cYFILVEF 	:= GetMv("MV_YFILVEF")
	Local cYFPBVEF 	:= GetMv("MV_YFPBVEF")

	Local nPLote		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOTECTL"})			// Posicao do Lote
	Local nPDTES		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_TES"})				// Posicao do TES
	Local nPDLocal		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOCAL"})			// Posicao do Local
	Local nPDPrcTab		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRCTAB"})			// Posicao do Pre็o de tabela
	Local nPReserv		:= AScan(aposCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_RESERVA"})			// Posicao do Numero da Reserva

	Local nPTES		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_YTES"})][2]		// Posicao da TES padrao
	Local nPLocal	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_YLOCAL"})][2]		// Posicao da TES padrao
	Local nPPrcTab	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_YPRCTAB"})][2] 	// Posicao do preco de tabela
	Local nPProd	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do Produto
	Local nPItem	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]		// Posicao do Item
	Local nPDescr	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_DESCRI"})][2]		// Posicao da Descricao do produto
	Local nPQuant	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
	Local nPCult	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_YCULTRA"})][2]	// Posicao da Cultura

	Local nPDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESC"})][2]		// Posicao do Desconto
	Local nPValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]	// Posicao do valor de desconto
	Local nPPerDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_YPERDES"})][2]	// Posicao do Desconto da Regra
	Local nPVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2] 	// Posicao do valor unitario do item
	Local nPVlItem	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VLRITEM"})][2] 	// Posicao do valor total do item

	Local nPAbast	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_YABAST"})][2] 	// Posicao do c๓digo de abastecimento
	Local nPBico	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_YBICO"})][2] 		// Posicao do c๓digo de abastecimento
	Local cAbaste	:= ""
	Local cQuerySL2	:= ""
	Local nQtdAbas	:= 0

	Local nPrcTab   := 0
	Local nVlUnit   := 0
	Local nVlItem   := 0
	Local nValDesc  := 0
	Local nDesc     := 0
	Local nPerDesc  := 0

	Private cMotCredito	:= ""
	Private cMotDesconto 	:= ""
	Private cMotVenFut		:= ""
	Private cMotCotacao	:= ""

	//O objeto oCondPg esta definido na tela de pagamentos, seu estado visivel indica se o usuario esta na tela de itens ou na tela de pagamentos.
	If Type("oCondPg") == "O"
		lPanVA3 := oCondPg:lVisible 	//Quando igual a .T., foi chamado a partir da tela de definicao de pagamentos.
	EndIf


	//Inicializacao das variaveis STATIC.
	cFluigLib 	:= ""
	lCotacao	:= .F.
	lDesconto	:= .F.
	lCredito	:= .F.
	lVenFut		:= .F.

	If nTipo == 2
		LjNFFimVd(.T.)
	EndIf

	//Tratamento da condicao de pagamento DATA FIXA quando EXECAUTO.
	//Deve ser tratado neste ponto pois do contrario ira ocorrer erro na gravacao da data de vencimento.
	If lAutoExec .And. nTipo == 2 .And. nOpc <> 0
		//Posiciona na condicao de pagamento
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+M->LQ_YCOND))
		If SE4->E4_YDTFIXA == 'S'
			//Por questao de compatiblidade, utiliza sempre a rotina do VENDA ASSISTIDA.
			For i := 1 to Len(aPgtos)
				If SEC->(DbSeek(xFilial("SEC")+M->LQ_YCOND+Padl(i,2,"0")))
					dVencto := StoD(Alltrim(SEC->EC_COND))
					If !Empty(dVencto)
						aPgtos[i,1] := dVencto
						aPgtos[i,5] := dVencto
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	// --------------------------------------------------
	// Tratamento de atualiza็ใo de valores da venda
	// na utiliza็ใo de ExecAuto
	// --------------------------------------------------

	If lAutoExec .And. nTipo == 1 .And. nOpc == 0

		nVlUnit := 0

		// Tratamento de valores dos or็amentos integrados via CRM

		If FunName() != "RPC"

			If !AllTrim(FunName()) $ "LOJAY023"
				ZCP->(DbSetOrder(3))
				ZCP->(DbSeek(xFilial("ZCP") + M->LQ_NUM + "O"))
			EndIf

			ZCQ->(DbSetOrder(1))
			If ZCQ->(DbSeek(xFilial("ZCQ") + ZCP->ZCP_ORCCRM + M->LR_PRODUTO))
				nVlUnit 	:= ZCQ->ZCQ_VALOR
				nPrcTab	 	:= ZCQ->ZCQ_VALOR
				nVlItem		:= ZCQ->ZCQ_VALOR * ZCQ->ZCQ_QUANT
				nValDesc	:= 0
				nDesc		:= 0
			EndIf

			RestArea(aAreaZCP)
			RestArea(aAreaZCQ)

			// -----------------------------------------------------
			// Tratamento de valores dos or็amentos em eventos
			// Valida se nใo estแ sendo alterado por um webservice
			// -----------------------------------------------------
			If !AllTrim(FunName()) $ "LOJAY027"
				ZD9->(DbSetOrder(2))
				ZD9->(DbSeek(xFilial("ZD9") + xFilial("SL1") + M->LQ_NUM))
			EndIf

			ZD8->(DbSetOrder(1))
			If ZD8->(DbSeek(xFilial("ZD8") + ZD9->ZD9_CODEVT + ZD9->ZD9_CODIGO + M->LR_ITEM + M->LR_PRODUTO))
				nVlUnit 	:= ZD8->ZD8_VRUNIT
				nPrcTab 	:= ZD8->ZD8_PRCTAB
				nValDesc	:= ZD8->ZD8_VALDES
				nDesc		:= ZD8->ZD8_DESC
				nPerDesc	:= ZD8->ZD8_DESC
				nVlItem		:= ZD8->ZD8_VRITEM
			EndIf
		EndIf

		// -----------------------------------------------------
		// Tratamento de valores dos or็amentos
		// Valida para nใo alterar os valores nos or็amentos automแticos vindos do barter LOJAY043
		// -----------------------------------------------------
		If AllTrim(FunName()) $ "LOJAY043"
			nVlUnit 	:= ZD3->ZD3_VLUNIT
			nPrcTab 	:= ZD3->ZD3_VLUNIT
			nValDesc	:= 0
			nDesc		:= 0
			nPerDesc	:= 0
			nVlItem		:= ZD3->ZD3_VLTOT
		EndIf

		// Atualiza valores do item
		If nVlUnit > 0
			nAuxTotal := LJ7T_Subtotal(2) - MaFisRet(n, "IT_TOTAL")
			Lj7T_Subtotal(2, nAuxTotal)

			aColsDet[n,nPDPrcTab] 	:= nPrcTab
			aCols[n,nPPrcTab] 		:= nPrcTab
			aCols[n,nPVlUnit] 		:= nVlUnit
			aCols[n,nPVlItem] 		:= nVlItem
			aCols[n,nPValDesc] 		:= nValDesc
			aCols[n,nPDesc] 		:= nDesc
			aCols[n,nPPerDesc] 		:= nPerDesc

			MaFisAlt("IT_VALMERC"	, aCols[n,nPVlItem], n)
			MaFisAlt("IT_PRCUNI"	, aCols[n,nPVlUnit], n)
			MaFisAlt("IT_DESCONTO"	, 0				   , n)

			nAuxTotal := LJ7T_Subtotal(2) + MaFisRet(n, "IT_TOTAL")
			nAuxTotal := Max(nAuxTotal, 0)
			Lj7T_Subtotal(2, nAuxTotal)
			Lj7T_Total(2, Lj7T_SubTotal(2) - Lj7T_DescV(2) + LJ7CalcFrete())
		EndIf

	EndIf
 
	//Tratamento para nao processar quando EXECAUTO a partir de rotinas customizadas.
	If !lAutoExec

		//Valida se a forma de pagamento do orcamento pode ser utilizada.
		//Verifica forma de pagamento
		cForma 	 := U_CLJFPG()
		//Monta o array de formas de pagamento que podem ser utilizadas.
		aFormaPg := STRTOKARR(cForma,"_")

		If nTipo == 2 .And. nOpc <> 0
			//O objeto oCondPg esta definido na tela de pagamentos, seu estado visivel indica se o usuario
			//esta na tela de itens ou na tela de pagamentos.
			If !lPanVA3
				//Forca o usuario a finalizar pela tela de pagamentos.
				//Isso e necessario pois ao alterar o desconto de algum produto, o sistema zera
				//os pagamentos existentes, e se o usuario escolher a opcao de gravar a partir da tela de itens
				//por padrao nao ocorre o recalculo das parcelas.
				//Ao alterar para a tela de pagamentos, este recalculo sera feito.
				Aviso("Erro", "Voc๊ deve finalizar pela tela de pagamentos (tecla F7).", {"Ok"},,"Aten็ใo")
				lRet := .F.
			EndIf

			//Validacoes para VENDA ENTREGA FUTURA.
			//		If lRet .And. M->LQ_YVENFUT == 'S'
			//			For nI := 1 To Len(aFormaPg)
			//				If (aFormaPg[nI] $ cYFPBVEF)
			//					MessageBox("Nใo ้ permitido o uso da forma de pagamento "+aFormaPg[nI]+" na VENDA ENTREGA FUTURA. Utilize uma condi็ใo de pagamento que nใo seja vinculada a "+cYFPBVEF+".",,16)
			//					lRet := .F.
			//				EndIf
			//			Next
			//		EndIf

			//Validacoes para venda a CONSUMIDOR FINAL.
			If lRet .And. M->LQ_CLIENTE == cYLJCLCF
				For nI := 1 To Len(aFormaPg)
					If !(aFormaPg[nI] $ cYLJFPCF)
						MessageBox("Nใo ้ permitido o uso da forma de pagamento "+aFormaPg[nI]+" na venda a consumidor final. Utilize uma condi็ใo de pagamento que seja vinculada a uma das formas de pagamento permitidas ("+AllTrim(StrTran(cYLJFPCF,";"," "))+").",,16)
						lRet := .F.
					EndIf
				Next

				//Valida se o valor total da venda ultrapassa o limite permitido.
				If lRet .And. Lj7T_Total(2) > nYLJLVCF
					MessageBox("Valor total do or็amento ultrapassa o valor mแximo permitido para venda a consumidor final (R$ "+AllTrim(Transform(nYLJLVCF,"@E 999,999.99"))+"). Informe um cliente vแlido ou altere o or็amento.",,16)
					lRet := .F.
				EndIf
			EndIf

			//Faz a validacao dos dados dos cheques.
			If lRet .And. nOpc <> 1 .And. !U_CLJNEG(.T.)
				lRet := .F.
			EndIf

			//EVENTOS - Nao permite finalizar como venda no ambiente OFFLINE.
			If lRet .And. nOpc <> 1 .And. cEstacao == cYLJESTE .And. cYAMBEVT == "1"
				MsgAlert("Nใo ้ possํvel finalizar o orcamento de EVENTO no ambiente OFFLINE!","Aten็ใo")
				lRet := .F.
			EndIf

			If lYALCORC
				//Verifica se o orcamento ja passou pelas regras de bloqueio.
				If lRet .And. M->LQ_YBLOQ <> "L"

					cMotCredito 	:= U_CLJVLC()
					cMotDesconto 	:= U_CLJVDA()
					cMotVenFut		:= U_CLJVFUT()
					cMotCotacao		:= U_CLJVCOT()

					lCotacao  		:= !Empty(cMotCotacao)
					lDesconto	 	:= !Empty(cMotDesconto)
					lCredito  		:= !Empty(cMotCredito)
					lVenFut   		:= !Empty(cMotVenFut)

					If lCotacao .Or. lDesconto .Or. lCredito .Or. lVenFut
						If nOpc == 1
							If lYLORFLU
								cFluigLib := U_LOJAY019()
								lRet := !Empty(cFluigLib)
							Else
								cMsg := "Or็amento bloqueado! "

								If lCotacao
									cMsg += chr(13)+chr(10)+cMotCotacao
								EndIf

								If lDesconto
									cMsg += chr(13)+chr(10)+cMotDesconto
								EndIf

								If lCredito
									cMsg += chr(13)+chr(10)+cMotCredito
								EndIf

								If lVenFut
									cMsg += chr(13)+chr(10)+cMotVenFut
								EndIf

								Aviso("Erro", cMsg, {"Ok"},,"Aten็ใo")
							EndIf
						Else
							MessageBox("O or็amento sofreu bloqueios. Utilize a op็ใo Gravar como or็amento (F4).",,16)
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf

		EndIf

		//Validacoes da TudoOK e da LinOK
		If nOpc == 0

			//Posiciona ordem das tabelas.
			SB2->(DbSetOrder(1))
			SB5->(DbSetOrder(1))

			nI := If(nTipo == 1, n, 1)

			Do While lRet .And. ((nTipo == 1 .And. nI == n) .Or. (nTipo == 2 .And. nI <= Len(aCols)))
				If !GdDeleted(nI, aHeader, aCols)

					// Nใo permite inserir linhas vazias no or็amento
					If lRet .And. Empty(aCols[nI,nPProd])
						lRet := .F.
					EndIf

					SB1->(DbSeek(xFilial("SB1")+aCols[nI,nPProd]))
					SB2->(DbSeek(xFilial("SB2")+aCols[nI,nPProd]+aCols[nI,nPLocal]))
					SB5->(DbSeek(xFilial("SB5")+aCols[nI,nPProd]))

					If lRet .And. nI <= Len(aColsDet)
						aCols[nI, nPTES] 	:= aColsDet[nI, nPDTES]
						aCols[nI, nPLocal] 	:= aColsDet[nI, nPDLocal]
						aCols[nI, nPPrcTab] := aColsDet[nI, nPDPrcTab]
					EndIf

					If lRet .And. Empty(aCols[nI,nPTES])
						Aviso("Erro", "TES nใo informada!"+Chr(13)+Chr(10)+"Exclua o item sem TES ou solicite a corre็ใo junto ao setor fiscal.", {"Ok"},,"Aten็ใo")
						lRet := .F.
					EndIf

					If lRet .And. SB5->B5_YCTRCUL == "1" .And. Empty(aCols[nI,nPCult])
						Aviso("Erro", "Cultura nใo informada!"+Chr(13)+Chr(10)+"ษ obrigatorio informar a cultura a que se destina o produto "+AllTrim(aCols[nI,nPDescr])+".", {"Ok"},,"Aten็ใo")
						lRet := .F.
					EndIf

					SZS->(DbSetOrder(1))
					If lRet .And. SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8" .And. !Empty(aCols[nI,nPAbast])

						cAbaste := ""
						nI2 	:= 1

						Do While nI2 <= Len(aCols)
							If !GdDeleted(nI2, aHeader, aCols) .And. !nI2 == nI
								cAbaste += aCols[nI2,nPAbast] + aCols[nI2,nPBico] + "-"
							EndIf
							nI2++
						EndDo

						If  aCols[nI,nPAbast] + aCols[nI,nPBico] $ cAbaste
							Aviso("Erro", "Abastecimento jแ informado!"+Chr(13)+Chr(10)+"O abastecimento jแ foi informado na tela", {"Ok"},,"Aten็ใo")
							lRet := .F.
						EndIf

						If lRet

							cQuerySL2	:= GetNextAlias()

							BeginSql ALIAS cQuerySL2
								SELECT 	SL2.L2_NUM AS ORCAMENTO,
								SL2.L2_ITEM AS ITEM,
								SL2.L2_DOC AS NOTA
								FROM %TABLE:SL2% SL2
								WHERE	SL2.L2_FILIAL 		= %EXP:FwFilial("SL2")%
								AND SL2.L2_EMISSAO 	>= '20191201'
								AND SL2.%NOTDEL%
								AND SL2.L2_YABAST 	= %EXP:aCols[nI,nPAbast]%
								AND SL2.L2_YBICO 	= %EXP:aCols[nI,nPBico]%
								AND SL2.L2_DOC		<> ' ';

							EndSQL

							If (cQuerySL2)->(!Eof())
								Aviso("Erro", "Abastecimento jแ informado!"+Chr(13)+Chr(10)+"O abastecimento: " + aCols[nI,nPAbast] + " Bico: " +;
								aCols[nI,nPBico] +  " item " + aCols[nI,nPItem] + " jแ foi informado na venda com or็amento numero: " + ;
								(cQuerySL2)->ORCAMENTO + " Item: " + (cQuerySL2)->ITEM + ", favor excluir esse abastecimento para continuar," + ;
								"e comunicar ao HelpDesk pois possํvelmente nใo foi vinculado a venda.", {"Ok"},,"Aten็ใo")
								lRet := .F.
							EndIf

							(cQuerySL2)->(DbCloseArea())

						EndIf
					EndIf

					lRet := lRet .And. U_CLJ008(nI)

					//Valida numero do lote quando produto com rastreabilidade.
					//Nao aplicavel quando orcamento pai de uma VENDA ENTREGA FUTURA.
					//Nใo aplicแvel na Recria para permitir salvar o or็amento quanto utilizada a op็ใo VEF,
					//mesmo a filial nใo estando no parโmetro MV_YFILVEF
					If lRet .And. Empty(aColsDet[nI,nPLote]) .And. Rastro(aCols[nI,nPProd]) .And. !((cFilAnt $ cYFILVEF .Or. cFilAnt == '06') .And. M->LQ_YVENFUT == 'S')
						Aviso("Erro","ษ obrigat๓rio o preenchimento do campo lote para produtos que utilizam rastreabilidade!",{"Voltar"},2)
						lRet := .F.
					EndIf

					If lRet .And. M->LQ_CLIENTE == cYLJCLCF
						//Validacoes para venda a CONSUMIDOR FINAL.
						If lRet .And. !Empty(SB5->B5_CLTOXI)
							//Nao permite a venda de produtos controlados.
							MessageBox("Nใo ้ permitido a venda do produto controlado "+AllTrim(aCols[nI,nPDescr])+" para consumidor final. Informe um cliente vแlido ou altere o produto.",,16)
							lRet := .F.
						EndIf
					EndIf

					If lRet .And. cEstacao == cYLJESTE .And. lYLJBENO .And. Empty(aColsDet[nI,nPReserv]) .And. SaldoSB2() < aCols[nI,nPQuant]
						//EVENTOS - Bloqueio de estoque negativo para orcamento.
						Aviso("Erro","Saldo insuficiente em estoque para o produto "+aCols[nI,nPProd],{"Ok"})
						lRet := .F.
					EndIf

					If lRet .And. M->LQ_YCOTFLU == 'S' .And. aCols[nI,nPDesc] > aCols[nI,nPPerDesc]
						//Valida se tentou alterar o desconto em cotacao.
						Aviso("Aten็ใo", "O desconto inserido no produto " + AllTrim(aCols[nI,nPDescr])+ " ultrapassa o MมXIMO PERMITIDO ("+Transform(aCols[nI,nPPerDesc],"@E 99.9999") + "% ).",{"Ok"})
						lRet := .F.
					EndIf

				EndIf

				nI++
			EndDo
		EndIf

		If nTipo <> 1 .And. nOpc == 0

			//nRotina - Variavel que indica qual a opcao selecionada no menu (aRotina) | 1-Pesquisar 2-Visualizar 3-Atendimento 4-Finaliza Venda

			//Foi necessario fazer um tratamento especial nesta parte pois observou-se que na saida da tela de venda
			//sempre estava gerando novamente as parcelas, com isso se perdia as alteracoes feitas no orcamento gravado
			//ou na tela de parcelas.
			If nRotina == 4 .And. !Empty(M->LQ_HORA)
				//Foi chamado a partir da opcao de finaliza venda, portanto o campo LQ_HORA sera preenchido com X
				//para posteriormente ser indentificado a necessidade de leitura dos dados ja gravados no SL4.
				//Ver rotina LJ7031 e CLJGPG
				M->LQ_HORA		:= Replicate("X",Len(M->LQ_HORA))
			ElseIf nRotina == 3 .And. M->LQ_YCOND == M->LQ_CONDPG
				//Foi chamado a partir da opcao de atendimento e nao houve alteracao da condicao de pagamento,
				//portanto o campo LQ_CONDPG ficara em branco para que o sistema nao recalcule as parcelas
				//o que faria com que fossem perdidas as alteracoes feitas na tela de pagamento.
				M->LQ_CONDPG	:= Space(Len(M->LQ_CONDPG))
			EndIf

		EndIf

	EndIf

	// Para uso do processo BARTER PRำPRIO	
	U_LOJAY50A() //antiga U_BARTERVA() 
	// Fim Para uso do processo BARTER PRำPRIO

	RestArea(aAreaSB1)
	RestArea(aAreaSB2)
	RestArea(aAreaSB5)
	RestArea(aAreaSZS)
	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7031 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada acionado na entrada e saida da tela de    บฑฑ
ฑฑบ          ณ pagamentos (tecla F7)									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ lCria - Se foi chamado na criacao da tela de definicao de  บฑฑ
ฑฑบ          ณ pagamentos.												  บฑฑ
ฑฑบ          ณ lPanVA3 - Quando igual a .T., foi chamado a partir da tela บฑฑ
ฑฑบ          ณ de definicao de pagamentos, ou seja, esta indo para a tela บฑฑ
ฑฑบ          ณ vendas.													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7031()

	Local lCria 		:= PARAMIXB[1]
	Local lPanVA3		:= PARAMIXB[2]
	Local _cFrmPdr		:= GetMv("MV_YFRMPDR")
	Local cYFILDUP		:= GetMv("MV_YFILDUP")
	Local lCheque		:= .F.
	Local lYCALFRE		:= GetMv("MV_YCALFRE")
	Local cForma		:= ""
	Local cTES			:= ""
	Local nFreteAtu		:= 0
	Local nOldPos		:= 0
	Local nPProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]

	Local _nLimVl		:= GetMV("MV_YLIMVL")

	//O ponteiro n indica a linha posicionada no browser, por padrao mesmo que nao existem itens na venda o browser possui uma linha em branco portanto n = 1.
	//Verifica se foi informado algum item no browser ou se foi chamado a partir da tela de pagamentos no caso da rotina RECEBIMENTOS, caso em que nao ha itens informados.
	If (!Empty(aCols[n,nPProd]) .Or. Len(aCols) > 1) .And. !lCria

		If lPanVA3
			M->LQ_YCOND := M->LQ_CONDPG
			//Forca o foco do controle para o browse de itens, o que faz com que o cabecalho da tela de vendas
			//seja atualizado. Foi observado que quando a mudanca de tela ocorre por meio da selecao des botoes
			//ao inves da tecla de atalho, o cabecalho nao atualiza automaticamente.
			oGetVA:oBrowse:SetFocus()
		Else
			//nRotina - Variavel que indica qual a opcao selecionada no menu (aRotina) | 1-Pesquisar 2-Visualizar 3-Atendimento 4-Finaliza Venda

			If lYCALFRE
				//Salva o valor do frete atual.
				nFreteAtu	:= M->LQ_FRETE
				//Totaliza o frete com base nos itens.
				M->LQ_FRETE	:= U_CLJFRT()
				LJ7T_Total( 2, LJ7T_SubTotal(2) - Lj7T_DescV(2) + LJ7CalcFrete() )
			EndIf

			//Neste ponto verifica se esta visualizando, finalizando ou gravando a venda.
			//Ver rotina LJ7030 e CLJGPG
			If nRotina == 2
				//Visualizacao.
				U_CLJGPG(M->LQ_YCOND,NIL,NIL,.T.)
			ElseIf (nRotina == 4 .And. M->LQ_HORA == Replicate("X",Len(M->LQ_HORA)))
				//Ao finalizar venda carrega as informacoes do orcamento salvo anteriormente.
				If (M->LQ_EMISSAO != DDATABASE)
					//Assume a condicao de pagamento digitada na tela de venda
					M->LQ_CONDPG := M->LQ_YCOND
					//Caso esteja finalizando em data diferente da emissao, sempre recalcula as parcelas.
					U_CLJGPG(M->LQ_YCOND,NIL,NIL,.F.)
				Else
					U_CLJGPG(M->LQ_YCOND,NIL,NIL,.T.)
				EndIf
			Else

				//Assume a condicao de pagamento digitada na tela de venda
				If Empty(M->LQ_CONDPG)
					M->LQ_CONDPG := M->LQ_YCOND
				EndIf

				//Verifica forma de pagamento
				cForma := U_CLJFPG()

				//Verifica se a condicao de pagamento foi alterada na tela de venda, em caso afirmativo recalcula
				//as parcelas de pagamento haja vista que a alteracao foi feita no campo condicao de pagamento customizado.
				//Se houver negociacao de pagamento ou forma de pagamento FINANCIAMENTO, TROCA FUTURA, BARTER ou CAMPANHA sempre recalcula as parcelas.
				//Tambem verifica o flag de geracao de parcelas e o valor do frete calculado.
				lCheque := SZB->(DbSeek(xFilial("SZB")+M->LQ_NUM))
				If (!Empty(M->LQ_YCOND) .And. M->LQ_YCOND != M->LQ_CONDPG) .Or. lCheque .Or. ("FN" $ cForma .Or. "TF" $ cForma .Or. "BT" $ cForma .Or. "CM" $ cForma) .Or. (lYCALFRE .And. M->LQ_FRETE <> nFreteAtu) .Or. lCLJGPG
					M->LQ_CONDPG := M->LQ_YCOND
					U_CLJGPG(M->LQ_YCOND)
				EndIf

			EndIf

			If lYCALFRE .And. !Empty(M->LQ_FRETE)
				MessageBox("O valor do frete R$ "+AllTrim(Transform(M->LQ_FRETE,"@E 999,999.99"))+" foi somado ao total dos produtos!",,48)
			EndIf

			If lVisuSint
				oPgtosSint:SetFocus()
			Else
				oPgtos:SetFocus()
			EndIf
		EndIf

	EndIf

	//Brasoft
	If  cFilAnt $ cYFILDUP
		If SL1->(DbSeek(xFilial("SL1")+M->LQ_NUM))
			If aTotais[1][2] > _nLimVl .And. M->LQ_FORMPG == "BO"
				Return
			Else
				For _nX := 1 To Len(aPgtos)
					If "BO" $ aPgtos[_nX, 3]
						aPgtos[_nx,3] := _cFrmPdr
						If !lPanVA3 .and. !lCria
							aPgtossint[1][1] := _cFrmPdr
						EndIf
					EndIf
				Next _nX
			EndIf
		Else
			If !lPanVA3 .and. !lCria
				For _nX := 1 To Len(aPgtos)
					If "BO" $ aPgtos[_nX, 3]
						aPgtos[_nx,3] := _cFrmPdr
						aPgtossint[1][1] := _cFrmPdr
					EndIf
				Next _nX
			EndIf
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7032 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esse ponto de entrada tem como finalidade validar o acesso บฑฑ
ฑฑบ          ณ a tela de atendimento do Venda Assistida.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nOpc - Rotina executada na MBrowse						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - Se permite ou nao o acesso a tela de atendimento.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7032()

	Local nOpc 		:= PARAMIXB[1]
	Local lRet 		:= .T.
	Local cUser		:= RetCodUsr()
	Local cYLJUOEV	:= GetMv("MV_YLJUOEV")
	Local cYMODEVT	:= GetMV("MV_YMODEVT")   									// Modo de configuracao do evento atual: 1 = Offline, 2 = Offline + Online (WS), 3 = Online.
	Local cYAMBEVT	:= GetMV("MV_YAMBEVT")										// Identifica o ambiente do evento atual: 1 = Offline (PDV), 2 = Online (Retaguarda)
	Local cYLJESTE	:= GetMv("MV_YLJESTE")	   									// Codigo da estacao relacionada a eventos
	Local cYFILVEF 	:= GetMv("MV_YFILVEF")
	Local lYLJEMNF	:= GetMv("MV_YLJEMNF")	   									// .T. = Forca emissao de NF pelo Venda Assistida
	Local lYUSAVA	:= GetMv("MV_YUSAVA")										// Habilita vendas pela rotina VENDA ASSISTIDA
	Local nI		:= 0
	Local aGrupos	:= UsrRetGrp(,RetCodUsr())
	Local lAdmin	:= .F.

	//Variavel publica destinada a controlar se gera as parcelas a partir de interacoes feitas na tela de vendas.
	//Ver funcoes CLJ003, CLJGPG, LJ7031 e FTVD7031
	Public lCLJGPG	:= .F.

	// Opcoes do MessageBox
	//MB_OK                 0
	//MB_OKCANCEL           1
	//MB_YESNO              4
	//MB_ICONHAND           16
	//MB_ICONQUESTION       32
	//MB_ICONEXCLAMATION    48
	//MB_ICONASTERISK       64

	// Retornos possiveis do MessageBox
	//IDOK                  1
	//IDCANCEL              2
	//IDYES                 6
	//IDNO                  7

	// Inicializacao de variavel estatica lBloqAnt.
	lBloqAnt := (nOpc == 4 .And. SL1->L1_YBLOQ != " " .And. SL1->L1_YBLOQ != "L")

	//Valida o uso da opcao Copia Orcamento do menu Acoes Relacionadas.
	//Esta opcao dispara um MsExecAuto do proprio LOJA701 e pode ser tratado pela variavel lAutoExec e a chamada da funcao Lj7CpGrvOr.
	If IsInCallStack("Lj7CpGrvOr")
		//Primeiro o MsExecAuto carrega o orcamento atual para ler os dados do mesmo (sem interface visual) e em seguida abre a tela de atendimento ja fora da rotina automatica.
		//O retorno deve ser o mesmo em ambos os momentos, porem quaisquer mensagens deverao ser exibidas somente fora da rotina automatica.

		//Veririca se usuario pertente ao grupo ADMINSTRADORES
		For nI := 1 to Len(aGrupos)
			If aGrupos[nI] = "000000"
				lAdmin := .T.
			EndIf
		Next nI

		If !lAutoExec .And. !lAdmin
			MessageBox("Este or็amento nใo pode ser copiado. Op็ใo nใo disponํvel!",,16)
		EndIf

		If !lAdmin
			lRet := .F.
		End
	Else
		//nOpc == 3, indica que foi chamado a partir da opcao "Atendimento" no MBrowse
		//ou seja, se trata de inclusao de uma nova venda.
		//nOpc == 4, indica que foi chamado a partir da opcao "Finaliza Venda" no MBrowse

		If nOpc == 4
			If !lAutoExec .And. SL1->L1_ESTACAO == cYLJESTE .And. cEstacao <> cYLJESTE
				//EVENTOS - Valida finalizacao fora da estacao.
				MessageBox("Or็amento relacionado a evento nใo poderแ ser finalizado nesta esta็ใo!",,16)
				lRet 	:= .F.
			ElseIf !lAutoExec .And. SL1->L1_ESTACAO == cYLJESTE .And. cYMODEVT == "1" .And. SL1->L1_YBLOQ == "P" .And. !AllTrim(cUser) $ cYLJUOEV
				//EVENTOS - Se modo de evento OFFLINE, valida finalizacao na estacao quando efetivado como pedido.
				MessageBox("Or็amento efetivado como PEDIDO nใo poderแ ser finalizado! Entre em contato com a organiza็ใo do evento.",,16)
				lRet 	:= .F.
			ElseIf !lAutoExec .And. SL1->L1_ESTACAO == cYLJESTE .And. cYMODEVT == "2" .And. cYAMBEVT == "1" .And. !Empty(SL1->L1_YORCEVT) .And. !Trim(SL1->L1_YORCEVT) $ "I_R"
				//EVENTOS - Se modo de evento OFFLINE + ONLINE valida finalizacao quando foi processado com sucesso na retaguarda a partir da estacao do evento na base OFFLINE.
				MessageBox("Este or็amento jแ foi PROCESSADO. Finalize o or็amento n๚mero "+SL1->L1_YORCEVT+" que foi gravado na RETAGUARDA!",,48)
				lRet := .F.
			ElseIf !lAutoExec .And. SL1->L1_ESTACAO == cYLJESTE .And. cYMODEVT == "2" .And. cYAMBEVT == "1" .And. Trim(SL1->L1_YORCEVT) == "R"
				//EVENTOS - Se modo de evento OFFLINE + ONLINE valida finalizacao quando orcamento invalido a partir da estacao do evento na base OFFLINE.
				MessageBox("Este or็amento foi REJEITADO e nใo poderแ ser finalizado. Efetue a corre็ใo da causa da rejei็ใo e refa็a o or็amento!",,16)
				lRet := .F.
			EndIf
		EndIf

		#IFDEF TOP
		If lYLJEMNF
			//Na entrada da tela de atendimento altera a identificacao do modulo para SIGAHSP - GESTAO HOSPITALAR
			//Neste modulo por padrao emite NOTA FISCAL ao inves de CUPOM FISCAL
			nModulo := 51
		EndIf

		If nOpc == 3 .And. U_CLJCXL() //SM0->M0_ESTENT == "MG" .And.
			//Quando a venda for feita por empresa de MG o cupom fiscal a impressao do cupom fiscal
			//ocorre de forma concomitante. Devido as customizacoes existentes na Venda Assistida
			//nao sera aceito a venda concomitante e portanto o acesso a tela de atendimento sera negado
			//para os usuarios que sao caixa.
			Aviso("Erro", "Usuแrio nใo possui acesso para atendimento! Utilize a op็ใo finaliza venda.", {"Ok"},,"Aten็ใo")
			lRet 	:= .F.
		EndIf
		#ENDIF
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7033 	บAuthor ณ Ylram Mariani		 บ Date ณ  22/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada acionado na saida da tela de vendas.	  บฑฑ
ฑฑบ          ณ Neste ponto os dados ja foram gravados no SL1 no caso de   บฑฑ
ฑฑบ          ณ confirmacao, ou a venda foi cancelada sem gravacao.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ lGravacao - Controla se foi chamado da gravacao (orcamento บฑฑ
ฑฑบ          ณ ou venda).												  บฑฑ
ฑฑบ          ณ nOpc - Rotina executada na MBrowse						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7033()

	Local lGravacao	:= PARAMIXB[1]
	Local nOpc		:= PARAMIXB[2]
	Local nPProd	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do Produto
	Local aAreaSL2	:= SL2->(GetArea())
	Local cYAMBEVT	:= GetMV("MV_YAMBEVT")														// Identifica o ambiente do evento atual: 1 = Offline (PDV), 2 = Online (Retaguarda)
	Local cYLJESTE	:= GetMv("MV_YLJESTE")	   													// Codigo da estacao relacionada a eventos
	Local lYLJEMNF	:= GetMv("MV_YLJEMNF")														// .T. = Forca emissao de NF pelo Venda Assistida
	Local aAreaSZS	:= SZS->(GetArea())

	//-----------------------------------------------------------------------------
	// Inicio das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------
	Local nC := 1
	//-----------------------------------------------------------------------------
	// Fim das tratativas referente ao Posto de Combustivel
	//-----------------------------------------------------------------------------

	//O ponteiro n indica a linha posicionada no browser, por padrao mesmo que nao existem itens na venda o browser possui uma linha em branco portanto n = 1.
	//Verifica se foi informado algum item no browser ou se foi chamado a partir da tela de pagamentos no caso da rotina RECEBIMENTOS, caso em que nao ha itens informados.
	If (!Empty(aCols[n,nPProd]) .Or. Len(aCols) > 1)

		If lYLJEMNF
			//Na saida da tela de atendimento restaura a identificacao do modulo para SIGALOJA - CONTROLE DE LOJA
			nModulo := 12
		EndIf

		//nOpc == 3, indica que foi chamado a partir da opcao "Atendimento" no MBrowse
		//ou seja, se trata de inclusao de uma nova venda.
		//nOpc == 4, indica que foi chamado a partir da opcao "Finaliza Venda" no MBrowse
		If nOpc == 3 .And. !lGravacao
			//Caso nao tenha confirmado a gravacao do orcamento devera excluir os dados da negociacao de pagamento SZB
			SZB->(DbSeek(XFilial("SZB")+M->LQ_NUM))
			Do While SZB->ZB_FILIAL == XFilial("SZB") .And. SZB->ZB_ORCAMEN == M->LQ_NUM .And. !SZB->(EoF())
				RecLock("SZB",.F.)
				SZB->(DbDelete())
				SZB->(MsUnLock())
				SZB->(DbSkip())
			EndDo
		EndIf

		If !lAutoExec .And. lGravacao

			//-----------------------------------------------------------------------------
			// Inicio das tratativas referente ao Posto de Combustivel
			//-----------------------------------------------------------------------------

			SZS->(DbSetOrder(1))
			If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"
				If GetNewPar("MV_YPCLHAB",.F.) .And. !ParamIXB[1]

					For nC := 1 to Len(aCols)

						cCodAbast 	:= GDFieldGet("LR_YABAST",nC)

						If !Empty(cCodAbast) .And. !GDDeleted()

							dbSelectArea("ZPA")
							dbSetOrder(1) //ZPA_FILIAL+ZPA_CODIGO

							If ZPA->(dbSeek(xFilial("ZPA")+cCodAbast))

								aZPA := {}
								aAdd(aZPA,{"ZPA_NUMORC"	,""})
								aAdd(aZPA,{"ZPA_ITEORC"	,""})
								aAdd(aZPA,{"ZPA_FILORC"	,""})
								aAdd(aZPA,{"ZPA_SITUA"	,"00"})

								FRTGeraSL("ZPA",aZPA,.F.)

							EndIf
						EndIf
					Next nC
				EndIf
			EndIf
			//-----------------------------------------------------------------------------
			// Fim das tratativas referente ao Posto de Combustivel
			//-----------------------------------------------------------------------------

		EndIf
	EndIf

	RestArea(aAreaSL2)
	RestArea(aAreaSZS)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7041 	บAuthor ณ Ylram Mariani		 บ Date ณ  11/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O ponto de entrada LJ7041 ocorre antes de chamar a funcao  บฑฑ
ฑฑบ          ณ Lj7VerEst (que valida o saldo em estoque do almoxarifado)  บฑฑ
ฑฑบ          ณ e permite ao cliente personalizar dinamicamente o 		  บฑฑ
ฑฑบ          ณ almoxarifado padrao do item de venda, alterando o conteudo บฑฑ
ฑฑบ          ณ da variavel cLocal na inclusao. 							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ cLocal - Local (almoxarifado) do produto.                  บฑฑ
ฑฑบ          ณ aColsDet - Array contendo os detalhes dos produtos.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ cLocal - O codigo do local (almoxarifado) desejado.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
User Function LJ7041()

Local cLocal  	:= PARAMIXB[1]   			// Recebe parametro contendo almoxarifado
Local aColsDet	:= PARAMIXB[2]      		// Recebe parametro contendo o array aColsDet
Local cYLJESTE	:= GetMv("MV_YLJESTE")		// Codigo da estacao relacionada a eventos

cLocal := '' // Se o retorno da funcao for vazio, nao altera o almoxarifado padrao

//EVENTOS - Inicializa local de estoque com a filial de retirada.
If cEstacao == cYLJESTE
cLocal := M->LQ_YFILPED
EndIf

Return cLocal
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7051 	บAuthor ณ Ylram Mariani		 บ Date ณ  18/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada localizado na Venda Assistida que atualizaบฑฑ
ฑฑบ          ณ os vetores aLegenda e aCores na inicializacao da interface บฑฑ
ฑฑบ          ณ de venda.												  บฑฑ
ฑฑบ          ณ Atencao: O Ponto de Entrada P_LJ7051 e utilizado			  บฑฑ
ฑฑบ          ณ exclusivamente pela equipe interna da Fabrica de Software  บฑฑ
ฑฑบ          ณ TOTVS. Utilize, portanto, o Ponto U_LJ7051. 				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nOpc - Numerico, 1 - Atualiza o aLegenda, 2 - Atualiza o   บฑฑ
ฑฑบ          ณ aCores													  บฑฑ
ฑฑบ          ณ aArray - Array of Record, Dependendo do nOpc, recebe o	  บฑฑ
ฑฑบ          ณ aLegenda ou aCores										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7051(nOpc,aArray)

	Local aArrayCustom	:= {}
	Local cYAMBEVT		:= GetMV("MV_YAMBEVT")	// Identifica o ambiente do evento atual: 1 = Offline (PDV), 2 = Online (Retaguarda)
	Local cYLJESTE		:= GetMv("MV_YLJESTE")	// Codigo da estacao relacionada a eventos
	Local nI

	//EVENTOS - Tratamento da legenda do orcamento quando ambiente OFFLINE.
	//Inclui as legendas customizadas no array customizado.
	If cEstacao == cYLJESTE .And. cYAMBEVT == '1'
		If nOpc == 1
			aAdd( aArrayCustom, { "IC_20_GRAVAR" 			, "Orcamento Processado no Evento" 		})
			aAdd( aArrayCustom, { "IC_EXPORTACAO" 			, "Orcamento a Processar no Evento" 	})
			aAdd( aArrayCustom, { "IC_EXCLAMACAO" 			, "Orcamento Inconsistente no Evento" 	})
			aAdd( aArrayCustom, { "IC_20_CANCELAR" 			, "Orcamento Rejeitado no Evento" 		})
			aAdd( aArrayCustom, { "IC_20_DOCUMENTO"	 		, "Orcamento com Pedido em Evento" 		})
		Else
			aAdd( aArrayCustom, { "!Empty(L1_YORCEVT) .And. !Trim(L1_YORCEVT) $ 'I_R'" 			, "IC_20_GRAVAR"  	})
			aAdd( aArrayCustom, { "Empty(L1_YORCEVT) .And. L1_YBLOQ <> 'P'" 					, "IC_EXPORTACAO" 	})
			aAdd( aArrayCustom, { "Trim(L1_YORCEVT) == 'I' .And. L1_DTLIM >= DDATABASE" 		, "IC_EXCLAMACAO" 	})
			aAdd( aArrayCustom, { "Trim(L1_YORCEVT) == 'R'" 									, "IC_20_CANCELAR" 	})
			aAdd( aArrayCustom, { "L1_YBLOQ == 'P'" 											, "IC_20_DOCUMENTO" })
		EndIf
	EndIf

	If nOpc == 1
		aAdd( aArrayCustom, { "IC_CADEADO_VERMELHO"		, "Orcamento Bloqueado"	})
	Else
		aAdd( aArrayCustom, { "L1_YBLOQ == 'C' .Or. L1_YBLOQ == 'D' .Or. L1_YBLOQ == 'T'" 	, "IC_CADEADO_VERMELHO" })
	EndIf

	//Adiciona ao array customizado as demais opcoes padrao, matendo as customizacoes no inicio.
	For nI := 1 to Len(aArray)
		aAdd(aArrayCustom,aClone(aArray[nI]))
	Next

	//Substitui o array padrao pelo, lembrando que o array padrao e passado por referencia.
	aArray := aClone(aArrayCustom)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7053 	บAuthor ณ Ylram Mariani		 บ Date ณ  21/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada executado na selecao da opcao Atendimento บฑฑ
ฑฑบ          ณ ->Venda Assistida no menu do modulo SIGALOJA, onde permite บฑฑ
ฑฑบ          ณ acrescentar mais opcoes de botoes no menu da tela.		  บฑฑ
ฑฑบ          ณ OBSERVACOES: Para que as opcoes do PE sejam acrescentada   บฑฑ
ฑฑบ          ณ no menu padrao sempre devera retornar uma variavel do tipo บฑฑ
ฑฑบ          ณ Array e cada posicao dela contendo um Array com 6 posicoes บฑฑ
ฑฑบ          ณ conforme o exemplo abaixo: 								  บฑฑ
ฑฑบ          ณ aArrayaRotinas := { { "Nome_Botao" ,"Funcao" ,0,1,,.F.};   บฑฑ
ฑฑบ          ณ 					   { "Nome_Botao2","Funcao2",0,1,,.F.} }  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ aArrayRotinas - Opcoes a serem acrescentadas ao menu. 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7053()

	Local aArrayRotinas		:= {}
	Local cYDTVGSO			:= GetMV("MV_YDTVGSO")

	aAdd( aArrayRotinas , { "Enviar para o CPL","U_LIBY006A(SL1->(Recno()), 'O')",0,2,,.F. })

	//DAV = Fonte LOJR210
	//MV_SCRORC = Parametro que configura o Script de impressao do Orcamento
	AAdd( aArrayRotinas , { "DAV","U_C_LOJR210()",0,6,,.F. } )

	//Vendas em grandes volumes.
	aAdd( aArrayRotinas , { "Status de Bloqueio","U_LOJAY020(SL1->(Recno()))",0,2,,.F. }) // nOpc = 2, para nใo travar o or็amento

	//Gera็ใo de Contrato financiado maquinas.
	aAdd( aArrayRotinas , { "Imprimir Contrato","U_LOJRY011(SL1->L1_FILIAL, SL1->L1_NUM)",0,2,,.F. }) // nOpc = 2, para nใo travar o or็amento

	//Gera็ใo de Receita agronomica.
	aAdd( aArrayRotinas , { "Solicitar Receita Agro.","U_LOJAY044()",0,2,,.F. }) // nOpc = 2, para nใo travar o or็amento

	aAdd( aArrayRotinas , { "KM Cliente.","U_LOJAY046()",0,2,,.F. })
	aAdd( aArrayRotinas , { "Recibo Abastecimento.","U_LOJRY019()",0,2,,.F. })

	//Reimpressใo de cupons de sorteio
	If (dDataBase >= SToD(SubStr(cYDTVGSO,1,8)) .And. dDataBase <= SToD(SubStr(cYDTVGSO,10,8)))
		aAdd( aArrayRotinas , { "Reimp Cupom Sorteio.","U_LOJAY036(1)",0,1,Nil,.F. })
	EndIf

Return aArrayRotinas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7054 	บAuthor ณ Ylram Mariani		 บ Date ณ  06/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada que substitui a tela de digitacao dos	  บฑฑ
ฑฑบ          ณ dados dos cheques.										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ aDadosChq - Array com os dados do cheque.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ aDadosChq - Array com os dados do cheque.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7054()

	Local aDadosChq := PARAMIXB[1]

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Array aDadosChq[1] que contem os dados do cheque, de acordo	ณ
	//ณ com a configuracao:											ณ
	//ณ 1 - Valor da parcela (numerico)								ณ
	//ณ 2 - Data do vencimento (date)								ณ
	//ณ 3 - Numero da parcela (numerico)							ณ
	//ณ 4 - Banco (caracter)										ณ
	//ณ 5 - Agencia (caracter)										ณ
	//ณ 6 - Conta (caracter)										ณ
	//ณ 7 - Numero do cheque (caracter)								ณ
	//ณ 8 - Compensacao (caracter)									ณ
	//ณ 9 - RG (caracter)											ณ
	//ณ 10 - Telefone (caracter)									ณ
	//ณ 11 - Utilizar nas proximas parcelas (logico)				ณ
	//ณ 12 - Cheques de terceiros (logico)							ณ
	//ณ 13 - Simbolo da moeda (caracter)							ณ
	//ณ 14 - Emitente (caracter)									ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If SZB->(DbSeek(XFilial("SZB")+M->LQ_NUM+aDadosChq[3]))
		//Pega os dados do cheque no SZB e preenche o array de retorno, dispensando a digitacao.
		aDadosChq[4]  := SZB->ZB_BANCO
		aDadosChq[5]  := SZB->ZB_AGENCIA
		aDadosChq[6]  := SZB->ZB_CONTA
		aDadosChq[7]  := SZB->ZB_NUM
		aDadosChq[9]  := SZB->ZB_CPFCNPJ
		aDadosChq[11] := .F.
		aDadosChq[12] := (SZB->ZB_CPFCNPJ <> SA1->A1_CGC)
		aDadosChq[14] := SZB->ZB_EMITENT
	EndIf

Return aDadosChq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7078   บAuthor ณ Ylram Mariani		 บ Date ณ 05/10/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O ponto de entrada LJ010FILT permite realizar filtros na	  บฑฑ
ฑฑบ          ณ serie da nota fiscal no instante da finalizacao da venda.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ nVlrTotal - Valor total da venda.						  บฑฑ
ฑฑบ          ณ nTotaImp - Valor total dos impostos.						  บฑฑ
ฑฑบ          ณ nTotImpFED - Valor total dos impostos federais.			  บฑฑ
ฑฑบ          ณ nTotImpEST - Valor total dos impostos estaduais.			  บฑฑ
ฑฑบ          ณ nTotImpMUN - Valor total dos impostos municipais.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ cMsgCupom - Mensagem a ser impressa no cupom fiscal.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7078()

	Local nVlrTotal		:= ParamIXB[1]
	Local nTotaImp 		:= ParamIXB[2]
	Local nTotImpFED	:= ParamIXB[3]
	Local nTotImpEST	:= ParamIXB[4]
	Local nTotImpMUN	:= ParamIXB[5]
	Local cMsgCupom		:= ""
	Local cTotImpFED 	:= AllTrim( Transform(  nTotImpFED , PesqPict( "SL1", "L1_VLRTOT",, 1 ) ) )
	Local cTotImpEST 	:= AllTrim( Transform(  nTotImpEST , PesqPict( "SL1", "L1_VLRTOT",, 1 ) ) )
	Local cTotImpMUN 	:= AllTrim( Transform(  nTotImpMUN , PesqPict( "SL1", "L1_VLRTOT",, 1 ) ) )

	cMsgCupom := "Trib.Aprox R$: " + cTotImpFED + " Fed;"
	cMsgCupom += " R$: " + cTotImpEST + " Est;"
	cMsgCupom += " R$: " + cTotImpMUN + " Mun."
	cMsgCupom += " Fonte:IBPT"+Chr(10)+Chr(13)

Return cMsgCupom

/*/{Protheus.doc} LJ7087
@description Com o CNPJ da empresa liberado para emissใo de Nota Fiscal
no Venda Assistida, este Ponto de Entrada permite que o
usuแrio defina o tipo da venda (Cupom ou Nota), ou se serแ
exibida a pergunta padrใo: “Cupom ou Nota?”.
Tamb้m ้ possํvel definir se serแ utilizado Cupom (NFC-e),
ou Nota sem a apresenta็ใo da pergunta na tela.
ษ executado no inํcio da venda, ap๓s o preenchimento do
cliente, ou na finaliza็ใo da venda por meio da op็ใo
“Finalizar Venda” na tela de lista de or็amentos .
@author Guilherme Covre Dalleprane
@since 03/11/2018
@version 1.0
@type function
/*/

User Function LJ7087()
	Local nRet			:= 1 	//0 = Verifica emissao (padrใo) / 1 = Emissใo de CF ou NFC-e / 2 = Emissao de nota
	Local cEstadoFil 	:= ""
	Local cEstadoCli	:= ""
	Local aAreaSZS		:= SZS->(GetArea())

	/*
	- Tudo que for interestadual, serแ utilizado NF-e.
	- Filiais especํficas emitem apenas NF-e.
	- Apenas para refor็ar, entregas dentro do estado serแ NFC-e.
	*/

	// --------------------------------
	// Sempre emite notas fiscais
	// para clientes de outro estado
	// --------------------------------
	If nRet == 1 .And. cEstadoCli != cEstadoFil
		nRet := 2
	EndIf

	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + xFilial("SL1")))
		cEstadoFil := SZS->ZS_EST
	EndIf

	If INCLUI
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + M->LQ_CLIENTE + M->LQ_LOJA))
			cEstadoCli := SA1->A1_EST
		EndIf
	Else
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA))
			cEstadoCli := SA1->A1_EST
		EndIf
	EndIf

	// --------------------------------
	// Sempre emite notas fiscais
	// clientes pessoa juridica
	// --------------------------------

	If nRet == 1 .And. SA1->A1_PESSOA == "J"
		//-----------------------------------------------------------------------------
		// Inicio das tratativas referente ao Posto de Combustivel
		//-----------------------------------------------------------------------------

		SZS->(DbSetOrder(1))
		If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"
			If SA1->A1_COD + SA1->A1_LOJA == SZS->ZS_CLIENTE + SZS->ZS_LOJACLI
				nRet := 2
			Else
				nRet := 1
			EndIf
		Else
			nRet := 2
		EndIf
	EndIf

	// --------------------------------
	// Sempre emite notas fiscais
	// para documentos de VEF
	// --------------------------------

	If INCLUI
		If nRet == 1 .And. M->LQ_YVENFUT == "S"
			nRet := 2
		EndIf
	Else
		If nRet == 1 .And. SL1->L1_YVENFUT == "S"
			nRet := 2
		EndIf
	EndIf

	RestArea(aAreaSZS)

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ7099 	บAuthor ณ Ylram Mariani		 บ Date ณ  08/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O Ponto de Entrada LJ7099, permite retornar uma string no  บฑฑ
ฑฑบ          ณ formato XML com informacoes referentes a um Produto 		  บฑฑ
ฑฑบ          ณ Especifico. Somente informacoes do produto especifico 	  บฑฑ
ฑฑบ          ณ devem ser retornados, ou seja, qualquer informa็ใo 		  บฑฑ
ฑฑบ          ณ adicional pode causar inconsistencia do documento 		  บฑฑ
ฑฑบ          ณ eletronico.											 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ cXML - String no formato XML contendo as informacoes do 	  บฑฑ
ฑฑบ          ณ produto especifico.			 							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ7099()

	Local aAreaSL1		:= SL1->(GetArea())
	Local aAreaSL2		:= SL2->(GetArea())
	Local aAreaSB5		:= SB5->(GetArea())
	Local cXML 			:= ""
	Local cInfAdProd	:= ""

	/*
	Observacoes:
	O Ponto de Entrada nao recebe nenhum parametro, porem no momento da execucao, o registro estara posicionado no item em questao (SL2);
	Como o registro esta posicionado no momento da execucao do ponto de entrada, e IMPORTANTE que as funcoes GetArea e RestArea sejam utilizadas;
	A string retornada nao pode conter caracteres de quebra de linhas (exemplo: CRLF);
	A informacao do produto especํfico deve ser retornada por item, ou seja, nesse caso o ponto de entrada sera executado para cada item;
	Somente um Produto Especofico pode ser informado por item;
	Para saber quais informacoes devem ser retornadas, recomendamos a leitura das Normas Tecnicas em vigor;
	*/

	//Informacoes referentes a combustivel
	SB5->(DbSetOrder(1))
	If  SB5->(DbSeek(xFilial("SB5")+SL2->L2_PRODUTO))

		//Monta a tag <comb>
		If !Empty(SB5->B5_YCODANP)
			C0G->(DbSetOrder(7))
			If C0G->(DbSeek(xFilial("C0G") + SB5->B5_YCODANP))
				cXML += "<comb>"
				cXML += "<cProdANP>"+AllTrim(SB5->B5_YCODANP)+"</cProdANP>"
				cXML += "<descANP>"+AllTrim(C0G->C0G_DESCRI)+"</descANP>"
				cXML += "<UFCons>"+Upper(SA1->A1_EST)+"</UFCons>"

				//-----------------------------------------------------------------------------
				// Inicio das tratativas referente ao Posto de Combustivel
				//-----------------------------------------------------------------------------
				If !Empty(SL2->L2_YABAST)
					cXML += "<encerrante>"
					cXML += "<nBico>" 	+ SL2->L2_YBICO	 + "</nBico>"
					cXML += "<nTanque>" + SL2->L2_LOCAL	 + "</nTanque>"
					cXML += "<vEncIni>"	+ Alltrim(Str(SL2->L2_YENCINI,12,3)) + "</vEncIni>"
					cXML += "<vEncFin>"	+ Alltrim(Str(SL2->L2_YENCFIM,12,3)) + "</vEncFin>"
					cXML += "</encerrante>"
				EndIf
				//-----------------------------------------------------------------------------
				// Fim das tratativas referente ao Posto de Combustivel
				//-----------------------------------------------------------------------------
				cXML += "</comb>"
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSL1)
	RestArea(aAreaSL2)
	RestArea(aAreaSB5)

Return cXML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJ010FILT บAuthor ณ Ylram Mariani	 บ Date ณ  02/01/16   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O ponto de entrada LJ010FILT permite realizar filtros na	  บฑฑ
ฑฑบ          ณ serie da nota fiscal no instante da finalizacao da venda.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ cSerie - Serie da nota fiscal.				 			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJ010FILT()

	Local cSerie := Padr(AllTrim(Str(Val(cFilAnt),2)),3)

Return cSerie

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LjRetCli    บAuthor ณ Ylram Mariani	 บ Date ณ 09/10/2017  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este ponto de entrada permite omitir a tela de CPF/CNPJ 	  บฑฑ
ฑฑบ          ณ e/ou incluir o retorno automatico das informacoes (em 	  บฑฑ
ฑฑบ          ณ substituicao a tela padrao do sistema )				  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ O vetor aRet possui a seguinte estrutura:				  บฑฑ
ฑฑบ          ณ [1] - Codigo do cliente (obriatorio) 					  บฑฑ
ฑฑบ          ณ [2] - Loja do cliente (obrigatorio)						  บฑฑ
ฑฑบ          ณ [3] - CPF/CNPJ (opcional)								  บฑฑ
ฑฑบ          ณ [4] - Logico, tela customizada no PE, se .T. nao mostra a  บฑฑ
ฑฑบ          ณ tela padrao, se .F. mostra a tela padrao (opcional)		  บฑฑ
ฑฑบ          ณ [5] - Nome do cliente (opcional)							  บฑฑ
ฑฑบ          ณ [6] - Endereco do cliente (opcional)						  บฑฑ
ฑฑบ          ณ [7] - Se usar Template de Combustiveis deve mostrar a 	  บฑฑ
ฑฑบ          ณ placa do carro (opcional)								  บฑฑ
ฑฑบ          ณ [8] - Se usar Template de Combustiveis deve mostrar a 	  บฑฑ
ฑฑบ          ณ kilometragem do carro (opcional)							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
User Function LjRetCli()

Local aRet 		:= {"","","",.F.,"","","",""}
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())

SA1->(DbSetOrder(1))
If Type("M->LQ_CLIENTE") <> "U" .And. Type("M->LQ_LOJA") <> "U"
SA1->(MsSeek(xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA))
Else
SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
EndIf

aRet[1] := SA1->A1_COD
aRet[2] := SA1->A1_LOJA
aRet[3] := SA1->A1_CGC
aRet[4] := .T.

RestArea(aAreaSA1)
RestArea(aArea)

Return aRet
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณ LJTES 	บAuthor ณ Ylram Mariani		 บ Date ณ  17/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este ponto de entrada e utilizado em todas as rotinas de   บฑฑ
ฑฑบ          ณ venda do modulo Controle de Lojas (SIGALOJA) e FrontLoja.  บฑฑ
ฑฑบ          ณ O conceito padrao dos modulos acima citados e sempre gerar บฑฑ
ฑฑบ          ณ a movimentacao financeira, independente do TES utilizado.  บฑฑ
ฑฑบ          ณ Para nao movimentar o financeiro no ato da venda devera	  บฑฑ
ฑฑบ          ณ ser utilizado o ponto de entrada LJTES com retorno falso.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ cTES - Codigo do TES que esta sendo processado (se chamado บฑฑ
ฑฑบ          ณ da Venda Rapida - LOJA220 ou Venda Balcao - LOJA010)	ou	  บฑฑ
ฑฑบ          ณ nulo (se chamado da Venda Assistida - LOJA701 ou 		  บฑฑ
ฑฑบ          ณ FrontLoja).												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบReturn    ณ lRet - Verdadeiro (.T.) indica que sera gerado movimento	  บฑฑ
ฑฑบ          ณ financeiro, se falso (.F.), nao ira gerar movimento		  บฑฑ
ฑฑบ          ณ financeiro.				  								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ SIGALOJA - LOJA701 - VENDA ASSISTIDA			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LJTES(cTES)

	Local lRet 		:= .T.
	Local cYFILVEF 	:= GetMv("MV_YFILVEF")
	Local aAreaSZS	:= SZS->(GetArea())

	If cFilAnt $ cYFILVEF
		//Condicao de pagamento BONIFICACAO, COMODATO ou VENDA ENTREGA FUTURA nao gera financeiro.
		If SL1->L1_CONDPG $ "BON_COM_VEF" .Or. SL1->L1_YCOND $ "BON_COM_VEF"
			lRet := .F.
		EndIf
	Else
		//Condicao de pagamento BONIFICACAO ou COMODATO nao gera financeiro.
		If SL1->L1_CONDPG $ "BON_COM" .Or. SL1->L1_YCOND $ "BON_COM"
			lRet := .F.
		EndIf
	EndIf

	SZS->(DbSetOrder(1))
	If lRet .And. SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. SZS->ZS_TIPOFIL == "8"
		If SL1->L1_CLIENTE + SL1->L1_LOJA == SZS->ZS_CLIENTE + SZS->ZS_LOJACLI
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSZS)

Return lRet

/*/{Protheus.doc} LJ7043
@description Fun็ใo para impedir que o usuแrio selecione outras tabelas de pre็o na rotina venda assistida
@author Fabio Junior Braga
@since 24/10/2018
@version 1.0
@type function
/*/
User Function LJ7043()

	Local lRet := .F.
	Alert("Nใo ้ permitido selecionar uma nova tabela.")

Return lRet

/*/{Protheus.doc} LJ7084
@description O Ponto de Entrada LJ7084, retira a reimpressใo de NFC-e
@author Adrian Demoner Malta
@since 27/10/2018
@version 1.0
@type function
/*/
User Function LJ7084()

	Local lRet := .T.
	Local aAreaSZS	:= SZS->(GetArea())

	IF IsInCallStack("Lj7ImpDanfe")

		SZS->(DbSetOrder(1))
		If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. !SZS->ZS_TIPOFIL == "8"
			MsgInfo("Nใo serแ possํvel reimprimir a NFC-e.")
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSZS)

Return lRet
