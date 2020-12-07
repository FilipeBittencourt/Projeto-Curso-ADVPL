#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} BIABC010
@author Barbara Coelho 
@since 13/11/2019
@version 1.0
@description Rotina para chamada da classe de atualização de fornecedor do pedido de compra. 
@obs Ticket: 2599
@type Function
/*/

User Function BIABC010()
Local cUsuario := ""
	
	If !U_VALOPER("Z51",.F.) 
		MsgSTOP("Usuário sem permissão para esta operação no cadastro!!!", "OP Z51")
		Return
	EndIf

	If fVldPed(SC7->C7_NUM)	
		cUsuario := LsCompr()
		RecLock("SC7", .F.)
			
		SC7->C7_USER := cUsuario
		
		SC7->(MsUnLock())
	EndIf
Return()

Static Function fVldPed(cNumPed)
Local lRet := .T.
Local aArea := GetArea()
	
	While !SC7->(Eof()) .And. SC7->C7_NUM == cNumPed .And. lRet
	
		If (SC7->C7_QUJE > 0 .And. SC7->C7_QTDACLA > 0) .Or. SC7->C7_RESIDUO == "S"
	
			lRet := .F.
		
			MsgAlert("Atenção, somente é permitido alterar o comprador para pedidos em aberto.")
		
		EndIf
		
		SC7->(DbSkip())
		
	EndDo()
	
	RestArea(aArea)
	
Return(lRet) 

Static Function LsCompr()
Local cLoad				:= "BIABC010" + cEmpAnt
Local cFileName			:= RetCodUsr() +"_"+ cLoad
Local nx
Local aAllusers := FWSFALLUSERS()
Local aCompr 	:= {}
Local aCombo 	:= {}
aPergs			:= {}
MV_PAR01 		:= SPACE(50)
cCompr          := ''

	For nx := 1 To Len(aAllusers)
		if (aAllusers[nx][6] == 'COMPRAS' .AND. aAllusers[nx][7] == 'COMPRADOR')
			//aAdd(aCompr,{aAllusers[nx][1], aAllusers[nx][2],aAllusers[nx][3],aAllusers[nx][4],aAllusers[nx][5],aAllusers[nx][6], aAllusers[nx][7]})
			aAdd(aCompr,aAllusers[nx][2]+"-"+aAllusers[nx][3])
			//aAdd(aCombo,aAllusers[nx][3])
		endif
		Next
		
	aAdd( aPergs ,{2, "Compradores", MV_PAR01, aCompr, 50, ".T.", .F.})
	
	If !ParamBox(aPergs ,"PC "+SC7->C7_NUM ,,,,,,,,cLoad,.T.,.T.)
		Return()
	EndIf
	
	MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
	cCompr := SubStr( MV_PAR01, 1, 6)

Return(cCompr)
