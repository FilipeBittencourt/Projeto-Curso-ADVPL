#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA694
@author Marcos Alberto Soprani
@since 24/05/21
@version 1.0
@description Extrato dos valores para Gestão Matricial de Tributos
@Obs Projeto A-59
@type function
/*/

User Function BIA694()


	Local aArea	as array 

	Local cUserID 	as character
	Local cSvEmpAnt	as character
	Local cSvFilAnt as character

	cUserID   := &("__CUSERID")
	cSvEmpAnt := &("cEmpAnt")
	cSvFilAnt := &("cFilAnt")

	aArea     := GetArea()

	BIA694A()

	If (&("cEmpAnt")!=cSvEmpAnt) .or. (&("cFilAnt")!=cSvFilAnt)
		rpcSetEnv(cSvEmpAnt,cSvFilAnt)
	EndIf

	&("__CUSERID") := cUserID

	RestArea(aArea)

Return

Static Function BIA694A()

	Local msAreaAtu := GetArea()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .T.
	Local oProcess

	Private cTitulo := "Extrato Gestão Matricial de Tributos"

	Private dDataIni
	Private dDataFin
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
	Private cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))

	Private cEmpresa   := "Geral"

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Extrato", {20, 35, 35, 70, 35, 100, 35, 100, 100, 150, 250, 80, 100, 150, 35, 100, 350}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, 15 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, 15 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Extrato GMT", 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, 15 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(15) 
	oExcel:AddCelula()
	oExcel:AddCelula("EMPRESA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILIAL"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DATREF"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VERCON"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DVERCON"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CODPLA"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DCODPLA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("RFDRE"           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("RUBRICA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DRUBRICA"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("OPERACAO"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DOPERACAO"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALOR"           , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TIPO1"           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DTIPO1"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("HISTORICO"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	oEmp := TLoadEmpresa():New()

	If ValidPerg()

		dDataIni := MV_PAR01
		dDataFin := MV_PAR02

		oEmp:GSEmpFil()

		If Len(oEmp:aEmpSel) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			For nW := 1 To Len(oEmp:aEmpSel)

				RpcSetType(3)
				RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

				smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])
				oProcess := MsNewProcess():New({|lEnd| MontaQrys(@oProcess) }, "Montando Querys...", smMsnPrc, .T.)
				oProcess:Activate()

				lRet := xVerRet
				If xVerRet

					RpcClearEnv()

				Else

					msCanPrc  := .F.
					Exit

				EndIf

			Next nW

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		RpcSetEnv( msEmpAtu, msFilAtu )

		If Type("__cInternet") == "C"
			__cInternet := Nil
		EndIf

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

	RestArea(msAreaAtu)

Return

Static Function ValidPerg()

	local cLoad	    := "BIA694" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	ctod("  /  /  ")
	MV_PAR02 := ctod("  /  /  ")

	aAdd( aPergs ,{1, "Data Inicial"     ,MV_PAR01 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Data Final"       ,MV_PAR02 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Extrato GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf

Return lRet

Static Function MontaQrys(oProcess)

	Local lRet	  := .T.
	Local nRegAtu := 0

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	oProcess:IncRegua1(smMsnPrc)

	GT007 := Alltrim(" SELECT EMPRESA = '" + cEmpAnt + "',                                                              ") + msEnter
	GT007 += Alltrim("        FILIAL = '" + cEmpAnt + "' + ZN6.ZN6_FILIAL,                                              ") + msEnter
	GT007 += Alltrim("        DATREF = ZN6.ZN6_DATREF,                                                                  ") + msEnter
	GT007 += Alltrim("        VERCON = ZN6.ZN6_VERCON,                                                                  ") + msEnter
	GT007 += Alltrim("        DVERCON = ZOY.ZOY_NOME,                                                                   ") + msEnter
	GT007 += Alltrim("        CODPLA = ZN6.ZN6_CODPLA,                                                                  ") + msEnter
	GT007 += Alltrim("        DCODPLA = CVE.CVE_DESCRI,                                                                 ") + msEnter
	GT007 += Alltrim("        RFDRE = CVF.CVF_YRFDRE,                                                                   ") + msEnter
	GT007 += Alltrim("        RUBRICA = ZN6.ZN6_RUBVIS,                                                                 ") + msEnter
	GT007 += Alltrim("        DRUBRICA = CVF.CVF_DESCCG,                                                                ") + msEnter
	GT007 += Alltrim("        OPERACAO = ZN6.ZN6_OPERAC,                                                                ") + msEnter
	GT007 += Alltrim("        DOPERACAO = CASE                                                                          ") + msEnter
	GT007 += Alltrim("                        WHEN ZN6.ZN6_OPERAC = 'D'                                                 ") + msEnter
	GT007 += Alltrim("                        THEN 'DIRETA'                                                             ") + msEnter
	GT007 += Alltrim("                        WHEN ZN6.ZN6_OPERAC = 'I'                                                 ") + msEnter
	GT007 += Alltrim("                        THEN 'INTERCOMPANY'                                                       ") + msEnter
	GT007 += Alltrim("                        WHEN ZN6.ZN6_OPERAC = 'S'                                                 ") + msEnter
	GT007 += Alltrim("                        THEN 'GERACAO SALDO'                                                      ") + msEnter
	GT007 += Alltrim("                        ELSE 'VERIFICAR'                                                          ") + msEnter
	GT007 += Alltrim("                    END,                                                                          ") + msEnter
	GT007 += Alltrim("        VALOR = ZN6.ZN6_VALOR,                                                                    ") + msEnter
	GT007 += Alltrim("        TIPO1 = ZN6.ZN6_TIPO1,                                                                    ") + msEnter
	GT007 += Alltrim("        DTIPO1 = CASE                                                                             ") + msEnter
	GT007 += Alltrim("                     WHEN ZN6.ZN6_TIPO1 = 'A'                                                     ") + msEnter
	GT007 += Alltrim("                     THEN 'AUTOMATICO'                                                            ") + msEnter
	GT007 += Alltrim("                     WHEN ZN6.ZN6_TIPO1 = 'M'                                                     ") + msEnter
	GT007 += Alltrim("                     THEN 'MANUAL'                                                                ") + msEnter
	GT007 += Alltrim("                     ELSE 'VERIFICAR'                                                             ") + msEnter
	GT007 += Alltrim("                 END,                                                                             ") + msEnter
	GT007 += Alltrim("        HIST = ZN6.ZN6_HIST                                                                       ") + msEnter
	GT007 += Alltrim(" FROM " + RetSqlName("ZN6") + " ZN6(NOLOCK)                                                       ") + msEnter
	GT007 += Alltrim("      INNER JOIN " + RetSqlName("ZOY") + " ZOY(NOLOCK) ON ZOY.ZOY_VERSAO = ZN6.ZN6_VERCON         ") + msEnter
	GT007 += Alltrim("                                       AND ZOY.D_E_L_E_T_ = ' '                                   ") + msEnter
	GT007 += Alltrim("      INNER JOIN " + RetSqlName("CVE") + " CVE(NOLOCK) ON CVE.CVE_CODIGO = ZN6.ZN6_CODPLA         ") + msEnter
	GT007 += Alltrim("                                       AND CVE.D_E_L_E_T_ = ' '                                   ") + msEnter
	GT007 += Alltrim("      INNER JOIN " + RetSqlName("CVF") + " CVF(NOLOCK) ON CVF.CVF_CODIGO = ZN6.ZN6_CODPLA         ") + msEnter
	GT007 += Alltrim("                                       AND CVF.CVF_CONTAG = ZN6.ZN6_RUBVIS                        ") + msEnter
	GT007 += Alltrim("                                       AND CVF.D_E_L_E_T_ = ' '                                   ") + msEnter
	GT007 += Alltrim(" WHERE ZN6_FILIAL = '" + xFilial("ZN6") +  "'                                                     ") + msEnter
	GT007 += Alltrim("       AND ZN6_DATREF BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'               ") + msEnter
	GT007 += Alltrim("       AND ZN6.D_E_L_E_T_ = ' '                                                                   ") + msEnter
	GT007 += Alltrim(" ORDER BY ZN6.ZN6_CODPLA,                                                                         ") + msEnter
	GT007 += Alltrim("          CVF.CVF_YRFDRE,                                                                         ") + msEnter
	GT007 += Alltrim("          ZN6.ZN6_VERCON,                                                                         ") + msEnter
	GT007 += Alltrim("          ZN6.ZN6_OPERAC                                                                          ") + msEnter

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
			oExcel:AddCelula( GT07->EMPRESA                                 , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->FILIAL                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( stod(GT07->DATREF)                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->VERCON                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->DVERCON                                 , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->CODPLA                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->DCODPLA                                 , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->RFDRE                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->RUBRICA                                 , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->DRUBRICA                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->OPERACAO                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->DOPERACAO                               , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->VALOR                                   , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->TIPO1                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->DTIPO1                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( GT07->HIST                                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

			GT07->(dbSkip())

		End

		GT07->(dbCloseArea())
		Ferase(GTIndex+GetDBExtension())
		Ferase(GTIndex+OrdBagExt())

	EndIf

	xVerRet := lRet

Return( lRet )
