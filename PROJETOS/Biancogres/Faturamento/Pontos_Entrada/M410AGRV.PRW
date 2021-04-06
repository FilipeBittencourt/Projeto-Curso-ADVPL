#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"


/*/{Protheus.doc} M410AGRV
@description Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). Está localizado na rotina de gravação do pedido, A410GRAVA(). É executado antes da gravação das alterações.
@author Fernando Rocha
@since 28/03/2017
@version undefined
@type function
/*/
User Function M410AGRV()
	Local nOpcao 		:= Paramixb[1]  //	indica a operação: 1 - inclusão / 2 - alteração / 3 - exclusão
	Local _nomeuser 	:= cUserName
	Local aMargem		:= {}
	Local nLinhaEmp		:= ""
	Local nEmpPed		:= ""
	Local xTpCli		:= ""
	Local xEstCli		:= ""
	Local xMenPad		:= "" 

	//Variavel para controle da Observação para desconto %Outros
	Local nDesp			:= 0

	//Variaveis utiilzadas no calculo/gravaçõs dos impostos
	Local nTotPIS		:= 0
	Local nTotCOFINS	:= 0
	Local nTotICMS		:= 0
	Local nTotIPI       := 0
	Local nTotDesZF     := 0
	Local nTotST		:= 0
	Local nTotPed		:= 0
	Local i, nNumParc

	Local cCategoria	:= ''

	//Tratamento especial para Replicacao de reajuste de preço
	If (IsInCallStack("U_M410RPRC")) .OR. (AllTrim(FunName()) == "RPC")
		Return Nil
	EndIf

	//Tratamento especial para geracao de pedidos de requisicao comum
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
		Return Nil
	EndIf

	//OS 3494-16 - Tania c/ aprovação do Fabio
	If cEmpAnt == "02"
		Return Nil
	EndIf
	
	//Posiciona no Cliente ou Fornecedor
	If Alltrim(M->C5_TIPO) $ ("B_D")
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI)
		xTpCli	:= SA2->A2_TIPO
		xEstCli	:= SA2->A2_EST
	Else
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)
		xTpCli	:= SA1->A1_TIPO
		xEstCli	:= SA1->A1_EST
	EndIf
	
	Public lCheckPV := .F. //Variavel Publica utilizada no P.E. M410STTS para verificao dos descontos fBloqPV

	If nOpcao == 1 .Or. nOpcao == 2  //Incluir ou Alterar

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Empresa
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If cEmpAnt == "14"
			M->C5_YEMP	:= "1401"
		ElseIf cEmpAnt == "13"
			If M->C5_YLINHA == "4"
				M->C5_YEMP	:= "1399"
			ElseIf M->C5_YLINHA == "6"
				M->C5_YEMP	:= "1302"	
			Else
				M->C5_YEMP	:= "1301"
			EndIf	
		Else
			Do Case
				Case M->C5_YLINHA == "1"
				M->C5_YEMP	:= "0101"
				Case M->C5_YLINHA == "2"
				M->C5_YEMP	:= "0501"
				Case M->C5_YLINHA == "3"
				M->C5_YEMP	:= "0599"
				Case M->C5_YLINHA == "4"
				M->C5_YEMP	:= "1399"
				Case M->C5_YLINHA == "5"
				M->C5_YEMP	:= "0199"
				Case M->C5_YLINHA == "6"
				M->C5_YEMP	:= "1302"

			EndCase
		EndIf

		//Forca gravação do Fator Financeiro para empresa Mundi, caso esteja errado.
		If cEmpAnt == "13" .And. M->C5_CLIENTE == "010064" .And. M->C5_YMAXCND <> 1
			M->C5_YMAXCND := 1
		EndIf

		//Procura o Produto e Empresa do Produto
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+Gdfieldget("C6_PRODUTO",1),.T.)
		nLinhaEmp := Posicione("ZZ7",1,xFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ,"ZZ7_EMP")

		//Posiciona no TES do Pedido
		SF4->(DbSetOrder(1))
		SF4->(DbSeek(XFilial("SF4")+Gdfieldget("C6_TES",1)))

		//Grava se Gera Duplicata S/N
		M->C5_YDUPLIC := SF4->F4_DUPLIC

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Define se o registro sera utilizado no resultado da Empresa.
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If M->C5_TIPO <> "D"
			If cEmpAnt == "01"								//BIANCOGRES

				/* DESATIVADA EM 17/10/2014
				If 	M->C5_CLIENTE <> "010064"
				M->C5_YRESULT := "S"
				M->C5_YRESUL2 := "S"
				Else
				M->C5_YRESULT := "N"
				M->C5_YRESUL2 := "N"
				EndIF
				*/

				//Tratamento do Campo YRESULT2 para empresa BIANCOGRES -> INCESA // ATIVADA EM 17/10/14
				If 	(M->C5_CLIENTE) $ "004536_010064"
					M->C5_YRESUL2 := "N"
				Else
					M->C5_YRESUL2 := "S"
				EndIF

				If (M->C5_CLIENTE == "010064" .And. (nLinhaEmp == "0501" .Or. nLinhaEmp == "0599") ) .Or. M->C5_CLIENTE <> "010064"
					M->C5_YRESULT := "S"
				Else
					M->C5_YRESULT := "N"
				EndIF


			ElseIf cEmpAnt == "05"							//INCESA

				//Tratamento do Campo YRESULT2 para empresa INCESA -> LM
				If 	(M->C5_CLIENTE) $ "000481_010064"
					M->C5_YRESUL2 := "N"
				Else
					M->C5_YRESUL2 := "S"
				EndIF

				If (M->C5_CLIENTE == "010064" .And. nLinhaEmp == "0101") .Or. 	M->C5_CLIENTE <> "010064"
					M->C5_YRESULT := "S"
				Else
					M->C5_YRESULT := "N"
				EndIF


			ElseIf cEmpAnt == "07"//LM

				If AllTrim(CFILANT) <> "01"
					M->C5_YRESULT := "S"
					M->C5_YRESUL2 := "S"
				Else
					If AllTrim(M->C5_CLIENTE) $ "025633_025634_025704"
						M->C5_YRESULT := "N"
						M->C5_YRESUL2 := "N"
					Else
						M->C5_YRESULT := "S"
						M->C5_YRESUL2 := "S"
					EndIf
				EndIf

			Else

				M->C5_YRESULT := "S"
				M->C5_YRESUL2 := "S"

			EndIf
		Else
			M->C5_YRESULT := "N"
			M->C5_YRESUL2 := "N"
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Para empresa LM grava o EMPRESA ORIGEM
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		nEmpPed := SubStr(SB1->B1_YEMPEST,1,2) //a empresa de origem dos pedidos LM outsourcing passou a ser por produto

		If cEmpAnt == "07" 

			//Pegar a empresa da primeira linha não deletada
			For i := 1 to Len(aCols)
				If !GdDeleted(i)
					If !Empty(Gdfieldget('C6_YEMPPED',i))

						nEmpPed := Gdfieldget('C6_YEMPPED',i)
						Exit

					EndIf
				EndIf
			Next i

			M->C5_YEMPPED := nEmpPed

		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Fator
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Alltrim(M->C5_YRECR) == "S"
			M->C5_YFATOR	:= GetMv("MV_YRECR")
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Forca a gravacao do Usuario na Inclusao e Alteracao do Pedido Venda
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If nOpcao == 1 .And. !AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") //Inclusao //Fernando -> nao alterar na replicacao LM
			M->C5_YDIGP := Upper(Alltrim(_nomeuser))
		EndIf
		If nOpcao == 2 //Alteracao
			M->C5_YALTP	:= Upper(Alltrim(_nomeuser))
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Mensagem para Cliente 015966-01 - ST ESPECIAL RJ
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Tratamento para novos pedidos
		If M->C5_CLIENTE == "015966" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "MVA cobrado em 53% por meio dos Mandados de Segurança: NR: 0060128-35.2010.8.19.0000 e NR: 0060127-50.2010.8.19.0000”
		EndIf

		// Tiago Rossini Coradini - 14/03/16 - OS: 0039-16 - Mayara Pimentel - Gravar mensagem especial para o Cliente: 012366 - HOME CENTER TENDTUDO
		If M->C5_CLIENTE == "012366" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "O ICMS devido por substituição tributária será recolhido pelo destinatário até o dia 15 do mês subsequente - Procedimento autorizadopela SEFAZ - SP - Regime Especial - Processo UA 13456-581479-2008"
		EndIf	

		//OS 0599-17 - Ranisses 24/02/17
		If M->C5_CLIENTE == "016443" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Não incidência de ICMS-ST conforme portaria 22-R/2018."
		EndIf
		
		//Ticket 21283
		If M->C5_CLIENTE == "029017" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Contribuinte credenciado para não-antecipação do ICMS – Processo 13953020195, Parecer final 11.792/2019."
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Mensagem para Cliente 022909 - OS 3201-15
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If M->C5_CLIENTE == "022909" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENPAD := "075"
		EndIf

		If Substr(SA1->A1_CGC,1,8) == "03840986" .And. SA1->A1_EST == "SP" .And. !(M->C5_TIPO $ "D_B") //Ticket 22020 - Marcus V. S. Nascimento 11/02/20
			M->C5_MENPAD := "096"
		EndIf	
		
		If Substr(SA1->A1_CGC,1,8) == "63004030" .And. SA1->A1_EST == "SP" .And. !(M->C5_TIPO $ "D_B") //Ticket 22299 //Ticket 7411
			M->C5_MENPAD := "088"
		EndIf

		//Ticket 7533
		If M->C5_CLIENTE == "027675" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENPAD := "089"
		EndIf

		// Tiago Rossini Coradini - 17/10/16 - OS: 3041-16 - Mayara Pimentel - Tratamento de mensagem especial do cliente 024318
		If M->C5_CLIENTE == "024318" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENPAD := "084"
		EndIf 

		// //Ticket 18884 - Barbara Luan Gomes Coelho 15/10/19
		If M->C5_CLIENTE == "018591" .And. !(M->C5_TIPO $ "D_B") .And. M->C5_EMISSAO <= STOD('20191231')
			M->C5_MENPAD := "093"
		EndIf 

		If M->C5_CLIENTE == "026643" .And. !(M->C5_TIPO $ "D_B")			
			M->C5_MENNOTA := "Destinatário eleito substituto tributário - conforme Termo de Acordo n° 2018/13965-0 - Art. 680, VI do Decreto nº 21.400/2002 RICMS/SE.”			
		EndIf

		If M->C5_CLIENTE == "012366" .And. !(M->C5_TIPO $ "D_B")			
			M->C5_MENNOTA := "O ICMS devido por substituição tributária será recolhido pelo destinatário até o dia 15 do mês subsequente - Procedimento autorizado pela SEFAZ - SP - Regime Especial Eletrônico: 22454/2016”
		EndIf	
		
		//Ticket 27097 - Pablo S Nascimento 30/09/2020
		If M->C5_CLIENTE == "017111" .And. !(M->C5_TIPO $ "D_B")			
			M->C5_MENNOTA := "O ICMS devido por substituição tributária será recolhido pelo destinatário– Procedimento Autorizado pela SEFAZ-BA art. 7-B, decreto 7.799/2020 – TERMO DE ACORDO Parecer n 6.491/2020”
		EndIf	
		
		//Ticket 26534 - Pablo S. Nascimento 04/09/20
		If M->C5_CLIENTE $ "029206_029207" .And. !(M->C5_TIPO $ "D_B")			
			M->C5_MENNOTA := "O ICMS devido por substituição tributária será recolhido pelo destinatário até o dia 15 do mês subsequente – Procedimento Autorizado pela SEFAZ - SP – Regime Especial Eletrônico: 26.209/2017."
		EndIf

		//Ticket 10402 - Barbara Luan Gomes Coelho 07/12/18 + //Ticket 22212 - Pablo S. Nascimento 11/02/2020
		If M->C5_CLIENTE $ "021896_001178_015943_016677_019784_019786_019788_019790_019792_019794_025604" .And. !(M->C5_TIPO $ "D_B") .And. (Alltrim(M->C5_YSUBTP) != "A") 
			M->C5_MENNOTA := "Fica dispensada a retenção e recolhimento do ICMS por substituição tributária, nos termos do Regime Especial (MG) E-PTA-RE n.° 45.000015112-38."
		EndIf	
		
		//Ticket 13512 - Barbara Luan Gomes Coelho 18/03/19
		If M->C5_CLIENTE == "017362" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Não recolhimento do ICMS ST conf. Artigo 426-A, Parag. 4, Item 2 do RICMS/SP."
		EndIf

		//Ticket 16184 - Barbara Luan Gomes Coelho 25/06/19
		If M->C5_CLIENTE == "028869" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "NFE foi emitida em conformidade com o Regime Especial de Tributação - TTS - E-PTA-RE número 45.000013155-44 de 06/03/2018 concedido à empresa Shoppiso Ltda"
		EndIf 

		//Ticket 17978 - Barbara Luan Gomes Coelho 29/08/19
		If M->C5_CLIENTE == "008904" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "ICMS devido por subst trib nos termos do art 426a do RICMS-SP/2000 será rec pelo dest até o dia 15 do mês subsequente ao da ent da merc . proced. aut SEFAZ SP Reg Especial eltro n. 620/15"
		EndIf 

		//Ticket 18036 - Barbara Luan Gomes Coelho 02/09/19
		If M->C5_CLIENTE == "008911" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Entrega depósito fechado CNPJ - 25.618.174/0003-05 INSC.EST. 062.017.715-01-72 Rua Antônio José de Carvalho, Nº440, BAIRRO - Caiçara"
		EndIf 

		//Ticket 18038 - Barbara Luan Gomes Coelho 02/09/19
		If M->C5_CLIENTE == "004982" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Entrega depósito fechado CNPJ - 24.839.226/0001-49 INSC.EST. 002.763.543.00-41"
		EndIf 

		//Ticket 18141 - Barbara Luan Gomes Coelho 05/09/19
		If M->C5_CLIENTE == "029106" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Dispensado da retenção do ICMS por substituição tributária, conforme E-PTA-RE nº 45.000013167-96"
		EndIf 

		//Ticket 20431 - Barbara Luan Gomes Coelho 03/12/19
		If M->C5_CLIENTE == "029042" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Dispensa de retenção do ICMS substituição tributária, conforme termo de acordo/ processo e201902012-2"
		EndIf 
		
		//Thiago Haagensen - Ticket 25853 - Inclusão de endereço cliente.
		If M->C5_CLIENTE == "017361" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Entrega depósito fechado CNPJ - 05.621.609/0002-82 INSC.EST. 082.796.9-3 Mercantil Molina Ltda EPP – Filial - Av. Alegre, 1606 – Bairro Shell – Linhares-ES - CEP 29.901-600"
		EndIf 
		
		//Ticket 29524 - Barbara Luan Gomes Coelho 18/01/21
		If M->C5_CLIENTE == "001124" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "O ICMS devido por substituição tributária será recolhido pelo destinatário – Regime Especial PTA 45.000019084-05/2020"
		EndIf 
		
		//Ticket 29536 - Barbara Luan Gomes Coelho 18/01/21
		If M->C5_CLIENTE == "031646" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Dispensado destaque do ICMS ST - destinatário com Regime Especial (MG) E-PTA-RE N.° 45.000021720-54"
		EndIf 
		
		//Ticket 30916 - Pablo S Nascimento 16/03/2021
		If M->C5_CLIENTE == "031859" .And. !(M->C5_TIPO $ "D_B")
			M->C5_MENNOTA := "Dispensado destaque do ICMS ST - destinatário com Regime Especial (MG) E-PTA-RE N.° 45.000021147-12 Prazo de Validade Indeterminado"
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Mensagem Padrao p/ REVIX - BIANCOGRES/LM OS 1079-14
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Alltrim(cempant) $ "01_07" .And. M->C5_CLIENTE == "017151"
			If Alltrim(M->C5_YSUBTP) $ "N_E" 		//Normal e Especial - MENSAGEM MERCADO INTERNO
				M->C5_MENPAD	:= "069"
			ElseIf Alltrim(M->C5_YSUBTP) == "FE" 	//Exportacao - MENSAGEM MERCADO EXTERNO
				M->C5_MENPAD	:= "070"
			EndIf
		EndIf


		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Mensagem Padrao para Vendas LM 
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Alltrim(cempant) $ "01_05_13" .And. M->C5_CLIENTE == "010064" //ALTERAÇÃO EM 26/10/2015 - OS 3844-15

			If Alltrim(cEmpAnt) == "01" .And. Alltrim(M->C5_YSUBTP) == "N" //Biancogres p/ LM venda Normal
				M->C5_MENPAD	:= "076"
			ElseIf Alltrim(cEmpAnt) == "05" .And. Alltrim(M->C5_YSUBTP) == "N" //Incesa p/ LM venda Normal
				M->C5_MENPAD	:= "077"
			ElseIf Alltrim(cEmpAnt) == "13" .And. Alltrim(M->C5_YSUBTP) == "IM" //Mundi p/ LM venda Importado
				M->C5_MENPAD	:= "078"
			ElseIf Alltrim(cEmpAnt) == "13" .And. Alltrim(M->C5_YSUBTP) == "A" //Mundi p/ LM venda de Amostra
				M->C5_MENPAD	:= "001"    
			EndIf

			//ESTA OPCAO FOI DESATIVADA DO PEDIDO DE VENDA E SERA UTILIZADA NO SF2460I
			//Atualiza Incremento Vencimento
			//M->C5_YPRZINC	:= 7 //SOLICITACAO DO SR. DIOGO E VAGNER NO DIA 23/06/09
		EndIf

		/*ROTINA FOI SUBSTITUIDA PELO BLOCO ACIMA
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Mensagem Padrao para Mundi
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Alltrim(cempant) == "13" .And. M->C5_CLIENTE == "010064"
		If Alltrim(M->C5_YSUBTP) == "IM"				//Venda Norma Importado
		M->C5_MENPAD	:= "058"
		ElseIf Alltrim(M->C5_YSUBTP) == "A"				//Venda Amostra
		M->C5_MENPAD	:= "001"
		EndIf
		EndIf
		*/

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Mensagem Padrao para Almostra LM
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Alltrim(cempant) == "07" .And. Alltrim(M->C5_YSUBTP) == "A"		//Venda Amostra
			If (M->C5_YLINHA == '6')
				M->C5_MENPAD	:= "094"
			Else
				M->C5_MENPAD	:= "059"
			EndIf	
		EndIf

		//Ticket 4786 - Pedro Henrique 08/01/2019 
		If (Inclui)
			cCategoria := Posicione("SA1", 1, xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI ,"A1_YCAT")
			If (AllTrim(M->C5_YSUBTP) == "A" .And. AllTrim(cCategoria) == 'LOJA ESPEC')
				M->C5_YOBS += CHR(13)+CHR(10)+"Amostra para Loja Especializada"
			EndIf	
		EndIf


		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±FACIL±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Grava Mensagem Padrao no Pedido de Venda //Implementado por Ranisses em 21/07/09 para NFE
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Empty(Alltrim(M->C5_MENPAD))

			Do Case
				Case xTpCli == 'F' .And. xEstCli <> 'MG' .And. Alltrim(SC5->C5_YSUBTP) == 'N'
				xMenPad	:= "028"
				Case xTpCli == 'F' .And. xEstCli == 'MG' .And. Alltrim(SC5->C5_YSUBTP) == 'N'
				xMenPad	:= "027"
			EndCase

			M->C5_MENPAD := xMenPad
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Verifica se o Pedido deve ser submetido a rotina fBloqPV
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If nOpcao == 1 //Inclusao
			Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), motivo: inclusão, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
			lCheckPV := .T.
		ElseIf nOpcao == 2 //Alteracao
			//Armazena informacoes do PV ja gravado para comparar com o aCols
			wwArea := ALIAS()
			dbSelectArea("SC6")
			wwOrdem := INDEXORD()
			wwPosReg := RECNO()
			aColsBck 	:= {}
			___nLenCols	:= 0
			
			dbSetOrder(1)
			If dbSeek(xFilial("SC6")+M->C5_NUM,.F.)
				While !EOF() .AND. M->C5_NUM == SC6->C6_NUM .AND. (XFILIAL("SC5") == SC6->C6_FILIAL)
					AADD(aColsBck, {SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_YDESC,SC6->C6_LOTECTL,SC6->C6_VALDESC,SC6->C6_YDESP})
					
					If (SC6->C6_BLQ != 'R') //não pega residuo
						___nLenCols += 1
					EndIf
					 
					dbSkip()
				EndDo
			Else
				MsgBox("Não foi possível localizar o itens do pedido: "+M->C5_NUM,"Erro!","STOP")
				//Conout("M410AGRV APROVAÇÃO => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: Não foi possível localizar o itens do pedido " + M->C5_NUM + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .F.
			EndIf
			dbSetorder(wwOrdem)
			dbGoto(wwPosReg)
			dbSelectArea(wwArea)
			
			//Verifica o que esta diferente no PV para submeter a aprovacao novamente
			For I := 1 To Len(aCols)

				//Verifica alteracao no PRODUTO - Submete a rotina de bloqueio
				If Len(aColsBck) >= I
					If aCols[I][2] <> aColsBck[I][2]
						Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: aCols[I][2] <> aColsBck[I][2] " + aCols[I][2] + " e " + aColsBck[I][2] + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
						lCheckPV := .T.
						Exit
					Else
						lCheckPV := .F.
					EndIf
				Else
					Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: Len(aColsBck) < I " + Str(Len(aColsBck)) + " e " + Str(I) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
					lCheckPV := .T.
					Exit
				EndIf

				//Verifica alteracao no DESCONTO - Submete a rotina de bloqueio
				If Gdfieldget('C6_YDESC',I)  <> aColsBck[I][3]
					Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: Gdfieldget('C6_YDESC',I)  <> aColsBck[I][3] " + Str(Gdfieldget('C6_YDESC',I)) + " e " + Str(aColsBck[I][3]) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
					lCheckPV := .T.
					Exit
				EndIf

				//Verifica alteracao no DESCONTO INCONDICIONAL - Se preenchido realiza bloqueio
				If Gdfieldget('C6_VALDESC',I) <> aColsBck[I][5]
					Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: Gdfieldget('C6_VALDESC',I) <> aColsBck[I][5] " + Str(Gdfieldget('C6_VALDESC',I)) + " e " + Str(aColsBck[I][5]) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
					lCheckPV := .T.
					Exit
				EndIf

				//Verifica alteracao no campo %Outros 
				If Gdfieldget('C6_YDESP',I) <> aColsBck[I][6]
					Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: Gdfieldget('C6_YDESP',I) <> aColsBck[I][6] " + Str(Gdfieldget('C6_YDESP',I)) + " e " + Str(aColsBck[I][6]) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
					lCheckPV := .T.
					Exit
				EndIf			

			Next
			
			
			
			//Verifica alteracao no FATOR FINANCEIRO - Submete a rotina de bloqueio
			nFatorFinMem := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_YMEDIA")
			nFatorFinGrv := Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_YMEDIA")
			If nFatorFinGrv <> nFatorFinMem
				Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: nFatorFinGrv <> nFatorFinMem " + Str(nFatorFinGrv) + " e " + Str(nFatorFinMem) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .T.
			EndIF
			If SC5->C5_YMAXCND <> M->C5_YMAXCND
				Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: SC5->C5_YMAXCND <> M->C5_YMAXCND " + Str(SC5->C5_YMAXCND) + " e " + Str(M->C5_YMAXCND) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .T.
			EndIF
			
			If (___nLenCols != Len(aCols))
				Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: __nLenCols != Len(aCols), thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .T.
			EndIf
			

			//Se for Condição de Pagamento Tipo 9 por Valor
			cTipoCond 	:= Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_TIPO")
			cVlrCond 	:= Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_COND")

			// Verifica se houve alteração nas parcelas              
			If AllTrim(cTipoCond) == '9' .And. AllTrim(cVlrCond) == '0'

				nNumParc := 0
				nMaxParc := GetMv("MV_NUMPARC", .F., 12)
				cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"

				For nNumParc := 1 To nMaxParc

					cCampoParc := "C5_PARC" +Subs(cParcela,nNumParc,1)
					cCampoDat  := "C5_DATA" +Subs(cParcela,nNumParc,1)

					If SC5->&(cCampoParc) <> M->&(cCampoParc) .Or. SC5->&(cCampoDat) <> M->&(cCampoDat)
						Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: SC5->&(cCampoParc) <> M->&(cCampoParc) .Or. SC5->&(cCampoDat) <> M->&(cCampoDat) " + SC5->&(cCampoParc) + " e " + M->&(cCampoParc) + " e " + SC5->&(cCampoDat) + " e " + M->&(cCampoDat) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
						lCheckPV := .T.	
					EndIf	

				Next

			EndIf

			//Verifica alteracao na LINHA - Submete a rotina de bloqueio
			If SC5->C5_YLINHA <> M->C5_YLINHA
				Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: SC5->C5_YLINHA <> M->C5_YLINHA " + SC5->C5_YLINHA + " e " + M->C5_YLINHA + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .T.
			EndIf

			//Verifica alteracao no TIPO PEDIDO - Se preenchido com Bonficacao, Doacao, Feiras e Garantia, realiza bloqueio
			If SC5->C5_YSUBTP <> M->C5_YSUBTP
				Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: SC5->C5_YSUBTP <> M->C5_YSUBTP " + SC5->C5_YSUBTP + " e " + M->C5_YSUBTP + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .T.
			EndIf

			//Verifica alteracao na DATA INCREMENTO - Se preenchido realiza bloqueio
			If SC5->C5_YDTINC <> M->C5_YDTINC
				lCheckPV := .T.
			EndIf

			//Verifica alteracao DIAS INCREMENTO - Se preenchido realiza bloqueio
			If SC5->C5_YPRZINC <> M->C5_YPRZINC
				Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: SC5->C5_YPRZINC <> M->C5_YPRZINC " + Str(SC5->C5_YPRZINC) + " e " + Str(M->C5_YPRZINC) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .T.
			EndIf

			//Verifica se o pedido está sem aprovador e submete novamente para aprovação
			If Alltrim(SC5->C5_YAAPROV) == "SEM LIBERADOR"
				Conout("M410AGRV APROVAÇÃO PEDIDO " + M->C5_NUM + " => (" + Iif(nOpcao==1,"INCLUSÃO",Iif(nOpcao==2,"ALTERAÇÃO","EXCLUSÃO")) + "), Motivo: Alltrim(SC5->C5_YAAPROV) == SEM LIBERADOR " + Alltrim(SC5->C5_YAAPROV) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
				lCheckPV := .T.
			EndIf

		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//GRAVA COMISSAO ZERO E VEND1 999999 PARA PEDIDOS DE VENDA DA LM PARA FARBICA
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Alltrim(cempant) $ "01_05_13" .And. 	M->C5_CLIENTE == "010064"
			M->C5_VEND1		:= "999999"
			M->C5_VEND2		:= ""
			M->C5_VEND3		:= ""
			M->C5_VEND4		:= ""
			M->C5_VEND5		:= ""
			M->C5_COMIS1	:= 0
			M->C5_COMIS2	:= 0
			M->C5_COMIS3	:= 0
			M->C5_COMIS4	:= 0
			M->C5_COMIS5	:= 0
		EndIf

		//Procura o Cliente
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.T.)

		//Atualiza os itens do Pedido
		If cEmpAnt <> "02"
			For i := 1 to Len(aCols)
				If !GdDeleted(i)

					nProd	:= Gdfieldget("C6_PRODUTO",i)
					nLote	:= Gdfieldget('C6_LOTECTL',i)

					//Grava o Campos
					//Desconto

					//Fernando/Facile em 17/08/15 - Nova Politica Comercial - Tratamento de descontos estao nos fonte TBiaPolitica e BPOLGA01
					/*If Inclui
					Gdfieldput("C6_YDESCLI",U_fBuscaDesconto(M->C5_VEND1,SA1->A1_SATIV1,M->C5_CLIENTE,SA1->A1_GRPVEN,nProd,nLote,Dtos(M->C5_EMISSAO),M->C5_YLINHA),i)
					Else
					If Empty(Alltrim(Gdfieldget("C6_YREGRA",i)))
					Gdfieldput("C6_YDESCLI",U_fBuscaDesconto(M->C5_VEND1,SA1->A1_SATIV1,M->C5_CLIENTE,SA1->A1_GRPVEN,nProd,nLote,Dtos(M->C5_EMISSAO),M->C5_YLINHA),i)
					EndIf
					EndIf*/

					//Grava Margem para produtos Classe A
					If Substr(nProd,8,1) == "1"
						aMargem	:= U_fBuscaMargem(M->C5_VEND1,SA1->A1_SATIV1,M->C5_CLIENTE,SA1->A1_GRPVEN,Substr(nProd,1,2),Substr(nProd,8,1),nProd,nLote,Dtos(M->C5_EMISSAO),M->C5_YLINHA)
						Gdfieldput("C6_YMRGCLI",aMargem[1],i)
						Gdfieldput("C6_YREGMRG",aMargem[2],i)
					EndIf

					If M->C5_TIPO <> "N"
						Gdfieldput("C6_YPRCTAB",Gdfieldget("C6_PRCVEN",i),i)
					EndIf

					//Armazena totais dos Impostos para gravação no SC5
					nTotPIS		:= nTotPIS 	  + Gdfieldget("C6_YVLTPIS",i)							
					nTotCOFINS	:= nTotCOFINS + Gdfieldget("C6_YVLTCOF",i)											
					nTotICMS	:= nTotICMS   + Gdfieldget("C6_YVLTICM",i)
					nTotIPI		:= nTotIPI	  + Gdfieldget("C6_YVLTIPI",i)
					nTotDesZF	:= nTotDesZF  + Gdfieldget("C6_YDESCZF",i)
					nTotST		:= nTotST	  + Gdfieldget("C6_YVLTST" ,i)
					nTotPed		:= nTotPed    + Gdfieldget("C6_YVLIMP" ,i)											

					//Grava informações referente ao flags do 
					Gdfieldput("C6_YEMP"   ,M->C5_YEMP,i)
					Gdfieldput("C6_YEMPPED",M->C5_YEMPPED,i)
					Gdfieldput("C6_YRESULT",M->C5_YRESULT,i)
					Gdfieldput("C6_YRESUL2",M->C5_YRESUL2,i)
					Gdfieldput("C6_YEMISSA",M->C5_EMISSAO,i)

					//Ajusta Itens Comissão
					//Grava comissao zero para os Pedidos de Venda LM
					If Alltrim(cempant) $ "01_05_13" .And. 	M->C5_CLIENTE == "010064" 

						ConOut("M410AGRV => ACERTA COMISSAO CLIENTE LM")

						Gdfieldput("C6_COMIS1",0,i)
						Gdfieldput("C6_COMIS2",0,i)
						Gdfieldput("C6_COMIS3",0,i)
						Gdfieldput("C6_COMIS4",0,i)
						Gdfieldput("C6_COMIS5",0,i)
					
					Else
						
						Gdfieldput("C6_COMIS1",M->C5_COMIS1,i)
						Gdfieldput("C6_COMIS2",M->C5_COMIS2,i)
						Gdfieldput("C6_COMIS3",M->C5_COMIS3,i)
						Gdfieldput("C6_COMIS4",M->C5_COMIS4,i)
						Gdfieldput("C6_COMIS5",M->C5_COMIS5,i)

						//Posiciona no Produto
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1")+nProd))

						//Acrescimo de Comissão - 17/04/13 - RANISSES
						If SB1->B1_YACRCOM <> 0
							If Gdfieldget("C6_COMIS1",i) <> 0
								Gdfieldput("C6_COMIS1",M->C5_COMIS1+SB1->B1_YACRCOM,i)
							EndIf
							If Gdfieldget("C6_COMIS2",i) <> 0
								Gdfieldput("C6_COMIS2",M->C5_COMIS2+SB1->B1_YACRCOM,i)
							EndIf
							If Gdfieldget("C6_COMIS3",i) <> 0
								Gdfieldput("C6_COMIS3",M->C5_COMIS3+SB1->B1_YACRCOM,i)
							EndIf
							If Gdfieldget("C6_COMIS4",i) <> 0
								Gdfieldput("C6_COMIS4",M->C5_COMIS4+SB1->B1_YACRCOM,i)
							EndIf
							If Gdfieldget("C6_COMIS5",i) <> 0
								Gdfieldput("C6_COMIS5",M->C5_COMIS5+SB1->B1_YACRCOM,i)
							EndIf
						EndIf

						//Comissão variavel - Linha Vitoria - 11/12/09 - WANISAY
						If SB1->B1_YPERCOM <> 0
							Gdfieldput("C6_COMIS1",M->C5_COMIS1+(M->C5_COMIS1*SB1->B1_YPERCOM/100),i)
							Gdfieldput("C6_COMIS2",M->C5_COMIS2+(M->C5_COMIS2*SB1->B1_YPERCOM/100),i)
							Gdfieldput("C6_COMIS3",M->C5_COMIS3+(M->C5_COMIS3*SB1->B1_YPERCOM/100),i)
							Gdfieldput("C6_COMIS4",M->C5_COMIS4+(M->C5_COMIS4*SB1->B1_YPERCOM/100),i)
							Gdfieldput("C6_COMIS5",M->C5_COMIS5+(M->C5_COMIS5*SB1->B1_YPERCOM/100),i)
						EndIf

						//Comissão Mundiali
						If SB1->B1_COMIS <> 0
							If Gdfieldget("C6_COMIS1",i) <> 0
								Gdfieldput("C6_COMIS1",SB1->B1_COMIS,i)
							EndIf
							Gdfieldput("C6_COMIS2",0,i)
							Gdfieldput("C6_COMIS3",0,i)
							Gdfieldput("C6_COMIS4",0,i)
							Gdfieldput("C6_COMIS5",0,i)
						EndIf

					EndIf

					//Grava variavel de desconto %Outros
					If nDesp == 0 .And. Gdfieldget('C6_YDESP',i) > 0
						nDesp	:= Gdfieldget('C6_YDESP',i) 
					EndIf
					
					//Ticket 23754
					//grupo Leroy Merlin 001486
					If(AllTrim(SA1->A1_GRPVEN) == "001486" .And. !Empty(M->C5_YPC))
						Gdfieldput("C6_NUMPCOM",M->C5_YPC,i)
						Gdfieldput("C6_ITEMPC",AllTrim(STR(i)),i)
					EndIf

				EndIf
			Next
		EndIf

		//Grava os valores totais dos impostos no cabeçalho
		M->C5_YVLTICM := nTotICMS
		M->C5_YVLTPIS := nTotPIS
		M->C5_YVLTCOF := nTotCOFINS
		M->C5_YVLTIPI := nTotIPI      
		M->C5_YDESCZF := nTotDesZF          
		M->C5_YVLTST  := nTotST
		M->C5_YVLTOTP := nTotPed	

		//Limpa Observação, caso não tenha sido utilizado o desconto %Outros
		If SC5->(FieldPos("C5_YOBDCOU")) > 0 .And. nDesp == 0 .And. !Empty(Alltrim(M->C5_YOBDCOU))	
			M->C5_YOBDCOU := ""
		EndIf

	EndIf

	//Exclusao de pedido
	If nOpcao == 3 .And. !Empty(M->C5_YNUMSI) .And. !(AllTrim(CEMPANT) $ '14')
		//Verificar se existe baixa de AI do pedido e excluir a baixa
		U_AIEXCBX(M->C5_NUM, M->C5_YLINHA, M->C5_YNUMSI, M->C5_CLIENTE, M->C5_YEMPPED)
	EndIf

	If SC6->(FieldPos("C6_YDAI")) > 0 .And. nOpcao == 3 .And. !Empty(M->C5_YNOUTAI) .And. !(AllTrim(CEMPANT) $ '14')
		//Verificar se existe baixa de AI do pedido e excluir a baixa
		U_AIEXCBX(M->C5_NUM, M->C5_YLINHA, M->C5_YNOUTAI, M->C5_CLIENTE, M->C5_YEMPPED)
	EndIf

	// Tiago Rossini Coradini - 08/11/2016 - OS: 4060-15 - Claudeir Fadini - Workflow de alteração de data de necessidade de engenharia
	U_BIAF037()

	//Retira caracteres especiais da Observação da NF - Problema na NF 4.0
	If !Empty(Alltrim(M->C5_MENNOTA))
		M->C5_MENNOTA := U_fDelTab(M->C5_MENNOTA)
	EndIf

Return
