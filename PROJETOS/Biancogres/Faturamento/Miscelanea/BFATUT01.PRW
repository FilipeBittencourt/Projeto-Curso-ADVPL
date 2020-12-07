#include "protheus.ch"
#include "topconn.ch"
              
/*/{Protheus.doc} BF1PCTCX
@description Funcoes uteis projetos comercial bianco RODAPE
@author Fernando Rocha
@since 09.06.16 
@version undefined
@param _cRodape, , descricao
@param _nQtdDig, , descricao
@type function
/*/

//funcao para converter qtde em PC para qtde em Caixas fechadas de piso base
User Function BF1PCTCX(_cRodape, _nQtdDig)

	Local aAreaB1 := SB1->(GetArea())
	Local nConvCx := 0
	Local nConvPC := 0 
	Local nQtMinPc := 0
	Local nMod := 0
	Local nQtdAlt := 0

	//posiciona tabela de conversao Rodape X Base
	ZA6->(DbSetOrder(2))
	If ZA6->(DbSeek(XFilial("ZA6")+_cRodape))  

		nConvPC := ZA6->ZA6_CONV

		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(XFilial("SB1")+ZA6->ZA6_BASE))

			nConvCx := SB1->B1_CONV  

			nQtMinPc := NoRound( nConvCx * nConvPC , 0)  //Nao pode vender qtde de peca quebrada

			nMod := ( _nQtdDig % nQtMinPc )

			nQtdAlt :=  ( int( _nQtdDig / nQtMinPc ) * nQtMinPc ) + IIf( nMod > 0, nQtMinPc, 0 )

		EndIf

	EndIf            

	RestArea(aAreaB1)

Return( { nQtdAlt, nQtMinPc } )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Verificar se existe pedido de Chao (Piso) e gravar na linha do pedido
//Chamado apos digitacao da quantidade no BIA068
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                
User Function BF1VPCHA(_cRodape, _nQtdDigM2)

	Local lOk	 := .F.
	Local oFont1 := TFont():New("Verdana",,022,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)
	Local oFont3 := TFont():New("Verdana",,016,,.T.,,,,,.F.,.F.)
	Local oFont4 := TFont():New("Verdana",,016,,.T.,,,,,.F.,.F.)
	Local oGroup1
	Local oSay1
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay7
	Local oSay8

	Private oSayCLot
	Private oGetPedLM
	Private cGetPedLM
	Private oGetPedOri
	Private cGetPedOri
	Private oSayDProd
	Private oSayDtEnt
	Private oSayLote
	Private oSayMsg
	Private oSayMsg2
	Private oSayQPed
	Private oDlgPPis
	Private oButConfirma
	Private oButNao
	Private oButSim
	Private aDadosSel := Nil

	Private nQtdDigM2 := _nQtdDigM2
	Private aPedPiso := {}

	//inicia variaveis
	cGetPedOri	:= Space(6)
	cGetPedLM	:= Space(6)

	//posiciona tabela de conversao Rodape X Base
	ZA6->(DbSetOrder(2))
	If ZA6->(DbSeek(XFilial("ZA6")+_cRodape))

		DEFINE MSDIALOG oDlgPPis TITLE "Pedido de Piso" FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL

		@ 006, 004 SAY oSay1 PROMPT "Deseja vincular a Pedido de Piso para este cliente?" SIZE 176, 026 OF oDlgPPis FONT oFont1 COLORS 16711680, 16777215 PIXEL
		@ 030, 074 BUTTON oButSim PROMPT "SIM" SIZE 051, 017 OF oDlgPPis FONT oFont1 PIXEL ACTION  ( PesqPedPiso() )
		@ 030, 127 BUTTON oButNao PROMPT "NÃO EXISTE" SIZE 069, 017 OF oDlgPPis FONT oFont1 PIXEL ACTION ( oDlgPPis:End() )

		@ 054, 003 GROUP oGroup1 TO 111, 195 PROMPT "Dados do Pedido" OF oDlgPPis COLOR 0, 16777215 PIXEL
		@ 054+010, 005 SAY oSay8 PROMPT "Pedido No.Orig.:" SIZE 075, 009 OF oGroup1 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 054+009, 071 MSGET oGetPedOri VAR cGetPedOri SIZE 040, 010 OF oGroup1 COLORS 0, 16777215 FONT oFont2 PIXEL VALID ( TrocaPed(1) ) F3 "BPISF3"
		@ 054+010, 119 SAY oSay3 PROMPT "No.LM:" SIZE 045, 007 OF oGroup1 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 054+009, 146 MSGET oGetPedLM VAR cGetPedLM SIZE 040, 010 OF oGroup1 COLORS 0, 16777215 FONT oFont2 PIXEL VALID ( TrocaPed(2) ) F3 "BPISF3"

		@ 054+025, 005 SAY oSay4 PROMPT "Produto:" SIZE 035, 007 OF oGroup1 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 054+035, 005 SAY oSay5 PROMPT "Qtde (m2):" SIZE 045, 007 OF oGroup1 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 054+035, 073 SAY oSayCLot PROMPT "Lote:" SIZE 023, 007 OF oGroup1 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 054+035, 112 SAY oSay7 PROMPT "Dt.Entrega:" SIZE 041, 007 OF oGroup1 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 054+025, 040 SAY oSayDProd PROMPT "" SIZE 057, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
		@ 054+035, 044 SAY oSayQPed PROMPT "" SIZE 028, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
		@ 054+035, 091 SAY oSayLote PROMPT "" SIZE 023, 008 OF oGroup1 COLORS 0, 16777215 PIXEL
		@ 054+035, 152 SAY oSayDtEnt PROMPT "" SIZE 036, 008 OF oGroup1 COLORS 0, 16777215 PIXEL

		@ 111, 004 SAY oSayMsg PROMPT "" SIZE 192, 007 OF oDlgPPis FONT oFont4 COLORS 255, 16777215 PIXEL
		@ 111, 004 SAY oSayMsg2 PROMPT "" SIZE 192, 007 OF oDlgPPis FONT oFont4 COLORS 255, 16777215 PIXEL

		@ 129, 126 BUTTON oButConfirma PROMPT "CONFIRMAR" SIZE 069, 017 OF oDlgPPis FONT oFont1 PIXEL ACTION ( IIf( lOk := ConfLote(aDadosSel), oDlgPPis:End(), ) )

		oGetPedLM:bWhen := {||.F.}
		oGetPedOri:bWhen := {||.F.}

		ACTIVATE MSDIALOG oDlgPPis CENTERED  

	EndIf

	If (!lOk)
		aDadosSel := Nil
	EndIf

Return( aDadosSel )

//Buscar o pedido de PISO para associar
Static Function PesqPedPiso()

	Local cAliasTmp
	Local _aAux

	Local _cPZ0Origem := "% PZ0" + AllTrim(CEMPANT) + "0 %"
	Local _cSC0Origem := "% SC0" + AllTrim(CEMPANT) + "0 %"
	Local _cSC9Origem := "% SC9" + AllTrim(CEMPANT) + "0 %"
	Local _cSC5Origem := "% SC5" + AllTrim(CEMPANT) + "0 %"
	Local _cSC6Origem := "% SC6" + AllTrim(CEMPANT) + "0 %"

	SB1->(DbSetOrder(1))
	IF SB1->(DbSeek(XFilial("SB1")+ZA6->ZA6_BASE)) .And. !Empty(SB1->B1_YEMPEST)

		_cPZ0Origem := "% PZ0" + SubStr(SB1->B1_YEMPEST,1,2) + "0 %"
		_cSC0Origem := "% SC0" + SubStr(SB1->B1_YEMPEST,1,2) + "0 %"
		_cSC9Origem := "% SC9" + SubStr(SB1->B1_YEMPEST,1,2) + "0 %"
		_cSC5Origem := "% SC5" + SubStr(SB1->B1_YEMPEST,1,2) + "0 %"
		_cSC6Origem := "% SC6" + SubStr(SB1->B1_YEMPEST,1,2) + "0 %"

	EndIf

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NoParser%

	select
	EMPORI = C5_YEMPPED,
	PEDORI = C5_YPEDORI,
	PEDLM = C5_NUM,
	C6_ITEM,
	C6_PRODUTO,
	B1_DESC,
	C6_QTDVEN,
	C0_QUANT = isnull(C0_QUANT,0),
	C0_LOTECTL = isnull(C0_LOTECTL,''),
	PZ0_QUANT = isnull(PZ0_QUANT,0),
	OPDOC = isnull(PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ,''),
	C6_ENTREG,
	C6_LOCAL,
	C9_QTDLIB = isnull(C9_QTDLIB,0),
	C9_LOTECTL = isnull(C9_LOTECTL,'')

	FROM SC5070 SC5
	JOIN SC6070 SC6 ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM
	JOIN SB1010 SB1 ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO  
	JOIN ZZ7010 ZZ7 ON B1_YLINHA = ZZ7_COD AND B1_YLINSEQ = ZZ7_LINSEQ
	left join %Exp:_cSC0Origem% SC0 (nolock) on C0_FILIAL = '01' and C5_YPEDORI = C0_YPEDIDO and C6_ITEM = C0_YITEMPV and C6_PRODUTO = C0_PRODUTO and SC0.D_E_L_E_T_ = ''
	left join %Exp:_cPZ0Origem% PZ0 (nolock) on PZ0_FILIAL = '01' and C5_YPEDORI = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO and PZ0.D_E_L_E_T_ = ''
	left join %Exp:_cSC9Origem% SC9 (nolock) on C9_FILIAL = C6_FILIAL and C9_PEDIDO = C5_YPEDORI and C9_ITEM = C6_ITEM and C9_PRODUTO = C6_PRODUTO and SC9.D_E_L_E_T_= ''

	WHERE
	C5_FILIAL = '01'
	AND C5_CLIENTE = %EXP:M->C5_CLIENTE%
	AND C5_LOJACLI = %EXP:M->C5_LOJACLI%
	AND C6_PRODUTO = %EXP:ZA6->ZA6_BASE%
	AND C6_BLQ <> 'R'
	AND B1_TIPO = 'PA'
	AND ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9070 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0
	AND SC5.D_E_L_E_T_ = ''
	AND SC6.D_E_L_E_T_ = ''
	AND SB1.D_E_L_E_T_ = ''
	AND ZZ7.D_E_L_E_T_ = ''

	union all

	select
	EMPORI = '01',
	PEDORI = C5_NUM,
	PEDLM = SPACE(6),
	C6_ITEM,
	C6_PRODUTO,
	B1_DESC,
	C6_QTDVEN,
	C0_QUANT = isnull(C0_QUANT,0),
	C0_LOTECTL = isnull(C0_LOTECTL,''),
	PZ0_QUANT = isnull(PZ0_QUANT,0),
	OPDOC = isnull(PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ,''),
	C6_ENTREG,
	C6_LOCAL,
	C9_QTDLIB = isnull(C9_QTDLIB,0),
	C9_LOTECTL = isnull(C9_LOTECTL,'')

	FROM %Exp:_cSC5Origem% SC5
	JOIN %Exp:_cSC6Origem% SC6 ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM
	JOIN SB1010 SB1 ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO  
	JOIN ZZ7010 ZZ7 ON B1_YLINHA = ZZ7_COD AND B1_YLINSEQ = ZZ7_LINSEQ
	left join %Exp:_cSC0Origem% SC0 (nolock) on C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV and C6_PRODUTO = C0_PRODUTO and SC0.D_E_L_E_T_ = ''
	left join %Exp:_cPZ0Origem% PZ0 (nolock) on PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO and PZ0.D_E_L_E_T_ = ''
	left join %Exp:_cSC9Origem% SC9 (nolock) on C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_= ''

	WHERE
	C5_FILIAL = '01'
	AND C5_CLIENTE = %EXP:M->C5_CLIENTE%
	AND C5_LOJACLI = %EXP:M->C5_LOJACLI%
	AND C6_PRODUTO = %EXP:ZA6->ZA6_BASE%
	AND C6_BLQ <> 'R'
	AND B1_TIPO = 'PA'
	AND ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9010 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0
	AND SC5.D_E_L_E_T_ = ''
	AND SC6.D_E_L_E_T_ = ''
	AND SB1.D_E_L_E_T_ = ''
	AND ZZ7.D_E_L_E_T_ = ''

	order by EMPORI, PEDORI

	EndSql

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		If ( (cAliasTmp)->C0_QUANT > 0 .Or. (cAliasTmp)->PZ0_QUANT > 0 .Or. (cAliasTmp)->C9_QTDLIB > 0 )  //reserva de estoque /op ou empenho

			_aAux := {}
			/*1*/AAdd(_aAux, (cAliasTmp)->PEDORI )
			/*2*/AAdd(_aAux, (cAliasTmp)->PEDLM )
			/*3*/AAdd(_aAux, (cAliasTmp)->B1_DESC )
			/*4*/AAdd(_aAux, (cAliasTmp)->C6_QTDVEN )
			/*5*/AAdd(_aAux, (cAliasTmp)->C6_ENTREG )
			/*6*/AAdd(_aAux, (cAliasTmp)->C0_QUANT )
			/*7*/AAdd(_aAux, IIF(!Empty((cAliasTmp)->C9_LOTECTL), (cAliasTmp)->C9_LOTECTL, (cAliasTmp)->C0_LOTECTL ) )
			/*8*/AAdd(_aAux, (cAliasTmp)->PZ0_QUANT )
			/*9*/AAdd(_aAux, (cAliasTmp)->EMPORI )
			/*10*/AAdd(_aAux, (cAliasTmp)->C6_LOCAL )
			/*11*/AAdd(_aAux, (cAliasTmp)->C6_ITEM )
			/*12*/AAdd(_aAux, Space(10)/*lote selecionado*/ )
			/*13*/AAdd(_aAux, 9 /*tipo selecao*/ )
			/*14*/AAdd(_aAux, "N" /*autoriza*/ )
			/*15*/AAdd(_aAux, "N" /*tipo de reserva*/ )
			/*16*/AAdd(_aAux, (cAliasTmp)->OPDOC )
			/*17*/AAdd(_aAux, (cAliasTmp)->C9_QTDLIB )
			/*18*/AAdd(_aAux, (cAliasTmp)->C9_LOTECTL )

			AAdd(aPedPiso, _aAux)

		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo

	If Len(aPedPiso) > 0

		If Len(aPedPiso) > 1
			oGetPedLM:bWhen := {||.T.}
			oGetPedOri:bWhen := {||.T.}
		EndIf

		SelPed(aPedPiso[1])

	EndIf

Return   

//Trocar o pedido de piso manualmente
Static Function TrocaPed(nCampo)
	Local nPos := 0
	Local lRet := .T.

	If ( nCampo == 1 )
		nPos := aScan( aPedPiso, {|x|  x[1] == cGetPedOri} )
	Else
		nPos := aScan( aPedPiso, {|x|  x[2] == cGetPedLM} )
	EndIf

	If ( nPos > 0 )
		SelPed(aPedPiso[nPos])

	Else
		MsgAlert("Pedido de PISO não existe.","Associar pedido de PISO")
		lRet := .F.		
	EndIf

Return( lRet )

//Slecionar o pedido e verificar regras de estoque
Static Function SelPed(aDados)
	Local aPesq

	//pedido piso tem reserva de estoque
	if ( aDados[6] > 0 )

		aPesq := PesqSaldo(aDados)
		If ( aPesq[1] )

			aDados[13] := aPesq[3]

			If ( aPesq[3] == 1 )
				aDados[12] := aDados[7]
				LoadPed(aDados, "Estoque disponível no mesmo LOTE.") 
			ElseIf ( aPesq[3] == 2 ) 
				aDados[12] := aPesq[2]
				LoadPed(aDados, "Estoque disponível no LOTE: "+aPesq[2]+".") 
			Else
				aDados[12] := aPesq[2]
				LoadPed(aDados, "Estoque disponível em LOTE DIFERENTE.")
			EndIf

			aDados[15] := "E"  //reserva de estoque

			aDadosSel := aDados
			oButConfirma:SetFocus()

		Else

			//pesquisa de OP?

			aDadosSel := Nil
			LoadPed(aDados, "Não tem Estoque disponível.")
		EndIf

		//pedido piso tem empenho
	elseif ( aDados[17] > 0 )

		aPesq := PesqSaldo(aDados)
		If ( aPesq[1] )

			aDados[13] := aPesq[3]

			If ( aPesq[3] == 1 )
				aDados[12] := aDados[7]
				LoadPed(aDados, "Estoque disponível no mesmo LOTE.") 
			ElseIf ( aPesq[3] == 2 ) 
				aDados[12] := aPesq[2]
				LoadPed(aDados, "Estoque disponível no LOTE: "+aPesq[2]+".") 
			Else
				aDados[12] := aPesq[2]
				LoadPed(aDados, "Estoque disponível em LOTE DIFERENTE.")
			EndIf

			aDados[15] := "P"  //estoque empenhado

			aDadosSel := aDados
			oButConfirma:SetFocus()

		Else

			//pesquisa de OP?

			aDadosSel := Nil
			LoadPed(aDados, "Não tem Estoque disponível.")
		EndIf

		//pedido piso tem reserva de OP
	elseif ( aDados[8] > 0 )

		aPesq := PesqOP(aDados)
		If ( aPesq[1] )

			LoadPed(aDados, "Saldo disponível na mesma OP.", .T.)
			aDados[15] := "R"  //reserva de OP

			aDadosSel := aDados
			oButConfirma:SetFocus()

		Else
			aDadosSel := Nil
			LoadPed(aDados, "Não tem Saldo disponível na OP.", .T.)
		EndIf

	endif 

Return

//Carregar dados do pedido selecionado na tela
Static Function LoadPed(aDados, cMensagem, lOp)

	Default lOp := .F.

	cGetPedOri := aDados[1] 
	cGetPedLM := aDados[2] 
	oSayDProd:cCaption := aDados[3]
	oSayQPed:cCaption := Transform(aDados[4], "@E 9,9999.99")


	If (!lOp)
		oSayCLot:cCaption := "Lote:"
		oSayLote:cCaption := aDados[7]
	Else
		oSayCLot:cCaption := "OP:"
		oSayLote:cCaption := SubStr(aDados[16],1,6)
	Endif	

	oSayDtEnt:cCaption := DTOC(STOD(aDados[5]))

	oSayMsg:cCaption := cMensagem

	oGetPedLM:Refresh()
	oGetPedOri:Refresh()
	oDlgPPis:Refresh()

Return

//Pesquisar saldo para reservar o pedido base 
Static Function PesqSaldo(aDados)

	Local _nSaldo := 0
	Local _cLote  := aDados[7]
	Local _nTipo	:= 9
	Local _cLoteSel := ""
	Local _cAliasSaldo 
	Local _cSB8Origem

	_cSB8Origem := "% SB8" + aDados[9] + "0 %"

	//PESQUISAR SE EXISTE SALDO NO MESMO LOTE
	_cAliasSaldo := GetNextAlias()
	BeginSql Alias _cAliasSaldo

	select LOTE = B8_LOTECTL, SALDO = sum(B8_SALDO - B8_EMPENHO)
	from %EXP:_cSB8Origem% SB8
	where
	B8_FILIAL = %XFilial:SB8%
	and B8_PRODUTO = %Exp:ZA6->ZA6_BASE%
	and B8_LOCAL = %Exp:aDados[10]%
	and B8_LOTECTL = %Exp:_cLote%
	and SB8.D_E_L_E_T_=''
	group by B8_LOTECTL
	having sum(B8_SALDO - B8_EMPENHO) >= %Exp:nQtdDigM2%

	EndSql

	(_cAliasSaldo)->(DbGoTop())
	If !(_cAliasSaldo)->(Eof())
		_nTipo := 1
		_cLoteSel := _cLote
	EndIf
	(_cAliasSaldo)->(DbCloseArea())

	If Empty(_cLoteSel)

		//PESQUISAR SE EXISTE SALDO EM LOTE PROXIMO - MESMO CALIBRE - TONALIDADE DIFERENTE
		_cAliasSaldo := GetNextAlias()
		BeginSql Alias _cAliasSaldo

		select TOP 1 LOTE = B8_LOTECTL, SALDO = sum(B8_SALDO - B8_EMPENHO)
		from %EXP:_cSB8Origem% SB8
		where
		B8_FILIAL = %XFilial:SB8%
		and B8_PRODUTO = %Exp:ZA6->ZA6_BASE%
		and B8_LOCAL = %Exp:aDados[10]%
		and B8_LOTECTL <> %Exp:_cLote%
		and substring(B8_LOTECTL,3,2) = substring(%Exp:_cLote%,3,2) 
		and SB8.D_E_L_E_T_=''
		group by B8_LOTECTL
		having sum(B8_SALDO - B8_EMPENHO) >= %Exp:nQtdDigM2%
		order by sum(B8_SALDO - B8_EMPENHO)

		EndSql

		(_cAliasSaldo)->(DbGoTop())
		If !(_cAliasSaldo)->(Eof())
			_nTipo := 2
			_cLoteSel := (_cAliasSaldo)->LOTE
		EndIf
		(_cAliasSaldo)->(DbCloseArea())

	EndIf

	If Empty(_cLoteSel)

		//PESQUISAR QUALQUER OUTRO LOTR - SOLICITAR AUTORIZACAO DO VENDEDOR
		_cAliasSaldo := GetNextAlias()
		BeginSql Alias _cAliasSaldo

		select TOP 1 LOTE = B8_LOTECTL, SALDO = sum(B8_SALDO - B8_EMPENHO)
		from %EXP:_cSB8Origem% SB8
		where
		B8_FILIAL = %XFilial:SB8%
		and B8_PRODUTO = %Exp:ZA6->ZA6_BASE%
		and B8_LOCAL = %Exp:aDados[10]%
		and B8_LOTECTL <> %Exp:_cLote%
		and SB8.D_E_L_E_T_=''
		group by B8_LOTECTL
		having sum(B8_SALDO - B8_EMPENHO) >= %Exp:nQtdDigM2%
		order by sum(B8_SALDO - B8_EMPENHO)

		EndSql

		(_cAliasSaldo)->(DbGoTop())
		If !(_cAliasSaldo)->(Eof())
			_nTipo := 3
			_cLoteSel := (_cAliasSaldo)->LOTE
		EndIf
		(_cAliasSaldo)->(DbCloseArea())

	EndIf

	If !Empty(_cLoteSel)
		Return({.T., _cLoteSel, _nTipo})
	EndIf

Return({.F., "", _nTipo})

//Pesquisar se a OP tem saldo suficiente para o pedido de rodape 
Static Function PesqOP(aDados)
	Local _cAliasSaldo 
	Local _cPZ0Origem
	Local _cSC2Origem
	Local _nTipo := 9

	_cPZ0Origem := "% PZ0" + aDados[9] + "0 %"
	_cSC2Origem := "% SC2" + aDados[9] + "0 %"

	_cAliasSaldo := GetNextAlias()
	BeginSql Alias _cAliasSaldo

	SELECT 
	OPDOC = C2_NUM+C2_ITEM+C2_SEQUEN, 
	SALDO = ROUND((((C2_QUANT * ZZ6_INDCOM)/100) - C2_YQTRTFC) - C2_QUJE,2)
	- ISNULL((SELECT SUM(PZ0_QUANT)
	FROM %EXP:_cPZ0Origem% (nolock)
	WHERE PZ0_FILIAL = C2_FILIAL AND PZ0_OPNUM = C2_NUM AND PZ0_OPITEM = C2_ITEM AND PZ0_OPSEQ = C2_SEQUEN 
	AND D_E_L_E_T_=' '),0)

	FROM %EXP:_cSC2Origem% SC2 (nolock)
	JOIN SB1010 SB1 (nolock) ON B1_FILIAL = '  ' AND B1_COD = C2_PRODUTO 
	JOIN ZZ6010 ZZ6 (nolock) ON ZZ6_FILIAL = '  ' AND ZZ6_COD = B1_YFORMAT	
	WHERE C2_FILIAL = '01'
	AND C2_SEQPAI = ''
	AND C2_DATRF = ''
	AND B1_YCLASSE = '1'
	AND C2_NUM+C2_ITEM+C2_SEQUEN = %EXP:aDados[16]%
	AND SC2.D_E_L_E_T_=' '
	AND SB1.D_E_L_E_T_ = ' '
	AND ZZ6.D_E_L_E_T_=' '

	EndSql

	(_cAliasSaldo)->(DbGoTop())
	If !(_cAliasSaldo)->(Eof()) .And. ( (_cAliasSaldo)->SALDO >= nQtdDigM2 )
		_nTipo := 1
		(_cAliasSaldo)->(DbCloseArea())
	EndIf

	If ( _nTipo == 1 )
		Return({.T., aDados[16], _nTipo})
	EndIf

Return({.F., "", _nTipo})

//Botao Confirmar - regras de validacao 
Static Function ConfLote(aDados)
	Local lRet := .T.
	Local nAut

	If (aDados == Nil)	
		MsgAlert("Nehum pedido de PISO encontrado/selecionado.","Associar pedido de PISO")
		lRet := .F.
	EndIf

	If lRet .And. (aDados[13] == 9)
		lRet := .F.
	EndIf

	//Autorizacao de lote diferente
	If lRet .And. (aDados[13] == 3)

		nAut := U_FROPMSG(	"VENDA DE RODAPÉ",;
		"Não existe estoque em lote igual ou próximo ao pedido de PISO. Deseja autorizar o envio do rodapé em LOTE DIFERENTE?";
		+CRLF+"Será enviado o lote: "+aDados[12], {"Não","Sim"}, 2, "Autorização de Lote Diferente.")

		If ( nAut == 2 )
			aDados[14] := "S"
		Else
			lRet := .F.
		EndIf

	EndIf

Return( lRet )

User Function BPISF3()

	Local aArea   		:= GetArea()
	Local cTitulo		:= "Pedidos de Piso"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SC5"							//obrigatorio
	Local cCpoChave		:= "C5_NUM"		 					//obrigatorio
	Local cTitCampo		:= RetTitle(cCpoChave)				//obrigatorio
	Local cMascara		:= PesqPict(cAlias,cCpoChave)		//obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "uCRet1"							//obrigatorio
	Local nColuna		:= 1
	Local cCodigo		:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrão			
	Local I
	Local cPedIn		:= ""
	Local cPedIn01		:= ""
	Local cPedIn05		:= ""

	Private bRet 		:= .F. 	
	Public uCRet1		:= ""

	If ( Len(aPedPiso) <= 0 )
		MsgAlert("Não foi encontrador pedidos de PISO para este CLIENTE/PRODUTO.","Associar pedido de PISO")
		RestArea( aArea )
		Return .T.
	EndIf

	For I := 1 To Len(aPedPiso)

		cPedIn += Iif(!Empty(cPedIn),",","")

		If ( AllTrim(Upper(ReadVar())) == "CGETPEDLM" )
			cPedIn += "'"+aPedPiso[I][2]+"'"
		Else
			//cPedIn += "'"+aPedPiso[I][9]+aPedPiso[I][1]+"'"

			If (aPedPiso[I][9] == "05") 
				cPedIn05 += Iif(!Empty(cPedIn05),",","")
				cPedIn05 += "'"+aPedPiso[I][1]+"'"
			Else
				cPedIn01 += Iif(!Empty(cPedIn01),",","")
				cPedIn01 += "'"+aPedPiso[I][1]+"'"
			EndIf

		EndIf

	Next I

	//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
	//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
	If ( AllTrim(Upper(ReadVar())) == "CGETPEDLM" )

		cQuery := " SELECT DISTINCT C5_NUM "
		cQuery += " FROM SC5070 AS SC5 WITH (NOLOCK) "
		cQuery += " WHERE C5_FILIAL  = '" + xFilial("SC5") + "' "
		cQuery += " AND C5_NUM IN ("+cPedIn+") "
		cQuery += " AND SC5.D_E_L_E_T_= ' ' "
		cQuery += " ORDER BY C5_NUM "

	Else

		If !Empty(cPedIn01)

			cQuery := " SELECT DISTINCT C5_NUM " 
			cQuery += " FROM SC5010 AS SC5 WITH (NOLOCK) " 
			cQuery += " WHERE C5_FILIAL  = '01' " 
			cQuery += " AND C5_NUM IN ("+cPedIn01+") " 
			cQuery += " AND SC5.D_E_L_E_T_= ' ' " 

		EndIf

		If !Empty(cPedIn01) .And. !Empty(cPedIn05) 
			cQuery += " UNION ALL "
		EndIf

		If !Empty(cPedIn05)

			cQuery += " SELECT DISTINCT C5_NUM " 
			cQuery += " FROM SC5050 AS SC5 WITH (NOLOCK) " 
			cQuery += " WHERE C5_FILIAL  = '01' " 
			cQuery += " AND C5_NUM IN ("+cPedIn05+") " 
			cQuery += " AND SC5.D_E_L_E_T_= ' ' "

		EndIf

		If !Empty(cPedIn01) .Or. !Empty(cPedIn05) 
			cQuery += " ORDER BY C5_NUM "
		EndIf

	EndIf

	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)

	If ( AllTrim(Upper(ReadVar())) == "CGETPEDLM" )
		cGetPedLM := uCRet1 
		oGetPedLM:Refresh()
	Else
		cGetPedOri := uCRet1 
		oGetPedOri:Refresh()
	EndIf 

	RestArea( aArea )
Return .T.


//Consulta informacoes sobre os vinculos do Pedido Rodape
User Function BF1CKROD()

	Local cAliasTmp
	Local cEmpOri
	Local cSC6Ori
	Local cSC0Ori

	Local oDlgGrid
	Local oWBrowse1
	Local aWBrowse1 := {}

	cEmpOri := IIf(!Empty(SC5->C5_YEORIBS),SC5->C5_YEORIBS,"01") 

	cSC6Ori := "% SC6"+SubString(cEmpOri,1,2)+"0 %"
	cSC0Ori := "% SC0"+SubString(cEmpOri,1,2)+"0 %"

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NoParser%

	select

	RODAPE = SC6.C6_PRODUTO,
	PECAS = SC6.C6_QTDVEN,
	PED_BASE = SC5.C5_YPEDBAS,
	PRO_BASE = C6ORI.C6_PRODUTO,
	QTD_BASE = C6ORI.C6_QTDVEN,
	RES_QTD = C0ORI.C0_QUANT,
	RES_LOTE = C0ORI.C0_LOTECTL,
	PISO_PED = C6CHA.C6_NUM,
	PISO_QTD = C6CHA.C6_QTDVEN,
	PISO_RES_LOTE = C0CHA.C0_LOTECTL


	from SC5140 SC5
	join SC6140 SC6 on SC6.C6_FILIAL = C5_FILIAL and C6_NUM = C5_NUM
	left join %Exp:cSC6Ori% C6ORI on C6ORI.C6_FILIAL = SC6.C6_FILIAL and C6ORI.C6_NUM = SC5.C5_YPEDBAS and C6ORI.C6_ITEM = SC6.C6_ITEM and C6ORI.D_E_L_E_T_ =''
	left join %Exp:cSC0Ori% C0ORI on C0ORI.C0_FILIAL = C6ORI.C6_FILIAL and C0ORI.C0_YPEDIDO = C6ORI.C6_NUM and C0ORI.C0_YITEMPV = C6ORI.C6_ITEM and C0ORI.C0_YTEMP <> 'S' and C0ORI.D_E_L_E_T_=''
	left join %Exp:cSC6Ori% C6CHA on C6CHA.C6_FILIAL = SC6.C6_FILIAL and C6CHA.C6_NUM = substring(SC6.C6_YPITCHA,1,6) and C6CHA.C6_ITEM = substring(SC6.C6_YPITCHA,7,2) and C6CHA.D_E_L_E_T_=''
	left join %Exp:cSC0Ori% C0CHA on C0CHA.C0_FILIAL = C6CHA.C6_FILIAL and C0CHA.C0_YPEDIDO = C6CHA.C6_NUM and C0CHA.C0_YITEMPV = C6CHA.C6_ITEM and C0CHA.C0_YTEMP <> 'S' and C0CHA.D_E_L_E_T_=''

	where
	SC5.C5_FILIAL = %XFILIAL:SC5%
	and SC5.C5_NUM = %Exp:SC5->C5_NUM%
	and SC5.D_E_L_E_T_=''
	and SC6.D_E_L_E_T_=''

	EndSql

	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(Eof())

		DEFINE MSDIALOG oDlgGrid TITLE "Consulta Processo Rodape" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

		While !(cAliasTmp)->(Eof())

			Aadd(aWBrowse1,{;
			(cAliasTmp)->RODAPE,;
			(cAliasTmp)->PECAS,;
			(cAliasTmp)->PED_BASE,;
			(cAliasTmp)->PRO_BASE,;
			(cAliasTmp)->QTD_BASE,;
			(cAliasTmp)->RES_LOTE,;
			(cAliasTmp)->PISO_PED,;
			(cAliasTmp)->PISO_QTD,;
			(cAliasTmp)->PISO_RES_LOTE})

			(cAliasTmp)->(DbSkip())
		EndDo

		@ 000, 000 LISTBOX oWBrowse1 Fields HEADER "Rodapé","Peças","Ped.Base","Pro.Base ","Qtd.Base","Lote Base","Ped.Piso","Qtd.Piso","Lote Piso" SIZE 300, 150 OF oDlgGrid PIXEL ColSizes 50,50
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {;
		aWBrowse1[oWBrowse1:nAt,1],;
		aWBrowse1[oWBrowse1:nAt,2],;
		aWBrowse1[oWBrowse1:nAt,3],;
		aWBrowse1[oWBrowse1:nAt,4],;
		aWBrowse1[oWBrowse1:nAt,5],;
		aWBrowse1[oWBrowse1:nAt,6],;
		aWBrowse1[oWBrowse1:nAt,7],;
		aWBrowse1[oWBrowse1:nAt,8],;
		aWBrowse1[oWBrowse1:nAt,9];
		}}

		// Don't change the Align Order 
		oWBrowse1:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlgGrid CENTERED   

	EndIf

Return

//Checkar se Produto eh um RODAPE - para algumas validacoes de reserva da Vitcer
User Function CHKRODA(_cProduto)
	Local lRet := .F.

	ZA6->(DbSetOrder(2))
	If ZA6->(DbSeek(XFilial("ZA6")+_cProduto)) //Pesquisa do rodape na tabela de conversao
		lRet := .T.
	EndIf

Return(lRet)



