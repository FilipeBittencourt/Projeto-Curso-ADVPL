#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG007
@author Gabriel Rossi Mafioletti
@since 06/06/2017
@version 1.0
@description Tela para Visualização de Log do Cockpit de Compras
@type function
/*/

User function BIAFG007()

	Local nOpc		:=	2
	Local nOpcGd	:=	0

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}
	
	Local _aHeader		:=	{}
	Local _aCols		:=	{}
	
	Local cSeek	:=	xFilial("Z09") + Z08->Z08_NUMPRC
	Local bWhile	:=	{|| Z09_FILIAL + Z09_NUMPRC}	
	
	Local aCpos	:=	GetCpoZ08()
	
	Private aTELA[0][0]
	Private aGETS[0]
	
	FillGetDados(nOpc,"Z09",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)
	
	_aSize := MsAdvSize(.T.)
	
	AAdd(_aObjects, {100, 20, .T. , .T. })
	AAdd(_aObjects, {100, 80, .T. , .T. })                      

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	
	
	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )
	
	RegToMemory("Z08",.F.)
	
	Define MsDialog _oDlg Title "Visualizar" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

		oCab := MsMGet():New('Z08', Z08->(Recno()),nOpc,,,,aCpos,{_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,4], _aPosObj[1,3]},,,,,,_oDlg)
		
		oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], nOpcGd, /*[ cLinhaOk]*/,/*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, /*cFieldOK*/,/*[ cSuperDel]*/, /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	Activate MsDialog _oDlg Centered on Init EnchoiceBar(_oDlg, {||_oDlg:End()}, {|| _oDlg:End()})

return


Static Function GetCpoZ08()

	Local _aCpos	:=	{}

	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	
	If SX3->(DbSeek("Z08"))
		While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "Z08"
			If X3USO(SX3->X3_CAMPO)
				aAdd(_aCpos,SX3->X3_CAMPO)
			EndIf
			SX3->(DbSkip())
		EndDo
	EndIF
Return _aCpos