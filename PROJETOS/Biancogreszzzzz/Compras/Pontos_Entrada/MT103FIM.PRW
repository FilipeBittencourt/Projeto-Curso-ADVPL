#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT103FIM
@description O ponto de entrada MT103FIM encontra-se no final da função A103NFISCAL
@author Carlos Junqueira
@since 16/10/2014
@version undefined
@type function
/*/
User Function MT103FIM()

	//-----------------------------------------------------------------------------------------------------------------------
	// Rotina : O ponto de entrada MT103FIM encontra-se no final da função A103NFISCAL.
	// 			Após o destravamento de todas as tabelas envolvidas na gravação do documento de entrada,
	//			depois de fechar a operação realizada neste, é utilizado para realizar alguma operação após a gravação da NFE.
	//-----------------------------------------------------------------------------------------------------------------------
	// Desenv 	: Carlos Junqueira
	// Data		: 16/10/2014
	//-----------------------------------------------------------------------------------------------------------------------

	Local nOpcao := paramixb[1] // se 4 - classificando NF
	Local lwConf := PARAMIXB[2] // Por Marcos Alberto Soprani em 22/12/15
	Local oObjCompen := TCompensacaoReceber():New()
	
	If !FwIsInCallStack('U_GATI001') .Or. (FwIsInCallStack('U_GATI001') .And. !l103Auto) .And. PARAMIXB[2] <> 0
		//Tratamento para Totvs Colaboracao 2.0
		If GetMv("MV_COMCOL1") <> 2 .And. Upper(Alltrim(FUNNAME())) == "SCHEDCOMCOL"  
			Return
		EndIf

		oObjCompen:Devolucao()

		If lwConf <> 0

			If nOpcao == 4 .and. Upper(Alltrim(FunName())) $ "MATA103/COMXCOL" .and. Alltrim(cEmpAnt) <> "07"

				If Alltrim(SF1->F1_ESPECIE) $ "NF/NFE/SPED"

					//If MsgNOYES("Deseja abrir a tela para inclusão de conhecimento de Frete?", "MT103FIM")

					if MsgBox ("Deseja abrir a tela para inclusão de conhecimento de Frete?","MT103FIM","YESNO")

						cFuncaoAux := FunName()
						auxEspNF := SF1->F1_ESPECIE
						auxRegF1 := SF1->(Recno())
						SetFunName("MATA116")
						MaFisAlt("NF_ESPECIE","CTR")
						MaFisAlt("NF_TPCOMP","F")
						MATA116()
						SetFunName(cFuncaoAux)
						SF1->(dbGoTo(auxRegF1))
						l103Class := .F.
						MaFisAlt("NF_ESPECIE", auxEspNF)

					EndIf

				EndIf

			EndIf

			//Fernando Rocha - Projeto portaria fiscal - executando via execaurto a classificacao
			If !isInCallStack("U_TACLNFJB") .and. !IsInCallStack("U_BACP0012") .and. !IsInCallStack("U_PNFM0002") .And. !IsInCallStack("U_PNFM0005") .And. !IsInCallStack("U_JOBFATPARTE")
				U_BIAF015(ParamIxb[1], ParamIxb[2])
				If (SF1->F1_TIPO == "N") .And. (lwConf == 1) .And. (nOpcao >= 3 .And. nOpcao <= 4)
					Reclock("SF1",.F.)
					SF1->F1_YNUMRPV	:=	c_cNumRpv
					SF1->(MsUnlock())
				EndIf
			EndIf

			U_BIAF116(ParamIxb[1], ParamIxb[2])

		EndIf


		//Fernando/Facile em 03/03/2017 - Inclusao de Baixa de AI no caso de devolucao de NF que teve desconto de AI informado
		If SC6->(FieldPos("C6_YDACO")) > 0 .And. lwConf <> 0 .And. ( nOpcao == 4 .Or. nOpcao == 3 )

			__cAliasTmp := GetNextAlias()
			BeginSql Alias __cAliasTmp
				%NoParser%

				with tab_a as (

				select

				C5_YNUMSI
				,C5_YLINHA
				,FATORDEV = Sum(D1_QUANT) /
				(isnull((select SUM(round(C6_QTDVEN,2)) from %Table:SC6% X where X.C6_FILIAL = SC5.C5_FILIAL and X.C6_NUM = SC5.C5_NUM and X.C6_BLQ <> 'R' and X.D_E_L_E_T_=''),0)+
				isnull((select SUM(round(C6_QTDENT,2)) from %Table:SC6% X where X.C6_FILIAL = SC5.C5_FILIAL and X.C6_NUM = SC5.C5_NUM and X.C6_BLQ = 'R' and X.D_E_L_E_T_=''),0))

				,VALOR = sum(isnull(ZZQ1.ZZQ_VALOR,isnull(ZZQ5.ZZQ_VALOR,0)))

				FROM %Table:SD1% SD1 (nolock)
				JOIN %Table:SF2% SF2 (nolock) on F2_FILIAL = D1_FILIAL and F2_DOC = D1_NFORI and F2_SERIE = D1_SERIORI and F2_CLIENTE = D1_FORNECE and F2_LOJA = D1_LOJA and SF2.D_E_L_E_T_=''
				JOIN %Table:SD2% SD2 (nolock) on D2_FILIAL = F2_FILIAL and D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC6% SC6 (nolock) on C6_FILIAL = D2_FILIAL and C6_NUM = D2_PEDIDO and C6_ITEM = D2_ITEMPV and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC5% SC5 (nolock) on C5_FILIAL = C6_FILIAL and C5_NUM = C6_NUM and SC5.D_E_L_E_T_=''
				JOIN %Table:SA1% SA1 (nolock) ON A1_FILIAL = '  ' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ =''
				JOIN %Table:SB1% SB1 (nolock) ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ =''
				LEFT JOIN ZZQ010 ZZQ1 (nolock) on ZZQ1.ZZQ_FILIAL = C5_FILIAL and SUBSTRING(ZZQ1.ZZQ_DOC,4,6) = C5_NUM AND ZZQ1.ZZQ_COD = C5_YNUMSI and ZZQ1.D_E_L_E_T_=''
				LEFT JOIN ZZQ050 ZZQ5 (nolock) on ZZQ5.ZZQ_FILIAL = C5_FILIAL and SUBSTRING(ZZQ5.ZZQ_DOC,4,6) = C5_NUM AND ZZQ5.ZZQ_COD = C5_YNUMSI and ZZQ5.D_E_L_E_T_=''

				where
				D1_FILIAL = %Exp:SF1->F1_FILIAL%
				and D1_DOC = %Exp:SF1->F1_DOC%
				and D1_SERIE = %Exp:SF1->F1_SERIE%
				and D1_FORNECE = %Exp:SF1->F1_FORNECE%
				and D1_LOJA = %Exp:SF1->F1_LOJA%
				and C5_YNUMSI <> ''
				and SD1.D_E_L_E_T_=''

				group by C5_YNUMSI, C5_YLINHA, C5_FILIAL, C5_NUM

				)

				select
				C5_YNUMSI,
				C5_YLINHA,
				VALOR = sum(VALOR * FATORDEV)
				from tab_a
				GROUP BY C5_YNUMSI, C5_YLINHA

			EndSql

			If !(__cAliasTmp)->(Eof()) .And. (__cAliasTmp)->VALOR > 0


				If AllTrim(CEMPANT) <> "07"

					lRet := U_AO_IBX_E(SF1->F1_DOC,(__cAliasTmp)->C5_YNUMSI,-(__cAliasTmp)->VALOR,,"Dev.Aut.NF com Desc.AI")

				Else

					If AllTrim((__cAliasTmp)->C5_YLINHA) $ "2#3" 
						nLinhaEmp := "0501"
					Else                   
						nLinhaEmp := "0101"
					EndIf

					lRet := U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_AO_IBX_E", SF1->F1_DOC,(__cAliasTmp)->C5_YNUMSI,-(__cAliasTmp)->VALOR, AllTrim(CEMPANT)+AllTrim(CFILANT),"Dev.Aut.NF com Desc.AI")

				EndIf

			EndIf
			(__cAliasTmp)->(DbCloseArea())

		EndIf

		//Fernando/Facile em 12/04/2017 - Inclusao de Baixa de outras AI no caso de devolucao de NF - quase igual ao bloco acima considerando o campo C5_YNOUTAI
		If SC6->(FieldPos("C6_YDAI")) > 0 .And. lwConf <> 0 .And. ( nOpcao == 4 .Or. nOpcao == 3 )

			__cAliasTmp := GetNextAlias()
			BeginSql Alias __cAliasTmp
				%NoParser%

				with tab_a as (

				select

				C5_YNOUTAI
				,C5_YLINHA
				,FATORDEV = Sum(D1_QUANT) /
				(isnull((select SUM(round(C6_QTDVEN,2)) from %Table:SC6% X where X.C6_FILIAL = SC5.C5_FILIAL and X.C6_NUM = SC5.C5_NUM and X.C6_BLQ <> 'R' and X.D_E_L_E_T_=''),0)+
				isnull((select SUM(round(C6_QTDENT,2)) from %Table:SC6% X where X.C6_FILIAL = SC5.C5_FILIAL and X.C6_NUM = SC5.C5_NUM and X.C6_BLQ = 'R' and X.D_E_L_E_T_=''),0))

				,VALOR = sum(isnull(ZZQ1.ZZQ_VALOR,isnull(ZZQ5.ZZQ_VALOR,0)))

				FROM %Table:SD1% SD1 (nolock)
				JOIN %Table:SF2% SF2 (nolock) on F2_FILIAL = D1_FILIAL and F2_DOC = D1_NFORI and F2_SERIE = D1_SERIORI and F2_CLIENTE = D1_FORNECE and F2_LOJA = D1_LOJA and SF2.D_E_L_E_T_=''
				JOIN %Table:SD2% SD2 (nolock) on D2_FILIAL = F2_FILIAL and D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC6% SC6 (nolock) on C6_FILIAL = D2_FILIAL and C6_NUM = D2_PEDIDO and C6_ITEM = D2_ITEMPV and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC5% SC5 (nolock) on C5_FILIAL = C6_FILIAL and C5_NUM = C6_NUM and SC5.D_E_L_E_T_=''
				JOIN %Table:SA1% SA1 (nolock) ON A1_FILIAL = '  ' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ =''
				JOIN %Table:SB1% SB1 (nolock) ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ =''
				LEFT JOIN ZZQ010 ZZQ1 (nolock) on ZZQ1.ZZQ_FILIAL = C5_FILIAL and SUBSTRING(ZZQ1.ZZQ_DOC,4,6) = C5_NUM AND ZZQ1.ZZQ_COD = C5_YNOUTAI and ZZQ1.D_E_L_E_T_=''
				LEFT JOIN ZZQ050 ZZQ5 (nolock) on ZZQ5.ZZQ_FILIAL = C5_FILIAL and SUBSTRING(ZZQ5.ZZQ_DOC,4,6) = C5_NUM AND ZZQ5.ZZQ_COD = C5_YNOUTAI and ZZQ5.D_E_L_E_T_=''

				where
				D1_FILIAL = %Exp:SF1->F1_FILIAL%
				and D1_DOC = %Exp:SF1->F1_DOC%
				and D1_SERIE = %Exp:SF1->F1_SERIE%
				and D1_FORNECE = %Exp:SF1->F1_FORNECE%
				and D1_LOJA = %Exp:SF1->F1_LOJA%
				and C5_YNOUTAI <> ''
				and SD1.D_E_L_E_T_=''

				group by C5_YNOUTAI, C5_YLINHA, C5_FILIAL, C5_NUM

				)

				select
				C5_YNOUTAI,
				C5_YLINHA,
				VALOR = SUM(VALOR * FATORDEV)
				from tab_a
				GROUP BY C5_YNOUTAI, C5_YLINHA	

			EndSql

			If !(__cAliasTmp)->(Eof()) .And. (__cAliasTmp)->VALOR > 0


				If AllTrim(CEMPANT) <> "07"

					lRet := U_AO_IBX_E(SF1->F1_DOC,(__cAliasTmp)->C5_YNOUTAI,-(__cAliasTmp)->VALOR,,"Dev.Aut.NF com Desc.AI")

				Else

					If AllTrim((__cAliasTmp)->C5_YLINHA) $ "2#3" 
						nLinhaEmp := "0501"
					Else                   
						nLinhaEmp := "0101"
					EndIf

					lRet := U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_AO_IBX_E", SF1->F1_DOC,(__cAliasTmp)->C5_YNOUTAI,-(__cAliasTmp)->VALOR, AllTrim(CEMPANT)+AllTrim(CFILANT),"Dev.Aut.NF com Desc.AI")

				EndIf

			EndIf
			(__cAliasTmp)->(DbCloseArea())

		EndIf

		//Fernando/Facile em 20/04/2017 - Inclusao de Baixa de outras AI no caso de devolucao de NF - Exclusao da NF de devolucao
		If SC6->(FieldPos("C6_YDAI")) > 0 .And. lwConf <> 0 .And. nOpcao == 5

			//BAIXA DE AI DE ACORDO
			__cAliasTmp := GetNextAlias()
			BeginSql Alias __cAliasTmp
				%NoParser%

				select
				distinct

				C5_YNUMSI
				,C5_YLINHA
				,D1_DOC

				FROM %Table:SD1% SD1 (nolock)
				JOIN %Table:SF2% SF2 (nolock) on F2_FILIAL = D1_FILIAL and F2_DOC = D1_NFORI and F2_SERIE = D1_SERIORI and F2_CLIENTE = D1_FORNECE and F2_LOJA = D1_LOJA and SF2.D_E_L_E_T_=''
				JOIN %Table:SD2% SD2 (nolock) on D2_FILIAL = F2_FILIAL and D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC6% SC6 (nolock) on C6_FILIAL = D2_FILIAL and C6_NUM = D2_PEDIDO and C6_ITEM = D2_ITEMPV and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC5% SC5 (nolock) on C5_FILIAL = C6_FILIAL and C5_NUM = C6_NUM and SC5.D_E_L_E_T_=''
				LEFT JOIN ZZQ010 ZZQ1 (nolock) on ZZQ1.ZZQ_FILIAL = C5_FILIAL and ZZQ1.ZZQ_DOC = D1_DOC AND ZZQ1.ZZQ_COD = C5_YNUMSI and ZZQ1.D_E_L_E_T_=''
				LEFT JOIN ZZQ050 ZZQ5 (nolock) on ZZQ5.ZZQ_FILIAL = C5_FILIAL and ZZQ5.ZZQ_DOC = D1_DOC AND ZZQ5.ZZQ_COD = C5_YNUMSI and ZZQ5.D_E_L_E_T_=''

				where
				D1_FILIAL = %Exp:SF1->F1_FILIAL%
				and D1_DOC = %Exp:SF1->F1_DOC%
				and D1_SERIE = %Exp:SF1->F1_SERIE%
				and D1_FORNECE = %Exp:SF1->F1_FORNECE%
				and D1_LOJA = %Exp:SF1->F1_LOJA%
				and C5_YNUMSI <> ''
				and SD1.D_E_L_E_T_='*'

			EndSql

			If !(__cAliasTmp)->(Eof())

				__cTabZZQ := "ZZQ"+AllTrim(cEmpAnt)+"0"
				If AllTrim(cEmpAnt) == "07"
					If ((__cAliasTmp)->C5_YLINHA == "1")
						__cTabZZQ := "ZZQ010"
					Else
						__cTabZZQ := "ZZQ050"
					EndIf
				EndIf

				__cSql := " update "+__cTabZZQ+" set D_E_L_E_T_ = '*' where ZZQ_COD = '"+(__cAliasTmp)->C5_YNUMSI+"' and ZZQ_FORNEC = '"+AllTrim(cEmpAnt)+AllTrim(cFilAnt)+"' and ZZQ_DOC = '"+(__cAliasTmp)->D1_DOC+"' and D_E_L_E_T_='' " 
				TCSQLExec(__cSql)

			EndIf
			(__cAliasTmp)->(DbCloseArea())


			//BAIXA DE OUTRAS AI
			__cAliasTmp := GetNextAlias()
			BeginSql Alias __cAliasTmp
				%NoParser%

				select
				distinct

				C5_YNOUTAI
				,C5_YLINHA
				,D1_DOC

				FROM %Table:SD1% SD1 (nolock)
				JOIN %Table:SF2% SF2 (nolock) on F2_FILIAL = D1_FILIAL and F2_DOC = D1_NFORI and F2_SERIE = D1_SERIORI and F2_CLIENTE = D1_FORNECE and F2_LOJA = D1_LOJA and SF2.D_E_L_E_T_=''
				JOIN %Table:SD2% SD2 (nolock) on D2_FILIAL = F2_FILIAL and D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC6% SC6 (nolock) on C6_FILIAL = D2_FILIAL and C6_NUM = D2_PEDIDO and C6_ITEM = D2_ITEMPV and D2_ITEM = D1_ITEMORI and SD2.D_E_L_E_T_=''
				JOIN %Table:SC5% SC5 (nolock) on C5_FILIAL = C6_FILIAL and C5_NUM = C6_NUM and SC5.D_E_L_E_T_=''
				LEFT JOIN ZZQ010 ZZQ1 (nolock) on ZZQ1.ZZQ_FILIAL = C5_FILIAL and ZZQ1.ZZQ_DOC = D1_DOC AND ZZQ1.ZZQ_COD = C5_YNOUTAI and ZZQ1.D_E_L_E_T_=''
				LEFT JOIN ZZQ050 ZZQ5 (nolock) on ZZQ5.ZZQ_FILIAL = C5_FILIAL and ZZQ5.ZZQ_DOC = D1_DOC AND ZZQ5.ZZQ_COD = C5_YNOUTAI and ZZQ5.D_E_L_E_T_=''

				where
				D1_FILIAL = %Exp:SF1->F1_FILIAL%
				and D1_DOC = %Exp:SF1->F1_DOC%
				and D1_SERIE = %Exp:SF1->F1_SERIE%
				and D1_FORNECE = %Exp:SF1->F1_FORNECE%
				and D1_LOJA = %Exp:SF1->F1_LOJA%
				and C5_YNOUTAI <> ''
				and SD1.D_E_L_E_T_='*'

			EndSql

			If !(__cAliasTmp)->(Eof())

				__cTabZZQ := "ZZQ"+AllTrim(cEmpAnt)+"0"
				If AllTrim(cEmpAnt) == "07"
					If ((__cAliasTmp)->C5_YLINHA == "1")
						__cTabZZQ := "ZZQ010"
					Else
						__cTabZZQ := "ZZQ050"
					EndIf
				EndIf

				__cSql := " update "+__cTabZZQ+" set D_E_L_E_T_ = '*' where ZZQ_COD = '"+(__cAliasTmp)->C5_YNOUTAI+"' and ZZQ_FORNEC = '"+AllTrim(cEmpAnt)+AllTrim(cFilAnt)+"' and ZZQ_DOC = '"+(__cAliasTmp)->D1_DOC+"' and D_E_L_E_T_='' " 
				TCSQLExec(__cSql)

			EndIf
			(__cAliasTmp)->(DbCloseArea())


		EndIf

		//Gabriel/Facile em 17/07/2017 - Inclusão de OP quando for Intra Grupo - INCESA
		If GetNewPar("MV_YFATGRP",.F.) .And. cA100For == "000534"  .And.  cEmpAnt == "05" .And. lwConf <> 0 .And. ( nOpcao == 4 .Or. nOpcao == 3 )
			fIntraOP()
		EndIf

		If ( nOpcao == 4 .Or. nOpcao == 3 ) .And.  SF1->F1_TIPO == "N"
			fApOPPR()
		EndIf	

		//Fernando em 29/06/2018 => Ticket 5309 => Envio de email para confirmação do servico realizado
		//IF SF1->(FieldPos("F1_YSERAPR")) > 0 .And. nOpcao == 3 .And. Empty(SF1->F1_STATUS)
		//	//NF de Serviços
		//	SD1->(DbSetOrder(1))
		//	If SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))) .And. SubStr(SD1->D1_COD,1,3) == "306"
		//
		//		U_FPFCRT02(SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)
		//
		//	EndIf	
		//ENDIF
	EndIf

	U_GTPE002()
	
Return()

Static Function fIntraOP(lwConf,nOpcao)

	Local _nPosOp		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_OP"})
	Local _nPosProd		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"})
	Local _nPosQtd		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT"})
	Local _nPosLoc		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_LOCAL"})
	Local _nI
	Local _cProdPP		
	Local _cAlias
	Local _aProd		:=	{}	
	Local _cErro		:=	""

	For _nI	:=	1 to Len(aCols)

		If !aCols[_nI,Len(aHeader)+1] .And.; 
		!Empty(aCols[_nI,_nPosOp]) .And. ;
		Posicione("SB1",1,xFilial("SB1")+aCols[_nI,_nPosProd],"B1_TIPO") == "PP"   

			_cAlias	:=	GetNextAlias()

			_cProdPP	:=	Substr(aCols[_nI,_nPosProd],1,7) + '%'

			//A Tabela e filial são fixas pois sempre será procurada a nota fiscal de saída da Empresa Biancogres(Sufixo 010) e Filial 01 
			BeginSql Alias _cAlias
				SELECT D2_COD, D2_LOTECTL
				FROM SD2010 SD2
				WHERE SD2.D2_FILIAL = '01'
				AND SD2.D2_DOC = %Exp:SF1->F1_DOC%
				AND SD2.D2_SERIE = %Exp:SF1->F1_SERIE%
				AND SD2.D2_COD LIKE %Exp:_cProdPP%
				AND SD2.D2_QUANT = %Exp:aCols[_nI,_nPosQtd]%
				AND SD2.%NotDel%
			EndSql
			If (_cAlias)->(!EOF())
				_aProd := { {     "D3_TM"       , "010"                                                                           ,NIL},;
				{                 "D3_OP"       , aCols[_nI,_nPosOp]                                                              ,NIL},;
				{                 "D3_LOTECTL"  , (_cAlias)->D2_LOTECTL                                                           ,NIL},;
				{                 "D3_QUANT"    , aCols[_nI,_nPosQtd]                                                             ,NIL},;
				{                 "D3_DOC"   	, SF1->F1_DOC 			                                                          ,NIL},;
				{                 "D3_EMISSAO"  , SF1->F1_DTDIGIT                                                                 ,NIL},;
				{                 "D3_LOCAL"    , aCols[_nI,_nPosLoc]                                                             ,NIL},;
				{                 "D3_UM"       , POSICIONE("SB1",1,xFilial("SB1")+(_cAlias)->D2_COD,"B1_UM")                     ,NIL},;
				{                 "D3_YRFCUST"  , "PRODUCTION ON DEMAND"                                                          ,NIL},;
				{                 "D3_YAPLIC"   , "1"					                                                          ,NIL},;
				{                 "D3_CC"       , "3000"                                                                          ,NIL} }
				lMsErroAuto := .F.
				msExecAuto({|x,Y| Mata250(x,Y)}, _aProd, 3)

				If lMsErroAuto
					MostraErro()
					_cErro	+=	Alltrim((_cAlias)->D2_COD) + ": Erro ao Gerar o Apontamento de Produção! " + CRLF 
				EndIf
			Else
				_cErro	+=	Alltrim(aCols[_nI,_nPosProd]) + ": Nota Fiscal ou Item Não encontrado na empresa Biancogres! " + CRLF
			EndIf
			(_cAlias)->(DbCloseArea())

		EndIf

	Next

	if !Empty(_cErro)
		MsgBox("Ocorreram os Erros abaixo durante a geração de Apontamentos de Produção: " + CRLF + _cErro,"MT103NFE","ALERT")
	EndIf

Return

Static Function fApOPPR()

	Local _nPosOp		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_OP"})
	Local _nPosProd		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"})
	Local _nPosQtd		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT"})
	Local _nPosLoc		:=	aScan(aHeader,{|x| Alltrim(x[2]) == "D1_LOCAL"})
	Local _nI
	Local _cProdPP		
	Local _cAlias
	Local _aProd		:=	{}	

	For _nI	:=	1 to Len(aCols)

		If !aCols[_nI,Len(aHeader)+1] .And.; 
		!Empty(aCols[_nI,_nPosOp]) .And. ;
		Posicione("SB1",1,xFilial("SB1")+aCols[_nI,_nPosProd],"B1_TIPO") == "PR"   

			SC2->(DbSetOrder(1))
			If SC2->(DbSeek(XFilial("SC2")+aCols[_nI,_nPosOp]))

				RecLock("SC2",.F.)
				SC2->C2_QUJE  := SC2->C2_QUJE + SD1->D1_QUANT
				SC2->(MsUnlock())

			EndIf

		EndIf

	Next _nI

Return
