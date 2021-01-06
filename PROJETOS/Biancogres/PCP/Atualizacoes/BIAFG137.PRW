#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG137
@author Gabriel Rossi Mafioletti
@since 17/12/2020
@version 1.0
@description Cadastro de Valores Padrões para o Formulário de Prensa
@type function
/*/

User Function BIAFG137()

	Local oBrowse := NIL

	DbSelectArea('ZCY')

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('ZCY')
	oBrowse:SetDescription('Cadastro de Valores Padrões para o Formulário de Prensa')

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar', 'U_BFG137PR', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'U_BFG137PR', 0, 4, 0, NIL } )


Return aRotina

User Function BFG137PR(cAlias,nReg,nOpc)

	Local _aSize	
	Local _aObjects := {}
	Local _aInfo
	Local _nOpca	:= 0
	Local _aPosObj

	Local _aHeader	:=	{}
	Local _aCols	:=	{}

	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	Local _oDlg	:=	Nil

	Local _nOk	:=	0

	Local cSeek
	Local bWhile	:=	{|| ZCY_FILIAL }

	_aSize := MsAdvSize(.T.) //Sem Enchoice

	Private nOpca := nOpc
	Private VISUAL :=  nOpca == 2
	Private INCLUI :=  nOpca == 3
	Private ALTERA :=  nOpca == 4

	Private _oGd
	Private _oEnch


	cSeek	:=	xFilial("ZCY")

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 0, 0}	


	AAdd(_aObjects, {100, 100, .T. , .T. })

	FillGetDados(4,"ZCY",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	DEFINE MSDIALOG _oDlg TITLE "Valores Padrões para o Formulário de Prensa" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL

	_oGetDados := MsNewGetDados():New(_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4], IF(INCLUI .OR. ALTERA,GD_INSERT+GD_UPDATE,0), "U_FG137LOK()"/*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/,999 /*[ nMax]*/, "U_FG137FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOk := 1, If(_oGetDados:TudoOk(), _oDlg:End(),_nOk := 0)}, {|| _oDlg:End()})

	If _nOk == 1 .And. nOpcA >= 3 .And. nOpca <= 5 
		fGrava(nOpcA)
	EndIf

Return

User Function FG137FOK()

	Local _cCpo	:=	ReadVar()
	Local _lRet	:=	.T.
	local nPosRec	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCY_REC_WT"})

	Local _aArea	:=	GetArea()

	If Alltrim(_cCpo) $ "M->ZCY_LINHA/M->ZCY_DESFOR/M->ZCY_TIPOLO" .And. _oGetDados:aCols[_oGetDados:nAt,nPosRec] > 0
		MsgInfo("Não é possível alterar os dados já gravados(Linha,Formato e Tipologia)")
		_lRet	:=	.F.
	EndIf
	RestArea(_aArea)
Return _lRet

Static Function fGrava(nOpcA)

	local nPosRec	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCY_REC_WT"})
	Local _nPosDel	:= Len(_oGetDados:aHeader)+1
	Local _nI

	DbSelectArea("ZCY")
	ZCY->(DbSetOrder(1))

		For _nI	:=	1 to Len(_oGetDados:aCols)
			If _oGetDados:aCols[_nI,nPosRec] == 0 .And. _oGetDados:aCols[_nI,_nPosDel] 
				Loop
			ElseIf _oGetDados:aCols[_nI,nPosRec] == 0 
				Reclock("ZCY",.T.)
					ZCY->ZCY_FILIAL	:=	xFilial("ZCY")
					ZCY->ZCY_LINHA	:=	GdFieldGet("ZCY_LINHA" ,_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_DESFOR	:=	GdFieldGet("ZCY_DESFOR",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_TIPOLO	:=	GdFieldGet("ZCY_TIPOLO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIPRMA	:=	GdFieldGet("ZCY_LIPRMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSPRMA	:=	GdFieldGet("ZCY_LSPRMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIPRES	:=	GdFieldGet("ZCY_LIPRES",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSPRES	:=	GdFieldGet("ZCY_LSPRES",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIPEPE	:=	GdFieldGet("ZCY_LIPEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSPEPE	:=	GdFieldGet("ZCY_LSPEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIESPE	:=	GdFieldGet("ZCY_LIESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSESPE	:=	GdFieldGet("ZCY_LSESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIUMMA	:=	GdFieldGet("ZCY_LIUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSUMMA	:=	GdFieldGet("ZCY_LSUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIUMRE	:=	GdFieldGet("ZCY_LIUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSUMRE	:=	GdFieldGet("ZCY_LSUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIGRAN	:=	GdFieldGet("ZCY_LIGRAN",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSGRAN	:=	GdFieldGet("ZCY_LSGRAN",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LITEPE	:=	GdFieldGet("ZCY_LITEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LSTEPE	:=	GdFieldGet("ZCY_LSTEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZCY->ZCY_LIREMS	:=	GdFieldGet("ZCY_LIREMS",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			
			Else
				ZCY->(DbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZCY",.F.)
			EndIf

			If _oGetDados:aCols[_nI,_nPosDel] .And. _oGetDados:aCols[_nI,nPosRec] > 0
				ZCY->(DbDelete())
			Else
				ZCY->ZCY_FILIAL	:=	xFilial("ZCY")
				ZCY->ZCY_LINHA	:=	GdFieldGet("ZCY_LINHA" ,_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_DESFOR	:=	GdFieldGet("ZCY_DESFOR",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_TIPOLO	:=	GdFieldGet("ZCY_TIPOLO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIPRMA	:=	GdFieldGet("ZCY_LIPRMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSPRMA	:=	GdFieldGet("ZCY_LSPRMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIPRES	:=	GdFieldGet("ZCY_LIPRES",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSPRES	:=	GdFieldGet("ZCY_LSPRES",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIPEPE	:=	GdFieldGet("ZCY_LIPEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSPEPE	:=	GdFieldGet("ZCY_LSPEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIESPE	:=	GdFieldGet("ZCY_LIESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSESPE	:=	GdFieldGet("ZCY_LSESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIUMMA	:=	GdFieldGet("ZCY_LIUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSUMMA	:=	GdFieldGet("ZCY_LSUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIUMRE	:=	GdFieldGet("ZCY_LIUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSUMRE	:=	GdFieldGet("ZCY_LSUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIGRAN	:=	GdFieldGet("ZCY_LIGRAN",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSGRAN	:=	GdFieldGet("ZCY_LSGRAN",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LITEPE	:=	GdFieldGet("ZCY_LITEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LSTEPE	:=	GdFieldGet("ZCY_LSTEPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZCY->ZCY_LIREMS	:=	GdFieldGet("ZCY_LIREMS",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			EndIf
			ZCY->(MsUnlock())
		Next _nI

Return

User Function FG137LOK()

	Local _lRet	:=	.T.
	Local _nPosDel	:= Len(_oGetDados:aHeader)+1
	Local _nI

	For _nI	:= 1 To Len(_oGetDados:aCols)

		If _nI <> _oGetDados:nAt .And.; 
		GdFieldGet("ZCY_LINHA",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZCY_LINHA",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And. ;
		GdFieldGet("ZCY_DESFOR",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZCY_DESFOR",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And. ;
		GdFieldGet("ZCY_TIPOLO",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZCY_TIPOLO",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And.;
		!_oGetDados:aCols[_nI,_nPosDel]

			MsgInfo("Dados já Cadastrados para Linha x Formato x Tipologia!")
			_lRet	:=	.F.
		EndIf
	Next

Return _lRet