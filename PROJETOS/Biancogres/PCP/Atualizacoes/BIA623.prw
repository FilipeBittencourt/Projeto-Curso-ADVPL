#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA623
Empresa   := Biancogres Cerâmica S/A
Data      := 28/03/16
Uso       := PCP
Aplicação := Cadastro de Equipes Operacionais
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA623()

	dbSelectArea("Z72")
	dbGoTop()

	n := 1
	cCadastro := " ....: Cadastro de Equipes Operacionais :.... "

	aRotina   := {  {"Pesquisar"   ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"  ,'AxVisual'                             ,0, 2},;
	{                "Incluir"     ,'AxInclui'                             ,0, 3},;
	{                "Alterar"     ,'AxAltera'                             ,0, 4},;
	{                "Excluir"     ,'AxDeleta'                             ,0, 5} }

	mBrowse(6,1,22,75, "Z72", , , , , ,)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIASRA623     ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para consulta personalizada via "F3".       ¦¦¦
¦¦¦          ¦ Com ele podem ser criados filtros mais rápidos e impedi-   ¦¦¦
¦¦¦          ¦ mento para visualização de detalhes que não podem ser ob-  ¦¦¦
¦¦¦          ¦ servados por alguns usuários.                              ¦¦¦
¦¦¦          ¦ Tabela "SRA"                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIASRA623()

	Local aAreaRA   := GetArea()

	Private oDlgSRA
	Private oRAGet1
	Private cRAGet1 := Space(45)
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"RA_MAT","RA_NOME"}
	Private aAlterFields := {"RA_MAT","RA_NOME"}
	Private oMSNewSraDados1
	Public  raRetur1 := ""
	Public  raRetur2 := ""

	DEFINE MSDIALOG oDlgSRA TITLE "Cadastro de Funcionário" FROM 000, 000  TO 540, 600 COLORS 0, 16777215 PIXEL

	fMSNewSraDados1()
	@ 216, 005 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Matricula","Nome" SIZE 071, 026 OF oDlgSRA COLOR 0, 16777215 ON CHANGE wMudRAOrd() PIXEL
	@ 248, 005 MSGET oRAGet1 VAR cRAGet1 SIZE 197, 015 OF oDlgSRA COLORS 0, 16777215 PIXEL
	@ 231, 208 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 037, 032 OF oDlgSRA ACTION( wSRACodCl() ) PIXEL
	@ 231, 255 BUTTON Retornar PROMPT "Retornar" SIZE 037, 032 OF oDlgSRA ACTION( wSRACodSel() ) PIXEL
	ACTIVATE MSDIALOG oDlgSRA

	n := 1
	RestArea( aAreaRA )

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(xFilial("SRA")+raRetur1+raRetur2)
	cNLjSRA   := SRA->RA_MAT
	cNomeRA   := SRA->RA_NOME

Return .T.

//*******************************************************
//**  SubFunction1 ref: BIASRA623()                    **
//*******************************************************
Static Function fMSNewSraDados1()

	Local nX
	Local _cAliasSr	:=	U_fGetDbSr()

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			If Alltrim(aFields[nX]) == "RA_MAT"
				Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,'99999999',8,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Else
				Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			EndIf
		Endif
	Next nX

	A0001 := " SELECT RIGHT('00' + Cast(numemp AS VARCHAR(2)), 2) + RIGHT('000000' + Cast(numcad AS VARCHAR(6)), 6) MAT "
	A0001 += "		,nomfun NOME "
	A0001 += "	FROM "+_cAliasSr+"..r034fun a "
	A0001 += "	WHERE tipcol = 1 "
	A0001 += "      AND (sitafa <> 7 "
	A0001 += "           OR "
	A0001 += " ( "
	A0001 += "    SELECT COUNT(*) "
	A0001 += "    FROM " + RetSqlName("ZLB") + " "
	A0001 += "    WHERE CONVERT(NUMERIC, SUBSTRING(ZLB_MATRES, 3, 6)) = a.numcad "
	A0001 += "          AND CONVERT(VARCHAR, GETDATE(), 112) BETWEEN ZLB_DTINI AND ZLB_DTFIM "
	A0001 += "          AND D_E_L_E_T_ = ' ' "
	A0001 += " ) > 0) "
	A0001 += "	ORDER BY numemp,numcad "

	A0cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.F.,.T.)
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		Aadd(aFieldFill, {A001->MAT, A001->NOME, .F. })
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())
	Ferase(A0cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(A0cIndex+OrdBagExt())          //indice gerado

	Aadd(aFieldFill, {'01999998', "MAX ZANCANARO"   , .F. })
	Aadd(aFieldFill, {'01999999', "LUCAS ZENI"      , .F. })

	If Len(aFieldFill) == 0

		For nX := 1 to Len(aFields)
			If dbSeek(aFields[nX])
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)

	Else

		aColsEx := aFieldFill

	EndIf

	oMSNewSraDados1 := MsNewGetDados():New( 005, 005, 213, 294, , , , , , , 999, , , , oDlgSRA, aHeaderEx, aColsEx)

Return

//*******************************************************
//**  SubFunction2 ref: BIASRA623()                    **
//*******************************************************
Static Function wSRACodCl()

	jk_Tam := Len(Alltrim(cRAGet1))
	nPos   := 0
	If Len(aColsEx) > 1

		If nRadMenu1 == 1
			nPos := aScan(aColsEx,{|x| Substr(x[1], 1, jk_Tam) == Substr(cRAGet1, 1, jk_Tam) })
		ElseIf nRadMenu1 == 2
			nPos := aScan(aColsEx,{|x| Substr(x[2], 1, jk_Tam) == Substr(cRAGet1, 1, jk_Tam) })
		EndIf

		If nPos <> 0
			n:=nPos
			oMSNewSraDados1:oBrowse:nAt:=nPos
			oMSNewSraDados1:oBrowse:Refresh()
			oMSNewSraDados1:oBrowse:SetFocus()
		EndIf

	EndIf

Return

//*******************************************************
//**  SubFunction3 ref: BIASRA623()                    **
//*******************************************************
Static Function wMudRAOrd()

	If Len(aColsEx) > 1

		If nRadMenu1 == 1
			aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		ElseIf nRadMenu1 == 2
			aColsEx := aSort(aColsEx,,,{|x,y| x[2] < y[2] })
		EndIf
		oMSNewSraDados1:ACOLS := aColsEx
		oMSNewSraDados1:oBrowse:Refresh()
		oMSNewSraDados1:oBrowse:SetFocus()

	EndIf

Return

//*******************************************************
//**  SubFunction4 ref: BIASRA623()                    **
//*******************************************************
Static Function wSRACodSel()

	raRetur1 := oMSNewSraDados1:ACOLS[oMSNewSraDados1:oBrowse:nAt][1]
	raRetur2 := oMSNewSraDados1:ACOLS[oMSNewSraDados1:oBrowse:nAt][2]
	oDlgSRA:End()

Return
