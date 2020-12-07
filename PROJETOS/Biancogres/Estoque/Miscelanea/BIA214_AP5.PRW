#include "rwmake.ch"
#INCLUDE "Topconn.ch"

User Function bia214()

	local _ni

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³ Bia214     ³ Autor ³ Marcelo Ventura Felix ³ Data ³25/04/2000³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Carga de Qtd Produzida por formato                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador xBase                                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	cMesAno  := "  /    "
	cDti     := cDtf := space(8)
	cFormato := cTipo := cEmp := ""  // Classifica‡Æo
	aHeader  := {} // Cabecalho
	aValids  := {} // Valida‡äes das colunas
	aItems   := {} // Items do ComboBox
	nUsado   := 0

	//Define colunas do browse
	dbSelectArea( "SX3" )
	DbSeek("UZ4")
	tb := "Z4_DATA_Z4_QTPRO"
	Do While !EOF() .And. X3_ARQUIVO == "UZ4"
		If x3_usado != " " .And. cNivel >= X3_NIVEL .and. alltrim(x3_campo) $ tb
			nUsado := nUsado + 1
			AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, ;
			X3_DECIMAL, "execblock('"+if(nUsado==1,"bia214dt","bia214vd")+"')", X3_USADO, X3_TIPO, X3_ARQUIVO } )
			If nUsado > 1 // Nao permitir completar data
				AADD(aItems, TRIM(X3_TITULO) )
			Endif
			AADD(aValids,{ TRIM(X3_TITULO), X3_CAMPO, X3_VALID } )
		EndIf
		Skip
	EndDo

	//Define Combo das Classificacoes
	aCodClas   := {}
	aDescrClas := {}
	DbSelectArea( "ZZC" )
	DbGoTop()
	Do While !Eof()
		AADD(aCodClas,trim(ZZC->ZZC_FORMAT+ZZC->ZZC_CLASSE))
		AADD(aDescrClas,ZZC->ZZC_DESC)
		Skip
	EndDo

	//Define Combo Empresa
	If cEmpAnt == "01"
		aCodEmp		:= {}
		aDescEmp	:= {}
		AADD(aCodEmp,"0101")
		AADD(aDescEmp,"Biancogres")
		cComboEmp := aDescEmp[1]
	Else
		aCodEmp		:= {}
		aDescEmp	:= {}
		AADD(aCodEmp,"0501")
		AADD(aDescEmp,"Incesa")
		AADD(aCodEmp,"0599")
		AADD(aDescEmp,"Bellacasa")
		cComboEmp := aDescEmp[1]
	EndIf

	Feriados := {}
	DbSelectArea( "SX5" )
	DbSeek("  63")
	Do While X5_TABELA == "63"
		AADD(Feriados,left(alltrim(X5_DESCRI),5))
		Skip
	EndDo
	cComboClas := aDescrClas[1]

	//Define Valores de Complemento
	dbSelectArea( "UZ4" )
	dbgoto(lastrec()+1)
	vCols := Array(nUsado+1)

	For _ni:=1 to nUsado
		vCols[_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
	Next
	vCols[nUsado+1]:=.F.

	@ 200,1 TO 400,540 DIALOG oDlg3 TITLE "Metas - Diretoria"
	@   7,  10 SAY "Mes/Ano:"
	@   7,  37 GET cMesAno  picture "99/9999" valid !Empty(cMesAno) .and. val(right(cMesAno,4)) #0 .and. strzero(val(left(cMesAno,2)),2)$"01_02_03_04_05_06_07_08_09_10_11_12";
	WHEN .t. SIZE 25, 10 OBJECT oMesAno
	@  7,70 Say "Classificacao:"
	@  7,107 COMBOBOX cComboClas ITEMS aDescrClas SIZE 75,50

	@  7,190 Say "Empresa:"
	@  7,220 COMBOBOX cComboEmp ITEMS aDescEmp SIZE 50,50

	@ 70,240 BMPBUTTON TYPE 01 ACTION Proc1()
	@ 85,240 BMPBUTTON TYPE 02 ACTION Close(oDlg3)
	ACTIVATE DIALOG oDlg3 CENTERED
return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ Proc1    ¦ Autor ¦                       ¦ Data ¦   /  /   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Proc1()

	aCols    :={}
	aCols_Bkp:={}
	_nAnt    := 1

	Processa( {|| Proc1a() } )

	@ 200,  1 TO 400,540 DIALOG oDlg4 TITLE "Metas - Diretoria"
	@   7, 10 SAY "Mes/Ano:"
	@   7, 37 GET cMesAno  picture "99/9999" WHEN .f. SIZE 25, 10
	@   7, 70 Say "Classificacao:"
	@   7,107 GET cComboClas picture "@!"    WHEN .f. SIZE 75, 10

	@   7,190 Say "Empresa:"
	@   7,220 GET cComboEmp picture "@!"     WHEN .f. SIZE 75, 10

	@  20, 10 TO  95,157 MULTILINE MODIFY DELETE object oMultiline valid ok() freeze 1
	@  70,240 BMPBUTTON TYPE 01 ACTION Atua()
	@  85,240 BMPBUTTON TYPE 02 ACTION Close(oDlg4)

	ACTIVATE DIALOG oDlg4 CENTERED
	dlgRefresh(oDlg3)
	CursorArrow()
	ObjectMethod(oMesano,"SetFocus(cMesAno)")
	ObjectMethod(oMesAno, "Refresh()" )

return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ ok       ¦ Autor ¦                       ¦ Data ¦   /  /   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static function ok()
	if n == len(aCols)
		return .f.
	endif
return .t.

Static Function Proc1a()

	Local _ni

	//Carga do Resultado da pesquisa
	ProcRegua(reccount())
	IncProc()
	dbgoto(lastrec()+1)
	cData			:= strzero(val(right(cMesAno,4)),4)+strzero(val(left(cMesAno,2)),2)
	cFormato	:= left(aCodClas[Ascan(aDescrClas,cComboClas)],2)
	cTipo			:= right(aCodClas[Ascan(aDescrClas,cComboClas)],1)
	cEmp			:= aCodEmp[Ascan(aDescEmp,cComboEmp)]
	dbseek(xFilial()+cData)
	Do While UZ4->Z4_FILIAL+left(DTOS(UZ4->Z4_DATA),6) == xFilial("UZ4")+cData
		If UZ4->Z4_FORMATO+UZ4->Z4_TIPO+UZ4->UZ4_EMP == cFormato+cTipo+cEmp
			IncProc("Carregando dia "+dtoc(UZ4->Z4_DATA))
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
		Endif
		dbSkip()
	EndDo
	aCols_Bkp  := ACLONE(aCols) // Matriz Espelho
	If len(aCols) == 0
		//Gera Novo Mes
		dData := ctod("01/"+cMesAno)
		Do While month(dData) == val(left(cMesAno,2))
			IncProc("Gerando dia "+dtoc(dData))
			AADD(aCols,Array(nUsado+1))
			AADD(aCols_Bkp,Array(nUsado+1))
			aCols[Len(aCols),1]:=dData
			For _ni:=2 to nUsado
				aCols[Len(aCols),_ni]:=vCols[_ni]
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			aCols[Len(aCols_Bkp),nUsado+1]:=.F.
			dData := dData + 1
		EndDo
	EndIf
	dData := ctod("01/"+cMesAno)
	cDtI := dtos(dData)
	Do While month(dData) == val(left(cMesAno,2))
		cDtF := dtos(dData)
		dData := dData + 1
	EndDo

return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ Atua     ¦ Autor ¦                       ¦ Data ¦   /  /   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Atua()

	Processa( {|| Atua1a() } )

return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ Atua1a   ¦ Autor ¦                       ¦ Data ¦   /  /   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Atua1a()

	Local _ni, j

	ProcRegua(len(aCols))

	DbSelectArea("UZ4")
	For j := 1 to len(aCols)
		lGrava := .f.
		If aCols[j,nUsado+1] .and. !Empty(aCols_Bkp[j,1]) // Excluir
			lGrava := .t.
		Else
			//Verifica se houve campo alterado
			For _ni:=1 to nUsado
				If aCols[j,_ni] #aCols_Bkp[j,_ni]
					lGrava := .t.
					exit
				EndIf
			Next
		EndIf
		If lGrava
			If aCols[j,nUsado+1] // Excluir
				If !Empty(aCols_Bkp[j,1])
					dbseek("  "+dtos(aCols_Bkp[j,1])+cFormato+cTipo+cEmp)
					RecLock("UZ4",.F.)
					delete
					MsUnLock()
					IncProc("Removendo dia "+dtoc(aCols[j,1]))
				EndIf
			Else
				//Incluir e Alterar
				If Empty(aCols_Bkp[j,1])
					RecLock("UZ4",.T.)
					IncProc("Gerando dia "+dtoc(aCols[j,1]))
				else
					dbseek("  "+dtos(aCols_Bkp[j,1])+cFormato+cTipo+cEmp)
					RecLock("UZ4",.F.)
					IncProc("Atualizando dia "+dtoc(aCols[j,1]))
				EndIf
				UZ4->Z4_FORMATO 	:= cFormato
				UZ4->Z4_TIPO    	:= cTipo
				UZ4->UZ4_EMP			:= cEmp
				For _ni:=1 to nUsado
					xCampo := "UZ4->"+(aHeader[_ni,2])+" :=  aCols[j,_ni]"
					yCampo := &xCampo
				Next
				MsUnLock()
			EndIf
		Else
			IncProc("Finalizando !...")
		EndIf
	next

	Close(oDlg4)

return
