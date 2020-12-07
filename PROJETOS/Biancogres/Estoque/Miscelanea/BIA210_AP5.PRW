#include "rwmake.ch" 
#INCLUDE "Topconn.ch"

User Function bia210()

	Local _ni

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³ Bia210     ³ Autor ³ Marcelo Ventura Felix ³ Data ³21/03/2000³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Carga de Metas Comercial                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador xBase                                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	cMesAno  := "  /    "
	cDti     := cDtf := space(8)
	cFormato := cTipo := cEmp := ""  // Classifica‡Æo
	aHeader  := {} // Cabecalho
	aValids  := {} // Valida‡äes das colunas
	aItems   := {} // Items do ComboBox
	nUsado   := 0

	//Define colunas do browse
	dbSelectArea( "SX3" )
	DbSeek("UZ1")
	tb := "Z1_DATA_Z1_QTMPEDE_Z1_VMTCARP_Z1_QTMTFAT_UZ1_VLRMFA_Z1_VLMMRGB_Z1_VLMRGC_Z1_QTMEXP_Z1_NDDMPZM"
	Do While !EOF() .And. X3_ARQUIVO == "UZ1"
		If x3_usado != " " .And. cNivel >= X3_NIVEL .and. alltrim(x3_campo) $ tb
			nUsado := nUsado + 1
			AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, ;
			X3_DECIMAL, "execblock('"+if(nUsado==1,"bia209dt","bia209vd")+"')", X3_USADO, X3_TIPO, X3_ARQUIVO } )
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
	DbSelectArea("SX5")
	DbSeek("  63")
	Do While X5_TABELA == "63"
		AADD(Feriados,left(alltrim(X5_DESCRI),8))   
		Skip
	EndDo
	cComboClas := aDescrClas[1]

	//Valores de Complemento
	dbSelectArea( "UZ1" )
	dbgoto(lastrec()+1)
	vCols := Array(nUsado+1)

	For _ni:=1 to nUsado
		vCols[_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
	Next
	vCols[nUsado+1]:=.F.

	@ 200,1 TO 400,540 DIALOG oDlg3 TITLE "Metas - Comercial"
	@   7,  10 SAY "Mes/Ano:"
	@   7,  37 GET cMesAno  picture "99/9999" valid !Empty(cMesAno) .and. val(right(cMesAno,4)) #0 .and. strzero(val(left(cMesAno,2)),2)$"01102_03_04_05_06_07_08_09_12";
	WHEN .t. SIZE 25, 10 OBJECT oMesAno
	@  7,70 Say "Classificacao:"
	@  7,107 COMBOBOX cComboClas ITEMS aDescrClas SIZE 75,50

	@  7,190 Say "Empresa:"
	@  7,220 COMBOBOX cComboEmp ITEMS aDescEmp SIZE 50,50

	@ 70,240 BMPBUTTON TYPE 01 ACTION DATA_VALIDA()
	@ 85,240 BMPBUTTON TYPE 02 ACTION Close(oDlg3)
	ACTIVATE DIALOG oDlg3 CENTERED
return

Static Function Proc1()
	aCols    :={}
	aCols_Bkp:={}
	_nAnt    := 1

	Processa( {|| Proc1a() } )
	@ 200,  1 TO 400,540 DIALOG oDlg4 TITLE "Metas - Comercial"
	@   7, 10 SAY "Mes/Ano:"
	@   7, 37 GET cMesAno  picture "99/9999" WHEN .f. SIZE 25, 10
	@   7, 70 Say "Classificacao:"
	@   7,107 GET cComboClas picture "@!"    WHEN .f. SIZE 75, 10

	@   7,190 Say "Empresa:"
	@   7,220 GET cComboEmp picture "@!"     WHEN .f. SIZE 75, 10

	@  20, 10 TO  95,235 MULTILINE MODIFY DELETE object oMultiline valid ok() freeze 1
	@  70,240 BMPBUTTON TYPE 01 ACTION Atua()
	@  85,240 BMPBUTTON TYPE 02 ACTION Close(oDlg4)
	ACTIVATE DIALOG oDlg4 CENTERED
	dlgRefresh(oDlg3)
	CursorArrow()
	ObjectMethod(oMesano,"SetFocus(cMesAno)")
	ObjectMethod(oMesAno, "Refresh()" )
return

STATIC FUNCTION DATA_VALIDA()
	IF LEN(ALLTRIM(cMesAno)) = 7
		Proc1()
	ELSE
		MSGBOX("ATENÇÃO, INFORME A DATA COM 4 DIGITOS","INFO","INFO")
	END IF
RETURN

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
	cData 		:= strzero(val(right(cMesAno,4)),4)+strzero(val(left(cMesAno,2)),2)
	cFormato 	:= left(aCodClas[Ascan(aDescrClas,cComboClas)],2)
	cTipo    	:= right(aCodClas[Ascan(aDescrClas,cComboClas)],1) 
	cEmp			:= aCodEmp[Ascan(aDescEmp,cComboEmp)]
	//dbseek(xFilial()+cData)
	//Do While UZ1->Z1_FILIAL+left(DTOS(UZ1->Z1_DATA),6) == xFilial()+cData
	//   If UZ1->Z1_FORMATO+UZ1->Z1_TIPO == cFormato+cTipo
	CSQL := ""  // MADALENO
	CSQL += "SELECT 	Z1_DATA, Z1_QTMPEDE, Z1_VMTCARP, Z1_QTMTFAT, " 
	CSQL += "			UZ1_VLRMFA, Z1_VLMMRGB, Z1_VLMRGC, Z1_QTMEXP, Z1_NDDMPZM  "
	CSQL += "FROM " +RETSQLNAME("UZ1")+ " " 
	CSQL += "WHERE 	SUBSTRING(Z1_DATA,1,6) = '"+cData+"' AND  " 
	CSQL += "		Z1_FORMATO = '"+cFormato+"' AND "
	CSQL += "		Z1_TIPO = '"+cTipo+"' AND	" 
	CSQL += "		UZ1_EMP = '"+cEmp+"' AND	" 
	CSQL += "		D_E_L_E_T_ = ''				" 
	CSQL += "ORDER BY Z1_DATA ASC				" 
	If chkfile("s_UZ1")  
		dbSelectArea("s_UZ1")  
		dbCloseArea()  
	EndIf  
	TCQUERY CSQL ALIAS "s_UZ1" NEW  // MADALENO
	DO WHILE ! s_UZ1->(EOF())		  // MADALENO
		AADD(aCols,Array(nUsado+1))
		aCols[Len(aCols),1]		:=	STOD(s_UZ1->Z1_DATA) // MADALENO	
		aCols[Len(aCols),2]		:=	s_UZ1->Z1_QTMPEDE // MADALENO	
		aCols[Len(aCols),3]		:=	s_UZ1->Z1_VMTCARP // MADALENO	
		aCols[Len(aCols),4]		:=	s_UZ1->Z1_QTMTFAT // MADALENO	
		aCols[Len(aCols),5]		:=	s_UZ1->UZ1_VLRMFA // MADALENO	
		aCols[Len(aCols),6]		:=	s_UZ1->Z1_VLMMRGB // MADALENO	
		aCols[Len(aCols),7]		:=	s_UZ1->Z1_VLMRGC // MADALENO	
		aCols[Len(aCols),8]		:=	s_UZ1->Z1_QTMEXP // MADALENO	
		aCols[Len(aCols),9]		:=	s_UZ1->Z1_NDDMPZM // MADALENO	
		aCols[Len(aCols),10]	:=	.F. // MADALENO	
		s_UZ1->(dbSkip())   
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

Static Function Atua()
	Processa( {|| Atua1a() } )
return

Static Function Atua1a()

	Local _ni
	Local j

	ProcRegua(len(aCols))
	DbSelectArea("UZ1")
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
					RecLock("UZ1",.F.)
					delete
					MsUnLock()
					IncProc("Removendo dia "+dtoc(aCols[j,1]))
				EndIf
			Else
				//Incluir e Alterar
				If Empty(aCols_Bkp[j,1])
					RecLock("UZ1",.T.)
					IncProc("Gerando dia "+dtoc(aCols[j,1]))
				else
					dbseek("  "+dtos(aCols_Bkp[j,1])+cFormato+cTipo+cEmp)
					RecLock("UZ1",.F.)
					IncProc("Atualizando dia "+dtoc(aCols[j,1]))
				EndIf
				UZ1->Z1_FORMATO	:= cFormato
				UZ1->Z1_TIPO		:= cTipo
				UZ1->UZ1_EMP		:= cEmp
				For _ni:=1 to nUsado
					xCampo := "UZ1->"+(aHeader[_ni,2])+" :=  aCols[j,_ni]"
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