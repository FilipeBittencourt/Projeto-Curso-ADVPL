#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

//C5_YLINHA - EMPRESA do pedido.
#define _BIANCOGRES '1'
#define _INCESA 	'2'
#define _BELLACASA 	'3'
#define _MUNDI 		'4'
#define _PEGASSUS	'5
#define _VINILICO	'6'


/*/{Protheus.doc} MTA410
@author Microsiga Vitoria
@version 1.0
@description Executa diversas validações no Pedido de Venda, inclusive validação de Crédito.
@history 04/11/2016, Ranisses A. Corona, Correção e melhorias na gravação do valor dos impostos por item. OS: 4052-16 Mayara Trigueiro / 3888-16 Elaine Sales
@type function
/*/


User Function MTA410()
	Local lRet					:= .T.
	Local nRet					:= "00"
	Local cSql					:= ""
	Local Enter					:= CHR(13)+CHR(10)
	Local TOTAL_RA				:= 0
	Local TOTAL_PEDIDO			:= 0
	Local TOTAL_ABERTO			:= 0
	Local I						:= 0
	Local nTpSeg				:= ""
	Local nProd					:= ""
	Local nDesc					:= ""
	Local cEst					:= ""
	Local cMun					:= ""
	Local nGrupo				:= ""

	Local cArq 					:= ""
	Local cInd 					:= 0
	Local cReg 					:= 0
	Local nCont

	Local cArqSA1 				:= ""
	Local cIndSA1 				:= 0
	Local cRegSA1 				:= 0

	Private nMaxParcela	     	:= GetMv("MV_NUMPARC", .F., 12)
	Private cParcela			:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
	Private nParcMin			:= GetMv("MV_YVRPARM", .F., 4000)
	Private nDescInc            := 0 // Por Marcos Alberto Soprani para auxiliar na integração com a validação da CLVL - BIA555

	//MSGALERT("MTA410")
	
	IF  !u_VALIDQTDPC()
		Return .F.
	Endif	

	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
		Return(.T.)
	EndIf

	//Tratamento especial para Reajuste de preço
	If (IsInCallStack("U_M410RPRC")) .And. SC6->(FieldPos("C6_YPREAJU")) > 0
		Return(.T.)
	EndIf

	//OS 3494-16 - Tania c/ aprovação do Fabio
	If cEmpAnt == "02"
		Return(.T.)
	EndIf

	If IsInCallStack("U_JOBFATPARTE") .And. IsBlind()

		Return(.T.)

	EndIf

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SA1")
	cArqSA1 := Alias()
	cIndSA1 := IndexOrd()
	cRegSA1 := Recno()

	//Posiciona no Cliente
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.T.)

	If Alltrim(M->C5_YFLAG) == "2"
		If Empty(Alltrim(M->C5_YEND)) .Or. Empty(Alltrim(M->C5_YBAIRRO)) .Or. Empty(Alltrim(M->C5_YCODMUN)) .Or. Empty(Alltrim(M->C5_YMUN)) .Or. Empty(Alltrim(M->C5_YEST)) .Or. Empty(Alltrim(M->C5_YCEP))
			Msgbox("Favor verificar o preenchimento de todos os campos do Local Entrega!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf

	//Só permite alteração do campo C5_YCONF, se o pedido de Engenharia estiver liberado pelo Crédito
	If Alltrim(M->C5_YTPCRED) == "5" .And. Alltrim(M->C5_YCRDENG) == "03" .And. M->C5_YCONF == "S"
		Msgbox("Este pedido de Engenharia está aguardando liberação do Setor de Crédito e Cobrança. Só será possivel alterar o campo Conferido, após aprovação do pedido!","MTA410","STOP")
		Return(.F.)
	EndIf

	//Só permite alteração do campo C5_YCONF, se o pedido de Contrato estiver liberado pelo Crédito
	If Alltrim(M->C5_YTPCRED) == "2" .And. ALTERA .And. U_fVlApCT(M->C5_NUM) .And. M->C5_YCONF == "S"
		Msgbox("Este pedido de Contrato está aguardando liberação do Setor de Crédito e Cobrança. Só será possivel alterar o campo Conferido, após aprovação do pedido!","MTA410","STOP")
		Return(.F.)
	EndIf


	//Permite o uso do Pedido Original uma UNICA VEZ para a chave PEDIDO ORIGINAL + EMPRESA PEDIDO //RANISSES EM 10/09/2015  
	If cEmpAnt == "07" .And. !Empty(Alltrim(M->C5_YPEDORI))

		cSql := "SELECT COUNT(*) QUANT FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = "+xFilial("SC5")+" AND C5_YPEDORI = '"+M->C5_YPEDORI+"' AND C5_YEMPPED = '"+M->C5_YEMPPED+"' AND D_E_L_E_T_ = '' "
		If Select("_RAC") > 0
			_RAC->(DbCloseArea())
		EndIf
		TCQUERY cSql ALIAS "_RAC" NEW

		If _RAC->QUANT > 1
			nEmpPed := Iif(M->C5_YEMPPED=="01","Biancogres","Incesa")	
			Msgbox("O Pedido Origem "+M->C5_YPEDORI+" já foi utilizado na empresa "+nEmpPed+". Favor verificar antes de continuar.","MTA410","STOP")
			Return(.F.)
		EndIf

		_RAC->(DbCloseArea())

	EndIf


	// Tiago Rossini Coradini - 19/10/15 - OS: 3245-15 - Tatiane Karina - Valida os campos de cliente e cliente entrega.
	If M->C5_CLIENTE <> M->C5_CLIENT
		MSGBOX("Favor conferir o campo Cliente Entrega, o mesmo está diferente do campo Cliente.","MTA410","STOP")
		Return(.F.)
	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//FACILE/FERNANDO - Projeto Pedido Representante - Validar as Classe de Valor/Item Contabil apos a Conferencia do pedido pela Atendente
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//BLOCO TRANSCRITIO DO PONTO DE ENTRADA M410LIOK ONDE FOI COMENTADO
	nDescInc	:= 0
	//IF !cEmpAnt $ "02_13_14" .And. M->C5_YCONF == "S"//Nao executa esta regra para Ceramica Incesa e Mundi. Empresa14 - tratamento feito por Marcos Alberto Soprani em 18/09/13
	IF !cEmpAnt $ "02_13_14" .And. M->C5_YCONF == "S" .And. M->C5_TIPO <> "D"  //Adicionado a regra para o tipo de Devolução. - Carlos Junqueira  O.S 1785-16
		FOR I := 1 TO LEN(ACOLS)
			nDescInc	:= Gdfieldget("C6_VALDESC",I)		//Desconto Incondicional
			nProd		:= Gdfieldget("C6_PRODUTO",I)
			nCFOP		:= Gdfieldget("C6_CF",I)

			// Ajuste efetua por Marcos Alberto Soprani para atender ao projeto de controle de Classe de Valor. Alinhado com Jean dos impactos desta alteração:
			// segundo Jean e demais da Contabilidade, atualmente as demais vendas estão sendo direcionadas para uma conta da BAS(416) bem com os impostos.
			//If (Alltrim(nCFOP) $ "5910/5911/5912/5914/5949/6910/6911/6912/6914/6949" .OR. Alltrim(nProd) < 'A' .Or. nDescInc > 0 ) .AND. EMPTY(M->C5_YCLVL)
			// Retirado por Marcos Alberto Soprani em 24/06/15 a pedido do Jean que definiu que toda venda os impostos irão para contas BAS(415)
			//If (Alltrim(nCFOP) $ "5910/5911/5912/5914/5949/6910/6911/6912/6914/6949" .Or. nDescInc > 0 ) .AND. EMPTY(M->C5_YCLVL)
			If nDescInc > 0 .AND. EMPTY(M->C5_YCLVL)
				Alert("A Classe de Valor devera ser informada. Favor verificar procedimento com Setor Contabil.", "MTA410")
				Return(.F.)
			EndIf
		NEXT
	ENDIF

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//ROTINA PARA VERIFICAR SE A TRANSPORTADORA ESTA CORRETA
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If !Alltrim(M->C5_TPFRETE) == "S" //Diferente de "S", TEM que informar Transportadora
		If Empty(Alltrim(M->C5_TRANSP)) .Or. Alltrim(Posicione("SA4",1,xFilial("SA4")+M->C5_TRANSP,"A4_COD")) == ""
			Msgbox("Transportadora não informada ou está incorreta!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf

	If Alltrim(M->C5_TPFRETE) == "S" //Igual a "S", NAO TEM Transportadora
		If !Empty(Alltrim(M->C5_TRANSP))
			Msgbox("Para o campo Tipo Frete igual a 'S', a Transportadora não poderá ser informada!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf

	If cEmpAnt $ ("01_05_13")
		If Alltrim(M->C5_CLIENTE) == "010064"
			If !Empty(Alltrim(M->C5_TRANSP)) .Or. !Alltrim(M->C5_TPFRETE) == "S"
				Msgbox("O campo Transportadora deve estar vazio e o campo Tipo Frete preenchido com 'S'!","MTA410","STOP")
				Return(.F.)
			EndIF
		EndIF
	EndIF

	//Fernando/Facile em 17/10/2014 - Projeto Acordo de Objetivos
	If cEmpAnt $ ("01_05_07_13")
		If Alltrim(M->C5_YITEMCT) == "I0201" .And. Empty(M->C5_YNUMSI)
			Msgbox("O campo 'Numero SI' deve se preenchido para pedidos de Acordo de Objetivos!","MTA410","STOP")
			Return(.F.)
		EndIF
	EndIF


	//Fernando/Facile em 25/07/2016 - Projeto Contratos de Verba
	If cEmpAnt $ ("01_05_07_13")

		If SC5->(FieldPos("C5_YCTRVER")) > 0 

			If Alltrim(M->C5_YITEMCT) == "I0202" .And. ( U_FCTVCHEK() ) .And. Empty(M->C5_YCTRVER)
				Msgbox("O campo 'Ctr. Verba' deve se preenchido para pedidos de Verbas Contratuais!","MTA410 - NUMERO DO CONTRATO DE VERBA","STOP")
				Return(.F.)
			EndIf

			If !Empty(M->C5_YCTRVER) .And. !( Alltrim(M->C5_YITEMCT) == "I0202" )
				Msgbox("O campo 'Ctr. Verba' somente pode ser preenchido para pedidos com item contabil I0202!","MTA410 - NUMERO DO CONTRATO DE VERBA","STOP")
				Return(.F.)
			EndIf

		EndIf

	EndIF


	//Valida digitação do Item Contabil na Empresa JK, nas vendas para a empresa Biancogres e Incesa
	//Solicitado pela Tânia e Fabiana no dia 02/09/14 conforme effettivo.
	//If cEmpAnt == "06" .And. Alltrim(M->C5_TIPO) == "N" .And. M->C5_CLIENTE $ ("000481_004536") .And. Empty(Alltrim(M->C5_YITEMCT))
	//	Msgbox("Nas vendas para as Empresa Biancogres e Incesa, é necessário preencher o campo Item Contabil.","MTA410","STOP")
	//	Return(.F.)
	//EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Grava o Valor Total do Pedido de Venda, ja com o Valor dos Impostos
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//M->C5_YVLTOTP	:= U_VLTOTPED(M->C5_NUM,.F.)		//Numero Pedido / Considera Saldo / Atualiza Impostos
	//M->C5_YVLTST	:= xVlrST							//Valor Total do ICMS ST, apurado pela funcao VLTOTPED
	//M->C5_YDESCZF	:= xVlrZF							//Este campo e utilizado no calculo da Margem na funcao de liberacao BIA660
	//M->C5_YVLTIPI	:= xVlrIPI							//Valor Total do IPI, apurado pela funcao VLTOTPED
	//M->C5_YVLTPIS	:= xVlrPIS							//Este campo e utilizado no calculo da Margem na funcao de liberacao BIA660
	//M->C5_YVLTCOF	:= xVlrCOF							//Este campo e utilizado no calculo da Margem na funcao de liberacao BIA660
	//M->C5_YVLTICM	:= xVlrICMS							//Este campo e utilizado no calculo da Margem na funcao de liberacao BIA660
	M->C5_YVLTOTP	:= U_fValPed(.F.,.F.)					//Considera Saldo Pedido / Atualiza Impostos

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Se o Tipo de Pedido Diferente de Normal, nao executa a Rotina
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If M->C5_TIPO <> "N"
		Return(.T.)
	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Obriga digitacao dos campos Cliente/Loja Origem para vendas LM
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If cEmpAnt $ ("01_05_13") .And. Alltrim(M->C5_CLIENTE) == "010064" .And. Alltrim(M->C5_TIPO) == "N" .And. (Empty(Alltrim(M->C5_YCLIORI)) .Or. Empty(Alltrim(M->C5_YLOJORI)))
		Msgbox("Vendas para empresa LM, é necessário informar os campos Cliente/Loja Origem!","MTA410","STOP")
		Return(.F.)
	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Não permite digitação dos campos Cliente/Loja Origem para vendas que não sejam LM
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If cEmpAnt $ ("01_05") .And. !(Alltrim(M->C5_CLIENTE) $ "010064_008615") .And. Alltrim(M->C5_TIPO) == "N" .And. (!Empty(Alltrim(M->C5_YCLIORI)) .Or. !Empty(Alltrim(M->C5_YLOJORI)))
		Msgbox("Os campos Cliente/Loja Origem devem ser preenchidos apenas para vendas para as empresas LM/VITCER!","MTA410","STOP")
		Return(.F.)
	EndIf



	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Obriga digitacao do Pedido Origem na Empresa LM
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//COMENTADO>>>>>PROJETO RESERVA DE OP - Fernando/Facile - em 06/05/14 - Inclusão de Pedido direto na LM - vai gerar o origem depois
	//If cEmpAnt == "07" .And. Alltrim(M->C5_TIPO) <> "D" .And. Empty(Alltrim(M->C5_YPEDORI))
	//	Msgbox("Vendas realizdas na LM, é necessário informar o campo Pedido Origem!","MTA410","STOP")
	//	Return(.F.)
	//EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Verifica se o campo Vendedor está repetido no campo Pedido de Venda VEND1, VEND2, VEND3, VEND4, VEND5
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If !Empty(Alltrim(M->C5_VEND1))
		If Alltrim(M->C5_VEND1) == Alltrim(M->C5_VEND2) .OR. Alltrim(M->C5_VEND1) == Alltrim(M->C5_VEND3) .OR. Alltrim(M->C5_VEND1) == Alltrim(M->C5_VEND4) .OR. Alltrim(M->C5_VEND1) == Alltrim(M->C5_VEND5)
			Msgbox("Favor verificar o código do Vendedor 1 '"+Alltrim(M->C5_VEND1)+"', pois está digitado mais de uma vez no Pedido. Favor deixar apenas o campo Vendedor 1 preenchido!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf
	If !Empty(Alltrim(M->C5_VEND2))
		If Alltrim(M->C5_VEND2) == Alltrim(M->C5_VEND1) .OR. Alltrim(M->C5_VEND2) == Alltrim(M->C5_VEND3) .OR. Alltrim(M->C5_VEND2) == Alltrim(M->C5_VEND4) .OR. Alltrim(M->C5_VEND2) == Alltrim(M->C5_VEND5)
			Msgbox("Favor verificar o código do Vendedor 2 '"+Alltrim(M->C5_VEND2)+"', pois está digitado mais de uma vez no Pedido. Favor deixar apenas o campo Vendedor 1 preenchido!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf
	If !Empty(Alltrim(M->C5_VEND3))
		If Alltrim(M->C5_VEND3) == Alltrim(M->C5_VEND1) .OR. Alltrim(M->C5_VEND3) == Alltrim(M->C5_VEND2) .OR. Alltrim(M->C5_VEND3) == Alltrim(M->C5_VEND4) .OR. Alltrim(M->C5_VEND3) == Alltrim(M->C5_VEND5)
			Msgbox("Favor verificar o código do Vendedor 3 '"+Alltrim(M->C5_VEND3)+"', pois está digitado mais de uma vez no Pedido. Favor deixar apenas o campo Vendedor 1 preenchido!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf
	If !Empty(Alltrim(M->C5_VEND4))
		If Alltrim(M->C5_VEND4) == Alltrim(M->C5_VEND1) .OR. Alltrim(M->C5_VEND4) == Alltrim(M->C5_VEND2) .OR. Alltrim(M->C5_VEND4) == Alltrim(M->C5_VEND4) .OR. Alltrim(M->C5_VEND4) == Alltrim(M->C5_VEND5)
			Msgbox("Favor verificar o código do Vendedor 4 '"+Alltrim(M->C5_VEND4)+"', pois está digitado mais de uma vez no Pedido. Favor deixar apenas o campo Vendedor 1 preenchido!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf
	If !Empty(Alltrim(M->C5_VEND5))
		If Alltrim(M->C5_VEND5) == Alltrim(M->C5_VEND1) .OR. Alltrim(M->C5_VEND5) == Alltrim(M->C5_VEND2) .OR. Alltrim(M->C5_VEND5) == Alltrim(M->C5_VEND3) .OR. Alltrim(M->C5_VEND5) == Alltrim(M->C5_VEND4)
			Msgbox("Favor verificar o código do Vendedor 5 '"+Alltrim(M->C5_VEND5)+"', pois está digitado mais de uma vez no Pedido. Favor deixar apenas o campo Vendedor 1 preenchido!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//VERIFICA SE O MUNICIPIOS TEM TARIFA DE FRETE
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If M->C5_TIPO == "N"
		//Posiciona na UF/Cidade do Cadastro do Cliente ou Pedido
		If Alltrim(M->C5_YFLAG) == "1"
			cEst	:= SA1->A1_EST
			cMun	:= SA1->A1_COD_MUN
		Else
			cEst	:= M->C5_YEST
			cMun	:= M->C5_YCODMUN //SC5->C5_YMUN
		EndIf

		DbSelectArea("CC2")
		DbSetOrder(1)
		If DbSeek(xFilial("CC2")+cEst+cMun,.T.) .And. Empty(Alltrim(CC2->CC2_YTARIF))
			MsgBox("Favor cadastrar a Tarifa de Frete, na tabela de Municipio!","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//VERIFICA SE O PEDIDO ESTA COM O PEDIDO PAI PREENCHIDO
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	IF Alltrim(M->C5_YSUBTP) $ "R2/R3"
		IF ALLTRIM(M->C5_YPEDPAI) == ""
			MsgBox("Atenção, o campo Pedido Pai não foi preenchido. Favor verificar!","MTA410","STOP")
			Return(.F.)
		END IF
	END IF

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//VERIFICA SE O PEDIDO ESTA COM O PEDIDO ORIGINAL DUPLICADO
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If !U_BIA849() .And. cEmpAnt == "07"
		Return(.F.)
	END IF

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	// BRUNO MADALENO: VERIFICA SE JA EXISTE ALGUM PEDIDO EM ABERTO COM O MESMO PRODUTO E CLIENTE
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	IF CEMPANT == '05'
		FOR I := 1 TO LEN(ACOLS)
			nProd := Gdfieldget('C6_PRODUTO',I)
			nDesc := Gdfieldget('C6_DESCRI',I)

			CSQL := "SELECT COUNT(*) QUANT" + ENTER
			CSQL += "FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) " + ENTER
			CSQL += "WHERE	C6_FILIAL	= '"+xFilial("SC6")+"'	AND "+ ENTER
			CSQL += "		C6_CLI		= '"+M->C5_CLIENTE+"' 	AND " + ENTER		
			CSQL += "		C6_LOJA 	= '"+M->C5_LOJACLI+"' 	AND " + ENTER		
			CSQL += "		C6_PRODUTO	= '"+nProd+"' 			AND " + ENTER
			CSQL += "		C6_QTDVEN - C6_QTDENT > 0 			AND " + ENTER
			CSQL += "		C6_BLQ 		<> 'R' 					AND " + ENTER
			CSQL += "		C6_NUM		 <> '"+ M->C5_NUM+"' 	AND	" + ENTER
			CSQL += "		D_E_L_E_T_	= '' 						" + ENTER
			IF CHKFILE("_TRAB")
				DBSELECTAREA("_TRAB")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_TRAB" NEW

			IF _TRAB->QUANT > 0
				CTEXTO := "O produto " + nDesc + " já esta cadastrado para esse cliente em outro pedido. Deseja Continuar?"
				IF ! MSGYESNO(CTEXTO)
					RETURN(.F.)
				END IF
			END IF
		NEXT
	END IF

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//ROTINA PARA VERIFICAR SE O VENDEDOR ESTA CADASTRADO NA TABELA ZZI - AMARRACAO VEND X SUP X GER X SEG
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If cEmpAnt $ "01_05" .And. SF4->F4_DUPLIC == "S" .And. Substr(Alltrim(Gdfieldget('C6_PRODUTO',1)),1,1) >= "A"

		/*cSql := "SELECT COUNT(*) QUANT " + Enter
		cSql += "FROM "+RetSqlName("ZZI")+" ZZI " + Enter
		cSql += "WHERE	ZZI_FILIAL	= '"+xFilial("ZZI")+"'	AND " + Enter
		cSql += "				ZZI_VEND		= '"+Alltrim(M->C5_VEND1)+"'	AND	" + Enter
		cSql += "				ZZI_TPSEG		= '"+SA1->A1_YTPSEG+"'	AND	" + Enter
		cSql += "				D_E_L_E_T_	= ''												" + Enter
		If chkfile("_RRR")
			dbSelectArea("_RRR")
			dbCloseArea()
		EndIf
		TcQuery cSql ALIAS "_RRR" NEW
		*/
		__cYEmp := ""
		If cEmpAnt == "14"
			__cYEmp	:= "1401"
		ElseIf cEmpAnt == "13"
			If M->C5_YLINHA == "4"
				__cYEmp	:= "1399"
			ElseIf M->C5_YLINHA == "6"
				__cYEmp	:= "1302"	
			Else
				__cYEmp	:= "1301"
			EndIf	
		Else
			Do Case
				Case M->C5_YLINHA == "1"
				__cYEmp	:= "0101"
				Case M->C5_YLINHA == "2"
				__cYEmp	:= "0501"
				Case M->C5_YLINHA == "3"
				__cYEmp	:= "0599"
				Case M->C5_YLINHA == "4"
				__cYEmp	:= "1399"
				Case M->C5_YLINHA == "5"
				__cYEmp	:= "0199"
				Case M->C5_YLINHA == "6"
				__cYEmp	:= "1302"
			EndCase
		EndIf
		
		oGerenteAtendente	:= TGerenteAtendente():New()
		oResult 			:= oGerenteAtendente:GetCliente(__cYEmp, M->C5_CLIENTE, M->C5_LOJACLI, M->C5_VEND1)

		If SA1->A1_YTPSEG == "R"
			nTpSeg := "REVENDA"
		ElseIf SA1->A1_YTPSEG == "E"
			nTpSeg := "ENGENHARIA"
		ElseIf SA1->A1_YTPSEG == "H"
			nTpSeg := "HOME CENTER"
		Else
			nTpSeg := "EXPORTAÇÃO"
		EndIf

		If Empty(oResult:cGerente)
			nMsg := "Não existe amarração cadastrada na tabela Vend x Sup x Ger x Seg (ZKP), " 	+ Enter
			nMsg += "para o Vendedor "+Alltrim(M->C5_VEND1)+" e Segmento "+nTpSeg+" ! "				+ Enter
			nMSg += ""+ Enter
			nMsg += "Favor solicitar o cadastramento desta informação no Setor Comercial."
			MsgAlert(nMsg)
			Return(.F.)
		EndIf
	EndIf

	//-------------------------------------------------------------------------------------
	//(Thiago Dantas - 08/04/2014) -> Verifca Total da comissão <-
	//-------------------------------------------------------------------------------------
	nTotComiss := M->C5_COMIS1 + M->C5_COMIS2 +  M->C5_COMIS3 + M->C5_COMIS4 + M->C5_COMIS5

	If (cEmpAnt $ '01_05_07_13')

		cAuxMsg := "Não é possível gravar o pedido pois Comissão excedeu "
		lExcedVlr := .F.

		If (M->C5_YLINHA == _BIANCOGRES 	.AND. nTotComiss > GETMV("MV_YPCOMBI"))
			cAuxMsg 	+= AllTrim(Str(GETMV("MV_YPCOMBI"))) +"%!"
			lExcedVlr 	:= .T.
		ElseIf(M->C5_YLINHA == _INCESA 		.AND. nTotComiss > GETMV("MV_YPCOMIN"))
			cAuxMsg 	+= AllTrim(Str(GETMV("MV_YPCOMIN"))) +"%!"
			lExcedVlr 	:= .T.
		ElseIf (M->C5_YLINHA == _BELLACASA 	.AND. nTotComiss > GETMV("MV_YPCOMBC"))
			cAuxMsg 	+= AllTrim(Str(GETMV("MV_YPCOMBC"))) +"%!"
			lExcedVlr 	:= .T.
		ElseIf (M->C5_YLINHA == _MUNDI 		.AND. nTotComiss > GETMV("MV_YPCOMMD"))
			cAuxMsg 	+= AllTrim(Str(GETMV("MV_YPCOMMD"))) +"%!"
			lExcedVlr 	:= .T.
		EndIf

		If lExcedVlr
			MsgBox(cAuxMsg,"MTA410","STOP")
			Return(.F.)
		EndIf

	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//ROTINA PARA TESTAR SE O PERCENTUAL DE COMISSAO ESTA PREENCHIDO
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	cMens := "ESTE PEDIDO ESTA COM O PERCENTUAL DE COMISSÃO ZERADO. DESEJA PROSSEGUIR"
	If Empty(M->C5_COMIS1)
		If MsgYesNo(cMens,OemToAnsi('ATENCAO'))
			lRet := .T.
		Else
			lRet := .F.
			Return(lRet)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A REGRA ABAIXO FOI ALTERADA EM 30/12/11, PARA TRATAMENTO DO NOVO PROCESSO VENDA LM   ³
	//³A COMISSAO SERA ZERADA NA BIANCOGRES, E GERADA ATRAVES DA EMPRESA LM                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//GRAVA COMISSAO ZERO E VEND1 999999 PARA PEDIDOS DE VENDA DA LM
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//If Alltrim(cempant) == "07"
	If Alltrim(cempant) $ "01_05_13" .And. M->C5_CLIENTE == "010064"
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


	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Validar se o codido do Vendedor ja esta Bloqueado
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	cSql := "SELECT A3_COD, A3_MSBLQL FROM "+RetSqlName("SA3")+	" "
	cSql += "WHERE	A3_MSBLQL	<>	'1' AND							"
	cSql += "		A3_COD		=	'"+Alltrim(M->C5_VEND1)+"' AND 	"
	cSql += "		D_E_L_E_T_	=	''								"
	If chkfile("R003")
		dbSelectArea("R003")
		dbCloseArea()
	EndIf
	TcQuery cSql ALIAS "R003" NEW

	If R003->(Eof())
		lRet := .F.
		MsgAlert("O Vendedor "+Alltrim(M->C5_VEND1)+" está bloqueado. Favor verificar o cadastro do cliente ou informar outro código!")
		Return(lRet)
	EndIf


	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Validar Condicao de Pagamento com Tipo de Cliente
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

	//Posiciona na Condição de Pagamento
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(XFilial("SE4")+M->C5_CONDPAG))

	//Valida se a Condição de Pagamento está ativa
	If SE4->E4_YATIVO <> '1'
		lRet := .F.
		MsgBox("A Condição de Pagamento escolhida, não está ativa. Favor verificar!","MTA410","ALERT")
		Return(lRet)
	EndIf

	nGrupo := Posicione("SB1",1,xFilial("SB1")+Gdfieldget('C6_PRODUTO',1),"B1_GRUPO")
	If Alltrim(nGrupo) == "PA"
		//If Alltrim(M->C5_TIPOCLI) == "S" .And. SA1->A1_EST $ "MG_BA_ES" .And. Alltrim(cempant) $ "01_05_07" .And. Empty(Alltrim(SA1->A1_YREGESP))
		If Alltrim(M->C5_TIPOCLI) == "S" .And. SA1->A1_EST $ GetMV("MV_YUFSTCD") .And. Alltrim(cEmpAnt) $ "01_05_07_14" .And. Empty(Alltrim(SA1->A1_YREGESP))
			If SE4->E4_SOLID <> "S"
				lRet := .F.
				MsgBox("Favor escolher uma Condição de Pagamento de ST!","MTA410","ALERT")
				Return(lRet)
			EndIf
		Else
			If SE4->E4_SOLID == "S"
				lRet := .F.
				MsgBox("Favor escolher uma Condição de Pagamento diferente de ST!","MTA410","ALERT")
				Return(lRet)
			EndIf
		EndIf
	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Procura condição de Pagamento para analisar o Tipo = '9'
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If SE4->E4_TIPO == '9'

		//Total das Parcelas do Pedido 
		nTotParc := 0

		//Obriga digitação de Valor/Percentual e Vencimento para pedidos com Condição do Tipo 9
		For nCont := 1 To nMaxParcela
			cCampoVal := "C5_PARC" +Subs(cParcela,nCont,1)
			cCampoData := "C5_DATA" +Subs(cParcela,nCont,1)
			If ( !Empty(M->&(cCampoVal)) .And. Empty(M->&(cCampoData)) ) .Or. ( Empty(M->&(cCampoVal)) .And. !Empty(M->&(cCampoData)) )
				MsgBox("Favor informar as datas e vencimentos dos títulos para esta Condição de Pagamento.","MTA410","ALERT")
				Return(.F.)		
			EndIf		    	
			//Armazena o valor das parcelas
			nTotParc += M->&(cCampoVal)			
		Next

		//Testa se os valores das parcelas preenchidas estão conferindo com o valor total do pedido / 100 %              
		If AllTrim(SE4->E4_COND) == '0' 
			If nTotParc <> M->C5_YVLTOTP
				MsgBox("O valor total das parcelas está diferente do valor total do pedido.","MTA410","ALERT")
				Return(.F.)
			EndIf
		Else
			If nTotParc <> 100
				MsgBox("A soma dos % percentuais das parcelas tem que ser igual a 100%.","MTA410","ALERT")
				Return(.F.)
			EndIf	
		EndIf

		/*
		If (Empty(M->C5_PARC1) .And. !Empty(M->C5_DATA1)) .Or. (!Empty(M->C5_PARC1).And. Empty(M->C5_DATA1)) .Or.;
		(Empty(M->C5_PARC2) .And. !Empty(M->C5_DATA2)) .Or. (!Empty(M->C5_PARC2).And. Empty(M->C5_DATA2)) .Or.;
		(Empty(M->C5_PARC3) .And. !Empty(M->C5_DATA3)) .Or. (!Empty(M->C5_PARC3).And. Empty(M->C5_DATA3)) .Or.;
		(Empty(M->C5_PARC4) .And. !Empty(M->C5_DATA4)) .Or. (!Empty(M->C5_PARC4).And. Empty(M->C5_DATA4)) 											
		MsgBox("Favor informar as datas e vencimentos dos títulos para esta Condição de Pagamento.","MTA410","ALERT")
		Return(.F.)		
		EndIf

		If AllTrim(SE4->E4_COND) <> '%' .And. (M->C5_PARC1 + M->C5_PARC2 + M->C5_PARC3 + M->C5_PARC4) <> M->C5_YVLTOTP
		MsgBox("O valor total das parcelas está diferente do valor total do pedido.","MTA410","ALERT")
		Return(.F.)
		Endif
		*/

		//Total das Parcelas para Contrato
		nTotParc := 0

		// Caso seja um CONTRATO //VALIDAÇÃO SOMENTE A PARTIR DE 01/08/2015 PARA A NOVA MODALIDADE DE CONTRATO	
		If M->C5_YFORMA == "4" .And. DTOS(M->C5_EMISSAO) >= "20150801" .And. fLibCont() //Ticket 2027

			//Z60->(DbSetOrder(1))
			//If Z60->(DbSeek(xFilial("Z60")+M->C5_NUM))		
			Z60->(DbSetOrder(2))			
			If Z60->(DbSeek(xFilial("Z60")+M->C5_YCHVRES))				

				For nCont := 1 To nMaxParcela

					cCampoVal := "Z60_PARC" +Subs(cParcela,nCont,1)
					cCampoData := "Z60_DATA" +Subs(cParcela,nCont,1)					

					If ( !Empty(Z60->&(cCampoVal)) .And. Empty(Z60->&(cCampoData)) ) .Or. ( Empty(Z60->&(cCampoVal)) .And. !Empty(Z60->&(cCampoData)) )
						MsgBox("Favor informar a Data e Vencimento corretamente da parcela "+cValToChar(nCont)+".","MTA410","ALERT")
						Return(.F.)
					EndIf

					//Verificar a Data se é maior que a data anterior
					If nCont > 1 .And. !Empty(Z60->&(cCampoVal)) .And. !Empty(Z60->&(cCampoData))

						cDatAnt := "Z60_DATA" +Subs(cParcela,nCont-1,1)
						dDatAnt := Z60->&(cDatAnt)

						If Z60->&(cCampoData) <= dDatAnt
							MsgBox("O Vencimento da Parcela "+cValToChar(nCont)+" é menor ou igual ao vencimento anterior.","MTA410","ALERT")
							Return(.F.)
						EndIf

					EndIf

					If !Empty(Z60->&(cCampoVal)) .And. !Empty(Z60->&(cCampoData))

						dDatUltPar := Z60->&(cCampoData)

						// Regra não utilzada pela Vitcer
						If cEmpAnt <> "14"	

							If Z60->&(cCampoVal) < nParcMin
								MsgBox("A Parcela "+cValToChar(nCont)+" está com valor abaixo do mínimo permitido - R$ "+cValToChar(nParcMin)+".","MTA410","ALERT")
								Return(.F.)
							EndIf

						EndIf

					EndIf

					nTotParc += Z60->&(cCampoVal)					

				Next

				If nTotParc <> M->C5_YVLTOTP
					MsgBox("O valor total das parcelas está diferente do valor total do pedido.","MTA410","ALERT")
					Return(.F.)
				EndIf

				// Ranisses A. Corona - 15/05/2017 - Melhoria na OS: 1176-17
				If dDataBase <= dDatUltPar
					// Tiago Rossini Coradini - 25/04/2017 - OS: 1176-17
					If M->C5_DATA1 <> dDatUltPar
						MsgBox("A data de vencimento 1, esta diferente da data da última parcela do contrato.","MTA410","ALERT")
						Return(.F.)
					EndIf
				EndIf

				// Regra não utilzada pela Vitcer
				If cEmpAnt <> "14"

					// Valida quantidade minina por contrato
					If !QtdMinPed()
						Return(.F.)
					EndIf

				EndIf

			Else
				MsgBox("Para Pedidos de Contrato é obrigátorio o preenchimento da parcelas. Favor verificar antes de finalizar o pedido.","MTA410","ALERT")
				Return(.F.)
			EndIf

		EndIf

	EndIf

	//CONFORME OS 1249-13
	If U_fValidaRA(M->C5_CONDPAG) .And. Alltrim(M->C5_YSUBTP) == 'B'
		lRet := .F.
		MsgBox("Para pedidos de BONIFICAÇÃO, não é permitido utilizar condição de pagamento ANTECIPADO!","MTA410","ALERT")
		Return(lRet)
	EndIf

	//Conforme solicitação da Tatiane/Incesa
	If Alltrim(M->C5_CONDPAG) == "145" .And. !cEmpAnt $ "01_13"
		MsgBox("Está condição de pagamento só pode ser utilizada na Empresa Biancogres!.","MTA410","STOP")
		Return(.F.)
	ElseIf Alltrim(M->C5_CONDPAG) == "945" .And. !cEmpAnt $ "05_13"
		MsgBox("Está condição de pagamento só pode ser utilizada na Empresa Incesa Revestimentos!.","MTA410","STOP")
		Return(.F.)
	EndIf

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//ROTINA PARA VERIFICAR A SITUACAO DE CREDITO DO CLIENTE
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//Posiciona no TES do Pedido
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(XFilial("SF4")+Gdfieldget("C6_TES",1)))

	//Grava se Gera Duplicata S/N
	M->C5_YDUPLIC := SF4->F4_DUPLIC


	//Fernando/Facile em 16/02/17
	//Fernando em 28/09/2017 - alterado este bloco para antes do Return .T. abaixo pois nao estava validando pedidos bonificados
	IF !M->C5_CLIENTE == "010064"
		//Tratamento para Desconto de Verba
		IF lRet .And. SC6->(FieldPos("C6_YDACO")) > 0 .And. !Empty(M->C5_YNUMSI)
			lRet := fDescVrb(M->C5_YNUMSI, 1)
		ENDIF

		IF lRet .And. SC6->(FieldPos("C6_YDAI")) > 0 .And. !Empty(M->C5_YNOUTAI)
			lRet := fDescVrb(M->C5_YNOUTAI, 2)
		ENDIF

		//manut email Jaqueline pedido bonificado
		IF (AllTrim(M->C5_YSUBTP) == "B")

			IF lRet .And. M->C5_YLINHA <> _MUNDI .And. M->C5_YLINHA <> _VINILICO .And. fGTotVerba(1) > 0 .And. Empty(M->C5_YNUMSI) .And. Empty(M->C5_YNOUTAI) .And. Empty(M->C5_YCTRVER)

				lRet := .F.
				MsgAlert("Pedido BONIFICADO. É obrigatório informar a AI/Contrato no cabeçalho no campo 'No.AI ref.AO' OU 'No.AI Outras' OU 'Ctr. Verba'.","ATENÇÃO! PEDIDO BONIFICADO -> MTA410")

			ENDIF

		ELSE

			IF lRet .And. Empty(M->C5_YNUMSI) .And. fGTotVerba(1) > 0
				lRet := .F.
				MsgAlert("Pedido contem descontos de AO. É obrigatório informa a AI no cabeçalho no campo 'No.AI ref.AO'.","ATENÇÃO! DESCONTO DE AO -> MTA410")
			ENDIF

			IF lRet .And. SC6->(FieldPos("C6_YDAI")) > 0 .And. Empty(M->C5_YNOUTAI) .And. fGTotVerba(2) > 0
				lRet := .F.
				MsgAlert("Pedido contem descontos de outras AI's. É obrigatório informa a AI no cabeçalho no campo 'No.AI Outras'.","ATENÇÃO! DESCONTO DE AO -> MTA410")
			ENDIF

		ENDIF
	ENDIF


	//Se o PV nao Gera Duplicata, nao executa a rotina de Credito
	If lRet .And. SF4->F4_DUPLIC == "N"
		RETURN(.T.)
	END IF

	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//VALIDA A FORMA DE PGTO COM O CADASTRO CLIENTE E COND. PAGAMENTO
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	If lRet .And. SA1->A1_YFORMA <> M->C5_YFORMA
		If (U_fValidaRA(M->C5_CONDPAG) .And. M->C5_YFORMA <> "3") .Or. (!U_fValidaRA(M->C5_CONDPAG) .And. M->C5_YFORMA == "3")
			MSGBOX("Favor conferir a Forma de Pagmento do Pedido pois não confere com o Cadastro de Cliente ou Condição de Pagamento.","MTA410","STOP")
			Return(.F.)
		EndIf
	EndIf

	If lRet .And. cEmpAnt <> "06" //conforme OS 0756-13

		If !M->C5_CLIENTE == "010064" //conforme 3228-16	

			If M->C5_YFORMA <> '4' .AND. M->C5_CONDPAG == '142' 
				MSGBOX("Favor conferir o campo Tipo Pagto pois deve ser preenchido como Contrato.","MTA410","STOP")
				Return(.F.)
			EndIf

		EndIf

	EndIf

	//Fernando Rocha em 21/08/2018 - projeto PBI validações
	__cEmpPed := ""
	IF AllTrim(CEMPANT) == '07' .And. (LEN(ACOLS) > 1)

		FOR I := 1 TO LEN(ACOLS)

			If !GdDeleted(I)

				If Empty(__cEmpPed)
					__cEmpPed := Gdfieldget('C6_YEMPPED',I)
				EndIf

				If I > 1 .And. !Empty(Gdfieldget('C6_YEMPPED',I)) .And. Gdfieldget('C6_YEMPPED',I) <> __cEmpPed

					U_FROPMSG("MTA410 - PBI", 	"Pedido contem produtos com estoque em empresas diferentes."+CRLF+;
					"Necessário colocar em pedidos diferentes.",;
					,,"Estoque em empresa diferente.")
					Return(.F.)

				EndIf

			EndIf

		NEXT I

	END IF


	If lRet .And. ALLTRIM(M->C5_TIPO) = "N"
		If ALLTRIM(FUNNAME()) <> "EECAP100"

			//ROTINA PARA VERIFICAO DE PEDIDO NORMAL (VERIFICA CREDITO)
			If SF4->F4_DUPLIC == "N"
				Return(.T.)
			EndIf

			//ROTINA PARA VERIFICAO DE PEDIDO ANTECIPADO (RA)
			//PROJETO2014
			If Alltrim(M->C5_YTPCRED) $ "0#5" //Validação através da Rotina de Crédito e Engenharia

				//Determina qual cliente o sistema devera analisar o Crédito
				If Empty(Alltrim(M->C5_YCLIORI))
					nCli 	:= M->C5_CLIENTE
					nLoja 	:= M->C5_LOJACLI
					lLm		:= .F.
				Else
					nCli 	:= M->C5_YCLIORI
					nLoja 	:= M->C5_YLOJORI
					lLm		:= .T.
				EndIf

				If (U_fValidaRA(M->C5_CONDPAG) .OR. Alltrim(M->C5_CONDPAG) $ "145_975") .Or. M->C5_YFORMA == "4"

					//lRet := U_fVerificaCredito("2",M->C5_NUM,nCli,nLoja,lLm,M->C5_YVLTOTP,0,.T.,.F.)
					//lRet := (U_fVerificaCredito("2",M->C5_NUM,nCli,nLoja,lLm,U_VLTOTPED(M->C5_NUM,.T.),0,.T.,.F.) == "00")
					lRet := (U_fVerificaCredito("2",M->C5_NUM,nCli,nLoja,lLm,U_fValPed(.T.,.F.),0,.T.,.F.) == "00")

				Else
					//Alterado por Wanisay e Thiago no dia 01/10/14
					//Alterado por Fernando em 23/12/2014 - Novo projeto comercial - tem que verificar credito na LM

					// Não é necessário verificar o crédito quando o PEDIDO é da LM, uma vez que esse processo já foi realizado na própria LM no momento da INCLUSÃO.
					IF !lLM
						//nRet := U_fVerificaCredito("1",M->C5_NUM,M->C5_CLIENTE,M->C5_LOJACLI,.F.,U_VLTOTPED(M->C5_NUM,.T.),0,.T.,.F.)
						nRet := U_fVerificaCredito("1",M->C5_NUM,M->C5_CLIENTE,M->C5_LOJACLI,.F.,U_fValPed(.T.,.F.),0,.T.,.F.)
						lRet := (nRet == "00")
					EndIf

				EndIf

				//Pedidos de Engenharia 
				If Alltrim(M->C5_YTPCRED) == "5" 		
					If lRet
						//Pedido de Engenharia Liberado
						M->C5_YCRDENG := "01" //Iif(INCLUI,"01",M->C5_YCRDENG)
						MsgBox("Para o canal de ENGENHARIA, não será feito análise de crédito durante a inclusão do Pedido!","MTA410","ALERT")	
						MsgBox("Para realizar a montagem de Carga, o crédito deverá ser analisado e liberado pelo Setor de Crédito e Cobrança!","MTA410","ALERT")
					Else
						//Pedido de Engenharia Bloqueado
						M->C5_YCRDENG := "03" //Iif(INCLUI,"03",M->C5_YCRDENG)

						If VldSolCr()
							MsgBox("Para o canal de ENGENHARIA, não será feito análise de crédito durante a inclusão do Pedido!","MTA410","ALERT")	
						Else        			    			
							MsgBox("Para o canal de ENGENHARIA, não será feito análise de crédito durante a inclusão do Pedido, porém este Cliente apresenta restrições e será obrigatório o preenchimento da Solicitação de Crédito a seguir:","MTA410","ALERT")								
							
							//Chama tela de inclusão de Solicitação de Crédito
							StaticCall(SOLI_CRE, uNOVO, nCli, M->C5_NUM, M->C5_YVLTOTP, 0, M->C5_CONDPAG, M->C5_YCHVRES)
							
						EndIf

						//Valida se a Solicitação foi incluida
						lRet := VldSolCr()	 
						If lRet
							MsgBox("Para realizar a montagem de Carga, o crédito deverá ser analisado e liberado pelo Setor de Crédito e Cobrança!","MTA410","ALERT")
						Else
							MsgBox("Para finalizar este pedido, é obrigatório a inclusão da Solicitação de Crédito. Favor confirmar a inclusão da Solicitação de Crédito","MTA410","ALERT")
						EndIf									

					EndIf				
				EndIf

			ElseIf Alltrim(M->C5_YTPCRED) == "2"	//Pedidos de Contrato
				lRet := .T.	
				MsgBox("Para Pedidos de Venda de Contrato, não será feito nálise de crédito na Inclusão do Pedido!","Atenção","ALERT")	
				MsgBox("Para realizar a montagem de Carga, o crédito deverá ser analisado e liberado pelo Setor de Crédito e Cobrança!","Atenção","ALERT")
			ElseIf Alltrim(M->C5_YTPCRED) == "3"	//Pedidos de Del Crédere
				lRet := .T.
				MsgBox("Para Pedidos de Venda de Del Crédere, não será feito análise de crédito na Inclusão do Pedido!","Atenção","ALERT")	
				MsgBox("Para realizar a montagem de Carga, é necessário que o documento assinado com firma reconhecida em cartório, esteja em poder do setor de Crédito para liberação do mesmo!","Atenção","ALERT")
			ElseIf Alltrim(M->C5_YTPCRED) == "4"	//Pedidos de Termo Resp.
				lRet := .T.
				MsgBox("Para Pedidos de Venda de Termo Resp., não será feito análise de crédito na Inclusão do Pedido!","Atenção","ALERT")	
				MsgBox("Para realizar a montagem de Carga é necessário que o documento assinado com firma reconhecida em cartório, esteja em poder do setor de Crédito para liberação do mesmo!","Atenção","ALERT")
			EndIf
		EndIf
	EndIf

	// Incluído por Marcos Alberto Soprani em 19/08/15 para atender ao novo controle de CLVL por empresa
	If lRet
		lRet := ExecBlock("BIA555", .F., .F., "SC5TOK1")
	EndIf

	// Tiago Rossini Coradini - 10/05/17 - OS: 0956-17 - Raul Viana
	If lRet
		FVldNorma()
	EndIf

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	If chkfile("_RA")
		dbSelectArea("_RA")
		dbCloseArea()
	EndIf
	If chkfile("_PEDFAT")
		dbSelectArea("_PEDFAT")
		dbCloseArea()
	EndIf
	If chkfile("_PEDIDO")
		dbSelectArea("_PEDIDO")
		dbCloseArea()
	EndIf
	If chkfile("_RRR")
		dbSelectArea("_RRR")
		dbCloseArea()
	EndIf

Return(lRet)

/*=======================================================================
+                                                                       +
+======================================================================*/
Static Function QtdMinPed()

	Local lRet := .T.
	Local aArea	:= GetArea()
	Local nQtdMin := GetMv("MV_YQTDMIN", .F., 2000) // Quantidade minima de contrato.
	Local nQtdPed := 0
	Local nLine

	For nLine := 1 To Len(aCols)

		If !GdDeleted(nLine)

			nQtdPed += GdFieldGet("C6_QTDVEN", nLine)

		EndIf

	Next

	If nQtdPed < nQtdMin
		MsgBox('O Pedido não possui a Quantidade Mínima de '+ cValToChar(nQtdMin) +'m² para essa Condição de Pagamento de Contratos!',"MTA410","ALERT")
		lRet := .F.
	EndIf

	RestArea(aArea)

Return(lRet)

/*=======================================================================
+                                                                       +
+======================================================================*/
Static Function VldSolCr()
	Local lRet := .F. //Retorna T para Solicitação encontrada // Retorna F para Solicitação não encontrada
	Local cSql := ""

	//Pesquisa somente as SC's que foram abertas diretamente no Pedido de Venda
	cSql := "SELECT COUNT(*) QUANT FROM "+RetSqlName("SZU")+" WHERE ZU_CHAVTMP = '"+M->C5_YCHVRES+"' AND ZU_CODCLI = '"+nCli+"' AND ZU_EMPRESA = '"+cEmpAnt+"' AND D_E_L_E_T_ = '' "
	If chkfile("_SZU")
		dbSelectArea("_SZU")
		dbCloseArea()
	EndIf
	TcQuery cSql ALIAS "_SZU" NEW

	If _SZU->QUANT > 0	
		lRet := .T.
	EndIf

	If chkfile("_SZU")
		dbSelectArea("_SZU")
		dbCloseArea()
	EndIf

Return(lRet)

/*
+===========================================================================
+Função para Calcular o Total do Pedido de Venda com Impostos
+ lSaldo:  .T. Considera Saldo do Pedido / .F. Considera o Total do Pedido  
+ lAtuImp: .T. Atualiza os impostos / .F. Não atualiza o valor dos impostos                                                                    
+===========================================================================
*/
User Function fValPed(lSaldo,lAtuImp)
	Local i		  := 0
	Local nValPed := 0
	Local nQtdVen := 0
	Local nQtdEnt := 0
	Local cBlqRes := ""
	Local aArea	  := GetArea()

	If lAtuImp
		//Calcula o valor do impostos para TODOS os Itens do Pedido
		aColsImp := U_fItImpos(0,{"IT_BASEPS2","IT_BASECF2","IT_VALPS2","IT_VALCF2","IT_VALICM","IT_VALIPI","IT_ALIQPS2","IT_ALIQCF2","IT_VALMERC","IT_DESCZF","IT_VALSOL","IT_BASEICM","IT_BASEIPI"})	
	EndIf

	For i := 1 To Len(aCols)

		If lAtuImp
			nBasePIS := aColsImp[i][1]
			nBaseCOF := aColsImp[i][2]
			nPIS     := aColsImp[i][3]
			nCOFINS  := aColsImp[i][4]
			nICMS	 := aColsImp[i][5]
			nIPI 	 := aColsImp[i][6]	
			nPercPIS := aColsImp[i][7]
			nPercCOF := aColsImp[i][8]  
			nValMerc := aColsImp[i][9]  
			nDescZF	 := aColsImp[i][10]  	
			nValST	 := aColsImp[i][11]
			nBaseICM := aColsImp[i][12]
			nBaseIPI := aColsImp[i][13]

			//Grava o valor dos impostos nos itens do Pedido de Venda 
			U_fAtuImp(I,nBasePIS,nBaseCOF,nPIS,nCOFINS,nICMS,nIPI,nPercPIS,nPercCOF,nValMerc,nDescZF,nValST,nBaseICM,nBaseIPI)
		EndIf

		If !GdDeleted(i)
			If !lSaldo
				nValPed += Gdfieldget("C6_YVLIMP",I)
			Else
				nQtdEnt := 0
				cBlqRes	:= ""
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+M->C5_NUM+Gdfieldget("C6_ITEM",I)))
					nQtdEnt := SC6->C6_QTDENT
					cBlqRes	:= SC6->C6_BLQ
				EndIf

				nQtdVen	:= Gdfieldget("C6_QTDVEN",I)

				If Alltrim(cBlqRes) <> "R" .And. nQtdVen-nQtdEnt > 0
					nValPed += Round((nQtdVen-nQtdEnt)/nQtdVen*Gdfieldget("C6_YVLIMP",I),2)		
				EndIf
			EndIf
		EndIf
	Next

	RestArea(aArea)

Return(nValPed)

//Fernando/Facile em 16/02/17
//Tratamento para Desconto de Verba
Static Function fDescVrb(_cNumAI, _nOpc)
	//_nOpc == 1 >> desconto de AI de AO
	//_nOpc == 2 >> desconto de outras AI

	Local i		:= 0
	Local aArea	:= GetArea()
	Local lRet	:= .T.	
	Local _nVDescVer
	Local _nSldAO	

	_nSldAO := U_AO_SALDO(_cNumAI, M->C5_NUM,,!INCLUI)
	_nVDescVer := fGTotVerba(_nOpc)

	If ( _nVDescVer > 0 .And. _nVDescVer > _nSldAO )
		lRet := .F.
		MsgAlert("Desconto de "+IIF(_nOpc==1,"AO","Outras AIs")+" total é maior que o saldo da AI informada."+CRLF+;
		"AI: "+IIF(_nOpc==1,M->C5_YNUMSI,M->C5_YNOUTAI)+" - Saldo (R$): "+Transform(_nSldAO,"@E 999,999.99")+CRLF+;
		"Total de desconto aplicado (R$): "+Transform(_nVDescVer,"@E 999,999.99");		
		,"ATENÇÃO! DESCONTO DE AI -> MTA410")
	EndIf

	RestArea(aArea)

Return(lRet)

Static Function fGTotVerba(_nOpc)
	//_nOpc == 1 >> desconto de AI de AO
	//_nOpc == 2 >> desconto de outras AI

	Local i
	Local _nDescVer, _nPrcTab, _nQtd
	Local _nVDescVer := 0
	Local oDesconto := TBiaPoliticaDesconto():New()
	Local _nFatEnt := 1

	_nVDescVer := 0 

	For i := 1 To Len(aCols)
		If !GdDeleted(i)

			If ALTERA

				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+M->C5_NUM+Gdfieldget("C6_ITEM",I))) .And. AllTrim(SC6->C6_BLQ) == "R"

					If SC6->C6_QTDENT <= 0
						loop
					Else
						_nFatEnt := ( SC6->C6_QTDENT / SC6->C6_QTDVEN )
					EndIf

				EndIf				

			EndIf

			IF (AllTrim(M->C5_YSUBTP) == "B")

				_nPrcTab := Gdfieldget("C6_VALOR",I)				
				_nVDescVer += _nPrcTab * _nFatEnt

			ELSE
			
				IF (AllTrim(M->C5_YSUBTP) <> "O")

					_nPrcTab := Gdfieldget("C6_YPRCTAB",I)
					_nDescVer := 0
					oDesconto:LoadParMem(i)  //Carrega todos os parametros necessarios para a busca da politica das variaveis na tela do pedido
					If oDesconto:GetPolitica()
	
						If (_nOpc == 1)
							_nDescVer := oDesconto:CalVlDACO(_nPrcTab)
						Else
							_nDescVer := oDesconto:CalVlDAI(_nPrcTab)
						EndIf			
	
					EndIf
	
					_nVDescVer += ( _nDescVer * Gdfieldget("C6_QTDVEN",I) ) * _nFatEnt
					
				EndIf
				
			ENDIF

		EndIf
	Next i

Return(_nVDescVer)


Static Function FVldNorma()
	Local aArea := GetArea()

	If M->C5_YCONF == "S" .And. aScan(aCols, {|x| x[GdFieldPos("C6_YDNV")] > 0 }) > 0 .And. Posicione("SE4", 1, xFilial("SE4") + M->C5_CONDPAG, "E4_YMEDIA") > 56

		MsgBox("Pedido com desconto em norma e prazo acima de 56 dias, favor informar ao gerente.", "MTA410", "ALERT")		

	EndIf

	RestArea(aArea)

Return()

//Libera validação dos pedidos de contrato, devido alteração no formato. - Ticket 2027 
Static Function fLibCont()
	Local lRet := .T. 

	If (cEmpAnt == "01" .And. Alltrim(M->C5_NUM) $ ("D22578_D23393_RABTO4_D16992_D23939_D18808_D23167_D15408") ) .Or. ( cEmpAnt == "07" .And. Alltrim(M->C5_NUM) $ ("D29435_D30566_RABLEF_D21509_D31335_X48597_D30262_D19314") )  
		lRet := .F.
	EndIf 

Return(lRet)

//Thiago Haagensen - Ticket 30399 - Tornar campo obrigatório para pedido M não dar divergencia de estoque
USER FUNCTION VALIDQTDPC()

LOCAL CTIPOVENDA :=""
LOCAL NQTDPECAS := 0
LOCAL Lzero := .T.
LOCAL CITEM  :=""

CTIPOVENDA := M->C5_YSUBTP

FOR NX := 1 TO LEN (ACOLS)
	
	IF ALLTRIM(CTIPOVENDA) == "M"
		NQTDPECAS := acols[NX,aScan(aHEADER,{|x| alltrim(x[2])=="C6_YQTDPC"})]
		IF  NQTDPECAS==0
			Lzero:=.F.
			CITEM := acols[NX,aScan(aHEADER,{|x| alltrim(x[2])=="C6_ITEM"})]
			AVISO("PREENCHER QUANTIDADE","Atenção! Favor preencher o campo Qtde. em PC do item " +CITEM + ", tipo M são obrigatórios!" ,;
			{"Fechar"},2)
		ENDIF
	
	ENDIF

NEXT
 
RETURN Lzero