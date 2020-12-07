#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG005
@author Gabriel Rossi Mafioletti
@since 05/06/2017
@version 1.0
@description Cadastro de Meta de Caco
@type function
/*/

User function BIAFG005()

	Local aArea       := GetArea()

	Local oBrowse     := nil
	private aRotina   := MenuDef()
	private cCadastro := "Meta de Caco"    


	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZ6')
	oBrowse:SetDescription(cCadastro)
	oBrowse:SetOnlyFields({'ZZ6_COD','ZZ6_DESC'})
	oBrowse:SetFilterDefault( "ZZ6_MSBLQL != '1'" )
	oBrowse:Activate()


	RestArea(aArea)

Return


// funcao para o menu                                 
Static Function MenuDef()

	local aRotina := {} 
	aRotina := {{"Pesquisar"   	,"AxPesqui"   , 0, 1},;     
	{            "Visualizar"  	,"U_BIAFG5ME" , 0, 2},; 
	{            "Alterar"		,"U_BIAFG5ME" , 0, 4}}
	

return aRotina

User Function BIAFG5ME(cAlias,nReg,nOpc)
	fMontaTela(cAlias,nReg,nOpc)  
return  

//Monta Tela
Static Function fMontaTela(cAlias,nReg,nOpc)
	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}

	Local _nOpca	:= 0 
	
	Local nOpcGd	:= Iif(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
	     
	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	Local _cForm		:=	ZZ6->ZZ6_COD
	Local _cDesForm	:=	ZZ6->ZZ6_DESC
	
	Local _aHeader	:=	{}			          
	Local _aCols	:=	{}			
	
	Local cSeek	:=	xFilial("Z93") + ZZ6->ZZ6_COD
	Local bWhile	:=	{|| Z93_FILIAL + Z93_FORMAT}	
	
	FillGetDados(4,"Z93",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)
	
	Private _oGetDados	:=	Nil    

	_aSize := MsAdvSize(.T.)
	
	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })                      

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	
	
	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )
	
	Define MsDialog _oDlg Title "Cadastro de Metas de Caco" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel
	
		@ 010,010 SAY "Formato:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
		@ 008,047 MSGET _cForm  SIZE 17, 11 OF _oDlg PIXEL WHEN .F.
	
		@ 010,070 SAY "Descricão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
		@ 008,110 MSGET _cDesForm  SIZE 100, 11 OF _oDlg PIXEL WHEN .F.
	

		_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], nOpcGd, "U_BIAF5LOK" /*[ cLinhaOk]*/,"U_BIAF5TOK" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_BIAF5FOK"/*cFieldOK*/,"U_BIAF5SDE" /*[ cSuperDel]*/, "U_BIAF5DEL"/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	Activate MsDialog _oDlg Centered on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),_oDlg:End(),_nOpcA := 0)}, {|| _oDlg:End()})

	if nOpc > 2 .And. _nOpca > 0
		fGrvDados()
	EndIf

return


Static Function VldGets(_cForm)


Return .T.

Static Function MontaCols()

	Local _aCols	:=	{}
	
	DbSelectArea("Z93")
	Z93->(DbSetOrder(1))
	
	If Z93->(DbSeek(xFilial("Z93")+ZZ6->ZZ6_COD))
		While xFilial("Z93") + ZZ6->ZZ6_COD == Z93->(Z93_FILIAL+Z93_FORMAT)
			Z93->(aAdd(_aCols,{Z93_DATADE,Z93_DATAAT,Z93_PERMET,.F.}))
			Z93->(DbSkip())
		EndDo
	endIf

Return _aCols


User Function BIAF5SDE()

Return .T.


User Function BIAF5DEL()


Return .T.

User Function BIAF5FOK()

	Local cMenVar   := ReadVar()
	Local _nI
	Local _lRet		:=	.T.
	Local _nAt		:=	_oGetDados:nAt
	Local _nPosDel	:=	Len(_oGetDados:aHeader)+1
	
	
	If cMenVar == "M->Z93_DATAAT" .Or. cMenVar == "M->Z93_DATADE"   
		For _nI	:= 1 to Len(_oGetDados:aCols)
			If !_oGetDados:aCols[_nI,_nPosDel] .And. _nI <> _nAt  .And. ((&(cMenvar) >= GdFieldGet("Z93_DATADE",_nI) .And. &(cMenvar) <= GdFieldGet("Z93_DATAAT",_nI)) )
				MsgInfo("Faixa de Data da Meta já Cadastrada!")
				Return .F.
			EndIf  
		Next
		If (cMenVar == "M->Z93_DATAAT" .And. &(cMenvar) < GdFieldGet("Z93_DATADE",_nAt)) .Or. (cMenVar == "M->Z93_DATADE" .And. &(cMenvar) > GdFieldGet("Z93_DATAAT",_nAt) .And. !Empty(GdFieldGet("Z93_DATAAT",_nAt)) )
			MsGInfo("A Data de Início não Pode ser Maior que a Data Fim")
			return .F.
		EndIf
	EndIf
	
Return	_lRet

//Grid - Tudo OK
User Function BIAF5TOK(oGd)

	local nx   := 0
	local lRet := .T.
	Local _nPosDel	:=	Len(_oGetDados:aHeader)+1
	
	For nx:=1 to Len(_oGetDados:aCols)
		if !_oGetDados:aCols[nx,_nPosDel]
			lRet := U_BIAF5LOK(oGd,nx)
			if !lRet
				Exit
			endif 
		endif	
	Next nx

Return lRet

//Grid - Linha OK
User Function BIAF5LOK(oGd,nLinha)

	local lRet			:= .T.
	local nPosDtDe	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z93_DATADE"})
	local nPosDtAt	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z93_DATAAT"})
	Local _nPosDel	:=	Len(_oGetDados:aHeader)+1
	
	
	Local _nI
	default nLinha	:=	_oGetDados:nAt	

	For _nI	:= 1 to Len(_oGetDados:aCols)
	
		If !_oGetDados:aCols[_nI,_nPosDel] .And. _nI <> nLinha .And. ((_oGetDados:aCols[nLinha,nPosDtDe] >= _oGetDados:aCols[_nI,nPosDtDe] .And. _oGetDados:aCols[nLinha,nPosDtDe] <= _oGetDados:aCols[_nI,nPosDtAt] ) .Or. ;
		(_oGetDados:aCols[nLinha,nPosDtAt] >= _oGetDados:aCols[_nI,nPosDtDe] .And. _oGetDados:aCols[nLinha,nPosDtAt] <= _oGetDados:aCols[_nI,nPosDtAt] ))
		
			MsgInfo("Faixa de Data da Meta já Cadastrada!")
					Return .F.
		
		EndIf

	Next
Return lRet


Static Function fGrvDados()

	Local _nI
	local nPosRec	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z93_REC_WT"})
	local nPosDtDe	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z93_DATADE"})
	local nPosDtAt	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z93_DATAAT"})
	local nPosMeta	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z93_PERMET"})
	Local _nPosDel	:=	Len(_oGetDados:aHeader)+1
	
	DbSelectArea('Z93')
	for _nI	:=	1 to Len(_oGetDados:aCols)
		If _oGetDados:aCols[_nI,nPosRec] > 0
			Z93->(DbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("Z93",.F.)
			If !_oGetDados:aCols[_nI,_nPosDel]
				Z93->Z93_DATADE	:=	_oGetDados:aCols[_nI,nPosDtDe]
				Z93->Z93_DATAAT	:=	_oGetDados:aCols[_nI,nPosDtAT]
				Z93->Z93_PERMET	:=	_oGetDados:aCols[_nI,nPosMeta]
			Else
				Z93->(DbDelete())
			EndIf
			Z93->(MsUnlock())
		Else
			Reclock("Z93",.T.)
			Z93->Z93_FILIAL	:=	xFilial("Z93")
			Z93->Z93_FORMAT	:=	ZZ6->ZZ6_COD
			Z93->Z93_DATADE	:=	_oGetDados:aCols[_nI,nPosDtDe]
			Z93->Z93_DATAAT	:=	_oGetDados:aCols[_nI,nPosDtAT]
			Z93->Z93_PERMET	:=	_oGetDados:aCols[_nI,nPosMeta]
			Z93->(MsUnlock())			
		EndIf
	next

Return