#include "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#Include "topconn.ch"


/*/{Protheus.doc} MT410TOK
@author Fernando Rocha 
@since 12/03/2014
@version 1.0
@description Validar a opercao da tela de Pedidos de venda. Calcular e gravar os impostos em cada item do Pedido.
@history 04/11/2016, Ranisses A. Corona, Correção e melhorias na gravação do valor dos impostos por item. OS: 4052-16 Mayara Trigueiro / 3888-16 Elaine Sales
@type function
/*/

User Function MT410TOK
	Local aArea		:= GetArea()
	Local nOpc		:= PARAMIXB[1]
	Local lRetorno	:= .T.
	Local I			:= 0
	Local aColsImp  := {} //Utilizado para Gravar os valores dos Impostos para os Itens do Pedido de Venda
	Local cRes
	Local _cSegmento

	//Parametro para Filtrar tipo de pedido que nao gera reserva - projeto reserva Estoque/OP
	Local _cTpNRes	:= GetNewPar("FA_TPNRES","A #RI#")

	//Projeto contrato de verbas
	Local nValPedX	:= 0
	Local nSaldoX	:= 0

	Local _nQtdDig	:= 0
	Local _cLote	:= ""
	Local _cPedido	:= ""
	Local _cEmpPed	:= ""
	Local _cFilPed	:= "01"
	Local _lRetValP	:= .T.


	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
		Return(.T.)
	EndIf

	// Ticket: 25464 - Automacao JK
	If IsInCallStack("U_JOBFATPARTE") .And. IsBlind()

		Return(.T.)

	EndIf
	
	//REAJUSTE DE PREÇO - GRAVAR TABELA ZM0 DE LOG
	IF IsInCallStack("U_M410RPRC") .And. SC6->(FieldPos("C6_YPREAJU")) > 0

		__oObj := TPedidoVendaReajustePreco():New()
		__oObj:GravaLogTok()
		Return(.T.)

	ENDIF
	///FIM REAJUSTE

	//Calcula o valor do impostos para TODOS os Itens do Pedido
	aColsImp := U_fItImpos(0,{"IT_BASEPS2","IT_BASECF2","IT_VALPS2","IT_VALCF2","IT_VALICM","IT_VALIPI","IT_ALIQPS2","IT_ALIQCF2","IT_VALMERC","IT_DESCZF","IT_VALSOL","IT_BASEICM","IT_BASEIPI"})

	//Grava o valor dos Impostos para TODOS os Itens do Pedido.
	For I := 1 To Len(aCols)

		nBasePIS := aColsImp[I][1]
		nBaseCOF := aColsImp[I][2]
		nPIS     := aColsImp[I][3]
		nCOFINS  := aColsImp[I][4]
		nICMS	 := aColsImp[I][5]
		nIPI 	 := aColsImp[I][6]
		nPercPIS := aColsImp[I][7]
		nPercCOF := aColsImp[I][8]
		nValMerc := aColsImp[I][9]
		nDescZF	 := aColsImp[I][10]
		nValST	 := aColsImp[I][11]
		nBaseICM := aColsImp[I][12]
		nBaseIPI := aColsImp[I][13]

		//Função para gravar o valor dos impostos nos itens do Pedido de Venda
		U_fAtuImp(I,nBasePIS,nBaseCOF,nPIS,nCOFINS,nICMS,nIPI,nPercPIS,nPercCOF,nValMerc,nDescZF,nValST,nBaseICM,nBaseIPI)

	Next


	SB1->(DbSetOrder(1))

	//Buscar segmento do cliente
	_cSegmento := U_fSegCliente(M->C5_YLINHA, M->C5_CLIENTE, M->C5_LOJACLI)

	///Validar Inclusao de Pedido - Projeto Reserva de OP - Verificar se tem item nao reservado e Bloquear
	If lRetorno .And. nOpc == 3 .And. M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. M->C5_YLINHA <> "4"

		If (_cSegmento == "E") .And. (AllTrim(M->C5_YSUBTP) $ "N#E") .And. Empty(M->C5_YNPRENG)
			If !MsgYesNo( "Pedido com cliente do segmento='Engenharia' é necessario informar 'Numero da Proposta', Deseja continuar sem 'Numero da Proposta'?", 'MT410TOK' )
				Return(.F.)
			EndIf
		EndIf
		
		//TRATAR FORMA DE PAGAMENTO BONIFICAÇÂO
		/*If (AllTrim(M->C5_YSUBTP) $ "B") .And. Empty(M->C5_YNOUTAI)
			Msgbox("ATENÇÃO. Pedido de venda Tipo: 'Bonificação' é necessario informar 'AI Outros'.","MT410TOK","STOP")
			Return(.F.)
		ElseIf (AllTrim(M->C5_YSUBTP) $ "B") .And. !Empty(M->C5_YNOUTAI)
			
			_cQuery := "select * from "+RETSQLNAME("SZO")+" SZO where ZO_SI = '"+M->C5_YNOUTAI+"' AND R_E_C_N_O_ = ''"
			_cAliasTemp := GetNextAlias()
			TcQuery _cQuery New Alias (_cAliasTemp)
			
			If (!(_cAliasTemp)->(Eof()))
				If !((_cAliasTemp)->ZO_FPAGTO == '1')
					Msgbox("ATENÇÃO. 'AI Outros' informada não está com forma de pagamento Bonificação.","MT410TOK","STOP")
					Return(.F.)
				EndIf
			Else
				Msgbox("ATENÇÃO. Número da 'AI Outros' informada não encontrada.","MT410TOK","STOP")
				Return(.F.)
			EndIf
			(_cAliasTemp)->(DbCloseArea())	
			
		EndIf	
		*/				
		
		
		// Tiago Rossini Coradini - 10/04/2017 - OS: 1219-17 - Adicionado tratamento para implantar pedidos de damostra na Mundi
		If AllTrim(CEMPANT) == "13" .And. !AllTrim(M->C5_YSUBTP) $ "A/IM"

			Msgbox("ATENÇÃO. Para Empresa Mundi somente é permitido tipo de pedido 'A/IM'.","MT410TOK","STOP")
			Return(.F.)

		ENDIF

		Private __nProd		:= Gdfieldget("C6_PRODUTO",1)  //primeiro produto do pedido

		If (AllTrim(CEMPANT) == "14") .And. !U_CHKRODA(__nProd)

			lRetorno := .T.

		ElseIF (M->C5_YSUBTP $ _cTpNRes)

			lRetorno := .T.

		ELSE

			For I := 1 To Len(aCols)

				If !aCols[I][Len(aHeader)+1]

					//Tratamento outro produtos
					_cProd 	:= aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
					_cItem 	:= aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})]
					_cTpEst := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})]


					If SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. SB1->B1_TIPO <> "PA"

						loop

						//Tratamento produtos classe B/Cliente Livre revestimetos - nao fazer tratamento de lote/reserva - Fernando em 17/08/15 - OS 2831-15
					ELSEIF SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. AllTrim(SB1->B1_YCLASSE) == "2" .And. (M->C5_CLIENTE == "006338");
							.And. AllTrim(_cTpEst) <> 'E'

						loop

					Else

						cRes := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})]

						If !(cRes $ "E#R#V") //.Or. Len(__aListRes) <= 0

							U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP",;
								"Pedido ITEM: "+_cItem+" não foi reservado."+CRLF+;
								"É obrigatória a reserva de Estoque ou OP para inclusão do pedido."+CRLF+;
								"Verifique a quantidade e saldo disponível.",;
								,,"ATENÇÃO! Itens NÃO RESERVADOS.")

							lRetorno := .F.
							exit

						EndIf

					EndIf


					//Validacao de campos e Lote para cliente Engenharia
					//Verificando Segmento do Cliente
					If lRetorno

						If (_cSegmento == "E") .And. !(AllTrim(M->C5_YSUBTP) $ "A#M")

							_cLoteCtl := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})]
							ZZ9->(DbSetOrder(1))
							if !Empty(_cLoteCtl) .And. ZZ9->(DbSeek(XFilial("ZZ9")+PADR(_cLoteCtl,TamSX3("ZZ9_LOTE")[1])+_cProd)) .And. AllTrim(ZZ9->ZZ9_RESTRI) == "*"

								U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP",;
									"Pedido para ENGENHARIA contêm itens com LOTE RESTRITO selecionado. Verifique/Digite novamente os produtos/quantidades.",;
									,,"ATENÇÃO! Engenharia com Lote restrito.")
								lRetorno := .F.
								exit

							endif

							_dDtNece  := aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDTNECE"})]
							if Empty(_dDtNece)

								U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP",;
									"Pedido para ENGENHARIA contêm itens sem a Data de Necessidade informada. Verifique/Digite novamente os produtos/quantidades.",;
									,,"ATENÇÃO! Engenharia sem Dt.Necessidade.")
								lRetorno := .F.
								exit

							endif

						EndIf

					EndIf


				EndIf

			Next I

		ENDIF

	EndIf

	If	lRetorno .And. Altera .And. M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. M->C5_YLINHA <> "4"

		For I := 1 To Len(aCols)

			If !aCols[I][Len(aHeader)+1]

				//Tratamento outro produtos
				_cProd 	:= aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
				_cItem 	:= aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})]
				cRes 	:= aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})]

				If (cRes $ "E" .And. /*M->C5_YCONF == "S" .And.*/ ALLTRIM(M->C5_YSUBTP) <> "A" )

					_nQtdDig 	:= Round(aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})],2)
					_cLote		:= aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})]
					_cPedido	:= M->C5_NUM
					_cEmpPed	:= aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YEMPPED"})]
					_cFilPed	:= "01"

					If (!Empty(M->C5_YPEDORI))
						_cPedido := M->C5_YPEDORI
					EndIf

					If Empty(_cEmpPed)
						_cEmpPed := CEMPANT
						_cFilPed := CFILANT
					EndIf

					IF ( AllTrim(cEmpAnt) $ "01_05_07_13" )

						_lRetValP 	:= ValiPonta(_cProd, _cLote, _nQtdDig, _cPedido, _cItem, _cEmpPed, _cFilPed, I, M->C5_NUM)
						If (!_lRetValP)
							lRetorno := .F.
							exit
						EndIf

					ENDIF

				EndIf

			EndIf

		Next I

	EndIf
	
	If (lRetorno .And. INCLUI .And. ALLTRIM(M->C5_YSUBTP) <> "A" .And. M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. M->C5_YLINHA <> "4")
		
		conout("MV_YVRESPE => "+cvaltochar(SUPERGETMV("MV_YVRESPE", .F., .T.)))
	
		If (SUPERGETMV("MV_YVRESPE", .F., .T.))
			__lREt := U_VRESPEDI(aCols, aHeader,  M->C5_NUM)
			If (!__lREt)
				Return(.F.)
			EndIf
		EndIf
	EndIf
	
	//Ticket 31159
	If (!Empty(Str(M->C5_FRETE)) .And. M->C5_FRETE > 0)
	    If(!MsgYesNo("Campo Frete /p Dev está preenchido. Deseja continuar?"))
	        Return(.F.)
	    Endif
	Endif

	// Tiago Rossini -- Bloqueio de Pedidos tipo 'B' com o campo Classe de Valor em branco -- OS: 0227-15 - Tania de Fatima
	// Tiago Rossini -- Bloqueio de Pedidos tipo 'G' com o campo Classe de Valor em branco -- OS: 3573-15 - Tania de Fatima
	// Tiago Rossini -- Bloqueio de Pedidos tipo 'G' com o campo Classe de Valor em branco -- OS: 3105-15 - Tania de Fatima
	// Caso o usuario não seja representante, avalia se a classe esta embranco para os tipos B/G
	If Empty(Alltrim(cRepAtu))

		If (nOpc == 3 .Or. nOpc == 4) .And. Alltrim(M->C5_YSUBTP) $ "B/G" .And. Empty(M->C5_YCLVL) .And. M->C5_YCONF == "S"
			MsgBox("Favor informar a Classe de Valor", "MT410TOK", "ALERT")
			Return(.F.)
		EndIf

	EndIf

	//Fernando em 11/04/18 - projeto despesas bi 3.0 - e-mail Claudeir - qualquer pedido O exibir classe, item e cliente AI
	If Alltrim(M->C5_YSUBTP) == "O"

		//Pedidos OUTROS com TES que atualiza estoque mas não gera financeiro precisa informar classe de valor - validacao sugerida pelo Claudeir em 18/04/2018
		_cTES := Gdfieldget("C6_TES",1)
		SF4->(DbSetOrder(1))
		If SF4->(DbSeek(XFilial("SF4")+_cTES)) .And. SF4->F4_ESTOQUE == "S" .And. SF4->F4_DUPLIC == "N" .And. Empty(M->C5_YCLVL)
			MsgBox("Para pedidos OUTROS com esta TES, é obrigatório informar a Classe de Valor.", "MT410TOK", "ALERT")
			Return(.F.)
		EndIf


		If !Empty(M->C5_YCLVL)
			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(XFilial("CTH")+M->C5_YCLVL)) .And. AllTrim(CTH->CTH_YCC) == "2000" .And. ( Empty(M->C5_YITEMCT) .Or. Empty(M->C5_YSI) )
				MsgBox("Para classe de valor 2000, favor informar o Item Contábil e Cliente da AI", "MT410TOK", "ALERT")
				Return(.F.)
			EndIf
		EndIf

	EndIf

	// Tiago Rossini -- OS: 4326-15 - Claudeir Fadini - Bloqueio de Pedidos tipo 'B' para representantes na empresa Biancogres
	If nOpc == 3 .And. !Empty(cRepAtu) .And. Alltrim(M->C5_YSUBTP) == "B" .And. Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_YTRTESP") == "1" .And. cEmpAnt == "01"
		MsgBox("Tipo de venda bloqueada para representantes", "Atencao", "ALERT")
		Return(.F.)
	EndIf


	//Calculo valor total do pedido para validacoes abaixo
	If lRetorno .and. (nOpc == 3 .Or. nOpc == 4)

		nValPedX := 0
		For I := 1 To Len(aCols)
			If !aCols[I][Len(aHeader)+1]
				//Somando valor total do pedido
				nValPedX += aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})]
			EndIf
		Next I

	EndIf

	//Projeto contrato de verbas
	If lRetorno .and. (nOpc == 3 .Or. nOpc == 4) .and. M->C5_YSUBTP = 'B' .and. !Empty(M->C5_YCTRVER)

		nSaldoX  := U_FCTVUT01(M->C5_YCTRVER, 1) - U_FCTVUT01(M->C5_YCTRVER, 2)

		if nSaldoX < nValPedX
			lRetorno := .F.
			MsgBox("O contrato numero "+M->C5_YCTRVER+" não possui saldo suficiente para este pedido: ";
				+CRLF+"Saldo do Contrato: " + Alltrim(Transform(nSaldoX,"@E 999,999,999,999.99")), "MT410TOK", "STOP")
		endif
	endif


	// Tiago Rossini -- Ticket: 19122 - Melhoria no sistema para controlar Vistoria em Obras de Engenharia
	If nOpc == 3 .Or. nOpc == 4

		DbSelectArea("SA1")
		DbSetOrder(1)
		If SA1->(DbSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI))

			If SA1->A1_YTPSEG == "E" .And. M->C5_TIPO == "N" .And. (SB1->(DbSeek(XFilial("SB1") + GdFieldGet("C6_PRODUTO"))) .And. SB1->B1_TIPO == "PA") .And. Empty(M->(C5_YMAILEN))

				MsgBox("Favor informar o e-mail do engenheiro responsável pela obra.", "MT410TOK", "ALERT")

				Return(.F.)

			EndIf

		EndIf

	EndIf

	//Projeto engenharia fase 2
	//Comentado abaixo - descomentar apos comercial validar processo de engenharia fase 2
	// 	If lRetorno .and. (nOpc == 3 .Or. nOpc == 4) .and. Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_YTPSEG") == "E" .and. Empty(M->C5_YNPRENG)
	// 	__nVMaxEng := GetNewPar("FA_VENGMAX",2000)
	// 	If ( nValPedX > __nVMaxEng )
	// 	lRetorno := .F.
	// 	U_FROPMSG("Canal Engenharia", "ATENÇÃO!"+CRLF+;
	// 	"NÃO Existe proposta aprovada para este cliente."+CRLF+;
	// 	"Para pedidos de volume maior que "+AllTrim(Str(__nVMaxEng))+" é obrigatório informar a proposta.", {"OK"}, 2, "Verificando Propostas")
	// 	EndIf
	// EndIf

	RestArea(aArea)
Return(lRetorno)

	

Static Function ValiPonta(_cProd, _cLote, _nQtdDig, _cPedido,_cItem, _cEmpPed, _cFilPed, nI, _cPedAtu)

	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local _lPswOk	:= .F.
	Local _lRet		:= .T.
	Local _aRet		:= {}
	Local _cGerente := U_FRGERADM(IIF(cEmpAnt=='07', M->C5_NUM, _cPedido))

	_aRet := U_FR2CHKPT(_cProd, _cLote, _nQtdDig,,_cPedido,_cItem, "", _cEmpPed, _cFilPed)

	//se vai gerar ponta - aciona autorizacao de superior
	If ( _aRet[1] == "P" )

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFilial("SB1")+_cProd))

		_aRetAut	:= U_FROPTE10(AllTrim(SB1->B1_DESC),_cLote,Transform(_nQtdDig,"@E 999,999.99"),Transform(_aRet[2],"@E 999,999.99"),Transform(_aRet[2]+_nQtdDig,"@E 999,999.99"),_cGerente)
		_lPswOk		:= _aRetAut[1]

		If (_lPswOk)

			_lRet := .T.
			Gdfieldput("C6_YMOTFRA"	,"998", nI) //Marcando como gerado ponta para relatorio

			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(XFilial("SC6")+_cPedAtu+_cItem))
				U_GravaPZ2(SC6->(RecNo()),"SC6",_aRetAut[4],_aRetAut[3],AllTrim(FunName()),"AGP", _aRetAut[2] )
			EndIf

		Else

			_lRet := .F.

		EndIf

	EndIf

	RestArea(aArea)
	SB1->(RestArea(aAreaSB1))
	SC6->(RestArea(aAreaSC6))

Return _lRet
