
User Function FTSTCALC

	aCodFol := {}
	aInssEmp:= Array(23,2)  
	cAnoMes := "201709"
	
	cCodFol  := PosSrv("721","01","RV_CODFOL") 
	
	//--Carrega Identificadores de Calculo
	If !FP_CODFOL(@aCodFol,cFilAnt)
		Return
	Endif

	//Carrega Parametro Encargos Inss Empresa
	If !fInssEmp(cFilAnt,@aInssEmp,,cAnoMes)
		Return
	Endif
		
Return