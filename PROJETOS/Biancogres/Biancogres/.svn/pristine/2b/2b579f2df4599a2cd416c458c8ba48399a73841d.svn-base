#include "rwmake.ch"
#include "topconn.ch"
#include "PROTHEUS.CH"

/*/{Protheus.doc} M460SOLI
@author Ranisses A. Corona
@since 14/05/2008
@version 1.0
@description P.E. utilizado para calculo dos valores do ICMS ST na Planilha Financeira no Pedido de Venda.
@history 04/11/2016, Ranisses A. Corona, Correção e melhorias na gravação do valor dos impostos por item. OS: 4052-16 Mayara Trigueiro / 3888-16 Elaine Sales
@type function
/*/

User Function M460SOLI()

	Local cCliEsp			:= "N" //CLIENTE ESPECIAL - APENAS PARA TRATAR O CLIENTE 015966-01
	Local wLinhas			:= PARAMIXB[1]
	Local nVlrFret			:= 0
	Local nVlrMerc			:= 0
	Local nVlrICMS			:= 0
	Local cUFSTCD			:= GetMV("MV_YUFSTCD") //Estados COM Destaque do ICMS ST na NF
	Local cUFSTSD			:= GetMV("MV_YUFSTSD") //Estados SEM Destaque do ICMS ST na NF
	Local aCliFor			:= {}
	Local lAchouPes			:= .F.
	Local cEST				:= ""
	Local cMUN				:= ""
	Local cRegEsp			:= ""
	Local cAlias			:= ""
	Local cSQL				:= ""
	Local cUPD				:= ""
	Local __nAliIcms
	Local __nBaseIcms

	Private	aArea	:= GetArea()
	Private aSolid			:= {}
	Private aMVA			:= {}
	Private nAliqIcms		:= AliqIcms(SC5->C5_TIPO,"S",SC5->C5_TIPOCLI,"S")/100 // Retorna a Aliquota interna do Estado de Origem
	Private nBaseIcmST		:= 0
	Private nIcmST			:= 0
	Private wPesoLiq		:= 0
	Private LiqC 			:= 0
	Private _peso			:= 0
	Private _volu			:= 0
	Private wPesoBr			:= 0
	Private wVt				:= 0
	Private wBaseCalc		:= 0
	Private cRegEsp			:= ""
	Private	cGrpPd			:= SB1->B1_GRTRIB
	Private	cNCM			:= SB1->B1_POSIPI

	Private _IsAuto := Type("_XCRGATFAT") <> "U" .And. _XCRGATFAT

	If IsInCallStack("U_BACP0020")

		Return(aSolid)

	EndIf

	If xBiaVTotNf == 0

		cAlias := GetNextAlias()

		cSQL := " SELECT ISNULL(SUM(C9_QTDLIB * C9_PRCVEN), 0) TOTNF "
		cSQL += " FROM " + RetSqlName("SC9") + " SC9 "
		cSQL += " WHERE C9_FILIAL	= " + ValToSql(xFilial("SC9"))
		cSQL += " AND C9_AGREG		= " + ValToSql(SC9->C9_AGREG)
		cSQL += " AND C9_PEDIDO		= " + ValToSql(SC9->C9_PEDIDO)
		cSQL += " AND C9_BLCRED 	= '' "
		cSQL += " AND C9_BLEST 		= '' "
		cSQL += " AND SC9.D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cAlias)

		xBiaVTotNf := (cAlias)->TOTNF

		(cAlias)->(DbCloseArea())

	EndIf

	IF (_IsAuto)

		If wLinhas == 1

			If cEmpAnt == "07"

				cAlias := GetNextAlias()

				cSQL := " SELECT C5_YVLFRST "
				cSQL += " FROM " + RetFullName("SC5", SC5->C5_YEMPPED) + " SC5 "
				cSQL += " WHERE C5_FILIAL	= '01' "
				cSQL += " AND C5_NUM		= " + ValToSql(SC5->C5_YPEDORI)
				cSQL += " AND SC5.D_E_L_E_T_ = '' "

				TcQuery cSQL New Alias (cAlias)

				If (cAlias)->(!EOF())

					nVlrFret  := (cAlias)->C5_YVLFRST
					xVlFrtInf := nVlrFret

				EndIf

				(cAlias)->(DbCloseArea())

				//TICKET 24346
				//Limpar o campo do SC5 apos o uso
				cUPD := " UPDATE "
				cUPD += RetFullName("SC5", SC5->C5_YEMPPED)
				cUPD += " SET C5_YVLFRST	= 0 "
				cUPD += " WHERE C5_FILIAL	= '01' "
				cUPD += " AND C5_NUM		= " + ValToSql(SC5->C5_YPEDORI)
				cUPD += " AND D_E_L_E_T_ = '' "

				TCSQLExec(cUPD)
				//FIM >>> TICKET 24346

			Else

				nVlrFret  := SC5->C5_YVLFRST
				xVlFrtInf := nVlrFret

				//TICKET 24346
				//Limpar o campo do SC5 apos o uso
				RecLock("SC5",.F.)
				SC5->C5_YVLFRST := 0
				SC5->(MsUnlock())
				//FIM >>> TICKET 24346

			EndIf

		Else

			nVlrFret := xVlFrtInf

		EndIf

	ELSE
		//Chama tela para digitacao do Frete Transportadora
		If wLinhas == 1

			@ 000,000 to 100,260 Dialog oDlg1 Title "Cálculo ICMS ST"
			//lin,col
			@ 001,002 Say "Informe o Valor do Frete Transportadora:"
			@ 002,002 Get nVlrFret	picture "@E 999,999,999.999"
			@ 026,085 BmpButton Type 01 Action Close(oDlg1)
			Activate Dialog oDlg1 Centered

			xVlFrtInf := nVlrFret

		Else

			nVlrFret := xVlFrtInf

		EndIf

	ENDIF

	// Incluído tratamento para rateio de cálculo de frete por item de produto - Por Marcos Alberto Soprani - 22/09/14
	If nVlrFret > 0
		xBiaPondera := ( SC9->C9_QTDLIB * SC9->C9_PRCVEN ) / xBiaVTotNf
		nVlrFret    := Round (nVlrFret * xBiaPondera, 2)
	EndIf

	//Inicio do Programa
	If Alltrim(SC5->C5_TIPO) == "I" //Complemnto de ICMS - Não realiza o calculo

		Return(aSolid)

	Else

		//Cliente especial
		If  !(SC5->C5_TIPO $ "D_B") .And. SC5->C5_CLIENTE == "015966"
			cCliEsp := "S"
		EndIf

		//Posiciona e pega campos do cadastro do CLIENTE ou FORNECEDOR , Pelo tipo do pedido
		aCliFor		:= U_fGetUF(FunName())
		lAchouPes	:= aCliFor[1]
		cEST		:= aCliFor[2]
		cMUN		:= aCliFor[3]
		cRegEsp		:= aCliFor[4]


		//ICMS ST com Destaque na NF
		If Alltrim(SC5->C5_TIPOCLI) == "S" .and. AllTrim(SB1->B1_TIPO) $ "PA_PR" .And. Alltrim(cEST) $ cUFSTCD

			//Se se o ICMS estiver zerado não precisa calcular.
			If ICMSITEM > 0 .Or.  ( Alltrim(cEST) == "AP" .And. ( MaFisRet(wLinhas,"IT_DESCZF") - ( MaFisRet(wLinhas,"IT_DESCZFCOF")+MaFisRet(wLinhas,"IT_DESCZFPIS") ) ) > 0)

				If ICMSITEM > 0
					nIcms := ICMSITEM
				Else
					nIcms := ( MaFisRet(wLinhas,"IT_DESCZF") - ( MaFisRet(wLinhas,"IT_DESCZFCOF")+MaFisRet(wLinhas,"IT_DESCZFPIS") ) )
				EndIf

				//Se for Autonomo ou a Pedido Antecipado
				If nTpFrete == 1
					wBaseCalc 	:= U_fCalcFreteAut(cEST,cMUN,SC6->C6_PRODUTO,SC6->C6_LOTECTL,QUANTITEM)[1] //Posicao 1 retorna a Base
				EndIf

				//CONFORME OS 2771-12 (BA) E 1048-13 (ES)
				If MaFisRet(wLinhas,"IT_DESCONTO") > 0 .And. Alltrim(cEST) == "ES" //Retira UF da BA conforme OS 3371-15, em 27/08/15
					nVlrMerc := MaFisRet(wLinhas,"IT_VALMERC")-MaFisRet(wLinhas,"IT_DESCONTO")
				Else
					nVlrMerc := MaFisRet(wLinhas,"IT_VALMERC")
				EndIf

				//Buscando base e aliquota ICMS - Ticket 21807
				__nAliIcms := MaFisRet(wLinhas,"IT_ALIQICM")
				__nBaseIcms := MaFisRet(wLinhas,"IT_BASEICM")

				//Grava a Base e o Valor da ST
				aSolid := U_fCalcVlrST(cGrpPd,cNCM,cRegEsp,cCliEsp,cEST,nVlrMerc,nIcms,MaFisRet(wLinhas,"IT_VALIPI"),wBaseCalc,nVlrFret,SC5->C5_CLIENTE,__nAliIcms,__nBaseIcms)

				//NFE 4.0 - ajustando calculo de FECP quando o ICMS ST eh ajusatdo pelo ponto de entrada
				_ALIQFECP := MaFisRet(1,"IT_ALFCST")

				If (_ALIQFECP > 0)

					aAdd(aSolid, aSolid[1])  //5  BASE FECP
					aAdd(aSolid, _ALIQFECP)  //6  Aliq FECP
					aAdd(aSolid, Round( (aSolid[1] * _ALIQFECP)/100 ,2) )  //VALOR FECP

				Else

					aAdd(aSolid, 0)  //5  BASE FECP
					aAdd(aSolid, 0)  //6  Aliq FECP
					aAdd(aSolid, 0)  //VALOR FECP

				EndIf

			Else

				aAdd(aSolid, 0) //1
				aAdd(aSolid, 0) //2
				aAdd(aSolid, 0) //3
				aAdd(aSolid, 0) //4
				aAdd(aSolid, 0) //5
				aAdd(aSolid, 0) //6
				aAdd(aSolid, 0) //7

			EndIf

			//ICMS ST sem Destaque na NF
		ElseIf Alltrim(SC5->C5_TIPOCLI) == "S" .and. AllTrim(SB1->B1_TIPO) $ "PA_PR" .And. Alltrim(cEST) $ cUFSTSD

			aAdd(aSolid, 0) //1
			aAdd(aSolid, 0) //2
			aAdd(aSolid, 0) //3
			aAdd(aSolid, 0) //4
			aAdd(aSolid, 0) //5
			aAdd(aSolid, 0) //6
			aAdd(aSolid, 0) //7

		EndIf

	EndIf

	RestArea(aArea)

Return(aSolid)