#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG092
@author Gabriel Rossi Mafioletti
@since 28/05/2019
@version 1.0
@description Cadastro de Aprovadores de Pré-Requisição
@type function
/*/

User Function BIAFG092()

	Local oBrowse := NIL

	DbSelectArea('ZE5')

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('ZE5')
	oBrowse:SetDescription('Cadastro de Aprovadores de Pré-Requisição ')

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar', 'U_BFG92PRI', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir', 	'U_BFG92PRI', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'U_BFG92PRI', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 'U_BFG92PRI', 0, 5, 0, NIL } )


Return aRotina

User Function BFG92PRI(cAlias,nReg,nOpc)

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
	Local bWhile	:=	{|| ZE5_FILIAL + ZE5_IDBIZ }

	_aSize := MsAdvSize(.T.) //Sem Enchoice

	Private nOpca := nOpc
	Private VISUAL :=  nOpca == 2
	Private INCLUI :=  nOpca == 3
	Private ALTERA :=  nOpca == 4

	Private _oGd
	Private _oEnch

	Private _cNome	:=	Iif(INCLUI,SPACE(60),ZE5->ZE5_NOME)
	Private _cEmail	:=	Iif(INCLUI,Space(60),ZE5->ZE5_EMAIL)
	Private _cCodBiz	:=	Iif(INCLUI,Space(9),ZE5->ZE5_IDBIZ)


	cSeek	:=	xFilial("ZE5") + _cCodBiz

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 0, 0}	


	AAdd(_aObjects, {100, 20, .T. , .T. })
	AAdd(_aObjects, {100, 80, .T. , .T. })


	FillGetDados(nOpc,"ZE5",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	DEFINE MSDIALOG _oDlg TITLE "Cadastro de Aprovadores de Pré-Requisição" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL

	@ _aposObj[1,1]+10, _aposObj[1,2] SAY "Nome.:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aposObj[1,1]+7, _aposObj[1,2] + 35 MSGET _oGetNome VAR _cNome  SIZE 200, 11 OF _oDlg PIXEL WHEN INCLUI

	@ _aposObj[1,1]+30, _aposObj[1,2] SAY "E-Mail.:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aposObj[1,1]+27, _aposObj[1,2] + 35 MSGET _oGetMail VAR _cEmail  SIZE 200, 11 OF _oDlg PIXEL WHEN INCLUI

	@ _aposObj[1,1]+50, _aposObj[1,2] SAY "Código.:" SIZE 55, 11 OF _oDlg PIXEL  FONT oFont 
	@ _aposObj[1,1]+47, _aposObj[1,2] + 35 MSGET _oGetCod VAR _cCodBiz  SIZE 60, 11 OF _oDlg PIXEL WHEN INCLUI F3 "ZAPROV" VALID U_BFG92FOK()

	@ _aPosObj[2][1], _aPosObj[2][2] GROUP oGpMRP1 TO _aPosObj[2][3], _aPosObj[2][4] PROMPT "Aprovações..." OF _oDlg COLOR 0, 16777215 PIXEL


	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], IF(INCLUI .OR. ALTERA,GD_UPDATE+GD_INSERT+GD_DELETE,0), "U_BFG92LOK()"/*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/,999 /*[ nMax]*/, "U_BFG92FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOk := 1, If(_oGetDados:TudoOk(), _oDlg:End(),_nOk := 0)}, {|| _oDlg:End()})

	If _nOk == 1 .And. nOpcA >= 3 .And. nOpca <= 5 
		fGrava(nOpcA)
	EndIf

Return

User Function BFG92FOK()

	Local _cCpo	:=	ReadVar()
	Local _lRet	:=	.T.
	Local _aArea	:=	GetArea()


	IF Alltrim(_cCpo) == "M->ZE5_CLVL"
		GdFieldPut("ZE5_DESCLA",Posicione("CTH",1,xFilial("CTH")+M->ZE5_CLVL,"CTH_DESC01"),_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:Acols,.F.)
	EndIf

	IF Alltrim(_cCpo) == "M->ZE5_CONTA"
		GdFieldPut("ZE5_DESCCT",Posicione("CT1",1,xFilial("CT1")+M->ZE5_CONTA,"CT1_DESC01"),_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:Acols,.F.)
	EndIf

	IF Alltrim(_cCpo) == "_CCODBIZ"
		DbSelectArea("ZE5")
		ZE5->(DbSetOrder(1))
		If ZE5->(DBSeek(xFilial("ZE5")+_cCodBiz))
			MsgInfo("Id do Bizagi já atribuído a outro usuário")
			_lRet	:=	.F.
		EndIf
	EndIf

	RestArea(_aArea)
Return _lRet

Static Function fGrava(nOpcA)

	local nPosRec	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZE5_REC_WT"})
	Local _nPosDel	:= Len(_oGetDados:aHeader)+1
	Local _nI

	DbSelectArea("ZE5")
	ZE5->(DbSetOrder(1))

	If nOpcA == 5
		If ZE5->(DbSeek(xFilial("ZE5")+_cCodBiz))
			While ZE5->(!EOF()) .And. xFilial("ZE5")+_cCodBiz == ZE5->(ZE5_FILIAL+ZE5_IDBIZ)
				Reclock("ZE5",.F.)
				ZE5->(DbDelete())
				ZE5->(MsUnlock())
				ZE5->(DbSkip())
			EndDo
		EndIf
	Else
		For _nI	:=	1 to Len(_oGetDados:aCols)
			If _oGetDados:aCols[_nI,nPosRec] == 0 .And. _oGetDados:aCols[_nI,_nPosDel] 
				Loop
			ElseIf _oGetDados:aCols[_nI,nPosRec] == 0 
				Reclock("ZE5",.T.)
				ZE5->ZE5_FILIAL	:=	xFilial("ZE5")
				ZE5->ZE5_NOME	:=	_cNome
				ZE5->ZE5_EMAIL	:=	_cEmail
				ZE5->ZE5_IDBIZ	:=	_cCodBiz
			Else
				ZE5->(DbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZE5",.F.)
			EndIf

			If _oGetDados:aCols[_nI,_nPosDel] .And. _oGetDados:aCols[_nI,nPosRec] > 0
				ZE5->(DbDelete())
			Else
				ZE5->ZE5_CLVL	:=	GdFieldGet("ZE5_CLVL",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZE5->ZE5_DESCLA	:=	GdFieldGet("ZE5_DESCLA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZE5->ZE5_CONTA	:=	GdFieldGet("ZE5_CONTA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZE5->ZE5_DESCCT	:=	GdFieldGet("ZE5_DESCCT",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZE5->ZE5_APLIC	:=	GdFieldGet("ZE5_APLIC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)				
			EndIf
			ZE5->(MsUnlock())
		Next _nI
	EndIf

Return

User Function BFG92LOK()

	Local _lRet	:=	.T.
	Local _nPosDel	:= Len(_oGetDados:aHeader)+1
	Local _nI

	For _nI	:= 1 To Len(_oGetDados:aCols)

		If _nI <> _oGetDados:nAt .And.; 
		GdFieldGet("ZE5_CLVL",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZE5_CLVL",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And. ;
		GdFieldGet("ZE5_CONTA",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZE5_CONTA",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And. ;
		GdFieldGet("ZE5_APLIC",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZE5_APLIC",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And.;
		!_oGetDados:aCols[_nI,_nPosDel]

			MsgInfo("Dados já Cadastrados para o Aprovador Atual!")
			_lRet	:=	.F.
		EndIf
	Next

Return _lRet