#INCLUDE 'PROTHEUS.CH'

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯omColRt  篈utor  矷horran Milholi     � Data �  10/03/14   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砇otina para incluir novos bot鮡s do totvs colabora玢o       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       矯OMXCOL                                                     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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