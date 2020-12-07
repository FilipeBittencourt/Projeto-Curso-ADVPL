#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA260
@author Marcos Alberto Soprani
@since 09/08/11
@version 1.0
@description Carga de Argila
@type function
/*/

User Function BIA260()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local i

	cHInicio := Time()
	fPerg := "BIA260"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "CARGA DE ARGILA ... Ord.Prod: " + Alltrim(MV_PAR01)
	fCabec1  := "Umidade Ref.: " + dtoc(MV_PAR03) + ",     Almoxarifado: " + MV_PAR05

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
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	sr_PZero   := .F.
	sr_CodMPM  := ""

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	A0001 := " SELECT C2_PRODUTO, B1_QB, B1_DESC, B1_REVATU, C2_REVISAO
	A0001 += "   FROM "+RetSqlName("SC2")+" SC2
	A0001 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                       AND B1_COD = C2_PRODUTO
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0001 += "  WHERE C2_FILIAL = '"+xFilial("SG1")+"'
	A0001 += "    AND C2_NUM+C2_ITEM+C2_SEQUEN+'  ' = '"+MV_PAR01+"'
	A0001 += "    AND SC2.D_E_L_E_T_ = ' '
	A0001 += "  GROUP BY C2_PRODUTO, B1_QB, B1_DESC, B1_REVATU, C2_REVISAO
	A0001 := ChangeQuery(A0001)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.T.,.T.)
	aStru1 := ("A001")->(dbStruct())

	/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_Ind := "C2_PRODUTO"
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
		wProduto   := A002->C2_PRODUTO
		wQtd1      := IIF(A002->B1_QB <> 0, A002->B1_QB, 1) * MV_PAR02
		wQtd2      := IIF(A002->B1_QB <> 0, A002->B1_QB, 1) * MV_PAR04
		wpRevAtu   := A002->B1_REVATU
		wpNivel    := 0
		cArqTmp    := ""
		cAliasTRB  := cArqTRB := "Estrut"
		sr_PZero   := .F.

		A0001 := " SELECT G1_COD COD,
		A0001 += "        G1_COMP COMP,
		A0001 += "        ISNULL((SELECT TOP 1 Z02_UMIDAD
		A0001 += "                  FROM " + RetSqlName("Z02")
		A0001 += "                 WHERE Z02_FILIAL = '" + xFilial("Z02") + "'
		A0001 += "                   AND Z02_PRODUT = G1_COMP
		A0001 += "                   AND Z02_DATREF = '" + dtos(MV_PAR03) + "'
		A0001 += "                   AND Z02_LOCAL = '" + MV_PAR05 + "'
		A0001 += "                   AND Z02_ORGCLT = '1'
		A0001 += "                   AND D_E_L_E_T_ = ' '), 0) PERDA,
		A0001 += "        G1_YMISTUR MISTURA,
		A0001 += "        G1_INI,
		A0001 += "        G1_FIM,
		A0001 += "        G1_YSEQIMP,
		A0001 += "        G1_YMOAGEM
		A0001 += "   FROM " + RetSqlName("SG1") + " "
		A0001 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "'
		A0001 += "    AND G1_COD = '" + A002->C2_PRODUTO + "'
		A0001 += "    AND G1_REVINI >= '" + A002->C2_REVISAO + "'
		A0001 += "    AND G1_REVFIM <= '" + A002->C2_REVISAO + "'
		A0001 += "    AND D_E_L_E_T_ = ' '
		A0001 += "  ORDER BY G1_COD, G1_YSEQIMP, G1_YMOAGEM, G1_COMP
		TcQuery A0001 ALIAS "ESTRUT" NEW
		dbSelectArea("ESTRUT")
		dbGoTop()
		While ESTRUT->(!Eof())

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + ESTRUT->COMP) )

			wQtd := 1
			wQtdRef := 1
			If ESTRUT->G1_YMOAGEM $ " /1)"
				wQtd := wQtd1 / (wQtd1+wQtd2)
				wQtdRef := wQtd1
			ElseIf ESTRUT->G1_YMOAGEM $ "2"
				wQtd := wQtd2 / (wQtd1+wQtd2)
				wQtdRef := wQtd2
			EndIf

			sg_Quantid := (ESTRUT->MISTURA/100) / wQtd * wQtdRef
			sd_QtdUmid := sg_Quantid / ( (100 - ESTRUT->PERDA) / 100 )

			sg_Descr := ""
			If !Empty(SB1->B1_YREFLAB)
				sg_Descr := SB1->B1_YREFLAB
			Else
				sg_Descr := "* "+SB1->B1_DESC
			EndIf
			aadd( kc_VetF, {wProduto,;
			ESTRUT->COMP,;
			sg_Descr,;
			SB1->B1_UM,;
			SB1->B1_CONV,;
			ESTRUT->MISTURA,;
			sg_Quantid,;
			ESTRUT->PERDA,;
			Round(sd_QtdUmid,2),;
			sd_QtdUmid / SB1->B1_CONV,;
			ESTRUT->G1_INI,;
			ESTRUT->G1_FIM,;
			ESTRUT->G1_YMOAGEM,;
			ESTRUT->G1_YSEQIMP})

			If ESTRUT->PERDA == 0
				sr_PZero   := .T.
				sr_CodMPM  += ESTRUT->COMP + CHR(13)+ CHR(13)
			EndIf

			ESTRUT->(dbSkip())

		End
		ESTRUT->(dbCloseArea())

		If sr_PZero
			Exit
		EndIf

		fImpCabec()
		kc_First := .T.
		kc_MisTl := 0
		kc_QtdTt := 0
		kc_Perda := 0
		kc_QTUmd := 0
		kc_QTReq := 0

		kc_VetF := aSort(kc_VetF,,,{|x,y| x[1]+x[14]+y[13]+x[2] < y[1]+y[14]+x[13]+y[2] })
		kc_Moage := kc_VetF[1][13]
		For i := 1 To Len(kc_VetF)
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			If kc_First
				oPrint:Say  (nRow1, 0100, "Ref.Sistema: " + Alltrim(kc_VetF[i][1])                                                              , oFont14)
				cft_Rvs := A002->B1_REVATU
				If A002->B1_REVATU <> A002->C2_REVISAO
					cft_Rvs := A002->C2_REVISAO
				EndIf
				If Empty(cft_Rvs)
					cft_Rvs := "000"
				EndIf
				dfr_RefRev := "Validade: "+dtoc(stod(kc_VetF[i][11]))+ " até: "+dtoc(stod(kc_VetF[i][12]))
				oPrint:Say  (nRow1, 2300, dfr_RefRev                                                                                            , oFont14)
				nRow1 += 075
				dvf_Descri := Alltrim(Posicione("SB1",1,xFilial("SB1")+kc_VetF[i][1],"B1_DESC"))
				oPrint:Say  (nRow1, 0100, Alltrim(dvf_Descri) +"/"+ cft_Rvs                                                                     , oFont32)
				nRow1 += 150
				xf_Titu := +;
				Padr("Código"                                                                   ,15)+" "+;
				Padr("Componente"                                                               ,50)+" "+;
				Padc("UM"                                                                       ,02)+" "+;
				Padl("Ft_Conv"                                                                  ,10)+" "+;
				Padl("% Mistura"                                                                ,15)+" "+;
				Padl("Massa_Seca"                                                               ,15)+" "+;
				Padl("Umidade"                                                                  ,15)+" "+;
				Padl("Massa_Umida"                                                              ,15)+" "+;
				Padl("REQUISIÇÃO"                                                               ,15)
				oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont10)
				oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
				nRow1 += 075
				kc_First := .F.
			EndIf

			If kc_Moage <> kc_VetF[i][13]
				kc_Moage := kc_VetF[i][13]
				nRow1 += 075
			EndIf

			xf_Item := +;
			Padr(kc_VetF[i][2]                                                              ,15)+" "+;
			Padr(kc_VetF[i][3]                                                              ,50)+" "+;
			Padc(kc_VetF[i][4]                                                              ,02)+" "+;
			Padl(Transform(kc_VetF[i][5], "@E 9,999.99")                                    ,10)+" "+;
			Padl(Transform(kc_VetF[i][6], "@E 999.99")                                      ,15)+" "+;
			Padl(Transform(kc_VetF[i][7], "@E 999,999,999")                                 ,15)+" "+;
			Padl(Transform(kc_VetF[i][8], "@E 999.99")                                      ,15)+" "+;
			Padl(Transform(kc_VetF[i][9], "@E 999,999,999")                                 ,15)+" "+;
			Padl(Transform(kc_VetF[i][10], "@E 999,999,999.99")                             ,15)
			oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont10)
			oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
			nRow1 += 075
			kc_MisTl += kc_VetF[i][6]
			kc_QtdTt += kc_VetF[i][7]
			kc_Perda += kc_VetF[i][7] * kc_VetF[i][8]
			kc_QTUmd += kc_VetF[i][9]
			kc_QTReq += kc_VetF[i][10]
		Next i

		// Tratamento para Retorno de Massa
		If kc_MisTl < 100
			kc_Rejeit := 100 - kc_MisTl
			kc_RejQtd := (wQtd1+wQtd2) * kc_Rejeit / 100
			kc_RejPer := 10
			kc_RejUmd := Round(kc_RejQtd  / ( (100 - kc_RejPer) / 100 ),2)
			xf_Totl := +;
			Padr(""                                                                         ,15)+" "+;
			Padr("MPM 700"                                                                  ,50)+" "+;
			Padc(""                                                                         ,02)+" "+;
			Padl(""                                                                         ,10)+" "+;
			Padl(Transform(kc_Rejeit, "@E 999.99")                                          ,15)+" "+;
			Padl(Transform(kc_RejQtd, "@E 999,999,999")                                     ,15)+" "+;
			Padl(Transform(kc_RejPer, "@E 999.99")                                          ,15)+" "+;
			Padl(Transform(kc_RejUmd, "@E 999,999,999")                                     ,15)+" "+;
			Padl(Transform(0,         "@E 999,999,999.99")                                  ,15)
			oPrint:Say  (nRow1 ,0050 ,xf_Totl                               ,oFont10)
			oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
			nRow1 += 075
			kc_MisTl += kc_Rejeit
			kc_QtdTt += kc_RejQtd
			kc_Perda += kc_RejQtd * kc_RejPer
			kc_QTUmd += kc_RejUmd
			kc_QTReq += 0
		EndIf

		xf_Totl := +;
		Padr("Totais........."                                                          ,15)+" "+;
		Padr(""                                                                         ,50)+" "+;
		Padc(""                                                                         ,02)+" "+;
		Padl(""                                                                         ,10)+" "+;
		Padl(Transform(kc_MisTl, "@E 999.99")                                           ,15)+" "+;
		Padl(Transform(kc_QtdTt, "@E 999,999,999")                                      ,15)+" "+;
		Padl(Transform(kc_Perda/kc_QtdTt, "@E 999.99")                                  ,15)+" "+;
		Padl(Transform(kc_QTUmd, "@E 999,999,999")                                      ,15)+" "+;
		Padl(Transform(kc_QTReq, "@E 999,999,999.99")                                   ,15)
		oPrint:Say  (nRow1 ,0050 ,xf_Totl                               ,oFont10)
		nRow1 += 075

		fImpRoda()

		dbSelectArea("A002")
		dbSkip()
	End
	A002->(dbCloseArea())

	If !sr_PZero
		oPrint:EndPage()
		oPrint:Preview()
	Else

		MsgSTOP("Uma ou mais MPMs não possuem UMIDADE cadastrada para o dia em questão!!!" + CHR(13) + CHR(13) + sr_CodMPM)

	EndIf

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
	oPrint:Say  (nRow1+75 ,0050 ,Padc(fCabec1,110)                                          ,oFont14)

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
	aAdd(aRegs,{cPerg,"01","Número da OP        ?","","","mv_ch1","C",13,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC2"})
	aAdd(aRegs,{cPerg,"02","Quantidade Ref.(Kg) ?","","","mv_ch2","N",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Data de Referência  ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Quant Ref.(Kg)( 2 ) ?","","","mv_ch4","N",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Almoxarifado        ?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","NNR"})
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
