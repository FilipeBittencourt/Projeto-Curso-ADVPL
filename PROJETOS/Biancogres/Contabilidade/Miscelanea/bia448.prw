#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA448
@author Marcos Alberto Soprani
@since 01/05/19
@version 1.0
@description Tela de Lançamentos de Ajustes do Orçamento
@type function
/*/

User Function BIA448()

	Local aArea := ZZ8->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Lançamentos de Ajustes do Orçamento"

	aRotina   := {  {"Pesquisar"              ,"AxPesqui"                             ,0 ,1},;
	{                "Visualizar"             ,'Execblock("BIA448B" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"                ,'Execblock("BIA448B" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"                ,'Execblock("BIA448B" ,.F.,.F.,"A")'    ,0, 4},;
	{                "Excluir"                ,'Execblock("BIA448B" ,.F.,.F.,"E")'    ,0, 5},;
	{                "Ajuste Meta C.VARIAVEL" ,"U_BIA448D()"                          ,0, 6},;
	{                "Ajuste Meta RECEITA"    ,"U_BIA448R()"                          ,0, 7},;
	{                "Ajuste PARADA"          ,"U_BIA448P()"                          ,0, 8},;
	{                "Carga DW"               ,"U_B448DWB()"                          ,0, 9} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZBF")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "Substr(ZBF_ORGLAN, 1, 8) == 'AJUSTADO'" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA448B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 01/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem de Tela Modelo2                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA448B()

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

	xsDatRef     := dDataBase
	If !lIncluir
		xsDatRef     := ZBF->ZBF_DATA
	EndIf

	nOpcx    := 0
	nUsado   := 0
	aHeader  := {}
	aCols    := {}

	zy_Cab  := {"ZBF_DATA  "}
	zy_Grid := {}
	nUsado := 0
	dbSelectArea("SX3")
	dbSeek("ZBF")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "ZBF"
		If aScan(zy_Cab, SX3->X3_CAMPO)	== 0
			If x3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado := nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, , } )
				Aadd(zy_Grid, x3_campo)
			Endif
		EndIf
		dbSkip()
	End
	Aadd(aHeader,{ "Registro", "REGZBF", "99999999999999", 14, 0,"AllwaysTrue()", x3_usado, "N", x3_arquivo, x3_context } )

	aCols:={}
	If !lIncluir
		dbSelectArea("ZBF")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("ZBF") + dtos(xsDatRef) )
		While !Eof() .and. ZBF->ZBF_FILIAL == xFilial("ZBF") .and. ZBF->ZBF_DATA == xsDatRef
			If ZBF->ZBF_ORGLAN == "AJUSTADO       "
				AADD(aCols,Array(nUsado+2))
				For _ni := 1 to nUsado
					aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				Next
				aCols[Len(aCols),nUsado+1] := Recno()
				aCols[Len(aCols),nUsado+2] := .F.
			EndIf
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
		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA448C',.F.,.F.,'1')",      , .F.})
		aGetsD   := {}
		nOpcx    := 1
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lIncluir
		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA448C',.F.,.F.,'1')",      ,})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, mk_LinhaOk, mk_TudoOk, aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lAlterar
		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA448C',.F.,.F.,'1')",      , .F.})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	ElseIf lExcluir
		AADD(aC,{"xfDatRef"   ,{020,010}  ,"Data: "        ,"@!", "ExecBlock('BIA448C',.F.,.F.,'1')",      , .F.})
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

					RecLock("ZBF",.T.)
					ZBF->ZBF_FILIAL := xFilial("ZBF")
					ZBF->ZBF_DATA   := xfDatRef
					ZBF->ZBF_LOTE   := GdFieldGet("ZBF_LOTE",_i)
					ZBF->ZBF_SBLOTE := GdFieldGet("ZBF_SBLOTE",_i)
					ZBF->ZBF_DOC    := GdFieldGet("ZBF_DOC",_i)
					ZBF->ZBF_LINHA  := GdFieldGet("ZBF_LINHA",_i)
					ZBF->ZBF_DC     := GdFieldGet("ZBF_DC",_i)
					ZBF->ZBF_DEBITO := GdFieldGet("ZBF_DEBITO",_i)
					ZBF->ZBF_CREDIT := GdFieldGet("ZBF_CREDIT",_i)
					ZBF->ZBF_CLVLDB := GdFieldGet("ZBF_CLVLDB",_i)
					ZBF->ZBF_CLVLCR := GdFieldGet("ZBF_CLVLCR",_i)
					ZBF->ZBF_ITEMDB := GdFieldGet("ZBF_ITEMDB",_i)
					ZBF->ZBF_ITEMCR := GdFieldGet("ZBF_ITEMCR",_i)
					ZBF->ZBF_VALOR  := GdFieldGet("ZBF_VALOR",_i)
					ZBF->ZBF_HIST   := GdFieldGet("ZBF_HIST",_i)
					ZBF->ZBF_YHIST  := GdFieldGet("ZBF_YHIST",_i)
					ZBF->ZBF_YSI    := GdFieldGet("ZBF_YSI",_i)
					ZBF->ZBF_YDELTA := dDataBase
					ZBF->ZBF_DRVDB  := GdFieldGet("ZBF_DRVDB",_i)
					ZBF->ZBF_DRVCR  := GdFieldGet("ZBF_DRVCR",_i)
					ZBF->ZBF_YAPLIC := GdFieldGet("ZBF_YAPLIC",_i)
					ZBF->ZBF_ORGLAN := "AJUSTADO"
					ZBF->ZBF_GMCD   := GdFieldGet("ZBF_GMCD",_i)
					ZBF->ZBF_SEQUEN := GdFieldGet("ZBF_SEQUEN",_i)					
					MsUnLock()
					MsUnLock()

				EndIf

			Next _i

		ElseIf lAlterar

			For _i := 1 to len(aCols)

				If !aCols[_i,nUsado+2]

					dbSelectArea("ZBF")

					If GdFieldGet("REGZBF",_i) == 0
						RecLock("ZBF",.T.)
						ZBF->ZBF_FILIAL := xFilial("ZBF")
					Else
						dbGoto(GdFieldGet("REGZBF",_i))
						RecLock("ZBF",.F.)
					EndIf

					ZBF->ZBF_DATA   := xfDatRef
					ZBF->ZBF_LOTE   := GdFieldGet("ZBF_LOTE",_i)
					ZBF->ZBF_SBLOTE := GdFieldGet("ZBF_SBLOTE",_i)
					ZBF->ZBF_DOC    := GdFieldGet("ZBF_DOC",_i)
					ZBF->ZBF_LINHA  := GdFieldGet("ZBF_LINHA",_i)
					ZBF->ZBF_DC     := GdFieldGet("ZBF_DC",_i)
					ZBF->ZBF_DEBITO := GdFieldGet("ZBF_DEBITO",_i)
					ZBF->ZBF_CREDIT := GdFieldGet("ZBF_CREDIT",_i)
					ZBF->ZBF_CLVLDB := GdFieldGet("ZBF_CLVLDB",_i)
					ZBF->ZBF_CLVLCR := GdFieldGet("ZBF_CLVLCR",_i)
					ZBF->ZBF_ITEMDB := GdFieldGet("ZBF_ITEMDB",_i)
					ZBF->ZBF_ITEMCR := GdFieldGet("ZBF_ITEMCR",_i)
					ZBF->ZBF_VALOR  := GdFieldGet("ZBF_VALOR",_i)
					ZBF->ZBF_HIST   := GdFieldGet("ZBF_HIST",_i)
					ZBF->ZBF_YHIST  := GdFieldGet("ZBF_YHIST",_i)
					ZBF->ZBF_YSI    := GdFieldGet("ZBF_YSI",_i)
					ZBF->ZBF_YDELTA := dDataBase
					ZBF->ZBF_DRVDB  := GdFieldGet("ZBF_DRVDB",_i)
					ZBF->ZBF_DRVCR  := GdFieldGet("ZBF_DRVCR",_i)
					ZBF->ZBF_YAPLIC := GdFieldGet("ZBF_YAPLIC",_i)
					ZBF->ZBF_ORGLAN := "AJUSTADO"
					ZBF->ZBF_GMCD   := GdFieldGet("ZBF_GMCD",_i)
					ZBF->ZBF_SEQUEN := GdFieldGet("ZBF_SEQUEN",_i)					
					MsUnLock()

				Else

					dbSelectArea("ZBF")
					dbGoto(GdFieldGet("REGZBF",_i))
					RecLock("ZBF",.F.)
					DELETE
					MsUnLockAll()

				EndIf

			Next _i

		ElseIf lExcluir

			For _i := 1 to len(aCols)
				dbSelectArea("ZBF")
				dbGoto(GdFieldGet("REGZBF",_i))
				RecLock("ZBF",.F.)
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
¦¦¦Funçao    ¦ BIA448C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 01/05/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validações diversas para os campos do cabec                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA448C()

	Local llRetOk := .T.
	Local llGatil := ParamIXB

	If llGatil == "1"

	EndIf

Return ( llRetOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA448D  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 10/07/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cálculo do Ajustado C.VARIAVEL para META                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA448D()

	cHInicio := Time()
	fPerg := "BIA448D"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Processa({ || RptDetail() })

Return

Static Function RptDetail()

	gtDtRef := MV_PAR01
	gtVerca := MV_PAR02
	gtRevis := MV_PAR03
	gtAnoRf := MV_PAR04
	gtDrive := B448Driver("C.VARIAVEL")
	gtContR := 0

	msZ56Seq := ""
	XR009 := " SELECT ISNULL(MAX(Z56_SEQUEN), '   ') SEQUENCIA "
	XR009 += "   FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	XR009 += "  WHERE Z56_FILIAL = '" + xFilial("Z56") + "' "
	XR009 += "    AND Z56_DATARF BETWEEN '" + Substr(dtos(gtDtRef),1,4) + "0101' AND '" + Substr(dtos(gtDtRef),1,4) + "1231' "
	XR009 += "    AND Z56.D_E_L_E_T_ = ' ' "
	XRIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XR009),'XR09',.T.,.T.)
	dbSelectArea("XR09")
	dbGoTop()
	msZ56Seq := XR09->SEQUENCIA
	XR09->(dbCloseArea())
	Ferase(XRIndex+GetDBExtension())
	Ferase(XRIndex+OrdBagExt())

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(ZBF_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("ZBF") + " ZBF(NOLOCK) "
	XP001 += " WHERE ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	XP001 += "       AND ZBF_DATA BETWEEN '" + Substr(dtos(gtDtRef),1,4) + "0101' AND '" + Substr(dtos(gtDtRef),1,4) + "1231' "
	XP001 += "       AND ZBF.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	KS001 := " DELETE " + RetSqlName("ZBF") + " "
	KS001 += "   FROM " + RetSqlName("ZBF") + " ZBF "
	KS001 += "  WHERE ZBF.ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	KS001 += "        AND ZBF.ZBF_DATA = '" + dtos(gtDtRef) +  "' "
	KS001 += "        AND ZBF.ZBF_ORGLAN LIKE '%AJUSTADO-C.VARI%' "
	KS001 += "        AND ZBF.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros ZBF... ",,{|| TcSQLExec(KS001) })

	msContad := .F.
	RT005 := " WITH CVARIAVEL "
	RT005 += "      AS (SELECT CASE "
	RT005 += "                     WHEN Z57_LINHA = 'P01' "
	RT005 += "                     THEN '3801' "
	RT005 += "                     WHEN Z57_LINHA = 'P02' "
	RT005 += "                     THEN '3802' "
	RT005 += "                     WHEN Z57_LINHA = 'P03' "
	RT005 += "                     THEN '3803' "
	RT005 += "                     WHEN Z57_LINHA = 'P04' "
	RT005 += "                     THEN '3804' "
	RT005 += "                     WHEN Z57_LINHA = 'P05' "
	RT005 += "                     THEN '3805' "
	RT005 += "                     WHEN ZZ6_FORNOP NOT IN('F04', 'F05') "
	RT005 += "                     THEN '3100' "
	RT005 += "                     ELSE '3200' "
	RT005 += "                 END CLVL, "
	RT005 += "                 Z56_DATARF DATARF, "
	RT005 += "                 Z56_CONTA CONTA, "
	RT005 += "                 CT1_DESC01 DESC01, "
	RT005 += "                 Z56_M" + Substr(dtos(gtDtRef),5,2) + " * Z57_QTDRAC CUSTOAJTD "
	RT005 += "          FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	RT005 += "               INNER JOIN " + RetSqlName("Z57") + " Z57(NOLOCK) ON Z57_FILIAL = '" + xFilial("Z57") + "' "
	RT005 += "                                        AND Z57_DATARF = Z56_DATARF "
	RT005 += "                                        AND Z57_PRODUT = Z56_COD "
	RT005 += "                                        AND Z57_SEQUEN = Z56_SEQUEN "
	RT005 += "                                        AND Z57.D_E_L_E_T_ = ' ' "
	RT005 += "                LEFT JOIN " + RetSqlName("ZZ6") + " ZZ6(NOLOCK) ON ZZ6_FILIAL = '" + xFilial("ZZ6") + "' "
	RT005 += "                                        AND ZZ6_COD = SUBSTRING(Z56_COD, 1, 2) "
	RT005 += "                                        AND ZZ6.D_E_L_E_T_ = ' ' "
	RT005 += "               INNER JOIN " + RetSqlName("CT1") + " CT1(NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "' "
	RT005 += "                                        AND CT1_CONTA = Z56_CONTA "
	RT005 += "                                        AND CT1.D_E_L_E_T_ = ' ' "
	RT005 += "          WHERE Z56_FILIAL = '" + xFilial("Z56") + "' "
	RT005 += "                AND Z56_DATARF = '" + dtos(gtDtRef) + "' "
	RT005 += "                AND Z56_SEQUEN = '" + msZ56Seq + "' "
	RT005 += "                AND Z56_CONTA NOT IN('61111001', '61112001            ') "
	RT005 += "                AND Z56.D_E_L_E_T_ = ' ' "
	RT005 += "          UNION ALL "
	RT005 += "          SELECT CLVL, " 
	RT005 += "                 '" + dtos(gtDtRef) + "' DATARF, " 
	RT005 += "                 CONTA, "
	RT005 += "                 CT1_DESC01 DESC01, " 
	RT005 += "                 0 CUSTOAJTD "
	RT005 += "          FROM "
	RT005 += "          ( "
	RT005 += "              SELECT ZBF_DEBITO CONTA, " 
	RT005 += "                     ZBF_CLVLDB CLVL, "
	RT005 += "                     ISNULL(SUM(ZBF_VALOR), 0) VALOR "
	RT005 += "              FROM " + RetSqlName("ZBF") + " ZBF(NOLOCK) "
	RT005 += "              WHERE ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	RT005 += "                    AND ZBF_DATA = '" + dtos(gtDtRef) + "' "
	RT005 += "                    AND ZBF_SEQUEN = '" + msSequenc + "' "
	RT005 += "                    AND ZBF_DEBITO <> '' "
	RT005 += "                    AND ZBF_CLVLDB <> '' "
	RT005 += "                    AND D_E_L_E_T_ = ' ' "
	RT005 += "              GROUP BY ZBF_DEBITO, "
	RT005 += "                       ZBF_CLVLDB "
	RT005 += "              UNION ALL "
	RT005 += "              SELECT ZBF_CREDIT CONTA, "
	RT005 += "                     ZBF_CLVLCR CLVL, "
	RT005 += "                     ISNULL(SUM(ZBF_VALOR), 0) * (-1) VALOR "
	RT005 += "              FROM " + RetSqlName("ZBF") + " ZBF(NOLOCK) "
	RT005 += "              WHERE ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	RT005 += "                    AND ZBF_DATA = '" + dtos(gtDtRef) + "' "
	RT005 += "                    AND ZBF_SEQUEN = '" + msSequenc + "' "
	RT005 += "                    AND ZBF_CREDIT <> '' "
	RT005 += "                    AND ZBF_CLVLCR <> '' "
	RT005 += "                    AND D_E_L_E_T_ = ' ' "
	RT005 += "              GROUP BY ZBF_CREDIT, "
	RT005 += "                       ZBF_CLVLCR "
	RT005 += "          ) AS TBL "
	RT005 += "          INNER JOIN " + RetSqlName("Z50") + " Z50(NOLOCK) ON Z50_FILIAL = '" + xFilial("Z50") + "' "
	RT005 += "                                   AND Z50_VERSAO = '" + gtVerca + "' "
	RT005 += "                                   AND Z50_REVISA = '" + gtRevis + "' "
	RT005 += "                                   AND Z50_ANOREF = '" + gtAnoRf + "' "
	RT005 += "                                   AND Z50_CONTA = TBL.CONTA "
	RT005 += "                                   AND Z50_M" + Substr(dtos(gtDtRef),5,2) + " <> 0 "
	RT005 += "                                   AND Z50.D_E_L_E_T_ = ' ' "
	RT005 += "          INNER JOIN " + RetSqlName("CT1") + " CT1(NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "' "
	RT005 += "                                           AND CT1_CONTA = CONTA "
	RT005 += "                                           AND CT1.D_E_L_E_T_ = ' ' "
	RT005 += "          GROUP BY CONTA, "
	RT005 += "                   CT1_DESC01, " 
	RT005 += "                   CLVL "
	RT005 += "          HAVING SUM(VALOR) <> 0 "
	RT005 += "      ) "
	RT005 += "      SELECT *, "
	RT005 += "             ROUND(CUSTO - (DEBITO + CREDITO), 2) AJUSTE "
	RT005 += "      FROM "
	RT005 += "      ( "
	RT005 += "          SELECT CLVL, "
	RT005 += "                 CONTA, "
	RT005 += "                 DESC01, "
	RT005 += "                 SUM(CUSTOAJTD) CUSTO, "
	RT005 += "          ( "
	RT005 += "              SELECT ISNULL(SUM(ZBF_VALOR), 0) VALOR "
	RT005 += "              FROM " + RetSqlName("ZBF") + " ZBF(NOLOCK) "
	RT005 += "              WHERE ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	RT005 += "                    AND ZBF_DEBITO = A.CONTA "
	RT005 += "                    AND ZBF_CLVLDB = A.CLVL "
	RT005 += "                    AND ZBF_DATA = A.DATARF "
	RT005 += "                    AND ZBF_SEQUEN = '" + msSequenc + "' "
	RT005 += "                    AND D_E_L_E_T_ = ' ' "
	RT005 += "          ) DEBITO, "
	RT005 += "          ( "
	RT005 += "              SELECT ISNULL(SUM(ZBF_VALOR), 0) VALOR "
	RT005 += "              FROM " + RetSqlName("ZBF") + " ZBF(NOLOCK) "
	RT005 += "              WHERE ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	RT005 += "                    AND ZBF_CREDIT = A.CONTA "
	RT005 += "                    AND ZBF_CLVLCR = A.CLVL "
	RT005 += "                    AND ZBF_DATA = A.DATARF "
	RT005 += "                    AND ZBF_SEQUEN = '" + msSequenc + "' "
	RT005 += "                    AND D_E_L_E_T_ = ' ' "
	RT005 += "          ) CREDITO "
	RT005 += "          FROM CVARIAVEL A "
	RT005 += "          GROUP BY DATARF, "
	RT005 += "                   CLVL, "
	RT005 += "                   CONTA, "
	RT005 += "                   DESC01 "
	RT005 += "      ) AS TBLZ "
	RT005 += "      ORDER BY CLVL, "
	RT005 += "               CONTA "
	RTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT005),'RT05',.T.,.T.)
	dbSelectArea("RT05")
	dbGoTop()
	While !Eof()

		msContad := .T.

		gtContR ++
		Reclock("ZBF",.T.)
		ZBF->ZBF_FILIAL   = xFilial("ZBF")
		ZBF->ZBF_DATA     = gtDtRef
		ZBF->ZBF_LOTE     = '007218'
		ZBF->ZBF_SBLOTE   = '001
		ZBF->ZBF_DOC      = '000001'
		ZBF->ZBF_LINHA    = StrZero(gtContR,3)
		ZBF->ZBF_DC       = IIF(RT05->AJUSTE > 0, '1'         , '2'         )
		ZBF->ZBF_DEBITO   = IIF(RT05->AJUSTE > 0, RT05->CONTA , ''          )                    
		ZBF->ZBF_CREDIT   = IIF(RT05->AJUSTE > 0, ''          , RT05->CONTA )
		ZBF->ZBF_CLVLDB   = IIF(RT05->AJUSTE > 0, RT05->CLVL  , ''          )
		ZBF->ZBF_CLVLCR   = IIF(RT05->AJUSTE > 0, ''          , RT05->CLVL  )
		ZBF->ZBF_ITEMDB   = ''
		ZBF->ZBF_ITEMCR   = ''
		ZBF->ZBF_VALOR    = ABS(RT05->AJUSTE)
		ZBF->ZBF_HIST     = 'AJUSTADO META INDUSTRIAL'
		ZBF->ZBF_YHIST    = 'AJUSTADO META INDUSTRIAL'
		ZBF->ZBF_YSI      = ''
		ZBF->ZBF_YDELTA   = Date()
		ZBF->ZBF_DRVDB    = IIF(RT05->AJUSTE > 0, gtDrive , ''          )
		ZBF->ZBF_DRVCR    = IIF(RT05->AJUSTE > 0, ''          , gtDrive )
		ZBF->ZBF_YAPLIC   = '1'
		ZBF->ZBF_ORGLAN   = 'AJUSTADO-C.VARI'
		ZBF->ZBF_GMCD    := "S"
		ZBF->ZBF_SEQUEN  := msSequenc
		ZBF->(MsUnlock())

		dbSelectArea("RT05")
		dbSkip()

	End
	RT05->(dbCloseArea())
	Ferase(RTIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RTIndex+OrdBagExt())          //indice gerado

	If msContad

		MsgINFO("Fim do Processamento...")

	Else

		MsgALERT("Favor verificar se a rotina capacidade para RAC foi executada corretamente, pois nenhum registro foi processado nesta etapa!!!")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA448R  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 15/07/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cálculo do Ajustado RECEITA para META                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA448R()

	cHInicio := Time()
	fPerg := "BIA448R"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Processa({ || RptrDetail() })

Return

Static Function RptrDetail()

	gtDtRef := MV_PAR01
	gtVerca := MV_PAR02
	gtRevis := MV_PAR03
	gtAnoRf := MV_PAR04
	gtDrive := B448Driver("RECEITA")
	gtCV21  := Space(2)
	gtCV22  := Space(2)
	gtCV23  := Space(2)
	gtContR := 0

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(ZBF_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("ZBF") + " ZBF "
	XP001 += " WHERE ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	XP001 += "       AND ZBF_DATA BETWEEN '" + Substr(dtos(gtDtRef),1,4) + "0101' AND '" + Substr(dtos(gtDtRef),1,4) + "1231' "
	XP001 += "       AND ZBF.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	KS001 := " DELETE " + RetSqlName("ZBF") + " "
	KS001 += "   FROM " + RetSqlName("ZBF") + " ZBF "
	KS001 += "  WHERE ZBF.ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	KS001 += "        AND ZBF.ZBF_DATA = '" + dtos(gtDtRef) +  "' "
	KS001 += "        AND ZBF.ZBF_ORGLAN LIKE '%AJUSTADO-RECEIT%' "
	KS001 += "        AND ZBF.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros ZBF... ",,{|| TcSQLExec(KS001) })

	RT005 := " WITH REALREC "
	RT005 += "      AS (SELECT MARCA, "
	RT005 += "                 CASE "
	RT005 += "                     WHEN MARCA = '1302' "
	RT005 += "                     THEN '23' "
	RT005 += "                     WHEN MARCA = '0101' "
	RT005 += "                     THEN '21' "
	RT005 += "                     ELSE '22' "
	RT005 += "                 END RAIZCLVL, "
	RT005 += "                 SUM(VALOR) VALOR "
	RT005 += "          FROM VW_SAP_CML_MOVVENDAS "
	RT005 += "          WHERE ATUDPL = 'S' "
	RT005 += "                AND RESULT1 = 'S' "
	RT005 += "                AND RESULT2 = 'S' "
	RT005 += "                AND PRODUTO >= 'A' "
	RT005 += "                AND DTEMIS >= '" + Substr(dtos(gtDtRef), 1, 6) + "01' "
	RT005 += "                AND DTEMIS <= '" + dtos(gtDtRef) + "' "
	RT005 += "                AND D_E_L_E_T_ = '' "
	RT005 += "          GROUP BY MARCA "
	RT005 += "          UNION ALL "
	RT005 += "          SELECT MARCA, "
	RT005 += "                 CASE "
	RT005 += "                     WHEN MARCA = '1302' "
	RT005 += "                     THEN '23' "
	RT005 += "                     WHEN MARCA = '0101' "
	RT005 += "                     THEN '21' "
	RT005 += "                     ELSE '22' "
	RT005 += "                 END RAIZCLVL, "
	RT005 += "                 SUM(VALOR) * (-1) "
	RT005 += "          FROM VW_SAP_CML_MOVDEVOLUCOES "
	RT005 += "          WHERE ATUDPL = 'S' "
	RT005 += "                AND RESULT1 = 'S' "
	RT005 += "                AND RESULT2 = 'S' "
	RT005 += "                AND PRODUTO >= 'A' "
	RT005 += "                AND DTDIGIT >= '" + Substr(dtos(gtDtRef), 1, 6) + "01' "
	RT005 += "                AND DTDIGIT <= '" + dtos(gtDtRef) + "' "
	RT005 += "                AND D_E_L_E_T_ = '' "
	RT005 += "          GROUP BY MARCA), "
	RT005 += "      ORCAREC "
	RT005 += "      AS (SELECT ZBH_MARCA MARCA, "
	RT005 += "                 CASE "
	RT005 += "                     WHEN ZBH_MARCA = '1302' "
	RT005 += "                     THEN '23' "
	RT005 += "                     WHEN ZBH_MARCA = '0101' "
	RT005 += "                     THEN '21' "
	RT005 += "                     ELSE '22' "
	RT005 += "                 END RAIZCLVL, "
	RT005 += "                 ZBH_CANALD CANALD, "
	RT005 += "                 ZBH_ANOREF + ZBH_PERIOD + '01' TEMPO, "
	RT005 += "                 ZBH_VEND, "
	RT005 += "                 ZBH_TPSEG, "
	RT005 += "                 ZBH_PCTGMR, "
	RT005 += "                 ZBH_FORMAT, "
	RT005 += "                 ZBH_GRPCLI, "
	RT005 += "                 ZBH_ESTADO, "
	RT005 += "                 SUM(ZBH_QUANT) QUANT, "
	RT005 += "                 SUM(ZBH_TOTAL) / SUM(ZBH_QUANT) VALOR, "
	RT005 += "                 SUM(ZBH_TOTAL) TOTAL "
	RT005 += "          FROM ZBH010 ZBH "
	RT005 += "          WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
	RT005 += "                AND ZBH.ZBH_VERSAO = '" + gtVerca + "' "
	RT005 += "                AND ZBH.ZBH_REVISA = '" + gtRevis + "' "
	RT005 += "                AND ZBH.ZBH_ANOREF = '" + gtAnoRf + "' "
	RT005 += "                AND ZBH.ZBH_PERIOD <> '00' "
	RT005 += "                AND ZBH.ZBH_ORIGF = '5' "
	RT005 += "                AND ZBH.ZBH_CANALD NOT IN('010', '030', '035') "
	RT005 += "          AND ZBH.D_E_L_E_T_ = ' ' "
	RT005 += "          GROUP BY ZBH_MARCA, "
	RT005 += "                   ZBH_CANALD, "
	RT005 += "                   ZBH_ANOREF + ZBH_PERIOD, "
	RT005 += "                   ZBH_VEND, "
	RT005 += "                   ZBH_TPSEG, "
	RT005 += "                   ZBH_PCTGMR, "
	RT005 += "                   ZBH_FORMAT, "
	RT005 += "                   ZBH_GRPCLI, "
	RT005 += "                   ZBH_ESTADO) "
	RT005 += "      SELECT RAIZCLVL, "
	RT005 += "             REC_REAL, "
	RT005 += "             (SELECT ROUND(SUM(ZBH.TOTAL), 2) REC_ORCA "
	RT005 += "                FROM ORCAREC ZBH "
	RT005 += "               WHERE ZBH.RAIZCLVL = TABLD.RAIZCLVL "
	RT005 += "                 AND TEMPO BETWEEN '" + Substr(dtos(gtDtRef), 1, 6) + "01' AND '" + dtos(gtDtRef) + "') REC_ORCA "
	RT005 += "      FROM (SELECT RAIZCLVL, "
	RT005 += "                   ROUND(SUM(VALOR), 2) REC_REAL "
	RT005 += "              FROM REALREC "
	RT005 += "             GROUP BY RAIZCLVL) AS TABLD "
	RTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT005),'RT05',.T.,.T.)
	dbSelectArea("RT05")
	dbGoTop()
	While !Eof()

		If RT05->RAIZCLVL == "21"
			gtCV21 := RT05->REC_REAL / RT05->REC_ORCA

		ElseIf RT05->RAIZCLVL == "22"
			gtCV22 := RT05->REC_REAL / RT05->REC_ORCA

		ElseIf RT05->RAIZCLVL == "23"
			gtCV23 := RT05->REC_REAL / RT05->REC_ORCA

		EndIf

		dbSelectArea("RT05")
		dbSkip()

	End
	RT05->(dbCloseArea())
	Ferase(RTIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RTIndex+OrdBagExt())          //indice gerado

	FK004 := " WITH DESPESASV "
	FK004 += "      AS (SELECT ZBZ_DEBITO CONTA, "
	FK004 += "                 ZBZ_CLVLDB CLVL, "
	FK004 += "                 ZBZ_ORIPR2 MARCA, "
	FK004 += "                 SUM(ZBZ_VALOR) VALOR "
	FK004 += "          FROM " + RetSqlName("ZBZ") + " "
	FK004 += "          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
	FK004 += "                AND ZBZ_VERSAO = '" + gtVerca + "' "
	FK004 += "                AND ZBZ_REVISA = '" + gtRevis + "' "
	FK004 += "                AND ZBZ_ANOREF = '" + gtAnoRf + "' "
	FK004 += "                AND ZBZ_DEBITO IN('31401020', '31401024', '31403001') "
	FK004 += "          AND ZBZ_DATA BETWEEN '" + Substr(dtos(gtDtRef), 1, 6) + "01' AND '" + dtos(gtDtRef) + "' "
	FK004 += "          AND D_E_L_E_T_ = ' ' "
	FK004 += "          GROUP BY ZBZ_DEBITO, "
	FK004 += "                   ZBZ_CLVLDB, "
	FK004 += "                   ZBZ_ORIPR2 "
	FK004 += "          UNION ALL "
	FK004 += "          SELECT ZBZ_CREDIT CONTA, "
	FK004 += "                 ZBZ_CLVLCR CLVL, "
	FK004 += "                 ZBZ_ORIPR2 MARCA, "
	FK004 += "                 SUM(ZBZ_VALOR) * (-1) VALOR "
	FK004 += "          FROM " + RetSqlName("ZBZ") + " "
	FK004 += "          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
	FK004 += "                AND ZBZ_VERSAO = '" + gtVerca + "' "
	FK004 += "                AND ZBZ_REVISA = '" + gtRevis + "' "
	FK004 += "                AND ZBZ_ANOREF = '" + gtAnoRf + "' "
	FK004 += "                AND ZBZ_CREDIT IN('31401020', '31401024', '31403001') "
	FK004 += "          AND ZBZ_DATA BETWEEN '" + Substr(dtos(gtDtRef), 1, 6) + "01' AND '" + dtos(gtDtRef) + "' "
	FK004 += "          AND D_E_L_E_T_ = ' ' "
	FK004 += "          GROUP BY ZBZ_CREDIT, "
	FK004 += "                   ZBZ_CLVLCR, "
	FK004 += "                   ZBZ_ORIPR2) "
	FK004 += "      SELECT CONTA, "
	FK004 += "             CLVL, "
	FK004 += "             SUM(VALOR) VALOR "
	FK004 += "      FROM DESPESASV A "
	FK004 += "      GROUP BY CONTA, "
	FK004 += "               CLVL "
	FK004 += "      ORDER BY CONTA, "
	FK004 += "               CLVL "
	FKIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,FK004),'FK04',.T.,.T.)
	dbSelectArea("FK04")
	dbGoTop()
	While !Eof()

		gtAjuste := 0
		If Substr(FK04->CLVL,1,2) == "21"
			gtAjuste := ( FK04->VALOR * gtCV21 ) - FK04->VALOR

		ElseIf Substr(FK04->CLVL,1,2) == "22"
			gtAjuste := ( FK04->VALOR * gtCV22 ) - FK04->VALOR

		ElseIf Substr(FK04->CLVL,1,2) == "23"
			gtAjuste := ( FK04->VALOR * gtCV23 ) - FK04->VALOR

		Else
			dbSelectArea("FK04")
			dbSkip()
			Loop

		EndIf

		gtContR ++
		Reclock("ZBF",.T.)
		ZBF->ZBF_FILIAL   = xFilial("ZBF")
		ZBF->ZBF_DATA     = gtDtRef
		ZBF->ZBF_LOTE     = '007278'
		ZBF->ZBF_SBLOTE   = '001
		ZBF->ZBF_DOC      = '000001'
		ZBF->ZBF_LINHA    = StrZero(gtContR,3)
		ZBF->ZBF_DC       = IIF(gtAjuste > 0, '1'         , '2'         )
		ZBF->ZBF_DEBITO   = IIF(gtAjuste > 0, FK04->CONTA , ''          )                    
		ZBF->ZBF_CREDIT   = IIF(gtAjuste > 0, ''          , FK04->CONTA )
		ZBF->ZBF_CLVLDB   = IIF(gtAjuste > 0, FK04->CLVL  , ''          )
		ZBF->ZBF_CLVLCR   = IIF(gtAjuste > 0, ''          , FK04->CLVL  )
		ZBF->ZBF_ITEMDB   = ''
		ZBF->ZBF_ITEMCR   = ''
		ZBF->ZBF_VALOR    = ABS(gtAjuste)
		ZBF->ZBF_HIST     = 'AJUSTADO META RECEITA'
		ZBF->ZBF_YHIST    = 'AJUSTADO META RECEITA'
		ZBF->ZBF_YSI      = ''
		ZBF->ZBF_YDELTA   = Date()
		ZBF->ZBF_DRVDB    = IIF(gtAjuste > 0, gtDrive , ''          )
		ZBF->ZBF_DRVCR    = IIF(gtAjuste > 0, ''          , gtDrive )
		ZBF->ZBF_YAPLIC   = '0'
		ZBF->ZBF_ORGLAN   = 'AJUSTADO-RECEIT'
		ZBF->ZBF_GMCD    := "S"
		ZBF->ZBF_SEQUEN  := msSequenc
		ZBF->(MsUnlock())

		dbSelectArea("FK04")
		dbSkip()

	End
	FK04->(dbCloseArea())
	Ferase(FKIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(FKIndex+OrdBagExt())          //indice gerado

	MsgINFO("Fim do Processamento...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B448Driver  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 16/07/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Buscca Driver para preenchimento automático do ajuste META ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function B448Driver(ctBusca)

	Local ctDriver

	OZ007 := " SELECT ZBE_DRIVER "
	OZ007 += "   FROM " + RetSqlName("ZBE") +  " "
	OZ007 += "  WHERE ZBE_FILIAL = '" + xFilial("ZBE") + "' "
	OZ007 += "    AND ZBE_VERSAO = '" + gtVerca + "' "
	OZ007 += "    AND ZBE_REVISA = '" + gtRevis + "' "
	OZ007 += "    AND ZBE_ANOREF = '" + gtAnoRf + "' "
	OZ007 += "    AND ZBE_APLDEF = '" + ctBusca + "' "
	OZ007 += "    AND D_E_L_E_T_ = ' '
	OZIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,OZ007),'OZ07',.T.,.T.)
	dbSelectArea("OZ07")
	dbGoTop()

	ctDriver := OZ07->ZBE_DRIVER

	OZ07->(dbCloseArea())
	Ferase(OZIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(OZIndex+OrdBagExt())          //indice gerado

Return (ctDriver)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA448P  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02/04/20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cálculo do REFLEXO DA PARADA NA META GMCD                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA448P()

	Local xrEnter   := CHR(13) + CHR(10)

	MsgINFO("Será processado o Ajuste PARADA!!!", "Ajuste PARADA")

	MsgSTOP("Antes de prosseguir é necessário procuara a TI!!!", "Ajuste PARADA")
	Return


	msVERSAO      := 'ORCA_20'
	msREVISA      := '002'
	msANOREF      := '2020'

	msDTINI       := '20200501'
	msDTFIM       := '20200531'
	msSEQUEN      := '   '

	F1_R01        := '0.55'
	F1_TOTGCS     := '0.65'
	F1_L01        := '0.66'
	F1_L03E04     := '0.61'
	F1_E03        := '0.68'
	F2_TOTMOPGCS  := '0.35'
	F2_R02        := '0.39'
	F0_TOT        := '0.53'

	If ( stod(msDTINI) <= GetMV("MV_ULMES") .or. stod(msDTFIM) <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA788 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA788 - Data de Fechamento!!!")
		Return
	EndIf

	msSEQUEN := ""
	XP001 := " SELECT ISNULL(MAX(ZBF_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("ZBF") + " ZBF "
	XP001 += " WHERE ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	XP001 += "       AND ZBF_DATA BETWEEN '" + msDTFIM + "0101' AND '" + msDTFIM + "1231'  "
	XP001 += "       AND ZBF.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSEQUEN := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	KS001 := " DELETE ZBF "
	KS001 += "   FROM " + RetSqlName("ZBF") + " ZBF "
	KS001 += "  WHERE ZBF.ZBF_FILIAL = '" + xFilial("ZBF") + "' "
	KS001 += "        AND ZBF.ZBF_DATA = '" + msDTFIM +  "' "
	KS001 += "        AND ZBF.ZBF_ORGLAN LIKE '%AJUSTADO-PARADA%' "
	KS001 += "        AND ZBF.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros ZBF... ",,{|| TcSQLExec(KS001) })

	JH007 := Alltrim(" INSERT INTO ZBF010 ") + xrEnter
	JH007 += Alltrim(" (ZBF_FILIAL, ") + xrEnter
	JH007 += Alltrim("  ZBF_DATA, ") + xrEnter
	JH007 += Alltrim("  ZBF_LOTE, ") + xrEnter
	JH007 += Alltrim("  ZBF_SBLOTE, ") + xrEnter
	JH007 += Alltrim("  ZBF_DOC, ") + xrEnter
	JH007 += Alltrim("  ZBF_LINHA, ") + xrEnter
	JH007 += Alltrim("  ZBF_DC, ") + xrEnter
	JH007 += Alltrim("  ZBF_DEBITO, ") + xrEnter
	JH007 += Alltrim("  ZBF_CREDIT, ") + xrEnter
	JH007 += Alltrim("  ZBF_CLVLDB, ") + xrEnter
	JH007 += Alltrim("  ZBF_CLVLCR, ") + xrEnter
	JH007 += Alltrim("  ZBF_ITEMDB, ") + xrEnter
	JH007 += Alltrim("  ZBF_ITEMCR, ") + xrEnter
	JH007 += Alltrim("  ZBF_VALOR, ") + xrEnter
	JH007 += Alltrim("  ZBF_HIST, ") + xrEnter
	JH007 += Alltrim("  ZBF_YHIST, ") + xrEnter
	JH007 += Alltrim("  ZBF_YSI, ") + xrEnter
	JH007 += Alltrim("  ZBF_YDELTA, ") + xrEnter
	JH007 += Alltrim("  D_E_L_E_T_, ") + xrEnter
	JH007 += Alltrim("  R_E_C_N_O_, ") + xrEnter
	JH007 += Alltrim("  R_E_C_D_E_L_, ") + xrEnter
	JH007 += Alltrim("  ZBF_DRVDB, ") + xrEnter
	JH007 += Alltrim("  ZBF_DRVCR, ") + xrEnter
	JH007 += Alltrim("  ZBF_YAPLIC, ") + xrEnter
	JH007 += Alltrim("  ZBF_ORGLAN, ") + xrEnter
	JH007 += Alltrim("  ZBF_SEQUEN, ") + xrEnter
	JH007 += Alltrim("  ZBF_GMCD ") + xrEnter
	JH007 += Alltrim(" ) ") + xrEnter
	JH007 += Alltrim(" SELECT '01' ZBF_FILIAL,  ") + xrEnter
	JH007 += Alltrim("        " + msDTFIM + " ZBF_DATA,  ") + xrEnter
	JH007 += Alltrim("        '005842' ZBF_LOTE,  ") + xrEnter
	JH007 += Alltrim("        '001' ZBF_SBLOTE,  ") + xrEnter
	JH007 += Alltrim("        '000001' ZBF_DOC,  ") + xrEnter
	JH007 += Alltrim("        '' ZBF_LINHA,  ") + xrEnter
	JH007 += Alltrim("        '3' ZBF_DC, ") + xrEnter
	JH007 += Alltrim("        CASE ") + xrEnter
	JH007 += Alltrim("            WHEN SUM(VALOR) < 0 ") + xrEnter
	JH007 += Alltrim("            THEN CONTA ") + xrEnter
	JH007 += Alltrim("            ELSE CONTA ") + xrEnter
	JH007 += Alltrim("        END ZBF_DEBITO, ") + xrEnter
	JH007 += Alltrim("        CASE ") + xrEnter
	JH007 += Alltrim("            WHEN SUM(VALOR) > 0 ") + xrEnter
	JH007 += Alltrim("            THEN CONTA ") + xrEnter
	JH007 += Alltrim("            ELSE CONTA ") + xrEnter
	JH007 += Alltrim("        END ZBF_CREDIT, ") + xrEnter
	JH007 += Alltrim("        CASE ") + xrEnter
	JH007 += Alltrim("            WHEN SUM(VALOR) < 0 ") + xrEnter
	JH007 += Alltrim("            THEN CLVL ") + xrEnter
	JH007 += Alltrim("            ELSE CASE ") + xrEnter
	JH007 += Alltrim("                     WHEN SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                     THEN '6107' ") + xrEnter
	JH007 += Alltrim("                     WHEN SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                     THEN '6204' ") + xrEnter
	JH007 += Alltrim("                     WHEN SUBSTRING(CLVL, 1, 2) IN('30', '60') ") + xrEnter
	JH007 += Alltrim("                     THEN '6001' ") + xrEnter
	JH007 += Alltrim("                 END ") + xrEnter
	JH007 += Alltrim("        END ZBF_CLVLDB, ") + xrEnter
	JH007 += Alltrim("        CASE ") + xrEnter
	JH007 += Alltrim("            WHEN SUM(VALOR) > 0 ") + xrEnter
	JH007 += Alltrim("            THEN CLVL ") + xrEnter
	JH007 += Alltrim("            ELSE CASE ") + xrEnter
	JH007 += Alltrim("                     WHEN SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                     THEN '6107' ") + xrEnter
	JH007 += Alltrim("                     WHEN SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                     THEN '6204' ") + xrEnter
	JH007 += Alltrim("                     WHEN SUBSTRING(CLVL, 1, 2) IN('30', '60') ") + xrEnter
	JH007 += Alltrim("                     THEN '6001' ") + xrEnter
	JH007 += Alltrim("                 END ") + xrEnter
	JH007 += Alltrim("        END ZBF_CLVLCR,  ") + xrEnter
	JH007 += Alltrim("        '' ZBF_ITEMDB,  ") + xrEnter
	JH007 += Alltrim("        '' ZBF_ITEMCR,  ") + xrEnter
	JH007 += Alltrim("        ROUND(SUM(VALOR) * CASE ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                           /* F1_R01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('R01') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('6107') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F1_R01 + " ") + xrEnter
	JH007 += Alltrim("                           /* F1_TOTGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('TOT','GCS')  ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F1_TOTGCS + " ") + xrEnter
	JH007 += Alltrim("                           /* F1_L01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('L01')  ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F1_L01 + " ") + xrEnter
	JH007 += Alltrim("                           /* F1_L03E04 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('L03','E04')  ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F1_L03E04 + " ") + xrEnter
	JH007 += Alltrim("                           /* F1_E03 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('E03')  ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F1_E03 + " ") + xrEnter
	JH007 += Alltrim("                           /* F2_TOTMOPGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('TOT','MOP','GCS')  ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('6204') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F2_TOTMOPGCS + " ") + xrEnter
	JH007 += Alltrim("                           /* F2_R02 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('R02')  ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('6204') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F2_R02 + " ") + xrEnter
	JH007 += Alltrim("                           /* F0_TOT */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                               WHEN CRIT IN('TOT')  ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                    AND SUBSTRING(CLVL, 1, 2) IN('30', '60') ") + xrEnter
	JH007 += Alltrim("                                    AND CLVL NOT IN('6001') ") + xrEnter
	JH007 += Alltrim("                               THEN " + F0_TOT + " ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                           /* -- */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                           END, 2) ZBF_VALOR,  ") + xrEnter
	JH007 += Alltrim("        'LCTO PARADA DE LINHA N/MES' ZBF_HIST,  ") + xrEnter
	JH007 += Alltrim("        'LCTO PARADA DE LINHA N/MES - POR PARADA NAO PROGRAMADA. ' + CASE ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                                                                     /* F1_R01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('R01') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('6107') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F1_R01 ' ") + xrEnter
	JH007 += Alltrim("                                                                     /* F1_TOTGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('TOT','GCS')  ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F1_TOTGCS ' ") + xrEnter
	JH007 += Alltrim("                                                                     /* F1_L01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('L01')  ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F1_L01 ' ") + xrEnter
	JH007 += Alltrim("                                                                     /* F1_L03E04 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('L03','E04')  ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F1_L03E04 ' ") + xrEnter
	JH007 += Alltrim("                                                                     /* F1_E03 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('E03')  ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F1_E03 ' ") + xrEnter
	JH007 += Alltrim("                                                                     /* F2_TOTMOPGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('TOT','MOP','GCS')  ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('6204') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F2_TOTMOPGCS ' ") + xrEnter
	JH007 += Alltrim("                                                                     /* F2_R02 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('R02')  ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('6204') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F2_R02 ' ") + xrEnter
	JH007 += Alltrim("                                                                     /* F0_TOT */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                       
	JH007 += Alltrim("                                                                         WHEN CRIT IN('TOT')  ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                              AND SUBSTRING(CLVL, 1, 2) IN('30', '60') ") + xrEnter
	JH007 += Alltrim("                                                                              AND CLVL NOT IN('6001') ") + xrEnter
	JH007 += Alltrim("                                                                         THEN ' F0_TOT ' ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                                                                     /* -- */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                                                                     END + ' VALOR ORIGINAL: ' + CONVERT(VARCHAR, SUM(VALOR)) + ';   PERCENTUAL: ' + CONVERT(VARCHAR, ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             CASE ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F1_R01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('R01') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('6107') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F1_R01 + " ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F1_TOTGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('TOT','GCS')  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F1_TOTGCS + " ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F1_L01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('L01')  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F1_L01 + " ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F1_L03E04 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('L03','E04')  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F1_L03E04 + " ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F1_E03 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('E03')  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('3117','6107') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F1_E03 + " ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F2_TOTMOPGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('TOT','MOP','GCS')  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('6204') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F2_TOTMOPGCS + " ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F2_R02 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('R02')  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('6204') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F2_R02 + " ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* F0_TOT */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter                                                                                                                                               
	JH007 += Alltrim("                                                                                                                                                                 WHEN CRIT IN('TOT')  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND SUBSTRING(CLVL, 1, 2) IN('30', '60') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                      AND CLVL NOT IN('6001') ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                                 THEN " + F0_TOT + " ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             /* -- */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                                                                                                                                                             END) ZBF_YHIST,  ") + xrEnter
	JH007 += Alltrim("        '' ZBF_YSI,  ") + xrEnter
	JH007 += Alltrim("        CONVERT(VARCHAR, GETDATE(), 112) ZBF_YDELTA,  ") + xrEnter
	JH007 += Alltrim("        '' D_E_L_E_T_,  ") + xrEnter
	JH007 += Alltrim(" ( ") + xrEnter
	JH007 += Alltrim("     SELECT MAX(R_E_C_N_O_) ") + xrEnter
	JH007 += Alltrim("     FROM ZBF010 ") + xrEnter
	JH007 += Alltrim(" ) + ROW_NUMBER() OVER( ") + xrEnter
	JH007 += Alltrim("        ORDER BY CONTA,  ") + xrEnter
	JH007 += Alltrim("                 CLVL) AS R_E_C_N_O_,  ") + xrEnter
	JH007 += Alltrim("        0 R_E_C_D_E_L_, ") + xrEnter
	JH007 += Alltrim("        CASE ") + xrEnter
	JH007 += Alltrim("            WHEN SUM(VALOR) < 0 ") + xrEnter
	JH007 += Alltrim("            THEN DRIVER ") + xrEnter
	JH007 += Alltrim("            ELSE '' ") + xrEnter
	JH007 += Alltrim("        END ZBF_DRVDB, ") + xrEnter
	JH007 += Alltrim("        CASE ") + xrEnter
	JH007 += Alltrim("            WHEN SUM(VALOR) > 0 ") + xrEnter
	JH007 += Alltrim("            THEN DRIVER ") + xrEnter
	JH007 += Alltrim("            ELSE '' ") + xrEnter
	JH007 += Alltrim("        END ZBF_DRVCR, ") + xrEnter
	JH007 += Alltrim("        APLIC ZBF_YAPLIC, ") + xrEnter
	JH007 += Alltrim("        'AJUSTADO-PARADA' ZBF_ORGLAN, ") + xrEnter
	JH007 += Alltrim("        '" + msSEQUEN + "' ZBF_SEQUEN, ") + xrEnter
	JH007 += Alltrim("        'S' ZBF_GMCD ") + xrEnter
	JH007 += Alltrim(" FROM ") + xrEnter
	JH007 += Alltrim(" ( ") + xrEnter
	JH007 += Alltrim("     SELECT TBDADOS.* ") + xrEnter
	JH007 += Alltrim("     FROM ") + xrEnter
	JH007 += Alltrim("     ( ") + xrEnter
	JH007 += Alltrim("         SELECT CONTA,  ") + xrEnter
	JH007 += Alltrim("                CT1_DESC01,  ") + xrEnter
	JH007 += Alltrim("                SUBSTRING(CT1_YAGRUP, 1, 10) AGRUP,  ") + xrEnter
	JH007 += Alltrim("                CLVL,  ") + xrEnter
	JH007 += Alltrim("                DRIVER,  ") + xrEnter
	JH007 += Alltrim("                APLIC,  ") + xrEnter
	JH007 += Alltrim("                SUBSTRING(CTH_YCRIT, 1, 3) CRIT,  ") + xrEnter
	JH007 += Alltrim("                SUM(VALOR) VALOR ") + xrEnter
	JH007 += Alltrim("         FROM ") + xrEnter
	JH007 += Alltrim("         ( ") + xrEnter
	JH007 += Alltrim("             SELECT ZBZ_DEBITO CONTA,  ") + xrEnter
	JH007 += Alltrim("                    ZBZ_CLVLDB CLVL,  ") + xrEnter
	JH007 += Alltrim("                    ZBZ_DRVDB DRIVER,  ") + xrEnter
	JH007 += Alltrim("                    ZBZ_APLIC APLIC,  ") + xrEnter
	JH007 += Alltrim("                    SUM(ZBZ_VALOR) VALOR ") + xrEnter
	JH007 += Alltrim("             FROM ZBZ010 ") + xrEnter
	JH007 += Alltrim("             WHERE ZBZ_FILIAL = '01' ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_DATA BETWEEN " + msDTINI + " AND " + msDTFIM + " ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_VERSAO = '"  + msVERSAO + "' ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_REVISA = '" + msREVISA + "' ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_ANOREF = '" + msANOREF + "' ") + xrEnter
	JH007 += Alltrim("                   AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6' ") + xrEnter
	JH007 += Alltrim("                   AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62' ") + xrEnter
	JH007 += Alltrim("                   AND D_E_L_E_T_ = ' ' ") + xrEnter
	JH007 += Alltrim("             GROUP BY ZBZ_DEBITO,  ") + xrEnter
	JH007 += Alltrim("                      ZBZ_CLVLDB,  ") + xrEnter
	JH007 += Alltrim("                      ZBZ_DRVDB,  ") + xrEnter
	JH007 += Alltrim("                      ZBZ_APLIC ") + xrEnter
	JH007 += Alltrim("             UNION ALL ") + xrEnter
	JH007 += Alltrim("             SELECT ZBZ_CREDIT CONTA,  ") + xrEnter
	JH007 += Alltrim("                    ZBZ_CLVLCR CLVL,  ") + xrEnter
	JH007 += Alltrim("                    ZBZ_DRVCR DRIVER,  ") + xrEnter
	JH007 += Alltrim("                    ZBZ_APLIC APLIC,  ") + xrEnter
	JH007 += Alltrim("                    SUM(ZBZ_VALOR) * (-1) VALOR ") + xrEnter
	JH007 += Alltrim("             FROM ZBZ010 ") + xrEnter
	JH007 += Alltrim("             WHERE ZBZ_FILIAL = '01' ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_DATA BETWEEN " + msDTINI + " AND " + msDTFIM + " ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_VERSAO = '" + msVERSAO + "' ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_REVISA = '" + msREVISA + "' ") + xrEnter
	JH007 += Alltrim("                   AND ZBZ_ANOREF = '" + msANOREF + "' ") + xrEnter
	JH007 += Alltrim("                   AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6' ") + xrEnter
	JH007 += Alltrim("                   AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62' ") + xrEnter
	JH007 += Alltrim("                   AND D_E_L_E_T_ = ' ' ") + xrEnter
	JH007 += Alltrim("             GROUP BY ZBZ_CREDIT,  ") + xrEnter
	JH007 += Alltrim("                      ZBZ_CLVLCR,  ") + xrEnter
	JH007 += Alltrim("                      ZBZ_DRVCR,  ") + xrEnter
	JH007 += Alltrim("                      ZBZ_APLIC ") + xrEnter
	JH007 += Alltrim("         ) AS TAB ") + xrEnter
	JH007 += Alltrim("         INNER JOIN CT1010 CT1 ON CT1_FILIAL = '  ' ") + xrEnter
	JH007 += Alltrim("                                  AND CT1_CONTA = CONTA ") + xrEnter
	JH007 += Alltrim("                                  AND CT1.D_E_L_E_T_ = ' ' ") + xrEnter
	JH007 += Alltrim("         INNER JOIN CTH010 CTH ON CTH_FILIAL = '  ' ") + xrEnter
	JH007 += Alltrim("                                  AND CTH_CLVL = CLVL ") + xrEnter
	JH007 += Alltrim("                                  AND CTH_YAPLCT = 'S' ") + xrEnter
	JH007 += Alltrim("                                  AND CTH.D_E_L_E_T_ = ' ' ") + xrEnter
	JH007 += Alltrim("         WHERE RTRIM(CLVL) NOT IN('3180','3181','3183','3155','3280','3105','3205') ") + xrEnter
	JH007 += Alltrim("         GROUP BY CONTA,  ") + xrEnter
	JH007 += Alltrim("                  CT1_DESC01,  ") + xrEnter
	JH007 += Alltrim("                  SUBSTRING(CT1_YAGRUP, 1, 10),  ") + xrEnter
	JH007 += Alltrim("                  CLVL,  ") + xrEnter
	JH007 += Alltrim("                  SUBSTRING(CTH_YCRIT, 1, 3),  ") + xrEnter
	JH007 += Alltrim("                  DRIVER,  ") + xrEnter
	JH007 += Alltrim("                  APLIC ") + xrEnter
	JH007 += Alltrim("     ) AS TBDADOS ") + xrEnter
	JH007 += Alltrim(" ) AS TBDADOS ") + xrEnter
	JH007 += Alltrim(" WHERE ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                 /* F1_R01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('R01') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('6107') ) ") + xrEnter
	JH007 += Alltrim("                     OR ") + xrEnter
	JH007 += Alltrim("                 /* F1_TOTGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('TOT','GCS')  ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('3117','6107') ) ") + xrEnter
	JH007 += Alltrim("                     OR ") + xrEnter
	JH007 += Alltrim("                 /* F1_L01 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('L01')  ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('3117','6107') ) ") + xrEnter
	JH007 += Alltrim("                     OR ") + xrEnter
	JH007 += Alltrim("                 /* F1_L03E04 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('L03','E04')  ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('3117','6107') ) ") + xrEnter
	JH007 += Alltrim("                     OR ") + xrEnter
	JH007 += Alltrim("                 /* F1_E03 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('E03')  ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('31', '61') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('3117','6107') ) ") + xrEnter
	JH007 += Alltrim("                     OR ") + xrEnter
	JH007 += Alltrim("                 /* F2_TOTMOPGCS */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('TOT','MOP','GCS')  ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('6204') ) ") + xrEnter
	JH007 += Alltrim("                     OR ") + xrEnter
	JH007 += Alltrim("                 /* F2_R02 */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('R02')  ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('32', '62') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('6204') ) ") + xrEnter
	JH007 += Alltrim("                     OR ") + xrEnter
	JH007 += Alltrim("                 /* F0_TOT */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter   
	JH007 += Alltrim("                     ( CRIT IN('TOT')  ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CONTA, 1, 3) IN('612', '613', '614', '615', '616', '617') ") + xrEnter
	JH007 += Alltrim("                          AND SUBSTRING(CLVL, 1, 2) IN('30', '60') ") + xrEnter
	JH007 += Alltrim("                          AND CLVL NOT IN('6001') ) ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim("                 /* -- */ ") + xrEnter
	JH007 += Alltrim("  ") + xrEnter
	JH007 += Alltrim(" GROUP BY CRIT,  ") + xrEnter
	JH007 += Alltrim("          CONTA,  ") + xrEnter
	JH007 += Alltrim("          CLVL,  ") + xrEnter
	JH007 += Alltrim("          DRIVER,  ") + xrEnter
	JH007 += Alltrim("          APLIC ") + xrEnter
	JH007 += Alltrim(" ORDER BY CRIT,  ") + xrEnter
	JH007 += Alltrim("          CONTA,  ") + xrEnter
	JH007 += Alltrim("          CLVL ") + xrEnter
	U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(JH007)})

	MsgINFO("Fim do Processamento...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B448DWB  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/01/20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Carga de dados para DWB                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B448DWB()

	Local aArea		:= GetArea()
	Local oProcess

	If MsgYesNo("Confirma a carga geral para o GMCD 2.0?", "Carga DW")

		oProcess := MsNewProcess():New({|lEnd| B4dwbPchk(@oProcess) }, "Carga de Dados", "DataBase SAP->DM_GMCD DW", .T.)
		oProcess:Activate()

	Else

		MsgALERT("Processo abortado...", "Carga DW")

	Endif

	RestArea(aArea)

Return

Static Function B4dwbPchk(oProcess)

	Local MS007
	Local nSrvDB := Iif( "PROD" $ Upper(AllTrim(getenvserver())) .or. "FECH" $ Upper(AllTrim(getenvserver())) , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV

	MS007 := " EXEC " + nSrvDB + ".msdb.dbo.sp_start_job N'SAP->DM_GMCD' "
	U_BIAMsgRun("Start JOB... Aguarde... ",,{|| TcSQLExec(MS007)})

	mCtrFimJob := .F. 
	oProcess:SetRegua1(100000)
	oProcess:SetRegua2(100000)             
	hhTmpINI      := TIME()
	oProcess:IncRegua1("Executando JOB...")
	Sleep( 5000 )
	While !mCtrFimJob

		oProcess:IncRegua2("JOB em progresso a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )   

		MS004 := " EXEC " + nSrvDB + ".msdb.dbo.sp_help_job "
		MS004 += "    @job_name = N'SAP->DM_GMCD', "
		MS004 += "    @job_aspect = N'JOB', "
		MS004 += "    @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.F.,.T.)
		dbSelectArea("MS04")
		dbGoTop()
		If Eof()
			mCtrFimJob := .T.
		Else
			Sleep( 1000 )
		End

		MS04->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 15/07/19 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Data Ref.Fechamento      ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Versão                   ?","","","mv_ch2","C",10,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"03","Revisão                  ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","AnoRef                   ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
