#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG129
@author Gabriel Rossi Mafioletti
@since 11/08/20
@version 1.0
@description Tela de Gerenciamento do HeadCount
@type function
/*/

User Function BIAFG129()

	Local oBrowse := NIL

	PRIVATE cCadastro	:=	"Gerenciamento do HeadCount"

	DbSelectArea('ZLC')

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('ZLC')
	oBrowse:SetDescription('Gerenciamento do HeadCount')

	oBrowse:AddLegend("ZLC_STATUS=='A'", "GREEN", "Aberto")
	oBrowse:AddLegend("ZLC_STATUS=='F'", "RED", "Fechado")
	oBrowse:AddLegend("ZLC_STATUS=='I'", "YELLOW", "Iniciado")

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'        , 'PesqBrw'  , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar'       , 'U_BFG129A', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Mudança Status'   , 'U_BFG129S', 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Legenda'          , 'U_BFG129L', 0, 8, 0, NIL } )

Return aRotina

User Function BFG129L()

	Brwlegenda(cCadastro, "Legenda",{{ "BR_VERDE"    ,"Aberto"}   ,;
	{                                  "BR_VERMELHO" ,"Fechado"}  ,;
	{                                  "BR_AMARELO"  ,"Iniciado"} })

Return

User Function BFG129A()

	Private _oDlg		:=	Nil
	Private _oGetDados	:=	Nil
	Private aSize := MsAdvSize(.T.) //Sem Enchoice
	Private aObjects	:=	{}

	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG _oDlg TITLE "Headcount - Visualizar" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL

	fGeraGd()

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg,  {||  _oDlg:End()}, {|| _oDlg:End()})

Return

Static Function fGeraGd()

	Local _aCols	:=	{}
	Local _aHeader	:=	{}
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		SELECT CASE 
		WHEN ZLD.ZLD_TIPO = '1'
		THEN 'AUTOMATICO'
		ELSE 'MANUAL'
	END TIPO
	,ZLA.ZLA_CODIGO
	,ZLA.ZLA_DESPOS
	,ZLD.ZLD_MAT
	,ISNULL(MAT.nomfun, '') AS NOMFUN
	,ISNULL(ZLE.ZLE_DESCRI, '') SITUAC
	,ZLD_OBS
	,ZLD_MATOBS
	,ISNULL(MATSUB.nomfun, '') AS NOMOBS
	,ZLD_DATOBS
	,ZLD_MOTOBS
	FROM %TABLE:ZLD% ZLD
	JOIN %TABLE:ZLA% ZLA ON ZLA.ZLA_FILIAL = ZLD.ZLD_FILIAL
	AND ZLA.ZLA_CODIGO = ZLD.ZLD_CODPOS
	AND ZLA.%NotDel%
	AND ZLD.%NotDel%
	LEFT JOIN %TABLE:ZLE% ZLE ON ZLE.ZLE_CODIGO = ZLD.ZLD_SITUAC
	AND ZLE.%NotDel%
	LEFT JOIN VETORH..r034fun MAT ON CAST(SUBSTRING(ZLD.ZLD_MAT, 1, 2) AS INT) = MAT.numemp
	AND CAST(RIGHT(ZLD.ZLD_MAT, 6) AS INT) = MAT.numcad
	AND MAT.tipcol = 1
	AND MAT.sitafa <> 7
	LEFT JOIN VETORH..r034fun MATSUB ON CAST(SUBSTRING(ZLD.ZLD_MATOBS, 1, 2) AS INT) = MATSUB.numemp
	AND CAST(RIGHT(ZLD.ZLD_MATOBS, 6) AS INT) = MATSUB.numcad
	AND MATSUB.tipcol = 1
	AND MATSUB.sitafa <> 7
	WHERE ZLD.ZLD_FILIAL = %Exp:ZLC->ZLC_FILIAL%
	AND ZLD.ZLD_CODIGO = %Exp:ZLC->ZLC_CODIGO%

	EndSql

	aAdd(_aHeader,{"Tipo"           ,"TIPO"   ,"@!"               , 10 , 0,,, "C",,,, })
	aAdd(_aHeader,{"Cod. Pos"       ,"CODPOS" ,"@!"               , 8  , 0,,, "C",,,, })
	aAdd(_aHeader,{"Desc. Pos"      ,"DESPOS" ,"@!"               , 70 , 0,,, "C",,,, })
	aAdd(_aHeader,{"Matrícula"      ,"MATRIC" ,"@!"               , 8  , 0,,, "C",,,, })
	aAdd(_aHeader,{"Nome"           ,"NOMFUN" ,"@!"               , 40 , 0,,, "C",,,, })
	aAdd(_aHeader,{"Situa."         ,"SITUAC" ,"@!"               , 20 , 0,,, "C",,,, })
	aAdd(_aHeader,{"Obs."           ,"OBS"    ,"@40"              , 40 , 0,,, "C",,,, })
	aAdd(_aHeader,{"Mat. Obs."      ,"MATOBS" ,"@!"               , 8  , 0,,, "C",,,, })
	aAdd(_aHeader,{"Nome Obs."      ,"NOMOBS" ,"@!"               , 40 , 0,,, "C",,,, })
	aAdd(_aHeader,{"Data Obs."      ,"DATOBS" ,"@!"               , 8  , 0,,, "D",,,, })
	aAdd(_aHeader,{"Mot. Obs."      ,"NOMFUN" ,"@!"               , 70 , 0,,, "C",,,, })

	While (_cAlias)->(!EOF())

		(_cAlias)->(aAdd(_aCols,{;
		TIPO,;
		ZLA_CODIGO,;
		ZLA_DESPOS,;
		ZLD_MAT,;
		NOMFUN,;
		SITUAC,;
		ZLD_OBS,;
		ZLD_MATOBS,;
		NOMOBS,;
		Stod(ZLD_DATOBS),;
		ZLD_MOTOBS,;
		.F.}))

		(_cAlias)->(DbSkip())

	EndDo

	_oGetDados	:=	MsNewGetDados():New( aPosObj[1][1] + 10, aPosObj[1][2] + 5, aPosObj[1][3] - 5, aPosObj[1][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "AllWaysTrue", "", _oDlg, _aHeader, _aCols, )

Return

User Function BFG129S()

	Private oDlg
	Private oButton1
	Private oButton2
	Private oComboBox1
	Private nComboBox1 := ZLC->ZLC_STATUS
	Private msRecZLC   := ZLC->(Recno())
	Private oSay1
	Private msFechTl   := .F.
	Private msAltReg   := .F.

	DEFINE MSDIALOG oDlg TITLE "Status HeadCount" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL

	@ 023, 011 SAY oSay1 PROMPT "Mudança de Status: " SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020, 072 MSCOMBOBOX oComboBox1 VAR nComboBox1 ITEMS {"A=Aberto;","I=Iniciado;","F=Fechado"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 019, 149 BUTTON oButton1 PROMPT "Cancelar"  SIZE 037, 012 OF oDlg ACTION msFecha()   PIXEL
	@ 019, 190 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION msConfSta() PIXEL

	ACTIVATE MSDIALOG oDlg VALID msFechTl

	If msAltReg

		MsgINFO("Alteração Realizada com SUCESSO.....", "Status")

	Else

		MsgAlert("Alteração Cancelada.....", "Status")

	EndIf

Return

Static Function msConfSta()

	dbSelectArea("ZLC")
	ZLC->(dbGoTo(msRecZLC))
	ZLC->(RecLock("ZLC",.F.))
	ZLC->ZLC_STATUS := nComboBox1
	ZLC->(MsUnLock())

	msFechTl  := .T.
	msAltReg  := .T.
	Close(oDlg)

Return

Static Function msFecha()

	msFechTl := .T.
	Close(oDlg)

Return
