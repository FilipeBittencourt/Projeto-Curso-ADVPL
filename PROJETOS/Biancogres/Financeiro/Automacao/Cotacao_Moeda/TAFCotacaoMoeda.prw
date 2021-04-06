#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFCotacaoMoeda
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe para tratamento de Cotacoes de Moedas Automaticamente
@type class
/*/

Class TAFCotacaoMoeda From LongClassName
	
	Data nDolar
	Data nEuro
	Data dData
	Data oBcb
	
	Method New() Constructor
	Method Insert()
	Method AddSM2()
	Method AddCTP()
	Method AddSYE()
	Method GetUSD()
	Method GetEUR()
	
EndClass


Method New() Class TAFCotacaoMoeda

	::nDolar := 0
	::nEuro := 0
	::dData := DataValida(DaySub(dDatabase, 1), .F.)
	::oBcb := TAFMoedaBancoCentral():New()

Return()


Method Insert() Class TAFCotacaoMoeda

	::GetUSD()

	::GetEUR()
	
	If ::nDolar > 0 .And. ::nEuro > 0
	
		Begin Transaction
		
			::AddSM2()
			
			::AddCTP()
			
			::AddSYE()
		
		End Transaction
	
	EndIf 
	
Return()


Method AddSM2() Class TAFCotacaoMoeda
Local lInsert := .T.
	
	DbSelectArea("SM2")
	SM2->(DbSetOrder(1))
	
	lInsert := !SM2->(DbSeek(dToS(dDatabase)))
	
	RecLock("SM2", lInsert)

		SM2->M2_DATA := dDatabase
		SM2->M2_MOEDA2 := ::nDolar
		SM2->M2_MOEDA5 := ::nEuro
	
	SM2->(MsUnLock())

Return()


Method AddCTP() Class TAFCotacaoMoeda
Local lInsert := .T.

	DbSelectArea("CTP")
	CTP->(DbSetOrder(1))

	lInsert := !CTP->(DbSeek(xFilial("CTP") + dToS(dDataBase) + "02"))
			
	RecLock("CTP", lInsert)

		CTP->CTP_FILIAL := xFilial("CTP")
		CTP->CTP_DATA := dDataBase
		CTP->CTP_MOEDA := "02" 
		CTP->CTP_TAXA := ::nDolar
		CTP->CTP_BLOQ := "2"
	
	CTP->(MsUnLock())
	
	lInsert := !CTP->(DbSeek(xFilial("CTP") + dToS(dDataBase) + "05"))
			
	RecLock("CTP", lInsert)

		CTP->CTP_FILIAL := xFilial("CTP")
		CTP->CTP_DATA := dDataBase
		CTP->CTP_MOEDA := "05" 
		CTP->CTP_TAXA := ::nEuro
		CTP->CTP_BLOQ := "2"
	
	CTP->(MsUnLock())	
			
Return()


Method AddSYE() Class TAFCotacaoMoeda
Local lInsert := .T.

	DbSelectArea("SYE")
	SYE->(DbSetOrder(1))

	lInsert := !SYE->(DbSeek(xFilial("SYE") + dToS(dDataBase) + "US$"))
			
	RecLock("SYE", lInsert)

		SYE->YE_FILIAL := xFilial("SYE")
		SYE->YE_DATA := dDataBase
		SYE->YE_MOEDA := "US$"
		SYE->YE_VLCON_C := ::nDolar
		SYE->YE_VLFISCA := ::nDolar
	
	SYE->(MsUnLock())
	
	lInsert := !SYE->(DbSeek(xFilial("SYE") + dToS(dDataBase) + "EUR"))
			
	RecLock("SYE", lInsert)

		SYE->YE_FILIAL := xFilial("SYE")
		SYE->YE_DATA := dDataBase
		SYE->YE_MOEDA := "EUR"
		SYE->YE_VLCON_C := ::nEuro
		SYE->YE_VLFISCA := ::nEuro
	
	SYE->(MsUnLock())	

Return()


Method GetUSD() Class TAFCotacaoMoeda

	::oBcb:cMoeda := "USD"
	::oBcb:cData := Month2Str(::dData) + "-" + Day2Str(::dData) + "-" + Year2Str(::dData)
	
	If ::oBcb:Request()
	
		::nDolar := ::oBcb:nValor 
	
	EndIf

Return()


Method GetEUR() Class TAFCotacaoMoeda
	
	::oBcb:cMoeda := "EUR"
	::oBcb:cData := Month2Str(::dData) + "-" + Day2Str(::dData) + "-" + Year2Str(::dData)
	
	If ::oBcb:Request()
	
		::nEuro := ::oBcb:nValor 
	
	EndIf
	
Return()