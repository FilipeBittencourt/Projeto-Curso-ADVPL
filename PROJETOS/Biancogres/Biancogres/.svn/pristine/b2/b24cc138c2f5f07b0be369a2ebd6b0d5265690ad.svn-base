#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT100CLA
@author Nilton Cesar
@since 14/10/2003
@version 1.0
@description Mensagem que a nota esta bloqueada
@history 08/05/2017, Ranisses A. Corona, Alterado para contemplar as NF recebidas via Totvs Colaboracao 2.0
@type function
/*/

User Function MT100CLA()

	Local aInfOri	:= {}
	Local _lIntrag	:=	.F.
	Local _cTpProd
	Local _aAreaF1 := SF1->(GetArea())
	Local _aAreaD1 := SD1->(GetArea())	

	Private vvvArea := GetArea()
	Private __CCOND := ""

	Public __cEmpAux	:= ''
	Public __Distri  	:= .F.     // Incluido em 16/01/15 por Marcos Alberto Soprani para atender integração Totvs Colaboração
	Public __LocDis  	:= "ZZZZ"  // Incluido em 16/01/15 por Marcos Alberto Soprani para atender integração Totvs Colaboração
	Public ktcGravei 	:= .F.     // Tratativa para controle de cancelamento do processo de classificação - Por Marcos Alberto Soprani em 28/12/15.

	If !FwIsInCallStack('U_GATI001') .Or. (FwIsInCallStack('U_GATI001') .And. !l103Auto)

		If SF1->F1_YBLOQ == "S"

			MsgBox("Atencao!! Essa nota fiscal esta bloqueada devido ao preco unitario estar fora da margem permitida! Solicite Liberacao","Alert")

		EndIf

		// Por Marcos Alberto Soprani. Em 28/12/15 foi identificado uma falha no controle de classificação, que mesmo estando classificada o sistema passava por este ponto de entrada.
		If !Empty(SF1->F1_STATUS) .And. !FwIsInCallStack('U_GATI001')

			MsgBox( "Esta nota fiscal está classificada...","MT100CLA", "INFO")
			Return

		EndIf

		QT001 := " SELECT DT_ITEM,
		QT001 += "        DT_PRODFOR,
		QT001 += "        DT_COD,
		QT001 += "        DT_DESCFOR,
		QT001 += "        DT_QUANT,
		QT001 += "        DT_VUNIT,
		QT001 += "        DT_TOTAL,
		QT001 += "        DT_YCFOP,
		QT001 += "        DT_PEDIDO,
		QT001 += "        DT_ITEMPC,
		QT001 += "        DT_YUNID,
		QT001 += "        DT_YCLVL,
		QT001 += "        DT_YTES,
		QT001 += "        DT_YREGRA,
		QT001 += "        DT_YNFORI,
		QT001 += "        DT_YSRORI,
		QT001 += "        DT_YITORI,
		QT001 += "        DT_YIDTB6,
		QT001 += "        DT_DOC,
		QT001 += "        DT_LOTE,
		QT001 += "        DT_DTVALID,
		QT001 += "        DT_XMLICST,
		QT001 += "        DT_YXMLBST,
		QT001 += "		  DT_XALICST,
		QT001 += "        DS_TIPO
		QT001 += "   FROM " + RetSqlName("SDT") + " SDT
		QT001 += "  INNER JOIN " + RetSqlName("SDS") + " SDS ON DS_FILIAL = '"+xFilial("SDS")+"'
		QT001 += "                   AND DS_DOC = DT_DOC
		QT001 += "                   AND DS_SERIE = DT_SERIE
		QT001 += "                   AND DS_FORNEC = DT_FORNEC
		QT001 += "                   AND DS_LOJA = DT_LOJA
		QT001 += "                   AND SDS.D_E_L_E_T_ = ' '
		QT001 += "  WHERE DT_FILIAL = '"+xFilial("SDT")+"'
		QT001 += "    AND DT_FORNEC = '"+SF1->F1_FORNECE+"'
		QT001 += "    AND DT_LOJA = '"+SF1->F1_LOJA+"'
		QT001 += "    AND DT_DOC = '"+SF1->F1_DOC+"'
		QT001 += "    AND DT_SERIE = '"+SF1->F1_SERIE+"'
		QT001 += "    AND SDT.D_E_L_E_T_ = ' '
		QTlIndex := CriaTrab(Nil,.f.)
		QT001 := ChangeQuery(QT001)
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QT001),'QT01',.T.,.T.)
		dbSelectArea("QT01")
		dbGoTop()
		While !Eof()

			kjCod     := QT01->DT_COD
			kjTES     := QT01->DT_YTES
			kjRegra   := QT01->DT_YREGRA
			kjNfOri   := QT01->DT_YNFORI
			kjSrOri   := QT01->DT_YSRORI
			kjItOri   := QT01->DT_YITORI
			kjIdtB6   := QT01->DT_YIDTB6
			kjPedid   := QT01->DT_PEDIDO
			kjItPed   := QT01->DT_ITEMPC
			kjFormt   := Space(2)
			kjLoteC   := Space(10)
			kjCodRf   := Space(15)
			kjAlmox	  := Space(2)
			_xTipoNf  := QT01->DS_TIPO

			If SF1->F1_FORNECE == "003721"

				kjCod   := QT01->DT_PRODFOR

				If Substr(QT01->DT_YCFOP,2,3) $ "902/903"

					kxNfRet  := .T.

					// Busca os dados de lote na Vitcer
					zp_Empr := "14"

					BK005 := " SELECT D2_LOTECTL, D2_YCODREF, D2_NFORI
					BK005 += "   FROM SD2"+zp_Empr+"0
					BK005 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					BK005 += "    AND D2_DOC = '"+QT01->DT_DOC+"'
					BK005 += "    AND D2_ITEM = '"+Substr(QT01->DT_ITEM,3,2)+"'
					BK005 += "    AND D2_QUANT = "+Alltrim(Str(QT01->DT_QUANT))
					BK005 += "    AND D_E_L_E_T_ = ' '
					BKlIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,BK005),'BK05',.T.,.T.)
					dbSelectArea("BK05")
					dbGoTop()
					kjLotOri := BK05->D2_LOTECTL
					kjCodRf  := BK05->D2_YCODREF
					kjNfOri  := BK05->D2_NFORI
					BK05->(dbCloseArea())
					Ferase(BKlIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(BKlIndex+OrdBagExt())          //indice gerado

					kjLoteC  := kjLotOri
					RT004 := " SELECT D2_DOC, D2_SERIE, D2_ITEM, D2_IDENTB6
					RT004 += "   FROM " + RetSqlName("SD2")
					RT004 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					RT004 += "    AND D2_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "    AND D2_COD = '"+kjCod+"'
					RT004 += "    AND D2_LOTECTL = '"+kjLotOri+"'
					RT004 += "    AND D2_IDENTB6 IN(SELECT MIN(B6_IDENT)
					RT004 += "                        FROM " + RetSqlName("SB6")
					RT004 += "                       WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					RT004 += "                         AND B6_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "                         AND B6_PRODUTO = '"+kjCod+"'
					RT004 += "                         AND B6_PRUNIT BETWEEN "+Alltrim(Str(NoRound(QT01->DT_VUNIT,1)))+" AND "+Alltrim(Str(Round(QT01->DT_VUNIT+0.1,4)))
					RT004 += "                         AND B6_SALDO >= " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "                         AND D_E_L_E_T_ = ' ')
					RT004 += "    AND D_E_L_E_T_ = ' '
					TcQuery RT004 ALIAS "RT04" NEW
					dbSelectArea("RT04")
					dbGoTop()
					If !Empty(RT04->D2_DOC)
						kjNfOri := RT04->D2_DOC
					EndIf
					kjSrOri := RT04->D2_SERIE
					kjItOri := RT04->D2_ITEM
					kjIdtB6 := RT04->D2_IDENTB6
					RT04->(dbCloseArea())

					If Substr(QT01->DT_YCFOP,2,3) $ "902"                                    // Retorno de Industrialização
						***************************************************************************************************
						kjTES   := "057"
						kjRegra := "M "
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                             // Ret. Ind. - Quebra no Processo
						***************************************************************************************************
						kjTES   := "089"
						kjRegra := "M "
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                        // Ret. Ind. - Quebra Fora do Processo
						***************************************************************************************************
						kjTES   := ""
						kjRegra := ""
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                               // Retorno Sem Industrialização
						***************************************************************************************************
						kjTES   := "175"
						kjRegra := "N "
					EndIf

				ElseIf Substr(QT01->DT_YCFOP,2,3) == "124"                                              // INDUSTRIALIZAÇÃO
					*******************************************************************************************************

					// Busca os dados de lote na Vitcer
					zp_Empr := "14"

					BK005 := " SELECT D2_LOTECTL, D2_YCODREF
					BK005 += "   FROM SD2"+zp_Empr+"0
					BK005 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					BK005 += "    AND D2_DOC = '"+QT01->DT_DOC+"'
					BK005 += "    AND D2_ITEM = '"+Substr(QT01->DT_ITEM,3,2)+"'
					BK005 += "    AND D2_QUANT = "+Alltrim(Str(QT01->DT_QUANT))
					BK005 += "    AND D_E_L_E_T_ = ' '
					BKlIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,BK005),'BK05',.T.,.T.)
					dbSelectArea("BK05")
					dbGoTop()
					kjLotInd := BK05->D2_LOTECTL
					kjFormt  := BK05->D2_YCODREF
					BK05->(dbCloseArea())
					Ferase(BKlIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(BKlIndex+OrdBagExt())          //indice gerado

					If Empty(kjPedid) .or. Empty(kjItPed)

						RT004 := " SELECT TOP 1 *
						RT004 += "   FROM (SELECT TOP 1 C7_NUM, C7_ITEM
						RT004 += "           FROM " + RetSqlName("SC7")
						RT004 += "          WHERE C7_FILIAL = '01'
						RT004 += "            AND C7_FORNECE = '003721'
						RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
						RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
						RT004 += "            AND C7_LOTECTL = '"+kjLotInd+"'
						RT004 += "            AND C7_CONAPRO IN('L',' ')
						RT004 += "            AND C7_RESIDUO = ' '
						RT004 += "            AND D_E_L_E_T_ = ' '
						RT004 += "         UNION
						RT004 += "         SELECT TOP 1 C7_NUM, C7_ITEM
						RT004 += "           FROM " + RetSqlName("SC7")
						RT004 += "          WHERE C7_FILIAL = '"+xFilial("SC7")+"'
						RT004 += "            AND C7_FORNECE = '003721'
						RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
						RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
						RT004 += "            AND C7_CONAPRO IN('L',' ')
						RT004 += "            AND C7_RESIDUO = ' '
						RT004 += "            AND D_E_L_E_T_ = ' ') PEDIDOS
						TcQuery RT004 ALIAS "RT04" NEW
						dbSelectArea("RT04")
						dbGoTop()
						kjPedid := RT04->C7_NUM
						kjItPed := RT04->C7_ITEM
						RT04->(dbCloseArea())

					End

					kjTES   := "178"
					kjRegra := "N "
					kjLoteC := kjLotInd

				EndIf

			ElseIf SF1->F1_FORNECE $ "007602/002912/000534/004695" .or. (cEmpAnt == "14" .and. SF1->F1_FORNECE == "000481" .and. _xTipoNf == "B")

				// Fornecedor      IntraGrupo -- Mundi(004695) / Incesa(002912) / Biancogres(000534) / LM(007602) / VITCER (003721)
				*************************************************************************************************
				// Cliente         IntraGrupo -- Mundi(014395) / Incesa(004536) / Biancogres(000481) / LM(010064) / VITCER (008615)
				*************************************************************************************************

				kjCod		:= QT01->DT_PRODFOR
				kjLotInd 	:= ""
				kjDtVlLot	:= ""
				kjLoteC 	:= kjLotInd
				_xIntrGrV	:= .T.

				//Preenche informações da Empresa Origem
				aInfOri	:= U_GetInfO2(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,"","",cEmpAnt)
				zp_Empr := aInfOri[1]
				zp_Fil	:= aInfOri[2]
				zp_Cli 	:= aInfOri[3] 

				//Preenche informações sobre a Distribuicao dos Produtos
				If cEmpAnt == "01"
					__Distri  := .T.
					__LocDis  := "ZZZZ"			
				ElseIf cEmpAnt == "05"
					__Distri  := .T.
					__LocDis  := "ZZZZ"
				ElseIf cEmpAnt == "07"
					__Distri  := .T.
					__LocDis  := "LM"			
				ElseIf cEmpAnt == "13"
					__Distri  := .F.
					__LocDis  := "ZZZZ"
				ElseIf cEmpAnt == "14"
					__Distri  := .T.
					__LocDis  := "ZZZZ"
				EndIf

				//Tratamento para Condição de Pagamento do Tipo 9 //OS 4134-15
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+aInfOri[16]))
				If Alltrim(SE4->E4_TIPO) <> '9'
					__CCOND  := aInfOri[16]
				Else
					__CCOND  := "056"
				EndIf

				//Grava o Peso Liquido 
				__PLiqui := aInfOri[17]

				//Define o TES 
				kjTES := "0A2"	
				If Alltrim(aInfOri[15]) == 'B'
					kjTES := '0A5'
				Else
					If zp_Empr == '01' .or. zp_Empr == '05'
						kjTES := '0A2'
						If cEmpAnt = '05'
							kjTES := '2A3'
						EndIf
					ElseIf zp_Empr == '07' 
						If cFilAnt == "01"
							kjTES := "001"
						ElseIf cFilAnt == "02"
							kjTES := "001"
						ElseIf cFilAnt == "03"
							kjTES := "001"
						ElseIf cFilAnt == "04"
							kjTES := "001"
						EndIf 							
					ElseIf zp_Empr == '13' .and. Alltrim(aInfOri[15]) <> 'A'
						//kjTES := '0A3'
						kjTES := '0A4'
					ElseIf zp_Empr == '13' .and. Alltrim(aInfOri[15]) == 'A'
						kjTES := '1C6'
					ElseIf cEmpAnt == '14' .and. zp_Empr == '01'
						kjTES := '001'
					EndIf
				EndIf

			EndIf

			_cTpProd	:=	""
			heRetLotOk := .F.
			If Alltrim(GetMv("MV_RASTRO")) == "S"
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+QT01->DT_COD))
					_cTpProd	:=	SB1->B1_TIPO
					If SB1->B1_RASTRO == "L"
						SF4->(dbSetOrder(1))
						SF4->(dbSeek(xFilial("SF4")+kjTES))
						If SF4->F4_ESTOQUE == "S" .or. 1 == 1
							heRetLotOk := .T.
						EndIf
					EndIf
				EndIf
			EndIf

			// Incluir tratamento para gravação do SD1
			dbSelectArea("SD1")
			dbSetOrder(1)
			If dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+QT01->DT_COD+QT01->DT_ITEM)
				RecLock("SD1",.F.)

				_lIntrag	:=	GetNewPar("MV_YFATGRP",.F.) .And.  cEmpAnt == "05"  .And. SF1->F1_FORNECE == '000534' .And. Alltrim(_cTpProd) == "PA"

				//Busca Informações da Origem por Item / Totvs Colaboracao intragrupo
				aInfOri		:= U_GetInfO2(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,QT01->DT_COD,QT01->DT_ITEM,cEmpAnt)	
				kjLotInd 	:= aInfOri[13]
				kjDtVlLot	:= aInfOri[14]
				kjLoteC 	:= kjLotInd
				kjAlmox		:= aInfOri[18]



				//Retirado a Pedido de Marcos para impedir que os campos sejam alterados
				/*
				If !isInCallStack("U_TACLNFJB")
					SD1->D1_TES     := kjTES
					SD1->D1_YREGRA  := IIF(Empty(kjRegra), "N", kjRegra)
					SD1->D1_PEDIDO  := kjPedid
					SD1->D1_ITEMPC  := kjItPed
				EndIf
				*/
				If _lIntrag
					SD1->D1_COD		:= SUBSTR(Alltrim(QT01->DT_COD),1,Len(Alltrim(QT01->DT_COD))-1)
					SD1->D1_LOTECTL := ""
					SD1->D1_DTVALID := STOD("")
					SD1->D1_OP		:= fSeekOp(QT01->DT_COD, SD1->D1_QUANT)
				Else
					SD1->D1_LOTECTL := IIF(heRetLotOk, kjLoteC, "")
					SD1->D1_DTVALID := STOD(IIF(heRetLotOk, kjDtVlLot,""))
				EndIf
				SD1->D1_YFORIND := kjFormt
				SD1->D1_YCODREF := kjCodRf
				SD1->D1_NFORI   := kjNfOri
				SD1->D1_SERIORI := kjSrOri
				SD1->D1_ITEMORI := kjItOri
				SD1->D1_IDENTB6 := kjIdtB6		
				//Se a NF teve ICMS ST na Origem (SD2 - Saída), grava este valor também na Entrada (SD1)
				If QT01->DT_XMLICST > 0			
					SD1->D1_BRICMS	:= QT01->DT_YXMLBST //Base ICMS ST  
					SD1->D1_ICMSRET := QT01->DT_XMLICST	//Vl. ICMS ST
					SD1->D1_VLSLXML	:= QT01->DT_XMLICST //Vl. ICMS ST
					SD1->D1_ALIQSOL	:= QT01->DT_XALICST //Aliq. ICMS ST
				EndIf

				If _xTipoNf == "B"
					SD1->D1_LOCAL   := "07"
				Else
					If cEmpAnt == "14" .and. kjTES == "004" .and. SF1->F1_FORNECE $ "000534/007602"  // Tratamento implementado em 15/05/14 por Marcos Alberto Soprani para atender ao emquadramento de almoxarifados da Vitcer
						SD1->D1_LOCAL   := "01"
					ElseIf cEmpAnt == "07" .And. SF1->F1_FORNECE $ "000534/002912"
						SD1->D1_LOCAL := kjAlmox
					Else
						//CTE busca da nota fiscal de origem
						If Alltrim(SF1->F1_ESPECIE) == "CTE"
							//SD1->D1_LOCAL := fGetLoc(SD1->D1_NFORI, SD1->D1_SERIORI, SD1->D1_COD)
						else 
							//Documento de entrada diferente de CTE busca do Pedido
							SC7->(DbSetOrder(1))
							If SC7->(DbSeek(XFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC)) .And. !Empty(SC7->C7_LOCAL)
								SD1->D1_LOCAL := SC7->C7_LOCAL
							Else
								SBZ->(DbSetOrder(1))
								If SBZ->(DbSeek(XFilial("SBZ")+SD1->D1_COD)) .And. !Empty(SBZ->BZ_LOCPAD)
									SD1->D1_LOCAL := SBZ->BZ_LOCPAD
								Else
									SD1->D1_LOCAL := SB1->B1_LOCPAD
								EndIf
							EndIf
						endIf
					EndIf
				EndIf

				MsUnLock()

				// Tratativa para controle de cancelamento do processo de classificação - Por Marcos Alberto Soprani em 28/12/15.
				ktcGravei := .T.

			EndIf

			dbSelectArea("QT01")
			dbSkip()

		End
		QT01->(dbCloseArea())
		Ferase(QTlIndex+GetDBExtension())	//arquivo de trabalho
		Ferase(QTlIndex+OrdBagExt())		//indice gerado

		// Implementado em 18/03/15 por Marcos Alberto Soprani
		If !Empty(__CCOND)
			dbSelectArea("SF1")
			RecLock("SF1",.F.)
			SF1->F1_COND  := __CCOND
			cCondicao     := __CCOND
			MsUnlock()
		EndIf

		RestArea(vvvArea)

		// Tiago Rossini Coradini - OS: 2047-15 - Marcieli Malavasi
		If FieldPos("F1_TPFRETE") > 0 .And. Len(aNFEDanfe) > 0

			If !Empty(SF1->F1_TPFRETE) .And. Empty(aNFEDanfe[14])

				aNFEDanfe[14] := RetTipoFrete(SF1->F1_TPFRETE)

			EndIf

		EndIf

		RestArea(_aAreaF1)
		RestArea(_aAreaD1)
	EndIf

Return

Static Function fSeekOp(_cCod,_nQuant)

	Local _cOp	:=	""
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT TOP 1
		ISNULL(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD, '') OP
		FROM    %TABLE:SC2% SC2
		WHERE   C2_PRODUTO = %Exp:_cCod%
		AND SC2.%Notdel%
		AND C2_DATRF = ''
		AND C2_LINHA IN ('003','L03','E3A')		
		AND C2_QUANT - C2_QUJE
		- ( SELECT  ISNULL(SUM(D1_QUANT),0)
		FROM    %TABLE:SD1% SD1
		WHERE   D1_FILIAL = %xFilial:SD1%
		AND D1_DOC = %EXP:SF1->F1_DOC%
		AND D1_SERIE = %Exp:SF1->F1_SERIE%
		AND D1_FORNECE = %Exp:SF1->F1_FORNECE%
		AND D1_LOJA = %Exp:SF1->F1_LOJA%
		AND D1_COD = C2_PRODUTO
		AND D1_OP = C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD
		) >= %Exp:_nQuant%
		ORDER BY SC2.C2_EMISSAO
	EndSql

	_cOp	:=	(_cAlias)->OP

	(_cAlias)->(DbCloseArea())

Return _cOp