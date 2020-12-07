#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG086
@author Gabriel Rossi Mafioletti
@since 13/05/2019
@version 1.0
@description Cadastro de CST para Simples Nacional
@type function
/*/

User Function BIAFG086()

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}
	
	Local _aHeader		:=	{}          
	Local _aCols		:=	{}
	
	Local _aHForm		:=	{}
	Local _aCForm		:=	{}

	Local cSeek	:=	xFilial("ZE2") + "1"
	Local bWhile	:=	{|| ZE2_FILIAL + ZE2_TIPO }   
	
	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	
	Local _aItens	:=	{;
						"1=PIS/COFINS",;
						"2=Ativo",;
						"3=CIAP",;
						"4=Difal",;
						"5=Cred. ICMS",;
						"6=Cred. IPI";
						}
	
	Local _cCbOper	:=	"IG=Igual;MA=Maior Igual;ME=Menor Igual;DF=Diferente De"
	
	Local _cOpLog	:=	".And.=E;.Or.=Ou"
	
	Local _cCbCampo	:=	"@@CLASSIF@@=Classificação;@@GRUPO@@=Grupo;@@ATRIB@@=Atributo;@@ESTOQUE@@=Estoque;@@FINANC@@=Financeiro;@@ICMS@@=ICMS;"
	_cCbCampo +=		"@@ATIVO@@=Ativo;@@CFOP@@=CFOP;@@UF@@=UF;@@TIPO@@=Tipo;@@IPI@@=IPI"
						
	
	
	
	Private _oDlg
	Private _oGetDados	:= Nil    
	
	Private _cCondic		:=	"1"
	
	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
//	AAdd(_aObjects, {100, 30, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZE2",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)
	
	
	If Len(_aCols) == 1
		_aCols[1,1] := "01"
	EndIf
	
	aAdd(_aHForm,{"Campo"         ,"CAMPO" ,"@!"               , 15   , 0,,, "C",,,_cCbCampo })      	// 1
	aAdd(_aHForm,{"Operador"      ,"OPERA" ,"@!"               , 15   , 0,,, "C",,,_cCbOper })      	// 1
	aAdd(_aHForm,{"Valor"	      ,"VALOR" ,"@!"               , 15   , 0,,, "C",,, })      	// 1
	aAdd(_aHForm,{"Op. Logica"     ,"LOGIC" ,"@!"               , 15   , 0,,, "C",,,_cOpLog })      	// 1
	
	
	Define MsDialog _oDlg Title "Condicionantes para Créditos" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ _aposObj[1,1]+3, _aposObj[1,2] SAY "Condic.:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aposObj[1,1], _aposObj[1,2] + 40 MSCOMBOBOX oComboBo1 VAR _cCondic ITEMS _aItens SIZE 055, 010 OF _oDlg COLORS 0, 16777215 PIXEL VALID U_BFG86CHG()
	
	//@ 048,040 MSGET _oGCracha VAR _cCracha  SIZE 50, 11 OF _oDlg PIXEL VALID fRetCracha()

	@ _aPosObj[2][1], _aPosObj[2][2] GROUP oGpMRP1 TO _aPosObj[2][3], _aPosObj[2][4] PROMPT "Fórmula..." OF _oDlg COLOR 0, 16777215 PIXEL
	
	//_oGdForm := MsNewGetDados():New(_aPosObj[2,1]+10, _aPosObj[2,2]+5, _aPosObj[2,3]-5, _aPosObj[2,4]/3, GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/,/*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_BFG86VL1()"/*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHForm, _aCForm)

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE+GD_INSERT+GD_DELETE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/,"+ZE2_SEQUEN" /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()}) 
	
Return


User Function BFG86CHG()

Local _aCols	:=	{}
Local _aHeader	:=	{}

Local cSeek	:=	xFilial("ZE2") + _cCondic
Local bWhile	:=	{|| ZE2_FILIAL + ZE2_TIPO }

FillGetDados(4,"ZE2",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

_oGetDados:aCols	:=	_aCols

_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI
	Local _nJ

	local nPosRec	    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZE2_REC_WT"})
	local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	DbSelectArea('ZE2')
	for _nI	:=	1 to Len(_oGetDados:aCols)
		If _oGetDados:aCols[_nI,nPosRec] > 0
			ZE2->(DbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZE2",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]
				For _nJ	:=	1 to Len(_oGetDados:aHeader)
					If _oGetDados:aHeader[_nJ][10] == "R"
						&("ZE2->" + Alltrim(_oGetDados:aHeader[_nJ][2])) := _oGetDados:aCols[_nI, _nJ]
					EndIf
				Next
			Else
				ZE2->(DbDelete())
			EndIf
			ZE2->(MsUnlock())
		ElseIf !_oGetDados:aCols[_nI,nPosDel]
			Reclock("ZE2",.T.)
			ZE2->ZE2_FILIAL:=	xFilial("ZE2")
			ZE2->ZE2_TIPO	:=	_cCondic
			For _nJ	:=	1 to Len(_oGetDados:aHeader)
				If _oGetDados:aHeader[_nJ][10] == "R"
					&("ZE2->" + Alltrim(_oGetDados:aHeader[_nJ][2])) := _oGetDados:aCols[_nI, _nJ]
				EndIf
			Next

			ZE2->(MsUnlock())			
		EndIf
	next

	MsgInfo("Dados Gravados com Sucesso!")
	
	U_BFG86CHG()

	

Return

User Function BFG86VL1()

	Local _cCpo	:=	ReadVar()
	Local _cCbox	:=	""
	Local _aArea	:=	GetArea()
	
	Local _aCols	:=	_oGdForm:aCols
	Local _aHeader	:=	_oGdForm:aHeader

	DbSelectArea("SD3")
	SX3->(DbSetOrder(2))
	If _cCpo	==	"M->CAMPO"
	
		Do Case
		
			Case M->CAMPO == "@@CLASSIF@@"
				If SX3->(DbSeek("BM_YCLASSI"))
					_cCbox	:=	x3Cbox()
				EndIf
			Case M->CAMPO == "@@ATRIB@@"
				_cCbox	:=	"C=Credito;D=Debito"
			Case M->CAMPO == "@@ESTOQUE@@"
				_cCbox	:=	"1=Sim;2=Não"
		End Case
	
		_oGdForm:aCols[1,3]	:=	Space(15)
		_oGdForm:aHeader[3,11]	:=	_cCbox
		_oGdForm:aInfo[3,2]	:=	_cCbox
	EndIf
	
	
	
	
	_oGdForm:ForceRefresh()
	
	/*
		Local _cCbCampo	:=	"@@CLASSIF@@=Classificação;@@GRUPO@@=Grupo;@@ATRIB@@=Atributo;@@ESTOQUE@@=Estoque;@@FINANC@@=Financeiro;@@ICMS@@=ICMS;"
	_cCbCampo +=		"@@ATIVO@@=Ativo;@@CFOP@@=CFOP;@@UF@@=UF;@@TIPO@@=Tipo;@@IPI@@=IPI"
	*/
	RestArea(_aArea)
Return .T.