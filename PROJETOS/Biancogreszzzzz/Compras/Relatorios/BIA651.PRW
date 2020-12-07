#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIA651
@author Luana Marin Ribeiro
@since 03/01/2018
@version 1.0
@description Relatório Linha do Tempo Interna do Pedido
@type function
/*/

User Function BIA651()	
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

	local cLoad	    := "BIA651"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.
	
	MV_PAR01 := SPACE(1)
	MV_PAR02 := STOD('')
	MV_PAR03 := STOD('')
	MV_PAR04 := SPACE(100)
	
	aAdd( aPergs ,{2,"Data", MV_PAR01 , {'E=Emissão SC','A=Aprovação SC','M=Emissão PC','L=Liberação PC','V=Envio PC'} ,50,"",.T.})
	aAdd( aPergs ,{1,"De", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Até", MV_PAR03, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{6,"Pasta destino", MV_PAR04, "", "", "", 90, .F., "Diretorio . |*.",, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório Linha do Tempo Interna do Pedido",,,,,,,,cLoad,.T.,.T.)

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

	local cArqXML := "BIA651_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	
	_cTipoData := MV_PAR01
	_cDataDe :=	DtoS(MV_PAR02)
	_cDataAte := DtoS(MV_PAR03)
	_cDirDest := MV_PAR04
	

	MontaQry(_cDataDe, _cDataAte, _cTipoData)
	TcQuery cSql Alias "QRY" New
	
	nHandle := FCreate(_cDirDest+"arquivo_consultaSQL.txt")
    FWrite(nHandle, cSql)
    FClose(nHandle)

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

	oExcel:AddPlanilha("Relatorio",{20,40,60,60,60,60,60,400,35,60,150,60,400,45,200,65,65,65,65,65,65,65,65,65,65,65,45,150,65,45,150,150,65,65,65,150,65,65,65,65,65,65,300},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula("BIANCOGRES/INCESA",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,40) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,40) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório Linha do Tempo Interna do Pedido",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,40)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()	
	
	oExcel:AddCelula('EMPRESA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ITEM PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ITEM SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD. FORN.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORNECEDOR',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('LOJA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORN. TEL.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORN. EMAIL',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD.PROD.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PRODUTO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD. GRUPO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('GRUPO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANTIDADE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. UNIT.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. TOTAL',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANT.ENT.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. EMISSAO PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. CHEGADA PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. NECESSI. PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. ENVIO PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. ENTREGA PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. FOLLOWUP PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANT.FOLLOWUP',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('RESIDUO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('APROVADOR PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. LIBERACAO PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('STATUS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COMPRADOR',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FOLLOW',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. EMISSAO SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. APROV. SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. INC. PROTHEUS SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('SOLICITANTE SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('APROV. SC - EMISSAO SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('EMISSAO PC - APROV.SC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('LIBERACAO PC - EMISSAO PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ENVIO PC - LIBERACAO PC',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('LINHA DO TEMPO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('MÊS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	
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
		oExcel:AddCelula(QRY->PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ITEM_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ITEM_SC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_FORN, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FORNECEDOR, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->LOJA, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FORN_TEL, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FORN_EMAIL, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_PROD, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PRODUTO, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_GRUPO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->GRUPO, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANTIDADE, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_UNIT, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_TOTAL, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANT_ENT, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_EMIS_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_CHEG_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_NECE_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_ENV_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_ENTR_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_FOLLO_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANT_FOLLO, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->RESIDUO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->APROVADOR_PC, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_LIB_PC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->STATU, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COMPRADOR, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FOLLOW, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_EMIS_SC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_APROV_SC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_INC_PROT_SC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SOLI_SC, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->APROV_SC_EMIS_SC, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->EMIS_PC_APROV_SC, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->LIBE_PC_EMIS_PC, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ENV_PC_LIB_PC, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->LIN_DO_TEMPO, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->MES, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		
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
	
	cSql += "SELECT 'BIANCOGRES' AS EMPRESA" + Enter
	cSql += "	, SC7.C7_NUM AS PC" + Enter
	cSql += "	, SC7.C7_ITEM AS ITEM_PC" + Enter
	cSql += "	, SC1.C1_NUM AS SC" + Enter
	cSql += "	, SC1.C1_ITEM AS ITEM_SC" + Enter
	cSql += "	, SC7.C7_FORNECE AS COD_FORN" + Enter
	cSql += "	, SA2.A2_NOME AS FORNECEDOR" + Enter
	cSql += "	, SA2.A2_LOJA AS LOJA" + Enter
	cSql += "	, SA2.A2_TEL AS FORN_TEL" + Enter
	cSql += "	, SA2.A2_EMAIL AS FORN_EMAIL" + Enter
	cSql += "	, SC7.C7_PRODUTO AS COD_PROD" + Enter
	cSql += "	, SC7.C7_DESCRI AS PRODUTO" + Enter
	cSql += "	, SBM.BM_GRUPO AS COD_GRUPO" + Enter
	cSql += "	, SBM.BM_DESC AS GRUPO" + Enter
	cSql += "	, SC7.C7_QUANT AS QUANTIDADE" + Enter
	cSql += "	, SC7.C7_PRECO AS VL_UNIT" + Enter
	cSql += "	, SC7.C7_TOTAL AS VL_TOTAL" + Enter
	cSql += "	, SC7.C7_QUJE AS QUANT_ENT" + Enter
	cSql += "	, (CASE SC7.C7_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_EMISSAO),103) END) AS DT_EMIS_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDATCHE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATCHE),103) END) AS DT_CHEG_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDTNECE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTNECE),103) END) AS DT_NECE_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDTENV WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTENV),103) END) AS DT_ENV_PC" + Enter
	cSql += "	, (CASE SC7.C7_DATPRF WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_DATPRF),103) END) AS DT_ENTR_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDATEMA WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATEMA),103) END) AS DT_FOLLO_PC" + Enter
	cSql += "	, SC7.C7_YQUAEMA AS QUANT_FOLLO" + Enter
	cSql += "	, SC7.C7_RESIDUO AS RESIDUO" + Enter
	cSql += "	, SAK.AK_NOME AS APROVADOR_PC" + Enter
	cSql += "	, (CASE SCR.CR_DATALIB WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SCR.CR_DATALIB),103) END) AS DT_LIB_PC" + Enter
	cSql += "	, SC7.C7_CONAPRO AS STATU" + Enter
	cSql += "	, SY1.Y1_NOME AS COMPRADOR" + Enter
	cSql += "	, SC7.C7_YFOLLOW AS FOLLOW" + Enter
	cSql += "	, (CASE SC1.C1_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC1.C1_EMISSAO),103) END) AS DT_EMIS_SC" + Enter
	cSql += "	, (CASE SC1.C1_YDATHOR WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SUBSTRING(SC1.C1_YDATHOR,1,8)),103) END) AS DT_APROV_SC" + Enter
	cSql += "	, (CASE SC1.C1_YDTINCB WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC1.C1_YDTINCB),103) END) AS DT_INC_PROT_SC" + Enter
	cSql += "	, SC1.C1_SOLICIT AS SOLI_SC" + Enter
	cSql += "	, (CASE SC1.C1_YDATHOR WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC1.C1_EMISSAO, SUBSTRING(SC1.C1_YDATHOR,1,8))) END) AS APROV_SC_EMIS_SC" + Enter
	cSql += "	, (CASE WHEN (CASE SC1.C1_YDATHOR WHEN '' THEN  DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO) ELSE DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO) END) < 0 THEN '' ELSE (CASE SC1.C1_YDATHOR WHEN '' THEN CONVERT(VARCHAR(10),DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO)) ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO)) END) END) AS EMIS_PC_APROV_SC" + Enter
	cSql += "	, (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' OR DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB)) END) AS LIBE_PC_EMIS_PC" + Enter
	cSql += "	, (CASE WHEN SC7.C7_YDTENV IS NULL OR SC7.C7_YDTENV = '' THEN '' ELSE (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' THEN (CASE WHEN DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV)) END) ELSE (CASE WHEN DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV)) END) END) END) AS ENV_PC_LIB_PC" + Enter
	cSql += "	, (CASE WHEN (CASE WHEN SC7.C7_YDTENV IS NULL OR SC7.C7_YDTENV = '' THEN '' ELSE (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' THEN (CASE WHEN DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV)) END) ELSE (CASE WHEN DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV)) END) END) END) = '' THEN" + Enter
	cSql += "			''" + Enter
	cSql += "		ELSE" + Enter
	cSql += "			CONVERT(VARCHAR(10),(CASE SC1.C1_YDATHOR WHEN '' THEN 0 ELSE DATEDIFF(DD, SC1.C1_EMISSAO, SUBSTRING(SC1.C1_YDATHOR,1,8)) END)" + Enter
	cSql += "				+ (CASE WHEN (CASE SC1.C1_YDATHOR WHEN '' THEN  DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO) ELSE DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO) END) < 0 THEN 0 ELSE (CASE SC1.C1_YDATHOR WHEN '' THEN DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO) ELSE DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO) END) END)" + Enter
	cSql += "				+ (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' OR DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB) < 0 THEN 0 ELSE DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB) END)" + Enter
	cSql += "				+ (CASE WHEN SC7.C7_YDTENV IS NULL OR SC7.C7_YDTENV = '' THEN '' ELSE (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' THEN (CASE WHEN DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV)) END) ELSE (CASE WHEN DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV)) END) END) END))" + Enter
	cSql += "		END) AS LIN_DO_TEMPO"
	cSql += "	, DATEPART(MONTH, SC7.C7_EMISSAO) AS MES" + Enter
	cSql += "FROM SC7010 SC7 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SC1010 SC1 WITH(NOLOCK) ON SC1.C1_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUMSC = SC1.C1_NUM" + Enter
	cSql += "		AND SC7.C7_ITEMSC = SC1.C1_ITEM" + Enter
	If _cTipoData == "E"
		cSql += "		AND SC1.C1_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	ElseIf _cTipoData == "A"
		cSql += "		AND SC1.C1_YDATHOR BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "		AND SC1.D_E_L_E_T_ = ' '" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_PRODUTO = SB1.B1_COD" + Enter
	cSql += "		AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SBM010 SBM WITH(NOLOCK) ON SBM.BM_FILIAL = ''" + Enter
	cSql += "		 AND SB1.B1_GRUPO = SBM.BM_GRUPO" + Enter
	cSql += "		 AND SBM.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SA2010 SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_FORNECE = SA2.A2_COD" + Enter
	cSql += "		AND SC7.C7_LOJA = SA2.A2_LOJA" + Enter
	cSql += "		AND SA2.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SY1010 SY1 WITH(NOLOCK) ON Y1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_USER = SY1.Y1_USER" + Enter
	cSql += "		AND SY1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SCR010 SCR WITH(NOLOCK) ON SCR.CR_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUM = SCR.CR_NUM" + Enter
	If _cTipoData == "L"
		cSql += "		AND SCR.CR_DATALIB BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter	
	EndIf
	cSql += "		AND SCR.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SAK010 SAK WITH(NOLOCK) ON SAK.AK_FILIAL = '01'" + Enter
	cSql += "		AND SCR.CR_APROV = SAK.AK_COD" + Enter
	cSql += "		AND SAK.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE SC7.C7_FILIAL = '01'" + Enter
	If _cTipoData == "M"
		cSql += "	AND SC7.C7_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	ElseIf _cTipoData == "V"
		cSql += "	AND SC7.C7_YDTENV BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "	AND SC7.D_E_L_E_T_ = ''" + Enter
	cSql += "UNION" + Enter
	cSql += "SELECT 'INCESA' AS EMPRESA" + Enter
	cSql += "	, SC7.C7_NUM AS PC" + Enter
	cSql += "	, SC7.C7_ITEM AS ITEM_PC" + Enter
	cSql += "	, SC1.C1_NUM AS SC" + Enter
	cSql += "	, SC1.C1_ITEM AS ITEM_SC" + Enter
	cSql += "	, SC7.C7_FORNECE AS COD_FORN" + Enter
	cSql += "	, SA2.A2_NOME AS FORNECEDOR" + Enter
	cSql += "	, SA2.A2_LOJA AS LOJA" + Enter
	cSql += "	, SA2.A2_TEL AS FORN_TEL" + Enter
	cSql += "	, SA2.A2_EMAIL AS FORN_EMAIL" + Enter
	cSql += "	, SC7.C7_PRODUTO AS COD_PROD" + Enter
	cSql += "	, SC7.C7_DESCRI AS PRODUTO" + Enter
	cSql += "	, SBM.BM_GRUPO AS COD_GRUPO" + Enter
	cSql += "	, SBM.BM_DESC AS GRUPO" + Enter
	cSql += "	, SC7.C7_QUANT AS QUANTIDADE" + Enter
	cSql += "	, SC7.C7_PRECO AS VL_UNIT" + Enter
	cSql += "	, SC7.C7_TOTAL AS VL_TOTAL" + Enter
	cSql += "	, SC7.C7_QUJE AS QUANT_ENT" + Enter
	cSql += "	, (CASE SC7.C7_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_EMISSAO),103) END) AS DT_EMIS_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDATCHE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATCHE),103) END) AS DT_CHEG_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDTNECE WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTNECE),103) END) AS DT_NECE_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDTENV WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDTENV),103) END) AS DT_ENV_PC" + Enter
	cSql += "	, (CASE SC7.C7_DATPRF WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_DATPRF),103) END) AS DT_ENTR_PC" + Enter
	cSql += "	, (CASE SC7.C7_YDATEMA WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC7.C7_YDATEMA),103) END) AS DT_FOLLO_PC" + Enter
	cSql += "	, SC7.C7_YQUAEMA AS QUANT_FOLLO" + Enter
	cSql += "	, SC7.C7_RESIDUO AS RESIDUO" + Enter
	cSql += "	, SAK.AK_NOME AS APROVADOR_PC" + Enter
	cSql += "	, (CASE SCR.CR_DATALIB WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SCR.CR_DATALIB),103) END) AS DT_LIB_PC" + Enter
	cSql += "	, SC7.C7_CONAPRO AS STATU" + Enter
	cSql += "	, SY1.Y1_NOME AS COMPRADOR" + Enter
	cSql += "	, SC7.C7_YFOLLOW AS FOLLOW" + Enter
	cSql += "	, (CASE SC1.C1_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC1.C1_EMISSAO),103) END) AS DT_EMIS_SC" + Enter
	cSql += "	, (CASE SC1.C1_YDATHOR WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SUBSTRING(SC1.C1_YDATHOR,1,8)),103) END) AS DT_APROV_SC" + Enter
	cSql += "	, (CASE SC1.C1_YDTINCB WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SC1.C1_YDTINCB),103) END) AS DT_INC_PROT_SC" + Enter
	cSql += "	, SC1.C1_SOLICIT AS SOLI_SC" + Enter
	cSql += "	, (CASE SC1.C1_YDATHOR WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC1.C1_EMISSAO, SUBSTRING(SC1.C1_YDATHOR,1,8))) END) AS APROV_SC_EMIS_SC" + Enter
	cSql += "	, (CASE WHEN (CASE SC1.C1_YDATHOR WHEN '' THEN  DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO) ELSE DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO) END) < 0 THEN '' ELSE (CASE SC1.C1_YDATHOR WHEN '' THEN CONVERT(VARCHAR(10),DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO)) ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO)) END) END) AS EMIS_PC_APROV_SC" + Enter
	cSql += "	, (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' OR DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB)) END) AS LIBE_PC_EMIS_PC" + Enter
	cSql += "	, (CASE WHEN SC7.C7_YDTENV IS NULL OR SC7.C7_YDTENV = '' THEN '' ELSE (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' THEN (CASE WHEN DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV)) END) ELSE (CASE WHEN DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV)) END) END) END) AS ENV_PC_LIB_PC" + Enter
	cSql += "	, (CASE WHEN (CASE WHEN SC7.C7_YDTENV IS NULL OR SC7.C7_YDTENV = '' THEN '' ELSE (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' THEN (CASE WHEN DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV)) END) ELSE (CASE WHEN DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV)) END) END) END) = '' THEN" + Enter
	cSql += "			''" + Enter
	cSql += "		ELSE" + Enter
	cSql += "			CONVERT(VARCHAR(10),(CASE SC1.C1_YDATHOR WHEN '' THEN 0 ELSE DATEDIFF(DD, SC1.C1_EMISSAO, SUBSTRING(SC1.C1_YDATHOR,1,8)) END)" + Enter
	cSql += "				+ (CASE WHEN (CASE SC1.C1_YDATHOR WHEN '' THEN  DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO) ELSE DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO) END) < 0 THEN 0 ELSE (CASE SC1.C1_YDATHOR WHEN '' THEN DATEDIFF(DD, SC1.C1_EMISSAO, SC7.C7_EMISSAO) ELSE DATEDIFF(DD, SUBSTRING(SC1.C1_YDATHOR,1,8), SC7.C7_EMISSAO) END) END)" + Enter
	cSql += "				+ (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' OR DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB) < 0 THEN 0 ELSE DATEDIFF(DD, SC7.C7_EMISSAO, SCR.CR_DATALIB) END)" + Enter
	cSql += "				+ (CASE WHEN SC7.C7_YDTENV IS NULL OR SC7.C7_YDTENV = '' THEN '' ELSE (CASE WHEN SCR.CR_DATALIB IS NULL OR SCR.CR_DATALIB = '' THEN (CASE WHEN DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SC7.C7_EMISSAO, SC7.C7_YDTENV)) END) ELSE (CASE WHEN DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV) < 0 THEN '' ELSE CONVERT(VARCHAR(10),DATEDIFF(DD, SCR.CR_DATALIB, SC7.C7_YDTENV)) END) END) END))" + Enter
	cSql += "		END) AS LIN_DO_TEMPO"
	cSql += "	, DATEPART(MONTH, SC7.C7_EMISSAO) AS MES" + Enter
	cSql += "FROM SC7050 SC7 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SC1050 SC1 WITH(NOLOCK) ON SC1.C1_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUMSC = SC1.C1_NUM" + Enter
	cSql += "		AND SC7.C7_ITEMSC = SC1.C1_ITEM" + Enter
	If _cTipoData == "E"
		cSql += "		AND SC1.C1_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	ElseIf _cTipoData == "A"
		cSql += "		AND SC1.C1_YDATHOR BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "		AND SC1.D_E_L_E_T_ = ' '" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_PRODUTO = SB1.B1_COD" + Enter
	cSql += "		AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SBM010 SBM WITH(NOLOCK) ON SBM.BM_FILIAL = ''" + Enter
	cSql += "		 AND SB1.B1_GRUPO = SBM.BM_GRUPO" + Enter
	cSql += "		 AND SBM.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SA2010 SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_FORNECE = SA2.A2_COD" + Enter
	cSql += "		AND SC7.C7_LOJA = SA2.A2_LOJA" + Enter
	cSql += "		AND SA2.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SY1050 SY1 WITH(NOLOCK) ON Y1_FILIAL = ''" + Enter
	cSql += "		AND SC7.C7_USER = SY1.Y1_USER" + Enter
	cSql += "		AND SY1.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SCR050 SCR WITH(NOLOCK) ON SCR.CR_FILIAL = '01'" + Enter
	cSql += "		AND SC7.C7_NUM = SCR.CR_NUM" + Enter
	If _cTipoData == "L"
		cSql += "		AND SCR.CR_DATALIB BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter	
	EndIf
	cSql += "		AND SCR.D_E_L_E_T_ = ''" + Enter
	cSql += "	LEFT JOIN SAK050 SAK WITH(NOLOCK) ON SAK.AK_FILIAL = '01'" + Enter
	cSql += "		AND SCR.CR_APROV = SAK.AK_COD" + Enter
	cSql += "		AND SAK.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE SC7.C7_FILIAL = '01'" + Enter
	If _cTipoData == "M"
		cSql += "	AND SC7.C7_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	ElseIf _cTipoData == "V"
		cSql += "	AND SC7.C7_YDTENV BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "	AND SC7.D_E_L_E_T_ = ''" + Enter
	cSql += "ORDER BY EMPRESA" + Enter
	cSql += "	, PC" + Enter
	cSql += "	, ITEM_PC" + Enter

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
