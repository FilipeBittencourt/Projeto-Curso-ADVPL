#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "fwcommand.ch"


/*/{Protheus.doc} TBiaEmpenhoPedido
@description Geracao de Empenho de pedido de venda SC9
@author Fernando Rocha
@since 03/09/2018
@version 1.0
@type class
/*/
Class TBiaEmpenhoPedido From LongClassName

//parametros da classe
Data lCredito
Data lEstoque
Data lAvalCred

//dados do pedido a ser liberados
Data Pedido
Data Item
Data Quantidade
Data Lote
Data Localiz

Data QtdALib2
Data LibOk
Data cErro
Data QtdLib
Data TpBlq
Data DescBlq

//dados para regras de empenho automatico
Data cCliLjOri		//cliente+loja de origem
Data cProduto		//produto
Data cSegmento		//segmento do cliente
Data cCategoria		//categoria do cliente
Data lLoteRestr		//Se Lote é Restrito (*)
Data lOkRestr		//se aceita receber lote restrito
Data lFocoEng		//se o produto é foco (Engenharia)

Data cRegraNAtend	//Regra de nao atendimento
Data cRegraNEmp		//Regra de nao empenho automatico

Method New() Constructor
Method Liberar()
Method GetDescBlq()
Method ChkAtendimento()	//Metodo para checkar se pode atender o pedido com o lote
Method ChkEmpAuto()  	//Metodo para checkar se a situacao é ou não para gerar empenho automatico conforme regras  
Method GetInfoEmp()
Method LibPedido()		//MEtodo para checkar e fazer o empenho de todos itens de um pedido

EndClass


Method New() Class TBiaEmpenhoPedido

	::lCredito 	:= .T.
	::lEstoque 	:= .T.
	::lAvalCred	:= .T.

	::Pedido		:= Space(TamSX3("C6_NUM")[1])
	::Item			:= Space(TamSX3("C6_ITEM")[1])
	::Quantidade	:= 0
	::Lote			:= ""

	::QtdALib2		:= 0
	::LibOk			:= .F.
	::cErro			:= .T.
	::QtdLib		:= 0	
	::TpBlq			:= "00"	
	::DescBlq		:= ""

	::cCliLjOri		:= ""
	::cProduto		:= ""
	::cSegmento		:= ""
	::cCategoria	:= ""
	::lLoteRestr	:= .F.
	::lOkRestr		:= .T.
	::lFocoEng		:= .F.
	::cRegraNEmp	:= ""
	::cRegraNAtend	:= ""

Return


Method Liberar() Class TBiaEmpenhoPedido

	Local cAliasTmp
	Local cPedido	:= ::Pedido
	Local lCredito 	:= ::lCredito
	Local lEstoque	:= ::lEstoque

	::LibOk := .T.

	BEGIN TRANSACTION

		SC6->(DbSetOrder(1))
		If !SC6->(DbSeek(XFilial("SC6")+::Pedido+::Item))

			::LibOk 	:= .F.
			::cErro := "Pedido não encontrado."

		Else

			If !Empty(::Lote)
				RecLock("SC6",.F.)
				SC6->C6_LOTECTL := ::Lote
				SC6->C6_LOCALIZ := ::Localiz
				SC6->(MsUnlock())
			EndIf

		EndIf

		If (::LibOk)

			::QtdALib2  := ConvUM(SC6->C6_PRODUTO, ::Quantidade, 0, 2)	

			::QtdLib	:= MaLibDoFat(SC6->(RecNo()),::Quantidade,@lCredito,@lEstoque,::lAvalCred,.T.,.F.,.F.,NIL,NIL,NIL,NIL,NIL,NIL,::QtdALib2)

		EndIf

		If ( ::QtdLib <> ::Quantidade .Or. !lEstoque )

			::LibOk 	:= .F.
			::cErro := "Erro na liberação de estoque, verificar estoque e empenhos."
			DisarmTransaction()

		ElseIf ( !lCredito )

			If Type("nTpBlq") <> "U"

				::TpBlq	:= nTpBlq

			Else

				::TpBlq	:= "99"

			EndIf		

			If ( ::TpBlq <> "00" )

				::LibOk := .F.

			EndIf

			::cErro := ::GetDescBlq()
			DisarmTransaction()

		Else

			//Verificar se pedido foi liberado na totalidade e marcar flag no SC5
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NoParser%

				select SALDOPED = sum(C6_QTDVEN) -
				isnull((select SUM(C9_QTDLIB) from %Table:SC9% SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and SC9.D_E_L_E_T_=''),0)
				from %Table:SC6% (nolock) 
				where C6_FILIAL = %XFilial:SC6% 
				and C6_NUM = %Exp:cPedido% 
				AND C6_BLQ <> 'R'
				group by C6_FILIAL, C6_NUM

			EndSql

			SC5->(DbSetOrder(1))
			If !(cAliasTmp)->(Eof()) .And. SC5->(DbSeek(XFilial("SC5")+cPedido)) .And. (cAliasTmp)->SALDOPED <= 0

				RecLock("SC5",.F.)
				SC5->C5_LIBEROK := "S"
				SC5->(MsUnlock())

			EndIf

			::LibOk := .T.
			::cErro := ""		

		EndIf

	END TRANSACTION

Return


Method GetDescBlq() Class TBiaEmpenhoPedido

	Do Case

		Case ::TpBlq == "00";	::DescBlq := "LIBERADO"
		Case ::TpBlq == "02";	::DescBlq := "SALDO DE RA INSUFICIENTE"
		Case ::TpBlq == "03";	::DescBlq := "CLIENTE ESTÁ COM RISCO 'E'"
		Case ::TpBlq == "04";	::DescBlq := "CLIENTE ESTÁ COM LIMITE DE CRÉDITO VENCIDO!"
		Case ::TpBlq == "05";	::DescBlq := "CLIENTE ESTÁ COM TITULOS EM ATRASO"

		Case ::TpBlq == "061";	::DescBlq := "CONTRATO - ALTERAÇÃO NA DATA DE ENTREGA"
		Case ::TpBlq == "062";	::DescBlq := "CONTRATO - ALTERAÇÃO NO VALOR"
		Case ::TpBlq == "063";	::DescBlq := "CONTRATO - LIBERADO ANTES DA DATA DE NECESSIDADE"
		Case ::TpBlq == "064";	::DescBlq := "CONTRATO - TITULO DE CONTRATO EM ABERTO E ATRASO"		
		Case ::TpBlq == "065";	::DescBlq := "LIBERADO NA EMPRESA ORIGEM"

		Case ::TpBlq == "07";	::DescBlq := "AGUARDANDO LIBERAÇÃO DO SETOR DE CRÉDITO E COBRANÇA"

		OtherWise;				::DescBlq := "BLOQUEIO DE CRÉDITO"

	endcase

Return(::DescBlq)


Method ChkAtendimento() Class TBiaEmpenhoPedido

	Local lRet := .T.

	::GetInfoEmp()
	::cRegraNAtend := ""

	If ( ::cSegmento == "E" .And. ::lLoteRestr )

		lRet := .F.
		::cRegraNAtend := "ENGENHARIA/LOTE RESTRITO"

	ElseIf ( ::lLoteRestr .And. !::lOkRestr )

		lRet := .F.
		::cRegraNAtend := "CLIENTE NÃO ACEITA LOTE RESTRITO"

	ElseIf ( AllTrim(::cCategoria) == "LOJA ESPEC" .And. ::lLoteRestr )

		lRet := .F.
		::cRegraNAtend := "LOJA ESPECIALIZADA NÃO ACEITA LOTE RESTRITO"

	EndIf

Return(lRet)


Method ChkEmpAuto() Class TBiaEmpenhoPedido

	Local lRet := .T.
	Local lAtend := ::ChkAtendimento()

	::cRegraNEmp := ""

	If (!lAtend)

		lRet := .F.
		::cRegraNEmp := ::cRegraNAtend

	ElseIf ( ::cSegmento == "E" .And. !::lFocoEng )

		lRet := .F.
		::cRegraNEmp := "ENGENHARIA/PRODUTO NÃO É FOCO"

	EndIf

Return(lRet)


Method GetInfoEmp() Class TBiaEmpenhoPedido

	Local aAreaA1 	:= SA1->(GetArea())
	Local aAreaB1 	:= SB1->(GetArea())
	Local aAreaZZ9 	:= ZZ9->(GetArea())

	SA1->(DbSetOrder(1))
	If !Empty(::cCliLjOri) .And. SA1->(DbSeek(XFilial("SA1")+::cCliLjOri))

		::cSegmento 	:= SA1->A1_YTPSEG

		If SA1->(FieldPos("A1_YLOTRES")) > 0
			::lOkRestr		:= ( SA1->A1_YLOTRES <> "N" )
		Else 
			::lOkRestr		:= .T.
		EndIf

		::cCategoria	:= SA1->A1_YCAT

	EndIf

	SB1->(DbSetOrder(1))
	If !Empty(::cProduto) .And. SB1->(DbSeek(XFilial("SB1")+::cProduto))

		If SB1->(FieldPos("B1_YFOCO")) > 0
			::lFocoEng		:= SB1->B1_YFOCO == "E"
		Else
			::lFocoEng		:= .F.
		EndIf

	EndIf

	ZZ9->(DbSetOrder(1))
	If !Empty(::Lote) .And. ZZ9->(DbSeek(XFilial("ZZ9")+::Lote+::cProduto))

		::lLoteRestr	:= ZZ9->ZZ9_RESTRI == "*"

	EndIf

	RestArea(aAreaZZ9)
	RestArea(aAreaA1)
	RestArea(aAreaB1)

Return


Method LibPedido(cNumPed) Class TBiaEmpenhoPedido

	Local _lSucesso	:= .T.
	Local _cErro	:= ""

	::lCredito	:= .T.
	::lEstoque	:= .T.
	::lAvalCred	:= .T.

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(XFilial("SC5")+cNumPed))	

	If ( SC5->C5_YCONF <> "S" )
		Return({.T., ""})
	EndIf

	::cCliLjOri		:= IIF(!Empty(SC5->C5_YCLIORI), SC5->C5_YCLIORI+SC5->C5_YLOJORI, SC5->C5_CLIENTE+SC5->C5_LOJACLI) 
	::Pedido		:= cNumPed 

	Begin Transaction

		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(XFilial("SC6")+cNumPed))

			SA1->(DbSetOrder(1))
			SA1->(DbSeek(XFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

			While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+cNumPed) 

				SC0->(DbSetOrder(8))
				If SC0->(DbSeek(XFilial("SC0")+SC6->C6_NUM+SC6->C6_ITEM)) .And. SC0->C0_YTEMP <> "S" .And. SC6->C6_YTPEST == "E"

					SB1->(DbSetOrder(1))
					SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO))

					::cProduto 		:= SC6->C6_PRODUTO				
					::Item			:= SC6->C6_ITEM
					::Quantidade	:= SC6->C6_QTDVEN
					::Lote			:= SC0->C0_LOTECTL  //lote que esta reservado
					::Localiz		:= SC0->C0_LOCALIZ

					//verificando se é para gerar empenho automatico do pedido ao invés de Reserva de Estoque
					
					ConOut("TBiaEmpenhoPedido => thread: "+AllTrim(Str(ThreadId()))+", PEDIDO: "+cNumPed+", Data: "+DTOC(dDataBase)+" Hora: "+Time()+" - LibPedido - Check Regras Emp Auto.")
					
					If ( ::ChkEmpAuto() )

						//Excluir reserva
						ConOut("TBiaEmpenhoPedido => thread: "+AllTrim(Str(ThreadId()))+", PEDIDO: "+cNumPed+", Data: "+DTOC(dDataBase)+" Hora: "+Time()+" - LibPedido - Excluindo Reserva.")
						U_FRRT02EX(SC6->C6_NUM, SC6->C6_ITEM,Nil,"EAT",,,.F.)

						//Empenhar pedido
						ConOut("TBiaEmpenhoPedido => thread: "+AllTrim(Str(ThreadId()))+", PEDIDO: "+cNumPed+", Data: "+DTOC(dDataBase)+" Hora: "+Time()+" - LibPedido - Liberando Pedido.")
						::Liberar()

						If ( !::LibOk )

							_lSucesso 	:= .F.
							_cErro		+= "ITEM "+SC6->C6_ITEM+": "+ ::cErro + CRLF
							DisarmTransaction()  //se der erro de liberacao em algum item voltar a transacao do pedido inteiro
							Exit

						Else

							_lSucesso	:= .T.
							_cErro		+= ""

							RecLock("SC6",.F.)
							SC6->C6_YTPEST := "P"
							SC6->(MsUnlock())

						EndIf

					Else

						_lSucesso 	:= .F.
						_cErro		+= "ITEM "+SC6->C6_ITEM+": "+ ::cRegraNEmp + CRLF

					EndIf

				EndIf

				SC6->(DbSkip())
			EndDo

		EndIf

	End Transaction

Return({_lSucesso, _cErro})