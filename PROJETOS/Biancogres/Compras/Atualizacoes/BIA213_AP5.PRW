#include "rwmake.ch"

User Function BIA213()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BIA213     ³ Autor ³ Marcelo Ventura Felix ³ Data ³13/04/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autoriza‡Æo de Entrega                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

SetPrvt("AHEADER,ACOLS,ACOLSS,NUSADO,PRODUTO,_NANT")
SetPrvt("ACOLS2,J,XCOLS,CFORN,NITEM,CNUM")

aHeader  := {} // Cabecalho
aCols    := {} // Colunas de get
aColsS   := {} // Coluna auxiliar de Saldo
nUsado   := 4  // Numero de colunas
produto  := space(15)

AADD(aHeader,{ "Almox"          ,"ALMOX"   ,"  "             ,02, 0, " ", "       ", "C", "" } ) //Ranisses
AADD(aHeader,{ "Material"       ,"PRODUTO" ,"@!"             ,15, 0, "execblock('BIA213B',.F.,.F.)", "€€€€€€€", "C", "" } )
AADD(aHeader,{ "Qtd Solicitada" ,"QTDSOL"  ,"@E 9,999,999.99",12, 2, "execblock('BIA213C',.F.,.F.)" , "€€€€€€€", "N", "" } )
AADD(aHeader,{ "Tipo Frete" 	,"C7_TPFRETE"  ,"@!"		 ,01, 0, "Pertence('C,F')" , "€€€€€€€", "C", "" } )
AADD(aHeader,{ "Entrega"        ,"DTENTR"  ,""               ,10, 0, "If(aCols[n,3]#0,!Empty(M->DTENTR) .and. DTOS(M->DTENTR) >= DTOS(DATE()) ,Empty(M->DTENTR))", "€€€€€€€", "D", "" } )
AADD(aHeader,{ "Data Chegada"   ,"DTCHEG"  ,""               ,10, 0, "If(aCols[n,3]#0,!Empty(M->DTCHEG) .and. DTOS(M->DTCHEG) >= DTOS(DATE()) ,Empty(M->DTCHEG))", "€€€€€€€", "D", "" } )
AADD(aHeader,{ "Descricao"      ,"DESCR"   ,"  "             ,40, 0, "M->DESCR == aCols[n,7]", "       ", "C", "" } )
AADD(aHeader,{ "OBS"            ,"OBS"     ,"  "             ,80, 0, " ", "       ", "C", "" } ) //madaleno
AADD(aHeader,{ "Dt Necessidade" ,"DTNECE"  ,""               ,10, 0, "If(aCols[n,3]#0,!Empty(M->DTNECE) .and. DTOS(M->DTNECE) >= DTOS(DATE()) ,Empty(M->DTNECE))", "€€€€€€€", "D", "" } )  // Por Marcos A. Soprani em 112/01/16

aCols := {{space(2),space(15),0000000000.00,Space(1),date(),date(),space(200),space(400),date(),.f.}} // madaleno

_nAnt    := 1
@ 200,  1 TO 550,780 DIALOG oDlg4 TITLE "Autorização de Entrega"
@  20,  5 TO 157,350 MULTILINE MODIFY DELETE object oMultiline freeze 0
@ 142,357 BMPBUTTON TYPE 01 ACTION Atua()
@ 157,357 BMPBUTTON TYPE 02 ACTION Close(oDlg4)

ACTIVATE DIALOG oDlg4 CENTERED

return

********************************************************************************************
Static Function Atua()
aTpFrete := {}
Processa( {|| Atua1a() } )

return .t.

********************************************************************************************
Static Function Atua1a()

Local j

ProcRegua(len(aCols))
aCols2 := {}

cTpFrete := aCols[1,4]

If aScan(aCols, {|x| x[4] <> cTpFrete }) > 0
	MsgBox("Não é permitido tipos de frete diferentes para a mesma autorização de entrega!","Aten‡Æo","ALERT")
	return .t.
EndIf

For j := 1 to len(aCols)
	
	IncProc()
	If aCols[j,3] #0 .and. !Empty(aCols[j,2]) //.and. !aCols[j,5] Foi retirado a obrigatoriedade da Observacao Ranisses
		
		If !aCols[j,4] $ "C/F"
			MsgBox("Tipo de Frete não identificado,"+chr(10)+"Operacao cancelada!","Aten‡Æo","ALERT")
			return .t.
		ElseIf Empty(aCols[j,5])
			MsgBox("Autorizacao sem data de entrega,"+chr(10)+"Operacao cancelada!","Aten‡Æo","ALERT")
			return .t.
		EndIf
		
		xCols := {}
		AADD(xCols,aColsS[j,1]) // C3_FILIAL
		AADD(xCols,aColsS[j,2]) // C3_NUM
		AADD(xCols,aColsS[j,3]) // C3_ITEM
		AADD(xCols,aColsS[j,4]) // C3_FORNECE
		AADD(xCols,aColsS[j,5]) // C3_PRODUTO
		AADD(xCols,aCols[j,3])  // QTDSOL
		AADD(xCols,aCols[j,4])  // TPFRETE
		AADD(xCols,aCols[j,5])  // DTENTR
		AADD(xCols,aCols[j,6])  // DTCHEG
		AADD(xCols,aCols[j,8])  // obs    // madaleno
		AADD(xCols,aCols[j,9])  // DTNESS // Marcos Alberto Soprani 12/01/16
		AADD(aCols2,xCols)
	EndIf
Next

If len(aCols2) # 0
	ProcRegua(len(aCols2))
	Asort(aCols2,,, { |x, y| x[4]+x[5] < y[4]+y[5] }) // Reordena por Fornecedor+produto
	IncProc()
	DbSelectArea("SC3")
	cForn := space(6)
	For j := 1 to len(aCols2)
		DbSeek(aCols2[j,1]+aCols2[j,2]+aCols2[j,3]) // filial+num+item
		If aCols2[j,4] #cForn
			nItem := 0
			DbSelectArea("SC7")
			DbSeek(aCols2[j,1]+"A99999",.t.)
			DbSkip(-1)
			If left(SC7->C7_NUM,1) #"A"
				cNum := "A00001"
			Else
				cNum := "A"+strzero(((val(subst(sc7->c7_num,2,5)))+1),5)
			EndIf
			cForn := aCols2[j,4]
		EndIf
		DbSelectArea("SB1")
		DbSeek(xFilial("SB1")+SC3->C3_PRODUTO)
		nItem := nItem + 1
		RecLock("SC7",.T.)
		SC7->C7_FILIAL	:= SC3->C3_FILIAL
		SC7->C7_TIPO	:= 2
		SC7->C7_ITEM	:= strzero(nItem,4)
		SC7->C7_PRODUTO := SC3->C3_PRODUTO
		SC7->C7_DESCRI	:= SB1->B1_DESC
		SC7->C7_QUANT	:= aCols2[j,6]
		SC7->C7_UM		:= SB1->B1_UM
		SC7->C7_PRECO	:= SC3->C3_PRECO
		SC7->C7_TOTAL	:= SC7->C7_PRECO * SC7->C7_QUANT
		SC7->C7_IPI		:= SC3->C3_IPI
		If SC7->C7_IPI > 0
			SC7->C7_BASEIPI	  := SC7->C7_TOTAL
			SC7->C7_VALIPI	  := (SC7->C7_BASEIPI * SC7->C7_IPI)/100
		EndIf
		
		SC7->C7_TPFRETE := aCols2[j,7]
		SC7->C7_USER := __cUserID
		
		IF SB1->B1_GRUPO = 'PA'
			SC7->C7_SEGUM   := SB1->B1_SEGUM
			SC7->C7_QTSEGUM := C7_QUANT / SB1->B1_CONV
			SC7->C7_YTAG    := 'COMGE001'
			SC7->C7_CONTA   := SB1->B1_CONTA
			SC7->C7_IPIBRUT := 'B'
			SC7->C7_FLUXO   := 'S'
			SC7->C7_BASEICM := SC7->C7_PRECO * SC7->C7_QUANT
			SC7->C7_BASEIPI := SC7->C7_PRECO * SC7->C7_QUANT
			SC7->C7_PENDEN  := 'N'
			SC7->C7_PICM    := 17
			SC7->C7_QTDSOL  := aCols2[j,6]
			SC7->C7_VALICM  := (SC7->C7_BASEICM * SC7->C7_PICM)/100
			SC7->C7_POLREPR := 'N'
			SC7->C7_GRADE   := 'N'
			SC7->C7_RATEIO  := '2'			
		ENDIF
		
		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+SB1->B1_TE,.T.)
		SC7->C7_TES		  := SB1->B1_TE
		SC7->C7_YICMS	  := Iif(SF4->F4_CREDICM=="S","S","N")
		SC7->C7_YPIS	  := Iif(SF4->F4_PISCOF $ "13" .AND. SF4->F4_PISCRED =="1","S","N")
		SC7->C7_YCOF	  := Iif(SF4->F4_PISCOF $ "23" .AND. SF4->F4_PISCRED =="1","S","N")
		SC7->C7_YIPI	  := Iif(SF4->F4_CREDIPI=="S","S","N")
		SC7->C7_DATPRF	  := aCols2[j,8]
		SC7->C7_YDATCHE   := aCols2[j,9]
		SC7->C7_LOCAL	  := SC3->C3_LOCAL
		SC7->C7_FORNECE	  := SC3->C3_FORNECE
		SC7->C7_LOJA	  := SC3->C3_LOJA
		SC7->C7_COND	  := SC3->C3_COND
		SC7->C7_OBS		  := alltrim(aCols2[j,10]) //SC3->C3_OBS
		SC7->C7_CONTATO	  := SC3->C3_CONTATO
		SC7->C7_FILENT	  := SC3->C3_FILENT
		SC7->C7_EMISSAO	  := DATE()
		SC7->C7_NUM    	  := cNum
		SC7->C7_REAJUST	  := SC3->C3_REAJUST
		SC7->C7_FRETE  	  := SC3->C3_FRETE
		SC7->C7_EMITIDO   := "N"
		SC7->C7_TPFRETE   := SC3->C3_TPFRETE
		SC7->C7_MSG       := SC3->C3_MSG
		//IF SC3->C3_MOEDA <> 0
		IF (SC3->C3_MOEDA <> 0 .And. !Empty(SC3->C3_MOEDA))
			SC7->C7_MOEDA := SC3->C3_MOEDA
		ELSE
			SC7->C7_MOEDA := 1
		ENDIF
		SC7->C7_ORIGEM    := "1"
		SC7->C7_YAPLIC    := "0"
		SC7->C7_YDTNECE   := aCols2[j,11] // Por Marcos Alberto Soprani em 12/01/16
		
		SC7->(MsUnlock())
		
		RecLock("SC3",.F.)
		SC3->C3_QUJE := SC3->C3_QUJE + aCols2[j,6]
		IF SC3->C3_QUJE >= SC3->C3_QUANT
			SC3->C3_ENCER     := 'E'
			SC3->C3_RESIDUO   := 'S'
			SC3->C3_DATPRF    := DDATABASE
		ENDIF
		SC3->(MsUnlock())
		
		MsgBox("AUTORIZAÇÃO DE ENTREGA Nº: " + ALLTRIM(cNum), "Atencao", "INFO")
		
		// Associa o transportador a autorizacao de entrega
		U_BIAF090(cNum)
		
		// Envia e-mail automatico
		U_BIAF091(cNum, "A")
		
	next
	
EndIf

Close(oDlg4)

Return .T.
