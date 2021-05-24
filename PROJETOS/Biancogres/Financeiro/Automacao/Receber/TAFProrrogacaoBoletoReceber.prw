#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFProrrogacaoBoletoReceber
@author Tiago Rossini Coradini
@since 15/05/2019
@project Automação Financeira
@version 1.0
@description Classe para tratar as prorrogacoes de boletos a receber
@type class
/*/

#DEFINE nP_MARK		1
#DEFINE nP_LEG		2
#DEFINE nP_DTREF	3
#DEFINE nP_PREF		5
#DEFINE nP_NUM		6	
#DEFINE nP_PARC		7
#DEFINE nP_TIPO		8
#DEFINE nP_CLIEN	9
#DEFINE nP_LOJA		10
#DEFINE nP_EMIS		12
#DEFINE nP_VENCT	13
#DEFINE nP_VENCR	14
#DEFINE nP_VALOR	15
#DEFINE nP_SALDO 	16
#DEFINE nP_RECNO 	21
	
Class TAFProrrogacaoBoletoReceber From TAFAbstractClass
	
	Data lCalc // Calcula e gera tidulo de juros
	Data nPerc // Percentula de juros
	Data dFIDC // Vencimento FIDC
	Data dVencto // Vencimento do juros
	Data nValor // Valor do totulo de juros

	Data cBanco
	Data cAgencia
	Data cConta
	Data cObs
	Data nDias
	Data lDepAnt // Se sera gerado Deposito antecipado (Renegociacao devido COVID-19)
	Data lFIDC //Se Titulo Corresponde a FIDC
	Data oJSon

	Data aTit // Titulos selecionados para envio
	Data oCR // Objeto de titulos a receber
	Data oMrr // Objeto de movimento de remessa a receber
	Data oApi // Objeto de integracao com a API 

	Method New() Constructor
	Method Load() 
	Method Process()
	Method Extend()
	Method Resend()
	Method Get()
	Method GetNextNum()
	Method BaixaDepAntJR()
	Method ExcDepAntJR(cNumero, lCanc)
	Method VldDepAntJR()
	Method IsJRProrrogBx(cNumero)
	Method EstBxDepAntJR()
	
EndClass


Method New(lLoad) Class TAFProrrogacaoBoletoReceber

	Default lLoad := .T.

	_Super:New()

	If lLoad

		::Load()

	EndIf

	::oCR := TContaReceber():New()
	::oMrr := TAFMovimentoRemessaReceber():New()
	::oApi := TAFIntegracaoApi():New()
								
Return()

Method Load() Class TAFProrrogacaoBoletoReceber

	::lCalc := .F.
	::nPerc := 0
	::dVencto := dDataBase
	::nValor := 0
	::aTit := {}

	::cBanco := Space(TamSx3("A6_COD")[1])
	::cAgencia := Space(TamSx3("A6_AGENCIA")[1])
	::cConta := Space(TamSx3("A6_NUMCON")[1])
	::cObs := ""
	::nDias := 0
	::lDepAnt := .F.
	::lFIDC := .F.

Return()


Method Process() Class TAFProrrogacaoBoletoReceber

	Local lRet := .T.

	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_REE_TIT"

	::oLog:Insert()
	
	If (lRet := ::Extend())

		if (!::lFIDC)
			If (!::lDepAnt) .Or. (::lDepAnt .And. !::lCalc .And. ::nValor == 0)
				::Resend()
			EndIf
		endif

	EndIf
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_REE_TIT"

	::oLog:Insert()
	
	::oPro:Finish()	
		
Return(lRet)


Method Extend() Class TAFProrrogacaoBoletoReceber

	Local lRet := .T.
	Local aArea := GetArea()
	Local nCount := 0
	Local cCliente := ""
	Local cZKCFilial:=xFilial("ZKC")
	Local cZK8Filial:=xFilial("ZK8")
	Local cLoja := ""
	Local cNumZK8 := ""
	
	Local nTxJuros
	Local nVlJuros
	Local nZK8Order

	Begin Transaction

		If ::lDepAnt .or. ::lFIDC

			if ::lFIDC
				DEFAULT ::oJSon:=JSONArray():New()
			endif

			For nCount := 1 To Len(::aTit)

				DbSelectArea("SE1")
				SE1->(DbGoTo(::aTit[nCount, nP_RECNO]))
				
				IF (SE1->(RecLock("SE1",.F.)))
					SE1->E1_HIST:=::cObs
					SE1->(MsUnLock())
				ENDIF

				if (!::lFIDC)

					If !::lCalc .And. ::nValor == 0

						DbSelectArea("SE1")
						SE1->(DbGoTo(::aTit[nCount, nP_RECNO]))
						
						RecLock("SE1", .F.)
						SE1->E1_VENCTO := ::aTit[nCount, nP_DTREF]
						SE1->E1_VENCREA := DataValida(::aTit[nCount, nP_DTREF])
						SE1->(MsUnLock())
					
					EndIf

				else

					if (!empty(::dFIDC))
						::nDias:=DateDiffDay(::dFIDC,CtoD(::aTit[nCount,nP_VENCT]))
					else
						::nDias:=DateDiffDay(::aTit[nCount,nP_DTREF],CtoD(::aTit[nCount,nP_VENCT]))
					endif
				
				endif

				If Empty(cNumZK8)

					nZK8Order:=retOrder("ZK8","ZK8_FILIAL+ZK8_NUMERO")
					ZK8->(dbSetOrder(nZK8Order))

					cNumZK8:=GetSXENum("ZK8", "ZK8_NUMERO")
					
					while (ZK8->(dbSeek(cZK8Filial+cNumZK8,.F.)))
						ConfirmSx8()
						cNumZK8:=GetSXENum("ZK8", "ZK8_NUMERO")
					end while

					cCliente := ::aTit[nCount, nP_CLIEN]
					cLoja := ::aTit[nCount, nP_LOJA]
					
					IF (ZK8->(RecLock("ZK8", .T.)))
						ZK8->ZK8_FILIAL := cZK8Filial
						ZK8->ZK8_NUMERO := cNumZK8
						ZK8->ZK8_GRPVEN := ""
						ZK8->ZK8_CODCLI := ::aTit[nCount, nP_CLIEN]
						ZK8->ZK8_VENCDE := ::dVencto
						ZK8->ZK8_VENCAT := ::dVencto
						ZK8->ZK8_DATDPI := ::dVencto
						
						ZK8->ZK8_BANCO 	:= ::cBanco
						ZK8->ZK8_AGENCI := ::cAgencia
						ZK8->ZK8_CONTA 	:= ::cConta
						
						ZK8->ZK8_CALCJR := "N"
						ZK8->ZK8_PERCJR := 0
						ZK8->ZK8_DATA 	:= dDataBase
						ZK8->ZK8_HORA 	:= Time()
						ZK8->ZK8_USER 	:= cUserName
						ZK8->ZK8_STATUS := if(::lFIDC,"F","A")
						ZK8->(MsUnLock())
					ENDIF

				EndIf

				if (::lFIDC)					
					::oJSon:FromJson(::cObs)
					nTxJuros:=::oJSon:get("txJuros")
					nVlJuros:=::aTit[nCount,nP_VALOR]
					nVlJuros:=Round((((nTxJuros/30/100)*nVlJuros)*::nDias),2)
					::oJSon:Set("vlJuros",nVlJuros)
					::cObs:=::oJSon:toJSON()
					SE1->(MsGoTo(::aTit[nCount, nP_RECNO]))
					if SE1->(RecLock("SE1",.F.))
						SE1->E1_HIST:=::oJSon:Get("Obs")
						SE1->(MsUnLock())
					endif
				endif					

				IF (ZKC->(RecLock("ZKC", .T.)))

					ZKC->ZKC_FILIAL := cZKCFilial
					ZKC->ZKC_NUMERO := cNumZK8
					ZKC->ZKC_NUM    := ::aTit[nCount, nP_NUM]
					ZKC->ZKC_PREFIX := ::aTit[nCount, nP_PREF]
					ZKC->ZKC_PARCEL := ::aTit[nCount, nP_PARC]
					ZKC->ZKC_TIPO   := ::aTit[nCount, nP_TIPO]
					ZKC->ZKC_CLIFOR := ::aTit[nCount, nP_CLIEN]
					ZKC->ZKC_LOJA   := ::aTit[nCount, nP_LOJA]
					ZKC->ZKC_VENCCA := ::aTit[nCount, nP_DTREF]
					ZKC->ZKC_EMISSA := CtoD(::aTit[nCount, nP_EMIS])
					ZKC->ZKC_VENCTO := CtoD(::aTit[nCount, nP_VENCT])
					ZKC->ZKC_VENCRE := CtoD(::aTit[nCount, nP_VENCR])
					ZKC->ZKC_VALOR  := ::aTit[nCount, nP_VALOR]
					ZKC->ZKC_SALDO  := ::aTit[nCount, nP_SALDO]
					ZKC->ZKC_DIAS	:= ::nDias
					ZKC->ZKC_OBSLIB := ::cObs
					if (::lFIDC)
						ZKC->ZKC_STATUS:="F"	// A=Titulo Origem;J=Titulo de JUROS;F=FIDC
						ZKC->ZKC_TXJUR:=nTxJuros
						ZKC->ZKC_JUROS:=nVlJuros
					else
						ZKC->ZKC_STATUS:="A"	// A=Titulo Origem;J=Titulo de JUROS;F=FIDC
					endif
						
					ZKC->(MsUnLock())

				ENDIF

			Next nCount
			
		Else

			For nCount := 1 To Len(::aTit)
		
				DbSelectArea("SE1")
				SE1->(DbGoTo(::aTit[nCount, nP_RECNO]))
				
				RecLock("SE1", .F.)
					
					SE1->E1_VENCTO := ::aTit[nCount, nP_DTREF]
					SE1->E1_VENCREA := DataValida(::aTit[nCount, nP_DTREF])
					
				SE1->(MsUnLock())
				
			Next nCount

			cCliente := SE1->E1_CLIENTE
			cLoja := SE1->E1_LOJA

		EndIf

		If (!::lFIDC) .and. (::lCalc .And. ::nValor > 0)

			::oCR:cPrefixo := "JR"
			::oCR:cNumero	:= ::GetNextNum()
			::oCR:cParcela := ""
			::oCR:cTipo := "JP"
			::oCR:cNatureza	:= "1227"
			::oCR:cCliente := cCliente
			::oCR:cLoja := cLoja
			::oCR:dVencto := ::dVencto
			::oCR:nValor := ::nValor
			::oCR:cVend1 := "999999"
			::oCR:cTipPag := "3"
			
			lRet := ::oCR:Incluir()
		
		EndIf

		If (!::lFIDC) .and. (lRet .And. ::lDepAnt .And. ::lCalc .And. ::nValor > 0) // Guardar para backup pois caso o titulo original de juros (SE1) nao for pago, sera apagado

			//Nesse momento o Titulo SE1 de JUROS esta posicionado
			RecLock("SE1", .F.)
	      	SE1->E1_YNUMDPI := cNumZK8
			SE1->(MsUnLock())

			RecLock("ZKC", .T.)
			
			ZKC->ZKC_FILIAL := cZKCFilial
			ZKC->ZKC_NUMERO := cNumZK8
			ZKC->ZKC_NUM    := ::oCR:cNumero
			ZKC->ZKC_PREFIX := ::oCR:cPrefixo
			ZKC->ZKC_PARCEL := ::oCR:cParcela
			ZKC->ZKC_TIPO   := ::oCR:cTipo
			ZKC->ZKC_CLIFOR := ::oCR:cCliente
			ZKC->ZKC_LOJA   := ::oCR:cLoja
			ZKC->ZKC_EMISSA := SE1->E1_EMISSAO
			ZKC->ZKC_VENCTO := ::oCR:dVencto
			ZKC->ZKC_VENCRE := SE1->E1_VENCREA
			ZKC->ZKC_VALOR  := ::oCR:nValor
			ZKC->ZKC_SALDO  := ::oCR:nValor
			ZKC->ZKC_OBSLIB := ::cObs
			ZKC->ZKC_DIAS	:= ::nDias
			ZKC->ZKC_STATUS := "J" // A=Titulo Origem;J=Titulo de JUROS
				
			ZKC->(MsUnLock())

		EndIf
		
		If lRet

			ConfirmSx8()

		Else

			DisarmTransaction()
			
			RollBAckSx8()

		EndIf
				
	End Transaction

	restArea(aArea)

Return(lRet)


Method Resend() Class TAFProrrogacaoBoletoReceber

	::oApi:cTipo := "R"
	::oApi:cOpcEnv := "L"
	::oApi:cReimpr := "S"
	::oApi:GArqRem := "N"
	::oApi:oLst := ::Get()
			
	::oApi:Send(::oPro:cIDProc)

Return()


Method Get() Class TAFProrrogacaoBoletoReceber

	Local aArea := GetArea()
	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaZK1 := ZK1->(GetArea())
	Local nCount := 0
	Local oLst := ArrayList():New()
	Local oObj := Nil

	For nCount := 1 To Len(::aTit)

		DbSelectArea("SE1")
		SE1->(DbGoTo(::aTit[nCount, nP_RECNO]))
		
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

		oObj := TIAFMovimentoFinanceiro():New()
		 
		oObj:cPrefixo := SE1->E1_PREFIXO
		oObj:cNumero := SE1->E1_NUM
		oObj:cParcela := SE1->E1_PARCELA
		oObj:cTipo := SE1->E1_TIPO
		oObj:cCliFor := SE1->E1_CLIENTE
		oObj:cLoja := SE1->E1_LOJA
		oObj:nValor := SE1->E1_VALOR
		oObj:nSaldo := SE1->E1_SALDO
		oObj:nAbat := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA)
		oObj:nDesc := SE1->E1_DECRESC
		oObj:nAcre := ::oMrr:GetAcre(SA1->A1_YTFGNRE, SE1->E1_YCLASSE, AllTrim(SE1->E1_YEMP), AllTrim(SE1->E1_YUFCLI))
		oObj:nPerJur := SE1->E1_PORCJUR
		oObj:dEmissao := SE1->E1_EMISSAO
		oObj:dVencto := SE1->E1_VENCTO
		oObj:dVencRea := SE1->E1_VENCREA
		oObj:cNumBor := SE1->E1_NUMBOR
		oObj:cNumBco := SE1->E1_NUMBCO
		oObj:cIDCnab := SE1->E1_IDCNAB
		oObj:cPedido := SE1->E1_PEDIDO
		oObj:lRecAnt := If (oObj:cTipo == "BOL" .And. SubStr(oObj:cPrefixo, 1, 2) $ "PR/CT" .And. !Empty(oObj:cPedido), .T., .F.)		
		oObj:cBanco := SE1->E1_PORTADO
		oObj:cAgencia := SE1->E1_AGEDEP
		oObj:cConta := SE1->E1_CONTA
		oObj:cSubCta := ""

		DbSelectArea("ZK1")
		ZK1->(DbSetOrder(1)) // ZK1_FILIAL, ZK1_CODREG, R_E_C_N_O_, D_E_L_E_T_

		If ZK1->(DbSeek(xFilial("ZK1") + SE1->E1_YCDGREG))

			oObj:cSubCta := ZK1->ZK1_SUBCTA
			
		EndIf

		oObj:nRecNo := SE1->(RecNo())
								
		// Se nao calcula juros (Titulo postergado), envia o valor do juros diarios para a impressao diretamente via API
		oObj:nJurosDia := (oObj:nPerJur / 100) * oObj:nSaldo + oObj:nJuros - oObj:nAbat
				
		// Calculo do valor total do boleto
		oObj:nValorBol := oObj:nSaldo + oObj:nJuros - oObj:nAbat
								
		// Tratamento de mensagens livres
		oObj:cMsgLiv1 := If(Empty(oObj:cMsgLiv1), oObj:cMsgLiv1, oObj:cMsgLiv1 + " ") + "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA " + dToC(oObj:dVencto)
				
		If oObj:nJurosDia > 0
		
			oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "JUROS POR DIA: R$ " + Alltrim(Transform(oObj:nJurosDia, "@E 99,999,999.99"))
		
		EndIf
			
		If oObj:lRecAnt
			
			oObj:cMsgLiv2 := If(Empty(oObj:cMsgLiv2), oObj:cMsgLiv2, oObj:cMsgLiv2 + " ") + "BOLETO REFERENTE AO PEDIDO DE VENDA: " + Upper(oObj:cPedido)
			
		EndIf
				
		If AllTrim(oObj:cTipo) == "FT"
						
			oObj:cMsgLiv3 := If(Empty(oObj:cMsgLiv3), oObj:cMsgLiv3, oObj:cMsgLiv3 + " ") + ::oMrr:GetFatura(oObj:cPrefixo, oObj:cNumero, oObj:cParcela)
		
		EndIf
		
		oLst:Add(oObj)
								
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"	
		::oLog:cMetodo := "S_REE_TIT"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := SE1->(RecNo())
		::oLog:cEnvWF := "N"
		::oLog:cRetMen := "BOLETO PRORROGADO"
		
		::oLog:Insert()
		
	Next
	
	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSA1)
	RestArea(aAreaZK1)

Return(oLst)


Method GetNextNum() Class TAFProrrogacaoBoletoReceber

	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(E1_NUM), '000000000') AS E1_NUM "
	cSQL += " FROM " + RetSQLName("SE1")
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_PREFIXO = 'JR' "
	cSQL += " AND LEN(E1_NUM) = 9 "
	cSQL += " AND E1_PARCELA = ''	"
	cSQL += " AND E1_TIPO = 'JP' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	cRet := Soma1((cQry)->E1_NUM)

	(cQry)->(DbCloseArea())

Return(cRet)

Method BaixaDepAntJR(lWorkFLow) Class TAFProrrogacaoBoletoReceber

	Local cNumero  := ""
	Local aAreaZKC := ZKC->(GetArea())
	Local aAreaZK8 := ZK8->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())

	Default lWorkFLow := .T.

	DBSelectArea("ZKC")
	ZKC->(DBSetOrder(2)) // ZKC_FILIAL, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, ZKC_NUMERO, R_E_C_N_O_, D_E_L_E_T_
	ZKC->(DbGoTop())

	If ZKC->(DBSeek(xFilial("ZKC") + SE1->(E1_NUM + E1_PREFIXO + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))) // Titulo de JUROS
		
		While ZKC->(!EOF()) .And. ZKC->(ZKC_FILIAL + ZKC_NUM + ZKC_PREFIX + ZKC_PARCEL + ZKC_TIPO + ZKC_CLIFOR + ZKC_LOJA) == xFilial("ZKC") + SE1->(E1_NUM + E1_PREFIXO + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

			If ZKC->ZKC_STATUS <> "C"

				If ZKC->ZKC_STATUS == "J"

					cNumero := ZKC->ZKC_NUMERO

					DBSelectArea("ZKC")
					ZKC->(DBSetOrder(1)) // ZKC_FILIAL, ZKC_NUMERO, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, R_E_C_N_O_, D_E_L_E_T_
					ZKC->(DbGoTop())

					If ZKC->(DBSeek(xFilial("ZKC") + cNumero)) // Titulos para prorrogação

						::oPro:Start()

						DBSelectArea("SE1")
						SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
						SE1->(DbGoTop())
						
						While ZKC->(!EOF()) .And. ZKC->(ZKC_FILIAL + ZKC_NUMERO) == xFilial("ZKC") + cNumero

							If SE1->(DBSeek(xFilial("SE1") + ZKC->(ZKC_CLIFOR + ZKC_LOJA + ZKC_PREFIX + ZKC_NUM + ZKC_PARCEL + ZKC_TIPO)))	

								If ZKC->ZKC_STATUS <> "J"

									If SE1->E1_SALDO > 0 // Pode ser que mesmo tenha sido prorrogado o cliente tenha pagado no vencimento oririnal

										RecLock("SE1", .F.)
										SE1->E1_VENCTO	:= ZKC->ZKC_VENCCA
										SE1->E1_VENCREA	:= ZKC->ZKC_VENCCA
										SE1->(MSUnLock())

										::aTit := {}

										If !Empty(SE1->E1_NUMBCO)

											aAdd(::aTit, {,,,,,,,,,,,,,,,,,,,SE1->(Recno())})

											::Resend()

										EndIf

									EndIf

								EndIf

							EndIf

							ZKC->(DBSkip())

						EndDo

						// Marca o deposito identificado como finalizado
						DBSelectArea("ZK8")
						ZK8->(DBSetOrder(1)) // ZK8_FILIAL, ZK8_NUMERO, R_E_C_N_O_, D_E_L_E_T_
						ZK8->(DbGoTop())

						If ZK8->(DBSeek(xFilial("ZK8") + cNumero))

							RecLock("ZK8", .F.)
							ZK8->ZK8_STATUS := "B"
							ZK8->(MsUnLock())

							::oLog:cIDProc := ::oPro:cIDProc
							::oLog:cTabela := RetSQLName("ZK8")
							::oLog:nIDTab := ZK8->(Recno())
							::oLog:cHrFin := Time()
							::oLog:cRetMen := "DEPOSITO - [BAIXADO]"
							::oLog:cOperac := "R"
							::oLog:cMetodo := "CR_DEP_IDE"
							::oLog:cEnvWF := If(lWorkFLow, "S", "N")

							::oLog:Insert()

						EndIf

						::oPro:Finish()

					EndIf

				EndIf

			EndIf

			ZKC->(DBSkip())

		EndDo

	EndIf

	RestArea(aAreaZKC)
	RestArea(aAreaZK8)
	RestArea(aAreaSE1)

Return()

Method ExcDepAntJR(cNumero, lCanc, cIDProc) Class TAFProrrogacaoBoletoReceber

	Local lRet := .T.
	Local lEmptyProc := .F.
	Local aAreaZKC := ZKC->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())

	Default cNumero  := ""
	Default lCanc := .F.
	Default cIDProc  := ""

	DBSelectArea("ZKC")
	ZKC->(DBSetOrder(1)) // ZKC_FILIAL, ZKC_NUMERO, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, R_E_C_N_O_, D_E_L_E_T_
	ZKC->(DbGoTop())
	
	DBSelectArea("SE1")
	SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	SE1->(DBGoTop())

	If ZKC->(DBSeek(xFilial("ZKC") + cNumero))
		
		If Empty(cIDProc)
			
			::oPro:Start()

			cIDProc := ::oPro:cIDProc

			lEmptyProc := .T.
		
		EndIf

		While ZKC->(!EOF()) .And. ZKC->(ZKC_FILIAL + ZKC_NUMERO) == xFilial("ZKC") + cNumero

			If ZKC->ZKC_STATUS == "J" // Titulo de JUROS

				If SE1->(DBSeek(xFilial("SE1") + ZKC->(ZKC_CLIFOR + ZKC_LOJA + ZKC_PREFIX + ZKC_NUM + ZKC_PARCEL + ZKC_TIPO)))

					RecLock("SE1", .F.)
					SE1->(DbDelete())
					SE1->(MsUnLock())

					RecLock("ZKC", .F.)

					If lCanc

						ZKC->ZKC_STATUS := "C" // Cancelado
					
					Else

						ZKC->(DbDelete())

					EndIf

					ZKC->(MsUnLock())

					If lCanc

						// Marca o deposito identificado como finalizado
						DBSelectArea("ZK8")
						ZK8->(DBSetOrder(1)) // ZK8_FILIAL, ZK8_NUMERO, R_E_C_N_O_, D_E_L_E_T_
						ZK8->(DbGoTop())

						If ZK8->(DBSeek(xFilial("ZK8") + cNumero))

							RecLock("ZK8", .F.)
							ZK8->ZK8_STATUS := "C"
							ZK8->(MsUnLock())

							::oLog:cIDProc := cIDProc
							::oLog:cTabela := RetSQLName("ZK8")
							::oLog:nIDTab := ZK8->(Recno())
							::oLog:cHrFin := Time()
							::oLog:cRetMen := "DEPOSITO - [CANCELADO]"
							::oLog:cOperac := "R"
							::oLog:cMetodo := "CR_DEP_IDE"
							::oLog:cEnvWF := "S"

							::oLog:Insert()

						EndIf

					EndIf

				EndIf

			Else

				RecLock("ZKC", .F.)

				If lCanc

					ZKC->ZKC_STATUS := "C" // Cancelado
				
				Else

					ZKC->(DbDelete())

				EndIf

				ZKC->(MsUnLock())
				
				If SE1->(DBSeek(xFilial("SE1") + ZKC->(ZKC_CLIFOR + ZKC_LOJA + ZKC_PREFIX + ZKC_NUM + ZKC_PARCEL + ZKC_TIPO)))

					RecLock("SE1", .F.)
					SE1->E1_HIST := ""
					SE1->(MsUnLock())
					
				EndIf

			EndIf

			ZKC->(DBSkip())

		EndDo

		If lEmptyProc

			::oPro:Finish()

		EndIf

	EndIf

	RestArea(aAreaZKC)
	RestArea(aAreaSE1)

Return(lRet)

Method IsJRProrrogBx(cNumero) Class TAFProrrogacaoBoletoReceber

	Local lRet := .T.
	Local aAreaZKC := ZKC->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())

	Default cNumero  := ""

	DBSelectArea("ZKC")
	ZKC->(DBSetOrder(1)) // ZKC_FILIAL, ZKC_NUMERO, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, R_E_C_N_O_, D_E_L_E_T_
	ZKC->(DbGoTop())
	
	DBSelectArea("SE1")
	SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	SE1->(DBGoTop())

	If ZKC->(DBSeek(xFilial("ZKC") + cNumero))

		While ZKC->(!EOF()) .And. ZKC->(ZKC_FILIAL + ZKC_NUMERO) == xFilial("ZKC") + cNumero

			If ZKC->ZKC_STATUS == "J" // Titulo de JUROS

				If SE1->(DBSeek(xFilial("SE1") + ZKC->(ZKC_CLIFOR + ZKC_LOJA + ZKC_PREFIX + ZKC_NUM + ZKC_PARCEL + ZKC_TIPO)))

					If SE1->E1_SALDO <> SE1->E1_VALOR

						lRet := .F.

					EndIf
				
				EndIf

			EndIf

			ZKC->(DBSkip())

		EndDo

	EndIf

	RestArea(aAreaZKC)
	RestArea(aAreaSE1)

Return(lRet)

Method VldDepAntJR() Class TAFProrrogacaoBoletoReceber

	Local lRet := .F.
	Local aAreaZKC := ZKC->(GetArea())
	Local aAreaZK8 := ZK8->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())
	
	If !IsBlind()

		DBSelectArea("ZKC")
		ZKC->(DBSetOrder(2)) // ZKC_FILIAL, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, ZKC_NUMERO, R_E_C_N_O_, D_E_L_E_T_
		ZKC->(DbGoTop())

		If ZKC->(DBSeek(xFilial("ZKC") + SE1->(E1_NUM + E1_PREFIXO + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))) // Titulo de JUROS

			While ZKC->(!EOF()) .And. ZKC->(ZKC_FILIAL + ZKC_NUM + ZKC_PREFIX + ZKC_PARCEL + ZKC_TIPO + ZKC_CLIFOR + ZKC_LOJA) == xFilial("ZKC") + SE1->(E1_NUM + E1_PREFIXO + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

				If ZKC->ZKC_STATUS <> "C"

					If ZKC->ZKC_STATUS == "J" // Titulo de JUROS

						DBSelectArea("ZK8")
						ZK8->(DBSetOrder(1)) // ZK8_FILIAL, ZK8_NUMERO, R_E_C_N_O_, D_E_L_E_T_
						ZK8->(DbGoTop())

						If ZK8->(DBSeek(xFilial("ZK8") + ZKC->ZKC_NUMERO)) // Titulos para prorrogação

							If ZK8->(ZK8_BANCO + ZK8_AGENCI + ZK8_CONTA) == cBanco + cAgencia + cConta

								lRet := .T.

							EndIf

						EndIf

					EndIf

				EndIf

				ZKC->(DBSkip())

			EndDo
		
		EndIf

	Else

		lRet := .T.

	EndIf

	If !lRet

		If MsgYesNo("A conta informada difere da informada no deposito identificado!" + CRLF + "Dejesa continuar com a baixa mesmo assim?" + CRLF + CRLF + "Caso escolha 'Sim' os titulos de prorrogação não teram suas datas alteradas!")

			lRet := .T.

		EndIf

	EndIf

	RestArea(aAreaZKC)
	RestArea(aAreaZK8)
	RestArea(aAreaSE1)

Return(lRet)

Method EstBxDepAntJR() Class TAFProrrogacaoBoletoReceber
	
	Local cNumero  := ""
	Local aAreaZKC := ZKC->(GetArea())
	Local aAreaZK8 := ZK8->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())

	If !IsBlind()

		If PARAMIXB == 6 .Or. PARAMIXB == 5

			DBSelectArea("ZKC")
			ZKC->(DBSetOrder(2)) // ZKC_FILIAL, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, ZKC_NUMERO, R_E_C_N_O_, D_E_L_E_T_
			ZKC->(DbGoTop())
			
			If ZKC->(DBSeek(xFilial("ZKC") + SE1->(E1_NUM + E1_PREFIXO + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))) // Titulo de JUROS

				While ZKC->(!EOF()) .And. ZKC->(ZKC_FILIAL + ZKC_NUM + ZKC_PREFIX + ZKC_PARCEL + ZKC_TIPO + ZKC_CLIFOR + ZKC_LOJA) == xFilial("ZKC") + SE1->(E1_NUM + E1_PREFIXO + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

					If ZKC->ZKC_STATUS <> "C"

						::oPro:Start()

						If ZKC->ZKC_STATUS == "J" // Caso seja estorno de titulo de JUROS

							cNumero := ZKC->ZKC_NUMERO

							DBSelectArea("ZKC")
							ZKC->(DBSetOrder(1)) // ZKC_FILIAL, ZKC_NUMERO, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, R_E_C_N_O_, D_E_L_E_T_
							ZKC->(DbGoTop())

							If ZKC->(DBSeek(xFilial("ZKC") + cNumero)) // Titulos para prorrogação

								DBSelectArea("SE1")
								SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
								SE1->(DbGoTop())
								
								While ZKC->(!EOF()) .And. ZKC->(ZKC_FILIAL + ZKC_NUMERO) == xFilial("ZKC") + cNumero

									If SE1->(DBSeek(xFilial("SE1") + ZKC->(ZKC_CLIFOR + ZKC_LOJA + ZKC_PREFIX + ZKC_NUM + ZKC_PARCEL + ZKC_TIPO)))	

										If ZKC->ZKC_STATUS <> "J"

											If SE1->E1_SALDO > 0 // Pode ser que mesmo tenha sido prorrogado o cliente tenha pagado no vencimento oririnal

												RecLock("SE1", .F.)
												SE1->E1_VENCTO	:= ZKC->ZKC_VENCTO
												SE1->E1_VENCREA	:= ZKC->ZKC_VENCRE
												SE1->(MSUnLock())

											EndIf

										EndIf

									EndIf

									ZKC->(DBSkip())

								EndDo

								// Marca o deposito identificado como finalizado
								DBSelectArea("ZK8")
								ZK8->(DBSetOrder(1)) // ZK8_FILIAL, ZK8_NUMERO, R_E_C_N_O_, D_E_L_E_T_
								ZK8->(DbGoTop())

								If ZK8->(DBSeek(xFilial("ZK8") + cNumero))

									RecLock("ZK8", .F.)
									ZK8->ZK8_STATUS := "A"
									ZK8->(MsUnLock())

									::oLog:cIDProc := ::oPro:cIDProc
									::oLog:cTabela := RetSQLName("ZK8")
									::oLog:nIDTab := ZK8->(Recno())
									::oLog:cHrFin := Time()
									::oLog:cRetMen := "DEPOSITO - [ESTORNO]"
									::oLog:cOperac := "R"
									::oLog:cMetodo := "CR_DEP_IDE"
									::oLog:cEnvWF := "S"

									::oLog:Insert()

								EndIf

							EndIf

						EndIf

					EndIf

					::oPro:Finish()
				
					ZKC->(DBSkip())

				EndDo
			
			EndIf

		EndIf
	
	EndIf

	RestArea(aAreaZKC)
	RestArea(aAreaZK8)
	RestArea(aAreaSE1)

Return()
