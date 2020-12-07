#INCLUDE "PROTHEUS.CH"   
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FCTVUT01
@description FUNCOES UTEIS PROJETO CONTRATO DE VERBA	
@author Fernando Rocha
@since 25/07/2016
@version undefined
@param _cContrato, , descricao
@param _nOpc, , descricao
@type function
/*/

//Calcular Creditos e Debitos do Contrato
//Alterado para considerar debitos e creditos do total da conta
User Function FCTVUT01(_cContrato, _nOpc)
	Local aArea := GetArea()
	Local aAreaZA7 := ZA7->(GetArea())
	Local cAliasTmp
	Local nValRet := 0
	Local cCtaPre := ""

	ZA7->(DbSetOrder(1))
	If ZA7->(DbSeek(XFilial("ZA7")+_cContrato))

		If (ZA7->ZA7_TIPO == '1')
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(XFilial("SA1")+ZA7->ZA7_CODCLI))
				cCtaPre := SA1->A1_YCTAPRE
			EndIf		
		Else
			ACY->(DbSetOrder(1))
			If ACY->(DbSeek(XFilial("ACY")+ZA7->ZA7_GRPCLI))	
				cCtaPre := ACY->ACY_YCTPRE
			EndIf	
		EndIf

		If ( _nOpc == 1 )

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp

			select VALOR = SUM(CT2_VALOR) 
			from %TABLE:CT2% CT2
			where
			CT2_FILIAL = %XFilial:CT2%
			and CT2_CREDIT = %EXP:cCtaPre%
			and CT2.D_E_L_E_T_=''

			EndSql

			If !(cAliasTmp)->(Eof())

				nValRet := (cAliasTmp)->VALOR 

			EndIf

			(cAliasTmp)->(DbCloseArea())

		ElseIf ( _nOpc == 2 )

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp

			select VALOR = SUM(CT2_VALOR) 
			from %TABLE:CT2% CT2
			where
			CT2_FILIAL = %XFilial:CT2%
			and CT2_DEBITO = %EXP:cCtaPre%
			and CT2.D_E_L_E_T_=''

			EndSql

			If !(cAliasTmp)->(Eof())

				nValRet := (cAliasTmp)->VALOR 

			EndIf

			(cAliasTmp)->(DbCloseArea())

		EndIf

	EndIf

	RestArea(aAreaZA7)
	RestArea(aArea)

Return(nValRet)

//Consulta Generica para Contratos de verba do cliente
User Function CTRVERF3()

	Local aArea   		:= GetArea()
	Local aAreaA1  		:= SA1->(GetArea())
	Local cTitulo		:= "Contratos de verba"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "ZA7"							//obrigatorio
	Local cCpoChave		:= "ZA7_CODIGO"		 					//obrigatorio
	Local cTitCampo		:= RetTitle(cCpoChave)				//obrigatorio
	Local cMascara		:= PesqPict(cAlias,cCpoChave)		//obrigatorio
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local cRetCpo		:= "uCRet1"							//obrigatorio
	Local nColuna		:= 1
	Local cCodigo		:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrão			

	//variaveis especificas
	Local cCodCli		:= ""
	Local cGrpVen		:= ""

	Private bRet 		:= .F. 	
	Public uCRet1		:= ""

	SA1->(DbSetOrder(1))

	If ( AllTrim(Upper(ReadVar())) == "M->C5_YCTRVER" )

		cCodCli := M->C5_CLIENTE+M->C5_LOJACLI

	ElseIf ( AllTrim(Upper(ReadVar())) == "M->D1_YCTRVER" )

		cCodCli := CA100FOR+CLOJA

	ElseIf ( AllTrim(Upper(FunName())) == "FINA070" )

		cCodCli := SE1->(E1_CLIENTE+E1_LOJA)

	EndIf

	If !Empty(cCodCli) .And. SA1->(DbSeek(XFilial("SA1")+cCodCli))
		cGrpVen := SA1->A1_GRPVEN
	EndIf 	 	

	//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
	//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
	cQuery := ""
	cQuery += " with tab_ctr as (																													  "+CRLF
	cQuery += " select                                                                                                                                "+CRLF
	cQuery += " ZA7_CODIGO,                                                                                                                           "+CRLF
	cQuery += " ZA7_DATA ,                                                                                                                            "+CRLF
	cQuery += " ZA8_DATINI,                                                                                                                           "+CRLF
	cQuery += " CONTA = case when ZA7_TIPO = '1' then (select top 1 A1_YCTAPRE from "+RetSqlName("SA1")+" where A1_COD+A1_LOJA = '"+cCodCli+"' and D_E_L_E_T_='' )   "+CRLF
	cQuery += " 		else (select top 1 ACY_YCTPRE from "+RetSqlName("ACY")+" where ACY_GRPVEN = '"+cGrpVen+"' and D_E_L_E_T_='' ) end                            "+CRLF
	cQuery += "                                                                                                                                       "+CRLF
	cQuery += " from "+RetSqlName("ZA7")+" ZA7 (nolock)                                                                                               "+CRLF
	cQuery += " join "+RetSqlName("ZA8")+" ZA8 (nolock) on ZA8_FILIAL = ZA7_FILIAL and ZA8_CODIGO = ZA7_CODIGO                                        "+CRLF
	cQuery += " where                                                                                                                                 "+CRLF
	cQuery += " ZA7_FILIAL = '"+XFilial("ZA7")+"'                                                                                                     "+CRLF
	cQuery += " and ZA7_STATUS = 'A'                                                                                                                  "+CRLF
	cQuery += " and ((ZA7_TIPO = '1' and ZA7_CODCLI+ZA7_LOJCLI = '"+cCodCli+"') or (ZA7_TIPO = '2' and ZA7_GRPCLI = '"+cGrpVen+"'))                   "+CRLF
	cQuery += " and ZA8_MSBLQL <> '1'                                                                                                                 "+CRLF
	cQuery += " and ZA8_DATINI <= '"+DTOS(dDataBase)+"'                                                                                               "+CRLF
	cQuery += " and ZA7.D_E_L_E_T_ = ''                                                                                                               "+CRLF
	cQuery += " and ZA8.D_E_L_E_T_ = ''                                                                                                               "+CRLF
	cQuery += " )                                                                                                                                     "+CRLF
	cQuery += " ,tab_calc as (                                                                                                                        "+CRLF
	cQuery += " select                                                                                                                                "+CRLF
	cQuery += " ZA7_CODIGO,                                                                                                                           "+CRLF
	cQuery += " ZA7_DATA,                                                                                                                             "+CRLF
	cQuery += " CONTA,                                                                                                                                "+CRLF
	cQuery += " CREDITOS = (select SUM(CT2_VALOR)                                                                                                     "+CRLF
	cQuery += " 			from "+RetSqlName("CT2")+" CT2 (nolock)                                                                                   "+CRLF
	cQuery += " 			where                                                                                                                     "+CRLF
	cQuery += " 			CT2_FILIAL = '"+XFilial("CT2")+"'                                                                                         "+CRLF
	cQuery += " 			and CT2_CREDIT = tab_ctr.CONTA                                                                                            "+CRLF
	cQuery += " 			and CT2_DATA >= ZA8_DATINI                                                                                                "+CRLF
	cQuery += " 			and CT2.D_E_L_E_T_=''),                                                                                                   "+CRLF
	cQuery += " DEBITOS =  (select SUM(CT2_VALOR)                                                                                                     "+CRLF
	cQuery += " 			from "+RetSqlName("CT2")+" CT2 (nolock)                                                                                   "+CRLF
	cQuery += " 			where                                                                                                                     "+CRLF
	cQuery += " 			CT2_FILIAL = '"+XFilial("CT2")+"'                                                                                         "+CRLF
	cQuery += " 			and CT2_DEBITO = tab_ctr.CONTA                                                                                            "+CRLF
	cQuery += " 			and CT2_DATA >= ZA8_DATINI                                                                                                "+CRLF
	cQuery += " 			and CT2.D_E_L_E_T_=''                                                                                                     "+CRLF
	cQuery += " 			)                                                                                                                         "+CRLF
	cQuery += " from tab_ctr                                                                                                                          "+CRLF
	cQuery += " )                                                                                                                                     "+CRLF
	cQuery += " select                                                                                                                                "+CRLF
	cQuery += " ZA7_CODIGO,                                                                                                                           "+CRLF
	cQuery += " ZA7_DATA                                                                                                                              "+CRLF
	cQuery += " from tab_calc                                                                                                                         "+CRLF
	cQuery += " where (CREDITOS - DEBITOS) > 0                                                                                                        "+CRLF


	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)

	RestArea(aAreaA1)
	RestArea(aArea)
Return .T.

//Checkar se Cliente tem contrato ativo
User Function FCTVCHEK()

	Local aArea   		:= GetArea()
	Local cQuery		:= "" 								//obrigatorio
	Local cCodCli		:= ""
	Local cGrpVen		:= ""
	Local lRet			:= .F.

	SA1->(DbSetOrder(1))

	If ( AllTrim(Upper(FunName())) == "MATA410" )

		cCodCli := M->C5_CLIENTE+M->C5_LOJACLI

		If SA1->(DbSeek(XFilial("SA1")+cCodCli))
			cGrpVen := SA1->A1_GRPVEN
		EndIf

	EndIf 	

	If !Empty(cCodCli) 	

		//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
		//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.

		//Fernando oem 13/01 - trocada a query abaixo para filtrar qualquer contrato com saldo - Solic. Claudeir - acompanhar  o funcionamento

		cQuery := " select " 
		cQuery += " ZA7_CODIGO, "
		cQuery += " ZA7_DATA "
		cQuery += " from "+RetSqlName("ZA7")+" ZA7 (nolock) "
		cQuery += " join "+RetSqlName("ZA8")+" ZA8 (nolock) on ZA8_FILIAL = ZA7_FILIAL and ZA8_CODIGO = ZA7_CODIGO "
		cQuery += " where "
		cQuery += " ZA7_FILIAL = '"+XFilial("ZA7")+"' "
		cQuery += " and ZA7_STATUS = 'A' "
		cQuery += " and ((ZA7_TIPO = '1' and ZA7_CODCLI+ZA7_LOJCLI = '"+cCodCli+"') or (ZA7_TIPO = '2' and ZA7_GRPCLI = '"+cGrpVen+"')) "
		cQuery += " and ZA8_MSBLQL <> '1' "
		cQuery += " and ZA8_DATINI <= '"+DTOS(dDataBase)+"' "
		cQuery += " and ZA7.D_E_L_E_T_ = '' "
		cQuery += " and ZA8.D_E_L_E_T_ = '' "

		cAliasQry := GetNextAlias()
		TCQUERY cQuery NEW ALIAS cAliasQry

		cAliasQry->(DbGoTop())

		While !cAliasQry->(Eof())

			//Avaliar se tem pelo menos 1 contrato com SALDO positivo para validar e obrigar a informar - Fernando em 13/01/17 - solicitacao do Claudeir
			__nSldCtr := U_FCTVUT01(cAliasQry->ZA7_CODIGO, 1) - U_FCTVUT01(cAliasQry->ZA7_CODIGO, 2) 

			If __nSldCtr > 0
				lRet := .T.
				exit			
			EndIf

			cAliasQry->(DbSkip())
		EndDo

		cAliasQry->(DbCloseArea())

	EndIf

	RestArea( aArea )
Return ( lRet )

//Checkar se a AI veio de um AO provisiona Sim - para validar o LP de bonificacao
User Function FCTCHKAO(_cAI)

	Local lRet := .F.
	Local cAliasTmp
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaZZ7 := ZZ7->(GetArea())
	Local cTabPZ5 := ""
	Local cTabPZ6 := ""

	//Buscando marca do produto para saber em qual empresa esta o acordo de objetivo
	//Produto tem que estar posicionado
	SB1->(DbSetOrder(1))
	ZZ7->(DbSetOrder(1))

	IF SB1->(DbSeek(XFilial("SB1")+SB1->B1_COD)) .And. ZZ7->(DbSeek(XFilial("ZZ7")+SB1->(B1_YLINHA+B1_YLINSEQ))) .And. !Empty(ZZ7->ZZ7_EMP)

		cTabPZ5 := "% PZ5"+SubStr(ZZ7->ZZ7_EMP,1,2)+"0 %"
		cTabPZ6 := "% PZ6"+SubStr(ZZ7->ZZ7_EMP,1,2)+"0 %"

	EndIf

	If !Empty(cTabPZ5)

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		%NOPARSER%

		select PZ6_CODIGO 
		from %Exp:cTabPZ5% PZ5
		join %Exp:cTabPZ6% PZ6 on PZ6_FILIAL = PZ5_FILIAL and PZ6_CODIGO = PZ5_CODIGO
		where PZ5_FILIAL = %XFilial:PZ5% 
		and PZ6_SI = %Exp:_cAI% 
		and PZ5_PROVER = 'S'
		and PZ5.D_E_L_E_T_=''
		and PZ6.D_E_L_E_T_=''

		EndSql

		(cAliasTmp)->(DbGoTop())
		If !(cAliasTmp)->(Eof())
			lRet := .T.
		EndIf
		(cAliasTmp)->(DbCloseArea())

	EndIf

	RestArea(aAreaZZ7)
	RestArea(aAreaSB1)
Return( lRet )

//Checkar se a AI veio de um AO provisiona Sim - para validar o LP de bonificacao
//Buscar dados a partir da origem da devolucao
User Function FCTCKNFE()
	Local lRet := .F.
	Local aAreaSB1 := SB1->(GetArea())
	Local cAliasTmp

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+SD1->D1_COD))

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NOPARSER%

	select
	top 1 C5_YNUMSI
	from %Table:SC5% SC5
	join %Table:SC6% SC6 on C6_FILIAL = C5_FILIAL and C6_NUM = C5_NUM
	join %Table:SD2% SD2 on D2_FILIAL = C6_FILIAL and D2_PEDIDO = C6_NUM and D2_ITEMPV = C6_ITEM

	where
	C5_FILIAL = %XFilial:SC5%
	and C5_CLIENTE = %Exp:SD1->D1_FORNECE%
	and C5_LOJACLI = %Exp:SD1->D1_LOJA%
	and C5_YITEMCT = 'I0201'
	and D2_DOC = %Exp:SD1->D1_NFORI%
	and D2_SERIE = %Exp:SD1->D1_SERIORI%
	and SC5.D_E_L_E_T_=''
	and SC6.D_E_L_E_T_=''
	and SD2.D_E_L_E_T_=''

	EndSql

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())

		lRet := U_FCTCHKAO((cAliasTmp)->C5_YNUMSI)

	EndIf
	(cAliasTmp)->(DbCloseArea())

	RestArea(aAreaSB1)
Return( lRet )

//Checkar data da NF de origem para ver se contabiliza contrato de devolucao
User Function FCTCNORI()
	Local lRet := .F.
	Local cAliasTmp

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NOPARSER%

	select
	top 1 D2_EMISSAO
	from SD2070
	where
	D2_FILIAL = %XFilial:SD2%
	and D2_DOC = %Exp:SD1->D1_NFORI%
	and D2_SERIE = %Exp:SD1->D1_SERIORI%
	and D2_CLIENTE = %Exp:SD1->D1_FORNECE%
	and D2_LOJA = %Exp:SD1->D1_LOJA%
	and D_E_L_E_T_=''

	EndSql

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())

		lRet := (cAliasTmp)->D2_EMISSAO >= '20160801'

	EndIf
	(cAliasTmp)->(DbCloseArea())

Return( lRet )