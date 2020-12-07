#include "PROTHEUS.CH"

/*/{Protheus.doc} FACOWF02
@description Workflow de provisao de acordos de objetivo
@author Fernando Rocha
@since 23/05/2017
@version undefined
@param cDtFimDe, characters, descricao
@param cDtFimAte, characters, descricao
@param cContrato, characters, descricao
@param cNumSI, characters, descricao
@type function
/*/
User Function FACOWF02(cDtFimDe,cDtFimAte,cContrato,cNumSI)

	local aAreaX   		:= GetArea() 
	local nContReg 		:= 0
	local nTotReg		:= 6
	local cTemp1		:= ""
	local cTemp2		:= ""
	private cTab1	   	:= GetNextAlias()
	private oFWExcel 	:= Nil
	private cDir 		:= "\P10\DOCTEMP\"
	private cFile 	 	:= "LANCAMENTOS_PROVISAO_AO_COM_BONUS-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	private cWorkSheet 	:= 'Lanc_Prov' 
	private cTable 	 	:= "AI x Lancamentos de Provisão"
	private cAliasTab  	:= ''
	private cTempEmp	:= ''
	private	cConta		:= ''
	private	cDtIni		:= ''
	private	cDtFim		:= ''

	if empty(cDtFimDe) .or. empty(cDtFimAte) 
		RestArea(aAreaX)
		return
	endif

	if !empty(cNumSI)
		cTemp1 += " AND PZ6.PZ6_SI = '"+ cNumSI +"' "
		cFile  := "LANCAMENTOS_PROVISAO_AI_"+Alltrim(cNumSI)+"-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
		cTable := "AI numero "+Alltrim(cNumSI)+" x Lancamentos de Provisão"
	endif
	if empty(cTemp1)
		cTemp1 += " AND PZ6.PZ6_SI <> '' "
	endif
	cTemp1 := "%"+cTemp1+"%"

	if !empty(cContrato)
		cTemp2 += " AND PZ5.PZ5_CODIGO = '"+ cContrato +"' "
	endif
	if empty(cTemp2)
		cTemp2 += " AND PZ5.PZ5_CODIGO <> '' "
	endif
	cTemp2 := "%"+cTemp2+"%"

	If Z79->(FieldPos("Z79_YCTPRO")) > 0

		BeginSQL Alias cTab1 
		%noparser%  

		SELECT
		PZ5.PZ5_CODIGO,
		PZ6.PZ6_SI,
		PZ6.PZ6_BONUS,
		PZ6.PZ6_PERINI,
		PZ6.PZ6_PERFIM,
		CODCLIGRP = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_COD+SA1.A1_LOJA 
		WHEN PZ5_TIPCLI = '2' THEN PZ5.PZ5_CODGRP
		ELSE PZ5.PZ5_REDE END,
		NOME = CASE WHEN PZ5_TIPCLI = '1' THEN A1_NOME
		WHEN PZ5_TIPCLI = '2' THEN ACY_DESCRI 
		ELSE (SELECT TOP 1 Z79_DESCR FROM %TABLE:Z79% (NOLOCK) Z79 WHERE Z79.Z79_REDE = PZ5.PZ5_REDE AND Z79.D_E_L_E_T_ = '') END,
		CONTA = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRO 
		WHEN PZ5_TIPCLI = '2' THEN ACY.ACY_YCTPRO
		ELSE (SELECT TOP 1 Z79_YCTPRO FROM %TABLE:Z79% (NOLOCK) Z79 WHERE Z79.Z79_REDE = PZ5.PZ5_REDE AND Z79.D_E_L_E_T_ = '') END

		FROM %TABLE:PZ6% (NOLOCK) PZ6
		JOIN %TABLE:PZ5% (NOLOCK) PZ5 
		ON PZ5.PZ5_CODIGO = PZ6.PZ6_CODIGO 
		AND  PZ5.D_E_L_E_T_ = '' 
		%exp:cTemp2%
		LEFT JOIN %TABLE:SA1% (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN %TABLE:ACY% (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = ''

		WHERE PZ6_PERFIM BETWEEN %exp:cDtFimDe%  and %exp:cDtFimAte% 
		AND PZ6.PZ6_DTULRE > PZ6.PZ6_PERFIM 
		AND PZ6.PZ6_BONUS > 0
		AND PZ6.PZ6_SI <> '' 
		AND PZ6.PZ6_SI IS NOT NULL 	
		AND PZ5.PZ5_PROVER = 'S'
		AND PZ6.D_E_L_E_T_ = ''
		%exp:cTemp1%
		ORDER BY PZ6.PZ6_CODIGO, PZ6.PZ6_PERFIM
		EndSQL

	Else

		BeginSQL Alias cTab1 
		%noparser%  

		SELECT
		PZ5.PZ5_CODIGO,
		PZ6.PZ6_SI,
		PZ6.PZ6_BONUS,
		PZ6.PZ6_PERINI,
		PZ6.PZ6_PERFIM,
		CODCLIGRP = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_COD+SA1.A1_LOJA ELSE ACY_GRPVEN END,
		NOME = CASE WHEN PZ5_TIPCLI = '1' THEN A1_NOME ELSE ACY_DESCRI END,
		CONTA = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRO ELSE ACY.ACY_YCTPRO END
		FROM %TABLE:PZ6% (NOLOCK) PZ6
		JOIN %TABLE:PZ5% (NOLOCK) PZ5 
		ON PZ5.PZ5_CODIGO = PZ6.PZ6_CODIGO 
		AND  PZ5.D_E_L_E_T_ = '' 
		%exp:cTemp2%
		LEFT JOIN %TABLE:SA1% (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN %TABLE:ACY% (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE PZ6_PERFIM BETWEEN %exp:cDtFimDe%  and %exp:cDtFimAte% 
		AND PZ6.PZ6_DTULRE > PZ6.PZ6_PERFIM 
		AND PZ6.PZ6_BONUS > 0
		AND PZ6.PZ6_SI <> '' 
		AND PZ6.PZ6_SI IS NOT NULL 	
		AND PZ5.PZ5_PROVER = 'S'
		AND PZ6.D_E_L_E_T_ = ''
		%exp:cTemp1%
		ORDER BY PZ6.PZ6_CODIGO, PZ6.PZ6_PERFIM
		EndSQL

	EndIf

	(cTab1)->(DbGoTop())  
	Count To nTotReg 
	(cTab1)->(DbGoTop())

	If (cTab1)->(Eof())
		//MsgInfo('Nenhum Registro encontrado para o Workflow de AI x Lançamentos')
		RestArea(aAreaX)
		return	
	else
		nTotReg += 2
		ProcRegua(nTotReg)
		nContReg++
		IncProc("Carregando e-mail - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

		oFWExcel := FWMsExcel():New()
		oFWExcel:AddWorkSheet(cWorkSheet)
		oFWExcel:AddTable(cWorkSheet, cTable)

		oFWExcel:AddColumn(cWorkSheet, cTable, "ACORDO"			, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "AI"				, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "VLR.BONUS"		, 1, 2)
		oFWExcel:AddColumn(cWorkSheet, cTable, "DATA INI"		, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "DATA FIM"		, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "COD CLI/GRP"	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "NOME"			, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CONTA"			, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "EMPRESA FAT"	, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "DATA"			, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "LOTE"			, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "DEBITO"			, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "CREDITO"		, 1, 1)
		oFWExcel:AddColumn(cWorkSheet, cTable, "VALOR"			, 1, 2) 

		while !(cTab1)->(Eof())

			cConta	:= (cTab1)->CONTA
			cDtIni	:= (cTab1)->PZ6_PERINI
			cDtFim	:= (cTab1)->PZ6_PERFIM

			fProcExcel()

			nContReg++
			IncProc("Carregando e-mail - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

			(cTab1)->(DbSkip())
		end

		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cDir+cFile)
		oFWExcel:DeActivate()

		SendMail(cDir + cFile,cNumSI)

		nContReg++
		IncProc("Carregando e-mail - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

	endif

	RestArea(aAreaX)
return


Static Function fProcExcel()

	Local aAreaY  := GetArea() 
	Local cTab2	  := GetNextAlias()
	local aAux	  := {}
	
	If Empty(cConta)
		Return
	EndIf

	BeginSQL Alias cTab2 
	%NOPARSER%

	SELECT 
	XEMP = '01',
	CT2.*
	FROM CT2010 (NOLOCK) CT2
	WHERE CT2.CT2_DATA BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
	AND CT2.CT2_DEBITO = %Exp:cConta%  
	AND CT2.D_E_L_E_T_ = ''

	UNION ALL 

	SELECT 
	XEMP = '05',
	CT2.*
	FROM CT2050 (NOLOCK) CT2
	WHERE CT2.CT2_DATA BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
	AND CT2.CT2_DEBITO = %Exp:cConta% 
	AND CT2.D_E_L_E_T_ = ''

	UNION ALL 

	SELECT 
	XEMP = '07',
	CT2.*
	FROM CT2070 (NOLOCK) CT2
	WHERE CT2.CT2_DATA BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
	AND CT2.CT2_DEBITO = %Exp:cConta%  
	AND CT2.D_E_L_E_T_ = ''

	UNION ALL 

	SELECT 
	XEMP = '01',
	CT2.*
	FROM CT2010 (NOLOCK) CT2
	WHERE CT2.CT2_DATA BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
	AND CT2.CT2_CREDIT = %Exp:cConta% 
	AND CT2.D_E_L_E_T_ = ''

	UNION ALL 

	SELECT 
	XEMP = '05',
	CT2.*
	FROM CT2050 (NOLOCK) CT2
	WHERE CT2.CT2_DATA BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
	AND CT2.CT2_CREDIT = %Exp:cConta% 
	AND CT2.D_E_L_E_T_ = ''

	UNION ALL 

	SELECT 
	XEMP = '07',
	CT2.*
	FROM CT2070 (NOLOCK) CT2
	WHERE CT2.CT2_DATA BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
	AND CT2.CT2_CREDIT = %Exp:cConta% 
	AND CT2.D_E_L_E_T_ = ''

	ORDER BY XEMP, CT2.CT2_DATA
	EndSQL

	(cTab2)->(DbGoTop())
	If !(cTab2)->(Eof()) 

		While !(cTab2)->(Eof())

			cTempEmp := ''
			aAux     := {}     
			do case 
				case (cTab2)->XEMP = '01'
				cTempEmp := 'BIANCOGRES'
				case (cTab2)->XEMP = '05'
				cTempEmp := 'INCESA'
				case (cTab2)->XEMP = '07'
				cTempEmp := 'LM'
			endcase		

			AAdd(aAux, (cTab1)->PZ5_CODIGO)
			AAdd(aAux, (cTab1)->PZ6_SI)
			AAdd(aAux, (cTab1)->PZ6_BONUS)	
			AAdd(aAux, DTOC(STOD((cTab1)->PZ6_PERINI)))
			AAdd(aAux, DTOC(STOD((cTab1)->PZ6_PERFIM)))	 
			AAdd(aAux, (cTab1)->CODCLIGRP)      
			AAdd(aAux, (cTab1)->NOME)
			AAdd(aAux, (cTab1)->CONTA)	
			AAdd(aAux, cTempEmp)
			AAdd(aAux, DTOC(STOD((cTab2)->CT2_DATA)))	     
			AAdd(aAux, (cTab2)->CT2_LOTE)
			AAdd(aAux, (cTab2)->CT2_DEBITO)      
			AAdd(aAux, (cTab2)->CT2_CREDIT)   
			AAdd(aAux, iif(alltrim(cConta) == Alltrim((cTab2)->CT2_DEBITO),(cTab2)->CT2_VALOR*(-1),(cTab2)->CT2_VALOR))	

			oFWExcel:AddRow(cWorkSheet, cTable,	aAux)

			(cTab2)->(DbSkip())
		EndDo 
	else
		aAux := {}                           
		AAdd(aAux, (cTab1)->PZ5_CODIGO)
		AAdd(aAux, (cTab1)->PZ6_SI)
		AAdd(aAux, (cTab1)->PZ6_BONUS)	
		AAdd(aAux, DTOC(STOD((cTab1)->PZ6_PERINI)))
		AAdd(aAux, DTOC(STOD((cTab1)->PZ6_PERFIM)))	 
		AAdd(aAux, (cTab1)->CODCLIGRP)      
		AAdd(aAux, (cTab1)->NOME)
		AAdd(aAux, (cTab1)->CONTA)	
		AAdd(aAux, '')
		AAdd(aAux, DTOC(STOD('')) )	     
		AAdd(aAux, '')
		AAdd(aAux, '')      
		AAdd(aAux, '')   
		AAdd(aAux, 0 )	

		oFWExcel:AddRow(cWorkSheet, cTable,	aAux)
	endif

	(cTab2)->(DbCloseArea())
	RestArea(aAreaY)
Return


Static Function SendMail(_cArquivo,cNumSI)
	Local cTo      := U_EmailWF("FACOWF02",CEMPANT)
	local lRet	   := .F.
	local cSubject := ''
	local cMens	   := ''

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))

	if !Empty(cNumSI)
		cSubject := "AI numero "+Alltrim(cNumSI)
		cMens	 := "Segue (Anexo) planilha com a lista de Lançamentos Contabeis de provisão, da AI numero "+Alltrim(cNumSI)+"." 
	else
		cSubject := "AI"
		cMens	 := "Segue (Anexo) planilha com a lista de AI x Lançamentos Contabeis de provisão."
	endif	
	cSubject += " x Lançamentos Contabeis - "+ AllTrim(SM0->M0_NOME)

	if !Empty(cTo)
		lRet := U_BIAEnvMail(, cTo, cSubject, cMens, "", _cArquivo, )
	endif

Return lRet
