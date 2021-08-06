#INCLUDE "TOTVS.CH"
#Include "rwmake.ch"
#Include 'PROTHEUS.CH'
#Include "tbiconn.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIAPN001
@description Relatório para Análise de Fechamento Imobilizado
@author Pablo S. Nascimento
@since 26/07/2021
@version 1.0
@type function
/*/

User Function BIAPN003()
    
	Local oReport
	Private cPerg    := "BIAPN003"
	Private nEmp	 := ""

	// fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	
	fValidPerg()
	
	// If !Pergunte(cPerg,.T.)
	// 	Return
	// EndIf

	oReport:= ReportDef()
	oReport:PrintDialog()
Return

Static Function ReportDef()
    
	Local oReport
	Local oSection1
	Local cReport := "BIAPN003"
	lOCAL cTitulo := "Análise de Fechamento Imobilizado"

	cSql	:= getSql()
	
	IF chkfile("BIAPN003")
		dbSelectArea("BIAPN003")
		dbCloseArea()
	ENDIF

	TcQuery cSql New Alias "BIAPN003"
	DbSelectArea("BIAPN003")

	oReport:= TReport():New(cReport, cTitulo, , {|oReport| PrintReport(oReport)},"Análise de Fechamento Imobilizado")	
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
    
	oSection1 := TRSection():New(oReport,"Analise",{"BIAPN003"})    

	TRCell():New(oSection1,"CUSTO_QUANT"	 	,"BIAPN003", "Custo qtd" 				,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_TOTAL"	 		,"BIAPN003", "Total Item"			    ,/**/,10,,,,,"RIGHT")	
	TRCell():New(oSection1,"D1_DOC"	 	        ,"BIAPN003", "Documento"			    ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_CLVL"	        ,"BIAPN003", "Classe Valor"		        ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_DTDIGIT"	 	    ,"BIAPN003", "Dt. Digitacao"		    ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_MOEDA" 	        ,"BIAPN003", "Moeda"	                ,/**/,5 ,,,,,"RIGHT")
	TRCell():New(oSection1,"A2_NOME" 	        ,"BIAPN003", "Nome"	                    ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_DESCRI"          ,"BIAPN003", "C7 Descricao"	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"B1_DESC"            ,"BIAPN003", "B1 Descricao"	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"B1_UM"              ,"BIAPN003", "Un. Medida."	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_CF"              ,"BIAPN003", "CF"	                    ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_QUANT"           ,"BIAPN003", "Item Qtd"			        ,/**/,15,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_YDRIVER"         ,"BIAPN003", "Driver"	                ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_CONTA"           ,"BIAPN003", "Conta"	                ,/**/,50,,,,,"RIGHT")
	TRCell():New(oSection1,"CT1_DESC01"         ,"BIAPN003", "CT1 Descricao"	        ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_EMISSAO"         ,"BIAPN003", "Dt. Emissao"	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_OBS"             ,"BIAPN003", "Observacao"	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_YOBS"            ,"BIAPN003", "Obs 2"	                ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_NUM"             ,"BIAPN003", "Numero Ped."	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_NUMSC"           ,"BIAPN003", "Numero SC"	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"C7_YMAT"            ,"BIAPN003", "Matricula"	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_ITEMCTA"         ,"BIAPN003", "Item Conta"	            ,/**/,10,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_YCONTR"          ,"BIAPN003", "C7_YCONTR"	            ,/**/,50,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_YDRIVER"         ,"BIAPN003", "DRIVER"	                ,/**/,15,,,,,"RIGHT")
	TRCell():New(oSection1,"A2_CGC"             ,"BIAPN003", "CPF/CNPJ"	                ,/**/,20,,,,,"RIGHT")

Return oReport

Static Function getSql()
    Local cSql := ""

    cSQL := "SELECT D1_CUSTO/D1_QUANT CUSTO_QUANT, D1_TOTAL, D1_DOC, D1_CLVL, D1_DTDIGIT, C7_MOEDA, A2_NOME, D1_COD, C7_DESCRI, B1_DESC, B1_UM, D1_CF, D1_QUANT,            "
    cSQL += "C7_YDRIVER, D1_CONTA, CT1_DESC01, D1_EMISSAO, C7_OBS, C7_YOBS, C7_NUM, C7_NUMSC, C7_YMAT, D1_ITEMCTA, D1_YCONTR, D1_YDRIVER, A2_CGC                "
    cSQL += "FROM SD1010 SD1                                                                                                                                    "
    cSQL += "INNER JOIN SB1010 SB1 ON SD1.D1_COD     = B1_COD AND SB1.D_E_L_E_T_ = ''                                                                           "
    //AND B1_DESC LIKE '%LENOVO%'                                                                                                                                 
    cSQL += "LEFT JOIN SC7010 SC7  ON SD1.D1_PEDIDO  = C7_NUM AND SD1.D1_ITEMPC = C7_ITEM AND SC7.D_E_L_E_T_ = ''                                               "
    //--AND C7_DESCRI LIKE '%WINSRV%' --AND NOT C7_DESCRI IS NULL   
    cSQL += "INNER JOIN SA2010 SA2 ON SD1.D1_FORNECE = A2_COD AND SD1.D1_LOJA = A2_LOJA   AND SA2.D_E_L_E_T_ = '' " //AND A2_NOME LIKE '%INGRAM%'                   "
    cSQL += "INNER JOIN CT1010 CT1 ON CT1.CT1_CONTA  = D1_CONTA AND SB1.D_E_L_E_T_ = ''                                                                         "

    cSQL += "WHERE D1_DTDIGIT BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'                                                                     "
    cSQL += "AND SUBSTRING(D1_CLVL,1,4) BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'                                                                       "
    cSQL += "AND A2_COD BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'                                                                                       "
    cSQL += "AND D1_DOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'																						"
	cSQL += "AND D1_YDRIVER BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'																					"
	    // --AND D1_COD IN ('2016513')
    cSQL += "AND SUBSTRING(D1_CONTA,1,8)  BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "'																	"

    If (!Empty(AllTrim(MV_PAR05)))
        cSQL += "AND D1_TOTAL >= '" + MV_PAR05 + "'                                                             "
    EndIf

    If (!Empty(AllTrim(MV_PAR06)))
        cSQL += "AND D1_TOTAL <= '" + MV_PAR06 + "'                                                             "
    EndIf

    cSQL += "AND D1_QUANT <> 0
    cSQL += "AND SD1.D_E_L_E_T_ = ''
    cSQL += "ORDER BY D1_DTDIGIT

return cSql

Static Function PrintReport(oReport)
	
	Local oSection1 := oReport:Section(1)
	
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	
	DbSelectArea("BIAPN003")
	dbGoTop()
	
	oReport:SetMeter(BIAPN003->(RecCount()))
	// oSection1:Init()

  	While BIAPN003->(!Eof())

		lImprime := .T.
		
		If oReport:Cancel()
			Exit
		EndIf  
	
		oReport:IncMeter()

		oSection1:PrintLine()
		BIAPN003->(DBSKIP())
	End
	
    BIAPN003->(dbCloseArea())
    
	oSection1:Finish()

Return

Static Function ExportarExcel()

    Local cSQL := ""
	Local cQry := "cQry"
	Local oExcel := nil
	
	//RpcSetType(3)
	//RpcSetEnv("01","01")
	
	If !fValidPerg()
		Return
	EndIf

    oExcel := FWMSEXCEL():New()
	
	nxPlan := "Planilha 01" //nome da planilha
	nxTabl := "Análise de Fechamento Imobilizado - Período " + DTOC(MV_PAR01) + " - " + DTOC(MV_PAR02) //nome no header da tabela
	
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	
	//adicionando colunas
	oExcel:AddColumn(nxPlan, nxTabl, "Custo por Quantidade"		,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Total Item"				,1,4)
    oExcel:AddColumn(nxPlan, nxTabl, "Documento"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Classe Valor"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Dt. Digitacao"			,1,1)
    //oExcel:AddColumn(nxPlan, nxTabl, "Moeda"					,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Nome"						,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "C7 Descricao"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "B1 Descricao"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Un. Medida"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "CF"						,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Item Quantidade"			,1,4)
    oExcel:AddColumn(nxPlan, nxTabl, "Driver"					,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Conta"					,1,4)
    oExcel:AddColumn(nxPlan, nxTabl, "CT1 Descricao"			,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Dt. Emissao"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Observacao"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Obs 2"					,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Numero Ped."				,1,1)
    //oExcel:AddColumn(nxPlan, nxTabl, "Numero SC"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "Matricula"				,1,1)
    //oExcel:AddColumn(nxPlan, nxTabl, "Item Conta"				,1,1)
    //oExcel:AddColumn(nxPlan, nxTabl, "C7_YCONTR"				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "DRIVER"   				,1,1)
    oExcel:AddColumn(nxPlan, nxTabl, "CPF/CNPJ"					,1,4)
	
    cSql := getSql()

	TcQUERY cSQL New ALIAS cQry

	While (cQry)->(!Eof())			

    oExcel:AddRow(nxPlan, nxTabl, { cQry->CUSTO_QUANT,;
                                    cQry->D1_TOTAL,;
                                    cQry->D1_DOC,;
                                    cQry->D1_CLVL,;
                                    cQry->D1_DTDIGIT,;
                                    cQry->A2_NOME,;
                                    cQry->C7_DESCRI,;
                                    cQry->B1_DESC,;
                                    cQry->B1_UM,;
                                    cQry->D1_CF,;
                                    cQry->D1_QUANT,;
                                    cQry->C7_YDRIVER,;
                                    cQry->D1_CONTA,;
                                    cQry->CT1_DESC01,;
                                    cQry->D1_EMISSAO,;
                                    cQry->C7_OBS,;
                                    cQry->C7_YOBS,;
                                    cQry->C7_NUM,;
                                    cQry->C7_YMAT,;
                                    cQry->D1_YDRIVER,;
                                    cQry->A2_CGC})
	
		cQry->(DbSkip())

	End
	
	cQry->(dbCloseArea())
	Gravar(oExcel)
Return

Static Function Gravar(oExcel)
		
	xArqTemp := "Fechamento_imob_" + dtos(MV_PAR01)+"_"+ dtos(MV_PAR02)
	caminho := "C:\TEMP\"+xArqTemp+".xml"
	
	If File(caminho)
		If fErase(caminho) == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + caminho + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf
	
	oExcel:Activate()
	oExcel:GetXMLFile(caminho)
	
	/* abrir automaticamente no Excel - se for chamado de um job, comentar esse trecho*/
	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+caminho )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open(caminho) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

Static Function fValidPerg()

	local cLoad	    := "BIAPN003"
	local cFileName := RetCodUsr() + "_AnaliseFechamentoImob_"+cEmpAnt
	local lRet		:= .F.

    private aPergs := {}

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := '    '
    MV_PAR04 := '    '
    MV_PAR05 := '        '
    MV_PAR06 := '        '
    MV_PAR07 := '      '
    MV_PAR08 := '      '
	MV_PAR09 := '         '
    MV_PAR10 := 'ZZZZZZZZZ'
    MV_PAR11 := '         '
    MV_PAR12 := 'ZZZZZZZZZ'
	MV_PAR13 := '        '
    MV_PAR14 := 'ZZZZZZZZ'
	
	aAdd( aPergs ,{1,"Dt Digitacao de ", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	
	aAdd( aPergs ,{1,"Dt Digitacao ate   ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Classe de Valor de ", MV_PAR03, "", 		, 'CTH', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Classe de Valor ate ", MV_PAR04, "", 		, 'CTH', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Valor total min ", MV_PAR05, "@E 99999999", 		, '', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Valor total max ", MV_PAR06, "@E 99999999", 		, '', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Fornecedor de ", MV_PAR07, "", 		, 'SA2', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Fornecedor ate ", MV_PAR08, "", 		, 'SA2', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Documento de ", MV_PAR09, "@", 		, '', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Documento ate ", MV_PAR10, "@", 		, '', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Driver de ", MV_PAR11, "", 		, '', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Driver ate ", MV_PAR12, "", 		, '', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Conta de ", MV_PAR13, "", 		, '', '.T.', 50, .F.})
    aAdd( aPergs ,{1,"Conta ate ", MV_PAR14, "", 		, '', '.T.', 50, .F.})

	If ParamBox(aPergs ,"Analise de Fechamento Imobilizado",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
        MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
        MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
        MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)
        MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07)
        MV_PAR08 := ParamLoad(cFileName,,8,MV_PAR08)
		MV_PAR09 := ParamLoad(cFileName,,9,MV_PAR09)
        MV_PAR10 := ParamLoad(cFileName,,10,MV_PAR10)
        MV_PAR11 := ParamLoad(cFileName,,11,MV_PAR11)
        MV_PAR12 := ParamLoad(cFileName,,12,MV_PAR12)
		MV_PAR13 := ParamLoad(cFileName,,13,MV_PAR13)
        MV_PAR14 := ParamLoad(cFileName,,14,MV_PAR14)
		
		MV_PAR05 := Alltrim(MV_PAR05)
        MV_PAR06 := Alltrim(MV_PAR06)

		MV_PAR03 := PadL(Alltrim(MV_PAR03), 4, ' ')
        MV_PAR04 := PadL(Alltrim(MV_PAR04), 4, ' ')
		
		// if(!Empty(Alltrim(MV_PAR03)))
		// 	MV_PAR03 := SUBSTR(MV_PAR03, 3, 6)
		// endif

	EndIf
Return lRet
