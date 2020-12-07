#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG029
@author Gabriel Rossi Mafioletti
@since 15/01/2018
@version 1.0
@description Tela para cadastro de Estado x Transportadora
@type function
/*/

User Function BIAFG029()

	Local oBrowse := NIL

	DbSelectArea('SX5')

	Set Filter To X5_TABELA == '12'

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('SX5')
	oBrowse:SetDescription('Cadastro de Estado X Transportadora ')
	oBrowse:SetOnlyFields({"X5_CHAVE","X5_DESCRI"})

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar', 'U_BFG029A', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'U_BFG029A', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Imprimir'  , 'U_BFG029A', 0, 8, 0, NIL } )

Return aRotina

User Function BFG029A(cAlias,nReg,nOpc)

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}

	Local _nOpca	:= 0 

	Local nOpcGd	:= Iif(nOpc == 2 , 0, GD_INSERT + GD_UPDATE + GD_DELETE)

	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	Local _cUF		:=	SX5->X5_CHAVE
	Local _cDescUF	:=	SX5->X5_DESCRI

	Local _aHeader	:=	{}			          
	Local _aCols	:=	{}			

	Local cSeek	:=	xFilial("ZC4") + PADR(SX5->X5_CHAVE,2)
	Local bWhile	:=	{|| ZC4_FILIAL + ZC4_ESTADO}	

	FillGetDados(4,"ZC4",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

	Private _oGetDados	:=	Nil    

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 5, .T. , .T. })
	AAdd(_aObjects, {100, 95, .T. , .T. })                      

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	Define MsDialog _oDlg Title "Cadastro de Estado X Transportadora" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ _aPosObj[1,1],010 SAY "ESTADO: " + _cDescUF SIZE 200, 11 OF _oDlg PIXEL FONT oFont
	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], nOpcGd, /*[ cLinhaOk]*/,/*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_BFG29FOK"/*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	fpopGd()

	Activate MsDialog _oDlg Centered on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),_oDlg:End(),_nOpcA := 0)}, {|| _oDlg:End()})

	if nOpc > 2 .And. _nOpca > 0
		fGrvDados()
	EndIf

Return

User Function BFG29FOK(nLin)

	Local cMenVar     := ReadVar()
	Local _nI
	Local _nPosDel	  := Len(_oGetDados:aHeader) + 1
	Local _nPosTrans  := aScan(_oGetDados:aHeader,{|x| Alltrim(x[2])=="ZC4_TRANSP"})
	Local _nPosDesc   := aScan(_oGetDados:aHeader,{|x| Alltrim(x[2])=="ZC4_DESCRI"})
	Local _cCodTran   := ""

	Default nLin	:= _oGetDados:nAt

	_cCodTran	:=	IIf(cMenVar	== "M->ZC4_TRANSP",M->ZC4_TRANSP,_oGetDados:aCols[nLin][_nPosTrans])

	For _nI	:= 1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,_nPosTrans] == _cCodTran .And. _nI <> nLin
			MsgInfo("Transportadora " + _cCodTran +" já incluída para o estado!")
			Return .F.
		EndIf
	Next

	DbSelectArea("SA4")
	SA4->(DbSetOrder(1))
	If SA4->(DbSeek(xFilial("SA4")+_cCodTran)) .And. SA4->A4_MSBLQL <> '1'
		_oGetDados:aCols[nLin,_nPosDesc] := SA4->A4_NOME
	ElseIf SA4->A4_MSBLQL == '1'
		MsgInfo("Registro Bloqueado para Uso!")
	Else	
		MsgInfo("Transportadora "+ _cCodTran + " não cadastrada!")
	EndIf

Return .T.

Static Function fGrvDados()

	Local _nI
	local nPosRec	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC4_REC_WT"})
	local nPosTrans	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC4_TRANSP"})
	Local nTCRGFC	:= aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "ZC4_TCRGFC"})
	Local nTCRGFR	:= aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "ZC4_TCRGFR"})
	Local _nPosDel	:= Len(_oGetDados:aHeader)+1

	DbSelectArea('ZC4')
	for _nI	:=	1 to Len(_oGetDados:aCols)
		If _oGetDados:aCols[_nI,nPosRec] > 0
			ZC4->(DbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZC4",.F.)
			If !_oGetDados:aCols[_nI,_nPosDel]
				ZC4->ZC4_TRANSP	:=	_oGetDados:aCols[_nI,nPosTrans]
				ZC4->ZC4_TCRGFC	:=	_oGetDados:aCols[_nI,nTCRGFC]
				ZC4->ZC4_TCRGFR	:=	_oGetDados:aCols[_nI,nTCRGFR]
			Else
				ZC4->(DbDelete())
			EndIf
			ZC4->(MsUnlock())
		Else
			Reclock("ZC4",.T.)
			ZC4->ZC4_FILIAL	:=	xFilial("ZC4")
			ZC4->ZC4_ESTADO	:=	SX5->X5_CHAVE
			ZC4->ZC4_TRANSP	:=	_oGetDados:aCols[_nI,nPosTrans]
			ZC4->ZC4_TCRGFC	:=	_oGetDados:aCols[_nI,nTCRGFC]
			ZC4->ZC4_TCRGFR	:=	_oGetDados:aCols[_nI,nTCRGFR]
			ZC4->(MsUnlock())			
		EndIf
	next

Return

Static Function fpopGd()

	Local _nI
	Local _nPosDesc		:= aScan(_oGetDados:aHeader,{|x| Alltrim(x[2])=="ZC4_DESCRI"})
	Local _nPosTrans	:= aScan(_oGetDados:aHeader,{|x| Alltrim(x[2])=="ZC4_TRANSP"})

	For _nI	:= 1 to Len(_oGetDados:aCols)

		_oGetDados:aCols[_nI,_nPosDesc]	:=	POSICIONE("SA4",1,xFilial("SA4") + _oGetDados:aCols[_nI,_nPosTrans], "A4_NOME")

	Next

Return
