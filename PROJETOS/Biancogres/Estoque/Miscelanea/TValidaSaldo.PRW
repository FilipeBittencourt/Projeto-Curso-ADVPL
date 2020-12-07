#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Class TValidaSaldo From LongClassName
	
	Data cProd
	Data cArmazem
	Data nQuant		
	Data nSaldo
	Data nEmpenhoBizagi
	
	Method New() Constructor
	Method Check()
	Method GetSaldo()
	Method GetEmpenhoBizagi()

EndClass


Method New(cProd, cArmazem, nQuant) Class TValidaSaldo
	
	::cProd 	:= cProd
	::cArmazem	:= cArmazem
	::nQuant	:= nQuant
	
Return()


Method GetSaldo() Class TValidaSaldo
	
	Local aArea			:= GetArea()
	Local nSaldo		:= 0
	
	/*Local aSaldos		:= {}
	
	aSaldos := CalcEst(PADR(::cProd, TamSx3("B1_COD")[1]), ::cArmazem, Date()+1)
	If (Len(aSaldos) > 0)
		nSaldo	:= aSaldos[1]
	EndIf
	*/

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	
	If SB2->(DbSeek(xFilial("SB2") + PADR(::cProd, TamSx3("B1_COD")[1]) + ::cArmazem))

		nSaldo := (SB2->B2_QATU - SB2->B2_RESERVA -  SB2->B2_QACLASS)

	EndIf
	
	SB2->(DbCloseArea())
	
	SB2->(RestArea(aArea))
	
	::nSaldo := nSaldo
	
Return nSaldo


Method GetEmpenhoBizagi() Class TValidaSaldo
	
	Local cQuery 		:= ""
	Local cAliasTemp	:= Nil
	Local nTotal		:= 0        	
	
	cAliasTemp := GetNextAlias()
		
	cQuery := " select Total=SUM(Quantidade)																						"
	cQuery += "	from ZEUS.BIZAGIPRD.dbo.VW_EMPENHO_BIZAGI																			"
	cQuery += " where Codigo = '"+::cProd+"' and right('00'+cast(Armazem as varchar (2)), 2) = '"+::cArmazem+"'						"
	
			
	TcQuery cQuery New Alias (cAliasTemp)
	  		
	If !(cAliasTemp)->(EOF())
			
	 	nTotal := (cAliasTemp)->Total    
                                                     
	EndIf
		
	(cAliasTemp)->(DbCloseArea())	
	
	::nEmpenhoBizagi := nTotal
		
Return nTotal

Method Check() Class TValidaSaldo
	
	Local lRet	:= .F.
	
	nSaldo 		:= ::GetSaldo()
	nEmpenho	:= ::GetEmpenhoBizagi()
	
	If (::nQuant <= (nSaldo - nEmpenho))
		lRet	:= .T.
	EndIf
	
	 		 		 		
Return lRet

