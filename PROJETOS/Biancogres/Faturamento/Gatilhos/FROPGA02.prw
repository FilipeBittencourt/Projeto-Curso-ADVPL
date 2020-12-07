#include "PROTHEUS.CH"
#include "TOPCONN.CH"

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

/*/{Protheus.doc} FROPGA02
@description Gatilho para calculo de estoque e reserva de OP.	
@author Fernando Rocha
@since 18/02/2014
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

User Function FROPGA02()
	Local aArea := GetArea()
	Local cMVPAR01 := MV_PAR01
	Local I

	Local _nSaldo	:= 0
	Local _lBlqPesq := .F.
	Local _cEmpOri	:= ""
	Local _cLocEst	:= ""
	Local _aSaldo	:= Nil
	Local _lOk		:= .F.
	Local _cProd 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
	Local _cLocal 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})]
	Local _nPTPEST 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})
	Local _nPENTREG	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})
	Local _nPNECESS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDTNECE"})
	Local _nPLOTE	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})
	Local _nPMOTFR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YMOTFRA"})
	Local _nQtdDig 	:= Round(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})],2)

	Local _cItem 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})]
	Local _nPrcVen 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})]
	Local _nPTotal	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
	Local _nPBLQLOT	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YBLQLOT"})

	Local _nPQTDSUG	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YQTDSUG"})
	Local _nPLOTSUG	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YLOTSUG"})
	Local _nPLOTTOT	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YLOTTOT"})

	Local _nPLOCAL	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})
	Local _nPYEMP	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YEMPPED"})

	Local _nQtdDigPC	:= Round(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YQTDPC"})],2)
	Local _cBlq			:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_BLQ"})]



	Local _nQtdRet		:= 0
	Local _aRetOP
	Local _lAchouOPE	:= .F.
	Local _cSegmento	:= "R"

	Local _aDadCli		:= {}
	Local _cTrtEsp		:= ""
	Local _cCategoria	:= ""
	Local _cLotRes		:= ""
	Local _cUFCli		:= ""

	Local _aRetLot
	Local _nRet			:= 0

	//identificar produto PR (sem lote e localizacao) p- Ticket 4910
	Local _lProdPR		:= .F.

	//Parametros para pergunta do motivo do lote
	Local aPergs	:= {}
	Local aRet 		:= {""}
	Local _cRestri	:= ""
	Local _lPalete 	:= .F.
	Local _lSimPalet := .F.
	Local __lOkPalete := .F.

	//Parametro para Filtrar tipo de pedido que não entram na regra do projeto reserva/pesquisa de lote
	Local _cTpNPLot := GetNewPar("FA_TPNLOT","A #M #G #B #RI#F #VO#")
	Local _cTpNRes	:= GetNewPar("FA_TPNRES","A #RI#F #")
	Local __cLocAmo := AllTrim(GetNewPar("FA_LOCAMO","05"))
	Local cCodMot	:= space(03)

	//Empresas - Vitcer nao usa
	If AllTrim(CEMPANT) == "14"
		aCols[N][_nPTPEST] := "E"
		Return(_nQtdDig)
	EndIf

	//Tratamento outros tipos de pedido
	If M->C5_TIPO <> "N"
		Return(_nQtdDig)
	EndIf

	//Tratamento para linha Mundialli - nao usa conceito de lotes
	If M->C5_YLINHA == "4"
		Return(_nQtdDig)
	EndIf

	//Fernando/Facile em 03/11/15 - forçar o Almoxarifado 05 para amostra - Nao vai mais entrar no bloco abaixo - vai passar a gerar reserva para Amostra
	//If (AllTrim(M->C5_YSUBTP) $ "A#M#F")
	//	aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})] := "05"
	//	_cLocal := "05"
	//EndIf

	If (M->C5_YSUBTP $ _cTpNRes)  //Tipos de pedido que nao gera reserva - tambem nao pesquisar lote. Fernando em 20/02/2015
		Return(_nQtdDig)
	EndIf

	//Tratamento outro produtos
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. !(SB1->B1_TIPO $ "PA#PR")  //Ticket 4910 adicionado PR para manta do porcelanato pratico
		Return(_nQtdDig)
	EndIf

	If (AllTrim(_cBlq) == 'R')
		MsgAlert("Item pedido com residuo eliminado.")
		Return(_nQtdDig)
	EndIf

	If (cEmpAnt+cFilAnt == '0701' .And. ALTERA .And. AllTrim(M->C5_CLIENTE) == '029954' .And. M->C5_YLINHA == "6")
		Return(_nQtdDig)
	EndIf

	// Projeto JK
	If AllTrim(cEmpAnt) == "06" .And. AllTrim(M->C5_CLIENTE) == '000481'
		return(_nQtdDig)
	EndIf

	/*//Tratamento produtos classe B/Cliente Livre revestimetos - nao fazer tratamento de lote/reserva - Fernando em 17/08/15 - OS 2831-15 
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. AllTrim(SB1->B1_YCLASSE) == "2" .And. (M->C5_CLIENTE == "006338")
	U_FROPPYC2()
	Return(_nQtdDig)
	EndIf
	*/

	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")

		Return(_nQtdDig)
	EndIf

	//Verificando Segmento do Cliente
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(XFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))

		_aDadCli	:= U_fInfCliente(M->C5_YLINHA, M->C5_CLIENTE, M->C5_LOJACLI)
		_cTrtEsp	:= _aDadCli[1]
		_cCategoria	:= _aDadCli[2]
		_cSegmento	:= _aDadCli[3]
		_cLotRes 	:= _aDadCli[4]

		_cUFCli		:= SA1->A1_EST

	EndIf

	If ( _cSegmento == "E" .And. ALLTRIM(__READVAR) == 'M->C6_QTDVEN' .And. Empty(aCols[N][_nPNECESS]) .And. !(AllTrim(M->C5_YSUBTP) $ "A#M#F") )
		U_FROPMSG(TIT_MSG, 	"SEGMENTO: ENGENHARIA"+CRLF+;
		"Favor preencher da DATA DE NECESSIDADE.",;
		,,"Pesquisa de OP disponível")
		_nQtdRet := _nQtdDig
		RestArea(aArea)
		return(_nQtdRet)
	EndIf

	If (AllTrim(M->C5_YSUBTP) == 'M' .And. ALLTRIM(__READVAR) == 'M->C6_QTDVEN')
		MsgAlert("Pedido do Tipo 'M=Mostruário' é permitido a digitação apenas no campo 'Qtd em PC'.")
		RestArea(aArea)

		If (_nQtdDigPC > 0)
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+_cProd))
				If SB1->B1_UM == "PC"
					Return (_nQtdDigPC)
				Else
					Return (ROUND(_nQtdDigPC/SB1->B1_YPECA*SB1->B1_CONV, 2))
				EndIf
			EndIf
			SB1->(DbCloseArea())
		EndIf

		Return(0)

	EndIf


	//Posicionar Produto
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProd))

	_lProdPR := (SB1->B1_TIPO == "PR")


	//Cliente que somente aceita paletizado - Fernando/Facile em 27/01/2015
	If  SA1->A1_YPALETE == '1' .And. !(AllTrim(M->C5_YSUBTP) $ "A#M#F")

		__aPal := CalcPalete(_nQtdDig)
		If (__aPal[2] <> _nQtdDig)

			_nRet := U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
			"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+;
			"DESEJA ARREDONDAR PARA: "+AllTrim(Str(__aPal[1]))+" PALETE(S) = "+AllTrim(Str(__aPal[2]))+" m2",;
			{"ACEITAR","REJEITAR"},2,"SUGESTÃO DE PALETE FECHADO")

			If (_nRet == 1) //aceitou
				_nQtdDig := __aPal[2]
				_nQtdRet := _nQtdDig
				_lPalete := .T. //marca pedido paletizado para nao entrar na sugestao de fracionado
			EndIf
		Else
			_lPalete := .T. //Ja digitou paletizado - marca pedido paletizado para nao entrar na sugestao de fracionado
		EndIf

	EndIf

	//Salvar conteudo padrao campo de bloqueio de lote
	aCols[N][_nPBLQLOT] := StrZero(0,TamSX3("C6_YBLQLOT")[1])

	//ENGENHARIA - se nao achar OP e for para menos de Z6_PRZENG procurar estoque imediato
	If ( _cSegmento == "E" .And. !(AllTrim(M->C5_YSUBTP) $ "A#M#F") )

		//Procurar OP para reserva
		If Empty(aCols[N][_nPNECESS])
			U_FROPMSG(TIT_MSG, 	"SEGMENTO: ENGENHARIA"+CRLF+;
			"Obrigatório preenchimento da DATA DE NECESSIDADE.",;
			,,"Pesquisa de OP disponível")
			_aRetOP := {Nil}
		Else

			//Ajuste para quoantidade de palete - se for reserva de OP - fernando em 30/12/2014
			__aPal := CalcPalete(_nQtdDig)
			__lOkPalete := .T.
			If (__aPal[2] <> _nQtdDig)
				_nRet := U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
				"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+;
				"O sistema vai pesquisar Previsão de Produção: "+CRLF+;
				"DESEJA ARREDONDAR PARA: "+AllTrim(Str(__aPal[1]))+" PALETE(S) = "+AllTrim(Str(__aPal[2]))+" m2",;
				{"ACEITAR","REJEITAR"},2,"Pesquisa de Previsão de Produção")

				//Obriga a informar o motivo - caso contra´rio aceita a sugestão.
				If !(_nRet == 1)
					PZ7->(DbSetOrder(1))

					aPergs := {}
					aAdd( aPergs ,{1,"Motivo da Rejeição: ",cCodMot,"@!",'U_FRG2VMOT()',"PZ7",'.T.',10,.T.})

					//fernando/facile em 30/03/2016 - bloquendo a selecao dos motivos reservados 998 e 999
					If !ParamBox(aPergs ,"Motivo da Rejeição de Paletizado",aRet,,,,,,,,.F.,.F.) .Or. Empty(aRet[1]) .Or. ( AllTrim(aRet[1]) $ "998#999" )
						U_FROPMSG(TIT_MSG, 	"Motivo não informado ou inválido. Verifique.",,,"MOTIVO DA REJEIÇÃO")
						__lOkPalete := .F.
						_nQtdRet := 0
					Else
						aCols[N][_nPMOTFR] := aRet[1]
					EndIf
				Else
					_lSimPalet := .T.
					_nQtdDig := __aPal[2]
				EndIf
			EndIf

			If __lOkPalete

				//Ticket 26369 - Alterar número de 90 para 120 dias, solicitação do Claudeir.
				//Ticket 26607 - Alterar número de 120 para 150 dias, solicitação do Claudeir.
				//Engenharia dt necessidade maior que (90 anteriormente) 120 dias - nao procura OP e coloca status "V"
				If (aCols[N][_nPNECESS] - dDataBase) > 150
					_aRetOP := {Nil}
					aCols[N][_nPTPEST] := "V"  //nao informou motivo - aborta
					aCols[N][_nPENTREG] := aCols[N][_nPNECESS]
					aCols[N][_nPMOTFR] := Space(3)
					aCols[N][_nPBLQLOT] := StrZero(0,TamSX3("C6_YBLQLOT")[1])

					U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
					"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+CRLF+;
					"Não existe previsão de produção para mais de 150 dias."+CRLF+;
					"Este pedido será vinculado a uma OP futura.",;
					,,"Produto sem Previsão de Produção")

					_nQtdRet 	:= _nQtdDig

					//OP futura sempre vincular a Biancogres - projeto consolidacao - 14/11/2018
					_cEmpOri	:= "01"
					SBZ->(DbSetOrder(1))
					If SBZ->(DbSeek(XFilial("SBZ")+_cProd)) .And. !Empty(SBZ->BZ_LOCPAD)
						_cLocEst	:= SBZ->BZ_LOCPAD
					EndIf

					_lAchouOPE 	:= .T.
				Else
					_aRetOP := U_FRRT04PO(M->C5_NUM,_cItem,_cProd, _nQtdDig,,_cSegmento, aCols[N][_nPNECESS])
				EndIf

			Else
				_aRetOP := {Nil}
				aCols[N][_nPTPEST] := "N"  //nao informou motivo - aborta
				aCols[N][_nPENTREG] := ctod(" ")
				aCols[N][_nPNECESS] := ctod(" ")
				aCols[N][_nPMOTFR] := Space(3)
				aCols[N][_nPBLQLOT] := StrZero(0,TamSX3("C6_YBLQLOT")[1])
				_nQtdRet := 0
				_lAchouOPE := .T.
			EndIf

		EndIf

		If _aRetOP[1] <> Nil

			U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
			"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+CRLF+;
			"Previsão de Produção: "+CRLF+;
			"Local: "+_aRetOP[7]+"/"+_aRetOP[8]+CRLF+;
			"OP: "+_aRetOP[1]+"-"+_aRetOP[2]+"-"+_aRetOP[3]+CRLF+;
			"Data da entrega: "+DTOC(_aRetOP[4]),;
			,,"Produto com Previsão de Produção")

			aCols[N][_nPTPEST] := "R"
			aCols[N][_nPENTREG] := Max(U_FROPAD3U(dDataBase), _aRetOP[4]) //data op
			aCols[N][_nPBLQLOT] := StrZero(0,TamSX3("C6_YBLQLOT")[1])

			_cEmpOri	:= _aRetOP[7]
			_cLocEst	:= _aRetOP[8]

			_nQtdRet := _nQtdDig
			_lAchouOPE := .T.

		EndIf

	EndIf
	//FIM ENGENHARIA - Tratamento diferente


	//REVENDA/OUTROS E ENGENHARIA SEM OP - Busca estoque primeiro e OP futura depois
	If !_lAchouOPE

		//fernando em 08/04/15 - limpa bloqueios que pode ter gravado na regra de engenharia
		aCols[N][_nPMOTFR] := Space(3)
		aCols[N][_nPBLQLOT] := StrZero(0,TamSX3("C6_YBLQLOT")[1])

		//Fernando em 25/08 ".And. !_lPalete" - estava perdendo a quantidade arredondada na regra de cliente que so aceita paletizado
		_nQtdDig := Round(IIF(ALLTRIM(__READVAR) == 'M->C6_QTDVEN' .And. !_lPalete .And. !_lSimPalet,M->C6_QTDVEN,_nQtdDig),2)

		If (AllTrim(M->C5_YSUBTP) $ "A#M#F") .And. (_cLocal == __cLocAmo)

			_aSaldo := Array(12)
			_nSaldo := Round(U_FRSLDAMO(_cProd, _cLocal, _nQtdDig),2)

		Else
			/*Formato do vetor _aRetSaldo (Retorno da funcao U_FROPRT01)
			aRet[1] 	:= oPBI:EmpEst			=> Empresa do Estoque	
			aRet[2] 	:= oPBI:LocEst			=> Armazem
			aRet[3] 	:= oPBI:CodProduto		=> Produto
			aRet[4] 	:= oPBI:Prioridade		=> Prioridade
			aRet[5] 	:= oPBI:Lote			=> Lote
			aRet[6] 	:= oPBI:Qtd_Solicit		=> Qtde Solicitada
			aRet[7] 	:= oPBI:Saldo			=> Saldo total do Lote
			aRet[8] 	:= oPBI:Qtd_Sug			=> Qtde sugerida para venda
			aRet[9] 	:= oPBI:N_Pallets		=> Numero de paletes fechados sugeridos para venda
			aRet[10] 	:= oPBI:Qtd_Um_Pallet	=> Qtde m2 de um palete
			aRet[11] 	:= oPBI:Qtd_Ponta		=> Qtde em Ponta/Fracionado sugerido para venda
			aRet[12] 	:= oPBI:Regra_Sug		=> Regra de sugestao usada
			*/

			//TICKET 21667 - pesquisa especifica do lote F35
			If ( GetNewPar("FA_PRCLF35","N") == "S" ) .And. ( M->C5_YLINHA == "1" ) .And. ( SubStr(_cProd,1,2) == "C6" ) .And. ( AllTrim(SB1->B1_YCLASSE) == "1" )


				If ( AllTrim(_cUFCli) $ "ES#MG" ) .And. ( _cSegmento == "R" )

					_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes, /*PROXLOT*/, /*LOTADD*/, "F35" /*LOTEXC*/)
					_nSaldo		:= Round(_aSaldo[7],2)

				Else

					_lBlqPesq	:= .T.
					_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes, /*PROXLOT*/, "F35" /*LOTADD*/, /*LOTEXC*/)
					_nSaldo		:= Round(_aSaldo[7],2)

				EndIf

			EndIf

			If ( !_lBlqPesq ) .And. (_nSaldo <= 0 .Or. _aSaldo == Nil)

				_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes)

			EndIf

			//Informacao de Saldo disponivel somente em outra empresa - prioridade 9 no PBI
			If ( _aSaldo[4] == 9 )

				U_FROPMSG(TIT_MSG, 	"ATENÇÃO, existe ESTOQUE do produto disponível em:"+CRLF+;
				"Empresa: "+IIf(_aSaldo[1]=="13","Mundi",IIf(_aSaldo[1]=="05","Incesa","Biancogres"))+CRLF+;
				"Lote: "+_aSaldo[5]+CRLF+;
				"Saldo: "+Transform(_aSaldo[7],"@R 999.99")+" m2";
				,,,"ESTOQUE EM OUTRA EMPRESA")

				_aSaldo := Array(12)
				_nSaldo		:= 0
				_cEmpOri	:= ""
				_cLocEst	:= ""

			Else

				_nSaldo		:= Round(_aSaldo[7],2)
				_cEmpOri	:= _aSaldo[1]
				_cLocEst	:= _aSaldo[2]

			EndIf

		EndIf

		_lOk	:= .F.


		//Somente para Amostra - verificar se o retorno da funcao de saldo e maior que Qtddig  (pedido normal pode ter sugestao de lote menor)
		If (AllTrim(M->C5_YSUBTP) $ "A#M#F") .And. (_cLocal == __cLocAmo) .And. !((_nSaldo - _nQtdDig) >= 0)

			U_FROPMSG("FROPGA02", "PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
			"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+;
			"Saldo de Amostra: "+AllTrim(Str(_nSaldo))+CRLF+CRLF+;
			"Não existe saldo de amostra para atender esse pedido.",;
			,,"PEDIDO DE AMOSTRA - ALMOXARIFADO 05")

		EndIf

		//bloquear pesquisa de proximo lote
		if (_lBlqPesq .And. _nSaldo == 0)
			_nSaldo = -1
		endif

		//BUSCA DE ESTOQUE IMEDIATO - ENCONTROU ESTOQUE - SUGESTAO E PESQUISA DE MELHOR LOTE
		If (_nSaldo) >= 0

			//Cliente somente aceita paletizado - nao vai entrar na pesquisa de fracionado
			//If _lPalete
			//	_aRetLot := Array(9)
			//Else

			//_cTpNPLot >> SE FOR PEDIDO DE AMOSTRA/BONIFICACAO/etc..  não considera a pesquisa de lote, aceita a qtde digitada como sugestao.
			If (M->C5_YSUBTP $ _cTpNPLot) .OR. _lProdPR

				_aRetLot := Array(9)  //ignora a pesquisa de lote - vai entrar na pesquisa de primeiro lote que nao gera ponta

			Else

				//Procurar o melhor LOTE - Regra de matar pontas de estoque - Fernando - em 10/06/2014
				//No projeto CONSOLIDACAO, o metodo do PBI ja traz as sugestoes de matar ponta

				_aRetLot := Array(9)
				_aRetLot[1] := _aSaldo[5]
				_aRetLot[2] := _aSaldo[7]
				_aRetLot[3] := _aSaldo[8]
				_aRetLot[4] := _aSaldo[9]
				_aRetLot[5]	:= _aSaldo[10]
				_aRetLot[6]	:= _aSaldo[11]
				_aRetLot[7]	:= _aSaldo[12]
				_aRetLot[8]	:= _aSaldo[1]
				_aRetLot[9]	:= _aSaldo[2]

				_cEmpOri := _aRetLot[8]
				_cLocEst := _aRetLot[9]

			EndIf

			//EndIf

			//Pesquisar restricao do LOTE "*"
			ZZ9->(DbSetOrder(1))
			if !Empty(_aRetLot[1]) .And. ZZ9->(DbSeek(XFilial("ZZ9")+PADR(_aRetLot[1],TamSX3("ZZ9_LOTE")[1])+_cProd)) .And. AllTrim(ZZ9->ZZ9_RESTRI) == "*"
				_cRestri := "("+AllTrim(ZZ9->ZZ9_RESTRI)+")"
			endif

			//Achou sugestão diferente da quantidade digitada
			If (!Empty(_aRetLot[1]) .And. _aRetLot[1] <> Nil .And. _aRetLot[3] <> _nQtdDig)

				//Registrando sugestao nos campos de analise de bloqueio - Fernando/Facil em 27/01/2015
				aCols[N][_nPLOTSUG] := _aRetLot[1]//Lote
				aCols[N][_nPLOTTOT] := _aRetLot[2]//Saldo total do lote
				aCols[N][_nPQTDSUG] := _aRetLot[3]//Qtd sugerida

				lShowTSug := .T.

				//TICKET 24431 - foi  solicitado para cliente paletizado exibir a tela de sugestão normalmente
				If _lPalete
					lShowTSug := .F.
				EndIf

				_nRet := 1

				If (lShowTSug)

					//TICKET 24431 - controle de execoes para as quais o botao REJEITAR é exibido - o padrao agora é sempre ACEITAR a sugestao
					//_lShowRej := ( Empty(CREPATU) ) .Or. ( _cSegmento == "E" ) .Or. ( AllTrim(_cCategoria) == "LOJA ESPEC" ) .Or. ( _lPalete ) .Or. ( M->C5_YLINHA == "6" )
					//_nRet := U_FROPTE07(AllTrim(_aRetLot[1])+_cRestri, AllTrim(Str(_aRetLot[2])), AllTrim(Str(_aRetLot[3])), AllTrim(Str(_aRetLot[4])), AllTrim(Str(_aRetLot[5])), AllTrim(Str(_aRetLot[6])),_aRetLot[7],_aRetLot[8],_aRetLot[9], _lShowRej)
					_nRet := U_FROPTE07(AllTrim(_aRetLot[1])+_cRestri, AllTrim(Str(_aRetLot[2])), AllTrim(Str(_aRetLot[3])), AllTrim(Str(_aRetLot[4])), AllTrim(Str(_aRetLot[5])), AllTrim(Str(_aRetLot[6])),_aRetLot[7],_aRetLot[8],_aRetLot[9])
					
				EndIf

				//Estoque Disponível - Gerar reserva SC0 - Sugestão de Lote
				aCols[N][_nPTPEST] := "E"
				aCols[N][_nPENTREG] := U_FROPAD3U(dDataBase)
				If (_cSegmento <> "E")
					aCols[N][_nPNECESS] := ctod(" ")
				EndIf

				//Obriga a informar o motivo - caso contra´rio aceita a sugestão.
				If !(_nRet == 1)
					PZ7->(DbSetOrder(1))

					aPergs := {}
					aAdd( aPergs ,{1,"Motivo da Rejeição: ",cCodMot,"@!",'U_FRG2VMOT()',"PZ7",'.T.',10,.T.})

					//fernando/facile em 30/03/2016 - bloquendo a selecao dos motivos reservados 998 e 999
					If !ParamBox(aPergs ,"Motivo da Rejeição da Sugestão de Lote",aRet,,,,,,,,.F.,.F.) .Or. Empty(aRet[1]) .Or. ( AllTrim(aRet[1]) $ "998#999" )
						U_FROPMSG(TIT_MSG, 	"Motivo não informado ou inválido. Verifique.",,,"MOTIVO DA REJEIÇÃO")
						_nRet := 1
					Else
						aCols[N][_nPMOTFR] := aRet[1]
					EndIf
				Else
					aCols[N][_nPMOTFR] := Space(3)
				EndIf

				If _nRet == 1 //Aceitou sugestão ou informou motivo inválido/vazio
					aCols[N][_nPLOTE] := _aRetLot[1]

					aCols[N][_nPMOTFR] := Space(3)
					_lOk := .T.

				Else

					//Rejeitou a Sugestao
					//Pesquisa do melhor lote para atender - primeiro que atenda e não gere ponta no estoque

					/*Formato do vetor _aRetSaldo (Retorno da funcao U_FROPRT01)
					aRet[1] 	:= oPBI:EmpEst			=> Empresa do Estoque	
					aRet[2] 	:= oPBI:LocEst			=> Armazem
					aRet[3] 	:= oPBI:CodProduto		=> Produto
					aRet[4] 	:= oPBI:Prioridade		=> Prioridade
					aRet[5] 	:= oPBI:Lote			=> Lote
					aRet[6] 	:= oPBI:Qtd_Solicit		=> Qtde Solicitada
					aRet[7] 	:= oPBI:Saldo			=> Saldo total do Lote
					aRet[8] 	:= oPBI:Qtd_Sug			=> Qtde sugerida para venda
					aRet[9] 	:= oPBI:N_Pallets		=> Numero de paletes fechados sugeridos para venda
					aRet[10] 	:= oPBI:Qtd_Um_Pallet	=> Qtde m2 de um palete
					aRet[11] 	:= oPBI:Qtd_Ponta		=> Qtde em Ponta/Fracionado sugerido para venda
					aRet[12] 	:= oPBI:Regra_Sug		=> Regra de sugestao usada
					*/
					_nProxLote := 1

					//TICKET 21667 - pesquisa especifica do lote F35
					//Fernando em 2//3/2020 corrigida logica para o lote F35		
					IF ( GetNewPar("FA_PRCLF35","N") == "S" ) .And. ( M->C5_YLINHA == "1" ) .And. ( SubStr(_cProd,1,2) == "C6" ) .And. ( AllTrim(SB1->B1_YCLASSE) == "1" )

						If ( AllTrim(_cUFCli) $ "ES#MG" ) .And. ( _cSegmento == "R" )

							//Pesquisa primeiro lote que NÃO GERE PONTA (_nProxLote := 1) e Não seja F35
							_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes, _nProxLote, /*LOTADD*/, "F35" /*LOTEXC*/)
							_nSaldo		:= Round(_aSaldo[7],2)

							// NAO Achou sem F35 - Pesquisa todos mas que nao gere PONTA
							If (_nSaldo <= 0 .Or. _aSaldo == Nil)

								_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes, _nProxLote)

							EndIf

						Else

							//Pesquisa primeiro lote que NÃO GERE PONTA e seja somente F35
							_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes, _nProxLote, "F35" /*LOTADD*/, /*LOTEXC*/)
							_nSaldo		:= Round(_aSaldo[7],2)

						EndIf

					ELSE

						//Outros produtos fora da regra F35 - Pesquisa primeiro lote que NÃO GERE PONTA (_nProxLote := 1)
						_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes, _nProxLote)

					ENDIF

					//No projeto CONSOLIDACAO, o metodo do PBI ja traz as sugestoes de matar ponta
					_aRetLot := Array(9)
					_aRetLot[1] := _aSaldo[5]
					_aRetLot[2] := _aSaldo[7]
					_aRetLot[3] := _aSaldo[8]
					_aRetLot[4] := _aSaldo[9]
					_aRetLot[5]	:= _aSaldo[10]
					_aRetLot[6]	:= _aSaldo[11]
					_aRetLot[7]	:= _aSaldo[12]
					_aRetLot[8]	:= _aSaldo[1]
					_aRetLot[9]	:= _aSaldo[2]

					_cEmpOri := _aRetLot[8]
					_cLocEst := _aRetLot[9]

					//Achou lote
					If (!Empty(_aRetLot[1]) .And. _aRetLot[1] <> Nil)

						aCols[N][_nPLOTE] := _aRetLot[1]
						_lOk := .T.

					Else

						//Se nao achou um lote que nao gere ponta, e rejeitou a sugestao, direcionar para OP
						aCols[N][_nPLOTE] := Space(TamSx3("C6_LOTECTL")[1])
						_lOk := .F.

					EndIf

				EndIf

				If (lShowTSug)
					_nQtdRet := IIF(_nRet == 1, _aRetLot[3], _nQtdDig)
				Else
					_nQtdRet := _nQtdDig
				EndIf

				//Achou sugestão igual a Quantida OU não teve lote sugerido devido ao Percentual de sugestao
			Else

				//Nao achou sugestao ou sugestao igual ao solicitado
				_lOk := .T.

				//Nao achou Sugestao
				If (Empty(_aRetLot[1]) .Or. _aRetLot[1] == Nil)

					If _lProdPR
						//produto PR - entra nesta pesquisa que considera produtos sem localizacao
						_aRetLot := U_FRRT01P3(_cProd, _cLocal, _nQtdDig)
					ElseIf !((AllTrim(M->C5_YSUBTP) $ "A#M#F") .And. (_cLocal == __cLocAmo))

						//Pesquisa do melhor lote para atender - primeiro que atenda e não gere ponta no estoque

						/*Formato do vetor _aRetSaldo (Retorno da funcao U_FROPRT01)
						aRet[1] 	:= oPBI:EmpEst			=> Empresa do Estoque	
						aRet[2] 	:= oPBI:LocEst			=> Armazem
						aRet[3] 	:= oPBI:CodProduto		=> Produto
						aRet[4] 	:= oPBI:Prioridade		=> Prioridade
						aRet[5] 	:= oPBI:Lote			=> Lote
						aRet[6] 	:= oPBI:Qtd_Solicit		=> Qtde Solicitada
						aRet[7] 	:= oPBI:Saldo			=> Saldo total do Lote
						aRet[8] 	:= oPBI:Qtd_Sug			=> Qtde sugerida para venda
						aRet[9] 	:= oPBI:N_Pallets		=> Numero de paletes fechados sugeridos para venda
						aRet[10] 	:= oPBI:Qtd_Um_Pallet	=> Qtde m2 de um palete
						aRet[11] 	:= oPBI:Qtd_Ponta		=> Qtde em Ponta/Fracionado sugerido para venda
						aRet[12] 	:= oPBI:Regra_Sug		=> Regra de sugestao usada
						*/
						_nProxLote := 1
						//If (_aRetLot[7] <> Nil .And. cvaltochar(_aRetLot[7]) $ '3_4')
						//	_nProxLote := 2
						//EndIf

						_aSaldo 	:= U_FROPRT01(_cProd,_cLocal,M->C5_NUM,_cItem,_nQtdDig,,_cSegmento, IIF(INCLUI,"",M->C5_YEMPPED), _lPalete, _cCategoria, _cLotRes, _nProxLote)

						//No projeto CONSOLIDACAO, o metodo do PBI ja traz as sugestoes de matar ponta
						_aRetLot := Array(9)
						_aRetLot[1] := _aSaldo[5]
						_aRetLot[2] := _aSaldo[7]
						_aRetLot[3] := _aSaldo[8]
						_aRetLot[4] := _aSaldo[9]
						_aRetLot[5]	:= _aSaldo[10]
						_aRetLot[6]	:= _aSaldo[11]
						_aRetLot[7]	:= _aSaldo[12]
						_aRetLot[8]	:= _aSaldo[1]
						_aRetLot[9]	:= _aSaldo[2]

						_cEmpOri := _aRetLot[8]
						_cLocEst := _aRetLot[9]

					Else

						If (AllTrim(cEmpAnt) == '07')

							SB1->(DbSetOrder(1))
							IF SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. !Empty(SB1->B1_YEMPEST)

								nLinhaEmp := SB1->B1_YEMPEST
								_aRetLot := U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_FRRT01P3", _cProd, _cLocal, _nQtdDig)

							EndIf
						Else

							//Amostra - primeiro lote
							_aRetLot := U_FRRT01P3(_cProd, _cLocal, _nQtdDig)

						EndIf

					EndIf

					//Achou lote
					If (!Empty(_aRetLot[1]) .And. _aRetLot[1] <> Nil) .OR. (_lProdPR)
						_lOk := .T.

						//Fernando em 25/10/18 => registrar os campos retornados pela pesquisa de lote - mesmo que nao haja tela e sugestao
						//Precisa destes campos para compor o DESCONTO de PALETIZADO
						//Ticket 9434

						aCols[N][_nPLOTSUG] := _aRetLot[1]//Lote
						aCols[N][_nPLOTTOT] := _aRetLot[2]//Saldo total do lote
						aCols[N][_nPQTDSUG] := _aRetLot[3]//Qtd sugerida

					Else
						//nao achou lote - ignora - vai para pesquisa de OP
						_lOk := .F.
					EndIf

				Else

					//Fernando em 25/10/18 => registrar os campos retornados pela pesquisa de lote - mesmo que nao haja tela e sugestao
					//Precisa destes campos para compor o DESCONTO de PALETIZADO
					//Ticket 9434

					aCols[N][_nPLOTSUG] := _aRetLot[1]//Lote
					aCols[N][_nPLOTTOT] := _aRetLot[2]//Saldo total do lote
					aCols[N][_nPQTDSUG] := _aRetLot[3]//Qtd sugerida

				EndIf

				If _lOk

					//Estoque Disponível - Gerar reserva SC0 - Validou a quantidade digitada
					aCols[N][_nPTPEST] := "E"
					aCols[N][_nPENTREG] := U_FROPAD3U(dDataBase)
					If (_cSegmento <> "E")
						aCols[N][_nPNECESS] := ctod(" ")
					EndIf

					If !Empty(_aRetLot[1])
						aCols[N][_nPLOTE] 	:= _aRetLot[1]
					EndIf

					_nQtdRet := _nQtdDig
					_lOk := .T.

				Else

					//Se engenharia ja abortar a sugestao - pois ja tratou todas as possibilidades
					If (AllTrim(M->C5_YSUBTP) $ "A#M#F") .And. (_cLocal == __cLocAmo)

						U_FROPMSG("FROPGA02", "PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
						"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+;
						"Saldo de Amostra: "+AllTrim(Str(_nSaldo))+CRLF+CRLF+;
						"Não existe saldo de amostra para atender esse pedido.",;
						,,"PEDIDO DE AMOSTRA - ALMOXARIFADO 05")

					ElseIf _cSegmento == "E"

						U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
						"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))/*+" - Estoque disponível: "+AllTrim(Str(_nSaldo))*/+CRLF+;
						"Não foi encontrado estoque ou OP. Verificar próximas produções com setor de PCP.",;
						,,"ESTOQUE NÃO DISPONÍVEL")

						aCols[N][_nPTPEST] := "N"  //Sem estoque disponivel nem previsao de producao
						aCols[N][_nPENTREG] := ctod(" ")
						aCols[N][_nPNECESS] := ctod(" ")

					EndIf

				EndIf

			EndIf

		EndIf


		If (!_lOk)
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. AllTrim(SB1->B1_YCLASSE) == "2" .And. (M->C5_CLIENTE == "006338")
				U_FROPPYC2()
				Return(_nQtdDig)
			EndIf
		EndIf


		//BUSCA DE OP FUTURA
		If !_lOk .And. !(AllTrim(M->C5_YSUBTP) $ "A#M#F")  //amostra nao pesquisa OP

			//fernando em 08/04/15 se entrou na pesquisa de op limpa o possivel motivo para avaliar so na pesquisa de op
			aCols[N][_nPMOTFR] := Space(3)
			aCols[N][_nPBLQLOT] := StrZero(0,TamSX3("C6_YBLQLOT")[1])

			__lOkPalete := .T.
			If _cSegmento <> "E" //nao faz mais para engenharia - ja tratado antes do estoque
				//Ajuste para quoantidade de palete - se for reserva de OP - fernando em 30/12/2014
				__aPal := CalcPalete(_nQtdDig)
				If (__aPal[2] <> _nQtdDig)
					_nRet := U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
					"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+;
					"Não existe estoque disponível, o sistema vai pesquisar Previsão de Produção: "+CRLF+;
					"DESEJA ARREDONDAR PARA: "+AllTrim(Str(__aPal[1]))+" PALETE(S) = "+AllTrim(Str(__aPal[2]))+" m2",;
					{"ACEITAR","REJEITAR"},2,"Pesquisa de Previsão de Produção")

					//Obriga a informar o motivo - caso contra´rio aceita a sugestão.
					If !(_nRet == 1)
						PZ7->(DbSetOrder(1))

						aPergs := {}
						aAdd( aPergs ,{1,"Motivo da Rejeição: ",cCodMot,"@!",'U_FRG2VMOT()',"PZ7",'.T.',10,.T.})

						//fernando/facile em 30/03/2016 - bloquendo a selecao dos motivos reservados 998 e 999
						If !ParamBox(aPergs ,"Motivo da Rejeição de Paletizado",aRet,,,,,,,,.F.,.F.) .Or. Empty(aRet[1]) .Or. ( AllTrim(aRet[1]) $ "998#999" )
							U_FROPMSG(TIT_MSG, 	"Motivo não informado ou inválido. Verifique.",,,"MOTIVO DA REJEIÇÃO")
							__lOkPalete := .F.
							_nQtdRet := 0
						Else
							aCols[N][_nPMOTFR] := aRet[1]
						EndIf
					Else
						_lSimPalet := .T.
						_nQtdDig := __aPal[2]
					EndIf
				EndIf
			EndIf

			If __lOkPalete
				//Procurar OP para reserva
				If _cSegmento <> "E"

					_aRetOP := U_FRRT04PO(M->C5_NUM,_cItem,_cProd, _nQtdDig)

					If _aRetOP[1] <> Nil

						U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
						"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+CRLF+;
						"Previsão de Produção: "+CRLF+;
						"Local: "+_aRetOP[7]+"/"+_aRetOP[8]+CRLF+;
						"OP: "+_aRetOP[1]+"-"+_aRetOP[2]+"-"+_aRetOP[3]+CRLF+;
						"Data da entrega: "+DTOC(_aRetOP[4]),;
						,,"Produto com Previsão de Produção")

						aCols[N][_nPTPEST] := "R"
						aCols[N][_nPENTREG] := Max(U_FROPAD3U(dDataBase), _aRetOP[4]) //data op

						_cEmpOri	:= _aRetOP[7]
						_cLocEst	:= _aRetOP[8]

						_nQtdRet := _nQtdDig

					Else

						U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
						"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))/*+" - Estoque disponível: "+AllTrim(Str(_nSaldo))*/+CRLF+;
						"Não foi encontrado estoque ou OP. Verificar próximas produções com setor de PCP.",;
						,,"ESTOQUE NÃO DISPONÍVEL")

						aCols[N][_nPTPEST] := "N"  //Sem estoque disponivel nem previsao de producao
						aCols[N][_nPENTREG] := ctod(" ")
						aCols[N][_nPNECESS] := ctod(" ")

					EndIf

					//ENGENHARIA - pesquisa OP futura acima da data
				Else

					//_aRetOP := U_FRRT04PO(M->C5_NUM,_cItem,_cProd, _nQtdDig)
					_aRetOP := U_FRRT04PO(M->C5_NUM,_cItem,_cProd, _nQtdDig,,_cSegmento)  //passa o segmento mas sem necessidade - pesquisar qualquer OP para frente da necessidade

					If _aRetOP[1] <> Nil

						//ENGENHARIA - Pergunta se aceita producao futura
						_nRet := U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
						"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+CRLF+;
						"Encontrada previsão de produção com data superior a solicitada."+CRLF+;
						"OP: "+_aRetOP[1]+"-"+_aRetOP[2]+"-"+_aRetOP[3]+CRLF+;
						"A nova data de NECESSIDADE será altera para: "+DTOC(_aRetOP[4])+CRLF+;
						"DESEJA PROSSEGUIR COM O PEDIDO?",;
						{"ACEITAR","REJEITAR"},,"Previsão de Produção para: "+DTOC(_aRetOP[4]))

						If (_nRet == 1)
							aCols[N][_nPTPEST] := "R"
							aCols[N][_nPENTREG] := Max(U_FROPAD3U(dDataBase), _aRetOP[4]) //data op
							aCols[N][_nPNECESS] := Max(U_FROPAD3U(dDataBase), _aRetOP[4]) //data op

							_cEmpOri	:= _aRetOP[7]
							_cLocEst	:= _aRetOP[8]

							_nQtdRet := _nQtdDig
						Else
							aCols[N][_nPTPEST] := "N"
							aCols[N][_nPENTREG] := ctod(" ")
							aCols[N][_nPNECESS] := ctod(" ")
						EndIf

					Else

						U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
						"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))/*+" - Estoque disponível: "+AllTrim(Str(_nSaldo))*/+CRLF+;
						"Não foi encontrado estoque ou OP. Verificar próximas produções com setor de PCP.",;
						,,"ESTOQUE NÃO DISPONÍVEL")

						aCols[N][_nPTPEST] := "N"  //Sem estoque disponivel nem previsao de producao
						aCols[N][_nPENTREG] := ctod(" ")
						aCols[N][_nPNECESS] := ctod(" ")

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	//Preencher campo LOCAL no SC6 pois pode ser diferente do padrao - projeto PBI/Consolidacao - Fernando em 24/10/2018
	If !Empty(_cLocEst)
		aCols[N][_nPLOCAL]	:= _cLocEst
	EndIf

	If !Empty(_cEmpOri)
		aCols[N][_nPYEMP]	:= _cEmpOri
	Else
		If (AllTrim(CEMPANT) <> "07")
			aCols[N][_nPYEMP]	:= CEMPANT
		Else
			SB1->(DbSetOrder(1))
			IF SB1->(DbSeek(XFilial("SB1")+_cProd))
				aCols[N][_nPYEMP] := SubStr(SB1->B1_YEMPEST,1,2)
			ENDIF
		EndIf
	EndIf

	//Check de Empresa origem LM - projeto PBI - Fernando em 17/07/2018
	If (AllTrim(CEMPANT) == "07") .And. !Empty(_cEmpOri)

		M->C5_YEMPPED 	:= _cEmpOri

		If ( Len(aCols) > 1 )

			For I := 1 To Len(aCols)

				If !GdDeleted(I) .And. I <> N .And. !Empty(aCols[I][_nPYEMP]) .And. aCols[I][_nPYEMP] <> _cEmpOri

					U_FROPMSG(TIT_MSG, 	"PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
					"Qtde Solicitada: "+AllTrim(Str(_nQtdDig))+CRLF+CRLF+;
					"Produto com estoque em empresa diferente de outro item já adicionado a este pedido."+CRLF+;
					"Necessário colocar em pedidos diferentes.",;
					,,"Estoque em empresa diferente.")

					_nQtdRet := 0
					exit
				EndIf

			Next I

		EndIf

	EndIf

	MV_PAR01 := cMVPAR01

	If (_nPrcVen > 0 .And. _nQtdRet > 0)
		aCols[N][_nPTotal] := Round( _nQtdRet * _nPrcVen ,2)
	EndIf

	U_FROPCLFU()

	RestArea(aArea)
return(_nQtdRet)


//calcular quantidade em palete fechado para atender pedido - produto posicionado - para reserva de OP
Static Function CalcPalete(nQtdM2)
	Local nQtdCX
	Local nDivPA := SB1->B1_YDIVPA
	Local nQtdPalet, nInteiro, nDecimal

	//Define quantidade na 2 Unidade de Medida
	If SB1->B1_TIPCONV == "D"
		nQtdCX		:= (nQtdM2 / SB1->B1_CONV)
	Else
		nQtdCX		:= (nQtdM2 * SB1->B1_CONV)
	EndIf

	nQtdPalet	:= nQtdCX / nDivPA

	nInteiro	:= INT(nQtdPalet)
	nDecimal	:= (nQtdPalet - INT(nQtdPalet))

	If nDecimal <> 0

		//Define as novas quantidades
		nQtdPalet	:= nInteiro + 1
		nQtdCX		:= nQtdPalet * nDivPA

		If SB1->B1_TIPCONV == "D"
			nQtdM2	:= (nQtdCX * SB1->B1_CONV)
		Else
			nQtdM2	:= (nQtdCX / SB1->B1_CONV)
		EndIf

	EndIf

Return({nQtdPalet,nQtdM2})


//VALIDAR A SELECAO DO MOTIVO DE REJEICAO NOS PARAMBOX ACIMA
User Function FRG2VMOT

	Local _cCod := MV_PAR01

	PZ7->(DbSetOrder(1))
	If !PZ7->(DbSeek(XFilial("PZ7")+_cCod))
		MsgAlert("MOTIVO INEXISTENTE!","ATENÇÃO")
		Return(.F.)
	EndIf

	If AllTrim(_cCod) $ "998#999"
		MsgAlert("MOTIVO RESERVADO DO SISTEMA - PROIBIDO O USO!","ATENÇÃO")
		Return(.F.)
	EndIf

Return(.T.)

/*/{Protheus.doc} FROPCLFU
@description //Regras para cliente 006338 para pedidos com produto B1_YCLASSE = '2' procurar OP de produto B1_YCLASSE = '1', 
Atualizar data entrega com data da OP
@author Pedro Henrique
@since 04/01/2019
@version 1.0
@type function
/*/
User Function FROPPYC2()

	Local aArea 	:= SB1->(GetArea())

	Local cAliasOP		:= GetNextAlias()
	Local _nPPRODUTO	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	Local _nPENTREG		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})
	Local _nPQTDVEN		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	Local _nPTPEST 		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})


	Local cQuery		:= ""
	Local nQuant		:= Round(aCols[N][_nPQTDVEN], 2)
	Local cProdCla2		:= aCols[N][_nPPRODUTO]
	Local cProdCla1		:= SubStr(cProdCla2, 1, 7) + "1"

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())

	cProdCla1 := PADR(cProdCla1, TAMSX3("C6_PRODUTO")[1])
	If (SB1->(DbSeek(XFilial("SB1")+cProdCla1)) .And. AllTrim(SB1->B1_YCLASSE) == "1")

		aCols[N][_nPENTREG]	:= U_FROPAD3U(dDataBase, 30)//caso não tenha OP
		aCols[N][_nPTPEST]	:= " "

		cQuery := "SELECT * FROM [FNC_ROP_PESQUISA_OP_EMP]('01', '', '', '', '', '"+cProdCla1+"', '', "+AllTrim(Str(nQuant))+", 'S', '', '', '')"
		TcQuery cQuery New Alias (cAliasOP)

		If !(cAliasOP)->(Eof())
			//traz ordenado pela data da disponibilidade
			aCols[N][_nPENTREG] := STOD((cAliasOP)->DATADISP)
		EndIf

		(cAliasOP)->(DbCloseArea())

	EndIf

	SB1->(RestArea(aArea))
Return


/*/{Protheus.doc} FROPCLFU
@description //Regras para clientes SA1->A1_YCAT == 'FUNC' e E=Estoque Imediato,
Atualizar adicionar a data de entrega 10 dias  
@author Pedro Henrique
@since 04/01/2019
@version 1.0
@type function
/*/

User Function FROPCLFU()

	Local aArea 	:= SA1->(GetArea())

	Local _nPTPEST 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})
	Local _nPENTREG	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENTREG"})

	Local cCodCli	:= M->C5_CLIENTE
	Local cLojaCli  := M->C5_LOJACLI

	If(aCols[N][_nPTPEST] == 'E') //E=Estoque Imediato;

		DbSelectArea('SA1')
		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())

		If SA1->(DbSeek(XFilial("SA1")+cCodCli+cLojaCli))
			If (AllTrim(SA1->A1_YCAT) == 'FUNC')
				aCols[N][_nPENTREG] := U_FROPAD3U(dDataBase, 10)
			Else
				aCols[N][_nPENTREG] := U_FROPAD3U(dDataBase)
			EndIf
		EndIf

		SA1->(DbCloseArea())
	EndIf

	SA1->(RestArea(aArea))
Return

