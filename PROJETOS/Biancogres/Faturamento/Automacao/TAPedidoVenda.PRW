#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TOPCONN.CH"

Class TPedidoVenda From LongClassName
	
	//atributos publico
	Public Data Pedido		as object
	
	//atributos privado
	Public Data _Opcao		as numeric
	Public Data _lOk		as logical
	Public Data _oResult	
	
	//metodos publicos	
	Public Method New() Constructor
	Public Method Incluir()		//incluir pedido
	Public Method GetNumPed()
	Public Method GetRecnosJson()
	Public Method GetSC5Recnos()
	Public Method GetSC6Recnos()
	
	//metodos privados
	Public Method _GetDoc()
	Public Method _GetCabecalho()	
	Public Method _GetItens()			
	Public Method _ValPed()
	Public Method _ValPedItem()
	Public Method _GatPed()
	Public Method _GatPedItem()			

EndClass


Method New(oPedido) Class TPedidoVenda

	::Pedido		:= oPedido
	::_oResult 		:= TPedidoVendaResultadoStruct():New()

Return()


Method _GetDoc() Class TPedidoVenda
	
	Local cDoc	:= ""
	
	cDoc := GetSxeNum("SC5", "C5_NUM")
	
	dbSelectArea("SC5")
	cMay := "SC5"+ Alltrim(xFilial("SC5"))
	
	SC5->(dbSetOrder(1))
	While ( DbSeek(xFilial("SC5")+cDoc) .Or. !MayIUseCode(cMay+cDoc) )
		cDoc := Soma1(cDoc, Len(cDoc))
	EndDo
	
Return cDoc

Method GetNumPed() Class TPedidoVenda

Return ::Pedido:Documento


Method GetRecnosJson() Class TPedidoVenda

	Local cJson			:= ''
	Local nId			:= ::GetSC5Recnos()
	Local aListaIds		:= ::GetSC6Recnos()
	Local oJson			:= Nil
	Local nI			:= 0
	
	
	cJson += '{C5,'+cvaltochar(nId)+'};'
	
	For nI:=1 To Len (aListaIds)
		
		cJson += '{C6,'+cvaltochar(aListaIds[nI])+'}'
		If (nI < Len(aListaIds))
			cJson += ';'
		EndIf
		
	Next nI
	
	
	/*cJson += '{"SC5": '+cvaltochar(nId)+','
	
	cJson += '"SC6":['
	For nI:=1 To Len (aListaIds)
		
		cJson += cvaltochar(aListaIds[nI])
		If (nI < Len(aListaIds))
			cJson += ','
		EndIf
		
	Next nI
	
	cJson += ']'
	
	cJson += '}'	
	*/
Return cJson 

Method GetSC5Recnos() Class TPedidoVenda
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local nId			:= 0 
	
	cQuery	+= "SELECT R_E_C_N_O_ FROM "+RetSQLName("SC5")+"		"
	cQuery	+= " WHERE 												" 
	cQuery	+= " C5_NUM	= '"+cValToChar(::Pedido:Documento)+"'		" 
	cQuery	+= " AND D_E_L_E_T_	= ''								" 
	
	TcQuery cQuery New Alias cAliasTrab	
		
	If !(cAliasTrab->(Eof()))
	
		nId := cAliasTrab->R_E_C_N_O_ 
		
	EndIf
	
	cAliasTrab->(DbCloseArea())	
	

Return nId

Method GetSC6Recnos() Class TPedidoVenda
	
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local nId			:= 0 
	Local aListaId		:= {}
	
	cQuery	+= "SELECT R_E_C_N_O_ FROM "+RetSQLName("SC6")+"		"
	cQuery	+= " WHERE 												" 
	cQuery	+= " C6_NUM	= '"+cValToChar(::Pedido:Documento)+"'		" 
	cQuery	+= " AND D_E_L_E_T_	= ''								" 
	
	TcQuery cQuery New Alias cAliasTrab	
		
	While !(cAliasTrab->(Eof()))
	
		nId := cAliasTrab->R_E_C_N_O_
		Aadd(aListaId, nId)
		
		cAliasTrab->(DbSkip())
	EndDo
	
	cAliasTrab->(DbCloseArea())	

Return aListaId


Method _GatPed() Class TPedidoVenda
	
Return 

Method _GatPedItem(nPosicao) Class TPedidoVenda
	
	//::Pedido:PedVenItens[nPosicao]
	
Return 


//todas validações do cabecalho
Method _ValPed() Class TPedidoVenda
	
	Local cMsgLog	:= ""
	Local lOk		:= .T.	
	Local aArea		:= GetArea()
	
	SE4->(dbSetOrder(1)) 
	If !SE4->(DbSeek(xFilial("SE4") + ::Pedido:CondPag))
		cMsgLog += "Condição de pagamento: "+::Pedido:CondPag +" não encontrado."+ CRLF
		lOk     := .F.
	EndIf
	
	
	If !(::Pedido:TipoPedido $ 'D_B')
		
		SA1->(dbSetOrder(1))
		If !SA1->(DbSeek(xFilial("SA1") + ::Pedido:Cliente + ::Pedido:LojaCli))
			cMsgLog += "Cliente " + ::Pedido:Cliente + ", Loja : " + ::Pedido:LojaCli+" não encontrado." + CRLF
			lOk     := .F.
		EndIf
	
	EndIf
	
	
	
	::_oResult:Add(lOk, cMsgLog, 0)
	
	RestArea(aArea)
	
Return 

//todas validações do item
Method _ValPedItem(oObj) Class TPedidoVenda
	
	Local cMsgLog	:= ""
	Local lOk		:= .T.	
	Local aArea		:= GetArea()
	Local oResult	:= Nil
	
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	
	If !SB2->(DbSeek(xFilial("SB2") + PADR(oObj:Produto, TamSx3("B1_COD")[1]) + oObj:Localiz))
					
		CriaSB2(oObj:Produto, oObj:Localiz)
	
	EndIf
	
	SB1->(dbSetOrder(1))
	If !SB1->(DbSeek(xFilial("SB1") + oObj:Produto))
		cMsgLog += "Produto: " + oObj:Produto +" não encontrado."+ CRLF
		lOk     := .F.
	EndIf

	SF4->(dbSetOrder(1))
	If !SF4->(DbSeek(xFilial("SF4") + oObj:Tes))
		cMsgLog += "TES: " + oObj:Tes +"  não encontrado."+ CRLF
		lOk     := .F.
	EndIf
	
	::_oResult:Add(lOk, cMsgLog, 0)
	
	RestArea(aArea)
	
Return 


Method _GetCabecalho() Class TPedidoVenda

	Local aCabec	:= {}
	
	//preenchimento de campos com base em outros campos
	::_GatPed() 
	
	//valida campos cabecalho ok
	::_ValPed() 
	
	If (::_Opcao == 3)
		::Pedido:Documento := ::_GetDoc()
	EndIf
	
	Aadd(aCabec, {"C5_NUM"		, ::Pedido:Documento		, Nil})
	Aadd(aCabec, {"C5_TIPO"		, ::Pedido:TipoPedido		, Nil})
	Aadd(aCabec, {"C5_CLIENTE"	, ::Pedido:Cliente			, Nil})
	Aadd(aCabec, {"C5_LOJACLI"	, ::Pedido:LojaCli			, Nil})
	Aadd(aCabec, {"C5_LOJAENT"	, ::Pedido:LojaEnt			, Nil})
	Aadd(aCabec, {"C5_CONDPAG"	, ::Pedido:CondPag			, Nil})
	Aadd(aCabec, {"C5_YSUBTP"	, ::Pedido:SubTp			, Nil})
	Aadd(aCabec, {"C5_EMISSAO"	, ::Pedido:DataEmissao		, Nil})
	
	
	Aadd(aCabec, {"C5_EMISSAO"	, ::Pedido:DataEmissao		, Nil})
	
	If (::Pedido:TipoPedido $ 'D_B')
		Aadd(aCabec, {"C5_YFORMA"	, "3"		, Nil})
	EndIf
	
	Aadd(aCabec, {"C5_VEND1"	, ::Pedido:Vendedor			, Nil})
	
	Aadd(aCabec, {"C5_TPFRETE"	, ::Pedido:TipoFrete		, Nil})
	Aadd(aCabec, {"C5_TRANSP"	, ::Pedido:Transportadora	, Nil})
	
	Aadd(aCabec, {"C5_YCONF"	, ::Pedido:Conf				, Nil})
	Aadd(aCabec, {"C5_YHORA"	, ::Pedido:Hora				, Nil})
	Aadd(aCabec, {"C5_MENNOTA"	, ::Pedido:Obs				, Nil})
	
	If !(Empty(::Pedido:CentroCusto))
		Aadd(aCabec, {"C5_YCC"		, ::Pedido:CentroCusto		, Nil})
	EndIf
	
	If !(Empty(::Pedido:ClasseValor	))
		Aadd(aCabec, {"C5_YCLVL"	, ::Pedido:ClasseValor		, Nil})
	EndIf
	
Return aCabec


Method _GetItens() Class TPedidoVenda
	
	Local nI		:= 0
	Local aLinha	:= {}
	Local aItens	:= {}
	Local oObj		:= Nil
	
	For nI := 1 To ::Pedido:PedVenItens:GetCount()
		
		oObj	:= ::Pedido:PedVenItens:GetItem(nI)
		aLinha	:= {}
		
		//preenchimento de campos com base em outros campos
		::_GatPedItem(nI) 
		
		//valida campos itens ok
		::_ValPedItem(oObj) 
		
		Aadd(aLinha,{"C6_NUM"		, ::Pedido:Documento						, Nil})
		
		If (::_Opcao == 3 .Or. Empty(oObj:Item))
			Aadd(aLinha,{"C6_ITEM"		, StrZero(nI, TamSx3("C6_ITEM")[1])					, Nil})
		Else	
			Aadd(aLinha,{"C6_ITEM"		, StrZero(oObj:Item, TamSx3("C6_ITEM")[1])			, Nil})
		EndIf
		
		
		Aadd(aLinha,{"C6_PRODUTO"	, oObj:Produto								, Nil})
		
		
		If (::Pedido:TipoPedido == 'D')
			
			DbSelectArea('SD1')
			SD1->(DbSetOrder(1))
			
			//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
			
			cChave := PADR(oObj:NumNFOri, TamSx3("D1_DOC")[1]) + PADR(oObj:SerieNFOri, TamSx3("D1_SERIE")[1]) + PADR(::Pedido:Cliente, TamSx3("D1_FORNECE")[1]) + PADR(::Pedido:LojaCli, TamSx3("D1_LOJA")[1]) + PADR(oObj:Produto, TamSx3("D1_COD")[1]) + PADR(oObj:ItemNFOri, TamSx3("D1_ITEM")[1])
			
			conout(cChave)
			If (SD1->(DbSeek(xFilial('SD1')+cChave)))
			
				Aadd(aLinha,{"C6_QTDVEN"	, oObj:QuantVen								, Nil})
				Aadd(aLinha,{"C6_PRCVEN"	, SD1->D1_VUNIT								, Nil})
				Aadd(aLinha,{"C6_PRUNIT"	, SD1->D1_VUNIT								, Nil})
				//Aadd(aLinha,{"C6_VALOR"		, SD1->D1_TOTAL								, Nil})
				
			EndIf
			
		Else
			
			Aadd(aLinha,{"C6_QTDVEN"	, oObj:QuantVen								, Nil})
			Aadd(aLinha,{"C6_PRCVEN"	, oObj:PrecoVen								, Nil})
			Aadd(aLinha,{"C6_PRUNIT"	, oObj:PrecoUni								, Nil})
			//Aadd(aLinha,{"C6_VALOR"		, oObj:Valor								, Nil})			
			
		EndIf
		
		
		Aadd(aLinha,{"C6_LOCAL"		, oObj:Localiz								, Nil})
		
		If (!Empty(oObj:Tes))
			Aadd(aLinha,{"C6_TES"		, oObj:Tes		 							, Nil})
		EndIf
		
		If (::Pedido:TipoPedido == 'D')
			
			Aadd(aLinha,{"C6_NFORI"		, oObj:NumNFOri								, Nil})
			Aadd(aLinha,{"C6_SERIORI"	, oObj:SerieNFOri							, Nil})
			Aadd(aLinha,{"C6_ITEMORI"	, oObj:ItemNFOri							, Nil})
			
		EndIf
			
				
		If (!Empty(oObj:PedCom))
			//Aadd(aLinha,{"C6_PEDCOM"	, oObj:PedCom	 							, Nil})
		EndIf
		
		
		Aadd(aItens, aLinha)
		
	Next nI   
	
Return aItens


Method Incluir() Class TPedidoVenda
	
	Local aCabec			:= {}
	Local aItens			:= {}
	
	Local lOk				:= .F.
	Local cMsgLog			:= ""
	Local nI				:= 0
	Local aErroAuto			:= {}
	
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.


	::_Opcao := 3
	aCabec	:= ::_GetCabecalho()
	aItens	:= ::_GetItens()
	
	If (::_oResult:Ok)
	
		Begin Transaction
		
			MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, ::_Opcao, .F.)
		
			If (!lMsErroAuto)
				lOk			:= .T.
				ConfirmSX8()
			Else
				
				RollBackSX8()
				DisarmTransaction()
				
				lOk			:= .F.
				aErroAuto	:= GetAutoGRLog()
			
				For nI := 1 To Len(aErroAuto)
					cMsgLog += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
				Next nI		
				
			EndIf
			
		End Transaction 
		
		::_oResult:Add(lOk, cMsgLog, ::GetSC5Recnos())
	
	EndIf
	
Return ::_oResult


//-----------------------------------------------------//

//classes struct

Class TPedidoVendaStruct from LongClassName

	Data Documento 				as character 
	Data Cliente				as character 
	Data LojaCli				as character
	Data LojaEnt				as character 
	Data CondPag				as character 
	Data SubTp					as character 
	Data TipoPedido				as character 
	Data DataEmissao			as date 
	Data Vendedor				as character
	Data TipoFrete				as character
	Data Transportadora			as character
	Data ClasseValor			as character
	Data CentroCusto			as character
	Data Conf					as character
	Data Hora					as character
	Data Obs					as character
	
	
	Data PedVenItens			
		
	Method New() Constructor

EndClass

Method New() Class TPedidoVendaStruct

	::Documento				:= ""	
	::Cliente				:= ""
	::LojaCli				:= ""
	::LojaEnt				:= ""
	::CondPag				:= ""
	::SubTp					:= ""
	::TipoPedido			:= ""
	::DataEmissao			:= Date()
	::TipoFrete				:= ""
	::Vendedor				:= ""
	::Transportadora		:= ""
	
	::ClasseValor			:= ""
	::CentroCusto			:= ""
	
	::Conf					:= ""
	::Hora					:= ""
	::Obs					:= ""
	
	
	::PedVenItens			:= ArrayList():New()
	
Return()


Class TPedidoVendaItemStruct From LongClassName
	
	Data Item		as character 
	Data Produto	as character 
	Data QuantVen	as numeric
	Data PrecoVen	as numeric
	Data PrecoUni	as numeric
	Data Valor		as numeric
	Data Tes		as character
	Data PedCom		as character
	Data Localiz	as character
	Data NumNFOri	as character
	Data SerieNFOri	as character
	Data ItemNFOri	as character
	
	Method New() Constructor
	
EndClass

Method New() Class TPedidoVendaItemStruct

	::Item		:= ""
	::Produto	:= ""
	::QuantVen	:= 0
	::PrecoVen	:= 0
	::PrecoUni	:= 0
	::Valor		:= 0
	::Tes		:= ""
	::PedCom	:= ""
	::Localiz	:= ""
	::NumNFOri	:= ""
	::SerieNFOri:= ""
	::ItemNFOri	:= ""
	
Return()

Class TPedidoVendaResultadoStruct From LongClassName
	
	Data Ok			as logical 
	Data Mensagem	as character 
	Data ID			as numeric
	
	Method New() Constructor
	Method Add()
	Method GetMensagem()
	
EndClass

Method New() Class TPedidoVendaResultadoStruct

	::Ok		:= .T.
	::Mensagem	:= ""
	::ID		:= 0

Return()

Method Add(lOk, cMensagem, cID) Class TPedidoVendaResultadoStruct

	::Ok		:= lOk
	::Mensagem	+= cMensagem
	::ID		:= cID
Return()


