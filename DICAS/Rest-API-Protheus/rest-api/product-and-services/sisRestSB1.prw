#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'

// Define o Carriage Return (CR) e Line Feed (LF)
// CR = Retorna o carro (referência a maquinas de escrever)
// LF = Alimenta nova linha
#Define CRLF (Chr(13)+Chr(10))

// Define se as tabelas personalizadas existem
// no dicionário de dados
Static lSB1ToZW1 := MsFile('ZW1'+cEmpAnt+'0') // Unidade de Medida Camalion X Protheus
Static lSB1ToZW2 := MsFile('ZW2'+cEmpAnt+'0') // Tipo de produto Camalion X Protheus

// Cria array de relacionamento entre estrutura
// de dados Camalion X Protheus
Static aRelation := dataCorrelation()

/*/{Protheus.doc} SISRESTSB1
WebService REST-API com os popósitos:
	- Integração Camalion X TOTVS Protheus
	- Propósitos gerais

@type      function
@author    Giovani
@since     18/09/2017
@version   1.0
/*/
WsRestFul SISRESTSB1 Description "Sisnet Solutions - Products and Services Webservice"

WsData id AS String

WsMethod GET Description "Get method" WsSyntax "/SISRESTSB1 || /SISRESTSB1/{id}"
WsMethod POST Description "Post method" WsSyntax "/SISRESTSB1/{id}"
WsMethod PUT Description "Put method" WSSYNTAX "/SISRESTSB1/{id}"

End WsRestFul


//WsMethod GET WsService SISRESTSB1
WsMethod GET WsReceive id WsService SISRESTSB1

	Local nI := 0
	Local cParam := ''
	Local cResponse := ''
	Local cJsonString := ''
	Local lGet := .T.
	Local lSeek := .T.

	Default ::id := ''

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")

	// Registra no console a chamada do metodo
	ConOut('SISRESTSB1 - GET METHOD')

	Do Case

	// Fluxo para parâmetros
	Case Len(::aUrlParms) > 0
		cParam := ::aUrlParms[1]
		cJsonString := jsString(cParam)

	// Fluxo para query string
	Case Len(::aUrlParms) == 0
		cParam := ::id
		If !Empty(cParam)
			cJsonString := jsString(cParam)
		EndIf

	End Case

	If !Empty(cJsonString)
		// Gera a resposta da chamada Get
		cResponse := '{'
		cResponse += 	'"response":['
		cResponse += 		cJsonString
		cResponse += 	']'
		cResponse += '}'
		// Retorna a resposta para a chamada Get
		::SetResponse(cResponse)
	Else
		lGet := .F.
		SetRestFault(500,'product or services code not found')
	EndIf

Return lGet


WsMethod POST WsService SISRESTSB1

	Local cBody := ''
	Local cResponse := ''
	Local lPost := .F.

	Private oBody := nil // oBody deve ser private para correto funcionamento do operador macro substituição (&)

	// Registra chamda do método no console do servidor
	ConOut('SISRESTSB1 - POST METHOD')

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")

	// Captura boby da requisição
	cBody := ::GetContent()

	// Deserializa dody da requisição
	lDeserialize := FWJsonDeserialize(cBody,@oBody)

	// Persiste dados conforme objeto js deserializado
	If lDeserialize .And. ValType(oBody) == "O"

		lPost := jsPersist(cBody,oBody,@cResponse,1)

		If lPost
			::SetResponse(cResponse)
		EndIf

	Else
		lOK := .F.
		SetRestFault(500,'json deserialize fault')
	EndIf

Return lPost


WsMethod PUT WsService SISRESTSB1

	Local cBody := ''
	Local cParam := ''
	Local cResponse := ''
	Local lPut := .F.

	Private oBody := nil // oBody deve ser private para correto funcionamento do operador macro substituição (&)

	// Registra chamda do método no console do servidor
	ConOut('SISRESTSB1 - PUT METHOD')

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")

	// Valida passagem de parametro via url (put)
	If Len(::aUrlParms) > 0

		// Captura parametro da url
		cParam := ::aUrlParms[1]

		// Captura boby da requisição
		cBody := ::GetContent()

		// Deserializa dody da requisição
		lDeserialize := FWJsonDeserialize(cBody,@oBody)

		// Persiste dados conforme objeto js deserializado
		If lDeserialize .And. ValType(oBody) == "O"

			lPut := jsPersist(cBody,oBody,@cResponse,2,cParam)

			If lPut
				::SetResponse(cResponse)
			EndIf

		Else
			lOK := .F.
			SetRestFault(500,'json deserialize fault')
		EndIf

	Else
		SetRestFault(500,'parameter id is required on url for put method')
	EndIf

Return lPut


/**************************************************
 Correlaciona estrutura de dados entre
 Camalion X Protheus
**************************************************/
Static Function dataCorrelation()

	Local aRelation := {}

	// [1] Camalion RestAPI field name (string)
	// [2] Protheus field name (string)
	// [3] Mandatory for post/put (boolean)

	aRelation := {;
		{'id','B1_COD'},;
		{'status','B1_MSBLQL'},;
		{'description','B1_DESC'},;
		{'type','B1_TIPO'},;
		{'category','B1_GRUPO'},;
		{'measurementUnit','B1_UM'},;
		{'secondaryMeasurementUnit','B1_SEGUM'},;
		{'secondaryMeasurementUnitFactor','B1_CONV'},;
		{'secondaryMeasurementUnitOperator','B1_TIPCONV'},;
		{'standardWarehouse','B1_LOCPAD'},;
		{'salePrice','B1_PRV1'},;
		{'lastPurchasePrice','B1_UPRC'},;
		{'lastPurchaseDate','B1_UCOM'},;
		{'invoiceProductOrigin','B1_ORIGEM'},;
		{'invoiceProductNCM','B1_POSIPI'},;
		{'invoiceProductCEST','B1_CEST'},;
		{'invoiceProductNetWeight','B1_PESO'},;
		{'invoiceProductGrossWeight','B1_PESBRU'};
	}

Return(aRelation)


/**************************************************
 Gera String em formato Json para retorno do
 método Get
**************************************************/
Static Function jsString(xParam)

	Local cField := ''
	Local cContent := ''
	Local cJsonString := ''
	Local lSeek := .F.
	Local lLoop := .F.
	Local lIgnora := .F.
	Local nI := 0

	// Abertura da tabela
	DbSelectArea("SB1")

	Do Case
	// Tratamento quando o parâmetro informado for correspondente
	// à chave de índice da tabela, para buca por MsSeek/DbSeek
	Case ValType(xParam) == 'C' .And. Lower(AllTrim(xParam)) != 'all'
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If MsSeek(xFilial('SB1')+xParam)
			lSeek := .T.
		EndIf
	// Tratamento quando for solicitado loop de todos registros
	// da tabela
	Case ValType(xParam) == 'C' .And. Lower(AllTrim(xParam)) == 'all'
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		lLoop := .T.
	// Tratamento quando o parâmetro informado for correspondente
	// ao Recno da tabela, para posicionamento com DbGoTop
	Case ValType(xParam) == 'N'
		SB1->(DbGoTo(xParam))
		lSeek := .T.
	End Case

	// Geração da String Json
	While lSeek .Or. (lLoop .And. !SB1->(EOF()))

		// Correlaciona campos entre Camalion X Protheus
		For nI:=1 to Len(aRelation)

			// Abre o arquivo
			If nI == 1
				cJsonString += '{'
			EndIf

			// Formata a primeira parte da string json
			// Exemplo: 'id':
			cJsonString += u_SFQuote(aRelation[nI,1],.F.) + ':'

			// Popula cField com o respectivo nome do campo
			// de aRelation posição 2
			cField := aRelation[nI,2]

			// Formata a segunda parte da string json
			// Exemplo: '123'
			Do Case

				//--------------------------------------------------
				// Trata disparidade de B1_MSBLQL
				//--------------------------------------------------
				Case aRelation[nI,2] == 'B1_MSBLQL'
					cJsonString += u_SFQuote(IIF(SB1->(&(cField))=='2','1','0'),.F.)

				//--------------------------------------------------
				// Valia dependências de B1_CONV e B1_TIPCONV
				//--------------------------------------------------
				Case aRelation[nI,2] $ 'B1_CONV/B1_TIPCONV'
					If !Empty(SB1->B1_SEGUM) .And. !Empty(SB1->B1_CONV) .And. !Empty(SB1->B1_TIPCONV)
						cJsonString += u_SFQuote(SB1->(&(cField)),.T.)
					Else
						lIgnora := .T.
					EndIf

				//--------------------------------------------------
				// Correlaciona Unid. Medida - Camalion X Protheus
				//--------------------------------------------------
				Case aRelation[nI,2] $ 'B1_UM/B1_SEGUM' .And. lSB1ToZW1
					DbSelectArea('ZW1')
					ZW1->(DbSetOrder(1)) // ZW1_FILIAL+ZW1_UMPROT
					ZW1->(DbGoTop())
					If MsSeek(xFilial('ZW1')+SB1->(&(aRelation[nI,2])))
						If aRelation[nI,2] == 'B1_SEGUM'
							If !Empty(SB1->B1_SEGUM) .And. !Empty(SB1->B1_CONV) .And. !Empty(SB1->B1_TIPCONV)
								cJsonString += u_SFQuote(ZW1->ZW1_UMCAMA,.T.)
							Else
								lIgnora := .T.
							EndIf
						Else // B1_UM
							cJsonString += u_SFQuote(ZW1->ZW1_UMCAMA,.T.)
						EndIf
					Else
						lIgnora := .T.
					EndIf
					ZW1->(DbCloseArea())

				//--------------------------------------------------
				// Correlaciona Tipo Produto - Camalion X Protheus
				//--------------------------------------------------
				Case aRelation[nI,2] == 'B1_TIPO' .And. lSB1ToZW2
					DbSelectArea('ZW2')
					ZW2->(DbSetOrder(1)) // ZW2_FILIAL+ZW2_TPPROT
					ZW2->(DbGoTop())
					If MsSeek(xFilial('ZW2')+SB1->(&(aRelation[nI,2])))
						cJsonString += u_SFQuote(ZW2->ZW2_TPCAMA,.T.)
					Else
						lIgnora := .T.
					EndIf
					ZW2->(DbCloseArea())

			Otherwise
				cJsonString += u_SFQuote(SB1->(&(cField)),.T.)
			EndCase

			// Determina que o conteúdo dos campos
			// ignorados, não será considerado na string json
			If lIgnora
				If ValType(SB1->(&(aRelation[nI,2]))) == 'N'
					cJsonString += u_SFQuote(0)
				Else
					cJsonString += u_SFQuote('')
				EndIf
				lIgnora := .F.
			EndIf

			// Não adiciona vírgula ao último elemento
			If nI != Len(aRelation)
				cJsonString += ','
			Else
				cJsonString += '}' // finaliza string json
			EndIf

		Next

		// Tratamento do loop
		If lLoop
			If !SB1->(EOF())
				SB1->(DbSkip()) // salta para próximo registro
				If !SB1->(EOF())
					cJsonString += ','
				EndIf
			Else
				Exit // sai do loop ao chegar no fim de arquivo
			EndIf
		Else
			Exit // sai do loop se não for percorrer todos os dados
		EndIf

	EndDo

	// Fechamento da tabela posicionada
	If Select('SB1') > 0
		SB1->(DbCloseArea())
	EndIf

Return(cJsonString)


/**************************************************
 Persiste os dados passados em formado
 js pelo body das requisições post/put
**************************************************/
Static Function jsPersist(cBody,oBody,cResponse,nOpc,cParam)

	Local nI := 0
	Local aDados := {}
	Local cExecError := ''
	Local lOK := .T.

	Private lMsErroAuto := .F.

	Default cParam := ''

	// Abre tabela para correto funcionamento
	// das funções de de numeração sequêncial
	// sxe-sxf / hardlock
	DbSelectArea('SB1')

	// Gera estrutura de dados para MsExecAuto
	aDados := jsStructure(cBody,oBody,nOpc,cParam)

	// Inclusao do cadastro de fornecedor via rotina padrao
	If Len(aDados) > 0

		MSExecAuto({|x,y| Mata010(x,y)},aDados,IIF(nOpc==1,3,4))

		If lMsErroAuto
			lOK := .F.
			cExecError := MostraErro() ; ConOut(cExecError) // captura erro e imprime no console do servidor
			cExecError := u_SFWSErr(cExecError,aRelation) // formata erro para exibição no RestFault
			SetRestFault(500, cExecError)
		Else
			For nI:=1 to Len(aDados)
				If aDados[nI,1] == 'B1_COD'
					SB1->(DbSetOrder(1))
					SB1->(DbGoTop())
					SB1->(MsSeek(xFilial('SB1')+aDados[nI,2]))
				EndIf
			Next
			cResponse := jsString(SB1->(Recno())) // retorna o objeto criado como resposta de sucesso
		EndIf

	Else
		lOK := .F.
	EndIf

	// Fecha tabela
	If Select('SB1') > 0
		SB1->(DbCloseArea())
	EndIf

Return lOK


/**************************************************
 Estrutura body da requisição post/put em array
 no formato ExecAuto
**************************************************/
Static Function jsStructure(cBody,oBody,nOpc,cParam)

	Local aTamSX3 := {}
	Local aStruct := {}
	Local xContent := ''
	Local nI := 0
	Local lOK := .T.
	Local lGrava := .T. // informa se o conteúdo de xContent será gravado no array aStruct
	Local lCriaVar := .F. // informa se foi utilizado CriaVar para definir conteúdo de xContent

	// Trata a filial conforme campo tenantId passado via header da requisição post/put
	// Caso o campo tenantId não tenha sido informado, será considerada a primeira working thread
	// de qualquer empresa
	AADD(aStruct, {'B1_FILIAL', xFilial('SB1'), nil})

	// Se for uma requisição Put, adiciona na estrutura o
	// campo B1_COD conforme conteúdo de cParam
	If nOpc == 2
		AADD(aStruct, {'B1_COD', cParam, nil})
	EndIf

	For nI := 1 to Len(aRelation)

		// Desconsidera campo B1_COD para requisições Put
		// pois o mesmo é enviado via parâmetro URL
		If nOpc == 2 .And. aRelation[nI,1] == 'id' // B1_COD
			Loop
		EndIf

		// Valida se o campo da estrutura foi passado pelo body da requisição post/put
		If At(u_SFQuote(aRelation[nI,1],.F.),cBody) > 0

			//--------------------------------------------------
			// Caputura conteúdo passado via body da requisição
			//--------------------------------------------------
			xContent := &('oBody:'+aRelation[nI,1])

			// Verifica se xContent não está vazio
			If !Empty(xContent) .Or. nOpc == 2
				lGrava := .T.
				//--------------------------------------------------
				// Trata xContent conforme tipo de dados do campo
				//--------------------------------------------------
				aTamSX3 := TamSX3(aRelation[nI,2])
				Do Case
					Case aTamSX3[3] == 'C' .And. Len(xContent) < aTamSX3[1]
						xContent := PadR(xContent, aTamSX3[1]) // adiciona espaços à direita conforme tamanho do campo
					Case aTamSX3[3] == 'D'
						xContent := u_SFDate(xContent,'-','D') // formata data 'AAAA-MM-DD' para 'DD/MM/AAAA'
				EndCase
			Else
				lGrava := .F.
			EndIf

			lCriaVar := .F.

		Else

			// Post
			If nOpc == 1
				// Carrega conteúdo conforme inicializador padrão
				// definido no dicionário de dados
				xContent := CriaVar(aRelation[nI,2])
				lCriaVar := .T.

				// Não gera estrutura se um campo obrigatório não
				// for informado e o mesmo não possui inicializador
				// padrão válido
				If Empty(xContent) .And. x3Obrigat(aRelation[nI,2])
					lOK := .F.
				EndIf
			EndIf

		EndIf

		If lOK

			//--------------------------------------------------
			// Trata disparidade de B1_MSBLQL
			//--------------------------------------------------
			If aRelation[nI,2] == 'B1_MSBLQL' .And. !lCriaVar
				xContent := IIF(xContent=='0','1','2')
			EndIf

			//--------------------------------------------------
			// Correlaciona Unid. Medida - Camalion X Protheus
			//--------------------------------------------------
			If aRelation[nI,2] $ 'B1_UM/B1_SEGUM' .And. lSB1ToZW1 .And. !lCriaVar
				DbSelectArea('ZW1')
				ZW1->(DbSetOrder(3)) // ZW1_FILIAL+ZW1_UMCAMA+ZW1+SINCRO
				ZW1->(DbGoTop())
				If MsSeek(xFilial('ZW1')+PadR(xContent,TamSX3('ZW1_UMCAMA')[1])+'1')
					xContent := ZW1->ZW1_UMPROT
				EndIf
				ZW1->(DbCloseArea())
			EndIf

			//--------------------------------------------------
			// Correlaciona Tipo Produto - Camalion X Protheus
			//--------------------------------------------------
			If aRelation[nI,2] == 'B1_TIPO' .And. lSB1ToZW2 .And. !lCriaVar
				DbSelectArea('ZW2')
				ZW2->(DbSetOrder(3)) // ZW2_FILIAL+ZW2_TPCAMA+ZW2_SINCRO
				ZW2->(DbGoTop())
				If MsSeek(xFilial('ZW2')+PadR(xContent,TamSX3('ZW2_TPCAMA')[1])+'1')
					xContent := ZW2->ZW2_TPPROT
				EndIf
				ZW1->(DbCloseArea())
			EndIf

			//--------------------------------------------------
			// Adciona campo e conteúdo na estrutura de dados
			//--------------------------------------------------
			If lGrava
				AADD(aStruct, {aRelation[nI,2], xContent, nil})
			EndIf

		// Se o retorno da inicialização com CriaVar() for vazio,
		// invalida a chamada e gera restFault, pois um campo obrigatório
		// e de inicialização vazia não foi passado no body da requisição post/put
		Else
			aStruct := {}
			SetRestFault(500,aRelation[nI,1] + space(1) + 'is mandatory')
			Exit
		EndIf

	Next

	//--------------------------------------------------
	// Trata demais campos obrigatórios que não fazem
	// parte do modelo de dados correlacionados
	//--------------------------------------------------
	If Len(aStruct) > 0
		AADD(aStruct, {'B1_GARANT', CriaVar('B1_GARANT'), nil})
	EndIf

	// Libera a reserva de código sequêncial se houver
	If GetSx8Len() > 0
		RollBackSx8()
	EndIf

Return(aStruct)
