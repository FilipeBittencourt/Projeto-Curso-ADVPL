#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG125
@author Gabriel Rossi Mafioletti
@since 13/05/2020
@version 1.0
@description Interface da Rotina de Impressão de Etiquetas
@type function
/*/

User Function BIAFG125()
	//Thiago Haagensen - Ticket 24508 - Mantem a tela de parâmetros de impressão aberta.
	while ValidPerg()
		U_BIAFG124(MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR01,,MV_PAR05) // RETIRADO O MV_PAR05 DEPOIS DA ULTIMA VIRGULA, MARCOS AURELIO 17/11/2021
	enddo

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG125" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	
	
	MV_PAR01 :=	""
	MV_PAR02 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR03 := 0
	MV_PAR04 :=	Space(6)
	MV_PAR05 :=	"" // MARCOS AURELIO 22-11-2021
	
	aAdd( aPergs ,{2,"Impressoras "   ,MV_PAR01, fgetImps(), 100, "", .T.})
	aAdd( aPergs ,{1,"Produto " 	  ,MV_PAR02 ,""  ,"",'SB1'  ,'.T.',70,.T.})
	aAdd( aPergs ,{1,"Qtd. Etiq. " 	  ,MV_PAR03 ,"@E 999"  ,"",''  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Pedido " 		  ,MV_PAR04 ,""  ,"",'SC7'  ,'.T.',50,.F.})
	aAdd( aPergs ,{2,"Almoxarifado "  ,MV_PAR05, {"",'01=Bianco',"20=Incesa"}, 70, "", .T.}) //  MARCOS AURELIO 17/11/2021
	
	If ParamBox(aPergs ,"Impressão de Etiquetas",,,,,,,,cLoad,.T.,.T.)
	
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05) //  MARCOS AURELIO 17/11/2021
	
	EndIf
	
Return lRet


Static Function fGetImps()

	Local _cAlias	:=	GetNextAlias()

	Local _aRet		:=	{}

	BEGINSQL Alias _cAlias
	
		SELECT *
		FROM VW_BZ_IMPRESSORAS
		ORDER BY CODIGO
	
	EndSql

	While (_cAlias)->(!EOF())
		aAdd(_aRet,Alltrim((_cAlias)->CODIGO)+'='+Alltrim((_cAlias)->DESCRICAO))
		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())
Return _aRet
