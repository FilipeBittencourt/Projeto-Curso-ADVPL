#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#Include "font.ch"

/*/{Protheus.doc} BIA557
@author Marcos Alberto Soprani
@since 17/02/16
@version 1.0
@description Controle de Estoque de Esmalte - DIÁRIO
@obs Em 21/02/17, Por Marcos Alberto Soprani - Ajustada filtro dos produtos que servirão de base para a rotina de confrontar
@type function
/*/

User Function BIA557()

	Local aCores
	Private xImpDh := .F.

	Public xtVetNfO := {}

	dbSelectArea("Z66")
	dbGoTop()

	n := 1
	cCadastro := " ....: Controle de Saldos de PI :.... "

	aRotina   := {  {"Pesquisar"   ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"  ,'Execblock("BIA557A" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"     ,'Execblock("BIA557A" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"     ,'Execblock("BIA557A" ,.F.,.F.,"A")'    ,0, 4},;
	{                "Explodir"    ,'Execblock("BIA557X" ,.F.,.F.,"X")'    ,0, 5},;
	{                "Confrontar"  ,'Execblock("BIA557D" ,.F.,.F.,"C")'    ,0, 6},;
	{                "Expr Excel"  ,'Execblock("BIA557L" ,.F.,.F.,"C")'    ,0, 7} }

	mBrowse(6,1,22,75, "Z66", , , , , ,)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem da Tela de Visualização, Inclusao e Alteração     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557A()

	Local _i
	Local xButTela := {}
	Local _ni

	wopcao := Paramixb
	lVisualizar := .F.
	lIncluir    := .F.
	lAlterar    := .F.

	aAdd(xButTela,{"EXCEL"	,{|| BIA557W() }	,"Excel"})

	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "INCLUIR"
		Case wOpcao == "A" ; lAlterar    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "ALTERAR"
	EndCase

	nOpcx    := 0
	nUsado   := 0
	aHeader  := {}
	aCols    := {}

	nUsado := 0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("Z66")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "Z66"
		If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. Alltrim(SX3->X3_CAMPO) <> "Z66_DATA"
			nUsado := nUsado+1
			Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal,"AllwaysTrue()", x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End
	nUsado := nUsado+1
	Aadd(aHeader,{ "REGZ66", "REGZ66", "999999999", 9, 0,"AllwaysTrue()", , "N", , } )

	xf_Data := ctod("  /  /  ")

	xf_Data := dDataBase
	xfOperad := Space(50)
	If cOpcao == "INCLUIR"

		BS001 := " SELECT MAX(Z66_DATA) DTREF
		BS001 += "   FROM " + RetSqlName("Z66")
		BS001 += "  WHERE Z66_FILIAL = '"+xFilial("Z66")+"'
		BS001 += "    AND D_E_L_E_T_ = ' '
		TCQUERY BS001 New Alias "BS01"
		dbSelectArea("BS01")
		dbGotop()
		If !Empty(BS01->DTREF)
			xf_Data := stod(BS01->DTREF)
		EndIf
		BS01->(dbCloseArea())

	Else

		xf_Data  := Z66->Z66_DATA
		xfOperad := Z66->Z66_OPERAD

	Endif

	// Usado para limpar os registros explodidos de PP
	If lAlterar
		BIA557Y()
	EndIf

	aCols:={}
	If cOpcao <> "INCLUIR" .or. cEmpAnt == "05"

		dbSelectArea("Z66")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("Z66")+dtos(xf_Data))
		While !Eof() .and. Z66->Z66_DATA == xf_Data

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+Z66->Z66_PRODUT))

			If Empty(Z66->Z66_SEQORI)

				AADD(aCols,Array(nUsado+1))
				For _ni:=1 to nUsado
					aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
					If Alltrim(aHeader[_ni,2]) == "Z66_DESCRI"
						aCols[Len(aCols),_ni] := Substr(SB1->B1_DESC,1,50)
					EndIf
				Next
				If cOpcao == "INCLUIR"
					aCols[Len(aCols),nUsado] := 0
				Else
					aCols[Len(aCols),nUsado] := Z66->(Recno())
				EndIf
				aCols[Len(aCols),nUsado+1]:=.F.

			EndIf

			dbSelectArea("Z66")
			dbSkip()

		End

	EndIf

	If Len(Acols) == 0
		aCols := {Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni := 1 to nUsado
			If Alltrim(aHeader[_ni,2]) == "Z66_SEQUEN"
				aCols[1,_ni] := "000"
			ElseIf Alltrim(aHeader[_ni,2]) == "REGZ66"
				aCols[1,_ni] := 0
			Else
				aCols[1,_ni] := CriaVar(aHeader[_ni,2])
			EndIf
		Next
	EndIf

	If cOpcao == "INCLUIR"
		xf_Data := dDataBase-1
	EndIf

	If len(aCols) == 0
		Return
	EndIf

	cTitulo  := "..: Controle de Saldos de PI :.."
	aC := {}
	aR := {}

	aCGD   := {70,5,250,455}
	aCordw := {95,03,600,820}

	aSort(aCols,,,{|x,y| x[2] < y[2] })

	If lVisualizar
		nOpcx    := 1
		AADD(aC,{"xf_Data"   ,{20,010}  ,"Data Ref:"          ,"@!",                               ,      , .F.})
		AADD(aC,{"xfOperad"  ,{20,110}  ,"Operador:"          ,"@!",                               ,      , .F.})
		aGetsD   := {}
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD,   , "+Z66_SEQUEN", 999, aCordw, .F. ,,xButTela)

	ElseIf lIncluir
		nOpcx    := 4
		AADD(aC,{"xf_Data"   ,{20,010}  ,"Data Ref:"          ,"@!", "ExecBlock('BIA557B',.F.,.F.)",      ,})
		AADD(aC,{"xfOperad"  ,{20,110}  ,"Operador:"          ,"@!",                               ,      , .T.})
		aGetsD   := {"Z66_TANQUE","Z66_PRODUT","Z66_VAZIO","Z66_DENSID","Z66_SITUAC","Z66_QUANTI"}
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD,   , "+Z66_SEQUEN", 999, aCordw, .T. ,,xButTela)

	ElseIf lAlterar
		nOpcx    := 3
		AADD(aC,{"xf_Data"   ,{20,010}  ,"Data Ref:"          ,"@!",                               ,      , .F.})
		AADD(aC,{"xfOperad"  ,{20,110}  ,"Operador:"          ,"@!",                               ,      , .F.})
		aGetsD   := {"Z66_TANQUE","Z66_PRODUT","Z66_VAZIO","Z66_DENSID","Z66_SITUAC","Z66_QUANTI"}
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD,   , "+Z66_SEQUEN", 999, aCordw, .T. ,,xButTela)

	EndIf

	If lRet

		If lIncluir .or. lAlterar

			For _i := 1 to len(aCols)

				If !aCols[_i,nUsado+1]

					If GdFieldGet("REGZ66",_i) == 0
						RecLock("Z66",.T.)
					Else
						dbSelectArea("Z66")
						dbSetOrder(1)
						dbGoTo(GdFieldGet("REGZ66",_i))
						RecLock("Z66",.F.)
					EndIf
					Z66->Z66_FILIAL := xFilial("Z66")
					Z66->Z66_DATA   := xf_Data
					Z66->Z66_SEQUEN := GdFieldGet("Z66_SEQUEN",_i)
					Z66->Z66_TANQUE := GdFieldGet("Z66_TANQUE",_i)
					Z66->Z66_PRODUT := GdFieldGet("Z66_PRODUT",_i)
					Z66->Z66_VAZIO  := GdFieldGet("Z66_VAZIO" ,_i)
					Z66->Z66_DENSID := GdFieldGet("Z66_DENSID",_i)
					Z66->Z66_SECO   := GdFieldGet("Z66_SECO"  ,_i)
					Z66->Z66_QUANTI := GdFieldGet("Z66_QUANTI",_i)
					Z66->Z66_SITUAC := GdFieldGet("Z66_SITUAC",_i)
					Z66->Z66_DISPON := GdFieldGet("Z66_DISPON",_i)
					Z66->Z66_OPERAD := xfOperad
					MsUnLock()

				Else

					If GdFieldGet("REGZ66",_i) <> 0
						dbSelectArea("Z66")
						dbSetOrder(1)
						dbGoTo(GdFieldGet("REGZ66",_i))
						RecLock("Z66",.F.)
						DELETE
						MsUnLock()
					EndIf

				EndIf

			Next _i

		EndIf

	EndIf

	n := 1

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valida digitação da data para não permitir incluir uma data¦¦¦
¦¦¦          ¦ já existente                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557B()

	Local _ftRet := .T.
	dbSelectArea("Z66")
	dbSetOrder(1)
	If dbSeek(xFilial("Z66")+dtos(xf_Data))
		_ftRet := .F.
		MsgALERT("A data informada já possui registros. Favor usar a opção de MENU Alterar ou escolher outra data.","Atenção")
	EndIf

Return ( _ftRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua calculo da Quantidade e do Disponível               ¦¦¦
¦¦¦          ¦ Executado a partir de gatilhos dos campos abaixo           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557C()

	Local gr_Quant := 0
	Local gr_Dispo := 0
	Local gr_IndRed := 10
	Local gr_Tanque := ""
	Local gr_Vazio  := 0
	Local gr_Densid := 0
	Local gr_Seco   := 0

	If Alltrim(__readvar) == "M->Z66_TANQUE"

		gr_Tanque := M->Z66_TANQUE
		gr_Vazio  := GdFieldGet("Z66_VAZIO", n)
		gr_Densid := GdFieldGet("Z66_DENSID", n)
		gr_Seco   := GdFieldGet("Z66_SECO", n)

	ElseIf Alltrim(__readvar) == "M->Z66_VAZIO"

		gr_Tanque := GdFieldGet("Z66_TANQUE", n)
		gr_Vazio  := M->Z66_VAZIO
		gr_Densid := GdFieldGet("Z66_DENSID", n)
		gr_Seco   := GdFieldGet("Z66_SECO", n)

	ElseIf Alltrim(__readvar) == "M->Z66_DENSID"

		gr_Tanque := GdFieldGet("Z66_TANQUE", n)
		gr_Vazio  := GdFieldGet("Z66_VAZIO", n)
		gr_Densid := M->Z66_DENSID
		gr_Seco   := GdFieldGet("Z66_SECO", n)

	EndIf

	If gr_Vazio <> 0 .and. gr_Densid <> 0 .and. gr_Seco <> 0
		dbSelectArea("Z67")
		dbSetOrder(1)
		If dbSeek(xFilial("Z67") + gr_Tanque)
			_rAltura := Z67->Z67_ALTURA
			If _rAltura > 0
				gr_Quant := ( _rAltura - gr_Vazio ) * Z67->Z67_LITROS * gr_Densid * ( gr_Seco / 100 )
				gr_Dispo := ( gr_Vazio - gr_IndRed ) * Z67->Z67_LITROS * gr_Densid * ( gr_Seco / 100 )
			EndIf
		EndIf
	EndIf

	GdFieldPut("Z66_DISPON", gr_Dispo, n)

Return ( gr_Quant )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557D  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tela que apresenta o saldo, numa determinada data, em esto-¦¦¦
¦¦¦          ¦que versus o controle fisico de estoque (CalcEst vs Z66)    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557D()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local zpArea     := GetArea()
	Private cfValid  := .T.
	Private fh_Esc   := .F.
	Private cObs1    := ""
	Private oObs1
	Private zoNwDad1
	Private zoNwRec2
	Private cf_C2OP
	Private oDlg1
	Private xfDatRef := Z66->Z66_DATA

	Private xLocReq := "01"

	// Controle de explosão de PP em PI/MP
	klCodSemEx := ""
	KL007 := " SELECT Z66_PRODUT, SUBSTRING(B1_DESC, 1, 50 ) DESCR "
	KL007 += "   FROM "+RetSqlName("Z66")+" Z66 "
	KL007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' "
	KL007 += "                       AND B1_COD = Z66_PRODUT "
	KL007 += "                       AND B1_TIPO = 'PP' "
	KL007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	KL007 += "  WHERE Z66_FILIAL = '"+xFilial("Z66")+"' "
	KL007 += "    AND Z66_DATA = '"+dtos(xfDatRef)+"' "
	KL007 += "    AND Z66_EXPL = ' ' "
	KL007 += "    AND Z66.D_E_L_E_T_ = ' ' "
	KLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KL007),'KL07',.T.,.T.)
	dbSelectArea("KL07")
	dbGotop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		klCodSemEx += Alltrim(KL07->Z66_PRODUT) + " - " + KL07->DESCR + CHR(13) + CHR(10)

		dbSelectArea("KL07")
		dbSkip()

	End
	KL07->(dbCloseArea())
	Ferase(KLIndex+GetDBExtension())
	Ferase(KLIndex+OrdBagExt())

	If !Empty(klCodSemEx)

		Aviso('Produtos Sem Explosão', klCodSemEx, {'Ok'}, 3 )

		Return

	EndIf

	dbSelectArea("SX5")

	fPerg := "BIA557"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	oFont1     := TFont():New( "Arial Black",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2     := TFont():New( "Courier New",0,-10,,.T.,0,,700,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New( nLin*.001, nCol*.001, nLin*.88, nCol*.825, "Confrontar e Ajustar Saldos em Estoque",,,.F.,,,,,,.T.,,,.T. )

	cMarca := GetMark()
	vt_TotVlr := "Data de Referência: " + dtoc(xfDatRef)
	MontTbl1()

	//Define as cores dos itens de legenda.
	_aCores := {}
	aAdd(_aCores,{"( MARK->QTDFIS ) - MARK->QTDSIS == 0", "BR_VERDE"	})
	aAdd(_aCores,{"( MARK->QTDFIS ) - MARK->QTDSIS <> 0", "BR_VERMELHO"})

	dbSelectArea("MARK")
	ky_Vet := {{"OK"     ,"" ,"Ajustar"     ,"@!"},;
	{           "CODIGO" ,"" ,"Produto"     ,"@!"},;
	{           "DESCRI" ,"" ,"Descrição"   ,"@!"},;
	{           "QTDFIS" ,"" ,"QuantFis"    ,"@E 999,999,999.99999999"},;
	{           "QTDSIS" ,"" ,"QuantSis"    ,"@E 999,999,999.99999999"},;
	{           "DIFERE" ,"" ,"Diferenca"   ,"@E 999,999,999.99999999"},;
	{           "NUMOP"  ,"" ,"OP"          ,"@!"} }

	oBrw1      := MsSelect():New( "MARK","OK","",ky_Vet,.F.,@cMarca,{nLin*.008,nCol*.005,nLin*.380,nCol*.410},,,oDlg1,,_aCores )
	oBrw1:bMark := {| | gInfAjt()}
	oBtn1      := TButton()  :New( nLin*.390,nCol*.385,"Fechar"       ,oDlg1,{|| fh_Esc := .T., oDlg1:End()                      },nLin*.040,nCol*.020,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton()  :New( nLin*.390,nCol*.350,"Ajustar"      ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIA557F",.F.,.F.)     },nLin*.040,nCol*.020,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton()  :New( nLin*.390,nCol*.315,"Excel"        ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIA557G",.F.,.F.)     },nLin*.040,nCol*.020,,,,.T.,,"",,,,.F. )

	oSay1      := TSay()     :New( nLin*.395,nCol*.005,{|| vt_TotVlr },oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,150,050)

	ACTIVATE MSDIALOG oDlg1 CENTERED VALID fh_Esc

	MARK->(dbCloseArea())

	RestArea(zpArea)

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ MontTbl1 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Cria temporario para o Alias: MARK                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MontTbl1()

	Local aFds := {}
	Local cTmp

	Private oDlgFisico
	Private oButton1
	Private oGet1Loc
	Private oSay1Fis

	Aadd( aFds , {"OK"      ,"C",002,000} )
	Aadd( aFds , {"CODIGO"  ,"C",015,000} )
	Aadd( aFds , {"DESCRI"  ,"C",050,000} )
	Aadd( aFds , {"QTDFIS"  ,"N",018,008} )
	Aadd( aFds , {"QTDSIS"  ,"N",018,008} )
	Aadd( aFds , {"DIFERE"  ,"N",018,008} )
	Aadd( aFds , {"NUMOP"   ,"C",013,000} )

	cTmp := CriaTrab( aFds, .T. )
	Use (cTmp) Alias MARK New Exclusive

	A0001 := " WITH CHKSALDO AS (SELECT Z66_PRODUT PRODUTO, "
	A0001 += "                          SUBSTRING(B1_DESC,1,50) DESCRIC, "
	A0001 += "                          B1_LOCPAD LOCB2, "
	A0001 += "                          SUM(Z66_QUANTI) QTDFIS "
	A0001 += "                     FROM " + RetSqlName("Z66") + " Z66 "
	A0001 += "                    INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	A0001 += "                                         AND B1_COD = Z66_PRODUT "
	A0001 += "                                         AND B1_TIPO <> 'PP' "
	A0001 += "                                         AND SB1.D_E_L_E_T_ = ' ' "
	A0001 += "                    WHERE Z66_FILIAL = '" + xFilial("Z66") + "' "
	A0001 += "                      AND Z66_DATA = '" + dtos(xfDatRef) + "' "
	A0001 += "                      AND Z66.D_E_L_E_T_ = ' ' "
	A0001 += "                    GROUP BY Z66_PRODUT, "
	A0001 += "                             SUBSTRING(B1_DESC,1,50), "
	A0001 += "                             B1_LOCPAD "
	A0001 += "                    UNION ALL "
	A0001 += "                   SELECT B2_COD PRODUTO, "
	A0001 += "                          SUBSTRING(B1_DESC,1,50) DESCRIC, "
	A0001 += "                          B2_LOCAL LOCB2, "
	A0001 += "                          0 QTDFIS "
	A0001 += "                     FROM " + RetSqlName("SB2") + " SB2 "
	A0001 += "                    INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	A0001 += "                                         AND B1_COD = B2_COD "
	A0001 += "                                         AND B1_TIPO <> 'PP' "
	A0001 += "                                         AND B1_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	A0001 += "                                         AND SB1.D_E_L_E_T_ = ' ' "
	A0001 += "                    WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
	A0001 += "                      AND B2_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	A0001 += "                      AND B2_LOCAL <> '03' "
	A0001 += "                      AND SB2.D_E_L_E_T_ = ' ' "
	A0001 += "                    GROUP BY B2_COD, "
	A0001 += "                             SUBSTRING(B1_DESC,1,50), "
	A0001 += "                             B2_LOCAL) "
	A0001 += " SELECT PRODUTO, "
	A0001 += "        DESCRIC, "
	A0001 += "        LOCB2, "
	A0001 += "        SUM(QTDFIS) QTDFIS "
	A0001 += "   FROM CHKSALDO "
	A0001 += "  GROUP BY PRODUTO, "
	A0001 += "           DESCRIC, "
	A0001 += "           LOCB2 "	
	A0Index := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.T.,.T.)
	dbSelectArea("A001")
	dbGotop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Proc.: " + Alltrim(A001->PRODUTO) + " " + A001->LOCB2)

		xf_Produ := A001->PRODUTO
		xf_Descr := A001->DESCRIC
		xf_Saldo := 0
		xf_SldFi := A001->QTDFIS
		While !Eof() .and. A001->PRODUTO == xf_Produ
			aSaldos := CalcEst(A001->PRODUTO, A001->LOCB2, xfDatRef+1)
			xf_Saldo += aSaldos[1]
			dbSelectArea("A001")
			dbSkip()
		End

		If xf_Saldo <> 0 .or. xf_SldFi <> 0

			dbSelectArea("MARK")
			RecLock("MARK",.T.)
			MARK->OK     := IIF(( xf_SldFi ) - xf_Saldo <> 0, cMarca, "  ")
			MARK->CODIGO := xf_Produ
			MARK->DESCRI := xf_Descr
			MARK->QTDFIS := xf_SldFi
			MARK->QTDSIS := NoRound(xf_Saldo,8)
			MARK->DIFERE := ( xf_SldFi ) - xf_Saldo
			MsUnLock()

		EndIf

		dbSelectArea("A001")

	End
	A001->(dbCloseArea())
	Ferase(A0Index+GetDBExtension())
	Ferase(A0Index+OrdBagExt())

	dbSelectArea("MARK")
	dbGoTop()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gInfAjt  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Apresenta tela para que seja informado a quantidade a ser  ¦¦¦
¦¦¦          ¦ ajustada e o número da OP                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gInfAjt()

	Local oDlgAjst
	Local kButton1
	Local kButton2
	Local oGetNOp
	Local oGetQtd
	Local oGroup1
	Local kSay1
	Local kSay2
	Private nGetQtd  := MARK->QTDFIS
	Private cGetNOp  := Space(13)
	Private ftFxAj   := .F.
	Private ftGrAjst := .F.

	dbSelectArea("MARK")
	RecLock("MARK",.F.)
	If MARK->OK == cMarca

		DEFINE MSDIALOG oDlgAjst FROM 000, 000  TO 135, 490 COLORS 0, 16777215 PIXEL

		@ 007, 006 GROUP oGroup1 TO 058, 199 OF oDlgAjst COLOR 0, 16777215 PIXEL
		@ 022, 011 SAY kSay1 PROMPT "Informe a quantidade física:" SIZE 070, 007 OF oDlgAjst COLORS 0, 16777215 PIXEL
		@ 020, 082 MSGET oGetQtd VAR nGetQtd SIZE 060, 010 OF oDlgAjst PICTURE "@E 999,999,999.99999999" VALID fValQtd() COLORS 0, 16777215 PIXEL
		@ 037, 201 BUTTON kButton2 PROMPT "Confirmar" SIZE 037, 019 OF oDlgAjst ACTION ( ftFxAj := .T., ftGrAjst := .T., oDlgAjst:End() )  PIXEL
		@ 040, 011 SAY kSay2 PROMPT "Informe o número da OP que receberá os ajuste:" SIZE 118, 007 OF oDlgAjst COLORS 0, 16777215 PIXEL
		@ 039, 130 MSGET oGetNOp VAR cGetNOp SIZE 060, 010 OF oDlgAjst VALID fValidOp() COLORS 0, 16777215 F3 "SC2BIA" PIXEL
		@ 009, 201 BUTTON kButton1 PROMPT "Cancelar"  SIZE 037, 019 OF oDlgAjst ACTION ( ftFxAj := .T., ftGrAjst := .F., oDlgAjst:End() )  PIXEL
		ACTIVATE MSDIALOG oDlgAjst VALID ftFxAj

		If ftGrAjst
			MARK->QTDFIS := nGetQtd
			MARK->NUMOP  := cGetNOp
			MARK->DIFERE := ( MARK->QTDFIS ) - MARK->QTDSIS
		Else
			MARK->OK     := ""
		EndIf

	Else

		MARK->NUMOP  := ""
		MARK->DIFERE := ( MARK->QTDFIS ) - MARK->QTDSIS

	EndIf
	MsUnLock()

	oDlg1:Refresh()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidOp ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidOp()

	Local kRetOk := .F.
	If !Empty(cGetNOp)
		dbSelectArea("SC2")
		dbSetOrder(1)
		If dbSeek(xFilial("SC2") + cGetNOp )
			kRetOk := .T.
		EndIf
	Else
		If MsgNOYES("Deseja continuar mesmo com a OP em branco?")
			kRetOk := .T.
		EndIf
	EndIf

Return ( kRetOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValQtd  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValQtd()

	Local kRetOk := .T.
	If MARK->QTDFIS <> 0
		If MARK->QTDFIS <> nGetQtd
			MsgSTOP("Favor verificar o produto versus quantidade que deseja ajustar, pois para este produto, primeiramente é necessário lançar esta quantidade no controle físico?")
			nGetQtd := MARK->QTDFIS
		EndIf
	EndIf

Return ( kRetOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIA557E       ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para consulta personalizada via "F3".       ¦¦¦
¦¦¦          ¦ Com ele podem ser criados filtros mais rápidos e impedi-   ¦¦¦
¦¦¦          ¦ mento para visualização de detalhes que não podem ser ob-  ¦¦¦
¦¦¦          ¦ servados por alguns usuários.                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557E()

	Local aArea   := GetArea()

	Private oDlg
	Private oGet1
	Private cGet1 := Space(45)
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"D4_OP","C2_PRODUTO","C2_EMISSAO","B1_DESC"}
	Private aAlterFields := {"D4_OP","C2_PRODUTO","C2_EMISSAO","B1_DESC"}
	Private oMSNewGetDados1
	Private srCodPro := MARK->CODIGO
	Public hk_Retur1 := ""
	Public hk_Retur2 := ""

	DEFINE MSDIALOG oDlg TITLE "Ordem de Produção" FROM 000, 000  TO 540, 600 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()
	@ 216, 005 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Número da OP","Produto","Descrição" SIZE 071, 026 OF oDlg COLOR 0, 16777215 ON CHANGE wMudOrd() PIXEL
	@ 248, 005 MSGET oGet1 VAR cGet1 SIZE 197, 015 OF oDlg COLORS 0, 16777215 PIXEL
	@ 231, 208 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 037, 032 OF oDlg ACTION( wRetCodCl() ) PIXEL
	@ 231, 255 BUTTON Retornar PROMPT "Retornar" SIZE 037, 032 OF oDlg ACTION( hk_Retur1 := oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1], oDlg:End() ) PIXEL
	ACTIVATE MSDIALOG oDlg

	n := 1
	RestArea( aArea )

	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+hk_Retur1)
	cNumOP := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN

Return .T.

//*******************************************************
//**  SubFunction1 ref: BIAConsultPer()                **
//*******************************************************
Static Function fMSNewGetDados1()

	Local nX

	_nomeuser := cUserName
	psworder(2)                          // Pesquisa por Nome
	If  pswseek(_nomeuser,.t.)           // Nome do usuario, Pesquisa usuarios
		_daduser  := pswret(1)           // Numero do registro
		_UsuarAt  := _daduser[1,1]
	EndIf

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	A0001 := " SELECT D4_OP, C2_PRODUTO, C2_EMISSAO, SUBSTRING(B1_DESC,1,50) B1_DESC
	A0001 += "   FROM "+RetSqlName("SD4")+" SD4
	A0001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6)
	A0001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2)
	A0001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3)
	A0001 += "                       AND C2_DATRF = '        '
	A0001 += "                       AND SC2.D_E_L_E_T_ = ' '
	A0001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                       AND B1_COD = C2_PRODUTO
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
	A0001 += "    AND D4_COD = '"+srCodPro+"'
	A0001 += "    AND D4_QUANT > 0
	A0001 += "    AND SD4.D_E_L_E_T_ = ' '
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		Aadd(aFieldFill, {A001->D4_OP, A001->C2_PRODUTO, stod(A001->C2_EMISSAO), A001->B1_DESC, .F. })
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())

	If Len(aFieldFill) == 0
		For nX := 1 to Len(aFields)
			dbSelectArea("SX3")
			dbSetOrder(2)
			If dbSeek(aFields[nX])
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Else
		aColsEx := aFieldFill
	EndIf

	oMSNewGetDados1 := MsNewGetDados():New( 005, 005, 213, 557, , , , , , , 999, , , , oDlg, aHeaderEx, aColsEx)

Return

//*******************************************************
//**  SubFunction2 ref: BIAConsultPer()                **
//*******************************************************
Static Function wRetCodCl()

	jk_Tam := Len(Alltrim(cGet1))
	nPos   := 0
	If Len(aColsEx) > 1
		If nRadMenu1 == 1
			nPos := aScan(aColsEx,{|x| Substr(x[1], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		ElseIf nRadMenu1 == 2
			nPos := aScan(aColsEx,{|x| Substr(x[3], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		ElseIf nRadMenu1 == 3
			nPos := aScan(aColsEx,{|x| Substr(x[4], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		EndIf
		If nPos <> 0
			n:=nPos
			oMSNewGetDados1:oBrowse:nAt:=nPos
			oMSNewGetDados1:oBrowse:Refresh()
			oMSNewGetDados1:oBrowse:SetFocus()
		EndIf
	EndIf

Return

//*******************************************************
//**  SubFunction3 ref: BIAConsultPer()                **
//*******************************************************
Static Function wMudOrd()

	If Len(aColsEx) > 1
		If nRadMenu1 == 1
			aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		ElseIf nRadMenu1 == 2
			aColsEx := aSort(aColsEx,,,{|x,y| x[3] < y[3] })
		ElseIf nRadMenu1 == 3
			aColsEx := aSort(aColsEx,,,{|x,y| x[4] < y[4] })
		EndIf
		oMSNewGetDados1:ACOLS := aColsEx
		oMSNewGetDados1:oBrowse:Refresh()
		oMSNewGetDados1:oBrowse:SetFocus()
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557F  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua o ajuste de estoque no sistema a partir das informa-¦¦¦
¦¦¦          ¦ções do controle físico                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557F()

	Private lMsHelpAuto	:= .T.
	Private lMsErroAuto	:= .F.
	Private _ExecAutoII	:= .T.

	MsgALERT('Esta opção está fora de uso até segunda ordem. Nenhum processamento será realizado. Favor verificar. Atenciosamente!!!', 'Ajustar...' )

	If 1 == 2

		If xfDatRef > GetMV("MV_ULMES")

			// Implementado tratamento para tinta para digital
			If xLocReq <> "99"

				dbSelectArea("MARK")
				dbGotop()
				While !Eof()

					If MARK->OK == cMarca .and. MARK->DIFERE <> 0

						// Implementado porque as casas decimais do protheus prejudicam a baixa conforme rotina
						If MARK->DIFERE < 0

							SB1->(dbSetOrder(1))
							SB1->(dbSeek(xFilial("SB1") + MARK->CODIGO ))

							tpSaldos := CalcEst(MARK->CODIGO, xLocReq, xfDatRef+1)
							POSQtdDif := tpSaldos[1] * (-1)

							If ABS(MARK->DIFERE) > ABS(POSQtdDif)

								QtdPNovMes := ABS(MARK->DIFERE) - ABS(POSQtdDif)
								swDoc     := UPPER( NextNumero("SD3", 2, "D3_DOC", .t.) )
								az_clvl   := IIF(cEmpAnt == "01", "3100", IIF(cEmpAnt == "05", "3200", ""))
								az_tm     := If(xLocReq <> "99", "120", "005")

								xb_DscOr := SB1->B1_DESC
								xb_UMOrg := SB1->B1_UM
								sk_LocOp := xLocReq
								xb_Conta := SB1->B1_YCTRIND
								xg_SegUm := SB1->B1_SEGUM

								//Preenche Cabecalho
								kk_aCab1 :=	{ {"D3_DOC"     ,swDoc     		, NIL},;
								{              "D3_TM"      ,az_tm   		, NIL},;
								{              "D3_CC"      ,"3000"    		, NIL},;
								{              "D3_CLVL"   	,az_clvl     	, NIL},;
								{              "D3_EMISSAO"	,xfDatRef+1     , NIL} }
								//Preenche os Itens
								kk_aTtItem := {}
								kk_aItem := {}
								aAdd(kk_aItem,{"D3_COD"	  	,MARK->CODIGO         			,NIL})
								aAdd(kk_aItem,{"D3_UM"	  	,xb_UMOrg 		     			,NIL})
								aAdd(kk_aItem,{"D3_QUANT"  	,QtdPNovMes                   	,NIL})
								aAdd(kk_aItem,{"D3_LOCAL"  	,sk_LocOp              		    ,NIL})
								aAdd(kk_aItem,{"D3_CONTA" 	,xb_Conta        				,NIL})
								aAdd(kk_aItem,{"D3_USUARIO"	,cUserName						,NIL})
								aAdd(kk_aItem,{"D3_CC"		,"3000" 	   					,NIL})
								aAdd(kk_aItem,{"D3_CLVL"	,az_clvl    					,NIL})
								aAdd(kk_aItem,{"D3_SEGUM"  	,xg_SegUm		        		,NIL})
								aAdd(kk_aItem,{"D3_YRFCUST" ,"BIA557"		        		,NIL})
								aAdd(kk_aItem,{"D3_YAPLIC"  ,"1"     		        		,NIL})
								If !Empty(MARK->NUMOP)
									aAdd(kk_aItem,{"D3_OP"	    ,MARK->NUMOP               		,NIL})
								EndIf
								aAdd(kk_aTtItem, kk_aItem)
								lMsErroAuto := .f.
								MSExecAuto({|x,y,z| MATA241(x,y,z)}, kk_aCab1, kk_aTtItem)
								If lMsErroAuto
									Mostraerro()
									lMostraErro:= .F.
								EndIf

							EndIf

							xb_QtdDif := ABS(MARK->DIFERE)

							// Incluído em 01/07/13 durante fechamento de estoque de junho de 2013, porque a totvs ainda não apresentou parcer até data do chamado THIZ63
							QR008 := " UPDATE " + RetSqlName("SD4")
							QR008 += "    SET D4_DATA = '"+dtos(xfDatRef+1)+"'
							QR008 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
							QR008 += "    AND D4_COD = '"+MARK->CODIGO+"'
							QR008 += "    AND D4_QUANT > 0
							QR008 += "    AND D4_DATA < '"+dtos(xfDatRef+1)+"'
							QR008 += "    AND D_E_L_E_T_ = ' '
							TCSQLExec(QR008)

						Else

							xb_QtdDif := ABS(MARK->DIFERE)

						EndIf

						swDoc     := UPPER( NextNumero("SD3", 2, "D3_DOC", .t.) )
						az_clvl   := IIF(cEmpAnt == "01", "3100", IIF(cEmpAnt == "05", "3200", ""))
						If xLocReq <> "99"
							az_tm     := IIF(MARK->DIFERE > 0, "120", "720")
						Else
							az_tm     := IIF(MARK->DIFERE > 0, "005", "502")
						EndIf

						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1") + MARK->CODIGO ))
						xb_DscOr := SB1->B1_DESC
						xb_UMOrg := SB1->B1_UM
						sk_LocOp := xLocReq
						xb_Conta := SB1->B1_YCTRIND
						xg_SegUm := SB1->B1_SEGUM

						//Preenche Cabecalho
						kk_aCab1 :=	{ {"D3_DOC"     ,swDoc     		, NIL},;
						{              "D3_TM"      ,az_tm   		, NIL},;
						{              "D3_CC"      ,"3000"    		, NIL},;
						{              "D3_CLVL"   	,az_clvl     	, NIL},;
						{              "D3_EMISSAO"	,xfDatRef       , NIL} }
						//Preenche os Itens
						kk_aTtItem := {}
						kk_aItem := {}
						aAdd(kk_aItem,{"D3_COD"	  	,MARK->CODIGO         			,NIL})
						aAdd(kk_aItem,{"D3_UM"	  	,xb_UMOrg 		     			,NIL})
						aAdd(kk_aItem,{"D3_QUANT"  	,xb_QtdDif                   	,NIL})
						aAdd(kk_aItem,{"D3_LOCAL"  	,sk_LocOp              		    ,NIL})
						aAdd(kk_aItem,{"D3_CONTA" 	,xb_Conta        				,NIL})
						aAdd(kk_aItem,{"D3_USUARIO"	,cUserName						,NIL})
						aAdd(kk_aItem,{"D3_CC"		,"3000" 	   					,NIL})
						aAdd(kk_aItem,{"D3_CLVL"	,az_clvl    					,NIL})
						aAdd(kk_aItem,{"D3_SEGUM"  	,xg_SegUm		        		,NIL})
						aAdd(kk_aItem,{"D3_YRFCUST" ,"BIA557"		        		,NIL})
						If !Empty(MARK->NUMOP)
							aAdd(kk_aItem,{"D3_OP"	    ,MARK->NUMOP               		,NIL})
						EndIf
						aAdd(kk_aTtItem, kk_aItem)
						lMsErroAuto := .f.
						MSExecAuto({|x,y,z| MATA241(x,y,z)}, kk_aCab1, kk_aTtItem)
						If lMsErroAuto
							Mostraerro()
							lMostraErro:= .F.
						EndIf

					EndIf
					dbSelectArea("MARK")
					dbSkip()

				End

			Else

				dbSelectArea("MARK")
				dbGotop()
				While !Eof()

					If MARK->OK == cMarca .and. MARK->DIFERE <> 0

						swDoc     := UPPER( NextNumero("SD3", 2, "D3_DOC", .t.) )
						az_clvl   := IIF(cEmpAnt == "01", "3100", IIF(cEmpAnt == "05", "3200", ""))
						az_tm     := IIF(MARK->DIFERE > 0, "005", "502")
						az_cf     := IIF(MARK->DIFERE > 0, "DE0", "RE0")
						az_Contn  := .F.

						If MARK->DIFERE < 0
							tpSaldos  := CalcEst(MARK->CODIGO, xLocReq, xfDatRef+1)
							POSQtdDif := tpSaldos[1]
							If POSQtdDif >= ABS(MARK->DIFERE)
								az_Contn  := .T.
							EndIf
						Else
							az_Contn  := .T.
						EndIf

						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1") + MARK->CODIGO ))

						If az_Contn
							RecLock("SD3",.T.)
							SD3->D3_FILIAL   :=  xFilial("SD3")
							SD3->D3_TM       :=  az_tm
							SD3->D3_CF       :=  az_cf
							SD3->D3_OP       :=  ""
							SD3->D3_COD      :=  MARK->CODIGO
							SD3->D3_QUANT    :=  ABS(MARK->DIFERE)
							SD3->D3_QTSEGUM  :=  ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2)
							SD3->D3_UM       :=  SB1->B1_UM
							SD3->D3_SEGUM    :=  SB1->B1_SEGUM
							SD3->D3_LOCAL    :=  xLocReq
							SD3->D3_GRUPO    :=  SB1->B1_GRUPO
							SD3->D3_USUARIO  :=  cUserName
							SD3->D3_CHAVE    :=  "E0"
							SD3->D3_TRT      :=  ""
							SD3->D3_CC       :=  "3000"
							SD3->D3_CLVL     :=  az_clvl
							SD3->D3_CONTA    :=  SB1->B1_YCTRIND
							SD3->D3_TIPO     :=  SB1->B1_TIPO
							SD3->D3_EMISSAO  :=  xfDatRef
							SD3->D3_DOC      :=  swDoc
							SD3->D3_NIVEL    :=  ""
							SD3->D3_NUMSEQ   :=  ProxNum()
							SD3->D3_YRFCUST  :=  "BIA557"
							MsUnlock()

							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2") + MARK->CODIGO + xLocReq)
								dpSaldos  := CalcEst(MARK->CODIGO, xLocReq, Date()+1)
								RecLock("SB2",.F.)
								SB2->B2_QATU     := dpSaldos[1]
								SB2->B2_QTSEGUM  := ConvUm(SB2->B2_COD, SB2->B2_QATU, 0, 2)
								SB2->B2_VATU1    := dpSaldos[2]
								MsUnLock()
							EndIf

						EndIf

					EndIf

					dbSelectArea("MARK")
					dbSkip()

				End

			EndIf

		Else

			MsgINFO("Não é permitido efetuar ajuste de estoque pois a data é anterior ao último fechamento de estoque!!!","Atenção.")

		EndIf

	EndIf

	fh_Esc := .T.
	oDlg1:End()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557W  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exporta dados para Excel                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA557W()

	Local rtc
	Local xDadosT := {}

	For rtc := 1 to Len(aCols)

		xDispon := IIf(aCols[rtc][10] == 0, aCols[rtc][8], aCols[rtc][10] )
		AADD(xDadosT, { aCols[rtc][1],;
		aCols[rtc][2],;
		aCols[rtc][3],;
		aCols[rtc][4],;
		Transform(aCols[rtc][5], "@E 999,999,999.9999"),;
		Transform(aCols[rtc][6], "@E 999,999,999.9999"),;
		Transform(aCols[rtc][7], "@E 999,999,999.9999"),;
		Transform(aCols[rtc][8], "@E 999,999,999.9999"),;
		IIf(aCols[rtc][9] == "1", "Retido", IIF(aCols[rtc][9] == "2", "Parado", "Liberado")),;
		Transform(xDispon      , "@E 999,999,999.9999"),;
		aCols[rtc][11]})

	Next rtc

	U_BIAxExcel(xDadosT, aHeader, "BIA557"+strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557X  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Explodir a quantidade de PP em componentes Esmalte para    ¦¦¦
¦¦¦          ¦ efeito de compor o saldo disponível em estoque.            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557X()

	Local xf_Data := Z66->Z66_DATA

	PX003 := " WITH EXPLOD AS (SELECT Z66_PRODUT, "
	PX003 += "                        Z66_QUANTI, "
	PX003 += "                        Z66_SEQUEN, "
	PX003 += "                        Z66_DATA, "
	PX003 += "                        Z66_TANQUE, "
	PX003 += "                        Z66.R_E_C_N_O_ REGZZ6 "
	PX003 += "                   FROM "+RetSqlName("Z66")+" Z66 "
	PX003 += "                  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' "
	PX003 += "                                       AND B1_COD = Z66_PRODUT "
	PX003 += "                                       AND B1_TIPO = 'PP' "
	PX003 += "                                       AND SB1.D_E_L_E_T_ = ' ' "
	PX003 += "                  WHERE Z66_FILIAL = '"+xFilial("Z66")+"' "
	PX003 += "                    AND Z66_DATA = '"+dtos(xf_Data)+"' "
	PX003 += "                    AND Z66_EXPL = ' ' "
	PX003 += "                    AND Z66.D_E_L_E_T_ = ' ') "
	PX003 += " SELECT EXL.*, "
	PX003 += "        G1_TRT, "
	PX003 += "        G1_COMP, "
	PX003 += "        G1_QUANT, "
	PX003 += "        G1_PERDA, "
	PX003 += "        ( Z66_QUANTI * G1_QUANT ) + ( Z66_QUANTI * G1_QUANT * G1_PERDA / 100) QTDEXPL "
	PX003 += "   FROM "+RetSqlName("SG1")+" SG1 "
	PX003 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' "
	PX003 += "                       AND B1_COD = G1_COMP "
	PX003 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	PX003 += "  INNER JOIN "+RetSqlName("SBM")+" SBM ON BM_FILIAL = '"+xFilial("SBM")+"' "
	PX003 += "                       AND BM_GRUPO = B1_GRUPO "
	PX003 += "                       AND BM_YAGRPCT = '102 ' "
	PX003 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	PX003 += "  INNER JOIN EXPLOD EXL ON Z66_PRODUT = G1_COD "
	PX003 += "                       AND Z66_DATA >= G1_INI
	PX003 += "                       AND Z66_DATA <= G1_FIM
	PX003 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"' "
	PX003 += "    AND SG1.D_E_L_E_T_ = ' ' "
	PXIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,PX003),'PX03',.T.,.T.)
	dbSelectArea("PX03")
	dbGotop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		RecLock("Z66",.T.)
		Z66->Z66_FILIAL := xFilial("Z66")
		Z66->Z66_DATA   := xf_Data
		Z66->Z66_SEQUEN := "ZZZ"
		Z66->Z66_TANQUE := PX03->Z66_TANQUE
		Z66->Z66_PRODUT := PX03->G1_COMP
		Z66->Z66_VAZIO  := 0
		Z66->Z66_DENSID := 0
		Z66->Z66_SECO   := 0
		Z66->Z66_QUANTI := PX03->QTDEXPL
		Z66->Z66_SITUAC := ""
		Z66->Z66_DISPON := 0
		Z66->Z66_P_ORIG := PX03->Z66_PRODUT
		Z66->Z66_REV_P  := PX03->G1_TRT
		Z66->Z66_SEQORI := PX03->Z66_SEQUEN
		MsUnLock()

		dbSelectArea("Z66")
		dbSetOrder(1)
		dbGoTo(PX03->REGZZ6)
		RecLock("Z66",.F.)
		Z66->Z66_EXPL   := "S"
		MsUnLock()

		dbSelectArea("PX03")
		dbSkip()

	End
	PX03->(dbCloseArea())
	Ferase(PXIndex+GetDBExtension())
	Ferase(PXIndex+OrdBagExt())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557Y  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Apaga os registros gerados a partir no PP explodido e em   ¦¦¦
¦¦¦          ¦ seguida zera o campo explodido                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA557Y()

	UX004 := " UPDATE "+RetSqlName("Z66")+" SET Z66_EXPL = ' ' "
	UX004 += "   FROM "+RetSqlName("Z66")+" Z66 "
	UX004 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' "
	UX004 += "                       AND B1_COD = Z66_PRODUT "
	UX004 += "                       AND B1_TIPO = 'PP' "
	UX004 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	UX004 += "  WHERE Z66_FILIAL = '"+xFilial("Z66")+"' "
	UX004 += "    AND Z66_DATA = '"+dtos(xf_Data)+"' "
	UX004 += "    AND Z66_EXPL = 'S' "
	UX004 += "    AND Z66.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Zerando...",,{|| TcSQLExec(UX004)})

	UX006 := " DELETE "+RetSqlName("Z66")+" "
	UX006 += "   FROM "+RetSqlName("Z66")+" Z66 "
	UX006 += "  WHERE Z66_FILIAL = '"+xFilial("Z66")+"' "
	UX006 += "    AND Z66_DATA = '"+dtos(xf_Data)+"' "
	UX006 += "    AND Z66_SEQUEN = 'ZZZ' "
	UX006 += "    AND Z66_P_ORIG <> '' "
	UX006 += "    AND Z66_SEQORI <> '' "
	UX006 += "    AND Z66.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Zerando...",,{|| TcSQLExec(UX006)})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557L  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09/03/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exporta para excel o resultado da digitação do dia posicio-¦¦¦
¦¦¦          ¦ nado                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557L()

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Resultado da digitação estoque físicos"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SEQ"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TANQUE"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRIC"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VAZIO"           ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DENSIDADE"       ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "%SECO"           ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANTIDADE"      ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "SITUACAO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DISPONIVEL"      ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "P_ORIGE"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "REV_P"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EXPL"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SEQORI"          ,1,1)

	BS003 := " SELECT Z66_DATA, "
	BS003 += "        Z66_SEQUEN, "
	BS003 += "        Z66_TANQUE, "
	BS003 += "        Z66_PRODUT, "
	BS003 += " 	      SUBSTRING(B1_DESC,1,50) DESCR, "
	BS003 += "        Z66_VAZIO, "
	BS003 += "        Z66_DENSID, "
	BS003 += "        Z66_SECO, "
	BS003 += "        Z66_QUANTI, "
	BS003 += "        Z66_SITUAC, "
	BS003 += "        Z66_DISPON, "
	BS003 += "        Z66_P_ORIG, "
	BS003 += "        Z66_REV_P, "
	BS003 += "        Z66_EXPL, "
	BS003 += "        Z66_SEQORI "
	BS003 += "   FROM "+RetSqlName("Z66")+" Z66 "
	BS003 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' "
	BS003 += "                       AND B1_COD = Z66_PRODUT "
	BS003 += " 					     AND SB1.D_E_L_E_T_ = ' '  "
	BS003 += "  WHERE Z66_FILIAL = '"+xFilial("Z66")+"' "
	BS003 += "    AND Z66_DATA = '"+dtos(Z66->Z66_DATA)+"' "
	BS003 += "    AND Z66.D_E_L_E_T_ = ' ' "
	BScIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,BS003),'BS03',.F.,.T.)
	dbSelectArea("BS03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		xxSituac := IIF(BS03->Z66_SITUAC == "1", "Retido", IIF(BS03->Z66_SITUAC == "2", "Parado", IIF(BS03->Z66_SITUAC == "3", "Liberado", BS03->Z66_SITUAC)))

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(BS03->Z66_DATA))    ,;
		BS03->Z66_SEQUEN                                              ,;
		BS03->Z66_TANQUE                                              ,;
		BS03->Z66_PRODUT                                              ,;
		BS03->DESCR                                                   ,;
		Transform(BS03->Z66_VAZIO   , "@E 999,999,999.99")            ,;
		Transform(BS03->Z66_DENSID  , "@E 999,999,999.99")            ,;
		Transform(BS03->Z66_SECO    , "@E 999,999,999.99")            ,;
		Transform(BS03->Z66_QUANTI  , "@E 999,999,999.99")            ,;
		xxSituac                                                      ,;
		Transform(BS03->Z66_DISPON  , "@E 999,999,999.99")            ,;
		BS03->Z66_P_ORIG                                              ,;
		BS03->Z66_REV_P                                               ,;
		BS03->Z66_EXPL                                                ,;
		BS03->Z66_SEQORI                                              })

		dbSelectArea("BS03")
		dbSkip()

	End

	BS03->(dbCloseArea())
	Ferase(BScIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(BScIndex+OrdBagExt())          //indice gerado

	xArqTemp := "saldo-estoque-" + dtos(Z66->Z66_DATA)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA557G  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exporta dados da grid do confronto diretamente para o Excel¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA557G()

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Resultado do confronto de estoque"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRIC"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QTDFIS"          ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTDSIS"          ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DIFERENCA"       ,3,2)

	dbSelectArea("MARK")
	dbGotop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(Z66->Z66_DATA)    ,;
		MARK->CODIGO                                           ,;
		MARK->DESCRI                                           ,;
		Transform(MARK->QTDFIS , "@E 999,999,999.99")          ,;
		Transform(MARK->QTDSIS , "@E 999,999,999.99")          ,;
		Transform(MARK->DIFERE , "@E 999,999,999.99")          })

		dbSelectArea("MARK")
		dbSkip()

	End

	dbSelectArea("MARK")
	dbGotop()

	xArqTemp := "confronto-" + dtos(Z66->Z66_DATA)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Produto               ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"02","Até Produto              ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","De Grupo                 ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"04","Até Grupo                ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
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
