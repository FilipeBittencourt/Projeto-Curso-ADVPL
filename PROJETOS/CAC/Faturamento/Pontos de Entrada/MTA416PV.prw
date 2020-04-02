User Function MTA416PV()
Local nC6Tes  := aScan(_aHeader, {|x| AllTrim(x[2]) == "C6_TES"})
//Local nC6Vdbs := aScan(_aHeader, {|x| AllTrim(x[2]) == "C6_VDOBS"})})

	M->C5_VEND1   := SCJ->CJ_YVEND1
	M->C5_YPROATL := SCJ->CJ_YPROATL
	M->C5_YOBS    := SCJ->CJ_YOBS
	                    
	If SCJ->CJ_YCATEGO == "1" 
		//Venda Direta
		M->C5_YCATEGO := '4'
		aEval(_aCols, {|x| x[nC6Tes] := "900" })
	ElseIf SCJ->CJ_YCATEGO == "2" 
		//revenda de Equipamento
		M->C5_YCATEGO := '5'    
		//Vericar TES
	ElseIf SCJ->CJ_YCATEGO == "3"
		//Locacao 
		M->C5_YCATEGO := '6' 
		//Verificar TES
	EndIf

//item
//CK_OBS <=> C6_VDOBS
//CK_TES <=> 900 <=> C6_TES
Return()