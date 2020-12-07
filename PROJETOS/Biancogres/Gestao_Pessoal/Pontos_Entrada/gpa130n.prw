#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} BIA687
@author Marcos Alberto Soprani
@since 04/08/16
@version 1.0
@description Relação dos valores de PIS para distinção pela Area de Livre Comercio
@obs OS: 2820-16 - Tania
@type function
/*/

User Function GPA130MN()

	Local aRotina 	:= ParamIXB[1]
	Local aSubMenu
	Local aUserMenu 

	aSubMenu := 	{{ "Mapa de Vale Transp" , "U_BIA688(0)", 0, 2} }

	aUserMenu :=	{ 'Específicos'       ,aSubMenu    , 0 , 2} 

	AADD(aRotina, aUserMenu)

Return aClone(aRotina)
