#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#Include "font.ch"

/*/{Protheus.doc} BIA294
@author Marcos Alberto Soprani
@since 16/05/12
@version 1.0
@description Controle de Estoque de Esmalte
@type function
/*/

User Function BIA294()

	Private xImpDh := .F.

	Public xtVetNfO := {}

	dbSelectArea("Z15")
	dbGoTop()

	n := 1
	cCadastro := " ....: Controle de Estoque de Esmalte e Massa :.... "

	aRotina   := {  {"Pesquisar"  ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar" ,'Execblock("BIA294A" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"    ,'Execblock("BIA294A" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"    ,'Execblock("BIA294A" ,.F.,.F.,"A")'    ,0, 4},;
	{                "Confrontar" ,'Execblock("BIA294D" ,.F.,.F.,"C")'    ,0, 5} }

	mBrowse(6,1,22,75, "Z15", , , , , ,)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA294A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 16.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem da Tela de Visualização, Inclusao e Alteração     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294A()

	Local _i
	Local xButTela := {}
	Local _ni

	wopcao := Paramixb
	lVisualizar := .F.
	lIncluir    := .F.
	lAlterar    := .F.

	aAdd(xButTela,{"EXCEL"	,{|| BIA294W() }	,"Excel"})

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
	dbSeek("Z15")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "Z15"
		If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. Alltrim(SX3->X3_CAMPO) <> "Z15_DATA" .and. Alltrim(SX3->X3_CAMPO) <> "Z15_CLVL"
			nUsado := nUsado+1
			Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal,"AllwaysTrue()", x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End
	nUsado := nUsado+1
	Aadd(aHeader,{ "REGZ15", "REGZ15", "999999999", 9, 0,"AllwaysTrue()", , "N", , } )

	xf_Data := ctod("  /  /  ")
	xf_CLVL := Space(9)

	xf_Data := dDataBase
	If cOpcao == "INCLUIR"

		BS001 := " SELECT MAX(Z15_DATA) DTREF
		BS001 += "   FROM " + RetSqlName("Z15")
		BS001 += "  WHERE Z15_FILIAL = '"+xFilial("Z15")+"'
		BS001 += "    AND D_E_L_E_T_ = ' '
		TCQUERY BS001 New Alias "BS01"
		dbSelectArea("BS01")
		dbGotop()
		If !Empty(BS01->DTREF)
			xf_Data := stod(BS01->DTREF)
		EndIf
		BS01->(dbCloseArea())

	Else

		xf_Data := Z15->Z15_DATA
		xf_CLVL := Z15->Z15_CLVL

	Endif

	aCols:={}
	If cOpcao <> "INCLUIR" .or. cEmpAnt == "05"

		dbSelectArea("Z15")
		dbSetOrder(2)
		dbGoTop()
		dbSeek(xFilial("Z15") + dtos(xf_Data) + xf_CLVL)
		While !Eof() .and. Z15->Z15_DATA == xf_Data .and. Z15->Z15_CLVL == xf_CLVL

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + Z15->Z15_PRODUT))

			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				If Alltrim(aHeader[_ni,2]) == "Z15_DESCRI"
					aCols[Len(aCols),_ni] := Substr(SB1->B1_DESC,1,50)
				EndIf
			Next
			If cOpcao == "INCLUIR"
				aCols[Len(aCols),nUsado] := 0
			Else
				aCols[Len(aCols),nUsado] := Z15->(Recno())
			EndIf
			aCols[Len(aCols),nUsado+1]:=.F.

			dbSelectArea("Z15")
			dbSkip()

		End

	EndIf

	If Len(Acols) == 0
		aCols := {Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni := 1 to nUsado
			If Alltrim(aHeader[_ni,2]) == "Z15_SEQUEN"
				aCols[1,_ni] := "000"
			ElseIf Alltrim(aHeader[_ni,2]) == "REGZ15"
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

	cTitulo  := "..: Controle de Estoque de Esmalte :.."
	aC := {}
	aR := {}

	aCGD   := {70,5,250,455}
	aCordw := {95,03,600,820}

	//Gabriel Rossi Mafioletti - Incluido para ordenar por tanque
	If Len(aCols) > 1
		aSort(aCols,,,{|x,y| Alltrim(x[2]) + Alltrim(x[3]) < Alltrim(y[2]) + Alltrim(y[3]) })
	EndIf
	If lVisualizar
		nOpcx    := 1
		AADD(aC,{"xf_Data"   ,{20,010}  ,"Data Ref:"          ,"@!",                               ,      , .F.})
		AADD(aC,{"xf_CLVL"   ,{20,100}  ,"Classe Valor:"      ,"@!",                               ,      , .F.})
		aGetsD   := {}
		mk_LinhaOk := "ExecBlock('BIA294L',.F.,.F.)" //"AllwaysTrue()"
		mk_TudoOk  := "ExecBlock('BIA294V',.F.,.F.)"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD,   , "+Z15_SEQUEN", 999, aCordw, .F. ,,xButTela)

	ElseIf lIncluir
		nOpcx    := 4
		AADD(aC,{"xf_Data"   ,{20,010}  ,"Data Ref:"          ,"@!", "ExecBlock('BIA294B',.F.,.F.)",      ,})
		AADD(aC,{"xf_CLVL"   ,{20,100}  ,"Classe Valor:"      ,"@!", "ExecBlock('BIA294B',.F.,.F.)",      ,})
		aGetsD   := {"Z15_TANQUE","Z15_LOCAL","Z15_PRODUT","Z15_VAZIO","Z15_DENSID","Z15_SITUAC","Z15_QUANTI"}
		mk_LinhaOk := "ExecBlock('BIA294L',.F.,.F.)" //"AllwaysTrue()"
		mk_TudoOk  := "ExecBlock('BIA294V',.F.,.F.)"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD,   , "+Z15_SEQUEN", 999, aCordw, .T. ,,xButTela)

	ElseIf lAlterar
		nOpcx    := 3
		AADD(aC,{"xf_Data"   ,{20,010}  ,"Data Ref:"          ,"@!",                               ,      , .F.})
		AADD(aC,{"xf_CLVL"   ,{20,100}  ,"Classe Valor:"      ,"@!",                               ,      , .F.})
		aGetsD   := {"Z15_TANQUE","Z15_LOCAL","Z15_PRODUT","Z15_VAZIO","Z15_DENSID","Z15_SITUAC","Z15_QUANTI"}
		mk_LinhaOk := "ExecBlock('BIA294L',.F.,.F.)" //"AllwaysTrue()"
		mk_TudoOk  := "ExecBlock('BIA294V',.F.,.F.)"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD,   , "+Z15_SEQUEN", 999, aCordw, .T. ,,xButTela)

	EndIf

	If lRet

		If lIncluir .or. lAlterar

			For _i := 1 to len(aCols)

				If !aCols[_i,nUsado+1]

					If GdFieldGet("REGZ15",_i) == 0
						RecLock("Z15",.T.)
					Else
						dbSelectArea("Z15")
						dbSetOrder(1)
						dbGoTo(GdFieldGet("REGZ15",_i))
						RecLock("Z15",.F.)
					EndIf
					Z15->Z15_FILIAL := xFilial("Z15")
					Z15->Z15_DATA   := xf_Data
					Z15->Z15_SEQUEN := GdFieldGet("Z15_SEQUEN",_i)
					Z15->Z15_TANQUE := GdFieldGet("Z15_TANQUE",_i)
					Z15->Z15_CLVL   := xf_CLVL
					Z15->Z15_LOCAL  := GdFieldGet("Z15_LOCAL",_i)
					Z15->Z15_PRODUT := GdFieldGet("Z15_PRODUT",_i)
					Z15->Z15_VAZIO  := GdFieldGet("Z15_VAZIO" ,_i)
					Z15->Z15_DENSID := GdFieldGet("Z15_DENSID",_i)
					Z15->Z15_SECO   := GdFieldGet("Z15_SECO"  ,_i)
					Z15->Z15_QUANTI := GdFieldGet("Z15_QUANTI",_i)
					Z15->Z15_SITUAC := GdFieldGet("Z15_SITUAC",_i)
					Z15->Z15_DISPON := GdFieldGet("Z15_DISPON",_i)
					MsUnLock()

				Else

					If GdFieldGet("REGZ15",_i) <> 0

						dbSelectArea("Z15")
						dbSetOrder(1)
						dbGoTo(GdFieldGet("REGZ15",_i))
						RecLock("Z15",.F.)
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
¦¦¦Funçao    ¦ BIA294B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 16.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valida digitação da data para não permitir incluir uma data¦¦¦
¦¦¦          ¦ já existente                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294B()

	Local _ftRet := .T.
	dbSelectArea("Z15")
	dbSetOrder(1)
	If dbSeek(xFilial("Z15") + dtos(xf_Data) + xf_CLVL )
		_ftRet := .F.
		MsgALERT("A data e classe de valor informadas já possui registros. Favor usar a opção de menu ALTERAR ou escolher outra data/Classe de Valor.", "Atenção")
	EndIf

	If !Empty(xf_CLVL)

		If !Alltrim(xf_CLVL) $ "3104/3204/3704"

			_ftRet := .F.
			MsgALERT("Somente são permitidas digitar as classes de valor 3104, 3204 e 3704, inclusive para a MASSA!!!", "Atenção")

		EndIf

		CTH->(dbSetOrder(1))
		If !CTH->(dbSeek(xFilial("CTH") + xf_CLVL))

			_ftRet := .F.
			MsgALERT("Erro na digitação da Classe de valor. Verifique possíveis espaços em branco a esquerda do código!!!", "Atenção")

		EndIf

	EndIf

Return ( _ftRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA294C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 16.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua calculo da Quantidade e do Disponível               ¦¦¦
¦¦¦          ¦ Executado a partir de gatilhos dos campos abaixo           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294C()

	Local gr_Quant  := 0
	Local gr_Dispo  := 0
	Local gr_IndRed := 5
	Local gr_Tanque := ""
	Local gr_Vazio  := 0
	Local gr_Densid := 0
	Local gr_Seco   := 0

	If Alltrim(__readvar) == "M->Z15_TANQUE"

		gr_Tanque := M->Z15_TANQUE
		gr_Vazio  := GdFieldGet("Z15_VAZIO", n)
		gr_Densid := GdFieldGet("Z15_DENSID", n)
		gr_Seco   := GdFieldGet("Z15_SECO", n)

	ElseIf Alltrim(__readvar) == "M->Z15_PRODUT"

		gr_Tanque := GdFieldGet("Z15_TANQUE", n)
		gr_Vazio  := M->Z15_VAZIO
		gr_Densid := GdFieldGet("Z15_DENSID", n)
		gr_Seco   := GdFieldGet("Z15_SECO", n)

	ElseIf Alltrim(__readvar) == "M->Z15_VAZIO"

		gr_Tanque := GdFieldGet("Z15_TANQUE", n)
		gr_Vazio  := M->Z15_VAZIO
		gr_Densid := GdFieldGet("Z15_DENSID", n)
		gr_Seco   := GdFieldGet("Z15_SECO", n)

	ElseIf Alltrim(__readvar) == "M->Z15_DENSID"

		gr_Tanque := GdFieldGet("Z15_TANQUE", n)
		gr_Vazio  := GdFieldGet("Z15_VAZIO", n)
		gr_Densid := M->Z15_DENSID
		gr_Seco   := GdFieldGet("Z15_SECO", n)

	EndIf

	If gr_Vazio <> 0 .and. gr_Densid <> 0 .and. gr_Seco <> 0

		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5") + "ZP" + gr_Tanque)
			_rAltura := Val(Alltrim(Substr(SX5->X5_DESCRI,22,8)))
			If _rAltura > 0
				gr_Quant := ( _rAltura - gr_Vazio ) * Val(Alltrim(Substr(SX5->X5_DESCRI,1,20))) * gr_Densid * ( gr_Seco / 100 )
				gr_Dispo := ( gr_Vazio - gr_IndRed ) * Val(Alltrim(Substr(SX5->X5_DESCRI,1,20))) * gr_Densid * ( gr_Seco / 100 )
			EndIf
		EndIf

	EndIf

	GdFieldPut("Z15_DISPON", gr_Dispo, n)

Return ( gr_Quant )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA294D  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tela que apresenta o saldo, numa determinada data, em esto-¦¦¦
¦¦¦          ¦que versus o controle fisico de estoque (CalcEst vs Z15)    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294D()

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
	Private xfDatRef := Z15->Z15_DATA

	Private xLocReq := "  "

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA294D")

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
	aAdd(_aCores,{"( MARK->QTDSEP + MARK->QTDFIS ) - MARK->QTDSIS == 0", "BR_VERDE"	})
	aAdd(_aCores,{"( MARK->QTDSEP + MARK->QTDFIS ) - MARK->QTDSIS <> 0", "BR_VERMELHO"})

	dbSelectArea("MARK")
	ky_Vet := {{"OK"     ,"" ,"Ajustar"     ,"@!"},;
	{           "CODIGO" ,"" ,"Produto"     ,"@!"},;
	{           "DESCRI" ,"" ,"Descrição"   ,"@!"},;
	{           "QTDSEP" ,"" ,"QtdSeparada" ,"@E 999,999,999.99999999"},;
	{           "QFISOR" ,"" ,"QtdFisOri"   ,"@E 999,999,999.99999999"},;
	{           "QTDFIS" ,"" ,"QuantFis"    ,"@E 999,999,999.99999999"},;
	{           "QTDSIS" ,"" ,"QuantSis"    ,"@E 999,999,999.99999999"},;
	{           "DIFERE" ,"" ,"Diferenca"   ,"@E 999,999,999.99999999"},;
	{           "NUMOP"  ,"" ,"OP"          ,"@!"},;
	{           "CLVL"   ,"" ,"CLVL"        ,"@!"},;
	{           "PERRAT" ,"" ,"%RatQtdCLVL" ,"@E 999,999,999.99999999"} }

	oBrw1      := MsSelect():New( "MARK","OK","",ky_Vet,.F.,@cMarca,{nLin*.008,nCol*.005,nLin*.380,nCol*.410},,,oDlg1,,_aCores )
	//oBrw1:bMark := {| | gInfAjt()}
	oBtn1      := TButton()  :New( nLin*.390,nCol*.385,"Fechar"       ,oDlg1,{|| fh_Esc := .T., oDlg1:End()                      },nLin*.040,nCol*.020,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton()  :New( nLin*.390,nCol*.350,"Ajustar"      ,oDlg1,{|| fh_Esc := .T., ExecBlock("BIA294F",.F.,.F.)     },nLin*.040,nCol*.020,,,,.T.,,"",,,,.F. )

	oSay1      := TSay()     :New( nLin*.395,nCol*.005,{|| vt_TotVlr },oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,150,050)

	ACTIVATE MSDIALOG oDlg1 CENTERED VALID fh_Esc

	MARK->(dbCloseArea())

	oLogProc:LogFimProc()
	RestArea(zpArea)

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ MontTbl1 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.05.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Cria temporario para o Alias: MARK                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MontTbl1()

	Local aFds        := {}
	Local cTmp
	Local msDtLanc    := dtos(Ultimodia(xfDatRef))
	Local msProcGeral := .T.
	local msENTER     := CHR(13) + CHR(10)

	Private oDlgFisico
	Private oButton1
	Private oGet1Loc

	If msDtLanc <> dtos(xfDatRef)

		msMsgDeth := "Identificado que o processamento que se pretende executar está fora da data de fechamento." + msENTER + msENTER
		msMsgDeth += "Selecione: " + msENTER + msENTER
		msMsgDeth += "Sim - para processar especificamente os produtos contidos no cadastro de sobras deste dia." + msENTER + msENTER
		msMsgDeth += "Não - para processar todos os produtos nesta data." + msENTER + msENTER

		msProcGeral := !MsgYESNO(msMsgDeth, "Seleção para Processamento")

	EndIf 

	If msProcGeral

		// Ação implementada em 24/05/16 em atendimento a OS effettivo 2114-16
		GP007 := " WITH SALDOPP AS (SELECT B2_QATU, "
		GP007 += "                         B2_QTSEGUM, "
		GP007 += "                         (SELECT MAX(R_E_C_N_O_) "
		GP007 += "                            FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
		GP007 += "                           WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		GP007 += "                             AND SUBSTRING(D3_EMISSAO,1,6) = '" + Substr(dtos(xfDatRef),1,6) + "' "
		GP007 += "                             AND D3_COD = B2_COD "
		GP007 += "                             AND D3_LOCAL = B2_LOCAL "
		GP007 += "                             AND D3_TM = '999' "
		GP007 += "                             AND D3_CF = 'RE1' "
		GP007 += "                             AND D3_OP <> '' "
		GP007 += "                             AND D3_QUANT > ABS(B2_QATU) "
		GP007 += "                             AND SD3.D_E_L_E_T_ = ' ') REGSD3 "
		GP007 += "                    FROM " + RetSqlName("SB2") + " SB2(NOLOCK) "
		GP007 += "                   INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
		GP007 += "                                        AND B1_COD = B2_COD "
		GP007 += "                                        AND B1_TIPO = 'PP' "
		GP007 += "                                        AND SB1.D_E_L_E_T_ = ' ' "
		GP007 += "                   WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
		GP007 += "                     AND B2_QATU <> 0 "
		GP007 += "                     AND SB2.D_E_L_E_T_ = ' ') "
		GP007 += " UPDATE " + RetSqlName("SD3") + " SET D3_QUANT = D3_QUANT + B2_QATU, D3_QTSEGUM = D3_QTSEGUM + B2_QTSEGUM "
		GP007 += "   FROM SALDOPP "
		GP007 += "  INNER JOIN " + RetSqlName("SD3") + " SD3 ON SD3.R_E_C_N_O_ = REGSD3 "
		U_BIAMsgRun("Aguarde... Atualizando arredondamento de saldo de PP",,{|| TcSQLExec(GP007)})

		PG005 := " UPDATE " + RetSqlName("SB2") + " SET B2_QATU = 0, B2_QTSEGUM = 0
		PG005 += "   FROM " + RetSqlName("SB2") + " SB2
		PG005 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'
		PG005 += "                       AND B1_COD = B2_COD
		PG005 += "                       AND B1_TIPO = 'PP'
		PG005 += "                       AND SB1.D_E_L_E_T_ = ' '
		PG005 += "  WHERE B2_FILIAL = '" + xFilial("SB2") + "'
		PG005 += "    AND B2_QATU <> 0
		PG005 += "    AND SB2.D_E_L_E_T_ = ' '
		U_BIAMsgRun("Aguarde... Atualizando arredondamento de saldo de PP",,{|| TcSQLExec(PG005)})

	EndIf

	DEFINE MSDIALOG oDlgFisico TITLE "Ajuste de Estoque - ALMOXARIFADO" FROM 000, 000  TO 095, 275 COLORS 0, 16777215 PIXEL
	@ 013, 009 SAY oSay1Fis PROMPT "Informar o ALMOXARIFADO:" SIZE 071, 007 OF oDlgFisico COLORS 0, 16777215 PIXEL
	@ 009, 080 MSGET oGet1Loc VAR xLocReq SIZE 017, 010 OF oDlgFisico COLORS 0, 16777215 PIXEL
	@ 007, 101 BUTTON oButton1 PROMPT "Ok" SIZE 020, 012 OF oDlgFisico  ACTION oDlgFisico:End() PIXEL
	ACTIVATE MSDIALOG oDlgFisico

	Aadd( aFds , {"OK"      ,"C",002,000} )
	Aadd( aFds , {"CODIGO"  ,"C",015,000} )
	Aadd( aFds , {"DESCRI"  ,"C",050,000} )
	Aadd( aFds , {"QTDSEP"  ,"N",018,008} )
	Aadd( aFds , {"QFISOR"  ,"N",018,008} )
	Aadd( aFds , {"QTDFIS"  ,"N",018,008} )
	Aadd( aFds , {"QTDSIS"  ,"N",018,008} )
	Aadd( aFds , {"DIFERE"  ,"N",018,008} )
	Aadd( aFds , {"NUMOP"   ,"C",013,000} )
	Aadd( aFds , {"CLVL"    ,"C",009,000} )
	Aadd( aFds , {"PERRAT"  ,"N",018,008} )

	cTmp := CriaTrab( aFds, .T. )
	Use (cTmp) Alias MARK New Exclusive

	A0001 := " WITH SOBRATOT "
	A0001 += "      AS (SELECT PRODUT = Z15_PRODUT, "
	A0001 += "                 LOCREF = Z15_LOCAL, "
	A0001 += "                 QTDTOT = SUM(Z15_QUANTI) "
	A0001 += "          FROM " + RetSqlName("Z15") + " Z15(NOLOCK) "
	A0001 += "          WHERE Z15_FILIAL = '" + xFilial("Z15") + "' "
	A0001 += "                AND Z15_DATA = '" + dtos(xfDatRef) + "' "
	A0001 += "                AND Z15.D_E_L_E_T_ = ' ' "
	A0001 += "          GROUP BY Z15_PRODUT, "
	A0001 += "                   Z15_LOCAL), "
	A0001 += "      RATEIO "
	A0001 += "      AS (SELECT Z15.Z15_PRODUT, "
	A0001 += "                 Z15.Z15_LOCAL, "
	A0001 += "                 Z15.Z15_CLVL, "
	A0001 += "                 Z15.Z15_QUANTI, "
	A0001 += "                 STOT.QTDTOT, "
	A0001 += "                 PERRAT = Z15.Z15_QUANTI / STOT.QTDTOT "
	A0001 += "          FROM " + RetSqlName("Z15") + " Z15(NOLOCK) "
	A0001 += "               LEFT JOIN SOBRATOT STOT ON STOT.PRODUT = Z15.Z15_PRODUT "
	A0001 += "                                          AND STOT.LOCREF = Z15.Z15_LOCAL "
	A0001 += "          WHERE Z15.Z15_FILIAL = '" + xFilial("Z15") + "' "
	A0001 += "                AND Z15.Z15_DATA = '" + dtos(xfDatRef) + "' "
	A0001 += "                AND Z15.D_E_L_E_T_ = ' ') "
	A0001 += "      SELECT SB1.B1_COD PRODUTO, "
	A0001 += "             SUBSTRING(SB1.B1_DESC, 1, 50) DESCRIC, "
	A0001 += "             SB2.B2_LOCAL LOCB2, "
	A0001 += "             ISNULL(Z15.Z15_CLVL, "
	A0001 += "                        CASE "
	A0001 += "                            WHEN SB2.B2_LOCAL = '01' "
	A0001 += "                            THEN '3104' "
	A0001 += "                            WHEN SB2.B2_LOCAL = '20' "
	A0001 += "                            THEN '3204' "
	A0001 += "                            ELSE '    ' "
	A0001 += "                        END) CLVL, "
	A0001 += "             ISNULL(SUM(Z15.Z15_QUANTI), 0) QTDFIS, "
	A0001 += "             0 QTDSEP, "
	A0001 += "             PERRAT = ISNULL(SUM(ROUND(Z15.PERRAT, 8)), 0) "
	A0001 += "      FROM " + RetSqlName("SB1") + " SB1(NOLOCK) "
	A0001 += "           INNER JOIN " + RetSqlName("SB2") + " SB2(NOLOCK) ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' "
	A0001 += "                                            AND SB2.B2_COD = SB1.B1_COD "
	A0001 += "                                            AND SB2.B2_LOCAL IN('" + xLocReq + "') "
	A0001 += "                                            AND SB2.D_E_L_E_T_ = ' ' "
	A0001 += "           " + IIF(msProcGeral, "LEFT", "INNER") + " JOIN RATEIO Z15(NOLOCK) ON Z15.Z15_PRODUT = SB1.B1_COD "
	A0001 += "                                           AND Z15.Z15_LOCAL = SB2.B2_LOCAL "
	A0001 += "      WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	If !xLocReq == "99"
		A0001 += "    AND B1_TIPO IN('PI','PP') "
	EndIf
	If xLocReq == "02"
		A0001 += "    AND B1_COD <> '1020585' "
	EndIf
	If xLocReq == "99"
		A0001 += "    AND B1_COD <> '1022395' "
	EndIf
	A0001 += "            AND SB1.D_E_L_E_T_ = ' ' "
	A0001 += "      GROUP BY SB1.B1_COD, "
	A0001 += "               SB1.B1_DESC, "
	A0001 += "               SB2.B2_LOCAL, "
	A0001 += "               Z15.Z15_CLVL "
	A0001 += "      ORDER BY SB1.B1_COD, "
	A0001 += "               SB2.B2_LOCAL "
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGotop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		xf_Produ  := A001->PRODUTO
		xf_Descr  := A001->DESCRIC
		xf_Saldo  := 0
		xf_SldFi  := A001->QTDFIS
		xf_qtSep  := A001->QTDSEP
		xf_CLVL   := A001->CLVL
		xf_PERRAT := A001->PERRAT

		aSaldos := CalcEst(A001->PRODUTO, A001->LOCB2, xfDatRef+1)
		xf_Saldo += aSaldos[1]

		msSalRat := xf_Saldo * xf_PERRAT

		If msSalRat <> 0 .or. xf_SldFi <> 0

			dbSelectArea("MARK")
			RecLock("MARK",.T.)
			MARK->OK     := IIF(( xf_qtSep + xf_SldFi ) - msSalRat <> 0, cMarca, "  ")
			MARK->CODIGO := xf_Produ
			MARK->DESCRI := xf_Descr
			MARK->QTDSEP := xf_qtSep
			MARK->QFISOR := xf_SldFi
			MARK->QTDFIS := xf_SldFi
			MARK->QTDSIS := Round(msSalRat,8)
			MARK->DIFERE := ( xf_qtSep + xf_SldFi ) - msSalRat
			MARK->CLVL   := xf_CLVL
			MARK->PERRAT := xf_PERRAT
			MsUnLock()

		EndIf

		dbSelectArea("A001")
		dbSkip()

	End
	A001->(dbCloseArea())

	dbSelectArea("MARK")
	dbGoTop()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIA294E       ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 17.05.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para consulta personalizada via "F3".       ¦¦¦
¦¦¦          ¦ Com ele podem ser criados filtros mais rápidos e impedi-   ¦¦¦
¦¦¦          ¦ mento para visualização de detalhes que não podem ser ob-  ¦¦¦
¦¦¦          ¦ servados por alguns usuários.                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294E()

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

	oMSNewGetDados1 := MsNewGetDados():New( 005, 005, 213, 294, , , , , , , 999, , , , oDlg, aHeaderEx, aColsEx)

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
¦¦¦Funçao    ¦ BIA294F  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.05.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua o ajuste de estoque no sistema a partir das informa-¦¦¦
¦¦¦          ¦ções do controle físico                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294F()

	Private lMsHelpAuto	:= .T.
	Private lMsErroAuto	:= .F.
	Private _ExecAutoII	:= .T.

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
							{              "D3_CLVL"   	,MARK->CLVL    	, NIL},;
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
							aAdd(kk_aItem,{"D3_CLVL"	,MARK->CLVL    					,NIL})
							aAdd(kk_aItem,{"D3_SEGUM"  	,xg_SegUm		        		,NIL})
							aAdd(kk_aItem,{"D3_YRFCUST" ,"BIA294"		        		,NIL})
							aAdd(kk_aItem,{"D3_YAPLIC"  ,"1"		             		,NIL})
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
					{              "D3_CLVL"   	,MARK->CLVL    	, NIL},;
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
					aAdd(kk_aItem,{"D3_CLVL"	,MARK->CLVL    					,NIL})
					aAdd(kk_aItem,{"D3_SEGUM"  	,xg_SegUm		        		,NIL})
					aAdd(kk_aItem,{"D3_YRFCUST" ,"BIA294"		        		,NIL})
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
				dbSelectArea("MARK")
				dbSkip()

			End

		Else

			dbSelectArea("MARK")
			dbGotop()
			While !Eof()

				If MARK->OK == cMarca .and. MARK->DIFERE <> 0

					swDoc     := UPPER( NextNumero("SD3", 2, "D3_DOC", .t.) )
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
						SD3->D3_CLVL     :=  MARK->CLVL
						SD3->D3_CONTA    :=  SB1->B1_YCTRIND
						SD3->D3_TIPO     :=  SB1->B1_TIPO
						SD3->D3_EMISSAO  :=  xfDatRef
						SD3->D3_DOC      :=  swDoc
						SD3->D3_NIVEL    :=  ""
						SD3->D3_NUMSEQ   :=  ProxNum()
						SD3->D3_YRFCUST  :=  "BIA294"
						SD3->D3_YAPLIC   :=  "1"
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

	fh_Esc := .T.
	oDlg1:End()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA294W  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02.10.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exporta dados para Excel                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA294W()

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

	U_BIAxExcel(xDadosT, aHeader, "BIA294"+strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA294L  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22.04.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Linha Ok para validação de Digitação                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294L()

	Local _ftRet  := .T.
	Local _msProd := aCols[n][4]

	If !aCols[n,nUsado+1]

		SBZ->(dbSetOrder(1))
		SBZ->(dbSeek(xFilial("SBZ") + _msProd))
		If SBZ->BZ_FANTASM == 'S'
			_ftRet := .F.
			MsgALERT("Produto Fantasma: não é permitida a digitação de sobras. Favor verificar!!!", "Atenção")
		EndIf

	EndIf

Return ( _ftRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA294V  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 01.02.19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Confirma se a Data e Classe de valor foram preenchidos     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA294V()

	Local _ftRet := .T.

	If Empty(xf_Data) .or. Empty(xf_CLVL)
		_ftRet := .F.
		MsgALERT("A data e classe de valor devem ser informadas para prosseguir com o cadastramento das sobras", "Atenção")
	EndIf

Return ( _ftRet )
