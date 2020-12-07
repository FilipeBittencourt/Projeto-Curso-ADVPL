#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RWMAKE.CH"


User Function BIAJ003()

If !ValidPerg()
	Return
EndIf

U_BIA003AL()

Return

Static Function ValidPerg()
	local cLoad	    := "BIA003AL" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	
	MV_PAR01 := SPACE(6)
	MV_PAR02 := SPACE(14)
	
	aAdd( aPergs ,{1,"Cod Vendedor:"    	,MV_PAR01 ,PesqPict( "SA3", "A3_COD" ) ,"ExistCPo('SA3')",'SA3','.T.',6,.F.})
	aAdd( aPergs ,{1,"CNPJ:"		  		,MV_PAR02 ,"@R 99.999.999/9999-99","",'','.T.',70,.T.})	
	

	If ParamBox(aPergs ,"Alteração de CNPJ",,,,,,,,cLoad,.T.,.T.)
	
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)


	EndIf
	
Return lRet


User Function BIA003AL()
	
	SA3->(DbSetOrder(1))
	
	If SA3->(DbSeek(xFilial("SA3")+MV_PAR01)) 
	
		If  Empty(SA3->A3_CGC)
			RecLock("SA3",.F.)
			SA3->A3_CGC := MV_PAR02
			SA3->(MsUnlock())

			MsgInfo("Informações Atualizadas com Sucesso")

		Else
			MsgAlert("O vendedor já tem CNPJ cadastrado","STOP")
		EndIf
	EndIf

Return


