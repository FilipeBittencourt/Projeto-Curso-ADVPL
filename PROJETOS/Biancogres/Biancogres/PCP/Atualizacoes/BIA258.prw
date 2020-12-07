#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA258
@author Marcos Alberto Soprani
@since 23/06/2016
@version 1.0
@description Browser para Cadastro do Controle de Umidade p/ Massa E Esmalte
@type function
/*/

User Function BIA258()

	Private cString := "Z02"

	If ValidPerg()

		_cLocDig	:=	MV_PAR01
		
		dbSelectArea("Z02")
		dbSetOrder(1)
	
		AxCadastro(cString, "Controle de Umidade", , )

	EndIf

Return


Static Function ValidPerg()

	local cLoad	    := "BIA258" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(2)
	


	aAdd( aPergs ,{1,"Almoxarifado" 		  	,MV_PAR01 ,""  ,"NAOVAZIO() .And. EXISTCPO('NNR')",'NNR'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Cadastro de Umidade de Amostra",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf
Return lRet
