#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA707
@author Marcos Alberto Soprani
@since 20/07/21
@version 1.0
@description Consulta Querys Projeto GMT
@type function
@Obs Projeto A-59 - Gestão Matricial de Tributos
/*/

User Function BIA707()

	Local xkCloseCon := .F.

	Private dDataIni
	Private dDataFin
	Private xVersao
	Private xRevisa
	Private xAnoRef
	Private xCodPla
	Private xRefDRE

	If ValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))
		xVersao  := MV_PAR02
		xRevisa  := MV_PAR03
		xAnoRef  := MV_PAR04
		xCodPla  := MV_PAR05
		xRefDRE  := MV_PAR06

		U_BIA707C()

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")
		xkCloseCon := .T.

	EndIf

	If !xkCloseCon

		U_BIA707()

	EndIf

Return

Static Function ValidPerg()

	Local cLoad	    := "BIA707" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)
	MV_PAR02 := Space(10)
	MV_PAR03 :=	Space(03)
	MV_PAR04 :=	Space(04)
	MV_PAR05 :=	Space(03)
	MV_PAR06 :=	Space(20)

	aAdd( aPergs ,{1, "Ano/Mês"          ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''        ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Versão Orca"      ,MV_PAR02 ,""            ,"EXISTCPO('ZB5')",'ZB5'     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Revisão Orca"     ,MV_PAR03 ,""            ,"NAOVAZIO()"     ,''        ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "AnoRef Orca"      ,MV_PAR04 ,""            ,"NAOVAZIO()"     ,''        ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Visão Gerencial"  ,MV_PAR05 ,""            ,"EXISTCPO('CVE')",'CVE'     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Ref. DRE"         ,MV_PAR06 ,""            ,"NAOVAZIO()"     ,'CVF707'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)

	EndIf

Return lRet

User Function BIA707C()

	Local oMultiGe1
	Local oMultiGe2
	Local oMultiGe3
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oButton1

	Private cMultiGe1 := ""
	Private cMultiGe2 := ""
	Private cMultiGe3 := ""
	Private xDescrRub := ""
	Private GMToDlg

	fqBIA707()

	DEFINE MSDIALOG GMToDlg TITLE "Consulta Querys" FROM 000, 000  TO 500, 1025 COLORS 0, 16777215 PIXEL

	@ 009, 007 SAY oSay4 PROMPT xDescrRub SIZE 306, 007 OF GMToDlg COLORS 0, 16777215 PIXEL

	@ 031, 005 GET oMultiGe1 VAR cMultiGe1 OF GMToDlg MULTILINE SIZE 150, 212 COLORS 0, 16777215 HSCROLL PIXEL
	@ 031, 159 GET oMultiGe2 VAR cMultiGe2 OF GMToDlg MULTILINE SIZE 150, 212 COLORS 0, 16777215 HSCROLL PIXEL
	@ 031, 314 GET oMultiGe3 VAR cMultiGe3 OF GMToDlg MULTILINE SIZE 150, 212 COLORS 0, 16777215 HSCROLL PIXEL

	@ 022, 006 SAY oSay1 PROMPT "Realizado" SIZE 030, 007 OF GMToDlg COLORS 0, 16777215 PIXEL
	@ 022, 161 SAY oSay2 PROMPT "Orçado" SIZE 025, 007 OF GMToDlg COLORS 0, 16777215 PIXEL
	@ 022, 316 SAY oSay3 PROMPT "Ajustado" SIZE 025, 007 OF GMToDlg COLORS 0, 16777215 PIXEL

	@ 031, 469 BUTTON oButton1 PROMPT "Fecha" SIZE 037, 012 OF GMToDlg ACTION GMToDlg:End() PIXEL

	ACTIVATE MSDIALOG GMToDlg CENTERED

Return

Static Function fqBIA707()

	Local xhnf
	Local xSubTrib := GetMv( "MV_SUBTRIB", , "" )

	CVF->( dbSetOrder(5) )
	CVF->( dbSeek( xFilial("CVF") + xCodPla + xRefDRE ))

	xDescrRub := xRefDRE + "  |  " + CVF->CVF_CONTAG + "  |  " + CVF->CVF_DESCCG  
	xYRFDre   := xRefDRE
	xRubVis   := CVF->CVF_CONTAG

	For xhnf := 1 to 3

		If xhnf == 1

			msQryPrc := CVF->CVF_YQRYRE

		ElseIf xhnf == 2

			msQryPrc := CVF->CVF_YQRYOR

		ElseIf xhnf == 3

			msQryPrc := CVF->CVF_YQRYAJ

		EndIf

		If !Empty(msQryPrc)

			While .T.
				nPosQP = AT("@ALIAS#", msQryPrc)
				msTamVar := Len("@ALIAS#")
				If nPosQP > 0
					msAlias := Substr(msQryPrc, nPosQP + msTamVar, 3) 
					msQryPrc = Replace(msQryPrc, Substr(msQryPrc, nPosQP, 3 + msTamVar) , RetSqlName(msAlias))
				Else
					Exit
				EndIf
			End
			While .T.
				nPosQP = AT("@XFILIAL#", msQryPrc)
				msTamVar := Len("@XFILIAL#")
				If nPosQP > 0
					msAlias := Substr(msQryPrc, nPosQP + msTamVar, 3) 
					msQryPrc = Replace(msQryPrc, Substr(msQryPrc, nPosQP, 3 + msTamVar) , xFilial(msAlias))
				Else
					Exit
				EndIf
			End
			msQryPrc = Replace(msQryPrc, "@DATAINI" , dtos(dDataIni))
			msQryPrc = Replace(msQryPrc, "@DATAFIM" , dtos(dDataFin))
			msQryPrc = Replace(msQryPrc, "@VERSAO"  , xVersao)
			msQryPrc = Replace(msQryPrc, "@REVISA"  , xRevisa)
			msQryPrc = Replace(msQryPrc, "@ANOREF"  , xAnoRef)
			msQryPrc = Replace(msQryPrc, "@CODPLA"  , xCodPla)
			msQryPrc = Replace(msQryPrc, "@RUBVIS"  , xRubVis)
			msQryPrc = Replace(msQryPrc, "@EMPANT"  , cEmpAnt)
			msQryPrc = Replace(msQryPrc, "@FILANT"  , cFilAnt)
			msQryPrc = Replace(msQryPrc, "@PERIODO" , Substr(dtos(dDataFin), 5, 2))
			msQryPrc = Replace(msQryPrc, "@YRFDRE"  , xYRFDre)
			msQryPrc = Replace(msQryPrc, "@SUBTRIB" , xSubTrib)

			If xhnf == 1

				cMultiGe1 := msQryPrc

			ElseIf xhnf == 2

				cMultiGe2 := msQryPrc

			ElseIf xhnf == 3

				cMultiGe3 := msQryPrc

			EndIf			

		EndIf

	Next xhnf

Return
