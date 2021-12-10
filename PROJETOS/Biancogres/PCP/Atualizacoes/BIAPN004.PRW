#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAPN004
@author Pablo Simões Nascimento
@since 14/09/2021
@version 1.0
@description Cadastro de Valores Padrões para o Formulário de Prensa 2
@type function
/*/

User Function BIAPN004()
	
	// AxCadastro("ZP1", 'Cadastro de Valores Padrões para o Formulário de Prensa 2')

	Local oBrowse := NIL

	DbSelectArea('ZP1')

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('ZP1')
	oBrowse:SetDescription('Cadastro de Valores Padrões para o Formulário de Prensa 2')

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar', 'U_BPN004PR', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'U_BPN004PR', 0, 4, 0, NIL } )

Return aRotina

User Function BPN004PR(cAlias,nReg,nOpc)

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
	Local bWhile	:=	{|| ZP1_FILIAL }

	_aSize := MsAdvSize(.T.) //Sem Enchoice

	Private nOpca := nOpc
	Private VISUAL :=  nOpca == 2
	Private INCLUI :=  nOpca == 3
	Private ALTERA :=  nOpca == 4

	Private _oGd
	Private _oEnch


	cSeek	:=	xFilial("ZP1")

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 0, 0}	


	AAdd(_aObjects, {100, 100, .T. , .T. })

	FillGetDados(4,"ZP1",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	DEFINE MSDIALOG _oDlg TITLE "Valores Padrões para o Formulário de Prensa 2" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL

	_oGetDados := MsNewGetDados():New(_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4], IF(INCLUI .OR. ALTERA,GD_INSERT+GD_UPDATE,0), "U_PN004FOK()"/*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/,999 /*[ nMax]*/, "U_PN004FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOk := 1, If(_oGetDados:TudoOk(), _oDlg:End(),_nOk := 0)}, {|| _oDlg:End()})

	If _nOk == 1 .And. nOpcA >= 3 .And. nOpca <= 5 
		fGrava(nOpcA)
	EndIf

Return

User Function PN004FOK()

	Local _cCpo	:=	ReadVar()
	Local _lRet	:=	.T.
	local nPosRec	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZP1_REC_WT"})

	Local _aArea	:=	GetArea()

	If Alltrim(_cCpo) $ "M->ZP1_LINHA/M->ZP1_FORMAT/M->ZP1_TIPOLO" .And. _oGetDados:aCols[_oGetDados:nAt,nPosRec] > 0
		MsgInfo("Não é possível alterar os dados já gravados(Linha,Formato e Tipologia)")
		_lRet	:=	.F.
	EndIf
	RestArea(_aArea)
Return _lRet

Static Function fGrava(nOpcA)

	local nPosRec	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZP1_REC_WT"})
	Local _nPosDel	:= Len(_oGetDados:aHeader)+1
	Local _nI

	DbSelectArea("ZP1")
	ZP1->(DbSetOrder(1))

		For _nI	:=	1 to Len(_oGetDados:aCols)
			If _oGetDados:aCols[_nI,nPosRec] == 0 .And. _oGetDados:aCols[_nI,_nPosDel] 
				Loop
			ElseIf _oGetDados:aCols[_nI,nPosRec] == 0 
				Reclock("ZP1",.T.)
					ZP1->ZP1_FILIAL		:=	xFilial("ZP1")
					ZP1->ZP1_LINHA		:=	GdFieldGet("ZP1_LINHA" ,_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_FORMAT		:=	GdFieldGet("ZP1_FORMAT",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_TIPOLO		:=	GdFieldGet("ZP1_TIPOLO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIUMMA 	:=	GdFieldGet("ZP1_LIUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSUMMA 	:=	GdFieldGet("ZP1_LSUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIPESA 	:=	GdFieldGet("ZP1_LIPESA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSPESA 	:=	GdFieldGet("ZP1_LSPESA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIPESB 	:=	GdFieldGet("ZP1_LIPESB",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSPESB 	:=	GdFieldGet("ZP1_LSPESB",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIPESC 	:=	GdFieldGet("ZP1_LIPESC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSPESC 	:=	GdFieldGet("ZP1_LSPESC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIPESD 	:=	GdFieldGet("ZP1_LIPESD",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSPESD 	:=	GdFieldGet("ZP1_LSPESD",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIUMRE 	:=	GdFieldGet("ZP1_LIUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSUMRE 	:=	GdFieldGet("ZP1_LSUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITMPP 	:=	GdFieldGet("ZP1_LITMPP",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTMPP 	:=	GdFieldGet("ZP1_LSTMPP",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIESPE 	:=	GdFieldGet("ZP1_LIESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSESPE 	:=	GdFieldGet("ZP1_LSESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIRESM 	:=	GdFieldGet("ZP1_LIRESM",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSRESM 	:=	GdFieldGet("ZP1_LSRESM",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIPESO 	:=	GdFieldGet("ZP1_LIPESO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSPESO 	:=	GdFieldGet("ZP1_LSPESO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIDIFA 	:=	GdFieldGet("ZP1_LIDIFA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSDIFA 	:=	GdFieldGet("ZP1_LSDIFA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIDILA 	:=	GdFieldGet("ZP1_LIDILA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSDILA 	:=	GdFieldGet("ZP1_LSDILA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)

					ZP1->ZP1_LITQ1  	:=	GdFieldGet("ZP1_LITQ1",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ1  	:=	GdFieldGet("ZP1_LSTQ1",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ2  	:=	GdFieldGet("ZP1_LITQ2",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ2  	:=	GdFieldGet("ZP1_LSTQ2",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ3  	:=	GdFieldGet("ZP1_LITQ3",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ3  	:=	GdFieldGet("ZP1_LSTQ3",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ4  	:=	GdFieldGet("ZP1_LITQ4",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ4  	:=	GdFieldGet("ZP1_LSTQ4",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ5  	:=	GdFieldGet("ZP1_LITQ5",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ5  	:=	GdFieldGet("ZP1_LSTQ5",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ6  	:=	GdFieldGet("ZP1_LITQ6",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ6  	:=	GdFieldGet("ZP1_LSTQ6",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ7  	:=	GdFieldGet("ZP1_LITQ7",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ7  	:=	GdFieldGet("ZP1_LSTQ7",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ8  	:=	GdFieldGet("ZP1_LITQ8",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ8  	:=	GdFieldGet("ZP1_LSTQ8",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ9  	:=	GdFieldGet("ZP1_LITQ9",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ9  	:=	GdFieldGet("ZP1_LSTQ9",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ10 	:=	GdFieldGet("ZP1_LITQ10",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ10 	:=	GdFieldGet("ZP1_LSTQ10",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ11 	:=	GdFieldGet("ZP1_LITQ11",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ11 	:=	GdFieldGet("ZP1_LSTQ11",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ12 	:=	GdFieldGet("ZP1_LITQ12",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ12 	:=	GdFieldGet("ZP1_LSTQ12",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ13 	:=	GdFieldGet("ZP1_LITQ13",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ13 	:=	GdFieldGet("ZP1_LSTQ13",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ14 	:=	GdFieldGet("ZP1_LITQ14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ14 	:=	GdFieldGet("ZP1_LSTQ14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ15 	:=	GdFieldGet("ZP1_LITQ15",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ15 	:=	GdFieldGet("ZP1_LSTQ15",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITQ16 	:=	GdFieldGet("ZP1_LITQ16",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTQ16 	:=	GdFieldGet("ZP1_LSTQ16",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LITREC 	:=	GdFieldGet("ZP1_LITREC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSTREC 	:=	GdFieldGet("ZP1_LSTREC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)

					ZP1->ZP1_LIGR14 	:=	GdFieldGet("ZP1_LIGR14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSGR14 	:=	GdFieldGet("ZP1_LSGR14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIGR25 	:=	GdFieldGet("ZP1_LIGR25",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSGR25 	:=	GdFieldGet("ZP1_LSGR25",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIGR40 	:=	GdFieldGet("ZP1_LIGR40",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSGR40 	:=	GdFieldGet("ZP1_LSGR40",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIGR60 	:=	GdFieldGet("ZP1_LIGR60",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSGR60 	:=	GdFieldGet("ZP1_LSGR60",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIGR80 	:=	GdFieldGet("ZP1_LIGR80",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSGR80 	:=	GdFieldGet("ZP1_LSGR80",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIG170 	:=	GdFieldGet("ZP1_LIG170",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSG170 	:=	GdFieldGet("ZP1_LSG170",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LIGRFU 	:=	GdFieldGet("ZP1_LIGRFU",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
					ZP1->ZP1_LSGRFU 	:=	GdFieldGet("ZP1_LSGRFU",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			
			Else
				ZP1->(DbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZP1",.F.)
			EndIf

			If _oGetDados:aCols[_nI,_nPosDel] .And. _oGetDados:aCols[_nI,nPosRec] > 0
				ZP1->(DbDelete())
			Else
				ZP1->ZP1_FILIAL		:=	xFilial("ZP1")
				ZP1->ZP1_LINHA		:=	GdFieldGet("ZP1_LINHA" ,_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_FORMAT		:=	GdFieldGet("ZP1_FORMAT",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_TIPOLO		:=	GdFieldGet("ZP1_TIPOLO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIUMMA 	:=	GdFieldGet("ZP1_LIUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSUMMA 	:=	GdFieldGet("ZP1_LSUMMA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIPESA 	:=	GdFieldGet("ZP1_LIPESA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSPESA 	:=	GdFieldGet("ZP1_LSPESA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIPESB 	:=	GdFieldGet("ZP1_LIPESB",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSPESB 	:=	GdFieldGet("ZP1_LSPESB",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIPESC 	:=	GdFieldGet("ZP1_LIPESC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSPESC 	:=	GdFieldGet("ZP1_LSPESC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIPESD 	:=	GdFieldGet("ZP1_LIPESD",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSPESD 	:=	GdFieldGet("ZP1_LSPESD",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIUMRE 	:=	GdFieldGet("ZP1_LIUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSUMRE 	:=	GdFieldGet("ZP1_LSUMRE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITMPP 	:=	GdFieldGet("ZP1_LITMPP",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTMPP 	:=	GdFieldGet("ZP1_LSTMPP",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIESPE 	:=	GdFieldGet("ZP1_LIESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSESPE 	:=	GdFieldGet("ZP1_LSESPE",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIRESM 	:=	GdFieldGet("ZP1_LIRESM",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSRESM 	:=	GdFieldGet("ZP1_LSRESM",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIPESO 	:=	GdFieldGet("ZP1_LIPESO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSPESO 	:=	GdFieldGet("ZP1_LSPESO",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIDIFA 	:=	GdFieldGet("ZP1_LIDIFA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSDIFA 	:=	GdFieldGet("ZP1_LSDIFA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIDILA 	:=	GdFieldGet("ZP1_LIDILA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSDILA 	:=	GdFieldGet("ZP1_LSDILA",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ1  	:=	GdFieldGet("ZP1_LITQ1",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ1  	:=	GdFieldGet("ZP1_LSTQ1",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ2  	:=	GdFieldGet("ZP1_LITQ2",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ2  	:=	GdFieldGet("ZP1_LSTQ2",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ3  	:=	GdFieldGet("ZP1_LITQ3",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ3  	:=	GdFieldGet("ZP1_LSTQ3",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ4  	:=	GdFieldGet("ZP1_LITQ4",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ4  	:=	GdFieldGet("ZP1_LSTQ4",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ5  	:=	GdFieldGet("ZP1_LITQ5",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ5  	:=	GdFieldGet("ZP1_LSTQ5",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ6  	:=	GdFieldGet("ZP1_LITQ6",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ6  	:=	GdFieldGet("ZP1_LSTQ6",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ7  	:=	GdFieldGet("ZP1_LITQ7",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ7  	:=	GdFieldGet("ZP1_LSTQ7",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ8  	:=	GdFieldGet("ZP1_LITQ8",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ8  	:=	GdFieldGet("ZP1_LSTQ8",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ9  	:=	GdFieldGet("ZP1_LITQ9",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ9  	:=	GdFieldGet("ZP1_LSTQ9",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ10 	:=	GdFieldGet("ZP1_LITQ10",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ10 	:=	GdFieldGet("ZP1_LSTQ10",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ11 	:=	GdFieldGet("ZP1_LITQ11",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ11 	:=	GdFieldGet("ZP1_LSTQ11",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ12 	:=	GdFieldGet("ZP1_LITQ12",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ12 	:=	GdFieldGet("ZP1_LSTQ12",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ13 	:=	GdFieldGet("ZP1_LITQ13",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ13 	:=	GdFieldGet("ZP1_LSTQ13",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ14 	:=	GdFieldGet("ZP1_LITQ14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ14 	:=	GdFieldGet("ZP1_LSTQ14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ15 	:=	GdFieldGet("ZP1_LITQ15",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ15 	:=	GdFieldGet("ZP1_LSTQ15",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITQ16 	:=	GdFieldGet("ZP1_LITQ16",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTQ16 	:=	GdFieldGet("ZP1_LSTQ16",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LITREC 	:=	GdFieldGet("ZP1_LITREC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSTREC 	:=	GdFieldGet("ZP1_LSTREC",_nI,,_oGetDados:aHeader,_oGetDados:aCols)

				ZP1->ZP1_LIGR14 	:=	GdFieldGet("ZP1_LIGR14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSGR14 	:=	GdFieldGet("ZP1_LSGR14",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIGR25 	:=	GdFieldGet("ZP1_LIGR25",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSGR25 	:=	GdFieldGet("ZP1_LSGR25",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIGR40 	:=	GdFieldGet("ZP1_LIGR40",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSGR40 	:=	GdFieldGet("ZP1_LSGR40",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIGR60 	:=	GdFieldGet("ZP1_LIGR60",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSGR60 	:=	GdFieldGet("ZP1_LSGR60",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIGR80 	:=	GdFieldGet("ZP1_LIGR80",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSGR80 	:=	GdFieldGet("ZP1_LSGR80",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIG170 	:=	GdFieldGet("ZP1_LIG170",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSG170 	:=	GdFieldGet("ZP1_LSG170",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LIGRFU 	:=	GdFieldGet("ZP1_LIGRFU",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
				ZP1->ZP1_LSGRFU 	:=	GdFieldGet("ZP1_LSGRFU",_nI,,_oGetDados:aHeader,_oGetDados:aCols)
			EndIf
			ZP1->(MsUnlock())
		Next _nI

Return

User Function PN004LOK()

	Local _lRet	:=	.T.
	Local _nPosDel	:= Len(_oGetDados:aHeader)+1
	Local _nI

	For _nI	:= 1 To Len(_oGetDados:aCols)

		If _nI <> _oGetDados:nAt .And.; 
		GdFieldGet("ZP1_LINHA",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZP1_LINHA",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And. ;
		GdFieldGet("ZP1_FORMAT",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZP1_FORMAT",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And. ;
		GdFieldGet("ZP1_TIPOLO",_nI,,_oGetDados:aHeader,_oGetDados:aCols) == GdFieldGet("ZP1_TIPOLO",_oGetDados:nAt,,_oGetDados:aHeader,_oGetDados:aCols) .And.;
		!_oGetDados:aCols[_nI,_nPosDel]

			MsgInfo("Dados já Cadastrados para Linha x Formato x Tipologia!")
			_lRet	:=	.F.
		EndIf
	Next

Return _lRet
