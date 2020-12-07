#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BIA670    º Autor ³ AP5 IDE            º Data ³  11/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Requisicoes pelo ultimo preco de aquisicao    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA670()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aOrd := {}
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo       := "REQUISICOES PELO ULTIMO PRECO DE AQUISICAO"
Local nLin         := 80
Local Cabec1       := "                                                                              D A D O S   D A   U L T I M A   C O M P R A"
Local Cabec2       := "TP GRUP CODIGO     DESCRICAO                 DATA     SERIE-NF   MOD FORNECEDOR                          PU+PU IPI        PU ICMS         PU IPI       PU FRETE    PU ICMS FRE     PU LIQUIDO     QUANT.    CUSTO TOTAL"
Local imprime      := .T.
Private cString, dta_ini, dta_fin, prod_ini, prod_fin, CLVL_ini, CLVL_fin, cArq
Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "BIA670"
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cPerg       := "BIA670"
//    Cabec2       := "99 9999 9999999999 XXXXXXXXXXXXXXXXXXXXXXXXX 99/99/99 XXX-999999 XXX 999999-XX XXXXXXXXXXXXXXXXXXXX  99.999.999,999 99.999.999,999 99.999.999,999 99.999.999,999 99.999.999,999 99.999.999,999 999,999.99 999.999.999,99
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "BIA670"
Private cString := "SD3"

Private cTmpTab := GetNextAlias()

dbSelectArea("SD3")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Perguntas                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
dta_ini  := mv_par01
dta_fin  := mv_par02
prod_ini := mv_par03
prod_fin := mv_par04
CLVL_ini := mv_par05
CLVL_fin := mv_par06
nTipo := If(aReturn[4]==1,15,18)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. 						                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| fprocSD3()})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechar os arquivos                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cTmpTab)
DbCloseArea()
DbSelectArea("SD1")
Set filter to
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FPROCSD3  º Autor ³ AP5 IDE            º Data ³  11/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Criar arquivo temporario com os dados do SD3               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fprocSD3()
Private acampos, lok:=.F., qt_aux := 0, nproc :=1, cchave := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do arquivo de trabalho                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := { {"TIPO     ","C", 02, 0},;
{"CLVL    ","C", 09, 0} ,;
{"GRUPO   ","C", 04, 0} ,;
{"COD     ","C", 15, 0} ,;
{"DDATA   ","D", 08, 0} ,;
{"NOTA    ","C", 09, 0} ,;
{"FORN    ","C", 08, 0} ,;
{"PU      ","N", 11, 3} ,;
{"PUICMS  ","N", 11, 3} ,;
{"PUIPI   ","N", 11, 3} ,;
{"PUF     ","N", 11, 3} ,;
{"PUFICMS ","N", 11, 3} ,;
{"QUANT   ","N", 10, 2} ,;
{"TPFRE   ","C", 03, 0} ,;
{"ORDEM   ","C", 01, 0}  }

cArq := CriaTrab(aCampos,.T.)

If Select(cTmpTab) > 0
	(cTmpTab)->(DbCloseArea())
EndIf

dbUseArea(.T.,,cArq, cTmpTab)

(cTmpTab)->(DbCreateIndex(__cUserID + "_ORDEM+COD.IND",  "ORDEM+COD"))
(cTmpTab)->(DbCreateIndex(__cUserID + "_COD.IND",  "COD"))

(cTmpTab)->(DbSetIndex(__cUserID + "_COD.IND"))
(cTmpTab)->(DbSetIndex(__cUserID + "_ORDEM+COD.IND"))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro no SD1                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SD1")
Set filter to !Empty(D1_TES)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processar arquivo SD3                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SD3")
DbSetOrder(6)
ProcRegua(RecCount())
DbSeek(xFilial("SD3")+Dtos(dta_ini),.t.)
Do while .not. eof() .and. D3_FILIAL == xFilial("SD3") .and. D3_EMISSAO <= dta_fin
	IncProc("Processando Requisicoes. Data: "+dtoc(D3_EMISSAO))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bypassar                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If D3_TIPO == "PA" .or. D3_COD < prod_ini .or. D3_COD > prod_fin .or. D3_QUANT == 0;
		.or. D3_CLVL < CLVL_ini .or. D3_CLVL > CLVL_fin
		DbSkip()
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicionar o produto                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+SD3->D3_COD))
	DbSelectArea(cTmpTab)
	DbSetOrder(1)
	If DbSeek(SD3->D3_COD)
		While !Reclock(cTmpTab,.f.);EndDo
	Else
		While !Reclock(cTmpTab,.t.);EndDo
		(cTmpTab)->COD         := SD3->D3_COD
		(cTmpTab)->TIPO        := SD3->D3_TIPO
		(cTmpTab)->CLVL        := SD3->D3_CLVL
		(cTmpTab)->GRUPO       := SD3->D3_GRUPO
		(cTmpTab)->ORDEM       := Iif(SD3->D3_TIPO == "MD","2","1")
	EndIf
	If SD3->D3_TM <= "499"
		(cTmpTab)->QUANT := (cTmpTab)->QUANT - SD3->D3_QUANT
	Else
		(cTmpTab)->QUANT := (cTmpTab)->QUANT + SD3->D3_QUANT
	EndIf
	MsUnlock()
	DbSelectArea("SD3")
	DbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apurar o ultimo preco                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cTmpTab)
DbSetOrder(1)
ProcRegua(RecCount())
DbGotop()
Do while .not. eof()
	IncProc("Processando arquivo de trabalho "+Str(nproc++,6))
	DbSelectArea("SD1")
	DbSetOrder(12)
	If !DbSeek(xFilial("SD1")+(cTmpTab)->COD+"N"+Dtos(ddatabase),.T.)
		DbSkip(-1)
	EndIf

	Do while .not. Bof() .and. SD1->D1_COD == (cTmpTab)->COD
		DbSelectArea("SF4")
		DbSetOrder(1)	
		If DbSeek(xFilial("SF4")+SD1->D1_TES,.T.)
			If SF4->F4_ESTOQUE == "N"
				DbSelectArea("SD1")
				DbSkip(-1)
				Loop
			EndIf
		EndIf
		DbSelectArea("SD1")
		If SD1->D1_TIPO == "N"
			lok := .T.
			Exit
		EndIf
		DbSkip(-1)
	EndDo

	DbSelectArea(cTmpTab)
	If lok
		cchave := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD //1a NF
		While !Reclock(cTmpTab,.f.);EndDo
		(cTmpTab)->DDATA  := SD1->D1_DTDIGIT
		(cTmpTab)->NOTA   := SD1->D1_SERIE+SD1->D1_DOC
		(cTmpTab)->FORN   := SD1->D1_FORNECE+SD1->D1_LOJA
		(cTmpTab)->PU     := SD1->D1_VUNIT + Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
		(cTmpTab)->PUICMS := Round(SD1->D1_VALICM / SD1->D1_QUANT,3)
		(cTmpTab)->PUIPI  := Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
		(cTmpTab)->TPFRE  := "CIF"
		If SD1->D1_VALFRE >  0
			(cTmpTab)->TPFRE  := "FOB"
		EndIf
		MsUnlock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificar qte total desse produto na NF de entrada para achar o frete
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		qt_aux := ftotent()
		lok := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tentar apurar o valor do frete                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF8")
		DbSetOrder(2)
		If DbSeek(xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
			DbSelectArea("SD1")
			DbSetOrder(1)
			If DbSeek(xFilial("SD1")+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_TRANSP+SF8->F8_LOJTRAN+(cTmpTab)->COD)
				While !Reclock(cTmpTab,.f.);EndDo
				(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
				(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
				(cTmpTab)->TPFRE  := "FOB"
				MsUnlock()
			EndIf
		Else
			nfaux := SD1->D1_DOC+SD1->D1_SERIE
			cproduto := SD1->D1_COD
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a NF nao teve frete verifico pelo numero da nota original        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SD1")
			nreg2 := Recno()
			DbSetOrder(11)
			DbSeek(xFilial("SD1")+nfaux)
			Do while !Eof() .and. D1_FILIAL == xFilial("SD1") .and. ;
				D1_NFORI+D1_SERIORI == nfaux
				If SD1->D1_COD == cProduto
					DbSelectArea(cTmpTab)
					While !Reclock(cTmpTab,.f.);EndDo
					(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
					(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
					(cTmpTab)->TPFRE  := "FOB"
					MsUnlock()
					DbSelectArea("SD1")
					Exit
				EndIf
				DbSkip()
			EndDo
			DbSelectArea("SD1")
			DbSetOrder(12)
			DbGoto(nreg2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a NF nao teve frete tento buscar a nf anterior                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cTmpTab)->PUF == 0
				DbSelectArea("SD1")
				DbSkip(-1)
				Do while .not. Bof() .and. SD1->D1_COD == (cTmpTab)->COD
					DbSelectArea("SF4")
					DbSetOrder(1)	
					If DbSeek(xFilial("SF4")+SD1->D1_TES,.T.)
						If SF4->F4_ESTOQUE == "N"
							DbSelectArea("SD1")
							DbSkip(-1)
							Loop
						EndIf
					EndIf
					If SD1->D1_TIPO == "N"
						lok := .T.
						Exit
					EndIf
					DbSelectArea("SD1")
					DbSkip(-1)
				EndDo
				If lok
					While !Reclock(cTmpTab,.f.);EndDo
					(cTmpTab)->DDATA  := SD1->D1_DTDIGIT
					(cTmpTab)->NOTA   := SD1->D1_SERIE+SD1->D1_DOC
					(cTmpTab)->FORN   := SD1->D1_FORNECE+SD1->D1_LOJA
					(cTmpTab)->PU     := SD1->D1_VUNIT + Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
					(cTmpTab)->PUICMS := Round(SD1->D1_VALICM / SD1->D1_QUANT,3)
					(cTmpTab)->PUIPI  := Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
					(cTmpTab)->TPFRE  := "CIF"
					If SD1->D1_VALFRE >  0
						(cTmpTab)->TPFRE  := "FOB"
					EndIf
					MsUnlock()
					qt_aux := ftotent()
					lok := .F.
					DbSelectArea("SF8")
					DbSetOrder(2)
					If DbSeek(xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
						DbSelectArea("SD1")
						DbSetOrder(1)
						If DbSeek(xFilial("SD1")+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_TRANSP+SF8->F8_LOJTRAN+(cTmpTab)->COD)
							While !Reclock(cTmpTab,.f.);EndDo
							(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
							(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
							MsUnlock()
						EndIf
					Else
						nfaux := SD1->D1_DOC+SD1->D1_SERIE
						cproduto := SD1->D1_COD
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se a NF nao teve frete verifico pelo numero da nota original        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SD1")
						nreg2 := Recno()
						DbSetOrder(11)
						DbSeek(xFilial("SD1")+nfaux)
						Do while !Eof() .and. D1_FILIAL == xFilial("SD1") .and. ;
							D1_NFORI+D1_SERIORI == nfaux
							If SD1->D1_COD == cProduto
								DbSelectArea(cTmpTab)
								While !Reclock(cTmpTab,.f.);EndDo
								(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
								(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
								(cTmpTab)->TPFRE  := "FOB"
								MsUnlock()
								DbSelectArea("SD1")
								Exit
							EndIf
							DbSkip()
						EndDo
						DbSelectArea("SD1")
						DbSetOrder(12)
						DbGoto(nreg2)
						If (cTmpTab)->PUF == 0
							DbSelectArea("SD1")
							DbSkip(-1)
							Do while .not. Bof() .and. D1_COD == (cTmpTab)->COD
								If D1_TIPO == "N"
									lok := .T.
									Exit
								EndIf
								DbSkip(-1)
							EndDo
							If lok
								While !Reclock(cTmpTab,.f.);EndDo
								(cTmpTab)->DDATA  := SD1->D1_DTDIGIT
								(cTmpTab)->NOTA   := SD1->D1_SERIE+SD1->D1_DOC
								(cTmpTab)->FORN   := SD1->D1_FORNECE+SD1->D1_LOJA
								(cTmpTab)->PU     := SD1->D1_VUNIT + Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
								(cTmpTab)->PUICMS := Round(SD1->D1_VALICM / SD1->D1_QUANT,3)
								(cTmpTab)->PUIPI  := Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
								(cTmpTab)->TPFRE  := "CIF"
								If SD1->D1_VALFRE >  0
									(cTmpTab)->TPFRE  := "FOB"
								EndIf
								MsUnlock()
								qt_aux := ftotent()
								lok := .F.
								DbSelectArea("SF8")
								DbSetOrder(2)
								If DbSeek(xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
									DbSelectArea("SD1")
									DbSetOrder(1)
									If DbSeek(xFilial("SD1")+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_TRANSP+SF8->F8_LOJTRAN+(cTmpTab)->COD)
										While !Reclock(cTmpTab,.f.);EndDo
										(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
										(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
										MsUnlock()
									EndIf
								EndIf
								If (cTmpTab)->PUF == 0
									nfaux := SD1->D1_DOC+SD1->D1_SERIE
									cproduto := SD1->D1_COD
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Se a NF nao teve frete verifico pelo numero da nota original        ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									DbSelectArea("SD1")
									nreg2 := Recno()
									DbSetOrder(11)
									DbSeek(xFilial("SD1")+nfaux)
									Do while !Eof() .and. D1_FILIAL == xFilial("SD1") .and. ;
										D1_NFORI+D1_SERIORI == nfaux
										If SD1->D1_COD == cProduto
											DbSelectArea(cTmpTab)
											While !Reclock(cTmpTab,.f.);EndDo
											(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
											(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
											(cTmpTab)->TPFRE  := "FOB"
											MsUnlock()
											DbSelectArea("SD1")
											Exit
										EndIf
										DbSkip()
									EndDo
									DbSelectArea("SD1")
									DbSetOrder(12)
									DbGoto(nreg2)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If (cTmpTab)->PUF == 0  // Se nao achou o valor do frete retorno para as informacoes da 1a nota
		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek(xFilial("SD1")+cchave)
		While !Reclock(cTmpTab,.f.);EndDo
		(cTmpTab)->DDATA  := SD1->D1_DTDIGIT
		(cTmpTab)->NOTA   := SD1->D1_SERIE+SD1->D1_DOC
		(cTmpTab)->FORN   := SD1->D1_FORNECE+SD1->D1_LOJA
		(cTmpTab)->PU     := SD1->D1_VUNIT + Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
		(cTmpTab)->PUICMS := Round(SD1->D1_VALICM / SD1->D1_QUANT,3)
		(cTmpTab)->PUIPI  := Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
		(cTmpTab)->TPFRE  := "CIF"
		If SD1->D1_VALFRE >  0
			(cTmpTab)->TPFRE  := "FOB"
		EndIf
		MsUnlock()
	EndIf
	DbSelectArea(cTmpTab)
	DbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apurar NF de entrada com produto final 0000                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SD1")
ProcRegua(RecCount())
DbSetOrder(6)
DbSeek(xFilial("SD1")+Dtos(dta_ini),.t.)
Do while .not. eof() .and. D1_FILIAL==xFilial("SD1") .and. D1_DTDIGIT <= dta_fin
	IncProc("Apurando produto com final 0000. Data "+Dtoc(D1_DTDIGIT))
	If Right(Alltrim(D1_COD),4) <> "0000" .or. D1_TIPO <> "N" .or. ;
		D1_COD < prod_ini .or. D1_COD > prod_fin .or. ;
		D1_CLVL < CLVL_ini .or. D1_CLVL > CLVL_fin
		DbSkip()
		Loop
	EndIf

	DbSelectArea("SF4")
	DbSetOrder(1)	
	If DbSeek(xFilial("SF4")+SD1->D1_TES,.T.)
		If SF4->F4_ESTOQUE == "N"
			DbSelectArea("SD1")
			DbSkip()
			Loop
		EndIf
	EndIf
	
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
	DbSelectArea(cTmpTab)
	while !Reclock(cTmpTab,.T.);EndDo
	DbSelectArea("SD1")
	(cTmpTab)->COD         := SD1->D1_COD
	(cTmpTab)->TIPO        := SB1->B1_TIPO
	(cTmpTab)->CLVL        := SD1->D1_CLVL
	(cTmpTab)->GRUPO       := SD1->D1_GRUPO
	(cTmpTab)->ORDEM       := "3"
	(cTmpTab)->QUANT 	   := (cTmpTab)->QUANT + SD1->D1_QUANT
	(cTmpTab)->DDATA  	   := SD1->D1_DTDIGIT
	(cTmpTab)->NOTA        := SD1->D1_SERIE+SD1->D1_DOC
	(cTmpTab)->FORN        := SD1->D1_FORNECE+SD1->D1_LOJA
	(cTmpTab)->PU          := SD1->D1_VUNIT + Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
	(cTmpTab)->PUICMS      := Round(SD1->D1_VALICM / SD1->D1_QUANT,3)
	(cTmpTab)->PUIPI       := Round(SD1->D1_VALIPI / SD1->D1_QUANT,3)
	(cTmpTab)->TPFRE       := "CIF"
	If SD1->D1_VALFRE >  0
		(cTmpTab)->TPFRE  := "FOB"
	EndIf
	MsUnlock()
	qt_aux := ftotent()
	lok := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tentar apurar o valor do frete                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF8")
	DbSetOrder(2)
	If DbSeek(xFilial("SF8")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
		DbSelectArea("SD1")
		DbSetOrder(1)
		If DbSeek(xFilial("SD1")+SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_TRANSP+SF8->F8_LOJTRAN+(cTmpTab)->COD)
			While !Reclock(cTmpTab,.f.);EndDo
			(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
			(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
			(cTmpTab)->TPFRE  := "FOB"
			MsUnlock()
		EndIf
	Else
		nfaux := SD1->D1_DOC+SD1->D1_SERIE
		cproduto := SD1->D1_COD
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a NF nao teve frete verifico pelo numero da nota original        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SD1")
		nreg2 := Recno()
		DbSetOrder(11)
		DbSeek(xFilial("SD1")+nfaux)
		Do while !Eof() .and. D1_FILIAL == xFilial("SD1") .and. ;
			D1_NFORI+D1_SERIORI == nfaux
			If SD1->D1_COD == cProduto
				DbSelectArea(cTmpTab)
				While !Reclock(cTmpTab,.f.);EndDo
				(cTmpTab)->PUF     := Round(SD1->D1_VUNIT / qt_aux,3)
				(cTmpTab)->PUFICMS := Round(SD1->D1_VALICM / qt_aux,3)
				(cTmpTab)->TPFRE  := "FOB"
				MsUnlock()
				DbSelectArea("SD1")
				Exit
			EndIf
			DbSkip()
		EndDo
		DbSelectArea("SD1")
		DbSetOrder(6)
		DbGoto(nreg2)
	EndIf
	DbSelectArea("SD1")
	DbSetOrder(6)
	DbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recriar o Indice pela ordem que vai ser impresso                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cTmpTab)
DbSetOrder(2)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP5 IDE            º Data ³  11/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Private nOrdem, atotqt[4],atotcus[4]
Afill(atotqt,0)
Afill(atotcus,0)
dbSelectArea(cTmpTab)
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount())
dbGoTop()
While !EOF()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	Do while .not. eof() .and. Prow() <= 56
		IncRegua()
		@ Prow()+1, 0      Psay (cTmpTab)->TIPO
//      @ Prow(),Pcol()+1 Psay Left((cTmpTab)->CLVL,4)
		@ Prow(),Pcol()+1 Psay (cTmpTab)->GRUPO
		@ Prow(),Pcol()+1 Psay Left((cTmpTab)->COD,10)
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cTmpTab)->COD))
		@ Prow(),Pcol()+1 Psay Left(SB1->B1_DESC,25)
		@ Prow(),Pcol()+1 Psay (cTmpTab)->DDATA
		@ Prow(),Pcol()+1 Psay Left((cTmpTab)->NOTA,3)+"-"+Subs((cTmpTab)->NOTA,4,6)
		@ Prow(),Pcol()+1 Psay (cTmpTab)->TPFRE
		@ Prow(),Pcol()+1 Psay Left((cTmpTab)->FORN,6)+"-"+Right((cTmpTab)->FORN,2)
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+(cTmpTab)->FORN))
		@ Prow(),Pcol()+1 Psay Left(SA2->A2_NOME,20)
		@ Prow(),Pcol()+1 Psay Transform((cTmpTab)->PU, "@E 99,999,999.999")
		@ Prow(),Pcol()+1 Psay Transform((cTmpTab)->PUICMS, "@E 99,999,999.999")
		@ Prow(),Pcol()+1 Psay Transform((cTmpTab)->PUIPI, "@E 99,999,999.999")
		@ Prow(),Pcol()+1 Psay Transform((cTmpTab)->PUF, "@E 99,999,999.999")
		@ Prow(),Pcol()+1 Psay Transform((cTmpTab)->PUFICMS, "@E 99,999,999.999")
		nliq := ((cTmpTab)->PU-(cTmpTab)->PUICMS-(cTmpTab)->PUIPI) + ((cTmpTab)->PUF-(cTmpTab)->PUFICMS)
		@ Prow(),Pcol()+1 Psay Transform(nliq,"@E 99,999,999.999")
		@ Prow(),Pcol()+1 Psay Transform((cTmpTab)->QUANT,"@E 999,999.99")
		@ Prow(),Pcol()+1 Psay Transform(Round((cTmpTab)->QUANT*nliq,2),"@E 999,999,999.99")
		atotqt[1] += (cTmpTab)->QUANT
		atotcus[1]+= Round((cTmpTab)->QUANT*nliq,2)
		atotqt[3] += (cTmpTab)->QUANT
		atotcus[3]+= Round((cTmpTab)->QUANT*nliq,2)
		atotqt[4] += (cTmpTab)->QUANT
		atotcus[4]+= Round((cTmpTab)->QUANT*nliq,2)
		DbSelectArea(cTmpTab)
		ctipaux  := ORDEM
		ccaux    := CLVL
		cgrupaux := GRUPO
		dbSkip()
/*	 	If GRUPO <> cgrupaux .or. CLVL <> ccaux
			@ Prow()+1,0 Psay Repli("-",220)
			@ Prow()+1,0 Psay "TOTAL GRUPO "+ cgrupaux
			@ Prow(),195 Psay Transform(atotqt[3],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(atotcus[3],"@E 999,999,999.99")
			@ Prow()+1,0 Psay Repli("-",220)
			atotqt[3]  := 0
			atotcus[3] := 0
		EndIf
		If CLVL <> ccaux
			@ Prow()+1,0 Psay Repli("-",220)
			@ Prow()+1,0 Psay "TOTAL CLASSE DE VALOR "+ccaux
			@ Prow(),195 Psay Transform(atotqt[4],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(atotcus[4],"@E 999,999,999.99")
			@ Prow()+1,0 Psay Repli("-",220)
			atotqt[4]  := 0
			atotcus[4] := 0
		EndIf*/
		If ORDEM <> ctipaux
			@ Prow()+1,0 Psay Repli("-",220)
			@ Prow()+1,0 Psay "TOTAL TIPO"
			@ Prow(),190 Psay Transform(atotqt[1],"@E 999,999.99")
			@ Prow(),Pcol()+1 Psay Transform(atotcus[1],"@E 999,999,999.99")
			@ Prow()+1,0 Psay Repli("-",220)
			atotqt[2]  += atotqt[1]
			atotcus[2] += atotcus[1]
			atotqt[1]  := 0
			atotcus[1] := 0
		EndIf
	EndDo
EndDo
@ Prow()+1,0 Psay "TOTAL GERAL"
@ Prow(),190 Psay Transform(atotqt[2],"@E 999,999.99")
@ Prow(),Pcol()+1 Psay Transform(atotcus[2],"@E 999,999,999.99")
@ Prow()+1,0 Psay Repli("-",220)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ftotent   º Autor ³ AP5 IDE            º Data ³  11/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verificar qte total desse produto na nf de entrada atual   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ftotent()
Local nregF , caliasF := Alias() , nordemF,cchaveF:=SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD
Local ccod := SD1->D1_COD
Local nqt := 0, nffrete
DbSelectArea("SD1")
nOrdemF := IndexOrd()
nregF   := Recno()
DbSetOrder(1)
DbSeek(xFilial("SD1")+cchaveF)
Do while .not. eof() .and. D1_FILIAL == xFilial("SD1") .and. ;
   SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD == cchaveF
   nqt += SD1->D1_QUANT
   DbSkip()
EndDo      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se existe nf de frete pois pode ser para mais de 1 NF Orig ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF8")
DbSetOrder(2)
If DbSeek(xFilial("SF8")+Subs(cchaveF,1,17)) 
   nffrete := SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_FORNECE+SF8->F8_LOJA
   nqt := 0
   DbSelectArea("SF8")
   DbSetOrder(1)
   DbSeek(xFilial("SF8")+nffrete)
   Do while !eof() .and. F8_FILIAL == xFilial("SF8") .and. ;
      SF8->F8_NFDIFRE+SF8->F8_SEDIFRE+SF8->F8_FORNECE+SF8->F8_LOJA == nffrete
      DbSelectArea("SD1")
      DbSetOrder(1)
      DbSeek(xFilial("SD1")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA+ccod)
      Do while .not. eof() .and. D1_FILIAL == xFilial("SD1") .and. ;
        SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD == ;
        SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA+ccod
        nqt += SD1->D1_QUANT
   	    DbSkip()
	  EndDo      
      DbSelectArea("SF8")
      DbSkip()
   EndDo   
EndIf  
DbSelectArea("SD1")                                                                            
DbSetOrder(nOrdemF)
DbGoto(nregF)
DbSelectArea(caliasF)
Return(nqt)