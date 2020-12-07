#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

//--------------------------------------------------------------------------------------------
//								*** RELATÓRIO DE OBRAS ***
//--------------------------------------------------------------------------------------------
// Solcitante: 
// Desenvolv.: Thiago Dantas
// Danta: 08/09/2014 
//--------------------------------------------------------------------------------------------
User Function BIA215()

	Private oReport
	Private oSection1
	Private cPerg   := "BIA215"
	Private cTitle  := "Relatório de Obras" 
	Private cEOL 	:= Chr(13)+Chr(10)

	ValPerg(cPerg)
	Pergunte(cPerg,.T.)

	oReport:= ReportDef()
	oReport:PrintDialog()


Return NIL
//---------------------------------------(ReportDef)--------------------------------------
Static Function ReportDef()

	oReport	:= TReport():New("BIA215",cTitle,cPerg, {|oReport| ReportPrint()},"Obras")
	oReport:SetLandScape(.T.)
	oReport:SetTotalInLine(.F.)

	oSection1 	:= TRSection():New(oReport,"Cargas",{"ZZO"},/*Ordem*/)
	oSection1	:SetTotalInLine(.F.)
	//oSection1:SetLineStyle()

	TRCell():New(oSection1,'ZZO_NUN'		,/**/,"Num Obra"  	,/**/,10)
	TRCell():New(oSection1,'ZZO_EMIS'  		,/**/,"Emissão"    	,/**/,10	)
	TRCell():New(oSection1,'ZZO_VEND'	 	,/**/,"Vendedor"   	,/**/,8	)
	TRCell():New(oSection1,'ZZO_NOMEV'	 	,/**/,"Nome Vend" 	,/**/,30)
	TRCell():New(oSection1,'ZZO_ESTV'	 	,/**/,"UF Vend"		,/**/,2 )
	TRCell():New(oSection1,'ZZO_NOMCAP'	 	,/**/,"Capitador" 	,/**/,30)
	TRCell():New(oSection1,'ZZO_OBRA'	 	,/**/,"Nome da Obra",/**/,30)
	TRCell():New(oSection1,'ZZO_ENDOBR'	 	,/**/,"End Obra" 	,/**/,65)
	TRCell():New(oSection1,'ZZO_BAIRRO'	 	,/**/,"Bairro" 		,/**/,30)
	TRCell():New(oSection1,'ZZO_MUN'	 	,/**/,"Município" 	,/**/,15)
	TRCell():New(oSection1,'ZZO_EST'	 	,/**/,"UF Obra"		,/**/,7)
	TRCell():New(oSection1,'ZZO_PADRAO'	 	,/**/,"Padrão" 		,/**/,5 ) 
	TRCell():New(oSection1,'ZZO_FASE'	 	,/**/,"Fase" 		,/**/,5 )
	TRCell():New(oSection1,'ZZO_DTPREV'	 	,/**/,"Prev Compra" ,/**/,10 )
	TRCell():New(oSection1,'ZZO_NROTOR'	 	,/**/,"Torres /BL"  ,/**/,10 )
	TRCell():New(oSection1,'ZZO_NROAPT'	 	,/**/,"Nro Aptos" 	,/**/,5 )
	TRCell():New(oSection1,'ZZO_QTDTOT'	 	,/**/,"Qtd Total M2",/**/,10)
	TRCell():New(oSection1,'ZZO_NOMCLI'	 	,/**/,"Nome Cliente",/**/,30)
	TRCell():New(oSection1,'ZZO_ENDCLI'	 	,/**/,"End Cliente" ,/**/,30)
	TRCell():New(oSection1,'ZZO_BAIRRC'	 	,/**/,"Bairro Cli"  ,/**/,15)
	TRCell():New(oSection1,'ZZO_TELC1'	 	,/**/,"Telefone Cli",/**/,15)
	TRCell():New(oSection1,'ZZO_OBS'	 	,/**/,"Obs"			,/**/,300)
	TRCell():New(oSection1,'ZZO_ALTSTA'	 	,/**/,"Alt Status"  ,/**/, 10)
	TRCell():New(oSection1,'ZZO_STATUS'	 	,/**/,"Status" 		,/**/,20)
	TRCell():New(oSection1,'ZZO_PERD'	 	,/**/,"Perdido"		,/**/,50)
	TRCell():New(oSection1,'ZZO_YMOTIV'	 	,/**/,"Motivo Perda"		,/**/,30)
	TRCell():New(oSection1,'ZZO_DTFECH'	 	,/**/,"Fechamento" 	,/**/,10 )
	TRCell():New(oSection1,'ZZO_REDEOB'	 	,/**/,"Rede" 		,/**/,4 )
	TRCell():New(oSection1,'ZZO_PEDIDO'	 	,/**/,"Pedido" 		,/**/,10)

Return  oReport
//---------------------------------------(ReportPrint)--------------------------------------
Static Function ReportPrint()

	Local cSQL := ""  
	Local oSection1 := oReport:Section(1)

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	cSQL := GeraSql()
	TcQuery cSQL New Alias "QRYCON"
	DbSelectArea("QRYCON")
	QRYCON->(DbGoTop()) 

	oReport:SetMeter(QRYCON->(RecCount()))

	If !QRYCON->(Eof()) 

		oSection1:Init()

		While !oReport:Cancel() .And. !QRYCON->(Eof()) 

			oReport:IncMeter()

			oSection1:Cell('ZZO_NUN'			):SetValue(QRYCON->ZZO_NUM	)
			oSection1:Cell('ZZO_NUN'			):SetAlign("CENTER")

			oSection1:Cell('ZZO_EMIS'  			):SetValue(Day2Str(sToD(QRYCON->ZZO_EMIS)) + "/" + Month2Str(sToD(QRYCON->ZZO_EMIS)) + "/" + Year2Str(sToD(QRYCON->ZZO_EMIS)))

			oSection1:Cell('ZZO_VEND'	 		):SetValue(QRYCON->ZZO_VEND )
			oSection1:Cell('ZZO_VEND'			):SetAlign("CENTER")

			oSection1:Cell('ZZO_NOMEV'	 		):SetValue(QRYCON->ZZO_NOMEV)

			oSection1:Cell('ZZO_ESTV'	 		):SetValue(QRYCON->ZZO_ESTV )
			oSection1:Cell('ZZO_ESTV'			):SetAlign("CENTER")

			oSection1:Cell('ZZO_NOMCAP'	 		):SetValue(QRYCON->ZZO_NOMCAP)
			oSection1:Cell('ZZO_OBRA'	 		):SetValue(QRYCON->ZZO_OBRA	)
			oSection1:Cell('ZZO_ENDOBR'	 		):SetValue(QRYCON->ZZO_ENDOBR )
			oSection1:Cell('ZZO_BAIRRO'	 		):SetValue(QRYCON->ZZO_BAIRRO )
			oSection1:Cell('ZZO_MUN'	 		):SetValue(QRYCON->ZZO_MUN )
			oSection1:Cell('ZZO_EST'	 		):SetValue(QRYCON->ZZO_EST )

			oSection1:Cell('ZZO_PADRAO'	 		):SetValue(QRYCON->ZZO_PADRAO)
			oSection1:Cell('ZZO_PADRAO'			):SetAlign("CENTER")

			oSection1:Cell('ZZO_FASE'	 		):SetValue(QRYCON->ZZO_FASE	 )
			oSection1:Cell('ZZO_FASE'			):SetAlign("CENTER")

			oSection1:Cell('ZZO_DTPREV'	 		):SetValue(Day2Str(sToD(QRYCON->ZZO_DTPREV)) + "/" + Month2Str(sToD(QRYCON->ZZO_DTPREV)) + "/" + Year2Str(sToD(QRYCON->ZZO_DTPREV)))
			oSection1:Cell('ZZO_NROTOR'	 		):SetValue(QRYCON->ZZO_NROTOR)
			oSection1:Cell('ZZO_NROAPT'	 		):SetValue(QRYCON->ZZO_NROAPT)
			oSection1:Cell('ZZO_QTDTOT'	 		):SetValue(QRYCON->ZZO_QTDTOT)
			oSection1:Cell('ZZO_NOMCLI'	 		):SetValue(QRYCON->ZZO_NOMCLI)
			oSection1:Cell('ZZO_ENDCLI'	 		):SetValue(QRYCON->ZZO_ENDCLI)
			oSection1:Cell('ZZO_BAIRRC'	 		):SetValue(QRYCON->ZZO_BAIRRC)
			oSection1:Cell('ZZO_TELC1'	 		):SetValue(QRYCON->ZZO_TELC1 )
			oSection1:Cell('ZZO_OBS'			):SetValue(QRYCON->ZZO_OBS )
			oSection1:Cell('ZZO_ALTSTA'	 		):SetValue(Day2Str(sToD(QRYCON->ZZO_ALTSTA)) + "/" + Month2Str(sToD(QRYCON->ZZO_ALTSTA)) + "/" + Year2Str(sToD(QRYCON->ZZO_ALTSTA)))

			oSection1:Cell('ZZO_STATUS'	 		):SetValue(QRYCON->ZZO_STATUS)
			oSection1:Cell('ZZO_STATUS'			):SetAlign("CENTER")

			oSection1:Cell('ZZO_PERD'	 		):SetValue(QRYCON->ZZO_PERD)
			oSection1:Cell('ZZO_YMOTIV'	 		):SetValue(QRYCON->ZZO_YMOTIV)		
			oSection1:Cell('ZZO_DTFECH'	 		):SetValue(Day2Str(sToD(QRYCON->ZZO_DTFECH)) + "/" + Month2Str(sToD(QRYCON->ZZO_DTFECH)) + "/" + Year2Str(sToD(QRYCON->ZZO_DTFECH)))
			oSection1:Cell('ZZO_REDEOB'	 		):SetValue(QRYCON->ZZO_REDEOB)
			oSection1:Cell('ZZO_PEDIDO'	 		):SetValue(QRYCON->ZZO_PEDIDO)

			oSection1:PrintLine()
			QRYCON->(dbSkip())

			dbSelectArea("QRYCON")

		End

		oReport:EndPage() 
		oSection1:Finish()
	EndIf

	QRYCON->(DbCloseArea()) 

Return
//---------------------------------------(GeraSql)--------------------------------------
Static Function GeraSql()  
	Local cFiltro 	:= ""
	Local _nomeuser := cUserName
	Local _daduser := ""

	psworder(2)                          // Pesquisa por Nome

	//_nomeuser:='A00027'
	If  pswseek(_nomeuser,.t.)           // Nome do usuario, Pesquisa usuarios
		_daduser  := pswret(1)           // Numero do registro
		_UsuarAt  := _daduser[1,1]
	EndIf

	cSQL := ""
	cSQL+= " SELECT ZZO_NUM,  
	cSQL+= "		ZZO_EMIS, 
	cSQL+= "		ZZO_VEND, ZZO_NOMEV, ZZO_ESTV, 
	cSQL+= "		ZZO_NOMCAP, 
	cSQL+= "		ZZO_OBRA, 
	cSQL+= "		RTRIM(ZZO_ENDOBR) + ', ' + RTRIM(ZZO_NUMOBR) AS ZZO_ENDOBR , RTRIM(ZZO_BAIRRO) AS ZZO_BAIRRO, RTRIM(ZZO_MUN) AS ZZO_MUN, RTRIM(ZZO_EST) AS ZZO_EST,  
	cSQL+= "		ZZO_PADRAO, ZZO_FASE, ZZO_DTPREV, ZZO_NROTOR, ZZO_NROAPT, ZZO_QTDTOT, 
	cSQL+= "		ZZO_NOMCLI, 
	cSQL+= "		RTRIM(ZZO_ENDCLI) AS ZZO_ENDCLI, RTRIM(ZZO_BAIRRC) AS ZZO_BAIRRC, ZZO_OBS, 
	cSQL+= "		ZZO_TELC1,ZZO_ALTSTA, 
	cSQL+= "		ZZO_STATUS + ' - ' +
	cSQL+= "		CASE  ZZO_STATUS
	cSQL+= "				WHEN '1'	THEN 'EM ESPECIFICACAO'
	cSQL+= "				WHEN '2'	THEN 'FECHADO'
	cSQL+= "				WHEN '3'	THEN 'PERDIDO'
	cSQL+= "				WHEN '4'	THEN 'ADIADO'
	cSQL+= "				ELSE 'DESCONHECIDO'
	cSQL+= "				END AS ZZO_STATUS, 
	cSQL+= "		ZZO_PERD, 

	cSQL+= "		ZZO_YMOTIV + ' - ' +
	cSQL+= "		CASE  ZZO_YMOTIV
	cSQL+= "				WHEN '1'	THEN 'DESCONHECIMENTO DA MARCA'
	cSQL+= "				WHEN '2'	THEN 'PRECO'
	cSQL+= "				WHEN '3'	THEN 'PRAZO DE ENTREGA'
	cSQL+= "				WHEN '4'	THEN 'CREDITO'
	cSQL+= "				WHEN '5'	THEN 'QUALIDADE'
	cSQL+= "				WHEN '6'	THEN 'FIDELIDADE A OUTRAS MARCAS'
	cSQL+= "				WHEN '7'	THEN 'OUTROS'
	cSQL+= "				ELSE ''
	cSQL+= "				END AS ZZO_YMOTIV, 

	cSQL+= "		ZZO_DTFECH, ZZO_REDEOB, ZZO_PEDIDO
	cSQL+="	FROM " + RetSqlName("ZZO")+ " ZZO "
	cSQL+="	WHERE ZZO_STATUS <> '' "
	cSQL+="	AND ZZO_FILIAL = '01'  "
	cSQL+="	AND D_E_L_E_T_ = ' '  "
	cSQL+="	AND ZZO_EMIS >= '"+DtoS(MV_PAR01)+"' "
	cSQL+="	AND ZZO_EMIS <= '"+DtoS(MV_PAR02)+"' "

	If !Empty(AllTrim(cRepAtu))
		cSQL += "		AND ZZO_VEND = '"+cRepAtu+"' "
	Else
		If Alltrim(Upper(_daduser[1,12])) == "ESPECIFICADORES" .And. Substr(Alltrim(_daduser[1,2]),1,1) = "A" //testar pra ver de qualé!
			cSQL += "		AND ZZO_VEND IN ('" + Replace(Alltrim(Upper(_daduser[1,13])),"/","','") + "') "
		Else
			cSQL += "		AND ZZO_VEND   BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		EndIf
	EndIf

	//cSQL+="	AND ZZO_VEND >= '"+MV_PAR03+"' "
	//cSQL+="	AND ZZO_VEND <= '"+MV_PAR04+"' "
	cSQL+="	ORDER BY ZZO_VEND          "

Return cSQL
//---------------------------------------(ValPerg)--------------------------------------
Static Function ValPerg(cPerg)

	Local j, i

	aRegs :={}
	cPerg := PADR(cPerg,10)

	aAdd(aRegs,{cPerg,"01","Emissão De?"	,"Emissão De?"	,"Emissão De?"		,"mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Emissão Ate?"	,"Emissão Ate?","Emissão Ate?"		,"mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Vendedor de?"	,"Vendedor De?"	,"Vendedor de?"		,"mv_ch1","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Vendedor Ate?"	,"Vendedor Ate?","Vendedor Ate?"	,"mv_ch2","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	dbSelectArea("SX1")

	dbSelectArea("SX1")
	For i:=1 to Len(aRegs)
		If !SX1->(dbSeek(cPerg+aRegs[i,2]))
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			SX1->(MsUnlock())
		Endif
	Next

Return
//--------------------------------------------------------------------------------------