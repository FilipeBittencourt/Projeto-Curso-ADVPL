#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIA652
@author Luana Marin Ribeiro
@since 03/01/2018
@version 1.0
@description Relatório Historico NF (cost saving)
@type function
/*/

User Function BIA652()	
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

	local cLoad	    := "BIA652"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.
	
	MV_PAR01 := SPACE(1)
	MV_PAR02 := STOD('')
	MV_PAR03 := STOD('')
	MV_PAR04 := SPACE(100)
	
	aAdd( aPergs ,{2,"Data", MV_PAR01 , {'E=Emissão Item','D=Digit. Item','R=Recebimento NF'} ,50,"",.T.})
	aAdd( aPergs ,{1,"De", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Até", MV_PAR03, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{6,"Pasta destino", MV_PAR04, "", "", "", 90, .F., "Diretorio . |*.",, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório Historico NF",,,,,,,,cLoad,.T.,.T.)

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

	local cArqXML := "BIA652_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	
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

	oExcel:AddPlanilha("Relatorio",{20,40,45,45,45,65,65,65,65,65,400,40,45,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,65,60,400,150,45,60,60,65,300},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula("BIANCOGRES/INCESA",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,46) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,46) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório Historico NF",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,46)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	
	oExcel:AddCelula('EMPRESA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('NF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('SERIE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('STATUS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. EMISSAO ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. DIGIT. ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. ENTRADA ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD. PROD.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PRODUTO',0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('UM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('GRUPO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANTIDADE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VALOR UNIT.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VALOR MERCAD',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ALIQ. IPI',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('BASE IPI',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. IPI',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ALIQ. ICMS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('BASE ICMS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. ICMS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DESCONTO ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ALIQ. ISS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('BASE ISS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('YVL. ISS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. ISS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ALIQ. PIS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. PIS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ALIQ. COFINS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula('VL. COFINS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ALIQ. FASE MT',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('BASE FASE MT',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. FASE MT',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ICMS ST FOR ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ICMS SOLID. ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. BRUTO ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. FRETE NF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DESCONTO NF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. DESPESA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('VL. BRUTO NF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('COD.FORN.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORNECEDOR',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORN. CIDADE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORN. UF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PEDIDO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ITEM PEDIDO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. REC.'	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	
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
		oExcel:AddCelula(QRY->NF, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->SERIE, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->STATU, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_EMI_ITEM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_DIG_ITEM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_ENT_ITEM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ITEM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_PROD, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PRODUTO, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->UM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->GRUPO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANTIDADE, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VALOR_UNIT, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VALOR_MERCAD, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->A_IPI, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->B_IPI, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_IPI, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->A_ICMS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->B_ICMS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_ICMS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DES_ITEM, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->A_ISS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->B_ISS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->YV_ISS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->V_ISS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->A_PIS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_PIS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->A_COFINS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)	
		oExcel:AddCelula(QRY->VL_COFINS, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->A_FASE_MT, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->B_FASE_MT, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_FASE_MT, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->IC_ST_FOR_ITEM, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->IC_SOLID_ITEM, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_BRUTO_ITEM, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_FRETE_NF, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DES_NF, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_DESPESA, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->VL_BRUTO_NF, 0, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->COD_FORN, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->FORNECEDOR, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->F_CIDADE, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->F_UF, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PEDIDO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ITEM_PEDIDO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->DT_REC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		
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
	cSql += "	, SD1.D1_DOC AS NF" + Enter
	cSql += "	, SD1.D1_SERIE AS SERIE" + Enter
	cSql += "	, SF1.F1_STATUS AS STATU" + Enter
	cSql += "	, (CASE SD1.D1_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SD1.D1_EMISSAO),103) END) AS DT_EMI_ITEM" + Enter
	cSql += "	, (CASE SD1.D1_DTDIGIT WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SD1.D1_DTDIGIT),103) END) AS DT_DIG_ITEM" + Enter
	cSql += "	, (CASE SD1.D1_YDTENT WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SD1.D1_YDTENT),103) END) AS DT_ENT_ITEM" + Enter
	cSql += "	, SD1.D1_ITEM AS ITEM" + Enter
	cSql += "	, SD1.D1_COD AS COD_PROD" + Enter
	cSql += "	, SB1.B1_DESC AS PRODUTO" + Enter
	cSql += "	, SB1.B1_UM AS UM" + Enter
	cSql += "	, SB1.B1_GRUPO AS GRUPO" + Enter
	cSql += "	, SD1.D1_QUANT AS QUANTIDADE" + Enter
	cSql += "	, SD1.D1_VUNIT AS VALOR_UNIT" + Enter
	cSql += "	, SD1.D1_TOTAL AS VALOR_MERCAD" + Enter
	cSql += "	, SD1.D1_IPI AS A_IPI" + Enter
	cSql += "	, SD1.D1_BASEIPI AS B_IPI" + Enter
	cSql += "	, SD1.D1_VALIPI AS VL_IPI" + Enter
	cSql += "	, SD1.D1_PICM AS A_ICMS" + Enter
	cSql += "	, SD1.D1_BASEICM AS B_ICMS" + Enter
	cSql += "	, SD1.D1_VALICM AS VL_ICMS" + Enter
	cSql += "	, SD1.D1_VALDESC AS DES_ITEM" + Enter
	cSql += "	, SD1.D1_ALIQISS AS A_ISS" + Enter
	cSql += "	, SD1.D1_BASEISS AS B_ISS" + Enter
	cSql += "	, SD1.D1_YVLISS AS YV_ISS" + Enter
	cSql += "	, SD1.D1_VALISS AS V_ISS" + Enter
	cSql += "	, SD1.D1_ALQIMP6 AS A_PIS" + Enter		//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de PIS em alguns produtos.
	cSql += "	, SD1.D1_VALIMP6 AS VL_PIS" + Enter		//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de ALIQ. PIS em alguns produtos.
	cSql += "	, SD1.D1_ALQIMP5 AS A_COFINS" + Enter	//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de ALIQ. COFINS em alguns produtos.  	
	cSql += "	, SD1.D1_VALIMP5 AS VL_COFINS" + Enter	//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de COFINS em alguns produtos.
	cSql += "	, SD1.D1_ALIFASE AS A_FASE_MT" + Enter
	cSql += "	, SD1.D1_BASFASE AS B_FASE_MT" + Enter
	cSql += "	, SD1.D1_VALFASE AS VL_FASE_MT" + Enter
	cSql += "	, SD1.D1_VLSLXML AS IC_ST_FOR_ITEM" + Enter
	cSql += "	, SD1.D1_ICMSRET AS IC_SOLID_ITEM" + Enter
	cSql += "	, (SD1.D1_TOTAL + SD1.D1_VALIPI + SD1.D1_ICMSRET) AS VL_BRUTO_ITEM" + Enter
	cSql += "	, SF1.F1_FRETE AS VL_FRETE_NF" + Enter
	cSql += "	, SF1.F1_DESCONT AS DES_NF" + Enter
	cSql += "	, SF1.F1_DESPESA AS VL_DESPESA" + Enter
	cSql += "	, SF1.F1_VALBRUT AS VL_BRUTO_NF" + Enter
	cSql += "	, SA2.A2_COD AS COD_FORN" + Enter
	cSql += "	, SA2.A2_NOME AS FORNECEDOR" + Enter
	cSql += "	, SA2.A2_MUN AS F_CIDADE" + Enter
	cSql += "	, SA2.A2_EST AS F_UF" + Enter
	cSql += "	, SD1.D1_PEDIDO AS PEDIDO" + Enter
	cSql += "	, SD1.D1_ITEMPC AS ITEM_PEDIDO" + Enter
	cSql += "	, CONVERT(VARCHAR(10),CONVERT(DATETIME,SF1.F1_RECBMTO),103) AS DT_REC" + Enter
	cSql += "FROM SD1010 SD1 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SF1010 SF1 WITH(NOLOCK) ON SF1.F1_FILIAL = '01'" + Enter
	cSql += "		AND SD1.D1_FILIAL = SF1.F1_FILIAL" + Enter
	cSql += "		AND SD1.D1_DOC = SF1.F1_DOC" + Enter
	cSql += "		AND SD1.D1_SERIE = SF1.F1_SERIE" + Enter
	cSql += "		AND SD1.D1_FORNECE = SF1.F1_FORNECE" + Enter
	cSql += "		AND SD1.D1_LOJA = SF1.F1_LOJA" + Enter
	cSql += "		AND SF1.F1_VALBRUT <> 0" + Enter
	If _cTipoData == "R"
		cSql += "		AND SF1.F1_RECBMTO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "		AND SF1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = ''" + Enter
	cSql += "		AND SD1.D1_COD = SB1.B1_COD" + Enter
	cSql += "		AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SBM010 SBM WITH(NOLOCK) ON SBM.BM_FILIAL = ''" + Enter
	cSql += "		AND SB1.B1_GRUPO = SBM.BM_GRUPO" + Enter
	cSql += "		AND SBM.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SA2010 SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = ''" + Enter
	cSql += "		AND SF1.F1_FORNECE = SA2.A2_COD" + Enter
	cSql += "		AND SF1.F1_LOJA = SA2.A2_LOJA" + Enter
	cSql += "		AND SA2.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE SD1.D1_FILIAL = '01'" + Enter
	cSql += "	AND SD1.D_E_L_E_T_ = ''" + Enter
	If _cTipoData == "E"
		cSql += "	AND SD1.D1_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	ElseIf _cTipoData == "D"
		cSql += "	AND SD1.D1_DTDIGIT BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "UNION" + Enter
	cSql += "SELECT 'INCESA' AS EMPRESA" + Enter
	cSql += "	, SD1.D1_DOC AS NF" + Enter
	cSql += "	, SD1.D1_SERIE AS SERIE" + Enter
	cSql += "	, SF1.F1_STATUS AS STATU" + Enter
	cSql += "	, (CASE SD1.D1_EMISSAO WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SD1.D1_EMISSAO),103) END) AS DT_EMI_ITEM" + Enter
	cSql += "	, (CASE SD1.D1_DTDIGIT WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SD1.D1_DTDIGIT),103) END) AS DT_DIG_ITEM" + Enter
	cSql += "	, (CASE SD1.D1_YDTENT WHEN '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME,SD1.D1_YDTENT),103) END) AS DT_ENT_ITEM" + Enter
	cSql += "	, SD1.D1_ITEM AS ITEM" + Enter
	cSql += "	, SD1.D1_COD AS COD_PROD" + Enter
	cSql += "	, SB1.B1_DESC AS PRODUTO" + Enter
	cSql += "	, SB1.B1_UM AS UM" + Enter
	cSql += "	, SB1.B1_GRUPO AS GRUPO" + Enter
	cSql += "	, SD1.D1_QUANT AS QUANTIDADE" + Enter
	cSql += "	, SD1.D1_VUNIT AS VALOR_UNIT" + Enter
	cSql += "	, SD1.D1_TOTAL AS VALOR_MERCAD" + Enter
	cSql += "	, SD1.D1_IPI AS A_IPI" + Enter
	cSql += "	, SD1.D1_BASEIPI AS B_IPI" + Enter
	cSql += "	, SD1.D1_VALIPI AS VL_IPI" + Enter
	cSql += "	, SD1.D1_PICM AS A_ICMS" + Enter
	cSql += "	, SD1.D1_BASEICM AS B_ICMS" + Enter
	cSql += "	, SD1.D1_VALICM AS VL_ICMS" + Enter
	cSql += "	, SD1.D1_VALDESC AS DES_ITEM" + Enter
	cSql += "	, SD1.D1_ALIQISS AS A_ISS" + Enter
	cSql += "	, SD1.D1_BASEISS AS B_ISS" + Enter
	cSql += "	, SD1.D1_YVLISS AS YV_ISS" + Enter
	cSql += "	, SD1.D1_VALISS AS V_ISS" + Enter
	cSql += "	, SD1.D1_ALQIMP6 AS A_PIS" + Enter		//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de PIS em alguns produtos.
	cSql += "	, SD1.D1_VALIMP6 AS VL_PIS" + Enter		//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de ALIQ. PIS em alguns produtos.
	cSql += "	, SD1.D1_ALQIMP5 AS A_COFINS" + Enter	//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de ALIQ. COFINS em alguns produtos.  	
	cSql += "	, SD1.D1_VALIMP5 AS VL_COFINS" + Enter	//Thiago Haagensen - Ticket 22871 - Anúplio - Correção de divergências de valores de COFINS em alguns produtos.
	cSql += "	, SD1.D1_ALIFASE AS A_FASE_MT" + Enter
	cSql += "	, SD1.D1_BASFASE AS B_FASE_MT" + Enter
	cSql += "	, SD1.D1_VALFASE AS VL_FASE_MT" + Enter
	cSql += "	, SD1.D1_VLSLXML AS IC_ST_FOR_ITEM" + Enter
	cSql += "	, SD1.D1_ICMSRET AS IC_SOLID_ITEM" + Enter
	cSql += "	, (SD1.D1_TOTAL + SD1.D1_VALIPI + SD1.D1_ICMSRET) AS VL_BRUTO_ITEM" + Enter
	cSql += "	, SF1.F1_FRETE AS VL_FRETE_NF" + Enter
	cSql += "	, SF1.F1_DESCONT AS DES_NF" + Enter
	cSql += "	, SF1.F1_DESPESA AS VL_DESPESA" + Enter
	cSql += "	, SF1.F1_VALBRUT AS VL_BRUTO_NF" + Enter
	cSql += "	, SA2.A2_COD AS COD_FORN" + Enter
	cSql += "	, SA2.A2_NOME AS FORNECEDOR" + Enter
	cSql += "	, SA2.A2_MUN AS F_CIDADE" + Enter
	cSql += "	, SA2.A2_EST AS F_UF" + Enter
	cSql += "	, SD1.D1_PEDIDO AS PEDIDO" + Enter
	cSql += "	, SD1.D1_ITEMPC AS ITEM_PEDIDO" + Enter
	cSql += "	, CONVERT(VARCHAR(10),CONVERT(DATETIME,SF1.F1_RECBMTO),103) AS DT_REC" + Enter
	cSql += "FROM SD1050 SD1 WITH(NOLOCK)" + Enter
	cSql += "	INNER JOIN SF1050 SF1 WITH(NOLOCK) ON SF1.F1_FILIAL = '01'" + Enter
	cSql += "		AND SD1.D1_FILIAL = SF1.F1_FILIAL" + Enter
	cSql += "		AND SD1.D1_DOC = SF1.F1_DOC" + Enter
	cSql += "		AND SD1.D1_SERIE = SF1.F1_SERIE" + Enter
	cSql += "		AND SD1.D1_FORNECE = SF1.F1_FORNECE" + Enter
	cSql += "		AND SD1.D1_LOJA = SF1.F1_LOJA" + Enter		
	cSql += "		AND SF1.F1_VALBRUT <> 0" + Enter
	If _cTipoData == "R"
		cSql += "		AND SF1.F1_RECBMTO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "		AND SF1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = ''" + Enter
	cSql += "		AND SD1.D1_COD = SB1.B1_COD" + Enter
	cSql += "		AND SB1.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SBM010 SBM WITH(NOLOCK) ON SBM.BM_FILIAL = ''" + Enter
	cSql += "		AND SB1.B1_GRUPO = SBM.BM_GRUPO" + Enter
	cSql += "		AND SBM.D_E_L_E_T_ = ''" + Enter
	cSql += "	INNER JOIN SA2010 SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = ''" + Enter
	cSql += "		AND SF1.F1_FORNECE = SA2.A2_COD" + Enter
	cSql += "		AND SF1.F1_LOJA = SA2.A2_LOJA" + Enter
	cSql += "		AND SA2.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE SD1.D1_FILIAL = '01'" + Enter
	cSql += "	AND SD1.D_E_L_E_T_ = ''" + Enter
	If _cTipoData == "E"
		cSql += "	AND SD1.D1_EMISSAO BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	ElseIf _cTipoData == "D"
		cSql += "	AND SD1.D1_DTDIGIT BETWEEN '" + _cDataDe + "' AND '" + _cDataAte + "'" + Enter
	EndIf
	cSql += "ORDER BY EMPRESA" + Enter
	cSql += "	, DT_EMI_ITEM" + Enter
	cSql += "	, NF" + Enter
	cSql += "	, SERIE" + Enter
	cSql += "	, COD_FORN" + Enter
	cSql += "	, ITEM" + Enter

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
