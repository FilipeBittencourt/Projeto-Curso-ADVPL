#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINAvaliaBloqueioPedidoController
@description Classe para avaliacao de regras e se é para bloquear / liberar
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/
Class TINAvaliaBloqueioPedidoController From LongClassName

	Data lRegra01		//Retorno se a Regra 1 foi verificada
	Data lRegra02		//Retorno se a Regra 2 foi verificada
	Data lRegra03		//Retorno se a Regra 3 foi verificada
	Data lRegra04		//Retorno se a Regra 4 foi verificada
	Data lRegra05		//Retorno se a Regra 5 foi verificada
	Data lPermite		//Flag que define se permite ou não continuar a digitacao do Pedido
	Data cRetorno
	
	Data cVendedor
	Data cCodOper
	Data cNumPedido
	Data nVlrVenda
	Data cObserv //UA_YOBS3

	Method New()
	Method WrapRegra()  //Avaliar todas as regras conforme dados do pedido.
	Method Regra01()
	Method Regra02()
	Method Regra03()
	Method Regra04()
	Method Regra05()
	Method Neurotech()
	Method LibCredPV()


EndClass



//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe
@author  Pontin
@since   18.12.18
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class TINAvaliaBloqueioPedidoController

	::nVlrVenda	 := 0
	::cVendedor   := ""
	::cCodOper   := ""
	::cNumPedido := ""
	::nVlrVenda  := ""
	::cObserv := ""

Return Self

/*/{Protheus.doc} AvPermIncl
@description Avaliar se permite a inclusao de pedido / se bloqueia ou se libera
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
@type function
/*/
Method WrapRegra(oClienteM) Class TINAvaliaBloqueioPedidoController

	// Iniciando com .F. pois se os retornos das regras forem verdadeiras, siginifica que teve problemas.
	::lRegra01 := .F.
	::lRegra02 := .F.
	::lRegra03 := .F.
	::lRegra04 := .F.
	::lRegra05 := .F.

    ::lPermite := .T.  // Permite se o processo poderá seguir
	::cRetorno := ""

	// ---- Fazendo dessa Forma para pegar todos os casos possiveis, para exibir todos os problemas que o cliente poderá ter ----

	//  Regra 01: Cadastro do cliente revisado por mais de 6 meses (controle por campo de data)
	If (::Regra01(oClienteM))
		::lRegra01 := .T.
		::lPermite := .F.
		::cRetorno += "Regra 01 -> Cliente com mais de 6 meses sem revisão de cadastro." + CRLF +;
						"Cliente: " + oClienteM:cCodigo + " - " + oClienteM:cNome + CRLF +;
						"Última Revisão: " + DtoC(oClienteM:dRevisao) + CRLF + CRLF						
 	EndIf

	 
	If oClienteM:cAvista == "S"
		::cRetorno += "CLIENTE A VISTA: Salve o pedido com uma opção diferente de FATURAMENTO e considerar abrir um chamado no OCOMON. Solicitando crédito para data vigente da venda a vista com o valor do pedido." + CRLF + CRLF
		// Regra 2: Limite de credito (Saldo) < Valor do Pedido		 
		If (::Regra02(oClienteM))
			::lRegra02 := .T.
			::lPermite := .F.
			::cRetorno += "Regra 02 -> Limite de Crédito é inferior ao valor da venda." + CRLF +;
							"Cliente: " + oClienteM:cCodigo + " - " + oClienteM:cNome + CRLF +;							
							"Valor total da venda: " + AllTrim(Transform(::nVlrVenda,"@R 999,999,999.99"))+ CRLF + CRLF
							
		EndIf

		// Regra 3: Data do limite de crédito vencida
		If (::Regra03(oClienteM))
			::lRegra03 := .T.
			::lPermite := .F.
			::cRetorno += "Regra 03 -> Limite de crédito vencido." + CRLF +;
							"Cliente: " + oClienteM:cCodigo + " - " + oClienteM:cNome + CRLF +;
							"Vencimento Limite de Crédito: " + DtoC(oClienteM:dCredVenc) + CRLF + CRLF
							
		EndIf
		 
	Else

		// Regra 2: Limite de credito (Saldo) < Valor do Pedido
		If (::Regra02(oClienteM))
			::lRegra02 := .T.
			::lPermite := .F.
			::cRetorno += "Regra 02 -> Limite de Crédito é inferior ao valor da venda." + CRLF +;
							"Cliente: " + oClienteM:cCodigo + " - " + oClienteM:cNome + CRLF +;
							"Limite de crédito disponível: " + AllTrim(Transform(oClienteM:nLimitCred,"@R 999,999,999.99")) + CRLF +;
							"Valor total da venda: " + AllTrim(Transform(::nVlrVenda,"@R 999,999,999.99")) + CRLF + CRLF
		EndIf

		// Regra 3: Data do limite de crédito vencida
		If (::Regra03(oClienteM))
			::lRegra03 := .T.
			::lPermite := .F.
			::cRetorno += "Regra 03 -> Limite de crédito vencido." + CRLF +;
							"Cliente: " + oClienteM:cCodigo + " - " + oClienteM:cNome + CRLF +;
							"Vencimento Limite de Crédito: " + DtoC(oClienteM:dCredVenc) + CRLF + CRLF
		EndIf

		// Regra 4: Títulos em atraso > Regra do risco do cliente
		If (::Regra04(oClienteM))
			::lRegra04 := .T.
			::lPermite := .F.
			::cRetorno += "Regra 04 -> Títulos em Atraso." + CRLF +;
							"Cliente: " + oClienteM:cCodigo + " - " + AllTrim(oClienteM:cNome) + " possui títulos em atraso." + CRLF + CRLF
		EndIf

		//Regra 5: Cliente cadastrado como parte do grupo econômico.
		If (::Regra05(oClienteM))
			::lRegra05 := .T.
			::lPermite := .F.
			::cRetorno += "Regra 05 -> Limite de crédito do grupo econômico inferior ao valor da venda." + CRLF +;
							"Cliente: " + oClienteM:cCodigo + " - " + oClienteM:cNome + CRLF +;
							"Limite de crédito Grupo Econômico: " + AllTrim(Transform(oClienteM:oGrupoEco:nSaldoGrp,"@R 999,999,999.99")) + CRLF +;
							"Valor total da venda: " + AllTrim(Transform(::nVlrVenda,"@R 999,999,999.99")) + CRLF + CRLF
		EndIf
	EndIf


  
Return Self


// Cadastro do cliente revisado por mais de 6 meses (controle por campo de data)
Method Regra01(oClienteM) Class TINAvaliaBloqueioPedidoController

	If (DateDiffMonth(cValToChar(dDataBase), cValToChar(oClienteM:dRevisao))) >= 6

		Return .T.

	EndIf

Return .F.


// Limite de credito (Saldo) < Valor do Pedido
Method Regra02(oClienteM) Class TINAvaliaBloqueioPedidoController

	If oClienteM:nLimitCred < ::nVlrVenda

		Return .T.

	EndIf

Return .F.

// Data do limite de crédito vencida
Method Regra03(oClienteM) Class TINAvaliaBloqueioPedidoController

	If dDataBase > oClienteM:dCredVenc

		Return .T.

	EndIf

Return .F.


// Títulos em atraso > Regra do risco do cliente
Method Regra04(oClienteM) Class TINAvaliaBloqueioPedidoController

	Local nDiasAtraso	:= 0
	Local cAliasSE1		:= ""
	Local dDataVenc		:= dDataBase



	//|Tratamento de acordo com o risco do cliente |
	If oClienteM:cRisco == "A"
		Return .F.
	ElseIf oClienteM:cRisco == "B"
		nDiasAtraso		:= GetMV("MV_RISCOB")
	ElseIf oClienteM:cRisco $ "C/D"
		nDiasAtraso		:= SuperGetMV("MV_YDATRAS",.F.,2)
	ElseIf oClienteM:cRisco $ "E"
		Return .T.
	EndIf

	cAliasSE1 := GetNextAlias()

	If Select(cAliasSE1) > 0
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbCloseArea())
	EndIf

	dDataVenc	:= DaySub(dDataVenc, nDiasAtraso)

	//|Busca títulos vencidos |
	BeginSql Alias cAliasSE1

		SELECT ISNULL(COUNT(*),0) AS QTD_TIT
		FROM %Table:SE1% SE1
		WHERE SE1.E1_FILIAL = %xFilial:SE1%
			AND SE1.E1_CLIENTE = %Exp:oClienteM:cCodigo%
			AND SE1.E1_LOJA = %Exp:oClienteM:cLoja%
			AND SE1.E1_TIPO NOT IN ('NCC', 'NDC', 'RA', 'AB-')
			AND SE1.E1_SALDO > 0
			AND SE1.E1_VENCREA <= %Exp:dDataVenc%
			AND SE1.%NotDel%

	EndSql

	(cAliasSE1)->(dbGoTop())
	If !(cAliasSE1)->(EoF())

		If (cAliasSE1)->QTD_TIT > 0
			Return .T.
		EndIf

	EndIf

Return .F.


//  Cliente cadastrado como parte do grupo econômico
Method Regra05(oClienteM) Class TINAvaliaBloqueioPedidoController


	//|Verifica se o cliente está em um grupo economico |
	If !Empty(oClienteM:oGrupoEco:cCodigo)

		If oClienteM:oGrupoEco:nSaldoGrp < ::nVlrVenda

			Return .T.

		EndIf

	EndIf

Return .F.