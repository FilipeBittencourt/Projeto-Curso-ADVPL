#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} PDMCARACVAL
@description Estrutura para receber as caracteristicas/Valores do PDM selecionado
@author Fernando Rocha
@since 14/08/2018
@type class
/*/
WSSTRUCT PDMCARACVAL 

	WSDATA Sequencia 	AS String
	WSDATA Item			AS String

ENDWSSTRUCT

/*/{Protheus.doc} PDMMARCA
@description Estrutura para receber as marcas do produto
@author Fernando Rocha
@since 14/08/2018
@type class
/*/
WSSTRUCT PDMMARCA
	WSDATA Marca	 	AS String   //Passar o CODIGO da marca ZD8
	WSDATA Referencia	AS String
	WSDATA InfAdicional	AS String
ENDWSSTRUCT

WSSTRUCT NewProduct //LP
WSDATA Codigo      			AS STRING	OPTIONAL
WSDATA Grupo       			AS STRING
WSDATA Tipo        			AS STRING	OPTIONAL
WSDATA TipoBianco  			AS STRING	OPTIONAL
WSDATA Politica    			AS STRING	OPTIONAL
WSDATA Descricao   			AS STRING 
WSDATA Unidade     			AS STRING	OPTIONAL
WSDATA LocalBianco 			AS STRING	OPTIONAL
WSDATA LocalIncesa 			AS STRING	OPTIONAL
WSDATA LocalPadrao 			AS STRING	OPTIONAL
WSDATA SegUm       			AS STRING	OPTIONAL
WSDATA Fator       			AS STRING	OPTIONAL
WSDATA MonoClassif 			AS STRING	OPTIONAL
WSDATA PecasCaixa  			AS INTEGER	OPTIONAL
WSDATA ConvPallets 			AS INTEGER	OPTIONAL
WSDATA Obs         			AS STRING	OPTIONAL
WSDATA Emissao     			AS Date		OPTIONAL
WSDATA TE					AS STRING 	OPTIONAL
WSDATA TS              		AS STRING 	OPTIONAL
WSDATA Conta           		AS STRING	OPTIONAL
WSDATA NCM             		AS STRING	OPTIONAL
WSDATA ICMS            		AS STRING 	OPTIONAL
WSDATA IPI             		AS STRING 	OPTIONAL
WSDATA ISS             		AS STRING 	OPTIONAL
WSDATA ICMRET          		AS STRING 	OPTIONAL
WSDATA Origem          		AS STRING 	OPTIONAL
WSDATA ClasFis         		AS STRING 	OPTIONAL
WSDATA GrpTrib         		AS STRING 	OPTIONAL
WSDATA ContaResult     		AS STRING 	OPTIONAL
WSDATA ContaResultInd  		AS STRING 	OPTIONAL
WSDATA ContaResultAdm  		AS STRING 	OPTIONAL
WSDATA INSS            		AS STRING 	OPTIONAL
WSDATA CNV52           		AS STRING 	OPTIONAL
WSDATA TipoProdContab  		AS STRING 	OPTIONAL
WSDATA AplicacaoDireta  	AS STRING 	OPTIONAL	
WSDATA EhComum  			AS STRING 	OPTIONAL
WSDATA Item        			AS STRING 	OPTIONAL
WSDATA Importado        	AS STRING 	OPTIONAL //true ou false
WSDATA Anuente       	 	AS STRING 	OPTIONAL //true ou false
WSDATA IsPDM        		AS STRING 	OPTIONAL
WSDATA GrupoPDM        		AS STRING 	OPTIONAL 
WSDATA SubgrupoPDM     		AS STRING 	OPTIONAL
WSDATA FamiliaPDM      		AS STRING 	OPTIONAL
WSDATA aPDMCaracteristicas	AS ARRAY OF PDMCARACVAL OPTIONAL
WSDATA aPDMMarcas		   	AS ARRAY OF PDMMARCA OPTIONAL
ENDWSSTRUCT

WSSTRUCT Cliente
	WSDATA Codigo				AS String OPTIONAL
	WSDATA Loja					AS String OPTIONAL 
	WSDATA Nome					AS String OPTIONAL 
	WSDATA CnpjCpf				AS String OPTIONAL 
	WSDATA TpPessoa				AS String OPTIONAL 
	WSDATA NomeFant   			AS String OPTIONAL 
	WSDATA TpCli				AS String OPTIONAL 
	WSDATA EndTpLog				AS String OPTIONAL
	WSDATA EndDesc				AS String OPTIONAL 
	WSDATA EndNum				AS String OPTIONAL 
	WSDATA EndUF        		AS String OPTIONAL 
	WSDATA EndCodMun			AS String OPTIONAL 
	WSDATA EndMun       		AS String OPTIONAL 
	WSDATA EndBairro    		AS String OPTIONAL 
	WSDATA EndCep       		AS String OPTIONAL 
	WSDATA EndPais   			AS String OPTIONAL
	WSDATA EndComplemento 		AS String OPTIONAL
	WSDATA Telefone     		AS String OPTIONAL 
	WSDATA Fax					AS String OPTIONAL 
	WSDATA Contato      		AS String OPTIONAL
	WSDATA InscEst      		AS String OPTIONAL 
	WSDATA EmailNF      		AS String OPTIONAL 
	WSDATA EmailCont    		AS String OPTIONAL
	WSDATA EmailCobr    		AS String OPTIONAL
	WSDATA HomePage	    		AS String OPTIONAL 
	WSDATA TpPag        		AS String OPTIONAL 
	WSDATA CobTpLog     		AS String OPTIONAL
	WSDATA CobEnd       		AS String OPTIONAL 
	WSDATA CobNum       		AS String OPTIONAL 
	WSDATA CobUF        		AS String OPTIONAL 
	WSDATA CobMun       		AS String OPTIONAL 
	WSDATA CobBairro    		AS String OPTIONAL 
	WSDATA CobCep       		AS String OPTIONAL 
	WSDATA EhContrib    		AS String OPTIONAL 
	WSDATA EhCadExpres  		AS String OPTIONAL
	WSDATA BacenCodPais 		AS String OPTIONAL
	WSDATA Suframa				AS String OPTIONAL
	WSDATA CodMunZonaFranca 	AS String OPTIONAL
	WSDATA DescontoSuframa 		AS String OPTIONAL
	WSDATA FomeZero				AS String OPTIONAL
	WSDATA TpSeg				AS String OPTIONAL 
	WSDATA Segmento				AS String OPTIONAL 
	WSDATA TpLimite				AS String OPTIONAL
	WSDATA GrupoLimite			AS String OPTIONAL	
	WSDATA TratEspecial 		AS String OPTIONAL
	WSDATA OBSRomaneio			AS String OPTIONAL  
	WSDATA AvaliaCliente		AS String OPTIONAL
	WSDATA LimiteCredito		AS String OPTIONAL
	WSDATA DataVencLimite   	AS String OPTIONAL
	WSDATA Risco				AS String OPTIONAL
	WSDATA CodRepresenBianco 	AS String OPTIONAL
	WSDATA CodRepresenIncesa 	AS String OPTIONAL
	WSDATA CodRepresenBellaCasa	AS String OPTIONAL
	WSDATA CodRepresenVitcer	AS String OPTIONAL
	WSDATA CodRepresenMundialli	AS String OPTIONAL	
	WSDATA ValComissBianco		AS String OPTIONAL
	WSDATA ValComissIncesa		AS String OPTIONAL
	WSDATA ValComissBellaCasa	AS String OPTIONAL
	WSDATA ValComissVitcer		AS String OPTIONAL
	WSDATA ValComissMundialli	AS String OPTIONAL
	WSDATA NumProcessoBizagi	AS String OPTIONAL	
	WSDATA TPJ 					AS String OPTIONAL	
	WSDATA Categoria			AS String OPTIONAL		
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT SolicCredito
	WSDATA Codigo		AS String OPTIONAL
	WSDATA DataSol		AS String OPTIONAL
	WSDATA HoraSol		AS String OPTIONAL	
	WSDATA CodCliente	AS String 
	WSDATA EhNovo		AS String OPTIONAL
	WSDATA Pedido		AS String OPTIONAL
	WSDATA TpPagamento	AS String OPTIONAL
	WSDATA CondPamento	AS String OPTIONAL
	WSDATA ObserSol		AS String OPTIONAL
	WSDATA Prazo		AS String OPTIONAL
	WSDATA StatusSol	AS String OPTIONAL
	WSDATA DataAprov	AS String OPTIONAL
	WSDATA ObserAprov	AS String OPTIONAL
	WSDATA Valor		AS String 
	WSDATA EmpresaPed	AS String OPTIONAL 
	WSDATA Usuario		AS String OPTIONAL
	WSDATA NumBizagi		AS String OPTIONAL
	
ENDWSSTRUCT	
//------------------------------------------------------
WSSTRUCT CabecSolicCompra
	WSDATA Codigo 				AS String OPTIONAL 
	WSDATA Empresa              AS STRING
	WSDATA Filial 	            AS STRING
	WSDATA Matricula			AS String 
	WSDATA NomeSolicitante      AS String
	WSDATA DataEmissao			AS String
	WSDATA DataAprovacao		AS String 	  	 
	WSDATA Necessidade			AS String
	WSDATA Prioridade			AS String
	WSDATA Contrato				AS String OPTIONAL
	WSDATA Melhoria				AS String OPTIONAL
	WSDATA CentroCusto			AS String OPTIONAL
	WSDATA Conta				AS String OPTIONAL //08/03/2016 - Luana Marin Ribeiro - esse campo foi retirado do cabecalho e colocado aqui, no item.
	WSDATA ItemConta			AS String OPTIONAL	
	WSDATA ClasseValor			AS String OPTIONAL
	WSDATA SituacaoAprovacao    AS String OPTIONAL
	WSDATA Indicacao            AS STRING OPTIONAL
	WSDATA SolicitBizagi        AS STRING OPTIONAL
	WSDATA TemProdNovo          AS STRING OPTIONAL
	WSDATA SolicEmpresa         AS STRING OPTIONAL
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT ItemSolicitacao
	WSDATA Item							As String		
	WSDATA Produto						As String 
	WSDATA PriUnidadeMedida				As String OPTIONAL
	WSDATA PriQuantidade				As Float
	WSDATA SegUnidadeMedida				As String OPTIONAL
	WSDATA SegQuantidade				As Float  OPTIONAL
	WSDATA Observacao					As String OPTIONAL
	WSDATA DescricaoProduto				As String OPTIONAL
	WSDATA ValorUnitario				As Float  OPTIONAL
	WSDATA Tag							AS String OPTIONAL
	WSDATA Aplicacao					AS String OPTIONAL
	WSDATA Fornecedor           		AS String OPTIONAL
	WSDATA CodCliente           		AS String OPTIONAL
	WSDATA TemAnexo           			AS String OPTIONAL
	WSDATA Conta						AS String OPTIONAL //08/03/2016 - Luana Marin Ribeiro - esse campo foi retirado do cabecalho e colocado aqui, no item.		
	WSDATA Importado					AS String OPTIONAL
	WSDATA AtenderServico				AS String OPTIONAL	
	WSDATA Driver						AS String OPTIONAL	
	WSDATA Armazem						AS String OPTIONAL	
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT SolicitacaoCompra
	WSDATA SCCab 						As CabecSolicCompra
	WSDATA SCItem						As ARRAY OF ItemSolicitacao
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT novaListaProdutos
	WSDATA Lista						As ARRAY OF NewProduct
	WSDATA Solicitante  				AS STRING  OPTIONAL
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT Resultado
	WSDATA Codigo		AS String //
	WSDATA Erro			AS String //
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT CabecalhoCotacao
	WSDATA EmpresaCotacao	AS String
	WSDATA Fornecedor		AS String
	WSDATA LojaFornedor		AS String
	WSDATA CodigoCotacao	AS String
	WSDATA Contato			AS String
	WSDATA DataValidade		AS String 	
	WSDATA Orcamento		AS String 	OPTIONAL
	WSDATA FormaPagamento	AS String
	WSDATA FormPagNegociado AS String	OPTIONAL
	WSDATA TipoFrete		AS String
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT ItemCotacao
	WSDATA Produto			 AS String
	WSDATA IPI				 AS Float
	WSDATA DiasEntrega		 AS Integer
	WSDATA PrecoUnitario	 AS Float
	WSDATA Desconto			 AS Float OPTIONAL
	WSDATA ValorDesconto	 AS Float OPTIONAL
	WSDATA Moeda			 AS Integer
	WSDATA ValorSubst		 AS Float 
	WSDATA PrecoTotal		 AS Float
	WSDATA Marca			 AS String OPTIONAL
	WSDATA AtendeTotal		 AS Boolean
	WSDATA Observacao		 AS String OPTIONAL
	WSDATA ProdutoFornecedor AS String OPTIONAL
	WSDATA AtendeCotacao	 AS String OPTIONAL
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT Cotacao
	WSDATA Cabecalho		As CabecalhoCotacao					
	WSDATA Item				As ARRAY OF ItemCotacao
ENDWSSTRUCT
//------------------------------------------------------

//#######################################################
//############## INICIO TABELA DE PRECO #################
//#######################################################
WSSTRUCT CabecTabelaPreco
	WSDATA TipoNegociacao AS String
	WSDATA FornDscAtual AS String 
	WSDATA FornDscNovo AS String
	WSDATA FornCodLojaAtual AS String 
	WSDATA FornCodLojaNovo AS String
	WSDATA FormaPagAtual AS String
	WSDATA FormaPagNovo AS String
	WSDATA TipoNegoc AS String		
	WSDATA AplicProd AS String
	WSDATA AplicFrete AS String
	WSDATA DataPrevSubs AS String
	//WSDATA DataIniVig AS String		
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT ItemTabelaPreco
	WSDATA ProdCodAtual AS String		
	WSDATA ProdCodNovo AS String
	WSDATA PrecoAtual AS String
	WSDATA PrecoNovo AS String
	WSDATA FreteAtual AS String
	WSDATA FreteNovo AS String
ENDWSSTRUCT
//------------------------------------------------------
WSSTRUCT TabelaPreco
	WSDATA TPCab 						As CabecTabelaPreco
	WSDATA TPItem						As ARRAY OF ItemTabelaPreco
ENDWSSTRUCT
//------------------------------------------------------
//#######################################################
//################ FIM TABELA DE PRECO ##################
//#######################################################


//#######################################################
//################# INICIO EMBALAGEM ####################
//#######################################################
WSSTRUCT EmbalagemInclusao
	WSDATA DescNova						As String
	WSDATA NcmAnterior					As String
ENDWSSTRUCT

WSSTRUCT EmbalagemAlteracao
	WSDATA CodAnterior 					As String
	WSDATA CodNovo						As String
	WSDATA Tipo							As String
	WSDATA Empresa						As String
ENDWSSTRUCT
//------------------------------------------------------
//#######################################################
//################### FIM EMBALAGEM #####################
//#######################################################


WSSERVICE BIANCO_BIZAGI         
	//atributos
	WSDATA	 Codigo	    		AS String
	WSDATA	 oResultado    		AS Resultado
	WSDATA   oCliente   		AS Cliente
	WSDATA   oSolicCredito  	AS SolicCredito
	WSDATA   SC					AS SolicitacaoCompra
	WSDATA   LP					AS novaListaProdutos
	WSDATA	 oCotacao			AS Cotacao
	WSDATA	 oTabPreco			AS TabelaPreco
	WSDATA	 oEmbInclusao		AS EmbalagemInclusao
	WSDATA	 oEmbAlteracao		AS EmbalagemAlteracao

	// metodos
	WSMETHOD putCliente
	WSMETHOD putSolicCredito
	WSMETHOD putSolicitacaoCompra
	WSMETHOD putNovoProduto
	WSMETHOD AtualizaCotacao
	WSMETHOD putTabelaPreco
	WSMETHOD putEmbalagemInclusao
	WSMETHOD putEmbalagemAlteracao

ENDWSSERVICE


WSMETHOD putSolicCredito WSRECEIVE oSolicCredito WSSEND oResultado WSSERVICE BIANCO_BIZAGI
Local cCodSol := ""
Local lInsert := .T.

	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	VarInfo("oSolicCredito", oSolicCredito)

	If !Empty(oSolicCredito:NumBizagi)
	
		If Empty(Alltrim(oSolicCredito:Codigo))
			lInsert := .T.			
			cCodSol	:= GetSxEnum('SZU', 'ZU_CODIGO')				
		Else
			SZU->(DbSetOrder(1))	
			If SZU->(DbSeek(xFilial("SZU")+Alltrim(oSolicCredito:Codigo)))
				lInsert := .F.
				cCodSol	:= SZU->ZU_CODIGO
			EndIf
		EndIf
		
		ConOut("[WS_BIZAGI - Method PutSolicCredito]: " + If (lInsert, "INSERT", "UPDATE") + " - [Processo Bizagi]: " + oSolicCredito:NumBizagi)
		
		Begin Transaction
	
			DbSelectArea("SZU")
		
			If lInsert
	
				ConOut("[WS_BIZAGI - Method PutSolicCredito]: INSERT - [Processo Bizagi]: " + oSolicCredito:NumBizagi + " - [CodSol]: " + cCodSol)			
				
				SZU->(RecLock("SZU", lInsert))
					SZU->ZU_FILIAL	:= xFilial("SZU")
					SZU->ZU_CODIGO	:= cCodSol
					SZU->ZU_NOV_CLI	:= "NOV"
					SZU->ZU_PEDIDO	:= "*"
					SZU->ZU_TIPOPAG	:= "BANCO"
					SZU->ZU_STATUS	:= "PENDENTE"
					SZU->ZU_COND_PA	:= "903"
					SZU->ZU_OBSERVA	:= "CLIENTE NOVO!"
					SZU->ZU_USUARIO	:= 'B-' + If (Len(oSolicCredito:Usuario) > 23, Substring(oSolicCredito:Usuario,1, 23), oSolicCredito:Usuario)
					SZU->ZU_CODCLI	:= oSolicCredito:CodCliente
					SZU->ZU_VALOR	:= VAL(If (oSolicCredito:Valor == Nil, '0', oSolicCredito:Valor))
					SZU->ZU_OBSERVA	:= If (oSolicCredito:ObserSol == Nil, "", oSolicCredito:ObserSol	)
					SZU->ZU_PEDIDO	:= If (oSolicCredito:Pedido == "",  "*", oSolicCredito:Pedido) 
					SZU->ZU_DATA	:= dDatabase
					SZU->ZU_SHORA	:= Time()
					SZU->ZU_PRAZO	:= DataValida(DataValida(DataValida(dDatabase + 1) + 1) + 1)
					SZU->ZU_BIZAGI	:= oSolicCredito:NumBizagi
				SZU->(MsUnLock())
				
				ConfirmSX8()
				
				::oResultado:Codigo := cCodSol
				::oResultado:Erro	:= ''		
				
			Else
	
				ConOut("[WS_BIZAGI - Method PutSolicCredito]: UPDATE - [Processo Bizagi]: " + oSolicCredito:NumBizagi + " - [CodSol]: " + cCodSol)			
				
				SZU->(DbSetOrder(1))					
				If SZU->(DbSeek(xFilial("SZU")+cCodSol))
					
					SZU->(RecLock("SZU",.F.))
		
						If Upper(oSolicCredito:StatusSol) $ "REPROVADO/APROVADO"
						
							SZU->ZU_DATAAPR	:= DATE()
							SZU->ZU_OBS_LIB := UPPER(If (oSolicCredito:ObserAprov	== Nil, "", oSolicCredito:ObserAprov))
							SZU->ZU_STATUS  := UPPER(oSolicCredito:StatusSol)
							
						EndIf
			
						SZU->ZU_TIPOPAG := If (oSolicCredito:TpPagamento == Nil, "BANCO", oSolicCredito:TpPagamento)
						SZU->ZU_COND_PA := If (oSolicCredito:CondPamento == Nil, "903", oSolicCredito:CondPamento) 
						SZU->ZU_EMPRESA := If (oSolicCredito:EmpresaPed	== Nil, "", oSolicCredito:EmpresaPed)
						SZU->ZU_USUARIO := 'B-' + If (Len(oSolicCredito:Usuario) > 23, Substring(oSolicCredito:Usuario,1, 23), oSolicCredito:Usuario) 
						SZU->ZU_CODCLI := oSolicCredito:CodCliente
		
					SZU->(MsUnLock())
					
					::oResultado:Codigo := cCodSol
					::oResultado:Erro	:= ''				
		
				Else
				
					ConOut("[WS_BIZAGI - Method PutSolicCredito]: UPDATE - [Processo Bizagi]: " + oSolicCredito:NumBizagi + " - [CodSol]: " + cCodSol + " NAO ENCONTRADA")			
				
					::oResultado:Codigo := cCodSol
					::oResultado:Erro	:= "Solicitacao de Credito: "+ cCodSol +" não encontrada"
				
				EndIf
	
			EndIf
	
		End Transaction

	Else
	
		ConOut("[WS_BIZAGI - Method PutSolicCredito]: " + If (lInsert, "INSERT", "UPDATE") + " - [Processo Bizagi]: NULL")			
		
		::oResultado:Codigo := ""
		::oResultado:Erro	:= "Numero do Processo Bizagi nao informado - [Cliente]: " + oSolicCredito:CodCliente
			
	EndIf

Return(.T.)


WSMETHOD putCliente WSRECEIVE oCliente WSSEND oResultado WSSERVICE BIANCO_BIZAGI

	Local nOperacao
	Local cLojaCliente
	Local cCliBZ := ""

	PRIVATE lMsErroAuto 	:= .F.
	Private lMsHelpAuto		:= .T.    
	Private lAutoErrNoFile 	:= .T.

	RPCSETTYPE(3)
	RPCSETENV('01','01')

	::oResultado := NIL
	::oResultado := WSClassNew( "Resultado" )
	CONOUT(" ---- PROCESSO CADASTRAR CLIENTE -----")

	//Parâmetros do MSExecAuto:
	//3 - Inclusão.
	//4 - Alteração
	//5 - Exclusão

	CONOUT("CODIGO CLIENTE : " + IIF(oCliente:Codigo == Nil, "", oCliente:Codigo))
	
	If Empty(oCliente:Codigo)
	
		nOperacao := 3
		
		INCLUI := .T.

		CSQL:=" SELECT TOP 1 A1_COD, A1_YBIZAGI, COUNT(A1_COD) AS QTD "
		CSQL+=" FROM SA1010							"
		CSQL+=" WHERE A1_CGC = '"+Alltrim(oCliente:CnpjCpf)+"'"
		CSQL+=" AND D_E_L_E_T_ = ''
		CSQL+=" GROUP BY A1_COD, A1_YBIZAGI"

		If chkfile("_SA1")
			dbSelectArea("_SA1")
			dbCloseArea("_SA1")
		EndIf

		TCQUERY CSQL ALIAS "_SA1" NEW
		dbSelectArea("_SA1")

		If _SA1->QTD > 0
			// (Thiago - 11/06/2015) -> Véspera
			// A fim de evitar erro do Bizagi que não está setando o codigo do cliente.
			If AllTrim(_SA1->A1_YBIZAGI) == AllTrim(oCliente:NumProcessoBizagi)
				nOperacao 			:= 4
				oCliente:Codigo 	:= _SA1->A1_COD
				::oResultado:Codigo := _SA1->A1_COD
				CONOUT("CLIENTE - ENCONTROU BIZAGI")
			Else
				::oResultado:Codigo := _SA1->A1_COD 
				::oResultado:Erro	:= "O "+IIF(oCliente:TPPessoa == "J", "CNPJ","CPF" )+" já está cadastrado no Sistema"
				dbCloseArea("_SA1")
				CONOUT("CLIENTE - ABORTOU INCLUSAO")
				Return .T.
			EndIf
		EndIf		 
	Else
		nOperacao := 4
	EndIf

	//Rodrigo informou que inicialmente será não.
	If Empty(oCliente:EhCadExpres)
		oCliente:EhCadExpres := "N"
	EndIf

	VarInfo("oCliente",oCliente)

	CONOUT("Representante Bianco - " + IIF(oCliente:CodRepresenBianco==NIL,'',oCliente:CodRepresenBianco))
	IF(oCliente:CodRepresenBianco == NIL)
		oCliente:CodRepresenBianco := ''
	EndIf
	CONOUT("Comissão Bianco - " + IIF(oCliente:ValComissBianco==NIL,'',oCliente:ValComissBianco))		
	IF(oCliente:ValComissBianco == NIL) 
		oCliente:ValComissBianco := '0'
	EndIf
	CONOUT("Representante Incesa - " + IIF(oCliente:CodRepresenIncesa==NIL,'',oCliente:CodRepresenIncesa))
	If oCliente:CodRepresenIncesa == NIL
		oCliente:CodRepresenIncesa := ''
	EndIf	
	CONOUT("Comissão Incesa - " + IIF(oCliente:ValComissIncesa==NIL,'', oCliente:ValComissIncesa))
	IF(oCliente:ValComissIncesa == NIL)
		oCliente:ValComissIncesa := '0'
	EndIf
	CONOUT("Representante BellaCasa - " + IIF(oCliente:CodRepresenBellaCasa==NIL,'',oCliente:CodRepresenBellaCasa))
	IF(oCliente:CodRepresenBellaCasa == NIL) 
		oCliente:CodRepresenBellaCasa := ''
	EndIf	
	CONOUT("Comissão BellaCasa - " + IIF(oCliente:ValComissBellaCasa==NIL,'', oCliente:ValComissBellaCasa))
	IF(oCliente:ValComissBellaCasa == NIL)
		oCliente:ValComissBellaCasa := '0'
	EndIf
	CONOUT("Representante Vitcer - " + IIF(oCliente:CodRepresenVitcer==NIL,'',oCliente:CodRepresenVitcer))
	IF(oCliente:CodRepresenVitcer == NIL) 
		oCliente:CodRepresenVitcer := ''
	EndIf
	CONOUT("Comissão Vitcer - " + IIF(oCliente:ValComissVitcer==NIL,'', oCliente:ValComissVitcer))
	IF(oCliente:ValComissVitcer == NIL)
		oCliente:ValComissVitcer := '0'
	EndIf		
	CONOUT("Representante Mundi - " + IIF(oCliente:CodRepresenMundialli==NIL,'',oCliente:CodRepresenMundialli))
	IF(oCliente:CodRepresenMundialli == NIL)
		oCliente:CodRepresenMundialli :=''
	EndIf
	CONOUT("Comissão Mundi - " + IIF(oCliente:ValComissMundialli==NIL,'', oCliente:ValComissMundialli))
	IF(oCliente:ValComissMundialli == NIL) 
		oCliente:ValComissMundialli := '0'
	EndIf 

	If(oCliente:Suframa	== Nil)
		oCliente:CodMunZonaFranca 	:= ""
		oCliente:DescontoSuframa	:= "N"
		oCliente:Suframa			:= ""
	EndIf

	If ( LEN(oCliente:Loja) < 2 )
		cLojaCliente = "0" + oCliente:Loja
	ElseIf (LEN(oCliente:Loja) == 2)
		cLojaCliente = oCliente:Loja
	EndIf	
	CONOUT("Cliente Loja - " + cLojaCliente)

	aVetor:={;
	{"A1_FILIAL" 		, xFilial("SA1"), Nil},;
	{"A1_LOJA"    		, cLojaCliente, Nil},;
	{"A1_NOME"			, AllTrim(StrTran(AllTrim(Upper(oCliente:Nome)),CHR(10),' ')), Nil},;
	{"A1_PESSOA"    	, oCliente:TPPessoa, Nil},;
	{"A1_CGC"       	, oCliente:CnpjCpf, Nil},;
	{"A1_TIPO"      	, oCliente:TpCli, Nil},;
	{"A1_NREDUZ"    	, AllTrim(Upper(oCliente:NomeFant)), Nil},;
	{"A1_END"       	, Upper(AllTrim(StrTran(oCliente:EndDesc,CHR(10), ' ')) +', ' + AllTrim(StrTran(oCliente:EndNum,CHR(10), ' '))), Nil},;
	{"A1_COMPLEM"       , Upper(alltrim(IIF(oCliente:EndComplemento == Nil, "", oCliente:EndComplemento ))), Nil},;
	{"A1_EST"       	, oCliente:EndUF, Nil},;
	{"A1_COD_MUN"      	, Upper(oCliente:EndCodMun), Nil},;
	{"A1_MUN"       	, AllTrim(Upper(oCliente:EndMun)), Nil},;
	{"A1_BAIRRO"    	, AllTrim(Upper(oCliente:EndBairro)), Nil},;
	{"A1_CEP"       	, AllTrim(oCliente:EndCep), Nil},;
	{"A1_TEL"			, AllTrim(oCliente:Telefone), Nil},; 
	{"A1_FAX"       	, AllTrim(IIF(oCliente:Fax == Nil, "", oCliente:Fax)), Nil},;
	{"A1_CONTATO"   	, AllTrim(Upper(oCliente:Contato)), Nil},;
	{"A1_INSCR"     	, Upper(AllTrim(oCliente:InscEst)), Nil},;
	{"A1_YMAILNF"   	, AllTrim(LOWER(oCliente:EmailNF)), Nil},;
	{"A1_EMAIL" 		, AllTrim(LOWER(oCliente:EmailCont)), Nil},;
	{"A1_YEMABOL" 		, AllTrim(IIF(oCliente:EmailCobr == Nil, "", oCliente:EmailCobr)), Nil},;	
	{"A1_HPAGE"     	, AllTrim(IIF(oCliente:HomePage == Nil,"", LOWER(oCliente:HomePage))), Nil},;
	{"A1_NATUREZ"		, '1121', Nil},;
	{"A1_ENDCOB"    	, Upper(AllTrim(oCliente:CobEnd) + ', ' + AllTrim(oCliente:CobNum)), Nil},;
	{"A1_ESTC"			, oCliente:CobUF, Nil},;
	{"A1_MUNC"			, AllTrim(Upper(oCliente:CobMun)), Nil},;
	{"A1_BAIRROC"   	, AllTrim(Upper(oCliente:CobBairro)), Nil},;
	{"A1_CEPC"      	, AllTrim(oCliente:CobCep), Nil},;
	{"A1_YCADEXP"		, IIF(oCliente:EhCadExpres == "1" .Or. oCliente:EhCadExpres == "S" .Or. UPPER(oCliente:EhCadExpres) == "TRUE", "1","2"), Nil},;
	{"A1_CONTRIB"		, IIF(oCliente:EhContrib == "1" .Or. oCliente:EhContrib == "S" .Or. UPPER(oCliente:EhContrib) == "TRUE", "1","2"), Nil},;
	{"A1_FOMEZER"		, IIF(oCliente:FomeZero == "1" .Or. oCliente:FomeZero == "S" .Or. UPPER(oCliente:FomeZero) == "TRUE", "1","2"), Nil},;
	{"A1_CODPAIS"		, oCliente:BacenCodPais, Nil},; 
	{"A1_YTIPOLC"		, oCliente:TpLimite, Nil},;
	{"A1_SATIV1"		, oCliente:Segmento, Nil},;
	{"A1_YTPSEG"		, oCliente:TpSeg, Nil},;
	{"A1_YAVALCL"		, AllTrim(IIF(oCliente:AvaliaCliente == Nil, "",oCliente:AvaliaCliente)), Nil},;
	{"A1_YOBSROM"		, AllTrim(IIF(oCliente:OBSRomaneio == Nil, "",oCliente:OBSRomaneio)), Nil},;
	{"A1_LC"			, VAL(IIF(oCliente:LimiteCredito == Nil, "0", oCliente:LimiteCredito)), Nil},;
	{"A1_RISCO"			, oCliente:Risco, Nil},;
	{"A1_YTRTESP"		, IIF(oCliente:TratEspecial == "1" .Or. oCliente:TratEspecial == "S" .Or. UPPER(oCliente:TratEspecial) == "TRUE","1","2"), Nil},;
	{"A1_SUFRAMA"		, IIF(oCliente:Suframa == Nil .OR. AllTrim(oCliente:Suframa) == '-',"", oCliente:Suframa), Nil},; 
	{"A1_CALCSUF"		, IIF(oCliente:DescontoSuframa == Nil,"N",oCliente:DescontoSuframa), Nil},;
	{"A1_YATUCLI"		, "S", NIL},;
	{"A1_YCAT"			, AllTrim(IIF(oCliente:Categoria == Nil, "", oCliente:Categoria)), Nil};
	}

	If !Empty(oCliente:TPJ)
		AADD(aVetor,{"A1_TPJ",AllTrim(oCliente:TPJ), Nil})
	EndIf

	//Ticket 26346 - Solicitação do Wellison do Financeiro para garantir padrão 'S' nos campos A1_YGERFAT e A1_YFGNRE
	AADD(aVetor,{"A1_YGERFAT",'S', Nil})
	AADD(aVetor,{"A1_YTFGNRE",'S', Nil})

	If !Empty(oCliente:CodMunZonaFranca) .And. oCliente:CodMunZonaFranca != '00000'
		AADD(aVetor,{"A1_CODMUN"		, IIF(oCliente:CodMunZonaFranca == Nil,""	,oCliente:CodMunZonaFranca)	, Nil})
	EndIf

	If !Empty(oCliente:CodRepresenBianco) .And. oCliente:CodRepresenBianco != '000000'
		AADD(aVetor,{"A1_VEND"			, oCliente:CodRepresenBianco 	, Nil})
	EndIf

	If !Empty(oCliente:CodRepresenIncesa) .And. oCliente:CodRepresenIncesa != '000000' 
		AADD(aVetor,{"A1_YVENDI"		, oCliente:CodRepresenIncesa 	, Nil})
	EndIf	

	If !Empty(oCliente:CodRepresenBellaCasa) .And. oCliente:CodRepresenBellaCasa != '000000' 
		AADD(aVetor,{"A1_YVENBE1"		, oCliente:CodRepresenBellaCasa	, Nil})
	EndIf

	If !Empty(oCliente:CodRepresenVitcer) .And. oCliente:CodRepresenVitcer != '000000'
		AADD(aVetor,{"A1_YVENVT1"		, oCliente:CodRepresenVitcer	, Nil})
	EndIf

	If !Empty(oCliente:CodRepresenMundialli) .And. oCliente:CodRepresenMundialli != '000000'
		AADD(aVetor,{"A1_YVENML1"		, oCliente:CodRepresenMundialli	, Nil})
	EndIf


	CONOUT("Vetor Cliente Gerado!")

	If nOperacao == 4

		CONOUT("--> Limite de Credito ($) = " +(IIF(oCliente:LimiteCredito	== Nil, "0", oCliente:LimiteCredito)))
		AADD(aVetor,{"A1_COD",oCliente:Codigo, Nil})
		AADD(aVetor,{"A1_LC" ,VAL(IIF(oCliente:LimiteCredito	== Nil, "0", oCliente:LimiteCredito)), Nil})

		//If(oCliente:TpLimite == "G") 
		If(oCliente:GrupoLimite != Nil .And. !Empty(oCliente:GrupoLimite) ) 
			AADD(aVetor,{ "A1_GRPVEN", oCliente:GrupoLimite, Nil}) 
		EndIf
		//EndIf
		if !Empty(oCliente:DataVencLimite) .And. oCliente:DataVencLimite != Nil
			aData 	:= StrTokArr(oCliente:DataVencLimite,"/")
			//aData 	:= StrTokArr(oCliente:DataVencLimite,"T")
			aData2	:= StrTokArr(aData[3]," ")
			//aData2 := Replace(aData[1],"-","")

			If Len(aData[1]) == 2  	
				cDataLimite := aData2[1]+aData[1]+aData[2]
			Else
				cDataLimite := aData2[1]+"0"+aData[1]+aData[2]
			EndIf

			CONOUT(cDataLimite)
			CONOUT("DATA LIMITE: " + oCliente:DataVencLimite)
			AADD(aVetor,{"A1_VENCLC"		, StoD(cDataLimite)		, Nil})
		Else
			AADD(aVetor,{"A1_VENCLC"		, dDatabase	- 1		    , Nil})
		EndIf
	Else
		If !Empty(oCliente:NumProcessoBizagi)
			AADD(aVetor,{"A1_YBIZAGI",oCliente:NumProcessoBizagi, Nil})
		EndIf
	EndIf

	BEGIN TRANSACTION

		CONOUT(IIF(nOperacao == 3, 'WS Bizagi: Inserindo Cliente...',  'WS Bizagi: Atualizando Cliente...'))
		CONOUT('Cliente : ' + oCliente:Nome)

		lMsErroAuto := .F.

		MSExecAuto({|x,y| Mata030(x,y)},aVetor,nOperacao)

		If lMsErroAuto

			cAuxErro := ""

			_aAutoerro := GetAutoGrLog()
			cLogTxt := xConvLog(_aAutoerro)
			CONOUT("-----------------------------------")
			CONOUT(cLogTxt)
			CONOUT("-----------------------------------")

			::oResultado:Codigo 	:= 'ERRO'

			if !Empty(cLogTxt)
				::oResultado:Erro		:= cLogTxt
			Else
				::oResultado:Erro		:= xConvLogF(_aAutoerro)
			EndIf

			CONOUT('WS Bizagi: Erro - ' + xConvLogF(_aAutoerro))
			
			DisarmTransaction()
						
		Else

			ConOut("[WS_BIZAGI - Method PutCliente]: " + If (nOperacao == 3, "INSERT", "UPDATE") + " - fRetCodCli [CNPJ]: " + oCliente:CnpjCpf + " - [Processo Bizagi]: " + oCliente:NumProcessoBizagi)
			
			cCliBZ := fRetCodCli(oCliente:CnpjCpf, oCliente:NumProcessoBizagi)
			
			ConOut("[WS_BIZAGI - Method PutCliente]: " + If (nOperacao == 3, "INSERT", "UPDATE") + " - [Cliente]: " + If (Empty(cCliBZ), "NAO ENCONTRADO", cCliBZ))

			If !Empty(cCliBZ)

				::oResultado:Codigo := cCliBZ
				::oResultado:Erro	:= ''

				ConOut("[WS_BIZAGI - Method PutCliente]: " + If (nOperacao == 3, "INSERT", "UPDATE") + " - [Operacao Realizada com Sucesso]")
				
			Else
				
				If nOperacao == 3
				
					::oResultado:Codigo := 'ERRO'
					
					_aAutoerro := GetAutoGrLog()
					
					cLogTxt := xConvLog(_aAutoerro)
					
					::oResultado:Erro	:= 'Erro Protheus: ' + cLogTxt + '( Favor Procurar a TI )'
					
				EndIf
				
			EndIf
			
		EndIf 

	END TRANSACTION

	cCliBZ := ''

Retur(.T.)


WSMETHOD putSolicitacaoCompra WSRECEIVE SC WSSEND oResultado WSSERVICE BIANCO_BIZAGI

	Local i         
	Local cMatric 		:= ''
	Local cSolicEmp		:= ''
	Local cEmpresa		:= ''
	Local cDataAprov 	:= ''
	Local cMsgErroSC	:= ''
	Local lErroSC 		:= .F.
	Local cNumSC		:= ''
	Local jlDoc         := ""

	Conout("<:: Inciando inclusão da Solicitacao de Compras ::>")

	cSolicEmp := IIF(SC:SCCab:SolicEmpresa == Nil,'',Substring(SC:SCCab:SolicEmpresa,1,2))
	cMatric   := SC:SCCab:Matricula
	cEmpresa  := SC:SCCab:Empresa

	IF !Empty(cEmpresa)

		RPCSetType(3)
		WFPrepEnv(SubStr(cEmpresa,1,2), SC:SCCab:Filial)

		Conout("Empresa -> " + SubStr(cEmpresa,1,2))
		Conout("Filial -> " + SC:SCCab:Filial)

	EndIf

	Conout("Matricula -> " + cMatric) 
	CSQL := "SELECT C1_NUM FROM SC1"+SubStr(cEmpresa,1,2)+"0 WHERE C1_YBIZAGI='" + AllTrim(SC:SCCab:SolicitBizagi) + "' AND D_E_L_E_T_ = ''"
	Conout("CSQL -> " + CSQL ) 
	If chkfile("BZVERIF")
		dbSelectArea("BZVERIF")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "BZVERIF" NEW
	dbSelectArea("BZVERIF")	
	While !BZVERIF->(EOF()) 
		::oResultado:Codigo := BZVERIF->C1_NUM
		::oResultado:Erro 	:= ''
		CONOUT("--> Solicitação Existente: " + BZVERIF->C1_NUM  )
		dbCloseArea()
		Return(.T.)
	End
	dbCloseArea()

	VarInfo("SC", SC)

	//                                                       Verifica Data Aprovação
	//******************************************************************************
	cDataAprov := AllTrim(SC:SCCab:DataAprovacao)
	xxDtAprov  := ""
	CSQL := "SELECT CONVERT(VARCHAR,CONVERT(DATETIME,'" + cDataAprov + "'),112) +'-'+ SUBSTRING(CONVERT(VARCHAR,CONVERT(DATETIME,'" + cDataAprov + "'),108),1,5) AS DATAAPRV "
	If chkfile("_TIME")
		dbSelectArea("_TIME")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_TIME" NEW
	dbSelectArea("_TIME")
	dbGoTop()
	xxDtAprov := _TIME->DATAAPRV
	dbSelectArea("_TIME")
	dbCloseArea()

	If Empty(xxDtAprov)
		::oResultado:Codigo := ''		
		::oResultado:Erro   := 'Erro - A data de aprovação está incorreta!'
		CONOUT(cMsgErroSC)
		Return(.T.)
	EndIf

	jlDoc := GetSXENum("SC1","C1_NUM")		
	SC1->(dbSetOrder(1))	
	While SC1->(dbSeek(xFilial("SC1") + jlDoc))	
		ConfirmSX8()		
		jlDoc := GetSXENum("SC1", "C1_NUM")	
	End		

	BEGIN TRANSACTION

		For i:= 1 To Len(SC:SCItem) 

			SB1->(dbSetOrder(1))
			If !SB1->(dbSeek(xFilial("SB1") + Alltrim(SC:SCItem[i]:Produto)))
				lErroSC 	:= .T.
				cMsgErroSC 	:= 'Erro - O Produto ' + SC:SCItem[i]:Produto + ' não está cadastrado!'
				::oResultado:Codigo := ''		
				::oResultado:Erro   := cMsgErroSC
				CONOUT(cMsgErroSC)
				DisarmTransaction()
				Exit
			EndIf   

			dbSelectArea("SC1")
			RecLock("SC1",.T.)

			SC1->C1_FILIAL  := SC:SCCab:Filial
			SC1->C1_NUM     := jlDoc	
			SC1->C1_ITEM    := SC:SCItem[i]:Item
			SC1->C1_PRODUTO := AllTrim(SC:SCItem[i]:Produto)
			If Substr(AllTrim(SC:SCItem[i]:Produto),1,3) == '306'
				If Empty(AllTrim(SC:SCItem[i]:DescricaoProduto))
					lErroSC 	:= .T.
					cMsgErroSC 	:= 'Erro - O Item '+SC:SCItem[i]:Item +' está sem descrição!'
					::oResultado:Codigo := ''		
					::oResultado:Erro   := cMsgErroSC
					CONOUT(cMsgErroSC)
					DisarmTransaction()
					Exit
				EndIf
				SC1->C1_DESCRI  := Upper(AllTrim(SC:SCItem[i]:DescricaoProduto))
			Else
				SC1->C1_DESCRI :=  AllTrim(SB1->B1_DESC)
			EndIf
			SC1->C1_UM      := SC:SCItem[i]:PriUnidadeMedida
			SC1->C1_QUANT   := SC:SCItem[i]:PriQuantidade
			If SC:SCItem[i]:Fornecedor != Nil
				SC1->C1_YFORNEC	:= Upper(SC:SCItem[i]:Fornecedor)
			EndIf
			SC1->C1_YSI    	:= SC:SCItem[i]:CodCliente
			If !Empty(SC:SCItem[i]:SegUnidadeMedida)
				SC1->C1_SEGUM   := SC:SCItem[i]:SegUnidadeMedida
			Else
				SC1->C1_SEGUM   := SC:SCItem[i]:PriUnidadeMedida
			EndIf
			If SC:SCItem[i]:SegQuantidade != Nil .And. SC:SCItem[i]:SegQuantidade != 0
				SC1->C1_QTSEGUM   := SC:SCItem[i]:SegQuantidade
			Else
				SC1->C1_QTSEGUM   := SC:SCItem[i]:PriQuantidade
			EndIf
			If SC:SCItem[i]:Observacao != Nil
				SC1->C1_YOBS    := Upper(SC:SCItem[i]:Observacao)
			EndIf
			SC1->C1_YTAG    := SC:SCItem[i]:Tag
			SC1->C1_QTDORIG := SC:SCItem[i]:PriQuantidade
			SC1->C1_YAPLIC  := IIF(EMPTY(SC:SCItem[i]:Aplicacao),"0",SC:SCItem[i]:Aplicacao) 
			SC1->C1_YANX	:= SC:SCItem[i]:TemAnexo
			SC1->C1_IMPORT 	:= IIF(!Empty(SC:SCItem[i]:Importado), IIF(SC:SCItem[i]:Importado == '1' .Or. SC:SCItem[i]:Importado == 'S' .Or. UPPER(SC:SCItem[i]:Importado) == 'TRUE', 'S', 'N' ), 'N'  )
			SC1->C1_COTACAO	:= IIF(!Empty(SC:SCItem[i]:Importado), IIF(SC:SCItem[i]:Importado == '1' .Or. SC:SCItem[i]:Importado == 'S' .Or. UPPER(SC:SCItem[i]:Importado) == 'TRUE', 'IMPORT', '' ), ''  )			
			SC1->C1_APROV  	:= "L"
			SC1->C1_YMAT    := CMATRIC
			SC1->C1_YSOLEMP := cSolicEmp
			SC1->C1_SOLICIT := UPPER(SC:SCCab:NomeSolicitante)
			SC1->C1_EMISSAO := CTOD(SUBSTR(SC:SCCab:DataEmissao,1,10))
			SC1->C1_YSTATUS := SC:SCCab:Prioridade
			SC1->C1_DATPRF  := CTOD(SUBSTR(SC:SCCab:Necessidade,1,10))
			SC1->C1_YINDSUG	:= SC:SCCab:Indicacao
			SC1->C1_YATSERV	:= IIF(UPPER(SC:SCItem[i]:AtenderServico) == "TRUE","S","N")
			SC1->C1_YDRIVER := IIF(SC:SCItem[i]:Driver == Nil,'',IIF(EMPTY(SC:SCItem[i]:Driver),"",SC:SCItem[i]:Driver))
			If !Empty(SC:SCCab:Contrato) .And. AllTrim(SC:SCCab:Contrato) != '000000'
				SC1->C1_YCONTR  := SC:SCCab:Contrato
			EndIf
			If !Empty(SC:SCCab:Melhoria) .And. AllTrim(SC:SCCab:Melhoria) != '000000'
				SC1->C1_YMELHOR := SC:SCCab:Melhoria
			EndIf	
			SC1->C1_LOCAL   := SC:SCItem[i]:Armazem
			SC1->C1_YGRUPO  := SB1->B1_GRUPO
			If (SC:SCItem[i]:Conta != "00000000" )
				SC1->C1_CONTA   := SC:SCItem[i]:Conta	
			ElseIf SubStr(SC:SCCab:ClasseValor, 1, 1) $  "1_2_4_8" .And. !Empty(SB1->B1_YCTRADM)
				SC1->C1_CONTA   := SB1->B1_YCTRADM
			ElseIf SubStr(SC:SCCab:ClasseValor, 1, 1) == "3" .And. !Empty(SB1->B1_YCTRIND) .And. SB1->B1_TIPO <> "PI"
				SC1->C1_CONTA   := SB1->B1_YCTRIND
			Else
				SC1->C1_CONTA   := SB1->B1_CONTA 
			EndIf
			SC1->C1_CC      := Posicione("CTH",1,XFILIAL("CTH")+ alltrim(SC:SCCab:ClasseValor),"CTH_YCC")
			SC1->C1_CLVL    := SC:SCCab:ClasseValor
			If !Empty(SC:SCCab:ItemConta) .And. AllTrim(SC:SCCab:ItemConta) != '0000'
				SC1->C1_ITEMCTA := SC:SCCab:ItemConta
			EndIf
			SC1->C1_QTDORIG := SC:SCItem[i]:PriQuantidade
			SC1->C1_YDTINCB := Date()
			SC1->C1_YDATHOR := xxDtAprov
			SC1->C1_FILENT 	:= cFilAnt
			SC1->C1_YBIZAGI := AllTrim(SC:SCCab:SolicitBizagi)

			SC1->(MsUnlock())

		Next i

	END TRANSACTION

	If !lErroSC

		ConfirmSX8()
		::oResultado:Codigo := jlDoc
		::oResultado:Erro := ''
		CONOUT("--> Solicitacao Gerada: " + jlDoc)

	EndIf

Return(.T.)


WSMETHOD putNovoProduto WSRECEIVE LP WSSEND oResultado WSSERVICE BIANCO_BIZAGI
Local cRet := ""
Local cNewCod := ""
Local aProd := {}
Local cAplicDir := ""
Local cComum	:= ""	
Local nCount := 0

	RpcSetType(3)
	RpcSetEnv("01", "01")

	VarInfo("LP", LP)

	Begin Transaction

		For nCount := 1 To Len(LP:Lista)
		
			cNewCod := U_ProxCod(Left(LP:Lista[nCount]:Grupo, 3), Left(LP:Lista[nCount]:Grupo, 3), .T., "WS")
			
			aAdd(aProd, {cNewCod})
	
			DbSelectArea("SB1")
	
			RecLock("SB1", .T.)
	
				SB1->B1_COD := cNewCod
				SB1->B1_GRUPO := LP:Lista[nCount]:Grupo	
				SB1->B1_TIPO := LP:Lista[nCount]:Tipo
				SB1->B1_YTIPO := ""
				SB1->B1_TIPCONV := "M"
				SB1->B1_ORIGEM := "0"
				SB1->B1_CLASFIS := "00"
				SB1->B1_DESC := AllTrim(StrTran(Upper(Alltrim(LP:Lista[nCount]:Descricao)),CHR(10), ' '))
				SB1->B1_YPOLIT := LP:Lista[nCount]:Politica
				SB1->B1_UM := LP:Lista[nCount]:Unidade
				SB1->B1_LOCPAD := LP:Lista[nCount]:LocalPadrao
				SB1->B1_YLOCALI := LP:Lista[nCount]:LocalBianco
				SB1->B1_YLOCINC := LP:Lista[nCount]:LocalIncesa
	
				If(LP:Lista[nCount]:SegUm != "*" .And. LP:Lista[nCount]:SegUm != Nil) 
					SB1->B1_SEGUM := LP:Lista[nCount]:SegUm
				Else
					SB1->B1_SEGUM := LP:Lista[nCount]:Unidade
				EndIf       
	
				IF SB1->B1_UM == SB1->B1_SEGUM
					SB1->B1_CONV := 1.00	
				ELSE
					SB1->B1_CONV := VAL(STRTRAN(LP:Lista[nCount]:Fator,",","."))
				ENDIF
	
				SB1->B1_YUSER := "BZ-" + Iif(!Empty(LP:Solicitante), LP:Solicitante,"") 
				SB1->B1_YDIVPA := LP:Lista[nCount]:ConvPallets
				SB1->B1_YPECA := LP:Lista[nCount]:PecasCaixa
	
				If(LP:Lista[nCount]:NCM != "*")
					SB1->B1_POSIPI := LP:Lista[nCount]:NCM
				EndIf
	
				SB1->B1_CONTA := LP:Lista[nCount]:Conta
				SB1->B1_YCTARES := LP:Lista[nCount]:ContaResult
				SB1->B1_YCTRIND := LP:Lista[nCount]:ContaResultInd
				SB1->B1_YCTRADM := LP:Lista[nCount]:ContaResultAdm
				SB1->B1_LOCALIZ	:= 'N'
				SB1->B1_RASTRO := 'N'
				SB1->B1_GARANT := '2'
				SB1->B1_ATIVO := 'S'	
				SB1->B1_IMPORT := IIF(!Empty(LP:Lista[nCount]:Importado), IIF(LP:Lista[nCount]:Importado == '1' .Or. LP:Lista[nCount]:Importado == 'S' .Or. UPPER(LP:Lista[nCount]:Importado) == 'TRUE', 'S', 'N' ), 'N' )
				SB1->B1_ANUENTE := IIF(!Empty(LP:Lista[nCount]:Anuente) , IIF(LP:Lista[nCount]:Anuente == '1' .Or. LP:Lista[nCount]:Anuente == 'S' .Or. UPPER(LP:Lista[nCount]:Anuente) == 'TRUE', '1', '2' ), '2'  ) //1 - SIM //2 - NÃO
	
			SB1->(MsUnLock())
	
			cAplicDir := IIF(!Empty(LP:Lista[nCount]:AplicacaoDireta), IIF(LP:Lista[nCount]:AplicacaoDireta == '1' .Or. LP:Lista[nCount]:AplicacaoDireta == 'S' .Or. UPPER(LP:Lista[nCount]:AplicacaoDireta) == 'TRUE', 'S', 'N' ), 'S'  )
			cComum := IIF(!Empty(LP:Lista[nCount]:EhComum) , IIF(LP:Lista[nCount]:EhComum == '1' .Or. LP:Lista[nCount]:EhComum == 'S' .Or. UPPER(LP:Lista[nCount]:EhComum) == 'TRUE', 'S', 'N' ), 'N'  )  
	
			// Inclui o indicador - Tabela SBZ
			U_WS_INCSBZ(cNewCod, cAplicDir, cComum)
	
		Next
		
		If Len(LP:Lista) == Len(aProd) .And. fVldPutProd(aProd)
	
			For nCount := 1 To Len(aProd)
			
				::oResultado:Codigo += aProd[nCount, 1] + "-" + LP:Lista[nCount]:Item + ";"
			
			Next
			
			::oResultado:Erro := ""
			
		Else
		
			::oResultado:Codigo := ""
			::oResultado:Erro := "ERROR - putNovoProduto"
			
			DisarmTransaction()
		
		EndIf		
			
	End Transaction
	
Return(.T.)


Static Function xConvLog(aAutoErro)

	Local cRet := ""

	If Len(aAutoErro) > 0
		cRet += aAutoErro[1]

		If cRet $ "MA030TOK"
			cRet := aAutoErro[2]
		EndIf
	EndIf
Return cRet


Static Function xConvLogF(aAutoErro)

	Local cRet := ""
	Local nX := 1

	For nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+" - "
	Next nX

Return cRet


WSMETHOD AtualizaCotacao WSRECEIVE oCotacao WSSEND oResultado WSSERVICE BIANCO_BIZAGI

	Local cEmpCot 	:= oCotacao:Cabecalho:EmpresaCotacao
	Local nItem		:= 0
	Local cCotacao	:= ''
	Local cProduto	:= ''
	Local cFornece	:= ''
	Local cLojaForn := ''

	::oResultado:Codigo := 'ERRO'
	::oResultado:Erro 	:= 'Não foi possível atualizar a cotação '+ oCotacao:Cabecalho:CodigoCotacao

	VarInfo("oCotacao", oCotacao)          

	RPCSETTYPE(3)
	WFPREPENV(cEmpCot,'01')

	dbSelectArea('SC8')
	dbSetOrder(3)

	BEGIN TRANSACTION

		For nItem := 1 To  Len(oCotacao:Item)

			cCotacao 	:= PadR( oCotacao:Cabecalho:CodigoCotacao 	, TamSX3( "C8_NUM" )[1],"") 
			cProduto 	:= PadR( oCotacao:Item[nItem]:Produto  		, TamSX3( "C8_PRODUTO" )[1],"" ) 
			cFornece 	:= PadR( oCotacao:Cabecalho:Fornecedor  	, TamSX3( "C8_FORNECE" )[1],"" ) 
			cLojaForn 	:= PadR( oCotacao:Cabecalho:LojaFornedor  	, TamSX3( "C8_LOJA" )[1],"")    

			If dbSeek(xFilial('SC8')+cCotacao+cProduto+cFornece+cLojaForn)

				CONOUT('Cotação '+cCotacao+' encontrada. (Fornecedor/Produto) -> '+cFornece+'/'+cProduto)    

				IF oCotacao:Item[nItem]:PrecoUnitario == 0
					CONOUT('Cotação '+cCotacao+' com preço unitário igual a zero. (Fornecedor/Produto) -> '+cFornece+'/'+cProduto)    	        
				ENDIF

				RecLock("SC8",.F.)

				SC8->C8_MOEDA	:= oCotacao:Item[nItem]:Moeda 
				SC8->C8_PRECO	:= oCotacao:Item[nItem]:PrecoUnitario
				SC8->C8_DESC	:= oCotacao:Item[nItem]:Desconto
				SC8->C8_TOTAL 	:= oCotacao:Item[nItem]:PrecoTotal
				SC8->C8_YMARCA	:= oCotacao:Item[nItem]:Marca
				SC8->C8_ALIIPI	:= oCotacao:Item[nItem]:IPI

				// Tiago Rossini Coradini 11/04/2017 - OS: 3571-16
				SC8->C8_YOBS	:= oCotacao:Item[nItem]:Observacao

				SC8->C8_PRAZO	:= oCotacao:Item[nItem]:DiasEntrega
				SC8->C8_CONTATO	:= oCotacao:Cabecalho:Contato
				SC8->C8_TPFRETE	:= oCotacao:Cabecalho:TipoFrete	
				SC8->C8_ORCFOR	:= oCotacao:Cabecalho:Orcamento
				SC8->C8_VALIDA	:= CTOD(SUBSTR(oCotacao:Cabecalho:DataValidade,1,10)) //CTOD(SUBSTR(SC:SCCab:DataEmissao,1,10))
				SC8->C8_COND	:= oCotacao:Cabecalho:FormaPagamento
				SC8->C8_YCOND	:= oCotacao:Cabecalho:FormPagNegociado
				SC8->C8_YFLAG	:= oCotacao:Item[nItem]:AtendeCotacao
				//SC8->C8_YFLAG	:= IIF(oCotacao:Item[nItem]:AtendeTotal,'S','N')
				SC8->C8_YVLSUB	:= oCotacao:Item[nItem]:ValorSubst
				If (oCotacao:Item[nItem]:IPI) > 0 
					SC8->C8_VALIPI	:= (oCotacao:Item[nItem]:IPI/100)*(oCotacao:Item[nItem]:PrecoTotal)
				EndIf
				SC8->C8_YFINAL	:= 'S'

				if Empty(SC8->C8_YPRDFOR)
					// Tiago Rossini Coradini - 13/01/2016 - Atualiza informação de produto x fornecedor
					SC8->C8_YPRDFOR := oCotacao:Item[nItem]:ProdutoFornecedor
				Endif

				//U_fUpdPrdFor(cFornece, cLojaForn, cProduto, oCotacao:Item[nItem]:ProdutoFornecedor)
				U_fGrvPdFr(cFornece, cLojaForn, cProduto, oCotacao:Item[nItem]:ProdutoFornecedor)								

				MsUnlock()
			Else
				cMsg := 'Cotação '+cCotacao+' NAO encontrada. (Fornecedor/Produto) -> '+cFornece+'/'+cProduto 
				Conout(cMsg)    	
				::oResultado:Codigo := 'ERRO'
				::oResultado:Erro 	:= cMsg
				RETURN .T.
			EndIf

		Next nItem

	END TRANSACTION

	::oResultado:Codigo := '0'
	::oResultado:Erro 	:= ''

Return(.T.)


Static Function GeraErro(oError)
	::oResultado:Codigo := 'ERRO'
	::oResultado:Erro 	:= oError:Description
	BREAK
Return (NIL)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Tabela de Preço       					                     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSMETHOD putTabelaPreco	WSRECEIVE oTabPreco	WSSEND oResultado WSSERVICE BIANCO_BIZAGI

	Local lSemEmpresa

	Private aCabec := {}
	Private aItens := {}
	Private wNewCod := ""
	Private wAuxData := ""
	Private wAuxData2 := ""
	Private sFilial := ""
	Private sFornCod := ""
	Private sFornLoja := ""
	Private sTabCod := ""
	Private sTabDesc := ""
	Private sDataDe := ""
	Private sDataAte := ""
	Private sCondPagto := ""
	Private sFornDesc := ""
	Private sItem := ""
	Private sProdCod := ""
	Private sPrcCom := ""
	Private sQtdLot := ""
	Private sIndLot := ""
	Private sMoeda := ""
	Private sDataVig := ""
	Private sFrete := ""
	Private lMsErroAuto := .F.
	Private CodErro := ""
	Private DscErro := ""

	Conout("Tabela de Preco - Iniciando empresa...")

	lSemEmpresa := Select("SX6") == 0
	If lSemEmpresa
		RPCSETTYPE(3)
		WFPREPENV('01','01')
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Teste de Inclusao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//novo: insert AIA e AIB / reajuste: update AIB / substituicao: insert AIB se produto - insert AIA e AIB se fornecedor
	//3-Inclusão ; 4-Alteração ; 5-Exclusão

	if oTabPreco:TPCab:TipoNegociacao == "1" //nova
		novaTP()
	ElseIf oTabPreco:TPCab:TipoNegociacao == "2" //substituicao
		substituicaoTP()
	ElseIf oTabPreco:TPCab:TipoNegociacao == "3" //reajuste
		reajusteTP()
	EndIf

	::oResultado:Codigo := CodErro
	::oResultado:Erro	:= DscErro

	RPCCLEARENV()

Return .T.


User Function WS_INCSBZ(cCodPrd, pcAplicDireta, pcComum)

	IncluiSBZ(cCodPrd, pcAplicDireta, pcComum)

	cTipo := "I"
	cCod := cCodPrd

	//Replica Cadastro de Indicador
	If cEmpAnt $ "01_05_06_07_12_13_14_16_17" 

		If cEmpAnt == "01"

			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "05"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "06"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "07"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "12"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "13"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "14"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "16"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("170",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		ElseIf cEmpAnt == "17"

			U_ReplicaIndicador("010",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("050",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("060",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("070",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("120",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("130",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("140",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS
			U_ReplicaIndicador("160",cTipo,cCod) // PARAMETRO EMPRESSA QUE VAI SER REPLICADAS

		EndIf

	EndIf

return()   


Static Function IncluiSBZ(cCodPrd, pcAplicDireta, pcComum)

	DbSelectArea("SB1")
	DbSetOrder(1)
	If SB1->(DbSeek(xFilial("SB1") + cCodPrd))

		DbSelectArea("SBZ")
		DbSetOrder(1)
		IF !DbSeek(xFilial("SBZ") + SB1->B1_COD)

			RecLock("SBZ",.T.)
			SBZ->BZ_FILIAL := xFilial("SBZ")
			SBZ->BZ_COD := SB1->B1_COD
			SBZ->BZ_YDESC := SB1->B1_DESC

			//Gabriel Mafioletti - 10/07/2018 Ticket - 4054
			If SB1->B1_TIPO $ "#PA#PP#"
				Do Case
					Case cEmpAnt == "01"
					SBZ->BZ_LOCPAD := "02"
					Case cEmpAnt == "05"
					SBZ->BZ_LOCPAD := "04"
					OtherWise
					SBZ->BZ_LOCPAD := SB1->B1_LOCPAD
				EndCase
			Else
				SBZ->BZ_LOCPAD := SB1->B1_LOCPAD
			EndIf

			SBZ->BZ_YPOLIT := SB1->B1_YPOLIT

			DO CASE
				CASE cEmpAnt == '01'
				SBZ->BZ_YLOCAL  := SB1->B1_YLOCALI
				CASE cEmpAnt == '05'
				SBZ->BZ_YLOCAL  := SB1->B1_YLOCINC
				CASE cEmpAnt == '14'
				SBZ->BZ_YLOCAL  := SB1->B1_YLOCVIT
			ENDCASE

			SBZ->BZ_YBLSCPC := '2'
			SBZ->BZ_YSOLIC  := SB1->B1_YSOLIC
			SBZ->BZ_EMIN    := SB1->B1_EMIN
			SBZ->BZ_UCOM    := SB1->B1_UCOM
			SBZ->BZ_CUSTD   := SB1->B1_CUSTD
			SBZ->BZ_ORIGEM  := SB1->B1_ORIGEM
			SBZ->BZ_YATIVO	:= 'S'
			SBZ->BZ_YEMPENH := 'S'

			If !Empty(pcAplicDireta)
				SBZ->BZ_YMD := iif(UPPER(pcAplicDireta)='TRUE' .Or. pcAplicDireta='S', 'S', 'N')
			Else
				SBZ->BZ_YMD := 'S'
			EndIf
			If !Empty(pcComum)
				SBZ->BZ_YCOMUM := iif(UPPER(pcComum)='TRUE' .Or. pcComum='S', 'S', 'N')
			Else
				SBZ->BZ_YCOMUM := 'N'
			EndIf

			// Incluído por Marcos Alberto Soprani em 24/04/13 para dar segurança os usuários que efetuam o cadastro a ffin de não permitir o cadastramento errado por esquecimento da regra.
			// inicialmente usado para os produtos iniciados com: ADI_,POL_,IMP_,IND_,CMS_,EMB_,ENE_,ADT_,RET_,GAS_
			If Substr(SB1->B1_COD,4,1) $ "_"
				SBZ->BZ_FANTASM := 'S'
			EndIf

			// Incluido por Ranisses Antonio Corona em 19/02/13, para gravar o Grupo Tributação também no cadadastro de Indicador
			// A Totvs passou a considerar este campo a partir de OUT/13 no fonte FISXFUN - função AliqIcms
			// Tratamento do Chamado TIHXAR/0223-14
			SBZ->BZ_GRTRIB := SB1->B1_GRTRIB

			SBZ->BZ_YATIVO  := 'S'
			SBZ->BZ_LOCALIZ := SB1->B1_LOCALIZ

			// Incluído por Rodrigo Ribeiro em 23/01/2018
			//SBZ->BZ_YMD := "N"
			SBZ->BZ_YEMPENH  := "S"

			SBZ->(MsUnLock())

		EndIf

	EndIf

Return()



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Inclusão de nova Tabela de Preço                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function novaTP()

	Local nItem

	sFilial := ""
	sFornCod := ""
	sFornLoja := ""
	sTabCod := ""
	sTabDesc := ""
	sDataDe := ""
	sDataAte := ""
	sCondPagto := ""
	sFornDesc := ""
	sItem := ""
	sProdCod := ""
	sPrcCom := ""
	sQtdLot := ""
	sIndLot := ""
	sMoeda := ""
	sDataVig := ""
	sFrete := ""

	CONOUT('Tabela de Preco - Nova')

	CSQL := "SELECT MAX(AIA_CODTAB) FROM " + RetSqlName("AIA") + " WHERE AIA_LOJFOR + AIA_CODFOR = '" + oTabPreco:TPCab:FornCodLojaNovo + "'"

	If chkfile("sqlTP")
		dbSelectArea("sqlTP")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "sqlTP" NEW

	dbSelectArea("sqlTP")

	If !sqlTP->(Eof())
		wNewCod := Soma1(sqlTP->AIA_CODTAB,4)
	Else
		wNewCod := "001"			
	EndIf

	dbCloseArea() 

	sFilial := xFilial("AIA")
	sFornCod := SUBSTRING(oTabPreco:TPCab:FornCodLojaNovo, 5, 6)
	sFornLoja := SUBSTRING(oTabPreco:TPCab:FornCodLojaNovo, 0, 2)
	sTabCod := wNewCod
	sTabDesc := oTabPreco:TPCab:AplicProd + " - " + sFornCod + " - " + dDatabase
	sDataDe := dDatabase

	wAuxData := StrTokArr(oTabPreco:TPCab:DataPrevSubs,"/")
	wAuxData2 := StrTokArr(wAuxData[3]," ")

	sDataAte := wAuxData2[1] + "1231" //31 de dezembro
	sCondPagto := oTabPreco:TPCab:FormaPagNovo
	sFornDesc := oTabPreco:TPCab:FornDscNovo

	For nItem := 1 To  Len(oTabelaPreco:TPItem)
		sItem := StrTran(Space(nItem, 3 - Len(nItem))," ", "0")
		sProdCod := oTabelaPreco:TPItem:ProdCodNovo
		sPrcCom := oTabelaPreco:TPItem:PrecoNovo
		sQtdLot := "999.999,99"
		sIndLot := "000000000999999.99"
		sMoeda := "1"

		If Len(wAuxData[1]) == 2  	
			sDataVig := wAuxData2[1]+wAuxData[1]+wAuxData[2]
		Else
			sDataVig := wAuxData2[1]+"0"+wAuxData[1]+wAuxData[2]
		EndIf	

		//sDataVig := ""
		sFrete := oTabelaPreco:TPItem:FreteNovo
	End

	//INICIO INSERÇÃO
	Begin Transaction
		aCabec := {}	

		aadd(aCabec,{"AIA_FILIAL",sFilial,})
		aadd(aCabec,{"AIA_CODFOR",sFornCod,})
		aadd(aCabec,{"AIA_LOJFOR",sFornLoja,})
		aadd(aCabec,{"AIA_CODTAB",sTabCod,})
		aadd(aCabec,{"AIA_DESCRI",sTabDesc,})
		aadd(aCabec,{"AIA_DATDE",sDataDe,})
		aadd(aCabec,{"AIA_DATATE",sDataAte,})
		aadd(aCabec,{"AIA_CONDPG",sCondPagto,})
		aadd(aCabec,{"AIA_YNOMFO",sFornDesc,})


		aItens := {}
		For nItem := 1 To  Len(oTabelaPreco:TPItem)
			aAdd(aItens,{})
			aadd(aItens[nItem],{"AIB_FILIAL",sFilial,})
			aadd(aItens[nItem],{"AIB_CODFOR",sFornCod,})
			aadd(aItens[nItem],{"AIB_LOJFOR",sFornLoja,})
			aadd(aItens[nItem],{"AIB_CODTAB",sTabCod,})
			aadd(aItens[nItem],{"AIB_ITEM",sItem,})
			aadd(aItens[nItem],{"AIB_CODPRO",sProdCod,})
			aadd(aItens[nItem],{"AIB_PRCCOM",sPrcCom,})
			aadd(aItens[nItem],{"AIB_QTDLOT",sQtdLot,})
			aadd(aItens[nItem],{"AIB_INDLOT",sIndLot,})
			aadd(aItens[nItem],{"AIB_MOEDA",sMoeda,})
			aadd(aItens[nItem],{"AIB_DATVIG",sDataVig,})
			aadd(aItens[nItem],{"AIB_FRETE",sFrete,})
		End

		PARAMIXB2 := aClone(aCabec)
		PARAMIXB3 := aClone(aItens)

		MSExecAuto({|x,y,z| coma010(x,y,z)},3,PARAMIXB2,PARAMIXB3) //inserção

		If !lMsErroAuto
			ConOut("Tabela de Preco - Incluido com sucesso! " + cCodTab)
			CodErro := cCodTab
			DscErro	:= ''
		Else
			CONOUT('Tabela de Preco - WS Bizagi: Erro - ' + xConvLogF(_aAutoerro))
			CodErro := "ERRO"
			if !Empty(cLogTxt)
				DscErro	:= cLogTxt
			Else
				DscErro	:= xConvLogF(_aAutoerro)
			EndIf
			DisarmTransaction()
		EndIf

		ConOut("Fim  : "+Time())

	End Transaction

Return()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Substituicao de Tabela de Preço                              |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function substituicaoTP()

	Local nItem

	sFilial := ""
	sFornCod := ""
	sFornLoja := ""
	sTabCod := ""
	sTabDesc := ""
	sDataDe := ""
	sDataAte := ""
	sCondPagto := ""
	sFornDesc := ""
	sItem := ""
	sProdCod := ""
	sPrcCom := ""
	sQtdLot := ""
	sIndLot := ""
	sMoeda := ""
	sDataVig := ""
	sFrete := ""

	CONOUT('Tabela de Preco - Substituicao')

	CSQL := "SELECT MAX(AIA_CODTAB) FROM " + RetSqlName("AIA") + " WHERE AIA_LOJFOR + AIA_CODFOR = '" + oTabPreco:TPCab:FornCodLojaNovo + "'"

	If chkfile("sqlTP")
		dbSelectArea("sqlTP")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "sqlTP" NEW

	dbSelectArea("sqlTP")

	If !sqlTP->(Eof())
		wNewCod := Soma1(sqlTP->AIA_CODTAB,4)
	Else
		wNewCod := "001"			
	EndIf

	dbCloseArea() 

	sFilial := xFilial("AIA")
	sFornCod := SUBSTRING(oTabPreco:TPCab:FornCodLojaNovo, 5, 6)
	sFornLoja := SUBSTRING(oTabPreco:TPCab:FornCodLojaNovo, 0, 2)
	sTabCod := wNewCod
	sTabDesc := oTabPreco:TPCab:AplicProd + " - " + sFornCod + " - " + dDatabase
	sDataDe := dDatabase

	wAuxData := StrTokArr(oTabPreco:TPCab:DataPrevSubs,"/")
	wAuxData2 := StrTokArr(wAuxData[3]," ")

	sDataAte := wAuxData2[1] + "1231" //31 de dezembro
	sCondPagto := oTabPreco:TPCab:FormaPagNovo
	sFornDesc := oTabPreco:TPCab:FornDscNovo

	For nItem := 1 To  Len(oTabelaPreco:TPItem)
		sItem := StrTran(Space(nItem, 3 - Len(nItem))," ", "0")
		sProdCod := oTabelaPreco:TPItem[nItem]:ProdCodNovo
		sPrcCom := oTabelaPreco:TPItem[nItem]:PrecoNovo
		sQtdLot := "999.999,99"
		sIndLot := "000000000999999.99"
		sMoeda := "1"

		If Len(wAuxData[1]) == 2  	
			sDataVig := wAuxData2[1]+wAuxData[1]+wAuxData[2]
		Else
			sDataVig := wAuxData2[1]+"0"+wAuxData[1]+wAuxData[2]
		EndIf	

		//sDataVig := ""
		sFrete := oTabelaPreco:TPItem[nItem]:FreteNovo
	End

	//INICIO INSERÇÃO
	Begin Transaction
		aCabec := {}	

		aadd(aCabec,{"AIA_FILIAL",sFilial,})
		aadd(aCabec,{"AIA_CODFOR",sFornCod,})
		aadd(aCabec,{"AIA_LOJFOR",sFornLoja,})
		aadd(aCabec,{"AIA_CODTAB",sTabCod,})
		aadd(aCabec,{"AIA_DESCRI",sTabDesc,})
		aadd(aCabec,{"AIA_DATDE",sDataDe,})
		aadd(aCabec,{"AIA_DATATE",sDataAte,})
		aadd(aCabec,{"AIA_CONDPG",sCondPagto,})
		aadd(aCabec,{"AIA_YNOMFO",sFornDesc,})


		aItens := {}
		For nItem := 1 To  Len(oTabelaPreco:TPItem)
			aAdd(aItens,{})
			aadd(aItens[nItem],{"AIB_FILIAL",sFilial,})
			aadd(aItens[nItem],{"AIB_CODFOR",sFornCod,})
			aadd(aItens[nItem],{"AIB_LOJFOR",sFornLoja,})
			aadd(aItens[nItem],{"AIB_CODTAB",sTabCod,})
			aadd(aItens[nItem],{"AIB_ITEM",sItem,})
			aadd(aItens[nItem],{"AIB_CODPRO",sProdCod,})
			aadd(aItens[nItem],{"AIB_PRCCOM",sPrcCom,})
			aadd(aItens[nItem],{"AIB_QTDLOT",sQtdLot,})
			aadd(aItens[nItem],{"AIB_INDLOT",sIndLot,})
			aadd(aItens[nItem],{"AIB_MOEDA",sMoeda,})
			aadd(aItens[nItem],{"AIB_DATVIG",sDataVig,})
			aadd(aItens[nItem],{"AIB_FRETE",sFrete,})
		End

		PARAMIXB2 := aClone(aCabec)
		PARAMIXB3 := aClone(aItens)

		MSExecAuto({|x,y,z| coma010(x,y,z)},3,PARAMIXB2,PARAMIXB3) //inserção

		If !lMsErroAuto
			ConOut("Tabela de Preco - Incluido com sucesso! " + cCodTab)
			CodErro := cCodTab
			DscErro	:= ''
		Else
			CONOUT('Tabela de Preco - WS Bizagi: Erro - ' + xConvLogF(_aAutoerro))
			CodErro := "ERRO"
			if !Empty(cLogTxt)
				DscErro	:= cLogTxt
			Else
				DscErro	:= xConvLogF(_aAutoerro)
			EndIf
			DisarmTransaction()
		EndIf

		ConOut("Fim  : "+Time())

	End Transaction

Return()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Reajuste de valor de Tabela de Preço                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function reajusteTP()

	Local nItem

	sFilial := ""
	sFornCod := ""
	sFornLoja := ""
	sTabCod := ""
	sTabDesc := ""
	sDataDe := ""
	sDataAte := ""
	sCondPagto := ""
	sFornDesc := ""
	sItem := ""
	sProdCod := ""
	sPrcCom := ""
	sQtdLot := ""
	sIndLot := ""
	sMoeda := ""
	sDataVig := ""
	sFrete := ""


	CSQL := "SELECT MAX(AIA_CODTAB) FROM " + RetSqlName("AIA") + " WHERE AIA_LOJFOR + AIA_CODFOR = '" + oTabPreco:TPCab:FornCodLojaNovo + "'"

	If chkfile("sqlTP")
		dbSelectArea("sqlTP")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "sqlTP" NEW

	dbSelectArea("sqlTP")

	If !sqlTP->(Eof())
		wNewCod := sqlTP->AIA_CODTAB
	Else
		CONOUT('WS Bizagi: Erro - Tabela de Preco do Fornecedor nao encontrada')
		CodErro := "ERRO"
		DscErro	:= "Tabela de Preco do Fornecedor nao encontrada"
		Return .F.			
	EndIf

	dbCloseArea() 

	sFilial := xFilial("AIA")
	sFornCod := SUBSTRING(oTabPreco:TPCab:FornCodLojaNovo, 5, 6)
	sFornLoja := SUBSTRING(oTabPreco:TPCab:FornCodLojaNovo, 0, 2)
	sTabCod := wNewCod
	//sTabDesc := oTabPreco:TPCab:AplicProd + " - " + sFornCod + " - " + dDatabase
	//sDataDe := dDatabase

	sDataAte := wAuxData2[1] + "1231" //31 de dezembro
	sCondPagto := oTabPreco:TPCab:FormaPagNovo
	sFornDesc := oTabPreco:TPCab:FornDscNovo

	For nItem := 1 To  Len(oTabelaPreco:TPItem)
		CSQL := "SELECT MAX(AIA_CODTAB) FROM " + RetSqlName("AIA") + " WHERE AIA_LOJFOR + AIA_CODFOR = '" + oTabPreco:TPCab:FornCodLojaNovo + "'"

		If chkfile("sqlTPnovo")
			dbSelectArea("sqlTPnovo")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "sqlTPnovo" NEW

		dbSelectArea("sqlTPnovo")

		If !sqlTPnovo->(Eof())
			wNewCod := sqlTPnovo->AIA_CODTAB
		Else
			CONOUT('WS Bizagi: Erro - Tabela de Preco do Fornecedor nao encontrada')
			CodErro := "ERRO"
			DscErro	:= "Tabela de Preco do Fornecedor nao encontrada"
			Return .F.			
		EndIf

		dbCloseArea()

		sItem := StrTran(Space(nItem, 3 - Len(nItem))," ", "0")
		//sProdCod := oTabelaPreco:TPItem:ProdCodNovo
		sPrcCom := oTabelaPreco:TPItem:PrecoNovo
		//sQtdLot := 999.999,99
		//sIndLot := "000000000999999.99"
		//sMoeda := "1"

		If Len(wAuxData[1]) == 2  	
			sDataVig := wAuxData2[1]+wAuxData[1]+wAuxData[2]
		Else
			sDataVig := wAuxData2[1]+"0"+wAuxData[1]+wAuxData[2]
		EndIf	

		//sDataVig := ""
		sFrete := oTabelaPreco:TPItem:FreteNovo
	End

	//INICIO INSERÇÃO
	Begin Transaction
		aCabec := {}	

		aadd(aCabec,{"AIA_FILIAL",sFilial,})
		aadd(aCabec,{"AIA_CODFOR",sFornCod,})
		aadd(aCabec,{"AIA_LOJFOR",sFornLoja,})
		aadd(aCabec,{"AIA_CODTAB",sTabCod,})
		aadd(aCabec,{"AIA_DESCRI",sTabDesc,})
		aadd(aCabec,{"AIA_DATDE",sDataDe,})
		aadd(aCabec,{"AIA_DATATE",sDataAte,})
		aadd(aCabec,{"AIA_CONDPG",sCondPagto,})
		aadd(aCabec,{"AIA_YNOMFO",sFornDesc,})


		aItens := {}
		For nItem := 1 To  Len(oTabelaPreco:TPItem)
			aAdd(aItens,{})
			aadd(aItens[nItem],{"AIB_FILIAL",sFilial,})
			aadd(aItens[nItem],{"AIB_CODFOR",sFornCod,})
			aadd(aItens[nItem],{"AIB_LOJFOR",sFornLoja,})
			aadd(aItens[nItem],{"AIB_CODTAB",sTabCod,})
			aadd(aItens[nItem],{"AIB_ITEM",sItem,})
			aadd(aItens[nItem],{"AIB_CODPRO",sProdCod,})
			aadd(aItens[nItem],{"AIB_PRCCOM",sPrcCom,})
			aadd(aItens[nItem],{"AIB_QTDLOT",sQtdLot,})
			aadd(aItens[nItem],{"AIB_INDLOT",sIndLot,})
			aadd(aItens[nItem],{"AIB_MOEDA",sMoeda,})
			aadd(aItens[nItem],{"AIB_DATVIG",sDataVig,})
			aadd(aItens[nItem],{"AIB_FRETE",sFrete,})
		End

		PARAMIXB2 := aClone(aCabec)
		PARAMIXB3 := aClone(aItens)

		MSExecAuto({|x,y,z| coma010(x,y,z)},3,PARAMIXB2,PARAMIXB3) //inserção

		If !lMsErroAuto
			ConOut("Tabela de Preco - Incluido com sucesso! " + cCodTab)
			CodErro := cCodTab
			DscErro	:= ''
		Else
			CONOUT('Tabela de Preco - WS Bizagi: Erro - ' + xConvLogF(_aAutoerro))
			CodErro := "ERRO"
			if !Empty(cLogTxt)
				DscErro	:= cLogTxt
			Else
				DscErro	:= xConvLogF(_aAutoerro)
			EndIf
			DisarmTransaction()
		EndIf

		ConOut("Fim  : "+Time())

	End Transaction

Return()



/*/{Protheus.doc} putEmbalagemInclusao
//TODO Descrição auto-gerada.
@author rodrigo.agostini
@description Inclusao de uma NOVA EMBALAGEM
@since 06/07/2017
@version 1.0
@type function
/*/
WSMETHOD putEmbalagemInclusao WSRECEIVE oEmbInclusao WSSEND oResultado WSSERVICE BIANCO_BIZAGI

	Local _aRet   
	Local lSemEmpresa

	lSemEmpresa := Select("SX6") == 0
	If lSemEmpresa
		RPCSETTYPE(3)
		WFPREPENV('01','01')	
	EndIf

	_aRet := U_InsrEmbalagem(oEmbInclusao)

	if Empty(_aRet)
		::oResultado:Codigo := "ERRO"
		::oResultado:Erro	:= "Variável de retorno vazia."
	else
		::oResultado:Codigo := _aRet[1]
		::oResultado:Erro	:= _aRet[2]  	
	EndIf	

	MsUnlockAll()
	RpcClearEnv()

Return .T.

/*/{Protheus.doc} putEmbalagemAlteracao
//TODO Descrição auto-gerada.
@author rodrigo.agostini
@description Atualizacao de uma EMBALAGEM
@since 06/07/2017
@version 1.0
@type function
/*/
WSMETHOD putEmbalagemAlteracao WSRECEIVE oEmbAlteracao WSSEND oResultado WSSERVICE BIANCO_BIZAGI

	Local _aRet  
	Local lSemEmpresa

	lSemEmpresa := Select("SX6") == 0
	If lSemEmpresa
		RPCSETTYPE(3)
		WFPREPENV('01','01')
	EndIf

	_aRet := U_UpdtEmbalagem(oEmbAlteracao)

	if Empty(_aRet)
		::oResultado:Codigo := "ERRO"
		::oResultado:Erro	:= "Variável de retorno vazia."
	else
		::oResultado:Codigo := _aRet[1]
		::oResultado:Erro	:= _aRet[2]  	
	EndIf	

	MsUnlockAll()
	RpcClearEnv()

Return .T.

/*/{Protheus.doc} InsrEmbalagem
//TODO Descrição auto-gerada.
@author rodrigo.agostini
@description Funcao utilizada pelo metodo de inclusao de Embalagem
@since 06/07/2017
@version 1.0
@param oEmbInclusao, array, descricao
@type function
/*/
User Function InsrEmbalagem(oEmbInclusao)

	Local sDescricao := oEmbInclusao:DescNova
	Local sNcm := oEmbInclusao:NcmAnterior
	Local wNewCod := ""

	Local _aRet
	Local aVetor := {}
	Local CodRet := ""
	Local DscRet := ""
	//
	Local _cError
	Local _cLogTxt
	Local bError :=	{ |e| oError := e , Break(e) }
	Local bErrorBlock := ErrorBlock( bError )
	//
	Private oError
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T. 

	BEGIN TRANSACTION

		aVetor:= {;
		{"B1_FILIAL"	, ""			, Nil},;
		{"B1_GRUPO"		, "104A"		, Nil},;
		{"B1_TIPO"		, "ME"			, Nil},;
		{"B1_YBLSCPC"	, "1"			, Nil},;
		{"B1_YPOLIT"	, "2"			, Nil},;
		{"B1_DESC"		, sDescricao	, Nil},;
		{"B1_UM"		, "PC"			, Nil},;
		{"B1_LOCPAD"	, "01"			, Nil},;
		{"B1_SEGUM"		, "PC"			, Nil},;
		{"B1_CONV"		, 1				, Nil},;
		{"B1_POSIPI"	, sNcm			, Nil},;
		{"B1_YPECA"		, 1				, Nil},;
		{"B1_YDIVPA"	, 1				, Nil},;
		{"B1_ORIGEM"	, "0"			, Nil},;
		{"B1_CLASFIS"	, "00"			, Nil},;
		{"B1_GARANT"	, "2"			, Nil},;
		{"B1_YTIPO"		, "1"			, Nil},;
		{"B1_TIPCONV"	, "M"			, Nil},;
		{"B1_YUSER"		, "EMB-BIZAGI"	, Nil},;
		{"B1_LOCALIZ"	, "N"			, Nil},;
		{"B1_YLOCALI"	, ""			, Nil},;
		{"B1_YLOCINC"	, ""			, Nil},;
		{"B1_RASTRO"	, "N"			, Nil},;
		{"B1_ATIVO"		, "S"			, Nil},;
		{"B1_IMPORT"	, "N"			, Nil}; 
		}

		wEmbCadManual := Posicione("SB1",3,XFILIAL("SB1")+ sDescricao,"B1_COD")

		If !Empty(wEmbCadManual) .And. ( Alltrim(wEmbCadManual) $ ('1040599','1040642') )	
			CodRet := Alltrim(wEmbCadManual)
			DscRet	:= ""
		Else

			wProdutoExiste := Posicione("SB1",3,XFILIAL("SB1")+ sDescricao,"B1_COD")

			If !Empty(wProdutoExiste)
				CodRet := "ERRO"
				DscRet	:= "EMB-ERRO-INSERT-01 : A descrição '" + sDescricao + "' já existe no Banco de Dados."
				DisarmTransaction()
			else		    	

				// EXECUTA EXECAUTO PARA INCLUSAO DE NOVO PRODUTO
				lMsErroAuto := .F.
				_cLogTxt := ""
				MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)

				// VERIFICA ERRO NA EXECUCAO DO 'MSExecAuto'
				If lMsErroAuto                   		

					aAutoErro := GETAUTOGRLOG()
					_cLogTxt += XCONVERRLOG(aAutoErro)
					CodRet := "ERRO"
					DscRet	:= "EMB-ERRO-INSERT-02 : Erro ao executar o MSExecAuto. Erro : " + _cLogTxt	
					DisarmTransaction()

				Else

					wNewCod := Posicione("SB1",3,XFILIAL("SB1")+ sDescricao,"B1_COD")
					CodRet := wNewCod
					//DscRet	:= "Produto '" + ALLTRIM(wNewCod) + "' inserido com sucesso!"				
					DscRet	:= ""

					If !Empty(wNewCod)
						//INCLUI INDICADORES DE PRODUTO - Tabela SBZ.
						U_WS_INCSBZ(wNewCod, "N","N") //Codigo / Ap. Direta / Prod. Comum	    
					else		    	
						CodRet := "ERRO"
						DscRet	:= "EMB-ERRO-INSERT-03 : O Produto '" + wNewCod + "' não encontrado no Banco de Dados."
						DisarmTransaction()	    		    
					EndIf

				EndIf

			EndIf

		End If	

		_aRet	:=	{CodRet,DscRet}		

	END TRANSACTION

Return _aRet


/*/{Protheus.doc} UpdtEmbalagem
//TODO Descrição auto-gerada.
@author rodrigo.agostini
@description Funcao utilizada pelo metodo de atualizacao de Embalagem
@since 07/07/2017
@version undefined
@param oEmbAlteracao, array, descricao
@type function
/*/
User Function UpdtEmbalagem(oEmbAlteracao)

	Local cQuery := ""
	Local cTabelaEmp := ""
	Local sProdAnterior := oEmbAlteracao:CodAnterior
	Local sProdNovo := oEmbAlteracao:CodNovo
	Local sEmp := oEmbAlteracao:Empresa

	Local _aRet
	Local CodRet := ""
	Local DscRet := ""
	//
	Local _cError
	Local _cLogTxt
	Local bError :=	{ |e| oError := e , Break(e) }
	Local bErrorBlock := ErrorBlock( bError )
	//
	Private oError
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T. 

	BEGIN TRANSACTION

		if (LEN(sEmp) != 2)

			DisarmTransaction()
			CodRet := 'ERRO'
			DscRet	:= "EMB-ERRO-UPDATE-00 : A EMPRESA ENVIADA POSSUI MAIS DE 2 CARACTERES -> " + sEmp		
			CONOUT("ERRO CODIGO EMPRESA -> CODIGO RETORNO : " + CodRet + " | MENSAGEM : " + DscRet)

		Else

			cTabelaEmp := sEmp + '0'		

			//HABILITA O PRODUTO NOVO
			//cQuery  := "UPDATE SB1" + cTabelaEmp + " "
			cQuery  := "UPDATE SB1010 "
			cQuery  += "SET B1_YBLSCPC = '2' "
			cQuery  += "WHERE B1_FILIAL = '' AND "
			cQuery  += " B1_COD = '" + sProdNovo + "' AND "
			cQuery  += " D_E_L_E_T_ = '' "

			returnQuery := TCSQLExec(cQuery)

			if (returnQuery < 0)

				DisarmTransaction()
				CodRet := "ERRO" //ALLTRIM(STR(returnQuery))
				DscRet	:= "EMB-ERRO-UPDATE-03 : ERRO NA HABILITACAO DO PRODUTO NOVO"				
				CONOUT("HABILITA PRODUTO NOVO -> CODIGO : " + CodRet + " | MENSAGEM : " + DscRet + " | SQL Error : " + TCSQLError())

			else

				//HABILITA O INDICADOR NOVO
				cQuery  := "UPDATE SBZ" + cTabelaEmp + " "
				cQuery  += "SET BZ_YBLSCPC = '2' "
				cQuery  += "WHERE BZ_FILIAL = '' AND "
				cQuery  += " BZ_COD = '" + sProdNovo + "' AND "
				cQuery  += " D_E_L_E_T_ = '' "

				returnQuery := TCSQLExec(cQuery)

				if (returnQuery < 0)

					DisarmTransaction()
					CodRet := "ERRO" //ALLTRIM(STR(returnQuery))
					DscRet	:= "EMB-ERRO-UPDATE-02 : ERRO NA HABILITACAO DO INDICADOR DO PRODUTO NOVO"			
					CONOUT("HABILITA INDICADOR NOVO -> CODIGO RETORNO : " + CodRet + " | MENSAGEM : " + DscRet + " | SQL Error : " + TCSQLError())

				Else

					CodRet := sProdNovo
					DscRet := ""

				EndIf

			EndIf

			If oEmbAlteracao:Tipo == "REV"

				//DESABILITA O INDICADOR ANTIGO
				cQuery  := "UPDATE SBZ" + cTabelaEmp + " "
				cQuery  += "SET BZ_YBLSCPC = '1' "	
				cQuery  += "WHERE BZ_FILIAL = '' AND "
				cQuery  += " BZ_COD = '" + sProdAnterior + "' AND "
				cQuery  += " D_E_L_E_T_ = '' "

				returnQuery := TCSQLExec(cQuery)

				if (returnQuery < 0)

					DisarmTransaction()
					CodRet := "ERRO" //ALLTRIM(STR(returnQuery))
					DscRet	:= "EMB-ERRO-UPDATE-01 : ERRO NA ATUALIZACAO DO INDICADOR DO PRODUTO ANTERIOR"		
					CONOUT("DESABILITA INDICADOR ANTIGO -> CODIGO RETORNO : " + CodRet + " | MENSAGEM : " + DscRet + " | SQL Error : " + TCSQLError())

				else

					//ATUALIZA O PRODUTO ANTERIOR
					//cQuery  := "UPDATE SB1" + cTabelaEmp + " "
					cQuery  := "UPDATE SB1010 "
					cQuery  += "SET B1_YCODCOM = '" + sProdNovo + "', B1_YBLSCPC = '1' "
					cQuery  += "WHERE B1_FILIAL = '' AND "
					cQuery  += " B1_COD = '" + sProdAnterior + "' AND "
					cQuery  += " D_E_L_E_T_ = '' "

					returnQuery := TCSQLExec(cQuery)

					if (returnQuery < 0)

						DisarmTransaction()
						CodRet := "ERRO" //ALLTRIM(STR(returnQuery))
						DscRet	:= "EMB-ERRO-UPDATE-04 : ERRO NA HABILITACAO DO PRODUTO ANTERIOR"					
						CONOUT("ATUALIZA PRODUTO ANTERIOR -> CODIGO RETORNO : " + CodRet + " | MENSAGEM : " + DscRet + " | SQL Error : " + TCSQLError())

					else

						CodRet := sProdNovo
						DscRet	:= ""

					Endif

				Endif					

			EndIf		

		EndIf

		_aRet	:=	{CodRet,DscRet}

	END TRANSACTION

Return _aRet

/*/{Protheus.doc} XCONVERRLOG
//TODO Descrição auto-gerada.
@author FERNANDO ROCHA
@description CONVERTER LOG DE ERRO PARA TEXTO SIMPLES
@since 06/07/2017
@version 1.0
@param aAutoErro, array, descricao
@type function
/*/
Static Function XCONVERRLOG(aAutoErro)
	Local cRet := ""
	Local nX := 1

	for nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX] + CRLF
	Next nX
Return cRet


Static Function fRetCodCli(cCnpj, cNumBiz)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(A1_COD, '') AS A1_COD "
	cSQL += " FROM "+ RetSQLName("SA1") + " WITH (NOLOCK) "
	cSQL += " WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1")) 
	cSQL += " AND A1_CGC = "+ ValToSQL(cCnpj)
	cSQL += " AND A1_YBIZAGI = "+ ValToSQL(cNumBiz)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->A1_COD)
	
		cRet := (cQry)->A1_COD
		
	EndIf
	
	(cQry)->(DbCloseArea())
	
Return(cRet)

Static Function fVldPutProd(aProd)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSQLIn := ArrTokStr(aProd, ",")

	cSQLIn := StrTran(cSQLIn, "{")
	cSQLIn := StrTran(cSQLIn, "}")
	cSQLIn := StrTran(cSQLIn, '"', "'")

	cSQL := " SELECT ISNULL(COUNT(B1_COD),0) AS COUNT "
	cSQL += " FROM "+ RetSQLName("Sb1") + " WITH (NOLOCK) " 
	cSQL += " WHERE B1_FILIAL = "+ ValToSQL(xFilial("SB1"))
	cSQL += " AND B1_COD IN (" + cSQLIn + ")"
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (Len(aProd) == (cQry)->COUNT)
	
	(cQry)->(DbCloseArea())
		
Return(lRet)