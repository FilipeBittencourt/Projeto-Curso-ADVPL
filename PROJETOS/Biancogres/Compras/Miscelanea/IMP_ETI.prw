#include "rwMake.ch"
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	IMP_ETI     ³ Autor ³BRUNO MADALENO        ³ Data ³ 18/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ IMPRIME ETIQUETAS SELECIONADAS NO MARKBROWSE                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function IMP_ETI(nOpc)

	If nOpc == 1
		U_Bia655()
	Else
		IMP_ETI_NOVA()
	EndIf

RETURN
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	IMP_ETI     ³ Autor ³BRUNO MADALENO        ³ Data ³ 18/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ IMPRIME ETIQUETAS SELECIONADAS NO MARKBROWSE                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function IMP_ETI_NOVA()

	Local  I
	Private aCampos
	Private cSql
	Private lop,cnum,ocheck,cmarkbr

	_aCampos := {   {"_OK",			"C",02,0},;
	{"c_PRODUTO",	"C",20,0},;
	{"c_DESCRI",	"C",50,0},;
	{"c_OBS",   	"C",50,0}}

	_trabalho := CriaTrab(_aCampos)
	dbUseArea(.T.,,_trabalho,"_trabalho",.t.)
	dbCreateInd(_trabalho,"c_DESCRI",{||c_DESCRI})


	FOR I:= 1 TO LEN(ACOLS)
		nCodProd := aScan(aHeader,{|x| x[2]=="C7_PRODUTO"})
		nCodProd := ALLTRIM(Acols[I,nCodProd])
		nDESC    := aScan(aHeader,{|x| x[2]=="C7_DESCRI "})
		nDESC    := ALLTRIM(Acols[I,nDESC])
		nOBS     := aScan(aHeader,{|x| x[2]=="C7_OBS    "})
		nOBS     := ALLTRIM(Acols[I,nOBS])

		RecLock("_trabalho",.t.)
		//_trabalho->_OK		:= cMarkBr
		_trabalho->c_PRODUTO := nCodProd
		_trabalho->c_DESCRI  := nDESC
		_trabalho->c_OBS     := nOBS
		MsUnlock()

	NEXT

	aCampos := {}
	AADD(aCampos,{"_OK"," " ,2})
	AADD(aCampos,{"c_PRODUTO", "COD PRODUTO" ,3})
	AADD(aCampos,{"c_DESCRI", "DESCRIÇÃO" ,50})
	AADD(aCampos,{"c_OBS", "OBSERVAÇÃO" ,50})
	Mark_2()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ 	MARKBROW    ³ Autor ³BRUNO MADALENO        ³ Data ³ 18/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MONTA O OBROWSE PARA LISTAS OS TITULOS BLOQUEADOS               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mark_2()
	nMarcados := 0
	lInverte  := .F.
	cMarca    := GetMark()
	@  10,10    to 370,750 Dialog oDlg1 Title "IMPRIME
	@ 160,155   Button "Imprime Etiq." Size 50,15 Action IMPRIME_ETIQ()
	@ 160,333   BmpButton Type 2 Action Close(oDlg1)
	lCheck := .F.
	oCheck := IW_CheckBox(160,015,"Marca/Desmarca Todos","lCheck")
	oCheck:blClicked := {|| MsAguarde( {|| A470Mark() } ) }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta MarkBrowse...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowse := IW_Browse(010,015,160,360,"_trabalho","_OK",,acampos)
	oBrowse:oBrowse:bAllMark := {|| MsAguarde( {|| A470Mark() } ) }
	ACTIVATE DIALOG oDlg1 ON INIT Eval({|| MsAguarde( {|| cMarkBr := ThisMark(),A470Mark() } ), _trabalho->(DbGoTop()), oBrowse:oBrowse:Refresh(), }) Centered
	DbSelectArea("_trabalho")
	DbCloseArea()
	Ferase(_trabalho+".DBF")
	Ferase(_trabalho+".CDX")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ MarcaDesmarca³ Autor ³BRUNO MADALENO        ³ Data ³ 18/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os itens do Browse...                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A470Mark()
	MsProcTXT(If(lCheck,"Marcando","Desmarcando"))
	_trabalho->(DbGoTop())
	While ! _trabalho->(Eof())
		_trabalho->(RecLock("_trabalho",.F.))
		If lCheck
			_trabalho->_OK := ''
		Else
			_trabalho->_OK := cMarkBr
		Endif
		_trabalho->(MsUnLock())
		_trabalho->(DbSkip())
	Enddo
	_trabalho->(DbCommit())
	_trabalho->(DbGoTop())
	oBrowse:oBrowse:Refresh()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ IMPRIME_ETIQ ³ Autor ³BRUNO MADALENO        ³ Data ³ 18/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os itens do Browse...                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPRIME_ETIQ()
	LOCAL wCod := ""
	LOCAL wQtd := 1       

	_trabalho->(DbGoTop())
	Do while !_trabalho->(EOF())
		IncProc()
		If Marked("_OK")
			wCod := _trabalho->c_PRODUTO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida os parametros passados                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lAlias := Alias()
			dbselectArea("SB1")
			lOrder := dbSetOrder(1)
			If !dbseek(xFilial("SB1")+wCod)
				MsgBox("O codigo de produto digitado nao existe!"+chr(13)+;
				"Verifique-o e tente novamente.","Alerta","ERRO")

				dbSetOrder(lOrder)
				dbselectArea(lAlias)
				Return
			EndIf

			If wQtd < 1 .and. wQtd > 999
				MsgBox("A quantidade informada deve ser de 1 a 999!","Alerta","ERRO")
				dbSetOrder(lOrder)
				dbselectArea(lAlias)
				Return
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera um arquivo texto temporario para a impressao das etiquetas          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If File("\\urano\Arquivos_P12\Etiquetas\ETIQ.TMP")
				Delete File \\urano\Arquivos_P12\Etiquetas\ETIQ.TMP
			EndIf
			wString := "O0220" + Chr(13)
			wString := wString + "M0350"  + Chr(13)
			wString := wString + "c0000"  + Chr(13)
			wString := wString + "f000"   + Chr(13)
			wString := wString + "e"      + Chr(13)
			wString := wString + "LC0000" + Chr(13)
			wString := wString + "H09"     + Chr(13)
			wString := wString + "D11"     + Chr(13)
			wString := wString + "SC"      + Chr(13)
			wString := wString + "PC"      + Chr(13)
			wString := wString + "R0000"   + Chr(13)
			wString := wString + "z"       + Chr(13)
			wString := wString + "W"       + Chr(13)
			wString := wString + "^01"     + Chr(13)

			//wString := wString + "1eF505000870015   "          + AllTrim(SB1->B1_COD)                          + Chr(13)
			//wString := wString + "113100000800015   "          + Padc(AllTrim(SB1->B1_COD),11," ")             + Chr(13)
			//wString := wString + "121100000550007   DES.:"     + SUBSTR(SB1->B1_DESC   ,01,19)                 + Chr(13)
			//wString := wString + "121100000420007   "          + SUBSTR(SB1->B1_DESC   ,20,24)                 + Chr(13)

			//Fernando/Facile em 25/11/2015 - estava imprimindo codigo errado cortado e com espacos na frente...   comentado acima 
			//Atencao -- esse bloco de impressao esta repetido no fonte BIA655 - alterar nos dois.

			wString := wString + "1e5204000870020" + AllTrim(SB1->B1_COD) + Chr(13)
			wString := wString + "113100000800020" + AllTrim(SB1->B1_COD) + Chr(13)
			wString := wString + "121100000550020" + SUBSTR(SB1->B1_DESC   ,01,30) + Chr(13)
			wString := wString + "121100000420020" + SUBSTR(SB1->B1_DESC   ,31,95) + Chr(13)

			IF SB1->B1_TIPO <> 'MD'
				IF cempant = "01"
					wString := wString + "121100000220007   LOC.:"     + SUBSTR(SB1->B1_YLOCALI,01,18)         + Chr(13)
				ELSEIF cempant = "05"
					wString := wString + "121100000220007   LOC.:"     + SUBSTR(SB1->B1_YLOCINC,01,18)         + Chr(13)
				ELSEIF cempant = "14"
					wString := wString + "121100000220007   LOC.:"     + SUBSTR(SB1->B1_YLOCVIT,01,18)         + Chr(13)
				ENDIF
			ELSE
				wString := wString + "121100000220007   SOL.:"     + SUBSTR(_trabalho->c_OBS,01,18)            + Chr(13)
			ENDIF

			wString := wString + "121100000020007   DATA:"     + DTOC(DATE()) + "  UND.:"+AllTrim(SB1->B1_UM)  + Chr(13)
			wString := wString + "Q"                           + StrZero(wQtd,4)                               + Chr(13)
			wString := wString + "E"                                                                           + Chr(13)

			MemoWrit("\\urano\Arquivos_P12\Etiquetas\ETIQ.TMP",wString)

			dbSetOrder(lOrder)
			dbSelectArea(lAlias)


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime as etiquetas                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
			If !SUBSTRING(UPPER(COMPUTERNAME()),1,11) $ ("ADM-ALM-B01_ADM-ALM-I04_ADM-VIT-V07") //Testa se impressao esta no computador Local
			WinExec("net use lpt2 /delete")
			If cEmpAnt == "01"
			WinExec("net use lpt2 \\ADM-ALM-B01\ARGOX")
			ElseIf cEmpAnt == "05
			WinExec("net use lpt2 \\ADM-ALM-I04\ARGOX")
			//ElseIf cEmpAnt == "14"
			//	WinExec("net use lpt2 \\ADM-VIT-V07\ARGOX")
			EndIf
			WinExec("CMD /C TYPE \\urano\Arquivos_P12\Etiquetas\ETIQ.TMP > LPT2")
			Else
			WinExec("CMD /C TYPE \\urano\Arquivos_P12\Etiquetas\ETIQ.TMP > LPT1")
			EndIf
			*/

			//Apaga mapeamento
			WinExec("net use lpt3 /delete")
			//Realiza o mapeamento 
			WinExec("net use lpt3 \\"+Alltrim(GetMV("MV_YPCETIQ"))+"\ARGOX")
			//Realiza a Impressão
			WinExec("CMD /C TYPE \\urano\Arquivos_P12\Etiquetas\ETIQ.TMP > LPT3")

		End If
		DbSelectArea("_Trabalho")
		DbSkip()
	End
	MsgBox("ETIQUETA ENVIADA COM SUCESSO","Alerta","INFO")
Return