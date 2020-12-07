#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "buttom.ch"

User Function BIA406()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ BIA406   ºAutor  ³ Wanisay William    º Data ³  13/02/08   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³   Apuracao PIS/COFINS 12/24/48 Meses.                      º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ MP 811                                                     º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	cHInicio := Time()
	fPerg := "BIA405"
	//ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	lOk := .T.
	cCLVL := ""
	aCLVL := {}
	do while lOk
		@ 000,000 TO 150,350 DIALOG oDialog TITLE "Selecao"
		@ 005,005 SAY "Digite abaixo separando por ; cada classe de valor:"
		@ 020,005 GET cCLVL SIZE 130,050 MEMO
		@ 060,140 BMPBUTTON TYPE BT_OK ACTION fFinaliza()
		ACTIVATE DIALOG oDialog CENTERED
		IF len(aCLVL) == 0
			cCLVL := "''"
		ENDIF
	enddo

	//valida primeiro dia do mes caso o Imposto seja gravado
	IF SUBSTR(DTOS(MV_PAR08),7,2) <> '01' .AND. MV_PAR06 == 1
		Msgbox("Data de gravacao incorreta. Digite o primeiro dia do mes!","STOP")
	ENDIF

	IF MV_PAR05 == 1 .OR. MV_PAR05 == 3
		Processa({|| RptDet_1()})
	ELSE
		Processa({|| RptDet_2()})
	ENDIF

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ RptDet_1 ¦ Autor ¦ Wanisay WilliamS      ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RptDet_1()

	Local i  := 0
	Local j  := 0
	Local aMeses := {}

	IF cEmpAnt == '01'
		aBitmap  := "LOGOPRI01.BMP"
	ELSE
		aBitmap  := "LOGOPRI05.BMP"
	ENDIF
	fCabec   := "Demonstrativo de crédito do PIS/COFINS do Ativo Permanente "
	fCabec2  := "(Lei nº 10.637 - 30/12/02 e 10.833 - 29/12/03 aquisições efetuadas entre 01/10/04 e 31/12/05)"
	wnPag    := 0
	nRow1    := 0

	CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()

	fImpCabec()

	//Tratar as compras com PIS e COFINS
	A0001 := " SELECT D1_FILIAL, D1_DTDIGIT AS DATA_DIG, D1_DOC, D1_CLVL, D1_TES, D1_CF, "
	A0001 += " D1_SERIE, D1_FORNECE, D1_LOJA, A2_NOME, SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,D1_DTDIGIT),113),4,10) AS ANO, "
	A0001 += " SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE-D1_VALDESC) AS F1_VALBRUT, SUM(D1_BASIMP5) AS D1_BASIMP5, SUM(D1_VALIMP6) AS D1_VALIMP6, SUM(D1_VALIMP5) AS D1_VALIMP5 "
	A0001 += " FROM "+RetSqlName("SD1")+" SD1, SA2010 SA2, SB1010 SB1 "
	A0001 += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
	A0001 += " AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	A0001 += " AND D1_FORNECE = A2_COD "
	A0001 += " AND D1_LOJA = A2_LOJA "
	A0001 += " AND D1_COD = B1_COD "
	IF MV_PAR09 == 1
		A0001 += " AND D1_YFECH = 'S' "
	ENDIF
	IF MV_PAR09 == 2
		A0001 += " AND D1_YFECH <> 'S' "
	ENDIF
	IF MV_PAR10 == 1
		A0001 += " AND ((SUBSTRING(D1_CF,2,3) = '551' OR SUBSTRING(D1_YREGRA,1,1) IN('I','P') ) AND SUBSTRING(D1_YREGRA,1,1) <> 'D' "
	ENDIF
	IF MV_PAR10 == 2
		A0001 += " AND ((SUBSTRING(D1_CF,2,3) = '551' OR SUBSTRING(D1_YREGRA,1,1) = 'D') AND SUBSTRING(D1_YREGRA,1,1) NOT IN('I','P')  ""
	ENDIF
	A0001 += " AND (D1_CLVL NOT IN ('1000') AND D1_CLVL <> ' ' AND D1_CLVL NOT IN ("+ALLTRIM(cCLVL)+") AND D1_CLVL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
	A0001 += " OR (D1_DOC = '330712' AND D1_FORNECE = '002372')  "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " OR (D1_DOC = '048468' AND D1_FORNECE = '005619')  "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " OR (D1_DOC = '000111' AND D1_FORNECE = '003257')  "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " OR (D1_DOC = '000112' AND D1_FORNECE = '003257')  "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " OR (D1_DOC = '000113' AND D1_FORNECE = '003257')  "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " OR (D1_DOC = '000888' AND D1_FORNECE = '003563')  "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " OR (D1_DOC = '479422' AND D1_FORNECE = '006658')  "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " OR (D1_DOC = '479096' AND D1_FORNECE = '006658')) "    //Nota fiscal com Classe de Valor incorreta.
	A0001 += " AND D1_VALIMP5+D1_VALIMP6 > 0  "
	A0001 += " AND D1_YREGRA <> 'IZ' "
	A0001 += " AND SD1.D_E_L_E_T_ = ' ' "
	A0001 += " AND SA2.D_E_L_E_T_ = ' ' "
	A0001 += " AND SB1.D_E_L_E_T_ = ' ' "
	A0001 += " GROUP BY D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_CLVL, D1_TES, D1_CF, "
	A0001 += " D1_SERIE, D1_FORNECE, D1_LOJA, A2_NOME, SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,D1_DTDIGIT),113),4,10) "
	A0001 += " ORDER BY D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_CLVL, D1_TES, D1_CF, "
	A0001 += " D1_SERIE, D1_FORNECE, D1_LOJA, A2_NOME, SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,D1_DTDIGIT),113),4,10) "
	TcQuery A0001 New Alias "A001"

	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())

	kp_Valor1 := 0
	kp_Valor2 := 0
	kp_Valor3 := 0

	kp_Vlrbas := 0
	kp_VlrPis := 0
	kp_VlrCof := 0

	nCont     := 0

	While !Eof()
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Atualizando....    Tempo: "+cTempo)

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		//Tratar excessoes solicitadas pela Tania
		//(A001->D1_DOC == '948402' .AND. A001->D1_FORNECE == '003305') .OR.;
		IF (A001->D1_DOC == '003710' .AND. A001->D1_FORNECE == '000608') .OR.;
		(A001->D1_DOC == '008337' .AND. A001->D1_FORNECE == '000765') .OR.;
		(A001->D1_DOC == '007665' .AND. A001->D1_FORNECE == '003090') .OR.;
		(A001->D1_DOC == '107707' .AND. A001->D1_FORNECE == '003572')
			DbSelectArea("A001")
			DbSkip()
			Loop
		ENDIF

		//Para casos de classes de valores de investimento, as notas foram apropriadas dentro do mes e o imposto ja foi creditado.
		IF (SUBSTR(MV_PAR03,1,1) == '8' .OR. SUBSTR(MV_PAR04,1,1) == '8') .AND. A001->D1_DOC $ '048468/330712/048468'
			DbSelectArea("A001")
			DbSkip()
			Loop
		ENDIF

		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek(xFilial("SD1")+A001->D1_DOC+A001->D1_SERIE+A001->D1_FORNECE+A001->D1_LOJA)
		cRegra := SPACE(2)

		// Ajuste efetuado para atender a OS effettivo 2271-12 e seguintes que usam este variável: htRegraOk
		htRegraOk := .T.
		While SD1->D1_DOC     == A001->D1_DOC     .AND. SD1->D1_SERIE == A001->D1_SERIE .AND.;
		SD1->D1_FORNECE == A001->D1_FORNECE .AND. SD1->D1_LOJA  == A001->D1_LOJA  .AND. !EOF()
			IF SD1->D1_YREGRA $ 'I1_I2_I4_D1_D2_D4_IA_IB_IC_ID_IE_IF_IG_IH_II_IJ_IK_DA_DB_DC_DD_DE_DF_DG_DH_DI_DJ_DK_P ' .AND. A001->D1_CLVL == SD1->D1_CLVL
				//IF ALLTRIM(SD1->D1_CLVL) = '8051'
				//Reclock("SD1",.F.)
				//SD1->D1_YREGRA := 'I1'
				//MsUnLock()
				//ENDIF
				cRegra := SD1->D1_YREGRA
				Exit
			ENDIF

			//If Alltrim(SD1->D1_YREGRA) $ "N" .and. dtos(SD1->D1_DTDIGIT) >= "20120701"
			//	htRegraOk := .F.
			//EndIf

			DbSelectArea("SD1")
			DbSkip()
		End

		If !htRegraOk
			dbSelectArea("A001")
			dbSkip()
			Loop
		EndIf

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SD1->D1_COD)

		xf_Item := +;
		Padc(STOD(A001->DATA_DIG)		                                                             ,08)+"  "+;
		Padr(A001->D1_DOC                                                                            ,09)+"  "+;
		Padr(cRegra                                                                                  ,06)+"  "+;
		Padr(A001->A2_NOME                                                                           ,30)+"  "+;
		Padr(SB1->B1_DESC                                                                            ,30)+"  "+;
		Padl(Transform(A001->F1_VALBRUT,  "@E 9,999,999.99")                                         ,12)+"  "+;
		Padl(Transform(A001->D1_BASIMP5,  "@E 9,999,999.99")                                         ,12)+"  "+;
		Padl(Transform(Round(A001->D1_VALIMP6/A001->D1_BASIMP5*100,2), "@E 9.99")                    ,04)+"  "+;
		Padl(Transform(A001->D1_VALIMP6,  "@E 9,999,999.99")                                         ,12)+"  "+;
		Padl(Transform(Round(A001->D1_VALIMP5/A001->D1_BASIMP5*100,2), "@E 9.99")                    ,04)+"  "+;
		Padl(Transform(A001->D1_VALIMP5,  "@E 9,999,999.99")                                         ,12)+"  "+;
		Padr(A001->D1_CLVL                                                                           ,10)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050

		kp_Valor1 += A001->D1_BASIMP5
		kp_Valor2 += A001->D1_VALIMP6
		kp_Valor3 += A001->D1_VALIMP5

		kp_Vlrbas := A001->D1_BASIMP5
		kp_VlrPis := A001->D1_VALIMP6
		kp_VlrCof := A001->D1_VALIMP5

		IF MV_PAR05 <> 3
			DO CASE
				CASE SD1->D1_YREGRA == 'I1' .OR. SD1->D1_YREGRA == 'D1'
				j := 12
				CASE SD1->D1_YREGRA == 'I2' .OR. SD1->D1_YREGRA == 'D2'
				j := 24
				CASE SD1->D1_YREGRA == 'I4' .OR. SD1->D1_YREGRA == 'D4'
				j := 48
				// Criada tabela ZK no SX5 e incluidas regras neste programa em 08/08/11 por Marcos Alberto
				CASE SD1->D1_YREGRA == 'IA' .OR. SD1->D1_YREGRA == 'DA'
				j := 11
				CASE SD1->D1_YREGRA == 'IB' .OR. SD1->D1_YREGRA == 'DB'
				j := 10
				CASE SD1->D1_YREGRA == 'IC' .OR. SD1->D1_YREGRA == 'DC'
				j := 09
				CASE SD1->D1_YREGRA == 'ID' .OR. SD1->D1_YREGRA == 'DD'
				j := 08
				CASE SD1->D1_YREGRA == 'IE' .OR. SD1->D1_YREGRA == 'DE'
				j := 07
				CASE SD1->D1_YREGRA == 'IF' .OR. SD1->D1_YREGRA == 'DF'
				j := 06
				CASE SD1->D1_YREGRA == 'IG' .OR. SD1->D1_YREGRA == 'DG'
				j := 05
				CASE SD1->D1_YREGRA == 'IH' .OR. SD1->D1_YREGRA == 'DH'
				j := 04
				CASE SD1->D1_YREGRA == 'II' .OR. SD1->D1_YREGRA == 'DI'
				j := 03
				CASE SD1->D1_YREGRA == 'IJ' .OR. SD1->D1_YREGRA == 'DJ'
				j := 02
				CASE SD1->D1_YREGRA == 'IK' .OR. SD1->D1_YREGRA == 'DK'
				j := 01
				CASE SD1->D1_YREGRA == 'P ' // Toda REGRA == 'P ' foi implantada por Marcos Alberto em 05/07/12 conforme OS Effettivo 1416-12
				j := 01
				OTHERWISE
				j := 0
			ENDCASE
		ELSE
			DO CASE
				CASE MV_PAR07 == 1
				j := 12
				CASE MV_PAR07 == 2
				j := 24
				CASE MV_PAR07 == 3
				j := 48
				OTHERWISE
				j := 0
			ENDCASE
		ENDIF

		dDataFim := mv_par08 - 1 //Ultimo dia do mes anterior ao MV_PAR08
		IF MV_PAR06 == 1
			FOR i := 1 TO j STEP 1
				IF MOD(YEAR(dDataFim),4) == 0
					aMeses := {31,29,31,30,31,30,31,31,30,31,30,31}
				ELSE
					aMeses := {31,28,31,30,31,30,31,31,30,31,30,31}
				ENDIF
				dDataFim := dDataFim + 1
				dDataIni := dDataFim
				dDataFim := CTOD(str(aMeses[MONTH(dDataFim)])+"/"+strzero(MONTH(dDataFim),2)+"/"+substr(strzero(YEAR(dDataFim),4),3,2))
				nCont    := nCont + 1

				DbSelectArea("SZ8")
				DbSetOrder(2)
				IF DbSeek(xFilial("SZ8")+SD1->D1_YREGRA+DTOS(MV_PAR08)+DTOS(dDataFim))
					IF nCont == 1
						MsgBox("Registro ja gravado para esta data e tipo. Favor avaliar se rotina ja foi executada para este mes ou classe de valor","STOP")
					ENDIF
					RecLock("SZ8",.F.)
					SZ8->Z8_FILIAL  := xFilial("SZ8")
					SZ8->Z8_BASIMP5 := SZ8->Z8_BASIMP5 + kp_Vlrbas
					SZ8->Z8_BASIMP6 := SZ8->Z8_BASIMP6 + kp_Vlrbas
					SZ8->Z8_VALIMP5 := SZ8->Z8_VALIMP5 + kp_VlrCof/j
					SZ8->Z8_VALIMP6 := SZ8->Z8_VALIMP6 + kp_VlrPis/j
				ELSE
					RecLock("SZ8",.T.)
					SZ8->Z8_FILIAL  := xFilial("SZ8")
					SZ8->Z8_TIPO    := SD1->D1_YREGRA
					SZ8->Z8_DTGER   := MV_PAR08
					SZ8->Z8_DTRATIN := dDataIni
					SZ8->Z8_DTRATFI := dDataFim
					SZ8->Z8_BASIMP5 := kp_Vlrbas
					SZ8->Z8_BASIMP6 := kp_Vlrbas
					SZ8->Z8_VALIMP5 := kp_VlrCof/j
					SZ8->Z8_VALIMP6 := kp_VlrPis/j
				ENDIF
				MsUnLock()
			Next i

			DbSelectArea("SD1")
			DbSetOrder(1)
			DbSeek(xFilial("SD1")+A001->D1_DOC+A001->D1_SERIE+A001->D1_FORNECE+A001->D1_LOJA)

			While SD1->D1_DOC == A001->D1_DOC .AND. SD1->D1_SERIE == A001->D1_SERIE .AND.;
			SD1->D1_FORNECE == A001->D1_FORNECE .AND. SD1->D1_LOJA  == A001->D1_LOJA  .AND. !EOF()
				IF (SUBSTR(SD1->D1_YREGRA,1,1) $ "I/P" .OR. SUBSTR(SD1->D1_YREGRA,1,1) = "D") .AND. SD1->D1_YFECH <> "S" .AND. A001->D1_CLVL == SD1->D1_CLVL
					RecLock("SD1",.F.)
					SD1->D1_YFECH := "S"
					MsUnLock()
				ENDIF
				DbSelectArea("SD1")
				DbSkip()
			End
		ENDIF

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		DbSelectArea("A001")
		DbSkip()
	End

	//Tratar as Devolucoes de compras com PIS e COFINS
	A0002 := " SELECT D2_FILIAL, D2_EMISSAO AS DATA_DIG, D2_DOC, D2_CLVL, D2_TES, D2_CF, "
	A0002 += " D2_SERIE, D2_CLIENTE, D2_LOJA, A2_NOME, SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,D2_EMISSAO),113),4,10) AS ANO, "
	A0002 += " SUM(D2_TOTAL+D2_VALIPI+D2_VALFRE) AS F2_VALBRUT, SUM(D2_BASIMP5) AS D2_BASIMP5, SUM(D2_VALIMP6) AS D2_VALIMP6, SUM(D2_VALIMP5) AS D2_VALIMP5 "
	A0002 += " FROM "+RetSqlName("SD2")+" SD2, SA2010 SA2, SB1010 SB1 "
	A0002 += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
	A0002 += " AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	A0002 += " AND D2_CLIENTE = A2_COD "
	A0002 += " AND D2_LOJA = A2_LOJA "
	A0002 += " AND D2_COD = B1_COD "
	IF MV_PAR09 == 1
		A0002 += " AND D2_YFECH = 'S' "
	ENDIF
	IF MV_PAR09 == 2
		A0002 += " AND D2_YFECH <> 'S' "
	ENDIF
	A0002 += " AND SUBSTRING(D2_CF,2,3) IN ('555','553') "
	A0002 += " AND D2_VALIMP5+D2_VALIMP6 > 0  "
	A0002 += " AND SD2.D_E_L_E_T_ = ' ' "
	A0002 += " AND SA2.D_E_L_E_T_ = ' ' "
	A0002 += " AND SB1.D_E_L_E_T_ = ' ' "
	A0002 += " GROUP BY D2_FILIAL, D2_EMISSAO, D2_DOC, D2_CLVL, D2_TES, D2_CF, "
	A0002 += " D2_SERIE, D2_CLIENTE, D2_LOJA, A2_NOME, SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,D2_EMISSAO),113),4,10) "
	A0002 += " ORDER BY D2_FILIAL, D2_EMISSAO, D2_DOC, D2_CLVL, D2_TES, D2_CF, "
	A0002 += " D2_SERIE, D2_CLIENTE, D2_LOJA, A2_NOME, SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,D2_EMISSAO),113),4,10) "
	TcQuery A0002 New Alias "A002"

	dbSelectArea("A002")
	dbGoTop()
	ProcRegua(RecCount())
	nCont := 0

	While !Eof()
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Atualizando....    Tempo: "+cTempo)

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek(xFilial("SD2")+A002->D2_DOC+A002->D2_SERIE+A002->D2_CLIENTE+A002->D2_LOJA)

		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek(xFilial("SD1")+SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA)
		cRegra := SPACE(2)

		IF SD1->D1_CLVL < MV_PAR03 .OR. SD1->D1_CLVL > MV_PAR04
			DbSelectArea("A002")
			DbSkip()
			Loop
		ENDIF

		// Ajuste efetuado para atender a OS effettivo 2271-12 e seguintes que usam este variável: htRegraOk
		htRegraOk := .T.
		While SD1->D1_DOC   == SD2->D2_NFORI   .AND. SD1->D1_SERIE == SD2->D2_SERIORI .AND.;
		SD1->D1_FORNECE == SD2->D2_CLIENTE .AND. SD1->D1_LOJA  == SD2->D2_LOJA    .AND. !EOF()
			IF SD1->D1_YREGRA $ 'I1_I2_I4_D1_D2_D4_IA_IB_IC_ID_IE_IF_IG_IH_II_IJ_IK_DA_DB_DC_DD_DE_DF_DG_DH_DI_DJ_DK_P '
				//IF ALLTRIM(SD1->D1_CLVL) = '8051'
				//Reclock("SD1",.F.)
				//SD1->D1_YREGRA := 'I1'
				//MsUnLock()
				//ENDIF
				cRegra := SD1->D1_YREGRA
				Exit
			ENDIF

			//If Alltrim(SD1->D1_YREGRA) $ "N" .and. dtos(SD1->D1_DTDIGIT) >= "20120701"
			//	htRegraOk := .F.
			//EndIf

			DbSelectArea("SD1")
			DbSkip()
		End

		If !htRegraOk
			dbSelectArea("A001")
			dbSkip()
			Loop
		EndIf

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SD2->D2_COD)

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)

		xf_Item := +;
		Padc(STOD(A002->DATA_DIG)	                                                                 ,08)+"  "+;
		Padr(A002->D2_DOC                                                                            ,09)+"  "+;
		Padr(cRegra                                                                                  ,06)+"  "+;
		Padr(SA2->A2_NOME                                                                            ,30)+"  "+;
		Padr(SB1->B1_DESC                                                                            ,30)+"  "+;
		Padl(Transform(A002->F2_VALBRUT*(-1),  "@E 9,999,999.99")                                    ,12)+"  "+;
		Padl(Transform(A002->D2_BASIMP5*(-1),  "@E 9,999,999.99")                                    ,13)+"  "+;
		Padl(Transform(Round(A002->D2_VALIMP6/A002->D2_BASIMP5*100,2), "@E 9.99")                    ,04)+"  "+;
		Padl(Transform(A002->D2_VALIMP6*(-1),  "@E 9,999,999.99")                                    ,13)+"  "+;
		Padl(Transform(Round(A002->D2_VALIMP5/A002->D2_BASIMP5*100,2), "@E 9.99")                    ,04)+"  "+;
		Padl(Transform(A002->D2_VALIMP5*(-1),  "@E 9,999,999.99")                                    ,13)+"  "+;
		Padr(SD1->D1_CLVL                                                                            ,10)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050

		kp_Valor1 -= A002->D2_BASIMP5
		kp_Valor2 -= A002->D2_VALIMP6
		kp_Valor3 -= A002->D2_VALIMP5

		kp_Vlrbas := A002->D2_BASIMP5
		kp_VlrPis := A002->D2_VALIMP6
		kp_VlrCof := A002->D2_VALIMP5

		IF MV_PAR05 <> 3
			DO CASE
				CASE SD1->D1_YREGRA == 'I1' .OR. SD1->D1_YREGRA == 'D1'
				j := 12
				CASE SD1->D1_YREGRA == 'I2' .OR. SD1->D1_YREGRA == 'D2'
				j := 24
				CASE SD1->D1_YREGRA == 'I4' .OR. SD1->D1_YREGRA == 'D4'
				j := 48
				// Criada tabela ZK no SX5 e incluidas regras neste programa em 08/08/11 por Marcos Alberto
				CASE SD1->D1_YREGRA == 'IA' .OR. SD1->D1_YREGRA == 'DA'
				j := 11
				CASE SD1->D1_YREGRA == 'IB' .OR. SD1->D1_YREGRA == 'DB'
				j := 10
				CASE SD1->D1_YREGRA == 'IC' .OR. SD1->D1_YREGRA == 'DC'
				j := 09
				CASE SD1->D1_YREGRA == 'ID' .OR. SD1->D1_YREGRA == 'DD'
				j := 08
				CASE SD1->D1_YREGRA == 'IE' .OR. SD1->D1_YREGRA == 'DE'
				j := 07
				CASE SD1->D1_YREGRA == 'IF' .OR. SD1->D1_YREGRA == 'DF'
				j := 06
				CASE SD1->D1_YREGRA == 'IG' .OR. SD1->D1_YREGRA == 'DG'
				j := 05
				CASE SD1->D1_YREGRA == 'IH' .OR. SD1->D1_YREGRA == 'DH'
				j := 04
				CASE SD1->D1_YREGRA == 'II' .OR. SD1->D1_YREGRA == 'DI'
				j := 03
				CASE SD1->D1_YREGRA == 'IJ' .OR. SD1->D1_YREGRA == 'DJ'
				j := 02
				CASE SD1->D1_YREGRA == 'IK' .OR. SD1->D1_YREGRA == 'DK'
				j := 01
				CASE SD1->D1_YREGRA == 'P '
				j := 01
				OTHERWISE
				j := 0
			ENDCASE
		ELSE
			DO CASE
				CASE MV_PAR07 == 1
				j := 12
				CASE MV_PAR07 == 2
				j := 24
				CASE MV_PAR07 == 3
				j := 48
				OTHERWISE
				j := 0
			ENDCASE
		ENDIF

		dDataFim := mv_par08 - 1 //Ultimo dia do mes anterior ao MV_PAR08
		IF MV_PAR06 == 1
			FOR i := 1 TO j STEP 1
				IF MOD(YEAR(dDataFim),4) == 0
					aMeses := {31,29,31,30,31,30,31,31,30,31,30,31}
				ELSE
					aMeses := {31,28,31,30,31,30,31,31,30,31,30,31}
				ENDIF
				dDataFim := dDataFim + 1
				dDataIni := dDataFim
				dDataFim := CTOD(str(aMeses[MONTH(dDataFim)])+"/"+strzero(MONTH(dDataFim),2)+"/"+substr(strzero(YEAR(dDataFim),4),3,2))
				nCont    := nCont + 1

				DbSelectArea("SZ8")
				DbSetOrder(2)
				IF DbSeek(xFilial("SZ8")+SD1->D1_YREGRA+DTOS(MV_PAR08)+DTOS(dDataFim))
					IF nCont == 1
						MsgBox("Registro ja gravado para esta data e tipo. Favor avaliar se rotina ja foi executada para este mes ou classe de valor","STOP")
					ENDIF
					RecLock("SZ8",.F.)
					SZ8->Z8_FILIAL  := xFilial("SZ8")
					SZ8->Z8_BASIMP5 := SZ8->Z8_BASIMP5 - kp_Vlrbas
					SZ8->Z8_BASIMP6 := SZ8->Z8_BASIMP6 - kp_Vlrbas
					SZ8->Z8_VALIMP5 := SZ8->Z8_VALIMP5 - kp_VlrCof/j
					SZ8->Z8_VALIMP6 := SZ8->Z8_VALIMP6 - kp_VlrPis/j
				ELSE
					RecLock("SZ8",.T.)
					SZ8->Z8_FILIAL  := xFilial("SZ8")
					SZ8->Z8_TIPO    := SD1->D1_YREGRA
					SZ8->Z8_DTGER   := MV_PAR08
					SZ8->Z8_DTRATIN := dDataIni
					SZ8->Z8_DTRATFI := dDataFim
					SZ8->Z8_BASIMP5 := kp_Vlrbas   * (-1)
					SZ8->Z8_BASIMP6 := kp_Vlrbas   * (-1)
					SZ8->Z8_VALIMP5 := kp_VlrCof/j * (-1)
					SZ8->Z8_VALIMP6 := kp_VlrPis/j * (-1)
				ENDIF
				MsUnLock()
			Next i

			DbSelectArea("SD2")
			DbSetOrder(3)
			DbSeek(xFilial("SD2")+A002->D2_DOC+A002->D2_SERIE+A002->D2_CLIENTE+A002->D2_LOJA)

			While SD2->D2_DOC == A002->D2_DOC .AND. SD2->D2_SERIE == A002->D2_SERIE .AND.;
			SD2->D2_CLIENTE == A002->D2_CLIENTE .AND. SD2->D2_LOJA  == A002->D2_LOJA  .AND. !EOF()
				IF SD2->D2_YFECH <> "S"
					RecLock("SD2",.F.)
					SD2->D2_YFECH := "S"
					MsUnLock()
				ENDIF
				DbSelectArea("SD2")
				DbSkip()
			End
		ENDIF

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		DbSelectArea("A002")
		DbSkip()
	End

	nRow1 += 050
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf

	xf_total := +;
	Padc(""							                                                             ,08)+"  "+;
	Padr(""                                                                                      ,09)+"  "+;
	Padr(""                                                                                      ,06)+"  "+;
	Padr("Total"                                                                                 ,30)+"  "+;
	Padr(""                                                                                      ,30)+"  "+;
	Padl(""                                                                                      ,12)+"  "+;
	Padl(Transform(kp_Valor1,  "@E 99,999,999.99")                                               ,13)+"  "+;
	Padl(""                                                                                      ,04)+"  "+;
	Padl(Transform(kp_Valor2,  "@E 99,999,999.99")                                               ,13)+"  "+;
	Padl(""                                                                                      ,04)+"  "+;
	Padl(Transform(kp_Valor3,  "@E 99,999,999.99")                                               ,13)+"  "+;
	Padr(""                                                                                      ,10)
	oPrint:Say  (nRow1 ,0010 ,xf_total  ,oFont8)
	nRow1 += 050
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

	A001->(dbCloseArea())
	A002->(dbCloseArea())

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay WilliamS      ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
	EndIf
	nRow1 += 025
	oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
	oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
	oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
	nRow1 += 075
	oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
	nRow1 += 150

	xf_Titu := +;
	Padc("Data"                       ,08)+"  "+;
	Padr("Nota Fiscal"                ,09)+"  "+;
	Padr("Regra"                      ,06)+"  "+;
	Padr("Fornecedor"                 ,30)+"  "+;
	Padr("Descricao do Produto"       ,30)+"  "+;
	Padl("Valor NF"                   ,12)+"  "+;
	Padl("B.Calculo"                  ,13)+"  "+;
	Padl("Aliq.(%)"                   ,04)+"  "+;
	Padl("PIS"                        ,13)+"  "+;
	Padl("Aliq.(%)"                   ,04)+"  "+;
	Padl("COFINS"                     ,13)+"  "+;
	Padr("CLVL"                       ,10)

	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

	nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ RptDet_2 ¦ Autor ¦ Wanisay WilliamS      ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RptDet_2()

	IF cEmpAnt == '01'
		aBitmap  := "LOGOPRI01.BMP"
	ELSE
		aBitmap  := "LOGOPRI05.BMP"
	ENDIF
	fCabec   := "Demonstrativo de crédito do PIS/COFINS do Ativo Permanente"
	fCabec2  := "(Lei nº 10.637 - 30/12/02 e 10.833 - 29/12/03 aquisições efetuadas entre 01/10/04 e 31/12/05)"
	wnPag    := 0
	nRow1    := 0

	CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()

	fImpCabec()

	//Tratar valores acumulados de PIS/COFINS
	A0003 := " SELECT SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,Z8_DTRATFI),113),4,10) AS MESANO, SUM(Z8_VALIMP5) AS Z8_VALIMP5, "
	A0003 += "        SUM(Z8_VALIMP6) AS Z8_VALIMP6 "
	A0003 += "   FROM "+RetSqlName("SZ8")+" SZ8 "
	A0003 += "  WHERE Z8_FILIAL = '"+xFilial("SZ8")+"' "
	A0003 += "    AND Z8_DTGER <= '"+dtos(MV_PAR02)+"' "
	A0003 += "    AND Z8_DTRATFI BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	A0003 += "    AND SZ8.D_E_L_E_T_ = ' ' "
	A0003 += "  GROUP BY SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,Z8_DTRATFI),113),4,10) "
	A0003 += "  ORDER BY SUBSTRING(CONVERT(VARCHAR(12),CONVERT(DATETIME,Z8_DTRATFI),113),4,10) "
	TcQuery A0003 New Alias "A003"

	DbSelectArea("A003")
	DbGoTop()
	ProcRegua(RecCount())

	kp_Valor1 := 0
	kp_Valor2 := 0

	While !Eof()
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Atualizando....    Tempo: "+cTempo)

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		xf_Item := +;
		Padc(A003->MESANO   			                                                             ,10)+"  "+;
		Padl(Transform(A003->Z8_VALIMP5,  "@E 999,999,999.99")                                       ,14)+"  "+;
		Padl(Transform(A003->Z8_VALIMP6,  "@E 999,999,999.99")                                       ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050

		kp_Valor1 += A003->Z8_VALIMP5
		kp_Valor2 += A003->Z8_VALIMP6

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		DbSelectArea("A003")
		DbSkip()
	End

	nRow1 += 050
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf

	xf_total := +;
	Padr("Total"                                                                                 ,10)+"  "+;
	Padl(Transform(kp_Valor1,  "@E 999,999,999.99")                                              ,14)+"  "+;
	Padl(Transform(kp_Valor2,  "@E 999,999,999.99")                                              ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_total  ,oFont8)
	nRow1 += 050
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

	A003->(dbCloseArea())

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 010, 2300, 3550)
	oPrint:Say  (2300+30 , 010,"Prog.: BIA406"                                        ,oFont7)
	oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	local j,i
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,6)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Classe de Valor Inicial?","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTT"})
	aAdd(aRegs,{cPerg,"04","Classe de Valor Final  ?","","","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT"})
	aAdd(aRegs,{cPerg,"05","Tipo do Relatorio      ?","","","mv_ch5","C",01,0,0,"C","","mv_par05","Mensal","Mensal","Mensal","","","Acumulado","Acumulado","Acumulado","","","Por CCusto","Por CCusto","Por CCusto","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Grava Dados            ?","","","mv_ch6","C",01,0,0,"C","","mv_par06","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Tipo do Rateio         ?","","","mv_ch7","C",01,0,0,"C","","mv_par07","12 meses","12 meses","12 meses","","","24 meses","24 meses","24 meses","","","48 meses","48 meses","48 meses","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","A Partir da Data       ?","","","mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Itens ja encerrados    ?","","","mv_ch9","C",01,0,0,"C","","mv_par09","Sim","Sim","Sim","","","Nao","Nao","Nao","","","Ambos","Ambos","Ambos","","","","","","","","","","","",""})
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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fFinaliza¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fFinaliza()

	Local nI

	aCLVL := {}
	do while len(cCLVL) > 0
		nPosC := at(";",cCLVL)
		if nPosC > 0
			cString := substr(cCLVL,1,nPosC-1)
		else
			cString := substr(cCLVL,1)
		endif

		cCLVL := cString
		nI    := 1
		do while .T.
			cAux := substr(cCLVL,nI,1)
			if ((Asc(cAux) < 32) .OR. (Asc(cAux) > 126)) .AND. (len(cCLVL) > 0)
				cCLVL := strtran(cCLVL,cAux,"")
				Loop
			else
				nI := nI + 1
			endif
			if nI >= len(cCLVL)
				Exit
			endif
		enddo
		cCLVL := Upper(Alltrim(cCLVL))

		if !empty(cCLVL) .AND. (ASCAN(aCLVL,cCLVL) == 0)
			AADD(aCLVL,cCLVL)
		endif

		cCLVL := substr(cCLVL,len(cString)+2)
	enddo

	asort(aCLVL)
	cCLVL := ""
	for nI := 1 to len(aCLVL)
		cCLVL := cCLVL + "'" + aCLVL[nI] + "'" + iif(nI<len(aCLVL),",","")
	next

	lOk := .F.
	Close(oDialog)

Return
