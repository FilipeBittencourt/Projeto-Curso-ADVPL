#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TIT_MSG "REPLICAÇÃO DE PEDIDO BASE PARA RODAPE VITCER"

/*/{Protheus.doc} BFATRT01
@description Replicacao de Pedido da Base Rodape VITCER
@author Fernando Rocha
@since 13/07/2016
@version undefined
@param cPedido, characters, descricao
@param lAuto, logical, descricao
@param lJob, logical, descricao
@type function
/*/
User Function BFATRT01(cPedido, lAuto, lJob)

	Local aArea
	Local aRet
	Local cTxtPedErro := ""
	Local cTxtErro := ""
	Local cEmpDest := ""
	Local cEmpOri
	Local cFilOri
	Local bProcessa      
	Local _cRepAtu
	Local _cUserName

	Default cPedido := ""
	Default lAuto := .T.
	Default lJob := .T.

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

			If Empty(SC5->C5_YPEDBAS)  //Pedido ja replicado

				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+cPedido))

					ZA6->(DbSetOrder(2))
					If ZA6->(DbSeek(XFilial("ZA6")+SC6->C6_PRODUTO))  //Posiciona produto rodape

						SB1->(DbSetOrder(1))
						IF SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO)) .And. !Empty(SB1->B1_YEMPEST)
							cEmpDest := SB1->B1_YEMPEST
						EndIf

					EndIf

				EndIf

				If !Empty(cEmpDest)

					//Execucao via JOB em outra empresa do EXECAUTO da replicacao do pedido LM
					bProcessa := {|| aRet := U_FROPCPRO(SubStr(cEmpDest,1,2),SubStr(cEmpDest,3,2),"U_BFVCXPED", cPedido, cEmpDest, _cRepAtu, _cUserName)  }

					If !lJob 
						U_BIAMsgRun("Aguarde... Criando pedido BASE na EMPRESA: "+cEmpDest,,bProcessa) 
					Else                                                                            
						eval(bProcessa)
					EndIf				

					If !lJob 
						If !aRet[1]   
							U_FROPMSG(TIT_MSG, 	"Informe ao setor Comercial/TI erro com a cópia do pedido para a empresa de fabricação: "+cEmpDest+CRLF+CRLF+aRet[2],,,"ERRO na replicação do Pedido: "+cPedido)
						Else
							U_FROPMSG(TIT_MSG, 	"Finalizado com Sucesso, incluido PEDIDO: "+aRet[3]+" na empresa: "+SubStr(cEmpDest,1,2),,,"CRIAR PEDIDO BASE VITCER - "+cPedido)
						EndIf 
					Else
						If !aRet[1]   
							ConOut("FUNCAO: "+AllTrim(FunName())+" - "+"ERRO na inclusão do Pedido: "+cPedido+" Informe ao setor Comercial/TI erro com a cópia do pedido para a empresa de fabricação: "+cEmpDest+CRLF+CRLF+aRet[2])
						Else
							ConOut("FUNCAO: "+AllTrim(FunName())+" - "+"REPLICAR PEDIDO BASE VITCER - "+cPedido+" Finalizado com Sucesso, incluido PEDIDO: "+aRet[3]+" na empresa: "+SubStr(cEmpDest,1,2))
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
User Function BFVCXPED(cPedido, cEmpDest, _cRepAtu, _cUserName)

	Local aCabPV := {}
	Local aItemPV:= {}
	Local cItem
	Local I
	Local cAliasTmp   
	Local cAliasAux
	Local _cLogTxt := ""

	Local cNumPed
	Local _cCondPag	:= AllTrim(GetNewPar("FA_PBASROD","056"))
	Local _cTipoPD	:= IIF(CEMPANT=="13","IM","N")  
	Local _cLin		:= ""
	Local _cTESX	:= ""
	Local _cCFX		:= ""
	Local _cCLASFX	:= ""
	Local aRetPrc      
	Local cPrcMundi 
	Local _cDIGP
	Local _cProduto
	Local _nQuant

	Local aSQLFields := ""
	Local aSC5Exc := {}
	Local aSC6Exc := {}
	Local aAux := {} 

	Local _cTabPar := ""

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	Default _cUserName := "RPC"

	/*TESTES*/
	//Default cPedido := "017416"
	//Default cEmpDest := "0101"
	//Default _cRepAtu := ""
	/*TESTES*/


	ConOut("FUNCAO: "+AllTrim(FunName())+" - CRIANDO PEDIDO BASE PARA PEDIDO VITCER - "+cPedido+": Preparando...")

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
	,OBSMEMO = ISNULL(cast(convert(varbinary(5000),C5_YOBS) as varchar(5000)),'')
	FROM SC5140 SC5
	JOIN SC6140 SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM
	WHERE
	SC5.C5_FILIAL = '01'
	AND SC5.C5_NUM = %EXP:cPedido%
	AND SC5.D_E_L_E_T_ = ' '
	AND SC6.D_E_L_E_T_ = ' '
	ORDER BY C5_NUM, C6_ITEM

	EndSql
	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(Eof())
		ConOut("CRIANDO PEDIDO BASE VITCER - "+cPedido+": Pedido Ok.")
	Else
		_cLogTxt := "CRIANDO PEDIDO BASE VITCER - "+cPedido+": Pedido NÃO ENCONTRADO!"
		ConOut(_cLogTxt)
		return({.F.,_cLogTxt})
	EndIf

	//Validacao de pedido ja replicado
	If !Empty((cAliasTmp)->C5_YPEDBAS)
		_cLogTxt := "CRIANDO PEDIDO BASE VITCER - "+cPedido+": Pedido já foi criado para empresa: "+AllTrim((cAliasTmp)->C5_YEORIBS)+" - com o número: "+AllTrim((cAliasTmp)->C5_YPEDBAS)+""
		ConOut(_cLogTxt)
		return({.F.,_cLogTxt})
	EndIf


	//Cabecalho

	//Numero do novo pedido
	If ( !Empty(_cRepAtu) .Or. AllTrim((cAliasTmp)->C5_YDIGP) == AllTrim((cAliasTmp)->C5_VEND1) ).And. (CEMPANT <> "13")//mundi tem uma mesma sequencia de pedido
		cNumPed := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_REP")
	Else
		cNumPed := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_INT")
	EndIf

	//Linha
	If (cAliasTmp)->C5_YEMPPED == "05"
		_cLin := "2"
	Else
		_cLin := "1"
	EndIf 

	//salvando variaveis do cabecalho
	_cDIGP := (cAliasTmp)->C5_YDIGP


	//Preenchimento dos Campos Padroes - Cabecalho
	aCabPV:={}
	aAdd(aCabPV,  {"C5_NUM"   		,cNumPed   					,Nil}) // Numero do pedido
	aAdd(aCabPV,  {"C5_TIPO"   		,(cAliasTmp)->C5_TIPO   	,Nil}) // Tipo do pedido
	aAdd(aCabPV,  {"C5_YLINHA"  	,_cLin					   	,Nil})
	aAdd(aCabPV,  {"C5_CLIENTE"   	,"008615"  					,Nil})
	aAdd(aCabPV,  {"C5_LOJACLI"   	,"01" 	 					,Nil})
	aAdd(aCabPV,  {"C5_TIPOCLI"		,"R"	  					,Nil})
	aAdd(aCabPV,  {"C5_CLIENT"   	,"008615"  					,Nil})
	aAdd(aCabPV,  {"C5_LOJAENT"		,"01"	  					,Nil})
	aAdd(aCabPV,  {"C5_YSUBTP"		,_cTipoPD					,Nil})  //Falta Validar
	aAdd(aCabPV,  {"C5_TRANSP"		,""							,Nil})
	aAdd(aCabPV,  {"C5_CONDPAG"		, _cCondPag					,Nil})
	aAdd(aCabPV,  {"C5_VEND1"		,"999999"					,Nil})
	aAdd(aCabPV,  {"C5_COMIS1"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS2"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS3"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS4"		,0							,Nil})
	aAdd(aCabPV,  {"C5_COMIS5"		,0							,Nil})
	aAdd(aCabPV,  {"C5_TPFRETE"		,"S"						,Nil})
	aAdd(aCabPV,  {"C5_EMISSAO"		,dDataBase					,Nil})

	//Preenchimento dos Campos Customizados - Cabecalho
	aAdd(aCabPV,  {"C5_YEMP"		,cEmpDest			 					,Nil})
	aAdd(aCabPV,  {"C5_YEMPPED"		,SubStr(cEmpDest,1,2)					,Nil})
	aAdd(aCabPV,  {"C5_YCLIORI"		,(cAliasTmp)->C5_CLIENTE				,Nil})
	aAdd(aCabPV,  {"C5_YLOJORI"		,(cAliasTmp)->C5_LOJACLI				,Nil})
	aAdd(aCabPV,  {"C5_YFORMA"		,"3"									,Nil})
	aAdd(aCabPV,  {"C5_YDIGP"		,(cAliasTmp)->C5_YDIGP					,Nil})
	aAdd(aCabPV,  {"C5_YPC"			,(cAliasTmp)->C5_YPC					,Nil})
	aAdd(aCabPV,  {"C5_YHORA"		,(cAliasTmp)->C5_YHORA					,Nil})
	aAdd(aCabPV,  {"C5_YOBS"		,(cAliasTmp)->OBSMEMO					,Nil})
	aAdd(aCabPV,  {"C5_YPEDBAS"		,cPedido								,Nil})//numero do pedido filho na Origem

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

		//Busca do Produto BASE
		_cProduto := ""
		ZA6->(DbSetOrder(2))
		If ZA6->(DbSeek(XFilial("ZA6")+(cAliasTmp)->C6_PRODUTO))
			_cProduto := ZA6->ZA6_BASE		
			_nQuant	:= ((cAliasTmp)->C6_QTDVEN / ZA6->ZA6_CONV)		
		EndIf

		If Empty(_cProduto)
			_cLogTxt := "Não foi possível determinar o Produto BASE para criacao deste pedido na empresa de origem!"
			ConOut(_cLogTxt)
			return({.F.,_cLogTxt})
		EndIf

		//Posicionar Produto Base
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFilial("SB1")+_cProduto))

		//Ajustar qtde de caixa fechada do produto base - a conversão de rodape em caixa pode não ser exata
		nMod := ( _nQuant % SB1->B1_CONV )
		_nQuant :=  ( int( _nQuant / SB1->B1_CONV ) * SB1->B1_CONV ) + IIf( nMod > 0, SB1->B1_CONV, 0 )


		//Regras especiais

		//TES de venda da origem para VITCER - se nao parametrizada busca da TES inteligente
		If Empty(_cTESX)

			cAliasAux := GetNextAlias()
			BeginSql Alias cAliasAux
			%NOPARSER%

			SELECT FM_TS FROM %TABLE:SFM% A WHERE 
			FM_GRTRIB = (SELECT A1_GRPTRIB FROM SA1010 WHERE A1_COD = '008615' AND D_E_L_E_T_='') 
			AND FM_TIPO = %EXP:IIF(CEMPANT=="13","IM","N")%
			AND (FM_GRPROD = (SELECT B1_GRTRIB FROM SB1010 B WHERE B1_COD = %EXP:_cProduto% AND B.D_E_L_E_T_='') OR FM_GRPROD = '') 
			AND A.D_E_L_E_T_=''

			EndSql
			(cAliasAux)->(DbGoTop())
			If !(cAliasAux)->(Eof())
				_cTESX := (cAliasAux)->FM_TS
			Else
				_cLogTxt := "Não foi possível determinar a TES para replicação deste pedido para a empresa de origem!"
				ConOut(_cLogTxt)
				(cAliasAux)->(DbCloseArea())
				return({.F.,_cLogTxt})	
			EndIf 
			(cAliasAux)->(DbCloseArea())   

		EndIf   

		//Buscar o CFOP - no automatico nao esta funcionando
		If !Empty(_cTESX) 

			SF4->(DbSetOrder(1))
			SF4->(DbSeek(XFilial("SF4")+_cTESX))

			_cCFX := SF4->F4_CF
			_cCFX := "5"+SubStr(_cCFX,2,3)

			_cCLASFX := "0"+SF4->F4_SITTRIB

		EndIf


		//Tabela de Prexo e calculo
		aRetPrc := CalcBase(cAliasTmp,_cLin, _cTESX, _cProduto, _nQuant, _cTipoPD)
		//aRet := {_nC6_PRCVEN,_nC6_VALOR,_nC6_PRUNIT,_nC6_YPERC,_nC6_YDESC,_nC6_VALDESC,_nC6_DESCONT,_nC6_YPRCTAB,_nC6_YDCAT,_nC6_YDPAL,_nC6_YDPOL}

		aAux := {}
		aAdd(aAux,{"C6_NUM"		,cNumPed						,Nil})
		aAdd(aAux,{"C6_ITEM"	,(cAliasTmp)->C6_ITEM			,Nil}) // Numero do Item no Pedido

		aAdd(aAux,{"C6_PRODUTO"	,_cProduto						,Nil}) 
		aAdd(aAux,{"C6_QTDVEN"	,_nQuant						,Nil})
		aAdd(aAux,{"C6_DESCRI"	,SB1->B1_YREF					,Nil})  //trazendo do rodape!?
		aAdd(aAux,{"C6_UM"		,SB1->B1_UM						,Nil})  //trazendo do rodape!?

		aAdd(aAux,{"C6_PRCVEN"	,aRetPrc[1]				   		,Nil}) 
		aAdd(aAux,{"C6_VALOR"	,aRetPrc[2]			 	   		,Nil})  
		aAdd(aAux,{"C6_PRUNIT"	,aRetPrc[3]			    		,Nil}) 
		aAdd(aAux,{"C6_YPERC"	,aRetPrc[4]			 	   		,Nil}) 
		aAdd(aAux,{"C6_YDESC"	,aRetPrc[5]			 	   		,Nil}) 	
		//aAdd(aAux,{"C6_VALDESC"	,aRetPrc[6]				  		,Nil})   
		//aAdd(aAux,{"C6_DESCONT"	,aRetPrc[7]						,Nil})
		aAdd(aAux,{"C6_YPRCTAB"	,aRetPrc[8]						,Nil})

		aAdd(aAux,{"C6_YDCAT"	,aRetPrc[9]						,Nil})
		aAdd(aAux,{"C6_YDPAL"	,aRetPrc[10]					,Nil})
		aAdd(aAux,{"C6_YDPOL"	,aRetPrc[11]					,Nil})

		aAdd(aAux,{"C6_TES"		,_cTESX					   		,Nil}) 
		aAdd(aAux,{"C6_CLASFIS"	,_cCLASFX				   		,Nil}) 
		aAdd(aAux,{"C6_CF"		,_cCFX					   		,Nil})

		aAdd(aAux,{"C6_LOCAL"	,SB1->B1_LOCPAD					,Nil})

		aAdd(aAux,{"C6_YEMP"	,cEmpDest						,Nil})
		aAdd(aAux,{"C6_YREGRA"	,(cAliasTmp)->C6_YREGRA			,Nil})

		//campos do processo de reserva de lote
		aAdd(aAux,{"C6_YTPEST"	,(cAliasTmp)->C6_YTPEST			,Nil})
		aAdd(aAux,{"C6_YDTNECE"	,(cAliasTmp)->C6_YDTNECE		,Nil})
		aAdd(aAux,{"C6_YDTNERE"	,(cAliasTmp)->C6_YDTNERE		,Nil})
		aAdd(aAux,{"C6_YQTDSUG"	,(cAliasTmp)->C6_YQTDSUG		,Nil})
		aAdd(aAux,{"C6_YLOTSUG"	,(cAliasTmp)->C6_YLOTSUG		,Nil})
		aAdd(aAux,{"C6_YLOTTOT"	,(cAliasTmp)->C6_YLOTTOT		,Nil})
		aAdd(aAux,{"C6_YDTDISP"	,CTOD(" ")						,Nil})

		//Campos do processo de Rodape Vitcer
		aAdd(aAux,{"C6_YEORICH"	,(cAliasTmp)->C6_YEORICH		,Nil})
		aAdd(aAux,{"C6_YPITCHA"	,(cAliasTmp)->C6_YPITCHA		,Nil})
		aAdd(aAux,{"C6_YRAVLOT"	,(cAliasTmp)->C6_YRAVLOT		,Nil})
		aAdd(aAux,{"C6_YLOTBAS"	,(cAliasTmp)->C6_YLOTBAS		,Nil})
		aAdd(aAux,{"C6_YOSBAS"	,(cAliasTmp)->C6_YOSBAS			,Nil})

		//Campos para nao processar
		aSC6Exc := {"C6_TES","C6_CF","C6_CLASFIS","C6_BLOQUEI","C6_BLQ"}

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
		return({.F.,_cLogTxt})
	ENDIF

	//Geracao do Pedido de Venda  
	Begin Transaction

	//Posicionar arquivos do cabecalho
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SA1")+"00861501"))   

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

	ConOut("CRIAR PEDIDO BASE VITCER - "+cPedido+": Iniciando ExecAuto...")
	MsExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,3)

	If lMsErroAuto
		RollBackSX8()
		DisarmTransaction()
				
		//Grava log de erro para consulta posterior
		aAutoErro := GETAUTOGRLOG()
		_cLogTxt += XCONVERRLOG(aAutoErro)
		ConOut("CRIAR PEDIDO BASE VITCER - "+cPedido+": ERRO: "+_cLogTxt)
		MemoWrite("\PEDREPL\PEDVIT_"+AllTrim(cPedido)+".TXT", _cLogTxt)
		return({.F.,_cLogTxt})
	Else
		ConfirmSX8()            

		(cAliasTmp)->(DbGoTop())

		//Gravar campos manualmente no Pedido de venda incluido na empresa origem, para não disparar regras de gatilhos/validacoes que ocorre problema no execauto
		//SC5->(DbSetOrder(1))
		//If SC5->(DbSeek(XFilial("SC5")+cNumPed))
		//	RecLock("SC5",.F.)
		//	SC5->(MsUnlock())
		//EndIf

		//Gravar campos na empresa origem - LM - via update
		//Grava o nome dos Produtos na tabela de Liberacao
		cSql := "UPDATE SC5140 "
		cSql += "	SET C5_YPEDBAS = '"+cNumPed+"' "
		cSql += "	, C5_YEORIBS = '"+AllTrim(CEMPANT)+AllTrim(CFILANT)+"' "
		cSql += "	WHERE "
		cSql += "		C5_FILIAL = '01' "
		cSql += "		AND C5_NUM = '"+cPedido+"' "
		cSql += "		AND D_E_L_E_T_ = ' ' "

		TcSQLExec(cSQL)

		//Tira o bloqueio de LOTE do pedido LM
		cSql := "UPDATE SC6140 "
		cSql += "	SET C6_YMOTFRA = ' ' "
		cSql += "	, C6_YBLQLOT = '00' "
		cSql += "	, C6_MSEXP   = '' "
		cSql += "	WHERE "
		cSql += "		C6_FILIAL = '01' "
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

		//Enviar email do pedido base para atendente
		U_Env_Pedido(cNumPed,.F.,.T.,CEMPANT,.F.,.T.)

	EndIf
	
	End Transaction

	(cAliasTmp)->(DbCloseArea())
	ConOut("CRIAR PEDIDO BASE VITCER - "+cPedido+": Finalizado com Sucesso, incluido PEDIDO: "+cNumPed+" na empresa: "+CEMPANT)
return({.T.,_cLogTxt, cNumPed})

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CONVERTER LOG DE ERRO PARA TEXTO SIMPLES
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
STATIC FUNCTION XCONVERRLOG(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1

	FOR nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+CRLF
	NEXT nX
RETURN cRet


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ROTINAS PARA CALCULO DE PRECOS/DESCONTO PARA PEDIDOS P/ LM
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function CalcBase(_cAliasPed, _cLinha, _cTes, _cProduto, _nQuant, _cTipoPD)   
	Local aRet := Array(8) 

	Local _nC6_PRCVEN 	:= (_cAliasPed)->C6_PRCVEN   	
	Local _nC6_VALOR 	:= (_cAliasPed)->C6_VALOR		 
	Local _nC6_PRUNIT 	:= (_cAliasPed)->C6_PRUNIT	 
	Local _nC6_YPERC	:= (_cAliasPed)->C6_YPERC	 
	Local _nC6_YDESC	:= (_cAliasPed)->C6_YDESC	
	Local _nC6_VALDESC	:= (_cAliasPed)->C6_VALDESC	
	Local _nC6_DESCONT	:= (_cAliasPed)->C6_DESCONT		 
	Local _nC6_YPRCTAB  := (_cAliasPed)->C6_YPRCTAB
	Local _nC6_YDCAT	:= 0 
	Local _nC6_YDPAL	:= 0
	Local _nC6_YDPOL	:= 0

	Local _aCampos := {"IT_ALIQICM","IT_ALIQCMP","IT_ALFCCMP","IT_ALIQPIS","IT_ALIQCOF"}

	Local _cTabela := ""
	Local nPreco

	If _cLinha == "1"			//BIANCOGRES
		_cTabela := Tabela("ZF","1E")
	ElseIf _cLinha == "2"		//INCESA
		_cTabela := Tabela("ZF","2E")
	ElseIf _cLinha == "3"		//BELLACASA
		_cTabela := Tabela("ZF","3E")
	ElseIf _cLinha == "4"		//MUNDI
		_cTabela := Tabela("ZF","4E")
	EndIf

	If !Empty(_cTabela)

		_aImp	:= U_fGetImp(_aCampos, "008615", "01", _cProduto, _cTes, 0, 0, 0)

		nPreco	:= U_fBuscaPreco(_cLinha,_cTabela,_cProduto,(_cAliasPed)->C5_EMISSAO,"008615","01",_cTipoPD,_aImp[1],_aImp[2],_aImp[3],_cTes) //os 4 tres ultimos parametros é para buscar uma regra especifica na tabela Fator Mult (Z65)


		//Politica de Desconto para VITCER
		oDesconto := TBiaPoliticaDesconto():New() 

		oDesconto:_cCliente 	:= "00861501"
		oDesconto:_cVendedor 	:= "999999"
		oDesconto:_cProduto 	:= _cProduto
		oDesconto:DESP			:= 0
		oDesconto:_lPaletizado	:= .T.
		oDesconto:_nPICMS 		:= _aImp[1]
		oDesconto:_nPPIS		:= _aImp[4]
		oDesconto:_nPCOF		:= _aImp[5]
		oDesconto:_nAComis		:= 0

		If oDesconto:GetPolitica()

			_nC6_YDESC := oDesconto:DTOT

			_nC6_YDCAT := oDesconto:DCAT
			_nC6_YDPAL := oDesconto:DPAL 
			_nC6_YDPOL := oDesconto:DPOL

		EndIf

		_nC6_YPERC 		:= _nC6_YDPOL       
		_nC6_DESCONT 	:= 0 
		_nC6_PRUNIT 	:= Round(nPreco,2) 
		_nC6_YPRCTAB	:= Round(nPreco,2) 

		//valor do desconto
		_nC6_VALDESC	:= (nPreco * (_nC6_YDESC / 100))

		//Aplicar o desconto
		_nC6_PRCVEN := nPreco - (nPreco * (_nC6_YDESC / 100))

		_nC6_VALOR 		:= Round(_nC6_PRCVEN * _nQuant ,2)

	EndIf

	aRet := {_nC6_PRCVEN,_nC6_VALOR,_nC6_PRUNIT,_nC6_YPERC,_nC6_YDESC,_nC6_VALDESC,_nC6_DESCONT,_nC6_YPRCTAB,_nC6_YDCAT,_nC6_YDPAL,_nC6_YDPOL}

Return( aRet )