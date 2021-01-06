#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIA680
@author Luana Marin Ribeiro
@since 26/04/2018
@version 1.0
@description Relatório de Anomalias Processo de Recebimento de Material
@type function
/*/

User Function BIA680()	
	Private Enter := CHR(13)+CHR(10)
	Private cSql := ""
	
	Private _cTipoAnomalia
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

	local cLoad	    := "BIA680"
	local cFileName := RetCodUsr() + "_" + cLoad
	local lRet		:= .F.
	
	MV_PAR01 := SPACE(1)
	MV_PAR02 := STOD('')
	MV_PAR03 := STOD('')
	MV_PAR04 := SPACE(100)
	
	//'2 = XML não carregado','3 = Liberação de Material sem XML','4 = Não Recebimento de Material','5 = Pedido de Compra não encontrado','6 = Descarregamento não autorizado pelo Compras','7 = Material não Conforme','8 = Amostragem Quantitativa Não Conforme','9 = Amostragem Qualitativa Negativa','10 = Recebimento de Material com Problema (Conferente)','11 = Recebimento de Material com Problema (Supervisor)'
	aAdd( aPergs ,{2,"Tipo Anomalia", MV_PAR01 , {'0=Todos','2=XML não carregado','3=Liberação sem XML','4=Não Receb. de Material','5=Ped. de Compra não encontrado','6=Descar. não aut. pelo Compras','7=Material não Conforme','8=Amostragem Quant. Não Conforme','9=Amostragem Qual. Negativa','10=Receb. de Material com Problema (Conferente)','11=Receb. de Material com Problema (Supervisor)'} ,50,"",.T.})
	aAdd( aPergs ,{1,"Data De", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Data Até", MV_PAR03, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{6,"Pasta destino", MV_PAR04, "", "", "", 90, .F., "Diretorio . |*.",, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório Anomalias Recebimento de Material",,,,,,,,cLoad,.T.,.T.)

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

	local cArqXML := "BIA655_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	
	_cTipoAnomalia := MV_PAR01
	_cDataDe :=	DtoS(MV_PAR02)
	_cDataAte := DtoS(MV_PAR03)
	_cDirDest := MV_PAR04
	

	MontaQry(_cDataDe, _cDataAte, _cTipoAnomalia)
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

	oExcel:AddPlanilha("Relatorio",{20,60,60,60,40,220,200,80,100,80,65,100,200,65,65,200,80,80,65,40,150,65,65,150,65,65,65,65,150,65},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula("BIANCOGRES/INCESA",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,28) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,28) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório Anomalias Recebimento de Material",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,28)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	
	oExcel:AddCelula("",0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun,,,,,.T.,2,11)
	oExcel:AddCelula("ANÁLISE QUANTITATIVA",0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun,.T.,.T.,.T.,.T.,.T.,14,7)
	oExcel:AddCelula("ENTRADA DE MATERIAL",0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun,.T.,.T.,.T.,.T.,.T.,22,4)
	oExcel:AddCelula("",0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun,.T.,.T.,.T.,.T.,.T.,27,3)
	//oExcel:AddCelula("ANÁLISE QUANTITATIVA",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,12,19)
	//oExcel:AddCelula("ENTRADA DE MATERIAL",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,20,24)
	//oExcel:AddCelula("",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,25,28)
	
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	
	oExcel:AddCelula('Nº BIZAGI',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PLACA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('Nº NF',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('SERIE',0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('CHAVE',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORNECEDOR NOME',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('FORNECEDOR CNPJ',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('NF EMPRESA DESCARGA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('REGISTRO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('CÓD. ANOMALIA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('ANOMALIA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('MOTIVO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QTD SUGERIDA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QTD CONFERIDA',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('OBS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('DT. AMOSTRAGEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('AMOSTRA CONFORME',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PROD.CÓD.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('UM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PROD. DESC.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('CONFERÊNCIA MATERIAL OK',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('SOLICITOU DECISÃO COMPRAS',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('OBS. DECISÃO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('RECEBIMENTO AUTORIZADO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('OBS. AUTORIZAÇÃO',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('Nº ITEM',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PROD. CÓD.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('PROD. DESC.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula('QUANT.',0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	
	While QRY->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()
		
		oExcel:AddCelula(QRY->BIZAGI, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PLACA, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->NF_NUMERO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->NF_SERIE, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->NF_CHAVE, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->NF_F_NOME, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->NF_F_CNPJ, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->NF_E_DESCARGA, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->REGISTRO, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->TPANOM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->ANOM, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->MOTIVO, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_SUG, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_CONF, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_OBS, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_DTA, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_AMC, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_CPRO, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_UM, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->AN_Q_DPRO, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->EM_C_MAT, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->EM_S_DEC, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->EM_OBS_DEC, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->EM_R_AUT, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->EM_OBS_AUT, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->NUM_ITEM, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PROD_COD, 0, 'C', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->PROD_DESC, 0, 'L', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula(QRY->QUANT, 2, 'R', cFonte2, nTamFont2, cCorFont2,,, cCorFun2, .T., .T., .T., .T.)
		
		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		QRY->(DbSkip())

	EndDo
	fGeraParametros()
	oExcel:SaveXml(Alltrim(_cDirDest),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	QRY->(dbCloseArea())

Return

Static Function MontaQry(_cDataDe, _cDataAte, _cTipoAnomalia)
	cBizagi	 := U_fGetBase("2") 
	
	cSql := ""                                                              
	cSql += "EXEC "+cBizagi+".dbo.BIANCOGRES_COMPRAS_ANOMALIAS " + _cTipoAnomalia + ", '" + _cDataDe + "', '" + _cDataAte + "'" + Enter
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

	aPergs[1,3] := _cTipoAnomalia
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
