#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG067
@author Gabriel Rossi Mafioletti
@since 27/09/2018
@version 1.0
@description Tela para Controlar parâmetros da rotina BIAFA004
@type function
/*/
User Function BIAFG067()

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YLIBSGG")
		CriarSX6("MV_YLIBSGG", 'L', 'Indica se a alteração das estruturas do SGG estão liberadas', ".F." )
	EndIf


	If ValidPerg()
	
		PutMv("MV_YLIBSGG",Iif(MV_PAR01,".T.",".F."))
	
	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG067" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	GetMV("MV_YLIBSGG")

	
	aAdd( aPergs ,{5,"Alt. Fora do Ano Orçamentario?"  		  	,MV_PAR01 ,100,"",	.F.})

	If ParamBox(aPergs ,"Controle de Alteração de Estruturas Orçamentárias",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

	EndIf
Return lRet