#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIAFG145
@author Gabriel Rossi Mafioletti
@since 24/05/21
@version 1.0
@description Extração do OrcaFinal para excel
@Obs Projeto A-63
@type function
/*/

User Function BIAFG145()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .T.
	Local oProcess

	Private cTitulo := "Extração do OrcaFinal para Excel"

	Private msEnter   := CHR(13) + CHR(10)
	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private hhTmpINI
	Private smMsnPrc
	Private msCanPrc  := .F.
	Private xVerRet   := .T.
	Private msErroQuery

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	Private nRegAtu    := 0
	Private cCab1Fon   := 'Calibri' 
	Private cCab1TamF  := 8   
	Private cCab1CorF  := '#FFFFFF'
	Private cCab1Fun   := '#4F81BD'

	Private cFonte1	   := 'Arial'
	Private nTamFont1  := 12   
	Private cCorFont1  := '#FFFFFF'
	Private cCorFun1   := '#4F81BD'

	Private cFonte2    := 'Arial'
	Private nTamFont2  := 8   
	Private cCorFont2  := '#000000'
	Private cCorFun2   := '#B8CCE4'

	Private cDirDest   := "c:\temp\"
	Private cArqXML    := UPPER(Alltrim("BIAFG145")) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))

	Private cEmpresa   := "Geral"

	Private _cVersao	:=	""
	Private _cAnoRef	:=	""
	Private _cRevisa	:=	""

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Extrato", {20, 100, 100, 100, 100,100,100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, 28 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, 28 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("OrcaFinal", 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, 28 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(15) 
	oExcel:AddCelula()
	oExcel:AddCelula("EMPRESA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILIAL"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VERSAO"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("REVISAO"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ANOREF"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ORIPRC"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ORIGLAN"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DATAREF"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LOTE"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("SUBLOTE"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DOC"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LINHA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DC"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CONTA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DSCONTA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CLVL"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DSCLVL"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ITEM"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DRIVER"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DSDRIVER"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALOR"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("HIST"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("YHIST"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("SI"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DELTA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ORIPR2"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("APLIC"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DSAPLIC"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NEGOCI"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	



	oEmp := TLoadEmpresa():New()

	If ValidPerg()

		_cVersao	:=	MV_PAR01
		_cRevisa	:=	MV_PAR02		
		_cAnoRef	:=	MV_PAR03

		oEmp:GSEmpFil()

		If Len(oEmp:aEmpSel) > 0

			hhTmpINI  := TIME()

			For nW := 1 To Len(oEmp:aEmpSel)

//				RpcSetType(3)
				RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

				smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])
				oProcess := MsNewProcess():New({|lEnd| MontaQrys(@oProcess) }, "Montando Querys...", smMsnPrc, .T.)
				oProcess:Activate()

				lRet := xVerRet
				If xVerRet


				Else

					msCanPrc  := .F.
					Exit

				EndIf

				RpcClearEnv()

			Next nW

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	RpcSetEnv( msEmpAtu, msFilAtu )

	If Type("__cInternet") == "C"
		__cInternet := Nil
	EndIf

	If !msCanPrc

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msEnter + msEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 
			MsgINFO("Fim do Processamento!!!" + msEnter + msEnter + Alltrim(ElapTime(hhTmpINI, TIME())), "Atenção!!!")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function ValidPerg()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIAFG145' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	Local lRet
	
	MV_PAR01        := space(010)
	MV_PAR02        := space(003) 
	MV_PAR03		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,MV_PAR01    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,MV_PAR02    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,MV_PAR03    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Extração OrcaFinal c/ ItCus",,,,,,,,cLoad,.T.,.T.)      
		MV_PAR01    := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02    := ParamLoad(cFileName,,2,MV_PAR02) 
		MV_PAR03    := ParamLoad(cFileName,,3,MV_PAR03) 
		lRet	:=	.T.
	Endif

Return lRet

Static Function MontaQrys(oProcess)

	Local lRet	  := .T.
	Local nRegAtu := 0

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	oProcess:IncRegua1(smMsnPrc)
	GT007	:=	""
	GT007	+=	Alltrim("	SELECT "+ValtoSql(cEmpAnt)+" EMPR 			                                ")
	GT007	+=	Alltrim("		,"+ValtoSql(cEmpAnt)+" + ZBZ_FILIAL FILIAL                                      ")
	GT007	+=	Alltrim("		,ZBZ_VERSAO                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_REVISA                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_ANOREF                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_ORIPRC                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_ORGLAN                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_DATA                                                                       ")
	GT007	+=	Alltrim("		,ZBZ_LOTE                                                                       ")
	GT007	+=	Alltrim("		,ZBZ_SBLOTE                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_DOC                                                                        ")
	GT007	+=	Alltrim("		,ZBZ_LINHA                                                                      ")
	GT007	+=	Alltrim("		,ZBZ_DC                                                                         ")
	GT007	+=	Alltrim("		,ZBZ_DEBITO                                                                     ")
	GT007	+=	Alltrim("		,CT1D.CT1_DESC01                                                                ")
	GT007	+=	Alltrim("		,ZBZ_CLVLDB                                                                     ")
	GT007	+=	Alltrim("		,CTHD.CTH_DESC01                                                                ")
	GT007	+=	Alltrim("		,ZBZ_ITEMD                                                                      ")
	GT007	+=	Alltrim("		,ZBZ_DRVDB                                                                      ")
	GT007	+=	Alltrim("		,ZBED.ZBE_DESCRI                                                                ")
	GT007	+=	Alltrim("		,ZBZ_CREDIT                                                                     ")
	GT007	+=	Alltrim("		,CT1C.CT1_DESC01                                                                ")
	GT007	+=	Alltrim("		,ZBZ_CLVLCR                                                                     ")
	GT007	+=	Alltrim("		,CTHC.CTH_DESC01                                                                ")
	GT007	+=	Alltrim("		,ZBZ_ITEMC                                                                      ")
	GT007	+=	Alltrim("		,ZBZ_DRVCR                                                                      ")
	GT007	+=	Alltrim("		,ZBEC.ZBE_DESCRI                                                                ")
	GT007	+=	Alltrim("		,ZBZ_VALOR                                                                      ")
	GT007	+=	Alltrim("		,ZBZ_HIST                                                                       ")
	GT007	+=	Alltrim("		,ZBZ_YHIST                                                                      ")
	GT007	+=	Alltrim("		,ZBZ_SI                                                                         ")
	GT007	+=	Alltrim("		,ZBZ_YDELTA                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_ORIPR2                                                                     ")
	GT007	+=	Alltrim("		,ZBZ_APLIC                                                                     ")
	GT007	+=	Alltrim("		,CASE                                                                           ")
	GT007	+=	Alltrim("			WHEN ZBZ_APLIC = '0'                                                        ")
	GT007	+=	Alltrim("				THEN 'NENHUM'                                                           ")
	GT007	+=	Alltrim("			WHEN ZBZ_APLIC = '1'                                                        ")
	GT007	+=	Alltrim("				THEN 'PRODUCAO'                                                         ")
	GT007	+=	Alltrim("			WHEN ZBZ_APLIC = '2'                                                        ")
	GT007	+=	Alltrim("				THEN 'MANUTENCAO'                                                       ")
	GT007	+=	Alltrim("			WHEN ZBZ_APLIC = '3'                                                        ")
	GT007	+=	Alltrim("				THEN 'MELHORIA_MANUT'                                                   ")
	GT007	+=	Alltrim("			WHEN ZBZ_APLIC = '4'                                                        ")
	GT007	+=	Alltrim("				THEN 'SEGURANCA'                                                        ")
	GT007	+=	Alltrim("			WHEN ZBZ_APLIC = '5'                                                        ")
	GT007	+=	Alltrim("				THEN 'CALIBRACAO'                                                       ")
	GT007	+=	Alltrim("			WHEN ZBZ_APLIC = '6'                                                        ")
	GT007	+=	Alltrim("				THEN 'MELHORIA_PROD'                                                    ")
	GT007	+=	Alltrim("			ELSE 'OUTROS'                                                               ")
	GT007	+=	Alltrim("			END APLIC                                                                   ")
	GT007	+=	Alltrim("		,ZBZ_NEGOCI                                                                     ")
	GT007	+=	Alltrim("	FROM "+ RetSqlName("ZBZ")+ " ZBZ WITH (NOLOCK)                                                       ")
	GT007	+=	Alltrim("	LEFT JOIN "+RetSqlName("CT1")+" CT1C WITH (NOLOCK) ON ZBZ.ZBZ_CREDIT = CT1C.CT1_CONTA              ")
	GT007	+=	Alltrim("		AND CT1C.D_E_L_E_T_ = ''                                                        ")
	GT007	+=	Alltrim("	LEFT JOIN "+RetSqlName("CT1")+" CT1D WITH (NOLOCK) ON ZBZ.ZBZ_DEBITO = CT1D.CT1_CONTA              ")
	GT007	+=	Alltrim("		AND CT1D.D_E_L_E_T_ = ''                                                        ")
	GT007	+=	Alltrim("	LEFT JOIN "+RetSqlName("CTH")+" CTHC WITH (NOLOCK) ON ZBZ.ZBZ_CLVLCR = CTHC.CTH_CLVL               ")
	GT007	+=	Alltrim("		AND CTHC.D_E_L_E_T_ = ''                                                        ")
	GT007	+=	Alltrim("	LEFT JOIN "+RetSqlName("CTH")+" CTHD WITH (NOLOCK) ON ZBZ.ZBZ_CLVLDB = CTHD.CTH_CLVL               ")
	GT007	+=	Alltrim("		AND CTHD.D_E_L_E_T_ = ''                                                        ")
	GT007	+=	Alltrim("	LEFT JOIN "+RetSqlName("ZBE")+" ZBEC WITH (NOLOCK) ON ZBZ.ZBZ_VERSAO = ZBEC.ZBE_VERSAO             ")
	GT007	+=	Alltrim("		AND ZBZ.ZBZ_ANOREF = ZBEC.ZBE_ANOREF                                            ")
	GT007	+=	Alltrim("		AND ZBZ.ZBZ_REVISA = ZBEC.ZBE_REVISA                                            ")
	GT007	+=	Alltrim("		AND ZBZ.ZBZ_DRVCR = ZBEC.ZBE_DRIVER                                             ")
	GT007	+=	Alltrim("		AND ZBEC.D_E_L_E_T_ = ''                                                        ")
	GT007	+=	Alltrim("	LEFT JOIN "+RetSqlName("ZBE")+" ZBED WITH (NOLOCK) ON ZBZ.ZBZ_VERSAO = ZBED.ZBE_VERSAO             ")
	GT007	+=	Alltrim("		AND ZBZ.ZBZ_ANOREF = ZBED.ZBE_ANOREF                                            ")
	GT007	+=	Alltrim("		AND ZBZ.ZBZ_REVISA = ZBED.ZBE_REVISA                                            ")
	GT007	+=	Alltrim("		AND ZBZ.ZBZ_DRVCR = ZBED.ZBE_DRIVER                                             ")
	GT007	+=	Alltrim("		AND ZBED.D_E_L_E_T_ = ''                                                        ")
	GT007	+=	Alltrim("	WHERE ZBZ_VERSAO = "+ValtoSql(_cVersao)+"                                           ")
	GT007	+=	Alltrim("		AND ZBZ_ANOREF = "+ValtoSql(_cAnoRef)+"                                         ")
	GT007	+=	Alltrim("		AND ZBZ_REVISA = "+ValtoSql(_cRevisa)+"                                         ")
	GT007	+=	Alltrim("		AND ZBZ.D_E_L_E_T_ = ''															")
	GT007	+=	Alltrim("	ORDER BY 1,2,3,4,5																	")


	GTIndex := CriaTrab(Nil,.f.)
	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,GT007),'GT07',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Empresa: " + cEmpAnt + msEnter + msEnter
		msErroQuery += "Filial: " + cFilAnt + msEnter + msEnter
		msErroQuery += GT007
		lRet := .F.
	EndIf

	If lRet

		dbSelectArea("GT07")
		dbGoTop()
		ProcRegua(0)
		While !GT07->(Eof())

			oProcess:IncRegua2("Gravando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

			nRegAtu++
			If MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			Else
				cCorFun2 := '#B8CCE4'
			EndIf

			oExcel:AddLinha(13) 
			oExcel:AddCelula()
			oExcel:AddCelula( GT07->EMPR  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->FILIAL  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_VERSAO  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_REVISA  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_ANOREF  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_ORIPRC  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_ORGLAN  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( DtoC(StoD(GT07->ZBZ_DATA))    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_LOTE    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_SBLOTE  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_DOC     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_LINHA   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_DC      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			If Alltrim(GT07->ZBZ_DC) == "1"
				oExcel:AddCelula( GT07->ZBZ_DEBITO  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->CT1_DESC01  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBZ_CLVLDB  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->CTH_DESC01  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBZ_ITEMD   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBZ_DRVDB   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBE_DESCRI  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			Else
				oExcel:AddCelula( GT07->ZBZ_CREDIT  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->CT1_DESC01  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBZ_CLVLCR  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->CTH_DESC01  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBZ_ITEMC   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBZ_DRVCR   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( GT07->ZBE_DESCRI  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			EndIf
			oExcel:AddCelula( GT07->ZBZ_VALOR   , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_HIST    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_YHIST   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_SI      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_YDELTA  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_ORIPR2  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_APLIC       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->APLIC       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->ZBZ_NEGOCI	, 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			GT07->(dbSkip())

		End

		GT07->(dbCloseArea())
		Ferase(GTIndex+GetDBExtension())
		Ferase(GTIndex+OrdBagExt())

	EndIf
	xVerRet := lRet

Return( lRet )
