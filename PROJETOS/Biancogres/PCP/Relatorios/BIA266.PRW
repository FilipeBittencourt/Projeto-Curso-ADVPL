#Include "Protheus.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} BIA266
@author Marcos Alberto Soprani
@since 16/09/11
@version 1.0
@description Ficha de Formulação - Terceiro
@type function
/*/

User Function BIA266()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local i

	cHInicio := Time()
	fPerg := "BIA266"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "FICHA DE FORMULAÇÃO"

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	A0001 := " SELECT G1_COD, B1_QB, B1_DESC, B1_REVATU
	A0001 += "   FROM " + RetSqlName("SG1") + " SG1
	A0001 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'
	A0001 += "                       AND B1_COD = G1_COD
	A0001 += "                       AND B1_TIPO = '" +MV_PAR03 + "'
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0001 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	A0001 += "    AND G1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	If MV_PAR03 == "PA" .and. MV_PAR04 == 1
		A0001 += "    AND SUBSTRING(G1_COD,1,7) IN(SELECT SUBSTRING(D3_COD,1,7)
		A0001 += "                                   FROM SD3010
		A0001 += "                                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                                    AND D3_EMISSAO BETWEEN '"+dtos(dDataBase-90)+"' AND '"+dtos(dDataBase)+"'
		A0001 += "                                    AND D3_TM = '500'
		A0001 += "                                    AND D_E_L_E_T_ = ' '
		A0001 += "                                  GROUP BY SUBSTRING(D3_COD,1,7)
		A0001 += "                                  UNION
		A0001 += "                                 SELECT SUBSTRING(D3_COD,1,7)
		A0001 += "                                   FROM SD3050
		A0001 += "                                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                                    AND D3_EMISSAO BETWEEN '"+dtos(dDataBase-90)+"' AND '"+dtos(dDataBase)+"'
		A0001 += "                                    AND D3_TM = '500'
		A0001 += "                                    AND D_E_L_E_T_ = ' '
		A0001 += "                                  GROUP BY SUBSTRING(D3_COD,1,7))
	EndIf
	A0001 += "    AND SG1.D_E_L_E_T_ = ' '
	A0001 += "  GROUP BY G1_COD, B1_QB, B1_DESC, B1_REVATU
	A0001 := ChangeQuery(A0001)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.T.,.T.)
	aStru1 := ("A001")->(dbStruct())

	/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_Ind := "G1_COD"
	If !chkfile("A002")
		A002 := U_BIACrTMP(aStru1)
		dbUseArea( .T.,, A002, "A002", .F., .F. )
		dbCreateInd(A002, gh_Ind,{ || gh_Ind })
	EndIf
	dbSelectArea("A002")
	APPEND FROM ("A001")
	If Select("A001") > 0
		A001->(dbCloseArea())
	Endif
	dbGotop()
	While !Eof()

		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Produto: "+Alltrim(A002->B1_DESC)+"  Tempo: "+cTempo)

		kc_VetF    := {}
		nEstru     := 0
		wProduto   := A002->G1_COD
		wQtd       := IIF(A002->B1_QB == 0, 1, A002->B1_QB)
		wpRevAtu   := A002->B1_REVATU
		wpNivel    := 0
		cArqTmp    := ""
		cAliasTRB  := cArqTRB := "Estrut"

		A0001 := " SELECT G1_COD COD,
		A0001 += "        G1_COMP COMP,
		A0001 += "        G1_QUANT QUANT,
		A0001 += "        G1_PERDA PERDA,
		A0001 += "        G1_YMISTUR MISTURA,
		A0001 += "        G1_YUNIDRF UNIDRF,
		A0001 += "        G1_INI,
		A0001 += "        G1_FIM
		A0001 += "   FROM " + RetSqlName("SG1")
		A0001 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
		A0001 += "    AND G1_COD = '"+A002->G1_COD+"'
		A0001 += "    AND G1_REVINI <= '" + A002->B1_REVATU + "'
		A0001 += "    AND G1_REVFIM >= '" + A002->B1_REVATU + "'
		A0001 += "    AND D_E_L_E_T_ = ' '
		TcQuery A0001 ALIAS "ESTRUT" NEW
		dbSelectArea("ESTRUT")
		dbGoTop()
		While ESTRUT->(!Eof())

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + ESTRUT->COMP) )

			sg_Quantid := ESTRUT->QUANT * wQtd
			If ESTRUT->PERDA <> 0
				sd_QtdPerd := sg_Quantid / (100 - ESTRUT->PERDA)
			Else
				sd_QtdPerd := sg_Quantid
			EndIf
			sg_Descr := SB1->B1_DESC

			aadd( kc_VetF, {wProduto,;
			ESTRUT->COMP,;
			sg_Descr,;
			SB1->B1_UM,;
			SB1->B1_CONV,;
			ESTRUT->MISTURA,;
			sg_Quantid,;
			ESTRUT->PERDA,;
			sd_QtdPerd,;
			sd_QtdPerd / SB1->B1_CONV,;
			ESTRUT->G1_INI,;
			ESTRUT->G1_FIM})

			ESTRUT->(dbSkip())

		End
		ESTRUT->(dbCloseArea())

		fImpCabec()
		kc_PosAtu := 0
		kc_PsAt02 := 0
		kc_First := .T.
		kc_MisTl := 0
		kc_TtPro := 0
		kc_TtSis := 0
		For i := 1 To Len(kc_VetF)
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			If kc_First
				oPrint:Say  (nRow1, 0100, "Ref.Sistema: " + Alltrim(kc_VetF[i][1])                                                              , oFont14)
				cft_Rvs := A002->B1_REVATU
				If Empty(cft_Rvs)
					cft_Rvs := "000"
				EndIf
				dfr_RefRev := "Revisão: " + cft_Rvs + "     Validade: "+dtoc(stod(kc_VetF[i][11]))+ " até: "+dtoc(stod(kc_VetF[i][12]))
				oPrint:Say  (nRow1, 1750, dfr_RefRev                                                                                            , oFont14)
				nRow1 += 075
				dvf_Descri := Alltrim(Posicione("SB1",1,xFilial("SB1")+kc_VetF[i][1],"B1_DESC"))
				oPrint:Say  (nRow1, 0100, dvf_Descri                                                             , oFont32)
				nRow1 += 150
				xf_Titu := +;
				Padr("Código"                                                                   ,15)+" "+;
				Padr("Componente"                                                               ,50)+" "+;
				Padc("UM"                                                                       ,02)+" "+;
				Padl("Ft_Conv"                                                                  ,08)+" "+;
				Padl("Sistema"                                                                  ,15)+" "+;
				Padl("%"                                                                        ,08)
				oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont10)
				oPrint:Line (nRow1+40, 050, nRow1+40, 1920)
				nRow1 += 075
				kc_First := .F.
				kc_PosAtu := nRow1
			EndIf

			xf_Item := +;
			Padr(kc_VetF[i][2]                                                              ,15)+" "+;
			Padr(kc_VetF[i][3]                                                              ,50)+" "+;
			Padc(kc_VetF[i][4]                                                              ,02)+" "+;
			Padl(Transform(kc_VetF[i][5], "@E 999.99")                                      ,08)+" "+;
			Padl(Transform(kc_VetF[i][7], "@E 999,999.99999999")                            ,15)+" "+;
			Padl(Transform(kc_VetF[i][6], "@E 9999.999")                                    ,08)
			oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont10)
			oPrint:Line (nRow1+40, 050, nRow1+40, 1920)
			nRow1 += 075
			kc_MisTl += kc_VetF[i][6]
			kc_TtPro += kc_VetF[i][7]
			kc_TtSis += kc_VetF[i][6]
		Next i

		// Tratamento para Retorno de Massa
		If kc_MisTl <> 0 .and. kc_MisTl < 100
			kc_Rejeit := 100 - kc_MisTl
			kc_RejQtd := wQtd * kc_Rejeit / 100
			xf_Totl := +;
			Padr(""                                                                         ,15)+" "+;
			Padr("RETORNO"                                                                  ,50)+" "+;
			Padc(""                                                                         ,02)+" "+;
			Padl(""                                                                         ,08)+" "+;
			Padl(Transform(kc_RejQtd, "@E 999,999.99999999")                                ,15)+" "+;
			Padl(Transform(kc_Rejeit, "@E 9999.999")                                        ,08)
			oPrint:Say  (nRow1 ,0050 ,xf_Totl                               ,oFont10)
			oPrint:Line (nRow1+40, 050, nRow1+40, 1920)
			nRow1 += 075
			kc_MisTl += kc_Rejeit
			kc_TtPro += kc_RejQtd
			kc_TtSis += kc_Rejeit
		EndIf

		xf_Totl := +;
		Padr("Totais"                                                                   ,15)+" "+;
		Padr(""                                                                         ,50)+" "+;
		Padc(""                                                                         ,02)+" "+;
		Padl(""                                                                         ,08)+" "+;
		Padl(Transform(kc_TtPro, "@E 999,999.99999999")                                 ,15)+" "+;
		Padl(Transform(kc_TtSis, "@E 9999.999")                                         ,08)
		oPrint:Say  (nRow1 ,0050 ,xf_Totl                               ,oFont10)
		oPrint:Line (nRow1+40, 050, nRow1+40, 1920)

		oPrint:Line (kc_PosAtu-100, 1750, kc_PosAtu-100, 1920)
		oPrint:Line (kc_PosAtu-100, 1750, nRow1+40, 1750)
		oPrint:Line (kc_PosAtu-100, 1920, nRow1+40, 1920)
		nRow1 += 075

		// Detalhamento de Impressão das Alterações de Revisão
		kc_PsAt02 := nRow1
		nRow1 := kc_PosAtu
		oPrint:Say  (nRow1-75, 2050, "Detalhamento das Alterações de Revisão" ,oFont10)
		oPrint:Line (nRow1-40, 2050, nRow1-40, 3350)

		AR007 := " SELECT R_E_C_N_O_ REGSG5
		AR007 += "   FROM (SELECT TOP 10 *
		AR007 += "           FROM SG5010
		AR007 += "          WHERE G5_FILIAL = '"+xFilial("SG5")+"'
		AR007 += "            AND G5_PRODUTO = '"+wProduto+"'
		AR007 += "            AND D_E_L_E_T_ = ' '
		AR007 += "          ORDER BY G5_REVISAO DESC) AS REVISAO
		AR007 += "  ORDER BY G5_REVISAO
		TcQuery AR007 ALIAS "AR07" NEW
		dbSelectArea("AR07")
		dbGoTop()
		While !Eof()
			SG5->(dbSetOrder(1))
			SG5->(dbGoTo(AR07->REGSG5))
			kc_Detalh := SG5->G5_REVISAO+" "+dtoc(SG5->G5_DATAREV)+" - "+Alltrim(SG5->G5_YMEMOBS)
			xPIni := 1
			While .T.
				If !Empty(Alltrim(Substr(kc_Detalh, xPIni, 70)))
					If nRow1 > 2250
						MsgINFO("As mensagens de alteração de revisão estão muito grande!!! Favor verificar.")
						Exit
					EndIf
					oPrint:Say  (nRow1   , 2050, Substr(kc_Detalh, xPIni, 70)                            ,oFont10)
					xPIni += 70
					nRow1 += 050
				Else
					Exit
				EndIf
			End
			nRow1 += 025
			dbSelectArea("AR07")
			dbSkip()
		End
		AR07->(dbCloseArea())

		// Controle de Ensaios
		gp_First := .T.
		nRow1 := kc_PsAt02 + 200
		AR008 := " SELECT Z03_PRODUT,
		AR008 += "        Z03_REVSAO,
		AR008 += "        Z03_DTINI,
		AR008 += "        Z03_DTFIM,
		AR008 += "        Z03_INTRDE,
		AR008 += "        Z03_INTRAT,
		AR008 += "        Z03_MEDIDA,
		AR008 += "        X5_DESCRI
		AR008 += "   FROM Z03010 Z03
		AR008 += "  INNER JOIN SX5010 SX5 ON X5_FILIAL = '"+xFilial("SX5")+"'
		AR008 += "                       AND X5_TABELA = 'ZL'
		AR008 += "                       AND X5_CHAVE = Z03_TIPO
		AR008 += "                       AND SX5.D_E_L_E_T_ = ' '
		AR008 += "  WHERE Z03_FILIAL = '"+xFilial("Z03")+"'
		AR008 += "    AND Z03_PRODUT = '"+wProduto+"'
		AR008 += "    AND Z03_REVSAO IN(SELECT TOP 1 Z03_REVSAO
		AR008 += "                        FROM Z03010
		AR008 += "                       WHERE Z03_FILIAL = '"+xFilial("Z03")+"'
		AR008 += "                         AND Z03_PRODUT = '"+wProduto+"'
		AR008 += "                         AND '"+dtos(dDataBase)+"' >= Z03_DTINI
		AR008 += "                         AND '"+dtos(dDataBase)+"' <= Z03_DTFIM
		AR008 += "                         AND D_E_L_E_T_ = ' '
		AR008 += "                       GROUP BY Z03_REVSAO
		AR008 += "                       ORDER BY Z03_REVSAO DESC)
		AR008 += "    AND Z03.D_E_L_E_T_ = ' '
		TcQuery AR008 ALIAS "AR08" NEW
		dbSelectArea("AR08")
		dbGoTop()
		While !Eof()
			If gp_First
				// Imprime breve cabec
				oPrint:Say  (nRow1 ,0050 ,"Lista de Ensaios"                               ,oFont8)
				oPrint:Line (nRow1+40, 050, nRow1+40, 0500)
				nRow1 += 075
				gp_CabEns := +;
				Padr("Rev"                                          ,03)+" "+;
				Padc("DtIni"                                        ,08)+" "+;
				Padc("DtFim"                                        ,08)+"   "+;
				Padr("Ensaio"                                       ,35)+" "+;
				Padl("InterDE"                                      ,08)+" "+;
				Padl("InterAT"                                      ,08)+"    "+;
				Padr("Medida"                                       ,20)
				oPrint:Say  (nRow1 ,0050 ,gp_CabEns                               ,oFont8)
				oPrint:Line (nRow1+40, 050, nRow1+40, 1900)
				nRow1 += 075
				gp_First := .F.
			EndIf

			gp_CabEns := +;
			Padr(AR08->Z03_REVSAO                            ,03)+" "+;
			Padc(dtoc(stod(AR08->Z03_DTINI))                 ,08)+" "+;
			Padc(dtoc(stod(AR08->Z03_DTFIM))                 ,08)+"   "+;
			Padr(AR08->X5_DESCRI                             ,35)+" "+;
			Padl(Transform(AR08->Z03_INTRDE, "@E 99999.99")  ,08)+" "+;
			Padl(Transform(AR08->Z03_INTRAT, "@E 99999.99")  ,08)+"    "+;
			Padr(AR08->Z03_MEDIDA                            ,20)
			oPrint:Say  (nRow1 ,0050 ,gp_CabEns                               ,oFont8)
			nRow1 += 050

			dbSelectArea("AR08")
			dbSkip()
		End
		AR08->(dbCloseArea())

		fImpRoda()

		dbSelectArea("A002")
		dbSkip()
	End
	A002->(dbCloseArea())

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025

	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
	oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

	nRow1 += 175
	oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 050, 2300, 3350)
	oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
	oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Produto          ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"02","Ate Produto         ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","De Tipo             ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"04","Caso Tipo PA        ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Ativos+Filtro","","","","","Apenas Filtro","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
