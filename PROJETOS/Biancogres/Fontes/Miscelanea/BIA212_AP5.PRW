#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function U_bia212()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("AHEADER,ACOLS,ACOLSE,NUSADO,_NANT,CFORNEC")
	SetPrvt("ACOLS2,J,XCOLS,CFORN,NITEM,CNUM")
	SetPrvt("CCH,")

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³ Bia212     ³ Autor ³ Marcelo Ventura Felix ³ Data ³03/04/2000³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Autoriza‡Æo de Entrega                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador xBase                                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	aHeader  := {} // Cabecalho
	aCols    := {} // Colunas
	aColsE   := {} // Colunas de Endere‡o
	nUsado   := 6  // Numero de colunas

	AADD(aHeader,{ "Fornecedor","C3_FORNECE","  ", 6, 0, "M->C3_FORNECE == aCols[n,1]", "€€€€€€€", "C", "" } )
	AADD(aHeader,{ "Material","C3_PRODUTO","  ", 9, 0, "M->C3_PRODUTO == aCols[n,2]", "€€€€€€€", "C", "" } )
	AADD(aHeader,{ "Descricao","B1_DESC","  ",30, 0, "M->B1_DESC == aCols[n,3]", "€€€€€€€", "C", "" } )
	AADD(aHeader,{ "Qtd Saldo","SLDATU","@E 9,999,999.99",12, 2, "M->SLDATU == aCols[n,4]", "€€€€€€€", "N", "" } )
	AADD(aHeader,{ "Qtd Solicitada","QTDSOL","@E 9,999,999.99",12, 2, "M->QTDSOL > 0 .AND. M->QTDSOL <= aCols[n,4]", "€€€€€€€", "N", "" } )
	AADD(aHeader,{ "Entrega","DTENTR","", 8, 0, "If(aCols[n,5]#0,!Empty(M->DTENTR) .and. DTOS(M->DTENTR) >= DTOS(DATE()) ,Empty(M->DTENTR))", "€€€€€€€", "D", "" } )

	aCols    :={}
	_nAnt    := 1
	Processa( {|| Proc1a() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Processa( {|| Execute(Proc1a) } )
	cFornec := aCols[1,1]
	If len(aCols) > 0
		@ 200,  1 TO 550,780 DIALOG oDlg4 TITLE "Autoriza‡Æo de Entrega"
		@  20,  5 TO 157,350 MULTILINE MODIFY object oMultiline valid ok() freeze 2// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    @  20,  5 TO 157,350 MULTILINE MODIFY object oMultiline valid execute(ok) freeze 2
		@ 142,357 BMPBUTTON TYPE 01 ACTION Atua()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    @ 142,357 BMPBUTTON TYPE 01 ACTION Execute(Atua)
		@ 157,357 BMPBUTTON TYPE 02 ACTION Close(oDlg4)
		ACTIVATE DIALOG oDlg4 CENTERED
	Else
		MsgBox("NÆo h  produtos com saldo para a "+chr(10)+"Autoriza‡Æo de Entrega!","Aten‡Æo","ALERT")
	EndIf
return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> function ok
Static function ok()
	If n == len(aCols)
		return .f.
	EndIf
return .t.

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Proc1a
Static Function Proc1a()
	* Carga das colunas
	dbSelectArea( "SC3" )
	DbSetOrder(5) // C3_FILIAL+C3_PRODUTO+C3_FORNECE+C3_LOJA+DTOS(C3_DATPRI)
	DbGoTop()
	ProcRegua(reccount())
	IncProc()
	Do While !eof()
		If SC3->C3_QUANT > SC3->C3_QUJE
			dbSelectArea( "SB1" )
			DbSeek(xFilial("SB1")+SC3->C3_PRODUTO)
			dbSelectArea( "SC3" )
			IncProc()
			AADD(aCols,Array(nUsado+1))
			aCols[Len(aCols),1]:=SC3->C3_FORNECE
			aCols[Len(aCols),2]:=SC3->C3_PRODUTO
			aCols[Len(aCols),3]:=SB1->B1_DESC
			aCols[Len(aCols),4]:=SC3->C3_QUANT - SC3->C3_QUJE
			aCols[Len(aCols),5]:=0.00
			aCols[Len(aCols),6]:=ctod("  ")
			aCols[Len(aCols),nUsado+1]:=.F.
			AADD(aColsE,Array(3))
			aColsE[Len(aColsE),1]:=SC3->C3_FILIAL
			aColsE[Len(aColsE),2]:=SC3->C3_NUM
			aColsE[Len(aColsE),3]:=SC3->C3_ITEM
		EndIf
		dbSkip()
	EndDo
	DbSetOrder(1) // C3_FILIAL+C3_NUM+C3_ITEM
return .T.

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Atua
Static Function Atua()
	Processa( {|| Atua1a() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Processa( {|| Execute(Atua1a) } )
return .t.

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Atua1a
Static Function Atua1a()
	Local j
	ProcRegua(len(aCols))
	aCols2 := {}
	For j := 1 to len(aCols)
		IncProc()
		If aCols[j,5] #0
			If Empty(aCols[j,6])
				MsgBox("Autorizacao sem data de entrega,"+chr(10)+"Operacao cancelada!","Aten‡Æo","ALERT")
				return .t.
			EndIf
			xCols := {}
			AADD(xCols,aColsE[j,1]) // C3_FILIAL
			AADD(xCols,aColsE[j,2]) // C3_NUM
			AADD(xCols,aColsE[j,3]) // C3_ITEM
			AADD(xCols,aCols[j,1]) // C3_FORNECE
			AADD(xCols,aCols[j,2]) // C3_PRODUTO
			AADD(xCols,aCols[j,5]) // QTDSOL
			AADD(xCols,aCols[j,6]) // DTENTR
			AADD(aCols2,xCols)
		EndIf
	Next
	If len(aCols2) #0
		ProcRegua(len(aCols2))
		Asort(aCols2,,, { |x, y| x[4]+x[5] < y[4]+y[5] }) // Reordena por Fornecedor+produto
		IncProc()
		DbSelectArea("SC3")
		cForn := space(6)
		For j := 1 to len(aCols2)
			DbSeek(aCols2[j,1]+aCols2[j,2]+aCols2[j,3])
			If aCols2[j,4] #cForn
				DbSelectArea("SC7")
				DbSetOrder(5) // C7_FILIAL+DTOS(C7_EMISSAO)+C7_NUM+C7_ITEM+C7_SEQUEN
				DbSeek(aCols2[j,1]+dtos(date()))
				nItem := 0
				If eof()
					DbSetOrder(1) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
					DbSeek(aCols2[j,1]+"A99999",.t.)
					DbSkip(-1)
					If left(SC7->C7_NUM,1) #"A"
						cNum := "A00001"
					Else
						cNum := "A"+strzero(((val(subst(sc7->c7_num,2,5)))+1),5)
					EndIf
				Else
					Do While SC7->C7_EMISSAO == date()
						If Left(SC7->C7_NUM,1) == "A"
							cNum  := SC7->C7_NUM
							If SC7->C7_FORNECE == SC3->C3_FORNECE .and. SC7->C7_EMITIDO #"S"
								cCh := SC7->C7_FILIAL+DTOS(SC7->C7_EMISSAO)+SC7->C7_NUM
								Do While cCh == SC7->C7_FILIAL+DTOS(SC7->C7_EMISSAO)+SC7->C7_NUM
									nItem := val(SC7->C7_ITEM)
									DbSkip()
								EndDo
								Exit
							EndIf
						EndIf
						DbSkip()
					EndDo
					If nItem == 0
						cNum := "A"+strzero(((val(subst(cNum,2,5)))+1),5)
					EndIf
					DbSetOrder(1) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
				EndIf
				cForn := aCols2[j,4]
			EndIf
			DbSelectArea("SB1")
			DbSeek(xFilial("SB1")+SC3->C3_PRODUTO)
			nItem := nItem + 1
			RecLock("SC7",.T.)
			SC7->C7_FILIAL  := SC3->C3_FILIAL
			SC7->C7_TIPO    := 1
			SC7->C7_ITEM    := strzero(nItem,2)
			SC7->C7_PRODUTO := SC3->C3_PRODUTO
			SC7->C7_DESCRI  := SB1->B1_DESC
			SC7->C7_QUANT   := aCols2[j,6]
			SC7->C7_UM      := SB1->B1_UM
			SC7->C7_PRECO   := SC3->C3_PRECO
			SC7->C7_TOTAL   := SC7->C7_PRECO * SC7->C7_QUANT
			SC7->C7_IPI     := SC3->C3_IPI
			SC7->C7_DATPRF  := aCols2[j,7]
			SC7->C7_LOCAL   := SC3->C3_LOCAL
			SC7->C7_FORNECE := SC3->C3_FORNECE
			SC7->C7_LOJA    := SC3->C3_LOJA
			SC7->C7_COND    := SC3->C3_COND
			SC7->C7_OBS     := SC3->C3_OBS
			SC7->C7_CONTATO := SC3->C3_CONTATO
			SC7->C7_FILENT  := SC3->C3_FILENT
			SC7->C7_EMISSAO := DATE()
			SC7->C7_NUM     := cNum
			SC7->C7_REAJUST := SC3->C3_REAJUST
			SC7->C7_FRETE   := SC3->C3_FRETE
			SC7->C7_EMITIDO := "N"
			SC7->C7_TPFRETE := SC3->C3_TPFRETE
			SC7->C7_MSG     := SC3->C3_MSG
			SC7->C7_ORIGEM  := "1"
			SC7->C7_YAPLIC  := "0" 
			SC7->(MsUnlock())
			RecLock("SC3",.F.)
			SC3->C3_QUJE := SC3->C3_QUJE + aCols2[j,6]       
			IF SC3->C3_QUJE >= SC3->C3_QUANT 
				SC3->C3_ENCER   := 'E'
				SC3->C3_RESIDUO := 'S' 
				SC3->C3_DATPRF  := DDATABASE
			ENDIF
			SC3->(MsUnlock())
		next
	EndIf
	Close(oDlg4)
return .t.