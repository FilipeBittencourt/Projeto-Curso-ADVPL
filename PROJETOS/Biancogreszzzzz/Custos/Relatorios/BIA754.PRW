#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA754
@author Marcos Alberto Soprani
@since 19/02/14
@version 1.0
@description Custo Final para Rateio - Por Classe Valor
@obs Estoque e Custos
@obs Incluído set de filtro para linha R09
@type function
/*/

/*/{Protheus.doc} BIA754
@author Artur Antunes
@since 27/04/2017
@version 1.1
@description Ajuste de agrupamento por periodo e alteração de layout
@obs OS 0781-17 
@type function
/*/

User Function BIA754()

	Local aArea    := GetArea()
	private aPergs := {}

	If !ValidPerg()
		Return
	EndIf

	Processa({|| RptDetail()},"Aguarde...","Carregando Registros...")

	RestArea(aArea)

Return

Static Function RptDetail()

	Local cTab     	:= GetNextAlias() 
	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
	local cTitulo   := "Relatório de Custo Final para Rateio - Por Classe Valor"  
	local nRegAtu   := 0
	local nTotReg   := 0
	local cArqXML   := "BIA754_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	local cQuery	:= ''
	local cContaC   := ''
	local cPeriodo	:= ''

	local cCab1Fon	:= 'Calibri' 
	local nCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'

	Local xrEnter   := CHR(13) + CHR(10)

	ProcRegua(0)

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA754",,{MV_PAR01,MV_PAR02,MV_PAR03})

	kjDtINI := MV_PAR01
	kjDtFIM := MV_PAR02

	msKernelCt := U_BIA185( kjDtINI, kjDtFIM )
	msNomeTMP  := "##TMPBIA754" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	msMontaSql := msKernelCt + "SELECT * INTO " + msNomeTMP + " FROM TABFINAL "
	U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(msMontaSql)})

	cQuery += Alltrim(" SELECT TBDADOS.* ,                                                                                                            ") + xrEnter
	cQuery += Alltrim("        CASE                                                                                                                   ") + xrEnter 
	cQuery += Alltrim("            WHEN CLVL IN ( '6112', '6208' ) THEN 'GASTOS COM SEGURANCA'                                                        ") + xrEnter
	cQuery += Alltrim("            WHEN CLVL IN ( '3180', '3181', '3183', '3184', '3280' ) THEN 'COGERACAO'                                           ") + xrEnter
	cQuery += Alltrim("            ELSE Z29.Z29_DESCR                                                                                                 ") + xrEnter
	cQuery += Alltrim("        END DITCUS,                                                                                                            ") + xrEnter
	cQuery += Alltrim("        CASE                                                                                                                   ") + xrEnter 
	cQuery += Alltrim("            WHEN CLVL IN ( '6112', '6208' ) THEN 'CF'                                                                          ") + xrEnter
	cQuery += Alltrim("            WHEN CLVL IN ( '3180', '3181', '3183', '3184', '3280' ) THEN 'CV'                                                  ") + xrEnter
	cQuery += Alltrim("            WHEN ITCUS = '050' THEN 'CF'                                                                                       ") + xrEnter
	cQuery += Alltrim("            ELSE Z29.Z29_TIPO                                                                                                  ") + xrEnter
	cQuery += Alltrim("        END TPCUST,                                                                                                            ") + xrEnter
	cQuery += Alltrim("        CASE                                                                                                                   ") + xrEnter 
	cQuery += Alltrim("            WHEN RTRIM(CLVL) IN('3801') THEN 'MP'                                                                              ") + xrEnter
	cQuery += Alltrim("            WHEN RTRIM(CLVL) IN('3802','3803') THEN 'PI'                                                                       ") + xrEnter
	cQuery += Alltrim("            WHEN RTRIM(CLVL) IN('3804','3805') THEN 'PA'                                                                       ") + xrEnter
	cQuery += Alltrim("            WHEN CLVL IN ( '6112', '6208' ) THEN 'PP'                                                                          ") + xrEnter
	cQuery += Alltrim("            WHEN CLVL IN ( '3180', '3181', '3183', '3184', '3280' ) THEN 'PP'                                                  ") + xrEnter
	cQuery += Alltrim("            WHEN MODS <> 'DIRETA' AND (SELECT COUNT(*) CONTAD                                                                  ") + xrEnter
	cQuery += Alltrim("                                         FROM " + RetSqlName("SB1") + " XB1 (NOLOCK)                                           ") + xrEnter
	cQuery += Alltrim("                                         JOIN (SELECT '%E03%' AS Pattern                                                       ") + xrEnter
	cQuery += Alltrim("                                                UNION ALL SELECT '%E04%'                                                       ") + xrEnter
	cQuery += Alltrim("                                                UNION ALL SELECT '%R01%'                                                       ") + xrEnter
	cQuery += Alltrim("                                                UNION ALL SELECT '%R02%'                                                       ") + xrEnter
	cQuery += Alltrim("                                                UNION ALL SELECT '%R09%') AS Patterns ON B1_COD LIKE Patterns.Pattern          ") + xrEnter
	cQuery += Alltrim("                                        WHERE B1_COD = MODS) = 1 THEN 'PA'                                                     ") + xrEnter
	cQuery += Alltrim("            WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) NOT IN('615', '616', '617')                                                    ") + xrEnter
	cQuery += Alltrim("                 AND SUBSTRING(AGRUP, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09')                                              ") + xrEnter
	cQuery += Alltrim("            THEN 'PA'                                                                                                          ") + xrEnter
	//cQuery += Alltrim("            WHEN MODS = 'DIRETA' AND SUBSTRING(CTA, 1, 5) IN ( '61104', '61110' ) THEN 'PA'                                    ") + xrEnter
	//cQuery += Alltrim("            WHEN MODS = 'DIRETA' AND SUBSTRING(CTA, 1, 5) NOT IN ( '61104', '61110' ) THEN 'PP'                                ") + xrEnter
	//cQuery += Alltrim("            ELSE XZ29.Z29_APLIC                                                                                                ") + xrEnter
	cQuery += Alltrim("            WHEN SUBSTRING(CTA, 1, 5) IN ( '61104', '61110' ) THEN 'PA'                                                        ") + xrEnter
	cQuery += Alltrim("            WHEN SUBSTRING(CTA, 1, 5) NOT IN ( '61104', '61110' ) THEN 'PP'                                                    ") + xrEnter
	cQuery += Alltrim("            ELSE 'PP'                                                                                                          ") + xrEnter
	cQuery += Alltrim("        END APLIC                                                                                                              ") + xrEnter
	cQuery += Alltrim(" FROM   " + msNomeTMP + " TBDADOS                                                                                              ") + xrEnter
	cQuery += Alltrim("        LEFT JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'                                            ") + xrEnter
	cQuery += Alltrim("                                AND B1_COD = MODS                                                                              ") + xrEnter
	cQuery += Alltrim("                                AND SB1.D_E_L_E_T_ = ' '                                                                       ") + xrEnter
	cQuery += Alltrim("        LEFT JOIN " + RetSqlName("Z29") + " Z29 ON Z29.Z29_FILIAL = '"+xFilial("Z29")+"'                                       ") + xrEnter
	cQuery += Alltrim("                                AND Z29.Z29_COD_IT = ITCUS                                                                     ") + xrEnter
	cQuery += Alltrim("                                AND Z29.D_E_L_E_T_ = ' '                                                                       ") + xrEnter
	cQuery += Alltrim("        LEFT JOIN " + RetSqlName("Z29") + " XZ29 ON XZ29.Z29_FILIAL = '"+xFilial("Z29")+"'                                     ") + xrEnter
	cQuery += Alltrim("                                AND XZ29.Z29_COD_IT = B1_YITCUS                                                                ") + xrEnter
	cQuery += Alltrim("                                AND XZ29.D_E_L_E_T_ = ' '                                                                      ") + xrEnter
	cQuery += Alltrim(" ORDER BY PERIODO,MODS                                                                                                         ") + xrEnter
	TcQuery cQuery Alias (cTab) New
	(cTab)->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	(cTab)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New() 
	oExcel:AddPlanilha('Planilha 01',{20,60,60,80,80,160,80,60,60,80,80,60,60,160,60,80,160,20,40,40},6)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,17) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,17) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,17)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()  
	oExcel:AddCelula("PERIODO"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("APL" 		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CTA"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DESC01"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("AGRUP"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CLVL"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CRIT"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("VALOR"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("MODS"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("KEY"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CONTRAP"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DESCR"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("REGRAC"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("RATEIO"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DITCUS"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("TPCUST"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("APLIC."	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While !(cTab)->(Eof())

		nRegAtu++
		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif	  

		cPeriodo := Substr(MesExtenso(val(substr((cTab)->PERIODO,5,2))),1,3) + "/" + substr((cTab)->PERIODO,1,4)

		If Empty((cTab)->MODS)
			cContaC := Alltrim(Substr((cTab)->MODS, 5, 11))
			CT1->(dbSetOrder(1))
			If !CT1->(dbSeek(xFilial("CT1")+cContaC))
				CT1->(dbSetOrder(1))
				If CT1->(dbSeek(xFilial("CT1")+Substr(cContaC,1,3)))
					cContaC := Substr(cContaC,1,3)
				EndIf
			EndIf
		Else
			cContaC := (cTab)->AGRUP
		EndIf

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		zpAplic := (cTab)->APLIC
		If Empty(zpAplic)
			zpAplic := "PP"
		EndIf 		

		oExcel:AddCelula( cPeriodo			,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->APL		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->CTA		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->DESC01	,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->AGRUP		,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->CLVL		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->CRIT		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->VALOR		,2 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->MODS		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( cContaC			,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->CONTRAP	,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->DESCR		,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->REGRAC	,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->RATEIO	,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->DITCUS	,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( (cTab)->TPCUST	,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( zpAplic       	,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

		(cTab)->(DbSkip())                
	EndDo    

	fGeraParametros()
	oExcel:SaveXml(Alltrim(MV_PAR03),cArqXML,.T.) 

	oLogProc:LogFimProc()

	nRegAtu++

	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	

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

	aPergs[1 ,3] := MV_PAR01 
	aPergs[2 ,3] := MV_PAR02  
	aPergs[3 ,3] := MV_PAR03     

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

return

Static Function ValidPerg()

	local cLoad	    := "BIA754" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := space(100)

	aAdd( aPergs ,{1,"Data De? " 		,MV_PAR01 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 		,MV_PAR02 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
	aAdd( aPergs ,{6,"Pasta Destino?"  	,MV_PAR03 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Relatório de Custo Final para Rateio",,,,,,,,cLoad,.T.,.T.)  

		lRet := .T.

		MV_PAR01 := ParamLoad(cFileName,,1 ,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2 ,MV_PAR02) 
		MV_PAR03 := ParamLoad(cFileName,,3 ,MV_PAR03) 

		if empty(MV_PAR03) 
			MV_PAR03 := AllTrim(GetTempPath()) 	
		endif  	
	endif

return lRet
