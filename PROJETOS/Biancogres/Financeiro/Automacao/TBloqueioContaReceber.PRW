#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function TBLQCR()
	Local _cID		:= 1929108
	Local _lRet		:= .F.
	
	RpcSetEnv('01', '01') 
	 
 	oBlqCR	:= TBloqueioContaReceber():New()
 	_lRet	:= oBlqCR:CheckPorRecno(_cID)
 	
 	conout('_lRet: '+cvaltochar(_lRet))
 	
Return 

Class TBloqueioContaReceber From LongClassName

	Data cID
	
	Method New() Constructor
	Method CheckPorRecno()
	Method CheckFIDC()

EndClass


Method New() Class TBloqueioContaReceber
	::cID			:= ""	
Return()

Method CheckPorRecno(_cID) Class TBloqueioContaReceber
	
	Local aArea	:= SE1->(GetArea())
	Local lRet 	:= .F.
	
	If (!Empty(_cID))
		::cID		:= _cID
	
		DbSelectArea('SE1')
		SE1->(DbSetOrder(1))
		SE1->(DbGoTo(::cID))
		
		lRet := ::CheckFIDC()
		
	EndIf
	
	SE1->(RestArea(aArea))
		
Return lRet


Method CheckFIDC() Class TBloqueioContaReceber

	Local cAliasTemp	:= Nil
	Local cQuery 		:= ""
	Local lRet 			:= .F.

	If (!Empty(SE1->E1_PORTADO) .And. !Empty(SE1->E1_AGEDEP) .And. !Empty(SE1->E1_CONTA))
		
		cQuery := " select A6_YTPINTB  from "+ RetSQLName("SA6") + " SA6						"
		cQuery += " where									 									"
		cQuery += " 	A6_FILIAL			= '"+xFilial("SA6")+"'	 							"
		cQuery += " 	AND A6_COD			= '"+SE1->E1_PORTADO+"'								"
		cQuery += " 	AND A6_AGENCIA		= '"+SE1->E1_AGEDEP+"' 								"
		cQuery += " 	AND A6_NUMCON		= '"+SE1->E1_CONTA+"'								"
		cQuery += " 	AND SA6.D_E_L_E_T_	= ''												"
		
		cAliasTemp	:= GetNextAlias()
			
		TcQuery cQuery New Alias (cAliasTemp)
			
		If !(cAliasTemp)->(Eof())
			If (Alltrim((cAliasTemp)->A6_YTPINTB) == '1')
				lRet	:= .T.
			EndIf	
		EndIf
			
		(cAliasTemp)->(DbCloseArea())
		
	EndIf
	
Return lRet