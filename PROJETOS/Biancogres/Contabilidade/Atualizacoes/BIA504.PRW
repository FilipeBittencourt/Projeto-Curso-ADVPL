#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA504
@author Marcos Alberto Soprani
@since 22/04/21
@version 1.0
@description Tela de Lançamentos de Ajustes Orçamentários EXTRAS
@type function
/*/

User Function BIA504()

	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Lançamentos de Ajustes Orçamentários"
	Private lVldTps   := GETMV("MV_CTBCTG",.T.,.F.)

	aRotina   := {  {"Pesquisar"              ,"AxPesqui"                             ,0 ,1},;
	{                "Visualizar"             ,'Execblock("BIA504B" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"                ,'Execblock("BIA504B" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"                ,'Execblock("BIA504B" ,.F.,.F.,"A")'    ,0, 4},;
	{                "Excluir"                ,'Execblock("BIA504B" ,.F.,.F.,"E")'    ,0, 5} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZOW")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Ativamos a classe
	oBrowse:Activate()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA504B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22/04/21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem de Tela Modelo2                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA504B()

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

	xsDatRef := dDataBase
	If !lIncluir
		xsDatRef := ZOW->ZOW_DATA
		xsVersao := ZOW->ZOW_VERSAO
		xsRevisa := ZOW->ZOW_REVISA
		xsAnoRef := ZOW->ZOW_ANOREF
	EndIf

	nOpcx    := 0
	nUsado   := 0
	aHeader  := {}
	aCols    := {}

	zy_Cab  := {"ZOW_DATA  "}
	zy_Grid := {}
	nUsado := 0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("ZOW")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "ZOW"
		If aScan(zy_Cab, SX3->X3_CAMPO)	== 0
			If x3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado := nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, , } )
				Aadd(zy_Grid, x3_campo)
			Endif
		EndIf
		dbSkip()
	End
	Aadd(aHeader,{ "Registro", "REGZOW", "99999999999999", 14, 0,"AllwaysTrue()", x3_usado, "N", x3_arquivo, x3_context } )

	aCols:={}
	If !lIncluir
		dbSelectArea("ZOW")
		dbSetOrder(2)
		dbGoTop()
		dbSeek(xFilial("ZOW") + xsVersao + xsRevisa + xsAnoRef + dtos(xsDatRef) )
		While !Eof() .and. ZOW->ZOW_FILIAL == xFilial("ZOW") .and. ZOW->ZOW_VERSAO == xsVersao .and. ZOW->ZOW_REVISA == xsRevisa .and. ZOW->ZOW_ANOREF == xsAnoRef  .and.  ZOW->ZOW_DATA == xsDatRef
			AADD(aCols,Array(nUsado+2))
			For _ni := 1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				If aHeader[_ni,2] == "ZOW_DDEB  "
					aCols[Len(aCols),_ni] := Posicione("CT1", 1, xFilial("CT1") + FieldGet(FieldPos("ZOW_DEBITO")), "CT1->CT1_DESC01")
				EndIf
				If aHeader[_ni,2] == "ZOW_DCRD  "
					aCols[Len(aCols),_ni] := Posicione("CT1", 1, xFilial("CT1") + FieldGet(FieldPos("ZOW_CREDIT")), "CT1->CT1_DESC01")
				EndIf
				If aHeader[_ni,2] == "ZOW_DCVDB "
					aCols[Len(aCols),_ni] := Posicione("CTH", 1, xFilial("CTH") + FieldGet(FieldPos("ZOW_CLVLDB")), "CTH->CTH_DESC01")
				EndIf
				If aHeader[_ni,2] == "ZOW_DCVCR "
					aCols[Len(aCols),_ni] := Posicione("CTH", 1, xFilial("CTH") + FieldGet(FieldPos("ZOW_CLVLCR")), "CTH->CTH_DESC01")
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

	aCGD   := {100,05,250,455}
	aCordw := {05,03,500,1220}

	xfDatRef := xsDatRef

	If lVisualizar

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA504C',.F.,.F.,'0')",      , .F.})
		aGetsD   := {}
		nOpcx    := 1
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lIncluir

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA504C',.F.,.F.,'1')",      ,})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lAlterar

		cTpSaldo    := '1'
		dDataEst	:= xsDatRef
		lDataOk 	:= CtbValiDt(4, dDataEst, .F., cTpSaldo, lVldTps)
		If !lDataOk
			Aviso('Calendário Contábil', 'O registro que se pretende deletar pertence a um período bloqueado para alteração conforme CALENDÁRIO CONTÁBIL. Favor Verificar!!!', {'Ok'})
			Return
		EndIf

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA504C',.F.,.F.,'2')",      , .F.})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lExcluir

		cTpSaldo    := '1'
		dDataEst	:= xsDatRef
		lDataOk 	:= CtbValiDt(4, dDataEst, .F., cTpSaldo, lVldTps)
		If !lDataOk
			Aviso('Calendário Contábil', 'O registro que se pretende deletar pertence a um período bloqueado para alteração conforme CALENDÁRIO CONTÁBIL. Favor Verificar!!!', {'Ok'})
			Return
		EndIf

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA504C',.F.,.F.,'3')",      , .F.})
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

					RecLock("ZOW",.T.)
					ZOW->ZOW_FILIAL := xFilial("ZOW")
					ZOW->ZOW_DATA   := xfDatRef
					ZOW->ZOW_VERSAO := GdFieldGet("ZOW_VERSAO",_i)
					ZOW->ZOW_REVISA := GdFieldGet("ZOW_REVISA",_i)
					ZOW->ZOW_ANOREF := GdFieldGet("ZOW_ANOREF",_i)
					ZOW->ZOW_LOTE   := GdFieldGet("ZOW_LOTE",_i)
					ZOW->ZOW_SBLOTE := GdFieldGet("ZOW_SBLOTE",_i)
					ZOW->ZOW_DOC    := GdFieldGet("ZOW_DOC",_i)
					ZOW->ZOW_LINHA  := GdFieldGet("ZOW_LINHA",_i)
					ZOW->ZOW_ORGLAN := GdFieldGet("ZOW_ORGLAN",_i)
					ZOW->ZOW_DC     := GdFieldGet("ZOW_DC",_i)
					ZOW->ZOW_DEBITO := GdFieldGet("ZOW_DEBITO",_i)
					ZOW->ZOW_CREDIT := GdFieldGet("ZOW_CREDIT",_i)
					ZOW->ZOW_CLVLDB := GdFieldGet("ZOW_CLVLDB",_i)
					ZOW->ZOW_CLVLCR := GdFieldGet("ZOW_CLVLCR",_i)
					ZOW->ZOW_ITEMD  := GdFieldGet("ZOW_ITEMD",_i)
					ZOW->ZOW_ITEMC  := GdFieldGet("ZOW_ITEMC",_i)
					ZOW->ZOW_VALOR  := GdFieldGet("ZOW_VALOR",_i)
					ZOW->ZOW_HIST   := GdFieldGet("ZOW_HIST",_i)
					ZOW->ZOW_YHIST  := GdFieldGet("ZOW_YHIST",_i)
					ZOW->ZOW_SI     := GdFieldGet("ZOW_SI",_i)
					ZOW->ZOW_YDELTA := dDataBase
					ZOW->ZOW_APLIC  := GdFieldGet("ZOW_APLIC",_i)
					ZOW->ZOW_DRVDB  := GdFieldGet("ZOW_DRVDB",_i)
					ZOW->ZOW_DRVCR  := GdFieldGet("ZOW_DRVCR",_i)
					ZOW->ZOW_NEGOCI := GdFieldGet("ZOW_NEGOCI",_i)
					//ZOW->ZOW_MESREF := ""
					ZOW->ZOW_ORIPR2 := ""
					ZOW->ZOW_ORIPRC := "AJUSTES"
					ZOW->ZOW_VERCON := ""
					MsUnLock()

				EndIf

			Next _i

		ElseIf lAlterar

			For _i := 1 to len(aCols)

				If !aCols[_i,nUsado+2]

					dbSelectArea("ZOW")

					If GdFieldGet("REGZOW",_i) == 0
						RecLock("ZOW",.T.)
						ZOW->ZOW_FILIAL := xFilial("ZOW")
					Else
						dbGoto(GdFieldGet("REGZOW",_i))
						RecLock("ZOW",.F.)
					EndIf

					ZOW->ZOW_DATA   := xfDatRef
					ZOW->ZOW_VERSAO := GdFieldGet("ZOW_VERSAO",_i)
					ZOW->ZOW_REVISA := GdFieldGet("ZOW_REVISA",_i)
					ZOW->ZOW_ANOREF := GdFieldGet("ZOW_ANOREF",_i)
					ZOW->ZOW_LOTE   := GdFieldGet("ZOW_LOTE",_i)
					ZOW->ZOW_SBLOTE := GdFieldGet("ZOW_SBLOTE",_i)
					ZOW->ZOW_DOC    := GdFieldGet("ZOW_DOC",_i)
					ZOW->ZOW_LINHA  := GdFieldGet("ZOW_LINHA",_i)
					ZOW->ZOW_ORGLAN := GdFieldGet("ZOW_ORGLAN",_i)
					ZOW->ZOW_DC     := GdFieldGet("ZOW_DC",_i)
					ZOW->ZOW_DEBITO := GdFieldGet("ZOW_DEBITO",_i)
					ZOW->ZOW_CREDIT := GdFieldGet("ZOW_CREDIT",_i)
					ZOW->ZOW_CLVLDB := GdFieldGet("ZOW_CLVLDB",_i)
					ZOW->ZOW_CLVLCR := GdFieldGet("ZOW_CLVLCR",_i)
					ZOW->ZOW_ITEMD  := GdFieldGet("ZOW_ITEMD",_i)
					ZOW->ZOW_ITEMC  := GdFieldGet("ZOW_ITEMC",_i)
					ZOW->ZOW_VALOR  := GdFieldGet("ZOW_VALOR",_i)
					ZOW->ZOW_HIST   := GdFieldGet("ZOW_HIST",_i)
					ZOW->ZOW_YHIST  := GdFieldGet("ZOW_YHIST",_i)
					ZOW->ZOW_SI     := GdFieldGet("ZOW_SI",_i)
					ZOW->ZOW_YDELTA := dDataBase
					ZOW->ZOW_APLIC  := GdFieldGet("ZOW_APLIC",_i)
					ZOW->ZOW_DRVDB  := GdFieldGet("ZOW_DRVDB",_i)
					ZOW->ZOW_DRVCR  := GdFieldGet("ZOW_DRVCR",_i)
					ZOW->ZOW_NEGOCI := GdFieldGet("ZOW_NEGOCI",_i)
					//ZOW->ZOW_MESREF := ""
					ZOW->ZOW_ORIPR2 := ""
					ZOW->ZOW_ORIPRC := "AJUSTES"
					ZOW->ZOW_VERCON := ""
					MsUnLock()

				Else

					dbSelectArea("ZOW")
					dbGoto(GdFieldGet("REGZOW",_i))
					RecLock("ZOW",.F.)
					DELETE
					MsUnLockAll()

				EndIf

			Next _i

		ElseIf lExcluir

			For _i := 1 to len(aCols)
				dbSelectArea("ZOW")
				dbGoto(GdFieldGet("REGZOW",_i))
				RecLock("ZOW",.F.)
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
¦¦¦Funçao    ¦ BIA504C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22/04/21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validações diversas para os campos do cabec                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA504C()

	Local llRetOk := .T.
	Local llGatil := ParamIXB

	If llGatil == "1"

		ZOW->(dbSetOrder(1))
		If ZOW->(dbSeek(xFilial("ZOW") + dtos(xfDatRef)))

			MsgALERT("Existem registros na base para a Data informada. Favor utilizar a rotina Alterar.", "Atenção!!!")
			llRetOk := .F.

		Else

			cTpSaldo    := "1"
			dDataEst	:= xfDatRef
			lDataOk 	:= CtbValiDt(4, dDataEst, .F., cTpSaldo, lVldTps)
			If !lDataOk
				Aviso('Calendário Contábil', 'O registro que se pretende incluir pertence a um período bloqueado para alteração conforme CALENDÁRIO CONTÁBIL. Favor Verificar!!!', {'Ok'})
				llRetOk := .F.
			EndIf

		EndIf

	EndIf

Return ( llRetOk )
