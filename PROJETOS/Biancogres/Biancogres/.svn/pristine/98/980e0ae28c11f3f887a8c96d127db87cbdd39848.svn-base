#INCLUDE "PROTHEUS.CH"   
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ FCTVLP01 ³ Autor ³ FERNANDO ROCHA        ³ Data ³22/07/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ LANCAMENTO PADRAO DE PROVISAO/PREVISAO DE VERBA DE CONTRATO³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ BIANCOGRES                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//NOTA FISCAL DE SAIDA - 610
User Function FCTVLP01(_nOpc)

	Local aArea := GetArea()
	Local uRetorno
	Local aCtr

	/*_nOpc
	Contratos de Verba
	11 = Percentual de bonus para credito de previsao
	12 = Codigo/Item do contrato de verba ativo do cliente/produto para Historico
	13 = Conta de Previsao do Cliente (posicionado) ou Grupo
	14 = Codigo/Item do contrato de verba selecionado conforme periodo para Debito de previsao
	15 = Classe de Valor do Contrato
	16 = Tipo de Valor do Contrato

	Acordo de Objetivo
	21 = Maior percentual de bonus do acordo de objetivo
	22 = Fator redutor do acorsdo de objetivo
	23 = Numero do acordo de objetivo ativo para o cliente
	24 = Conta de Provisao do Cliente/Grupo
	25 = Marca do Acordo Objetivo
	26 = Classe de Valor do Acordo de Objetivo
	*/

	//Dados do contrato para credito de previsao
	If ( _nOpc == 11 .Or. _nOpc == 12 .Or. _nOpc == 15 .Or. _nOpc == 16)

		aCtr := PesqCtrCli(SD2->D2_EMISSAO)

		//Percentual de bonus contrato de verba
		If ( _nOpc == 11 )
			uRetorno := aCtr[1]
		ElseIf ( _nOpc == 12 )
			uRetorno := aCtr[2]
		ElseIf ( _nOpc == 15 )
			uRetorno := aCtr[3]
		Else
			uRetorno := aCtr[4]
		EndIf

	EndIf

	//Conta de Previsao
	If ( _nOpc == 13 )
		uRetorno := PesqCtaPre()

		//Contrato/Item de contrato para debitos de previsao
	ElseIf ( _nOpc == 14 )
		uRetorno := PCtrBonus(SC5->C5_YCTRVER, SD2->D2_EMISSAO)

	EndIf


	//Acordo de objetivo
	If ( _nOpc == 21 .Or. _nOpc == 22 .Or. _nOpc == 23 .Or. _nOpc == 25 .Or. _nOpc == 26)


		//Buscar empresa origem
		__cEmpOri := AllTrim(CEMPANT)
		If ( __cEmpOri == "07" )

			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(XFilial("SC5")+SD2->D2_PEDIDO)) .And. !Empty(SC5->C5_YEMPPED)

				__cEmpOri := SC5->C5_YEMPPED

			EndIf

		EndIf

		aCtr := PesqAcObj(SD2->D2_EMISSAO, __cEmpOri)

		//Maior Percentual de bonus acordo
		If ( _nOpc == 21 )
			uRetorno := aCtr[1]

			//Fator Redutor do Acordo
		ElseIf ( _nOpc == 22 )
			uRetorno := aCtr[2]

			//Numero do acordo
		ElseIf ( _nOpc == 23 )
			uRetorno := aCtr[3]

			//Marca do acordo
		ElseIf ( _nOpc == 25 )
			uRetorno := aCtr[4]

			//Classe de Valor
		ElseIf ( _nOpc == 26 )
			uRetorno := aCtr[5]

		EndIf

	EndIf

	//Conta de Provisao
	If ( _nOpc == 24 )
		uRetorno := PesqCtaPro()
	EndIf

	RestArea(aArea)
Return(uRetorno)


//NOTA FISCAL DE ENTRADA (devolucao de venda) - 640
User Function FCTVLP02(_nOpc)
	Local aArea := GetArea()
	Local uRetorno
	Local aCtr

	/*_nOpc
	Contratos de Verba
	11 = Percentual de bonus para credito de previsao
	12 = Codigo/Item do contrato de verba ativo do cliente/produto para Historico
	13 = Conta de Previsao do Cliente (posicionado) ou Grupo
	14 = Codigo/Item do contrato de verba selecionado conforme periodo para Debito de previsao
	15 = Conta de Previsao do Cliente ou Grupo para documento de entrada
	16 = Classe de Valor do Contrato para documento de entrada
	17 = Codigo/Item do contrato de verba selecionado conforme periodo para Debito de previsao

	Acordo de Objetivo
	21 = Maior percentual de bonus do acordo de objetivo
	22 = Fator redutor do acorsdo de objetivo
	23 = Numero do acordo de objetivo ativo para o cliente
	24 = Conta de Provisao do Cliente/Grupo
	*/

	//Dados do contrato para credito de previsao
	If ( _nOpc == 11 .Or. _nOpc == 12)

		aCtr := PesqCtrCli(SD1->D1_DTDIGIT)

		//Percentual de bonus contrato de verba
		If ( _nOpc == 11 )
			uRetorno := aCtr[1]
		Else
			uRetorno := aCtr[2]
		EndIf

	EndIf

	//Conta de Previsao
	If ( _nOpc == 13 )
		uRetorno := PesqCtaPre()

		//Contrato/Item de contrato para debitos de previsao
	ElseIf ( _nOpc == 14 )
		uRetorno := PCtrBonus(SD1->D1_YCTRVER, SD1->D1_DTDIGIT)

	EndIf


	//Acordo de objetivo
	If ( _nOpc == 21 .Or. _nOpc == 22 .Or. _nOpc == 23)

		//Buscar empresa origem
		__cEmpOri := AllTrim(CEMPANT)
		If ( __cEmpOri == "07" .And. SD1->D1_TIPO == "D" )

			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(XFilial("SD2")+SD1->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA)))

				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(XFilial("SC5")+SD2->D2_PEDIDO)) .And. !Empty(SC5->C5_YEMPPED)

					__cEmpOri := SC5->C5_YEMPPED

				EndIf

			EndIf

		EndIf

		aCtr := PesqAcObj(SD1->D1_DTDIGIT, __cEmpOri)

		//Maior Percentual de bonus acordo
		If ( _nOpc == 21 )
			uRetorno := aCtr[1]

			//Fator Redutor do Acordo
		ElseIf ( _nOpc == 22 )
			uRetorno := aCtr[2]

			//Numero do acordo
		ElseIf ( _nOpc == 23 )
			uRetorno := aCtr[3]

			//Marca do acordo
		ElseIf ( _nOpc == 25 )
			uRetorno := aCtr[4]

			//Classe de Valor
		ElseIf ( _nOpc == 26 )
			uRetorno := aCtr[5]

		EndIf

	EndIf

	//Conta de Provisao
	If ( _nOpc == 24 )
		uRetorno := PesqCtaPro()
	EndIf

	//Conta de Previsao - Documento de entrada
	If ( _nOpc == 15 .or. _nOpc == 16 .or. _nOpc == 17)
		aCtr := fRetCtrPre(SD1->D1_YCTRVER)
		do case 
			case _nOpc == 15
			uRetorno := aCtr[1] //conta
			case _nOpc == 16	
			uRetorno := aCtr[2]
			case _nOpc == 17	
			uRetorno := aCtr[3]
		endcase
	endif

	RestArea(aArea)
Return(uRetorno)


//BAIXA DE CONTAS A RECEBER - LP 520
User Function FCTVLP03(_nOpc)

	Local aArea := GetArea()
	Local uRetorno := " " //Thiago Haagensen - Ticket 22674

	/*_nOpc
	Contratos de Verba
	11 = Conta de Previsao do Cliente (posicionado) ou Grupo
	12 = Codigo/Item do contrato de verba selecionado conforme periodo para Debito de previsao
	13 = Classe de Valor
	*/

	//Conta de Previsao
	If ( _nOpc == 11 )
		uRetorno := PesqCtaPre()

		//Contrato/Item de contrato para debitos de previsao
	ElseIf ( _nOpc == 12 )
		uRetorno := PCtrBonus(SE5->E5_YCTRVER, SE5->E5_DATA)
		//Classe de valor do contrato
	ElseIf ( _nOpc == 13 )

		ZA7->(DbSetOrder(1))
		If ZA7->(DbSeek(XFilial("ZA7")+SE5->E5_YCTRVER))
			uRetorno := ZA7->ZA7_CLVLD
		EndIf

	EndIf

	RestArea(aArea)
Return(uRetorno)



//PESQUISA CONTRATO COM CLIENTE E PRODUTO POSICIONADO
Static Function PesqCtrCli(dDtDig)
	Local cAliasTmp
	Local aRet := {0,"","",""}

	//Posicinar Linha do Produto
	ZZ7->(DbSetOrder(1))
	ZZ7->(DbSeek(XFilial("ZZ7")+ SB1->(B1_YLINHA+B1_YLINSEQ)))

	//buscando o contrato ativo
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NOPARSER%

		Select
		ZA8_FORMA,
		ZA8_PERC,
		CONTRATO = ZA8_CODIGO+ZA8_ITEM,
		ZA7_CLVLD,
		ZA7_TPVAL

		FROM %Table:ZA7% ZA7 (nolock)
		JOIN %Table:ZA8% ZA8 (nolock) on ZA8_FILIAL = ZA7_FILIAL and ZA8_CODIGO = ZA7_CODIGO

		WHERE 
		ZA7_FILIAL = '  '
		and ((ZA7_TIPO = '1' and ZA7_CODCLI = %EXP:SA1->A1_COD% and ZA7_LOJCLI = %EXP:SA1->A1_LOJA%) or (ZA7_TIPO = '2' and ZA7_GRPCLI = %EXP:SA1->A1_GRPVEN%))
		and ZA7_STATUS = 'A'
		and ZA8_FORMA = 'P' 
		and ZA8_MSBLQL <> '1'
		and ZA8_DATINI <= %EXP:DTOS(dDtDig)% and ZA8_DATFIM >= %EXP:DTOS(dDtDig)%
		and (ZA7_CLASSE = '' or ZA7_CLASSE = 'X' or ZA7_CLASSE = %EXP:SB1->B1_YCLASSE%)
		and (ZA7_PACOTE = '' or RTRIM(%EXP:SB1->B1_YPCGMR3%) = '' or ZA7_PACOTE like '%'+%EXP:SB1->B1_YPCGMR3%+'%')
		and (ZA7_MARCA = '' or ZA7_MARCA = %EXP:ZZ7->ZZ7_EMP% or (ZA7_MARCA = '05XX' and substring(%EXP:ZZ7->ZZ7_EMP%,1,2) = '05'))
		and ZA7.D_E_L_E_T_ = ' ' 
		and ZA8.D_E_L_E_T_ = ' '
		
		//Ticket 22282 - Pablo S. Nascimento: adicao de verificacao D_E_L_E_T_ = ' '

	EndSql

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())

		aRet := {}

		//percentual de bonus
		aAdd( aRet, (cAliasTmp)->ZA8_PERC )

		//codigo do contrato
		aAdd( aRet, (cAliasTmp)->CONTRATO )

		//classe de valor
		aAdd( aRet, (cAliasTmp)->ZA7_CLVLD )

		//tipo de valor
		aAdd( aRet, (cAliasTmp)->ZA7_TPVAL )

	EndIf

	(cAliasTmp)->(DbCloseArea())

Return(aRet)


//PESQUISA CONTA DE PREVISAO DO CLIENTE OU DO GRUPO
Static Function PesqCtaPre()
	Local cConta

	cConta := SA1->A1_YCTAPRE

	If !Empty(SA1->A1_GRPVEN)

		ACY->(DbSetOrder(1))
		If ACY->(DbSeek(XFilial("ACY")+SA1->A1_GRPVEN))

			If !Empty(ACY->ACY_YCTPRE)
				cConta := ACY->ACY_YCTPRE
			endif
		EndIf

	EndIf

Return(cConta) 


//PESQUISA CONTA DE PROVISAO DO CLIENTE OU DO GRUPO
Static Function PesqCtaPro()
	Local cConta

	cConta := SA1->A1_YCTAPRO

	If !Empty(SA1->A1_GRPVEN)

		ACY->(DbSetOrder(1))
		If ACY->(DbSeek(XFilial("ACY")+SA1->A1_GRPVEN))

			If !Empty(ACY->ACY_YCTPRO)
				cConta := ACY->ACY_YCTPRO
			endif
		EndIf

	EndIf

Return(cConta) 


//LANCAMENTOS DE DEBITOS - Pesquisar o item do contrato validao para a data 
Static Function PCtrBonus(_cContrato, dDtDig)

	Local aArea := GetArea()
	Local uRetorno
	Local cAliasTmp

	//buscando o contrato ativo
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NOPARSER%

		Select
		CONTRATO = ZA8_CODIGO+ZA8_ITEM

		FROM %Table:ZA7% ZA7 (nolock)
		JOIN %Table:ZA8% ZA8 (nolock) on ZA8_FILIAL = ZA7_FILIAL and ZA8_CODIGO = ZA7_CODIGO

		WHERE 
		ZA7_FILIAL = '  '
		and ZA7_CODIGO = %EXP:_cContrato%
		and ZA7_STATUS = 'A'
		and ZA8_MSBLQL <> '1'
		and ZA8_DATINI <= %EXP:DTOS(dDtDig)% and ZA8_DATFIM >= %EXP:DTOS(dDtDig)%

	EndSql

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())

		_cContrato := (cAliasTmp)->CONTRATO 

	EndIf
	(cAliasTmp)->(DbCloseArea())

	RestArea(aArea)
Return(_cContrato)


//PESQUISA ACORDO DE OBJETIVO COM CLIENTE E PRODUTO POSICIONADO
Static Function PesqAcObj(dDtDig, cEmpOri)

	Local aArea := GetArea()
	Local cAliasTmp
	Local cTabPZ5 := ""
	Local cTabPZ6 := ""
	Local aRet := {0, 0, "", "", ""}

	//Buscando marca do produto para saber em qual empresa esta o acordo de objetivo
	cTabPZ5 := "% PZ5"+cEmpOri+"0 %"
	cTabPZ6 := "% PZ6"+cEmpOri+"0 %"

	//Posicinar Linha do Produto
	ZZ7->(DbSetOrder(1))
	ZZ7->(DbSeek(XFilial("ZZ7")+ SB1->(B1_YLINHA+B1_YLINSEQ)))

	//buscando se tem acordo objetivo ativo
	If !Empty(cTabPZ5)

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NOPARSER%

			select

			ACORDO = PZ5_CODIGO,
			PBONUS = (SELECT MAX(PBONUS) FROM (VALUES (PZ6_PBONF1),(PZ6_PBONF2),(PZ6_PBONF3),(PZ6_PBONF4),(PZ6_PBONF5)) AS a(PBONUS)),
			PZ5_FREDVB,
			PZ5_MARCA,
			PZ5_CLFABR,
			PZ5_CLDIST

			from %Exp:cTabPZ5% PZ5
			join %Exp:cTabPZ6% PZ6 (nolock) on PZ6_FILIAL = PZ5_FILIAL and PZ6_CODIGO = PZ5_CODIGO

			where
			PZ5_FILIAL = '  '

			and (  (PZ5_TIPCLI = '1' and PZ5_CODCLI = %EXP:SA1->A1_COD% and PZ5_LOJCLI = %EXP:SA1->A1_LOJA%) 
			or (PZ5_TIPCLI = '2' and PZ5_CODGRP = %EXP:SA1->A1_GRPVEN%) )

			and PZ5_STATUS = 'S'
			and PZ6_PERINI <= %EXP:DTOS(dDtDig)% and PZ6_PERFIM >= %EXP:DTOS(dDtDig)%
			and (PZ5_TIPFIL = '' or PZ5_TIPFIL = '2' or %EXP:SB1->B1_YCLASSE% = '1')
			and (PZ5_PACOTE = '' or RTRIM(%EXP:SB1->B1_YPCGMR3%) = '' or PZ5_PACOTE like '%'+%EXP:SB1->B1_YPCGMR3%+'%') 
			and (PZ5_MARCA = '' or PZ5_MARCA = %EXP:ZZ7->ZZ7_EMP% or (PZ5_MARCA = '05XX' and substring(%EXP:ZZ7->ZZ7_EMP%,1,2) = '05'))
			and PZ5.PZ5_PROVER = 'S'
			and PZ5.D_E_L_E_T_=''
			and PZ6.D_E_L_E_T_=''

		EndSql

		(cAliasTmp)->(DbGoTop())
		If !(cAliasTmp)->(Eof())

			aRet := {}

			//maior percentual de bonus
			aAdd(aRet , (cAliasTmp)->PBONUS)

			//fator de reducao do acordo
			aAdd(aRet , (cAliasTmp)->PZ5_FREDVB)

			//Numero do acordo
			aAdd(aRet , (cAliasTmp)->ACORDO)

			//Marca do acordo
			aAdd(aRet , (cAliasTmp)->PZ5_MARCA)

			//Classe de Valor
			If AllTrim(cEmpAnt) == "07"
				aAdd(aRet , (cAliasTmp)->PZ5_CLDIST)
			Else
				aAdd(aRet , (cAliasTmp)->PZ5_CLFABR)
			EndIf

		EndIf

		(cAliasTmp)->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return(aRet)


//PESQUISA CONTA DE PREVISAO DO CLIENTE OU DO GRUPO INFORMADO NO CONTRADO DO DOCUMENTO DE ENTRADA
Static Function fRetCtrPre(cContrato)
	Local cConta := ''
	Local aRet   := {'','',''}

	dbselectarea('ZA7')
	ZA7->(dbsetorder(1))

	if ZA7->(DbSeek(XFilial("ZA7")+cContrato))
		if ZA7->ZA7_STATUS = 'A'
			if ZA7->ZA7_TIPO == '1'
				dbselectarea('SA1')
				SA1->(dbsetorder(1))
				if SA1->(dbseek(xfilial('SA1')+PADR(alltrim(ZA7->ZA7_CODCLI),TamSX3("A1_COD")[1])+PADR(alltrim(ZA7->ZA7_LOJCLI),TamSX3("A1_LOJA")[1])))
					cConta := SA1->A1_YCTAPRE
				endif
			else
				dbselectarea('ACY')
				ACY->(dbsetorder(1))
				if ACY->(dbseek( xfilial('ACY')+PADR(alltrim(ZA7->ZA7_GRPCLI),TamSX3("ACY_GRPVEN")[1]) ))
					if !Empty(ACY->ACY_YCTPRE)
						cConta := ACY->ACY_YCTPRE
					endif	
				endif
			endif	

			aRet[1] := cConta
			aRet[2] := ZA7->ZA7_CLVLD
			aRet[3] := ZA7->ZA7_CODIGO
		endif	
	endif

Return(aRet) 