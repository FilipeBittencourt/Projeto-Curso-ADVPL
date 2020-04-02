#INCLUDE "PROTHEUS.CH"
#Include "aarray.ch"

User Function SchedPedido(aParam)

	Local oSchedPedido 	:= SchedPedido():New()

	oSchedPedido:cEmp 	:= "09"
	oSchedPedido:cFil 	:= "01"

	//altera informação da tread
	PTInternal(1,"U_SCHEDPEDIDO|"+oSchedPedido:cEmp+"|"+oSchedPedido:cFil)

	If oSchedPedido:ControlJOB("U_SCHEDPEDIDO",5)

		oSchedPedido:IniciaAmb()

		//PERCORRE TODAS AS APIS DE INTEGRAÇÃO
		VT8->(dbGoTop())
		While VT8->(!Eof())

			//Verifica se a API esta habilitada para uso
			If VT8->VT8_MSBLQL == "2"

				//seta variaves para utilzação da API
				oSchedPedido:SetAPI(VT8->VT8_API)

				//verifica qual integração esta configurada para esta empresa
				Do Case

					Case AllTrim(oSchedPedido:cAPI) == "VTEX"

					oSchedPedido:IntPedPagAprov()
					oSchedPedido:IntPedPagPend()

					Case AllTrim(oSchedPedido:cAPI) == "BSELLER"

					oSchedPedido:BSPedPagAprov()
					oSchedPedido:BSPedPagPend()
					oSchedPedido:BSPedCanc()
					oSchedPedido:BSPedPagNeg()

					//				Case AllTrim(oSchedPedido:cAPI) == "ANYMARKET"
					//					oSchedPedido:AnyPedBase()
					//					oSchedPedido:AnyPedidos()
					//				
					//				Case AllTrim(oSchedPedido:cAPI) == "CIASHOP"
					//					oSchedPedido:CiaPedidos()									
					//
				EndCase

			EndIf

			VT8->(dbSkip())

		EndDo

		oSchedPedido:FinalAmb()

	EndIf

Return

/*
@Title   : Classe para schedule de integração dos pedidos de venda com o ecommerce VTEX
@Type    : CLS = Classe
@Name    : SchedPedido
@Author  : Ihorran Milholi
@Date    : 21/08/2014
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
Class SchedPedido From SchedAcesso

Data cOrderID
Data cSequence
Data cIdCart
Data cNumPed
Data aProdutos
Data cStatus
Data cStatPed
Data cToken

Data cCNPJCli
Data cTransp
Data nValFrete
Data nPercDesc
Data cTipoFrete
Data dDtEntrega
Data aNumPed
Data cNomeAdquir

Data cTransVT6
Data cAPIVT6

Method New() CONSTRUCTOR
Method IntPedPagPend()
Method IntPedPagAprov()
Method IntPedido()
Method FatGrupo()
Method GetTransp()
Method AtuCondPag()
Method TrocaStatus()
Method GeraPedido()
Method PedidoGrupo()
Method BuscaProd()
Method CriaSB2()
Method BuscaPreco()
Method LibPedido()
Method GrvNumPed()
Method CriaInteg()
Method GetAdmFinanc()
Method CancelInt()
Method BSPedPagPend()
Method BSPedPagAprov()
Method BSIntPedido()
Method BSAtuCondPag()
Method BSPedPagNeg()
Method BSPedCanc()
Method CriaStatPed()
Method GetProduto()
Method ElimiResid()
Method VerPedLog()
Method AlterTransp()

//Métodos da ANYMARKET
Method CriaPedAny()

Method AnyPedidos()
Method AnyPedBase()
Method AnyNovosPedidos()
Method AnyIntPedido()
Method ANYAtuCondPag()
Method ANYPedPagAprov()
Method ANYPedPagPend()
Method ANYPedCanc()
Method ANYPedPagNeg()
Method ANYAddTrans()

//Métodos da CiaShop
Method CiaPedidos()
Method CriaPedCia()
Method CiaIntPedido()
Method CiaAtuCondPag()
Method CiaPgtoNega()		//PaymentTransactionDeclined (Pedidos rejeitados pela administradora
Method CiaPedCanc()		//Cancelled (cancelado)
Method CiaPedPagNeg()	//PaymentTransactionDeclined (Pedidos rejeitados pela administradora).

//Métodos da Canal da Peça
Method CanalPedBase()
Method CanalPedidos()
Method CriaPedCanal()
Method CanalIntPedido()
Method CanalAtuCondPag()
Method CanalPedCanc()	//CANCELED (cancelado)
Method CanalPedPagNeg()	//STRAYED (Pedidos rejeitados pela administradora).

//Métodos da Resultate
Method ResPedidos()
Method ResPedBco()
Method CriaPedRes()
Method ResIntPedido()
Method ResAtuCondPag()
Method ResPgtoNega()		//PaymentTransactionDeclined (Pedidos rejeitados pela administradora
Method ResPedCanc()		//Cancelled (cancelado)
Method ResPedPagNeg()	//PaymentTransactionDeclined (Pedidos rejeitados pela administradora).
Method ResAddTrans()
Method ResIntegra()

Method B2CPedidos()
//Method B2CPedBanco()

EndClass

/*/
@Title   : Construtor do Objeto
@Type    : MTH = Metodo
@Name    : New
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method New() Class SchedPedido

	//Inicializa Metodos New da Classe RestAcesso          
	_Super:New()

	::cOrderID		:= ""
	::cSequence		:= ""
	::cIdCart		:= ""	
	::cNumPed		:= ""
	::aProdutos		:= {}
	::cTransp		:= ""
	::nValFrete		:= 0
	::nPercDesc		:= 0
	::cTipoFrete	:= ""
	::cCNPJCli		:= ""
	::cStatus		:= ""
	::aNumPed		:= {}
	::cNomeAdquir	:= ""
	::cTransVT6		:= ""
	::cAPIVT6		:= ""

Return Self

/*/
@Title   : Integração dos Pedidos com Status Pendentes de Pagamento
@Type    : MTH = Metodo
@Name    : IntPedPagPend
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method IntPedPagPend() Class SchedPedido

	Local nTotPage		:= 0
	Local nPage			:= 0
	Local cStatus		:= "payment-pending"
	Local oRestPedido	:= RestPedido():New()
	Local jsPedidos		:= oRestPedido:GetTPedidos(cStatus,1)
	Local lPedIntegr	:= .f.
	Local i
	Local x

	If jsPedidos <> NIL

		//Recupera o total de pagina de pedidos                                              
		nTotPage := jsPedidos[#"paging"][#"pages"]

		While nPage <> nTotPage

			nPage++

			If nPage <> 1

				//Recupera os pedidos da proxima pagina
				jsPedidos := oRestPedido:GetTPedidos(cStatus,nPage)

			EndIf

			If jsPedidos <> NIL

				VT1->(dbSetOrder(1))

				For i:= Len(jsPedidos[#"list"]) to 1 Step -1

					::cOrderID 	:= Padr(Upper(jsPedidos[#"list"][i][#"orderId"]),TamSx3("VT1_ORDID")[1])
					::cSequence	:= Padr(Upper(jsPedidos[#"list"][i][#"sequence"]),TamSx3("VT1_SEQUEN")[1])

					lPedIntegr := ::CriaInteg()

					If lPedIntegr

						//Caso status em branco necessario integrar pedido	
						If Empty(::cStatus)

							lPedIntegr := ::IntPedido()
							lPedIntegr := ::TrocaStatus(lPedIntegr)
							lPedIntegr := ::GrvNumPed(lPedIntegr)

						EndIf

						//Caso tenha mensagem de erro grava na tabela de integração
						::GrvMsgErro()

					EndIf

				Next

			EndIf

		EndDo

	EndIf

Return Self

/*/
@Title   : Integração dos Pedidos com Status Pagamento Aprovado
@Type    : MTH = Metodo
@Name    : IntPedPagAprov
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method IntPedPagAprov() Class SchedPedido

	Local nTotPage		:= 0
	Local nPage			:= 0
	Local cStatus		:= "ready-for-handling"
	Local oRestPedido	:= RestPedido():New()
	Local jsPedidos		:= oRestPedido:GetTPedidos(cStatus,1)
	Local lPedIntegr	:= .f.
	Local i

	If jsPedidos <> NIL

		//Recupera o total de pagina de pedidos                                              
		nTotPage := jsPedidos[#"paging"][#"pages"]

		While nPage <> nTotPage

			nPage++

			If nPage <> 1

				//Recupera os pedidos da proxima pagina
				jsPedidos := oRestPedido:GetTPedidos(cStatus,nPage)

			EndIf

			If jsPedidos <> NIL

				VT1->(dbSetOrder(1))

				For i:= Len(jsPedidos[#"list"]) to 1 Step -1

					::cOrderID 	:= Padr(Upper(jsPedidos[#"list"][i][#"orderId"]),TamSx3("VT1_ORDID")[1])
					::cSequence	:= Padr(Upper(jsPedidos[#"list"][i][#"sequence"]),TamSx3("VT1_SEQUEN")[1])

					lPedIntegr := ::CriaInteg()

					If lPedIntegr

						//Caso status em branco necessario integrar pedido	
						If Empty(::cStatus)

							lPedIntegr := ::IntPedido()
							lPedIntegr := ::TrocaStatus(lPedIntegr)
							lPedIntegr := ::GrvNumPed(lPedIntegr)

						EndIf

						//Caso o pedido esteja integrado e com o pagamento aprovado, sera feito a mudança de status do pedido para Iniciar Manuseio		
						If ::cStatus == "1"

							lPedIntegr := ::AtuCondPag()
							lPedIntegr := ::TrocaStatus(lPedIntegr)

						EndIf

						//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status na vtex
						If ::cStatus == "2"
							lPedIntegr	 := AlteraPrazoEnt(Self, ::cNumPed, ::cOrderID, ::cAPI)
							lPedIntegr := ::TrocaStatus(lPedIntegr)

						EndIf

						//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status na vtex
						If ::cStatus == "3"

							lPedIntegr := ::LibPedido()
							lPedIntegr := ::TrocaStatus(lPedIntegr)

						EndIf

						//Caso tenha mensagem de erro grava na tabela de integração
						::GrvMsgErro()

						//rotina para pausar os pedidos do mercado livre, provisorio
						If ::cStatus == "4"

							If SubStr(::cOrderID,1,11) == "MERCADOPAGO"

								VT1->(dbSetOrder(1))
								If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

									RecLock("VT1",.f.)
									VT1->VT1_OBS		:= 'Pausado automaticamente pedidos do mercado livre, provisorio (MERCADOPAGO)'
									VT1->VT1_STATAN	:= VT1->VT1_STATUS
									VT1->VT1_STATUS	:= "P"
									VT1->(msUnlock())

								EndIf

							EndIf

						EndIf

					EndIf

				Next

			EndIf

		EndDo

	EndIf

Return Self

/*/
@Title   : Monta informações atraves de JSON para pedido de venda VTEX x Protheus
@Type    : MTH = Metodo
@Name    : IntPedido
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method IntPedido() Class SchedPedido

	Local oRestPedido	:= RestPedido():New()
	Local jsPedido		:= oRestPedido:GetPedido(::cOrderID)
	Local oCliente 		:= SchedCliente():New(::cAPI)
	Local lRetorno		:= .f.

	Local jsEndCliente
	Local jsCliente
	Local jsItens
	Local i

	Private lMsErroAuto := .f.

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If jsPedido <> NIL

		jsCliente	:= jsPedido[#"clientProfileData"]
		jsItens		:= jsPedido[#"items"]
		jsEndCliente:= jsPedido[#"shippingData"][#"address"]

		::aProdutos		:= {}
		::cTipoFrete	:= iif(jsPedido[#"value"]-jsPedido[#"totals"][1][#"value"]-jsPedido[#"totals"][2][#"value"]==jsPedido[#"totals"][3][#"value"],"C","F")
		::nValFrete		:= Round((jsPedido[#"totals"][3][#"value"]/100),TamSx3("L1_FRETE")[2])
		::cTransp		:= ::GetTransp(jsPedido[#"shippingData"][#"logisticsInfo"][1][#"deliveryIds"][1][#"courierId"])
		::dDtEntrega	:= dDataBase+10

		//metodo para cadastrar ou atualizar cliente
		lRetorno := oCliente:IncluiCliente(jsCliente,jsEndCliente)

		//Atualiza tabela de integração
		If lRetorno

			//Recupera os produtos e quantidades para solicitar estoque em outra loja caso estoque seja compartilhados
			For i := 1 to Len(jsItens)

				aAdd(::aProdutos,{StrZero(i,TamSX3("C6_ITEM")[1]),Padr(jsItens[i][#"refId"],TamSx3("B1_COD")[1]),jsItens[i][#"quantity"],jsItens[i][#"sellingPrice"]/100,.t.,::dDtEntrega})

			Next

			lRetorno := ::GeraPedido(oCliente)

		Else

			//inclui mensagens de erro no vetor principal
			::AddErro(oCliente:aMsgErro)

		EndIf

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para integração inicial!")

	EndIf

Return lRetorno

/*/
@Title   :
@Type    : MTH = Metodo
@Name    : PedidoGrupo
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method PedidoGrupo() Class SchedPedido

	Local oCliente	:= SchedCliente():New(::cAPI)
	Local lRetorno	:= .f.

	Private lMsErroAuto := .f.

	//metodo para cadastrar ou atualizar cliente
	lRetorno := oCliente:VerifCliente(::cCNPJCli)

	//Atualiza tabela de integração
	If lRetorno

		lRetorno := ::GeraPedido(oCliente)

	Else

		aAdd(::aMsgErro,"Não foi possivel encontrar um codigo de cliente referente ao CNPJ "+::cCNPJCli+" na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")

	EndIf

Return lRetorno

/*/
@Title   : Criação de um pedido de venda via execauto
@Type    : MTH = Metodo
@Name    : GeraPedido
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method GeraPedido(oCliente, cVendedor) Class SchedPedido

	Local cProduto 		:= ""
	Local nPreco   		:= 0
	Local cTES	  		:= ""
	Local aCabec   		:= {}
	Local aItens   		:= {}
	Local aAuxItens		:= {}
	Local lRetorno 		:= .t.
	Local aPvlNfs  		:= {}
	Local aBloqueio		:= {}
	Local cOper	   		:= SuperGetMv("VT_TESINTS",.F.,"51")
	Local cCondPag 		:= SuperGetMv("VT_CONDPAG",.F.,"001")
	Local lFatAutomat		:= SuperGetMv("VT_FATAUT",.F.,.T.)
	Local nQtdLib  		:= 0
	Local aRecSC6  		:= {}
	Local i
	Local nPrecoVenda		:= 0

	Local nVolumes 		:= 0
	Local nPesoBrut		:= 0
	Local nPesoLiq 		:= 0
	Local cEspecie 		:= "VOLUME(S)"
	Local aPedidos		:= {}
	Local cEmpArm			:= ''
	Local cFilArm			:= ''
	Local cEmpEst			:= ''
	Local cFilEst			:= ''
	Local aProdEst		:= {}
	Local aProdutos		:= {}

	Local nI, nJ			:= 0

	Default cVendedor := ''

	If cEmpAnt == '08'

		For nI := 1 to Len(::aProdutos)

			cProduto := ::BuscaProd(::aProdutos[nI][2],::aProdutos[nI][5])

			cEmpEst	:= cEmpAnt
			cFilEst	:= cFilAnt

			//Verifica o cadastro de produto
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cProduto))

				ZZL->(dbSetOrder(1))
				If ( ZZL->(dbSeek(xFilial("ZZL")+SB1->B1_FABRIC)) .and. ZZL->ZZL_EMPFOR+ZZL->ZZL_FILFOR <> cEmpAnt+cFilAnt )
					cEmpEst := ZZL->ZZL_EMPFOR
					cFilEst := ZZL->ZZL_FILFOR

				EndIf
			EndIf

			nPos := 0

			If Len(aProdEst) == 0

				aAdd(aProdEst, { cEmpEst, cFilEst , {::aProdutos[nI]}} )

			Else

				nPos := aScan(aProdEst, {|x| x[1]+x[2] == cEmpEst + cFilEst})

				If nPos > 0
					aAdd(aProdEst[nPos, 3], ::aProdutos[nI] )

				Else
					aAdd(aProdEst, { cEmpEst, cFilEst , {::aProdutos[nI]}} )

				EndIf

			EndIf

		Next

	Else
		aAdd(aProdEst, {'08', '01', ::aProdutos})

	EndIf

	For nI := 1 to Len(aProdEst)

		nVolumes	:= 0
		nPesoBrut	:= 0
		nPesoLiq	:= 0

		//Verifica se já não existe pedido de venda na base
		//pode ser que esteja executando novamente e apenas ter pendencias no faturamento entre grupos
		SC5->(dbOrderNickName("YPEDWEB"))
		If !SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1])+oCliente:cCliente+oCliente:cLoja + aProdEst[nI][1] + aProdEst[nI][2] ))

			::cNumPed 	:= GetSx8Num("SC5","C5_NUM")
			aCabec		:= {}
			aItens		:= {}

			ConfirmSx8()

			aProdutos := aProdEst[nI][3]

			For i:= 1 to Len(aProdutos)

				cProduto := ::BuscaProd(aProdutos[i][2],aProdutos[i][5])

				If !Empty(cProduto)

					//Verifica o cadastro de produto
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+cProduto))

						cProduto := SB1->B1_COD

						::CriaSB2(cProduto)

						//Define a TES via TES Inteligente				
						//cTES := MaTesInt(2,cOper,oCliente:cCliente,oCliente:cLoja,"C",cProduto)
						cTES := U_VIXA103(2,cOper,oCliente:cCliente,oCliente:cLoja,"C",cProduto)

						SF4->(DbSetOrder(1))
						If SF4->(dbSeek(xFilial("SF4")+cTES))

							nPrecoVenda := aProdutos[i][4]
							nPreco := ::BuscaPreco(cProduto,oCliente,nPrecoVenda)

							If nPreco > 0

								aAuxItens	:= {}
								nQtdLib		:= 0

								SB1->(dbSetOrder(1))
								SB1->(dbSeek(xFilial("SB1")+cProduto))

								nQdtVenda := aProdutos[i][3]
								//Verifica se o item precisa de faturamento entre grupo, caso não precise será analisado se houve problema de liberação de credito e estoque
								VT3->(dbSetOrder(1))
								If ! ( VT3->(dbSeek(xFilial("VT3")+SB1->B1_FABRIC)) .and. VT3->VT3_EMPFOR+VT3->VT3_FILFOR <> cEmpAnt+cFilAnt )

									nQtdLib := nQdtVenda

									lFatAutomat		:= SuperGetMv("VT_FATAUT",.F.,.T.)

									If !lFatAutomat
										lFatAutomat := ::VerPedLog(cProduto)
									EndIf

									If lFatAutomat

										nVolumes	+= nQdtVenda
										nPesoBrut	+= SB1->B1_PESO*nQdtVenda
										nPesoLiq	+= SB1->B1_PESO*nQdtVenda

									EndIf

								EndIf

								aAdd(::aNumPed,{aProdutos[i][2],::cNumPed,aProdutos[i][1]})

								aadd(aAuxItens,{"C6_ITEM"		,aProdutos[i][1],Nil})
								aadd(aAuxItens,{"C6_PRODUTO"	,cProduto,Nil})
								aadd(aAuxItens,{"C6_LOCAL"		,"01",Nil})
								aadd(aAuxItens,{"C6_TES"		,cTES,Nil})
								aadd(aAuxItens,{"C6_QTDVEN"		,Round(nQdtVenda,TamSx3("C6_QTDVEN")[2]),Nil})
								aadd(aAuxItens,{"C6_QTDLIB"		,Round(nQtdLib,TamSx3("C6_QTDVEN")[2]),Nil})
								aadd(aAuxItens,{"C6_PRUNIT"		,Round(nPreco,TamSx3("C6_PRUNIT")[2]),Nil})
								aadd(aAuxItens,{"C6_PRCVEN"		,Round(nPreco,TamSx3("C6_PRCVEN")[2]),Nil})
								aadd(aAuxItens,{"C6_VALOR"		,Round( Round(nQdtVenda,TamSx3("C6_QTDVEN")[2]) * Round(nPreco,TamSx3("C6_PRCVEN")[2]), TamSx3("C6_VALOR")[2]),Nil})
								aadd(aAuxItens,{"C6_ENTREG"		,aProdutos[i][6],Nil})
								aadd(aAuxItens,{"C6_VALDESC"	,0,Nil})
								aadd(aAuxItens,{"C6_DESCONT"	,0,Nil})								

								aAdd(aItens,aAuxItens)

							Else

								//Registra o erro no cadastro do produtos no vetor
								lRetorno := .f.

								aAdd(::aMsgErro,"Não foi possivel definir um preco para o produto "+AllTrim(cProduto)+" na base de dados, favor revisar a tabela SB0 na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")

							EndIf

						Else

							//Registra o erro no cadastro do produtos no vetor
							lRetorno := .f.

							aAdd(::aMsgErro,"Não foi possivel encontrar uma TES de Venda para o produto "+AllTrim(cProduto)+" na base de dados, favor revisar as tabelas SF4 e SFM na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")

						EndIf

					Else

						//Registra o erro no cadastro do produtos no vetor
						lRetorno := .f.

						aAdd(::aMsgErro,"Não foi possivel encontrar o codigo do produto "+AllTrim(aProdutos[i][2])+" na base de dados, favor revisar a tabela SB1 na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")

					EndIf

				Else

					//Registra o erro no cadastro do produtos no vetor
					lRetorno := .f.

					aAdd(::aMsgErro,"Não foi possivel encontrar uma amarração para o codigo do produto "+AllTrim(aProdutos[i][2])+" na base de dados, favor revisar a tabela SB1 na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")

				EndIf


			Next

			If lRetorno

				//Monta cabeçalho do pedidos de venda
				aadd(aCabec,{"C5_TIPO" 		,"N",Nil})
				aadd(aCabec,{"C5_NUM"		,::cNumPed,Nil})
				aadd(aCabec,{"C5_CLIENTE"	,oCliente:cCliente,Nil})
				aadd(aCabec,{"C5_LOJACLI"	,oCliente:cLoja,Nil})
				aadd(aCabec,{"C5_LOJAENT"	,oCliente:cLoja,Nil})
				aadd(aCabec,{"C5_YEMPFOR"	,aProdEst[nI][1] + aProdEst[nI][2],Nil})

				If !Empty(oCliente:cCondPag)
					aadd(aCabec,{"C5_CONDPAG",oCliente:cCondPag,Nil})
				ElseIf !Empty(cCondPag)
					aadd(aCabec,{"C5_CONDPAG",cCondPag,Nil})
				EndIf

				If ! Empty(cVendedor)
					aadd(aCabec,{"C5_VEND1",cVendedor,Nil})

				ElseIf !Empty(oCliente:cVendedor)
					aadd(aCabec,{"C5_VEND1",oCliente:cVendedor,Nil})

				EndIf

				aadd(aCabec,{"C5_EMISSAO"	,dDataBase,Nil})
				aadd(aCabec,{"C5_YSTATUS"	,"B",Nil})
				aadd(aCabec,{"C5_YPEDWEB"	,::cOrderID,Nil})

				aadd(aCabec,{"C5_ESPECI1"	,cEspecie,Nil})

				aadd(aCabec,{"C5_VOLUME1"	,Round(nVolumes,TamSx3("C5_VOLUME1")[2]),Nil})
				aadd(aCabec,{"C5_PESOL"		,Round(nPesoLiq,TamSx3("C5_PESOL")[2]),Nil})
				aadd(aCabec,{"C5_PBRUTO"	,Round(nPesoBrut,TamSx3("C5_PBRUTO")[2]),Nil})

				aadd(aCabec,{"C5_YAPI"		,::cAPI,Nil})

				If !Empty(::cTransp)

					SA4->(dbSetOrder(1))
					If SA4->(dbSeek(xFilial("SA4")+::cTransp))

						aadd(aCabec,{"C5_TRANSP",::cTransp,Nil})

					EndIf

				Else

					SA1->(dbSetOrder(1))
					If SA1->(dbSeek(xFilial("SA1")+oCliente:cCliente+oCliente:cLoja))

						If !Empty(SA1->A1_TRANSP)

							aadd(aCabec,{"C5_TRANSP",SA1->A1_TRANSP,Nil})

						EndIf

					EndIf

				EndIf

				If !Empty(::cTipoFrete)
					aadd(aCabec,{"C5_TPFRETE",::cTipoFrete,Nil})
				EndIf

				aadd(aCabec,{"C5_DESC1",::nPercDesc	,Nil})
				aadd(aCabec,{"C5_FRETE",::nValFrete,Nil})
				aadd(aCabec,{"C5_TIPLIB","1",Nil})

				If SC5->(FieldPos("C5_YHRINC")) > 0
					aadd(aCabec,{"C5_YHRINC",TIME(),Nil})
				EndIf

				If SC5->(FieldPos("C5_YMSGNF")) > 0 .and. !Empty(oCliente:cComplemento)
					aadd(aCabec,{"C5_YMSGNF","COMPLEMENTO "+oCliente:cComplemento,Nil})
				EndIf

				//Gravacao do PEDIDO DE VENDA
				If Len(aItens) > 0
					MsExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)
				Else
					lRetorno := .f.
					aAdd(::aMsgErro,"Não foram encontrados itens da base para o pedido."+cEmpAnt+"\"+cFilAnt+"!")
				EndIf

				If lMsErroAuto

					lRetorno := .f.

					aAdd(::aMsgErro,MostraErro(::cPathLog,"SC5"+AllTrim(::cNumPed)+".LOG"))

					DisarmTransaction()

				EndIf

			EndIf

		Else

			//atualiza variavel com numero do pedido de venda já cadastrado 			                                    	
			::cNumPed := SC5->C5_NUM

			//Realiza estorno de liberação de estoque e credito
			SC9->(dbSetOrder(1))
			If SC9->(dbSeek(xFilial('SC9')+::cNumPed))

				While SC9->(!Eof()) .and. xFilial('SC9')+::cNumPed == SC9->C9_FILIAL+SC9->C9_PEDIDO

					If Empty(SC9->C9_NFISCAL)

						SC6->(dbSetOrder(1))
						SC6->(dbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))

						If SC6->C6_QTDVEN-SC6->C6_QTDENT > 0

							aAdd(aRecSC6,SC6->(Recno()))

						EndIf

						Begin Transaction
							SC9->(a460Estorna())
						End Transaction

					EndIf

					SC9->(dbSkip())

				EndDo

			EndIf

			//Caso tenha algum item liberado anteriormente realiza uma nova liberação	
			For i := 1 to Len(aRecSC6)

				SC6->(dbGoTo(aRecSC6[i]))

				nQtdLib := SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT )


				// Foi comentado o If, devido que alguns pedidos não estavam
				// criando a VT4 corretamente, provavelmente, o sistema caia
				// e quando ia criar a VT4 o sistema pegava somente o primeiro
				// item e isso estava dando problema no schedfatur. Uma vez,
				// que o faturamento é em cima da VT4 para separar as notas fiscais.

				//RETIRADO PARA TER APENAS EM PEDIDOS NOVOS
				//If Len(::aNumPed) == 0
				aAdd(::aNumPed,{SC6->C6_PRODUTO,SC6->C6_NUM,SC6->C6_ITEM})
				//EndIf


				If nQtdLib > 0

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Libera por Item de Pedido                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction
						MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.F.,.T.,.T.,.F.,.F.)
					End Transaction

				EndIf

			Next

			If Len(aRecSC6) > 0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o Flag do Pedido de Venda                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Begin Transaction
					MaLiberOk({SC5->C5_NUM},.F.)
				End Transaction

			EndIf

		EndIf	

		If lRetorno

			//Checa itens liberados
			Ma410LbNfs(1,@aPvlNfs,@aBloqueio)

			If Len(aBloqueio) > 0

				//Percorre o vetor de bloqueio para adicionar as mensagens de erro		        			
				For i := 1 to Len(aBloqueio)

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+aBloqueio[i][4]))

					lRetorno := .f.

					If !Empty(aBloqueio[i][6])
						aAdd(::aMsgErro,"Não foi possivel liberar o credito do pedido para o produto "+AllTrim(aBloqueio[i][4])+" na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")
					EndIf

					If !Empty(aBloqueio[i][7])
						aAdd(::aMsgErro,"Não foi possivel liberar o estoque do pedido para o produto "+AllTrim(aBloqueio[i][4])+" e quantidade "+AllTrim(aBloqueio[i][5])+" na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")
					EndIf

				Next

			EndIf

		EndIf

	Next

	If lRetorno

		//Verifica o faturamento entre grupos
		lRetorno := ::FatGrupo()

	EndIf

Return lRetorno

/*/
@Title   : Metodo para criação do faturamento entre empresas do grupo
@Type    : MTH = Metodo
@Name    : FatGrupo
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method FatGrupo() Class SchedPedido

	Local aFatGrupo	:= {}
	Local nPos		:= 0
	Local aErroAux	:= {}
	Local aPedGrupo	:= {}
	Local i
	Local j
	Local z
	Local lCriaVT4	:= .T.
	Local nQdeVT4		:= 0
	Local aVT4Criada := {}

	Private aAux		:= {}

	//Verifica os fabricantes de cada produto para definir onde irá gerar os pedidos intra-grupo
	For i := 1 to Len(::aProdutos)

		//Verifica o cadastro de produto
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+::aProdutos[i][2]))

			//Verifica se o item precisa de faturamento entre grupo
			VT3->(dbSetOrder(1))
			If VT3->(dbSeek(xFilial("VT3")+SB1->B1_FABRIC)) .and. VT3->VT3_EMPFOR+VT3->VT3_FILFOR <> cEmpAnt+cFilAnt

				nPos := aScan(aFatGrupo,{|x| x[1] == VT3->VT3_EMPFOR .and. x[2] == VT3->VT3_FILFOR})

				If nPos == 0

					aAdd(aFatGrupo,{VT3->VT3_EMPFOR,VT3->VT3_FILFOR,VT3->VT3_FORNECE,VT3->VT3_LOJA,{}})

					nPos := Len(aFatGrupo)

				EndIf

				//Verifica se o cadastro de produtos é igual entre as empresas\filiais
				//::aProdutos[i][5] := StartJob("u_SB1Grupo",GetEnvServer(),.t.,{aFatGrupo[nPos][1],aFatGrupo[nPos][2],RetSqlName("SB1"),xFilial("SB1")})
				::aProdutos[i][5] := RetFullName("SB1",cEmpant) == RetFullName("SB1",aFatGrupo[nPos][1]) 
				If ::aProdutos[i][5] <> NIL

					//Inclui no vetor o item para faturamento entre grupo
					aAdd(aFatGrupo[nPos][5],::aProdutos[i])

				Else

					aAdd(::aMsgErro,"Não foi possivel recuperar o tipo de cadastro de produtos para o produto "+::aProdutos[i,2 ]+" na Empresa\Filial "+aFatGrupo[nPos][1]+"\"+aFatGrupo[nPos][2]+"!")

				EndIf

			EndIf

		EndIf

	Next	

	/*
	if Len(aFatGrupo) == 0
	aAdd(::aMsgErro,"Faturamento entre grupo sem dados VT3!")
	//Return .F.
	Endif
	*/			

	If Len(::aMsgErro) == 0

		//For para percorrer empresas e criar pedidos no destino
		For i := 1 to Len(aFatGrupo)

			//VT4->(dbSetOrder(1))
			//If !VT4->(dbSeek(xFilial("VT4")+::cAPI+::cOrderID+::cSequence+aFatGrupo[i][1]+aFatGrupo[i][2]))

			//Executa um pedido de venda no destino atravez de STARTJOB
			aAux := StartJob("u_PedGrupo",GetEnvServer(),.t.,{aFatGrupo[i][1],aFatGrupo[i][2],SM0->M0_CGC,::cApi,::cOrderID,::cSequence,aFatGrupo[i][5],::cTransp})

			If aAux <> NIL .and. Type('aAux') == 'A' .AND. LEN(aAux) >= 2

				aErroAux := aAux[1]
				aPedGrupo:= aAux[2] // ::aNumPed

				If Len(aErroAux) == 0

					VT4->(DbSetOrder(1))
					If VT4->(DbSeek(xFilial('VT4')+::cApi + ::cOrderID + ::cSequence))
						While !VT4->(Eof()) .and. VT4->(VT4_FILIAL+VT4_API+VT4_ORDID+VT4_SEQUEN) == xFilial('VT4')+::cApi + ::cOrderID + ::cSequence

							aAdd(aVT4Criada, {VT4->VT4_PRODUT, VT4->VT4_ITEM})

							VT4->(DbSkip())
						EndDo
					EndIf

					Begin Transaction

						For z := 1 to Len(aFatGrupo[i][5])

							nPos := aScan(aPedGrupo, {|x| X[3]+X[1] == aFatGrupo[i][5][z][1]+aFatGrupo[i][5][z][2]}) //ITEM + PRODUTO

							lCriaVT4 := aScan(aVT4Criada, {|x| X[2]+X[1] == aFatGrupo[i][5][z][1]+aFatGrupo[i][5][z][2]}) <= 0

							If nPos > 0 .and. lCriaVT4
								RecLock("VT4",lCriaVT4)
								VT4->VT4_FILIAL	:= xFilial("VT4")
								VT4->VT4_API	:= ::cAPI
								VT4->VT4_ORDID	:= ::cOrderID
								VT4->VT4_SEQUEN	:= ::cSequence
								VT4->VT4_EMPFOR	:= aFatGrupo[i][1]
								VT4->VT4_FILFOR	:= aFatGrupo[i][2]
								VT4->VT4_FORNEC	:= aFatGrupo[i][3]
								VT4->VT4_LOJA	:= aFatGrupo[i][4]

								VT4->VT4_NUMPED	:= aPedGrupo[nPos, 2]
								VT4->VT4_ITEM	:= aPedGrupo[nPos, 3]
								VT4->VT4_PRODUT	:= aFatGrupo[i][5][z][2]
								VT4->VT4_QUANT	:= aFatGrupo[i][5][z][3]
								VT4->VT4_DESCPR	:= Posicione("SB1",1,xFilial("SB1")+aFatGrupo[i][5][z][2],"B1_DESC")
								VT4->VT4_STATUS	:= "1"
								VT4->(msUnLock())
								/*Else
								aAdd(::aMsgErro,"Não Gerada VT4 para o Pedido!")
								*/
							EndIf

						Next

						If Len(aFatGrupo[i][5]) == 0
							aAdd(::aMsgErro,"Faturamento entre grupo sem dados VT4!")
						EndIf

					End Transaction

				Else

					//inclui mensagens de erro no vetor principal
					::AddErro(aErroAux)

				EndIf

			Else

				aAdd(::aMsgErro,"Não foi possivel criar o faturamento entre grupos na Empresa\Filial "+aFatGrupo[i][1]+"\"+aFatGrupo[i][2]+"!")

			EndIf

			//EndIf

		Next

	EndIf

Return Len(::aMsgErro) == 0

/*/
@Title   : Recupera a transportadora de acordo com de x para Protheus x VTEX
@Type    : MTH = Metodo
@Name    : GetTransp
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method GetTransp(cIdTransp) Class SchedPedido
	Local cAPI	:= ''
	Local cTransp := ""

	cAPI := ::cAPI

	//Compatibiliza o tamanho do campo               
	cIdTransp := Upper(PadR(cIdTransp,TamSx3('VT6_IDWEB')[1]))

	If AllTrim(cAPI) == 'B2C-RESULT'
		cAPI := PadR('RESULTATE',TamSx3('VT6_API')[1])
	EndIf

	VT6->(dbSetOrder(1))
	If VT6->(dbSeek(xFilial("VT6")+cAPI+cIdTransp))

		cTransp := VT6->VT6_TRANSP

	EndIf

Return cTransp

/*/
@Title   : Atualiza condição de pagamento dos pedidos pagos
@Type    : MTH = Metodo
@Name    : AtuCondPag
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method AtuCondPag() Class SchedPedido

	Local oRestPedido	:= RestPedido():New()
	Local jsPedido		:= oRestPedido:GetPedido(::cOrderID)
	Local lRetorno		:= .f.
	Local i
	Local z

	Local jsCondPag

	Local cOrigem 		:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])
	Local cFormaID		:= ""
	Local cNumCart		:= ""
	Local cForma		:= ""
	Local cAdmFinanc	:= Space(TamSx3("AE_COD")[1])
	Local cDescAdmFin	:= ""
	Local cTid			:= ""
	Local cNSU			:= ""
	Local cDescPag		:= ""
	Local cYObs			:= ""
	Local dVencimento
	Local nPosPag		:= 0

	Private jsPagament
	Private nPosPag

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If jsPedido <> NIL

		Begin Transaction

			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(xFilial("SC5")+::cNumPed))

				//apaga informações de pagamento anteriores
				SL4->(dbSetOrder(1))
				If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))

					While SL4->(!Eof()) .and. xFilial("SL4")+SC5->C5_NUM+cOrigem == SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM

						RecLock("SL4",.f.)
						SL4->(dbDelete())
						SL4->(msUnLock())

						SL4->(dbSkip())

					EndDo

				EndIf

				//Recupera todas as transações de pagamento
				jsCondPag := jsPedido[#"paymentData"][#"transactions"]

				For i := 1 to Len(jsCondPag)

					If jsCondPag[i][#"isActive"]

						//Recupera todas as condições de pagamento de uma transação
						jsPagament := jsCondPag[i][#"payments"]

						For nPosPag := 1 to Len(jsPagament)

							//seta retorno positivo caso grave alguma condição de pagamento
							lRetorno	:= .t.
							cAdmFinanc	:= ::GetAdmFinanc(jsPagament[nPosPag][#"paymentSystem"],jsPagament[nPosPag][#"installments"])

							cDescPag	+= iif(Empty(cDescPag),"",", ")
							cDescPag	+= Upper(	AllTrim(jsPagament[nPosPag][#"paymentSystemName"])+;
							" R$ "+AllTrim(Transform(jsPagament[nPosPag][#"value"]/100,PesqPict("SE1","E1_VALOR")))+;
							iif(jsPagament[nPosPag][#"installments"]>1," - PARCELAS: "+cValtoChar(jsPagament[nPosPag][#"installments"]),""))

							If jsPagament[nPosPag][#"firstDigits"] <> NIL

								cNumCart:= AllTrim(jsPagament[nPosPag][#"connectorResponses"][#"authId"])
								cTid	:= AllTrim(jsPagament[nPosPag][#"connectorResponses"][#"Tid"])
								cNSU	:= AllTrim(jsPagament[nPosPag][#"connectorResponses"][#"Nsu"])
								cYObs	+= iif(Empty(cYOBS),"",", ")
								cYObs	+= "NSU: "+cNSU+" - TID: "+cTid+" - AUTORIZACAO: "+cNumCart

							Else

								cNumCart:= ""
								cTid	:= ""
								cNSU	:= ""

							EndIf

							For z := 1 to jsPagament[nPosPag][#"installments"]

								SAE->(dbSetOrder(1))
								If SAE->(dbSeek(xFilial("SAE")+cAdmFinanc))

									//Caso seja parcelado 
									dVencimento := dDatabase+(30*z)
									cFormaID	:= cValToChar(nPosPag)
									cForma		:= SAE->AE_TIPO
									cDescAdmFin	:= SAE->AE_COD+" - "+SAE->AE_DESC

								Else

									dVencimento := dDatabase+7
									cFormaID	:= cValToChar(nPosPag)
									cForma		:= "NF"
									cDescAdmFin	:= ""

								EndIf

								RecLock("SL4",.T.)
								SL4->L4_FILIAL	:= xFilial("SL4")
								SL4->L4_NUM		:= SC5->C5_NUM
								SL4->L4_ORIGEM	:= cOrigem
								SL4->L4_DATA	:= dVencimento
								SL4->L4_VALOR	:= Round(jsPagament[nPosPag][#"value"]/jsPagament[nPosPag][#"installments"]/100,TamSx3("L4_VALOR")[2])
								SL4->L4_FORMA	:= cForma
								SL4->L4_FORMAID	:= cFormaID
								SL4->L4_NUMCART	:= cNumCart
								SL4->L4_ADMINIS	:= cDescAdmFin
								SL4->(msUnLock())

							Next

						Next

					EndIf

				Next

				RecLock("SC5",.f.)

				SC5->C5_MENNOTA	:= ::AcertaString(cDescPag)

				If SC5->(FieldPos("C5_YOBS")) > 0
					SC5->C5_YOBS := ::AcertaString(cYObs)
				EndIf

				SC5->(msUnLock())

			Else

				aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+::cNumPed+" na base de dados, favor verificar a tabela SC5!")

			EndIf

		End Transaction

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para criação das formas de pagamento!")

	EndIf

	//caso tenha realizado a atualização do pagamento o sistema atualiza as datas de pagamento
	If lRetorno

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			If !IsBlind()
				RecLock("VT1",.f.)
			EndIf

			VT1->VT1_DATAPG	:= dDataBase
			VT1->VT1_HORAPG	:= Time()

			VT1->VT1_DATAUL	:= dDataBase
			VT1->VT1_HORAUL	:= Time()

			If !IsBlind()
				VT1->(msUnlock())
			EndIf

		EndIf

	EndIf

Return lRetorno

/*/
@Title   : Recupera preco a ser vendido o produto de acordo com o cliente
@Type    : MTH = Metodo
@Name    : BuscaPreco
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BuscaPreco(cProduto,oCliente,nPrecoWEB) Class SchedPedido

	Local cPreco := ""
	Local nPreco := 0
	Local oPreco

	If oCliente:lClienteWEB

		nPreco := nPrecoWEB

	Else

		/*Instancia o Objeto da Classe de Regras de Preco*/
		oPreco:= TpwPreco():New(cProduto,oCliente:cCliente,oCliente:cLoja,"")

		nPreco := oPreco:nPreco

		/*	
		cPreco := "B0_PRV"+Alltrim(oCliente:cTabela)

		If !Empty(cPreco)

		SX3->(dbSetOrder(2))
		If SX3->(dbSeek(cPreco))

		SB0->(dbSetOrder(1))
		If SB0->(dbSeek(xFilial("SB0")+cProduto))

		nPreco := &('SB0->'+cPreco)

		EndIf

		EndIf

		EndIf
		*/

	EndIf

Return nPreco

/*/
@Title   : Construtor do Objeto
@Type    : MTH = Metodo
@Name    : GeraPedido
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BuscaProd(cProduto,lProduto) Class SchedPedido

	Local cAlias 	:= GetNextAlias()
	Local cProdRet	:= ""

	If !lProduto

		BeginSql Alias cAlias

			SELECT	TOP 1 SB1.B1_COD

			FROM	%table:SB1% SB1

			WHERE	SB1.B1_FILIAL	= %xFilial:SB1%
			AND	SB1.B1_YALTER4	= %Exp:cProduto%
			AND SB1.%notdel%

		EndSQL

		(cAlias)->(dbGoTop())
		If (cAlias)->(!Eof()) .and. (cAlias)->(!Bof())
			cProdRet := (cAlias)->B1_COD
		EndIf
		(cAlias)->(dbCloseArea())

	Else

		cProdRet := cProduto

	EndIf

Return cProdRet

/*/
@Title   : Rotina para liberação do pedido para faturamento
@Type    : MTH = Metodo
@Name    : LibPedido
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method LibPedido(cEmpFor, cFilFor) Class SchedPedido

	Local lRetorno := .t.
	Local aErroAux := {}
	Local cAssunto := ''
	Local cMensagem:= ''
	Local aRetME2	:= {}
	Local oRestPedido

	Default cEmpFor	:= ''
	Default cFilFor	:= ''

	//Verifica se já não existe pedido de venda na base
	//pode ser que esteja executando novamente e apenas ter pendencias no faturamento entre grupos
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+::cNumPed))

		VT4->(dbSetOrder(1))
		If VT4->(dbSeek(xFilial("VT4")+::cAPI+::cOrderID+::cSequence/*+cEmpFor+cFilFor*/))

			While VT4->(!eof()) .and. xFilial("VT4")+::cAPI+::cOrderID+::cSequence == VT4->VT4_FILIAL+VT4->VT4_API+VT4->VT4_ORDID+VT4->VT4_SEQUEN

				aErroAux := StartJob("u_LibPedGrupo",GetEnvServer(),.t.,{VT4->VT4_EMPFOR,VT4->VT4_FILFOR,::cApi,::cOrderID,::cSequence,VT4->VT4_NUMPED})

				If aErroAux <> NIL .And. valtype(aErroAux) == 'A'

					If Len(aErroAux) > 0

						lRetorno := .f.

						//inclui mensagens de erro no vetor principal
						::AddErro(aErroAux)

					EndIf

				Else

					lRetorno := .f.

					aAdd(::aMsgErro,"Não foi possivel realizar a liberação do faturamento entre grupos na Empresa\Filial "+VT4->VT4_EMPFOR+"\"+VT4->VT4_FILFOR+"!")

				EndIf

				If lRetorno

					If VT4->VT4_STATUS == '3' .And. ! Empty(VT4->VT4_STATUS)
						cAssunto 	:= 'Mudança de Status'
						cMensagem 	:= 'O pedido "'+AllTrim(::cOrderID)+'" da API "'+AllTrim(::cAPI)+'" seria atualizado para o status 2, porém ele já está no status 3' 
						::EnvEmail(cAssunto, cMensagem)
					EndIf

					If VT4->VT4_STATUS != '3' 
						RecLock("VT4",.f.)
						VT4->VT4_STATUS	:= "2"
						VT4->(msUnLock())
					EndIf

				EndIf

				VT4->(dbSkip())

			EndDo

		Else

			RecLock("SC5",.F.)
			SC5->C5_YSTATUS	:= iif(AllTrim(SC5->C5_YSTATUS)=="B","1",SC5->C5_YSTATUS)
			SC5->C5_YDTLIB  := DATE()
			SC5->C5_YHRLIBP := SubStr(Time(),1,5) 
			SC5->(msUnLock())

		EndIf

		If lRetorno

			//Verifica se esta na empresa integrada com o vtex              
			VT1->(dbSetOrder(1))
			If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

				//verifica qual integração esta configurada para esta empresa
				Do Case

					Case AllTrim(::cAPI) == "VTEX"

					//cria os objetos para mudança do status do pedido na vtex	
					oRestPedido	:= RestPedido():New()
					lRetorno	:= oRestPedido:TrocaStatus(::cOrderID)

					Case AllTrim(::cAPI) == "BSELLER"

					lRetorno	:= .t.

				EndCase

				If !lRetorno

					aAdd(::aMsgErro,"Não foi possivel realizar a mudança de status para Pronto Para Manuseio do pedido na "+AllTrim(Capital(::cAPI))+"!")

				EndIf

			EndIf

		EndIf

	Else

		lRetorno := .f.

		aAdd(::aMsgErro,"Não foi possivel liberar o pedido para faturamento na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")

	EndIf

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))		        

		//realiza nova verificação da modalidade de frete   
		If ::cAPI == 'B2C-RESULT' .and. Empty(VT1->VT1_MODFRE)

			If UPPER('mercadopago') $ ::cNomeAdquir

				oBjMEnvios 	:= MEnviosRastreamento():New()

				oBjMEnvios:cSequen := ::cSequence
				oBjMEnvios:cIdCart := ::cIdCart

				aRetME2 := oBjMEnvios:GetAtuRastro(.F.)

				If !IsBlind()
					RecLock("VT1", .F.)
				EndIf

				VT1->VT1_STATUS := If(aRetME2[1], VT1->VT1_STATUS, "P") 
				VT1->VT1_OBS	:= If(aRetME2[1], VT1->VT1_OBS, aRetME2[2])
				if VT1->(FieldPos('VT1_MODFRE')) > 0
					VT1->VT1_MODFRE	:= oBjMEnvios:cModFrete
				EndIF

				If !IsBlind()
					VT1->(msUnlock())
				EndIf

			EndIf

		End if

	EndIf


Return lRetorno

/*/
@Title   : Metodo para acertar strings com caracters especiais
@Type    : MTH = Metodo
@Name    : CriaSB2
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method CriaSB2(cProduto) Class SchedPedido

	//Acrescenta informações ao sb2
	SB2->(dbSetOrder(1))
	If !SB2->(dbSeek(xFilial("SB2")+cProduto+"01"))
		CriaSB2(cProduto,"01")
	EndIf

Return

/*/
@Title   :
@Type    : MTH = Metodo
@Name    : GrvNumPed
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method GrvNumPed(lPedIntegr, cEmpFor, cFilFor) Class SchedPedido
	Default cEmpFor := ''
	Default cFilFor := ''

	If lPedIntegr

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))

			If !IsBlind()
				RecLock("VT1",.f.)
			EndIf

			VT1->VT1_NUMPED	:= ::cNumPed
			VT1->VT1_FRETE	:= ::nValFrete

			If !IsBlind()
				VT1->(msUnlock())
			EndIf

			//atualiza valor de status da integração
			::cStatus := VT1->VT1_STATUS

		Else

			aAdd(::aMsgErro,"Não foi atualizar o numero do pedido de venda na tabela de Pedidos VTEX!")

		EndIf


	EndIf

Return Len(::aMsgErro)==0

/*/
@Title   : Metodo para criação do registro na tabela de integração
@Type    : MTH = Metodo
@Name    : CriaInteg
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method CriaInteg(cEmpFor, cFilFor, oPedido) Class SchedPedido
	Local cAliasSC5	:= SC5->(GetArea())	 
	Local lPedIntegr := .f.
	Local cCodigo		:= ''
	Local oBjMEnvios 	:= Nil
	Local cModFrete		:= ''

	Private oPedML	:= Nil

	Default cEmpFor	:= ''
	Default cFilFor	:= ''
	Default oPedido	:= Nil

	oPedML := oPedido

	//Verifica se ja existe registro de integração deste pedido
	VT1->(dbSetOrder(1))
	If !VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))

		If ::cAPI == 'B2C-RESULT' .and. oPedido <> nil		
			If Type('oPedML:DadosPgto[1]:cNomeAdquir') == 'C'			
				If UPPER('mercadopago') $ UPPER(oPedML:DadosPgto[1]:cNomeAdquir)
					oBjMEnvios 	:= MEnviosRastreamento():New()

					oBjMEnvios:cSequen := ::cSequence
					oBjMEnvios:cIdCart := ::cIdCart
					oBjMEnvios:GetAtuRastro(.F.)

					cModFrete := oBjMEnvios:cModFrete
				EndIf
			EndIf
		EndIf

		RecLock("VT1", .T.)
		VT1->VT1_FILIAL	:= xFilial("VT1")
		VT1->VT1_API	:= ::cAPI
		VT1->VT1_ORDID	:= ::cOrderID
		VT1->VT1_SEQUEN	:= ::cSequence
		VT1->VT1_DATAIN	:= dDataBase
		VT1->VT1_HORAIN	:= Time()	 
		VT1->VT1_EMPFOR	:= cEmpFor
		VT1->VT1_FILFOR := cFilFor	
		if VT1->(FieldPos('VT1_MODFRE')) > 0
			VT1->VT1_MODFRE	:= cModFrete
		EndIF

		if VT1->(FieldPos('VT1_IDCART')) > 0
			VT1->VT1_IDCART	:= ::cIdCart
		EndIF
		VT1->(msUnlock())

	EndIf

	If VT1->(SimpleLock())

		lPedIntegr 	:= .t.

		//caso tenha integrado pele segunda vez atualiza data e hora e limpa erro
		VT1->VT1_OBS 	:= "Em Processamento - "+dtoc(dDatabase)+" as "+Time()
		VT1->VT1_DATAUL	:= dDataBase
		VT1->VT1_HORAUL	:= Time()

		If Empty(VT1->VT1_EMPFOR)
			VT1->VT1_EMPFOR	:= cEmpFor
			VT1->VT1_FILFOR 	:= cFilFor
		EndIf

		VT1->(SimpleLock())

		//atualiza valor de status da integração
		::cStatus	:= VT1->VT1_STATUS
		::cNumPed	:= VT1->VT1_NUMPED

	EndIf

	If lPedIntegr
		SC5->(dbOrderNickName("YPEDWEB"))
		If SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1])))
			cCodigo := SC5->(C5_CLIENTE + C5_LOJACLI) 

			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial('SA1')+cCodigo))
				::cCNPJCli := SA1->A1_CGC
			EndIf

		EndIf

	EndIf

	RestArea(cAliasSC5)

Return lPedIntegr

/*/
@Title   : Metodo para atualização do status na tabela de integração
@Type    : MTH = Metodo
@Name    : TrocaStatus
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method TrocaStatus(lPedIntegr, cEmpFor, cFilFor) Class SchedPedido

	Default cEmpFor := ''
	Default cFilFor := ''

	If lPedIntegr

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))

			If !IsBlind()
				RecLock("VT1",.f.)
			EndIf

			If VT1->VT1_STATUS != "P"
				VT1->VT1_STATUS	:= Soma1(VT1->VT1_STATUS)
			EndIf

			If !IsBlind()
				VT1->(msUnlock())
			EndIf

			//atualiza valor de status da integração
			::cStatus := VT1->VT1_STATUS

		Else

			lPedIntegr := .f.

		EndIf

	EndIf

Return lPedIntegr

/*/
@Title   : Metodo para definir a administradora do cartão de acordo com integração
@Type    : MTH = Metodo
@Name    : GetAdmFinanc
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method GetAdmFinanc(cIDWEB,nNumParc, cFormaPgto) Class SchedPedido

	Local cAdmFinanc:= Space(TamSx3("AE_COD")[1])
	Local cAlias	:= GetNextAlias()
	Local cAPI		:= ::cAPI
	Local cFiltro	:= '%%'

	default cFormaPgto := ''

	If cFormaPgto == 'BOLETO'
		cFiltro := "% AND SAE.AE_TIPO = 'BOL' %"
	EndIf

	BeginSql Alias cAlias

		SELECT	TOP 1 SAE.AE_COD
		FROM 	
		%Table:SAE% SAE

		JOIN %Table:VT5% VT5	ON	VT5.VT5_FILIAL 	= %xFilial:VT5%
		AND VT5.VT5_ADMFIN	= SAE.AE_COD
		AND VT5.VT5_IDWEB	= %Exp:Padr(cIDWEB,6)%
		AND VT5.VT5_API		= %Exp:cAPI%
		AND VT5.%notdel%
		WHERE 	
		SAE.AE_FILIAL 	= %xFilial:SAE%
		%Exp:cFiltro%
		AND SAE.%notdel%	
		AND %Exp:nNumParc%	BETWEEN SAE.AE_PARCDE AND SAE.AE_PARCATE

	EndSql

	//Percorre pelos registros a afim realizar o faturamento e envio de informações de faturamento
	(cAlias)->(dbGoTop())
	If (cAlias)->(!Eof()) .and. (cAlias)->(!Bof())

		cAdmFinanc := (cAlias)->AE_COD

	EndIf
	(cAlias)->(dbCloseArea())

Return cAdmFinanc

/*/
@Title   : Metodo para excluir a integração entre grupos
@Type    : MTH = Metodo
@Name    : ExcluiInt
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method CancelInt(cEmpFor, cFilFor) Class SchedPedido

	Local lRetorno	:= .f.
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aErroAux	:= {}
	Local aFatGrupo	:= {}
	Local aPedidos  := {}
	Local i

	Local oCliente	:= SchedCliente():New(::cAPI)
	Local lRetorno	:= .f.
	Local cOrigem 	:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])
	Local lTemSC6		:= .F.
	Local lTemVT4		:= .F.

	Private lMsErroAuto 	:= .f.
	Default cEmpFor		:= ''
	Default cFilFor		:= ''

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))

		lRetorno := .t.

		If ! Empty(::cCNPJCli)
			oCliente:VerifCliente(::cCNPJCli)
		EndIf

		SC5->(dbOrderNickName("YPEDWEB"))
		If SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1]) +oCliente:cCliente+oCliente:cLoja /*+cEmpFor+cFilFor*/ ))                         
			::cNumPed 	:= SC5->C5_NUM
			lRetorno	:= .t.

		ElseIf SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1]) +oCliente:cCliente+'02' /*+cEmpFor+cFilFor*/ ))
			::cNumPed 	:= SC5->C5_NUM
			lRetorno	:= .t.

		EndIf

	Else

		//metodo para cadastrar ou atualizar cliente
		lRetorno := oCliente:VerifCliente(::cCNPJCli)

		If lRetorno

			SC5->(dbOrderNickName("YPEDWEB"))
			If SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1])+oCliente:cCliente+oCliente:cLoja/*+cEmpFor+cFilFor*/))				
				::cNumPed := SC5->C5_NUM

			ElseIf SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1]) +oCliente:cCliente+'02' /*+cEmpFor+cFilFor*/ ))
				::cNumPed 	:= SC5->C5_NUM

			Else
				lRetorno := .f.

			EndIf

		EndIf

	EndIf

	If !lRetorno
		::cNumPed := PedidoDel(::cAPI, ::cOrderID, cEmpFor, cFilFor)

		If ! Empty(::cNumPed)
			lRetorno := .T.

		EndIf

	EndIf

	If lRetorno

		//Verifica na tabela de faturamento entre grupos
		VT4->(dbSetOrder(1))
		If VT4->(dbSeek(xFilial("VT4")+::cAPI+::cOrderID+::cSequence))

			While VT4->(!eof()) .and. xFilial("VT4")+::cAPI+::cOrderID+::cSequence == VT4->VT4_FILIAL+VT4->VT4_API+VT4->VT4_ORDID+VT4->VT4_SEQUEN .and. lRetorno

				If VT4->VT4_STATUS <> "3"

					If aScan(aFatGrupo,{|x| x[1] == VT4->VT4_EMPFOR .and. x[2] == VT4->VT4_FILFOR}) == 0

						aAdd(aFatGrupo,{VT4->VT4_EMPFOR,VT4->VT4_FILFOR,::cAPI,::cOrderID,::cSequence,SM0->M0_CGC})

					EndIf

				Else

					aAdd(::aMsgErro,"Existem produtos faturados no Pedido "+AllTrim(::cSequence)+" na Empresa\Filial "+VT4->VT4_EMPFOR+"\"+VT4->VT4_FILFOR+"!")

					lRetorno := .f.

				EndIf

				VT4->(dbSkip())

			EndDo

		Endif

		//Analisa os produtos do faturamento entre grupo
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial('SC6')+::cNumPed))
			lTemSC6 := .T.
			While SC6->(!Eof()) .and. xFilial('SC6')+::cNumPed == SC6->C6_FILIAL+SC6->C6_NUM .and. lRetorno

				If !Empty(SC6->C6_NOTA)

					aAdd(::aMsgErro,"Existem produtos faturados no Pedido "+AllTrim(::cSequence)+" na Empresa\Filial "+cEmpAnt+"\"+cFilAnt+"!")

					lRetorno := .f.

				Else

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

					//Verifica se o item precisa de faturamento entre grupo, caso não precise será analisado se houve problema de liberação de credito e estoque
					VT3->(dbSetOrder(1))
					If VT3->(dbSeek(xFilial("VT3")+SB1->B1_FABRIC)) .and. VT3->VT3_EMPFOR+VT3->VT3_FILFOR <> cEmpAnt+cFilAnt

						If aScan(aFatGrupo,{|x| x[1] == VT3->VT3_EMPFOR .and. x[2] == VT3->VT3_FILFOR}) == 0

							aAdd(aFatGrupo,{VT3->VT3_EMPFOR,VT3->VT3_FILFOR,::cApi,::cOrderID,::cSequence,SM0->M0_CGC})

						EndIf

					EndIf

				EndIf

				SC6->(dbSkip())

			EndDo

		EndIf

		If lRetorno .or. !lTemSC6 //Não SC6, feita exclusão manual do pedido
			lRetorno := .T.

			If lRetorno

				For i :=  1 to Len(aFatGrupo)

					aErroAux :=  StartJob("u_ExcFatGrupo",GetEnvServer(),.t.,aFatGrupo[i])

					If aErroAux <> NIL

						If Len(aErroAux) > 0

							lRetorno := .f.

							//inclui mensagens de erro no vetor principal
							::AddErro(aErroAux)

						EndIf

					Else

						lRetorno := .f.

						aAdd(::aMsgErro,"Não foi possivel realizar a exclusão do pedido "+::cNumPed+" referente ao faturamento entre grupos na Empresa\Filial "+aFatGrupo[i][1]+"\"+aFatGrupo[i][2]+"!")

					EndIf

				Next

			EndIf

			//Apaga toda a amarração do pedido		
			If lRetorno

				VT4->(dbSetOrder(1))
				If VT4->(dbSeek(xFilial("VT4")+::cAPI+::cOrderID+::cSequence))

					While VT4->(!eof()) .and. xFilial("VT4")+::cAPI+::cOrderID+::cSequence == VT4->VT4_FILIAL+VT4->VT4_API+VT4->VT4_ORDID+VT4->VT4_SEQUEN .and. lRetorno

						RecLock("VT4",.F.)
						VT4->(dbDelete())
						VT4->(msUnLock())

						VT4->(dbSkip())

					EndDo

				EndIf

			EndIf

			VT4->(dbSkip())

		EndIf

	EndIf

	//Realiza a exclusão de todos os pedidos que consta o pedido web
	//Uma vez que estava somente excluindo o primeiro pedido e não o segundo
	//no TIMS (Pneu e Peça)

	SC5->(dbOrderNickName("YPEDWEB"))
	SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1])+oCliente:cCliente/*+cEmpFor+cFilFor*/))

	While SC5->(!EOF()) .AND. SC5->C5_YPEDWEB == Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1]) .AND. SC5->C5_YAPI == Padr(::cAPI,TamSx3("C5_YAPI")[1]) .AND. SC5->C5_CLIENTE == oCliente:cCliente

		AADD(aPedidos,SC5->C5_NUM)

		SC5->(dbSkip())
	End if


	If lRetorno

		For i :=1 to len(aPedidos)

			SC5->(dbSetOrder(1))
			SC5->(dbSeek(xFilial('SC5')+aPedidos[i]))

			//Realiza estorno de liberação de estoque e credito      
			SC9->(dbSetOrder(1))
			If SC9->(dbSeek(xFilial('SC9')+SC5->C5_NUM))

				While SC9->(!Eof()) .and. xFilial('SC9')+ SC5->C5_NUM == SC9->C9_FILIAL+SC9->C9_PEDIDO

					If Empty(SC9->C9_NFISCAL)

						SC6->(dbSetOrder(1))
						SC6->(dbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))

						Begin Transaction
							SC9->(a460Estorna())
						End Transaction

					EndIf

					SC9->(dbSkip())

				EndDo

			EndIf

			//Realiza a exclusão do pedido de venda
			//SC5->(dbSetOrder(1))
			//If SC5->(dbSeek(xFilial('SC5')+::cNumPed))

			::ElimiResid()


			/*
			//Monta cabeçalho do pedidos de venda
			aadd(aCabec,{"C5_TIPO" 		,SC5->C5_TIPO		,Nil})
			aadd(aCabec,{"C5_NUM"		,SC5->C5_NUM		,Nil})
			aadd(aCabec,{"C5_CLIENTE"	,SC5->C5_CLIENTE	,Nil})
			aadd(aCabec,{"C5_LOJACLI"	,SC5->C5_LOJACLI	,Nil})
			aadd(aCabec,{"C5_LOJAENT"	,SC5->C5_LOJAENT	,Nil})

			//Gravacao do PEDIDO DE VENDA			
			MsExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,5)

			If lMsErroAuto

			lRetorno := .f.

			aAdd(::aMsgErro,MostraErro(::cPathLog,"SC5"+AllTrim(::cNumPed)+".LOG"))

			DisarmTransaction()

			Else
			*/
			//apaga informações de pagamento anteriores
			SL4->(dbSetOrder(1))
			If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))

				While SL4->(!Eof()) .and. xFilial("SL4")+SC5->C5_NUM+cOrigem == SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM

					RecLock("SL4",.f.)
					SL4->(dbDelete())
					SL4->(msUnLock())

					SL4->(dbSkip())

				EndDo

			EndIf

		Next

		//EndIf

	EndIf

Return lRetorno

/*/
@Title   : Rotina para eliminação de residuos
@Type    : MTH = Metodo
@Name    : ElimiResid
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method ElimiResid() Class SchedPedido

	Local cNumPed 	:= ''
	Local lIntTMK	:= .t.

	//Elimina residuo do pedido posicionado
	Begin Transaction

		cNumPed := SC5->C5_NUM
		SC6->(dbSetOrder(1))

		If SC6->(dbSeek(xFilial("SC6")+cNumPed))

			While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
				if SC6->C6_QTDEMP < 0
					RecLock('SC6', .F.)
					SC6->C6_QTDEMP := 0
					SC6->(MsUnLock())
				EndIf

				If SC6->C6_QTDVEN - SC6->C6_QTDENT > 0 .and. Empty(SC6->C6_SERVIC)
					MaResDoFat(,.T.,.F.)
				EndIf

				//Verifica se o pedido foi gerado pelo Televendas.	
				lIntTMK := IIF(lIntTMK,!Empty(SC6->C6_PEDCLI) .And. "TMK" $ upper(SC6->C6_PEDCLI),lIntTMK)

				SC6->(dbSkip())

			EndDo

			SC6->(MaLiberOk({SC5->C5_NUM},.T.))

			//Se o pedido for eliminado por completo, será feito o cancelamento do atendimento do Televendas.
			If lIntTMK .And. SC5->C5_LIBEROK == "S" .And. "X" $ SC5->C5_NOTA
				TkAtuTlv(SC5->C5_NUM,4)
			EndIf

			//Já está posicionado
			RecLock('SC5', .F.)
			SC5->C5_YSTATUS := '8' //Excluido
			SC5->(MsUnLock())

			If ExistBlock("M410VRES")
				ExecBlock("M410VRES",.F.,.F.)
			EndIf

		EndIf

	End Transaction

Return

/*/
@Title   : Integração dos Pedidos com Status Pendentes de Pagamento para o ambiente BSeller
@Type    : MTH = Metodo
@Name    : BSPedPagPend
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BSPedPagPend() Class SchedPedido

	Local oBSPedido	:= BSPedido():New()
	Local i

	//Defini o status para recuperar os pedidos
	oBSPedido:cStatus := "AWAITING_PAYMENT"

	//Atualiza a lista de pedidos no atributo
	oBSPedido:GetAllPedidos()

	//Percorre por todos os pedidos recuperados
	For i := Len(oBSPedido:aPedidos) to 1 Step -1

		::cOrderID 	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_ORDID")[1])
		::cSequence	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_SEQUEN")[1])
		::cStatPed	:= oBSPedido:cStatus

		::CriaStatPed()

	Next

Return

/*/
@Title   : Integração dos Pedidos com Status Pagamento Aprovado para o ambiente BSeller
@Type    : MTH = Metodo
@Name    : BSPedPagAprov
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BSPedPagAprov() Class SchedPedido

	Local oBSPedido	:= BSPedido():New()
	Local i

	//Defini o status para recuperar os pedidos
	oBSPedido:cStatus := "PAYMENT_APPROVED"

	//Atualiza a lista de pedidos no atributo
	oBSPedido:GetAllPedidos()

	//Percorre por todos os pedidos recuperados
	For i := Len(oBSPedido:aPedidos) to 1 Step -1

		::cOrderID 	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_ORDID")[1])
		::cSequence	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_SEQUEN")[1])
		::cStatPed	:= oBSPedido:cStatus

		::CriaStatPed()

	Next

Return

/*/
@Title   : Atualiza condição de pagamento dos pedidos pagos
@Type    : MTH = Metodo
@Name    : CriaStatPed
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method CriaStatPed() Class SchedPedido

	Local lPedIntegr:= .F.
	Local lPassou	:= .f.

	//Caso esteje com o status parado, sai da rotina	
	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
		If VT1->VT1_STATUS == 'P'
			Return
		EndIf

	EndIf

	lPedIntegr:= ::CriaInteg()

	If lPedIntegr

		//Caso status em branco necessario integrar pedido	
		If Empty(::cStatus)

			lPedIntegr 	:= ::BSIntPedido()
			lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
			lPedIntegr	:= ::GrvNumPed(lPedIntegr)
			lPassou		:= .t.

		EndIf

		If ::cStatPed == "PAYMENT_APPROVED"

			//Caso o pedido esteja integrado e com o pagamento aprovado, sera feito a mudança de status do pedido para Iniciar Manuseio		
			If ::cStatus == "1"

				lPedIntegr 	:= ::BSAtuCondPag()
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status na vtex
			If ::cStatus == "2"
				lPedIntegr 	:= AlteraPrazoEnt(Self, ::cNumPed, ::cOrderID, ::cAPI)
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status na vtex
			If ::cStatus == "3"

				lPedIntegr 	:= ::LibPedido()
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

			EndIf

			//rotina para pausar os pedidos do mercado livre, provisorio
			If ::cStatus == "4"	 .and. lPassou

				If	"LOJASAMERICANAS-"	$ AllTrim(::cOrderID) .OR. ;
				"SUBMARINO-"		$ AllTrim(::cOrderID) .OR. ;
				"SHOPTIME-"			$ AllTrim(::cOrderID) .OR. ;
				"EX-"				$ AllTrim(::cOrderID) .OR. ;
				"ML-"				$ AllTrim(::cOrderID) .OR. ;
				"B2W-"				$ AllTrim(::cOrderID)

					VT1->(dbSetOrder(1))
					If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

						RecLock("VT1",.f.)
						VT1->VT1_OBS		:= 'Pausado automaticamente '+AllTrim(::cOrderID)
						VT1->VT1_STATAN	:= VT1->VT1_STATUS
						VT1->VT1_STATUS	:= "P"
						VT1->(msUnlock())

					EndIf

				EndIf

			EndIf

		EndIf

		//Caso tenha mensagem de erro grava na tabela de integração
		::GrvMsgErro()

	EndIf

Return

/*/
@Title   : Atualiza condição de pagamento dos pedidos pagos
@Type    : MTH = Metodo
@Name    : CriaPedAny
@Author  : Henrique
@Date    : 15/12/2015
/*/
Method CriaPedAny(lNotificar) Class SchedPedido

	Local lPedIntegr	:= .F.
	Local lPassou		:= .F.
	Local oPedido		:= AnyPedid():New()

	Default lNotificar := .T.

	//Caso esteje com o status parado, sai da rotina	
	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
		If VT1->VT1_STATUS == 'P'
			Return
		EndIf

	EndIf

	lPedIntegr	:= ::CriaInteg()

	If lPedIntegr

		//Caso status em branco necessario integrar pedido	
		If Empty(::cStatus)
			lPedIntegr 	:= ::AnyIntPedido()
			lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
			lPedIntegr		:= ::GrvNumPed(lPedIntegr)
			lPassou		:= .T.
		EndIf

		oPedido:cRotina := 'SchedPedido - CriaPedAny'
		oPedido:GetPedido(::cOrderID)
		::ANYAddTrans(oPedido)

		If ::cStatPed $ "PAID_WAITING_SHIP/INVOICED" //Status

			//Caso o pedido esteja integrado e com o pagamento aprovado, sera feito a mudança de status do pedido para Iniciar Manuseio		
			If ::cStatus == "1"

				lPedIntegr 	:= ::AnyAtuCondPag()
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

				If lNotificar
					oPedido:Notificar(::cToken)
				EndIf
				::cToken := ''
			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status na 
			If ::cStatus == "2"
				lPedIntegr 	:= AlteraPrazoEnt(Self, ::cNumPed, ::cOrderID, ::cAPI)
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

				If lNotificar
					oPedido:Notificar(::cToken)
				EndIf

				::cToken := ''
			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status na 
			If ::cStatus == "3"

				lPedIntegr 	:= ::LibPedido()
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

				If lNotificar
					oPedido:Notificar(::cToken)
				EndIf

				::cToken := ''
			EndIf

			//rotina para pausar os pedidos do mercado livre, provisorio
			If ::cStatus == "4"	 .and. lPassou

				If	"LOJASAMERICANAS-"	$ AllTrim(::cOrderID) .OR. ;
				"SUBMARINO-"			$ AllTrim(::cOrderID) .OR. ;
				"SHOPTIME-"			$ AllTrim(::cOrderID) .OR. ;
				"EX-"					$ AllTrim(::cOrderID) .OR. ;
				"ML-"					$ AllTrim(::cOrderID) .OR. ;
				"B2W-"					$ AllTrim(::cOrderID)

					VT1->(dbSetOrder(1))
					If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

						RecLock("VT1",.f.)
						VT1->VT1_OBS		:= 'Pausado automaticamente '+AllTrim(::cOrderID)
						VT1->VT1_STATAN	:= VT1->VT1_STATUS
						VT1->VT1_STATUS	:= "P"
						VT1->(msUnlock())

						If lNotificar
							oPedido:Notificar(::cToken)
						EndIf
					EndIf

				EndIf

			ElseIf !(::cStatus $ '1/2/3')
				If lNotificar
					oPedido:Notificar(::cToken)
				EndIf

			EndIf
			//Se estiver pendente mais se já estiver no protheus é notificado para sair do Feeds
		ElseIf ::cStatPed $ "PENDING"
			If lNotificar
				oPedido:Notificar(::cToken)
			EndIf
		EndIf

		//Caso tenha mensagem de erro grava na tabela de integração
		::GrvMsgErro()

	EndIf

	If ValType(oPedido) == 'O'
		FreeObj(oPedido)
	EndIf
Return

/*/
@Title   : Adiciona a transportador caso não exista no pedido de vendas
@Type    : MTH = Metodo
@Name    : ANYAddTrans
@Author  : Henrique
@Date    : 16/05/2016
/*/
Method ANYAddTrans(oPedido) Class SchedPedido
	Local aAreaVT1 	:= VT1->(GetArea())
	Local aAreaSC5 	:= SC5->(GetArea())
	Local cTransp		:= ''
	Local cPedido		:= ''

	Default oPedido := nil
	If Empty(::cOrderID) .OR. oPedido == NIL
		Return
	EndIf

	If Len(oPedido:aFormaEnvio) > 0
		cTransp	:= ::GetTransp(oPedido:aFormaEnvio[1]:cTipo)
	Endif

	If Empty(cTransp)
		Return
	EndIf

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
		cPedido := VT1->VT1_NUMPED
	EndIf

	If Empty(cPedido)
		Return
	EndIf

	DbSelectArea('SC5')
	DbSetOrder(1)
	If SC5->(DbSeek(xFilial('SC5')+cPedido))
		If Empty(SC5->C5_TRANSP)
			RecLock('SC5',.F.)
			SC5->C5_TRANSP := cTransp
			SC5->(MsUnLock())
		EndIf
	EndIf

	VT1->(RestArea(aAreaVT1))
	SC5->(RestArea(aAreaSC5))

Return

/*/
@Title   : Monta informações atraves de XML para pedido de venda BSELLER x Protheus
@Type    : MTH = Metodo
@Name    : IntPedido
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BSIntPedido() Class SchedPedido

	Local oBSPedido		:= BSPedido():New()
	Local oPedido		:= oBSPedido:GetPedido(AllTrim(::cOrderID))
	Local oCliente 		:= SchedCliente():New(::cAPI)
	Local lRetorno		:= .f.
	Local aItens		:= {}
	Local nTotProd		:= 0
	Local cCodProd		:= ""

	Local oBSProduto	:= BSProduto():New()

	Local xEndCliente
	Local xCliente
	Local xItens
	Local i

	Private lMsErroAuto := .f.

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If oPedido <> NIL

		xCliente	:= oPedido:_ORDER:_CUSTOMER
		xItens		:= oPedido:_ORDER:_CART:_ORDERLINES
		xEndCliente	:= oPedido:_ORDER:_ADDRESSES

		::aProdutos		:= {}
		::cTransp		:= ::GetTransp(oPedido:_ORDER:_DELIVERIES:_DELIVERY:_DELIVERYTYPE:TEXT)
		::cTipoFrete	:= "C"
		::nValFrete		:= Round(Val(oPedido:_ORDER:_DELIVERIES:_DELIVERY:_PRICE:TEXT),TamSx3("C5_FRETE")[2])
		::dDtEntrega	:= dDataBase+10

		If XmlChildEx(oPedido:_ORDER:_DELIVERIES:_DELIVERY,"_ESTIMATE") != Nil

			::dDtEntrega	:= SubStr(oPedido:_ORDER:_DELIVERIES:_DELIVERY:_ESTIMATE:TEXT,1,10)
			::dDtEntrega	:= stod(Replace(::dDtEntrega,"-",""))

		EndIf

		//metodo para cadastrar ou atualizar cliente
		lRetorno := oCliente:IncluiCliente(xCliente,xEndCliente)

		//Atualiza tabela de integração
		If lRetorno

			//caso seja apenas um itens cria-se um vetor para compatibilizar o fonte    
			If ValType(xItens:_ORDERLINE) == "A"

				aItens := xItens:_ORDERLINE

			Else

				AAdd(aItens,xItens:_ORDERLINE)

			EndIf

			//Recupera os produtos e quantidades para solicitar estoque em outra loja caso estoque seja compartilhados
			For i := 1 to Len(aItens)

				//define os valores para busca do produto
				oBSProduto:cCodigo	:= AllTrim(aItens[i]:_SKUID:TEXT)
				oBSProduto:cIdWeb	:= ""

				//recupera o codigo externo do produto
				oBSProduto:GetProdCodExt()

				//de acordo com o codigo externo busca o produto no cadastro SB1
				cCodProd := ::GetProduto(oBSProduto:cIdWeb,::cAPI)

				aAdd(::aProdutos,{	StrZero(i,TamSX3("C6_ITEM")[1]),;
				Padr(cCodProd,TamSx3("B1_COD")[1]),;
				Val(aItens[i]:_QUANTITY:TEXT),;
				Val(aItens[i]:_SALEPRICE:TEXT),;
				.t.,;
				::dDtEntrega})

				nTotProd += Val(aItens[i]:_TOTALAMOUNT:TEXT)

			Next

			//CALCULA PERCENTUAL DE DESCONTO
			If Val(oPedido:_ORDER:_CART:_TOTALDISCOUNTAMOUNT:TEXT) > 0

				::nPercDesc	:= Round((Val(oPedido:_ORDER:_CART:_TOTALDISCOUNTAMOUNT:TEXT)/nTotProd)*100,TamSx3("C5_DESC1")[2])

			Else

				::nPercDesc	:= 0

			EndIf

			lRetorno := ::GeraPedido(oCliente)

		Else

			//inclui mensagens de erro no vetor principal
			::AddErro(oCliente:aMsgErro)

		EndIf

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para integração inicial!")

	EndIf

Return lRetorno

/*/
@Title   : Atualiza condição de pagamento dos pedidos pagos
@Type    : MTH = Metodo
@Name    : BSAtuCondPag
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BSAtuCondPag() Class SchedPedido

	Local oBSPedido		:= BSPedido():New()
	Local oPedido		:= oBSPedido:GetPedido(AllTrim(::cOrderID))
	Local oMLPagamento
	Local lRetorno		:= .f.
	Local cOrigem 		:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])

	Local aCondPag		:= {}
	Local i
	Local z
	Local x
	Local nQtdParcelas	:= 0
	Local cPagamento	:= ""
	Local nValor		:= 0

	Local cFormaID		:= ""
	Local cNumCart		:= ""
	Local cForma		:= ""
	Local cAdmFinanc	:= Space(TamSx3("AE_COD")[1])
	Local cDescAdmFin	:= ""
	Local cTid			:= ""
	Local cNSU			:= ""
	Local cDescPag		:= ""
	Local cYObs			:= ""
	Local dVencimento
	Local aProps		:= {}

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If oPedido <> NIL

		Begin Transaction

			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(xFilial("SC5")+::cNumPed))

				//apaga informações de pagamento anteriores
				SL4->(dbSetOrder(1))
				If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))

					While SL4->(!Eof()) .and. xFilial("SL4")+SC5->C5_NUM+cOrigem == SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM

						RecLock("SL4",.f.)
						SL4->(dbDelete())
						SL4->(msUnLock())

						SL4->(dbSkip())

					EndDo

				EndIf

				//verifica se existe a tag PAYMENTS
				If XmlChildEx(oPedido:_ORDER,"_PAYMENTS") != Nil

					If XmlChildEx(oPedido:_ORDER:_PAYMENTS,"_PAYMENT") != Nil

						//caso seja apenas um itens cria-se um vetor para compatibilizar o fonte    
						If ValType(oPedido:_ORDER:_PAYMENTS:_PAYMENT) == "A"

							aCondPag := oPedido:_ORDER:_PAYMENTS:_PAYMENT

						Else

							AAdd(aCondPag,oPedido:_ORDER:_PAYMENTS:_PAYMENT)

						EndIf

					EndIf

					//caso venha com a tag simples PAYMENT
				ElseIf XmlChildEx(oPedido:_ORDER,"_PAYMENT") != Nil

					AAdd(aCondPag,oPedido:_ORDER:_PAYMENT)

				EndIf

				//percorre por todas as condições de pagamento			
				For i := 1 to Len(aCondPag)

					lRetorno	:= .t.
					aProps		:= {}
					cPagamento	:= ""
					cNumCart	:= ""
					cTid		:= ""
					cNSU		:= ""

					If AllTrim(aCondPag[i]:_TYPE:TEXT) == "GATEWAY"

						If XmlChildEx(aCondPag[i],"_PAYMENTPROPS") != Nil

							If XmlChildEx(aCondPag[i]:_PAYMENTPROPS,"_PROP") != Nil

								//caso seja apenas um itens cria-se um vetor para compatibilizar o fonte    
								If ValType(aCondPag[i]:_PAYMENTPROPS:_PROP) == "A"

									aProps := aCondPag[i]:_PAYMENTPROPS:_PROP

								Else

									AAdd(aProps,aCondPag[i]:_PAYMENTPROPS:_PROP)

								EndIf

								//Percorre por todas as propriedades do cartão
								For x := 1 to Len(aProps)

									Do Case

										Case AllTrim(Upper(aProps[x]:_KEY:TEXT)) == "ACQUIRERMESSAGE"

										cPagamento := AllTrim(Upper(aProps[x]:_VALUE:TEXT))

										Case AllTrim(Upper(aProps[x]:_KEY:TEXT)) == "ACQUIRERAUTHORIZATIONCODE"

										cNumCart := AllTrim(Upper(aProps[x]:_VALUE:TEXT))

										Case AllTrim(Upper(aProps[x]:_KEY:TEXT)) == "TRANSACTIONIDENTIFIER"

										cTid := AllTrim(Upper(aProps[x]:_VALUE:TEXT))

										Case AllTrim(Upper(aProps[x]:_KEY:TEXT)) == "UNIQUESEQUENTIALNUMBER"

										cNSU := AllTrim(Upper(aProps[x]:_VALUE:TEXT))

									EndCase

								Next

							EndIf

						EndIf

						If XmlChildEx(aCondPag[i],"_CREDITCARD") != Nil

							//Realiza tratamento exclusivo para o cartão AMEX
							If Upper(AllTrim(aCondPag[i]:_CREDITCARD:_BRAND:TEXT)) == "AMEX"

								cPagamento := Upper(AllTrim(aCondPag[i]:_CREDITCARD:_BRAND:TEXT))

							EndIf

							If Empty(cNumCart)

								If XmlChildEx(aCondPag[i],"_INCOME") != Nil

									cNumCart:= AllTrim(Upper(aCondPag[i]:_INCOME:_AUTHORIZATIONCODE:TEXT))

								Else

									cNumCart:= ""

								EndIf

							EndIf

							If Empty(cPagamento)

								cPagamento := Upper(AllTrim(aCondPag[i]:_GATEWAY:TEXT))

							EndIf

							If Empty(cTid)

								If XmlChildEx(aCondPag[i],"_TRANSACTIONID") != Nil

									cTid := aCondPag[i]:_TRANSACTIONID:TEXT

								EndIf

							EndIf

							If Empty(cNSU)

								If XmlChildEx(aCondPag[i],"_SEQUENCIALNUMBER") != Nil

									cNSU := aCondPag[i]:_SEQUENCIALNUMBER:TEXT

								EndIf

							EndIf

							nQtdParcelas	:= Val(aCondPag[i]:_CREDITCARD:_PARCELS:TEXT)
							cAdmFinanc 	:= ::GetAdmFinanc(cPagamento,nQtdParcelas)

							cYObs	+= iif(Empty(cYOBS),"",", ")
							cYObs	+= iif(Empty(cYOBS),""," - ")+"NSU: "+cNSU
							cYObs	+= iif(Empty(cYOBS),""," - ")+"TID: "+cTid
							cYObs	+= iif(Empty(cYOBS),""," - ")+"AUTORIZACAO: "+cNumCart

						Else

							cTid			:= ""
							cNSU			:= ""
							cNumCart		:= ""
							nQtdParcelas	:= 1
							cPagamento		:= "BOLETO"
							cAdmFinanc		:= Space(TamSx3("AE_COD")[1])

						EndIf

						nValor		:= Val(aCondPag[i]:_AMOUNT:TEXT)

						cDescPag	+= iif(Empty(cDescPag),"",", ")
						cDescPag	+= Upper(	cPagamento+;
						" R$ "+AllTrim(Transform(nValor,PesqPict("SE1","E1_VALOR")))+;
						iif(nQtdParcelas>1," - PARCELAS: "+cValtoChar(nQtdParcelas),""))

					ElseIf AllTrim(aCondPag[i]:_TYPE:TEXT) == "MARKETPLACE"

						cPagamento	:= Upper(AllTrim(SubStr(::cOrderID,1,At("-",::cOrderID)-1)))
						nQtdParcelas:= 1
						cAdmFinanc 	:= ::GetAdmFinanc(cPagamento,nQtdParcelas)
						cNumCart	:= Upper(AllTrim(SubStr(::cOrderID,At("-",::cOrderID)+1,Len(::cOrderID))))
						cTid		:= ""
						cNSU		:= ""
						lRetorno	:= .t.
						nValor 		:= Val(aCondPag[i]:_AMOUNT:TEXT)

						cDescPag	+= iif(Empty(cDescPag),"",", ")
						cDescPag	+= Upper(	cPagamento+;
						" R$ "+AllTrim(Transform(nValor,PesqPict("SE1","E1_VALOR")))+;
						iif(nQtdParcelas>1," - PARCELAS: "+cValtoChar(nQtdParcelas),""))



					Else

						nQtdParcelas:= 1
						cAdmFinanc	:= Space(TamSX3("AE_COD")[1])
						cNumCart	:= ""
						cTid		:= ""
						cNSU		:= ""
						lRetorno	:= .t.
						nValor		:= Val(oPedido:_ORDER:_CART:_TOTALAMOUNT:TEXT)

					EndIf

					If nValor > 0

						For z := 1 to nQtdParcelas

							SAE->(dbSetOrder(1))
							If SAE->(dbSeek(xFilial("SAE")+cAdmFinanc))

								//Caso seja parcelado 
								dVencimento := dDatabase+(30*z)
								cFormaID	:= cValToChar(z)
								cForma		:= SAE->AE_TIPO
								cDescAdmFin	:= SAE->AE_COD+" - "+SAE->AE_DESC

							Else

								dVencimento := dDatabase+7
								cFormaID	:= cValToChar(z)
								cForma		:= "NF"
								cDescAdmFin	:= ""

							EndIf

							RecLock("SL4",.T.)
							SL4->L4_FILIAL	:= xFilial("SL4")
							SL4->L4_NUM		:= SC5->C5_NUM
							SL4->L4_ORIGEM	:= cOrigem
							SL4->L4_DATA	:= dVencimento
							SL4->L4_VALOR	:= Round(nValor/nQtdParcelas,TamSx3("L4_VALOR")[2])
							SL4->L4_FORMA	:= cForma
							SL4->L4_FORMAID	:= cFormaID
							SL4->L4_NUMCART	:= cNumCart
							SL4->L4_ADMINIS	:= cDescAdmFin
							SL4->(msUnLock())

						Next

					EndIf

				Next

				RecLock("SC5",.f.)

				SC5->C5_MENNOTA	:= cDescPag

				If SC5->(FieldPos("C5_YOBS")) > 0
					SC5->C5_YOBS := cYObs
				EndIf

				SC5->(msUnLock())

			Else

				aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+::cNumPed+" na base de dados, favor verificar a tabela SC5!")

			EndIf

		End Transaction

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para criação das formas de pagamento!")

	EndIf

	//caso tenha realizado a atualização do pagamento o sistema atualiza as datas de pagamento
	If lRetorno

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			If !IsBlind()
				RecLock("VT1",.f.)
			EndIf

			VT1->VT1_DATAPG	:= dDataBase
			VT1->VT1_HORAPG	:= Time()

			VT1->VT1_DATAUL	:= dDataBase
			VT1->VT1_HORAUL	:= Time()

			If !IsBlind()
				VT1->(msUnlock())
			EndIf

		EndIf

	EndIf

Return lRetorno

/*/
@Title   : Integração dos Pedidos com pagamento cancelado para o ambiente BSeller
@Type    : MTH = Metodo
@Name    : BSPedPagNeg
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BSPedPagNeg() Class SchedPedido

	Local oBSPedido	:= BSPedido():New()

	Local i

	//Defini o status para recuperar os pedidos
	oBSPedido:cStatus := "PAYMENT_DECLINED"

	//Atualiza a lista de pedidos no atributo
	oBSPedido:GetAllPedidos()

	//Percorre por todos os pedidos recuperados
	For i := Len(oBSPedido:aPedidos) to 1 Step -1

		::cOrderID 	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_ORDID")[1])
		::cSequence	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_SEQUEN")[1])

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			::CriaInteg()

			If ::CancelInt()

				If oBSPedido:CancPedido(::cOrderID)

					RecLock("VT1",.F.)
					VT1->VT1_STATAN	:= ''
					VT1->VT1_STATUS	:= "E"
					VT1->(msUnLock())

				EndIf

			EndIf

			//Caso tenha mensagem de erro grava na tabela de integração
			::GrvMsgErro()

		EndIf

	Next

Return

/*/
@Title   : Integração dos Pedidos cancelados para o ambiente BSeller
@Type    : MTH = Metodo
@Name    : BSPedCanc
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method BSPedCanc() Class SchedPedido

	Local oBSPedido	:= BSPedido():New()

	Local i

	//Defini o status para recuperar os pedidos
	oBSPedido:cStatus := "CANCELLED"

	//Atualiza a lista de pedidos no atributo
	oBSPedido:GetAllPedidos()

	//Percorre por todos os pedidos recuperados
	For i := Len(oBSPedido:aPedidos) to 1 Step -1

		::cOrderID 	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_ORDID")[1])
		::cSequence	:= Padr(Upper(oBSPedido:aPedidos[i]),TamSx3("VT1_SEQUEN")[1])

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI)) .and. VT1->VT1_STATUS <> "C"

			::CriaInteg()

			If ::CancelInt()

				RecLock("VT1",.F.)
				VT1->VT1_STATAN	:= ''
				VT1->VT1_STATUS	:= "E"
				//VT1->(dbDelete())
				VT1->(msUnLock())

			Else

				//Caso tenha mensagem de erro grava na tabela de integração
				::GrvMsgErro()

				VT1->(dbSetOrder(1))
				VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

				RecLock("VT1",.F.)
				VT1->VT1_STATUS	:= "C"
				VT1->VT1_STATAN	:= ""
				VT1->(msUnLock())

			EndIf


		EndIf

	Next

Return

/*/
@Title   : Metodo para buscar o codigo do produto de acordo com o ID WEB
@Type    : MTH = Metodo
@Name    : GetProduto
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method GetProduto(cProdIDWEB,cAPI) Class SchedPedido

	Local cAlias 	:= GetNextAlias()
	Local cProdRet	:= ""

	BeginSql Alias cAlias

		SELECT	TOP 1 SB1.B1_COD

		FROM	%table:SB1% SB1

		INNER JOIN %Table:VT9% VT9 ON	VT9.VT9_FILIAL	= %xFilial:VT9%
		AND	VT9.VT9_PRODUT	= SB1.B1_COD
		AND	VT9.VT9_API		= %Exp:cAPI%
		AND	VT9.VT9_IDWEB	= %Exp:cProdIDWEB%
		AND VT9.%notdel%

		WHERE	SB1.B1_FILIAL	= %xFilial:SB1%
		AND SB1.%notdel%

		ORDER BY SB1.B1_COD

	EndSQL

	(cAlias)->(dbGoTop())
	If (cAlias)->(!Eof()) .and. (cAlias)->(!Bof())
		cProdRet := (cAlias)->B1_COD
	EndIf
	(cAlias)->(dbCloseArea())

Return cProdRet

/*/
@Title   : Integração dos Pedidos com Status Pagamento Aprovado para o ambiente AnyMarket
@Type    : MTH = Metodo
@Name    : ANYPedPagAprov
@Author  : Henrique
@Date    : 16/12/2015
/*/
Method AnyPedidos() Class SchedPedido
	Local oAnyPedido		:= Nil
	Local oPedido			:= Nil
	Local nI				:= 0
	Local nJ				:= 0

	oAnyPedido 	:= AnyPedido():New()
	oPedido		:= AnyPedId():New()
	oPedido:cRotina := 'SchedPedido - AnyPedidos'

	//=========================================================================================
	//O While é necessário porque o Feed do pedido só traz os 10 primeiros itens
	//Depois de gravar o pedidos no protheus é necessário notificar a AnyMarket que estes itens 
	//já foram idos para a próxima leitura não trazer os mesmo pedidos
	//=========================================================================================
	//Foi retirado o While e adicionado For
	//=========================================================================================

	oAnyPedido:GetAllPedidos()

	If Len(oAnyPedido:aPedidos) != 0

		For nI := Len(oAnyPedido:aPedidos) to 1 STEP -1
			::cOrderID 	:= Padr(Upper(cValToChar(oAnyPedido:aPedidos[nI, 1])),TamSx3("VT1_ORDID")[1])

			//É necessário para fazer a notificar a AnyMarket que este pedido já foi lido
			::cToken		:= oAnyPedido:aPedidos[nI, 2]

			If oPedido:GetPedido(AllTrim(::cOrderID ))
				::cStatPed		:= AllTrim(oPedido:cStatus)
				::cSequence	:= Padr(Upper(oPedido:cMPlaceId),TamSx3("VT1_SEQUEN")[1])

				If ::cStatPed $ "PAID_WAITING_SHIP"
					Self:ANYPedPagAprov()		//PAID_WAITING_SHIP: Pedido pago e aguardando envio
				ElseIf ::cStatPed == "PENDING"
					Self:ANYPedPagPend()			//PENDING: Pedido pendente
				ElseIf ::cStatPed == "CANCELED"
					Self:ANYPedCanc() 			//CANCELED: Pedido cancelado
				Else //AllTrim(::cStatPed) $ "PAID_WAITING_DELIVERY/CONCLUDED")
					VT1->(DbSetOrder(1))

					If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
						oPedido:Notificar(::cToken)
					EndIf
				EndIf

				//oSchedPedido:AnyPedFat() 		//INVOICED: Pedido faturado
				//oSchedPedido:AnyPedEnv() 		//PAID_WAITING_DELIVERY: Pedido enviado				
				//oSchedPedido:AnyPedConc() 	//CONCLUDED: Pedido entregue					

			Else
				//==========================================================================
				//Caso o pedido esteja na lista do feeds e o pedido não existe no Anymarket
				//ou o pedido esteja parado (status P), o sistema irá notificar para o pedido 
				//não ser listado novamente do Feeds 
				//==========================================================================

				oPedido:cIdWeb := AllTrim(::cOrderID )
				If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
					oPedido:Notificar(::cToken)
				EndIf
			EndIf

		Next

	EndIf

	FreeObj(oAnyPedido)
	FreeObj(oPedido)
Return


/*/
@Title   : Integração dos Pedidos com Status Pagamento Aprovado para o ambiente AnyMarket
@Type    : MTH = Metodo
@Name    : ANYPedPagAprov
@Author  : Henrique
@Date    : 16/12/2015
/*/
Method AnyNovosPedidos() Class SchedPedido
	Local oAnyPedido		:= Nil
	Local oPedido			:= Nil
	Local nI				:= 0
	Local nJ				:= 0

	oAnyPedido 	:= AnyPedido():New()
	oPedido		:= AnyPedId():New()
	oPedido:cRotina := 'SchedPedido - AnyPedidos'

	//=========================================================================================
	//O While é necessário porque o Feed do pedido só traz os 10 primeiros itens
	//Depois de gravar o pedidos no protheus é necessário notificar a AnyMarket que estes itens 
	//já foram idos para a próxima leitura não trazer os mesmo pedidos
	//=========================================================================================
	//Foi retirado o While e adicionado For
	//=========================================================================================
	oAnyPedido:GetAllPedidos()

	If Len(oAnyPedido:aPedidos) != 0

		For nI := 1 to Len(oAnyPedido:aPedidos)

			::cOrderID 	:= Padr(Upper(cValToChar(oAnyPedido:aPedidos[nI, 1])),TamSx3("VT1_ORDID")[1])

			If POSICIONE('VT1', 1, xFilial('VT1')+::cOrderID+'ANYMARKET', 'Found()')
				Loop
			EndIf

			//É necessário para fazer a notificar a AnyMarket que este pedido já foi lido
			::cToken		:= oAnyPedido:aPedidos[nI, 2]

			If oPedido:GetPedido(AllTrim(::cOrderID ))
				::cStatPed		:= AllTrim(oPedido:cStatus)
				::cSequence	:= Padr(Upper(oPedido:cMPlaceId),TamSx3("VT1_SEQUEN")[1])

				If ::cStatPed $ "PAID_WAITING_SHIP"
					Self:ANYPedPagAprov()		//PAID_WAITING_SHIP: Pedido pago e aguardando envio
				ElseIf ::cStatPed == "PENDING"
					Self:ANYPedPagPend()			//PENDING: Pedido pendente
				ElseIf ::cStatPed == "CANCELED"
					Self:ANYPedCanc() 			//CANCELED: Pedido cancelado
				Else //AllTrim(::cStatPed) $ "PAID_WAITING_DELIVERY/CONCLUDED")
					If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
						oPedido:Notificar(::cToken)
					EndIf
				EndIf

				//oSchedPedido:AnyPedFat() 		//INVOICED: Pedido faturado
				//oSchedPedido:AnyPedEnv() 		//PAID_WAITING_DELIVERY: Pedido enviado				
				//oSchedPedido:AnyPedConc() 	//CONCLUDED: Pedido entregue					

			Else
				//==========================================================================
				//Caso o pedido esteja na lista do feeds e o pedido não existe no Anymarket
				//ou o pedido esteja parado (status P), o sistema irá notificar para o pedido 
				//não ser listado novamente do Feeds 
				//==========================================================================
				oPedido:cIdWeb := AllTrim(::cOrderID )
				If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
					oPedido:Notificar(::cToken)
				EndIf
			EndIf

		Next

	EndIf

	FreeObj(oAnyPedido)
	FreeObj(oPedido)
Return

/*/
@Title   : Integração dos Pedidos com Status Pagamento Aprovado para o ambiente AnyMarket
Analisa se existem pedidos que já estão no Protheus porém ainda não estão com o
Status acima do 3
@Type    : MTH = Metodo
@Name    : AnyPedBabse
@Author  : Henrique
@Date    : 31/03/2016
/*/
Method AnyPedBase() Class SchedPedido
	Local oAnyPedido	:= Nil
	Local oPedido		:= Nil
	Local cAlias 		:= GetNextAlias()
	Local cAPI			:= ::cAPI

	BeginSql Alias cAlias
		SELECT
		VT1_ORDID
		FROM
		%Table:VT1% VT1
		WHERE
		VT1.VT1_FILIAL = %xFilial:VT1%
		AND VT1.%notdel%
		AND	VT1.VT1_API = %Exp:cAPI%
		AND VT1.VT1_STATUS IN (' ', '1', '2', '3')			

	EndSQL

	oAnyPedido 	:= AnyPedido():New()
	oPedido		:= AnyPedId():New()
	oPedido:cRotina := 'SchedPedido - AnyPedBase'

	(cAlias)->(dbGoTop())
	While !(cAlias)->(Eof())
		::cOrderID 	:= (cAlias)->VT1_ORDID

		If oPedido:GetPedido(AllTrim(::cOrderID ))
			::cStatPed		:= AllTrim(oPedido:cStatus)
			::cSequence	:= Padr(Upper(oPedido:cMPlaceId),TamSx3("VT1_SEQUEN")[1])

			If ::cStatPed $ "PAID_WAITING_SHIP" //Pedido pago e aguardando envio
				Self:ANYPedPagAprov(.F.)
			ElseIf ::cStatPed == "PENDING" //Pedido pendente
				Self:ANYPedPagPend(.F.)
			ElseIf ::cStatPed == "CANCELED"
				Self:ANYPedCanc(.F.)
			EndIf

		EndIf
		(cAlias)->(DbSkip())

	EndDo

	FreeObj(oAnyPedido)
	FreeObj(oPedido)

	(cAlias)->(dbCloseArea())
Return


/*/
@Title   : Integração dos Pedidos com Status Pagamento Aprovado para o ambiente AnyMarket
@Type    : MTH = Metodo
@Name    : ANYPedPagAprov
@Author  : Henrique
@Date    : 25/11/2015
/*/
Method ANYPedPagAprov(lNotificar) Class SchedPedido
	Default lNotificar := .T.

	::CriaPedAny(lNotificar)

Return

/*/
@Title   : Integração dos Pedidos com Status Pendentes de Pagamento para o ambiente AnyMarket
@Type    : MTH = Metodo
@Name    : AnyPedPagPend
@Author  : Henrique
@Date    : 25/11/2015
/*/
Method ANYPedPagPend(lNotificar) Class SchedPedido
	Default lNotificar := .T.

	::CriaPedAny(lNotificar)

Return

/*/
@Title   : Integração dos Pedidos cancelados para o ambiente AnyMarket
@Type    : MTH = Metodo
@Name    : BSPedCanc
@Author  : Henrique
@Date    : 25/11/2015
/*/
Method ANYPedCanc(lNotificar) Class SchedPedido
	Local oPedido		:= nil

	Default lNotificar := .T.

	If ::cStatPed == "CANCELED"
		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI)) .and. VT1->VT1_STATUS <> "C"

			If ::CriaInteg()

				If ::CancelInt()
					RecLock("VT1",.F.)
					//VT1->(dbDelete())
					VT1->VT1_STATAN	:= ''
					VT1->VT1_STATUS	:= "E"
					VT1->(msUnLock())

				Else

					//Caso tenha mensagem de erro grava na tabela de integração
					::GrvMsgErro()

					VT1->(dbSetOrder(1))
					VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

					RecLock("VT1",.F.)
					VT1->VT1_STATUS	:= "C"
					VT1->VT1_STATAN	:= ""
					VT1->(msUnLock())
				EndIf

			Else
				If lNotificar
					lNotificar := .F.
				EndIf

			EndIf

		EndIf

		If lNotificar
			oPedido		:= AnyPedId():New()
			oPedido:cRotina := 'SchedPedido - ANYPedCanc'

			If oPedido:GetPedido(AllTrim(::cOrderID ))
				oPedido:Notificar(::cToken)
			EndIf

			FreeObj(oPedido)
		EndIf
	EndIf
Return

/*/
@Title   : Integração dos Pedidos com pagamento cancelado para o ambiente AnyMarket
@Type    : MTH = Metodo
@Name    : ANYPedPagNeg
@Author  : Henrique
@Date    : 25/11/2015
/*/
Method ANYPedPagNeg() Class SchedPedido

	/*	Local oAnyPedido	:= AnyPedido():New()	
	Local i

	//Defini o status para recuperar os pedidos
	//oAnyPedido:cStatus := "PAYMENT_DECLINED"

	//Atualiza a lista de pedidos no atributo
	oAnyPedido:GetAllPedidos()

	//Percorre por todos os pedidos recuperados
	While .T.
	oAnyPedido:GetAllPedidos()

	If Len(oAnyPedido:aPedidos) == 0
	Exit
	EndIf

	//Percorre por todos os pedidos recuperados
	For i := Len(oAnyPedido:aPedidos) to 1 Step -1

	::cOrderID 	:= Padr(Upper(cValToChar(oAnyPedido:aPedidos[i, 1])),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(cValToChar(oAnyPedido:aPedidos[i, 1])),TamSx3("VT1_SEQUEN")[1])	
	::cToken		:= oAnyPedido:aPedidos[i, 2] //É necessário para fazer a notificar a AnyMarket que este pedido já foi lido

	VT1->(dbSetOrder(1))     	
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

	::CriaInteg()

	If ::CancelInt()

	If oAnyPedido:CancPedido(::cOrderID)

	RecLock("VT1",.F.)
	VT1->(dbDelete())
	VT1->(msUnLock())

	EndIf

	EndIf

	//Caso tenha mensagem de erro grava na tabela de integração
	::GrvMsgErro()

	EndIf
	Next
	EndDo
	*/
Return

/*/
@Title   : Monta informações atraves de XML para pedido de venda BSELLER x Protheus
@Type    : MTH = Metodo
@Name    : IntPedido
@Author  : Ihorran Milholi
@Date    : 21/08/2014
/*/
Method AnyIntPedido() Class SchedPedido

	Local oPedido			:= AnyPedId():New()
	Local oCliente 		:= SchedCliente():New(::cAPI)
	Local lRetorno		:= .F.
	Local aItens			:= {}
	Local nTotProd		:= 0
	Local cVendedor		:= ''
	Local nQdtVenda		:= 0
	Local nPrecoVenda		:= 0
	Local xEndCliente
	Local xCliente
	Local xItens
	Local i				:= 0
	Local lAchou 			:= .F.
	Local cProduto 		:= ''
	Local nLoteDist		:= 0

	Private lMsErroAuto := .F.

	oPedido:cRotina := 'SchedPedido - AnyIntPedido'

	::cStatPed		:= ''
	oPedido:GetPedido(::cOrderID)

	//Tratamento de Erro caso haja falha na integração
	If oPedido <> NIL

		xItens			:= oPedido:aItems
		xItens			:= AnaliseKit(xItens, ::cAPI)
		oPedido:aItems:= xItens

		xCliente		:= oPedido
		xEndCliente	:= oPedido

		::aProdutos	:= {}
		::cTransp		:= ''
		::cTipoFrete	:= "C"
		::nValFrete	:= Round(oPedido:nVlrFrete,TamSx3("C5_FRETE")[2])

		cVendedor := ObtemVend(oPedido:cMarketPlace)

		If Len(oPedido:aFormaEnvio) > 0
			::cTransp		:= ::GetTransp(oPedido:aFormaEnvio[1]:cTipo)
		Endif

		::cStatPed		:= oPedido:cStatus

		//Se o pedido já estiver criado, sai da rotina
		//Coloquei este código porque duas instancias estavam criando o pedido causa de 
		//simutâneamento, gerando duplicidade de pedidos de vendas
		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
			If AllTrim(VT1->VT1_STATUS) != ''
				Return .T.
			EndIf

		EndIf

		lRetorno := oCliente:IncluiCliente(xCliente,xEndCliente)

		//Atualiza tabela de integração
		If lRetorno .and. Len(xItens) > 0

			aItens := xItens

			//Recupera os produtos e quantidades para solicitar estoque em outra loja caso estoque seja compartilhados
			For i := 1 to Len(aItens)

				If ::dDtEntrega == nil .Or. ::dDtEntrega == CTOD('')
					::dDtEntrega	:= dDataBase+10
				EndIf

				lAchou 	:= .F.
				cProduto 	:= ''
				DbSelectArea('VT9')
				VT9->(DbSetOrder(1))
				If Dbseek(xFilial('VT9')+ padr(::cAPI, TAMSX3('VT9_API')[1], ' ')+ aItens[i]:cProdID) .and. AllTrim(VT9->VT9_IDWEB) == AllTrim(aItens[i]:cProdID)
					cProduto := VT9->VT9_PRODUT
					lAchou := .T.
				EndIf

				If lAchou
					If SB1->(dbSeek(xFilial('SB1')+cProduto))
						nLoteDist := SB1->B1_YLMDIST
						If SB1->B1_TIPO == 'KT'
							nLoteDist := 1
							cProduto := aItens[i]:cProduto
						EndIf
					EndIf
				EndIf

				If lAchou
					DbSelectArea('SB1')
					DbSetOrder(1)

					nQdtVenda := aItens[i]:nQuantidade
					nPrecoVenda := aItens[i]:nValorUnit

					If SB1->(DbSeek(xFilial('SB1')+cProduto))

						If nLoteDist > 1
							nQdtVenda *= nLoteDist
							nPrecoVenda /= nLoteDist
						EndIf

					EndIf

					aAdd(::aProdutos,{StrZero(i,TamSX3("C6_ITEM")[1]),;
					cProduto,;
					nQdtVenda,;
					nPrecoVenda,;
					.t.,;
					::dDtEntrega })
					nTotProd += aItens[i]:nTotal

				Else
					aAdd(::aMsgErro,'Não foi encontrado o produto "'+aItens[i]:cProduto+'" no cadastro de Produto X Web!')
					lRetorno := .F.
				EndIf
			Next

			//CALCULA PERCENTUAL DE DESCONTO     
			If oPedido:nDesconto > 0
				::nPercDesc	:= Round(oPedido:nDesconto/nTotProd*100,TamSx3("C5_DESC1")[2])
			Else
				::nPercDesc	:= 0
			EndIf

			lRetorno := ::GeraPedido(oCliente, cVendedor)
			If lRetorno
				oPedido:Notificar(::cToken)
			EndIf

		Else
			//inclui mensagens de erro no vetor principal
			::AddErro(oCliente:aMsgErro)

		EndIf

	Else
		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para integração inicial!")

	EndIf

Return lRetorno


/*/
@Title   : Atualiza condição de pagamento dos pedidos pagos
@Type    : MTH = Metodo
@Name    : ANYAtuCondPag
@Author  : Henrique
@Date    : 15/12/2015
/*/
Method AnyAtuCondPag() Class SchedPedido
	Local oPedido			:= AnyPedId():New()
	Local lRetorno		:= .f.
	Local cOrigem 		:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])
	Local i
	Local z
	Local nQtdParcelas	:= 0
	Local cPagamento		:= ""
	Local nValor			:= 0
	Local cFormaID		:= ""
	Local cNumCart		:= ""
	Local cForma			:= ""
	Local cAdmFinanc		:= Space(TamSx3("AE_COD")[1])
	Local cDescAdmFin		:= ""
	Local cTid				:= ""
	Local cNSU				:= ""
	Local cDescPag		:= ""
	Local cYObs			:= ""
	Local dVencimento
	Local aProps			:= {}
	Local oCliente 		:= SchedCliente():New(::cAPI)
	Local nI			:= 0

	Private lMsErroAuto := .F.

	oPedido:cRotina := 'SchedPedido - AnyAtuCondPag'
	oPedido:GetPedido(::cOrderID)

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If oPedido <> NIL

		Begin Transaction

			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(xFilial("SC5")+::cNumPed))

				//apaga informações de pagamento anteriores
				SL4->(dbSetOrder(1))
				If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))

					While SL4->(!Eof()) .and. xFilial("SL4")+SC5->C5_NUM+cOrigem == SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM

						RecLock("SL4",.f.)
						SL4->(dbDelete())
						SL4->(msUnLock())

						SL4->(dbSkip())

					EndDo

				EndIf

				//percorre por todas as condições de pagamento	
				//For i := 1 to Len(oPedido:aFormaPtgo)

				lRetorno	:= .T.
				aProps		:= {}
				cPagamento	:= ""
				cNumCart	:= ""
				cTid		:= ""
				cNSU		:= ""

				//cPagamento		:= Upper(oPedido:aFormaPtgo[i]:cForma)
				cPagamento		:= oPedido:cMarketPlace
				nQtdParcelas	:= 1
				cAdmFinanc 	:= ::GetAdmFinanc(cPagamento,nQtdParcelas)
				cTid			:= ""
				cNSU			:= ""
				lRetorno		:= .t.
				nValor 		:= oPedido:nTotal//oPedido:aFormaPtgo[i]:nValor
				cNumCart		:= oPedido:cMPlaceId

				cDescPag		:= Upper(" R$ "+AllTrim(Transform(nValor,PesqPict("SE1","E1_VALOR"))))

				If nValor > 0

					For z := 1 to nQtdParcelas

						SAE->(dbSetOrder(1))
						If SAE->(dbSeek(xFilial("SAE")+cAdmFinanc))

							//Caso seja parcelado 
							dVencimento	:= dDatabase+(30*z)
							cFormaID		:= cValToChar(z)
							cForma			:= SAE->AE_TIPO
							cDescAdmFin	:= SAE->AE_COD+" - "+SAE->AE_DESC

						Else

							dVencimento 	:= dDatabase+7
							cFormaID		:= cValToChar(z)
							cForma			:= "NF"
							cDescAdmFin	:= ""

						EndIf

						RecLock("SL4",.T.)
						SL4->L4_FILIAL	:= xFilial("SL4")
						SL4->L4_NUM		:= SC5->C5_NUM
						SL4->L4_ORIGEM	:= cOrigem
						SL4->L4_DATA		:= dVencimento
						SL4->L4_VALOR		:= Round(nValor/nQtdParcelas,TamSx3("L4_VALOR")[2])
						SL4->L4_FORMA		:= cForma
						SL4->L4_FORMAID	:= cFormaID
						SL4->L4_NUMCART	:= cNumCart
						SL4->L4_ADMINIS	:= cDescAdmFin
						SL4->(msUnLock())

					Next

				EndIf

				//Next

				RecLock("SC5",.f.)

				SC5->C5_MENNOTA	:= cDescPag

				If SC5->(FieldPos("C5_YOBS")) > 0
					SC5->C5_YOBS := cYObs
				EndIf

				SC5->(msUnLock())

			Else

				aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+::cNumPed+" na base de dados, favor verificar a tabela SC5!")

			EndIf

		End Transaction

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para criação das formas de pagamento!")

	EndIf

	//caso tenha realizado a atualização do pagamento o sistema atualiza as datas de pagamento
	If lRetorno

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			If !IsBlind()
				RecLock("VT1",.f.)
			EndIf

			VT1->VT1_DATAPG	:= oPedido:dDataPtgo // dDataBase
			VT1->VT1_HORAPG	:= oPedido:cHoraPtgo //Time()

			VT1->VT1_DATAUL	:= dDataBase
			VT1->VT1_HORAUL	:= Time()

			If !IsBlind()
				VT1->(msUnlock())
			EndIf
		Else
			lRetorno := .F.

		EndIf

	EndIf

	If lRetorno
		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))	
			lRetorno := VT1->VT1_DATAPG <> ctod('')
		EndIf

	EndIf

Return lRetorno

/*/
@Title   : Obtem o código do vendedor para vendas na AnyMarket
@Type    : MTH = Metodo
@Name    : ObtemVend
@Author  : Henrique
@Date    : 02/05/2016
/*/
Static Function ObtemVend(cMarketPlace)
	Local cCodVend:= ''
	Local aArea	:= GetArea()

	If ! Empty(cMarketPlace)
		DbSelectArea('SA3')
		DbSetOrder(2) //Nome vendedor

		If SA3->(DbSeek(xFilial('SA3')+cMarketPlace))
			cCodVend := SA3->A3_COD
		ElseIf	SA3->(DbSeek(xFilial('SA3')+Replace(cMarketPlace, '_', ' ')))
			cCodVend := SA3->A3_COD
		EndIf
	EndIf

	//==============================================================================
	//Necessário colocar o código abaixo, poís na ExcAuto do cadastrado de cliente
	//está utilizando a tabela SA3 sem setar o indice 1, gerando erro ao validar o
	//código do vendedor
	//==============================================================================
	DbSelectArea('SA3')
	DbSetOrder(1) //Código

	RestArea(aArea)
Return	cCodVend

/*/
@Title   : Integração dos Pedidos com Status Pagamento Aprovado para o ambiente CiaShop
@Type    : MTH = Metodo
@Name    : ANYPedPagAprov
@Author  : Henrique
@Date    : 23/05/2016
/*/
Method CiaPedidos() Class SchedPedido
	Local oCiaPedido 		:= CiaPedidos():New()
	Local nI				:= 0

	//Tratamentos dos pedidos aprovados
	oCiaPedido:GetAllAprovado()
	For nI := 1 to Len(oCiaPedido:aPedidos)
		::CriaPedCia(oCiaPedido:aPedidos[nI])
	Next
	oCiaPedido:aPedidos := {}

	//Tratamentos dos pedidos pendente de pagamento
	//Confirmed (Transação realizada, mas sem a confirmação de pagamento).
	oCiaPedido:GetAllConfirmado()
	For nI := 1 to Len(oCiaPedido:aPedidos)
		::CriaPedCia(oCiaPedido:aPedidos[nI])
	Next
	oCiaPedido:aPedidos := {}

	//Tratamentos dos pedidos cancelados
	//Cancelled (cancelado)
	oCiaPedido:GetAllCancelado()
	For nI := 1 to Len(oCiaPedido:aPedidos)
		::CiaPedCanc(oCiaPedido:aPedidos[nI])
	Next
	oCiaPedido:aPedidos := {}

	FreeObj(oCiaPedido)

Return

/*/
@Title   : Cria os pedido
@Type    : MTH = Metodo
@Name    : CriaPedCia
@Author  : Henrique
@Date    : 23/05/2016
/*/
Method CriaPedCia(oPedido) Class SchedPedido

	Local lPedIntegr	:= .F.
	Local lPassou		:= .F.

	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_SEQUEN")[1])

	::cStatPed		:= oPedido:cStatus

	//Caso esteje com o status parado, sai da rotina	
	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
		If VT1->VT1_STATUS == 'P'
			Return
		EndIf

	EndIf

	lPedIntegr := ::CriaInteg()

	If lPedIntegr

		//Caso status em branco necessario integrar pedido	
		If Empty(::cStatus)
			lPedIntegr 	:= ::CiaIntPedido(oPedido)
			lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
			lPedIntegr		:= ::GrvNumPed(lPedIntegr)
			lPassou		:= .T.

		EndIf

		If Upper(::cStatPed) $ Upper("PaymentApproved") //Status

			//Caso o pedido esteja integrado e com o pagamento aprovado, sera feito a mudança de status do pedido para Iniciar Manuseio		
			If ::cStatus == "1"
				lPedIntegr 	:= ::CiaAtuCondPag(oPedido)
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .T.
			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status
			If ::cStatus == "2"
				lPedIntegr		:= AlteraPrazoEnt(Self, ::cNumPed, ::cOrderID, ::cAPI)

				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .T.

			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status
			If ::cStatus == "3"
				lPedIntegr 	:= ::LibPedido()
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

			EndIf

			//Se estiver pendente mais se já estiver no protheus é notificado para sair do Feeds
		ElseIf ::cStatPed $ "PENDING"

		EndIf

		//Caso tenha mensagem de erro grava na tabela de integração
		::GrvMsgErro()

	EndIf

Return

/*/
@Title   : Monta informações atraves de XML para pedido de venda CiaShop x Protheus
@Type    : MTH = Metodo
@Name    : CiaIntPedido
@Author  : Henrique
@Date    : 23/05/2016
/*/
Method CiaIntPedido(oPedido) Class SchedPedido

	Local oCliente 		:= SchedCliente():New(::cAPI)
	Local lRetorno		:= .F.
	Local aItens			:= {}
	Local nTotProd		:= 0
	Local cVendedor		:= ''

	Local xEndCliente
	Local xCliente
	Local xItens
	Local i				:= 0
	Local nQdtVenda		:= 0
	Local nPrecoVenda		:= 0
	Local lAchou 			:= .F.
	Local cProduto 		:= ''
	Local nLoteDist		:= 0

	Default oPedido		:= Nil

	Private lMsErroAuto 	:= .F.

	If oPedido == Nil
		Return .F.
	EndIf

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If oPedido <> NIL

		xItens			:= oPedido:ItensPedido
		xItens			:= AnaliseKit(xItens, ::cAPI)
		oPedido:ItensPedido := xItens

		xCliente		:= oPedido
		xEndCliente	:= oPedido

		::aProdutos	:= {}
		::cTransp		:= ''
		::cTipoFrete	:= "C"
		::nValFrete	:= Round(oPedido:DadosEntrega:nFrete,TamSx3("C5_FRETE")[2])

		If oPedido:DadosEntrega:nDiasMax > 0
			::dDtEntrega	:= dDataBase+oPedido:DadosEntrega:nDiasMax
		Else
			::dDtEntrega	:= dDataBase+10
		EndIf

		cVendedor := ObtemVend('CIASHOP')

		If Len(oPedido:DadosEntrega:cNome) > 0
			::cTransp		:= ::GetTransp(oPedido:DadosEntrega:cNome)
		Endif

		::cStatPed		:= oPedido:cStatus

		//metodo para cadastrar ou atualizar cliente
		lRetorno := oCliente:IncluiCliente(xCliente,xEndCliente)

		//Atualiza tabela de integração
		If lRetorno .and. Len(xItens) > 0

			aItens := xItens
			nResto := 0
			//Recupera os produtos e quantidades para solicitar estoque em outra loja caso estoque seja compartilhados
			For i := 1 to Len(aItens)

				If ::dDtEntrega == nil .Or. ::dDtEntrega == CTOD('')

					::dDtEntrega	:= dDataBase+10
				EndIf

				lAchou 	:= .F.
				cProduto 	:= ''
				DbSelectArea('VT9')
				VT9->(DbSetOrder(1))
				If Dbseek(xFilial('VT9')+ padr(::cAPI, TAMSX3('VT9_API')[1], ' ')+ aItens[i]:cIdProduto) .and. AllTrim(VT9->VT9_IDWEB) == AllTrim(aItens[i]:cIdProduto)
					cProduto := VT9->VT9_PRODUT
					lAchou := .T.
				EndIf

				If lAchou
					If SB1->(dbSeek(xFilial('SB1')+cProduto))
						nLoteDist := SB1->B1_YLMDIST
						If SB1->B1_TIPO == 'KT'
							nLoteDist := 1
							cProduto := aItens[i]:cCodProduto
						EndIf
					EndIf
				EndIf

				If lAchou
					DbSelectArea('SB1')
					DbSetOrder(1)

					nQdtVenda := aItens[i]:nQuantidade
					nPrecoVenda := aItens[i]:nPrecoAjuste

					If SB1->(DbSeek(xFilial('SB1')+cProduto))

						If nLoteDist > 1
							nQdtVenda *= nLoteDist
							nPrecoVenda /= nLoteDist
						EndIf

					EndIf

					aAdd(::aProdutos,{StrZero(i,TamSX3("C6_ITEM")[1]),;
					cProduto,;
					nQdtVenda,; //Valor já com o desconto
					nPrecoVenda,;
					.t.,;
					::dDtEntrega })
					nTotProd += aItens[i]:nQuantidade*aItens[i]:nPrecoAjuste

				Else
					aAdd(::aMsgErro,'Não foi encontrado o produto "'+aItens[i]:cCodProduto+'" no cadastro de Produto X Web!')
					lRetorno := .F.
				EndIf
			Next

			//CALCULA PERCENTUAL DE DESCONTO     
			If oPedido:Desconto:nValor > 0
				::nPercDesc	:= Round(oPedido:Desconto:nValor/nTotProd*100,TamSx3("C5_DESC1")[2])
			Else
				::nPercDesc	:= 0
			EndIf

			lRetorno := ::GeraPedido(oCliente, cVendedor)

		Else
			//inclui mensagens de erro no vetor principal
			::AddErro(oCliente:aMsgErro)
			lRetorno := .F.

		EndIf

	Else
		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para integração inicial!")

	EndIf

Return lRetorno

/*/
@Title   : Analisa se na lista de produtos possui Kit e caso possua, adicionado no array os produtos reais
@Type    : MTH = Metodo
@Name    : AnaliseKit
@Author  : Henrique
@Date    : 04/11/2016
/*/
Static Function AnaliseKit(xItens, cApi)
	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local cAlias		:= ''
	Local nI			:= 0
	Local aItens		:= {}
	Local nValorAtual	:= 0
	Local nQdeItem	:= 0
	Local nPrecoFinal	:= 0
	Local nI			:= 0
	Local cPrdProtheus:= ''
	Local cProduto	:= ''
	Local nPrecoVenda	:= 0
	Local nQdtVenda	:= 0
	Local nValor		:= 0
	Local nResto		:= 0
	Local oPedido := nil

	If cApi == 'B2C-RESULT'
		cApi := Padr('RESULTATE', TamSx3("VT9_API")[1])
	EndIf

	If !Upper(AllTrim(cApi)) $ 'CIASHOP/ANYMARKET/RESULTATE/B2C-RESULT'
		Return xItens
	EndIf

	cAlias		:= GetNextAlias()

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))

	DbSelectArea('VT9')
	VT9->(DbSetOrder(1))

	For nI := 1 To Len(xItens)

		cPrdProtheus := ''
		If Upper(AllTrim(cApi)) == 'CIASHOP'

			If VT9->(DbSeek(xFilial('VT9')+cApi+xItens[nI]:cIdProduto))
				cPrdProtheus := VT9->VT9_PRODUT
			EndIf
		ElseIf Upper(AllTrim(cApi)) == 'ANYMARKET'

			If VT9->(DbSeek(xFilial('VT9')+cApi+xItens[nI]:cProdID))
				cPrdProtheus := VT9->VT9_PRODUT
			EndIf
			//		ElseIf Upper(AllTrim(cApi)) == 'CANALPECAS'
			//		
			//			If VT9->(DbSeek(xFilial('VT9')+cApi+xItens[nI]:cProduto))
			//				cPrdProtheus := VT9->VT9_PRODUT
			//			EndIf
		ElseIf Upper(AllTrim(cApi)) $ ('RESULTATE/B2C-RESULT')
			If VT9->(DbSeek(xFilial('VT9')+ cApi + xItens[nI]:cProdutoWeb))
				cPrdProtheus := VT9->VT9_PRODUT
			EndIf

		EndIf

		If ! Empty(cPrdProtheus) .AND. SB1->(DbSeek(xFilial('SB1') + cPrdProtheus ))
			If SB1->B1_TIPO == 'KT'

				If Upper(AllTrim(cApi)) == 'CIASHOP'
					cProduto		:= xItens[nI]:cIdProduto
					nQdtVenda 		:= xItens[nI]:nQuantidade
					nPrecoVenda 	:= xItens[nI]:nPrecoAjuste

				ElseIf Upper(AllTrim(cApi)) == 'ANYMARKET'
					cProduto		:= xItens[nI]:cProdID
					nQdtVenda 		:= xItens[nI]:nQuantidade
					nPrecoVenda 	:= xItens[nI]:nValorUnit

					//				ElseIf Upper(AllTrim(cApi)) == 'CANALPECAS'
					//					cProduto		:= xItens[nI]:cProduto
					//					nQdtVenda 		:= xItens[nI]:nQuantidade
					//					nPrecoVenda 	:= xItens[nI]:nValor

				ElseIf Upper(AllTrim(cApi)) $ ('RESULTATE/B2C-RESULT')
					cProduto		:= xItens[nI]:cCodSku
					nQdtVenda 		:= xItens[nI]:nQde
					nPrecoVenda 	:= xItens[nI]:nVlrUnit
				EndIf

				//Obtem os produtos do KIT
				If Select(cAlias) > 0
					(cAlias)->(DbCloseArea())
					cAlias		:= GetNextAlias()
				EndIf

				BeginSql Alias cAlias
					SELECT
					MEU.MEU_CODIGO, MEU.MEU_DESCNT, MEV.MEV_PRODUT, MEV.MEV_QTD, MEV.MEV_DESCNT
					, B1_FABRIC, B1_COD
					, VT9_IDWEB
					FROM
					%Table:MEU% MEU
					JOIN %Table:MEV% MEV ON MEV.MEV_FILIAL = %xFilial:MEV% AND MEV.%NotDel% AND MEV.MEV_CODKIT = MEU.MEU_CODIGO
					JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1% AND SB1.%NotDel% AND SB1.B1_COD = MEV.MEV_PRODUT
					JOIN %Table:VT9% VT9 ON VT9.VT9_FILIAL = %xFilial:VT9% AND VT9.%NotDel% AND VT9.VT9_PRODUT = MEU.MEU_CODIGO
					AND VT9_API = %Exp:cApi%
					WHERE
					MEU.MEU_FILIAL = %xFilial:MEU%
					AND MEU.%NotDel%
					AND MEU.MEU_CODIGO = %Exp:cPrdProtheus%
				EndSql

				If (cAlias)->(Eof())
					aAdd(aItens, xItens[nI])

				Else
					nValorAtual := 0
					nQdeItem	:= 0
					//Soma os valores atuais dos produtos do KIT para rateio de valores
					(cAlias)->(DbGoTop())
					While !(cAlias)->(Eof())
						nValorAtual += U_PrvEcommerce((cAlias)->MEV_PRODUT) * (cAlias)->MEV_QTD * nQdtVenda
						nQdeItem ++

						(cAlias)->(DbSkip())
					EndDo

					(cAlias)->(DbGoTop())

					If Upper(AllTrim(cApi)) == 'CIASHOP'
						If nQdeItem == 1 //Caso o KIT possua apenas um produto

							aAdd(aItens, xItens[nI])

							aItens[Len(aItens)]:cIdProduto		:= (cAlias)->VT9_IDWEB
							aItens[Len(aItens)]:cCodProduto		:= (cAlias)->MEV_PRODUT
							aItens[Len(aItens)]:nQuantidade		*= (cAlias)->MEV_QTD
							aItens[Len(aItens)]:nPrecoAjuste	/= (cAlias)->MEV_QTD

						Else // Caso o produto seja um KIT e este KIT possuir mais de um produto

							//nPerc := 100-(nValorAtual*100/nPrecoVenda)
							nPerc := nPrecoVenda/nValorAtual
							nValor := 0
							While !(cAlias)->(Eof())
								oPedido := CiaItens():New()
								nValor := U_PrvEcommerce((cAlias)->MEV_PRODUT) //* (cAlias)->MEV_QTD * nQdtVenda

								oPedido:cIdWeb			:= xItens[nI]:cIdWeb
								oPedido:dCriacao			:= xItens[nI]:dCriacao
								oPedido:dUtimAlter		:= xItens[nI]:dUtimAlter
								oPedido:cIdSku			:= xItens[nI]:cIdSku
								oPedido:LisaPromocoes	:= xItens[nI]:LisaPromocoes
								oPedido:cMsgSemEstoque	:= xItens[nI]:cMsgSemEstoque
								oPedido:nValorBonus		:= xItens[nI]:nValorBonus
								oPedido:Embalagem			:= xItens[nI]:Embalagem
								oPedido:CartaoPresente	:= xItens[nI]:CartaoPresente
								oPedido:cTipoProduto		:= xItens[nI]:cTipoProduto
								oPedido:Sku				:= xItens[nI]:Sku
								oPedido:Produto			:= xItens[nI]:Produto
								oPedido:Modulos			:= xItens[nI]:Modulos
								oPedido:Kits				:= xItens[nI]:Kits

								oPedido:cIdProduto		:= (cAlias)->VT9_IDWEB
								oPedido:cCodProduto		:= (cAlias)->MEV_PRODUT
								oPedido:nQuantidade		:= xItens[nI]:nQuantidade * (cAlias)->MEV_QTD

								nFator						:= xItens[nI]:nPreco / xItens[nI]:nPrecoAjuste

								//Rateia o preço entre os itens
								//nPrecoFinal 			:= oPedido:nPrecoAjuste / (cAlias)->MEV_QTD
								nPrecoFinal 				:= nValor * nPerc
								oPedido:nPrecoAjuste 	:= round(nPrecoFinal, 2)

								//nResto						:= ((nPrecoFinal * nFator) - round(nPrecoFinal * nFator, 2)
								oPedido:nPreco			:= round(nPrecoFinal * nFator, 2)
								nResto 					+= oPedido:nPrecoAjuste * oPedido:nQuantidade

								aAdd(aItens, oPedido)

								(cAlias)->(DbSkip())
							EndDo

							//							If nResto <> nPrecoVenda
							//								oPedido:nPrecoAjuste += (nPrecoVenda - nResto) / oPedido:nQuantidade
							//							EndIf
							//						
						EndIf

					ElseIf Upper(AllTrim(cApi)) == 'ANYMARKET'
						If nQdeItem == 1 //Caso o KIT possua apenas um produto

							aAdd(aItens, xItens[nI])

							aItens[Len(aItens)]:cProdID		:= (cAlias)->VT9_IDWEB
							aItens[Len(aItens)]:cProduto	:= (cAlias)->MEV_PRODUT
							aItens[Len(aItens)]:nQuantidade	*= (cAlias)->MEV_QTD
							aItens[Len(aItens)]:nValorUnit	/= (cAlias)->MEV_QTD

						Else // Caso o produto seja um KIT e este KIT possuir mais de um produto

							//nPerc := 100-(nPrecoVenda*100/nValorAtual)
							nPerc := nPrecoVenda/nValorAtual
							nValor := 0
							While !(cAlias)->(Eof())
								oPedido := AnyItens():New()
								nValor := U_PrvEcommerce((cAlias)->MEV_PRODUT)

								oPedido:cProduto		:= xItens[nI]:cProduto
								oPedido:nQuantidade	:= xItens[nI]:nQuantidade
								oPedido:nValorUnit	:= xItens[nI]:nValorUnit
								oPedido:nTotal		:= xItens[nI]:nTotal
								oPedido:nTotalBruto	:= xItens[nI]:nTotalBruto
								oPedido:cProdID		:= xItens[nI]:cProdID
								oPedido:cTitulo		:= xItens[nI]:cTitulo
								oPedido:cSkuId		:= xItens[nI]:cSkuId
								oPedido:nDesconto		:= xItens[nI]:nDesconto

								oPedido:cProduto		:= (cAlias)->MEV_PRODUT
								oPedido:cProdID		:= (cAlias)->VT9_IDWEB
								oPedido:nQuantidade	*= (cAlias)->MEV_QTD

								nFator					:= xItens[nI]:nTotalBruto / xItens[nI]:nTotal

								//Rateia o preço entre os itens
								//nPrecoFinal 		:= oPedido:nPrecoAjuste / (cAlias)->MEV_QTD
								nPrecoFinal 			:= ROUND(nValor * nPerc, 2) * xItens[nI]:nQuantidade
								oPedido:nValorUnit 	:= nPrecoFinal
								oPedido:nTotal		:= nPrecoFinal * (cAlias)->MEV_QTD * nQdtVenda
								oPedido:nTotalBruto	:= round(oPedido:nTotal * nFator		, 2)
								nResto 				+= oPedido:nTotal

								aAdd(aItens, oPedido)

								(cAlias)->(DbSkip())
							EndDo

							//							If nResto <> nPrecoVenda
							//								oPedido:nTotalBruto += (nPrecoVenda - nResto)  / oPedido:nQuantidade
							//							EndIf					

						EndIf

					ElseIf Upper(AllTrim(cApi)) $ ('RESULTATE/B2C-RESULT')
						If nQdeItem == 1 //Caso o KIT possua apenas um produto

							aAdd(aItens, xItens[nI])

							aItens[Len(aItens)]:cIdWeb		:= (cAlias)->VT9_IDWEB
							aItens[Len(aItens)]:cCodSku		:= (cAlias)->MEV_PRODUT
							aItens[Len(aItens)]:nQde			*= (cAlias)->MEV_QTD
							aItens[Len(aItens)]:nVlrUnit	/= (cAlias)->MEV_QTD

						Else // Caso o produto seja um KIT e este KIT possuir mais de um produto

							//nPerc := 100-(nValorAtual*100/nPrecoVenda)
							nPerc := nPrecoVenda/nValorAtual
							nValor := 0
							While !(cAlias)->(Eof())
								oPedido := ResItens():New()
								nValor := U_PrvEcommerce((cAlias)->MEV_PRODUT) //* (cAlias)->MEV_QTD * nQdtVenda


								oPedido:cIdWeb 			:= xItens[nI]:cIdWeb
								oPedido:cOrdemId 			:= xItens[nI]:cOrdemId
								oPedido:dDtCriacao 		:= xItens[nI]:dDtCriacao
								oPedido:cHrCriacao		:= xItens[nI]:cHrCriacao
								oPedido:dDtAtuali 		:= xItens[nI]:dDtAtuali
								oPedido:cHrAtuali 		:= xItens[nI]:cHrAtuali
								oPedido:cTipProd 			:= xItens[nI]:cTipProd
								oPedido:nPeso 			:= xItens[nI]:nPeso
								oPedido:nVFreteGratis	:= xItens[nI]:nVFreteGratis
								oPedido:cDescProd 		:= xItens[nI]:cDescProd
								oPedido:cIdWeb			:= (cAlias)->VT9_IDWEB
								oPedido:cCodSku			:= (cAlias)->MEV_PRODUT
								oPedido:nQde				:= xItens[nI]:nQde * (cAlias)->MEV_QTD
								oPedido:cProdutoWeb		:= xItens[nI]:cProdutoWeb

								//Rateia o preço entre os itens
								nFator						:= xItens[nI]:nVlrOriginal / xItens[nI]:nVlrUnit
								nPrecoFinal 				:= nValor * nPerc * xItens[nI]:nQde
								oPedido:nVlrUnit 			:= round(nPrecoFinal, 2)

								//nResto					:= ((nPrecoFinal * nFator) - round(nPrecoFinal * nFator, 2)
								oPedido:nVlrOriginal		:= round(nPrecoFinal * nFator, 2)
								nResto 					+= oPedido:nVlrUnit * oPedido:nQde
								oPedido:nTotal			:= oPedido:nVlrUnit * oPedido:nQde

								aAdd(aItens, oPedido)

								(cAlias)->(DbSkip())
							EndDo

							//							If nResto <> nPrecoVenda
							//								oPedido:nPrecoAjuste += (nPrecoVenda - nResto) / oPedido:nQuantidade
							//							EndIf
							//						
						EndIf

					EndIf

				EndIf

			Else //Se o produto não for um KIT
				aAdd(aItens, xItens[nI])

			EndIf
		Else
			aItens := aClone(xItens)

		EndIf

	Next

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	RestArea(aAreaSB1)
	RestArea(aArea)

Return aItens

/*/
@Title   : Atualiza condição de pagamento dos pedidos pagos
@Type    : MTH = Metodo
@Name    : CiaAtuCondPag
@Author  : Henrique
@Date    : 24/05/2016
/*/
Method CiaAtuCondPag(oPedido) Class SchedPedido

	Local lRetorno		:= .f.
	Local cOrigem 		:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])

	Local i
	Local z
	Local nQtdParcelas	:= 0
	Local cPagamento		:= ""
	Local nValor			:= 0

	Local cFormaID		:= ""
	Local cNumCart		:= ""
	Local cForma			:= ""
	Local cAdmFinanc		:= Space(TamSx3("AE_COD")[1])
	Local cDescAdmFin		:= ""
	Local cTid				:= ""
	Local cNSU				:= ""
	Local cDescPag		:= ""
	Local cYObs			:= ""
	Local dVencimento

	If oPedido <> NIL

		Begin Transaction

			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(xFilial("SC5")+::cNumPed))

				//apaga informações de pagamento anteriores
				SL4->(dbSetOrder(1))
				If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))

					While SL4->(!Eof()) .and. xFilial("SL4")+SC5->C5_NUM+cOrigem == SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM

						RecLock("SL4",.f.)
						SL4->(dbDelete())
						SL4->(msUnLock())

						SL4->(dbSkip())

					EndDo

				EndIf

				//verifica se existe a tag PAYMENT			 
				If .T. //Upper(oPedido:cTipoTransacao) == 'PAYMENT'
					For i := 1 to Len(oPedido:DadosPgto)
						lRetorno	:= .T.

						If 'FATURADO' == UPPER(oPedido:DadosPgto[i]:cMetodoPtgo)
							//Não existe
							lRetorno	:= .F.

						ElseIf 'BOLETO' $ UPPER(oPedido:DadosPgto[i]:cMetodoPtgo)
							cTid			:= ""
							cNSU			:= ""
							cNumCart		:= ""
							nQtdParcelas	:= 1
							cPagamento		:= "BOLETO"
							cAdmFinanc		:= Space(TamSx3("AE_COD")[i])
							cAdmFinanc 	:= ::GetAdmFinanc(cPagamento,1)

						Else

							nQtdParcelas	:= oPedido:DadosPgto[i]:nQdeParcelas

							If !Empty(oPedido:DadosPgto[i]:cAdquirente)
								cPagamento 	:= UPPER(oPedido:DadosPgto[i]:cAdquirente)
							Else
								cPagamento 	:= Replace(UPPER(oPedido:DadosPgto[i]:cMetodoPtgo), 'MUNDIPAGG', '')
							EndIf

							cAdmFinanc 		:= ::GetAdmFinanc(cPagamento,nQtdParcelas)

							If AllTrim(cPagamento) == '' .OR. AllTrim(cAdmFinanc) == ''
								If 'CIELO' $ UPPER(oPedido:DadosPgto[i]:cMetodoPtgo)
									cPagamento		:= "CIELO"
								Else
									cPagamento		:= "MUNDIP"
								EndIf

								cAdmFinanc := ::GetAdmFinanc(cPagamento,nQtdParcelas)

							EndIf

							cNumCart		:= oPedido:DadosPgto[i]:cIdAutorizacao
							cTid			:= oPedido:DadosPgto[i]:cIdTransacao
							cNSU			:= ""
							nQtdParcelas	:= oPedido:DadosPgto[i]:nQdeParcelas
							nJuros			:= oPedido:DadosPgto[i]:nJuros

							cYObs	+= iif(Empty(cYOBS),"",", ")
							cYObs	+= iif(Empty(cYOBS),""," - ")+"NSU: "+cNSU
							cYObs	+= iif(Empty(cYOBS),""," - ")+"TID: "+cTid
							cYObs	+= iif(Empty(cYOBS),""," - ")+"AUTORIZACAO: "+cNumCart

						EndIf

						nValor		:= oPedido:nTotal

						cDescPag	+= iif(Empty(cDescPag),"",", ")
						cDescPag	+= Upper(	cPagamento+;
						" R$ "+AllTrim(Transform(nValor,PesqPict("SE1","E1_VALOR")))+;
						iif(nQtdParcelas>1," - PARCELAS: "+cValtoChar(nQtdParcelas),""))

						If nValor > 0

							For z := 1 to nQtdParcelas

								SAE->(dbSetOrder(1))
								If SAE->(dbSeek(xFilial("SAE")+cAdmFinanc))

									//Caso seja parcelado 
									dVencimento	:= dDatabase+(30*z)
									cFormaID		:= cValToChar(z)
									cForma			:= SAE->AE_TIPO
									cDescAdmFin	:= SAE->AE_COD+" - "+SAE->AE_DESC

								Else

									dVencimento 	:= dDatabase+7
									cFormaID		:= cValToChar(z)
									cForma			:= "NF"
									cDescAdmFin	:= ""

								EndIf

								RecLock("SL4",.T.)
								SL4->L4_FILIAL	:= xFilial("SL4")
								SL4->L4_NUM		:= SC5->C5_NUM
								SL4->L4_ORIGEM	:= cOrigem
								SL4->L4_DATA		:= dVencimento
								SL4->L4_VALOR		:= Round(nValor/nQtdParcelas,TamSx3("L4_VALOR")[2])
								SL4->L4_FORMA		:= cForma
								SL4->L4_FORMAID	:= cFormaID
								SL4->L4_NUMCART	:= cNumCart
								SL4->L4_ADMINIS	:= cDescAdmFin
								SL4->(msUnLock())

							Next

						EndIf

					Next

				EndIf

				RecLock("SC5",.f.)

				SC5->C5_MENNOTA	:= cDescPag

				If SC5->(FieldPos("C5_YOBS")) > 0
					SC5->C5_YOBS := cYObs
				EndIf

				SC5->(msUnLock())

			Else

				aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+::cNumPed+" na base de dados, favor verificar a tabela SC5!")

			EndIf

		End Transaction

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para criação das formas de pagamento!")

	EndIf

	//caso tenha realizado a atualização do pagamento o sistema atualiza as datas de pagamento
	If lRetorno

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			If !IsBlind()
				RecLock("VT1",.f.)
			EndIf

			VT1->VT1_DATAPG	:= dDataBase
			VT1->VT1_HORAPG	:= Time()

			VT1->VT1_DATAUL	:= dDataBase
			VT1->VT1_HORAUL	:= Time()

			If !IsBlind()
				VT1->(msUnlock())
			EndIf

		EndIf

	EndIf

Return lRetorno

/*/
@Title   : Cancela os pedidos no Protheus
@Type    : MTH = Metodo
@Name    : CiaPedCanc
@Author  : Henrique
@Date    : 30/05/2016
/*/
Method CiaPedCanc(oPedido) Class SchedPedido
	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_SEQUEN")[1])

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI)) .and. VT1->VT1_STATUS <> "C"

		::CriaInteg()

		If ::CancelInt()
			RecLock("VT1",.F.)
			VT1->VT1_STATAN	:= ''
			VT1->VT1_STATUS	:= "E"
			VT1->(msUnLock())

		Else

			//Caso tenha mensagem de erro grava na tabela de integração
			::GrvMsgErro()

			VT1->(dbSetOrder(1))
			VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			RecLock("VT1",.F.)
			VT1->VT1_STATUS	:= "C"
			VT1->VT1_STATAN	:= ""
			VT1->(msUnLock())

		EndIf

	EndIf

Return

/*/
@Title   : Integração dos Pedidos com pagamento cancelado para o ambiente CiaShop
@Type    : MTH = Metodo
@Name    : CiaPedPagNeg
@Author  : Henrique
@Date    : 30/05/2016
/*/
Method CiaPedPagNeg(oPedido) Class SchedPedido
	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_SEQUEN")[1])

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

		::CriaInteg()
		If ::CancelInt()

			If oPedido:Cancelar()

				RecLock("VT1",.F.)				
				VT1->VT1_STATAN	:= ''
				VT1->VT1_STATUS	:= "E"
				VT1->(msUnLock())

			EndIf

		EndIf

		//Caso tenha mensagem de erro grava na tabela de integração
		::GrvMsgErro()

	EndIf

Return

/*/
@Title   : Altera o prazo de entrega do pedido após o pagamento
@Type    : MTH = Metodo
@Name    : AlteraPrazoEnt
@Author  : Henrique
@Date    : 08/06/2016
/*/
Static Function AlteraPrazoEnt(oSched, cPedido, cIdWeb, cAPI, oPedido, cEmpFor, cFilFor)//oPedido, ::cNumPed, ::cOrderID, ::cAPI
	Local aAreaSC6 	:= SC6->(GetArea())
	Local aAreaSC5 	:= SC5->(GetArea())
	Local aAreaVT1	:= VT1->(GetArea())
	Local aAreaSA4	:= SA4->(GetArea())
	Local aArea		:= GetArea()
	Local dDataPagto	:= CTOD('')
	Local dDtEntrega	:= CTOD('')
	Local aProdutos	:= {}
	Local nFrete		:= 0
	Local cTransp		:= ''
	Local cCepEntrega	:= ''
	Local nDias		:= 0
	Local nValProdutos:= 0
	Local lRet			:= .F.
	Local cTipoPrevisao := SuperGetMv("VT_TIPPREV",.F.,"E") //E = Emissao - P = Pagamento
	Local dDtFatur	:= ctod('')

	Default oPedido	:= Nil
	Default cEmpFor	:= '' 
	Default cFilFor	:= '' 

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+cIdWeb+cAPI/*+cEmpFor+cFilFor*/))
		dDataPagto := VT1->VT1_DATAPG 
	Else
		Return .F.
	EndIf

	If dDataPagto == CTOD('')
		Return .F.
	EndIf

	SC5->(dbSetOrder(1))
	If !SC5->(dbSeek(xFilial("SC5")+cPedido))
		aAdd(::aMsgErro,'O pedido no Protheus não foi encontrado.')
		Return .F.
	EndIf

	nFrete 		:= SC5->C5_FRETE
	cTransp		:= SC5->C5_TRANSP

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
		cCepEntrega := SA1->A1_CEP
	EndIf

	dDtFatur := CTOD('')
	SC6->(dbSetOrder(1))
	If SC6->(dbSeek(xFilial("SC6")+cPedido))
		While !SC6->(Eof()) .and. AllTrim(SC6->C6_NUM) = AllTrim(cPedido)
			aAdd(aProdutos, {SC6->C6_PRODUTO, SC6->C6_QTDVEN, SC6->C6_PRCVEN})
			nValProdutos += SC6->C6_VALOR

			If SC6->C6_DATFAT <> CTOD('')
				dDtFatur := SC6->C6_DATFAT
			EndIf	

			SC6->(DbSkip())
		EndDo

		If cAPI == 'CANALPECAS' .and. oPedido <> nil
			cTransp 	:= POSICIONE('VT6', 1, xFilial('VT6')+Padr('CANALPECAS',TamSx3("VT6_API")[1])+ upper(oPedido:DadosEntrega[1]:cTransp), 'VT6->VT6_TRANSP')
			nDias		:= oPedido:DadosEntrega[1]:nPrazo

		Else
			DiasEntrega(cAPI, cCepEntrega, aProdutos, @cTransp, @nDias, nFrete, nValProdutos, cPedido, oSched)

		EndIF

		If nDias > 0
			If cTipoPrevisao == 'E' .AND. dDtFatur <> CTOD('') //Emissao da nota fiscal
				dDtEntrega := dDtFatur
			Else
				dDtEntrega := dDataPagto
			EndIf

			dDtEntrega := DataValida( dDtEntrega, .T.)

			dDtEntrega := U_DiasUteis(dDtEntrega, nDias,.T.) //pega a próxima data útil (não considera feriados)

		Else
			dDtEntrega := dDataPagto+10
		EndIf

		SC6->(dbSeek(xFilial("SC6")+cPedido))
		While !SC6->(Eof()) .and. AllTrim(SC6->C6_NUM) = AllTrim(cPedido)

			RecLock('SC6', .F.)
			SC6->C6_ENTREG := dDtEntrega
			SC6->(MsUnLock())

			SC6->(DbSkip())
		EndDo

		If Empty(SC5->C5_TRANSP)
			RecLock('SC5', .F.)
			SC5->C5_TRANSP := cTransp
			SC5->(MsUnLock())
		EndIf

	EndIf

	//====================================================================
	//Quando a transportadora for correios, será alterada a transportadora
	//no Tims para a Hiper por questões de prioridade na separação dos
	//produtos
	//Henrique - A pedido do Gabriel Checon
	//====================================================================
	If Empty (cTransp)
		aAdd(oSched:aMsgErro,'Código da transportadora não encontrado.')
		lRet := .F.

	ElseIf cEmpAnt != '09' .and. ! Empty(cTransp)
		lRet := .T.

	ElseIf cEmpAnt == '09'

		SA4->(dbSetOrder(1))
		If SA4->(dbSeek(xFilial("SA4")+cTransp))

			If SA4->(FieldPos("A4_YCROBRI")) > 0 .and. SA4->A4_YCROBRI == "S"
				lRet := StartJob("u_AlterTransTims",GetEnvServer(),.t.,{cIdWeb, cAPI, SM0->M0_CGC,SA4->A4_COD})				
			Else
				lRet := .T.

			EndIf

		Else	
			lRet := .T.
		EndIf

	EndIf

	SA4->(RestArea(aAreaSA4))
	SC6->(RestArea(aAreaSC6))
	VT1->(RestArea(aAreaVT1))
	SC5->(RestArea(aAreaSC5))

	RestArea(aArea)

Return lRet

/*/
@Title   :
@Type    : MTH = Metodo
@Name    :
@Author  : Henrique
@Date    : 21/06/2016
/*/
Static Function DiasEntrega(cAPI, cCepEntrega, aProdutos, cTransp, nDiasEntrega, nValFrete, nValProdutos, cPedido, oSched)
	Local aAreaSB5		:= SB5->(GetArea())
	Local aAreaVT6		:= VT6->(GetArea())
	Local oFrete 			:= Nil
	Local oVolume			:= Nil
	Local cCEPOrigem		:= SuperGetMv("VT_CEPORIG",.F.,"29110286")
	Local nCalcFrete		:= 0
	Local lTransp			:= .F.
	Local cTranspWeb	:= ''
	Local aCotacao		:= {}
	Local cOrigem 		:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])
	Local cAdmiFina		:= ''
	Local cCodAdminis		:= ''
	Local lAchouTransp	:= .F.
	Local nI				:= 0
	Local aCotPrd			:={}

	Default cCepEntrega 	:= ''
	Default aProdutos		:= {}
	Default cTransp		:= ''
	Default nValProdutos	:= 0
	Default nValFrete		:= 0
	Default nDiasEntrega	:= 0
	Default cPedido		:= ''

	lTransp := ! Empty(cTransp)

	If Empty(cCepEntrega) .OR. Len(aProdutos) == 0
		Return

	EndIf

	If lTransp
		cTranspWeb := POSICIONE('VT6', 2, xFilial('VT6')+Padr('INTELIPOST',TamSx3("VT6_API")[1])+cTransp, 'VT6->VT6_IDWEB')
	EndIf

	oFrete := IPTFrete():New()

	oFrete:cCepOrig		:= cCEPOrigem
	oFrete:cCepDest		:= cCepEntrega
	//oFrete:nValor			:= nValProdutos

	For nI := 1 to Len(aProdutos)
		oVolume := IPTProduto():New()
		oVolume:cCodProduto		:= aProdutos[nI, 1]
		oVolume:nQuantidade 		:= aProdutos[nI, 2]
		oVolume:nCost_of_goods	:= aProdutos[nI, 3]

		DbSelectArea('SB5')
		DbSetOrder(1)
		If SB5->(DbSeek(xFilial('SB5')+aProdutos[nI, 1]))

			oVolume:nAltura			:= Ceiling(SB5->B5_ALTURLC)
			oVolume:nComprimento 	:= Ceiling(SB5->B5_COMPRLC)
			oVolume:nLargura		:= Ceiling(SB5->B5_LARGLC)

			SB1->(DbSEtOrder(1))
			If SB1->(DbSeek(xFilial('SB1')+aProdutos[nI, 1]))
				oVolume:nPeso			:= Ceiling(SB1->B1_PESBRU)
			EndIf

			aAdd(oFrete:Produtos, oVolume)
		Else
			Return
		EndIf

	Next

	aCotPrd := oFrete:CotarProduto()

	If len(aCotPrd) > 1 .and. aCotPrd[1]

		If lTransp
			For nI := 1 to Len(oFrete:aCotacoes)
				If AllTrim(cTranspWeb) == AllTrim( cValToChar( oFrete:aCotacoes[nI]:nId ) )
					nDiasEntrega 	:= oFrete:aCotacoes[nI]:nQdeEstimada
					nCalcFrete 		:= oFrete:aCotacoes[nI]:nFrete
					Exit
				EndIf
			Next

		Else
			For nI := 1 to Len(oFrete:aCotacoes)
				aAdd(aCotacao, {oFrete:aCotacoes[nI]:nQdeEstimada, oFrete:aCotacoes[nI]:nFrete, ABS((nValFrete - oFrete:aCotacoes[nI]:nFrete)), cValToChar( oFrete:aCotacoes[nI]:nId )})
			Next

			If Len(aCotacao) > 0
				aCotacao := aSort(aCotacao,,,{|x,y| padl(Transform(x[3],"@E 9999999.99"), 12, '0')+ padl(cValToChar(x[2]), 4, '0')+ padl(Transform(x[1],"@E 9999999.99"), 12, '0');
				< padl(Transform(y[3],"@E 9999999.99"), 12, '0')+ padl(cValToChar(y[2]), 4, '0')+ padl(Transform(y[1],"@E 9999999.99"), 12, '0')})

				///Pega os dados da primeira transportadora que já está posicionada 
				cTransp  := POSICIONE('VT6', 1, xFilial('VT6')+Padr('INTELIPOST',TamSx3("VT6_API")[1])+ UPPER(aCotacao[1,4]), 'VT6->VT6_TRANSP')
				nDiasEntrega 	:= aCotacao[1, 1]
				nCalcFrete 	:= aCotacao[1, 2]

			Else
				nDiasEntrega 	:= 0
				nCalcFrete 	:= 0

			EndIf

		EndIf

	Else
		If valtype(aCotPrd[2]) == "U"
			aCotPrd[2] := ""
		EndIf

		aAdd(oSched:aMsgErro,"Não foi possível fazer a cotação do frete." + chr(13)+ chr(10)+	aCotPrd[2])

	EndIf

	SB5->(RestArea(aAreaSB5))
	VT6->(RestArea(aAreaVT6))
Return


/*/
@Title   :
@Type    : MTH = Metodo
@Name    : Canal Peças
@Author  : Henrique
@Date    : 25/11/2016
/*/
Method CanalPedBase() Class SchedPedido
	Local oPedido		:= CanalPedDetalhe():New()
	Local cAlias 		:= GetNextAlias()
	Local cAPI			:= ::cAPI

	BeginSql Alias cAlias
		SELECT
		VT1_ORDID
		FROM
		%Table:VT1% VT1
		WHERE
		VT1.VT1_FILIAL = %xFilial:VT1%
		AND VT1.%notdel%
		AND	VT1.VT1_API = %Exp:cAPI%
		AND VT1.VT1_STATUS IN (' ', '1', '2', '3')
	EndSQL

	(cAlias)->(dbGoTop())
	While !(cAlias)->(Eof())
		::cOrderID 		:= (cAlias)->VT1_ORDID
		oPedido:cIdWeb	:= AllTrim((cAlias)->VT1_ORDID)

		If oPedido:GetPedido()
			::cStatPed		:= AllTrim(oPedido:cStatus)
			::cSequence	:= Padr(Upper((cAlias)->VT1_ORDID),TamSx3("VT1_SEQUEN")[1])

			If AllTrim(oPedido:cStatus) == 'AWAITING_PAYMENT'
				::CriaPedCanal(oPedido)
			ElseIf AllTrim(oPedido:cStatus) == 'PAYMENT_APPROVED'
				::CriaPedCanal(oPedido)
			ElseIf AllTrim(oPedido:cStatus) == 'CANCELED'
				::CanalPedCanc(oPedido)
			ElseIf AllTrim(oPedido:cStatus) == 'STRAYED'
				::CanalPedPagNeg(oPedido)
			EndIf

		EndIf

		(cAlias)->(DbSkip())

	EndDo

	FreeObj(oPedido)

	(cAlias)->(dbCloseArea())
Return


//=============================================================================================================================================
//Metodos da API do Canal da Peça
//=============================================================================================================================================
/*/
@Title   : Integração dos Pedidos do Canal da Peça
@Type    : MTH = Metodo
@Name    : CiaPedidos
@Author  : Henrique
@Date    : 21/11/2016
/*/
Method CanalPedidos() Class SchedPedido
	Local oCanalPedido 	:= CanalPedidos():New()
	Local nI				:= 0

	//Tratamentos dos pedidos aprovados
	oCanalPedido:GetAllPedidos()
	For nI := 1 to Len(oCanalPedido:Pedidos)

		If AllTrim(oCanalPedido:Pedidos[nI]:cStatus) == 'AWAITING_PAYMENT'
			::CriaPedCanal(oCanalPedido:Pedidos[nI])
		ElseIf AllTrim(oCanalPedido:Pedidos[nI]:cStatus) == 'PAYMENT_APPROVED'
			::CriaPedCanal(oCanalPedido:Pedidos[nI])
		ElseIf AllTrim(oCanalPedido:Pedidos[nI]:cStatus) == 'CANCELED'
			::CanalPedCanc(oCanalPedido:Pedidos[nI])
		ElseIf AllTrim(oCanalPedido:Pedidos[nI]:cStatus) == 'STRAYED'
			::CanalPedPagNeg(oCanalPedido:Pedidos[nI])
		EndIf

	Next

	FreeObj(oCanalPedido)

Return


/*/
@Title   : Cria os pedido
@Type    : MTH = Metodo
@Name    : CriaPedCanal
@Author  : Henrique
@Date    : 21/11/2016
/*/
Method CriaPedCanal(oPedido) Class SchedPedido

	Local lPedIntegr	:= .F.
	Local lPassou		:= .F.

	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_SEQUEN")[1])

	//Caso esteje com o status parado, sai da rotina	
	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
		If VT1->VT1_STATUS == 'P'
			Return
		EndIf

	EndIf

	::cStatPed		:= oPedido:cStatus

	lPedIntegr := ::CriaInteg()


	If lPedIntegr

		//Caso status em branco necessario integrar pedido	
		If Empty(::cStatus)
			lPedIntegr 	:= ::CanalIntPedido(oPedido)
			lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
			lPedIntegr		:= ::GrvNumPed(lPedIntegr)
			lPassou		:= .T.

		EndIf

		If Upper(::cStatPed) $ Upper("PAYMENT_APPROVED") //Status

			//Caso o pedido esteja integrado e com o pagamento aprovado, sera feito a mudança de status do pedido para Iniciar Manuseio		
			If ::cStatus == "1"
				lPedIntegr 	:= ::CanalAtuCondPag(oPedido)
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .T.
			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status
			If ::cStatus == "2"
				lPedIntegr := AlteraPrazoEnt(Self, ::cNumPed, ::cOrderID, ::cAPI, oPedido)

				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .T.

			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status
			If ::cStatus == "3"
				lPedIntegr 	:= ::LibPedido()
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr)
				lPassou		:= .t.

			EndIf

		EndIf
		//Caso tenha mensagem de erro grava na tabela de integração
		::GrvMsgErro()

	EndIf

Return

/*/
@Title   : Monta informações atraves da API para pedido de venda Canal Peças x Protheus
@Type    : MTH = Metodo
@Name    : CanalIntPedido
@Author  : Henrique
@Date    : 21/11/2016
/*/
Method CanalIntPedido(oPedido) Class SchedPedido

	Local oCliente 		:= SchedCliente():New(::cAPI)
	Local lRetorno		:= .F.
	Local aItens			:= {}
	Local nTotProd		:= 0
	Local cVendedor		:= ''
	Local xEndCliente		:= Nil
	Local xCliente  		:= Nil
	Local xItens 			:= Nil
	Local i				:= 0
	Local nQdtVenda		:= 0
	Local nPrecoVenda		:= 0
	Local lAchou 			:= .F.
	Local cProduto 		:= ''
	Local nLoteDist		:= 0

	Default oPedido		:= Nil

	Private lMsErroAuto 	:= .F.

	If oPedido == Nil
		Return .F.
	EndIf

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If oPedido <> NIL

		xItens			:= oPedido:Itens
		//xItens			:= AnaliseKit(xItens, ::cAPI)
		//oPedido:Itens := xItens

		xCliente		:= oPedido
		xEndCliente	:= oPedido

		::aProdutos	:= {}
		::cTransp		:= ''
		::cTipoFrete	:= "C"
		::nValFrete	:= Round(oPedido:DadosEntrega[1]:nFrete,TamSx3("C5_FRETE")[2])

		If oPedido:DadosEntrega[1]:nPrazo > 0
			::dDtEntrega	:= dDataBase+oPedido:DadosEntrega[1]:nPrazo
		Else
			::dDtEntrega	:= dDataBase+10
		EndIf

		cVendedor := ObtemVend('CANALPECAS')

		If Len(oPedido:DadosEntrega[1]:cTransp) > 0
			::cTransp		:= ::GetTransp(oPedido:DadosEntrega[1]:cTransp)
		Endif

		::cStatPed		:= oPedido:cStatus

		//metodo para cadastrar ou atualizar cliente
		lRetorno := oCliente:IncluiCliente(xCliente,xEndCliente)

		//Atualiza tabela de integração
		If lRetorno .and. Len(xItens) > 0

			aItens := xItens

			//Recupera os produtos e quantidades para solicitar estoque em outra loja caso estoque seja compartilhados
			For i := 1 to Len(aItens)

				If ::dDtEntrega == nil .Or. ::dDtEntrega == CTOD('')
					::dDtEntrega	:= dDataBase+10

				EndIf

				lAchou 	:= .F.
				cProduto 	:= ''
				DbSelectArea('VT9')
				VT9->(DbSetOrder(1))
				If Dbseek(xFilial('VT9')+ padr(::cAPI, TAMSX3('VT9_API')[1], ' ')+ aItens[i]:cProduto) .and. AllTrim(VT9->VT9_IDWEB) == AllTrim(aItens[i]:cProduto)
					cProduto := VT9->VT9_PRODUT
					lAchou := .T.
				EndIf

				If lAchou
					If SB1->(dbSeek(xFilial('SB1')+cProduto))
						nLoteDist := SB1->B1_YLMDIST
						If SB1->B1_TIPO == 'KT'
							nLoteDist := 1
							cProduto := aItens[i]:cCodProduto
						EndIf
					EndIf
				EndIf

				If lAchou
					DbSelectArea('SB1')
					DbSetOrder(1)

					nQdtVenda 		:= aItens[i]:nQuantidade
					nPrecoVenda 	:= aItens[i]:nValor

					If SB1->(DbSeek(xFilial('SB1')+cProduto))

						If nLoteDist > 1
							nQdtVenda *= nLoteDist
							nPrecoVenda /= nLoteDist
						EndIf

					EndIf

					aAdd(::aProdutos,{StrZero(i,TamSX3("C6_ITEM")[1]),;
					cProduto,;
					nQdtVenda,; //Valor já com o desconto
					nPrecoVenda,;
					.t.,;
					::dDtEntrega })
					nTotProd += aItens[i]:nQuantidade*aItens[i]:nValor

				EndIf
			Next

			lRetorno := ::GeraPedido(oCliente, cVendedor)

		Else
			//inclui mensagens de erro no vetor principal
			::AddErro(oCliente:aMsgErro)

		EndIf

	Else
		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para integração inicial!")

	EndIf

Return lRetorno

/*/
@Title   : Atualiza condição de pagamento dos pedidos pagos do Canal da Peça
@Type    : MTH = Metodo
@Name    : CiaAtuCondPag
@Author  : Henrique
@Date    : 21/11/2016
/*/
Method CanalAtuCondPag(oPedido) Class SchedPedido

	Local lRetorno		:= .f.
	Local cOrigem 		:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])

	Local i
	Local z
	Local nQtdParcelas	:= 0
	Local cPagamento		:= ""
	Local nValor			:= 0

	Local cFormaID		:= ""
	Local cNumCart		:= ""
	Local cForma			:= ""
	Local cAdmFinanc		:= Space(TamSx3("AE_COD")[1])
	Local cDescAdmFin		:= ""
	Local cTid				:= ""
	Local cNSU				:= ""
	Local cDescPag		:= ""
	Local cYObs			:= ""
	Local dVencimento

	If oPedido <> NIL

		Begin Transaction

			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(xFilial("SC5")+::cNumPed))

				//apaga informações de pagamento anteriores
				SL4->(dbSetOrder(1))
				If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))

					While SL4->(!Eof()) .and. xFilial("SL4")+SC5->C5_NUM+cOrigem == SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM

						RecLock("SL4",.f.)
						SL4->(dbDelete())
						SL4->(msUnLock())

						SL4->(dbSkip())

					EndDo

				EndIf

				//verifica se existe a tag PAYMENT			 
				If Upper(oPedido:cStatus) == 'PAYMENT_APPROVED'
					lRetorno		:= .T.
					nQtdParcelas	:= 1
					cPagamento 	:= 'MOIP'
					cAdmFinanc 	:= ::GetAdmFinanc(cPagamento,nQtdParcelas)

					cNumCart		:= ''//oPedido:DadosPgto[i]:cIdAutorizacao
					cTid			:= ''//oPedido:DadosPgto[i]:cIdTransacao
					cNSU			:= ''
					nQtdParcelas	:= 1//oPedido:DadosPgto[i]:nQdeParcelas
					nJuros			:= ''//oPedido:DadosPgto[i]:nJuros

					cYObs	+= iif(Empty(cYOBS),"",", ")
					cYObs	+= iif(Empty(cYOBS),""," - ")+"NSU: "+cNSU
					cYObs	+= iif(Empty(cYOBS),""," - ")+"TID: "+cTid
					cYObs	+= iif(Empty(cYOBS),""," - ")+"AUTORIZACAO: "+cNumCart

					nValor		:= oPedido:nTotal

					cDescPag	+= iif(Empty(cDescPag),"",", ")
					cDescPag	+= Upper(	cPagamento+;
					" R$ "+AllTrim(Transform(nValor,PesqPict("SE1","E1_VALOR")))+;
					iif(nQtdParcelas>1," - PARCELAS: "+cValtoChar(nQtdParcelas),""))

					If nValor > 0

						For z := 1 to nQtdParcelas

							SAE->(dbSetOrder(1))
							If SAE->(dbSeek(xFilial("SAE")+cAdmFinanc))

								//Caso seja parcelado 
								dVencimento	:= dDatabase+(30*z)
								cFormaID		:= cValToChar(z)
								cForma			:= SAE->AE_TIPO
								cDescAdmFin	:= SAE->AE_COD+" - "+SAE->AE_DESC

							Else

								dVencimento 	:= dDatabase+7
								cFormaID		:= cValToChar(z)
								cForma			:= "NF"
								cDescAdmFin	:= ""

							EndIf

							RecLock("SL4",.T.)
							SL4->L4_FILIAL	:= xFilial("SL4")
							SL4->L4_NUM		:= SC5->C5_NUM
							SL4->L4_ORIGEM	:= cOrigem
							SL4->L4_DATA		:= dVencimento
							SL4->L4_VALOR		:= Round(nValor/nQtdParcelas,TamSx3("L4_VALOR")[2])
							SL4->L4_FORMA		:= cForma
							SL4->L4_FORMAID	:= cFormaID
							SL4->L4_NUMCART	:= cNumCart
							SL4->L4_ADMINIS	:= cDescAdmFin
							SL4->(msUnLock())

						Next

					EndIf

				EndIf

				RecLock("SC5",.f.)

				SC5->C5_MENNOTA	:= cDescPag

				If SC5->(FieldPos("C5_YOBS")) > 0
					SC5->C5_YOBS := cYObs
				EndIf

				SC5->(msUnLock())

			Else

				aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+::cNumPed+" na base de dados, favor verificar a tabela SC5!")

			EndIf

		End Transaction

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para criação das formas de pagamento!")

	EndIf

	//caso tenha realizado a atualização do pagamento o sistema atualiza as datas de pagamento
	If lRetorno

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			If !IsBlind()
				RecLock("VT1",.f.)
			EndIf

			VT1->VT1_DATAPG	:= dDataBase
			VT1->VT1_HORAPG	:= Time()

			VT1->VT1_DATAUL	:= dDataBase
			VT1->VT1_HORAUL	:= Time()

			If !IsBlind()
				VT1->(msUnlock())
			EndIf

		EndIf

	EndIf

Return lRetorno

/*/
@Title   : Cancela os pedidos no Protheus referente ao Canal da peça
@Type    : MTH = Metodo
@Name    : CanalPedCanc
@Author  : Henrique
@Date    : 21/11/2016
/*/
Method CanalPedCanc(oPedido) Class SchedPedido
	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_SEQUEN")[1])

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI)) .and. VT1->VT1_STATUS <> "C"

		::CriaInteg()

		If ::CancelInt()
			RecLock("VT1",.F.)			
			VT1->VT1_STATAN	:= ''
			VT1->VT1_STATUS	:= "E"
			VT1->(msUnLock())

		Else

			//Caso tenha mensagem de erro grava na tabela de integração
			::GrvMsgErro()

			VT1->(dbSetOrder(1))
			VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

			RecLock("VT1",.F.)
			VT1->VT1_STATUS	:= "C"
			VT1->VT1_STATAN	:= ""
			VT1->(msUnLock())

		EndIf

	EndIf

Return

/*/
@Title   : Integração dos Pedidos com pagamento negada pela administradora financeira
@Type    : MTH = Metodo
@Name    : CanalPedPagNeg
@Author  : Henrique
@Date    : 21/11/2016
/*/
Method CanalPedPagNeg(oPedido) Class SchedPedido
	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_SEQUEN")[1])

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))

		if ::CriaInteg()
			If ::CancelInt()

				If oPedido:Cancelar()

					RecLock("VT1",.F.)
					VT1->VT1_STATAN	:= ''
					VT1->VT1_STATUS	:= "E"
					VT1->(msUnLock())

				EndIf

			EndIf

			//Caso tenha mensagem de erro grava na tabela de integração
			::GrvMsgErro()

		EndIf
	EndIf

Return

/*/
@Title   : Construtor do Objeto
@Type    : MTH = Metodo
@Name    : Despacho
@Author  : Henrique
@Date    : 08/12/2015
/*/
Method VerPedLog(cProduto) Class SchedPedido

	Local lRet 	:= .f.
	Local cAlias	:= ''

	If cEmpAnt == "08"
		cAlias:= GetNextAlias()
		//recupe as notas fiscais para envio logistico
		BeginSql Alias cAlias
			SELECT
			SB1.B1_COD
			FROM
			%Table:SB1% SB1
			INNER JOIN %Table:ZZL% ZZL ON	ZZL.ZZL_FILIAL	= %xFilial:ZZL%
			AND ZZL.ZZL_FABRIC	= SB1.B1_FABRIC
			AND ZZL.%notdel%
			WHERE
			SB1.B1_FILIAL	= %xFilial:SB1%
			AND SB1.%notdel%
			AND SB1.B1_COD = %Exp:cProduto%
		EndSql

		(cAlias)->(dbGoTop())
		lRet := (cAlias)->(!Eof())
		(cAlias)->(DbCloseArea())
	EndIf

	Return lRet



	/*/{Protheus.doc}
	INTEGRAÇÃO RESULTATE
	/*/

	/*/{Protheus.doc} ResPedidos
	Obtem os pedidos da Resultate a serem processados
	@author henrique
	@since 20/06/2017
	@version 1.0
	@example
	(examples)
	@see (links_or_references)
	/*/Method ResPedidos(cTipo) Class SchedPedido
	Local oResPedido 		:= Nil
	Local nI, nJ			:= 0
	Local aPedidos		:= {}
	Local lCancelou := .F.

	Default cTipo := ''

	oResPedido 		:= ResPedidos():New(cTipo)

	//Tratamentos dos pedidos pendente de pagamento
	//pending (Transação realizada, mas sem a confirmação de pagamento).
	oResPedido:GetAllPending()	
	For nI := 1 to Len(oResPedido:aPedidos)
		aPedidos := {}
		aPedidos := SeparaPedido(Self, oResPedido:aPedidos[nI], ::cAPI) 

		For nJ := 1 to Len(aPedidos)
			//Caso encontre o pedido da Mercado Livre no 00K, analisa se já foi criado 
			//pela Anymarket anteriormente
			If PedidoAnyML(aPedidos[nJ], ::cAPI, Self)
				Loop
			EndIf

			oResPedido:aPedidos[nI]:Itens := aPedidos[nJ, 3]

			If nJ > 1
				oResPedido:aPedidos[nI]:nTaxaEnvio := 0
			EndIf

			::CriaPedRes(cTipo, oResPedido:aPedidos[nI], aPedidos[nJ, 1], aPedidos[nJ, 2])
		Next

	Next	
	oResPedido:aPedidos := {}

	//Tratamentos dos pedidos Aguardando Pagamento holded
	oResPedido:GetAllAguard()
	For nI := 1 to Len(oResPedido:aPedidos)

		aPedidos := {}
		aPedidos := SeparaPedido(Self, oResPedido:aPedidos[nI], ::cAPI) 

		For nJ := 1 to Len(aPedidos)
			//Caso encontre o pedido da Mercado Livre no 00K, analisa se já foi criado 
			//pela Anymarket anteriormente
			If PedidoAnyML(aPedidos[nJ])
				Loop
			EndIf

			oResPedido:aPedidos[nI]:Itens := aPedidos[nJ, 3]

			If nJ > 1
				oResPedido:aPedidos[nI]:nTaxaEnvio := 0
			EndIf

			::CriaPedRes(cTipo, oResPedido:aPedidos[nI], aPedidos[nJ, 1], aPedidos[nJ, 2])
		Next

	Next	
	oResPedido:aPedidos := {}

	//processing
	oResPedido:GetAllAprovado()	
	For nI := 1 to Len(oResPedido:aPedidos)	

		aPedidos := {}
		aPedidos := SeparaPedido(Self, oResPedido:aPedidos[nI], ::cAPI) 

		For nJ := 1 to Len(aPedidos)
			//Caso encontre o pedido da Mercado Livre no 00K, analisa se já foi criado 
			//pela Anymarket anteriormente
			If PedidoAnyML(aPedidos[nJ])
				Loop
			EndIf

			oResPedido:aPedidos[nI]:Itens := aPedidos[nJ, 3]

			If nJ > 1
				oResPedido:aPedidos[nI]:nTaxaEnvio := 0
			EndIf

			::CriaPedRes(cTipo, oResPedido:aPedidos[nI], aPedidos[nJ, 1], aPedidos[nJ, 2])
		Next

	Next	
	oResPedido:aPedidos := {}	

	//Tratamentos dos pedidos cancelados
	//Cancelled (cancelado)
	oResPedido:GetAllCancelado()
	For nI := 1 to Len(oResPedido:aPedidos)
		aPedidos := {}
		aPedidos := SeparaPedido(Self, oResPedido:aPedidos[nI], ::cAPI) 
		For nJ := 1 to Len(aPedidos)
			//Caso encontre o pedido da Mercado Livre no 00K, analisa se já foi criado 
			//pela Anymarket anteriormente
			If PedidoAnyML(aPedidos[nJ])
				Loop
			EndIf

			oResPedido:aPedidos[nI]:Itens := aPedidos[nJ, 3]
			lCancelou := ::ResPedCanc(oResPedido:aPedidos[nI], aPedidos[nJ, 1], aPedidos[nJ, 2])

			If ! lCancelou
				Exit

			EndIf

		Next

		If lCancelou	
			oResPedido:aPedidos[nI]:Finalizar()

		EndIf

	Next	
	oResPedido:aPedidos := {}

	//Tratamentos dos pedidos reembolsados
	//closed
	oResPedido:GetAllReembols()	
	For nI := 1 to Len(oResPedido:aPedidos)
		aPedidos := {}
		aPedidos := SeparaPedido(Self, oResPedido:aPedidos[nI], ::cAPI) 
		For nJ := 1 to Len(aPedidos)
			//Caso encontre o pedido da Mercado Livre no 00K, analisa se já foi criado 
			//pela Anymarket anteriormente
			If PedidoAnyML(aPedidos[nJ])
				Loop
			EndIf

			oResPedido:aPedidos[nI]:Itens := aPedidos[nJ, 3]
			lCancelou := ::ResPedCanc(oResPedido:aPedidos[nI], aPedidos[nJ, 1], aPedidos[nJ, 2])

			If ! lCancelou
				Exit

			EndIf

		Next

		If lCancelou	
			oResPedido:aPedidos[nI]:Finalizar()

		EndIf

	Next	
	oResPedido:aPedidos := {}	

	FreeObj(oResPedido)

Return

/*/{Protheus.doc} CriaPedRes
Processa os pedidos de acordo com o status
@author henrique
@since 20/06/2017
@version 1.0
@param oPedido, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/Method CriaPedRes(cTipo, oPedido, cEmpFor, cFilFor) Class SchedPedido

	Local lPedIntegr	:= .F.
	Local lPassou		:= .F. 

	Default cTipo 	:= ''
	Default cEmpFor	:= ''
	Default cFilFor	:= ''

	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cPedMPlace),TamSx3("VT1_SEQUEN")[1])

	if VT1->(FieldPos('VT1_IDCART')) > 0
		::cIdCart	:= Padr(Upper(oPedido:cIdCart),TamSx3("VT1_IDCART")[1])
	Else
		::cIdCart:= ''
	EndIf

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor */))
		If VT1->VT1_STATUS == 'P'
			Return
		EndIf

	EndIf

	::cStatPed		:= oPedido:cStatus

	lPedIntegr := ::CriaInteg(cEmpFor, cFilFor, oPedido)


	If lPedIntegr

		//Caso status em branco necessario integrar pedido	
		If Empty(::cStatus)
			lPedIntegr 	:= ::ResIntPedido(oPedido, cTipo, cEmpFor, cFilFor)		    
			lPedIntegr 	:= ::TrocaStatus(lPedIntegr, cEmpFor, cFilFor)
			lPedIntegr	:= ::GrvNumPed(lPedIntegr, cEmpFor, cFilFor)
			lPassou		:= .T.

		EndIf

		::ResAddTrans(oPedido, cEmpFor, cFilFor)

		If UPPER(AllTrim(::cStatPed)) $ 'PENDING' .AND. AllTrim(::cApi) == 'RESULTATE'
			If Depositado(::cAPI, ::cOrderID, ::cSequence, oPedido:nTotal) .and. (cTipo == 'B2B' .OR. AllTrim(cTipo) == '')
				oPedido:Aprovar()

				::cStatPed		:= oPedido:cStatus

			EndIf

		EndIf

		If UPPER(AllTrim(::cStatPed)) $ UPPER('processing/invoiced/pick_and_pack/ready_for_handling/complete/delivered') //'PENDING/HOLDED/PENDING_PAYMENT'	
			//Caso o pedido esteja integrado e com o pagamento aprovado, sera feito a mudança de status do pedido para Iniciar Manuseio		
			If ::cStatus == "1"
				lPedIntegr 	:= ::ResAtuCondPag(oPedido, cEmpFor, cFilFor, cTipo)
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr, cEmpFor, cFilFor)
				lPassou		:= .T.

			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status
			If ::cStatus == "2"
				//lPedIntegr 	:= ::ResIntPedido(oPedido, cTipo, cEmpFor, cFilFor)

				If cTipo != 'B2B' //
					CheckVT4(::cApi,::cOrderID,::cSequence, Self)
				EndIf

				If ::cStatus == "2"
				
					lPedIntegr 	:= AlteraPrazoEnt(Self, ::cNumPed, ::cOrderID, ::cAPI, , cEmpFor, cFilFor)	
	
					lPedIntegr 	:= ::TrocaStatus(lPedIntegr, cEmpFor, cFilFor)
					lPassou		:= .T.
					
				EndIf

			EndIf

			//Caso o pedido ja esteja com as condições de pagamento integradas, começa a liberação de faturamento e troca de status
			If ::cStatus == "3"		                                        
				lPedIntegr 	:= ::LibPedido(cEmpFor, cFilFor)  
				lPedIntegr 	:= ::TrocaStatus(lPedIntegr, cEmpFor, cFilFor)
				lPassou		:= .t.

				If lPedIntegr	   			
					oPedido:Separar()	
				EndIf

			EndIf

		EndIf

		//Caso tenha mensagem de erro grava na tabela de integração
		::GrvMsgErro(cEmpFor, cFilFor)          

	EndIf

Return

/*/{Protheus.doc} ResIntPedido
Faz a integração dos pedidos no Protheus
@author henrique
@since 20/06/2017
@version 1.0
@param oPedido, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/Method ResIntPedido(oPedido, cTipo) Class SchedPedido

	Local oCliente 		:= SchedCliente():New(::cAPI)
	Local lRetorno		:= .F.
	Local aItens			:= {}
	Local nTotProd		:= 0
	Local cVendedor		:= ''	
	Local xItens 
	Local i				:= 0
	Local nQdtVenda		:= 0
	Local nPrecoVenda		:= 0
	Local cCondPag		:= ''
	Local nLoteDist		:= 0
	Local oResCliente		:= Nil

	Default oPedido		:= Nil
	Default cTipo			:= Nil

	Private lMsErroAuto 	:= .F.

	If oPedido == Nil
		Return .F.
	EndIf

	//Tratamento de Erro caso haja falha na integração com a VTEX
	If oPedido <> NIL

		xItens			:= oPedido:Itens
		xItens			:= AnaliseKit(xItens, ::cAPI)
		oPedido:Itens := xItens

		//xCliente		:= oPedido
		//xEndCliente	:= oPedido

		::aProdutos	:= {}
		::cTransp		:= ''
		::cTipoFrete	:= "C"
		::nValFrete	:= Round(oPedido:nTaxaEnvio,TamSx3("C5_FRETE")[2])

		If oPedido:nDiasEntrega > 0 
			::dDtEntrega	:= dDataBase+oPedido:nDiasEntrega
		Else
			::dDtEntrega	:= dDataBase+10
		EndIf

		If (cTipo == 'B2B' .AND. cEmpAnt == '08')
			cVendedor := ObtemVend('B2B TIMS')
		ElseIf ! Empty(oPedido:cMarketPlace)
			cVendedor := ObtemVend(oPedido:cMarketPlace)
		Else		 
			cVendedor := ObtemVend('SITE')
		EndIF

		If ! Empty(oPedido:cMetodEnvio)
			::cTransp		:= ::GetTransp(oPedido:cMetodEnvio)
		Endif

		::cStatPed		:= oPedido:cStatus 

		//Se o pedido já estiver criado, sai da rotina
		//Coloquei este código porque duas instancias estavam criando o pedido causa de 
		//simutâneamento, gerando duplicidade de pedidos de vendas
		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI))
			If AllTrim(VT1->VT1_STATUS) != ''
				Return .T.
			EndIf

		EndIf

		If ::cAPI == 'B2C-RESULT'
			lRetorno := oCliente:IncluiCliente(oPedido,oPedido,cTipo)

		Else			
			oResCliente	:= ResCliente():New(cTipo)
			oResCliente:cCNPJ := oPedido:cCNPJ
			oResCliente:GetCliente()

			//metodo para cadastrar ou atualizar cliente
			lRetorno := oCliente:IncluiCliente(oResCliente,oPedido,cTipo)
		EndIf

		If ::cAPI <> 'B2C-RESULT'
			cCondPag	:= POSICIONE('VTC', 2, xFilial('VTC')+Padr(oPedido:cCondPgtoWeb ,TamSx3("VTC_IDWEB")[1])+ 'RESULTATE', 'VTC_CONDPG')

			If Empty(cCondPag)
				aAdd(::aMsgErro,'A Condição de pagamento "'+ oPedido:cCondPgtoWeb +'" cadastrada no Web, não está vinculada a uma condição de pagamento do Protheus, favor cadastar na rotina Cond Pagto X Web.')
				Return	
			Else	
				oCliente:cCondPag := cCondPag
			EndIf
		EndIf

		//Atualiza tabela de integração
		If lRetorno .and. Len(xItens) > 0

			aItens := xItens
			nResto := 0
			//Recupera os produtos e quantidades para solicitar estoque em outra loja caso estoque seja compartilhados
			For i := 1 to Len(aItens)

				If ::dDtEntrega == nil .Or. ::dDtEntrega == CTOD('')				
					::dDtEntrega	:= dDataBase+10

				EndIf

				lAchou 	:= .F.
				cProduto 	:= ''
				DbSelectArea('VT9')
				VT9->(DbSetOrder(1))
				If Dbseek(xFilial('VT9')+ padr('RESULTATE', TAMSX3('VT9_API')[1], ' ')+ aItens[i]:cProdutoWeb) .and. AllTrim(VT9->VT9_IDWEB) == AllTrim(aItens[i]:cProdutoWeb)
					cProduto := VT9->VT9_PRODUT
					lAchou := .T.
				EndIf

				If lAchou
					If SB1->(dbSeek(xFilial('SB1')+cProduto))
						nLoteDist := SB1->B1_YLMDIST
						If SB1->B1_TIPO == 'KT'
							nLoteDist := 1
							cProduto := aItens[i]:cCodSku

						EndIf
					EndIf 
				EndIf 

				If lAchou
					DbSelectArea('SB1')
					DbSetOrder(1)

					nQdtVenda 		:= aItens[i]:nQde
					nPrecoVenda 	:= aItens[i]:nVlrUnit				

					If SB1->(DbSeek(xFilial('SB1')+cProduto))

						If nLoteDist > 1
							nQdtVenda *= nLoteDist
							nPrecoVenda /= nLoteDist
						EndIf

					EndIf

					aAdd(::aProdutos,{StrZero(i,TamSX3("C6_ITEM")[1]),;
					cProduto,;
					nQdtVenda,; //Valor já com o desconto
					nPrecoVenda,;
					.t.,;
					::dDtEntrega })	
					nTotProd += nQdtVenda*nPrecoVenda

				Else
					aAdd(::aMsgErro,'Não foi encontrado o produto "'+aItens[i]:cCodSku+'" no cadastro de Produto X Web!')
					lRetorno := .F.
				EndIf					
			Next

			//CALCULA PERCENTUAL DE DESCONTO     
			If oPedido:nDesconto > 0
				::nPercDesc	:= Round(oPedido:nDesconto/nTotProd*100,TamSx3("C5_DESC1")[2])
			Else
				::nPercDesc	:= 0
			EndIf

			If ::nPercDesc >= 100			
				lRetorno := .F.
				aAdd(::aMsgErro,"Não é permitido desconto acima de 100%!")				
			EndIf

			If lRetorno
				::GeraPedido(oCliente, cVendedor) 
			EndIf	    

		Else			   
			//inclui mensagens de erro no vetor principal
			::AddErro(oCliente:aMsgErro)
			lRetorno := .F.

		EndIf

	Else		
		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para integração inicial!")

	EndIf

Return lRetorno

/*/{Protheus.doc} ResAtuCondPag
Atualiza as condições de pagamento dos títulos.  
Analisa qual a administradora financeira para grava na tabela SL4.
@author henrique
@since 20/06/2017
@version 1.0
@param oPedido, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/Method ResAtuCondPag(oPedido, cEmpFor, cFilFor,cTipo) Class SchedPedido

	Local lRetorno		:= .f.
	Local cOrigem 		:= Padr("MATA460",TamSx3("L4_ORIGEM")[1])

	Local i
	Local z
	Local nQtdParcelas	:= 0
	Local cPagamento		:= ""
	Local nValor			:= 0

	Local cFormaID		:= ""
	Local cNumCart		:= ""
	Local cForma			:= ""
	Local cAdmFinanc		:= Space(TamSx3("AE_COD")[1])
	Local cDescAdmFin		:= ""
	Local cTid				:= ""
	Local cNSU				:= ""
	Local cDescPag		:= ""
	Local cYObs			:= ""
	Local dVencimento
	Local cCliente		:= ''
	Local lMetodoAlter	:= .F.
	Local nValorRes		:= 0
	Local lCriarSL4 	:= .T. 
	Local lGravou := .F.

	Default cTipo := ''

	If oPedido <> NIL

		Begin Transaction

			SC5->(dbSetOrder(1))	                                    
			If SC5->(dbSeek(xFilial("SC5")+::cNumPed))
				cCliente := SC5->C5_CLIENTE 

				//apaga informações de pagamento anteriores
				SL4->(dbSetOrder(1))
				If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))

					While SL4->(!Eof()) .and. xFilial("SL4")+SC5->C5_NUM+cOrigem == SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM

						RecLock("SL4",.f.)			
						SL4->(dbDelete())
						SL4->(msUnLock())

						SL4->(dbSkip())

					EndDo

				EndIf

				lCriarSL4 := .T.

				//verifica se existe a tag PAYMENT			 
				If Len( oPedido:Adquirente ) > 0 //.and. ! Empty(oPedido:DadosPgto[1]:cMetodo)
					For i := 1 to Len(oPedido:Adquirente)
						nValorRes 	:= 0
						lRetorno	:= .T.

						lMetodoAlter := Len( oPedido:DadosPgto ) > 0 .and. ! Empty(oPedido:DadosPgto[1]:cMetodo) 
						If lMetodoAlter .AND. 'FATURADO' == UPPER(oPedido:DadosPgto[1]:cMetodo)
							lRetorno	:= .F.

						ElseIf lMetodoAlter .AND. 'BOL' $ UPPER(oPedido:DadosPgto[1]:cFormaPgto) .AND. ;
						UPPER('mercadopago_customticket') $ UPPER(oPedido:DadosPgto[1]:cMetodo)
							cTid			:= ""
							cNSU			:= ""
							cNumCart		:= ""
							nQtdParcelas	:= 1
							cNumCart		:= oPedido:cPedMPlace
							cPagamento		:= UPPER(oPedido:Adquirente[i]:cName)

							If AllTrim(cPagamento) == 'MERCADOPAGO'
								cPagamento := 'MPBOLE'
							EndIf

							cAdmFinanc		:= Space(TamSx3("AE_COD")[i])
							cAdmFinanc 		:= ::GetAdmFinanc(cPagamento,1, 'BOLETO')

						ElseIf lMetodoAlter .AND. 'BOLETO' $ UPPER(oPedido:DadosPgto[1]:cMetodo) //Boleto bancário
							cTid			:= ""
							cNSU			:= ""
							nQtdParcelas	:= 1
							cNumCart		:= oPedido:cPedMPlace
							cPagamento		:= UPPER(oPedido:Adquirente[i]:cName)
							cAdmFinanc		:= Space(TamSx3("AE_COD")[i])
							cAdmFinanc 		:= ::GetAdmFinanc(cPagamento,1, 'BOLETO')

						ElseIf cTipo == 'B2B' .and. Empty(oPedido:Adquirente[i]:cName)
							lCriarSL4 := .F.

						Else
							nQtdParcelas	:= oPedido:Adquirente[i]:nQdeParcelas
							cPagamento 		:= UPPER(oPedido:Adquirente[i]:cName)

							If AllTrim(cPagamento) == 'MERCADOPAGO'
								cPagamento := 'MPCART'
							EndIf

							cAdmFinanc 		:= ::GetAdmFinanc(cPagamento,nQtdParcelas)						
							cNumCart		:= oPedido:cPedMPlace//oPedido:Adquirente[i]:cNumAutoriz
							nValorRes		:= oPedido:Adquirente[i]:nValor					
							cTid			:= oPedido:Adquirente[i]:cTID
							cNSU			:= ""

							cYObs	+= iif(Empty(cYOBS),"",", ")
							cYObs	+= iif(Empty(cYOBS),""," - ")+"NSU: "+cNSU
							cYObs	+= iif(Empty(cYOBS),""," - ")+"TID: "+cTid
							cYObs	+= iif(Empty(cYOBS),""," - ")+"AUTORIZACAO: "+cNumCart

						EndIf

						If nValorRes > 0
							nValor := nValorRes
						Else
							nValor		:= oPedido:nTotal
						EndIf			     		 	   							       	                               

						cDescPag	+= iif(Empty(cDescPag),"",", ")
						cDescPag	+= Upper(	cPagamento+;
						" R$ "+AllTrim(Transform(nValor,PesqPict("SE1","E1_VALOR")))+;
						iif(nQtdParcelas>1," - PARCELAS: "+cValtoChar(nQtdParcelas),""))

						If nValor > 0 .and. lCriarSL4

							For z := 1 to nQtdParcelas

								SAE->(dbSetOrder(1))
								If SAE->(dbSeek(xFilial("SAE")+cAdmFinanc))

									//Caso seja parcelado 
									dVencimento	:= dDatabase+(30*z)
									cFormaID		:= cValToChar(z)
									cForma			:= SAE->AE_TIPO
									cDescAdmFin	:= SAE->AE_COD+" - "+SAE->AE_DESC

								Else

									dVencimento 	:= dDatabase+7
									cFormaID		:= cValToChar(z)
									cForma			:= "NF"
									cDescAdmFin	:= ""																			

								EndIf

								lGravou := .F.
								If AllTrim(cPagamento) == 'MERCADOPAGO'
									//Soma as parcelas com a mesma data de vencimento
									SL4->(dbSetOrder(1))
									If SL4->(dbSeek(xFilial("SL4")+SC5->C5_NUM+cOrigem))
										If SL4->L4_DATA == dVencimento
											lGravou := .T.
											RecLock("SL4",.F.)
											SL4->L4_VALOR	+= Round(nValor/nQtdParcelas,TamSx3("L4_VALOR")[2])										
											SL4->(msUnLock())

										EndIf

									EndIf

								EndIf

								If !lGravou							
									RecLock("SL4",.T.)
									SL4->L4_FILIAL	:= xFilial("SL4")
									SL4->L4_NUM		:= SC5->C5_NUM
									SL4->L4_ORIGEM	:= cOrigem
									SL4->L4_DATA	:= dVencimento
									SL4->L4_VALOR	:= Round(nValor/nQtdParcelas,TamSx3("L4_VALOR")[2])
									SL4->L4_FORMA	:= cForma
									SL4->L4_FORMAID	:= cFormaID
									SL4->L4_NUMCART	:= cNumCart
									SL4->L4_ADMINIS	:= cDescAdmFin
									SL4->(msUnLock())

								EndIf

							Next

						EndIf

					Next

					RecLock("SC5",.f.)	
					SC5->C5_MENNOTA	:= cDescPag

					If SC5->(FieldPos("C5_YOBS")) > 0
						SC5->C5_YOBS := cYObs
					EndIf   

					SC5->(msUnLock())

				EndIf

			Else

				aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+::cNumPed+" na base de dados, favor verificar a tabela SC5!")

			EndIf			

		End Transaction

	Else

		aAdd(::aMsgErro,"Não foi possivel recuperar o pedido "+AllTrim(::cOrderID)+" na "+AllTrim(Capital(::cAPI))+" para criação das formas de pagamento!")

	EndIf                

	//caso tenha realizado a atualização do pagamento o sistema atualiza as datas de pagamento
	If lRetorno

		VT1->(dbSetOrder(1))
		If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))

			If !IsBlind()		
				RecLock("VT1",.f.)    
			EndIf

			VT1->VT1_DATAPG	:= dDataBase
			VT1->VT1_HORAPG	:= Time()

			VT1->VT1_DATAUL	:= dDataBase
			VT1->VT1_HORAUL	:= Time()

			If !IsBlind()		
				VT1->(msUnlock())
			EndIf

		EndIf

	EndIf

	Return lRetorno

	/*/{Protheus.doc} ResPedCanc
	Cancela os pedidos no Protheus
	@author henrique
	@since 20/06/2017
	@version 1.0
	@param oPedido, objeto, (Descrição do parâmetro)
	@example
	(examples)
	@see (links_or_references)
	/*/Method ResPedCanc(oPedido, cEmpFor, cFilFor) Class SchedPedido
	Local lRet := .T.

	Default cEmpFor := ''
	Default cFilFor := ''

	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cPedMPlace),TamSx3("VT1_SEQUEN")[1]) 

	VT1->(dbSetOrder(1))     	
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/)) .and. VT1->VT1_STATUS <> "C"

		lPedIntegr 	:= ::CriaInteg(cEmpFor, cFilFor)
		lRet			:= .F. 

		If lPedIntegr            
			If ::CancelInt(cEmpFor, cFilFor)	    
				RecLock("VT1",.F.)
				VT1->VT1_STATAN	:= ''
				VT1->VT1_STATUS	:= "E"
				VT1->(msUnLock())
				lRet		:= .T. 
			Else

				//Caso tenha mensagem de erro grava na tabela de integração
				::GrvMsgErro(cEmpFor, cFilFor)

				VT1->(dbSetOrder(1))     	
				If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))

					RecLock("VT1",.F.)
					VT1->VT1_STATUS	:= "C"
					VT1->VT1_STATAN	:= ""
					VT1->(msUnLock())
					lRet		:= .T. 

				EndIf
			EndIf

		EndIf

	EndIf

	Return lRet

	/*/{Protheus.doc} ResPedPagNeg
	Deleta os pedidos no Protheus que foram cancelados na Resultate
	@author henrique
	@since 20/06/2017
	@version 1.0
	@param oPedido, objeto, (Descrição do parâmetro)
	@example
	(examples)
	@see (links_or_references)
	/*/Method ResPedPagNeg(oPedido, cEmpFor, cFilFor) Class SchedPedido
	Default cEmpFor := ''
	Default cFilFor := ''

	If Empty(cEmpFor) .or. Empty(cFilFor)
		Return
	EndIf

	::cOrderID 	:= Padr(Upper(oPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	::cSequence	:= Padr(Upper(oPedido:cPedMPlace),TamSx3("VT1_SEQUEN")[1]) 

	VT1->(dbSetOrder(1))     	
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))

		::CriaInteg()   
		If ::CancelInt()

			If oPedido:Cancelar()

				RecLock("VT1",.F.)
				VT1->VT1_STATAN	:= ''
				VT1->VT1_STATUS	:= "E"
				VT1->(msUnLock())

			EndIf

		EndIf

		//Caso tenha mensagem de erro grava na tabela de integração
		::GrvMsgErro(cEmpFor, cFilFor)

	EndIf

	Return

	/*/{Protheus.doc} QdeVT4
	(long_description)
	@author henrique
	@since 27/07/2017
	@version 1.0
	@param ${param}, ${param_type}, ${param_descr}
	@return ${return}, ${return_description}
	@example
	(examples)
	@see (links_or_references)
	/*/Static Function QdeVT4(cApi, cOrderID, cSequence)
	Local cAlias 	:= GetNextAlias()
	Local nRet		:= 0 

	BeginSql Alias cAlias
		SELECT
		COUNT(*) AS QDE	 
		FROM
		%Table:VT4% VT4
		WHERE
		VT4_FILIAL = %xFilial:VT4% AND VT4.%NotDel%
		AND VT4_ORDID = %Exp:cOrderID%
		AND VT4_API = %Exp:cApi%
		AND VT4_SEQUEN = %Exp:cSequence%
	EndSql

	nRet := (cAlias)->QDE

	(cAlias)->(DbCloseArea())

	Return nRet

	/*/{Protheus.doc} Depositado
	(long_description)
	@author henrique
	@since 11/08/2017
	@version 1.0
	@param ${param}, ${param_type}, ${param_descr}
	@return ${return}, ${return_description}
	@example
	(examples)
	@see (links_or_references)
	/*/Static Function Depositado(cAPI, cOrderID, cSequencia, nValor)
	Local aArea 	:= GetArea()
	Local cAlias 	:= GetNextAlias()
	Local lRet		:= .F.
	Local cValor	:= ''

	Default cOrderID		:= ''
	Default cAPI			:= ''
	Default cSequencia	:= ''
	Default nValor 		:= 0

	If Empty(cOrderID)
		Return .F.
	EndIf

	cValor := cValToChar(nValor)	

	BeginSql Alias cAlias

		SELECT 
		COUNT(*) QDE 
		FROM 
		%Table:VT1% VT1
		JOIN %Table:SC5% SC5 ON SC5.%NotDel% AND SC5.C5_FILIAL = %xFilial:SC5% AND SC5.C5_NUM = VT1.VT1_NUMPED
		JOIN %Table:SZ3% SZ3 ON SZ3.%NotDel% AND SZ3.Z3_FILIAL = %xFilial:SZ3% AND Z3_STATUS = 'N' AND Z3_CODCLI = SC5.C5_CLIENTE AND Z3_TIPO = 'RA'
		JOIN %Table:SE1% SE1 ON SE1.%NotDel% AND SE1.E1_FILIAL = %xFilial:SE1% AND SE1.E1_NUM = Z3_CODIGO AND SE1.E1_PREFIXO = 'DUP' AND SE1.E1_TIPO = SZ3.Z3_TIPO
		WHERE 
		VT1.%NotDel% AND VT1_FILIAL = %xFilial:VT1% 
		AND VT1.VT1_ORDID = %Exp:cOrderID%
		AND VT1.VT1_SEQUEN = %Exp:cSequencia%
		AND VT1.VT1_API = %Exp:cAPI%
		AND Z3_VALOR = %Exp:nValor%
	EndSql

	lRet := (cAlias)->QDE > 0

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIF 

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} SeparaPedido
(long_description)
@author henrique
@since 05/09/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function SeparaPedido(oSched, oPedido, cAPI)
	Local aDivPed 	:= {}
	Local xItens		:= Nil
	Local aProdutos	:= {}
	Local cEmpEst		:= ''
	Local cFilEst		:= ''
	Local nI			:= 0
	Local aProdEst	:= {}
	Local cProduto	:= ''
	Local oPed		 	:= Nil

	xItens			:= oPedido:Itens
	aProdutos		:= AnaliseKit(xItens, cAPI)

	For nI := 1 to Len(aProdutos)
		cProduto 	:= ''
		DbSelectArea('VT9')
		VT9->(DbSetOrder(1))
		If VT9->(Dbseek(xFilial('VT9')+ padr(cAPI, TAMSX3('VT9_API')[1], ' ')+ aProdutos[nI]:cProdutoWeb))
			cProduto 	:= VT9->VT9_PRODUT
		EndIf

		If cEmpAnt == '09'
			cEmpEst	:= '08'
			cFilEst	:= '01'

		Else
			cEmpEst	:= cEmpAnt
			cFilEst	:= cFilAnt

		EndIf

		//Verifica o cadastro de produto
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+cProduto))

			ZZL->(dbSetOrder(1))
			If ( ZZL->(dbSeek(xFilial("ZZL")+SB1->B1_FABRIC)) .and. ZZL->ZZL_EMPFOR+ZZL->ZZL_FILFOR <> cEmpAnt+cFilAnt )
				cEmpEst := ZZL->ZZL_EMPFOR
				cFilEst := ZZL->ZZL_FILFOR	

			EndIf
		EndIf

		nPos := 0 

		If Len(aProdEst) == 0

			aAdd(aProdEst, { cEmpEst, cFilEst , {aProdutos[nI]}} )

		Else

			nPos := aScan(aProdEst, {|x| x[1]+x[2] == cEmpEst + cFilEst})

			If nPos > 0
				aAdd(aProdEst[nPos, 3], aProdutos[nI] )

			Else				
				aAdd(aProdEst, { cEmpEst, cFilEst , {aProdutos[nI]}} )

			EndIf

		EndIf

	Next

Return aProdEst

/*/{Protheus.doc} AlterTransTims
Altera a transportadora no Tims
@author henrique
@since 13/09/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function AlterTransTims(aParam)

	Local cIdWeb		:= aParam[1]		
	Local cAPI			:= aParam[2]
	Local cCNPJ			:= aParam[3]
	Local cTransVT6		:= aParam[4]
	Local cAPIVT6		:= "HIPERVAREJ"
	Local oPedGrupo 	:= SchedPedido():New()
	Local lRet			:= .T.

	//atualiza variaveis para conexão de grupo
	oPedGrupo:cEmp		:= "08"
	oPedGrupo:cFil		:= "01"
	oPedGrupo:cAPI		:= PadR(cAPI,10)
	oPedGrupo:cOrderID	:= PadR(cIdWeb,30)
	oPedGrupo:cCNPJCli	:= cCNPJ

	// Informa qual é a transportadora correios no Hipervarejo
	// para realizar um de/para com a transportadora no TIMS
	// e realizar a troca para priorização da seperação
	oPedGrupo:cTransVT6:= cTransVT6
	oPedGrupo:cAPIVT6	:= cAPIVT6

	//chama metodos para inciar ambiente
	oPedGrupo:IniciaAmb()
	lRet := oPedGrupo:AlterTransp()
	oPedGrupo:FinalAmb()

Return lRet

/*/{Protheus.doc} AlterTransTims
Metodo criado para altera a tranpostadora do Tims para a Hiper 
quando o método de entrega for via transportadora
@author henrique
@since 13/09/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Method AlterTransp() Class SchedPedido
	Local cTranspCorre 	:= SuperGetMv("VT_CORREIO",.F.,"000903")
	Local lRet				:= .T. 
	Local oCliente		:= SchedCliente():New(::cAPI)

	oCliente:VerifCliente(::cCNPJCli)

	// Verifica se a transportadora tem relação com a VT6
	// na API HIPER para realizar a troca, caso nao encontre
	// utilize a transportadora do parametro
	VT6->(dbSetOrder(1))
	If VT6->(dbSeek(xFilial("VT6")+::cAPIVT6 +::cTransVT6))

		cTranspCorre := VT6->VT6_TRANSP

	EndIf

	SA4->(dbSetOrder(1))
	If ! SA4->(dbSeek(xFilial("SA4")+cTranspCorre))
		aAdd(::aMsgErro,'A Transportadora do cadastrada no parâmetro "VT_CORREIO" ou "VT6" não existe. Favor gerar um chamado para a equipe de T.I. fazer a alteração.')
		Return .F.		
	EndIf


	SC5->(dbOrderNickName("YPEDWEB"))
	If SC5->(dbSeek(xFilial("SC5")+Padr(::cAPI,TamSx3("C5_YAPI")[1])+Padr(::cOrderID,TamSx3("C5_YPEDWEB")[1]) +oCliente:cCliente+oCliente:cLoja ))
		While ! SC5->(Eof()) .AND. SC5->C5_CLIENTE == oCliente:cCliente .AND. SC5->C5_LOJACLI == oCliente:cLoja .AND. ;
		AllTrim(SC5->C5_YPEDWEB) == AllTrim(::cOrderID) .AND. AllTrim(SC5->C5_YAPI) == AllTrim(::cAPI)

			If SC5->(SimpleLock())
				SC5->C5_TRANSP := cTranspCorre

				SC5->(MsUnLock())
				lRet := .T.
			Else
				lRet := .F.

				Exit
			EndIf

			SC5->(DbSkip())

		EndDo

	Else
		aAdd(::aMsgErro,'Pedido não encontrado na empresa 08. Não é possível alterar a transportadora.')
		lRet := .F.
	EndIf

	Return lRet

/*/{Protheus.doc} ResAddTrans
Adiciona a transportadora ao pedido caso o mesmo não tenho sido feito anteriormente
@author henrique
@since 19/09/2017
@version 1.0
@param oPedido, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/Method ResAddTrans(oPedido, cEmpFor, cFilFor) Class SchedPedido
	Local aAreaVT1 	:= VT1->(GetArea())
	Local aAreaSC5 	:= SC5->(GetArea())
	Local cTransp		:= ''
	Local cPedido		:= ''

	Default oPedido 	:= nil
	Default cEmpFor	:= ''
	Default cFilFor	:= ''

	//	If Empty(cEmpFor) .or. Empty(cFilFor)
	//		Return
	//	EndIf

	If Empty(::cOrderID) .OR. oPedido == NIL
		Return
	EndIf

	If ! Empty(oPedido:cMetodEnvio)
		cTransp		:= ::GetTransp(oPedido:cMetodEnvio)
	Endif

	If Empty(cTransp)
		Return
	EndIf

	VT1->(dbSetOrder(1))
	If VT1->(dbSeek(xFilial("VT1")+::cOrderID+::cAPI/*+cEmpFor+cFilFor*/))
		cPedido := VT1->VT1_NUMPED
	EndIf

	If Empty(cPedido)
		Return
	EndIf

	DbSelectArea('SC5')
	DbSetOrder(1)
	If SC5->(DbSeek(xFilial('SC5')+cPedido))
		If Empty(SC5->C5_TRANSP)
			RecLock('SC5',.F.)
			SC5->C5_TRANSP := cTransp
			SC5->(MsUnLock())
		EndIf
	EndIf

	::cTransp := cTransp

	VT1->(RestArea(aAreaVT1))
	SC5->(RestArea(aAreaSC5))

Return

/*/{Protheus.doc} ResPedBco
(long_description)
@author henrique
@since 10/11/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Method ResPedBco(cTipo) Class SchedPedido
	Local oAnyPedido := Nil
	Local cAlias 	 := GetNextAlias()
	Local cAPI		 := ::cAPI
	Local oPedido	 := Nil
	Local aRecSC6  	 := {}

	Default cTipo 	 := 'B2C'	

	Check4_SC9(cAPI)	

	BeginSql Alias cAlias
		SELECT
		VT1_ORDID, VT1_NUMPED, VT1_STATUS, VT1_STATAN
		FROM
		%Table:VT1% VT1
		WHERE
		VT1.VT1_FILIAL = %xFilial:VT1%
		AND VT1.%notdel%
		AND	VT1.VT1_API = %Exp:cAPI%			
		AND VT1.VT1_STATUS IN (' ', '1', '2', '3')		
		//AND VT1.VT1_ORDID IN ('200051052')
	EndSQL

	oPedido := ResPedCli():New(cTipo)

	(cAlias)->(dbGoTop())
	While !(cAlias)->(Eof())
		::cOrderID := (cAlias)->VT1_ORDID

		If oPedido:GetPedido((cAlias)->VT1_ORDID)
			::cStatPed	:= AllTrim(oPedido:cStatus)			

			//Realiza estorno de liberação de estoque e credito
			SC9->(dbSetOrder(1))
			If SC9->(dbSeek(xFilial('SC9')+(cAlias)->VT1_NUMPED))

				While SC9->(!Eof()) .and. xFilial('SC9')+(cAlias)->VT1_NUMPED == SC9->C9_FILIAL+SC9->C9_PEDIDO

					If Empty(SC9->C9_NFISCAL)

						SC6->(dbSetOrder(1))
						SC6->(dbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))

						If SC6->C6_QTDVEN-SC6->C6_QTDENT > 0

							aAdd(aRecSC6,SC6->(Recno()))

						EndIf

						Begin Transaction
							SC9->(a460Estorna())
						End Transaction

					EndIf

					SC9->(dbSkip())

				EndDo

			EndIf			

			If Type('oPedido:DadosPgto[1]:cNomeAdquir') == 'C'			
				::cNomeAdquir := UPPER(oPedido:DadosPgto[1]:cNomeAdquir)
			End if

			If UPPER(AllTrim(::cStatPed)) $ 'FINALIZADO' .AND. UPPER(oPedido:cState) == 'CANCELED'
				lCancelou := ::ResPedCanc(oPedido)//, cEmpAnt, cFilAnt)  

			ElseIf UPPER(AllTrim(::cStatPed)) $ 'CANCELED'
				lCancelou := ::ResPedCanc(oPedido)//, cEmpAnt, cFilAnt)

				If ! lCancelou
					Exit

				EndIf

				If lCancelou .and. UPPER(AllTrim(::cStatPed))== 'CANCELED'	
					oPedido:Finalizar()

				EndIf

			Else
				::CriaPedRes(cTipo, oPedido)

			EndIf

		EndIf

		(cAlias)->(DbSkip())

	EndDo

	FreeObj(oPedido)

	(cAlias)->(dbCloseArea())

Return

Method ResIntegra(cOrderID, lPulaStatus) Class SchedPedido

	Local oPedido		:= Nil	
	Local lTrasDados	:= .T.
	Local cTipo := 'B2C'
	Default lPulaStatus := .F.

	cOrderID 	:= Padr(cOrderID,TamSx3("VT1_ORDID")[1])
	oPedido := ResPedCli():New(cTipo)

	lTrasDados := .T.
	If lPulaStatus
		If VT1->(DbSeek(xFilial('VT1')+cOrderID+'B2C-RESULT'))
			lTrasDados := !(VT1->VT1_STATUS $ '4/5/6/7/8/9/E/C') ///Caso esteja nestes status não será mais processados
		EndIf

		//Vai para o próximo registro caso já esteja integrado no Protheus
		If !lTrasDados
			Return
		EndIf
	EndIf

	If oPedido:GetPedido(AllTrim(cOrderID))

		If PedidoAnyML(oPedido, ::cAPI, Self)
			Return
		EndIf

		::CriaPedRes(cTipo, oPedido)

	EndIf

Return

/*/{Protheus.doc} B2CPedidos
(long_description)
@author henrique
@since 26/09/2017
@version 1.0
@param cTipo, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Method B2CPedidos() Class SchedPedido
	Local oResPedido 	:= Nil
	Local nI, nJ		:= 0
	Local oPedido		:= Nil
	Local aPedidos		:= {}
	Local lCancelou		:= .F.
	Local cOrderID		:= ''

	Local cTipo := 'B2C'

	oResPedido 		:= ResPedidos():New(cTipo)

	//processing
	oResPedido:GetAllAprovado(.T.)	
	For nI := 1 to Len(oResPedido:aPedidos)

		::ResIntegra(oResPedido:aPedidos[nI],.T.)

	Next	

	oResPedido:aPedidos := {}

	//Tratamentos dos pedidos pendente de pagamento
	//pending (Transação realizada, mas sem a confirmação de pagamento).
	oResPedido:GetAllPending(.T.)	
	For nI := 1 to Len(oResPedido:aPedidos)		
		::ResIntegra(oResPedido:aPedidos[nI],.T.)

	Next	


	oResPedido:aPedidos := {}

	//Tratamentos dos pedidos Aguardando Pagamento holded
	oResPedido:GetAllAguard(.T.)
	For nI := 1 to Len(oResPedido:aPedidos)	
		::ResIntegra(oResPedido:aPedidos[nI])

	Next	

	oResPedido:aPedidos := {}	

	//Tratamentos dos pedidos cancelados
	//Cancelled (cancelado)
	oResPedido:GetAllCancelado(.T.)	
	For nI := 1 to Len(oResPedido:aPedidos)	
		cOrderID 	:= Padr(oResPedido:aPedidos[nI],TamSx3("VT1_ORDID")[1])
		oPedido := ResPedCli():New(cTipo)

		If oPedido:GetPedido(AllTrim(cOrderID))

			If PedidoAnyML(oPedido, ::cAPI, Self)
				Loop
			EndIf

			lCancelou := ::ResPedCanc(oPedido)//, cEmpAnt, cFilAnt)

			If ! lCancelou
				Exit

			EndIf

			If lCancelou
				oPedido:Finalizar()			
			EndIf
		EndIf

	Next	
	oResPedido:aPedidos := {}

	//Tratamentos dos pedidos reembolsados
	//closed
	oResPedido:GetAllReembols(.T.)	
	For nI := 1 to Len(oResPedido:aPedidos)
		cOrderID 	:= Padr(oResPedido:aPedidos[nI],TamSx3("VT1_ORDID")[1])
		oPedido := ResPedCli():New(cTipo)

		If oPedido:GetPedido(AllTrim(cOrderID))

			If PedidoAnyML(oPedido, ::cAPI, Self)
				Loop
			EndIf

			lCancelou := ::ResPedCanc(oPedido)//, cEmpAnt, cFilAnt)

			If ! lCancelou
				Exit

			EndIf

			If lCancelou
				oPedido:Finalizar()			
			EndIf
		EndIf

	Next	
	oResPedido:aPedidos := {}	

	FreeObj(oResPedido)

Return

/*/{Protheus.doc} PedidoDel
Obtem o código do pedido deletado para poder excluir os pedidos WEB para outros empresas
@author henrique
@since 10/11/2017
@version 1.0
@param cAPI, character, (Descrição do parâmetro)
@param cOrdID, character, (Descrição do parâmetro)
@param cEmpFor, character, (Descrição do parâmetro)
@param cFilFor, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function PedidoDel(cAPI, cOrdID, cEmpFor, cFilFor)
	Local cAlias := ''
	Local cPedido:= ''

	Default cAPI		:= ''
	Default cOrdID	:= ''
	Default cEmpFor	:= ''
	Default cFilFor	:= ''

	cEmpFor += cFilFor

	If Empty(cAPI) .OR. Empty(cOrdID)
		Return ''
	EndIf

	cAlias := GetNextAlias()

	//Obtem o pedido deletado
	BeginSql Alias cAlias
		SELECT C5_NUM  
		FROM %Table:SC5% SC5 (NOLOCK) 
		WHERE C5_FILIAL = %xFilial:SC5% AND C5_YPEDWEB = %Exp:cOrdID% AND C5_YAPI = %Exp:cAPI%
		AND (C5_YEMPFOR = %Exp:cEmpFor% or %Exp:cEmpFor% = '')
	EndSql

	(cAlias)->(DbGoTop())
	If (cAlias)->(!Eof())
		cPedido := (cAlias)->C5_NUM
	EndIf

	(cAlias)->(DbCloseArea())

Return cPedido

Static Function Check4_SC9(cAPI)	

	Local cAliasC9 := GetNextAlias()
	Local aRecSC6  := {}		

	BeginSql Alias cAliasC9
		SELECT
		VT1_ORDID, VT1_NUMPED, VT1_STATUS, VT1_STATAN, VT1_API
		FROM
		%Table:VT1% VT1
		WHERE
		VT1.VT1_FILIAL = %xFilial:VT1%
		AND VT1.%notdel%
		AND	VT1.VT1_API = %Exp:cAPI%
		AND VT1.VT1_STATUS IN ('P')			
		//AND VT1.VT1_STATAN IN ('4')	
	EndSQL	

	(cAliasC9)->(dbGoTop())

	While !(cAliasC9)->(Eof())

		/*
		If !SC9->(SimpleLock())
		SC9->(dbSkip())
		Loop
		EndIf
		*/

		//Realiza estorno de liberação de estoque e credito
		SC9->(dbSetOrder(1))
		If SC9->(dbSeek(xFilial('SC9')+(cAliasC9)->VT1_NUMPED))
			While SC9->(!Eof()) .and. xFilial('SC9')+(cAliasC9)->VT1_NUMPED == SC9->C9_FILIAL+SC9->C9_PEDIDO

				If Empty(SC9->C9_NFISCAL)

					SC6->(dbSetOrder(1))
					SC6->(dbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))

					If SC6->C6_QTDVEN-SC6->C6_QTDENT > 0

						aAdd(aRecSC6,SC6->(Recno()))

					EndIf

					Begin Transaction
						SC9->(a460Estorna())
					End Transaction

				EndIf

				SC9->(dbSkip())

			EndDo

			VT1->(dbSetOrder(1))
			If VT1->(dbSeek(xFilial("VT1")+(cAliasC9)->VT1_ORDID+(cAliasC9)->VT1_API))		  

				RecLock("VT1",.F.)		
				VT1->VT1_STATUS	:= ""		
				VT1->(msUnlock())	

			EndIf

		EndIf		

		(cAliasC9)->(DbSkip())

	EndDo	

Return

/*/{Protheus.doc} PedidoAnyML
Localiza os pedidos do Mercado Livre amarrado a API Anymarket que está entrando
pelo 00K.
@author henrique.reis
@since 11/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function PedidoAnyML(oResPedido, cAPI, oSelf)
	Local lRet 		:= .T.
	Local aArea 	:= GetArea()
	Local aAreaVT1	:= VT1->(GetArea())
	Local cSequence := ''

	Default oResPedido := nil

	If oResPedido == nil
		//Coloquei verdadeira para não ter possibilidade de duplicar pedidos no sistema
		Return .T. 
	EndIF

	//Analisa se o pedido é do Mercado Livre, caso não seja, o pedido deverá ser incluido no
	//Protheus normalmente
	If ! cAPI == 'B2C-RESULT' .or. !'MERCADO' $ UPPER(oResPedido:cMarketPlace)
		Return .F. 
	EndIF

	//Localiza os pedidos do Mercado Livre na Anymarket
	DbSelectArea('VT1')
	DbSetOrder(2)//VT1_FILIAL, VT1_SEQUEN, VT1_API, R_E_C_N_O_, D_E_L_E_T_

	cOrderID 	:= Padr(Upper(oResPedido:cIdWeb),TamSx3("VT1_ORDID")[1])
	cSequence	:= Padr(Upper(oResPedido:cPedMPlace),TamSx3("VT1_SEQUEN")[1])

	If Empty(cSequence)
		//Coloquei verdadeira para não ter possibilidade de duplicar pedidos no sistema
		Return .T. 
	EndIF

	lRet := VT1->(DbSeek(xFilial('VT1')+cSequence+'ANYMARKET'))	

	//Caso exista o pedido, um e-mail será enviado para que o usuário possa cancelar na 00K
	if lRet
		cAssunto 	:= 'Pedidos Mercado Livre na 00K'
		cMensagem 	:= 'O pedido "'+AllTrim(cOrderID)+'" da API "'+AllTrim(cAPI)+'" já está cadastrado no sistema com a API da Anymarket. O mesmo não será processado' + chr(13)+ chr(10) 
		cMensagem 	+= '<p>Pedido da Anymarket: "'+AllTrim(VT1->VT1_ORDID)+'"' + chr(13)+ chr(10)
		cMensagem 	+= '<p>Pedido Mercado Livre: "'+AllTrim(cSequence)+'"' 

		If oResPedido:Cancelar() .and. oResPedido:Finalizar()
			cMensagem 	+= '<p>Obs.: O pedido foi cancelado na Resultate'
		Else
			cMensagem 	+= '<p>Obs.: Não foi possível cancelar o pedido na Resultate'
		EndIf

		oSelf:EnvEmail(cAssunto, cMensagem)

	EndIf

	RestArea(aAreaVT1)
	RestArea(aArea)

Return lRet

Static Function CheckVT4(cApi, cOrderID, cSequence, Self)
	
	Local lRet := .F.

	VT4->(DbSetOrder(1))
	
	If VT4->(DbSeek(xFilial('VT4')+cApi+cOrderID+cSequence))
		lRet := .T.		
	Else
		VT1->(dbsetorder(1))
		
		If VT1->(dbSeek(xFilial("VT1")+cOrderID+cApi))
			
			If !IsBlind()
				RecLock("VT1",.F.)
			EndIf	
					
			VT1->VT1_STATUS := ""
			
			If !IsBlind()
				VT1->(msUnlock())
			Endif	

			//atualiza valor de status da integração
			::cStatus := VT1->VT1_STATUS
		EndIf
		
		lRet := .F.		
		
	EndIf

Return lRet