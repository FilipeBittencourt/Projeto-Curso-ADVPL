#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0024; Return()

/*/{Protheus.doc} TRecebimentoAntecipado
@author Tiago Rossini Coradini - Facile Sistemas
@since 04/05/15
@version 6.0
@description Classe para tratamento de recebimento antecipado com boletos via pedido de venda
@type class
/*/

	Class TRecebimentoAntecipado From LongClassName

		Data cNumPed
		Data lJob
		Data cNossoNum
		Data nVlJuros

		Data oConRecBx
		Data oConRecRa
		Data cErro

		Method New() Constructor
		Method IncluirPr() // Inclui titulo provisorio para geração do boleto bancario
		Method BaixarPr() // Baixa titulo provisorio com motivo "CONTRATO" no retorno do cnab, sem movimento bancario
		Method TituloPr(cNumBco) // Verifica se é um titulo provisoriso
		Method TituloRecBan(aParam) // Verifica se o titulo foi recebido pelo banco
		Method ExistePr(cPrefixo) // Verifica se já existe titulo provisorio para o pedido de venda
		Method BoletoPr(dEmissao, cCliente, cLoja, cNumPed, lReenv, cNumBor) // Gera boleto com titulo provisorio
		Method RetNumBol(cPrefixo) // Retorna numero do boleto
		Method ValidaBor(nTipo, cBanBor, cAgeBor, cConBor) // Valida geração de bordero, somente serao aceitos borderos para os bancos/agencias/contas pre-definidos
		Method RetNumTit(cPrefixo) // Retorna numero do titulo por cliente
		Method RetDtVenBol() // Retorna data de vencimento do boleto, leva em consideração o prazo de 3 dias uteis - REVENDA (C6_ENTREG), ENGENHARIA (C6_YDTNECE)
		Method RetDtEntPed() // Retorna maior data de entrega do pedido
		Method DadosPed() //informacoes do pedido
		Method RetAgeCon() // Retorna agencia e conta correta por banco
		Method TarifaBco(nTarifa,cBanTit,cAgeTit,cConTit,cPreTit,cNmTit,cParTit,cTpTit,cCliTit,cLjTit,dDtCred) // Gera tarifa bancaria referente ao envio de cobranca, utilizada somente para liquidacao sem registro (Ocorrencia 05)
		Method RetDtVenTit(cNumPed, cEmpTit) // Retorna data de vencimento do tituto
		Method CalcJuros(cPrefixo, dDtVen, dDtRec, nValor, nPerJur) // Calcula juros simples a partir percentual de juros por dias de atraso - Somente para Contratos
		Method LancContJur() // Inclui lancamento contabil de juros sobre titulo
		Method PedidoRodape() // Verifica se o pedido é de rodape
		Method RetDtPedRod() // Retorna data de emissao do pedido de rodape
		Method RetDesconto(cPrefixo, cNumero, cParcela, cTipo, cCliente) // Retorna valor de desconto sobre o título

	EndClass


Method New() Class TRecebimentoAntecipado

	::cNumPed := ""
	::cNossoNum := ""
	::nVlJuros := 0

	::lJob := .F.

	::oConRecBx := Nil
	::oConRecRa := Nil
	::cErro := ""

Return()


Method IncluirPr() Class TRecebimentoAntecipado
	Local lRet := .F.
	Local aArea := GetArea()
	Local oConRec := TContaReceber():New()
	Local cParCon := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
	Local nMaxPar	:= GetMv("MV_NUMPARC", .F., 12)
	Local cParFin := "A"
	Local cNumTitCT := ""
	Local nCount := 0
	Local cCpoVal := ""
	Local cCpoDat := ""

	DbSelectArea("SC5")
	DbSetOrder(1)
	If SC5->(DbSeek(xFilial("SC5") + ::cNumPed))

		// Se a condição de pagamento do pedido for RA, gera o titulo provisorio
		If U_fValidaRA(SC5->C5_CONDPAG) .And. !::ExistePr("PR")

			oConRec:cPrefixo := "PR" + SC5->C5_YLINHA
			oConRec:cNumero	:= ::RetNumTit("PR")
			oConRec:cParcela := ""
			oConRec:cTipo := "BOL"
			oConRec:cNatureza	:= "1121"
			oConRec:cCliente := SC5->C5_CLIENTE
			oConRec:cLoja := SC5->C5_LOJACLI
			oConRec:dEmissao := dDataBase
			oConRec:dVencto := ::RetDtVenBol()
			oConRec:nValor := SC5->C5_YVLTOTP
			oConRec:cClasse := "6"
			oConRec:cNumPed := SC5->C5_NUM
			oConRec:cVend1 := SC5->C5_VEND1

			oConRec:Incluir()

			::BoletoPr(oConRec:dEmissao, oConRec:cCliente, oConRec:cLoja, oConRec:cNumPed)

			// Pedido de Contrato
		ElseIf SC5->C5_YFORMA == "4" .And. !::ExistePr("CT")

			DbSelectArea("Z60")
			DbSetOrder(1)
			If Z60->(DbSeek(xFilial("Z60") + ::cNumPed))

				cNumTitCT := ::RetNumTit("CT")

				For nCount := 1 To nMaxPar

					cCpoVal := "Z60_PARC" + SubStr(cParCon, nCount, 1)
					cCpoDat := "Z60_DATA" + SubStr(cParCon, nCount, 1)

					If !Empty(Z60->&(cCpoVal)) .And. !Empty(Z60->&(cCpoDat))

						oConRec:cPrefixo := "CT" + SC5->C5_YLINHA
						oConRec:cNumero := cNumTitCT
						oConRec:cParcela := cParFin
						oConRec:cTipo := "BOL"
						oConRec:cNatureza	:= "1121"
						oConRec:cCliente := SC5->C5_CLIENTE
						oConRec:cLoja := SC5->C5_LOJACLI
						oConRec:dEmissao := dDataBase
						oConRec:dVencto := Z60->&(cCpoDat)
						oConRec:nValor := Z60->&(cCpoVal)
						oConRec:nPerJur := 0.2
						oConRec:cClasse := "2"
						oConRec:cNumPed := SC5->C5_NUM
						oConRec:cVend1 := SC5->C5_VEND1

						oConRec:Incluir()

						cParFin := Soma1(cParFin, 1)

					EndIf

				Next

				::BoletoPr(oConRec:dEmissao, oConRec:cCliente, oConRec:cLoja, oConRec:cNumPed)

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return(lRet)


Method TituloRecBan(aParam) Class TRecebimentoAntecipado
	Local lRet := .F.
	Local cNumBco	:= aParam[1][4] // Numero do Banco (Nosso Numero)
	Local nTarifa	:= aParam[1][5]	// Tarifa Bancária
	Local nVlrDes := aParam[1][6]	// Valor de desconto
	Local nVlrRec := aParam[1][8]	// Valor recebido
	Local dCredito := aParam[1][13]	// Data do credito
	Local cOcor := AllTrim(aParam[1][14]) // Ocorrencia
	Local cSE1 := RetSQLName("SE1")

	If ::TituloPr(cNumBco)

		// 05 - Liquidacao sem registro, 06 - Liquidacao normal
		If cOcor $ "05/06/15"

			lRet := .T.

			cSQL :=	" UPDATE "+ cSE1
			cSQL += " SET	E1_YRECANT = 'S' "
			cSQL += " ,E1_YDTCRED = "+ ValToSQL(dCredito)

			// Tratamento para efetuar a baixa do valor que realmente foi recebido
			If nVlrDes > 0
				cSQL += " ,E1_DECRESC = "+ ValToSQL(nVlrDes)
				cSQL += " ,E1_SDDECRE = "+ ValToSQL(nVlrDes)
			EndIf

			If nTarifa > 0
				cSQL += " ,E1_YTFCBPR = "+ ValToSQL(nTarifa)
			EndIf

			cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
			cSQL += " AND E1_NUMBCO = "+ ValToSQL(cNumBco)
			cSQL += " AND D_E_L_E_T_ = '' "

			TcSQLExec(cSQL)

		EndIf

	EndIf

Return(lRet)


Method TituloPr(cNumBco) Class TRecebimentoAntecipado
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSE1 := RetSQLName("SE1")
	Default cNumBco := ""

	If !Empty(cNumBco)

		cSQL := " SELECT E1_TIPO, E1_PREFIXO, E1_PEDIDO "
		cSQL += " FROM " + cSE1
		cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
		cSQL += " AND E1_TIPO = 'BOL' "
		cSQL += " AND E1_NUMBCO = " + ValToSQL(cNumBco)
		cSQL += " AND D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		If (cQry)->E1_TIPO == "BOL" .And. SubStr((cQry)->E1_PREFIXO, 1, 2) $ "PR/CT" .And. !Empty((cQry)->E1_PEDIDO)
			lRet := .T.
		EndIf

		(cQry)->(DbCloseArea())

	Else

		If SE1->E1_TIPO == "BOL" .And. SubStr(SE1->E1_PREFIXO, 1, 2) $ "PR/CT" .And. !Empty(SE1->E1_PEDIDO)
			lRet := .T.
		EndIf

	EndIf

Return(lRet)


Method BaixarPr() Class TRecebimentoAntecipado
	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSE1 := RetSQLName("SE1")
	Local cSEA := RetSQLName("SEA")
	Local nDesconto := 0

	Private xfDtCtba

	::oConRecBx := TContaReceber():New()
	::oConRecRa := TContaReceber():New()

	::cErro := ""

	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, (E1_VALOR + E1_ACRESC - E1_DECRESC) AS E1_VALOR, E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_NUMBOR, E1_NUMBCO, E1_YDTCRED, E1_NATUREZ, E1_CLIENTE, E1_LOJA, "
	cSQL += " E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_PORCJUR, E1_PEDIDO, E1_VEND1, E1_COMIS1, E1_YTFCBPR, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + cSE1
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND SUBSTRING(E1_PREFIXO, 1, 2) IN ('PR', 'CT')	"
	cSQL += " AND SUBSTRING(E1_PREFIXO, 3, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9') "
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND E1_SALDO > 0 "
	cSQL += " AND E1_PEDIDO <> '' "
	cSQL += " AND E1_NUMBCO <> '' "
	cSQL += " AND E1_YRECANT = 'S' "

	If !Empty(::cNossoNum)

		cSQL += " AND ((E1_NUMBCO = " + ValToSQL(::cNossoNum) + ")"
		cSQL += " OR (E1_NUMBCO = LEFT(" + ValToSQL(::cNossoNum) + ", Len(" + ValToSQL(::cNossoNum) + ")-1)))

	EndIf

	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		Begin Transaction

			// Somente altera o titulo provisorio quando o mesmo foi registrado no banco
			If !Empty((cQry)->E1_NUMBOR)

				// Remove referencia do bordero
				cSQL :=	" UPDATE "+ cSEA
				cSQL += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
				cSQL += " WHERE EA_FILIAL = " + ValToSQL(xFilial("SEA"))
				cSQL += " AND EA_NUMBOR = "+ ValToSQL((cQry)->E1_NUMBOR)
				cSQL += " AND EA_PREFIXO = "+ ValToSQL((cQry)->E1_PREFIXO)
				cSQL += " AND EA_NUM = "+ ValToSQL((cQry)->E1_NUM)
				cSQL += " AND EA_PARCELA = "+ ValToSQL((cQry)->E1_PARCELA)
				cSQL += " AND EA_TIPO = "+ ValToSQL((cQry)->E1_TIPO)
				cSQL += " AND D_E_L_E_T_ = '' "

				TcSQLExec(cSQL)

				// Limpa os campos refentes a carteira e ao banco quando o titulo esta em bordero
				cSQL :=	" UPDATE "+ cSE1
				cSQL += " SET E1_SITUACA = '0' "
				cSQL += " ,E1_PORTADO = '' "
				cSQL += " ,E1_AGEDEP = '' "
				cSQL += " ,E1_CONTA = '' "
				cSQL += " ,E1_MOVIMEN = " + ValToSQL(dDataBase)
				cSQL += " ,E1_NUMBOR = '' "
				cSQL += " ,E1_DATABOR = '' "
				cSQL += " ,E1_NUMBCO = '' "
				cSQL += " ,E1_YNUMBCO = "+ ValToSQL((cQry)->E1_NUMBCO)
				cSQL += " ,E1_VEND1 = '' "
				cSQL += " ,E1_COMIS1 = 0 "
				cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
				cSQL += " AND E1_NUMBCO = "+ ValToSQL((cQry)->E1_NUMBCO)
				cSQL += " AND D_E_L_E_T_ = '' "

				TcSQLExec(cSQL)

			EndIf

			// Baixa titulo provisorio na carteira de contrato
			::oConRecBx:cPrefixo := (cQry)->E1_PREFIXO
			::oConRecBx:cNumero := (cQry)->E1_NUM
			::oConRecBx:cParcela := (cQry)->E1_PARCELA
			::oConRecBx:cTipo := (cQry)->E1_TIPO
			::oConRecBx:cMotBx := "BOL" // Contrato, sem movimento bancario
			::oConRecBx:cBanco := ""
			::oConRecBx:cAgencia := ""
			::oConRecBx:cConta := ""
			::oConRecBx:dBaixa := dDataBase
			::oConRecBx:dCredito := sToD((cQry)->E1_YDTCRED)

			// Se tiver baixando um titulo especifico via baixa automatica API, considerar o Juros enviado pelo Banco - Projeto TAF - Fernando em 08/02/2019
			If !Empty(::cNossoNum)

				::oConRecBx:nJuros := ::nVlJuros

			Else

				::oConRecBx:nJuros := ::CalcJuros((cQry)->E1_PREFIXO, sToD((cQry)->E1_VENCTO), dDataBase, (cQry)->E1_VALOR, (cQry)->E1_PORCJUR)

			EndIf

			// Retorna valor de desconto sobre o título
			nDesconto := 0
			nDesconto := ::RetDesconto((cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, (cQry)->E1_TIPO, (cQry)->E1_CLIENTE)

			::oConRecBx:nValor := (cQry)->E1_VALOR - nDesconto

			// Baixa o titulo provisorio
			If ::oConRecBx:Baixar()

				// Tiago Rossini Coradini - 23/02/2016 - OS: 0361-16 - Clebes Jose
				// 1.1 - Verifica se o título possui juros, caso possua, baixa o juros e adiciona lançamento contábil - Somente para Contratos (CT)
				If ::oConRecBx:nJuros > 0 .And. SubStr(::oConRecBx:cPrefixo, 1, 2) == "CT"

					// Associa o banco de recebimento e efetua a baixa do juro sobre o titulo de contrato (CT)
					::oConRecBx:cMotBx := "NOR" // Normal, associado ao Banco de origem, pois necessita ser conciliado
					::oConRecBx:cBanco := (cQry)->E1_PORTADO
					::oConRecBx:cAgencia := (cQry)->E1_AGEDEP
					::oConRecBx:cConta := (cQry)->E1_CONTA
					::oConRecBx:nValor := ::oConRecBx:nJuros
					::oConRecBx:nJuros := 0

					// Baixa juros sobre o titulo
					If !::oConRecBx:Baixar()

						::cErro += ::oConRecBx:cErro + CRLF + CRLF

						lRet := .F.

					EndIf

					// Inclui lancamento contabil de juros sobre titulo
					::LancContJur()

				EndIf

				// Inclui titulo de RA referente ao titulo provisorio
				::oConRecRa:cPrefixo := "RA" + SubStr((cQry)->E1_PREFIXO, 3, 1)
				::oConRecRa:cNumero := (cQry)->E1_NUM
				::oConRecRa:cParcela := (cQry)->E1_PARCELA
				::oConRecRa:cTipo := "RA"
				::oConRecRa:cBanco := (cQry)->E1_PORTADO
				::oConRecRa:cAgencia := (cQry)->E1_AGEDEP
				::oConRecRa:cConta := (cQry)->E1_CONTA
				::oConRecRa:cNumBco := (cQry)->E1_NUMBCO
				::oConRecRa:cNatureza := (cQry)->E1_NATUREZ
				::oConRecRa:cCliente := (cQry)->E1_CLIENTE
				::oConRecRa:cLoja := (cQry)->E1_LOJA
				::oConRecRa:dEmissao := sToD((cQry)->E1_YDTCRED)
				::oConRecRa:dVencto := sToD((cQry)->E1_YDTCRED)

				// Se o prefixo for PR e o recebimento possui juros, soma o valor do titulo mais o juros
				::oConRecRa:nValor := ((cQry)->E1_VALOR - nDesconto) + If (SubStr(::oConRecBx:cPrefixo, 1, 2) == "PR", ::oConRecBx:nJuros, 0)

				::oConRecRa:cNumPed := (cQry)->E1_PEDIDO
				::oConRecRa:cVend1 := (cQry)->E1_VEND1

				If !::oConRecRa:Incluir(.T.)

					::cErro += ::oConRecRa:cErro + CRLF + CRLF

					lRet := .F.

				EndIf

				// Atualiza campo de processameno de RA, para não baixar novamente
				cSQL :=	" UPDATE "+ cSE1
				cSQL += " SET E1_YRECANT = 'N' "
				cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
				cSQL += " AND R_E_C_N_O_ = "+ ValToSQL((cQry)->RecNo)
				cSQL += " AND D_E_L_E_T_ = '' "

				TcSQLExec(cSQL)

			Else

				::cErro += ::oConRecBx:cErro + CRLF + CRLF

				lRet := .F.

			EndIf

		End Transaction

		(cQry)->(DbSkip())

		d1AuxData := dDataBase

		// Altera database para contabilizar na data de credito
		dDataBase := SE1->E1_EMIS1
		xfDtCtba := SE1->E1_EMIS1

		// Adiciona linha ao lancamento contabil
		nTotal := DetProva(nHdlPrv, "520", "FINA200", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)

		// Calcula rodape do lancamento contabil
		RodaProva(nHdlPrv, nTotal)

		// Grava lancamento contabil
		cA100Incl(cArquivo, nHdlPrv, 3, cLote, .F., .F.)

		// Restaura database
		dDataBase := d1AuxData

	EndDo

	(cQry)->(DbCloseArea())

	If (!::lJob)

		fViewCTB()

	EndIf

Return(lRet)


Method RetNumTit(cPrefixo) Class TRecebimentoAntecipado
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSE1 := RetSQLName("SE1")
	Local cNumTit := ""

	cSQL := " SELECT ISNULL(MAX(E1_NUM), '000000000') AS E1_NUM "
	cSQL += " FROM " + cSE1
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_PREFIXO = " + ValToSQL(cPrefixo + SC5->C5_YLINHA)
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	cNumTit := Soma1((cQry)->E1_NUM)

	(cQry)->(DbCloseArea())

Return(cNumTit)


Method RetDtVenBol() Class TRecebimentoAntecipado

	Local dRet := ::RetDtEntPed()

	/* 
	// Mundaça da regra: ticket: 31884 em 12/07/2021
	Local dRet := dDataBase

	If ::PedidoRodape()

		dRet := ::RetDtPedRod()

	Else

		dRet := ::RetDtEntPed()

	EndIf
	*/

Return(dRet)


Method DadosPed() Class TRecebimentoAntecipado
	Local aArea	:= GetArea()
	Local cRet := {"", "", ""}
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT CONDPAG=C5_CONDPAG, EMISSAO=C5_EMISSAO, TPSEG=A1_YTPSEG, A1CGC=A1_CGC "
	cSQL += " FROM " + RetSQLName("SC5") +" SC5"
	cSQL += " INNER JOIN " +  RetSQLName("SA1") +" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND  SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''"
	cSQL += " WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))+""
	cSQL += " AND C5_NUM = " + ValToSQL(::cNumPed)+""
	cSQL += " AND SC5.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !(cQry)->(Eof())

		cRet := { (cQry)->CONDPAG, (cQry)->TPSEG, (cQry)->EMISSAO , (cQry)->A1CGC  }

	EndIf

	RestArea(aArea)

Return(cRet)


Method RetDtEntPed() Class TRecebimentoAntecipado

	Local dRet      := dDataBase
	Local aDadosPed := {}
	Local nCount    := 0

	aDadosPed := ::DadosPed()

	//aDadosPed[1] CondPag
	//aDadosPed[2] TpSeg
	//aDadosPed[3] Emissao
	//aDadosPed[4] CNPJ/CPF DO CLIENTE
	If (aDadosPed[1] $ '000_208' .And. (aDadosPed[2] $ 'E_R')  .OR.  u_fValFunc(aDadosPed[4]))

		dRet := DaySum(dRet, 7)

		If dRet <> DataValida(dRet, .T.)

			dRet := DataValida(dRet, .T.)

		EndIf

	Else // Não identificamos um cenário para uso da regra abaixo

		For nCount := 1 To 3

			dRet := DaySum(dRet, 1)

			If dRet <> DataValida(dRet, .T.)

				dRet := DataValida(dRet, .T.)

			EndIf

		Next

	EndIf

Return(dRet)


Method PedidoRodape() Class TRecebimentoAntecipado
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(C5_NUM, '') AS C5_NUM "
	cSQL += " FROM " + RetSQLName("SC5") + " SC5 "
	cSQL += " INNER JOIN " + RetSQLName("SC6") + " SC6 "
	cSQL += " ON C5_FILIAL = C6_FILIAL "
	cSQL += " AND C5_NUM = C6_NUM "
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 "
	cSQL += " ON C6_PRODUTO = B1_COD "
	cSQL += " WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))
	cSQL += " AND C5_NUM = " + ValToSQL(::cNumPed)
	cSQL += " AND C5_CONDPAG = '000' "
	cSQL += " AND B1_FILIAL = " + ValToSQL(xFilial("SB1"))
	cSQL += " AND B1_YPCGMR3 = 'E' "
	cSQL += " AND SC5.D_E_L_E_T_ = '' "
	cSQL += " AND SC6.D_E_L_E_T_ = '' "
	cSQL += " AND SB1.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->C5_NUM)

		lRet := .T.

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)


Method RetDtPedRod() Class TRecebimentoAntecipado
	Local dRet := SC5->C5_EMISSAO
	Local nCount := 0

	If dRet < dDataBase
		dRet := dDataBase
	EndIf

	For nCount := 1 To 7

		dRet := DaySum(dRet, 1)

		If dRet <> DataValida(dRet, .T.)

			dRet := DataValida(dRet, .T.)

		EndIf

	Next

Return(dRet)


Method ExistePr(cPrefixo) Class TRecebimentoAntecipado
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSE1 := RetSQLName("SE1")

	cSQL := " SELECT COUNT(E1_PEDIDO) AS COUNT, E1_NUMBOR "
	cSQL += " FROM " + cSE1
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_PREFIXO = " + ValToSQL(cPrefixo + SC5->C5_YLINHA)
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND E1_CLIENTE = " + ValToSQL(SC5->C5_CLIENTE)
	cSQL += " AND E1_LOJA = " + ValToSQL(SC5->C5_LOJACLI)
	cSQL += " AND E1_PEDIDO = " + ValToSQL(SC5->C5_NUM)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E1_NUMBOR "

	TcQuery cSQL New Alias (cQry)

	If (lRet := (cQry)->COUNT > 0)

		::BoletoPr(SC5->C5_EMISSAO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_NUM, !Empty((cQry)->E1_NUMBOR), (cQry)->E1_NUMBOR)

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)


Method BoletoPr(dEmissao, cCliente, cLoja, cNumPed, lReenv, cNumBor) Class TRecebimentoAntecipado
	Local oObj := Nil

	Default lReenv := .F.
	Default cNumBor := ""

	oObj := TAFRemessaReceber():New()

	oObj:oMrr:dEmissaoDe := dEmissao
	oObj:oMrr:dEmissaoAte := dEmissao
	oObj:oMrr:nDia := 0
	oObj:oMrr:cCliente := cCliente
	oObj:oMrr:cLoja := cLoja
	oObj:oMrr:cPedido := cNumPed

	If lReenv

		oObj:oMrr:lReenvBord := .T.
		oObj:oMrr:cBorDe := cNumBor
		oObj:oMrr:cBorAte := cNumBor

	EndIf

	oObj:Send()

Return()


Method ValidaBor(nTipo, cBanBor, cAgeBor, cConBor) Class TRecebimentoAntecipado
	Local lRet := .T.
	Local cBanco := ""
	Local cAgencia := ""
	Local cConta := ""

	// 4=BOL, 5=RA
	If nTipo == 4 .Or. nTipo == 5

		If cEmpAnt == "01"

			cBanco := "001"
			cAgencia := "34312"
			cConta := "55.097-3"

		ElseIf cEmpAnt == "05"

			cBanco := "001"
			cAgencia := "34312"
			cConta := "5.666-9"

		ElseIf cEmpAnt == "07"

			cBanco := "001"
			cAgencia := "34312"
			cConta := "52868"

		ElseIf cEmpAnt == "14"

			cBanco := "001"
			cAgencia := "3431"
			cConta := "48755"

		EndIf

		If cBanco <> AllTrim(cBanBor) .Or. cAgencia <> AllTrim(cAgeBor) .Or. cConta <> AllTrim(cConBor)

			lRet := .F.

			MsgAlert("Atenção, banco/agência/conta inválidos para a operação de RA, favor conferir o banco informado no borderô!")

		EndIf

	EndIf

Return(lRet)


Method RetNumBol() Class TRecebimentoAntecipado
	Local aNumBol := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSE1 := RetSQLName("SE1")

	cSQL := " SELECT E1_NUMBCO "
	cSQL += " FROM " + cSE1
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_TIPO = 'BOL' "
	cSQL += " AND E1_CLIENTE = " + ValToSQL(SC5->C5_CLIENTE)
	cSQL += " AND E1_PEDIDO = " + ValToSQL(SC5->C5_NUM)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aAdd(aNumBol, (cQry)->E1_NUMBCO)

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return(aNumBol)


Method TarifaBco(nTarifa,cBanTit,cAgeTit,cConTit,cPreTit,cNmTit,cParTit,cTpTit,cCliTit,cLjTit,dDtCred) Class TRecebimentoAntecipado
	Local dAuxData := dDataBase

	//Posiciona o banco para que o lancamento contabil identifique a conta de credito
	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial("SA6")+cBanTit+cAgeTit+cConTit))

	// Cria movimento bancario
	Reclock("SE5", .T.)
	SE5->E5_FILIAL := xFilial("SE5")
	SE5->E5_DATA := Stod(dDtCred) //dBaixa
	SE5->E5_VALOR	:= nTarifa
	SE5->E5_NATUREZ	:= '2915'
	SE5->E5_HISTOR := 'TAR. ENVIO COBRANCA '+Alltrim(cNmTit)+" "+Alltrim(cParTit)
	SE5->E5_RECPAG := "P"
	SE5->E5_DTDIGIT	:= Stod(dDtCred) //dDataBase
	SE5->E5_BANCO	:= cBanTit
	SE5->E5_AGENCIA	:= cAgeTit
	SE5->E5_CONTA	:= cConTit
	SE5->E5_DTDISPO	:= Stod(dDtCred) //dDataCred
	SE5->E5_CNABOC := "05"
	SE5->E5_TIPODOC	:= "DB"
	SE5->E5_MOTBX	:= "NOR"
	SE5->E5_PREFIXO	:= cPreTit
	SE5->E5_NUMERO := cNmTit
	SE5->E5_PARCELA	:= cParTit
	SE5->E5_TIPO := cTpTit
	SE5->E5_CLIFOR := cCliTit
	SE5->E5_LOJA := cLjTit
	SE5->E5_CLVLDB := U_BIA478G("ZJ0_CLVLDB", SE5->E5_NATUREZ, "P")
	SE5->E5_CCD	:= '1000'
	SE5->E5_FILORIG	:= cFilAnt
	SE5->(MsUnlock())

	// Preenche variaveis internas da rotina FINA200
	cBanco := cBanTit
	cAgencia := cAgeTit
	cConta := cConTit

	// Atualiza saldo bancario
	AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DATA, SE5->E5_VALOR, "-")

	// Altera database para contabilizar na data de credito
	dDataBase := Stod(dDtCred)

	// Adiciona linha ao lancamento contabil
	nTotal := DetProva(nHdlPrv, "562", "FINA200", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)

	// Calcula rodape do lancamento contabil
	RodaProva(nHdlPrv, nTotal)

	// Grava lancamento contabil
	cA100Incl(cArquivo, nHdlPrv, 3, cLote, .F., .F.)

	// Restaura database
	dDataBase := dAuxData

Return()


Method RetDtVenTit(cNumPed, cEmpTit) Class TRecebimentoAntecipado
	Local cDtVenRea := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSE1 := RetSQLName("SE1")

	If !Empty(cEmpTit)
		cSE1 := "SE1"+AllTrim(cEmpTit)+"0"
	EndIf

	If !Empty(cNumPed)

		cSQL := " SELECT E1_VENCREA "
		cSQL += " FROM " + cSE1
		cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
		cSQL += " AND SUBSTRING(E1_PREFIXO, 1, 2) IN ('PR', 'CT')	"
		cSQL += " AND SUBSTRING(E1_PREFIXO, 3, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9') "
		cSQL += " AND E1_TIPO = 'BOL' "
		cSQL += " AND E1_PEDIDO = "+ ValToSQL(cNumPed)
		cSQL += " AND D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		If !(cQry)->(Eof())

			cDtVenRea := (cQry)->E1_VENCREA

		Else

			cDtVenRea := ""

		EndIf

		(cQry)->(DbCloseArea())

	EndIf

Return(cDtVenRea)


Method CalcJuros(cPrefixo, dDtVen, dDtRec, nValor, nPerJur) Class TRecebimentoAntecipado
	Local nRet := 0
	Local nDia := 0

	Default nPerJur := 0.2

	// Calcula juros
	If dDtVen < dDtRec

		// Dias de vencido
		nDia := DateDiffDay(dDtVen, dDtRec)

		nRet := NoRound(nValor * nPerJur / 100) * nDia

	EndIf

Return(nRet)


Method LancContJur() Class TRecebimentoAntecipado
	Local dAuxData := dDataBase

	// Altera database para contabilizar na data de credito
	dDataBase := SE1->E1_YDTCRED

	// Adiciona linha ao lancamento contabil
	nTotal := DetProva(nHdlPrv, "520", "FINA200", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)

	// Calcula rodape do lancamento contabil
	RodaProva(nHdlPrv, nTotal)

	// Grava lancamento contabil
	cA100Incl(cArquivo, nHdlPrv, 3, cLote, .F., .F.)

	// Restaura database
	dDataBase := dAuxData

Return()


Static Function fViewCTB()
	Private oDlgCT2
	Private oButtonCT2
	Private oSay1
	Private xftVlrLnt := 0

	DEFINE MSDIALOG oDlgCT2 TITLE "Confirmação da Contabilização do RA" FROM 000, 000  TO 450, 960 COLORS 0, 16777215 PIXEL

	fGetDataCTB()

	@ 202, 007 SAY oSay1 PROMPT "Valor Total do Lançamento: " + Transform(xftVlrLnt, "@E 999,999,999.99") SIZE 159, 007 OF oDlgCT2 COLORS 0, 16777215 PIXEL
	@ 201, 435 BUTTON oButtonCT2 PROMPT "Fechar" SIZE 037, 012 OF oDlgCT2 ACTION oDlgCT2:End() PIXEL

	ACTIVATE MSDIALOG oDlgCT2

Return


Static Function fGetDataCTB()
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"CT2_DATA","CT2_LOTE","CT2_SBLOTE","CT2_DOC","CT2_LINHA","CT2_VALOR","CT2_YHIST"}
	Local aAlterFields := {"CT2_DATA","CT2_LOTE","CT2_SBLOTE","CT2_DOC","CT2_LINHA","CT2_VALOR","CT2_YHIST"}
	Private oGetCTB

	// Define field properties
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)

		If SX3->(dbSeek(aFields[nX]))

			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

		Endif

	Next nX

	RT002 := " SELECT CT2_DATA, "
	RT002 += "        CT2_LOTE, "
	RT002 += "        CT2_SBLOTE, "
	RT002 += "        CT2_DOC, "
	RT002 += "        CT2_LINHA, "
	RT002 += "        CT2_YHIST, "
	RT002 += "        CT2_VALOR "
	RT002 += "   FROM " + RetSqlName("CT2") +  " "
	RT002 += "  WHERE CT2_FILIAL = '" + xFilial("CT2")+ "' "
	RT002 += "    AND CT2_DATA = '" + dtos(xfDtCtba)+ "' "
	RT002 += "    AND CT2_LOTE = '008850' "
	RT002 += "    AND CT2_ROTINA IN ('FINA040', 'FINA740') "
	RT002 += "    AND CT2_LP LIKE '501' "
	RT002 += "    AND CT2_YHIST LIKE '%RA%' "
	RT002 += "    AND CT2_DC <> '4' "
	RT002 += "    AND D_E_L_E_T_ = ' ' "
	RT002 += "  ORDER BY R_E_C_N_O_ "

	RTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT002),'RT02',.T.,.T.)

	dbSelectArea("RT02")
	dbGoTop()

	ct2Regs := .F.

	While !Eof()

		ct2Regs := .T.

		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := stod(RT02->CT2_DATA)
		aColsEx[Len(aColsEx), 2] := RT02->CT2_LOTE
		aColsEx[Len(aColsEx), 3] := RT02->CT2_SBLOTE
		aColsEx[Len(aColsEx), 4] := RT02->CT2_DOC
		aColsEx[Len(aColsEx), 5] := RT02->CT2_LINHA
		aColsEx[Len(aColsEx), 6] := RT02->CT2_VALOR
		aColsEx[Len(aColsEx), 7] := RT02->CT2_YHIST
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.

		xftVlrLnt += RT02->CT2_VALOR

		dbSelectArea("RT02")

		dbSkip()

	End

	RT02->(dbCloseArea())
	Ferase(RTIndex+GetDBExtension())
	Ferase(RTIndex+OrdBagExt())

	If !ct2Regs

		DbSelectArea("SX3")
		SX3->(DbSetOrder(2))

		For nX := 1 to Len(aFields)

			If DbSeek(aFields[nX])

				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))

			Endif

		Next nX

		Aadd(aFieldFill, .F.)

		Aadd(aColsEx, aFieldFill)

	EndIf

	oGetCTB := MsNewGetDados():New( 006, 007, 194, 473, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgCT2, aHeaderEx, aColsEx)

Return()


Method RetDesconto(cPrefixo, cNumero, cParcela, cTipo, cCliente) Class TRecebimentoAntecipado
	Local nRet := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(SUM(E5_VALOR), 0) AS E5_VALOR "
	cSQL += " FROM " + RetSQLName("SE5")
	cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))
	cSQL += " AND E5_PREFIXO = " + ValToSQL(cPrefixo)
	cSQL += " AND E5_NUMERO = " + ValToSQL(cNumero)
	cSQL += " AND E5_PARCELA = " + ValToSQL(cParcela)
	cSQL += " AND E5_TIPO = " + ValToSQL(cTipo)
	cSQL += " AND E5_CLIFOR = " + ValToSQL(cCliente)
	cSQL += " AND E5_TIPODOC = 'DC' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->E5_VALOR

	(cQry)->(DbCloseArea())

Return(nRet)