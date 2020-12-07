#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIA652
@author Luana Marin Ribeiro
@since 23/04/2018
@version 1.0
@description Relatório Solicitações de Compras Pendentes
@type function
/*/

User Function BIA654()	
	Private Enter := CHR(13)+CHR(10)
	Private cSql := ""
	
	Private _cTipoData
	Private _cDataDe
	Private _cDataAte
	Private _cDirDest

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	private aPergs := {}
	Private oExcel      := nil 

	If !ValidPerg()
		Return
	EndIf

	fQryDados()

return

Static Function ValidPerg()

	local cLoad	    := "BIA654"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.
	
	MV_PAR01 := SPACE(1)
	MV_PAR02 := STOD('')
	MV_PAR03 := STOD('')
	MV_PAR04 := SPACE(100)
	
	aAdd( aPergs ,{2,"Data", MV_PAR01 , {'E=Emissão'} ,50,"",.T.})
	aAdd( aPergs ,{1,"Data De", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Data Até", MV_PAR03, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{6,"Pasta destino", MV_PAR04, "", "", "", 90, .F., "Diretorio . |*.",, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório Solicitações de Compras Pendentes",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04) 

		if empty(MV_PAR04) 
			MV_PAR04 := AllTrim(GetTempPath()) 	
		endif

	EndIf

Return lRet

Static Function fQryDados()
	Local nTotReg := 0
	local nRegAtu := 0

	local cCab1Fon := 'Calibri' 
	local cCab1TamF := 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun := '#4F81BD'

	local cFonte1 := 'Arial'
	local nTamFont1 := 12   
	local cCorFont1 := '#FFFFFF'
	local cCorFun1 := '#4F81BD'

	local cFonte2 := 'Arial'
	local nTamFont2 := 8   
	local cCorFont2 := '#000000'
	local cCorFun2 := '#B8CCE4'

	local cArqXML := "BIA654_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	
	_cTipoData := MV_PAR01
	_cDataDe :=	DtoS(MV_PAR02)
	_cDataAte := DtoS(MV_PAR03)
	_cDirDest := MV_PAR04
	

	MontaQry(_cDataDe, _cDataAte, _cTipoData)
	TcQuery cSql Alias "QRY" New

	QRY->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	QRY->(DbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio",{20,60,60,60,40,60,200,40,65,65,65,40,200,200,150,60,300},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula("BIANCOGRES/INCESA",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,14) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,14) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório Solicitações de Compras Pendentes",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,14)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	
	oExcel:AddCelula('EMPRESA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('Nº SC. BIZAGI',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('Nº SC. PROTHEUS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ITEM SC.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD. PROD.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PRODUTO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD. GRUPO PROD.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. EMISSÃO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. APROVAÇÃO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. INCLUSÃO SC.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('MAT. SOL.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('SOLICITANTE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('APROVADOR',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ATIVIDADE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ALMOX.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	
	While QRY->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()
		
		oExcel:AddCelula(QRY->EMPRESA, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_BZ, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_NUM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_ITEM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_COD_PROD, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_DESC, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PROD_GRUPO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_EMIS, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_DT_APROV, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_DT_INC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FUNC_MAT, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SOLICIT, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_APROV, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC_ATIV, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ALMOX, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		
		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		QRY->(DbSkip())

	EndDo
	fGeraParametros()
	oExcel:SaveXml(Alltrim(_cDirDest),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	QRY->(dbCloseArea())

Return

Static Function MontaQry(_cDataDe, _cDataAte, _cTipoData)
	cSql := ""                                                              
	
	cSql += "" + Enter
	
	cSql += "SELECT 'BIANCOGRES' AS EMPRESA" + Enter
	cSql += "	, C1_YBIZAGI AS SC_BZ" + Enter
	cSql += "	, C1_NUM AS SC_NUM" + Enter
	cSql += "	, C1_ITEM AS SC_ITEM" + Enter
	cSql += "	, C1_PRODUTO AS SC_COD_PROD" + Enter
	cSql += "	, C1_DESCRI AS SC_DESC" + Enter
	cSql += "	, B1_GRUPO AS PROD_GRUPO" + Enter
	cSql += "	, (CASE C1_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C1_EMISSAO),103) END) AS SC_EMIS" + Enter
	cSql += "	, (CASE C1_YDATHOR WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SUBSTRING(C1_YDATHOR,1,8)),103) END) AS SC_DT_APROV" + Enter
	cSql += "	, (CASE C1_YDTINCB WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C1_YDTINCB),103) END) AS SC_DT_INC" + Enter
	cSql += "	, C1_YMAT AS FUNC_MAT" + Enter
	cSql += "	, ISNULL(RA_NOME, C1_SOLICIT) AS SOLICIT" + Enter
	cSql += "	, '' AS SC_APROV" + Enter
	cSql += "	, '' AS SC_ATIV" + Enter
	cSql += "	, C1_LOCAL AS ALMOX" + Enter
	cSql += "FROM SC1010 SC1 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_COD = SC1.C1_PRODUTO AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SRA010 SRA WITH(NOLOCK) ON RA_MAT = C1_YMAT AND SRA.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE C1_FILIAL = '01'" + Enter
	cSql += "	AND C1_RESIDUO <> 'S'" + Enter
	cSql += "	AND C1_COTACAO <> 'IMPORX'" + Enter
	cSql += "	AND SC1.C1_APROV NOT IN ('B','R')" + Enter
	cSql += "	AND ((C1_PEDIDO = ''" + Enter
	cSql += "			AND SC1.C1_QUJE = 0" + Enter
	cSql += "			AND NOT EXISTS (SELECT *" + Enter
	cSql += "				FROM SC7010" + Enter
	cSql += "				WHERE C7_FILIAL = '01'" + Enter
	cSql += "					AND C7_NUMSC = C1_NUM" + Enter
	cSql += "					AND C7_PRODUTO = C1_PRODUTO" + Enter
	cSql += "					AND C7_ITEMSC  = C1_ITEM" + Enter
	cSql += "					AND C7_RESIDUO <> 'S'" + Enter
	cSql += "					AND D_E_L_E_T_ = ''))" + Enter
	cSql += "		OR (C1_PEDIDO <> ''" + Enter
	cSql += "			AND SC1.C1_QUJE <> SC1.C1_QUANT" + Enter
	cSql += "			AND EXISTS (SELECT *" + Enter
	cSql += "				FROM SC7010" + Enter
	cSql += "				WHERE C7_FILIAL = '01'" + Enter
	cSql += "					AND C7_NUMSC = C1_NUM" + Enter
	cSql += "					AND C7_PRODUTO = C1_PRODUTO" + Enter
	cSql += "					AND C7_ITEMSC  = C1_ITEM" + Enter
	cSql += "					AND C7_RESIDUO <> 'S'" + Enter
	cSql += "					AND D_E_L_E_T_ = '')))" + Enter
	If _cTipoData == "E"
		cSql += "	AND SC1.C1_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "	AND SC1.D_E_L_E_T_ = ''" + Enter
	cSql += "	AND B1_GRUPO <> 'PA'" + Enter
	cSql += "UNION" + Enter
	cSql += "SELECT 'INCESA' AS EMPRESA" + Enter
	cSql += "	, C1_YBIZAGI AS SC_BZ" + Enter
	cSql += "	, C1_NUM AS SC_NUM" + Enter
	cSql += "	, C1_ITEM AS SC_ITEM" + Enter
	cSql += "	, C1_PRODUTO AS SC_COD_PROD" + Enter
	cSql += "	, C1_DESCRI AS SC_DESC" + Enter
	cSql += "	, B1_GRUPO AS PROD_GRUPO" + Enter
	cSql += "	, (CASE C1_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C1_EMISSAO),103) END) AS SC_EMIS" + Enter
	cSql += "	, (CASE C1_YDATHOR WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SUBSTRING(C1_YDATHOR,1,8)),103) END) AS SC_DT_APROV" + Enter
	cSql += "	, (CASE C1_YDTINCB WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,C1_YDTINCB),103) END) AS SC_DT_INC" + Enter
	cSql += "	, C1_YMAT AS FUNC_MAT" + Enter
	cSql += "	, ISNULL(RA_NOME, C1_SOLICIT) AS SOLICIT" + Enter
	cSql += "	, '' AS SC_APROV" + Enter
	cSql += "	, '' AS SC_ATIV" + Enter
	cSql += "	, C1_LOCAL AS ALMOX" + Enter
	cSql += "FROM SC1050 SC1 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON B1_COD = SC1.C1_PRODUTO AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SRA050 SRA WITH(NOLOCK) ON RA_MAT = C1_YMAT AND SRA.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE C1_FILIAL = '01'" + Enter
	cSql += "	AND C1_RESIDUO <> 'S'" + Enter
	cSql += "	AND C1_COTACAO <> 'IMPORX'" + Enter
	cSql += "	AND SC1.C1_APROV NOT IN ('B','R')" + Enter
	cSql += "	AND ((C1_PEDIDO = ''" + Enter
	cSql += "			AND SC1.C1_QUJE = 0" + Enter
	cSql += "			AND NOT EXISTS (SELECT *" + Enter
	cSql += "				FROM SC7050" + Enter
	cSql += "				WHERE C7_FILIAL = '01'" + Enter
	cSql += "					AND C7_NUMSC = C1_NUM" + Enter
	cSql += "					AND C7_PRODUTO = C1_PRODUTO" + Enter
	cSql += "					AND C7_ITEMSC  = C1_ITEM" + Enter
	cSql += "					AND C7_RESIDUO <> 'S'" + Enter
	cSql += "					AND D_E_L_E_T_ = ''))" + Enter
	cSql += "		OR (C1_PEDIDO <> ''" + Enter
	cSql += "			AND SC1.C1_QUJE <> SC1.C1_QUANT" + Enter
	cSql += "			AND EXISTS (SELECT *" + Enter
	cSql += "				FROM SC7050" + Enter
	cSql += "				WHERE C7_FILIAL = '01'" + Enter
	cSql += "					AND C7_NUMSC = C1_NUM" + Enter
	cSql += "					AND C7_PRODUTO = C1_PRODUTO" + Enter
	cSql += "					AND C7_ITEMSC  = C1_ITEM" + Enter
	cSql += "					AND C7_RESIDUO <> 'S'" + Enter
	cSql += "					AND D_E_L_E_T_ = '')))" + Enter
	If _cTipoData == "E"
		cSql += "	AND SC1.C1_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "	AND SC1.D_E_L_E_T_ = ''" + Enter
	cSql += "	AND B1_GRUPO <> 'PA'" + Enter
	cSql += "UNION" + Enter
	cSql += "SELECT (CASE EMP WHEN '01' THEN 'BIANCOGRES' WHEN '05' THEN 'INCESA' WHEN '13' THEN 'MUNDI' WHEN '14' THEN 'VITCER' WHEN '06' THEN 'JK' ELSE '' END) AS EMPRESA" + Enter
	cSql += "	, PROCE collate Latin1_General_BIN AS SC_BZ" + Enter
	cSql += "	, '' AS SC_NUM" + Enter
	cSql += "	, '' AS SC_ITEM" + Enter
	cSql += "	, '' AS SC_COD_PROD" + Enter
	cSql += "	, '' AS SC_DESC" + Enter
	cSql += "	, '' AS PROD_GRUPO" + Enter
	cSql += "	, (CASE SC_DT_EMIS collate Latin1_General_BIN WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC_DT_EMIS collate Latin1_General_BIN),103) END) AS SC_EMIS" + Enter
	cSql += "	, (CASE SC_DT_APROV WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SUBSTRING(SC_DT_APROV,1,8)),103) END) AS SC_DT_APROV" + Enter
	cSql += "	, '' AS SC_DT_INC" + Enter
	cSql += "	, '' AS FUNC_MAT" + Enter
	cSql += "	, SC_SOLIC collate Latin1_General_BIN AS SOLICIT" + Enter
	cSql += "	, SC_APROV AS SC_APROV" + Enter
	cSql += "	, SC_ATIV AS SC_ATIV" + Enter
	cSql += "	, ARMAZEM collate Latin1_General_BIN AS ALMOX" + Enter
	cSql += "FROM ZEUS.BIZAGIPRD.dbo.VW_SC_ABERTA" + Enter
	If _cTipoData == "E"
		cSql += "WHERE SC_DT_EMIS BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
Return

//Gera parametros
Static Function fGeraParametros()

	local nCont		 := 0 
	local cCorFundo  := ""
	local cTitulo	 := 'Parametros'

	local cFonte1    := 'Calibri' 
	local nTamFont1  := 9
	local cCorFont1  := '#FFFFFF'
	local cCorFund1  := '#4F81BD'

	local cFonte2    := 'Arial' 
	local nTamFont2  := 9
	local cCorFont2  := '#000000'

	aPergs[1,3] := _cTipoData
	aPergs[2,3] := DtoC(StoD(_cDataDe)) 
	aPergs[3,3] := DtoC(StoD(_cDataAte))  
	aPergs[4,3] := _cDirDest     

	oExcel:AddPlanilha('Parametros',{30,80,120,270})
	oExcel:AddLinha(18)
	oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

	for nCont := 1 to Len(aPergs)	

		if MOD(nCont,2) > 0 
			cCorFundo := '#DCE6F1'	
		else
			cCorFundo := '#B8CCE4'	
		endif	  

		oExcel:AddLinha(16) 
		oExcel:AddCelula()
		oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

	next aPergs

Return 
