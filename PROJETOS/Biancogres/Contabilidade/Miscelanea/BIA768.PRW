#include 'protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA768
@author Marcos Alberto Soprani
@since 03/11/21
@version 1.0
@description Rotina para Extrair Excel da Planilha para Consolidação dos Expurgos - Novo Extrator
@type function
/*/

User Function BIA768()

	Local oProcess

	Private XX003
	Private RT002
	Private smMsnPrc
	Private hhTmpINI
	Private msrhEnter   := CHR(13) + CHR(10)

	If cEmpAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado.", "BIA768", "STOP")
		Return
	EndIf

	If cEmpAnt == "90" .and. cFilAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado, Filial 90, devido as amarrações com as tabelas origens.", "BIA768", "STOP")
		Return
	EndIf

	If xValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))
		xTpRelat := Substr(MV_PAR02, 1, 1)

		hhTmpINI  := TIME()
		smMsnPrc := "Processando geração de planilha em Excel"

		If xTpRelat == "1"
			oProcess := MsNewProcess():New({|lEnd| fExAn768(@oProcess) }, "Extraindo...", smMsnPrc, .T.)
		Else
			oProcess := MsNewProcess():New({|lEnd| fExSi768(@oProcess) }, "Extraindo...", smMsnPrc, .T.)
		EndIf
		oProcess:Activate()

	EndIf

Return

Static Function xValidPerg()

	Local cLoad	    := "BIA768" + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	Local xxCombo   := {"1=Analítico","2=Sintético"}
	Local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)
	MV_PAR02 :=	""

	aAdd( aPergs ,{1, "Ano/Mês"                    ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{2, "Tipo de Relatório"          ,MV_PAR02 ,xxCombo                      , 50, "", .T.})

	If ParamBox(aPergs ,"Extrair PPC",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02) 

	EndIf

Return lRet

Static Function fExAn768(oProcess)

	Local msrhEnter    := CHR(13) + CHR(10)

	Local nRegAtu    := 0
	Local cCab1Fon   := 'Calibri' 
	Local cCab1TamF  := 8   
	Local cCab1CorF  := '#FFFFFF'
	Local cCab1Fun   := '#4F81BD'

	Local cFonte1	 := 'Arial'
	Local nTamFont1	 := 12   
	Local cCorFont1  := '#FFFFFF'
	Local cCorFun1	 := '#4F81BD'

	Local cFonte2	 := 'Arial'
	Local nTamFont2	 := 8   
	Local cCorFont2  := '#000000'
	Local cCorFun2	 := '#B8CCE4'

	Local cEmpresa   := ""
	Local msVetColun := 31
	Local msNomeFunc := "BIA768" 

	Local cArqXML    := UPPER(Alltrim(msNomeFunc)) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	Private cDirDest := "c:\temp\"

	fTotalReg()

	TTIndex := CriaTrab(Nil,.f.)

	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,XX003),'UU001',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += XX003
		lRet := .F.
		Return
	EndIf

	dbSelectArea("UU001")
	dbGoTop()
	uuRegs := UU001->TOTREGS
	UU001->(dbCloseArea())
	Ferase(TTIndex+GetDBExtension())
	Ferase(TTIndex+OrdBagExt())

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(uuRegs)             

	cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio", {20, 70, 50, 50, 50, 50, 50, 50, 60, 70, 90, 30, 70, 30, 30, 40, 30, 30, 30, 30, 30, 40, 50, 30, 50, 70, 200, 70, 100, 50, 70, 150, 100}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Nova PPC - " + msNomeFunc, 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + msVetColun + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("DATPRC"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EMPORI"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILORI"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EMPDES"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILDES"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TABMOV"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ORIMOV"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DATMOV"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DOC"                , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("SERIE "             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CODPRD"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TIPONF"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CFOP"               , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("GRPPRD"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("YTPPRO"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CRDICM"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CALICM"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LFICM "             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DUPLIC"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("YCCONT"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CLIENT"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LOJA"               , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ESTADO"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ITCTA"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("HISLAN"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ROTINA"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("QUANT"              , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DC"                 , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TPMOV"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CONTA"              , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALOR"              , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	RT002 := U_BIA768Qy()

	QPIndex := CriaTrab(Nil,.f.)

	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT002),'QP001',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += RT002
		lRet := .F.
		Return
	EndIf

	dbSelectArea("QP001")
	dbGoTop()
	oProcess:SetRegua1(1)

	While !QP001->(Eof())

		oProcess:IncRegua2("Gerando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

		nRegAtu++
		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()
		oExcel:AddCelula( dtoc(stod(QP001->ZNC_DATPRC))                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_EMPORI                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_FILORI                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_EMPDES                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_FILDES                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_TABMOV                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_ORIMOV                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( dtoc(stod(QP001->ZNC_DATMOV))                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_DOC                                 , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_SERIE                               , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_CODPRD                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_TIPONF                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_CFOP                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_GRPPRD                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_YTPPRO                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_CRDICM                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_CALICM                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_LFICM                               , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_DUPLIC                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_YCCONT                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_CLIENT                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_LOJA                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_ESTADO                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_ITCTA                               , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_HISLAN                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_ROTINA                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_QUANT                               , 4 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->DC                                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->TPMOV                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CONTA                                   , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALOR                                   , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

		QP001->(dbSkip())

	End

	QP001->(dbCloseArea())
	Ferase(QPIndex+GetDBExtension())
	Ferase(QPIndex+OrdBagExt())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return

Static Function fExSi768(oProcess)

	Local msrhEnter    := CHR(13) + CHR(10)

	Local nRegAtu    := 0
	Local cCab1Fon   := 'Calibri' 
	Local cCab1TamF  := 8   
	Local cCab1CorF  := '#FFFFFF'
	Local cCab1Fun   := '#4F81BD'

	Local cFonte1	 := 'Arial'
	Local nTamFont1	 := 12   
	Local cCorFont1  := '#FFFFFF'
	Local cCorFun1	 := '#4F81BD'

	Local cFonte2	 := 'Arial'
	Local nTamFont2	 := 8   
	Local cCorFont2  := '#000000'
	Local cCorFun2	 := '#B8CCE4'

	Local cEmpresa   := ""
	Local msVetColun := 21
	Local msNomeFunc := "BIA768" 

	Local cArqXML    := UPPER(Alltrim(msNomeFunc)) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	Private cDirDest := "c:\temp\"

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(254)             

	cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio", {20, 50, 70, 50, 50, 50, 50, 50, 50, 50, 50, 60, 100, 70, 150, 50, 100, 100, 70}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + msVetColun + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Nova PPC - " + msNomeFunc, 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + msVetColun + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("ELEGIVEL"           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DATPRC"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EMPORI"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILORI"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("EMPDES"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FILDES"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TABMOV"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ORIMOV"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("GRPPRD"             , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DC"                 , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TPMOV"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CONTA"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ITCTA"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VALOR"              , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DC_EXPURGO"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_EXPURGO"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_CPV"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VLR_CPV"            , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CTA_RAI"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VLR_RAI"            , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VLR_GANHO"          , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	RT003 := U_BIA768Qy()

	RT002 := Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        DC,                                                                                                        ") + msrhEnter
	RT002 += Alltrim("        TPMOV,                                                                                                     ") + msrhEnter
	RT002 += Alltrim("        CONTA,                                                                                                     ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        VALOR = SUM(VALOR)                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM                                                                                                              ") + msrhEnter
	RT002 += Alltrim(" (                                                                                                                 ") + msrhEnter
	RT002 += RT003
	RT002 += Alltrim(" ) AS TEMP1                                                                                                        ") + msrhEnter
	RT002 += Alltrim(" GROUP BY ZNC_DATPRC,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_TABMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_ORIMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_GRPPRD,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          DC,                                                                                                      ") + msrhEnter
	RT002 += Alltrim("          TPMOV,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          CONTA,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          ZNC_ITCTA                                                                                                ") + msrhEnter
	RT002 += Alltrim(" ORDER BY ZNC_DATPRC,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          DC,                                                                                                      ") + msrhEnter
	RT002 += Alltrim("          TPMOV,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          ZNC_TABMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_ORIMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_GRPPRD,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          CONTA,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          ZNC_ITCTA                                                                                                ") + msrhEnter

	QPIndex := CriaTrab(Nil,.f.)

	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT002),'QP001',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += RT002
		lRet := .F.
		Return
	EndIf

	dbSelectArea("QP001")
	dbGoTop()
	oProcess:SetRegua1(1)

	While !QP001->(Eof())

		oProcess:IncRegua2("Gerando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

		nRegAtu++
		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		xDCExt    := ""
		xContaExt  := ""
		If !Empty(QP001->ZNC_EMPDES)
			xDCExt    := IIF(Substr(QP001->DC,1,1) == "1", "2-CREDITO", IIF(Substr(QP001->DC,1,1) == "2", "1-DEBITO", ""))
			xContaExt  := QP001->CONTA
		EndIf

		msCtaCPV := "41301001"
		msTpCPV  := 0
		msVlrCPV := 0
		If QP001->ZNC_TABMOV == "FAT" .and. QP001->ZNC_ORIMOV == "SAI"
			If QP001->TPMOV == "1-REC"
				msTpCPV  := 1
			Else
				msTpCPV  := -1
			EndIf 
		ElseIf QP001->ZNC_TABMOV == "FAT" .and. QP001->ZNC_ORIMOV == "DEV"
			If QP001->TPMOV == "1-REC"
				msTpCPV  := -1
			Else
				msTpCPV  := 1
			EndIf 
		ElseIf QP001->ZNC_TABMOV == "CTB"
			If QP001->TPMOV == "1-REC"
				msTpCPV  := 1
			Else
				msTpCPV  := -1
			EndIf 
		EndIf
		msVlrCPV := QP001->VALOR * msTpCPV

		msCtaRAI := ""
		msVlrRAI := 0
		msVlrGan := 0

		RJ004 := Alltrim(" SELECT CTARAI = ZNE_CTARAI,                                                                                     ") + msrhEnter
		RJ004 += Alltrim("        PERORI = ZNE_PERORI / 100,                                                                               ") + msrhEnter
		RJ004 += Alltrim("        PERDES = ZNE_PERDES / 100                                                                                ") + msrhEnter
		RJ004 += Alltrim(" FROM " + RetSqlName("ZNE") + " ZNE(NOLOCK)                                                                      ") + msrhEnter
		RJ004 += Alltrim(" WHERE ZNE_FILIAL = '" + xFilial("ZNE") + "'                                                                     ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_EMPORI = '" + QP001->ZNC_EMPORI + "'                                                              ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_EMPDES = '" + QP001->ZNC_EMPDES + "'                                                              ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_CONTA = '" + QP001->CONTA + "'                                                                    ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_TABMOV = '" + QP001->ZNC_TABMOV + "'                                                              ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_TPMOV = '" + Substr(QP001->TPMOV,1,1) + "'                                                        ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE.D_E_L_E_T_ = ' '                                                                                  ") + msrhEnter
		RJIndex := CriaTrab(Nil,.f.)
		lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,RJ004),'RJ04',.T.,.T.) },,.T.,,)
		If !lEvalBlock
			msErroQuery := "Problema: " + msrhEnter + msrhEnter
			msErroQuery += RJ004
			lRet := .F.
			Return
		EndIf

		RJ04->(dbGoTop())
		If !RJ04->(Eof())
			msCtaRAI := RJ04->CTARAI
			msVlrRAI := msVlrCPV * ( 1 - RJ04->PERORI )
			msVlrGan := ( msVlrCPV * ( 1 - RJ04->PERDES ) ) - msVlrRAI
		EndIf
		RJ04->(dbCloseArea())
		Ferase(RJIndex+GetDBExtension())
		Ferase(RJIndex+OrdBagExt())

		msElegivel := "Sim"
		If QP001->ZNC_FILDES $ "  /ER" 
			msElegivel := "Não"
		EndIf

		oExcel:AddLinha(14) 
		oExcel:AddCelula()
		oExcel:AddCelula( msElegivel                                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( dtoc(stod(QP001->ZNC_DATPRC))                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_EMPORI                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_FILORI                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_EMPDES                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_FILDES                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_TABMOV                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_ORIMOV                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_GRPPRD                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->DC                                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->TPMOV                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->CONTA                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->ZNC_ITCTA                               , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( QP001->VALOR                                   , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( xDCExt                                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( xContaExt                                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( msCtaCPV                                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( msVlrCPV                                       , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( msCtaRAI                                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( msVlrRAI                                       , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
		oExcel:AddCelula( msVlrGan                                       , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

		QP001->(dbSkip())

	End

	QP001->(dbCloseArea())
	Ferase(QPIndex+GetDBExtension())
	Ferase(QPIndex+OrdBagExt())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return

Static Function fTotalReg()

	XX003 := Alltrim(" SELECT TOTREGS = SUM(REGS)                                                                                         ") + msrhEnter
	XX003 += Alltrim(" FROM                                                                                                               ") + msrhEnter
	XX003 += Alltrim(" (                                                                                                                  ") + msrhEnter
	XX003 += Alltrim("     SELECT COUNT(*) REGS                                                                                           ") + msrhEnter
	XX003 += Alltrim("     FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                     ") + msrhEnter
	XX003 += Alltrim("     WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                    ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_VLRREC <> 0                                                                                      ") + msrhEnter
	XX003 += Alltrim("           AND ZNC.D_E_L_E_T_ = ' '                                                                                 ") + msrhEnter
	XX003 += Alltrim("     UNION ALL                                                                                                      ") + msrhEnter
	XX003 += Alltrim("     SELECT COUNT(*) REGS                                                                                           ") + msrhEnter
	XX003 += Alltrim("     FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                     ") + msrhEnter
	XX003 += Alltrim("     WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                    ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_VLRICM <> 0                                                                                      ") + msrhEnter
	XX003 += Alltrim("           AND ZNC.D_E_L_E_T_ = ' '                                                                                 ") + msrhEnter
	XX003 += Alltrim("     UNION ALL                                                                                                      ") + msrhEnter
	XX003 += Alltrim("     SELECT COUNT(*) REGS                                                                                           ") + msrhEnter
	XX003 += Alltrim("     FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                     ") + msrhEnter
	XX003 += Alltrim("     WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                    ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_VLRPIS <> 0                                                                                      ") + msrhEnter
	XX003 += Alltrim("           AND ZNC.D_E_L_E_T_ = ' '                                                                                 ") + msrhEnter
	XX003 += Alltrim("     UNION ALL                                                                                                      ") + msrhEnter
	XX003 += Alltrim("     SELECT COUNT(*) REGS                                                                                           ") + msrhEnter
	XX003 += Alltrim("     FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                     ") + msrhEnter
	XX003 += Alltrim("     WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                    ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_VLRCOF <> 0                                                                                      ") + msrhEnter
	XX003 += Alltrim("           AND ZNC.D_E_L_E_T_ = ' '                                                                                 ") + msrhEnter
	XX003 += Alltrim("     UNION ALL                                                                                                      ") + msrhEnter
	XX003 += Alltrim("     SELECT COUNT(*) REGS                                                                                           ") + msrhEnter
	XX003 += Alltrim("     FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                     ") + msrhEnter
	XX003 += Alltrim("     WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                    ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_VLRIPI <> 0                                                                                      ") + msrhEnter
	XX003 += Alltrim("           AND ZNC.D_E_L_E_T_ = ' '                                                                                 ") + msrhEnter
	XX003 += Alltrim("     UNION ALL                                                                                                      ") + msrhEnter
	XX003 += Alltrim("     SELECT COUNT(*) REGS                                                                                           ") + msrhEnter
	XX003 += Alltrim("     FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                     ") + msrhEnter
	XX003 += Alltrim("     WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                    ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                ") + msrhEnter
	XX003 += Alltrim("           AND ZNC_VLRCTB <> 0                                                                                      ") + msrhEnter
	XX003 += Alltrim("           AND ZNC.D_E_L_E_T_ = ' '                                                                                 ") + msrhEnter
	XX003 += Alltrim(" ) TEMP1                                                                                                            ") + msrhEnter

Return

User Function BIA768Qy()

	Local RT002 := ""

	RT002 := Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DATMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DOC,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("        ZNC_SERIE,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_CODPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TIPONF,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CFOP,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YTPPRO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CRDICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CALICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LFICM,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_DUPLIC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YCCONT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CLIENT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LOJA,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_ESTADO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_HISLAN,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ROTINA,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_QUANT,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        DC = CASE                                                                                                  ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'DEV'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '1-DEBITO'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'SAI'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '2-CREDITO'                                                                                  ") + msrhEnter
	RT002 += Alltrim("             END,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        TPMOV = '1-REC',                                                                                           ") + msrhEnter
	RT002 += Alltrim("        CONTA = ZNC_CTAREC,                                                                                        ") + msrhEnter
	RT002 += Alltrim("        VALOR = ZNC_VLRREC                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                        ") + msrhEnter
	RT002 += Alltrim(" WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                       ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                   ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_TABMOV = 'FAT'                                                                                      ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_VLRREC <> 0                                                                                         ") + msrhEnter
	RT002 += Alltrim("       AND ZNC.D_E_L_E_T_ = ' '                                                                                    ") + msrhEnter
	RT002 += Alltrim(" UNION ALL                                                                                                         ") + msrhEnter
	RT002 += Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DATMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DOC,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("        ZNC_SERIE,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_CODPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TIPONF,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CFOP,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YTPPRO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CRDICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CALICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LFICM,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_DUPLIC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YCCONT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CLIENT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LOJA,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_ESTADO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_HISLAN,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ROTINA,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_QUANT,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        DC = CASE                                                                                                  ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'SAI'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '1-DEBITO'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'DEV'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '2-CREDITO'                                                                                  ") + msrhEnter
	RT002 += Alltrim("             END,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        TPMOV = '2-ICM',                                                                                           ") + msrhEnter
	RT002 += Alltrim("        CONTA = ZNC_CTAICM,                                                                                        ") + msrhEnter
	RT002 += Alltrim("        VALOR = ZNC_VLRICM                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                        ") + msrhEnter
	RT002 += Alltrim(" WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                       ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                   ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_TABMOV = 'FAT'                                                                                      ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_VLRICM <> 0                                                                                         ") + msrhEnter
	RT002 += Alltrim("       AND ZNC.D_E_L_E_T_ = ' '                                                                                    ") + msrhEnter
	RT002 += Alltrim(" UNION ALL                                                                                                         ") + msrhEnter
	RT002 += Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DATMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DOC,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("        ZNC_SERIE,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_CODPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TIPONF,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CFOP,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YTPPRO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CRDICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CALICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LFICM,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_DUPLIC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YCCONT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CLIENT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LOJA,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_ESTADO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_HISLAN,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ROTINA,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_QUANT,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        DC = CASE                                                                                                  ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'SAI'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '1-DEBITO'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'DEV'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '2-CREDITO'                                                                                  ") + msrhEnter
	RT002 += Alltrim("             END,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        TPMOV = '3-PIS',                                                                                           ") + msrhEnter
	RT002 += Alltrim("        CONTA = ZNC_CTAPIS,                                                                                        ") + msrhEnter
	RT002 += Alltrim("        VALOR = ZNC_VLRPIS                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                        ") + msrhEnter
	RT002 += Alltrim(" WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                       ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                   ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_TABMOV = 'FAT'                                                                                      ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_VLRPIS <> 0                                                                                         ") + msrhEnter
	RT002 += Alltrim("       AND ZNC.D_E_L_E_T_ = ' '                                                                                    ") + msrhEnter
	RT002 += Alltrim(" UNION ALL                                                                                                         ") + msrhEnter
	RT002 += Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DATMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DOC,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("        ZNC_SERIE,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_CODPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TIPONF,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CFOP,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YTPPRO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CRDICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CALICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LFICM,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_DUPLIC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YCCONT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CLIENT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LOJA,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_ESTADO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_HISLAN,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ROTINA,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_QUANT,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        DC = CASE                                                                                                  ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'SAI'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '1-DEBITO'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'DEV'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '2-CREDITO'                                                                                  ") + msrhEnter
	RT002 += Alltrim("             END,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        TPMOV = '4-COF',                                                                                           ") + msrhEnter
	RT002 += Alltrim("        CONTA = ZNC_CTACOF,                                                                                        ") + msrhEnter
	RT002 += Alltrim("        VALOR = ZNC_VLRCOF                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                        ") + msrhEnter
	RT002 += Alltrim(" WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                       ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                   ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_TABMOV = 'FAT'                                                                                      ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_VLRCOF <> 0                                                                                         ") + msrhEnter
	RT002 += Alltrim("       AND ZNC.D_E_L_E_T_ = ' '                                                                                    ") + msrhEnter
	RT002 += Alltrim(" UNION ALL                                                                                                         ") + msrhEnter
	RT002 += Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DATMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DOC,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("        ZNC_SERIE,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_CODPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TIPONF,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CFOP,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YTPPRO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CRDICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CALICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LFICM,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_DUPLIC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YCCONT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CLIENT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LOJA,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_ESTADO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_HISLAN,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ROTINA,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_QUANT,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        DC = CASE                                                                                                  ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'SAI'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '1-DEBITO'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'DEV'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '2-CREDITO'                                                                                  ") + msrhEnter
	RT002 += Alltrim("             END,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        TPMOV = '5-IPI',                                                                                           ") + msrhEnter
	RT002 += Alltrim("        CONTA = ZNC_CTAIPI,                                                                                        ") + msrhEnter
	RT002 += Alltrim("        VALOR = ZNC_VLRIPI                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                        ") + msrhEnter
	RT002 += Alltrim(" WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                       ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                   ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_TABMOV = 'FAT'                                                                                      ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_VLRIPI <> 0                                                                                         ") + msrhEnter
	RT002 += Alltrim("       AND ZNC.D_E_L_E_T_ = ' '                                                                                    ") + msrhEnter
	RT002 += Alltrim(" UNION ALL                                                                                                         ") + msrhEnter
	RT002 += Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DATMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_DOC,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("        ZNC_SERIE,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_CODPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TIPONF,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CFOP,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YTPPRO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CRDICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CALICM,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LFICM,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_DUPLIC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_YCCONT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_CLIENT,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_LOJA,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        ZNC_ESTADO,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        ZNC_HISLAN,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ROTINA,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_QUANT,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        DC = CASE                                                                                                  ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'DEB'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '1-DEBITO'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                 WHEN ZNC_ORIMOV = 'CRD'                                                                           ") + msrhEnter
	RT002 += Alltrim("                 THEN '2-CREDITO'                                                                                  ") + msrhEnter
	RT002 += Alltrim("             END,                                                                                                  ") + msrhEnter
	RT002 += Alltrim("        TPMOV = CASE                                                                                               ") + msrhEnter
	RT002 += Alltrim("                    WHEN CT1_DESC01 LIKE '%ICM%'                                                                   ") + msrhEnter
	RT002 += Alltrim("                    THEN '2-ICM'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                    WHEN CT1_DESC01 LIKE '%PIS%'                                                                   ") + msrhEnter
	RT002 += Alltrim("                    THEN '3-PIS'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                    WHEN CT1_DESC01 LIKE '%COF%'                                                                   ") + msrhEnter
	RT002 += Alltrim("                    THEN '4-COF'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                    WHEN CT1_DESC01 LIKE '%IPI%'                                                                   ") + msrhEnter
	RT002 += Alltrim("                    THEN '5-IPI'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                    ELSE '1-REC'                                                                                   ") + msrhEnter
	RT002 += Alltrim("                END,                                                                                               ") + msrhEnter
	RT002 += Alltrim("        CONTA = ZNC_CTACTB,                                                                                        ") + msrhEnter
	RT002 += Alltrim("        VALOR = ZNC_VLRCTB                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM " + RetSqlName("ZNC") + " ZNC(NOLOCK)                                                                        ") + msrhEnter
	RT002 += Alltrim("      LEFT JOIN " + RetSqlName("CT1") + " CT1(NOLOCK) ON CT1.CT1_FILIAL = '" + xFilial("CT1") + "'                 ") + msrhEnter
	RT002 += Alltrim("                                       AND CT1.CT1_CONTA = ZNC.ZNC_CTACTB                                          ") + msrhEnter
	RT002 += Alltrim("                                       AND CT1.D_E_L_E_T_ = ' '                                                    ") + msrhEnter
	RT002 += Alltrim(" WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "'                                                                       ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_DATPRC = '" + dtos(dDataFin) + "'                                                                   ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_TABMOV = 'CTB'                                                                                      ") + msrhEnter
	RT002 += Alltrim("       AND ZNC_VLRCTB <> 0                                                                                         ") + msrhEnter
	RT002 += Alltrim("       AND ZNC.D_E_L_E_T_ = ' '                                                                                    ") + msrhEnter

Return ( RT002 )
