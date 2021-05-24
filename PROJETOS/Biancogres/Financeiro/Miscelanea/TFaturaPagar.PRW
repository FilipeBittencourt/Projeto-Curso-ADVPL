#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TOPCONN.CH"

Class TFaturaPagar From LongClassName

	Data _oFatPagStruct		as object
	Data _oResult			as object

	Method New() Constructor
	Method Incluir()
	Method Cancelar()

	Method _GetCabecalho()
	Method _GetItens()
	Method _LoadDados(dDataDe, dDataAte, cForne, cLojaForne, cNatureza)
	Method _Valida()
	Method _UpdateVenc()
	Method _ExecBaixaDesc()
	Method _BaixaDesc()
	Method _CheckForn()
	Method GetProxNumFat()
	
EndClass

Method New(_oFatPagStruct) Class TFaturaPagar

	::_oFatPagStruct	:= _oFatPagStruct
	::_oResult 			:= TFaturaPagarResultadoStruct():New()

Return()


Method _Valida() Class TFaturaPagar

	Local cMsgLog	:= ""
	Local lOk		:= .T.
	Local aArea		:= GetArea()

	RestArea(aArea)

Return


Method _LoadDados(dDataDe, dDataAte, cForne, cLojaForne, cNatureza) Class TFaturaPagar

	Local aArea			:= GetArea()
	Local nDesc			:= 0
	Local nI			
	Local cLjGeracao	:= ""

	Default dDataDe		:= Nil
	Default dDataAte	:= Nil
	Default cForne		:= ""
	Default cLojaForne	:= ""
	Default cNatureza	:= ""

	If (::_oFatPagStruct:lLoadDados)

		For nI := 1 To ::_oFatPagStruct:oFatPagItens:GetCount()

			oObj	:= ::_oFatPagStruct:oFatPagItens:GetItem(nI)
			nId 	:= oObj:nId
			nDesc	+= oObj:nValorDesc

			If (nId != 0)

				DbSelectArea('SE2')
				SE2->(DbSetOrder(0))
				SE2->(DbGoTo(nId))

				If (!SE2->(Eof()))

					cForne 		:= SE2->E2_FORNECE
					cLojaForne	:= SE2->E2_LOJA
					cNatureza	:= SE2->E2_NATUREZ

					If (dDataDe == Nil .Or. SE2->E2_EMISSAO < dDataDe)
						dDataDe := SE2->E2_EMISSAO
					EndIf

					If (dDataAte == Nil .Or. SE2->E2_EMISSAO > dDataAte)
						dDataAte := SE2->E2_EMISSAO
					EndIf

				EndIf

			EndIf

		Next nI

		::_oFatPagStruct:cNumero := ::GetProxNumFat()

		cLjGeracao  := cLojaForne
		If(AllTrim(::_oFatPagStruct:cPrefixo) == 'APF')
			If (::_CheckForn(cForne))
				cLjGeracao := '01'
			EndIf
		EndIf
		
		::_oFatPagStruct:cNatureza			:= PADR(AllTrim(cNatureza)	, TamSX3("E2_NATUREZ")[1])
		::_oFatPagStruct:dDataDe			:= dDataDe
		::_oFatPagStruct:dDataAte			:= dDataAte
		::_oFatPagStruct:cFornecedor		:= PADR(AllTrim(cForne)		, TamSX3("E2_FORNECE")[1])
		::_oFatPagStruct:cLoja			    := PADR(AllTrim(cLjGeracao)	, TamSX3("E2_LOJA")[1])
		::_oFatPagStruct:cForneGeracao		:= PADR(Alltrim(cForne)		, TamSX3("E2_FORNECE")[1])
		::_oFatPagStruct:cLojaGeracao		:= PADR(AllTrim(cLjGeracao), TamSX3("E2_LOJA")[1])
		::_oFatPagStruct:cCondPag			:= "000"
		::_oFatPagStruct:nValorDesconto		:= nDesc

	EndIf

	RestArea(aArea)

Return()


Method _GetCabecalho(dDataDe, dDataAte, cForne, cLojaForne, cNatureza) Class TFaturaPagar

	Local aCabec	:= {}
	Local aItens	:= {}
	Local aArea			:= GetArea()
	Local nDesc			:= 0
	Local nI

	Default dDataDe		:= Nil
	Default dDataAte	:= Nil
	Default cForne		:= ""
	Default cLojaForne	:= ""
	Default cNatureza	:= ""
	
	//Descricao do Array aFatPag
	//[01] - Prefixo
	//[02] - Tipo
	//[03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)
	//[04] - Natureza
	//[05] - Data de
	//[06] - Data Ate
	//[07] - Fornecedor
	//[08] - Loja
	//[09] - Fornecedor para geracao
	//[10] - Loja do fornecedor para geracao
	//[11] - Condicao de pagto
	//[12] - Moeda
	//[13] - ARRAY com os titulos da fatura - Geradores
	//[14] - Valor de decrescimo
	//[15] - Valor de acrescimo

	::_LoadDados(dDataDe, dDataAte, cForne, cLojaForne, cNatureza)

	aItens := ::_GetItens()

	aCabec := { ;
		PADR(::_oFatPagStruct:cPrefixo, TamSX3("E2_PREFIXO")[1]),;
		PADR(::_oFatPagStruct:cTipo, TamSX3("E2_TIPO")[1]),;
		::_oFatPagStruct:cNumero,;
		::_oFatPagStruct:cNatureza,;
		::_oFatPagStruct:dDataDe,;
		::_oFatPagStruct:dDataAte,;
		::_oFatPagStruct:cFornecedor,;
		::_oFatPagStruct:cLoja,;
		::_oFatPagStruct:cForneGeracao,;
		::_oFatPagStruct:cLojaGeracao,;
		::_oFatPagStruct:cCondPag,;
		::_oFatPagStruct:cMoeda,;
		aItens,;
		0,;//::_oFatPagStruct:nValorDesconto
	::_oFatPagStruct:nValorAcrescimo;
		}

Return aCabec


Method _GetItens() Class TFaturaPagar

	Local nI			:= 0
	Local aLinha		:= {}
	Local aItens		:= {}
	Local oObj			:= Nil
	Local nId			:= 0
	Local nDesc			:= 0
	Local cLoja			:= ""

	For nI := 1 To ::_oFatPagStruct:oFatPagItens:GetCount()

		oObj	:= ::_oFatPagStruct:oFatPagItens:GetItem(nI)
		aLinha	:= {}

		nId 		:= oObj:nId
		nDesc		:= oObj:nValorDesc


		//[13] - ARRAY com os titulos da fatura - Geradores (esses títulos devem existir na base)
		//[13,1] Prefixo
		//[13,2] Numero
		//[13,3] Parcela
		//[13,4] Tipo
		//[13,5] Título localizado na geracao de fatura (lógico). Iniciar com falso.
		//[13,6] Fornecedor
		//[13,7] Loja


		If (nId != 0)

			DbSelectArea('SE2')
			SE2->(DbSetOrder(0))
			SE2->(DbGoTo(nId))

			If (!SE2->(Eof()))

				//aplicar desconto
				//gerar duas baixas SE5 um valor desconto outro valor normal
				//RecLock("SE2", .F.)
				//	SE2->E2_DECRESC := nDesc
				//	SE2->E2_SDDECRE := nDesc
				//SE2->(MsUnLock())
				//cLoja := IIF(AllTrim(::_oFatPagStruct:cPrefixo) == 'APF', '01', SE2->E2_LOJA)	
				
				aLinha	:= {;
					SE2->E2_PREFIXO,;
					SE2->E2_NUM,;
					SE2->E2_PARCELA,;
					SE2->E2_TIPO,;
					.F.,;
					SE2->E2_FORNECE,;
					SE2->E2_LOJA;
					}


			EndIf

		EndIf

		Aadd(aItens, aLinha)

	Next nI

Return aItens

Method _CheckForn(cForne) Class TFaturaPagar

	Local aArea			:= GetArea()
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local lRet			:= .F.

	cQuery	+= "SELECT TOTAL=COUNT(*) FROM "+RetSQLName("SA2")+"							"
	cQuery	+= " WHERE 																		"
	cQuery	+= " A2_COD			= '"+cForne+"'												"
	cQuery	+= " AND A2_MSBLQL <> '1'														"
	cQuery	+= " AND D_E_L_E_T_	= ''														"

	TcQuery cQuery New Alias cAliasTrab

	If !(cAliasTrab->(Eof()))

		If (cAliasTrab->TOTAL > 1) 
			lRet := .T.
		EndIf

	EndIf

	cAliasTrab->(DbCloseArea())

	RestArea(aArea)

Return lRet


Method _UpdateVenc() Class TFaturaPagar

	Local aArea			:= GetArea()
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery		:= ""
	Local nId			:= 0

	
	If(AllTrim(::_oFatPagStruct:cPrefixo) == 'APF')
		
		cQuery	+= "SELECT R_E_C_N_O_ FROM "+RetSQLName("SE2")+" (NOLOCK)						"
		cQuery	+= " WHERE 																		"
		cQuery	+= " E2_FORNECE		= '"+cValToChar(::_oFatPagStruct:cForneGeracao)+"'			"
		cQuery	+= " AND E2_LOJA	= '"+cValToChar(::_oFatPagStruct:cLojaGeracao)+"'			"
		cQuery	+= " AND E2_PREFIXO	= '"+cValToChar(::_oFatPagStruct:cPrefixo)+"'				"
		cQuery	+= " AND E2_TIPO	= '"+cValToChar(::_oFatPagStruct:cTipo)+"'					"
		cQuery	+= " AND E2_PARCELA	= 'A'														"
		cQuery	+= " AND E2_FILIAL	= '"+xFilial('SE2')+"'										"
		cQuery	+= " AND D_E_L_E_T_	= ''														"
		cQuery	+= " ORDER BY R_E_C_N_O_ DESC													"
	
	
	Else
		
		cQuery	+= "SELECT R_E_C_N_O_ FROM "+RetSQLName("SE2")+"								"
		cQuery	+= " WHERE 																		"
		cQuery	+= " E2_FORNECE		= '"+cValToChar(::_oFatPagStruct:cFornecedor)+"'			"
		cQuery	+= " AND E2_LOJA	= '"+cValToChar(::_oFatPagStruct:cLoja)+"'					"
		cQuery	+= " AND E2_PREFIXO	= '"+cValToChar(::_oFatPagStruct:cPrefixo)+"'				"
		cQuery	+= " AND E2_TIPO	= '"+cValToChar(::_oFatPagStruct:cTipo)+"'					"
		cQuery	+= " AND E2_PARCELA	= 'A'														"
		cQuery	+= " AND E2_FILIAL	= '"+xFilial('SE2')+"'										"
		cQuery	+= " AND D_E_L_E_T_	= ''														"
		cQuery	+= " ORDER BY R_E_C_N_O_ DESC													"
		
	EndIf
	
	TcQuery cQuery New Alias cAliasTrab

	If !(cAliasTrab->(Eof()))

		nId := cAliasTrab->R_E_C_N_O_

		DbSelectArea('SE2')
		SE2->(DbSetOrder(0))
		SE2->(DbGoTo(nId))

		If (!SE2->(Eof()))

			RecLock("SE2", .F.)

			SE2->E2_VENCTO 	:= DataValida(::_oFatPagStruct:dDataRecebimento, .T.)
			SE2->E2_VENCREA := DataValida(::_oFatPagStruct:dDataRecebimento, .T.)
			SE2->E2_VENCORI := ::_oFatPagStruct:dDataRecebimento

			SE2->(MsUnLock())

		EndIf

	EndIf

	cAliasTrab->(DbCloseArea())

	RestArea(aArea)

Return

Method _BaixaDesc(nId, nValor) Class TFaturaPagar
	
	Local aArea				:= GetArea()
	Local aParcBaixa 		:= {}
	Local lOk				:= .F.
	Local cMsgLog			:= ""
	Local nI				:= 0
	
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.

	DbSelectArea('SE2')
	SE2->(DbSetOrder(0))
	SE2->(DbGoTo(nId))

	If (!SE2->(Eof()))

		AADD(aParcBaixa, {"E2_FILIAL"   , SE2->E2_FILIAL   						, Nil})
		AADD(aParcBaixa, {"E2_PREFIXO"  , SE2->E2_PREFIXO   					, Nil})
		AADD(aParcBaixa, {"E2_NUM"      , SE2->E2_NUM      						, Nil})
		AADD(aParcBaixa, {"E2_PARCELA"  , SE2->E2_PARCELA  						, Nil})
		AADD(aParcBaixa, {"E2_TIPO"     , SE2->E2_TIPO      					, Nil})
		AADD(aParcBaixa, {"E2_FORNECE"  , SE2->E2_FORNECE   					, Nil})
		AADD(aParcBaixa, {"E2_LOJA"     , SE2->E2_LOJA      					, Nil})
		AADD(aParcBaixa, {"AUTMOTBX"    , "DES"									, Nil})
		AADD(aParcBaixa, {"AUTBANCO"    , ""	      							, Nil})
		AADD(aParcBaixa, {"AUTDTBAIXA"  , dDataBase      						, Nil})
		//AADD(aParcBaixa, {"AUTHIST"     , cHist			    					, Nil})

		AADD(aParcBaixa,{"AUTVLRPG"  	, nValor	,Nil})

		MsExecAuto ({|x,y| FINA080(x,y)}, aParcBaixa, 3)

		If (!lMsErroAuto)
			lOk			:= .T.
		Else

			lOk			:= .F.
			aErroAuto	:= GetAutoGRLog()

			For nI := 1 To Len(aErroAuto)
				cMsgLog += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
			Next nI

		EndIf

		::_oResult:Add(lOk, cMsgLog)

	EndIf
	
	RestArea(aArea)

Return 

Method _ExecBaixaDesc() Class TFaturaPagar

	Local aArea				:= GetArea()
	Local cAliasTrab		:= GetNextAlias()
	Local cQuery			:= ""
	Local nId				:= 0
	
	cQuery	+= "SELECT R_E_C_N_O_ FROM "+RetSQLName("SE2")+" (NOLOCK)						"
	cQuery	+= " WHERE 																		"
	cQuery	+= " E2_FORNECE		= '"+cValToChar(::_oFatPagStruct:cFornecedor)+"'			"
	cQuery	+= " AND E2_LOJA	= '"+cValToChar(::_oFatPagStruct:cLoja)+"'					"
	cQuery	+= " AND E2_PREFIXO	= '"+cValToChar(::_oFatPagStruct:cPrefixo)+"'				"
	cQuery	+= " AND E2_TIPO	= '"+cValToChar(::_oFatPagStruct:cTipo)+"'					"
	cQuery	+= " AND E2_PARCELA	= 'A'														"
	cQuery	+= " AND E2_FILIAL	= '"+xFilial('SE2')+"'										"
	cQuery	+= " AND D_E_L_E_T_	= ''														"
	cQuery	+= " ORDER BY R_E_C_N_O_ DESC													"

	TcQuery cQuery New Alias cAliasTrab

	If !(cAliasTrab->(Eof()))

		nId := cAliasTrab->R_E_C_N_O_
		::_BaixaDesc(nId, ::_oFatPagStruct:nValorDesconto)
		
	EndIf

	cAliasTrab->(DbCloseArea())

	RestArea(aArea)

Return

Method Incluir(lDesc, lVenc, dDataDe, dDataAte, cForne, cLojaForne, cNatureza) Class TFaturaPagar

	Local lOk				:= .F.
	Local cMsgLog			:= ""
	Local nI				:= 0
	Local aErroAuto			:= {}
	Local aArea				:= GetArea()

	Local _nId 				:= 0
	Local _nDesc			:= 0
	Local _nTaxa			:= 0

	Default lDesc := .T.
	Default lVenc := .T.
	Default dDataDe		:= Nil
	Default dDataAte	:= Nil
	Default cForne		:= ""
	Default cLojaForne	:= ""
	Default cNatureza	:= ""

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.

	varinfo("::_oFatPagStruct: ", ::_oFatPagStruct)
	
	If (Empty(::_oFatPagStruct:cTipoAntecipacao) .Or. AllTrim(::_oFatPagStruct:cTipoAntecipacao) == 'N')
		
		Begin Transaction
		
			aFatPag	:= ::_GetCabecalho(dDataDe, dDataAte, cForne, cLojaForne, cNatureza)

			varinfo( "Fatura => ", aFatPag )
	
			MsExecAuto( { |x,y| FINA290(x,y)}, 3, aFatPag )
	
			If (!lMsErroAuto)
				lOk	:= .T.
	
				If lDesc
					::_ExecBaixaDesc()
				EndIF
	
				If (::_oResult:Ok)
	
					If lVenc
						::_UpdateVenc()
					EndIf
	
				Else
					DisarmTransaction()
				EndIf
	
			Else
	
				DisarmTransaction()
	
				lOk			:= .F.
				aErroAuto	:= GetAutoGRLog()
	
				For nI := 1 To Len(aErroAuto)
					cMsgLog += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
				Next nI
	
			EndIf
	
			::_oResult:Add(lOk, cMsgLog)
		
		End Transaction
		
	Else //baixa normal no titulo : FIDC
		
		For nI := 1 To ::_oFatPagStruct:oFatPagItens:GetCount()
			
			Begin Transaction
			
				_oObj	:= ::_oFatPagStruct:oFatPagItens:GetItem(nI)
				_nId 	:= _oObj:nId
				_nDesc	:= _oObj:nValorDesc
				_nTaxa	:= _oObj:nTaxa
				
				varinfo( "Registro => ", _oObj )
				
				If (_nId != 0)
		
					DbSelectArea('SE2')
					SE2->(DbSetOrder(0))
					SE2->(DbGoTo(_nId))
		
					If (!SE2->(Eof()))
						
						::_BaixaDesc(_nId, _nDesc) //executa a baixa
						
						Conout(::_oResult:Ok)
						
						If (::_oResult:Ok)
							//aplicar desconto
							RecLock("SE2", .F.)
								SE2->E2_YANTTX	:= _nTaxa
								SE2->E2_YANTDES	:= _nDesc
								SE2->E2_VENCTO 	:= DataValida(::_oFatPagStruct:dDataRecebimento, .T.)
								SE2->E2_VENCREA := DataValida(::_oFatPagStruct:dDataRecebimento, .T.)
							SE2->(MsUnLock())
						Else
							DisarmTransaction()
						EndIf
						
					EndIf
		
				EndIf
			
			End Transaction
		Next nI
		
	EndIf
		
	RestArea(aArea)

Return ::_oResult

Method GetProxNumFat() Class TFaturaPagar

	Local cRet      := ""
	Local cQuery    := ""
	Local cQry      := GetNextAlias()

	cQuery := " SELECT MAX(E2_NUM) AS NUMMAX "
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " WHERE E2_FILIAL = " + ValToSql(xFilial("SE2"))
	cQuery += " AND E2_TIPO 	= " + ValToSql(::_oFatPagStruct:cTipo)
	cQuery += " AND E2_PREFIXO 	= " + ValToSql(::_oFatPagStruct:cPrefixo)
	cQuery += " AND LEN(E2_NUM) = " + cValToChar(TamSx3("E2_NUM")[1])
	cQuery += " AND D_E_L_E_T_	= '' "

	TcQuery cQuery New Alias (cQry)

	cRet := (cQry)->NUMMAX

	(cQry)->(DbCloseArea())

	cRet := Replicate("0", TamSx3("E2_NUM")[1] - Len(Alltrim(cRet))) + Alltrim(cRet)

	cRet := Soma1(cRet)

	While !MayIUseCode("SE2" + xFilial("SE2") + "FATP" + cRet)

		cRet := Soma1(cRet)

	EndDo

	FreeUsedCode()

Return(cRet)

Method Cancelar() Class TFaturaPagar

	Local aCabec			:= {}
	Local lOk				:= .F.
	Local cMsgLog			:= ""
	Local oResult 			:= Nil
	Local nI				:= 0
	Local aErroAuto			:= {}
	Local aArea				:= GetArea()

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.

	aFatPag	:= ::_GetCabecalho(.F.)

	varinfo( "", aFatPag )

	DBSelectArea("SE2")
	SE2->(DBSetOrder(1)) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_

	If SE2->(DBSeek(xFilial("SE2") + aFatPag[1] + aFatPag[3] + "A" + aFatPag[2] + aFatPag[7] + aFatPag[8]))

		MsExecAuto( { |x,y,z| FINA290(x,y,z)}, 4, aFatPag, .T. ) // Esta 4, mas eh exclusao

		If (!lMsErroAuto)

			lOk	:= .T.

		Else

			//DisarmTransaction()

			lOk			:= .F.
			aErroAuto	:= GetAutoGRLog()

			For nI := 1 To Len(aErroAuto)
				cMsgLog += StrTran(StrTran(aErroAuto[nI], "<", ""), "-", "") + " "
			Next nI

		EndIf

		::_oResult:Add(lOk, cMsgLog)

	Else

		::_oResult:Add(.F., "Fatura não encontrada!")

	EndIf

	RestArea(aArea)

Return ::_oResult

//-----------------------------------------------------//

//classes struct

Class TFaturaPagarStruct from LongClassName

	Data cPrefixo
	Data cTipo
	Data cNumero
	Data cNatureza
	Data dDataDe
	Data dDataAte
	Data cFornecedor
	Data cLoja
	Data cForneGeracao
	Data cLojaGeracao
	Data cCondPag
	Data cMoeda
	Data nValorDesconto
	Data nValorAcrescimo
	Data oFatPagItens
	Data lLoadDados
	Data dDataRecebimento
	Data cTipoAntecipacao

	Method New() Constructor

EndClass

Method New() Class TFaturaPagarStruct

	::cPrefixo 				:= ""
	::cTipo					:= ""
	::cNumero				:= ""
	::cNatureza				:= ""
	::dDataDe				:= Date()
	::dDataAte				:= Date()
	::cFornecedor			:= ""
	::cLoja			        := ""
	::cForneGeracao			:= ""
	::cLojaGeracao			:= ""
	::cCondPag			    := ""
	::cMoeda			    := 01
	::nValorDesconto		:= 0
	::nValorAcrescimo		:= 0
	::lLoadDados			:= .F.
	::dDataRecebimento		:= Date()
	::cTipoAntecipacao		:= ""
	::oFatPagItens	    	:= ArrayList():New()

Return()


Class TFaturaPagarItemStruct From LongClassName

	Data nId
	Data nValorDesc
	Data nTaxa

	Method New() Constructor

EndClass

Method New() Class TFaturaPagarItemStruct

	::nId			 := 0
	::nValorDesc	 := 0
	::nTaxa			 := 0

Return()

Class TFaturaPagarResultadoStruct From LongClassName

	Data Ok			as logical
	Data Mensagem	as character
	Data ID			as numeric

	Method New() Constructor
	Method Add()

EndClass

Method New() Class TFaturaPagarResultadoStruct

	::Ok		:= .T.
	::Mensagem	:= ""
	::ID		:= 0

Return()

Method Add(lOk, cMensagem, cID) Class TFaturaPagarResultadoStruct

	::Ok		:= lOk
	::Mensagem	+= cMensagem
	::ID		:= cID

Return()
