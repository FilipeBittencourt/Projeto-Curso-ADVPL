#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BPOLVLXX	ºAutor  ³Fernando Rocha      º Data ³ 18/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacoes para projeto Politica Comercial.		          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//Validar alteracao do campo C6_PRCVEN
User Function BPOLVL01()

	Local aAreaB1 := SB1->(GetArea())
	Local lRet := .F.
	//Parametro para filtrar empresas que nao usam o sistema comercial/reserva
	Local _cEmpNRes := GetNewPar("FA_EMNRES","")
	//Produto
	Local _cProd 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]

	//Empresas - Vitcer nao usa
	If !lRet .And. CEMPANT $ AllTrim(_cEmpNRes)
		lRet := .T.
	EndIf

	//Tratamento outros tipos de pedido
	If !lRet .And. M->C5_TIPO <> "N"
		lRet := .T.
	EndIf

	//Tratamento para linha Mundialli
	If !lRet .And. M->C5_YLINHA == "4"
		lRet := .T.
	EndIf

	//Tratamento outro produtos
	SB1->(DbSetOrder(1))
	If !lRet .And. SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. SB1->B1_TIPO <> "PA"
		lRet := .T.
	EndIf

	//Tratamento especial para Replcacao de pedido LM
	If !lRet .And. AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")
		lRet := .T.
	EndIf

	If !lRet .And. ( M->C5_CLIENTE == "010064" .And. M->C5_CONDPAG == "142" )

		__DataLib := GetNewPar("FA_DALTPPD",STOD("20151231"))

		if !(Date() > __DataLib)  //provisorio liberar alteracao de produtos - solicitacao do Claudeir em 25/11
			U_FROPMSG("Pedidos de Contrato - LM", 	"Alteração de PRECO DE VENDA - PEDIDOS DE CONTRATO LM no modo atendente."+CRLF+"Permitida somente até "+DTOC(__DataLib)+" para manutenção especial.",,2,"Tratamento Especial.")
			lRet := .T.
		Endif

	EndIf

	If !lRet
		MsgAlert("NÃO é possível alterar o Preço de venda."+CRLF+"Altere o campo Desconto Especial","Nova Política Comercial (BPOLVLXX)")
	EndIf

	RestArea(aAreaB1)
Return(lRet)

#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BPOLVL02	ºAutor  ³Fernando Rocha      º Data ³ 12/08/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacoes se o item do pedido tem desconto de Lote        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//Validar alteracao do campo C6_PRCVEN
User Function BPOLVL02(_cPedido, _cItem)

	Local lRet := .F.
	Local aAreaZA4 := ZA4->(GetArea())
	Local aAreaZA0 := ZA0->(GetArea())

	ZA4->(DbSetOrder(1))
	If ZA4->(DbSeek(XFilial("ZA4")+_cPedido+_cItem+"DNV "))

		ZA0->(DbSetOrder(2))
		If ZA0->(DbSeek(XFilial("ZA0")+ZA4->ZA4_CODREG)) .And. !Empty(ZA0->ZA0_LOTE)

			lRet := .T.

		EndIf

	EndIf

	RestArea(aAreaZA4)
	RestArea(aAreaZA0)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BPOLVLC6	ºAutor  ³Fernando Rocha      º Data ³ 12/08/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao no campo C6_LOTECTL						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BPOLVLC6()

	Local lRet as Logical

	if (!stackTools():IsInStackCall({"ProcPedido","ProcessaDevolucao"}))
		lRet := BPOLVLC6()
	Else
		lRet := .T.
	EndIf

Return(lRet)

Static Function BPOLVLC6()

	Local lRet := .T.
	Local cTES
	Local cAliasTmp
	Local aArea := GetArea()

	if (!stackTools():IsInStackCall({"ProcPedido","ProcessaDevolucao"}))

		If Alltrim(funname())=="MATA440"

			If U_BPOLVL02(M->C5_NUM, Gdfieldget("C6_ITEM",n))
				MSGALERT("ATENÇÃO! Este pedido tem desconto de LOTE"+Chr(10)+Chr(13)+"Não é permitida a troca.","Valida Politica de Lote")
				lRet := .F.
			EndIf

			//Vitcer nao permmitir alterar lote se liberando pedido de rodape que a base ja foi faturada
			If lRet .And. AllTrim(CEMPANT) == "14" .And. !Empty(SC5->C5_YPEDBAS)

				__cTabC5Bas := "% SC5"+SubStr(SC5->C5_YEORIBS,1,2)+"0 %"

				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
			select C5_NOTA from %Exp:__cTabC5Bas% where C5_FILIAL = %Exp:SubStr(SC5->C5_YEORIBS,3,2)% and C5_NUM = %Exp:SC5->C5_YPEDBAS% and %NotDel%
				EndSql

				If !(cAliasTmp)->(Eof()) .And. !Empty((cAliasTmp)->C5_NOTA)
					MsgStop("Pedido BASE do Rodapé já foi faturado pela empresa origem."+CRLF+"Alteração de LOTE no pedido rodapé não permitida!","BPOLVLC6")
					lContinua := .T. //lContinua := .F. - Fernando em 25/01/17 - solicitado por Camila - Vitcer vai fechar
				EndIf

				(cAliasTmp)->(DbCloseArea())

			EndIf

			If lRet

				__cLoteBas 	:= Gdfieldget("C6_YLOTBAS",n)
				__cRAut		:= Gdfieldget("C6_YRAVLOT",n)
				__cPedIt	:= Gdfieldget("C6_YPITCHA",n)


				If ( !Empty(__cLoteBas) .And. __cRAut == "N" )

					If !MSGNOYES(	"ATENÇÃO! Este pedido esta vinculado ao PEDIDO PISO: "+__cPedIt+" com o lote: "+__cLoteBas+"."+CRLF+;
							"O Representante não autorizou envio com lote diferente."+CRLF+CRLF+;
							"TEM CERTEZA QUE DESEJA ALTERAR O LOTE?","Valida Lote de Rodapé")

						lRet := .F.
					EndIf

				EndIf

			EndIf

			If lRet

				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
			select top 1 C6_YLOTBAS from SC6140 where C6_FILIAL = '01' and C6_YPITCHA = %Exp:SC5->C5_NUM+Gdfieldget("C6_ITEM",n)% and C6_YLOTBAS <> '' and C6_YRAVLOT <> 'S'
				EndSql

				If !(cAliasTmp)->(Eof()) .And. !Empty((cAliasTmp)->C6_YLOTBAS)

					If !MSGNOYES("Este Pedido está vinculado ao pedido de Rodapé (VITCER) com o lote '"+(cAliasTmp)->C6_YLOTBAS+"'."+CRLF+;
							"O representante não autorizou envio em lote diferente."+CRLF+;
							"TEM CERTEZA QUE DESEJA ALTERAR O LOTE?","Valida Lote de Rodapé")

						lRet := .F.

					EndIf

				EndIf
				(cAliasTmp)->(DbCloseArea())

			EndIf

		EndIf

		If Alltrim(funname())=="MATA410"

			cTES := Gdfieldget("C6_TES",n)
			SF4->(dbSetOrder(1))

			If SF4->(dbSeek(xFilial("SF4")+cTES)) .And. SF4->F4_ESTOQUE == "S"

				MSGALERT("ATENÇÃO! Favor escolher o LOTE pela consulta F6.","Valida Politica de Lote")
				lRet := .F.

			EndIf

		EndIf

		RestArea(aArea)
	EndIf
	
Return(lRet)
