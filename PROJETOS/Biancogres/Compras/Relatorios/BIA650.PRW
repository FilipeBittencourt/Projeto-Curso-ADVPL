#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIA650
@author Luana Marin Ribeiro
@since 03/01/2018
@version 1.0
@description Relatório OTIF
@type function
/*/

User Function BIA650()	
	Private Enter := CHR(13)+CHR(10)
	Private cSql := ""
	
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

	local cLoad	    := "BIA650"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := SPACE(100)
	
	aAdd( aPergs ,{1,"Data chegada de", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Data chegada até", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{6,"Pasta destino", MV_PAR03, "", "", "", 90, .F., "Diretorio . |*.",, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório OTIF",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 

		if empty(MV_PAR03) 
			MV_PAR03 := AllTrim(GetTempPath()) 	
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

	local cArqXML := "BIA650_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	
	_cDataDe :=	DtoS(MV_PAR01)
	_cDataAte := DtoS(MV_PAR02)
	_cDirDest := MV_PAR03
	

	MontaQry(_cDataDe, _cDataAte)
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

	oExcel:AddPlanilha("Relatorio",{20,40,60,60,60,400,35,60,400,45,200,65,65,65,65,65,65,65,65,65,65,65,65,65,60,60,45,150,45,150,150,65,45,45,45,300},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula("BIANCOGRES/INCESA",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,33) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,33) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório OTIF ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,33)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	
	
	oExcel:AddCelula('EMPRESA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PEDIDO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ITEM PEDIDO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD. FORN.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORNECEDOR',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('LOJA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD.PROD.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PRODUTO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD. GRUPO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('GRUPO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANTIDADE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. UNIT.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. TOTAL',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANT.ENT.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. EMISSAO NF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. CHEGADA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. NECESSI.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. ENVIO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. ENTREGA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. FOLLOWUP',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. ENTRADA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. DIGIT.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANT.FOLLOWUP',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ITEM SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('RESIDUO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('APROVADOR',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('STATUS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COMPRADOR',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FOLLOW',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANT. NF ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ON TIME',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('IN FULL',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('OTIF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	
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
		oExcel:AddCelula(QRY->PEDIDO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ITEM_PEDIDO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_FORN, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FORNECEDOR, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->LOJA, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_PROD, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PRODUTO, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_GRUPO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->GRUPO, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANTIDADE, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_UNIT, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_TOTAL, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANT_ENT, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_EMISSAO_NF, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_CHEGADA, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_NECESSI, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_ENVIO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_ENTREGA, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_FOLLOWUP, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_ENTRADA, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_DIGIT, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANT_FOLLOWUP, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ITEM_SC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->RESIDUO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->APROVADOR, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->STATU, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COMPRADOR, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FOLLOW, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANT_NF_ITEM, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ON_TIME, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->IN_FULL, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->OTIF, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		QRY->(DbSkip())

	EndDo
	fGeraParametros()
	oExcel:SaveXml(Alltrim(_cDirDest),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	QRY->(dbCloseArea())

Return

Static Function MontaQry(_cDataDe, _cDataAte)
	cSql := ""                                                              
	
	cSql += "SELECT 'BIANCOGRES' AS EMPRESA" + Enter
	cSql += "	, SC7.C7_NUM AS PEDIDO" + Enter
	cSql += "	, SC7.C7_ITEM AS ITEM_PEDIDO" + Enter
	cSql += "	, SC7.C7_FORNECE AS COD_FORN" + Enter
	cSql += "	, SA2.A2_NOME AS FORNECEDOR" + Enter
	cSql += "	, SA2.A2_LOJA AS LOJA" + Enter
	cSql += "	, SC7.C7_PRODUTO AS COD_PROD" + Enter
	cSql += "	, SC7.C7_DESCRI AS PRODUTO" + Enter
	cSql += "	, SBM.BM_GRUPO AS COD_GRUPO" + Enter
	cSql += "	, SBM.BM_DESC AS GRUPO" + Enter
	cSql += "	, SC7.C7_QUANT AS QUANTIDADE" + Enter
	cSql += "	, SC7.C7_PRECO AS VL_UNIT" + Enter
	cSql += "	, SC7.C7_TOTAL AS VL_TOTAL" + Enter
	cSql += "	, SC7.C7_QUJE AS QUANT_ENT" + Enter
	cSql += "	, (CASE MAX(SD1.D1_EMISSAO) WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,MAX(SD1.D1_EMISSAO)),103) END) AS DT_EMISSAO_NF" + Enter
	cSql += "	, (CASE SC7.C7_YDATCHE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATCHE),103) END) AS DT_CHEGADA" + Enter
	cSql += "	, (CASE SC7.C7_YDTNECE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTNECE),103) END) AS DT_NECESSI" + Enter
	cSql += "	, (CASE SC7.C7_YDTENV WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTENV),103) END) AS DT_ENVIO" + Enter
	cSql += "	, (CASE SC7.C7_DATPRF WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_DATPRF),103) END) AS DT_ENTREGA" + Enter
	cSql += "	, (CASE SC7.C7_YDATEMA WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATEMA),103) END) AS DT_FOLLOWUP" + Enter
	cSql += "	, (CASE MAX(SD1.D1_YDTENT) WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,MAX(SD1.D1_YDTENT)),103) END) AS DT_ENTRADA" + Enter
	cSql += "	, (CASE MAX(SD1.D1_DTDIGIT) WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,MAX(SD1.D1_DTDIGIT)),103) END) AS DT_DIGIT" + Enter
	cSql += "	, SC7.C7_YQUAEMA AS QUANT_FOLLOWUP" + Enter
	cSql += "	, SC7.C7_NUMSC AS SC" + Enter
	cSql += "	, SC7.C7_ITEMSC AS ITEM_SC" + Enter
	cSql += "	, SC7.C7_RESIDUO AS RESIDUO" + Enter
	cSql += "	, ISNULL(SAK.AK_NOME,'') AS APROVADOR" + Enter
	cSql += "	, SC7.C7_CONAPRO AS STATU" + Enter
	cSql += "	, SY1.Y1_NOME AS COMPRADOR" + Enter
	cSql += "	, SC7.C7_YFOLLOW AS FOLLOW" + Enter
	cSql += "	, SUM(SD1.D1_QUANT) AS QUANT_NF_ITEM" + Enter
	cSql += "	, (CASE WHEN (CASE WHEN MAX(SD1.D1_YDTENT) = '' THEN MAX(SD1.D1_DTDIGIT) ELSE MAX(SD1.D1_YDTENT) END) <= SC7.C7_YDATCHE THEN 1 ELSE 0 END) AS ON_TIME" + Enter
	cSql += "	, (CASE WHEN SC7.C7_QUJE >= (SC7.C7_QUANT * 0.97) THEN 1 ELSE (CASE SC7.C7_RESIDUO WHEN 'S' THEN 1 ELSE 0 END) END) AS IN_FULL" + Enter
	cSql += "	, (CASE WHEN" + Enter
	cSql += "		(CASE WHEN (CASE WHEN MAX(SD1.D1_YDTENT) = '' THEN MAX(SD1.D1_DTDIGIT) ELSE MAX(SD1.D1_YDTENT) END) <= SC7.C7_YDATCHE THEN 1 ELSE 0 END)" + Enter
	cSql += "		+" + Enter
	cSql += "		(CASE WHEN SC7.C7_QUJE >= (SC7.C7_QUANT * 0.97) THEN 1 ELSE (CASE SC7.C7_RESIDUO WHEN 'S' THEN 1 ELSE 0 END) END)" + Enter
	cSql += "		= 2 THEN 1 ELSE 0 END) AS OTIF" + Enter
	cSql += "FROM SC7010 SC7 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_PRODUTO = SB1.B1_COD" + Enter
	cSql += "		AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SBM010 SBM WITH(NOLOCK) ON SBM.BM_FILIAL = ''" + Enter
	cSql += "		 AND SB1.B1_GRUPO = SBM.BM_GRUPO" + Enter
	cSql += "		 AND SBM.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SD1010 SD1 WITH(NOLOCK) ON SD1.D1_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUM = SD1.D1_PEDIDO" + Enter
	cSql += "		AND SC7.C7_ITEM = SD1.D1_ITEMPC" + Enter
	cSql += "		AND SC7.C7_FORNECE = SD1.D1_FORNECE" + Enter
	cSql += "		AND SC7.C7_LOJA = SD1.D1_LOJA" + Enter
	cSql += "		AND SD1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SA2010 SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_FORNECE = SA2.A2_COD" + Enter
	cSql += "		AND SC7.C7_LOJA = SA2.A2_LOJA" + Enter
	cSql += "		AND SA2.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SY1010 SY1 WITH(NOLOCK) ON Y1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_USER = SY1.Y1_USER" + Enter
	cSql += "		AND SY1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SCR010 SCR WITH(NOLOCK) ON SCR.CR_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUM = SCR.CR_NUM" + Enter
	cSql += "		AND SCR.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SAK010 SAK WITH(NOLOCK) ON SAK.AK_FILIAL = '01'" + Enter
	cSql += "		AND SCR.CR_APROV = SAK.AK_COD" + Enter
	cSql += "		AND SAK.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE SC7.C7_FILIAL = '01'" + Enter
	cSql += "	AND SC7.C7_YDATCHE BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	cSql += "	AND (CASE SC7.C7_RESIDUO WHEN 'S' THEN (CASE WHEN SC7.C7_QUJE > 0 THEN 1 ELSE 0 END) ELSE 1 END) = 1" + Enter	
	cSql += "	AND SC7.D_E_L_E_T_ = ''" + Enter
	cSql += "GROUP BY SC7.C7_NUM" + Enter
	cSql += "	, SC7.C7_ITEM" + Enter
	cSql += "	, SC7.C7_FORNECE" + Enter
	cSql += "	, SA2.A2_NOME" + Enter
	cSql += "	, SA2.A2_LOJA" + Enter 
	cSql += "	, SC7.C7_PRODUTO" + Enter
	cSql += "	, SC7.C7_DESCRI" + Enter	
	cSql += "	, SBM.BM_GRUPO" + Enter
	cSql += "	, SBM.BM_DESC" + Enter
	cSql += "	, SC7.C7_QUANT" + Enter
	cSql += "	, SC7.C7_PRECO" + Enter
	cSql += "	, SC7.C7_TOTAL" + Enter
	cSql += "	, SC7.C7_QUJE" + Enter
	cSql += "	, SC7.C7_YDATCHE" + Enter
	cSql += "	, SC7.C7_YDTNECE" + Enter
	cSql += "	, SC7.C7_YDTENV" + Enter
	cSql += "	, SC7.C7_DATPRF" + Enter
	cSql += "	, SC7.C7_YDATEMA" + Enter
	cSql += "	, SC7.C7_YQUAEMA" + Enter
	cSql += "	, SC7.C7_NUMSC" + Enter
	cSql += "	, SC7.C7_ITEMSC" + Enter
	cSql += "	, SC7.C7_RESIDUO" + Enter
	cSql += "	, SAK.AK_NOME" + Enter
	cSql += "	, SC7.C7_CONAPRO" + Enter
	cSql += "	, SY1.Y1_NOME" + Enter
	cSql += "	, SC7.C7_YFOLLOW" + Enter
	cSql += "UNION" + Enter
	cSql += "SELECT 'INCESA' AS EMPRESA" + Enter
	cSql += "	, SC7.C7_NUM AS PEDIDO" + Enter
	cSql += "	, SC7.C7_ITEM AS ITEM_PEDIDO" + Enter
	cSql += "	, SC7.C7_FORNECE AS COD_FORN" + Enter
	cSql += "	, SA2.A2_NOME AS FORNECEDOR" + Enter
	cSql += "	, SA2.A2_LOJA AS LOJA" + Enter
	cSql += "	, SC7.C7_PRODUTO AS COD_PROD" + Enter
	cSql += "	, SC7.C7_DESCRI AS PRODUTO" + Enter
	cSql += "	, SBM.BM_GRUPO AS COD_GRUPO" + Enter
	cSql += "	, SBM.BM_DESC AS GRUPO" + Enter
	cSql += "	, SC7.C7_QUANT AS QUANTIDADE" + Enter
	cSql += "	, SC7.C7_PRECO AS VL_UNIT" + Enter
	cSql += "	, SC7.C7_TOTAL AS VL_TOTAL" + Enter
	cSql += "	, SC7.C7_QUJE AS QUANT_ENT" + Enter
	cSql += "	, (CASE MAX(SD1.D1_EMISSAO) WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,MAX(SD1.D1_EMISSAO)),103) END) AS DT_EMISSAO_NF" + Enter
	cSql += "	, (CASE SC7.C7_YDATCHE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATCHE),103) END) AS DT_CHEGADA" + Enter
	cSql += "	, (CASE SC7.C7_YDTNECE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTNECE),103) END) AS DT_NECESSI" + Enter
	cSql += "	, (CASE SC7.C7_YDTENV WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTENV),103) END) AS DT_ENVIO" + Enter
	cSql += "	, (CASE SC7.C7_DATPRF WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_DATPRF),103) END) AS DT_ENTREGA" + Enter
	cSql += "	, (CASE SC7.C7_YDATEMA WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATEMA),103) END) AS DT_FOLLOWUP" + Enter
	cSql += "	, (CASE MAX(SD1.D1_YDTENT) WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,MAX(SD1.D1_YDTENT)),103) END) AS DT_ENTRADA" + Enter
	cSql += "	, (CASE MAX(SD1.D1_DTDIGIT) WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,MAX(SD1.D1_DTDIGIT)),103) END) AS DT_DIGIT" + Enter
	cSql += "	, SC7.C7_YQUAEMA AS QUANT_FOLLOWUP" + Enter
	cSql += "	, SC7.C7_NUMSC AS SC" + Enter
	cSql += "	, SC7.C7_ITEMSC AS ITEM_SC" + Enter
	cSql += "	, SC7.C7_RESIDUO AS RESIDUO" + Enter
	cSql += "	, ISNULL(SAK.AK_NOME,'') AS APROVADOR" + Enter
	cSql += "	, SC7.C7_CONAPRO AS STATU" + Enter
	cSql += "	, SY1.Y1_NOME AS COMPRADOR" + Enter
	cSql += "	, SC7.C7_YFOLLOW AS FOLLOW" + Enter
	cSql += "	, SUM(SD1.D1_QUANT) AS QUANT_NF_ITEM" + Enter
	cSql += "	, (CASE WHEN (CASE WHEN MAX(SD1.D1_YDTENT) = '' THEN MAX(SD1.D1_DTDIGIT) ELSE MAX(SD1.D1_YDTENT) END) <= SC7.C7_YDATCHE THEN 1 ELSE 0 END) AS ON_TIME" + Enter
	cSql += "	, (CASE WHEN SC7.C7_QUJE >= (SC7.C7_QUANT * 0.97) THEN 1 ELSE (CASE SC7.C7_RESIDUO WHEN 'S' THEN 1 ELSE 0 END) END) AS IN_FULL" + Enter
	cSql += "	, (CASE WHEN" + Enter
	cSql += "		(CASE WHEN (CASE WHEN MAX(SD1.D1_YDTENT) = '' THEN MAX(SD1.D1_DTDIGIT) ELSE MAX(SD1.D1_YDTENT) END) <= SC7.C7_YDATCHE THEN 1 ELSE 0 END)" + Enter
	cSql += "		+" + Enter
	cSql += "		(CASE WHEN SC7.C7_QUJE >= (SC7.C7_QUANT * 0.97) THEN 1 ELSE (CASE SC7.C7_RESIDUO WHEN 'S' THEN 1 ELSE 0 END) END)" + Enter
	cSql += "		= 2 THEN 1 ELSE 0 END) AS OTIF" + Enter
	cSql += "FROM SC7050 SC7 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_PRODUTO = SB1.B1_COD" + Enter
	cSql += "		AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SBM010 SBM WITH(NOLOCK) ON SBM.BM_FILIAL = ''" + Enter
	cSql += " 		 AND SB1.B1_GRUPO = SBM.BM_GRUPO" + Enter
	cSql += "		 AND SBM.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SD1050 SD1 WITH(NOLOCK) ON SD1.D1_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUM = SD1.D1_PEDIDO" + Enter
	cSql += "		AND SC7.C7_ITEM = SD1.D1_ITEMPC" + Enter
	cSql += "		AND SC7.C7_FORNECE = SD1.D1_FORNECE" + Enter
	cSql += "		AND SC7.C7_LOJA = SD1.D1_LOJA" + Enter
	cSql += "		AND SD1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SA2010 SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_FORNECE = SA2.A2_COD" + Enter
	cSql += "		AND SC7.C7_LOJA = SA2.A2_LOJA" + Enter
	cSql += "		AND SA2.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SY1050 SY1 WITH(NOLOCK) ON Y1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_USER = SY1.Y1_USER" + Enter
	cSql += "		AND SY1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SCR050 SCR WITH(NOLOCK) ON SCR.CR_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUM = SCR.CR_NUM" + Enter
	cSql += "		AND SCR.D_E_L_E_T_ = ''" + Enter
	cSql += " 	LEFT JOIN SAK050 SAK WITH(NOLOCK) ON SAK.AK_FILIAL = '01'" + Enter
	cSql += "		AND SCR.CR_APROV = SAK.AK_COD" + Enter
	cSql += "		AND SAK.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE SC7.C7_FILIAL = '01'" + Enter
	cSql += "	AND SC7.C7_YDATCHE BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	cSql += "	AND (CASE SC7.C7_RESIDUO WHEN 'S' THEN (CASE WHEN SC7.C7_QUJE > 0 THEN 1 ELSE 0 END) ELSE 1 END) = 1" + Enter
	cSql += "	AND SC7.D_E_L_E_T_ = ''" + Enter
	cSql += "GROUP BY SC7.C7_NUM" + Enter
	cSql += "	, SC7.C7_ITEM" + Enter
	cSql += "	, SC7.C7_FORNECE" + Enter
	cSql += "	, SA2.A2_NOME" + Enter
	cSql += "	, SA2.A2_LOJA" + Enter
	cSql += "	, SC7.C7_PRODUTO" + Enter
	cSql += "	, SC7.C7_DESCRI" + Enter
	cSql += "	, SBM.BM_GRUPO" + Enter
	cSql += "	, SBM.BM_DESC" + Enter
	cSql += "	, SC7.C7_QUANT" + Enter
	cSql += "	, SC7.C7_PRECO" + Enter
	cSql += "	, SC7.C7_TOTAL" + Enter
	cSql += "	, SC7.C7_QUJE" + Enter
	cSql += "	, SC7.C7_YDATCHE" + Enter
	cSql += "	, SC7.C7_YDTNECE" + Enter
	cSql += "	, SC7.C7_YDTENV" + Enter
	cSql += "	, SC7.C7_DATPRF" + Enter
	cSql += "	, SC7.C7_YDATEMA" + Enter
	cSql += "	, SC7.C7_YQUAEMA" + Enter
	cSql += "	, SC7.C7_NUMSC" + Enter
	cSql += "	, SC7.C7_ITEMSC" + Enter
	cSql += "	, SC7.C7_RESIDUO" + Enter
	cSql += "	, SAK.AK_NOME" + Enter
	cSql += "	, SC7.C7_CONAPRO" + Enter
	cSql += "	, SY1.Y1_NOME" + Enter
	cSql += "	, SC7.C7_YFOLLOW" + Enter
	cSql += "ORDER BY EMPRESA" + Enter
	cSql += "	, PEDIDO" + Enter
	cSql += "	, ITEM_PEDIDO" + Enter

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

	aPergs[1,3] := DtoC(StoD(_cDataDe)) 
	aPergs[2,3] := DtoC(StoD(_cDataAte))  
	aPergs[3,3] := _cDirDest     

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
