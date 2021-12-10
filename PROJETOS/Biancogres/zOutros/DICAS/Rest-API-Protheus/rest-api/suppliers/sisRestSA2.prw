#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

// Define o Carriage Return (CR) e Line Feed (LF)
// CR = Retorna o carro (referência a maquinas de escrever)
// LF = Alimenta nova linha
#DEFINE CRLF (Chr(13)+Chr(10))

/*
Função: SISRESTSA2
------------------------------------------------------------------------------------------------------------
Escopo     : Webservice (REST)
Descrição  : Operacoes no cadastro de Fornecedores (SA2)
Uso:       : Integração Sisnet Camalion X TOTVS Protheus
Parâmetros : Nenhum
Retorno    : Nulo
------------------------------------------------------------------------------------------------------------
Atualizações:
- 28/07/2017 - Giovani Soares - Construção inicial
------------------------------------------------------------------------------------------------------------
*/
WSRESTFUL SISRESTSA2 DESCRIPTION "Sisnet Solutions - Suppliers Webservice"

	WSDATA count 	AS Integer
	WSDATA codigo 	AS String

	WSMETHOD GET 	DESCRIPTION "Get method" WSSYNTAX "/SISRESTSA2 || /SISRESTSA2/{codigo}"
	WSMETHOD POST 	DESCRIPTION "Post method" WSSYNTAX "/SISRESTSA2/{codigo}"
	WSMETHOD PUT 	DESCRIPTION "Put method" WSSYNTAX "/SISRESTSA2/{codigo}"

END WSRESTFUL

//----------------------------------------
// GET - Consulta de Fornecedores
//----------------------------------------
WSMETHOD GET WSRECEIVE count,codigo WSSERVICE SISRESTSA2

	Local nI := 0
	Local cCodFor := ''
	Local cResponse := ''
	Local lGet := .T.
	Local lSeek := .T.

	Default ::count := 1
	Default ::codigo := '0'

	// Prepara tabela SA2
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbGoTop())

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")

	// Registra no console a chamada do metodo
	conOut('SISRESTSA2 - GET METHOD')

	Do Case

	// 1. Quando ha parametros na URL
	Case Len(::aUrlParms) > 0

		cCodFor := ::aUrlParms[1]
		SA2->(DbSetOrder(1))

		// Valida se o cCodFor existe
		If SA2->(DbSeek(xFilial('SA2')+cCodFor))

			// Monta o retorno do metodo GET
			cResponse := '{' + CRLF
			cResponse += '"response":['
			cResponse += jsStrGetMethod()
			cResponse += ']' + CRLF
			cResponse += '}'

			// Executa o retorno do metodo GET
			::SetResponse(cResponse)

		Else // Tratamento para registro inexistente

			// Retorna mensagem de erro
			lGet := .F.
			SetRestFault(500,'supplier code not found')

		EndIf

	// 2. Quando nao ha parametros na URL
	Case Len(::aUrlParms) == 0

		cCodFor := ::codigo

		// Tratamento quando ha passagem de parametro via query string
		// Neste caso, busca pelo respectivo codigo passado como parametro
		// na tabela SA2
		If cCodFor != '0'
			 lSeek := SA2->(DbSeek(xFilial('SA2')+cCodFor))
		EndIf

		// Tratamento quando nao ha parametros via query string
		// ou quando o codigo passado nao pode ser encontrado por
		// ser inexistente. Neste caso, retorna toda a tabela
		If cCodFor == '0' .Or. !lSeek
			SA2->(DbGoTop())
		EndIf

		// Prepara retorno
		//cResponse := '[' + CRLF
		cResponse := '{' + CRLF
		cResponse += '"response":['
		While !SA2->(EOF())
			cResponse += jsStrGetMethod()
			SA2->(DbSkip())
			If !SA2->(EOF()) // Cada posicao do array deve ser separada por virgula, exceto a ultima
				cResponse += ','
			EndIf
			cResponse += CRLF
		EndDo
		cResponse += ']' + CRLF
		cResponse += '}'

		// Executa o retorno do metodo GET
		::SetResponse(cResponse)

	End Case

	// Fecha a tabela SA2
	If Select("SA2") > 0
		SA2->(DbCloseArea())
	EndIf

Return lGet



//----------------------------------------
// POST - Inclusão de Fornecedores
//----------------------------------------
WSMETHOD POST WSSERVICE SISRESTSA2

	Local nI := 0
	Local aDados := {}
	Local cBody := ::GetContent()
	Local cCodFor := ''
	Local cResponse := ''
	Local cInscEstadual := ''
	Local cDDD := ''
	Local cFilter := ''
	Local oFornecedor := nil
	Local lFornecedor := FWJsonDeserialize(cBody,@oFornecedor)
	Local lPost := .T.

	Private lMsErroAuto := .F.

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")

	// Registra no console a chamada do metodo
	conOut('SISRESTSA2 - POST METHOD')

	// Valida Deserializacao
	If lFornecedor .and. valType(oFornecedor) == "O"

		// Filtra apenas fornecedores com CGC cadastrados
		// desconsiderando os registros auto-gerados pelo Protheus
		// como é o caso do fornecedor "MUNIC".
		cFilter += 'SA2->A2_CGC <> " " '

		DbSelectAre("SA2")
		SA2->(dbSetOrder(1)) // define índice a1_filial+a1_cod+a1_loja
		SA2->(DbSetFilter( { || &cFilter }, cFilter ) )
		SA2->(dbGoBottom()) // posiciona no último registro

		// Gera codigo do Fornecedor
		cCodFor := Soma1(SA2->A2_COD)

		// Ajusta inscricao municial quando vazio
		If Empty(oFornecedor:stateRegistrationCode)
			cInscEstadual := "ISENTO"
		Else
			cInscEstadual := oFornecedor:stateRegistrationCode
		EndIf

		// Ajusta codigo de area
		If Len(oFornecedor:areaCode) == 2
			cDDD := "0" + oFornecedor:areaCode
		Else
			cDDD := oFornecedor:areaCode
		EndIf

		aadd(aDados,{"A2_FILIAL",xFilial("SA2"),})
		aadd(aDados,{"A2_COD",cCodFor,})
		aadd(aDados,{"A2_LOJA","01",})
		aadd(aDados,{"A2_MSBLQL",IIF(oFornecedor:status=="0","1","2"),})
		aadd(aDados,{"A2_NOME",oFornecedor:companyName,})
		aadd(aDados,{"A2_NREDUZ",oFornecedor:tradeName,})
		aadd(aDados,{"A2_TIPO",oFornecedor:type,})
		aadd(aDados,{"A2_CGC",oFornecedor:taxpayerGeneralRegistry,})
		aadd(aDados,{"A2_INSCRM",oFornecedor:municipalRegistrationCode,})
		aadd(aDados,{"A2_EMAIL",oFornecedor:email,})
		aadd(aDados,{"A2_CONTATO",oFornecedor:contactName,})
		aadd(aDados,{"A2_DDD",cDDD,})
		aadd(aDados,{"A2_TEL",oFornecedor:phoneNumber,})
		aadd(aDados,{"A2_FAX",oFornecedor:faxNumber,})
		aadd(aDados,{"A2_CEP",oFornecedor:postCode,})
		aadd(aDados,{"A2_EST",oFornecedor:state,})
		aadd(aDados,{"A2_INSCR",cInscEstadual,}) // deve ser ordenado apos o campos A2_EST
		aadd(aDados,{"A2_END",oFornecedor:address,})
		aadd(aDados,{"A2_BAIRRO",oFornecedor:neighborhood,})
		aadd(aDados,{"A2_COMPLEM",oFornecedor:address2,})
		aadd(aDados,{"A2_MUN",oFornecedor:townName,})
		aadd(aDados,{"A2_COD_MUN",oFornecedor:townCode,})

		// Campos obrigatorios tratados com inicializador padrao
		aadd(aDados,{"A2_PAIS",criaVar("A2_PAIS",.T.),})
		aadd(aDados,{"A2_CODPAIS",criaVar("A2_CODPAIS",.T.),})
		aadd(aDados,{"A2_CONTA",criaVar("A2_CONTA",.T.),})

		// Inclusao do cadastro de fornecedor via rotina padrao
		MSExecAuto({|x,y| mata020(x,y)},aDados,3)

		If lMsErroAuto
			lPost := .F.
			conOut(mostraErro())
			SetRestFault(500,'internal server error')
		Else

			// Prepara retorno do metodo
			cResponse += '{'
			//cResponse += '"id": "' + cValToChar(val(cCodFor+"01")) + '",'
			cResponse += '"id": "' + cCodFor+"01" + '",'
			cResponse += '"status": "' + oFornecedor:status + '",'
			cResponse += '"companyName": "' + oFornecedor:companyName + '",'
			cResponse += '"tradeName": "' + oFornecedor:tradeName + '",'
			cResponse += '"type": "' + oFornecedor:type + '",'
			cResponse += '"taxpayerGeneralRegistry": "' + oFornecedor:taxpayerGeneralRegistry + '",'
			cResponse += '"stateRegistrationCode": "' + oFornecedor:stateRegistrationCode + '",'
			cResponse += '"municipalRegistrationCode": "' + oFornecedor:municipalRegistrationCode + '",'
			cResponse += '"email": "' + oFornecedor:email + '",'
			cResponse += '"contactName": "' + oFornecedor:contactName + '",'
			cResponse += '"areaCode": "' + oFornecedor:areaCode + '",'
			cResponse += '"phoneNumber": "' + oFornecedor:phoneNumber + '",'
			cResponse += '"faxNumber": "' + oFornecedor:faxNumber + '",'
			cResponse += '"postCode": "' + oFornecedor:postCode + '",'
			cResponse += '"address": "' + oFornecedor:address + '",'
			cResponse += '"addressNumber": "' + oFornecedor:addressNumber + '",'
			cResponse += '"address2": "' + oFornecedor:address2 + '",'
			cResponse += '"neighborhood": "' + oFornecedor:neighborhood + '",'
			cResponse += '"townName": "' + oFornecedor:townName + '", '
			cResponse += '"townCode": "' + oFornecedor:townCode + '", '
			cResponse += '"state": "' + oFornecedor:state + '"'
			cResponse += '}'

			::SetResponse(cResponse)

		EndIf

	Else
		lPost := .F.
		SetRestFault(500,'json deserialize fault')
	EndIf

	// Fecha tabela de Fornecedores
	If Select("SA2") > 0
		SA2->(DbClearFilter())
		SA2->(DbCloseArea())
	EndIf

Return lPost


//----------------------------------------
// PUT - Atualizacao de Fornecedores
//----------------------------------------
WSMETHOD PUT WSSERVICE SISRESTSA2

	Local aDados := {}
	Local cBody := ::GetContent()
	Local cCodFor := ''
	Local cResponse := ''
	Local cInscEstadual:= ''
	Local cDDD := ''
	Local oFornecedor := nil
	Local lFornecedor := FWJsonDeserialize(cBody,@oFornecedor)
	Local lPut := .T.

	Private lMsErroAuto := .F.

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")

	// Registra no console a chamada do metodo
	conOut('SISRESTSA2 - PUT METHOD')


	// Valida se hoube passagem de parametro via url
	If Len(::aUrlParms) > 0

		cCodFor := SubStr(::aUrlParms[1],1,6)
		cLoja := SubStr(::aUrlParms[1],7,8)

		// Valida Deserializacao
		If lFornecedor .and. valType(oFornecedor) == "O"

			// Ajusta inscricao municial quando vazio
			If Empty(oFornecedor:stateRegistrationCode)
				cInscEstadual := "ISENTO"
			Else
				cInscEstadual := oFornecedor:stateRegistrationCode
			EndIf

			// Ajusta codigo de area
			If Len(oFornecedor:areaCode) == 2
				cDDD := "0" + oFornecedor:areaCode
			Else
				cDDD := oFornecedor:areaCode
			EndIf

			aadd(aDados,{"A2_FILIAL",xFilial("SA2"),})
			aadd(aDados,{"A2_COD",cCodFor,})
			aadd(aDados,{"A2_LOJA",cLoja,})

			iif(at('"status":',cBody)>0,aadd(aDados,{"A2_MSBLQL",IIF(oFornecedor:status=="0","1","2"),}),nil)
			iif(at('"companyName":',cBody)>0,aadd(aDados,{"A2_NOME",oFornecedor:companyName,}),nil)
			iif(at('"tradeName":',cBody)>0,aadd(aDados,{"A2_NREDUZ",oFornecedor:tradeName,}),nil)
			iif(at('"type":',cBody)>0,aadd(aDados,{"A2_TIPO",oFornecedor:type,}),nil)
			iif(at('"taxpayerGeneralRegistry":',cBody)>0,aadd(aDados,{"A2_CGC",oFornecedor:taxpayerGeneralRegistry,}),nil)
			iif(at('"municipalRegistrationCode":',cBody)>0,aadd(aDados,{"A2_INSCRM",oFornecedor:municipalRegistrationCode,}),nil)
			iif(at('"email":',cBody)>0,aadd(aDados,{"A2_EMAIL",oFornecedor:email,}),nil)
			iif(at('"contactName":',cBody)>0,aadd(aDados,{"A2_CONTATO",oFornecedor:contactName,}),nil)
			iif(at('"areaCode":',cBody)>0,aadd(aDados,{"A2_DDD",cDDD,}),nil)
			iif(at('"phoneNumber":',cBody)>0,aadd(aDados,{"A2_TEL",oFornecedor:phoneNumber,}),nil)
			iif(at('"faxNumber":',cBody)>0,aadd(aDados,{"A2_FAX",oFornecedor:faxNumber,}),nil)
			iif(at('"postCode":',cBody)>0,aadd(aDados,{"A2_CEP",oFornecedor:postCode,}),nil)
			iif(at('"state":',cBody)>0,aadd(aDados,{"A2_EST",oFornecedor:state,}),nil)
			iif(at('"stateRegistrationCode":',cBody)>0,aadd(aDados,{"A2_INSCR",cInscEstadual,}),nil)
			iif(at('"address":',cBody)>0,aadd(aDados,{"A2_END",oFornecedor:address,}),nil)
			iif(at('"neighborhood":',cBody)>0,aadd(aDados,{"A2_BAIRRO",oFornecedor:neighborhood,}),nil)
			iif(at('"address2":',cBody)>0,aadd(aDados,{"A2_COMPLEM",oFornecedor:address2,}),nil)
			iif(at('"townName":',cBody)>0,aadd(aDados,{"A2_MUN",oFornecedor:townName,}),nil)
			iif(at('"townCode":',cBody)>0,aadd(aDados,{"A2_COD_MUN",oFornecedor:townCode,}),nil)

			If len(aDados) > 3

				// Alteracao do cadastro de fornecedor via rotina padrao
				MSExecAuto({|x,y| mata020(x,y)},aDados,4)

				If lMsErroAuto
					lPut := .F.
					conOut(mostraErro())
					SetRestFault(500,'internal server error')
				Else

					DbSelectArea("SA2")
					SA2->(DbSetOrder(1))
					SA2->(DbGoTop())
					If SA2->(DbSeek(xFilial("SA2")+::aUrlParms[1]))

						// Prepara retorno do metodo
						cResponse += '{'
						cResponse += '"id": "' + cCodFor+"01" + '",'
						cResponse += '"status": "' + IIF(SA2->A2_MSBLQL=="2","1","0") + '",'
						cResponse += '"companyName": "' + AllTrim(SA2->A2_NOME) + '",'
						cResponse += '"tradeName": "' + AllTrim(SA2->A2_NREDUZ) + '",'
						cResponse += '"type": "' + AllTrim(SA2->A2_TIPO) + '",'
						cResponse += '"taxpayerGeneralRegistry": "' + AllTrim(SA2->A2_CGC) + '",'
						cResponse += '"stateRegistrationCode": "' + AllTrim(SA2->A2_INSCR) + '",'
						cResponse += '"municipalRegistrationCode": "' + AllTrim(SA2->A2_INSCRM) + '",'
						cResponse += '"email": "' + AllTrim(SA2->A2_EMAIL) + '",'
						cResponse += '"contactName": "' + AllTrim(SA2->A2_CONTATO) + '",'
						cResponse += '"areaCode": "' + AllTrim(SA2->A2_DDD) + '",'
						cResponse += '"phoneNumber": "' + AllTrim(SA2->A2_TEL) + '",'
						cResponse += '"faxNumber": "' + AllTrim(SA2->A2_FAX) + '",'
						cResponse += '"postCode": "' + AllTrim(SA2->A2_CEP) + '",'
						cResponse += '"address": "' + AllTrim(SA2->A2_END) + '",'
						//cResponse += '"addressNumber": "' + oFornecedor:addressNumber + '",'
						cResponse += '"address2": "' + AllTrim(SA2->A2_COMPLEM) + '",'
						cResponse += '"neighborhood": "' + AllTrim(SA2->A2_BAIRRO) + '",'
						cResponse += '"townName": "' + AllTrim(SA2->A2_MUN) + '", '
						cResponse += '"townCode": "' + AllTrim(SA2->A2_COD_MUN) + '", '
						cResponse += '"state": "' + AllTrim(SA2->A2_EST) + '"'
						cResponse += '}'

						::SetResponse(cResponse)

					Else
						lPut := .F.
						SetRestFault(500,'internal server error')
					EndIf

				EndIf

			EndIf
		Else
			lPut := .F.
			SetRestFault(500,'json deserialize fault')
		EndIf

	Else
		lPut := .F.
		SetRestFault(500,'parameter id is mandatory')
	EndIf

Return lPut



//----------------------------------------
// Json String Get Method
//----------------------------------------
Static Function jsStrGetMethod()

	Local cString := ""
	Local cEndereco := AllTrim(SA2->A2_END)
	Local cNumero := ""

	// Extracao do numero contido no endereco
	If at(",",SA2->A2_END) >= 1
		cEndereco := allTrim(subStr(SA2->A2_END,1,at(",",SA2->A2_END)-1)) // extrai apenas o endereco (sem o numero apos a virgula)
		cNumero := allTrim(subStr(SA2->A2_END,at(",",SA2->A2_END)+1,Len(AllTrim(SA2->A2_END)))) // extrai apenas o numero
		// Valida se a extracao pode ser convertida para numerico
		If int(val(cNumero)) >= 1
			cNumero := cValToChar(int(val(cNumero)))
			cEndereco := cEndereco
		Else
			cNumero := ""
			cEndereco := AllTrim(SA2->A2_END)
		EndIf
	EndIf

	cString += '{' + CRLF
	cString += '"id": "' + AllTrim(SA2->(A2_COD+A2_LOJA)) + '", ' + CRLF
	cString += '"status": "' + IIF(SA2->A2_MSBLQL=="2","1","0") + '", ' + CRLF
	cString += '"companyName": "' + AllTrim(SA2->A2_NOME) + '", ' + CRLF
	cString += '"tradeName": "' + AllTrim(SA2->A2_NREDUZ) + '", ' + CRLF
	cString += '"type": "' + AllTrim(SA2->A2_TIPO) + '", ' + CRLF
	cString += '"taxpayerGeneralRegistry": "' + AllTrim(SA2->A2_CGC) + '", ' + CRLF
	cString += '"stateRegistrationCode": "' + AllTrim(SA2->A2_INSCR) + '", ' + CRLF
	cString += '"municipalRegistrationCode": "' + AllTrim(SA2->A2_INSCRM) + '", ' + CRLF
	cString += '"email": "' + AllTrim(SA2->A2_EMAIL) + '", ' + CRLF
	cString += '"contactName": "' + AllTrim(SA2->A2_CONTATO) + '", ' + CRLF
	cString += '"areaCode": "' + AllTrim(SA2->A2_DDD) + '", ' + CRLF
	cString += '"phoneNumber": "' + AllTrim(SA2->A2_TEL) + '", ' + CRLF
	cString += '"faxNumber": "' + AllTrim(SA2->A2_FAX) + '", ' + CRLF
	cString += '"postCode": "' + AllTrim(SA2->A2_CEP) + '", ' + CRLF
	cString += '"address": "' + cEndereco + '", ' + CRLF
	cString += '"addressNumber": "' + cNumero + '", ' + CRLF
	cString += '"address2": "' + AllTrim(SA2->A2_COMPLEM) + '", ' + CRLF
	cString += '"neighborhood": "' + AllTrim(SA2->A2_BAIRRO) + '", ' + CRLF
	cString += '"townName": "' + AllTrim(SA2->A2_MUN) + '", ' + CRLF
	cString += '"townCode": "' + AllTrim(SA2->A2_COD_MUN) + '", ' + CRLF
	cString += '"state": "' + AllTrim(SA2->A2_EST) + '"' + CRLF
	cString += '}'

Return(cString)
