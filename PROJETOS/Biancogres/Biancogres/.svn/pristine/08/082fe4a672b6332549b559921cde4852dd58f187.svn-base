#include "TOTVS.CH"

/*/{Protheus.doc} TAutomacaoNotaEntrada
@description Classe para automatocoes de processos referente a documento de entrada
@author Fernando Rocha
@since 10/06/2019
@version 1.0
@type class
/*/
Class TAutomacaoNotaEntrada from TAbstractClass

	Public Data lPreNota

	Public Data RecERP
	Public Data cFilP
	Public Data cDoc
	Public Data cSerie
	Public Data cFornece
	Public Data cLoja

	Public Data cTipo
	Public Data cFormul
	Public Data cEspecie
	Public Data dDtEmis

	Public Data oItens

	Public Data lClass
	Public Data cLogRet

	Public Method New() Constructor

	Public Method Get()
	Public Method SetTESPN()
	Public Method Classificar()
	Public Method Validar()
	Public Method GetByBZ(_oItem)
	Public Method ChkServico()

EndClass

Method New() Class TAutomacaoNotaEntrada

	_Super:New()

	::lPreNota	:= .F.

	::RecERP	:= 0
	::cFilP 	:= XFILIAL("SF1")
	::cDoc 		:= ""
	::cSerie 	:= ""
	::cFornece	:= ""
	::cLoja		:= ""

	::cTipo		:= ""
	::cFormul	:= ""
	::cEspecie	:= ""
	::dDtEmis	:= CTOD(" ")

	::oItens 	:= ArrayList():New()

	::lClass	:= .F. 
	::cLogRet	:= ""

Return

/*/{Protheus.doc} Get
@description Posicionar o documento de entrada baseado nos campos chave informados e preencher demais propriedades
@author Fernando Rocha
@since 12/06/2019
@version 1.0
@type function
/*/
Method Get() Class TAutomacaoNotaEntrada

	Local _oItem
	Local _lRet := .F.

	::cDoc := PADR(::cDoc,TamSx3("F1_DOC")[1])
	::cSerie := PADR(::cSerie,TamSx3("F1_SERIE")[1])
	::cFornece := PADR(::cFornece,TamSx3("F1_FORNECE")[1])
	::cLoja := PADR(::cLoja,TamSx3("F1_LOJA")[1])

	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(::cFilP+::cDoc+::cSerie+::cFornece+::cLoja))

		_lRet 		:= .T.

		::RecERP	:= SF1->(RecNo())
		::cTipo 	:= SF1->F1_TIPO
		::cFormul	:= SF1->F1_FORMUL
		::cEspecie	:= SF1->F1_ESPECIE
		::dDtEmis	:= SF1->F1_EMISSAO

		If Empty(SF1->F1_STATUS)

			::lPreNota := .T.

		EndIf

		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(::cFilP+::cDoc+::cSerie+::cFornece+::cLoja))

			While !SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == (::cFilP+::cDoc+::cSerie+::cFornece+::cLoja)

				_oItem := TItemNotaEntrada():New()

				_oItem:cItem 		:= SD1->D1_ITEM
				_oItem:cProduto		:= SD1->D1_COD
				_oItem:nQuantidade	:= SD1->D1_QUANT
				_oItem:nVUnit		:= SD1->D1_VUNIT
				_oItem:cTES			:= SD1->D1_TES
				_oItem:cTESPN		:= SD1->D1_YTESPN
				_oItem:nPIcms		:= SD1->D1_PICM
				
				_oItem:cPedido		:= SD1->D1_PEDIDO
				_oItem:cItemPC		:= SD1->D1_ITEMPC
				If !Empty(_oItem:cPedido) .And. !Empty(_oItem:cItemPc)
					DbSelectArea("SC7")
					SC7->(DbSetOrder(1))
					If SC7->(DbSeek(xFilial("SC7")+_oItem:cPedido+_oItem:cItemPC))
						_oItem:cLocal	:=	SC7->C7_LOCAL
					Else
						_oItem:cLocal	:=	SD1->D1_LOCAL
					EndIf
				Else
					_oItem:cLocal	:=	SD1->D1_LOCAL
				EndIf
				::oItens:Add(_oItem)

				SD1->(DbSkip())
			EndDo

		EndIf

	EndIf

Return(_lRet)

/*/{Protheus.doc} Classificar
@description ExecAuto para Classificacao de Pre-Nota
@author Fernando Rocha
@since 12/06/2019
@version 1.0
@type function
/*/
Method Classificar() Class TAutomacaoNotaEntrada

	Local aCabNF
	Local aItem
	Local aItens := {}
	Local lOk := .F.
	Local nCount := 1
	Local _aAutoErro
	Local _cLogTxt := ""
	Local aPerg := {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	::lClass := .T.

	If !(::lPreNota)

		::cLogRet += "Documento já classificado ou não existente."+CRLF
		Return .F.

	EndIf

	If !(::Validar())
		Return .F.
	EndIf
	
	
	Pergunte("MTA103",.F.,,,,, @aPerg)

	MV_PAR01 := 2
	MV_PAR02 := 1
	MV_PAR06 := 1
	
	__SaveParam("MTA103", aPerg)
	
	SF1->(DbSetOrder(1))
	SF1->(DbSeek(XFilial("SF1")+PADR(::cDoc, TamSx3("D1_DOC")[1])+PADR(::cSerie, TamSx3("D1_SERIE")[1])+PADR(::cFornece, TamSx3("D1_FORNECE")[1])+PADR(::cLoja, TamSx3("D1_LOJA")[1])))
	
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(XFilial("SA2")+PADR(::cFornece, TamSx3("D1_FORNECE")[1])+PADR(::cLoja, TamSx3("D1_LOJA")[1])))
	
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(XFilial("SF4")+PADR(::oItens:GetItem(nCount):cTES, TamSx3("D1_TES")[1])))

	aCabNF		:= {}
	aItem		:= {}

	//Monta array cabecalho nota fiscal
	aCabNF := {}

	aAdd(aCabNF,{"F1_TIPO"    , ::cTipo            				, NIL, Nil})
	aAdd(aCabNF,{"F1_FORMUL"  , ::cFormul             			, NIL, Nil})
	aAdd(aCabNF,{"F1_ESPECIE" , ::cEspecie			 			, NIL, Nil})
	aAdd(aCabNF,{"F1_DOC"     , ::cDoc		 					, NIL, Nil})
	aAdd(aCabNF,{"F1_SERIE"   , ::cSerie			 			, NIL, Nil})
	aAdd(aCabNF,{"F1_EMISSAO" , ::dDtEmis						, NIL, Nil})
	aAdd(aCabNF,{"F1_FORNECE" , ::cFornece			   			, NIL, Nil})
	aAdd(aCabNF,{"F1_LOJA"    , ::cLoja				  			, NIL, Nil})	


	While nCount <= ::oItens:GetCount()

		aItem := {}

		aAdd(aItem,{"D1_ITEM" 		, PADR(::oItens:GetItem(nCount):cItem, TamSx3("D1_ITEM")[1])		, NIL, Nil})
		aAdd(aItem,{"D1_COD" 		, PADR(::oItens:GetItem(nCount):cProduto, TamSx3("D1_COD")[1])     	, NIL, Nil})
		aAdd(aItem,{"D1_DOC"    	, PADR(::cDoc, TamSx3("D1_DOC")[1])     							, Nil, Nil})
		aAdd(aItem,{"D1_SERIE"    	, PADR(::cSerie, TamSx3("D1_SERIE")[1])      						, Nil, Nil})
		aAdd(aItem,{"D1_FORNECE"   	, PADR(::cFornece, TamSx3("D1_FORNECE")[1])      					, Nil, Nil})
		aAdd(aItem,{"D1_LOJA"    	, PADR(::cLoja, TamSx3("D1_LOJA")[1])     							, Nil, Nil})
		aAdd(aItem,{"D1_QUANT"    	, ::oItens:GetItem(nCount):nQuantidade  , Nil, Nil})
		aAdd(aItem,{"D1_VUNIT"    	, ::oItens:GetItem(nCount):nVUnit   	, Nil, Nil})
		aAdd(aItem,{"D1_TES"    	, PADR(::oItens:GetItem(nCount):cTES, TamSx3("D1_TES")[1])   		, Nil, Nil})
		
		
		If !Empty(::oItens:GetItem(nCount):cPedido)

			aAdd(aItem,{"D1_PEDIDO"   	, ::oItens:GetItem(nCount):cPedido 		, ".T.", Nil})
			aAdd(aItem,{"D1_ITEMPC"   	, ::oItens:GetItem(nCount):cItemPC 		, ".T.", Nil})
			aAdd(aItem,{"D1_LOCAL"   	, ::oItens:GetItem(nCount):cLocal 		, ".T.", Nil})
			//aAdd(aItem,{"D1_PEDIDO"   	, PADR(::oItens:GetItem(nCount):cPedido, TamSx3("D1_PEDIDO")[1])  		, Nil, Nil})
			//aAdd(aItem,{"D1_ITEMPC"   	, PADR(::oItens:GetItem(nCount):cItemPC, TamSx3("D1_ITEMPC")[1])  		, Nil, Nil})

		EndIf
		
		If (AllTrim(SA2->A2_SIMPNAC) == '1')//simples nacional
			If (::oItens:GetItem(nCount):nPIcms > 0)
				aAdd(aItem,{"D1_PICM"    	, ::oItens:GetItem(nCount):nPIcms   	, Nil, Nil})
				
				CONOUT("TAutomacaoNotaEntrada => Fornecedor Simples Nacional => Numero: "+::cDoc+", Serie: "+::cSerie+", Fornecedor: "+::cFornece+", Produto: "+::oItens:GetItem(nCount):cProduto+", PIcms: "+cValTochar(::oItens:GetItem(nCount):nPIcms))
			
			EndIf
		EndIf
		
		
		
		AAdd(aItens, aItem)

		nCount++

	EndDo

	MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabNF,aItens,4,.T.)

	If !lMsErroAuto
		lOk := .T.
	Else
		lOk := .F.
		DisarmTransaction()

		_aAutoErro := GETAUTOGRLOG()
		_cLogTxt += U_XCONVELOG(_aAutoErro)
		
		ConOut("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<ERRO EXECAUTO MATA103>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
		ConOut(_cLogTxt)

		::cLogRet := _cLogTxt
	EndIf

Return(lOk)

/*/{Protheus.doc} SetTESPN
@description Copiar o campo TES Pre Nota para a TES principal para classificacao
@author Fernando Rocha
@since 12/06/2019
@version 1.0
@type function
/*/
Method SetTESPN() Class TAutomacaoNotaEntrada

	Local nCount := 1

	While nCount <= ::oItens:GetCount()

		::oItens:GetItem(nCount):cTES := ::oItens:GetItem(nCount):cTESPN

		nCount++
	EndDo

Return


/*/{Protheus.doc} SetTESPN
@description Validacoes do Modelos antes da Execucao
@author Fernando Rocha
@since 12/06/2019
@version 1.0
@type function
/*/
Method Validar() Class TAutomacaoNotaEntrada

	Local nCount := 1
	Local lRet := .T.

	While nCount <= ::oItens:GetCount()

		If Empty(::oItens:GetItem(nCount):cPedido)

			::cLogRet += "Documento/Item sem PEDIDO Informado."+CRLF
			lRet := .F.
			exit

		EndIf

		nCount++
	EndDo

Return(lRet)


Method GetByBZ(_oItem) Class TAutomacaoNotaEntrada

	//41190602928428000124550010000141421571186711;000014142;1  ;009209;01;DRIMEC INDUSTRIA MECANICA LTDA - EPP;02928428000124;T; ;[0001|2205361        |True];
	/*
	CHAVE
	NUMERO NOTA FISCAL
	SERIE NOTA FISCAL
	FORNECEDOR CODIGO
	FORNECEDOR LOJA
	FORNECEDOR NOME
	FORNECEDOR CNPJ
	MATERIAL RECEBIDO
	MOTIVO DA RECUSA
	ITENS NOTA FISCAL
	*/

	Local aDados	
	Local _DadosEntr := _oItem:Dados

	aDados := StrToKArr2(_DadosEntr,";",.T.)

	If ( Len(aDados) >= 8 )

		_oItem:lDadosOk := .T.

		::cDoc 		:= AllTrim(aDados[2])
		::cSerie 	:= AllTrim(aDados[3])
		::cFornece	:= AllTrim(aDados[4])
		::cLoja		:= AllTrim(aDados[5])

		_oItem:lConferido := ( AllTrim(aDados[8]) == "T" )

		If ( _oItem:lConferido )

			If ( ::Get() )

				_oItem:lDocOk := .T.
				Return .T.

			EndIf

		Else

			CONOUT("TAutomacaoNotaEntrada > GetByBZ ==> Documento: "+::cDoc+::cSerie+::cFornece+::cLoja+" ==> RECUSADO pelo processo.")

		EndIf

	Else

		CONOUT("TAutomacaoNotaEntrada > GetByBZ ==> Estrutura do campo DADOS_ENTRADA inválida.")

	EndIf

Return .F.



Method ChkServico() Class TAutomacaoNotaEntrada

	Local lServico := .F.

	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(::cFilP+::cDoc+::cSerie+::cFornece+::cLoja)) .And. SubStr(SD1->D1_COD,1,3) == "306"

		lServico := .T.

	EndIf

Return(lServico)


User Function TACLNFJB()

	Local oProc
	Local _cUser		
	Local _cPassword	

	RPCSetEnv("01", "01")

	

	_cUser		:=	GetNewPar("MV_YUSRCTB","FACILE")
	_cPassword	:=	GetNewPar("MV_YPSWCTB","TESTE01")

	RpcClearEnv()

	RPCSetEnv("01", "01")

	
	/*_Dados = '32200110582903000181550010000017401000004716;000001740;1  ;006432;01;GUERRINI & TOREZANI LTDA - ME;10582903000181;T; ;[0001|1040404|T];'
	_Dados = '32200135994045000103550010000024681000086423;000002468;1  ;000875;01;SERGIO ECHER - EPP;35994045000103;T; ;[0001|1040434|T];'
	
	
	_oItem := TIntegracaoBizagiItem():New()
	_oItem:Set('01', '01', 'RM', '0', 100, _Dados, 'RM-009606')

	oProc := TIntegracaoBizagi():New()
	oProc:oItens:Add(_oItem)
	PrJobClNf(oProc)
	*/
	
	//Rodar processamento de Notas de Materaial
	oProc := TIntegracaoBizagi():New()
	oProc:SetProcesso("NFE")
	oProc:Get()
	PrJobClNf(oProc)
	
	
	//Rodar processamento de Notas de Servico
	oProc := TIntegracaoBizagi():New()
	oProc:SetProcesso("NFS")
	oProc:Get()
	PrJobClNf(oProc, .T.)
	
		
	RpcClearEnv()

Return



Static Function PrJobClNf(oProc, lServico)

	Local nCount := 1
	Local oNFE := Nil
	Local lErroLinha

	Default lServico := .F.

	While nCount <= oProc:oItens:GetCount()

		If ( oProc:oItens:GetItem(nCount):Empresa <> CEMPANT .Or. oProc:oItens:GetItem(nCount):Filial <> CFILANT)

			RpcClearEnv()
			RPCSetEnv(oProc:oItens:GetItem(nCount):Empresa, oProc:oItens:GetItem(nCount):Filial)

		EndIf

		//Instancia da classe para execauto
		oNFE := TAutomacaoNotaEntrada():New()
		//Campos para workflow
		
		
		oNFE:oPro:oWFP:cMethod := "Classificacao de "+IIF(lServico, 'Pre-Nota de Serviço', 'Documento de Entrada')
		oNFE:oPro:oWFP:AddField("F1_DOC")
		oNFE:oPro:oWFP:AddField("F1_SERIE")
		oNFE:oPro:oWFP:AddField("F1_FORNECE")
		oNFE:oPro:oWFP:AddField("F1_LOJA")
		oNFE:oPro:oWFP:AddField("F1_EMISSAO")

		//Classe padrao de Log de Processo e Workflow
		oNFE:oPro:Start()

		lErroLinha 	:= .F.

		If ( oNFE:GetByBZ(oProc:oItens:GetItem(nCount)) )

			IF (!lServico)

				oNFE:SetTESPN()

				If !(oNFE:Classificar())

					//U_FROPMSG("TAutomacaoNotaEntrada", oNFE:cLogRet)

					oProc:oItens:GetItem(nCount):SetStatus(.F., oNFE:cLogRet)
					oProc:oItens:GetItem(nCount):UpdateBizagi("ERRO CLASSIFICACAO","")
					lErroLinha := .T.

				Else

					oProc:oItens:GetItem(nCount):SetStatus(.T., "")
					oProc:oItens:GetItem(nCount):UpdateBizagi("PROCESSADO COM SUCESSO","{F1:, "+AllTrim(Str(oNFE:RecERP))+"}")
					lErroLinha := .F.

				EndIf

			ELSE

				//Servico - finaliza item BIZAGI
				oProc:oItens:GetItem(nCount):SetStatus(.T., "")
				oProc:oItens:GetItem(nCount):UpdateBizagi("PRE-NOTA SERVIÇO APROVADA","{F1:, "+AllTrim(Str(oNFE:RecERP))+"}")

				//Worklfow informativo de NFS disponivel para classificacao		
				oNFE:oPro:oWFP:cMenRet := "PRE-NOTA DE SERVICO APROVADA PARA CLASSIFICAÇÃO"		
				oNFE:oLog:cIDProc 	:= oNFE:oPro:cIDProc
				oNFE:oLog:cOperac 	:= "N"	
				oNFE:oLog:cMetodo 	:= "IBZ_CNFS"
				oNFE:oLog:cTabela 	:= RetSQLName("SF1")  	//tabela de origem
				oNFE:oLog:nIDTab 	:= oNFE:RecERP			//recno da tabela de origem
				oNFE:oLog:cRetMen	:= "PRE-NOTA DE SERVICO APROVADA PARA CLASSIFICAÇÃO"
				oNFE:oLog:cHrFin 	:= Time()
				oNFE:oLog:cEnvWF 	:= "S"	
				oNFE:oLog:Insert()

			ENDIF

		Else

			If !( oProc:oItens:GetItem(nCount):lDadosOk )		
				oProc:oItens:GetItem(nCount):SetStatus(.F., "TAutomacaoNotaEntrada > Estrutura do campo DADOS_ENTRADA inválida.")
				oProc:oItens:GetItem(nCount):UpdateBizagi("NÃO PROCESSADO","")
			ElseIf !( oProc:oItens:GetItem(nCount):lConferido )
				oProc:oItens:GetItem(nCount):SetStatus(.F., "TAutomacaoNotaEntrada > Documento RECUSADO pelo processo.")
				oProc:oItens:GetItem(nCount):UpdateBizagi("NÃO PROCESSADO","")
			ElseIf !( oProc:oItens:GetItem(nCount):lDocOk )
				oProc:oItens:GetItem(nCount):SetStatus(.F., "TAutomacaoNotaEntrada > Documento de Entrada não Localizado no ERP.")
				oProc:oItens:GetItem(nCount):UpdateBizagi("NÃO PROCESSADO","")
			EndIf

			lErroLinha := .T.

		EndIf

		oProc:oItens:GetItem(nCount):Update()


		oNFE:oLog:cIDProc 	:= oNFE:oPro:cIDProc
		oNFE:oLog:cOperac 	:= "N"	
		oNFE:oLog:cMetodo 	:= "IBZ_CNFE"
		oNFE:oLog:cTabela 	:= RetSQLName("SF1")  	//tabela de origem
		oNFE:oLog:nIDTab 	:= oNFE:RecERP			//recno da tabela de origem
		oNFE:oLog:cRetMen	:= oNFE:cLogRet			//mensagem do erro/retorno
		oNFE:oLog:cHrFin 	:= Time()
		oNFE:oLog:cEnvWF 	:= IIF(lErroLinha,"S","N")	
		oNFE:oLog:Insert()

		If (lErroLinha)
			oNFE:oPro:oWFP:cMenRet := oNFE:cLogRet
		EndIf		

		oNFE:oPro:Finish()
		//FIM workflow

		oNFE := Nil

		nCount++
	EndDo

Return

