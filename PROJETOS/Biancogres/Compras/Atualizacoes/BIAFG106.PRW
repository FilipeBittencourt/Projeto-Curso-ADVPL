#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG106
@author Gabriel Rossi Mafioletti
@since 27/08/2019
@version 1.0
@description Tela para gravação do número do RPV 
@type function
/*/

User Function BIAFG106()

	While !ValidPerg()
	EndDo

Return


Static Function ValidPerg()


	local lRet		:= .F.
	Local aPergs	:=	{}
	
	Local _xBkpMV01

	_xBkpMV01	:=	MV_PAR01

	MV_PAR01 := SPACE(50)


	aAdd( aPergs ,{1,"Número RPV " 		  	,MV_PAR01 ,""  ,"",''  ,'.T.',50,.F.})


	If ParamBox(aPergs ,"Gravação do RPV",,,,,,,,,.F.,.F.)

		lRet := .T.

		c_cNumRpv	:=	MV_PAR01

	EndIf
	
	
	MV_PAR01	:=	_xBkpMV01
	
Return lRet