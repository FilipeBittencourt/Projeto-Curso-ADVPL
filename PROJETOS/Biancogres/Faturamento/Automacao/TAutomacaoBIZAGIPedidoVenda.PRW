#Include "TOTVS.CH"
#Include "Protheus.CH"

Class TAutomacaoBIZAGIPedidoVenda From TAbstractClass
	
	//atributos publico
	
	Public Data Empresa	as character
	Public Data Filial		as character
	
	//atributos privado
	Public Data _oResult	
	
	//metodos publicos	
	Public Method New() Constructor
	
	Public Method Processa()	//incluir pedido
	
	//metodos privados
	Public Method _CriarPedido()			

EndClass

Method New (cEmp, cFil) Class TAutomacaoBIZAGIPedidoVenda
	
	_Super:New()
	
	::Empresa	:= cEmp
	::Filial	:= cFil
	
Return 


Method _CriarPedido(cString) Class TAutomacaoBIZAGIPedidoVenda

	Local aListDados		:= {}
	Local nPos				:= 0
	Local nI				:= 0
	
	Local cVend				:= ""//VENDEDOR
	Local cTipoSai			:= ""//TIPODESAIDA
	Local cTipoPed			:= ""//VENDEDOR
	Local cCliente			:= ""//CLIENTE
	Local cLoja				:= ""//LOJA
	Local cPedCom			:= ""//PEDIDODECOMPRA
	Local cProd				:= ""//[PRODUTO | QUANTIDADEPRODUTO | VALORPRODUTO | TES]
	Local cCLVL				:= ""//CLASSEDEVALOR
	Local cCC				:= ""//CENTRODECUSTO
	Local cFrete			:= ""//FREETE
	Local cTrans			:= ""//TRANSPORTADORA
	Local cDtSaiMer			:= ""//DATADESAIDADAMERCADORIA
	Local cSolici			:= ""//SOLICITANTE
	Local cAutori			:= ""//AUTORIZADOPOR
	Local cCondPag			:= ""//COND_PAG
	Local cObs				:= ""
	Local cLocaliz			:= ""
	
	Local aCliente			:= ""
	Local aProd				:= {}
	Local aLinha			:= {}
	
	Local oPVStruct 		:= Nil
	Local oPVItemStruct		:= Nil
	Local oListPVItem 		:= ArrayList():New()
	
	/*
	SEQUENCIA:
	  VENDEDOR
	  TIPODESAIDA
	  TIPODEPEDIDO
	  CLIENTE-LOJA
	  PEDIDODECOMPRA
	  [PRODUTO | QUANTIDADEPRODUTO | VALORPRODUTO| TES]
	  CLASSEDEVALOR
	  CENTRODECUSTO
	  FRETE
	  TRANSPORTADORA
	  DATADESAIDADAMERCADORIA
	  SOLICITANTE
	  AUTORIZADOPOR
	  COND_PAG
	*/
	
	aListDados	:= StrTokArr2(cString, ";", .T.)
	
	nPos		:= 1
	cVend		:= aListDados[nPos++]//VENDEDOR
	cTipoSai	:= aListDados[nPos++]//TIPODESAIDA
	cTipoPed	:= aListDados[nPos++]//TIPODEPEDIDO
	cCliente	:= aListDados[nPos++]//CLIENTE
	cPedCom		:= aListDados[nPos++]//PEDIDODECOMPRA
	cProd		:= aListDados[nPos++]//[PRODUTO | QUANTIDADEPRODUTO | VALORPRODUTO]
	cCLVL		:= aListDados[nPos++]//CLASSEDEVALOR
	cCC			:= aListDados[nPos++]//CENTRODECUSTO
	cFrete		:= aListDados[nPos++]//FREETE
	cTrans		:= aListDados[nPos++]//TRANSPORTADORA
	cDtSaiMer	:= aListDados[nPos++]//DATADESAIDADAMERCADORIA
	cSolici		:= aListDados[nPos++]//SOLICITANTE
	cAutori		:= aListDados[nPos++]//AUTORIZADO
	cCondPag	:= aListDados[nPos++]//COND_PAG
	cLocaliz	:= aListDados[nPos++]//Localização
	cObs		:= aListDados[nPos++]//Obs
	
	cProd		:= StrTran(cProd, "[", "" )
	cProd		:= StrTran(cProd, "]", "" )
	aProd		:= StrTokArr2(cProd, "&", .T.)
	
	aCliente	:= StrTokArr2(cCliente, "-", .T.)
	cCliente	:= aCliente[1]
	cLoja		:= aCliente[2]


	//monta dados cabeçalho pedido
	
	oPVStruct					:= TPedidoVendaStruct():New()
	oPVStruct:Vendedor			:= AllTrim(cVend)
	oPVStruct:Cliente 			:= AllTrim(cCliente)
	oPVStruct:LojaCli 			:= AllTrim(cLoja)
	oPVStruct:LojaEnt 			:= AllTrim(cLoja)
	oPVStruct:SubTp				:= "O"
	oPVStruct:TipoPedido		:= cTipoPed
	oPVStruct:CondPag			:= cCondPag
	oPVStruct:ClasseValor		:= cCLVL
	oPVStruct:CentroCusto		:= cCC
	oPVStruct:TipoFrete			:= cFrete
	oPVStruct:Transportadora	:= AllTrim(cTrans)
	oPVStruct:Conf				:= 'S'
	oPVStruct:Hora				:= Substr(Time(), 1, 5)
	oPVStruct:Obs				:= cObs
	
	
	//oPVStruct:TipoSaida		:= cTipoSai
	//oPVStruct:CodPedCompra	:= cPedCom
	//oPVStruct:Solicitante		:= cSolici
	//oPVStruct:Autorizado		:= cAutori
	
	
	For nI:=1 To Len(aProd)
		
		aLinha := StrTokArr2(aProd[nI], "|", .T.)
		
		//[PRODUTO | QUANTIDADEPRODUTO | VALORPRODUTO | TES]
		
		//monda dados item
		oPVItemStruct			:= TPedidoVendaItemStruct():New()
		oPVItemStruct:Produto	:= AllTrim(aLinha[1])
		oPVItemStruct:QuantVen	:= Val(aLinha[2])
		oPVItemStruct:PrecoVen	:= Val(aLinha[3])
		oPVItemStruct:PrecoUni	:= Val(aLinha[3])
		oPVItemStruct:Valor 	:= Val(aLinha[2]) * Val(aLinha[3])
		oPVItemStruct:PedCom	:= cPedCom
		oPVItemStruct:Tes		:= aLinha[4] //"572"
		oPVItemStruct:NumNFOri	:= AllTrim(aLinha[5]) 
		oPVItemStruct:SerieNFOri:= AllTrim(aLinha[6]) 
		oPVItemStruct:ItemNFOri	:= AllTrim(aLinha[7])//Substr(AllTrim(aLinha[7]) , 3, 2)
		
		oPVItemStruct:Localiz	:= cLocaliz 
		
		oPVStruct:PedVenItens:Add(oPVItemStruct)
		
	Next nI


Return oPVStruct


Method Processa() Class TAutomacaoBIZAGIPedidoVenda

	Local oIntBizagi	:= Nil
	Local oListItens	:= Nil	
	Local oPedido		:= Nil
	Local oPedVen		:= Nil
	Local oRetPedVen	:= Nil
	Local oIntBizItem	:= Nil
	Local nI			:= 0
	Local lErroReg		:= .F.
	Local cEmp			:= ""
	Local cFil			:= ""
	
	
	//Classe padrao de Log de Processo e Workflow
	::oPro:Start()	
	
	//Campos para workflow
	::oPro:oWFP:cMethod := "Inclusão Pedido Venda Bizagi"
	
	oIntBizagi 			:= TIntegracaoBizagi():New()
	oIntBizagi:Empresa	:= ::Empresa
	oIntBizagi:Filial	:= ::Filial
	oIntBizagi:SetProcesso("PV")
	oIntBizagi:Get()
	

	For nI:=1 To oIntBizagi:oItens:GetCount()
		
		cEmp	:= AllTrim(oIntBizagi:oItens:GetItem(nI):Empresa)
		cFil	:= AllTrim(oIntBizagi:oItens:GetItem(nI):Filial)
		
		If (!Empty(cEmp) .or. !Empty(cFil))
			
			If (cEmpAnt <> cEmp .Or. cFilAnt <> cFil)
				RpcClearEnv()
				RPCSetType(3)
				RPCSetEnv(cEmp, cFil)
			EndIf
			
				lErroReg 	:= .F.
				
				oIntBizItem	:= oIntBizagi:oItens:GetItem(nI)
				
				If (oIntBizItem <> Nil .And. !Empty(oIntBizItem:Dados))
					
					oPedido		:= ::_CriarPedido(oIntBizItem:Dados)
					
					oPedVen		:= TPedidoVenda():New(oPedido)
					oRetPedVen	:= oPedVen:Incluir()
					
					oIntBizItem:SetStatus(oRetPedVen:Ok, oRetPedVen:Mensagem)
					oIntBizItem:Update()
						
					If (oRetPedVen:Ok) //caso sucesso
					
						cNumPed := oPedVen:GetNumPed()
						cJson	:= oPedVen:GetRecnosJson()
						
						oIntBizItem:UpdateBizagi(cNumPed+";;", cJson)
						
						oIntBizagi:oItens:GetItem(nI):SetStatus(.T., "")
						lErroReg := .F.
						
					Else //caso erro
					
						oIntBizItem:UpdateBizagi(";"+oRetPedVen:Mensagem+";", "")
						
						oIntBizagi:oItens:GetItem(nI):SetStatus(.F., oRetPedVen:Mensagem)
						lErroReg := .T.
						
					EndIf
									
		
					::oLog:cIDProc 	:= ::oPro:cIDProc
					::oLog:cOperac 	:= "N"	
					::oLog:cMetodo 	:= "IBZ_IPV"
					::oLog:cTabela 	:= RetSQLName("SC5")  	//tabela de origem
					::oLog:nIDTab 	:= oRetPedVen:ID		//recno da tabela de origem
					::oLog:cRetMen	:= oRetPedVen:Mensagem	//mensagem do erro/retorno
					::oLog:cHrFin 	:= Time()
					::oLog:cEnvWF 	:= IIF(lErroReg, "S", "N")	
					::oLog:Insert()
					
					If (lErroReg)
					
						::oPro:oWFP:cMenRet := oRetPedVen:Mensagem
						
						::oPro:oWFP:AddMensagem("Processo Bizagi", oIntBizItem:ProcBizagi) 
					
					EndIf
							
					
				EndIf	
			
		EndIf
		
	Next nI
	
	::oPro:Finish()
	
Return
