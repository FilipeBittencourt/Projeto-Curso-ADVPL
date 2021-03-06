#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA508
@author Marcos Alberto Soprani
@since 29/09/14
@version 1.0
@description Tela de Lan�amentos Extra Cont�beis
@Obs Movimentos Cont�beis Gerencias
@Obs Browser para cadastro de MCG
@type function
/*/

User Function BIA508()

	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Lan�amentos Extra Cont�beis"
	Private lVldTps   := GETMV("MV_CTBCTG",.T.,.F.)

	aRotina   := {  {"Pesquisar"              ,"AxPesqui"                             ,0 ,1},;
	{                "Visualizar"             ,'Execblock("BIA508B" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"                ,'Execblock("BIA508B" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"                ,'Execblock("BIA508B" ,.F.,.F.,"A")'    ,0, 4},;
	{                "Excluir"                ,'Execblock("BIA508B" ,.F.,.F.,"E")'    ,0, 5} }

	//Iniciamos a constru��o b�sica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	oBrowse:SetAlias("Z48")

	//Definimos o t�tulo que ser� exibido como m�todo SetDescription
	oBrowse:SetDescription(cCadastro)

	//Ativamos a classe
	oBrowse:Activate()

Return

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � BIA508B  � Autor � Marcos Alberto S      � Data � 01/05/19 ���
��+----------+------------------------------------------------------------���
���Descri��o � Montagem de Tela Modelo2                                   ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function BIA508B()

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
		cTpSaldo := Z48->Z48_TPSALD
		xsDatRef := Z48->Z48_DATA
	EndIf

	nOpcx    := 0
	nUsado   := 0
	aHeader  := {}
	aCols    := {}

	zy_Cab  := {"Z48_DATA  "}
	zy_Grid := {}
	nUsado := 0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("Z48")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "Z48"
		If aScan(zy_Cab, SX3->X3_CAMPO)	== 0
			If x3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado := nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, , } )
				Aadd(zy_Grid, x3_campo)
			Endif
		EndIf
		dbSkip()
	End
	Aadd(aHeader,{ "Registro", "REGZ48", "99999999999999", 14, 0,"AllwaysTrue()", x3_usado, "N", x3_arquivo, x3_context } )

	aCols:={}
	If !lIncluir
		dbSelectArea("Z48")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("Z48") + dtos(xsDatRef) )
		While !Eof() .and. Z48->Z48_FILIAL == xFilial("Z48") .and. Z48->Z48_DATA == xsDatRef
			AADD(aCols,Array(nUsado+2))
			For _ni := 1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				If aHeader[_ni,2] == "Z48_DDEB  "
					aCols[Len(aCols),_ni] := Posicione("CT1", 1, xFilial("CT1") + FieldGet(FieldPos("Z48_DEBITO")), "CT1->CT1_DESC01")
				EndIf
				If aHeader[_ni,2] == "Z48_DCRD  "
					aCols[Len(aCols),_ni] := Posicione("CT1", 1, xFilial("CT1") + FieldGet(FieldPos("Z48_CREDIT")), "CT1->CT1_DESC01")
				EndIf
				If aHeader[_ni,2] == "Z48_DCVDB "
					aCols[Len(aCols),_ni] := Posicione("CTH", 1, xFilial("CTH") + FieldGet(FieldPos("Z48_CLVLDB")), "CTH->CTH_DESC01")
				EndIf
				If aHeader[_ni,2] == "Z48_DCVCR "
					aCols[Len(aCols),_ni] := Posicione("CTH", 1, xFilial("CTH") + FieldGet(FieldPos("Z48_CLVLCR")), "CTH->CTH_DESC01")
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

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA508C',.F.,.F.,'0')",      , .F.})
		aGetsD   := {}
		nOpcx    := 1
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lIncluir

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA508C',.F.,.F.,'1')",      ,})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lAlterar

		cTpSaldo    := cTpSaldo
		dDataEst	:= xsDatRef
		lDataOk 	:= CtbValiDt(4, dDataEst, .F., cTpSaldo, lVldTps)
		If !lDataOk
			Aviso('Calend�rio Cont�bil', 'O registro que se pretende deletar pertence a um per�odo bloqueado para altera��o conforme CALEND�RIO CONT�BIL. Favor Verificar!!!', {'Ok'})
			Return
		EndIf

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA508C',.F.,.F.,'2')",      , .F.})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lExcluir

		cTpSaldo    := cTpSaldo
		dDataEst	:= xsDatRef
		lDataOk 	:= CtbValiDt(4, dDataEst, .F., cTpSaldo, lVldTps)
		If !lDataOk
			Aviso('Calend�rio Cont�bil', 'O registro que se pretende deletar pertence a um per�odo bloqueado para altera��o conforme CALEND�RIO CONT�BIL. Favor Verificar!!!', {'Ok'})
			Return
		EndIf

		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA508C',.F.,.F.,'3')",      , .F.})
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

					RecLock("Z48",.T.)
					Z48->Z48_FILIAL := xFilial("Z48")
					Z48->Z48_DATA   := xfDatRef
					Z48->Z48_LOTE   := GdFieldGet("Z48_LOTE",_i)
					Z48->Z48_SBLOTE := GdFieldGet("Z48_SBLOTE",_i)
					Z48->Z48_DOC    := GdFieldGet("Z48_DOC",_i)
					Z48->Z48_LINHA  := GdFieldGet("Z48_LINHA",_i)
					Z48->Z48_DC     := GdFieldGet("Z48_DC",_i)
					Z48->Z48_DEBITO := GdFieldGet("Z48_DEBITO",_i)
					Z48->Z48_CREDIT := GdFieldGet("Z48_CREDIT",_i)
					Z48->Z48_CLVLDB := GdFieldGet("Z48_CLVLDB",_i)
					Z48->Z48_CLVLCR := GdFieldGet("Z48_CLVLCR",_i)
					Z48->Z48_ITEMD  := GdFieldGet("Z48_ITEMD",_i)
					Z48->Z48_ITEMC  := GdFieldGet("Z48_ITEMC",_i)
					Z48->Z48_VALOR  := GdFieldGet("Z48_VALOR",_i)
					Z48->Z48_HIST   := GdFieldGet("Z48_HIST",_i)
					Z48->Z48_YHIST  := GdFieldGet("Z48_YHIST",_i)
					Z48->Z48_SI     := GdFieldGet("Z48_SI",_i)
					Z48->Z48_YDELTA := dDataBase
					Z48->Z48_YAPLIC := GdFieldGet("Z48_YAPLIC",_i)
					Z48->Z48_YDRVDB := GdFieldGet("Z48_YDRVDB",_i)
					Z48->Z48_YDRVCR := GdFieldGet("Z48_YDRVCR",_i)
					Z48->Z48_NEGOCI := GdFieldGet("Z48_NEGOCI",_i)
					MsUnLock()

				EndIf

			Next _i

		ElseIf lAlterar

			For _i := 1 to len(aCols)

				If !aCols[_i,nUsado+2]

					dbSelectArea("Z48")

					If GdFieldGet("REGZ48",_i) == 0
						RecLock("Z48",.T.)
						Z48->Z48_FILIAL := xFilial("Z48")
					Else
						dbGoto(GdFieldGet("REGZ48",_i))
						RecLock("Z48",.F.)
					EndIf

					Z48->Z48_DATA   := xfDatRef
					Z48->Z48_LOTE   := GdFieldGet("Z48_LOTE",_i)
					Z48->Z48_SBLOTE := GdFieldGet("Z48_SBLOTE",_i)
					Z48->Z48_DOC    := GdFieldGet("Z48_DOC",_i)
					Z48->Z48_LINHA  := GdFieldGet("Z48_LINHA",_i)
					Z48->Z48_DC     := GdFieldGet("Z48_DC",_i)
					Z48->Z48_DEBITO := GdFieldGet("Z48_DEBITO",_i)
					Z48->Z48_CREDIT := GdFieldGet("Z48_CREDIT",_i)
					Z48->Z48_CLVLDB := GdFieldGet("Z48_CLVLDB",_i)
					Z48->Z48_CLVLCR := GdFieldGet("Z48_CLVLCR",_i)
					Z48->Z48_ITEMD  := GdFieldGet("Z48_ITEMD",_i)
					Z48->Z48_ITEMC  := GdFieldGet("Z48_ITEMC",_i)
					Z48->Z48_VALOR  := GdFieldGet("Z48_VALOR",_i)
					Z48->Z48_HIST   := GdFieldGet("Z48_HIST",_i)
					Z48->Z48_YHIST  := GdFieldGet("Z48_YHIST",_i)
					Z48->Z48_SI     := GdFieldGet("Z48_SI",_i)
					Z48->Z48_YDELTA := dDataBase
					Z48->Z48_YAPLIC := GdFieldGet("Z48_YAPLIC",_i)
					Z48->Z48_YDRVDB := GdFieldGet("Z48_YDRVDB",_i)
					Z48->Z48_YDRVCR := GdFieldGet("Z48_YDRVCR",_i)
					Z48->Z48_NEGOCI := GdFieldGet("Z48_NEGOCI",_i)
					MsUnLock()

				Else

					dbSelectArea("Z48")
					dbGoto(GdFieldGet("REGZ48",_i))
					RecLock("Z48",.F.)
					DELETE
					MsUnLockAll()

				EndIf

			Next _i

		ElseIf lExcluir

			For _i := 1 to len(aCols)
				dbSelectArea("Z48")
				dbGoto(GdFieldGet("REGZ48",_i))
				RecLock("Z48",.F.)
				DELETE
				MsUnLockAll()
			Next _i

		EndIf

	EndIf

	n := 1

Return

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � BIA508C  � Autor � Marcos Alberto S      � Data � 01/05/19 ���
��+----------+------------------------------------------------------------���
���Descri��o � Valida��es diversas para os campos do cabec                ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function BIA508C()

	Local llRetOk := .T.
	Local llGatil := ParamIXB

	If llGatil == "1"

		Z48->(dbSetOrder(1))
		If Z48->(dbSeek(xFilial("Z48") + dtos(xfDatRef)))

			MsgALERT("Existem registros na base para a Data informada. Favor utilizar a rotina Alterar.", "Aten��o!!!")
			llRetOk := .F.

		Else

			cTpSaldo    := "1"
			dDataEst	:= xfDatRef
			lDataOk 	:= CtbValiDt(4, dDataEst, .F., cTpSaldo, lVldTps)
			If !lDataOk
				Aviso('Calend�rio Cont�bil', 'O registro que se pretende incluir pertence a um per�odo bloqueado para altera��o conforme CALEND�RIO CONT�BIL. Favor Verificar!!!', {'Ok'})
				llRetOk := .F.
			EndIf

		EndIf

	EndIf

Return ( llRetOk )
