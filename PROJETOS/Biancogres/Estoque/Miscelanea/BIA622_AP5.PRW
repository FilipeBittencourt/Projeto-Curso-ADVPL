#include "rwmake.ch"        
#include "buttom.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA622   ³ Autor ³ Cesar Magnago         ³ Data ³ 06/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apropriacao por Aplicacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Compras/Estoque                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BIA622()      

	SetPrvt("CDESC1,CDESC2,CDESC3,WNREL,TAMANHO,TITULO")
	SetPrvt("CSTRING,ARETURN,ALINHA,NLASTKEY,CPERG,ADRIVER")
	SetPrvt("LABORTPRINT,NOMEPROG,WTOTICM,AMESES,CBTXT,CBCONT")
	SetPrvt("LI,M_PAG,CABEC1,CABEC2,NTIPO,_ACAMPOS")
	SetPrvt("_TEMPW,WQTDREG,CQUERY,WSCUSTSD3,WCLVL,WTPAPLIC")
	SetPrvt("WNTOTQTDA,WNTOTCUST,WNTOTQTDAG,WNTOTCUSTG,WNTOTQGER,WNTOTCGERT")
	SetPrvt("WNFLAG,")
	Private accustos   := {}, ccustos

	cDesc1      := "Este programa emitir  um Relatorio de Custo de Manutencao por  "
	cDesc2      := "Aplicacao                                   "
	cDesc3      := ""
	wnrel       :="BIA622"
	Tamanho     := "G"
	titulo      := "Custo de Manutencao por Aplicacao"
	cString     := "SD3"
	aReturn     := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	aLinha      := { }
	nLastKey    := 0
	cPerg       :="BIA622"
	aDriver     := ReadDriver()
	lAbortPrint := .F.
	nomeprog    := "BIA622"
	wTotIcm     := 0
	aAplic      := {"NENHUM","PRODUCAO","MANUTENCAO","MELHORIA","SEGURANÇA","CALIBRAÇÃO"}

	cbtxt := SPACE(10)
	cbcont:= 0
	li    := 1
	m_pag := 1
	cabec1:= "     Produto         Descricao Produto                          TAG            Descricao TAG                          Quantidade    Custo Total R$     Documento   Fornecedor"
	Cabec2:= ""

	nTipo  := IIF(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        // Da Aplicacao                              ³
	//³ mv_par02        // Ate a Aplicacao                           ³
	//³ mv_par03        // Do Grupo                                  ³
	//³ mv_par04        // Ate o Grupo                               ³
	//³ mv_par05        // Da TAG                                    ³
	//³ mv_par06        // Ate a TAG                                 ³
	//³ mv_par07        // Do Periodo                                ³
	//³ mv_par08        // Ate o Periodo                             |
	//³ mv_par09        // Do C.Custo                                ³
	//³ mv_par10        // Ate C.custo                               ³                                    
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.f.,Tamanho)

	pergunte("BIA622",.F.)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	cCustos   := ""
	titulo    := "Custo de Manutencao por Aplicacao "+" Periodo de "+dtoc(mv_par07)+" a "+dtoc(mv_par08)
	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	_aCampos := {   {"APLIC " , "C", 01, 0},;
	{"GRUPO"  , "C", 03, 0},;
	{"PROD "  , "C", 15, 0},;
	{"TAG  "  , "C", 08, 0},;
	{"DOC  "  , "C", 09, 0},;
	{"FORN "  , "C", 06, 0},;
	{"LOJA "  , "C", 02, 0},;
	{"QUANT"  , "N", 11, 4},;
	{"CUSTOT" , "N", 14, 4},;
	{"CLVL"   , "C", 04, 0}}

	_Tempw := CriaTrab(_aCampos)
	DbUseArea(.T.,,_Tempw,"_Tempw")
	DbCreateInd(_Tempw,"CLVL+APLIC+GRUPO+PROD",{||CLVL+APLIC+GRUPO+PROD})

	Processa({|| R622GER() })
	Processa({|| R622IMP() })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R622GER  ³ Autor ³ Cesar Magnago         ³ Data ³ 06/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIA622                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R622GER()

	DbSelectArea("SD3")
	DbSetOrder(6)

	wQtdReg := reccount()
	ProcRegua(wQtdReg)

	cQuery := "SELECT "
	cQuery := cQuery +  "D3_FILIAL, D3_EMISSAO, D3_CLVL, D3_YAPLIC, D3_YTAG, D3_QUANT, D3_CUSTO1, D3_COD, D3_TM, D3_DOC, D3_GRUPO"
	cQuery := cQuery +  " FROM " + retsqlname("SD3")
	cQuery := cQuery +  " WHERE "
	cQuery := cQuery +  " D3_FILIAL  = '"  + xFilial("SD1") + "' AND "
	cQuery := cQuery +  " D3_YAPLIC  >= '" + MV_PAR01 + "' AND "
	cQuery := cQuery +  " D3_YAPLIC  <= '" + MV_PAR02 + "' AND "
	cQuery := cQuery +  " D3_GRUPO   >= '" + MV_PAR03 + "' AND "
	cQuery := cQuery +  " D3_GRUPO   <= '" + MV_PAR04 + "' AND "
	cQuery := cQuery +  " D3_YTAG    >= '" + MV_PAR05 + "' AND "
	cQuery := cQuery +  " D3_YTAG    <= '" + MV_PAR06 + "' AND "
	cQuery := cQuery +  " D3_EMISSAO >= '" + Dtos(MV_PAR07) + "' AND "
	cQuery := cQuery +  " D3_EMISSAO <= '" + Dtos(MV_PAR08) + "' AND "
	cQuery := cQuery +  " D3_CLVL    >= '" + MV_PAR09 + "' AND "
	cQuery := cQuery +  " D3_CLVL    <= '" + MV_PAR10 + "' AND "
	If cEmpAnt == "05" //Somente para Incesa
		cQuery := cQuery +  " SUBSTRING(D3_YTAG,3,2) >= '" + MV_PAR11 + "' AND "
		cQuery := cQuery +  " SUBSTRING(D3_YTAG,3,2) <= '" + MV_PAR12 + "' AND "
	EndIf
	cQuery := cQuery +  " D3_YAPLIC  <> '' AND "
	cQuery := cQuery +  " D3_QUANT   >   0 AND "
	cQuery := cQuery +  " D3_CUSTO1  >   0 AND "
	cQuery := cQuery + "  D_E_L_E_T_ = '' "
	cQuery := cQuery + "  ORDER BY D3_FILIAL, D3_CLVL, D3_YAPLIC, D3_GRUPO, D3_COD"

	TCQUERY cQuery NEW ALIAS "TRBSD3"

	DbSelectArea("TRBSD3")
	DbGotop()

	While ! Eof()

		IncProc("Selecionando Requisicoes...")

		DbselectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+TRBSD3->D3_COD,.F.)

		DbSelectArea("_Tempw")
		RecLock("_Tempw", ! DbSeek(TRBSD3->D3_CLVL+Subs(TRBSD3->D3_CLVL,1,1)+TRBSD3->D3_YAPLIC+TRBSD3->D3_GRUPO+TRBSD3->D3_COD), .F.  )

		_Tempw->CLVL   := TRBSD3->D3_CLVL
		_Tempw->APLIC  := TRBSD3->D3_YAPLIC
		_Tempw->GRUPO  := TRBSD3->D3_GRUPO
		_Tempw->PROD   := TRBSD3->D3_COD
		_Tempw->TAG    := TRBSD3->D3_YTAG
		_Tempw->DOC    := TRBSD3->D3_DOC
		_Tempw->FORN   := SPACE(6)
		_Tempw->LOJA   := SPACE(2)
		_Tempw->QUANT  := If(TRBSD3->D3_TM > "499",_Tempw->QUANT+TRBSD3->D3_QUANT,_Tempw->QUANT-TRBSD3->D3_QUANT)
		_Tempw->CUSTOT := If(TRBSD3->D3_TM > "499",_Tempw->CUSTOT+TRBSD3->D3_CUSTO1,_Tempw->CUSTOT-TRBSD3->D3_CUSTO1)

		DbSelectArea("TRBSD3")
		DbSkip()
	EndDo

	DbCloseArea("TRBSD3")

	DbSelectArea("SD1")
	DbSetOrder(3)

	wQtdReg := reccount()
	ProcRegua(wQtdReg)

	cQuery := "SELECT "
	cQuery := cQuery +  " SD1.D1_FILIAL, SD1.D1_DTDIGIT, SD1.D1_CLVL, SD1.D1_YTAG, SD1.D1_YAPLIC, SD1.D1_QUANT, SD1.D1_CUSTO, SD1.D1_COD, "
	cQuery := cQuery +  " SD1.D1_CF, SD1.D1_TIPO, SD1.D1_FORNECE, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_LOJA, SD1.D1_GRUPO "
	cQuery := cQuery +  " FROM " + retsqlname("SD1")+" SD1, " + retsqlname("SF4") + " SF4 "
	cQuery := cQuery +  " WHERE "
	cQuery := cQuery +  " SD1.D1_FILIAL  = '" +     xFilial("SD1")    + "'      AND "
	cQuery := cQuery +  " SF4.F4_FILIAL  = '" +     xFilial("SF4")    + "'      AND "
	cQuery := cQuery +  " SD1.D1_YAPLIC  >= '" +    MV_PAR01          + "'      AND "
	cQuery := cQuery +  " SD1.D1_YAPLIC  <= '" + 	MV_PAR02          + "'      AND "
	cQuery := cQuery +  " SD1.D1_GRUPO   >= '" + 	MV_PAR03          + "' 		AND "
	cQuery := cQuery +  " SD1.D1_GRUPO   <= '" +	MV_PAR04          + "' 		AND "
	cQuery := cQuery +  " SD1.D1_YTAG    >= '" + 	MV_PAR05          + "' 		AND "
	cQuery := cQuery +  " SD1.D1_YTAG    <= '" + 	MV_PAR06          + "' 		AND "
	cQuery := cQuery +  " SD1.D1_DTDIGIT >= '" + 	Dtos(MV_PAR07)    + "' 		AND "
	cQuery := cQuery +  " SD1.D1_DTDIGIT <= '" + 	Dtos(MV_PAR08)    + "' 		AND "
	cQuery := cQuery +  " SD1.D1_CLVL    >= '" + 	MV_PAR09  	      + "'      AND "
	cQuery := cQuery +  " SD1.D1_CLVL    <= '" +   	MV_PAR10 	      + "'      AND "
	If cEmpAnt == "05"  //Somente para Incesa
		cQuery := cQuery +  " SUBSTRING(D1_YTAG,3,2) >= '" + MV_PAR11 + "'          AND "
		cQuery := cQuery +  " SUBSTRING(D1_YTAG,3,2) <= '" + MV_PAR12 + "'          AND "
	EndIf
	cQuery := cQuery +  " SD1.D1_CF  NOT IN ('1551','2551','3551')         		AND "
	cQuery := cQuery +  " SD1.D1_YAPLIC  <> ''                             		AND "
	cQuery := cQuery +  " SD1.D1_QUANT   >   0                             		AND "
	cQuery := cQuery +  " SD1.D1_CUSTO   >   0                            		AND "
	cQuery := cQuery +  " SD1.D1_TES     = SF4.F4_CODIGO                        AND "
	cQuery := cQuery +  " SF4.F4_ESTOQUE <> 'S'                                 AND "
	cQuery := cQuery +  " SD1.D_E_L_E_T_ = ' '                                  AND "
	cQuery := cQuery +  " SF4.D_E_L_E_T_ = ' '                                      "
	cQuery := cQuery +  " ORDER BY SD1.D1_CLVL, SD1.D1_YAPLIC, SD1.D1_GRUPO, SD1.D1_COD"

	TCQUERY cQuery NEW ALIAS "TRBSD1"

	DbSelectArea("TRBSD1")
	DbGotop()

	While ! Eof()

		IncProc("Selecionando Nota Fiscal de Entrada - Genericos...")

		DbselectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+TRBSD1->D1_COD,.F.)

		DbSelectArea("_Tempw")
		RecLock("_Tempw", ! DbSeek(TRBSD1->D1_CLVL+Subs(TRBSD1->D1_CLVL,1,1)+TRBSD1->D1_YAPLIC+TRBSD1->D1_GRUPO+TRBSD1->D1_COD), .F.  )

		_Tempw->CLVL   := TRBSD1->D1_CLVL
		_Tempw->APLIC  := TRBSD1->D1_YAPLIC
		_Tempw->GRUPO  := TRBSD1->D1_GRUPO
		_Tempw->PROD   := TRBSD1->D1_COD
		_Tempw->TAG    := TRBSD1->D1_YTAG
		_Tempw->DOC    := TRBSD1->D1_DOC
		_Tempw->FORN   := TRBSD1->D1_FORNECE
		_Tempw->LOJA   := TRBSD1->D1_LOJA
		_Tempw->QUANT  := _Tempw->QUANT  + TRBSD1->D1_QUANT
		_Tempw->CUSTOT := _Tempw->CUSTOT + TRBSD1->D1_CUSTO

		DbSelectArea("TRBSD1")
		DbSkip()
	EndDo

	DbCloseArea("TRBSD1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R622IMP  ³ Autor ³ Cesar Magnago         ³ Data ³ 06/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIA622                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R622IMP()
	Private ccant

	DbSelectArea("_Tempw")
	DbGotop()

	wQtdReg := LastRec()
	ProcRegua(wQtdReg)

	GrupoAnt   := _Tempw->GRUPO
	AplicAnt   := _Tempw->APLIC

	wnTotQtdG  := 0
	wnTotCusG  := 0

	wnTotQtdA  := 0
	wnTotCusA  := 0

	nTotCC := 0

	wnTotQGer  := 0
	wnTotCGer  := 0
	wnFlag     := 0

	wsAPLIC    := "0"

	While !Eof()

		li:=55
		wnflag := 1
		If li >= 55
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		EndIf
		ccant      := _Tempw->CLVL
		li++
		CTH->(DbSetOrder(1))
		CTH->(Dbseek(xFilial("CTH")+_Tempw->CLVL))
		@ li,01 PSAY "CLASSE DE VALOR: "+ _Tempw->CLVL +" - "+CTH->CTH_DESC01
		li:= li + 2
		Do while .not. eof() .and. _Tempw->CLVL == ccant
			If li >= 55
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
			EndIf
			If _Tempw->APLIC == "0"
				wsAPLIC := 1
			EndIf
			If _Tempw->APLIC == "1"
				wsAPLIC := 2
			EndIf
			If _Tempw->APLIC == "2"
				wsAPLIC := 3
			EndIf
			If _Tempw->APLIC == "3"
				wsAPLIC := 4
			EndIf
			If _Tempw->APLIC == "4"
				wsAPLIC := 5
			EndIf
			If _Tempw->APLIC == "5"
				wsAPLIC := 6
			EndIf		
			@ li,05 PSAY _Tempw->APLIC
			@ li,06 PSAY " - "
			@ li,09 PSAY aAPLIC[wsAPLIC]
			wnFlag := 1
			li := li + 2

			DbSelectArea("SBM")
			DbSetOrder(1)
			If !DbSeek(xFilial("SBM")+_Tempw->GRUPO,.F.)
				wsGRUPO := "GRUPO INEXISTENTE...."
			Else
				wsGrupo := SBM->BM_DESC
			EndIf

			@ li,05 PSAY _Tempw->GRUPO
			@ li,08 PSAY " - "
			@ li,11 PSAY wsGRUPO
			li := li + 2
			DbSelectArea("_Tempw")

			IncProc("Imprimindo Relatorio...")

			While _Tempw->APLIC == AplicAnt .and. _Tempw->CLVL == ccant

				While _Tempw->GRUPO == GrupoAnt .And. _Tempw->APLIC == AplicAnt

					DbselectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+_Tempw->PROD,.F.)

					If !Empty(_Tempw->FORN)
						DbselectArea("SA2")
						DbSetOrder(1)
						DbSeek(xFilial("SA2")+_Tempw->FORN+_Tempw->LOJA,.F.)
						wNomeForn := SA2->A2_NREDUZ
					Else
						wNomeForn := SPACE(30)
					EndIf

					DbselectArea("SZC")
					DbSetOrder(1)
					DbSeek(xFilial("SZC")+_Tempw->TAG,.F.)

					@ li,05  PSAY _Tempw->PROD
					@ li,21  PSAY SUBS(SB1->B1_DESC,1,40)
					@ li,65  PSAY _Tempw->TAG              PICTURE "@R XX-XXX-XXX"
					@ li,79  PSAY SUBS(SZC->ZC_DESC,1,40)
					@ li,113 PSAY _Tempw->QUANT            PICTURE "@E 999,999,999.99"
					@ li,131 PSAY _Tempw->CUSTOT           PICTURE "@E 999,999,999.99"
					@ li,151 PSAY _Tempw->DOC
					@ li,163 PSAY _Tempw->FORN
					@ li,169 PSAY If(Empty(_Tempw->FORN),"   "," - ")
					@ li,171 PSAY wNomeForn
					li := li + 1

					If li >= 55
						Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
					EndIf

					wnTotQtdG  := wnTotQtdG  + _Tempw->QUANT
					wnTotCusG  := wnTotCusG  + _Tempw->CUSTOT

					wnTotQtdA  := wnTotQtdA  + _Tempw->QUANT
					wnTotCusA  := wnTotCusA  + _Tempw->CUSTOT

					wnTotQGer  := wnTotQGer  + _Tempw->QUANT
					wnTotCGer  := wnTotCGer  + _Tempw->CUSTOT

					nTotCC += _Tempw->CUSTOT

					_Tempw->(DbSkip())

				EndDo

				li := li + 2
				If li >= 55
					Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
				EndIf

				DbSelectArea("SBM")
				DbSetOrder(1)
				DbSeek(xFilial("SBM")+GrupoAnt,.F.)

				@ li,54  PSAY Replicate("-",91)
				li := li + 1
				@ li,54  PSAY "TOTAL DO GRUPO "+GrupoAnt+" "+SUBS(SBM->BM_DESC,1,20)
				@ li,113 PSAY wnTotQtdG        PICTURE "@E 999,999,999.99"
				@ li,131 PSAY wnTotCusG        PICTURE "@E 999,999,999.99"
				li := li + 1
				@ li,54  PSAY Replicate("-",91)
				li := li + 2

				If _Tempw->GRUPO # GrupoAnt .And. _Tempw->(!Eof()) .And. _Tempw->APLIC == AplicAnt
					DbSelectArea("SBM")
					DbSetOrder(1)
					If !DbSeek(xFilial("SBM")+_Tempw->GRUPO,.F.)
						wsGRUPO := "GRUPO INEXISTENTE...."
					Else
						wsGrupo := SBM->BM_DESC
					EndIf

					@ li,05 PSAY _Tempw->GRUPO
					@ li,08 PSAY " - "
					@ li,11 PSAY wsGRUPO
					li := li + 2
				EndIf

				GrupoAnt   := _Tempw->GRUPO
				wnTotQtdG  := 0
				wnTotCusG  := 0
				DbSelectArea("_Tempw")

			EndDo

			If li >= 55
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
			EndIf

			If AplicAnt == "0"
				wsAPLIC := 1
			EndIf
			If AplicAnt == "1"
				wsAPLIC := 2
			EndIf
			If AplicAnt == "2"
				wsAPLIC := 3
			EndIf
			If AplicAnt == "3"
				wsAPLIC := 4
			EndIf
			If AplicAnt == "4"
				wsAPLIC := 5
			EndIf
			If AplicAnt == "5"
				wsAPLIC := 6
			EndIf					
			@ li,54  PSAY Replicate("-",91)
			li := li + 1
			@ li,54  PSAY "TOTAL DA APLICACAO "+AplicAnt+" "+aAplic[wsAPLIC]
			@ li,113 PSAY wnTotQtdA        PICTURE "@E 999,999,999.99"
			@ li,131 PSAY wnTotCusA        PICTURE "@E 999,999,999.99"
			li := li + 1
			@ li,54  PSAY Replicate("-",91)
			wnTotQGer  := wnTotQGer + wnTotQtdA
			//		wnTotCGer  := wnTotCGer + wnTotCusA
			wnTotQtdA  := 0
			wnTotCusA  := 0
			AplicAnt   := _Tempw->APLIC
			li := li + 1

			If AplicAnt == "0"
				wsAPLIC := 1
			EndIf
			If AplicAnt == "1"
				wsAPLIC := 2
			EndIf
			If AplicAnt == "2"
				wsAPLIC := 3
			EndIf
			If AplicAnt == "3"
				wsAPLIC := 4
			EndIf
			If AplicAnt == "4"
				wsAPLIC := 5
			EndIf
			If AplicAnt == "5"
				wsAPLIC := 6
			EndIf					

			DbSelectArea("SBM")
			DbSetOrder(1)
			If !DbSeek(xFilial("SBM")+GrupoAnt,.F.)
				wsGRUPO := "GRUPO INEXISTENTE...."
			Else
				wsGrupo := SBM->BM_DESC
			EndIf
			li := li + 2

			DbSelectArea("_Tempw")
		EndDo
		li++
		@ li,54  PSAY Replicate("-",91)
		li++
		@ li,54  PSAY "TOTAL C.VALOR "+ccant+" "+SUBS(CTH->CTH_DESC01,1,20)
		@ li,131 PSAY ntotCC           PICTURE "@E 999,999,999.99"
		ntotCC:=0
		li := li + 1
		@ li,54  PSAY Replicate("-",91)
		li := li + 2

	EndDo

	If li >= 55
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
	EndIf

	@ li,54  PSAY Replicate("-",91)
	li := li + 1
	@ li,54  PSAY "TOTAL GERAL "
	@ li,131 PSAY wnTotCGer        PICTURE "@E 999,999,999.99"
	li := li + 1
	@ li,54  PSAY Replicate("-",91)
	wnTotQtdA  := 0
	wnTotCusA  := 0

	wnTotQtdG  := 0
	wnTotCusG  := 0

	wnTotQGer  := 0
	wnTotCGer  := 0

	Set device to Screen
	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

	DbSelectArea("_Tempw")
	DbCloseArea("_Tempw")
	If file(_Tempw+".DBF")
		Ferase(_Tempw+".DBF")
		Ferase(_Tempw+".ntx")
	Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fFinaliza  ³ Autor ³ WLADIMIR ILLIUSHENKO 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Finaliza4 digitacao da Selecao de Produtos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA075													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fFinaliza()

	Local nI

	accustos := {}
	do while len(cCustos) > 0
		nPosC := at(";",cCustos)
		if nPosC > 0
			cString := substr(cCustos,1,nPosC-1)
		else
			cString := substr(cCustos,1)
		endif

		cCust := cString
		nI    := 1
		do while .T.
			cAux := substr(cCust,nI,1)
			if ((Asc(cAux) < 32) .OR. (Asc(cAux) > 126)) .AND. (len(cCust) > 0)
				cCust := strtran(cCust,cAux,"")
				Loop
			else
				nI := nI + 1
			endif
			if nI >= len(cCust)
				Exit
			endif
		enddo
		cCust := Upper(Alltrim(cCust))

		if !empty(cCust) .AND. (ASCAN(acCustos,cCust) == 0)
			AADD(acCustos,cCust)
		endif

		cCustos := substr(cCustos,len(cString)+2)
	enddo

	asort(aCcustos)
	cCustos := ""
	for nI := 1 to len(acCustos)
		cCustos := cCustos + "'" + aCcustos[nI] + "'" + iif(nI<len(aCcustos),",","")
	next

	lOk := .F.
	Close(oDialog)

Return
