#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"


/*/{Protheus.doc} BIAFG021
@author Gabriel Rossi Mafioletti
@since 29/08/2017
@version 1.0
@description Tela para alterar Tag de Apontamento
@type function
/*/

User Function BIAFG021()

	If SD3->D3_EMISSAO <= GetMv("MV_ULMES")
		MsgStop("A Movimenta��o Selecionada Encontra-se em um Per�odo j� Fechado e, Portanto, n�o Poder� ter sua TAG Modificada!")
		Return
	EndIf

	If !ValidPerg()
		Return
	EndIf
	
	Reclock("SD3",.F.)
	SD3->D3_YTAG	:=	MV_PAR02
	SD3->D3_YOBS	:=	Alltrim(SD3->D3_YOBS) + " TAG " + AlltriM(MV_PAR01) + "->" + Alltrim(MV_PAR02)
	SD3->(MsUnlock())

Return

Static Function ValidPerg()

	local lRet		:= .F.
	Local _aRet		:=	{}
	Local aPergs	:=	{}

	MV_PAR01 := SD3->D3_YTAG
	MV_PAR02 := Space(TamsX3("D3_YTAG")[1])

	aAdd( aPergs ,{1,"Tag Atual " 	   		,MV_PAR01 ,PesqPict("SD3","D3_YTAG")  ,"",''  ,'.F.',50,.F.})	
	aAdd( aPergs ,{1,"Nova Tag  " 	   		,MV_PAR02 ,PesqPict("SD3","D3_YTAG")  ,"NAOVAZIO() .And. U_BFG21VLD()",'SZC'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Altera��o de TAG",@_aRet)

		lRet := .T.
		MV_PAR01 := _aRet[1] 
		MV_PAR02 := _aRet[2]

	EndIf

Return lRet

User Function BFG21VLD()
	SZC->(DbSetOrder(1))
	If SZC->(DbSeek(XFilial("SZC")+MV_PAR02)) 
		If ( SD3->D3_CLVL <> SZC->ZC_CLVL )
			MsgAlert("TAG com classe de valor diferente. ","BIAFG021")
			Return(.F.)
		EndIf
	Else
		MsgAlert("TAG N�o Encontrada!","BIAFG021")
		Return(.F.)
	EndIf
Return .T.