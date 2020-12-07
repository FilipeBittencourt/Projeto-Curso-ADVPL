#INCLUDE "PROTHEUS.CH"

User Function FCOMIP01 
Local cMay := ""                  
Local lRep
Local cNextCod
Local aAreaTmp := GetArea() 

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")
	Return(Space(6))
EndIf

lRep := Type("CREPATU") <> "U" .And. !Empty(CREPATU)

If lRep

	If (AllTrim(cEmpAnt) == '01')
		cNextCod := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_BIA_REP")
	
	ElseIf(AllTrim(cEmpAnt) == '07')
		
		If (AllTrim(cFilAnt) == '05')
			cNextCod := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_LM_05")
		Else
			cNextCod := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_LM_REP")
		EndIf
		
	Else
		cNextCod := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_REP") 
	
	EndIf
	
	//TICKET 13542: Controle da sequência do número do pedido para 	que o 3º dígito do pedido não seja letra
	if !IsNumeric(Substr(cNextCod,3,1))
		cNextCod := Substr( cNextCod, 1, 2) + 'ZZZZ'
		cNextCod := Soma1(cNextCod,Len(cNextCod))
	endif
Else
	
		
	If (AllTrim(cEmpAnt) == '07') .And. (AllTrim(cFilAnt) == '05')
		cNextCod := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_LM_05")
	Else
		cNextCod := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_INT")	
	EndIf
	
EndIf

//(Thiago Dantas - 24/02/15)
//Verificar numeracao do pedido
dbSelectArea("SC5")
cMay := "SC5"+ Alltrim(xFilial("SC5"))
SC5->(dbSetOrder(1))
While ( DbSeek(xFilial("SC5")+cNextCod) .or. !MayIUseCode(cMay+cNextCod) )
	cNextCod := Soma1(cNextCod,Len(cNextCod))
EndDo
 
Conout("FCOMIP01 NUMERO "+cNextCod)

RestArea(aAreaTmp)

Return(cNextCod) 