#INCLUDE 'PROTHEUS.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณComColRt  บAutor  ณIhorran Milholi     บ Data ณ  10/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para incluir novos bot๕es do totvs colabora็ใo       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCOMXCOL                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function COMCOLRT()
	
	Local aRotina := ParamIxb[1]
	
	AAdd( aRotina,{ "Exc.XML"			 	, "U_VIXA078"	, 0 , 4, 0, NIL } )
	AAdd( aRotina,{ "Produtos"			 	, "U_VIXMT010"	, 0 , 3, 0, NIL } )
	AAdd( aRotina,{ "Prod x Fornecedor" 	, "U_VIXMT060"	, 0 , 3, 0, NIL } )
	AAdd( aRotina,{ "Entrada NF-e"		, "A140XMLNFe"	, 0 , 3, 0, nil } )
	AAdd( aRotina,{ "Pre Nota Entrada" 	, "U_VIXMT140"	, 0 , 3, 0, nil } )
	AAdd( aRotina,{ "Autoriz. Gerente" 	, "U_VIX259CL"	, 0 , 4, 0, nil } )

Return(aRotina)

User Function VIXMT060()
	
	Local cFunc := AllTrim(FunName())
	
	SetFunName("MATA060")
	
	MATA060()
	
	SetFunName(cFunc)	

Return()

User Function VIXMT010()

	Local cFunc := AllTrim(FunName())
	
	SetFunName("MATA010")
	
	MATA010()

	SetFunName(cFunc)
		
Return()

User Function VIXMT140()

	Local cFunc := AllTrim(FunName())
	
	SetFunName("MATA140")
	
	MATA140()

	SetFunName(cFunc)
		
Return()