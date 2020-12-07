#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FACOWF03	ºAutor  ³Artur Antunes       º Data ³ 06/10/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow de Lancamentos Contabeis de acordos de objetivos  º±±
±±			   para metas não atingidas									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FACOWF03(cDtFimDe,cDtFimAte)

	Local aAreaX   		:= GetArea() 
	local nContReg 		:= 0
	local nTotReg		:= 6
	private cTab1	   	:= GetNextAlias()
	private oFWExcel 	:= Nil
	private cDir 		:= "\P10\DOCTEMP\"
	private cFile 	 	:= "LANCAMENTOS_PROVISAO_AO_SEM_BONUS-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	private cWorkSheet 	:= 'Lanc_Prov' 
	private cTable 	 	:= "Lancamentos de Provisão - Com Metas não atingidas no AO "
	private cAliasTab  	:= ''
	private cTempEmp	:= ''
	private	cConta		:= ''
	private	cDtIni		:= ''
	private	cDtFim		:= ''

	if empty(cDtFimDe) .or. empty(cDtFimAte) 
		RestArea(aAreaX)
		return
	endif

	IF PZ5->(FieldPos("PZ5_REDE")) > 0

		BeginSQL Alias cTab1 
		%NOPARSER%
		SELECT
		PZ5.PZ5_CODIGO,
		PZ6.PZ6_SI,
		PZ6.PZ6_BONUS,
		PZ6.PZ6_PERINI,
		PZ6.PZ6_PERFIM,

		CODCLIGRP = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_COD+'-'+SA1.A1_LOJA WHEN PZ5_TIPCLI = '2' THEN ACY_GRPVEN ELSE PZ5_REDE END,
		NOME      = CASE WHEN PZ5_TIPCLI = '1' THEN A1_NOME WHEN PZ5_TIPCLI = '2' THEN ACY_DESCRI ELSE (SELECT TOP 1 Z79_DESCR FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,
		CONTA  = CASE WHEN PZ5_TIPCLI = '1' THEN SA1.A1_YCTAPRO WHEN PZ5_TIPCLI = '2' THEN ACY.ACY_YCTPRO ELSE (SELECT TOP 1 Z79_YCTPRO FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,

		FROM %TABLE:PZ6% (NOLOCK) PZ6
		JOIN %TABLE:PZ5% (NOLOCK) PZ5 
		ON PZ5.PZ5_CODIGO = PZ6.PZ6_CODIGO 
		AND  PZ5.D_E_L_E_T_ = '' 
		LEFT JOIN %TABLE:SA1% (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN %TABLE:ACY% (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE PZ6_PERFIM BETWEEN %exp:cDtFimDe%  and %exp:cDtFimAte% 
		AND PZ6.PZ6_DTULRE > PZ6.PZ6_PERFIM 
		AND PZ6.PZ6_BONUS = 0
		AND PZ6.D_E_L_E_T_ = ''
		ORDER BY PZ6.PZ6_CODIGO, PZ6.PZ6_PERFIM
		EndSQL

	ELSE
		BeginSQL Alias cTab1 
		%NOPARSER%
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
		LEFT JOIN %TABLE:SA1% (NOLOCK) SA1 	
		ON  SA1.A1_COD = PZ5.PZ5_CODCLI	 
		AND SA1.A1_LOJA = PZ5.PZ5_LOJCLI 
		AND SA1.D_E_L_E_T_ = ''
		LEFT JOIN %TABLE:ACY% (NOLOCK) ACY 
		ON ACY.ACY_GRPVEN = PZ5.PZ5_CODGRP 
		AND  ACY.D_E_L_E_T_ = '' 
		WHERE PZ6_PERFIM BETWEEN %exp:cDtFimDe%  and %exp:cDtFimAte% 
		AND PZ6.PZ6_DTULRE > PZ6.PZ6_PERFIM 
		AND PZ6.PZ6_BONUS = 0
		AND PZ6.D_E_L_E_T_ = ''
		ORDER BY PZ6.PZ6_CODIGO, PZ6.PZ6_PERFIM
		EndSQL

	ENDIF
	
	(cTab1)->(DbGoTop())  
	Count To nTotReg 
	(cTab1)->(DbGoTop())

	If (cTab1)->(Eof())
		MsgInfo('Nenhum Registro encontrado para o Workflow de Metas não alcançadas')
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

		SendMail(cDir + cFile)

		nContReg++
		IncProc("Carregando e-mail - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

	endif

	RestArea(aAreaX)
return


Static Function fProcExcel()

	Local aAreaY  := GetArea() 
	Local cTab2	  := GetNextAlias()
	local aAux	  := {}

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


Static Function SendMail(_cArquivo,_cNumSI)

	Local cTo      := U_EmailWF("FACOWF02",CEMPANT)
	local lRet	   := .F.
	local cSubject := ''

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))
	cSubject := "AO com metas não Alcançadas x Lançamentos Contabeis - "+ AllTrim(SM0->M0_NOME)

	if !Empty(cTo)
		lRet := U_BIAEnvMail(, cTo, cSubject, "Segue (Anexo) planilha com a lista de lançamentos de AO, com metas não Alcançadas.", "", _cArquivo)
	endif

Return lRet
