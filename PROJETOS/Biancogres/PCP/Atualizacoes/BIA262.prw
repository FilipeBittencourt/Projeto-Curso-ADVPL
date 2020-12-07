#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA262
Empresa   := Biancogres Cerâmica S/A
Data      := 26/08/11
Uso       := PCP
Aplicação := Browser para cadastro de Ensaios usados pela fábrica para ve-
.            rificação de qualidade.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA262()

	Private cCadastro := "Controle de Ensaios de Qualidade"

	aRotina   := {  {"Pesquisar"     ,"AxPesqui"	                        ,0 ,1},;
	{                "Visualizar"   ,'Execblock("BIA262B" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"      ,'Execblock("BIA262B" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"      ,'Execblock("BIA262B" ,.F.,.F.,"A")'    ,0, 4},;
	{                "Excluir"      ,'Execblock("BIA262B" ,.F.,.F.,"E")'    ,0, 5} }

	dbSelectArea("Z03")
	dbSetOrder(1)
	dbGoTop()

	Z03->(mBrowse(06,01,22,75,"Z03"))

	dbSelectArea("Z03")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA262B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 31.07.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem de Tela Modelo2                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA262B()

	local _i
	Local _ni

	wopcao      := Paramixb
	lVisualizar := .F.
	lIncluir    := .F.
	lAlterar    := .F.
	lExcluir    := .F.

	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "INCLUIR"
		Case wOpcao == "A" ; lAlterar    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "ALTERAR"
		Case wOpcao == "E" ; lExcluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "EXCLUIR"
	EndCase

	xs_Produ    := Space(15)
	xs_Descr    := Space(50)
	xs_Revis    := Space(03)
	xs_DtIn     := dDataBase
	xs_DtFi     := dDataBase
	If !lIncluir
		xs_Produ    := Z03->Z03_PRODUT
		xs_Descr    := Substr(Posicione("SB1", 1, xFilial("SB1")+Z03->Z03_PRODUT,"B1_DESC"),1,50)
		xs_Revis    := Z03->Z03_REVSAO
		xs_DtIn     := Z03->Z03_DTINI
		xs_DtFi     := Z03->Z03_DTFIM
	EndIf

	nOpcx    := 0
	nUsado   := 0
	aHeader  := {}
	aCols    := {}

	zy_Cab  := {"Z03_PRODUT","Z03_DESCRI","Z03_REVSAO","Z03_DTINI ","Z03_DTFIM "}
	zy_Grid := {}
	nUsado := 0
	dbSelectArea("SX3")
	dbSeek("Z03")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "Z03"
		If aScan(zy_Cab, SX3->X3_CAMPO)	== 0
			If x3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado := nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, , } )
				Aadd(zy_Grid, x3_campo)
			Endif
		EndIf
		dbSkip()
	End
	Aadd(aHeader,{ "Registro", "REGZ03", "99999999999999", 14, 0,"AllwaysTrue()", x3_usado, "N", x3_arquivo, x3_context } )

	aCols:={}
	If !lIncluir
		dbSelectArea("Z03")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("Z03")+xs_Produ+xs_Revis)
		While !Eof() .and. Z03->Z03_FILIAL == xFilial("Z03") .and. Z03->Z03_PRODUT == xs_Produ .and. Z03_REVSAO == xs_Revis
			AADD(aCols,Array(nUsado+2))
			For _ni := 1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				If Alltrim(aHeader[_ni,2]) == "Z03_DESCTP"
					aCols[Len(aCols),_ni] := TABELA("ZL",aCols[Len(aCols)][1])
				EndIf
			Next
			aCols[Len(aCols),nUsado+1] := Recno()
			aCols[Len(aCols),nUsado+2] := .F.
			dbSkip()
		End
	EndIf

	If Len(Acols) == 0
		aCols := {Array(nUsado+2)}
		For _ni := 1 to nUsado
			aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1] := 0
		aCols[1,nUsado+2] := .F.
	EndIf

	If len(aCols) == 0
		Return
	EndIf

	cTitulo  := "..: "+cCadastro+" :.."
	aC := {}
	aR := {}

	aCGD   := {170,05,250,455}
	aCordw := {95,03,600,820}

	xf_Prod := xs_Produ
	xf_Desc := xs_Descr
	xf_Revi := xs_Revis
	xf_DtIn := xs_DtIn
	xf_DtFi := xs_DtFi

	If lVisualizar
		AADD(aC,{"xf_Prod"   ,{020,010}  ,"Produto:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'1')", "SB1", .F.})
		AADD(aC,{"xf_Desc"   ,{020,130}  ,"Descrição:"        ,"@!",                                   ,      , .F.})
		AADD(aC,{"xf_Revi"   ,{020,500}  ,"Revisão:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'2')",      , .F.})
		AADD(aC,{"xf_DtIn"   ,{040,010}  ,"Data Ini: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      , .F.})
		AADD(aC,{"xf_DtFi"   ,{040,130}  ,"Data Fim: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      , .F.})
		aGetsD   := {}
		nOpcx    := 1
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lIncluir
		AADD(aC,{"xf_Prod"   ,{020,010}  ,"Produto:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'1')", "SB1",})
		AADD(aC,{"xf_Desc"   ,{020,130}  ,"Descrição:"        ,"@!",                                   ,      , .F.})
		AADD(aC,{"xf_Revi"   ,{020,500}  ,"Revisão:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'2')",      ,})
		AADD(aC,{"xf_DtIn"   ,{040,010}  ,"Data Ini: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      ,})
		AADD(aC,{"xf_DtFi"   ,{040,130}  ,"Data Fim: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      ,})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lAlterar
		AADD(aC,{"xf_Prod"   ,{020,010}  ,"Produto:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'1')", "SB1", .F.})
		AADD(aC,{"xf_Desc"   ,{020,130}  ,"Descrição:"        ,"@!",                                   ,      , .F.})
		AADD(aC,{"xf_Revi"   ,{020,500}  ,"Revisão:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'2')",      , .F.})
		AADD(aC,{"xf_DtIn"   ,{040,010}  ,"Data Ini: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      , .F.})
		AADD(aC,{"xf_DtFi"   ,{040,130}  ,"Data Fim: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      ,})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lExcluir
		AADD(aC,{"xf_Prod"   ,{020,010}  ,"Produto:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'1')", "SB1", .F.})
		AADD(aC,{"xf_Desc"   ,{020,130}  ,"Descrição:"        ,"@!",                                   ,      , .F.})
		AADD(aC,{"xf_Revi"   ,{020,500}  ,"Revisão:  "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'2')",      , .F.})
		AADD(aC,{"xf_DtIn"   ,{040,010}  ,"Data Ini: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      , .F.})
		AADD(aC,{"xf_DtFi"   ,{040,130}  ,"Data Fim: "        ,"@!", "ExecBlock('BIA262C',.F.,.F.,'3')",      , .F.})
		aGetsD   := {}
		nOpcx    := 1
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .F.     )

	EndIf

	If lRet

		If lIncluir

			For _i := 1 to len(aCols)
				If !aCols[_i,nUsado+2]
					RecLock("Z03",.T.)
					Z03->Z03_FILIAL := xFilial("Z03")
					Z03->Z03_PRODUT := xf_Prod
					Z03->Z03_REVSAO := xf_Revi
					Z03->Z03_DTINI  := xf_DtIn
					Z03->Z03_DTFIM  := xf_DtFi
					Z03->Z03_TIPO   := GdFieldGet("Z03_TIPO",_i)
					Z03->Z03_INTRDE := GdFieldGet("Z03_INTRDE",_i)
					Z03->Z03_INTRAT := GdFieldGet("Z03_INTRAT",_i)
					Z03->Z03_MEDIDA := GdFieldGet("Z03_MEDIDA",_i)
					MsUnLock()
				EndIf
			Next _i

			U0001 := " UPDATE "+RetSqlName("Z03")+" SET Z03_DTFIM = '"+dtos(xf_DtIn-1)+"'
			U0001 += "  WHERE Z03_FILIAL = '"+xFilial("Z03")+"'
			U0001 += "    AND Z03_PRODUT = '"+xf_Prod+"'
			U0001 += "    AND Z03_DTFIM > '"+dtos(xf_DtIn)+"'
			U0001 += "    AND D_E_L_E_T_ = ' '
			TCSQLExec(U0001)

		ElseIf lAlterar

			For _i := 1 to len(aCols)
				If !aCols[_i,nUsado+2]
					dbSelectArea("Z03")
					If GdFieldGet("REGZ03",_i) == 0
						RecLock("Z03",.T.)
						Z03->Z03_FILIAL := xFilial("Z03")
						Z03->Z03_PRODUT := xf_Prod
						Z03->Z03_REVSAO := xf_Revi
						Z03->Z03_DTINI  := xf_DtIn
					Else
						dbGoto(GdFieldGet("REGZ03",_i))
						RecLock("Z03",.F.)
					EndIf
					Z03->Z03_DTFIM  := xf_DtFi
					Z03->Z03_TIPO   := GdFieldGet("Z03_TIPO",_i)
					Z03->Z03_INTRDE := GdFieldGet("Z03_INTRDE",_i)
					Z03->Z03_INTRAT := GdFieldGet("Z03_INTRAT",_i)
					Z03->Z03_MEDIDA := GdFieldGet("Z03_MEDIDA",_i)
					MsUnLock()
				Else
					dbSelectArea("Z03")
					dbGoto(GdFieldGet("REGZ03",_i))
					RecLock("Z03",.F.)
					DELETE
					MsUnLockAll()
				EndIf
			Next _i

		ElseIf lExcluir

			For _i := 1 to len(aCols)
				dbSelectArea("Z03")
				dbGoto(GdFieldGet("REGZ03",_i))
				RecLock("Z03",.F.)
				DELETE
				MsUnLockAll()
			Next _i

		EndIf

	EndIf

	n := 1

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA262C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 31.07.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validações diversas para os campos do cabec                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA262C()

	Local llRetOk := .T.
	Local llGatil := ParamIXB

	If llGatil == "1"

		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+xf_Prod)
			If SB1->B1_MSBLQL == "1"
				MsgINFO("Produto Bloqueado.")
				llRetOk := .F.
			EndIf
			xf_Desc := Substr(SB1->B1_DESC,1,50)
		Else
			MsgINFO("Produto não cadastrado.")
			llRetOk := .F.
		EndIf

	ElseIf llGatil == "2"

		If Len(Alltrim(xf_Revi)) < 3
			MsgINFO("É necessário informar a revisão com 3 digitos (zeros a esquerda).")
			llRetOk := .F.
		Else
			dbSelectArea("Z03")
			dbSetOrder(1)
			If dbSeek(xFilial("Z03")+xf_Prod+xf_Revi)
				MsgINFO("Esta revisão já está cadastrada para este produto.")
				llRetOk := .F.
			EndIf
		EndIf

	ElseIf llGatil == "3"

		If xf_DtIn > xf_DtFi
			MsgINFO("A data inicial não pode ser menor que a data final.")
			llRetOk := .F.
		ElseIf !lAlterar
			H0001 := " SELECT COUNT(*) CONTAD
			H0001 += "   FROM " + RetSqlName("Z03")
			H0001 += "  WHERE Z03_FILIAL = '"+xFilial("Z03")+"'
			H0001 += "    AND Z03_PRODUT = '"+xf_Prod+"'
			H0001 += "    AND '"+dtos(xf_DtIn-1)+"' < Z03_DTINI
			H0001 += "    AND D_E_L_E_T_ = ' '
			TCQUERY H0001 New Alias "H001"
			dbSelectArea("H001")
			dbGotop()
			If H001->CONTAD > 0
				MsgINFO("A data irá gerar conflito com as revisões já gravadas.")
				llRetOk := .F.
			EndIf
			H001->(dbCloseArea())
		EndIf

	EndIf

Return ( llRetOk )
