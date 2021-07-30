#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TIT_MSG "REPLICAÇÃO DE PEDIDO LM"

/*/{Protheus.doc} FCOMRT01
@description Replicacao de Pedido da LM para Outras Empresas
@author Fernando Rocha
@since 08/07/2014
@version undefined
@param cPedido, characters, descricao
@param lAuto, logical, descricao
@param lJob, logical, descricao
@param lMatriz, logical, descricao
@type function
/*/
User Function FCOMRT01(cPedido, lAuto, lJob, lMatriz)

	Local aArea
	Local aRet
	Local aRetMatriz
	Local cTxtPedErro := ""
	Local cTxtErro := ""
	Local cEmpDest := ""
	Local cEmpOri
	Local cFilOri
	Local bProcessa
	Local bProcMatriz
	Local _cRepAtu
	Local _cUserName
	Local cAliasAux
	Local lRepORI 	:= .T.
	Local lRepLMMat := .T.
	Local cPedOri	:= ""
	Local cPedMatriz := ""
	Local _cRetEmpAut := ""

	Local lOk := .T.
	Local cErro := ""

	Default cPedido := ""
	Default lAuto := .T.
	Default lJob := .T.
	Default lMatriz := .F.

	aArea := GetArea()

	If !Empty(cPedido)

		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(XFilial("SC5")+cPedido))

			If lJob
				_cRepAtu := SC5->C5_VEND1
				_cUserName := SC5->C5_YDIGP
			Else
				_cRepAtu := cRepAtu
				_cUserName := CUSERNAME
			EndIf

			lRepORI := Empty(SC5->C5_YPEDORI) //Pedido origem p/LM filial ja replicado
			lRepLMMat := lRepORI

			If ALLTRIM(FUNNAME()) == 'MATA410' .And. SC5->C5_FILIAL <> "01"
				lMatriz := .T.
			EndIf

			If lMatriz .And. !lRepORI

				//se for pedido de filial LM - verificar se foi replicado o pedido na LM Matriz
				cAliasAux := GetNextAlias()
				BeginSql Alias cAliasAux
					%NOPARSER%

					select 1 from SC5070 where C5_FILIAL = '01' and C5_YPEDORI = %Exp:SC5->C5_YPEDORI% and C5_YEMPPED = %Exp:SC5->C5_YEMPPED% and D_E_L_E_T_=''

				EndSql
				If (cAliasAux)->(Eof())
					lRepLMMat := .T.  // nao replicou o pedido para a LM Matriz
				EndIf

			EndIf

			If lRepORI .Or. (lMatriz .And. lRepLMMat)

				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+cPedido))

					If !Empty(SC6->C6_YEMPPED)

						cEmpDest := SC6->C6_YEMPPED+"01"

					Else

						SB1->(DbSetOrder(1))
						IF SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO))

							cEmpDest := SB1->B1_YEMPEST

						ENDIF

					EndIf
				EndIf

				If !Empty(cEmpDest)

					IF lRepORI
						//Execucao via JOB em outra empresa do EXECAUTO da replicacao do pedido LM
						bProcessa := {|| aRet := U_FROPCPRO(SubStr(cEmpDest,1,2),SubStr(cEmpDest,3,2),"U_FCOMXPED", cPedido, cEmpDest, _cRepAtu, _cUserName, cFilAnt)  }

						If !lJob
							U_BIAMsgRun("Aguarde... Replicando pedido para EMPRESA: "+cEmpDest,,bProcessa)
						Else
							eval(bProcessa)
						EndIf

						lOk := aRet[1]
						cErro := aRet[2]
						cPedOri := aRet[3]

						If Len(aRet) >= 4
							_cRetEmpAut :=  aRet[4]
						EndIf

					ENDIF

					//Fernando em 12/04/2017 -> SE for pedido de Filial LM, se replicou com sucesso para origem replica para LM matriz
					If lMatriz .And. ( (lRepORI .And. lOk) .OR. lRepLMMat )

						If !(lRepORI .And. lOk)
							cPedOri := SC5->C5_YPEDORI
						EndIf

						bProcMatriz := {|| aRetMatriz := U_FROPCPRO("07","01","U_FCOMXPED", cPedido, cEmpDest, _cRepAtu, _cUserName, cFilAnt, lMatriz, cPedOri)  }

						If !lJob
							U_BIAMsgRun("Aguarde... Replicando pedido para a LM MATRIZ",,bProcMatriz)
						Else
							eval(bProcMatriz)
						EndIf

						lOk := lOk .And. aRetMatriz[1]
						cErro := cErro + aRetMatriz[2]
						cPedMatriz := aRetMatriz[3]

					EndIf

					If !lJob
						If !lOk

							U_FROPMSG(TIT_MSG, 	"Informe ao setor Comercial/TI erro com a cópia do pedido para a empresa de fabricação: "+cEmpDest+CRLF+CRLF+cErro,,,"ERRO na replicação do Pedido: "+cPedido)

						Else

							U_FROPMSG(TIT_MSG, 	"Finalizado com Sucesso, incluido PEDIDO: "+cPedOri+" na empresa: "+SubStr(cEmpDest,1,2)+;
								IIF(lMatriz,CRLF+"E incluido pedido "+cPedMatriz+" na LM MATRIZ",""),,,"REPLICAR PEDIDO LM - "+cPedido)

							If !Empty(_cRetEmpAut)

								U_FROPMSG("FCOMRT01 - EMPENHO AUTOMATICO","Alerta empenho automático do pedido: "+CRLF+_cRetEmpAut,,2,"Empenho Automático de Pedidos")

							EndIf
						EndIf
					Else
						If !lOk
							//ConOut("FUNCAO: "+AllTrim(FunName())+" - "+"ERRO na replicação do Pedido: "+cPedido+" Informe ao setor Comercial/TI erro com a cópia do pedido para a empresa de fabricação: "+cEmpDest+CRLF+CRLF+cErro)
						Else
							ConOut("FUNCAO: "+AllTrim(FunName())+" - "+"REPLICAR PEDIDO LM - "+cPedido+" Finalizado com Sucesso, incluido PEDIDO: "+cPedOri+" na empresa: "+SubStr(cEmpDest,1,2))
						EndIf
					EndIf

				Else

					If !lJob
						U_FROPMSG(TIT_MSG, "EMPRESA PARA REPLICAÇÃO NÃO CONFIGURADA - ENTRAR EM CONTATO COM O COMERCIAL!",,,"ERRO na replicação do Pedido: "+cPedido)
					Else
						ConOut("ERRO na replicação do Pedido: "+cPedido+" EMPRESA PARA REPLICAÇÃO NÃO CONFIGURADA - ENTRAR EM CONTATO COM O COMERCIAL!")
					EndIf

				EndIf

			Else

				If !lJob
					U_FROPMSG(TIT_MSG, "PEDIDO JÁ FOI REPLICADO!",,,"ERRO na replicação do Pedido: "+cPedido)
				Else
					ConOut("ERRO na replicação do Pedido: "+cPedido+" PEDIDO JÁ FOI REPLICADO!")
				EndIf

			EndIf

		Else

			If !lJob
				U_FROPMSG(TIT_MSG, "PEDIDO NÃO ENCONTRADO - ENTRAR EM CONTATO COM O COMERCIAL!",,,"ERRO na replicação do Pedido: "+cPedido)
			Else
				ConOut("ERRO na replicação do Pedido: "+cPedido+" PEDIDO NÃO ENCONTRADO - ENTRAR EM CONTATO COM O COMERCIAL!")
			EndIf

		EndIf

	Else
		//Consulta Pedidos Pendentes

	End

	RestArea(aArea)

Return


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//EXECAUTO DO PEDIDO DE VENDAS
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function FCOMXPED(cPedido, cEmpDest, _cRepAtu, _cUserName, cFilOri, lMatriz, cPedOri)

	Local aCabPV := {}
	Local aItemPV:= {}
	Local cItem
	Local I
	Local cAliasTmp
	Local cAliasAux
	Local _cLogTxt := ""

	Local cNumPed
	Local _cCondPag := ""
	Local _cTipoPD 	:= ""
	Local _cLin		:= ""
	Local _cTESX	:= AllTrim(GetNewPar("FA_TSVLM"+AllTrim(CEMPANT),""))
	Local _cCFX		:= ""
	Local _cCLASFX	:= ""
	Local aRetPrc
	Local cPrcMundi
	Local _cDIGP

	Local aSQLFields := ""
	Local aSC5Exc := {}
	Local aSC6Exc := {}
	Local aAux := {}

	Local _cTabPar := ""
	Local _cTabLM := ""
	Local _cCLIENTE
	Local _cRetEmpAut := ""

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	Default _cUserName	:= "RPC"
	Default lMatriz 	:= .F.
	Default cPedOri		:= ""

	ConOut("FUNCAO: "+AllTrim(FunName())+" - REPLICAR PEDIDO LM - "+cPedido+": Preparando...")

	//Campos do SC5
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SC5"))
	While !SX3->(eof()) .And. SX3->X3_ARQUIVO == "SC5"
		If  X3USO(SX3->X3_USADO) .And. SX3->X3_NIVEL <= cNivel .And. SX3->X3_TIPO <> "M" .And. SX3->X3_CONTEXT <> "V"
			aSQLFields += IIF(!Empty(aSQLFields),", ","")
			aSQLFields += "SC5."+AllTrim(SX3->X3_CAMPO)
		EndIf
		SX3->(DbSkip())
	EndDo

	//Campos do SC6
	SX3->(DbSeek("SC6"))
	While !SX3->(eof()) .And. SX3->X3_ARQUIVO == "SC6"
		If  X3USO(SX3->X3_USADO) .And. SX3->X3_NIVEL <= cNivel .And. SX3->X3_TIPO <> "M" .And. SX3->X3_CONTEXT <> "V"
			aSQLFields += IIF(!Empty(aSQLFields),", ","")
			aSQLFields += "SC6."+AllTrim(SX3->X3_CAMPO)
		EndIf
		SX3->(DbSkip())
	EndDo

	aSQLFields := "% "+aSQLFields+" %"

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NOPARSER%

		SELECT %EXP:aSQLFields%
		,SC5.C5_YEMP
		,OBSMEMO = ISNULL(cast(convert(varbinary(5000),C5_YOBS) as varchar(5000)),'')
		,A1_YCDGREG 
		FROM SC5070 SC5
		JOIN SC6070 SC6 ON C6_FILIAL  = C5_FILIAL AND C6_NUM 	 = C5_NUM
		JOIN SA1010 SA1 ON C5_CLIENTE = A1_COD 	  AND C5_LOJACLI = A1_LOJA 
		WHERE
		SC5.C5_FILIAL = %EXP:cFilOri%
		AND SC5.C5_NUM = %EXP:cPedido%
		AND SC5.D_E_L_E_T_ = ' '
		AND SC6.D_E_L_E_T_ = ' '
		AND SA1.D_E_L_E_T_ = ' '
		ORDER BY C5_NUM, C6_ITEM

	EndSql
	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(Eof())
		ConOut("REPLICAR PEDIDO LM - "+cPedido+": Pedido Ok.")
	Else
		_cLogTxt := "REPLICAR PEDIDO LM - "+cPedido+": Pedido NÃO ENCONTRADO!"
		//ConOut(_cLogTxt)
		return({.F.,_cLogTxt, ""})
	EndIf

	//Validacao de pedido ja replicado
	If !lMatriz
		If !Empty((cAliasTmp)->C5_YPEDORI)
			_cLogTxt := "REPLICAR PEDIDO LM - "+cPedido+": Pedido já foi replicado para empresa: "+AllTrim((cAliasTmp)->C5_YEMPPED)+" - com o número: "+AllTrim((cAliasTmp)->C5_YPEDORI)+""
			//ConOut(_cLogTxt)
			return({.F.,_cLogTxt, ""})
		EndIf
	EndIf

	//Cabecalho

	//Numero do novo pedido
	//If ( !Empty(_cRepAtu) .Or. AllTrim((cAliasTmp)->C5_YDIGP) == AllTrim((cAliasTmp)->C5_VEND1) ).And. (CEMPANT <> "13")//mundi tem uma mesma sequencia de pedido
	If ( (!Empty(_cRepAtu) .And. (AllTrim((cAliasTmp)->C5_VEND1) <> '999999')) .Or. AllTrim((cAliasTmp)->C5_YDIGP) == AllTrim((cAliasTmp)->C5_VEND1) ).And. (CEMPANT <> "13")//mundi tem uma mesma sequencia de pedido

		If (AllTrim(cEmpAnt) == '01')
			cNumPed := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_BIA_REP")
		ElseIf(AllTrim(cEmpAnt) == '07')
			cNumPed := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_LM_REP")
		Else
			cNumPed := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_REP")
		EndIf
	Else
		cNumPed := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_INT")
	EndIf

	//Condicao de Pagamento LM
	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux

		select E4_YCOND, E4_TIPO from SE4010 where E4_CODIGO = %EXP:(cAliasTmp)->C5_CONDPAG% and E4_YCOND <> E4_CODIGO and  D_E_L_E_T_=''

	EndSql
	(cAliasAux)->(DbGoTop())
	If !(cAliasAux)->(Eof())
		//Tratamento para Condição de Pagamento do Tipo 9 // OS 4134-15
		If Alltrim((cAliasAux)->E4_TIPO) <> "9"
			_cCondPag := (cAliasAux)->E4_YCOND
		Else
			_cCondPag := "056"
		EndIf
	Else
		_cCondPag := (cAliasTmp)->C5_CONDPAG
	EndIf
	(cAliasAux)->(DbCloseArea())

	//Se for pedido na Matriz para Filial - procura a condicao ST relaciona a normal
	If lMatriz

		cAliasAux := GetNextAlias()
		BeginSql Alias cAliasAux

			select E4_CODIGO, E4_TIPO from SE4010 where E4_YCOND = %EXP:(cAliasTmp)->C5_CONDPAG% and E4_SOLID = 'S' and D_E_L_E_T_=''

		EndSql
		(cAliasAux)->(DbGoTop())
		If !(cAliasAux)->(Eof())
			//Tratamento para Condição de Pagamento do Tipo 9 // OS 4134-15
			If Alltrim((cAliasAux)->E4_TIPO) <> "9"
				_cCondPag := (cAliasAux)->E4_CODIGO
			Else
				_cCondPag := "236"
			EndIf
		Else
			_cCondPag := (cAliasTmp)->C5_CONDPAG
		EndIf
		(cAliasAux)->(DbCloseArea())

	EndIf

	//Tipo do Pedido
	If AllTrim(CEMPANT) == "13"
		_cTipoPD := "IM"
		If _cCondPag == "000"
			_cCondPag := "145"
		EndIf

		If (AllTrim((cAliasTmp)->C5_YLINHA) == '6' .And. AllTrim((cAliasTmp)->C5_CLIENTE) == '029954')
			_cCondPag := "090" //90 dias
		EndIf


	Else
		If !lMatriz
			_cTipoPD := "N"
		Else
			_cTipoPD := "E"
		EndIf
	EndIf


	//Fernando/Facile em 24/09/15 - para outsourcing buscar condicao de pagamento do parametro - solicitacao do Claudeir
	//Parametro FA_CPGPCT+"Pacote" configurado em cada empresa conforme pacotes -> por enquanro so o outsourcing entrada da incesa
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+(cAliasTmp)->C6_PRODUTO))

		_cCPGPar := "FA_CPGPCT"+AllTrim(SB1->B1_YPCGMR3)
		_cCondsO := AllTrim(GetNewPar(_cCPGPar,""))

		If !Empty(_cCondsO) .And. Len(_cCondsO) == 7

			_cCondNor := SubStr(AllTrim(GetNewPar(_cCPGPar,"")),1,3)
			_cCondAnt := SubStr(AllTrim(GetNewPar(_cCPGPar,"")),5,3)

			cAliasAux := GetNextAlias()
			BeginSql Alias cAliasAux
				%NOPARSER%
				select ANTECIPADO = case when %EXP:_cCondPag% in (select distinct E4_CODIGO from SE4010 where E4_DESCRI like '%ANTEC%' and E4_YATIVO = '1' and E4_TIPO = '1' and E4_MSBLQL <> '1' and D_E_L_E_T_='') then 1 else 0 end
			EndSql

			If !(cAliasAux)->(Eof()) .And. (cAliasAux)->ANTECIPADO == 1
				_cCondPag := _cCondAnt
			Else
				_cCondPag := _cCondNor
			EndIf
			(cAliasAux)->(DbCloseArea())

		EndIf

	EndIf

	//Tratamento para Condicao de Pagamento - FIDC
	If (cAliasTmp)->A1_YCDGREG == "000029" .And. !U_fValidaRA((cAliasTmp)->C5_CONDPAG)
		_cCondPag := "505"
	EndIf

	//Consolidacao - manter a mesma linha escolhida na LM
	_cLin := (cAliasTmp)->C5_YLINHA

	//salvando variaveis do cabecalho
	_cDIGP := (cAliasTmp)->C5_YDIGP

	//Fernando em 12/04/2017 - projeto filial LM
	_cCLIENTE := "010064"

	If lMatriz

		If cFilOri == "02"
			_cCLIENTE := "025633"
		ElseIf cFilOri == "03"
			_cCLIENTE := "025634"
		ElseIf cFilOri == "04"
			_cCLIENTE := "025704"
		EndIf

	EndIf

	//Preenchimento dos Campos Padroes - Cabecalho
	aCabPV:={}
	aAdd(aCabPV,  {"C5_NUM"   		,cNumPed   					,Nil}) // Numero do pedido
	aAdd(aCabPV,  {"C5_TIPO"   		,(cAliasTmp)->C5_TIPO   	,Nil}) // Tipo do pedido
	aAdd(aCabPV,  {"C5_YLINHA"  	,_cLin					   	,Nil})
	aAdd(aCabPV,  {"C5_CLIENTE"   	,_cCLIENTE 					,Nil})
	aAdd(aCabPV,  {"C5_LOJACLI"   	,"01" 	 					,Nil})
	aAdd(aCabPV,  {"C5_TIPOCLI"		,IIf(lMatriz,"S","R")		,Nil})
	aAdd(aCabPV,  {"C5_CLIENT"   	,_cCLIENTE 					,Nil})
	aAdd(aCabPV,  {"C5_LOJAENT"		,"01"	  					,Nil})
	aAdd(aCabPV,  {"C5_YSUBTP"		,_cTipoPD					,Nil})  //Falta Validar
	aAdd(aCabPV,  {"C5_ORIGEM"		,""							,Nil})

	//fernando/facile em 25/04/17 - se for pedido na LM Matriz copiar a transportador e tipo de frete
	If lMatriz
		aAdd(aCabPV,  {"C5_TRANSP"		,(cAliasTmp)->C5_TRANSP		,Nil})
		aAdd(aCabPV,  {"C5_TPFRETE"		,(cAliasTmp)->C5_TPFRETE	,Nil})
	Else
		aAdd(aCabPV,  {"C5_TRANSP"		,""							,Nil})
		aAdd(aCabPV,  {"C5_TPFRETE"		,"S"						,Nil})
	EndIf

	aAdd(aCabPV,  {"C5_CONDPAG"		, _cCondPag					,Nil})

	//Correção da Comissão para Pedidos do Cliente LM
	aAdd(aCabPV,  {"C5_VEND1"		,"999999"					,Nil})
	aAdd(aCabPV,  {"C5_COMIS1"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS2"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS3"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS4"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS5"		,0							,Nil})

	aAdd(aCabPV,  {"C5_EMISSAO"		,dDataBase					,Nil})

	//Preenchimento dos Campos Customizados - Cabecalho
	If lMatriz
		aAdd(aCabPV,  {"C5_YPEDORI"		,cPedOri		 					,Nil})
	EndIf

	//aAdd(aCabPV,  {"C5_YEMP"		,cEmpDest			 					,Nil})
	aAdd(aCabPV,  {"C5_YEMP"		,(cAliasTmp)->C5_YEMP					,Nil})  //Alterado no projeto PBI
	aAdd(aCabPV,  {"C5_YEMPPED"		,SubStr(cEmpDest,1,2)					,Nil})
	aAdd(aCabPV,  {"C5_YCLIORI"		,(cAliasTmp)->C5_CLIENTE				,Nil})
	aAdd(aCabPV,  {"C5_YLOJORI"		,(cAliasTmp)->C5_LOJACLI				,Nil})
	aAdd(aCabPV,  {"C5_YFORMA"		,"3"									,Nil})
	aAdd(aCabPV,  {"C5_YDIGP"		,(cAliasTmp)->C5_YDIGP					,Nil})
	aAdd(aCabPV,  {"C5_YPC"			,(cAliasTmp)->C5_YPC					,Nil})
	aAdd(aCabPV,  {"C5_YHORA"		,(cAliasTmp)->C5_YHORA					,Nil})
	aAdd(aCabPV,  {"C5_YOBS"		,(cAliasTmp)->OBSMEMO					,Nil})


	// Tiago Rossini Coradini - OS: 1736-15
	aAdd(aCabPV,  {"C5_YFLAG", "1", Nil})


	//Se for usuario interno - replicar automaticamente os campos de conferencia
	If Empty(_cRepAtu)

		aAdd(aCabPV,  {"C5_YCONF"	,(cAliasTmp)->C5_YCONF	,Nil})
		aAdd(aCabPV,  {"C5_YUSCONF"	,_cUserName	,Nil})

	EndIf

	//Campo para nao processar
	aSC5Exc := {"C5_TABELA","C5_LOJACLI","C5_TIPOCLI","C5_MENNOTA"}

	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SC5"))
	While !SX3->(eof()) .And. SX3->X3_ARQUIVO == "SC5"
		If  X3USO(SX3->X3_USADO) .And. SX3->X3_NIVEL <= cNivel .And. SX3->X3_TIPO <> "M" .And. SX3->X3_CONTEXT <> "V";
				.And. aScan(aCabPV,{|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)}) <= 0;
				.And. aScan(aSC5Exc,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) <= 0;
				.And. !Empty(&(cAliasTmp+"->"+AllTrim(SX3->X3_CAMPO)));
				.And. SX3->X3_PROPRI <> "U"

			If SX3->X3_TIPO <> "D"
				aAdd(aCabPV,  {SX3->X3_CAMPO	,	&(cAliasTmp+"->"+AllTrim(SX3->X3_CAMPO))	,Nil})
			Else
				aAdd(aCabPV,  {SX3->X3_CAMPO	,	STOD(&(cAliasTmp+"->"+AllTrim(SX3->X3_CAMPO)))	,Nil})
			EndIf

		EndIf
		SX3->(DbSkip())
	EndDo

	//Items
	aItemPV := {}

	//Item inicial
	cItem := StrZero(0,TamSx3("C6_ITEM")[1])

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		cItem := Soma1(cItem,Len(cItem))

		//Regras especiais
		//__CTES := MaTesInt(2,Space(2),(cAliasTmp)->C5_CLIENT,(cAliasTmp)->C5_LOJAENT,If((cAliasTmp)->C5_TIPO$'DB',"F","C"),(cAliasTmp)->C6_PRODUTO,"C6_TES")


		//Fernando/Facile em 21/09/15 - buscar preco fixo LM de tabela outsourcing - OS 3551-15
		//Parametro FA_TABPCT+"Pacote" configurado em cada empresa conforme pacotes/tabelas
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(XFilial("SB1")+(cAliasTmp)->C6_PRODUTO))

			_cTabPar := "FA_TABPCT"+AllTrim(SB1->B1_YPCGMR3)
			_cTabLM := AllTrim(GetNewPar(_cTabPar,""))


		EndIf

		//vinilico transferencia filial
		If (AllTrim(cEmpAnt) == '13' .And. AllTrim(_cLin) == '6' .And. AllTrim((cAliasTmp)->C5_CLIENTE) == '029954')

			aRetPrc := CalcTraVin(cAliasTmp)

		Else

			If !Empty(_cTabLM)

				aRetPrc := CalcLMOut(cAliasTmp, _cTabLM, _cLin)

			Else

				aRetPrc := CalcLM(cAliasTmp, _cLin, cFilOri, _cCondPag )

			EndIf

		EndIf

		//TES de venda da origme para LM - se nao parametrizada busca da TES inteligente
		If Empty(_cTESX)

			cAliasAux := GetNextAlias()
			BeginSql Alias cAliasAux
				%NOPARSER%

				SELECT FM_TS FROM %TABLE:SFM% A WHERE FM_FILIAL = %XFILIAL:SFM% AND FM_CLIENTE = %Exp:_cCLIENTE% AND FM_TIPO = %EXP:_cTipoPD%
				AND (FM_GRPROD = (SELECT B1_GRTRIB FROM SB1010 B WHERE B1_COD = %EXP:(cAliasTmp)->C6_PRODUTO% AND B.D_E_L_E_T_='') OR FM_GRPROD = '') AND A.D_E_L_E_T_=''

			EndSql
			(cAliasAux)->(DbGoTop())
			If !(cAliasAux)->(Eof())
				_cTESX := (cAliasAux)->FM_TS
			Else
				_cLogTxt := "Não foi possível determinar a TES para replicação deste pedido para a empresa de origem!"
				//ConOut(_cLogTxt)
				return({.F.,_cLogTxt, ""})
			EndIf
			(cAliasAux)->(DbCloseArea())

		EndIf

		//Buscar o CFOP - no automatico nao esta funcionando
		If !Empty(_cTESX)

			SF4->(DbSetOrder(1))
			SF4->(DbSeek(XFilial("SF4")+_cTESX))

			_cCFX := SF4->F4_CF

			If (_cCLIENTE == "010064")
				_cCFX := "5"+SubStr(_cCFX,2,3)
			Else
				_cCFX := "6"+SubStr(_cCFX,2,3)
			EndIf

			_cCLASFX := "0"+SF4->F4_SITTRIB

			SBZ->(DbSetOrder(1))
			If SBZ->(DbSeek(XFilial("SBZ")+(cAliasTmp)->C6_PRODUTO))
				_cCLASFX := SBZ->BZ_ORIGEM+SF4->F4_SITTRIB
			Else
				_cCLASFX := SB1->B1_ORIGEM+SF4->F4_SITTRIB
			EndIf

		EndIf


		aAux := {}
		aAdd(aAux,{"C6_NUM"		,cNumPed						,Nil})
		aAdd(aAux,{"C6_ITEM"	,(cAliasTmp)->C6_ITEM			,Nil}) // Numero do Item no Pedido

		aAdd(aAux,{"C6_PRODUTO"	,(cAliasTmp)->C6_PRODUTO		,Nil})
		aAdd(aAux,{"C6_QTDVEN"	,(cAliasTmp)->C6_QTDVEN			,Nil})
		aAdd(aAux,{"C6_YQTDPC"	,(cAliasTmp)->C6_YQTDPC			,Nil})

		aAdd(aAux,{"C6_PRCVEN"	,aRetPrc[1]				   		,Nil})
		aAdd(aAux,{"C6_VALOR"	,aRetPrc[2]			 	   		,Nil})
		aAdd(aAux,{"C6_PRUNIT"	,aRetPrc[3]			    		,Nil})
		aAdd(aAux,{"C6_YPERC"	,aRetPrc[4]			 	   		,Nil})
		aAdd(aAux,{"C6_YDESC"	,aRetPrc[5]			 	   		,Nil})
		aAdd(aAux,{"C6_VALDESC"	,aRetPrc[6]				  		,Nil})
		aAdd(aAux,{"C6_DESCONT"	,aRetPrc[7]						,Nil})
		aAdd(aAux,{"C6_YPRCTAB"	,aRetPrc[8]						,Nil})

		If aRetPrc[9] <> 0
			aAdd(aAux,{"C6_YFATMUL"	,aRetPrc[9]						,Nil})
		Else
			aAdd(aAux,{"C6_YFATMUL"	,(cAliasTmp)->C6_YFATMUL		,Nil})
		EndIf

		aAdd(aAux,{"C6_YFATRED"	,aRetPrc[10]					,Nil})

		aAdd(aAux,{"C6_TES"		,_cTESX					   		,Nil})
		aAdd(aAux,{"C6_CLASFIS"	,_cCLASFX				   		,Nil})
		aAdd(aAux,{"C6_CF"		,_cCFX					   		,Nil})

		aAdd(aAux,{"C6_YEMP"	,cEmpDest						,Nil})
		aAdd(aAux,{"C6_YREGRA"	,(cAliasTmp)->C6_YREGRA			,Nil})

		//Local pegando o mesmo da LM - ja esta tratado conforme estoque selecionado projeto PBI/Consolidacao
		aAdd(aAux,{"C6_LOCAL"	,(cAliasTmp)->C6_LOCAL	,Nil})

		//campos do processo de reserva de lote
		aAdd(aAux,{"C6_YTPEST"	,(cAliasTmp)->C6_YTPEST			,Nil})
		aAdd(aAux,{"C6_YDTNECE"	,(cAliasTmp)->C6_YDTNECE		,Nil})
		aAdd(aAux,{"C6_YDTNERE"	,(cAliasTmp)->C6_YDTNERE		,Nil})
		aAdd(aAux,{"C6_YQTDSUG"	,(cAliasTmp)->C6_YQTDSUG		,Nil})
		aAdd(aAux,{"C6_YLOTSUG"	,(cAliasTmp)->C6_YLOTSUG		,Nil})
		aAdd(aAux,{"C6_YLOTTOT"	,(cAliasTmp)->C6_YLOTTOT		,Nil})

		aAdd(aAux,{"C6_YMOTFRA"	,(cAliasTmp)->C6_YMOTFRA		,Nil})
		aAdd(aAux,{"C6_YBLQLOT"	,(cAliasTmp)->C6_YBLQLOT		,Nil})
		aAdd(aAux,{"C6_YDTDISP"	,CTOD(" ")						,Nil})

		//campos da nova politica - fernando em 01/10/2015 -- Ranisses em 06/10/2015 para ajuste nos calculos da empresa Origem
		If AllTrim(CEMPANT) <> "13"
			aAdd(aAux,{"C6_YDESP"	,(cAliasTmp)->C6_YDESP			,Nil})
			aAdd(aAux,{"C6_YDPAL"	,(cAliasTmp)->C6_YDPAL			,Nil})
			aAdd(aAux,{"C6_YDREG"	,(cAliasTmp)->C6_YDREG			,Nil})
			aAdd(aAux,{"C6_YDMIX"	,(cAliasTmp)->C6_YDMIX			,Nil})
			aAdd(aAux,{"C6_YDNV"	,(cAliasTmp)->C6_YDNV			,Nil})
			aAdd(aAux,{"C6_YDCAT"	,(cAliasTmp)->C6_YDCAT			,Nil})

			aAdd(aAux,{"C6_YDVER"	,(cAliasTmp)->C6_YDVER			,Nil})
			aAdd(aAux,{"C6_YDACO"	,(cAliasTmp)->C6_YDACO			,Nil})
			aAdd(aAux,{"C6_YDFRA"	,(cAliasTmp)->C6_YDFRA			,Nil})



			If SC6->(FieldPos("C6_YDAI")) > 0
				aAdd(aAux,{"C6_YDAI"	,(cAliasTmp)->C6_YDAI			,Nil})
			EndIf

			aAdd(aAux,{"C6_YDESCLI"	,(cAliasTmp)->C6_YDESCLI		,Nil})
		EndIf

		//Campos para nao processar
		aSC6Exc := {"C6_TES","C6_CF","C6_CLASFIS","C6_BLOQUEI","C6_BLQ","C6_LOCALIZ"}

		SX3->(DbSetOrder(1))
		SX3->(DbSeek("SC6"))
		While !SX3->(eof()) .And. SX3->X3_ARQUIVO == "SC6"
			If  X3USO(SX3->X3_USADO) .And. SX3->X3_NIVEL <= cNivel .And. SX3->X3_TIPO <> "M" .And. SX3->X3_CONTEXT <> "V";
					.And. aScan(aAux,{|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)}) <= 0;
					.And. aScan(aSC6Exc,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) <= 0;
					.And. !Empty(&(cAliasTmp+"->"+AllTrim(SX3->X3_CAMPO)));
					.And. SX3->X3_PROPRI <> "U"

				If SX3->X3_TIPO <> "D"
					aAdd(aAux,  {SX3->X3_CAMPO	,	&(cAliasTmp+"->"+AllTrim(SX3->X3_CAMPO))	,Nil})
				Else
					aAdd(aAux,  {SX3->X3_CAMPO	, STOD(&(cAliasTmp+"->"+AllTrim(SX3->X3_CAMPO)))	,Nil})
				EndIf

			EndIf
			SX3->(DbSkip())
		EndDo

		Aadd(aItemPV,AClone(aAux))

		(cAliasTmp)->(DbSkip())
	EndDo

	IF Len(aItemPV) <= 0
		_cLogTxt += "Não é possível gerar pedido de vendas sem itens!"
		return({.F.,_cLogTxt, ""})
	ENDIF

	//Geracao do Pedido de Venda
	Begin Transaction

		//Posicionar arquivos do cabecalho
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(XFilial("SA1")+_cCLIENTE+"01"))

		SE4->(DbSetOrder(1))
		SE4->(DbSeek(XFilial("SE4")+_cCondPag))

		//Verificar numeracao do pedido
		dbSelectArea("SC5")
		cMay := "SC5"+ Alltrim(xFilial("SC5"))
		SC5->(dbSetOrder(1))
		While ( DbSeek(xFilial("SC5")+cNumPed) .or. !MayIUseCode(cMay+cNumPed) )
			cNumPed := Soma1(cNumPed,Len(cNumPed))
			aCabPV[1][2] := cNumPed
			AEval(aItemPV,{|x|  x[1][2] := cNumPed })
		EndDo

		ConOut("REPLICAR PEDIDO LM - "+cPedido+": Iniciando ExecAuto...")
		MsExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,3)

		If lMsErroAuto
			RollBackSX8()
			DisarmTransaction()

			//Grava log de erro para consulta posterior
			aAutoErro := GETAUTOGRLOG()
			_cLogTxt += XCONVERRLOG(aAutoErro)
			//ConOut("REPLICAR PEDIDO LM - "+cPedido+": ERRO: "+_cLogTxt)
			MemoWrite("\PEDREPL\PED_"+AllTrim(cPedido)+".TXT", _cLogTxt)
			return({.F.,_cLogTxt, ""})
		Else
			ConfirmSX8()

			(cAliasTmp)->(DbGoTop())

			//Gravar campos manualmente no Pedido de venda incluido na empresa origem, para não disparar regras de gatilhos/validacoes que ocorre problema no execauto
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(XFilial("SC5")+cNumPed))

				RecLock("SC5",.F.)

				If !Empty(_cTabLM)
					SC5->C5_TABELA	:= _cTabLM
				EndIf

				SC5->C5_YDTINC := STOD((cAliasTmp)->C5_YDTINC)
				SC5->C5_YPRZINC := (cAliasTmp)->C5_YPRZINC
				SC5->C5_YNUMSI := (cAliasTmp)->C5_YNUMSI

				If SC5->(FieldPos("C5_YNOUTAI")) > 0
					SC5->C5_YNOUTAI := (cAliasTmp)->C5_YNOUTAI
				EndIf

				SC5->(MsUnlock())

			EndIf

			//GRAVA COMISSAO ZERO PARA PEDIDOS DE VENDA DA LM PARA FARBICA
			If Alltrim(cEmpAnt) $ "01_05_13" .And. 	SC5->C5_CLIENTE == "010064"
				ConOut("FCOMRT01 => ACERTA COMISSAO CLIENTE LM")

				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM))
					While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+SC5->C5_NUM)
						RecLock("SC6",.F.)
						SC6->C6_COMIS1 := 0
						SC6->C6_COMIS2 := 0
						SC6->C6_COMIS3 := 0
						SC6->C6_COMIS4 := 0
						SC6->C6_COMIS5 := 0
						SC6->(MsUnlock())

						SC6->(DbSkip())
					EndDo
				EndIf

			EndIf

			If !lMatriz

				//Gravar campos na empresa origem - LM - via update
				//Grava o nome dos Produtos na tabela de Liberacao
				cSql := "UPDATE SC5070 "
				cSql += "	SET C5_YPEDORI = '"+cNumPed+"' "
				cSql += "	, C5_YEMPPED = '"+AllTrim(CEMPANT)+"' "
				cSql += "	WHERE "
				cSql += "		C5_FILIAL = '"+cFilOri+"' "
				cSql += "		AND C5_NUM = '"+cPedido+"' "
				cSql += "		AND D_E_L_E_T_ = ' ' "

				TcSQLExec(cSQL)

				//Tira o bloqueio de LOTE do pedido LM
				cSql := "UPDATE SC6070 "
				cSql += "	SET C6_YMOTFRA = ' ' "
				cSql += "	, C6_YBLQLOT = '00' "
				cSql += "	, C6_MSEXP   = '' 	"
				cSql += "	WHERE "
				cSql += "		C6_FILIAL = '"+cFilOri+"' "
				cSql += "		AND C6_NUM = '"+cPedido+"' "
				cSql += "		AND D_E_L_E_T_ = ' ' "

				TcSQLExec(cSQL)


				aAdd(aAux,{"C6_YMOTFRA"	,""			,Nil})
				aAdd(aAux,{"C6_YBLQLOT"	,"00"		,Nil})


				//Gravar campos na reserva SC0 do pedido original se existir
				PswOrder(2)
				PswSeek(_cDIGP,.T.)

				cSql := "UPDATE "+RetSQLName("SC0")+" "
				cSql += "SET C0_YPEDIDO = '"+cNumPed+"' "
				cSql += "	, C0_YITEMPV = SUBSTRING(C0_YPITORI,7,2) "
				cSql += "	, C0_SOLICIT = '"+_cUserName+"' "
				cSql += "	, C0_YTEMP = 'N' "
				cSql += " WHERE R_E_C_N_O_ in "
				cSql += " 	( "
				cSql += " select distinct R_E_C_N_O_ from ( "
				cSql += " select C0_SOLICIT = SubString(C0_SOLICIT,1,6), C0_PRODUTO, ITEM = SUBSTRING(C0_YPITORI,7,2), R_E_C_N_O_ = Max(SC0.R_E_C_N_O_) "
				cSql += "  	from "+RetSQLName("SC0")+" SC0  "
				cSql += "  	join "+RetSQLName("SC6")+" SC6 on C6_NUM = '"+cNumPed+"' and C6_ITEM = SUBSTRING(C0_YPITORI,7,2) and C6_PRODUTO = C0_PRODUTO  "
				cSql += "  	where  "
				cSql += "  		SubString(C0_SOLICIT,1,6) = '"+PswID()+"' "
				cSql += "  		and C0_YTEMP = 'S'  "
				cSql += "  		and SC0.D_E_L_E_T_='' "
				cSql += "  		and SC6.D_E_L_E_T_='' "
				cSql += " 	group by SubString(C0_SOLICIT,1,6), C0_PRODUTO, SUBSTRING(C0_YPITORI,7,2)) tab "
				cSql += "   ) "
				cSql += "	AND D_E_L_E_T_ = ' ' "

				TcSQLExec(cSQL)

				cSql := "UPDATE "+RetSQLName("PZ0")+" "
				cSql += "SET PZ0_PEDIDO = '"+cNumPed+"' "
				cSql += "	, PZ0_USUINC = '"+_cUserName+"' "
				cSql += "	, PZ0_STATUS = 'P' "
				cSql += " WHERE R_E_C_N_O_ in "
				cSql += " 	( "
				cSql += " select distinct R_E_C_N_O_ from( "
				cSql += " select PZ0_USUINC = SubString(PZ0_USUINC,1,6), PZ0_CODPRO, ITEM = PZ0_ITEMPV, R_E_C_N_O_ = Max(PZ0.R_E_C_N_O_) "
				cSql += "  	from "+RetSQLName("PZ0")+" PZ0 "
				cSql += "  	join "+RetSQLName("SC6")+" SC6 on C6_NUM = '"+cNumPed+"' and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO  "
				cSql += "  	where  "
				cSql += "  		SubString(PZ0_USUINC,1,6) = '"+PswID()+"'  "
				cSql += "  		and PZ0_STATUS = 'T'  "
				cSql += "  		and PZ0.D_E_L_E_T_=''  "
				cSql += "  		and SC6.D_E_L_E_T_='' "
				cSql += " 	group by SubString(PZ0_USUINC,1,6), PZ0_CODPRO, PZ0_ITEMPV) tab  "
				cSql += " ) "
				cSql += "	AND D_E_L_E_T_ = ' ' "

				TcSQLExec(cSQL)

				//Atendente interno incluindo pedido ja conferido
				If Empty(_cRepAtu) .And. (cAliasTmp)->C5_YCONF == "S"

					_oEmpAut := TBiaEmpenhoPedido():New()
					_aRetEmp := _oEmpAut:LibPedido(cNumPed)
					If (!Empty(_aRetEmp[2]))

						_cRetEmpAut := _aRetEmp[2]
						CONOUT("FCOMRT01 - EMPENHO AUTOMATICO - Alerta empenho automático do pedido: "+_aRetEmp[2])

					EndIf

				EndIf

			EndIf

		EndIf

	End Transaction

	(cAliasTmp)->(DbCloseArea())
	ConOut("REPLICAR PEDIDO LM - "+cPedido+": Finalizado com Sucesso, incluido PEDIDO: "+cNumPed+" na empresa: "+CEMPANT)
return({.T.,_cLogTxt, cNumPed, _cRetEmpAut})

STATIC FUNCTION XCONVERRLOG(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1

	FOR nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+CRLF
	NEXT nX
RETURN cRet



/*/{Protheus.doc} CalcLM
@description Calculo de Preco LM
@author Fernando Rocha
@since 12/04/2017
@version undefined
@param _cAliasPed, , descricao
@param _cLinha, , descricao
@type function
/*/
Static Function CalcLM(_cAliasPed,_cLinha, cFilOri, _cCondPag)
	//Programa Transcrito do MTA416PV - regras para calculcar preços e descontos do pedido LM
	//aRet >>> vetor de retorno na mesma ordem das variaveis/campos abaixo

	Local aRet 			:= Array(8)

	Local _nC6_PRCVEN 	:= (_cAliasPed)->C6_PRCVEN
	Local _nC6_PRUNIT 	:= (_cAliasPed)->C6_PRUNIT
	Local _nC6_YPRCTAB	:= (_cAliasPed)->C6_YPRCTAB
	Local _nC6_VALOR 	:= (_cAliasPed)->C6_VALOR
	Local _nC6_VALDESC	:= (_cAliasPed)->C6_VALDESC
	Local _nC6_DESCONT	:= (_cAliasPed)->C6_DESCONT
	Local _nC6_YPERC	:= (_cAliasPed)->C6_YPERC
	Local _nC6_YDESC	:= (_cAliasPed)->C6_YDESC
	Local _nC5_YMAXCND	:= (_cAliasPed)->C5_YMAXCND
	Local _nC6_YFATMUL	:= 0
	Local _nC6_YFATRED	:= 1
	Local _nNewFatFin	:= 0
	Local _cPacote		:= ""
	Local _aAreaM0		:= SM0->(GetArea())
	Local _aAreaSE4		:= SE4->(GetArea())

	SM0->(DbSetOrder(1))
	SM0->(DbSeek("07"+cFilOri))

	If (AllTrim(SB1->B1_YPCGMR3) == 'J') //Projeto Vinilico - Ticket: 20038
		_cPacote := AllTrim(SB1->B1_YPCGMR3)
	EndIf

	_nC6_YFATRED		:= U_LMFatRed(SM0->M0_ESTCOB, _cPacote)

	RestArea(_aAreaM0)

	//Posiciona nova Condicao Pagamento - FIDC
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(XFilial("SE4")+_cCondPag))

	_nNewFatFin	:= SE4->E4_YMAXDES
	RestArea(_aAreaSE4)

	_nC6_YPRCTAB	:= _nC6_YPRCTAB / (_cAliasPed)->C5_YMAXCND	 	//RETIRA FATOR FINANCEIRO ORIGINAL
	_nC6_YPRCTAB	:= _nC6_YPRCTAB * _nNewFatFin					//APLICA NOVO FATOR FINANCEIRO

	IF AllTrim(cFilOri) == "01" .Or. (_cAliasPed)->C6_YFATMUL == 0
		_nC6_YPRCTAB	:= Round(_nC6_YPRCTAB * _nC6_YFATRED, 4)
	ELSE
		_nC6_YPRCTAB	:= Round( ( _nC6_YPRCTAB / (_cAliasPed)->C6_YFATMUL ) * _nC6_YFATRED, 4)
	ENDIF

	_nC6_PRCVEN 	:= Round(_nC6_YPRCTAB - (_nC6_YPRCTAB * (_nC6_YDESC/100)), 2)
	_nC6_PRUNIT 	:= _nC6_PRCVEN
	_nC6_VALOR		:= Round(_nC6_PRCVEN * (_cAliasPed)->C6_QTDVEN ,2)
	_nC6_VALDESC 	:= 0
	_nC6_DESCONT 	:= 0

	aRet := {_nC6_PRCVEN,_nC6_VALOR,_nC6_PRUNIT,_nC6_YPERC,_nC6_YDESC,_nC6_VALDESC,_nC6_DESCONT,_nC6_YPRCTAB,_nC6_YFATMUL,_nC6_YFATRED}

Return( aRet )


/*/{Protheus.doc} CalcLMOut
@description ROTINAS PARA CALCULO DE PRECOS/DESCONTO PARA PEDIDOS P/ LM OUTSOURCING
@author Fernando Rocha
@since 12/04/2017
@version undefined
@param _cAliasPed, , descricao
@param _cTabLM, , descricao
@param _cLinha, , descricao
@type function
/*/
Static Function CalcLMOut(_cAliasPed, _cTabLM, _cLinha)
	Local aRet := Array(8)

	Local _nC6_PRCVEN 	:= (_cAliasPed)->C6_PRCVEN
	Local _nC6_VALOR 	:= (_cAliasPed)->C6_VALOR
	Local _nC6_PRUNIT 	:= (_cAliasPed)->C6_PRUNIT
	Local _nC6_YPERC	:= (_cAliasPed)->C6_YPERC
	Local _nC6_YDESC	:= (_cAliasPed)->C6_YDESC
	Local _nC6_VALDESC	:= (_cAliasPed)->C6_VALDESC
	Local _nC6_DESCONT	:= (_cAliasPed)->C6_DESCONT
	Local _nC6_YPRCTAB  := (_cAliasPed)->C6_YPRCTAB
	Local _nC6_YFATMUL	:= 0
	Local _nC6_YFATRED	:= 0

	Local nTab, nTabela

	nTabela := _cTabLM

	If !Empty(nTabela)

		nTab	:= U_fBuscaPreco(_cLinha,nTabela,(_cAliasPed)->C6_PRODUTO,(_cAliasPed)->C5_EMISSAO,"010064","01","N",99,0,0,"RAC",@_nC6_YFATMUL) //os 4 tres ultimos parametros é para buscar uma regra especifica na tabela Fator Mult (Z65)

		_nC6_VALDESC	:= 0
		_nC6_YPERC 		:= 0
		_nC6_YDESC 		:= 0
		_nC6_DESCONT 	:= 0
		_nC6_PRUNIT 	:= nTab
		_nC6_YPRCTAB	:= nTab
		_nC6_PRCVEN 	:= nTab
		_nC6_VALOR 		:= Round(_nC6_PRCVEN * (_cAliasPed)->C6_QTDVEN ,2)

	EndIf

	aRet := {_nC6_PRCVEN,_nC6_VALOR,_nC6_PRUNIT,_nC6_YPERC,_nC6_YDESC,_nC6_VALDESC,_nC6_DESCONT,_nC6_YPRCTAB, _nC6_YFATMUL, _nC6_YFATRED}

Return( aRet )


Static Function CalcTraVin(_cAliasPed)


	Local aRet 			:= Array(8)

	Local _nC6_PRCVEN 	:= (_cAliasPed)->C6_PRCVEN
	Local _nC6_VALOR 	:= (_cAliasPed)->C6_VALOR
	Local _nC6_PRUNIT 	:= (_cAliasPed)->C6_PRUNIT
	Local _nC6_YPERC	:= (_cAliasPed)->C6_YPERC
	Local _nC6_YDESC	:= (_cAliasPed)->C6_YDESC
	Local _nC6_VALDESC	:= (_cAliasPed)->C6_VALDESC
	Local _nC6_DESCONT	:= (_cAliasPed)->C6_DESCONT
	Local _nC6_YPRCTAB  := (_cAliasPed)->C6_YPRCTAB
	Local _nC6_YFATMUL	:= 0
	Local _nC6_YFATRED	:= 0

	Local _cQuery		:= ""
	Local _cAliasTmp	:= Nil
	Local _cCodTab		:= ""
	Local _nPrecoVen	:= 0

	Local _dEmiss		:= (_cAliasPed)->C5_EMISSAO
	Local _cProd		:= (_cAliasPed)->C6_PRODUTO


	_cQuery	:= "select X5_DESCRI from SX5070										"
	_cQuery	+= "				where 												"
	_cQuery	+= "				X5_TABELA		= 'ZF'								"
	_cQuery	+= "				AND X5_CHAVE	= 'VRT'								"
	_cQuery	+= "				AND D_E_L_E_T_	= ''								"

	_cAliasTmp	:= GetNextAlias()

	TCQUERY _cQuery NEW ALIAS (_cAliasTmp)

	If !(_cAliasTmp)->(Eof())
		_cCodTab := AllTrim((_cAliasTmp)->X5_DESCRI)
	EndIf

	(_cAliasTmp)->(DbCloseArea())


	_cQuery	:= "SELECT DA1_PRCVEN, DA0_YPOLIT 											"
	_cQuery	+= "FROM DA1070 DA1, DA0070 DA0 											"
	_cQuery	+= " WHERE																	"
	_cQuery	+= "		DA0.DA0_FILIAL 		= '05'	AND 								"
	_cQuery	+= "     	DA1.DA1_FILIAL 		= '05'	AND 								"
	_cQuery	+= "		'" + _dEmiss +"' 	>= DA0.DA0_DATDE			AND 			"
	_cQuery	+= "		'" + _dEmiss +"' 	<= DA0.DA0_DATATE			AND 			"
	_cQuery	+= "		DA0.DA0_CODTAB		= '" + _cCodTab +"'			AND 			"
	_cQuery	+= "		DA0.DA0_CODTAB		= DA1.DA1_CODTAB			AND 			"
	_cQuery	+= "		DA1.DA1_CODPRO		= '" + _cProd +"'			AND 			"
	_cQuery	+= "		DA0.D_E_L_E_T_		= ''						AND 			"
	_cQuery	+= "		DA1.D_E_L_E_T_ 		= ''										"

	_cAliasTmp	:= GetNextAlias()

	TCQUERY _cQuery NEW ALIAS (_cAliasTmp)

	If !(_cAliasTmp)->(Eof())

		_nPrecoVen := (_cAliasTmp)->DA1_PRCVEN

		_nC6_VALDESC	:= 0
		_nC6_YPERC 		:= 0
		_nC6_YDESC 		:= 0
		_nC6_DESCONT 	:= 0
		_nC6_PRUNIT 	:= (_nPrecoVen * 0.8) //80% do valor
		_nC6_YPRCTAB	:= _nPrecoVen
		_nC6_PRCVEN 	:= (_nPrecoVen * 0.8) //80% do valor
		_nC6_VALOR 		:= Round(_nC6_PRCVEN * (_cAliasPed)->C6_QTDVEN ,2)


	EndIf

	(_cAliasTmp)->(DbCloseArea())

	aRet := {_nC6_PRCVEN,_nC6_VALOR,_nC6_PRUNIT,_nC6_YPERC,_nC6_YDESC,_nC6_VALDESC,_nC6_DESCONT,_nC6_YPRCTAB, _nC6_YFATMUL, _nC6_YFATRED}

Return( aRet )
